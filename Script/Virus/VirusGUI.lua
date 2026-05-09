-- ██╗   ██╗██╗██████╗ ██╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗
-- ██║   ██║██║██╔══██╗██║   ██║██╔════╝██╔════╝ ██║   ██║██║
-- ██║   ██║██║██████╔╝██║   ██║███████╗██║  ███╗██║   ██║██║
-- ╚██╗ ██╔╝██║██╔══██╗██║   ██║╚════██║██║   ██║██║   ██║██║
--  ╚████╔╝ ██║██║  ██║╚██████╔╝███████║╚██████╔╝╚██████╔╝██║
--   ╚═══╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝
-- VirusGUI Prank Script — for fun only 🎉

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local CoreGui        = game:GetService("CoreGui")
local RunService     = game:GetService("RunService")
local UIS            = game:GetService("UserInputService")
local StarterGui     = game:GetService("StarterGui")
local LocalPlayer    = Players.LocalPlayer

-- Cleanup old instance
pcall(function() CoreGui:FindFirstChild("VirusGUI"):Destroy() end)

-- ============================================================
-- APP NAME POOL  (Mom.Love = lebih jarang)
-- ============================================================
local appPool = {}
local regular = {
    {name="Supersus.exe",  theme="sus"},
    {name="Roblox.exe",    theme="roblox"},
    {name="FreeRobux.exe", theme="robux"},
    {name="SusHub.exe",    theme="sus"},
    {name="Hub.exe",       theme="hub"},
    {name="Discord.exe",   theme="discord"},
    {name="Delta.exe",     theme="delta"},
    {name="Xeno.exe",      theme="xeno"},
}
for _, v in ipairs(regular) do
    for _ = 1, 10 do table.insert(appPool, v) end  -- bobot 10
end
for _ = 1, 2 do  -- bobot 2 → lebih jarang
    table.insert(appPool, {name="Mom.Love", theme="mom"})
end

math.randomseed(tick())
local selected = appPool[math.random(1, #appPool)]
local appName  = selected.name
local appTheme = selected.theme

-- ============================================================
-- THEMES
-- ============================================================
local T = {
    sus     = {bg=Color3.fromRGB(18,18,28),    bar=Color3.fromRGB(180,20,20),   text=Color3.fromRGB(255,110,110), accent=Color3.fromRGB(220,50,50),   icon="☠️ "},
    roblox  = {bg=Color3.fromRGB(24,24,24),    bar=Color3.fromRGB(226,35,26),   text=Color3.fromRGB(255,255,255), accent=Color3.fromRGB(226,35,26),   icon="🅡 "},
    robux   = {bg=Color3.fromRGB(10,22,10),    bar=Color3.fromRGB(0,130,0),     text=Color3.fromRGB(100,255,100), accent=Color3.fromRGB(255,215,0),   icon="💰 "},
    hub     = {bg=Color3.fromRGB(18,18,35),    bar=Color3.fromRGB(40,40,110),   text=Color3.fromRGB(190,190,255), accent=Color3.fromRGB(80,100,255),  icon="🔧 "},
    discord = {bg=Color3.fromRGB(49,51,56),    bar=Color3.fromRGB(88,101,242),  text=Color3.fromRGB(220,221,222), accent=Color3.fromRGB(88,101,242),  icon="🎮 "},
    delta   = {bg=Color3.fromRGB(12,18,28),    bar=Color3.fromRGB(0,110,180),   text=Color3.fromRGB(160,220,255), accent=Color3.fromRGB(0,170,255),   icon="⚡ "},
    xeno    = {bg=Color3.fromRGB(14,14,14),    bar=Color3.fromRGB(255,140,0),   text=Color3.fromRGB(255,255,255), accent=Color3.fromRGB(255,140,0),   icon="🔥 "},
    mom     = {bg=Color3.fromRGB(255,235,240),  bar=Color3.fromRGB(255,100,150), text=Color3.fromRGB(120,0,60),   accent=Color3.fromRGB(255,150,180), icon="💖 "},
}
local theme = T[appTheme]

local infoTexts = {
    sus     = "> Scanning for impostors...\n> Red is sus.\n> Emergency meeting in 3...\n> WARNING: Crewmate detected.",
    roblox  = "> Roblox Corporation\n> Version 666.0.0\n> Loading assets...\n> ERROR: Player.exe corrupted",
    robux   = "> 🤑 FREE ROBUX GENERATOR 🤑\n> Generating 99999 Robux...\n> Step 1/1: Click RUN\n> ⚠️  Totally legit. Trust me.",
    hub     = "> ScriptHub Pro v9.9\n> Loading modules...\n> Bypassing anti-cheat...\n> Status: Undetected ✅",
    discord = "> Discord v9999.0\n> Connecting to gateway...\n> 47 friend requests pending\n> New message from: Mom 💬",
    delta   = "> Delta Executor v6.9\n> Injecting into Roblox...\n> Bypass: Active ⚡\n> Ready to execute.",
    xeno    = "> Xeno Executor\n> Skull mode: Enabled 💀\n> Bypassing Byfron...\n> system32: Deleted ✅",
    mom     = "> mom.love Installer\n> Loading memories...\n> WARNING: She's watching.\n> 💖 She always loved you.",
}

-- ============================================================
-- BUILD GUI
-- ============================================================
local NW, NH = 420, 310
local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "VirusGUI"
screenGui.IgnoreGuiInset  = true
screenGui.ResetOnSpawn    = false
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder    = 999
screenGui.Parent          = CoreGui

-- Window frame
local isMin, isMax = false, false
local savedSize    = UDim2.new(0, NW, 0, NH)
local savedPos     = UDim2.new(0.5, -NW/2, 0.5, -NH/2)

local window = Instance.new("Frame")
window.Name                 = "Window"
window.Size                 = UDim2.new(0, 0, 0, 0)         -- starts hidden (entry anim)
window.Position             = UDim2.new(0.5, 0, 0.5, 0)
window.BackgroundColor3     = theme.bg
window.BackgroundTransparency = 1
window.BorderSizePixel      = 0
window.ZIndex               = 100
window.Parent               = screenGui
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 9)

-- Fake drop shadow
local shadow = Instance.new("ImageLabel")
shadow.Size               = UDim2.new(1, 40, 1, 40)
shadow.Position           = UDim2.new(0, -20, 0, -15)
shadow.BackgroundTransparency = 1
shadow.Image              = "rbxassetid://6014261993"
shadow.ImageColor3        = Color3.fromRGB(0,0,0)
shadow.ImageTransparency  = 0.55
shadow.ScaleType          = Enum.ScaleType.Slice
shadow.SliceCenter        = Rect.new(49,49,450,450)
shadow.ZIndex             = 99
shadow.Parent             = window

-- ---- Title bar ----
local titleBar = Instance.new("Frame")
titleBar.Name            = "TitleBar"
titleBar.Size            = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = theme.bar
titleBar.BorderSizePixel = 0
titleBar.ZIndex          = 101
titleBar.Parent          = window
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 9)
-- Fill bottom corners of titlebar
local tbFix = Instance.new("Frame")
tbFix.Size            = UDim2.new(1, 0, 0.5, 0)
tbFix.Position        = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3 = theme.bar
tbFix.BorderSizePixel = 0
tbFix.ZIndex          = 101
tbFix.Parent          = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size             = UDim2.new(1, -110, 1, 0)
titleLabel.Position         = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text             = theme.icon .. appName
titleLabel.TextColor3       = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize         = 14
titleLabel.Font             = Enum.Font.GothamBold
titleLabel.TextXAlignment   = Enum.TextXAlignment.Left
titleLabel.ZIndex           = 102
titleLabel.Parent           = titleBar

-- Window control buttons (macOS-style circles)
local function makeWinBtn(sym, col, xOff)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, 20, 0, 20)
    b.Position         = UDim2.new(1, xOff, 0.5, -10)
    b.BackgroundColor3 = col
    b.Text             = sym
    b.TextColor3       = Color3.fromRGB(0,0,0)
    b.TextSize         = 11
    b.Font             = Enum.Font.GothamBold
    b.BorderSizePixel  = 0
    b.ZIndex           = 103
    b.Parent           = titleBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    -- hover dim
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency=0.35}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency=0}):Play()
    end)
    return b
end
local btnClose = makeWinBtn("✕", Color3.fromRGB(255,80,80),  -30)
local btnMax   = makeWinBtn("◻", Color3.fromRGB(255,195,0),  -56)
local btnMin   = makeWinBtn("—", Color3.fromRGB(80,210,80),  -82)

-- ---- Content area ----
local content = Instance.new("Frame")
content.Name                 = "Content"
content.Size                 = UDim2.new(1, 0, 1, -36)
content.Position             = UDim2.new(0, 0, 0, 36)
content.BackgroundTransparency = 1
content.ClipsDescendants     = true
content.ZIndex               = 101
content.Parent               = window

-- Download label
local dlLabel = Instance.new("TextLabel")
dlLabel.Size            = UDim2.new(0.9, 0, 0, 20)
dlLabel.Position        = UDim2.new(0.05, 0, 0, 14)
dlLabel.BackgroundTransparency = 1
dlLabel.Text            = "Downloading  " .. appName .. "..."
dlLabel.TextColor3      = theme.text
dlLabel.TextSize        = 13
dlLabel.Font            = Enum.Font.Gotham
dlLabel.TextXAlignment  = Enum.TextXAlignment.Left
dlLabel.ZIndex          = 102
dlLabel.Parent          = content

-- Progress bar track
local dlTrack = Instance.new("Frame")
dlTrack.Size            = UDim2.new(0.9, 0, 0, 14)
dlTrack.Position        = UDim2.new(0.05, 0, 0, 40)
dlTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
dlTrack.BorderSizePixel = 0
dlTrack.ZIndex          = 102
dlTrack.Parent          = content
Instance.new("UICorner", dlTrack).CornerRadius = UDim.new(0, 5)

local dlFill = Instance.new("Frame")
dlFill.Size            = UDim2.new(0, 0, 1, 0)
dlFill.BackgroundColor3 = theme.accent
dlFill.BorderSizePixel = 0
dlFill.ZIndex          = 103
dlFill.Parent          = dlTrack
Instance.new("UICorner", dlFill).CornerRadius = UDim.new(0, 5)

local dlPct = Instance.new("TextLabel")
dlPct.Size            = UDim2.new(0.9, 0, 0, 14)
dlPct.Position        = UDim2.new(0.05, 0, 0, 57)
dlPct.BackgroundTransparency = 1
dlPct.Text            = "0%   |   0.0 MB / ?.? MB"
dlPct.TextColor3      = theme.text
dlPct.TextSize        = 10
dlPct.Font            = Enum.Font.Code
dlPct.TextXAlignment  = Enum.TextXAlignment.Left
dlPct.ZIndex          = 102
dlPct.Parent          = content

-- Info / log box
local infoBox = Instance.new("Frame")
infoBox.Size            = UDim2.new(0.9, 0, 0, 108)
infoBox.Position        = UDim2.new(0.05, 0, 0, 80)
infoBox.BackgroundColor3 = Color3.fromRGB(0,0,0)
infoBox.BackgroundTransparency = appTheme == "mom" and 0.75 or 0.5
infoBox.BorderSizePixel = 0
infoBox.ZIndex          = 102
infoBox.Parent          = content
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 7)

local infoText = Instance.new("TextLabel")
infoText.Size           = UDim2.new(1, -12, 1, -8)
infoText.Position       = UDim2.new(0, 6, 0, 4)
infoText.BackgroundTransparency = 1
infoText.Text           = infoTexts[appTheme]
infoText.TextColor3     = theme.text
infoText.TextSize       = 11
infoText.Font           = Enum.Font.Code
infoText.TextWrapped    = true
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.ZIndex         = 103
infoText.Parent         = infoBox

-- RUN button
local runBtn = Instance.new("TextButton")
runBtn.Size            = UDim2.new(0, 140, 0, 36)
runBtn.Position        = UDim2.new(0.5, -70, 1, -52)
runBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
runBtn.Text            = "▶   RUN"
runBtn.TextColor3      = Color3.fromRGB(110, 110, 120)
runBtn.TextSize        = 14
runBtn.Font            = Enum.Font.GothamBold
runBtn.BorderSizePixel = 0
runBtn.Active          = false
runBtn.AutoButtonColor = false
runBtn.ZIndex          = 102
runBtn.Parent          = content
Instance.new("UICorner", runBtn).CornerRadius = UDim.new(0, 9)

-- ============================================================
-- DRAGGING
-- ============================================================
local dragging, dragStart, winStart
titleBar.InputBegan:Connect(function(i)
    if (i.UserInputType == Enum.UserInputType.MouseButton1 or
        i.UserInputType == Enum.UserInputType.Touch) and not isMax then
        dragging = true
        dragStart = i.Position
        winStart  = window.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or
        i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        window.Position = UDim2.new(winStart.X.Scale, winStart.X.Offset + d.X,
                                     winStart.Y.Scale, winStart.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or
       i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================
-- WINDOW CONTROLS
-- ============================================================
local TI_FAST  = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_BACK  = TweenInfo.new(0.28, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
local TI_BACKIN = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- Close
btnClose.MouseButton1Click:Connect(function()
    local cx = window.Position.X.Offset + NW/2
    local cy = window.Position.Y.Offset + NH/2
    TweenService:Create(window, TI_BACKIN, {
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.new(window.Position.X.Scale, cx, window.Position.Y.Scale, cy),
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.3, function() screenGui:Destroy() end)
end)

-- Minimize (shrink to titlebar only / restore)
btnMin.MouseButton1Click:Connect(function()
    if isMax then return end
    if not isMin then
        isMin = true
        savedSize = window.Size
        savedPos  = window.Position
        content.Visible = false
        TweenService:Create(window, TI_BACKIN, {Size = UDim2.new(0, NW, 0, 36)}):Play()
    else
        isMin = false
        content.Visible = true
        TweenService:Create(window, TI_BACK, {Size = savedSize}):Play()
    end
end)

-- Maximize (fullscreen / restore)
btnMax.MouseButton1Click:Connect(function()
    if isMin then return end
    if not isMax then
        isMax = true
        savedSize = window.Size
        savedPos  = window.Position
        TweenService:Create(window, TI_FAST, {
            Size     = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    else
        isMax = false
        TweenService:Create(window, TI_FAST, {
            Size     = savedSize,
            Position = savedPos
        }):Play()
    end
end)

-- ============================================================
-- DOWNLOAD ANIMATION
-- ============================================================
local totalMB      = math.random(52, 134)
local dlDuration   = math.random(5, 9)
local downloadDone = false

task.spawn(function()
    local elapsed = 0
    while elapsed < dlDuration do
        elapsed = elapsed + task.wait(0.05)
        local pct = math.min(elapsed / dlDuration, 1)
        local mb  = pct * totalMB
        dlFill.Size = UDim2.new(pct, 0, 1, 0)
        dlPct.Text  = string.format("%.0f%%   |   %.1f MB / %.1f MB", pct*100, mb, totalMB)
        if pct >= 0.88 then
            dlLabel.Text = "Installing  " .. appName .. "..."
        end
    end
    dlLabel.Text   = "✅   " .. appName .. "  ready!"
    dlPct.Text     = string.format("100%%   |   %.1f MB / %.1f MB", totalMB, totalMB)
    downloadDone   = true

    -- Unlock run button
    TweenService:Create(runBtn, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundColor3 = theme.accent,
        TextColor3       = Color3.fromRGB(255,255,255)
    }):Play()
    runBtn.Active          = true
    runBtn.AutoButtonColor = true

    -- Pulse glow on run button
    task.spawn(function()
        while runBtn.Active do
            TweenService:Create(runBtn, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {BackgroundTransparency=0.3}):Play()
            task.wait(0.7)
            TweenService:Create(runBtn, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {BackgroundTransparency=0}):Play()
            task.wait(0.7)
        end
    end)
end)

-- ============================================================
-- EFFECT HELPERS
-- ============================================================
local function screenFlash(color, times, interval)
    local f = Instance.new("Frame")
    f.Size            = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = color
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ZIndex          = 5000
    f.Parent          = screenGui
    for _ = 1, (times or 3) do
        TweenService:Create(f, TweenInfo.new(0.07), {BackgroundTransparency=0.25}):Play()
        task.wait(0.09)
        TweenService:Create(f, TweenInfo.new(0.1),  {BackgroundTransparency=1}):Play()
        task.wait(interval or 0.2)
    end
    f:Destroy()
end

local function bigText(txt, color, duration)
    local lbl = Instance.new("TextLabel")
    lbl.Size                  = UDim2.new(1,0,0,100)
    lbl.Position              = UDim2.new(0,0,0.4,-50)
    lbl.BackgroundTransparency = 1
    lbl.Text                  = txt
    lbl.TextColor3            = color
    lbl.TextSize              = 10
    lbl.Font                  = Enum.Font.GothamBlack
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3      = Color3.fromRGB(0,0,0)
    lbl.ZIndex                = 4999
    lbl.Parent                = screenGui
    TweenService:Create(lbl, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {TextSize=58}):Play()
    task.delay(duration or 2.5, function()
        TweenService:Create(lbl, TweenInfo.new(0.3), {TextTransparency=1, TextStrokeTransparency=1}):Play()
        task.delay(0.35, function() lbl:Destroy() end)
    end)
end

local function sysMsg(txt, color)
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = txt,
            Color = color or Color3.fromRGB(255,255,255),
            Font = Enum.Font.GothamBold,
            FontSize = Enum.FontSize.Size18,
        })
    end)
end

local function notif(title, body, count, interval)
    task.spawn(function()
        for _ = 1, (count or 3) do
            pcall(function()
                StarterGui:SetCore("SendNotification", {Title=title, Text=body, Duration=4})
            end)
            task.wait(interval or 0.9)
        end
    end)
end

local function chatSay(msgs, count, interval)
    task.spawn(function()
        local rs = game:GetService("ReplicatedStorage")
        local ev = rs:FindFirstChild("DefaultChatSystemChatEvents")
                    and rs.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
        if not ev then return end
        for _ = 1, (count or 5) do
            pcall(function()
                ev:FireServer(msgs[math.random(1,#msgs)], "All")
            end)
            task.wait(interval or 0.5)
        end
    end)
end

-- Fake "You were kicked" overlay + actual kick attempt
local function fakeKick(msg, delay_)
    task.delay(delay_ or 0, function()
        -- Explosion on character
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local exp = Instance.new("Explosion")
                exp.Position    = root.Position
                exp.BlastRadius = 20
                exp.BlastPressure = 9e5
                exp.Parent      = workspace
            end
        end)
        task.wait(1.2)
        -- Black overlay
        local ov = Instance.new("Frame")
        ov.Size            = UDim2.new(1,0,1,0)
        ov.BackgroundColor3 = Color3.fromRGB(0,0,0)
        ov.ZIndex          = 9999
        ov.BorderSizePixel = 0
        ov.Parent          = screenGui
        local kl = Instance.new("TextLabel", ov)
        kl.Size            = UDim2.new(0.8,0,0.3,0)
        kl.Position        = UDim2.new(0.1,0,0.35,0)
        kl.BackgroundTransparency = 1
        kl.Text            = "You were kicked from this experience:\n\n" .. (msg or "💀")
        kl.TextColor3      = Color3.fromRGB(255,255,255)
        kl.TextSize        = 26
        kl.Font            = Enum.Font.GothamBold
        kl.TextWrapped     = true
        kl.ZIndex          = 10000
        task.wait(3)
        pcall(function() LocalPlayer:Kick(msg or "bye") end)
    end)
end

-- ============================================================
-- EFFECTS PER THEME
-- ============================================================
local Effects = {}

-- SUS
Effects.sus = function()
    bigText("⚠️  EMERGENCY MEETING  ⚠️", Color3.fromRGB(255,50,50), 3.5)
    screenFlash(Color3.fromRGB(200,0,0), 5, 0.18)
    chatSay({"AMONG US 📮","RED IS SUS!!","EMERGENCY MEETING 🚨","He was the impostor.","Eject them NOW!"}, 8, 0.45)
    notif("🚨 EMERGENCY MEETING", "A body has been reported!", 5, 0.8)
    task.delay(4, function() fakeKick("You were the impostor. 📮") end)
end

-- ROBLOX (fake BSOD)
Effects.roblox = function()
    local crash = Instance.new("Frame")
    crash.Size            = UDim2.new(1,0,1,0)
    crash.BackgroundColor3 = Color3.fromRGB(0,120,215)
    crash.ZIndex          = 5000
    crash.BorderSizePixel = 0
    crash.Parent          = screenGui

    local sadFace = Instance.new("TextLabel", crash)
    sadFace.Size  = UDim2.new(0.8,0,0,120)
    sadFace.Position = UDim2.new(0.1,0,0.12,0)
    sadFace.BackgroundTransparency = 1
    sadFace.Text  = ":("
    sadFace.TextColor3 = Color3.fromRGB(255,255,255)
    sadFace.TextSize   = 130
    sadFace.Font       = Enum.Font.GothamThin
    sadFace.ZIndex     = 5001

    local bsodTxt = Instance.new("TextLabel", crash)
    bsodTxt.Size  = UDim2.new(0.75,0,0.4,0)
    bsodTxt.Position = UDim2.new(0.12,0,0.38,0)
    bsodTxt.BackgroundTransparency = 1
    bsodTxt.Text  = "Your Roblox ran into a problem and needs to restart.\n\nError Code: EXPLOITER_DETECTED\nStop Code: ROBLOX_VIRUS.EXE\n\nVersion: 666.0.0\nFile: robloxapp.exe"
    bsodTxt.TextColor3 = Color3.fromRGB(255,255,255)
    bsodTxt.TextSize   = 16
    bsodTxt.Font       = Enum.Font.Gotham
    bsodTxt.TextWrapped = true
    bsodTxt.TextXAlignment = Enum.TextXAlignment.Left
    bsodTxt.ZIndex     = 5001

    local prog = Instance.new("TextLabel", crash)
    prog.Size     = UDim2.new(0.75,0,0,28)
    prog.Position = UDim2.new(0.12,0,0.85,0)
    prog.BackgroundTransparency = 1
    prog.Text     = "0% complete"
    prog.TextColor3 = Color3.fromRGB(255,255,255)
    prog.TextSize   = 15
    prog.Font       = Enum.Font.Gotham
    prog.TextXAlignment = Enum.TextXAlignment.Left
    prog.ZIndex     = 5001

    task.spawn(function()
        for i = 0, 100, 2 do
            task.wait(0.07)
            prog.Text = i .. "% complete"
        end
        task.wait(0.8)
        fakeKick("BSOD: ROBLOX_VIRUS.EXE 💻")
    end)
end

-- FREE ROBUX
Effects.robux = function()
    bigText("💰  ROBUX INCOMING  💰", Color3.fromRGB(255,215,0), 3)
    notif("💰 FREE ROBUX", "Generating 99,999 Robux for you...", 5, 0.7)
    task.delay(1.5, function()
        -- Multiplying pop-up ads
        for i = 1, 12 do
            task.spawn(function()
                local pad = Instance.new("Frame")
                pad.Size            = UDim2.new(0, 190, 0, 90)
                pad.Position        = UDim2.new(math.random()*0.75, 0, math.random()*0.75, 0)
                pad.BackgroundColor3 = Color3.fromRGB(10,100,10)
                pad.BorderSizePixel = 0
                pad.ZIndex          = 800
                pad.Parent          = screenGui
                Instance.new("UICorner", pad).CornerRadius = UDim.new(0, 8)
                local pl = Instance.new("TextLabel", pad)
                pl.Size            = UDim2.new(1,0,1,0)
                pl.BackgroundTransparency = 1
                pl.Text            = "🤑  FREE ROBUX\nClick to claim!"
                pl.TextColor3      = Color3.fromRGB(255,215,0)
                pl.TextSize        = 15
                pl.Font            = Enum.Font.GothamBold
                pl.ZIndex          = 801
                task.delay(3.5, function() pad:Destroy() end)
            end)
            task.wait(0.22)
        end
    end)
    task.delay(5.5, function() fakeKick("Robux Scam Detected 💸  Goodbye.") end)
end

-- HUB
Effects.hub = function()
    notif("🔧 ScriptHub Pro", "Executing secret payload...", 3, 0.8)
    local logWin = Instance.new("Frame")
    logWin.Size            = UDim2.new(0, 360, 0, 210)
    logWin.Position        = UDim2.new(0.5,-180,0.5,-105)
    logWin.BackgroundColor3 = Color3.fromRGB(12,12,22)
    logWin.BorderSizePixel = 0
    logWin.ZIndex          = 500
    logWin.Parent          = screenGui
    Instance.new("UICorner", logWin).CornerRadius = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel", logWin)
    lbl.Size            = UDim2.new(1,-14,1,-12)
    lbl.Position        = UDim2.new(0,7,0,6)
    lbl.BackgroundTransparency = 1
    lbl.Text            = ""
    lbl.TextColor3      = Color3.fromRGB(0,255,100)
    lbl.TextSize        = 12
    lbl.Font            = Enum.Font.Code
    lbl.TextXAlignment  = Enum.TextXAlignment.Left
    lbl.TextYAlignment  = Enum.TextYAlignment.Top
    lbl.TextWrapped     = true
    lbl.ZIndex          = 501
    local logs = {
        "> Initializing ScriptHub Pro v9.9...",
        "> Loading modules... ✅",
        "> Bypassing Byfron anti-cheat... ✅",
        "> Injecting payload... ✅",
        "> Server crash scheduled in 3...",
        "> Server crash scheduled in 2...",
        "> Server crash scheduled in 1...",
        "> BOOM 💥  GG everyone.",
    }
    task.spawn(function()
        local txt = ""
        for _, l in ipairs(logs) do
            txt = txt .. l .. "\n"
            lbl.Text = txt
            task.wait(0.65)
        end
        task.wait(0.4)
        logWin:Destroy()
        fakeKick("Hub.exe finished its job. 🔧")
    end)
end

-- DISCORD
Effects.discord = function()
    local yOffset = -80
    local function discordNotif(user, msg)
        local n = Instance.new("Frame")
        n.Size            = UDim2.new(0, 310, 0, 68)
        n.Position        = UDim2.new(1, 10, 1, yOffset)
        n.BackgroundColor3 = Color3.fromRGB(54,57,63)
        n.BorderSizePixel = 0
        n.ZIndex          = 900
        n.Parent          = screenGui
        Instance.new("UICorner", n).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", n)
        stroke.Color     = Color3.fromRGB(88,101,242)
        stroke.Thickness = 1.5
        local nt = Instance.new("TextLabel", n)
        nt.Size            = UDim2.new(1,-12,1,-10)
        nt.Position        = UDim2.new(0,6,0,5)
        nt.BackgroundTransparency = 1
        nt.Text            = "🔔  " .. user .. "\n" .. msg
        nt.TextColor3      = Color3.fromRGB(220,221,222)
        nt.TextSize        = 13
        nt.Font            = Enum.Font.Gotham
        nt.TextXAlignment  = Enum.TextXAlignment.Left
        nt.TextWrapped     = true
        nt.ZIndex          = 901
        TweenService:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = UDim2.new(1, -318, 1, yOffset)}):Play()
        yOffset = yOffset - 76
        task.delay(4, function()
            TweenService:Create(n, TweenInfo.new(0.25), {Position = UDim2.new(1, 10, 1, n.Position.Y.Offset)}):Play()
            task.delay(0.3, function() n:Destroy() end)
        end)
    end
    local convos = {
        {"Mom 💖", "Dinner is ready sweetheart 🍜"},
        {"Xeno Support", "Your executor has been detected 🚫"},
        {"FBI Agent", "We know what you did. 👀"},
        {"Roblox", "Your account has been terminated."},
        {"Delta Executor", "Update available: v999.0 ⚡"},
        {"Among Us", "Emergency meeting!!! 🚨"},
    }
    task.spawn(function()
        for _, m in ipairs(convos) do
            discordNotif(m[1], m[2])
            task.wait(1.1)
        end
        task.delay(0.8, function()
            chatSay({"@everyone free robux → free-robux.scam","join my discord!","ping ping ping 🔔"}, 5, 0.4)
            fakeKick("Discord.exe closed unexpectedly. 🎮")
        end)
    end)
end

-- DELTA
Effects.delta = function()
    screenFlash(Color3.fromRGB(0,150,255), 4, 0.15)
    bigText("⚡  INJECTING...  ⚡", Color3.fromRGB(0,200,255), 3)
    notif("⚡ Delta Executor", "Injection successful! Bypassing Byfron...", 4, 0.8)
    task.delay(3, function()
        screenFlash(Color3.fromRGB(255,50,50), 6, 0.12)
        bigText("❌  INJECTION FAILED  ❌", Color3.fromRGB(255,80,30), 3)
        task.delay(1, function() fakeKick("⚡ Delta.exe crashed your game.") end)
    end)
end

-- XENO
Effects.xeno = function()
    screenFlash(Color3.fromRGB(255,140,0), 5, 0.15)
    bigText("🔥  XENO ACTIVATED  🔥", Color3.fromRGB(255,140,0), 3)
    chatSay({"XENO > ALL 🔥","💀💀💀","system32 deleted ✅","goodbye everyone 👋","GG no re"}, 7, 0.38)
    notif("🔥 Xeno Executor", "Skull mode activated. Goodbye.", 3, 0.7)
    task.delay(3.5, function() fakeKick("🔥 Xeno.exe says goodbye. 💀") end)
end

-- MOM.LOVE  ✨ Special event
Effects.mom = function()
    task.spawn(function()
        bigText("💖  Hi, sweetheart...  💖", Color3.fromRGB(255,100,150), 4)
        sysMsg("💖 Mom: I missed you so much...", Color3.fromRGB(255,100,150))
        notif("💖 Mom.Love", "She's here for you.", 2, 1)
        task.wait(3)

        -- Build Mom NPC near player
        local char  = LocalPlayer.Character
        local root  = char and char:FindFirstChild("HumanoidRootPart")
        local base  = root and root.Position or Vector3.new(0,3,0)
        local spawn = base + Vector3.new(6, 0, 0)

        local mom = Instance.new("Model")
        mom.Name   = "Mom"
        mom.Parent = workspace

        local function makePart(name, sz, cf, col)
            local p = Instance.new("Part")
            p.Name     = name
            p.Size     = sz
            p.CFrame   = cf
            p.BrickColor = BrickColor.new(col or "Light orange")
            p.Material = Enum.Material.SmoothPlastic
            p.Anchored = true
            p.Parent   = mom
            return p
        end

        local torso = makePart("Torso",    Vector3.new(2,2,1),   CFrame.new(spawn+Vector3.new(0,3,0)))
        local head  = makePart("Head",     Vector3.new(1,1,1),   CFrame.new(spawn+Vector3.new(0,5.1,0)))
        local lArm  = makePart("LeftArm",  Vector3.new(1,2,1),   CFrame.new(spawn+Vector3.new(-1.5,3,0)))
        local rArm  = makePart("RightArm", Vector3.new(1,2,1),   CFrame.new(spawn+Vector3.new( 1.5,3,0)))
        local lLeg  = makePart("LeftLeg",  Vector3.new(1,2,1),   CFrame.new(spawn+Vector3.new(-0.5,1,0)))
        local rLeg  = makePart("RightLeg", Vector3.new(1,2,1),   CFrame.new(spawn+Vector3.new( 0.5,1,0)))
        mom.PrimaryPart = torso

        -- Heart over head
        local bb = Instance.new("BillboardGui")
        bb.Size        = UDim2.new(0, 110, 0, 44)
        bb.StudsOffset = Vector3.new(0, 2.2, 0)
        bb.AlwaysOnTop = true
        bb.Parent      = head
        local nameTag  = Instance.new("TextLabel", bb)
        nameTag.Size   = UDim2.new(1,0,1,0)
        nameTag.BackgroundTransparency = 1
        nameTag.Text   = "💖  Mom  💖"
        nameTag.TextColor3 = Color3.fromRGB(255,100,150)
        nameTag.TextSize   = 19
        nameTag.Font       = Enum.Font.GothamBold

        local allParts   = {lArm, rArm, lLeg, rLeg, torso, head}
        local glitched   = {}
        local glitchCount = 0
        local lastGlitch = tick()
        local GLITCH_INTERVAL = 10

        local momMsgs = {
            "💖 Mom: Are you eating properly?",
            "💖 Mom: I made your favorite food...",
            "💖 Mom: Don't stay up too late, okay?",
            "💖 Mom: I'm always here for you.",
            "💖 Mom: Don't be scared... it's still me.",
        }
        local msgIdx = 1

        task.spawn(function()
            while mom and mom.Parent do
                task.wait(0.06)

                -- Animate already-glitched parts (rainbow + jitter)
                for part, origCF in pairs(glitched) do
                    if part and part.Parent then
                        local hue = (tick() * 2.5) % 1
                        part.Color = Color3.fromHSV(hue, 1, 1)
                        part.CFrame = origCF * CFrame.new(
                            (math.random()-0.5)*0.12,
                            (math.random()-0.5)*0.12,
                            (math.random()-0.5)*0.08
                        )
                    end
                end

                -- Glitch one new limb every 10s
                if tick() - lastGlitch >= GLITCH_INTERVAL then
                    lastGlitch = tick()
                    for _, p in ipairs(allParts) do
                        if not glitched[p] then
                            glitched[p] = p.CFrame
                            glitchCount += 1
                            sysMsg(momMsgs[math.min(msgIdx, #momMsgs)], Color3.fromRGB(255,100,150))
                            msgIdx += 1
                            break
                        end
                    end

                    -- All parts glitched → wait 3s → BOOM → kick
                    if glitchCount >= #allParts then
                        task.wait(3)
                        sysMsg("💖 Mom: I love you.", Color3.fromRGB(255,50,100))
                        task.wait(0.6)
                        local exp = Instance.new("Explosion")
                        exp.Position    = torso.Position
                        exp.BlastRadius = 25
                        exp.BlastPressure = 1.2e6
                        exp.Parent      = workspace
                        mom:Destroy()
                        task.wait(2)
                        fakeKick("i love you.")
                        break
                    end
                end
            end
        end)
    end)
end

-- ============================================================
-- RUN BUTTON CLICK
-- ============================================================
runBtn.MouseButton1Click:Connect(function()
    if not downloadDone then return end
    runBtn.Active          = false
    runBtn.AutoButtonColor = false
    TweenService:Create(runBtn, TweenInfo.new(0.2), {BackgroundTransparency=0.45}):Play()
    runBtn.Text = "Running..."

    screenFlash(theme.accent, 2, 0.1)

    task.delay(0.5, function()
        local fx = Effects[appTheme]
        if fx then fx() end
    end)
end)

-- ============================================================
-- ENTRY ANIMATION
-- ============================================================
TweenService:Create(window, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size                 = UDim2.new(0, NW, 0, NH),
    Position             = UDim2.new(0.5, -NW/2, 0.5, -NH/2),
    BackgroundTransparency = 0
}):Play()

print("[VirusGUI] Loaded — " .. appName .. " (" .. appTheme .. ")")
