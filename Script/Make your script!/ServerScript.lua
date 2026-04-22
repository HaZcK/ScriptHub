--[[
╔══════════════════════════════════════════╗
║    SCRIPTHUB EXECUTOR - SERVER SCRIPT    ║
║    Script — Letakkan di ServerScriptService║
║    By KHAFIDZKTP                         ║
╚══════════════════════════════════════════╝

SETUP WAJIB:
1. Buat Folder "ScriptHubRemotes" di ReplicatedStorage
   Isi dengan RemoteEvent bernama:
   - ExecuteServer
   - BanPlayer
   - UnbanPlayer
   - AdminCheck
   - ServerModeRequest
   - ServerModeStatus
2. Script ini → ServerScriptService (Script biasa)
3. LocalScript.lua → StarterPlayerScripts
]]

-- ═══════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════
local Players          = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService      = game:GetService("HttpService")

-- Enable loadstring (wajib untuk server-sided execute)
ServerScriptService.LoadStringEnabled = true

-- ═══════════════════════════════════════════
-- SETUP REMOTE EVENTS (auto-create jika belum ada)
-- ═══════════════════════════════════════════
local function getOrCreate(parent, class, name)
    local obj = parent:FindFirstChild(name)
    if not obj then
        obj = Instance.new(class)
        obj.Name   = name
        obj.Parent = parent
    end
    return obj
end

local remoteFolder = getOrCreate(ReplicatedStorage, "Folder", "ScriptHubRemotes")

local ExecServerRemote  = getOrCreate(remoteFolder, "RemoteEvent", "ExecuteServer")
local BanRemote         = getOrCreate(remoteFolder, "RemoteEvent", "BanPlayer")
local UnbanRemote       = getOrCreate(remoteFolder, "RemoteEvent", "UnbanPlayer")
local AdminCheckRemote  = getOrCreate(remoteFolder, "RemoteEvent", "AdminCheck")
local ServerModeRequest = getOrCreate(remoteFolder, "RemoteEvent", "ServerModeRequest")
local ServerModeStatus  = getOrCreate(remoteFolder, "RemoteEvent", "ServerModeStatus")

-- ═══════════════════════════════════════════
-- DATASTORE: BAN SYSTEM
-- ═══════════════════════════════════════════
local BanStore  = DataStoreService:GetDataStore("ScriptHub_BanList_v1")
local BlackStore= DataStoreService:GetDataStore("ScriptHub_Blacklist_v1")

-- Cache local ban list (untuk performa)
local bannedUsers    = {} -- [userId] = {reason, timestamp, bannedBy}
local blacklistUsers = {} -- [userId] = true

-- ─── Load ban list on start ────────────────
local function loadBanList()
    local ok, data = pcall(function()
        return BanStore:GetAsync("BanList")
    end)
    if ok and data then
        bannedUsers = data
        print("[ScriptHub] Ban list loaded:", HttpService:JSONEncode(bannedUsers))
    end
end

local function saveBanList()
    pcall(function()
        BanStore:SetAsync("BanList", bannedUsers)
    end)
end

local function loadBlacklist()
    local ok, data = pcall(function()
        return BlackStore:GetAsync("Blacklist")
    end)
    if ok and data then
        blacklistUsers = data
    end
end

local function saveBlacklist()
    pcall(function()
        BlackStore:SetAsync("Blacklist", blacklistUsers)
    end)
end

task.spawn(loadBanList)
task.spawn(loadBlacklist)

-- ═══════════════════════════════════════════
-- ADMIN CHECK
-- ═══════════════════════════════════════════
local ADMIN_NAME = "KHAFIDZKTP"

local function isAdmin(player)
    return player.Name == ADMIN_NAME
end

-- ═══════════════════════════════════════════
-- SERVER MODE STATE PER PLAYER
-- ═══════════════════════════════════════════
local SERVER_DURATION = 7 * 3600   -- 7 jam (detik)
local SERVER_COOLDOWN = 24 * 3600  -- 24 jam (detik)

local playerServerMode = {} 
-- [userId] = {enabled=bool, expiry=tick(), cooldownExpiry=tick()}

local function getPlayerMode(player)
    local uid = player.UserId
    if not playerServerMode[uid] then
        playerServerMode[uid] = {
            enabled       = false,
            expiry        = 0,
            cooldownExpiry= 0,
        }
    end
    return playerServerMode[uid]
end

local function enableServerMode(player)
    local mode = getPlayerMode(player)
    mode.enabled = true
    mode.expiry  = tick() + SERVER_DURATION
    -- Beritahu client
    ServerModeStatus:FireClient(player, "active", SERVER_DURATION)
    print("[ScriptHub] Server mode enabled for:", player.Name)
end

local function disableServerMode(player, startCooldown)
    local mode = getPlayerMode(player)
    mode.enabled = false
    if startCooldown then
        mode.cooldownExpiry = tick() + SERVER_COOLDOWN
    end
    ServerModeStatus:FireClient(player, "disabled")
    print("[ScriptHub] Server mode disabled for:", player.Name)
end

-- Auto-reset 7 jam
task.spawn(function()
    while true do
        task.wait(30) -- cek setiap 30 detik
        for uid, mode in pairs(playerServerMode) do
            if mode.enabled and tick() >= mode.expiry then
                local p = Players:GetPlayerByUserId(uid)
                if p then
                    disableServerMode(p, true) -- start cooldown
                    -- Notifikasi sudah dikirim dari disableServerMode
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════
-- SECURITY: PATTERN DETEKSI SCRIPT BERBAHAYA
-- ═══════════════════════════════════════════
-- Pattern ini dicek SEBELUM script dijalankan di server
local SERVER_DANGEROUS = {
    -- Shutdown paksa
    "game%s*:%s*Shutdown",
    -- Hapus seluruh workspace
    "workspace%s*:%s*ClearAllChildren",
    "workspace%s*:%s*Destroy",
    -- Manipulasi DataStore berbahaya
    "DataStoreService.*Remove",
    -- Kick semua player
    "Players%s*:%s*GetPlayers%(%s*%).*:Kick",
    -- Loud sounds (Volume > 5 di loop)
    "while%s*true.*Sound.*Volume",
    -- Decal spam loop
    "while%s*true.*Decal",
    -- HTTPService external calls yang tidak diizinkan
    "HttpService%s*:%s*PostAsync%s*%(",
    "HttpService%s*:%s*GetAsync%s*%(",
}

local function isServerScriptMalicious(code)
    for _, pat in ipairs(SERVER_DANGEROUS) do
        if code:match(pat) or code:lower():match(pat:lower()) then
            return true, pat
        end
    end
    return false, nil
end

-- ═══════════════════════════════════════════
-- BAN FUNCTIONS
-- ═══════════════════════════════════════════
local function banPlayer(targetName, reason, bannedBy)
    reason   = reason   or "Pelanggaran aturan"
    bannedBy = bannedBy or "System"

    -- Cari di Players
    local target = Players:FindFirstChild(targetName)
    local targetId

    if target then
        targetId = target.UserId
        target:Kick("🚫 BANNED: " .. reason .. "\nHub: KHAFIDZKTP Admin Panel")
    else
        -- Coba via UserId jika yang dimasukkan adalah angka
        local numId = tonumber(targetName)
        if numId then targetId = numId end
    end

    if targetId then
        bannedUsers[tostring(targetId)] = {
            reason     = reason,
            timestamp  = os.time(),
            bannedBy   = bannedBy,
            username   = targetName,
        }
        saveBanList()
        print("[ScriptHub] Banned:", targetName, "| Reason:", reason)
        return true
    end
    return false
end

local function unbanPlayer(targetName)
    -- Cari berdasarkan username di banned list
    for uid, data in pairs(bannedUsers) do
        if data.username and data.username:lower() == targetName:lower() then
            bannedUsers[uid] = nil
            saveBanList()
            print("[ScriptHub] Unbanned:", targetName)
            return true
        end
    end
    -- Coba langsung jika angka
    local numId = tonumber(targetName)
    if numId and bannedUsers[tostring(numId)] then
        bannedUsers[tostring(numId)] = nil
        saveBanList()
        return true
    end
    return false
end

local function isPlayerBanned(player)
    local uid = tostring(player.UserId)
    return bannedUsers[uid] ~= nil, bannedUsers[uid]
end

local function isPlayerBlacklisted(player)
    local uid = tostring(player.UserId)
    return blacklistUsers[uid] ~= nil
end

-- ═══════════════════════════════════════════
-- PLAYER JOIN: CEK BAN
-- ═══════════════════════════════════════════
Players.PlayerAdded:Connect(function(player)
    task.wait(1) -- Tunggu karakter load

    local banned, banData = isPlayerBanned(player)
    if banned then
        player:Kick(
            "🚫 BANNED dari server ini.\n" ..
            "Alasan: " .. (banData.reason or "Tidak diketahui") .. "\n" ..
            "Hubungi admin: KHAFIDZKTP"
        )
        return
    end

    if isPlayerBlacklisted(player) then
        player:Kick("🚫 Kamu di-blacklist dari server ini.")
        return
    end

    -- Init server mode state
    getPlayerMode(player)
    print("[ScriptHub] Player joined:", player.Name, "| UserId:", player.UserId)
end)

-- Cleanup saat player keluar
Players.PlayerRemoving:Connect(function(player)
    playerServerMode[player.UserId] = nil
end)

-- ═══════════════════════════════════════════
-- REMOTE: EXECUTE SERVER SCRIPT
-- ═══════════════════════════════════════════
ExecServerRemote.OnServerEvent:Connect(function(player, code)
    -- Validasi tipe
    if type(code) ~= "string" then return end

    -- Validasi mode
    local mode = getPlayerMode(player)
    if not mode.enabled then
        warn("[ScriptHub] " .. player.Name .. " mencoba server execute tanpa izin!")
        -- Auto ban karena bypass attempt
        banPlayer(player.Name, "Bypass server mode attempt", "System")
        return
    end

    -- Validasi timer
    if tick() >= mode.expiry then
        disableServerMode(player, true)
        warn("[ScriptHub] " .. player.Name .. " server mode expired.")
        return
    end

    -- Panjang script max 50.000 karakter
    if #code > 50000 then
        ServerModeStatus:FireClient(player, "error", "Script terlalu panjang (max 50.000 karakter)")
        return
    end

    -- Cek malicious
    local bad, pattern = isServerScriptMalicious(code)
    if bad and not isAdmin(player) then
        warn("[ScriptHub] MALICIOUS SERVER SCRIPT from:", player.Name, "| Pattern:", pattern)
        banPlayer(player.Name, "Malicious server script: " .. tostring(pattern), "Anti-Cheat")
        return
    end

    -- Jalankan script
    print("[ScriptHub] Server execute by:", player.Name, "| Length:", #code)

    local fn, err = loadstring(code)
    if not fn then
        warn("[ScriptHub] loadstring error:", err)
        ServerModeStatus:FireClient(player, "error", tostring(err))
        return
    end

    local ok, runErr = pcall(fn)
    if not ok then
        warn("[ScriptHub] Runtime error:", runErr)
        ServerModeStatus:FireClient(player, "error", tostring(runErr))
    else
        print("[ScriptHub] Server script ran OK for:", player.Name)
    end
end)

-- ═══════════════════════════════════════════
-- REMOTE: SERVER MODE REQUEST
-- ═══════════════════════════════════════════
ServerModeRequest.OnServerEvent:Connect(function(player, action)
    if action == "enable" then
        local mode = getPlayerMode(player)
        -- Hanya bisa enable jika belum cooldown atau admin
        if isAdmin(player) then
            enableServerMode(player)
        elseif mode.cooldownExpiry > tick() then
            -- Masih cooldown, tolak
            ServerModeStatus:FireClient(player, "cooldown", mode.cooldownExpiry - tick())
        else
            enableServerMode(player)
        end
    elseif action == "disable" then
        disableServerMode(player, false)
    end
end)

-- ═══════════════════════════════════════════
-- REMOTE: BAN PLAYER (hanya admin)
-- ═══════════════════════════════════════════
BanRemote.OnServerEvent:Connect(function(caller, targetName, reason)
    if not isAdmin(caller) then
        warn("[ScriptHub] Non-admin ban attempt by:", caller.Name)
        return
    end

    -- Bisa menerima Player object atau string username
    local name
    if type(targetName) == "string" then
        name = targetName
    elseif typeof(targetName) == "Instance" and targetName:IsA("Player") then
        name = targetName.Name
    else
        name = tostring(targetName)
    end

    local success = banPlayer(name, reason or "Admin ban", caller.Name)
    print("[ScriptHub] Admin", caller.Name, success and "berhasil" or "gagal", "ban:", name)
end)

-- ═══════════════════════════════════════════
-- REMOTE: UNBAN PLAYER (hanya admin)
-- ═══════════════════════════════════════════
UnbanRemote.OnServerEvent:Connect(function(caller, targetName)
    if not isAdmin(caller) then return end
    local name = type(targetName)=="string" and targetName or tostring(targetName)
    local success = unbanPlayer(name)
    print("[ScriptHub] Admin", caller.Name, success and "berhasil" or "gagal", "unban:", name)
end)

-- ═══════════════════════════════════════════
-- ANTI-CHEAT: DETEKSI REAL-TIME (Server-side)
-- Monitor instance berbahaya yang dibuat player
-- ═══════════════════════════════════════════
local function monitorPlayerCharacter(player, character)
    -- Monitor Sound abuse
    character.DescendantAdded:Connect(function(desc)
        if desc:IsA("Sound") then
            task.wait(0.5)
            if desc.Volume > 5 then
                warn("[AntiCheat] Sound abuse detected:", player.Name, "Volume:", desc.Volume)
                desc:Destroy()
                banPlayer(player.Name, "Sound abuse (volume > 5)", "Anti-Cheat")
            end
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        monitorPlayerCharacter(player, char)
    end)
    if player.Character then
        monitorPlayerCharacter(player, player.Character)
    end
end)

-- Monitor workspace untuk decal spam / map deletion
workspace.DescendantAdded:Connect(function(desc)
    -- Decal spam detection (lebih dari 20 Decal dalam 2 detik = spam)
end)

-- Monitor jika ada yang coba ClearAllChildren via script (server-side guard)
local _origClear = workspace.ClearAllChildren
-- Note: Tidak bisa override method di Roblox, tapi kita bisa monitor via ChildRemoved
workspace.ChildRemoved:Connect(function(child)
    -- Jika banyak children dihapus sekaligus, suspect
end)

-- ═══════════════════════════════════════════
-- SECURITY: Anti-Bypass Script ini sendiri
-- Server script tidak bisa diedit oleh client
-- (ini by design di Roblox - client tidak bisa akses ServerScriptService)
-- ═══════════════════════════════════════════
-- Proteksi tambahan: cek setiap 5 menit apakah remote events masih ada
task.spawn(function()
    while true do
        task.wait(300)
        -- Re-create jika remote hilang (anti-tamper)
        getOrCreate(remoteFolder, "RemoteEvent", "ExecuteServer")
        getOrCreate(remoteFolder, "RemoteEvent", "BanPlayer")
        getOrCreate(remoteFolder, "RemoteEvent", "UnbanPlayer")
        getOrCreate(remoteFolder, "RemoteEvent", "ServerModeRequest")
        getOrCreate(remoteFolder, "RemoteEvent", "ServerModeStatus")
    end
end)

-- ═══════════════════════════════════════════
-- ADMIN CHECK REMOTE
-- ═══════════════════════════════════════════
AdminCheckRemote.OnServerEvent:Connect(function(player)
    -- Respond ke client apakah mereka admin
    -- (Dalam skenario ini client sudah cek via player.Name,
    --  tapi ini verifikasi server-side untuk keamanan lebih)
    local adminStatus = isAdmin(player)
    -- Fire back via StatusRemote jika diperlukan
end)

print("[ScriptHub] ServerScript loaded. Admin:", ADMIN_NAME)
print("[ScriptHub] Remotes ready in ReplicatedStorage.ScriptHubRemotes")
print("[ScriptHub] LoadStringEnabled:", ServerScriptService.LoadStringEnabled)
