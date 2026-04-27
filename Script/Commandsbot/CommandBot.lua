-- ╔══════════════════════════════════════════╗
-- ║       CommandBot  |  by KHAFIDZKTP       ║
-- ║     Rayfield UI  +  CodeBox Editor       ║
-- ╚══════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ══════════════ SERVICES ══════════════
local Players            = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local TweenService       = game:GetService("TweenService")
local UIS                = game:GetService("UserInputService")
local LP                 = Players.LocalPlayer
local PlayerGui          = LP:WaitForChild("PlayerGui")

-- ══════════════ STATE ══════════════
local botEnabled     = false
local customCommands = {}   -- [".name"] = { trigger = "...", stop = "..." }
local followThread   = nil
local followTarget   = nil
local chatConn       = nil
local chatConn2      = nil   -- TextChatService listener

-- ══════════════ SEND CHAT ══════════════
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

-- ══════════════ STOP FOLLOW ══════════════
local function stopFollow()
    if followThread then task.cancel(followThread) followThread = nil end
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
        if p ~= LP and (p.Name:lower():find(name:lower(),1,true) or p.DisplayName:lower():find(name:lower(),1,true)) then
            local mC, tC = LP.Character, p.Character
            if mC and tC then
                local mH, tH = mC:FindFirstChild("HumanoidRootPart"), tC:FindFirstChild("HumanoidRootPart")
                if mH and tH then
                    mH.CFrame = tH.CFrame * CFrame.new(3,0,0)
                    sendChat("[Bot] Teleported to " .. p.Name) return
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
        if tool then tool.Parent = LP.Backpack sendChat("[Bot] Tool loaded!")
        else sendChat("[Bot] No tool in asset " .. id) end
        model:Destroy()
    end)
    if not ok then sendChat("[Bot] Error: " .. tostring(err)) end
end

local function cmd_follow(args)
    local name = args[1]
    if not name then sendChat("[Bot] Usage: .follow (username)") return end
    stopFollow()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and (p.Name:lower():find(name:lower(),1,true) or p.DisplayName:lower():find(name:lower(),1,true)) then
            followTarget = p break
        end
    end
    if not followTarget then sendChat("[Bot] Not found: " .. name) return end
    sendChat("[Bot] Following " .. followTarget.Name .. " | .unfollow to stop")
    -- Helper: MoveTo dengan timeout biar tidak hang
    local function moveToSafe(hum, pos, timeout)
        hum:MoveTo(pos)
        local done = false
        local conn
        conn = hum.MoveToFinished:Connect(function()
            done = true
            conn:Disconnect()
        end)
        local t = 0
        while not done and t < (timeout or 1.2) do
            task.wait(0.1)
            t = t + 0.1
        end
        if conn then pcall(function() conn:Disconnect() end) end
    end

    followThread = task.spawn(function()
        while followTarget do
            task.wait(0.35)

            local mC = LP.Character
            local tC = followTarget.Character

            -- Ganti continue dengan if/else (Delta tidak support continue)
            if mC and tC then
                local mHRP = mC:FindFirstChild("HumanoidRootPart")
                local tHRP = tC:FindFirstChild("HumanoidRootPart")
                local hum  = mC:FindFirstChildOfClass("Humanoid")

                if mHRP and tHRP and hum then
                    local dist = (mHRP.Position - tHRP.Position).Magnitude

                    if dist > 5 then
                        -- Coba pathfinding dulu
                        local path = PathfindingService:CreatePath({
                            AgentRadius  = 2,
                            AgentHeight  = 5,
                            AgentCanJump = true,
                        })
                        local ok = pcall(function()
                            path:ComputeAsync(mHRP.Position, tHRP.Position)
                        end)

                        if ok and path.Status == Enum.PathStatus.Success then
                            local wps = path:GetWaypoints()
                            for _, wp in ipairs(wps) do
                                if not followTarget then break end
                                -- Re-cek jarak, kalau sudah dekat stop waypoint
                                local curHRP = (LP.Character or {}):FindFirstChild("HumanoidRootPart")
                                local tarHRP = (followTarget.Character or {}):FindFirstChild("HumanoidRootPart")
                                if curHRP and tarHRP then
                                    if (curHRP.Position - tarHRP.Position).Magnitude <= 5 then break end
                                end
                                if wp.Action == Enum.PathWaypointAction.Jump then
                                    hum.Jump = true
                                end
                                moveToSafe(hum, wp.Position, 1.0)
                            end
                        else
                            -- Fallback: langsung jalan ke target
                            moveToSafe(hum, tHRP.Position, 1.5)
                        end
                    end
                end
            else
                task.wait(0.8) -- tunggu character respawn
            end
        end
    end)
end

local function cmd_cmds()
    task.spawn(function()
        sendChat("=== BASIC COMMANDS ===")
        task.wait(0.4)
        sendChat(".Teleport (Username)  |  .Tools (AssetId)  |  .Follow (Username)  |  .Unfollow")
        task.wait(0.4)
        if next(customCommands) then
            local list = {}
            for n, data in pairs(customCommands) do
                local entry = n
                if data.stop and data.stop ~= "" then
                    entry = entry .. " (.Un" .. n:sub(2) .. ")"
                end
                table.insert(list, entry)
            end
            sendChat("=== CUSTOM: " .. table.concat(list, "  |  ") .. " ===")
        else
            sendChat("(Belum ada custom command)")
        end
    end)
end

local BUILTINS = {
    [".teleport"] = cmd_teleport, [".tp"] = cmd_teleport,
    [".tools"]    = cmd_tools,
    [".follow"]   = cmd_follow,
    [".unfollow"] = function() stopFollow() sendChat("[Bot] Unfollowed.") end,
    [".cmds"]     = function() cmd_cmds() end,
    [".commands"] = function() cmd_cmds() end,
}

-- ══════════════ CHAT HANDLER ══════════════
local function onChat(raw)
    if not botEnabled then return end
    raw = raw:match("^%s*(.-)%s*$")
    if raw == "" then return end
    local parts = {}
    for w in raw:gmatch("%S+") do table.insert(parts, w) end
    local cmd  = parts[1]:lower()
    local args = {}
    for i = 2, #parts do table.insert(args, parts[i]) end

    if BUILTINS[cmd] then BUILTINS[cmd](args) return end

    for name, data in pairs(customCommands) do
        if name:lower() == cmd then
            _G.cmdArgs = args
            local fn, err = loadstring(data.trigger or "")
            if fn then pcall(fn) else sendChat("[Bot] Error: " .. tostring(err):sub(1,60)) end
            return
        end
        -- .Un prefix → stop script
        local stopName = ".un" .. name:sub(2)
        if stopName == cmd and data.stop and data.stop ~= "" then
            _G.cmdArgs = args
            local fn, err = loadstring(data.stop)
            if fn then pcall(fn) else sendChat("[Bot] Stop Error: " .. tostring(err):sub(1,60)) end
            return
        end
    end
end

-- ══════════════════════════════════════════════════
--                  CODEBOX GUI
-- ══════════════════════════════════════════════════

-- Template otomatis di editor
local TEMPLATE = [[-- ▶ TRIGGER SCRIPT
-- Dijalankan saat command dipanggil di chat
-- Args: _G.cmdArgs[1], _G.cmdArgs[2], dst...

-- Tulis script di sini:


-- ■ STOP SCRIPT  (HAPUS BAGIAN INI JIKA TIDAK PERLU)
-- Otomatis terdaftar sebagai ".Un[namacommand]"
-- Contoh: command .dance → stop dengan .Undance

-- Tulis script stop di sini:
]]

-- Palette
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

    -- Backdrop
    local bd = Instance.new("Frame", sg)
    bd.Size = UDim2.new(1,0,1,0)
    bd.BackgroundColor3 = Color3.new(0,0,0)
    bd.BackgroundTransparency = 0.45
    bd.ZIndex = 14

    -- Window frame
    local win = Instance.new("Frame", sg)
    win.Size = UDim2.new(0,640,0,510)
    win.Position = UDim2.new(0.5,-320,0.5,-255)
    win.BackgroundColor3 = C.bg
    win.ZIndex = 15
    Instance.new("UICorner",win).CornerRadius = UDim.new(0,12)
    local ws = Instance.new("UIStroke",win)
    ws.Color = C.border  ws.Thickness = 1.5  ws.Transparency = 0.25

    -- Pop-in
    win.Size = UDim2.new(0,640,0,0)
    TweenService:Create(win,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,640,0,510)}):Play()

    local function closeBox()
        TweenService:Create(win,TweenInfo.new(0.18),{Size=UDim2.new(0,640,0,0)}):Play()
        task.wait(0.2)  sg:Destroy()  codeBoxOpen = false
    end

    -- ── Title bar ──
    local tb = Instance.new("Frame", win)
    tb.Size = UDim2.new(1,0,0,46)
    tb.BackgroundColor3 = C.panel
    tb.BorderSizePixel = 0  tb.ZIndex = 16
    Instance.new("UICorner",tb).CornerRadius = UDim.new(0,12)
    local tbFix = Instance.new("Frame",tb)
    tbFix.Size = UDim2.new(1,0,0,12)  tbFix.Position = UDim2.new(0,0,1,-12)
    tbFix.BackgroundColor3 = C.panel  tbFix.BorderSizePixel = 0  tbFix.ZIndex = 16

    local ttl = Instance.new("TextLabel",tb)
    ttl.Text = "  ⌨  CodeBox  —  Command Builder"
    ttl.TextColor3 = C.text  ttl.Font = Enum.Font.GothamBold  ttl.TextSize = 15
    ttl.BackgroundTransparency = 1  ttl.Size = UDim2.new(1,-50,1,0)
    ttl.TextXAlignment = Enum.TextXAlignment.Left  ttl.ZIndex = 17

    local xBtn = Instance.new("TextButton",tb)
    xBtn.Text = "✕"  xBtn.TextColor3 = C.sub
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

    -- ── Content ──
    local pad = 14
    local cx = Instance.new("Frame",win)
    cx.Size = UDim2.new(1,-pad*2,1,-60)
    cx.Position = UDim2.new(0,pad,0,52)
    cx.BackgroundTransparency = 1  cx.ZIndex = 16

    -- Command Name label + box
    local nl = Instance.new("TextLabel",cx)
    nl.Text = "Command Name  (contoh: .dance  |  .speed)"
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
    local ns = Instance.new("UIStroke",nameBox)  ns.Color = C.border  ns.Thickness = 1

    -- Script editor label
    local sl = Instance.new("TextLabel",cx)
    sl.Text = "Script Editor  —  hapus bagian '■ STOP SCRIPT' jika tidak diperlukan"
    sl.TextColor3 = C.sub  sl.Font = Enum.Font.GothamBold  sl.TextSize = 12
    sl.BackgroundTransparency = 1  sl.Size = UDim2.new(1,0,0,16)
    sl.Position = UDim2.new(0,0,0,64)
    sl.TextXAlignment = Enum.TextXAlignment.Left  sl.ZIndex = 17

    -- Editor wrapper
    local ew = Instance.new("Frame",cx)
    ew.Size = UDim2.new(1,0,0,286)  ew.Position = UDim2.new(0,0,0,84)
    ew.BackgroundColor3 = C.input  ew.ZIndex = 16
    Instance.new("UICorner",ew).CornerRadius = UDim.new(0,8)
    local es = Instance.new("UIStroke",ew)  es.Color = C.border  es.Thickness = 1

    -- Line number panel
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

    -- Script TextBox
    local scriptBox = Instance.new("TextBox",ew)
    scriptBox.Size = UDim2.new(1,-46,1,-8)  scriptBox.Position = UDim2.new(0,44,0,4)
    scriptBox.BackgroundTransparency = 1
    scriptBox.TextColor3 = C.text  scriptBox.Font = Enum.Font.Code  scriptBox.TextSize = 13
    scriptBox.ClearTextOnFocus = false  scriptBox.MultiLine = true
    scriptBox.TextXAlignment = Enum.TextXAlignment.Left
    scriptBox.TextYAlignment = Enum.TextYAlignment.Top
    scriptBox.Text = TEMPLATE  scriptBox.ZIndex = 17

    -- Update line numbers
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

    -- ── Buttons ──
    local br = Instance.new("Frame",cx)
    br.Size = UDim2.new(1,0,0,38)  br.Position = UDim2.new(0,0,0,380)
    br.BackgroundTransparency = 1  br.ZIndex = 16

    makeBtn(br, "✅  Save Command", C.green, UDim2.new(0,0,0,0), UDim2.new(0.48,0,1,0), function()
        local name = nameBox.Text:match("^%s*(.-)%s*$")
        local src  = scriptBox.Text

        if name == "" then
            Rayfield:Notify({Title="Error",Content="Isi Command Name dulu!",Duration=3,Image=4483362458})
            return
        end
        if name:sub(1,1) ~= "." then name = "." .. name end
        name = name:lower()
        if BUILTINS[name] then
            Rayfield:Notify({Title="⚠️ Blocked",Content="'"..name.."' adalah built-in!",Duration=4,Image=4483362458})
            return
        end

        -- Split pada marker  "-- ■ STOP"
        local triggerPart = src
        local stopPart    = ""
        local marker = src:find("%-%-[^\n]*■ STOP")
        if marker then
            triggerPart = src:sub(1, marker-1):match("^(.-)%s*$")
            local stopSection = src:sub(marker)
            -- Skip comment header lines, ambil baris kode aktif
            local afterHeader = stopSection:match("%-%-[^\n]*\n%-%-[^\n]*\n%-%-[^\n]*\n(.*)")
                             or stopSection:match("%-%-[^\n]*\n%-%-[^\n]*\n(.*)")
                             or stopSection:match("%-%-[^\n]*\n(.*)")
                             or ""
            stopPart = afterHeader:match("^%s*(.-)%s*$") or ""
        end

        customCommands[name] = { trigger = triggerPart, stop = stopPart }

        local stopInfo = (stopPart ~= "") and ("  +  .Un" .. name:sub(2) .. " (stop)") or ""
        Rayfield:Notify({
            Title   = "✅ Saved!",
            Content = "'"..name.."'"..stopInfo.." ditambahkan!",
            Duration = 3, Image = 4483362458,
        })
        closeBox()
    end)

    makeBtn(br, "✕  Cancel", C.red, UDim2.new(0.52,0,0,0), UDim2.new(0.48,0,1,0), closeBox)

    -- Hint
    local hint = Instance.new("TextLabel",cx)
    hint.Text = "💡 _G.cmdArgs[1..n] untuk args  |  Stop otomatis = .Un[command]  |  Drag title bar untuk pindah"
    hint.TextColor3 = C.sub  hint.Font = Enum.Font.Gotham  hint.TextSize = 11
    hint.BackgroundTransparency = 1  hint.Size = UDim2.new(1,0,0,14)
    hint.Position = UDim2.new(0,0,0,424)
    hint.TextXAlignment = Enum.TextXAlignment.Left  hint.ZIndex = 16
end

-- ══════════════ RAYFIELD UI ══════════════
local Window = Rayfield:CreateWindow({
    Name            = "CommandBot  |  KHAFIDZKTP",
    LoadingTitle    = "CommandBot",
    LoadingSubtitle = "Initializing...",
    Theme           = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings   = false,
    ConfigurationSaving    = { Enabled = false },
})

-- ─── TAB: CONTROL ───
local CtrlTab = Window:CreateTab("⚡ Control", 4483362458)
CtrlTab:CreateSection("Bot Toggle")
CtrlTab:CreateToggle({
    Name = "Enable Bot", CurrentValue = false, Flag = "BotEnabled",
    Callback = function(val)
        botEnabled = val
        if val then
            -- Disconnect lama
            if chatConn  then chatConn:Disconnect()  chatConn  = nil end
            if chatConn2 then chatConn2:Disconnect() chatConn2 = nil end

            -- ── Metode 1: LP.Chatted (legacy chat / server-replicated)
            chatConn = LP.Chatted:Connect(function(msg)
                onChat(msg)
            end)

            -- ── Metode 2: TextChatService.MessageReceived
            -- LP.Chatted tidak fire untuk pesan SENDIRI di TextChatService baru!
            -- Ini fix utamanya.
            pcall(function()
                local TCS = game:GetService("TextChatService")
                chatConn2 = TCS.MessageReceived:Connect(function(msg)
                    -- Hanya proses pesan dari LocalPlayer sendiri
                    if msg.TextSource then
                        local ok, userId = pcall(function() return msg.TextSource.UserId end)
                        if ok and userId == LP.UserId then
                            onChat(msg.Text)
                        end
                    end
                end)
            end)

            task.wait(0.4)
            sendChat("Thanks Using My Script! | Say .cmds in Chat!")
        else
            if chatConn  then chatConn:Disconnect()  chatConn  = nil end
            if chatConn2 then chatConn2:Disconnect() chatConn2 = nil end
            stopFollow()
        end
    end,
})
CtrlTab:CreateSection("Quick Actions")
CtrlTab:CreateButton({
    Name = "📋 List Commands in Chat",
    Callback = function()
        if botEnabled then cmd_cmds()
        else Rayfield:Notify({Title="Bot Disabled",Content="Enable bot dulu!",Duration=3,Image=4483362458}) end
    end,
})
CtrlTab:CreateButton({
    Name = "🛑 Stop Follow",
    Callback = function()
        stopFollow()
        Rayfield:Notify({Title="Stopped",Content="Follow dihentikan.",Duration=2,Image=4483362458})
    end,
})

-- ─── TAB: ADD COMMAND ───
local AddTab = Window:CreateTab("➕ Add Command", 4483362458)
AddTab:CreateSection("Custom Command Builder")
AddTab:CreateLabel("Klik 'Open CodeBox' untuk buka editor")
AddTab:CreateLabel("Template trigger & stop sudah ada otomatis")
AddTab:CreateLabel("Hapus bagian STOP jika command tidak butuh stop")
AddTab:CreateButton({
    Name = "⌨  Open CodeBox",
    Callback = function()
        if codeBoxOpen then
            Rayfield:Notify({Title="CodeBox",Content="CodeBox sudah terbuka!",Duration=2,Image=4483362458})
            return
        end
        openCodeBox()
    end,
})
AddTab:CreateSection("Manage")
AddTab:CreateButton({
    Name = "🗑️ Remove All Custom Commands",
    Callback = function()
        local c = 0
        for _ in pairs(customCommands) do c = c + 1 end
        customCommands = {}
        Rayfield:Notify({Title="Cleared!",Content=c.." command dihapus.",Duration=3,Image=4483362458})
    end,
})

-- ─── TAB: INFO ───
local InfoTab = Window:CreateTab("📖 Info", 4483362458)
InfoTab:CreateSection("Built-in Commands")
InfoTab:CreateLabel(".cmds → List semua command di chat")
InfoTab:CreateLabel(".teleport (username) → TP ke player")
InfoTab:CreateLabel(".tools (assetid) → Ambil tool dari catalog")
InfoTab:CreateLabel(".follow (username) → Pathfinding + bisa jump")
InfoTab:CreateLabel(".unfollow → Stop follow")
InfoTab:CreateSection("CodeBox Template")
InfoTab:CreateLabel("▶ TRIGGER SCRIPT → script utama command")
InfoTab:CreateLabel("■ STOP SCRIPT → hapus jika tidak diperlukan")
InfoTab:CreateLabel("Stop otomatis: .command → .Uncommand")
InfoTab:CreateSection("Credits")
InfoTab:CreateLabel("Made by KHAFIDZKTP  |  HaZcK/ScriptHub")
