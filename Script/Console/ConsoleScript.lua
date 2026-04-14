-- ╔══════════════════════════════════════════════════════════════╗
-- ║   ConsoleScript  ─  SERVER BRIDGE for Console Used v2.0     ║
-- ║   Taruh di: ServerScriptService                              ║
-- ║   Fungsi: Mengaktifkan SERVER mode di ConsoleUsed            ║
-- ╚══════════════════════════════════════════════════════════════╝

-- Cara install:
-- 1. Buka Roblox Studio di game kamu
-- 2. Insert Script ke ServerScriptService
-- 3. Rename jadi "ConsoleScript"
-- 4. Paste kode ini
-- 5. Publish game

local RS = game:GetService("ReplicatedStorage")

-- Buat RemoteEvent bridge
local CUBridge = Instance.new("RemoteEvent")
CUBridge.Name = "CU_Bridge"
CUBridge.Parent = RS

-- Bridge relay:
-- Semua pesan dari client A → server → forward ke client B
-- Server tidak menyimpan data, hanya relay
CUBridge.OnServerEvent:Connect(function(sender, msgType, targetUID, data)

    -- Cari target player
    local targetPlayer = game.Players:GetPlayerByUserId(targetUID)
    if not targetPlayer then return end
    if targetPlayer == sender then return end  -- no self-loop

    if msgType == "PERMISSION_REQUEST" then
        -- Sender minta izin ke target
        CUBridge:FireClient(targetPlayer,
            "PERMISSION_REQUEST",
            sender.UserId,
            sender.Name,
            nil
        )

    elseif msgType == "PERMISSION_RESPONSE" then
        -- Target membalas ke sender (targetUID di sini adalah sender aslinya)
        local requester = game.Players:GetPlayerByUserId(targetUID)
        if requester then
            CUBridge:FireClient(requester,
                "PERMISSION_RESPONSE",
                sender.UserId,
                sender.Name,
                data  -- true/false
            )
        end

    elseif msgType == "CONTROL_UPDATE" then
        -- Kirim update posisi ke target player
        if typeof(data) == "Vector3" then
            CUBridge:FireClient(targetPlayer,
                "CONTROL_UPDATE",
                sender.UserId,
                sender.Name,
                data
            )
        end
    end

end)

print("[ConsoleScript] Server bridge ready. CU_Bridge created in ReplicatedStorage.")
