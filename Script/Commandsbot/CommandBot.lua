-- ╔══════════════════════════════════════════╗
-- ║       CommandBot  |  by KHAFIDZKTP       ║
-- ║         Rayfield UI  |  Delta Ready      ║
-- ╚══════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ══════════════ SERVICES ══════════════
local Players        = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService     = game:GetService("RunService")
local LP             = Players.LocalPlayer

-- ══════════════ STATE ══════════════
local botEnabled     = false
local customCommands = {}   -- [".cmdname"] = "lua script string"
local followThread   = nil
local followTarget   = nil
local chatConn       = nil

-- ══════════════ SEND CHAT ══════════════
local function sendChat(msg)
    local sent = false
    -- Try TextChatService (New Chat)
    pcall(function()
        local TCS = game:GetService("TextChatService")
        if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
            local ch = TCS.TextChannels:FindFirstChild("RBXGeneral")
            if ch then
                ch:SendAsync(msg)
                sent = true
            end
        end
    end)
    -- Fallback: Legacy Chat
    if not sent then
        pcall(function()
            game:GetService("ReplicatedStorage")
                .DefaultChatSystemChatEvents
                .SayMessageRequest:FireServer(msg, "All")
        end)
    end
end

-- ══════════════ BUILT-IN: STOP FOLLOW ══════════════
local function stopFollow()
    if followThread then
        task.cancel(followThread)
        followThread = nil
    end
    followTarget = nil
    local char = LP.Character
    if char then
        local h   = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if h and hrp then h:MoveTo(hrp.Position) end
    end
end

-- ══════════════ BUILT-IN COMMANDS ══════════════

local function cmd_teleport(args)
    local name = args[1]
    if not name then sendChat("[Bot] Usage: .teleport (username)") return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and (
            p.Name:lower():find(name:lower(), 1, true) or
            p.DisplayName:lower():find(name:lower(), 1, true)
        ) then
            local myChar = LP.Character
            local tChar  = p.Character
            if myChar and tChar then
                local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                local tHRP  = tChar:FindFirstChild("HumanoidRootPart")
                if myHRP and tHRP then
                    myHRP.CFrame = tHRP.CFrame * CFrame.new(3, 0, 0)
                    sendChat("[Bot] Teleported to " .. p.Name)
                    return
                end
            end
        end
    end
    sendChat("[Bot] Player not found: " .. name)
end

local function cmd_tools(args)
    local id = tonumber(args[1])
    if not id then sendChat("[Bot] Usage: .tools (assetid)") return end
    local ok, err = pcall(function()
        local model = game:GetService("InsertService"):LoadAsset(id)
        local tool  = model:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = LP.Backpack
            sendChat("[Bot] Tool loaded!")
        else
            sendChat("[Bot] No Tool found in asset " .. id)
        end
        model:Destroy()
    end)
    if not ok then sendChat("[Bot] Error: " .. tostring(err)) end
end

local function cmd_follow(args)
    local name = args[1]
    if not name then sendChat("[Bot] Usage: .follow (username)") return end

    stopFollow()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and (
            p.Name:lower():find(name:lower(), 1, true) or
            p.DisplayName:lower():find(name:lower(), 1, true)
        ) then
            followTarget = p
            break
        end
    end

    if not followTarget then
        sendChat("[Bot] Player not found: " .. name)
        return
    end

    sendChat("[Bot] Following " .. followTarget.Name .. " | .unfollow to stop")

    followThread = task.spawn(function()
        while followTarget do
            task.wait(0.4)

            local myChar  = LP.Character
            local tChar   = followTarget.Character
            if not myChar or not tChar then task.wait(1) end
            if not myChar or not tChar then break end

            local myHRP = myChar:FindFirstChild("HumanoidRootPart")
            local tHRP  = tChar:FindFirstChild("HumanoidRootPart")
            local hum   = myChar:FindFirstChildOfClass("Humanoid")

            if not myHRP or not tHRP or not hum then task.wait(0.5) end
            if not myHRP or not tHRP or not hum then break end

            local dist = (myHRP.Position - tHRP.Position).Magnitude
            if dist <= 5 then task.wait(0.3) end
            if dist <= 5 then break end  -- inner loop break won't work, use goto pattern

            -- Compute path
            local path = PathfindingService:CreatePath({
                AgentRadius  = 2,
                AgentHeight  = 5,
                AgentCanJump = true,
                AgentMaxSlope = 45,
            })

            local ok = pcall(function()
                path:ComputeAsync(myHRP.Position, tHRP.Position)
            end)

            if ok and path.Status == Enum.PathStatus.Success then
                local waypoints = path:GetWaypoints()
                for _, wp in ipairs(waypoints) do
                    if not followTarget then break end
                    local newTHRP = (followTarget.Character or {}):FindFirstChild("HumanoidRootPart")
                    if newTHRP and (myHRP.Position - newTHRP.Position).Magnitude <= 5 then break end
                    if wp.Action == Enum.PathWaypointAction.Jump then
                        hum.Jump = true
                    end
                    hum:MoveTo(wp.Position)
                    hum.MoveToFinished:Wait(0.8)
                end
            else
                -- Fallback: direct move
                hum:MoveTo(tHRP.Position)
                hum.MoveToFinished:Wait(0.5)
            end
        end
    end)
end

local function cmd_cmds()
    task.spawn(function()
        sendChat("=== BASIC COMMANDS ===")
        task.wait(0.4)
        sendChat(".Teleport (Username)  |  .Tools (AssetId)")
        task.wait(0.4)
        sendChat(".Follow (Username)  |  .Unfollow")
        task.wait(0.4)
        if next(customCommands) then
            local list = {}
            for n, _ in pairs(customCommands) do
                table.insert(list, n)
            end
            sendChat("=== CUSTOM COMMANDS ===")
            task.wait(0.3)
            sendChat(table.concat(list, "  |  "))
        else
            sendChat("(No custom commands added yet)")
        end
    end)
end

-- Lookup table
local BUILTINS = {
    [".teleport"] = cmd_teleport,
    [".tp"]       = cmd_teleport,
    [".tools"]    = cmd_tools,
    [".follow"]   = cmd_follow,
    [".unfollow"] = function(_) stopFollow() sendChat("[Bot] Unfollowed.") end,
    [".cmds"]     = function(_) cmd_cmds() end,
    [".commands"] = function(_) cmd_cmds() end,
}

-- ══════════════ CHAT HANDLER ══════════════
local function onChat(rawMsg)
    if not botEnabled then return end
    rawMsg = rawMsg:match("^%s*(.-)%s*$")  -- trim
    if rawMsg == "" then return end

    -- Parse
    local parts = {}
    for w in rawMsg:gmatch("%S+") do
        table.insert(parts, w)
    end
    local cmd  = parts[1]:lower()
    local args = {}
    for i = 2, #parts do table.insert(args, parts[i]) end

    -- Check builtins first
    if BUILTINS[cmd] then
        BUILTINS[cmd](args)
        return
    end

    -- Check custom commands
    for name, scriptStr in pairs(customCommands) do
        if name:lower() == cmd then
            _G.cmdArgs = args  -- expose args to custom scripts
            local fn, err = loadstring(scriptStr)
            if fn then
                local ok, runErr = pcall(fn)
                if not ok then
                    sendChat("[Bot] Script Error: " .. tostring(runErr):sub(1, 80))
                end
            else
                sendChat("[Bot] Compile Error: " .. tostring(err):sub(1, 80))
            end
            return
        end
    end
end

-- ══════════════ RAYFIELD UI ══════════════
local Window = Rayfield:CreateWindow({
    Name             = "CommandBot  |  KHAFIDZKTP",
    LoadingTitle     = "CommandBot",
    LoadingSubtitle  = "Initializing...",
    Theme            = "Default",
    DisableRayfieldPrompts  = false,
    DisableBuildWarnings    = false,
    ConfigurationSaving = {
        Enabled = false,
    },
})

-- ─── TAB 1: CONTROL ───
local CtrlTab = Window:CreateTab("⚡ Control", 4483362458)

CtrlTab:CreateSection("Bot Toggle")

CtrlTab:CreateToggle({
    Name         = "Enable Bot",
    CurrentValue = false,
    Flag         = "BotEnabled",
    Callback     = function(val)
        botEnabled = val
        if val then
            -- Connect chat listener
            if chatConn then chatConn:Disconnect() end
            chatConn = LP.Chatted:Connect(onChat)
            task.wait(0.4)
            sendChat("Thanks Using My Script! | Say .cmds in Chat!")
        else
            if chatConn then
                chatConn:Disconnect()
                chatConn = nil
            end
            stopFollow()
        end
    end,
})

CtrlTab:CreateSection("Quick Actions")

CtrlTab:CreateButton({
    Name     = "📋 List Commands in Chat",
    Callback = function()
        if botEnabled then
            cmd_cmds()
        else
            Rayfield:Notify({
                Title   = "Bot Disabled",
                Content = "Enable bot dulu sebelum pakai fitur ini!",
                Duration = 3,
                Image   = 4483362458,
            })
        end
    end,
})

CtrlTab:CreateButton({
    Name     = "🛑 Stop Follow",
    Callback = function()
        stopFollow()
        Rayfield:Notify({
            Title   = "Stopped",
            Content = "Follow dihentikan.",
            Duration = 2,
            Image   = 4483362458,
        })
    end,
})

-- ─── TAB 2: CODERBOX ───
local AddTab = Window:CreateTab("🖥️ Coderbox", 4483362458)

-- ┌──────────────────────────────────┐
-- │  SECTION: TRIGGER  (wajib diisi) │
-- └──────────────────────────────────┘
AddTab:CreateSection("[ TRIGGER ] — Command & Script")
AddTab:CreateLabel("Nama command yang akan memicu script ini.")

local cb_name   = ""
local cb_script = ""

AddTab:CreateInput({
    Name                     = "Command Name",
    PlaceholderText          = "contoh: .dance   |   .speed   |   .loop",
    RemoveTextAfterFocusLost = false,
    Callback                 = function(val) cb_name = val end,
})

AddTab:CreateInput({
    Name                     = "Trigger Script (Lua)",
    PlaceholderText          = "-- script yang jalan saat command dipanggil",
    RemoveTextAfterFocusLost = false,
    Callback                 = function(val) cb_script = val end,
})

-- ┌──────────────────────────────────────────────────┐
-- │  SECTION: STOP  (opsional — kosongkan jika skip) │
-- └──────────────────────────────────────────────────┘
AddTab:CreateSection("[ STOP ] — Opsional, kosongkan jika tidak perlu")
AddTab:CreateLabel("Nama command untuk menghentikan. Contoh: .undance")

local cb_stopName   = ""
local cb_stopScript = ""

AddTab:CreateInput({
    Name                     = "Stop Command Name",
    PlaceholderText          = "contoh: .stoplooop   |   .undance   (kosongkan jika skip)",
    RemoveTextAfterFocusLost = false,
    Callback                 = function(val) cb_stopName = val end,
})

AddTab:CreateInput({
    Name                     = "Stop Script (Lua)",
    PlaceholderText          = "-- script yang jalan untuk menghentikan (kosongkan jika skip)",
    RemoveTextAfterFocusLost = false,
    Callback                 = function(val) cb_stopScript = val end,
})

-- ┌───────────────┐
-- │  ADD SCRIPT   │
-- └───────────────┘
AddTab:CreateSection("")
AddTab:CreateButton({
    Name     = "✅  Add Script",
    Callback = function()
        -- ── Validasi Trigger ──
        local name   = cb_name:match("^%s*(.-)%s*$")
        local script = cb_script:match("^%s*(.-)%s*$")

        if name == "" or script == "" then
            Rayfield:Notify({
                Title   = "❌ Error",
                Content = "Command Name dan Trigger Script wajib diisi!",
                Duration = 3,
                Image   = 4483362458,
            })
            return
        end

        -- Auto-dot
        if name:sub(1,1) ~= "." then name = "." .. name end
        name = name:lower()

        if BUILTINS[name] then
            Rayfield:Notify({
                Title   = "⚠️ Warning",
                Content = "'" .. name .. "' adalah built-in dan tidak bisa di-override!",
                Duration = 4,
                Image   = 4483362458,
            })
            return
        end

        -- Register trigger command
        customCommands[name] = script
        local addedMsg = "Trigger '" .. name .. "' ditambahkan!"

        -- ── Opsional: Stop command ──
        local stopName   = cb_stopName:match("^%s*(.-)%s*$")
        local stopScript = cb_stopScript:match("^%s*(.-)%s*$")

        if stopName ~= "" and stopScript ~= "" then
            if stopName:sub(1,1) ~= "." then stopName = "." .. stopName end
            stopName = stopName:lower()
            if not BUILTINS[stopName] then
                customCommands[stopName] = stopScript
                addedMsg = addedMsg .. "\nStop '" .. stopName .. "' ditambahkan!"
            end
        elseif stopName ~= "" and stopScript == "" then
            -- Stop name ada tapi script kosong — skip stop, kasih warning
            Rayfield:Notify({
                Title   = "⚠️ Stop Script kosong",
                Content = "Stop Command Name diisi tapi Stop Script kosong → bagian stop di-skip.",
                Duration = 4,
                Image   = 4483362458,
            })
        end

        Rayfield:Notify({
            Title   = "✅ Berhasil!",
            Content = addedMsg,
            Duration = 4,
            Image   = 4483362458,
        })
    end,
})

-- ─── Manage ───
AddTab:CreateSection("Manage Custom Commands")

AddTab:CreateButton({
    Name     = "🗑️ Remove All Custom Commands",
    Callback = function()
        local count = 0
        for _ in pairs(customCommands) do count = count + 1 end
        customCommands = {}
        Rayfield:Notify({
            Title   = "Cleared!",
            Content = count .. " custom command dihapus.",
            Duration = 3,
            Image   = 4483362458,
        })
    end,
})

-- ─── TAB 3: INFO ───
local InfoTab = Window:CreateTab("📖 Info", 4483362458)

InfoTab:CreateSection("Built-in Commands")
InfoTab:CreateLabel(".cmds → List semua command di chat")
InfoTab:CreateLabel(".teleport (username) → TP ke player")
InfoTab:CreateLabel(".tools (assetid) → Ambil tool dari catalog")
InfoTab:CreateLabel(".follow (username) → Follow player (pathfinding + jump)")
InfoTab:CreateLabel(".unfollow → Stop follow")

InfoTab:CreateSection("Custom Command Tips")
InfoTab:CreateLabel("Gunakan _G.cmdArgs[1], [2]... untuk args")
InfoTab:CreateLabel("Contoh script: print(_G.cmdArgs[1])")
InfoTab:CreateLabel("Args = kata setelah command di chat")

InfoTab:CreateSection("Credits")
InfoTab:CreateLabel("Made by KHAFIDZKTP")
InfoTab:CreateLabel("GitHub: HaZcK/ScriptHub")
