--[[
╔══════════════════════════════════════════╗
║       SCRIPTHUB EXECUTOR GUI v1.0        ║
║         LocalScript - StarterPlayerScripts║
║         By KHAFIDZKTP                    ║
╚══════════════════════════════════════════╝
    PETUNJUK SETUP:
    1. Script ini → StarterPlayerScripts (LocalScript)
    2. ServerScript.lua → ServerScriptService (Script)
    3. Buat Folder "ScriptHubRemotes" di ReplicatedStorage
       berisi RemoteEvent:
       - ExecuteServer
       - BanPlayer
       - UnbanPlayer
       - AdminCheck
       - ServerModeRequest
       - ServerModeStatus
    4. Aktifkan ServerScriptService.LoadStringEnabled = true
       (via ServerScript atau plugin)
]]

-- ═══════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local RS              = game:GetService("ReplicatedStorage")

local player     = Players.LocalPlayer
local playerGui  = player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════
-- REMOTE EVENTS
-- ═══════════════════════════════════════════
local Remotes             = RS:WaitForChild("ScriptHubRemotes", 10)
local ExecServerRemote    = Remotes and Remotes:FindFirstChild("ExecuteServer")
local BanRemote           = Remotes and Remotes:FindFirstChild("BanPlayer")
local UnbanRemote         = Remotes and Remotes:FindFirstChild("UnbanPlayer")
local AdminCheckRemote    = Remotes and Remotes:FindFirstChild("AdminCheck")
local ServerModeRequest   = Remotes and Remotes:FindFirstChild("ServerModeRequest")
local ServerModeStatus    = Remotes and Remotes:FindFirstChild("ServerModeStatus")

-- ═══════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════
local savedCode           = nil          -- Kode tersimpan session
local serverSidedEnabled  = false
local serverExpiry        = 0            -- tick() kapan server mode habis
local serverCooldownExpiry= 0            -- tick() kapan cooldown selesai
local isAdmin             = (player.Name == "KHAFIDZKTP")
local mainOpen            = false
local currentTab          = "scripts"

-- ═══════════════════════════════════════════
-- SETTINGS
-- ═══════════════════════════════════════════
local S = {
    bg         = Color3.fromRGB(10, 10, 20),
    panel      = Color3.fromRGB(16, 16, 32),
    header     = Color3.fromRGB(14, 14, 26),
    accent     = Color3.fromRGB(88, 88, 230),
    accentHov  = Color3.fromRGB(110, 110, 255),
    text       = Color3.fromRGB(210, 215, 245),
    subText    = Color3.fromRGB(110, 115, 160),
    success    = Color3.fromRGB(60, 200, 100),
    error      = Color3.fromRGB(220, 70, 70),
    warning    = Color3.fromRGB(230, 170, 40),
    trans      = 0.06,
    highlight  = true,
    fontSize   = 13,
    execMode   = "client",  -- "client" | "server"
}

-- ═══════════════════════════════════════════
-- TEMPLATE SCRIPT
-- ═══════════════════════════════════════════
local TEMPLATE = [[-- ╔════════════════════════════════╗
-- ║   TEMPLATE SCRIPT - ScriptHub  ║
-- ║   Fly | Teleport | Invisible   ║
-- ╚════════════════════════════════╝

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- ══ FLY ══
local flying = false
local flySpeed = 60
local bv, bg, flyConn

local function startFly()
    character = player.Character; if not character then return end
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    humanoid.PlatformStand = true
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bg.D = 100
    bg.Parent = hrp
    flyConn = RunService.Heartbeat:Connect(function()
        if not flying then return end
        local dir = Vector3.zero
        local cf = camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.yAxis end
        if dir.Magnitude>0 then dir=dir.Unit end
        bv.Velocity = dir*flySpeed
        bg.CFrame = cf
    end)
end

local function stopFly()
    flying = false
    if bv then bv:Destroy() bv=nil end
    if bg then bg:Destroy() bg=nil end
    if flyConn then flyConn:Disconnect() flyConn=nil end
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

-- ══ INVISIBLE ══
local invisible = false
local origCF, camConn

local function startInvisible()
    character = player.Character; if not character then return end
    hrp = character:WaitForChild("HumanoidRootPart")
    origCF = hrp.CFrame
    hrp.CFrame = origCF * CFrame.new(0, -500, 0)
    -- Bagi player: kamera terkunci di posisi asli (kamu "terlihat" di tanah)
    camera.CameraType = Enum.CameraType.Scriptable
    local camOrigPos = origCF.Position + Vector3.new(0, 2, -8)
    camera.CFrame = CFrame.new(camOrigPos, origCF.Position + Vector3.new(0,1,0))
    camConn = RunService.RenderStepped:Connect(function()
        if not invisible then return end
        camera.CFrame = CFrame.new(camOrigPos, origCF.Position + Vector3.new(0,1,0))
    end)
    for _,v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") then v.LocalTransparencyModifier=1 end
    end
end

local function stopInvisible()
    invisible = false
    if camConn then camConn:Disconnect() camConn=nil end
    character = player.Character; if not character then return end
    hrp = character:WaitForChild("HumanoidRootPart")
    if origCF then hrp.CFrame = origCF*CFrame.new(0,3,0) end
    camera.CameraType = Enum.CameraType.Custom
    for _,v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") then v.LocalTransparencyModifier=0 end
    end
end

-- ══ TELEPORT ══
local function teleportTo(pos)
    character = player.Character; if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(pos) end
end

-- ══ TEMPLATE GUI ══
local tGui = Instance.new("ScreenGui")
tGui.Name = "TemplatePanel"; tGui.ResetOnSpawn=false
tGui.IgnoreGuiInset=true
tGui.Parent = player:WaitForChild("PlayerGui")

local tFrame = Instance.new("Frame")
tFrame.Size = UDim2.new(0,185,0,240)
tFrame.Position = UDim2.new(0,12,0.5,-120)
tFrame.BackgroundColor3 = Color3.fromRGB(10,10,20)
tFrame.BackgroundTransparency = 0.06
tFrame.BorderSizePixel=0; tFrame.Parent=tGui
Instance.new("UICorner",tFrame).CornerRadius=UDim.new(0,12)
local tStroke=Instance.new("UIStroke",tFrame)
tStroke.Color=Color3.fromRGB(88,88,230); tStroke.Thickness=1.5

local tTitle=Instance.new("TextLabel")
tTitle.Size=UDim2.new(1,0,0,36); tTitle.BackgroundTransparency=1
tTitle.Text="TEMPLATE FEATURES"; tTitle.TextColor3=Color3.fromRGB(180,180,255)
tTitle.Font=Enum.Font.GothamBold; tTitle.TextSize=11; tTitle.Parent=tFrame

local tDiv=Instance.new("Frame")
tDiv.Size=UDim2.new(0.85,0,0,1); tDiv.Position=UDim2.new(0.075,0,0,36)
tDiv.BackgroundColor3=Color3.fromRGB(60,60,180); tDiv.BorderSizePixel=0; tDiv.Parent=tFrame

local function mkToggle(lbl, yp, cb)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-18,0,40); btn.Position=UDim2.new(0,9,0,yp)
    btn.BackgroundColor3=Color3.fromRGB(20,20,38); btn.BorderSizePixel=0
    btn.Text=""; btn.AutoButtonColor=false; btn.Parent=tFrame
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    local lbL=Instance.new("TextLabel"); lbL.Size=UDim2.new(0.6,0,1,0)
    lbL.Position=UDim2.new(0,10,0,0); lbL.BackgroundTransparency=1
    lbL.Text=lbl; lbL.TextColor3=Color3.fromRGB(185,185,225)
    lbL.Font=Enum.Font.Gotham; lbL.TextSize=12; lbL.TextXAlignment=Enum.TextXAlignment.Left
    lbL.Parent=btn
    local track=Instance.new("Frame"); track.Size=UDim2.new(0,38,0,20)
    track.Position=UDim2.new(1,-46,0.5,-10); track.BackgroundColor3=Color3.fromRGB(40,40,65)
    track.BorderSizePixel=0; track.Parent=btn
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,16,0,16)
    knob.Position=UDim2.new(0,2,0.5,-8); knob.BackgroundColor3=Color3.fromRGB(130,130,170)
    knob.BorderSizePixel=0; knob.Parent=track
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local on=false
    btn.MouseButton1Click:Connect(function()
        on=not on
        if on then
            TweenService:Create(track,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(88,88,230)}):Play()
            TweenService:Create(knob,TweenInfo.new(0.2),{Position=UDim2.new(0,20,0.5,-8),BackgroundColor3=Color3.fromRGB(220,220,255)}):Play()
        else
            TweenService:Create(track,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(40,40,65)}):Play()
            TweenService:Create(knob,TweenInfo.new(0.2),{Position=UDim2.new(0,2,0.5,-8),BackgroundColor3=Color3.fromRGB(130,130,170)}):Play()
        end
        cb(on)
    end)
end

mkToggle("✈  Fly", 45, function(on)
    flying=on; if on then startFly() else stopFly() end
end)
mkToggle("👁  Invisible", 95, function(on)
    invisible=on; if on then startInvisible() else stopInvisible() end
end)

local tpBtn=Instance.new("TextButton")
tpBtn.Size=UDim2.new(1,-18,0,38); tpBtn.Position=UDim2.new(0,9,0,145)
tpBtn.BackgroundColor3=Color3.fromRGB(20,20,38); tpBtn.BorderSizePixel=0
tpBtn.Text="🌀  Teleport (0, 0, 0)"; tpBtn.TextColor3=Color3.fromRGB(185,185,225)
tpBtn.Font=Enum.Font.Gotham; tpBtn.TextSize=12; tpBtn.Parent=tFrame
Instance.new("UICorner",tpBtn).CornerRadius=UDim.new(0,8)
tpBtn.MouseButton1Click:Connect(function() teleportTo(Vector3.new(0,10,0)) end)

local clsBtn=Instance.new("TextButton")
clsBtn.Size=UDim2.new(1,-18,0,30); clsBtn.Position=UDim2.new(0,9,0,193)
clsBtn.BackgroundColor3=Color3.fromRGB(35,15,15); clsBtn.BorderSizePixel=0
clsBtn.Text="✕  Tutup Panel"; clsBtn.TextColor3=Color3.fromRGB(220,100,100)
clsBtn.Font=Enum.Font.Gotham; clsBtn.TextSize=12; clsBtn.Parent=tFrame
Instance.new("UICorner",clsBtn).CornerRadius=UDim.new(0,8)
clsBtn.MouseButton1Click:Connect(function()
    tGui:Destroy()
end)
]]

-- ═══════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════
local function tween(obj, props, t, style, dir)
    TweenService:Create(obj, TweenInfo.new(
        t or 0.2,
        style or Enum.EasingStyle.Quad,
        dir or Enum.EasingDirection.Out
    ), props):Play()
end

local function mkCorner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function mkStroke(parent, col, thick)
    local s = Instance.new("UIStroke", parent)
    s.Color = col or S.accent
    s.Thickness = thick or 1.5
    return s
end

-- ═══════════════════════════════════════════
-- SECURITY: Deteksi Script Berbahaya
-- ═══════════════════════════════════════════
local DANGEROUS_PATTERNS = {
    -- Map & server destruction
    "workspace%s*:%s*ClearAllChildren",
    "workspace%s*:%s*Destroy",
    "game%s*:%s*Shutdown",
    "game%s*.Workspace%s*:%s*ClearAllChildren",
    -- Sound abuse
    "Sound%s*%.%s*Volume%s*=%s*[5-9]%d",
    "Sound%s*%.%s*Volume%s*=%s*%d%d%d",
    -- Decal spam
    "while%s*true%s*do.*Decal",
    "for%s*.*Decal.*do",
    -- Data wipe
    "DataStore.*Remove",
    "DataStore.*Delete",
    -- Kick/ban abuse
    "Players%s*:%s*GetPlayers.*:Kick",
    -- Teleport service abuse
    "TeleportService%s*:%s*Teleport%s*%(",
}

local function isMalicious(code)
    local lower = code:lower()
    for _, pat in ipairs(DANGEROUS_PATTERNS) do
        if code:match(pat) or lower:match(pat:lower()) then
            return true, pat
        end
    end
    return false, nil
end

-- ═══════════════════════════════════════════
-- SERVER SIDED TIMER MANAGEMENT
-- ═══════════════════════════════════════════
local SERVER_DURATION = 7 * 3600   -- 7 jam
local SERVER_COOLDOWN = 24 * 3600  -- 24 jam

local function getServerTimeLeft()
    if not serverSidedEnabled then return 0 end
    return math.max(0, serverExpiry - tick())
end

local function getServerCooldownLeft()
    return math.max(0, serverCooldownExpiry - tick())
end

local function enableServerMode()
    serverSidedEnabled = true
    serverExpiry = tick() + SERVER_DURATION
    S.execMode = "server"
end

local function disableServerMode(startCooldown)
    serverSidedEnabled = false
    S.execMode = "client"
    if startCooldown then
        serverCooldownExpiry = tick() + SERVER_COOLDOWN
    end
end

-- Auto-reset ke client setelah 7 jam
RunService.Heartbeat:Connect(function()
    if serverSidedEnabled and tick() >= serverExpiry then
        disableServerMode(true)
        -- Notifikasi (akan diupdate ke label jika GUI terbuka)
    end
end)

-- ═══════════════════════════════════════════
-- HIDDEN COMMAND DETECTOR
-- ═══════════════════════════════════════════
local SECRET_CMD_LOWER = "/setting-server-sided()"

local function checkHiddenCommand(code)
    -- Case-insensitive check
    if code:lower():match(secret_cmd_lower:gsub("%(","%%%("):gsub("%)","%%%)")) then
        return true
    end
    -- Juga cek tanpa spasi
    local stripped = code:lower():gsub("%s","")
    local secretStripped = SECRET_CMD_LOWER:gsub("%s","")
    return stripped:find(secretStripped, 1, true) ~= nil
end

-- Fix: gunakan variabel langsung
local function checkSecret(code)
    local c = code:lower():gsub("%s+","")
    local s = "/setting-server-sided()"
    return c:find(s:gsub("%(","%%%("):gsub("%)","%%%)"), 1, false) ~= nil
        or code:lower():find("/setting%-server%-sided%(%)") ~= nil
end

-- ═══════════════════════════════════════════
-- MAIN SCREEN GUI
-- ═══════════════════════════════════════════
local screenGui = Instance.new("ScreenGui")
screenGui.Name       = "ScriptHubExecutor"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent     = playerGui

-- ─── TAB BUTTON (kanan layar) ─────────────
local tabBtn = Instance.new("TextButton")
tabBtn.Name   = "TabBtn"
tabBtn.Size   = UDim2.new(0, 28, 0, 100)
tabBtn.Position = UDim2.new(1, -28, 0.5, -50)
tabBtn.BackgroundColor3 = S.accent
tabBtn.BorderSizePixel  = 0
tabBtn.Text   = ""
tabBtn.ZIndex = 10
tabBtn.Parent = screenGui
mkCorner(tabBtn, 8)

-- Teks vertikal "SCRIPTS"
local tabLabel = Instance.new("TextLabel")
tabLabel.Size   = UDim2.new(1, 0, 1, 0)
tabLabel.BackgroundTransparency = 1
tabLabel.Text   = "S\nC\nR\nI\nP\nT\nS"
tabLabel.TextColor3 = Color3.fromRGB(255,255,255)
tabLabel.Font   = Enum.Font.GothamBold
tabLabel.TextSize = 11
tabLabel.LineHeight = 1.1
tabLabel.ZIndex = 11
tabLabel.Parent = tabBtn

-- ─── PANEL UTAMA ──────────────────────────
local panel = Instance.new("Frame")
panel.Name   = "MainPanel"
panel.Size   = UDim2.new(0, 560, 0, 440)
panel.Position = UDim2.new(1, 0, 0.5, -220)  -- dimulai di luar layar
panel.BackgroundColor3 = S.bg
panel.BackgroundTransparency = S.trans
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Parent = screenGui
mkCorner(panel, 12)
mkStroke(panel, S.accent, 1.5)

-- ─── HEADER PANEL ─────────────────────────
local header = Instance.new("Frame")
header.Size  = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = S.header
header.BorderSizePixel  = 0
header.Parent = panel
mkCorner(header, 12)

-- Fix corner bawah header
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1,0,0,12)
headerFix.Position = UDim2.new(0,0,1,-12)
headerFix.BackgroundColor3 = S.header
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local headerTitle = Instance.new("TextLabel")
headerTitle.Size  = UDim2.new(0.6, 0, 1, 0)
headerTitle.Position = UDim2.new(0, 16, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text  = "⚡ ScriptHub Executor"
headerTitle.TextColor3 = S.text
headerTitle.Font  = Enum.Font.GothamBold
headerTitle.TextSize = 14
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = header

-- Mode indicator
local modeLabel = Instance.new("TextLabel")
modeLabel.Size  = UDim2.new(0, 140, 0, 22)
modeLabel.Position = UDim2.new(0.5, -20, 0.5, -11)
modeLabel.BackgroundColor3 = Color3.fromRGB(20,20,40)
modeLabel.BackgroundTransparency = 0
modeLabel.Text  = "● CLIENT-SIDED"
modeLabel.TextColor3 = S.success
modeLabel.Font  = Enum.Font.GothamBold
modeLabel.TextSize = 10
modeLabel.Parent = header
mkCorner(modeLabel, 6)

-- Close button header
local closeBtn = Instance.new("TextButton")
closeBtn.Size   = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(35,15,15)
closeBtn.BorderSizePixel  = 0
closeBtn.Text   = "✕"
closeBtn.TextColor3 = Color3.fromRGB(220,80,80)
closeBtn.Font   = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = header
mkCorner(closeBtn, 8)

-- ─── TABS NAVIGATION ──────────────────────
local tabNav = Instance.new("Frame")
tabNav.Size  = UDim2.new(1, 0, 0, 36)
tabNav.Position = UDim2.new(0, 0, 0, 44)
tabNav.BackgroundColor3 = S.panel
tabNav.BorderSizePixel  = 0
tabNav.Parent = panel

local tabButtons = {}
local tabPages   = {}

local function makeNavTab(name, label, xpos)
    local btn = Instance.new("TextButton")
    btn.Size  = UDim2.new(0, 120, 0, 36)
    btn.Position = UDim2.new(0, xpos, 0, 0)
    btn.BackgroundColor3 = S.panel
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text  = label
    btn.TextColor3 = S.subText
    btn.Font  = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = tabNav
    tabButtons[name] = btn

    local indicator = Instance.new("Frame")
    indicator.Size  = UDim2.new(0.7, 0, 0, 2)
    indicator.Position = UDim2.new(0.15, 0, 1, -2)
    indicator.BackgroundColor3 = S.accent
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Parent = btn

    btn._indicator = indicator
    return btn
end

local btnScripts = makeNavTab("scripts", "📜  Scripts", 8)
local btnSettings= makeNavTab("settings","⚙  Settings", 136)
local btnAdmin   = isAdmin and makeNavTab("admin", "👑  Admin", 264) or nil

-- ─── TAB PAGES ────────────────────────────
local function makePage(name)
    local page = Instance.new("Frame")
    page.Name  = name
    page.Size  = UDim2.new(1, 0, 1, -80)
    page.Position = UDim2.new(0, 0, 0, 80)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.Parent  = panel
    tabPages[name] = page
    return page
end

local pageScripts  = makePage("scripts")
local pageSettings = makePage("settings")
local pageAdmin    = isAdmin and makePage("admin") or nil

-- Tab switching logic
local function switchTab(name)
    currentTab = name
    for n, btn in pairs(tabButtons) do
        local active = (n == name)
        tween(btn, {TextColor3 = active and S.text or S.subText})
        tween(btn._indicator, {BackgroundTransparency = active and 0 or 1})
    end
    for n, page in pairs(tabPages) do
        page.Visible = (n == name)
    end
end

-- ═══════════════════════════════════════════
-- TAB: SCRIPTS
-- ═══════════════════════════════════════════

-- Label atas codebox
local codeLabel = Instance.new("TextLabel")
codeLabel.Size  = UDim2.new(0, 120, 0, 22)
codeLabel.Position = UDim2.new(0, 12, 0, 6)
codeLabel.BackgroundTransparency = 1
codeLabel.Text  = "◈ Code Editor"
codeLabel.TextColor3 = S.subText
codeLabel.Font  = Enum.Font.GothamBold
codeLabel.TextSize = 11
codeLabel.TextXAlignment = Enum.TextXAlignment.Left
codeLabel.Parent = pageScripts

-- Mode badge di samping label
local modeBadge = Instance.new("TextLabel")
modeBadge.Size  = UDim2.new(0, 110, 0, 18)
modeBadge.Position = UDim2.new(0, 136, 0, 8)
modeBadge.BackgroundColor3 = Color3.fromRGB(20,40,20)
modeBadge.Text  = "⬤ CLIENT-SIDED"
modeBadge.TextColor3 = S.success
modeBadge.Font  = Enum.Font.GothamBold
modeBadge.TextSize = 9
modeBadge.Parent = pageScripts
mkCorner(modeBadge, 5)

-- ─── CODEBOX CONTAINER ────────────────────
local codeContainer = Instance.new("Frame")
codeContainer.Size  = UDim2.new(1, -16, 0, 190)
codeContainer.Position = UDim2.new(0, 8, 0, 32)
codeContainer.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
codeContainer.BorderSizePixel  = 0
codeContainer.ClipsDescendants = true
codeContainer.Parent = pageScripts
mkCorner(codeContainer, 8)
mkStroke(codeContainer, Color3.fromRGB(40,40,80), 1)

-- Line numbers (dekoratif)
local lineNumFrame = Instance.new("Frame")
lineNumFrame.Size  = UDim2.new(0, 30, 1, 0)
lineNumFrame.BackgroundColor3 = Color3.fromRGB(12,12,22)
lineNumFrame.BorderSizePixel  = 0
lineNumFrame.Parent = codeContainer

local lineNumLabel = Instance.new("TextLabel")
lineNumLabel.Size  = UDim2.new(1, 0, 1, 0)
lineNumLabel.BackgroundTransparency = 1
lineNumLabel.Text  = "1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13"
lineNumLabel.TextColor3 = Color3.fromRGB(60,60,100)
lineNumLabel.Font  = Enum.Font.Code
lineNumLabel.TextSize = 11
lineNumLabel.TextYAlignment = Enum.TextYAlignment.Top
lineNumLabel.Parent = lineNumFrame

-- Scrolling TextBox
local codeScroll = Instance.new("ScrollingFrame")
codeScroll.Size  = UDim2.new(1, -30, 1, 0)
codeScroll.Position = UDim2.new(0, 30, 0, 0)
codeScroll.BackgroundTransparency = 1
codeScroll.BorderSizePixel = 0
codeScroll.ScrollBarThickness = 4
codeScroll.ScrollBarImageColor3 = S.accent
codeScroll.CanvasSize = UDim2.new(0, 0, 3, 0)
codeScroll.Parent = codeContainer

local codeBox = Instance.new("TextBox")
codeBox.Size  = UDim2.new(1, -8, 1, 0)
codeBox.Position = UDim2.new(0, 6, 0, 4)
codeBox.BackgroundTransparency = 1
codeBox.Text  = savedCode or TEMPLATE
codeBox.TextColor3 = Color3.fromRGB(200, 210, 255)
codeBox.Font  = Enum.Font.Code
codeBox.TextSize = 12
codeBox.TextXAlignment = Enum.TextXAlignment.Left
codeBox.TextYAlignment = Enum.TextYAlignment.Top
codeBox.MultiLine = true
codeBox.ClearTextOnFocus = false
codeBox.PlaceholderText = "-- Ketik script kamu di sini..."
codeBox.PlaceholderColor3 = Color3.fromRGB(60,60,100)
codeBox.Parent = codeScroll

-- Update line numbers
codeBox:GetPropertyChangedSignal("Text"):Connect(function()
    savedCode = codeBox.Text
    local lines = 1
    for _ in codeBox.Text:gmatch("\n") do lines = lines + 1 end
    local nums = {}
    for i = 1, math.max(lines, 13) do nums[i] = tostring(i) end
    lineNumLabel.Text = table.concat(nums, "\n")
end)

-- ─── BUTTONS ROW ──────────────────────────
local btnRow = Instance.new("Frame")
btnRow.Size  = UDim2.new(1, -16, 0, 36)
btnRow.Position = UDim2.new(0, 8, 0, 228)
btnRow.BackgroundTransparency = 1
btnRow.Parent = pageScripts

local function mkButton(txt, xp, w, bgCol, txtCol)
    local b = Instance.new("TextButton")
    b.Size  = UDim2.new(0, w, 1, 0)
    b.Position = UDim2.new(0, xp, 0, 0)
    b.BackgroundColor3 = bgCol
    b.BorderSizePixel  = 0
    b.Text  = txt
    b.TextColor3 = txtCol or Color3.fromRGB(255,255,255)
    b.Font  = Enum.Font.GothamBold
    b.TextSize = 12
    b.AutoButtonColor = false
    b.Parent = btnRow
    mkCorner(b, 8)
    -- Hover effect
    b.MouseEnter:Connect(function()
        tween(b, {BackgroundColor3 = bgCol:lerp(Color3.fromRGB(255,255,255), 0.12)})
    end)
    b.MouseLeave:Connect(function()
        tween(b, {BackgroundColor3 = bgCol})
    end)
    return b
end

local executeBtn = mkButton("▶ Execute", 0, 170, S.accent)
local clearBtn   = mkButton("⌫ Clear", 178, 90, Color3.fromRGB(40,25,25), Color3.fromRGB(220,110,110))
local templateBtn= mkButton("📄 Template", 276, 120, Color3.fromRGB(25,35,25), Color3.fromRGB(110,200,110))

-- ─── OUTPUT AREA ──────────────────────────
local outLabel = Instance.new("TextLabel")
outLabel.Size  = UDim2.new(0, 80, 0, 18)
outLabel.Position = UDim2.new(0, 12, 0, 272)
outLabel.BackgroundTransparency = 1
outLabel.Text  = "◈ Output"
outLabel.TextColor3 = S.subText
outLabel.Font  = Enum.Font.GothamBold
outLabel.TextSize = 11
outLabel.TextXAlignment = Enum.TextXAlignment.Left
outLabel.Parent = pageScripts

local outputFrame = Instance.new("ScrollingFrame")
outputFrame.Size  = UDim2.new(1, -16, 0, 72)
outputFrame.Position = UDim2.new(0, 8, 0, 292)
outputFrame.BackgroundColor3 = Color3.fromRGB(6,6,12)
outputFrame.BorderSizePixel  = 0
outputFrame.ScrollBarThickness = 4
outputFrame.ScrollBarImageColor3 = S.accent
outputFrame.CanvasSize = UDim2.new(0,0,0,0)
outputFrame.Parent = pageScripts
mkCorner(outputFrame, 8)
mkStroke(outputFrame, Color3.fromRGB(30,30,60), 1)

local outputText = Instance.new("TextLabel")
outputText.Size  = UDim2.new(1, -12, 1, 0)
outputText.Position = UDim2.new(0, 8, 0, 4)
outputText.BackgroundTransparency = 1
outputText.Text  = "[System]: Siap. Ketik script dan klik Execute."
outputText.TextColor3 = S.subText
outputText.Font  = Enum.Font.Code
outputText.TextSize = 11
outputText.TextXAlignment = Enum.TextXAlignment.Left
outputText.TextYAlignment = Enum.TextYAlignment.Top
outputText.TextWrapped = true
outputText.RichText = false
outputText.Parent = outputFrame

-- Update canvas size outputText
outputText:GetPropertyChangedSignal("TextBounds"):Connect(function()
    local newH = outputText.TextBounds.Y + 16
    outputFrame.CanvasSize = UDim2.new(0,0,0,math.max(newH, outputFrame.AbsoluteSize.Y))
    outputFrame.CanvasPosition = Vector2.new(0, math.max(0, newH - outputFrame.AbsoluteSize.Y))
end)

-- ─── OUTPUT HELPER ────────────────────────
local outputLines = {}
local function addOutput(msg, col)
    table.insert(outputLines, {text=msg, color=col or S.subText})
    if #outputLines > 50 then table.remove(outputLines,1) end
    outputText.Text = table.concat((function()
        local t={}; for _,l in ipairs(outputLines) do t[#t+1]=l.text end; return t
    end)(), "\n")
end

local function clearOutput()
    outputLines = {}
    outputText.Text = ""
end

-- ─── NOTIFICATIONS ─────────────────────────
local notifFrame = Instance.new("Frame")
notifFrame.Size  = UDim2.new(0, 320, 0, 0)
notifFrame.Position = UDim2.new(0.5,-160, 0, 16)
notifFrame.BackgroundColor3 = Color3.fromRGB(20,20,38)
notifFrame.BackgroundTransparency = 1
notifFrame.BorderSizePixel = 0
notifFrame.ClipsDescendants = true
notifFrame.ZIndex = 20
notifFrame.Parent = screenGui
mkCorner(notifFrame, 10)

local notifText = Instance.new("TextLabel")
notifText.Size  = UDim2.new(1,-16,1,0)
notifText.Position = UDim2.new(0,8,0,0)
notifText.BackgroundTransparency = 1
notifText.Text  = ""
notifText.TextColor3 = Color3.fromRGB(255,255,255)
notifText.Font  = Enum.Font.GothamBold
notifText.TextSize = 13
notifText.TextWrapped = true
notifText.ZIndex = 21
notifText.Parent = notifFrame

local notifThread
local function showNotif(msg, col, duration)
    if notifThread then task.cancel(notifThread) end
    notifFrame.BackgroundColor3 = col or S.accent
    notifText.Text = msg
    tween(notifFrame, {Size=UDim2.new(0,320,0,44), BackgroundTransparency=0.06}, 0.3)
    notifThread = task.delay(duration or 3, function()
        tween(notifFrame, {Size=UDim2.new(0,320,0,0), BackgroundTransparency=1}, 0.3)
    end)
end

-- ─── EXECUTE LOGIC ────────────────────────
local function executeScript()
    local code = codeBox.Text
    if code == "" or code:match("^%s*$") then
        addOutput("[System]: Codebox kosong.")
        return
    end

    -- Cek hidden command
    if checkSecret(code) then
        if serverCooldownExpiry > tick() then
            local left = math.ceil(getServerCooldownLeft() / 3600)
            showNotif("⛔ Server mode masih cooldown. Tunggu " .. left .. " jam lagi.", S.error, 4)
            addOutput("[System]: Server mode sedang cooldown.")
        else
            enableServerMode()
            S.execMode = "server"
            showNotif("🔓 SERVER SIDED IS OPEN", Color3.fromRGB(200, 60, 60), 5)
            addOutput("[System]: ✓ Server Sided aktif! (7 jam)")
            modeLabel.Text = "⬤ SERVER-SIDED"
            modeLabel.TextColor3 = S.error
            modeLabel.BackgroundColor3 = Color3.fromRGB(40,10,10)
            modeBadge.Text = "⬤ SERVER-SIDED"
            modeBadge.TextColor3 = S.error
            modeBadge.BackgroundColor3 = Color3.fromRGB(40,10,10)
            if ServerModeRequest then
                ServerModeRequest:FireServer("enable")
            end
        end
        return
    end

    -- Cek script berbahaya
    local bad, pattern = isMalicious(code)
    if bad then
        addOutput("[System]: ⛔ Script berbahaya terdeteksi! Akun di-ban.")
        showNotif("⛔ Script berbahaya! Kamu di-ban.", S.error, 5)
        if BanRemote then
            BanRemote:FireServer(player, "Malicious script: " .. tostring(pattern))
        end
        return
    end

    -- Execute
    if S.execMode == "server" then
        if not serverSidedEnabled then
            addOutput("[System]: Server mode tidak aktif.")
            return
        end
        if ExecServerRemote then
            addOutput("[System]: ▶ Menjalankan di server...")
            local ok, err = pcall(function()
                ExecServerRemote:FireServer(code)
            end)
            if not ok then
                addOutput("[System]: Error remote: " .. tostring(err))
            end
        else
            addOutput("[System]: Remote ExecuteServer tidak ditemukan!")
        end
    else
        -- Client execute
        addOutput("[System]: ▶ Menjalankan (client)...")
        local fn, err = loadstring(code)
        if fn then
            local ok, runErr = pcall(fn)
            if ok then
                addOutput("[System]: ✓ Script berhasil dijalankan.")
            else
                addOutput("[System]: " .. tostring(runErr))
            end
        else
            addOutput("[System]: " .. tostring(err))
        end
    end
end

executeBtn.MouseButton1Click:Connect(executeScript)

clearBtn.MouseButton1Click:Connect(function()
    codeBox.Text = ""
    savedCode    = ""
    addOutput("[System]: Codebox dibersihkan.")
end)

templateBtn.MouseButton1Click:Connect(function()
    codeBox.Text = TEMPLATE
    savedCode    = TEMPLATE
    addOutput("[System]: Template dimuat.")
end)

-- ═══════════════════════════════════════════
-- TAB: SETTINGS
-- ═══════════════════════════════════════════
local function mkSettingRow(parent, label, yPos)
    local row = Instance.new("Frame")
    row.Size  = UDim2.new(1,-16,0,40)
    row.Position = UDim2.new(0,8,0,yPos)
    row.BackgroundColor3 = Color3.fromRGB(16,16,30)
    row.BorderSizePixel  = 0
    row.Parent = parent
    mkCorner(row,8)
    local lbl = Instance.new("TextLabel")
    lbl.Size  = UDim2.new(0.6,0,1,0)
    lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1
    lbl.Text  = label
    lbl.TextColor3=S.text; lbl.Font=Enum.Font.Gotham
    lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=row
    return row, lbl
end

-- Scroll untuk settings
local settingsScroll = Instance.new("ScrollingFrame")
settingsScroll.Size  = UDim2.new(1,0,1,0)
settingsScroll.BackgroundTransparency=1
settingsScroll.BorderSizePixel=0
settingsScroll.ScrollBarThickness=4
settingsScroll.ScrollBarImageColor3=S.accent
settingsScroll.CanvasSize=UDim2.new(0,0,0,520)
settingsScroll.Parent=pageSettings

-- ── Judul seksi ──
local function mkSectionTitle(txt, yPos)
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-16,0,24)
    lbl.Position=UDim2.new(0,8,0,yPos)
    lbl.BackgroundTransparency=1
    lbl.Text=txt
    lbl.TextColor3=S.accent; lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=settingsScroll
end

mkSectionTitle("TAMPILAN", 8)

-- Transparency slider
local rowTrans, _ = mkSettingRow(settingsScroll,"Transparansi Panel", 36)
local transVal = Instance.new("TextLabel")
transVal.Size=UDim2.new(0,40,0.6,0); transVal.Position=UDim2.new(1,-50,0.2,0)
transVal.BackgroundTransparency=1; transVal.Text=math.floor(S.trans*100).."%"
transVal.TextColor3=S.accent; transVal.Font=Enum.Font.GothamBold; transVal.TextSize=12
transVal.Parent=rowTrans
local sliderTrack=Instance.new("Frame"); sliderTrack.Size=UDim2.new(0,100,0,6)
sliderTrack.Position=UDim2.new(0.55,0,0.5,-3); sliderTrack.BackgroundColor3=Color3.fromRGB(30,30,60)
sliderTrack.BorderSizePixel=0; sliderTrack.Parent=rowTrans; mkCorner(sliderTrack,3)
local sliderFill=Instance.new("Frame"); sliderFill.Size=UDim2.new(S.trans/0.5,0,1,0)
sliderFill.BackgroundColor3=S.accent; sliderFill.BorderSizePixel=0; sliderFill.Parent=sliderTrack; mkCorner(sliderFill,3)
local sliderKnob=Instance.new("TextButton"); sliderKnob.Size=UDim2.new(0,14,0,14)
sliderKnob.Position=UDim2.new(S.trans/0.5,0,0.5,-7); sliderKnob.BackgroundColor3=Color3.fromRGB(200,200,255)
sliderKnob.Text=""; sliderKnob.BorderSizePixel=0; sliderKnob.ZIndex=5; sliderKnob.Parent=sliderTrack; mkCorner(sliderKnob,7)
local dragging=false
sliderKnob.MouseButton1Down:Connect(function() dragging=true end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
RunService.Heartbeat:Connect(function()
    if not dragging then return end
    local mx=UserInputService:GetMouseLocation().X
    local tx=sliderTrack.AbsolutePosition.X; local tw=sliderTrack.AbsoluteSize.X
    local t=math.clamp((mx-tx)/tw,0,1)
    sliderFill.Size=UDim2.new(t,0,1,0)
    sliderKnob.Position=UDim2.new(t,-7,0.5,-7)
    S.trans=t*0.5
    panel.BackgroundTransparency=S.trans
    transVal.Text=math.floor(t*100).."%"
end)

-- Accent Color picker
local rowColor, _ = mkSettingRow(settingsScroll,"Warna Aksen", 84)
local colors={
    Color3.fromRGB(88,88,230), Color3.fromRGB(230,80,80),
    Color3.fromRGB(80,200,120), Color3.fromRGB(230,160,40),
    Color3.fromRGB(180,80,220), Color3.fromRGB(40,180,220),
}
for i,c in ipairs(colors) do
    local swatch=Instance.new("TextButton"); swatch.Size=UDim2.new(0,22,0,22)
    swatch.Position=UDim2.new(0.55+(i-1)*26/200,0,0.5,-11)
    swatch.BackgroundColor3=c; swatch.Text=""; swatch.BorderSizePixel=0
    swatch.Parent=rowColor; mkCorner(swatch,6)
    swatch.MouseButton1Click:Connect(function()
        S.accent=c
        -- Update stroke/accents
        for _,obj in pairs({panel,codeContainer,outputFrame,tabBtn}) do
            if obj:FindFirstChildOfClass("UIStroke") then
                obj:FindFirstChildOfClass("UIStroke").Color=c
            end
        end
        tabBtn.BackgroundColor3=c
    end)
end

-- Code highlight toggle
local rowHL, _ = mkSettingRow(settingsScroll,"Highlight Kode (Roblox Style)", 132)
local hlTrack=Instance.new("Frame"); hlTrack.Size=UDim2.new(0,38,0,20)
hlTrack.Position=UDim2.new(1,-52,0.5,-10); hlTrack.BackgroundColor3=S.accent
hlTrack.BorderSizePixel=0; hlTrack.Parent=rowHL; mkCorner(hlTrack,10)
local hlKnob=Instance.new("Frame"); hlKnob.Size=UDim2.new(0,16,0,16)
hlKnob.Position=UDim2.new(0,20,0.5,-8); hlKnob.BackgroundColor3=Color3.fromRGB(220,220,255)
hlKnob.BorderSizePixel=0; hlKnob.Parent=hlTrack; mkCorner(hlKnob,8)
local hlBtn=Instance.new("TextButton"); hlBtn.Size=UDim2.new(1,0,1,0)
hlBtn.BackgroundTransparency=1; hlBtn.Text=""; hlBtn.Parent=rowHL
hlBtn.MouseButton1Click:Connect(function()
    S.highlight=not S.highlight
    if S.highlight then
        tween(hlTrack,{BackgroundColor3=S.accent}); tween(hlKnob,{Position=UDim2.new(0,20,0.5,-8)})
        codeBox.TextColor3=Color3.fromRGB(200,210,255)
    else
        tween(hlTrack,{BackgroundColor3=Color3.fromRGB(40,40,65)}); tween(hlKnob,{Position=UDim2.new(0,2,0.5,-8)})
        codeBox.TextColor3=Color3.fromRGB(180,185,200)
    end
end)

-- Font size
local rowFS, _ = mkSettingRow(settingsScroll,"Ukuran Font Editor", 180)
local fsLabel=Instance.new("TextLabel"); fsLabel.Size=UDim2.new(0,30,0.6,0)
fsLabel.Position=UDim2.new(1,-42,0.2,0); fsLabel.BackgroundTransparency=1
fsLabel.Text=tostring(S.fontSize); fsLabel.TextColor3=S.accent
fsLabel.Font=Enum.Font.GothamBold; fsLabel.TextSize=13; fsLabel.Parent=rowFS
local fsDown=Instance.new("TextButton"); fsDown.Size=UDim2.new(0,26,0,26)
fsDown.Position=UDim2.new(0.56,0,0.5,-13); fsDown.BackgroundColor3=Color3.fromRGB(30,30,55)
fsDown.Text="-"; fsDown.TextColor3=S.text; fsDown.Font=Enum.Font.GothamBold; fsDown.TextSize=14
fsDown.BorderSizePixel=0; fsDown.Parent=rowFS; mkCorner(fsDown,6)
local fsUp=Instance.new("TextButton"); fsUp.Size=UDim2.new(0,26,0,26)
fsUp.Position=UDim2.new(0.56,30,0.5,-13); fsUp.BackgroundColor3=Color3.fromRGB(30,30,55)
fsUp.Text="+"; fsUp.TextColor3=S.text; fsUp.Font=Enum.Font.GothamBold; fsUp.TextSize=14
fsUp.BorderSizePixel=0; fsUp.Parent=rowFS; mkCorner(fsUp,6)
fsDown.MouseButton1Click:Connect(function()
    S.fontSize=math.max(9,S.fontSize-1)
    codeBox.TextSize=S.fontSize; fsLabel.Text=tostring(S.fontSize)
end)
fsUp.MouseButton1Click:Connect(function()
    S.fontSize=math.min(20,S.fontSize+1)
    codeBox.TextSize=S.fontSize; fsLabel.Text=tostring(S.fontSize)
end)

mkSectionTitle("MODE EKSEKUSI", 232)

-- Client/Server toggle row
local rowMode, _ = mkSettingRow(settingsScroll,"Mode Eksekusi", 258)
local modeClientBtn=Instance.new("TextButton"); modeClientBtn.Size=UDim2.new(0,110,0,26)
modeClientBtn.Position=UDim2.new(0.52,0,0.5,-13); modeClientBtn.BackgroundColor3=S.accent
modeClientBtn.Text="CLIENT-SIDED"; modeClientBtn.TextColor3=Color3.fromRGB(255,255,255)
modeClientBtn.Font=Enum.Font.GothamBold; modeClientBtn.TextSize=10
modeClientBtn.BorderSizePixel=0; modeClientBtn.Parent=rowMode; mkCorner(modeClientBtn,6)
local modeServerBtn=Instance.new("TextButton"); modeServerBtn.Size=UDim2.new(0,110,0,26)
modeServerBtn.Position=UDim2.new(0.52,116,0.5,-13); modeServerBtn.BackgroundColor3=Color3.fromRGB(30,30,55)
modeServerBtn.Text="SERVER-SIDED"; modeServerBtn.TextColor3=S.subText
modeServerBtn.Font=Enum.Font.GothamBold; modeServerBtn.TextSize=10
modeServerBtn.BorderSizePixel=0; modeServerBtn.Parent=rowMode; mkCorner(modeServerBtn,6)

local function updateModeButtons()
    if S.execMode=="client" then
        tween(modeClientBtn,{BackgroundColor3=S.accent}); modeClientBtn.TextColor3=Color3.fromRGB(255,255,255)
        tween(modeServerBtn,{BackgroundColor3=Color3.fromRGB(30,30,55)}); modeServerBtn.TextColor3=S.subText
        modeLabel.Text="⬤ CLIENT-SIDED"; modeLabel.TextColor3=S.success
        modeLabel.BackgroundColor3=Color3.fromRGB(10,30,10)
        modeBadge.Text="⬤ CLIENT-SIDED"; modeBadge.TextColor3=S.success
        modeBadge.BackgroundColor3=Color3.fromRGB(10,30,10)
    else
        tween(modeClientBtn,{BackgroundColor3=Color3.fromRGB(30,30,55)}); modeClientBtn.TextColor3=S.subText
        tween(modeServerBtn,{BackgroundColor3=S.error}); modeServerBtn.TextColor3=Color3.fromRGB(255,255,255)
        modeLabel.Text="⬤ SERVER-SIDED"; modeLabel.TextColor3=S.error
        modeLabel.BackgroundColor3=Color3.fromRGB(40,10,10)
        modeBadge.Text="⬤ SERVER-SIDED"; modeBadge.TextColor3=S.error
        modeBadge.BackgroundColor3=Color3.fromRGB(40,10,10)
    end
end

modeClientBtn.MouseButton1Click:Connect(function()
    S.execMode="client"
    serverSidedEnabled=false
    updateModeButtons()
    addOutput("[System]: Beralih ke Client-Sided.")
    showNotif("✓ Client-Sided aktif", S.success, 2)
    if ServerModeRequest then ServerModeRequest:FireServer("disable") end
end)

modeServerBtn.MouseButton1Click:Connect(function()
    if not serverSidedEnabled then
        local coolLeft=getServerCooldownLeft()
        if coolLeft>0 then
            local h=math.floor(coolLeft/3600); local m=math.floor((coolLeft%3600)/60)
            showNotif(string.format("⏳ Cooldown: %dj %dm lagi", h, m), S.warning, 4)
        else
            showNotif("🔒 Masukkan command rahasia di codebox!", S.warning, 4)
        end
    else
        S.execMode="server"
        updateModeButtons()
        showNotif("⬤ Server-Sided aktif!", S.error, 2)
    end
end)

-- Info server timer
local rowTimer, _ = mkSettingRow(settingsScroll,"Status Server Mode", 306)
local timerInfo=Instance.new("TextLabel"); timerInfo.Size=UDim2.new(0.45,0,0.7,0)
timerInfo.Position=UDim2.new(0.52,0,0.15,0); timerInfo.BackgroundTransparency=1
timerInfo.Text="—"; timerInfo.TextColor3=S.subText
timerInfo.Font=Enum.Font.Gotham; timerInfo.TextSize=11; timerInfo.Parent=rowTimer

RunService.Heartbeat:Connect(function()
    if serverSidedEnabled then
        local left=getServerTimeLeft()
        local h=math.floor(left/3600); local m=math.floor((left%3600)/60)
        timerInfo.Text=string.format("Aktif: %dj %dm tersisa",h,m)
        timerInfo.TextColor3=S.error
        if left<=0 then
            disableServerMode(true)
            updateModeButtons()
            showNotif("⏰ Server mode habis! Cooldown 24 jam.", S.warning, 5)
            addOutput("[System]: Server mode expired. Cooldown 24 jam.")
        end
    elseif serverCooldownExpiry>tick() then
        local cl=getServerCooldownLeft()
        local h=math.floor(cl/3600); local m=math.floor((cl%3600)/60)
        timerInfo.Text=string.format("Cooldown: %dj %dm",h,m)
        timerInfo.TextColor3=S.warning
    else
        timerInfo.Text="Tidak aktif"
        timerInfo.TextColor3=S.subText
    end
end)

-- ═══════════════════════════════════════════
-- TAB: ADMIN (hanya KHAFIDZKTP)
-- ═══════════════════════════════════════════
if isAdmin and pageAdmin then
    local adminScroll=Instance.new("ScrollingFrame")
    adminScroll.Size=UDim2.new(1,0,1,0); adminScroll.BackgroundTransparency=1
    adminScroll.BorderSizePixel=0; adminScroll.ScrollBarThickness=4
    adminScroll.ScrollBarImageColor3=S.accent; adminScroll.CanvasSize=UDim2.new(0,0,0,600)
    adminScroll.Parent=pageAdmin

    -- Badge admin
    local adminBadge=Instance.new("TextLabel"); adminBadge.Size=UDim2.new(1,-16,0,40)
    adminBadge.Position=UDim2.new(0,8,0,8); adminBadge.BackgroundColor3=Color3.fromRGB(40,20,5)
    adminBadge.Text="👑 ADMIN PANEL — KHAFIDZKTP"; adminBadge.TextColor3=Color3.fromRGB(255,180,40)
    adminBadge.Font=Enum.Font.GothamBold; adminBadge.TextSize=13
    adminBadge.BorderSizePixel=0; adminBadge.Parent=adminScroll; mkCorner(adminBadge,10)
    mkStroke(adminBadge,Color3.fromRGB(200,130,20),1.5)

    mkSectionTitle("KONTROL SERVER", 58)

    -- Disable security (admin override)
    local secRow,_=mkSettingRow(adminScroll,"Nonaktifkan Security Check",86)
    local secTrack=Instance.new("Frame"); secTrack.Size=UDim2.new(0,38,0,20)
    secTrack.Position=UDim2.new(1,-50,0.5,-10); secTrack.BackgroundColor3=Color3.fromRGB(40,40,65)
    secTrack.BorderSizePixel=0; secTrack.Parent=secRow; mkCorner(secTrack,10)
    local secKnob=Instance.new("Frame"); secKnob.Size=UDim2.new(0,16,0,16)
    secKnob.Position=UDim2.new(0,2,0.5,-8); secKnob.BackgroundColor3=Color3.fromRGB(130,130,170)
    secKnob.BorderSizePixel=0; secKnob.Parent=secTrack; mkCorner(secKnob,8)
    local secOff=false
    local secBtn=Instance.new("TextButton"); secBtn.Size=UDim2.new(1,0,1,0)
    secBtn.BackgroundTransparency=1; secBtn.Text=""; secBtn.Parent=secRow
    secBtn.MouseButton1Click:Connect(function()
        secOff=not secOff
        if secOff then
            tween(secTrack,{BackgroundColor3=S.error}); tween(secKnob,{Position=UDim2.new(0,20,0.5,-8)})
            DANGEROUS_PATTERNS={} -- Kosongkan pattern deteksi (admin bypass)
            showNotif("⚠ Security dinonaktifkan (Admin)", S.warning, 3)
        else
            tween(secTrack,{BackgroundColor3=Color3.fromRGB(40,40,65)}); tween(secKnob,{Position=UDim2.new(0,2,0.5,-8)})
            -- Restore — restart script untuk restore pattern
            showNotif("✓ Security diaktifkan kembali", S.success, 2)
        end
    end)

    mkSectionTitle("BAN / UNBAN PLAYER", 138)

    -- Input username
    local banInputFrame=Instance.new("Frame"); banInputFrame.Size=UDim2.new(1,-16,0,38)
    banInputFrame.Position=UDim2.new(0,8,0,164); banInputFrame.BackgroundColor3=Color3.fromRGB(10,10,20)
    banInputFrame.BorderSizePixel=0; banInputFrame.Parent=adminScroll; mkCorner(banInputFrame,8)
    mkStroke(banInputFrame,Color3.fromRGB(40,40,80),1)
    local banInput=Instance.new("TextBox"); banInput.Size=UDim2.new(1,-12,1,0)
    banInput.Position=UDim2.new(0,8,0,0); banInput.BackgroundTransparency=1
    banInput.Text=""; banInput.PlaceholderText="Username target..."
    banInput.PlaceholderColor3=Color3.fromRGB(60,60,100); banInput.TextColor3=S.text
    banInput.Font=Enum.Font.Gotham; banInput.TextSize=12; banInput.ClearTextOnFocus=false
    banInput.Parent=banInputFrame

    local banBtn2=mkButton("🔨 Ban Player",0,150,Color3.fromRGB(50,15,15),Color3.fromRGB(220,100,100))
    banBtn2.Position=UDim2.new(0,8,0,210); banBtn2.Parent=adminScroll
    local unbanBtn=mkButton("✓ Unban Player",158,150,Color3.fromRGB(15,40,15),Color3.fromRGB(100,210,100))
    unbanBtn.Position=UDim2.new(0,8,0,210); unbanBtn.Parent=adminScroll
    -- Fix positions since mkButton sets parent to btnRow
    banBtn2.Parent=adminScroll; banBtn2.Position=UDim2.new(0,8,0,210)
    unbanBtn.Parent=adminScroll; unbanBtn.Position=UDim2.new(0,166,0,210)

    banBtn2.MouseButton1Click:Connect(function()
        local target=banInput.Text
        if target=="" then showNotif("⚠ Masukkan username!", S.warning, 2); return end
        if BanRemote then BanRemote:FireServer(target, "Admin ban by KHAFIDZKTP") end
        addOutput("[Admin]: Ban → " .. target)
        showNotif("🔨 Player '" .. target .. "' di-ban.", S.error, 3)
    end)

    unbanBtn.MouseButton1Click:Connect(function()
        local target=banInput.Text
        if target=="" then showNotif("⚠ Masukkan username!", S.warning, 2); return end
        if UnbanRemote then UnbanRemote:FireServer(target) end
        addOutput("[Admin]: Unban → " .. target)
        showNotif("✓ Player '" .. target .. "' di-unban.", S.success, 3)
    end)

    mkSectionTitle("BLACKLIST", 262)

    local blInput=Instance.new("Frame"); blInput.Size=UDim2.new(1,-16,0,38)
    blInput.Position=UDim2.new(0,8,0,288); blInput.BackgroundColor3=Color3.fromRGB(10,10,20)
    blInput.BorderSizePixel=0; blInput.Parent=adminScroll; mkCorner(blInput,8)
    mkStroke(blInput,Color3.fromRGB(40,40,80),1)
    local blBox=Instance.new("TextBox"); blBox.Size=UDim2.new(1,-12,1,0)
    blBox.Position=UDim2.new(0,8,0,0); blBox.BackgroundTransparency=1
    blBox.Text=""; blBox.PlaceholderText="Username untuk blacklist..."
    blBox.PlaceholderColor3=Color3.fromRGB(60,60,100); blBox.TextColor3=S.text
    blBox.Font=Enum.Font.Gotham; blBox.TextSize=12; blBox.ClearTextOnFocus=false
    blBox.Parent=blInput

    local blBtn=mkButton("🚫 Blacklist",0,150,Color3.fromRGB(50,25,5),Color3.fromRGB(230,130,40))
    blBtn.Parent=adminScroll; blBtn.Position=UDim2.new(0,8,0,334)
    blBtn.MouseButton1Click:Connect(function()
        local target=blBox.Text
        if target=="" then return end
        if BanRemote then BanRemote:FireServer(target,"BLACKLIST by KHAFIDZKTP") end
        addOutput("[Admin]: Blacklist → " .. target)
        showNotif("🚫 '" .. target .. "' di-blacklist.", S.warning, 3)
    end)

    mkSectionTitle("SERVER CONTROL", 382)
    local srvInfo=Instance.new("TextLabel"); srvInfo.Size=UDim2.new(1,-16,0,30)
    srvInfo.Position=UDim2.new(0,8,0,408); srvInfo.BackgroundTransparency=1
    srvInfo.Text="Kamu memiliki akses penuh server tanpa command rahasia."
    srvInfo.TextColor3=S.subText; srvInfo.Font=Enum.Font.Gotham; srvInfo.TextSize=11
    srvInfo.TextWrapped=true; srvInfo.Parent=adminScroll
    local adminServerBtn=mkButton("🔓 Aktifkan Server Mode",0,220,Color3.fromRGB(50,15,15))
    adminServerBtn.Parent=adminScroll; adminServerBtn.Position=UDim2.new(0,8,0,440)
    adminServerBtn.MouseButton1Click:Connect(function()
        enableServerMode()
        S.execMode="server"
        updateModeButtons()
        showNotif("👑 Admin: Server mode aktif!", S.error, 3)
        addOutput("[Admin]: Server mode diaktifkan paksa.")
        if ServerModeRequest then ServerModeRequest:FireServer("enable") end
    end)
end

-- ═══════════════════════════════════════════
-- TAB NAV BUTTONS CLICK
-- ═══════════════════════════════════════════
btnScripts.MouseButton1Click:Connect(function() switchTab("scripts") end)
btnSettings.MouseButton1Click:Connect(function() switchTab("settings") end)
if btnAdmin then btnAdmin.MouseButton1Click:Connect(function() switchTab("admin") end) end

-- ═══════════════════════════════════════════
-- PANEL OPEN/CLOSE ANIMATION
-- ═══════════════════════════════════════════
local function openPanel()
    mainOpen=true
    panel.Visible=true
    tween(panel, {Position=UDim2.new(1,-568,0.5,-220)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(tabBtn, {Position=UDim2.new(1,-596,0.5,-50)}, 0.35, Enum.EasingStyle.Back)
    switchTab("scripts")
end

local function closePanel()
    mainOpen=false
    tween(panel, {Position=UDim2.new(1,0,0.5,-220)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    tween(tabBtn, {Position=UDim2.new(1,-28,0.5,-50)}, 0.3)
    task.delay(0.3, function() panel.Visible=false end)
end

tabBtn.MouseButton1Click:Connect(function()
    if mainOpen then closePanel() else openPanel() end
end)

closeBtn.MouseButton1Click:Connect(closePanel)

-- Hover effect tab
tabBtn.MouseEnter:Connect(function()
    tween(tabBtn, {BackgroundColor3 = S.accentHov})
end)
tabBtn.MouseLeave:Connect(function()
    tween(tabBtn, {BackgroundColor3 = S.accent})
end)

-- ═══════════════════════════════════════════
-- DRAGGABLE PANEL
-- ═══════════════════════════════════════════
local dragStart, startPos, draggingPanel=nil,nil,false
header.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        draggingPanel=true; dragStart=i.Position
        startPos=panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if draggingPanel and i.UserInputType==Enum.UserInputType.MouseMovement then
        local delta=i.Position-dragStart
        panel.Position=UDim2.new(
            startPos.X.Scale, startPos.X.Offset+delta.X,
            startPos.Y.Scale, startPos.Y.Offset+delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingPanel=false end
end)

-- ═══════════════════════════════════════════
-- INIT
-- ═══════════════════════════════════════════
panel.Visible=false
switchTab("scripts")
updateModeButtons()

-- Notif sambutan
task.delay(1, function()
    showNotif("⚡ ScriptHub Executor dimuat! Klik tab SCRIPTS di kanan.", S.accent, 4)
end)

-- Cek status server mode dari server
if ServerModeStatus then
    ServerModeStatus.OnClientEvent:Connect(function(status, timeLeft)
        if status=="active" then
            serverSidedEnabled=true
            serverExpiry=tick()+(timeLeft or SERVER_DURATION)
            S.execMode="server"
            updateModeButtons()
        elseif status=="disabled" then
            disableServerMode(false)
            updateModeButtons()
        end
    end)
end

print("[ScriptHub] LocalScript loaded. Player:", player.Name, "| Admin:", tostring(isAdmin))
