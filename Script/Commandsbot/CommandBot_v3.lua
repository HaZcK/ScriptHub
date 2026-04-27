-- ╔══════════════════════════════════════════╗
-- ║      CommandBot v3  |  by KHAFIDZKTP     ║
-- ║    Rayfield UI  +  CodeBox Editor        ║
-- ╚══════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ════════════════════════════════════════
--               SERVICES
-- ════════════════════════════════════════
local Players            = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local UIS                = game:GetService("UserInputService")
local LP                 = Players.LocalPlayer
local PlayerGui          = LP:WaitForChild("PlayerGui")

-- ════════════════════════════════════════
--                 STATE
-- ════════════════════════════════════════
local botEnabled     = false
local customCommands = {}
local followThread   = nil
local followTarget   = nil
local orbitConn      = nil   -- RunService connection for orbit
local spinConn       = nil   -- RunService connection for spin
local noclipConn     = nil   -- RunService connection for noclip
local godConn        = nil   -- HealthChanged connection for god mode
local freezeConn     = nil   -- RunService connection for freeze

local chatConn       = nil
local chatConn2      = nil
local otherConns     = {}
local whitelist      = {}
local whitelistAll   = false

-- Default stats (restored on un-commands)
local defaultSpeed   = 16
local defaultJump    = 50

-- ════════════════════════════════════════
--              SEND CHAT
-- ════════════════════════════════════════
local function sendChat(msg)
    local sent = false
    pcall(function()
        local TCS = game:GetService("TextChatService")
        if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
            local ch = TCS.TextChannels:FindFirstChild("RBXGeneral")
            if ch then ch:SendAsync(msg) sent = true end
        end
    end)
    if not sent then
        pcall(function()
            game:GetService("ReplicatedStorage")
                .DefaultChatSystemChatEvents
                .SayMessageRequest:FireServer(msg, "All")
        end)
    end
end

-- ════════════════════════════════════════
--             WHITELIST
-- ════════════════════════════════════════
local function isWhitelisted(userId)
    if userId == LP.UserId then return true end
    if whitelistAll then return true end
    return whitelist[userId] == true
end

local function findPlayer(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and (
            p.Name:lower():find(name:lower(), 1, true) or
            p.DisplayName:lower():find(name:lower(), 1, true)
        ) then return p end
    end
    return nil
end

-- ════════════════════════════════════════
--            STOP HELPERS
-- ════════════════════════════════════════
local function stopFollow()
    if followThread then task.cancel(followThread) followThread = nil end
    followTarget = nil
end

local function stopOrbit()
    if orbitConn then orbitConn:Disconnect() orbitConn = nil end
end

local function stopSpin()
    if spinConn then spinConn:Disconnect() spinConn = nil end
end

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    local char = LP.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end

local function stopFreeze()
    if freezeConn then freezeConn:Disconnect() freezeConn = nil end
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp then hrp.Anchored = false end
        if hum then hum.WalkSpeed = defaultSpeed end
    end
end

local function stopGod()
    if godConn then godConn:Disconnect() godConn = nil end
end

-- ════════════════════════════════════════
--            MOVE TO (NO continue)
-- ════════════════════════════════════════
local function moveToSafe(hum, pos, timeout)
    hum:MoveTo(pos)
    local done = false
    local conn = hum.MoveToFinished:Connect(function() done = true end)
    local t = 0
    while not done and t < (timeout or 1.2) do
        task.wait(0.1) t = t + 0.1
    end
    pcall(function() conn:Disconnect() end)
end

-- ════════════════════════════════════════
--          BUILT-IN COMMANDS
-- ════════════════════════════════════════

-- .teleport (username)
local function cmd_teleport(args)
    local name = args[1]
    if not name then sendChat("[Bot] Usage: .teleport (username)") return end
    local p = findPlayer(name)
    if p and LP.Character and p.Character then
        local mH = LP.Character:FindFirstChild("HumanoidRootPart")
        local tH = p.Character:FindFirstChild("HumanoidRootPart")
        if mH and tH then
            mH.CFrame = tH.CFrame * CFrame.new(3, 0, 0)
            sendChat("[Bot] Teleported to " .. p.Name)
            return
        end
    end
    sendChat("[Bot] Player not found: " .. (name or "?"))
end

-- .tools (assetid)
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
            sendChat("[Bot] No tool found in asset " .. id)
        end
        model:Destroy()
    end)
    if not ok then sendChat("[Bot] Error: " .. tostring(err)) end
end

-- .follow (username)
local function cmd_follow(args)
    local name = args[1]
    if not name then sendChat("[Bot] Usage: .follow (username)") return end
    stopFollow()
    followTarget = findPlayer(name)
    if not followTarget then sendChat("[Bot] Player not found: " .. name) return end
    sendChat("[Bot] Following " .. followTarget.Name .. " | .unfollow to stop")

    followThread = task.spawn(function()
        while followTarget do
            task.wait(0.35)
            local mC = LP.Character
            local tC = followTarget and followTarget.Character
            if mC and tC then
                local mHRP = mC:FindFirstChild("HumanoidRootPart")
                local tHRP = tC:FindFirstChild("HumanoidRootPart")
                local hum  = mC:FindFirstChildOfClass("Humanoid")
                if mHRP and tHRP and hum then
                    local dist = (mHRP.Position - tHRP.Position).Magnitude
                    if dist > 4 then
                        local moved = false
                        pcall(function()
                            local path = PathfindingService:CreatePath({
                                AgentRadius=2, AgentHeight=5,
                                AgentCanJump=true, AgentMaxSlope=60,
                            })
                            path:ComputeAsync(mHRP.Position, tHRP.Position)
                            if path.Status == Enum.PathStatus.Success then
                                for _, wp in ipairs(path:GetWaypoints()) do
                                    if not followTarget then break end
                                    local newTC = followTarget.Character
                                    if newTC then
                                        local nHRP = newTC:FindFirstChild("HumanoidRootPart")
                                        if nHRP and (wp.Position - nHRP.Position).Magnitude > 20 then break end
                                    end
                                    if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                                    moveToSafe(hum, wp.Position, 1.0)
                                end
                                moved = true
                            end
                        end)
                        if not moved then
                            pcall(function() hum:MoveTo(tHRP.Position) end)
                        end
                    end
                end
            else
                task.wait(0.8)
            end
        end
    end)
end

-- .chat (message)
local function cmd_chat(args)
    if #args == 0 then sendChat("[Bot] Usage: .chat (message)") return end
    sendChat(table.concat(args, " "))
end

-- .whitelist (username/all)
local function cmd_whitelist(args)
    local target = args[1]
    if not target then sendChat("[Bot] Usage: .whitelist (username) or .whitelist all") return end
    if target:lower() == "all" then
        whitelistAll = true
        sendChat("[Bot] Whitelist ALL — everyone can control the bot!")
        return
    end
    local p = findPlayer(target)
    if p then
        whitelist[p.UserId] = true
        sendChat("[Bot] " .. p.Name .. " added to whitelist!")
    else
        sendChat("[Bot] Player not found: " .. target)
    end
end

-- .unwhitelist (username/all)
local function cmd_unwhitelist(args)
    local target = args[1]
    if not target then sendChat("[Bot] Usage: .unwhitelist (username) or .unwhitelist all") return end
    if target:lower() == "all" then
        whitelistAll = false
        whitelist    = {}
        sendChat("[Bot] Whitelist cleared.")
        return
    end
    local p = findPlayer(target)
    if p then
        whitelist[p.UserId] = nil
        sendChat("[Bot] " .. p.Name .. " removed from whitelist.")
    else
        sendChat("[Bot] Player not found: " .. target)
    end
end

-- ════════════════════════════════════════
--           ORBIT COMMAND
-- ════════════════════════════════════════
-- .orbit (target) (speed) (radius)
-- target: player name | baseplate | me/self | part name in workspace
local function cmd_orbit(args)
    stopOrbit()
    local targetName = args[1] or "me"
    local speed      = tonumber(args[2]) or 1.0
    local radius     = tonumber(args[3]) or 12

    -- Resolve target to a function that returns Vector3 position
    local getPos = nil

    if targetName:lower() == "me" or targetName:lower() == "self" then
        -- Orbit around own current position (locked in place)
        local char = LP.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then sendChat("[Bot] Character not found.") return end
        local lockedPos = hrp.Position
        getPos = function() return lockedPos end

    elseif targetName:lower() == "baseplate" or targetName:lower() == "base" then
        local bp = workspace:FindFirstChild("Baseplate")
            or workspace:FindFirstChild("Base")
            or workspace.Terrain
        if bp and bp:IsA("BasePart") then
            getPos = function() return bp.Position end
        else
            -- Fallback: center of map at Y=0
            getPos = function() return Vector3.new(0, 0, 0) end
        end

    else
        -- Try player first
        local p = findPlayer(targetName)
        if p then
            getPos = function()
                local c = p.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                return h and h.Position or Vector3.new(0, 0, 0)
            end
        else
            -- Try part in workspace
            local part = workspace:FindFirstChild(targetName, true)
            if part and part:IsA("BasePart") then
                getPos = function() return part.Position end
            else
                sendChat("[Bot] Orbit target not found: " .. targetName)
                return
            end
        end
    end

    sendChat("[Bot] Orbiting " .. targetName .. " | speed=" .. speed .. " radius=" .. radius .. " | .unorbit to stop")

    local angle = 0
    orbitConn = RunService.Heartbeat:Connect(function(dt)
        angle = angle + speed * dt
        local char = LP.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local center = getPos()
            local x = center.X + math.cos(angle) * radius
            local z = center.Z + math.sin(angle) * radius
            local y = center.Y + 5
            hrp.CFrame = CFrame.new(x, y, z) * CFrame.Angles(0, -angle - math.pi / 2, 0)
        end
    end)
end

-- ════════════════════════════════════════
--          NEW COMMANDS (v3)
-- ════════════════════════════════════════

-- .speed (value) / .unspeed
local function cmd_speed(args)
    local val = tonumber(args[1]) or 50
    val = math.clamp(val, 0, 500)
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        defaultSpeed = hum.WalkSpeed  -- save before changing
        hum.WalkSpeed = val
        sendChat("[Bot] Speed set to " .. val)
    end
end

local function cmd_unspeed()
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 sendChat("[Bot] Speed reset to 16.") end
end

-- .jump (value) / .unjump
local function cmd_jump(args)
    local val = tonumber(args[1]) or 100
    val = math.clamp(val, 0, 500)
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = val
        sendChat("[Bot] Jump power set to " .. val)
    end
end

local function cmd_unjump()
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 50 sendChat("[Bot] Jump power reset to 50.") end
end

-- .noclip / .unnoclip
local noclipActive = false
local function cmd_noclip()
    if noclipActive then sendChat("[Bot] Noclip already active. Use .unnoclip") return end
    noclipActive = true
    sendChat("[Bot] Noclip ON | .unnoclip to disable")
    noclipConn = RunService.Stepped:Connect(function()
        local char = LP.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end)
end

local function cmd_unnoclip()
    noclipActive = false
    stopNoclip()
    sendChat("[Bot] Noclip OFF.")
end

-- .spin (speed) / .unspin
local function cmd_spin(args)
    stopSpin()
    local speed = tonumber(args[1]) or 5
    sendChat("[Bot] Spinning at speed " .. speed .. " | .unspin to stop")
    spinConn = RunService.Heartbeat:Connect(function(dt)
        local char = LP.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, speed * dt, 0)
        end
    end)
end

local function cmd_unspin()
    stopSpin()
    sendChat("[Bot] Spin stopped.")
end

-- .fling (username)
local function cmd_fling(args)
    local name = args[1]
    if not name then sendChat("[Bot] Usage: .fling (username)") return end
    local target = findPlayer(name)
    if not target or not target.Character then
        sendChat("[Bot] Player not found: " .. (name or "?")) return
    end
    local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not tHRP then sendChat("[Bot] Target has no HumanoidRootPart.") return end

    -- Teleport self next to target then apply velocity
    local myChar = LP.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local prevCF = myHRP.CFrame
    myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, -1)

    -- Launch via BodyVelocity
    local bv = Instance.new("BodyVelocity")
    bv.Velocity  = Vector3.new(
        math.random(-1,1) * 200,
        400,
        math.random(-1,1) * 200
    )
    bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
    bv.P         = 1e4
    bv.Parent    = myHRP

    task.wait(0.08)
    bv:Destroy()

    -- Return self
    task.wait(0.1)
    myHRP.CFrame = prevCF
    sendChat("[Bot] Flung " .. target.Name .. "!")
end

-- .freeze / .unfreeze
local freezePos = nil
local function cmd_freeze()
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    freezePos = hrp.CFrame
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hrp.Anchored  = true
    sendChat("[Bot] Frozen at current position | .unfreeze to move again")
end

local function cmd_unfreeze()
    stopFreeze()
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hrp then hrp.Anchored = false end
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
    sendChat("[Bot] Unfrozen.")
end

-- .god / .ungod
local function cmd_god()
    stopGod()
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.MaxHealth = math.huge
    hum.Health    = math.huge
    godConn = hum.HealthChanged:Connect(function(hp)
        if hp < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)
    sendChat("[Bot] God mode ON | .ungod to disable")
end

local function cmd_ungod()
    stopGod()
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.MaxHealth = 100
        hum.Health    = 100
    end
    sendChat("[Bot] God mode OFF.")
end

-- .size (scale) / .unsize
local function cmd_size(args)
    local scale = tonumber(args[1]) or 2
    scale = math.clamp(scale, 0.1, 10)
    local char = LP.Character
    if not char then return end
    for _, v in ipairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale","HeadScale","BodyTypeScale"}) do
        local val = char:FindFirstChild("Humanoid")
                 and char.Humanoid:FindFirstChild(v)
        if val and val:IsA("NumberValue") then
            val.Value = scale
        end
    end
    sendChat("[Bot] Size set to " .. scale .. "x")
end

local function cmd_unsize()
    local char = LP.Character
    if not char then return end
    for _, v in ipairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale","HeadScale","BodyTypeScale"}) do
        local val = char:FindFirstChild("Humanoid")
                 and char.Humanoid:FindFirstChild(v)
        if val and val:IsA("NumberValue") then
            val.Value = 1
        end
    end
    sendChat("[Bot] Size reset to 1x")
end

-- .invisible / .uninvisible
local savedTransparency = {}
local function cmd_invisible()
    local char = LP.Character
    if not char then return end
    savedTransparency = {}
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            savedTransparency[p] = p.Transparency
            p.Transparency = 1
        elseif p:IsA("Decal") then
            savedTransparency[p] = p.Transparency
            p.Transparency = 1
        end
    end
    sendChat("[Bot] Invisible ON | .uninvisible to show again")
end

local function cmd_uninvisible()
    local char = LP.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if savedTransparency[p] ~= nil then
            if p:IsA("BasePart") or p:IsA("Decal") then
                p.Transparency = savedTransparency[p]
            end
        end
    end
    savedTransparency = {}
    sendChat("[Bot] Visible again.")
end

-- .cmds
local function cmd_cmds()
    task.spawn(function()
        sendChat("=== BASIC COMMANDS ===")
        task.wait(0.4)
        sendChat(".teleport .tools .follow .unfollow .chat .whitelist .unwhitelist")
        task.wait(0.4)
        sendChat(".orbit .unorbit | .speed .unspeed | .jump .unjump | .noclip .unnoclip")
        task.wait(0.4)
        sendChat(".spin .unspin | .fling | .freeze .unfreeze | .god .ungod | .size .unsize | .invisible .uninvisible")
        task.wait(0.4)
        if next(customCommands) then
            local list = {}
            for n, data in pairs(customCommands) do
                local entry = n
                if data.stop and data.stop ~= "" then
                    entry = entry .. "(.Un" .. n:sub(2) .. ")"
                end
                table.insert(list, entry)
            end
            sendChat("=== CUSTOM: " .. table.concat(list, " | ") .. " ===")
        else
            sendChat("(No custom commands added yet)")
        end
    end)
end

-- ════════════════════════════════════════
--             BUILTINS TABLE
-- ════════════════════════════════════════
local BUILTINS = {
    -- Core
    [".teleport"]     = cmd_teleport,
    [".tp"]           = cmd_teleport,
    [".tools"]        = cmd_tools,
    [".follow"]       = cmd_follow,
    [".unfollow"]     = function() stopFollow()  sendChat("[Bot] Unfollowed.") end,
    [".chat"]         = cmd_chat,
    [".whitelist"]    = cmd_whitelist,
    [".unwhitelist"]  = cmd_unwhitelist,
    [".cmds"]         = function() cmd_cmds() end,
    [".commands"]     = function() cmd_cmds() end,
    -- Orbit
    [".orbit"]        = cmd_orbit,
    [".unorbit"]      = function() stopOrbit()   sendChat("[Bot] Orbit stopped.") end,
    -- Speed / Jump
    [".speed"]        = cmd_speed,
    [".unspeed"]      = function() cmd_unspeed() end,
    [".jump"]         = cmd_jump,
    [".unjump"]       = function() cmd_unjump()  end,
    -- Noclip
    [".noclip"]       = cmd_noclip,
    [".unnoclip"]     = cmd_unnoclip,
    -- Spin
    [".spin"]         = cmd_spin,
    [".unspin"]       = cmd_unspin,
    -- Fling
    [".fling"]        = cmd_fling,
    -- Freeze
    [".freeze"]       = cmd_freeze,
    [".unfreeze"]     = cmd_unfreeze,
    -- God
    [".god"]          = cmd_god,
    [".ungod"]        = cmd_ungod,
    -- Size
    [".size"]         = cmd_size,
    [".unsize"]       = cmd_unsize,
    -- Invisible
    [".invisible"]    = cmd_invisible,
    [".uninvisible"]  = cmd_uninvisible,
    [".vis"]          = cmd_uninvisible,
}

-- ════════════════════════════════════════
--            CHAT HANDLER
-- ════════════════════════════════════════
local function onChat(raw, senderId)
    if not botEnabled then return end
    raw = raw:match("^%s*(.-)%s*$")
    if raw == "" or raw:sub(1,1) ~= "." then return end

    local sId = senderId or LP.UserId
    if not isWhitelisted(sId) then return end

    local parts = {}
    for w in raw:gmatch("%S+") do table.insert(parts, w) end
    local cmd  = parts[1]:lower()
    local args = {}
    for i = 2, #parts do table.insert(args, parts[i]) end

    -- Only owner can manage whitelist
    if (cmd == ".whitelist" or cmd == ".unwhitelist") and sId ~= LP.UserId then return end

    if BUILTINS[cmd] then BUILTINS[cmd](args) return end

    for name, data in pairs(customCommands) do
        if name:lower() == cmd then
            _G.cmdArgs = args
            local fn, err = loadstring(data.trigger or "")
            if fn then pcall(fn) else sendChat("[Bot] Script Error: " .. tostring(err):sub(1,60)) end
            return
        end
        local stopName = ".un" .. name:sub(2)
        if stopName == cmd and data.stop and data.stop ~= "" then
            _G.cmdArgs = args
            local fn, err = loadstring(data.stop)
            if fn then pcall(fn) else sendChat("[Bot] Stop Error: " .. tostring(err):sub(1,60)) end
            return
        end
    end
end

-- ════════════════════════════════════════
--       OTHER PLAYER LISTENERS
-- ════════════════════════════════════════
local function connectOtherPlayers()
    for _, c in ipairs(otherConns) do pcall(function() c:Disconnect() end) end
    otherConns = {}
    local function hookPlayer(p)
        if p == LP then return end
        local c = p.Chatted:Connect(function(msg) onChat(msg, p.UserId) end)
        table.insert(otherConns, c)
    end
    for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
    local jc = Players.PlayerAdded:Connect(hookPlayer)
    table.insert(otherConns, jc)
end

local function disconnectOtherPlayers()
    for _, c in ipairs(otherConns) do pcall(function() c:Disconnect() end) end
    otherConns = {}
end

-- ════════════════════════════════════════════════════
--                  CODEBOX GUI
-- ════════════════════════════════════════════════════
local TEMPLATE = [[-- TRIGGER SCRIPT
-- Runs when command is called in chat
-- Access args via: _G.cmdArgs[1], _G.cmdArgs[2], etc.

-- Write your trigger script here:


-- STOP SCRIPT (DELETE THIS SECTION IF NOT NEEDED)
-- Auto-registered as ".Un[commandname]"
-- Example: .dance -> .undance to stop

-- Write your stop script here:
]]

local C = {
    bg      = Color3.fromRGB(15,  15,  22),
    panel   = Color3.fromRGB(22,  22,  32),
    border  = Color3.fromRGB(88,  88, 200),
    text    = Color3.fromRGB(220, 220, 255),
    sub     = Color3.fromRGB(130, 130, 170),
    green   = Color3.fromRGB(72,  199, 116),
    red     = Color3.fromRGB(220,  75,  75),
    input   = Color3.fromRGB(11,  11,  18),
    linenum = Color3.fromRGB(20,  20,  30),
}

local codeBoxOpen = false

local function makeBtn(parent, label, bg, pos, size, cb)
    local b = Instance.new("TextButton", parent)
    b.BackgroundColor3 = bg
    b.Text = label  b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold  b.TextSize = 14
    b.Position = pos  b.Size = size  b.AutoButtonColor = false
    b.ZIndex = 20
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)
    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=bg:Lerp(Color3.new(1,1,1),0.18)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=bg}):Play()
    end)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function openCodeBox()
    if codeBoxOpen then return end
    codeBoxOpen = true

    local sg = Instance.new("ScreenGui")
    sg.Name = "CBCodeBox"  sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true  sg.Parent = PlayerGui

    local bd = Instance.new("Frame", sg)
    bd.Size = UDim2.new(1,0,1,0)
    bd.BackgroundColor3 = Color3.new(0,0,0)
    bd.BackgroundTransparency = 0.45
    bd.ZIndex = 14

    local win = Instance.new("Frame", sg)
    win.Size = UDim2.new(0,640,0,510)
    win.Position = UDim2.new(0.5,-320,0.5,-255)
    win.BackgroundColor3 = C.bg
    win.ZIndex = 15
    Instance.new("UICorner",win).CornerRadius = UDim.new(0,12)
    local ws = Instance.new("UIStroke",win)
    ws.Color = C.border  ws.Thickness = 1.5  ws.Transparency = 0.25

    win.Size = UDim2.new(0,640,0,0)
    TweenService:Create(win,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,640,0,510)}):Play()

    local function closeBox()
        TweenService:Create(win,TweenInfo.new(0.18),{Size=UDim2.new(0,640,0,0)}):Play()
        task.wait(0.2)  sg:Destroy()  codeBoxOpen = false
    end

    -- Title bar
    local tb = Instance.new("Frame", win)
    tb.Size = UDim2.new(1,0,0,46)
    tb.BackgroundColor3 = C.panel
    tb.BorderSizePixel = 0  tb.ZIndex = 16
    Instance.new("UICorner",tb).CornerRadius = UDim.new(0,12)
    local tbFix = Instance.new("Frame",tb)
    tbFix.Size = UDim2.new(1,0,0,12)  tbFix.Position = UDim2.new(0,0,1,-12)
    tbFix.BackgroundColor3 = C.panel  tbFix.BorderSizePixel = 0  tbFix.ZIndex = 16

    local ttl = Instance.new("TextLabel",tb)
    ttl.Text = "   CodeBox  -  Command Builder"
    ttl.TextColor3 = C.text  ttl.Font = Enum.Font.GothamBold  ttl.TextSize = 15
    ttl.BackgroundTransparency = 1  ttl.Size = UDim2.new(1,-50,1,0)
    ttl.TextXAlignment = Enum.TextXAlignment.Left  ttl.ZIndex = 17

    local xBtn = Instance.new("TextButton",tb)
    xBtn.Text = "X"  xBtn.TextColor3 = C.sub
    xBtn.Font = Enum.Font.GothamBold  xBtn.TextSize = 16
    xBtn.BackgroundTransparency = 1
    xBtn.Size = UDim2.new(0,46,1,0)
    xBtn.Position = UDim2.new(1,-46,0,0)  xBtn.ZIndex = 17
    xBtn.MouseButton1Click:Connect(closeBox)

    -- Drag
    local dragging, ds, sp = false, nil, nil
    tb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true  ds = i.Position  sp = win.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            win.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Content
    local pad = 14
    local cx = Instance.new("Frame",win)
    cx.Size = UDim2.new(1,-pad*2,1,-60)
    cx.Position = UDim2.new(0,pad,0,52)
    cx.BackgroundTransparency = 1  cx.ZIndex = 16

    -- Command Name
    local nl = Instance.new("TextLabel",cx)
    nl.Text = "Command Name  (e.g. .dance  |  .speed)"
    nl.TextColor3 = C.sub  nl.Font = Enum.Font.GothamBold  nl.TextSize = 12
    nl.BackgroundTransparency = 1  nl.Size = UDim2.new(1,0,0,16)
    nl.TextXAlignment = Enum.TextXAlignment.Left  nl.ZIndex = 17

    local nameBox = Instance.new("TextBox",cx)
    nameBox.Size = UDim2.new(1,0,0,36)  nameBox.Position = UDim2.new(0,0,0,20)
    nameBox.BackgroundColor3 = C.input
    nameBox.TextColor3 = C.text  nameBox.PlaceholderText = ".mycommand"
    nameBox.PlaceholderColor3 = C.sub
    nameBox.Font = Enum.Font.Code  nameBox.TextSize = 15
    nameBox.ClearTextOnFocus = false  nameBox.Text = ""  nameBox.ZIndex = 17
    Instance.new("UICorner",nameBox).CornerRadius = UDim.new(0,7)
    Instance.new("UIStroke",nameBox).Color = C.border

    -- Script label
    local sl = Instance.new("TextLabel",cx)
    sl.Text = "Script Editor  -  delete the STOP SCRIPT section if not needed"
    sl.TextColor3 = C.sub  sl.Font = Enum.Font.GothamBold  sl.TextSize = 12
    sl.BackgroundTransparency = 1  sl.Size = UDim2.new(1,0,0,16)
    sl.Position = UDim2.new(0,0,0,64)
    sl.TextXAlignment = Enum.TextXAlignment.Left  sl.ZIndex = 17

    -- Editor wrapper
    local ew = Instance.new("Frame",cx)
    ew.Size = UDim2.new(1,0,0,286)  ew.Position = UDim2.new(0,0,0,84)
    ew.BackgroundColor3 = C.input  ew.ZIndex = 16
    Instance.new("UICorner",ew).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke",ew).Color = C.border

    local lp = Instance.new("Frame",ew)
    lp.Size = UDim2.new(0,38,1,0)
    lp.BackgroundColor3 = C.linenum  lp.BorderSizePixel = 0  lp.ZIndex = 17
    Instance.new("UICorner",lp).CornerRadius = UDim.new(0,8)
    local lpFix = Instance.new("Frame",lp)
    lpFix.Size = UDim2.new(0,10,1,0)  lpFix.Position = UDim2.new(1,-10,0,0)
    lpFix.BackgroundColor3 = C.linenum  lpFix.BorderSizePixel = 0  lpFix.ZIndex = 17

    local lnLabel = Instance.new("TextLabel",lp)
    lnLabel.Size = UDim2.new(1,-4,1,-8)  lnLabel.Position = UDim2.new(0,2,0,4)
    lnLabel.BackgroundTransparency = 1  lnLabel.TextColor3 = C.sub
    lnLabel.Font = Enum.Font.Code  lnLabel.TextSize = 13
    lnLabel.TextYAlignment = Enum.TextYAlignment.Top
    lnLabel.TextXAlignment = Enum.TextXAlignment.Right  lnLabel.ZIndex = 18

    local scriptBox = Instance.new("TextBox",ew)
    scriptBox.Size = UDim2.new(1,-46,1,-8)  scriptBox.Position = UDim2.new(0,44,0,4)
    scriptBox.BackgroundTransparency = 1
    scriptBox.TextColor3 = C.text  scriptBox.Font = Enum.Font.Code  scriptBox.TextSize = 13
    scriptBox.ClearTextOnFocus = false  scriptBox.MultiLine = true
    scriptBox.TextXAlignment = Enum.TextXAlignment.Left
    scriptBox.TextYAlignment = Enum.TextYAlignment.Top
    scriptBox.Text = TEMPLATE  scriptBox.ZIndex = 17

    local function updateLines(txt)
        local n = select(2, txt:gsub("\n","\n")) + 1
        local t = {}
        for i = 1, math.min(n, 40) do t[i] = tostring(i) end
        lnLabel.Text = table.concat(t, "\n")
    end
    updateLines(scriptBox.Text)
    scriptBox:GetPropertyChangedSignal("Text"):Connect(function()
        updateLines(scriptBox.Text)
    end)

    local br = Instance.new("Frame",cx)
    br.Size = UDim2.new(1,0,0,38)  br.Position = UDim2.new(0,0,0,380)
    br.BackgroundTransparency = 1  br.ZIndex = 16

    makeBtn(br, "Save Command", C.green, UDim2.new(0,0,0,0), UDim2.new(0.48,0,1,0), function()
        local name = nameBox.Text:match("^%s*(.-)%s*$")
        local src  = scriptBox.Text
        if name == "" then
            Rayfield:Notify({Title="Error",Content="Fill in the Command Name first!",Duration=3,Image=4483362458})
            return
        end
        if name:sub(1,1) ~= "." then name = "." .. name end
        name = name:lower()
        if BUILTINS[name] then
            Rayfield:Notify({Title="Blocked",Content="'"..name.."' is a built-in command!",Duration=4,Image=4483362458})
            return
        end
        local triggerPart = src
        local stopPart    = ""
        local marker = src:find("%-%-+ STOP SCRIPT")
        if marker then
            triggerPart = src:sub(1, marker-1):match("^(.-)%s*$")
            local stopSection = src:sub(marker)
            local afterHeader = stopSection:match("%-%-[^\n]*\n%-%-[^\n]*\n%-%-[^\n]*\n(.*)")
                             or stopSection:match("%-%-[^\n]*\n%-%-[^\n]*\n(.*)")
                             or stopSection:match("%-%-[^\n]*\n(.*)")
                             or ""
            stopPart = afterHeader:match("^%s*(.-)%s*$") or ""
        end
        customCommands[name] = { trigger = triggerPart, stop = stopPart }
        local stopInfo = (stopPart ~= "") and ("  +  .un" .. name:sub(2)) or ""
        Rayfield:Notify({
            Title   = "Saved!",
            Content = "'"..name.."'"..stopInfo.." added!",
            Duration = 3, Image = 4483362458,
        })
        closeBox()
    end)

    makeBtn(br, "Cancel", C.red, UDim2.new(0.52,0,0,0), UDim2.new(0.48,0,1,0), closeBox)

    local hint = Instance.new("TextLabel",cx)
    hint.Text = "Tip: _G.cmdArgs[1..n] for arguments  |  Stop = .un[command]  |  Drag title bar to move"
    hint.TextColor3 = C.sub  hint.Font = Enum.Font.Gotham  hint.TextSize = 11
    hint.BackgroundTransparency = 1  hint.Size = UDim2.new(1,0,0,14)
    hint.Position = UDim2.new(0,0,0,424)
    hint.TextXAlignment = Enum.TextXAlignment.Left  hint.ZIndex = 16
end

-- ════════════════════════════════════════
--             RAYFIELD UI
-- ════════════════════════════════════════
local Window = Rayfield:CreateWindow({
    Name            = "CommandBot v3  |  KHAFIDZKTP",
    LoadingTitle    = "CommandBot v3",
    LoadingSubtitle = "Loading commands...",
    Theme           = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings   = false,
    ConfigurationSaving    = { Enabled = false },
})

-- ─── TAB: CONTROL ───────────────────────
local CtrlTab = Window:CreateTab("Control", 4483362458)

CtrlTab:CreateSection("Bot Toggle")
CtrlTab:CreateToggle({
    Name = "Enable Bot", CurrentValue = false, Flag = "BotEnabled",
    Callback = function(val)
        botEnabled = val
        if val then
            if chatConn  then chatConn:Disconnect()  chatConn  = nil end
            if chatConn2 then chatConn2:Disconnect() chatConn2 = nil end
            disconnectOtherPlayers()

            -- Owner: legacy LP.Chatted
            chatConn = LP.Chatted:Connect(function(msg)
                onChat(msg, LP.UserId)
            end)

            -- TextChatService: all messages (self + others)
            pcall(function()
                local TCS = game:GetService("TextChatService")
                chatConn2 = TCS.MessageReceived:Connect(function(msg)
                    if not msg.TextSource then return end
                    local ok, uid = pcall(function() return msg.TextSource.UserId end)
                    if ok then onChat(msg.Text, uid) end
                end)
            end)

            -- Legacy: other players' Chatted
            connectOtherPlayers()

            task.wait(0.4)
            sendChat("Thanks Using My Script! | Say .cmds in Chat!")
        else
            if chatConn  then chatConn:Disconnect()  chatConn  = nil end
            if chatConn2 then chatConn2:Disconnect() chatConn2 = nil end
            disconnectOtherPlayers()
            stopFollow()
            stopOrbit()
            stopSpin()
        end
    end,
})

CtrlTab:CreateSection("Quick Actions")
CtrlTab:CreateButton({
    Name = "List Commands in Chat",
    Callback = function()
        if botEnabled then cmd_cmds()
        else Rayfield:Notify({Title="Bot Disabled",Content="Enable the bot first!",Duration=3,Image=4483362458}) end
    end,
})
CtrlTab:CreateButton({
    Name = "Stop Follow",
    Callback = function()
        stopFollow()
        Rayfield:Notify({Title="Stopped",Content="Follow disabled.",Duration=2,Image=4483362458})
    end,
})
CtrlTab:CreateButton({
    Name = "Stop Orbit",
    Callback = function()
        stopOrbit()
        Rayfield:Notify({Title="Stopped",Content="Orbit disabled.",Duration=2,Image=4483362458})
    end,
})
CtrlTab:CreateButton({
    Name = "Stop Spin",
    Callback = function()
        stopSpin()
        Rayfield:Notify({Title="Stopped",Content="Spin disabled.",Duration=2,Image=4483362458})
    end,
})
CtrlTab:CreateButton({
    Name = "Clear Whitelist",
    Callback = function()
        whitelistAll = false
        whitelist    = {}
        Rayfield:Notify({Title="Whitelist Cleared",Content="All access revoked.",Duration=3,Image=4483362458})
    end,
})
CtrlTab:CreateButton({
    Name = "Reset All Effects",
    Callback = function()
        stopFollow() stopOrbit() stopSpin()
        cmd_unnoclip() cmd_ungod() cmd_unfreeze()
        cmd_unsize({}) cmd_uninvisible() cmd_unspeed() cmd_unjump()
        Rayfield:Notify({Title="Reset",Content="All effects cleared.",Duration=3,Image=4483362458})
    end,
})

-- ─── TAB: ORBIT ─────────────────────────
local OrbitTab = Window:CreateTab("Orbit", 4483362458)

OrbitTab:CreateSection("Orbit Settings")
OrbitTab:CreateLabel("Usage: .orbit (target) (speed) (radius)")
OrbitTab:CreateLabel("Target: player name | baseplate | me | part name")

local orbitTargetInput = ""
local orbitSpeedInput  = "1"
local orbitRadiusInput = "12"

OrbitTab:CreateInput({
    Name = "Target (player / baseplate / me / partname)",
    PlaceholderText = "e.g. baseplate  or  PlayerName",
    RemoveTextAfterFocusLost = false,
    Callback = function(v) orbitTargetInput = v end,
})
OrbitTab:CreateInput({
    Name = "Speed (default: 1)",
    PlaceholderText = "1",
    RemoveTextAfterFocusLost = false,
    Callback = function(v) orbitSpeedInput = v end,
})
OrbitTab:CreateInput({
    Name = "Radius (default: 12)",
    PlaceholderText = "12",
    RemoveTextAfterFocusLost = false,
    Callback = function(v) orbitRadiusInput = v end,
})
OrbitTab:CreateButton({
    Name = "Start Orbit",
    Callback = function()
        cmd_orbit({
            orbitTargetInput ~= "" and orbitTargetInput or "me",
            orbitSpeedInput,
            orbitRadiusInput,
        })
    end,
})
OrbitTab:CreateButton({
    Name = "Stop Orbit",
    Callback = function()
        stopOrbit()
        Rayfield:Notify({Title="Orbit",Content="Orbit stopped.",Duration=2,Image=4483362458})
    end,
})

-- ─── TAB: COMMANDS ──────────────────────
local CmdTab = Window:CreateTab("Commands", 4483362458)

CmdTab:CreateSection("Movement")

local speedVal = "50"
CmdTab:CreateInput({
    Name = "Walk Speed (default: 50)",
    PlaceholderText = "50",
    RemoveTextAfterFocusLost = false,
    Callback = function(v) speedVal = v end,
})
CmdTab:CreateButton({
    Name = "Set Speed",
    Callback = function() cmd_speed({speedVal}) end,
})
CmdTab:CreateButton({
    Name = "Reset Speed",
    Callback = function() cmd_unspeed() end,
})

local jumpVal = "100"
CmdTab:CreateInput({
    Name = "Jump Power (default: 100)",
    PlaceholderText = "100",
    RemoveTextAfterFocusLost = false,
    Callback = function(v) jumpVal = v end,
})
CmdTab:CreateButton({
    Name = "Set Jump",
    Callback = function() cmd_jump({jumpVal}) end,
})
CmdTab:CreateButton({
    Name = "Reset Jump",
    Callback = function() cmd_unjump() end,
})

CmdTab:CreateSection("Character")

local sizeVal = "2"
CmdTab:CreateInput({
    Name = "Size Scale (0.1 - 10)",
    PlaceholderText = "2",
    RemoveTextAfterFocusLost = false,
    Callback = function(v) sizeVal = v end,
})
CmdTab:CreateButton({
    Name = "Set Size",
    Callback = function() cmd_size({sizeVal}) end,
})
CmdTab:CreateButton({
    Name = "Reset Size",
    Callback = function() cmd_unsize({}) end,
})

CmdTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(val)
        if val then cmd_noclip() else cmd_unnoclip() end
    end,
})
CmdTab:CreateToggle({
    Name = "Invisible",
    CurrentValue = false,
    Flag = "InvisToggle",
    Callback = function(val)
        if val then cmd_invisible() else cmd_uninvisible() end
    end,
})
CmdTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodToggle",
    Callback = function(val)
        if val then cmd_god() else cmd_ungod() end
    end,
})
CmdTab:CreateToggle({
    Name = "Freeze",
    CurrentValue = false,
    Flag = "FreezeToggle",
    Callback = function(val)
        if val then cmd_freeze() else cmd_unfreeze() end
    end,
})

CmdTab:CreateSection("Spin")
local spinVal = "5"
CmdTab:CreateInput({
    Name = "Spin Speed (default: 5)",
    PlaceholderText = "5",
    RemoveTextAfterFocusLost = false,
    Callback = function(v) spinVal = v end,
})
CmdTab:CreateButton({
    Name = "Start Spin",
    Callback = function() cmd_spin({spinVal}) end,
})
CmdTab:CreateButton({
    Name = "Stop Spin",
    Callback = function() cmd_unspin() end,
})

CmdTab:CreateSection("Fling")
local flingTarget = ""
CmdTab:CreateInput({
    Name = "Fling Target (username)",
    PlaceholderText = "PlayerName",
    RemoveTextAfterFocusLost = false,
    Callback = function(v) flingTarget = v end,
})
CmdTab:CreateButton({
    Name = "Fling Player",
    Callback = function()
        if flingTarget ~= "" then cmd_fling({flingTarget})
        else Rayfield:Notify({Title="Error",Content="Enter a target name first!",Duration=3,Image=4483362458}) end
    end,
})

-- ─── TAB: ADD COMMAND ───────────────────
local AddTab = Window:CreateTab("Add Command", 4483362458)
AddTab:CreateSection("Custom Command Builder")
AddTab:CreateLabel("Click Open CodeBox to open the editor")
AddTab:CreateLabel("Trigger and Stop templates are already filled in")
AddTab:CreateLabel("Delete the STOP section if the command does not need a stop")
AddTab:CreateButton({
    Name = "Open CodeBox",
    Callback = function()
        if codeBoxOpen then
            Rayfield:Notify({Title="CodeBox",Content="CodeBox is already open!",Duration=2,Image=4483362458})
            return
        end
        openCodeBox()
    end,
})
AddTab:CreateSection("Manage")
AddTab:CreateButton({
    Name = "Remove All Custom Commands",
    Callback = function()
        local c = 0
        for _ in pairs(customCommands) do c = c + 1 end
        customCommands = {}
        Rayfield:Notify({Title="Cleared!",Content=c.." command(s) removed.",Duration=3,Image=4483362458})
    end,
})

-- ─── TAB: INFO ──────────────────────────
local InfoTab = Window:CreateTab("Info", 4483362458)

InfoTab:CreateSection("Core Commands")
InfoTab:CreateLabel(".cmds                   -> list all commands in chat")
InfoTab:CreateLabel(".teleport (username)    -> teleport to player")
InfoTab:CreateLabel(".tools (assetid)        -> load tool from catalog")
InfoTab:CreateLabel(".follow (username)      -> pathfinding follow + jump")
InfoTab:CreateLabel(".unfollow               -> stop following")
InfoTab:CreateLabel(".chat (message)         -> send a chat message")

InfoTab:CreateSection("Orbit Command")
InfoTab:CreateLabel(".orbit (target) (speed) (radius)")
InfoTab:CreateLabel("target: player | baseplate | me | partname")
InfoTab:CreateLabel(".unorbit                -> stop orbit")
InfoTab:CreateLabel("Example: .orbit baseplate 2 15")

InfoTab:CreateSection("New Commands (v3)")
InfoTab:CreateLabel(".speed (val)  / .unspeed    -> walk speed")
InfoTab:CreateLabel(".jump (val)   / .unjump      -> jump power")
InfoTab:CreateLabel(".noclip       / .unnoclip    -> phase through walls")
InfoTab:CreateLabel(".spin (speed) / .unspin      -> spin character")
InfoTab:CreateLabel(".fling (username)            -> launch player")
InfoTab:CreateLabel(".freeze       / .unfreeze    -> freeze in place")
InfoTab:CreateLabel(".god          / .ungod       -> infinite health")
InfoTab:CreateLabel(".size (scale) / .unsize      -> resize (0.1 - 10)")
InfoTab:CreateLabel(".invisible    / .uninvisible -> hide character")

InfoTab:CreateSection("Whitelist System")
InfoTab:CreateLabel(".whitelist (username)        -> allow player to use commands")
InfoTab:CreateLabel(".whitelist all               -> allow everyone")
InfoTab:CreateLabel(".unwhitelist (username/all)  -> revoke access")
InfoTab:CreateLabel("Whitelisted players type commands in chat")
InfoTab:CreateLabel("and your character executes them")

InfoTab:CreateSection("CodeBox")
InfoTab:CreateLabel("TRIGGER SCRIPT -> runs when command is called")
InfoTab:CreateLabel("STOP SCRIPT    -> delete section if not needed")
InfoTab:CreateLabel("Stop auto-registered as .un[command]")

InfoTab:CreateSection("Credits")
InfoTab:CreateLabel("Made by KHAFIDZKTP  |  GitHub: HaZcK/ScriptHub")
