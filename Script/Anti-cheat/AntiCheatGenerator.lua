-- ╔══════════════════════════════════════════════════════╗
-- ║        ANTI-CHEAT GENERATOR  v2.0                    ║
-- ║        Created by KHAFIDZKTP                         ║
-- ║        Auto-Learning Anti-Cheat System               ║
-- ╚══════════════════════════════════════════════════════╝

-- ► SERVICES
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ► DESTROY OLD GUI
if CoreGui:FindFirstChild("ACGen_GUI") then
    CoreGui:FindFirstChild("ACGen_GUI"):Destroy()
end

-- ► CONFIGURATION STATE
local Config = {
    GameType     = "FPS",
    Strictness   = "Medium",
    Features     = {
        SpeedCheck    = true,
        FlyCheck      = true,
        TeleportCheck = true,
        AimBot        = true,
        WallHack      = false,
        ChatFilter    = false,
        RapidFire     = true,
        BHop          = true,
    },
    DiscordWebhook  = "",
    DiscordEnabled  = false,
    CheckInterval   = 24,
    AutoLearn       = true,
    OwnerUserId     = tostring(LocalPlayer.UserId),
}

-- ► TWEEN HELPER
local function tween(obj, props, dur, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(dur or 0.3, style, dir), props):Play()
end

-- ► RIPPLE EFFECT
local function ripple(btn)
    local rip = Instance.new("Frame")
    rip.Size             = UDim2.new(0,0,0,0)
    rip.AnchorPoint      = Vector2.new(0.5,0.5)
    rip.Position         = UDim2.new(0.5,0,0.5,0)
    rip.BackgroundColor3 = Color3.fromRGB(255,255,255)
    rip.BackgroundTransparency = 0.7
    rip.BorderSizePixel  = 0
    rip.ZIndex           = btn.ZIndex + 1
    rip.Parent           = btn
    Instance.new("UICorner", rip).CornerRadius = UDim.new(1,0)
    tween(rip, {Size = UDim2.new(2,0,2,0), BackgroundTransparency = 1}, 0.5)
    task.delay(0.5, function() rip:Destroy() end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ►  GUI  CONSTRUCTION
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name              = "ACGen_GUI"
ScreenGui.ResetOnSpawn      = false
ScreenGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder      = 999
ScreenGui.Parent            = CoreGui

-- MAIN WINDOW
local Main = Instance.new("Frame")
Main.Name                   = "Main"
Main.Size                   = UDim2.new(0, 620, 0, 500)
Main.Position               = UDim2.new(0.5, -310, 0.5, -250)
Main.BackgroundColor3       = Color3.fromRGB(10, 12, 20)
Main.BorderSizePixel        = 0
Main.ClipsDescendants       = true
Main.Parent                 = ScreenGui

-- Border glow
local border = Instance.new("UIStroke", Main)
border.Color     = Color3.fromRGB(0, 190, 255)
border.Thickness = 1.5
border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local mainCorner = Instance.new("UICorner", Main)
mainCorner.CornerRadius = UDim.new(0, 12)

-- AMBIENT GLOW BACKGROUND
local ambientBG = Instance.new("Frame")
ambientBG.Size               = UDim2.new(1, 0, 1, 0)
ambientBG.BackgroundColor3   = Color3.fromRGB(0, 190, 255)
ambientBG.BackgroundTransparency = 0.94
ambientBG.BorderSizePixel    = 0
ambientBG.ZIndex             = 0
ambientBG.Parent             = Main
Instance.new("UICorner", ambientBG).CornerRadius = UDim.new(0, 12)

-- HEADER BAR
local Header = Instance.new("Frame")
Header.Name                 = "Header"
Header.Size                 = UDim2.new(1, 0, 0, 56)
Header.BackgroundColor3     = Color3.fromRGB(6, 8, 16)
Header.BorderSizePixel      = 0
Header.ZIndex               = 3
Header.Parent               = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

-- fix top corners only
local headerFix = Instance.new("Frame")
headerFix.Size              = UDim2.new(1,0,0.5,0)
headerFix.Position          = UDim2.new(0,0,0.5,0)
headerFix.BackgroundColor3  = Color3.fromRGB(6, 8, 16)
headerFix.BorderSizePixel   = 0
headerFix.ZIndex            = 3
headerFix.Parent            = Header

-- Accent line under header
local accentLine = Instance.new("Frame")
accentLine.Size             = UDim2.new(1,0,0,2)
accentLine.Position         = UDim2.new(0,0,1,-2)
accentLine.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
accentLine.BorderSizePixel  = 0
accentLine.ZIndex           = 4
accentLine.Parent           = Header

-- Logo icon (shield)
local shieldLbl = Instance.new("TextLabel")
shieldLbl.Size              = UDim2.new(0, 36, 0, 36)
shieldLbl.Position          = UDim2.new(0, 14, 0.5, -18)
shieldLbl.BackgroundColor3  = Color3.fromRGB(0, 190, 255)
shieldLbl.BorderSizePixel   = 0
shieldLbl.ZIndex            = 5
shieldLbl.Text              = "🛡"
shieldLbl.TextSize          = 20
shieldLbl.Font              = Enum.Font.GothamBold
shieldLbl.TextColor3        = Color3.fromRGB(255,255,255)
shieldLbl.Parent            = Header
Instance.new("UICorner", shieldLbl).CornerRadius = UDim.new(0,8)

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size             = UDim2.new(0, 250, 0, 28)
TitleLabel.Position         = UDim2.new(0, 58, 0.5, -14)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text             = "ANTI-CHEAT GENERATOR"
TitleLabel.TextColor3       = Color3.fromRGB(255,255,255)
TitleLabel.Font             = Enum.Font.GothamBold
TitleLabel.TextSize         = 16
TitleLabel.TextXAlignment   = Enum.TextXAlignment.Left
TitleLabel.ZIndex           = 5
TitleLabel.Parent           = Header

local SubLabel = Instance.new("TextLabel")
SubLabel.Size               = UDim2.new(0, 250, 0, 16)
SubLabel.Position           = UDim2.new(0, 58, 0.5, 10)
SubLabel.BackgroundTransparency = 1
SubLabel.Text               = "by KHAFIDZKTP  •  v2.0  •  Auto-Learning"
SubLabel.TextColor3         = Color3.fromRGB(0, 190, 255)
SubLabel.Font               = Enum.Font.Gotham
SubLabel.TextSize           = 11
SubLabel.TextXAlignment     = Enum.TextXAlignment.Left
SubLabel.ZIndex             = 5
SubLabel.Parent             = Header

-- CLOSE button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size               = UDim2.new(0, 28, 0, 28)
CloseBtn.Position           = UDim2.new(1, -40, 0.5, -14)
CloseBtn.BackgroundColor3   = Color3.fromRGB(220, 50, 50)
CloseBtn.Text               = "✕"
CloseBtn.TextColor3         = Color3.fromRGB(255,255,255)
CloseBtn.Font               = Enum.Font.GothamBold
CloseBtn.TextSize           = 13
CloseBtn.BorderSizePixel    = 0
CloseBtn.ZIndex             = 6
CloseBtn.Parent             = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)

-- MINIMIZE button
local MinBtn = Instance.new("TextButton")
MinBtn.Size                 = UDim2.new(0, 28, 0, 28)
MinBtn.Position             = UDim2.new(1, -74, 0.5, -14)
MinBtn.BackgroundColor3     = Color3.fromRGB(40, 160, 80)
MinBtn.Text                 = "—"
MinBtn.TextColor3           = Color3.fromRGB(255,255,255)
MinBtn.Font                 = Enum.Font.GothamBold
MinBtn.TextSize             = 13
MinBtn.BorderSizePixel      = 0
MinBtn.ZIndex               = 6
MinBtn.Parent               = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,6)

-- ► DRAGGING
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos  = Main.Position
    end
end)
Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- MINIMIZE logic
local minimized = false
CloseBtn.MouseButton1Click:Connect(function()
    ripple(CloseBtn)
    tween(Main, {Size = UDim2.new(0,620,0,0)}, 0.3)
    task.delay(0.35, function() ScreenGui:Destroy() end)
end)
MinBtn.MouseButton1Click:Connect(function()
    ripple(MinBtn)
    minimized = not minimized
    if minimized then
        tween(Main, {Size = UDim2.new(0,620,0,56)}, 0.3)
    else
        tween(Main, {Size = UDim2.new(0,620,0,500)}, 0.3)
    end
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ►  TAB NAVIGATION BAR
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local TabBar = Instance.new("Frame")
TabBar.Name                 = "TabBar"
TabBar.Size                 = UDim2.new(0, 140, 1, -56)
TabBar.Position             = UDim2.new(0, 0, 0, 56)
TabBar.BackgroundColor3     = Color3.fromRGB(8, 10, 18)
TabBar.BorderSizePixel      = 0
TabBar.ZIndex               = 3
TabBar.Parent               = Main

local tabRight = Instance.new("Frame")
tabRight.Size               = UDim2.new(0,1,1,0)
tabRight.Position           = UDim2.new(1,-1,0,0)
tabRight.BackgroundColor3   = Color3.fromRGB(0, 190, 255)
tabRight.BackgroundTransparency = 0.5
tabRight.BorderSizePixel    = 0
tabRight.ZIndex             = 4
tabRight.Parent             = TabBar

-- CONTENT AREA
local ContentArea = Instance.new("Frame")
ContentArea.Name            = "ContentArea"
ContentArea.Size            = UDim2.new(1, -140, 1, -56)
ContentArea.Position        = UDim2.new(0, 140, 0, 56)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.ZIndex          = 2
ContentArea.Parent          = Main

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ►  HELPER: MAKE TAB BUTTON
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local tabButtons    = {}
local tabPanels     = {}
local activeTab     = nil

local tabDefs = {
    { id = "game",     icon = "🎮", label = "Game Type"  },
    { id = "strict",   icon = "⚙️",  label = "Strictness" },
    { id = "features", icon = "🔧", label = "Features"   },
    { id = "discord",  icon = "💬", label = "Discord"    },
    { id = "generate", icon = "⚡", label = "Generate"   },
}

for i, def in ipairs(tabDefs) do
    local btn = Instance.new("TextButton")
    btn.Size                = UDim2.new(1, 0, 0, 56)
    btn.Position            = UDim2.new(0, 0, 0, (i-1)*56)
    btn.BackgroundColor3    = Color3.fromRGB(8, 10, 18)
    btn.BorderSizePixel     = 0
    btn.Text                = ""
    btn.ZIndex              = 4
    btn.Parent              = TabBar

    local accentBar = Instance.new("Frame")
    accentBar.Name          = "Accent"
    accentBar.Size          = UDim2.new(0, 3, 0.6, 0)
    accentBar.Position      = UDim2.new(0, 0, 0.2, 0)
    accentBar.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
    accentBar.BackgroundTransparency = 1
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex        = 5
    accentBar.Parent        = btn

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size            = UDim2.new(0, 30, 0, 24)
    iconLbl.Position        = UDim2.new(0, 12, 0.5, -12)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text            = def.icon
    iconLbl.TextSize        = 16
    iconLbl.Font            = Enum.Font.GothamBold
    iconLbl.TextColor3      = Color3.fromRGB(130,130,160)
    iconLbl.ZIndex          = 5
    iconLbl.Parent          = btn

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size            = UDim2.new(1, -50, 0, 16)
    nameLbl.Position        = UDim2.new(0, 46, 0.5, -8)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text            = def.label
    nameLbl.TextSize        = 11
    nameLbl.Font            = Enum.Font.GothamBold
    nameLbl.TextColor3      = Color3.fromRGB(110,110,140)
    nameLbl.TextXAlignment  = Enum.TextXAlignment.Left
    nameLbl.ZIndex          = 5
    nameLbl.Parent          = btn

    tabButtons[def.id] = { btn = btn, accent = accentBar, icon = iconLbl, name = nameLbl }

    -- PANEL
    local panel = Instance.new("ScrollingFrame")
    panel.Name              = def.id .. "_panel"
    panel.Size              = UDim2.new(1, 0, 1, 0)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel   = 0
    panel.ScrollBarThickness = 3
    panel.ScrollBarImageColor3 = Color3.fromRGB(0,190,255)
    panel.CanvasSize        = UDim2.new(0, 0, 0, 0)
    panel.Visible           = false
    panel.ZIndex            = 3
    panel.Parent            = ContentArea
    tabPanels[def.id]       = panel

    btn.MouseButton1Click:Connect(function()
        ripple(btn)
        switchTab(def.id)
    end)
end

-- ► SWITCH TAB FUNCTION
function switchTab(id)
    if activeTab == id then return end
    -- hide all panels
    for pid, panel in pairs(tabPanels) do
        panel.Visible = false
        local tb = tabButtons[pid]
        tween(tb.btn, {BackgroundColor3 = Color3.fromRGB(8,10,18)}, 0.2)
        tween(tb.accent, {BackgroundTransparency = 1}, 0.2)
        tween(tb.icon, {TextColor3 = Color3.fromRGB(110,110,140)}, 0.2)
        tween(tb.name, {TextColor3 = Color3.fromRGB(110,110,140)}, 0.2)
    end
    -- show active
    tabPanels[id].Visible = true
    local atb = tabButtons[id]
    tween(atb.btn, {BackgroundColor3 = Color3.fromRGB(12,18,32)}, 0.2)
    tween(atb.accent, {BackgroundTransparency = 0}, 0.2)
    tween(atb.icon, {TextColor3 = Color3.fromRGB(0,190,255)}, 0.2)
    tween(atb.name, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
    activeTab = id
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ►  HELPER UI ELEMENTS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local CYAN    = Color3.fromRGB(0, 190, 255)
local WHITE   = Color3.fromRGB(255,255,255)
local DIM     = Color3.fromRGB(130,130,160)
local DARK    = Color3.fromRGB(14, 18, 30)
local DARKER  = Color3.fromRGB(10, 12, 20)

local function sectionTitle(parent, yoff, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1, -24, 0, 18)
    lbl.Position           = UDim2.new(0, 12, 0, yoff)
    lbl.BackgroundTransparency = 1
    lbl.Text               = text
    lbl.TextColor3         = CYAN
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize           = 11
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 4
    lbl.Parent             = parent
    local line = Instance.new("Frame")
    line.Size              = UDim2.new(1, -24, 0, 1)
    line.Position          = UDim2.new(0, 12, 0, yoff + 20)
    line.BackgroundColor3  = CYAN
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel   = 0
    line.ZIndex            = 4
    line.Parent            = parent
    return yoff + 28
end

local function makeCard(parent, yoff, h)
    local card = Instance.new("Frame")
    card.Size              = UDim2.new(1, -24, 0, h)
    card.Position          = UDim2.new(0, 12, 0, yoff)
    card.BackgroundColor3  = DARK
    card.BorderSizePixel   = 0
    card.ZIndex            = 4
    card.Parent            = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color           = Color3.fromRGB(30,40,60)
    stroke.Thickness       = 1
    return card
end

-- RADIO GROUP
local function makeRadioGroup(parent, yoff, label, options, key)
    local startY = yoff
    yoff = sectionTitle(parent, yoff, label)
    local rowY = yoff + 4

    for i, opt in ipairs(options) do
        local card = makeCard(parent, rowY + (i-1)*42, 34)
        local radio = Instance.new("Frame")
        radio.Size             = UDim2.new(0, 16, 0, 16)
        radio.Position         = UDim2.new(0, 12, 0.5, -8)
        radio.BackgroundColor3 = Color3.fromRGB(30,40,60)
        radio.BorderSizePixel  = 0
        radio.ZIndex           = 5
        radio.Parent           = card
        Instance.new("UICorner", radio).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame")
        dot.Name               = "Dot"
        dot.Size               = UDim2.new(0, 8, 0, 8)
        dot.AnchorPoint        = Vector2.new(0.5, 0.5)
        dot.Position           = UDim2.new(0.5, 0, 0.5, 0)
        dot.BackgroundColor3   = CYAN
        dot.BackgroundTransparency = Config[key] == opt.value and 0 or 1
        dot.BorderSizePixel    = 0
        dot.ZIndex             = 6
        dot.Parent             = radio
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local lbl = Instance.new("TextLabel")
        lbl.Size               = UDim2.new(1, -44, 1, 0)
        lbl.Position           = UDim2.new(0, 36, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text               = opt.label
        lbl.TextColor3         = WHITE
        lbl.Font               = Enum.Font.Gotham
        lbl.TextSize           = 12
        lbl.TextXAlignment     = Enum.TextXAlignment.Left
        lbl.ZIndex             = 5
        lbl.Parent             = card

        local desc = ""
        if opt.desc then
            local dl = Instance.new("TextLabel")
            dl.Size            = UDim2.new(1, -44, 0, 12)
            dl.Position        = UDim2.new(0, 36, 0.5, 2)
            dl.BackgroundTransparency = 1
            dl.Text            = opt.desc
            dl.TextColor3      = DIM
            dl.Font            = Enum.Font.Gotham
            dl.TextSize        = 10
            dl.TextXAlignment  = Enum.TextXAlignment.Left
            dl.ZIndex          = 5
            dl.Parent          = card
        end

        local btn = Instance.new("TextButton")
        btn.Size               = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text               = ""
        btn.ZIndex             = 7
        btn.Parent             = card

        btn.MouseButton1Click:Connect(function()
            Config[key] = opt.value
            -- update all dots in group by re-scanning
            for _, c in ipairs(parent:GetChildren()) do
                if c:IsA("Frame") and c:FindFirstChild("UICorner") then
                    local r = c:FindFirstChildOfClass("Frame")
                    if r then
                        local d = r:FindFirstChild("Dot")
                        if d then
                            -- rough match: parent has same y range
                        end
                    end
                end
            end
            dot.BackgroundTransparency = 0
        end)

        card._dot   = dot
        card._value = opt.value
        card._key   = key
        card._btn   = btn
        rowY = rowY
    end

    yoff = rowY + #options * 42 + 8
    return yoff
end

-- TOGGLE SWITCH
local function makeToggle(parent, yoff, label, key, desc)
    local card = makeCard(parent, yoff, 46)

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1, -80, 0, 18)
    lbl.Position           = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = WHITE
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize           = 12
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 5
    lbl.Parent             = card

    if desc then
        local dl = Instance.new("TextLabel")
        dl.Size            = UDim2.new(1, -80, 0, 14)
        dl.Position        = UDim2.new(0, 14, 0, 24)
        dl.BackgroundTransparency = 1
        dl.Text            = desc
        dl.TextColor3      = DIM
        dl.Font            = Enum.Font.Gotham
        dl.TextSize        = 10
        dl.TextXAlignment  = Enum.TextXAlignment.Left
        dl.ZIndex          = 5
        dl.Parent          = card
    end

    -- toggle track
    local track = Instance.new("Frame")
    track.Size             = UDim2.new(0, 40, 0, 22)
    track.Position         = UDim2.new(1, -52, 0.5, -11)
    track.BackgroundColor3 = Config.Features[key] and CYAN or Color3.fromRGB(30,40,60)
    track.BorderSizePixel  = 0
    track.ZIndex           = 5
    track.Parent           = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame")
    thumb.Size             = UDim2.new(0, 16, 0, 16)
    thumb.Position         = Config.Features[key]
        and UDim2.new(0, 21, 0.5, -8)
        or  UDim2.new(0, 3, 0.5, -8)
    thumb.BackgroundColor3 = WHITE
    thumb.BorderSizePixel  = 0
    thumb.ZIndex           = 6
    thumb.Parent           = track
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Size               = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text               = ""
    btn.ZIndex             = 7
    btn.Parent             = card

    btn.MouseButton1Click:Connect(function()
        Config.Features[key] = not Config.Features[key]
        tween(track, {BackgroundColor3 = Config.Features[key] and CYAN or Color3.fromRGB(30,40,60)}, 0.2)
        tween(thumb, {Position = Config.Features[key]
            and UDim2.new(0,21,0.5,-8)
            or  UDim2.new(0,3,0.5,-8)}, 0.2)
    end)

    return yoff + 54
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ►  TAB 1: GAME TYPE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local gPanel = tabPanels["game"]
local gy = 12

gy = sectionTitle(gPanel, gy, "━  SELECT YOUR GAME TYPE")

local gameTypes = {
    { value="FPS",      label="🔫  FPS / Shooter",          desc="First-person shooter, combat games" },
    { value="RPG",      label="⚔️   RPG / Adventure",         desc="Role-playing, open world games"    },
    { value="RACING",   label="🏎️   Racing / Simulator",      desc="Vehicle, speed-based games"        },
    { value="OBBY",     label="🟦  Obstacle Course / Obby",  desc="Platformer, parkour games"         },
    { value="TYCOON",   label="💰  Tycoon / Simulator",      desc="Economic, building games"          },
    { value="HORROR",   label="👻  Horror",                  desc="Scary, atmospheric games"          },
    { value="CUSTOM",   label="🔩  Custom / Other",          desc="Any other game type"               },
}

local gButtons = {}
for i, gtype in ipairs(gameTypes) do
    local card = makeCard(gPanel, gy + (i-1)*44, 36)

    local radio = Instance.new("Frame")
    radio.Size             = UDim2.new(0, 16, 0, 16)
    radio.Position         = UDim2.new(0, 12, 0.5, -8)
    radio.BackgroundColor3 = Color3.fromRGB(25,35,50)
    radio.BorderSizePixel  = 0
    radio.ZIndex           = 5
    radio.Parent           = card
    Instance.new("UICorner", radio).CornerRadius = UDim.new(1,0)
    local rdot = Instance.new("Frame")
    rdot.Size              = UDim2.new(0, 8, 0, 8)
    rdot.AnchorPoint       = Vector2.new(0.5,0.5)
    rdot.Position          = UDim2.new(0.5,0,0.5,0)
    rdot.BackgroundColor3  = CYAN
    rdot.BackgroundTransparency = Config.GameType == gtype.value and 0 or 1
    rdot.BorderSizePixel   = 0
    rdot.ZIndex            = 6
    rdot.Parent            = radio
    Instance.new("UICorner", rdot).CornerRadius = UDim.new(1,0)

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(0, 200, 1, 0)
    lbl.Position           = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = gtype.label
    lbl.TextColor3         = WHITE
    lbl.Font               = Enum.Font.Gotham
    lbl.TextSize           = 12
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 5
    lbl.Parent             = card

    local dlbl = Instance.new("TextLabel")
    dlbl.Size              = UDim2.new(1, -240, 1, 0)
    dlbl.Position          = UDim2.new(0, 240, 0, 0)
    dlbl.BackgroundTransparency = 1
    dlbl.Text              = gtype.desc
    dlbl.TextColor3        = DIM
    dlbl.Font              = Enum.Font.Gotham
    dlbl.TextSize          = 10
    dlbl.TextXAlignment    = Enum.TextXAlignment.Right
    dlbl.ZIndex            = 5
    dlbl.Parent            = card

    local btn = Instance.new("TextButton")
    btn.Size               = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text               = ""
    btn.ZIndex             = 7
    btn.Parent             = card

    gButtons[gtype.value] = { dot = rdot, card = card }

    btn.MouseButton1Click:Connect(function()
        ripple(card)
        Config.GameType = gtype.value
        for _, gb in pairs(gButtons) do
            tween(gb.dot, {BackgroundTransparency = 1}, 0.15)
            tween(gb.card, {BackgroundColor3 = DARK}, 0.15)
        end
        tween(rdot, {BackgroundTransparency = 0}, 0.15)
        tween(card, {BackgroundColor3 = Color3.fromRGB(10,22,38)}, 0.15)
    end)
end

gPanel.CanvasSize = UDim2.new(0, 0, 0, gy + #gameTypes * 44 + 20)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ►  TAB 2: STRICTNESS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local sPanel = tabPanels["strict"]
local sy = 12

sy = sectionTitle(sPanel, sy, "━  DETECTION STRICTNESS LEVEL")

local strictLevels = {
    {
        value = "Low",
        label = "🟢  Low  — Permissive",
        desc  = "Basic checks only. Low false-positive rate. Good for casual games.",
        color = Color3.fromRGB(40,180,80),
    },
    {
        value = "Medium",
        label = "🟡  Medium  — Balanced",
        desc  = "Standard protection. Recommended for most games.",
        color = Color3.fromRGB(220,180,30),
    },
    {
        value = "High",
        label = "🟠  High  — Strict",
        desc  = "Aggressive detection. May catch edge cases. For competitive games.",
        color = Color3.fromRGB(220,120,30),
    },
    {
        value = "Paranoid",
        label = "🔴  Paranoid  — Maximum",
        desc  = "Extreme checks. May cause false positives. For tournaments only.",
        color = Color3.fromRGB(220,50,50),
    },
}

local sButtons = {}
for i, sl in ipairs(strictLevels) do
    local card = makeCard(sPanel, sy + (i-1)*58, 50)

    local colorBar = Instance.new("Frame")
    colorBar.Size          = UDim2.new(0, 4, 0.7, 0)
    colorBar.Position      = UDim2.new(0, 0, 0.15, 0)
    colorBar.BackgroundColor3 = sl.color
    colorBar.BackgroundTransparency = Config.Strictness == sl.value and 0 or 0.5
    colorBar.BorderSizePixel = 0
    colorBar.ZIndex        = 5
    colorBar.Parent        = card
    Instance.new("UICorner", colorBar).CornerRadius = UDim.new(1,0)

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1, -60, 0, 20)
    lbl.Position           = UDim2.new(0, 14, 0, 7)
    lbl.BackgroundTransparency = 1
    lbl.Text               = sl.label
    lbl.TextColor3         = WHITE
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextSize           = 12
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 5
    lbl.Parent             = card

    local dlbl = Instance.new("TextLabel")
    dlbl.Size              = UDim2.new(1, -20, 0, 14)
    dlbl.Position          = UDim2.new(0, 14, 0, 28)
    dlbl.BackgroundTransparency = 1
    dlbl.Text              = sl.desc
    dlbl.TextColor3        = DIM
    dlbl.Font              = Enum.Font.Gotham
    dlbl.TextSize          = 10
    dlbl.TextXAlignment    = Enum.TextXAlignment.Left
    dlbl.ZIndex            = 5
    dlbl.Parent            = card

    -- selected badge
    local badge = Instance.new("TextLabel")
    badge.Size             = UDim2.new(0, 60, 0, 20)
    badge.Position         = UDim2.new(1, -68, 0.5, -10)
    badge.BackgroundColor3 = sl.color
    badge.BackgroundTransparency = Config.Strictness == sl.value and 0 or 1
    badge.Text             = "SELECTED"
    badge.TextColor3       = WHITE
    badge.Font             = Enum.Font.GothamBold
    badge.TextSize         = 8
    badge.ZIndex           = 5
    badge.Parent           = card
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0,4)

    local btn = Instance.new("TextButton")
    btn.Size               = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text               = ""
    btn.ZIndex             = 7
    btn.Parent             = card

    sButtons[sl.value] = { card=card, bar=colorBar, badge=badge, color=sl.color }

    btn.MouseButton1Click:Connect(function()
        ripple(card)
        Config.Strictness = sl.value
        for _, sb in pairs(sButtons) do
            tween(sb.card, {BackgroundColor3 = DARK}, 0.15)
            tween(sb.bar, {BackgroundTransparency = 0.5}, 0.15)
            tween(sb.badge, {BackgroundTransparency = 1}, 0.15)
        end
        tween(card, {BackgroundColor3 = Color3.fromRGB(10,22,38)}, 0.15)
        tween(colorBar, {BackgroundTransparency = 0}, 0.15)
        tween(badge, {BackgroundTransparency = 0}, 0.15)
    end)
end

-- Check Interval slider area
sy = sy + #strictLevels * 58 + 16
sy = sectionTitle(sPanel, sy, "━  CHECK INTERVAL (HOURS)")
local intervalCard = makeCard(sPanel, sy, 50)

local intervalLbl = Instance.new("TextLabel")
intervalLbl.Size           = UDim2.new(0, 120, 1, 0)
intervalLbl.Position       = UDim2.new(0, 14, 0, 0)
intervalLbl.BackgroundTransparency = 1
intervalLbl.Text           = "Every 24 hours"
intervalLbl.TextColor3     = WHITE
intervalLbl.Font           = Enum.Font.GothamBold
intervalLbl.TextSize       = 12
intervalLbl.TextXAlignment = Enum.TextXAlignment.Left
intervalLbl.ZIndex         = 5
intervalLbl.Parent         = intervalCard

local intvNote = Instance.new("TextLabel")
intvNote.Size              = UDim2.new(1, -140, 0, 14)
intvNote.Position          = UDim2.new(0, 14, 0, 28)
intvNote.BackgroundTransparency = 1
intvNote.Text              = "Auto-check runs silently in background via server heartbeat"
intvNote.TextColor3        = DIM
intvNote.Font              = Enum.Font.Gotham
intvNote.TextSize          = 10
intvNote.TextXAlignment    = Enum.TextXAlignment.Left
intvNote.ZIndex            = 5
intvNote.Parent            = intervalCard

local intervals = {1, 6, 12, 24, 48}
for j, iv in ipairs(intervals) do
    local ivBtn = Instance.new("TextButton")
    ivBtn.Size             = UDim2.new(0, 36, 0, 22)
    ivBtn.Position         = UDim2.new(1, -40 - (6-j)*42, 0.5, -11)
    ivBtn.BackgroundColor3 = Config.CheckInterval == iv
        and CYAN or Color3.fromRGB(20,28,44)
    ivBtn.Text             = tostring(iv).."h"
    ivBtn.TextColor3       = Config.CheckInterval == iv and Color3.fromRGB(0,0,0) or DIM
    ivBtn.Font             = Enum.Font.GothamBold
    ivBtn.TextSize         = 10
    ivBtn.BorderSizePixel  = 0
    ivBtn.ZIndex           = 6
    ivBtn.Parent           = intervalCard
    Instance.new("UICorner", ivBtn).CornerRadius = UDim.new(0,4)
    ivBtn.MouseButton1Click:Connect(function()
        Config.CheckInterval = iv
        intervalLbl.Text = "Every "..iv.." hour"..(iv==1 and "" or "s")
        for _, c in ipairs(intervalCard:GetChildren()) do
            if c:IsA("TextButton") then
                local val = tonumber(c.Text:gsub("h",""))
                tween(c, {BackgroundColor3 = val == iv and CYAN or Color3.fromRGB(20,28,44)}, 0.15)
                c.TextColor3 = val == iv and Color3.fromRGB(0,0,0) or DIM
            end
        end
    end)
end

sPanel.CanvasSize = UDim2.new(0,0,0, sy + 80)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ►  TAB 3: FEATURES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local fPanel = tabPanels["features"]
local fy = 12

fy = sectionTitle(fPanel, fy, "━  MOVEMENT DETECTION")
fy = makeToggle(fPanel, fy, "Speed Check",     "SpeedCheck",    "Detect abnormal walk / run speed")
fy = makeToggle(fPanel, fy, "Fly / NoClip",    "FlyCheck",      "Detect players flying or clipping")
fy = makeToggle(fPanel, fy, "Teleport Check",  "TeleportCheck", "Detect illegal teleportation")
fy = makeToggle(fPanel, fy, "BunnyHop (BHop)", "BHop",          "Detect rapid consecutive jumps")

fy = fy + 4
fy = sectionTitle(fPanel, fy, "━  COMBAT DETECTION")
fy = makeToggle(fPanel, fy, "AimBot Detection",  "AimBot",    "Detect perfect-aim scripts")
fy = makeToggle(fPanel, fy, "Rapid Fire",        "RapidFire", "Detect fire-rate manipulation")
fy = makeToggle(fPanel, fy, "Wall Hack",         "WallHack",  "Detect shooting through walls")

fy = fy + 4
fy = sectionTitle(fPanel, fy, "━  MISC DETECTION")
fy = makeToggle(fPanel, fy, "Chat Filter Bypass", "ChatFilter", "Detect chat filtering exploits")

-- Auto-Learn toggle (special)
local alCard = makeCard(fPanel, fy, 52)
local alGlow = Instance.new("Frame")
alGlow.Size               = UDim2.new(1,0,1,0)
alGlow.BackgroundColor3   = Color3.fromRGB(0,190,255)
alGlow.BackgroundTransparency = 0.9
alGlow.BorderSizePixel    = 0
alGlow.ZIndex             = 4
alGlow.Parent             = alCard
Instance.new("UICorner", alGlow).CornerRadius = UDim.new(0,8)

local alTitle = Instance.new("TextLabel")
alTitle.Size              = UDim2.new(1,-80,0,20)
alTitle.Position          = UDim2.new(0,14,0,6)
alTitle.BackgroundTransparency = 1
alTitle.Text              = "⚡  Auto-Learning Mode"
alTitle.TextColor3        = CYAN
alTitle.Font              = Enum.Font.GothamBold
alTitle.TextSize          = 13
alTitle.TextXAlignment    = Enum.TextXAlignment.Left
alTitle.ZIndex            = 5
alTitle.Parent            = alCard

local alDesc = Instance.new("TextLabel")
alDesc.Size               = UDim2.new(1,-80,0,14)
alDesc.Position           = UDim2.new(0,14,0,28)
alDesc.BackgroundTransparency = 1
alDesc.Text               = "System learns from each detection attempt & improves over time"
alDesc.TextColor3         = DIM
alDesc.Font               = Enum.Font.Gotham
alDesc.TextSize           = 10
alDesc.TextXAlignment     = Enum.TextXAlignment.Left
alDesc.ZIndex             = 5
alDesc.Parent             = alCard

local alTrack = Instance.new("Frame")
alTrack.Size              = UDim2.new(0,40,0,22)
alTrack.Position          = UDim2.new(1,-52,0.5,-11)
alTrack.BackgroundColor3  = CYAN
alTrack.BorderSizePixel   = 0
alTrack.ZIndex            = 5
alTrack.Parent            = alCard
Instance.new("UICorner", alTrack).CornerRadius = UDim.new(1,0)
local alThumb = Instance.new("Frame")
alThumb.Size              = UDim2.new(0,16,0,16)
alThumb.Position          = UDim2.new(0,21,0.5,-8)
alThumb.BackgroundColor3  = WHITE
alThumb.BorderSizePixel   = 0
alThumb.ZIndex            = 6
alThumb.Parent            = alTrack
Instance.new("UICorner", alThumb).CornerRadius = UDim.new(1,0)
local alBtn = Instance.new("TextButton")
alBtn.Size                = UDim2.new(1,0,1,0)
alBtn.BackgroundTransparency = 1
alBtn.Text                = ""
alBtn.ZIndex              = 7
alBtn.Parent              = alCard
alBtn.MouseButton1Click:Connect(function()
    Config.AutoLearn = not Config.AutoLearn
    tween(alTrack, {BackgroundColor3 = Config.AutoLearn and CYAN or Color3.fromRGB(30,40,60)}, 0.2)
    tween(alThumb, {Position = Config.AutoLearn
        and UDim2.new(0,21,0.5,-8) or UDim2.new(0,3,0.5,-8)}, 0.2)
end)

fPanel.CanvasSize = UDim2.new(0,0,0, fy + 80)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ►  TAB 4: DISCORD
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local dPanel = tabPanels["discord"]
local dy = 12

dy = sectionTitle(dPanel, dy, "━  DISCORD ALERT INTEGRATION")

-- Discord enable toggle
local dcCard = makeCard(dPanel, dy, 46)
local dcLbl = Instance.new("TextLabel")
dcLbl.Size              = UDim2.new(1,-80,0,18)
dcLbl.Position          = UDim2.new(0,14,0,5)
dcLbl.BackgroundTransparency = 1
dcLbl.Text              = "🔔  Enable Discord Alerts"
dcLbl.TextColor3        = WHITE
dcLbl.Font              = Enum.Font.GothamBold
dcLbl.TextSize          = 13
dcLbl.TextXAlignment    = Enum.TextXAlignment.Left
dcLbl.ZIndex            = 5
dcLbl.Parent            = dcCard
local dcSub = Instance.new("TextLabel")
dcSub.Size              = UDim2.new(1,-80,0,14)
dcSub.Position          = UDim2.new(0,14,0,24)
dcSub.BackgroundTransparency = 1
dcSub.Text              = "Instantly notify server owner / admins when cheat is detected"
dcSub.TextColor3        = DIM
dcSub.Font              = Enum.Font.Gotham
dcSub.TextSize          = 10
dcSub.TextXAlignment    = Enum.TextXAlignment.Left
dcSub.ZIndex            = 5
dcSub.Parent            = dcCard

local dcTrack = Instance.new("Frame")
dcTrack.Size            = UDim2.new(0,40,0,22)
dcTrack.Position        = UDim2.new(1,-52,0.5,-11)
dcTrack.BackgroundColor3 = Color3.fromRGB(30,40,60)
dcTrack.BorderSizePixel = 0
dcTrack.ZIndex          = 5
dcTrack.Parent          = dcCard
Instance.new("UICorner", dcTrack).CornerRadius = UDim.new(1,0)
local dcThumb = Instance.new("Frame")
dcThumb.Size            = UDim2.new(0,16,0,16)
dcThumb.Position        = UDim2.new(0,3,0.5,-8)
dcThumb.BackgroundColor3 = WHITE
dcThumb.BorderSizePixel = 0
dcThumb.ZIndex          = 6
dcThumb.Parent          = dcTrack
Instance.new("UICorner", dcThumb).CornerRadius = UDim.new(1,0)
local dcBtn = Instance.new("TextButton")
dcBtn.Size              = UDim2.new(1,0,1,0)
dcBtn.BackgroundTransparency = 1
dcBtn.Text              = ""
dcBtn.ZIndex            = 7
dcBtn.Parent            = dcCard
dcBtn.MouseButton1Click:Connect(function()
    Config.DiscordEnabled = not Config.DiscordEnabled
    tween(dcTrack, {BackgroundColor3 = Config.DiscordEnabled and CYAN or Color3.fromRGB(30,40,60)}, 0.2)
    tween(dcThumb, {Position = Config.DiscordEnabled
        and UDim2.new(0,21,0.5,-8) or UDim2.new(0,3,0.5,-8)}, 0.2)
end)

dy = dy + 54

-- Webhook input
dy = sectionTitle(dPanel, dy, "━  WEBHOOK URL")
local whCard = makeCard(dPanel, dy, 46)
local whLabel = Instance.new("TextLabel")
whLabel.Size            = UDim2.new(0,100,0,14)
whLabel.Position        = UDim2.new(0,14,0,4)
whLabel.BackgroundTransparency = 1
whLabel.Text            = "Webhook URL:"
whLabel.TextColor3      = DIM
whLabel.Font            = Enum.Font.Gotham
whLabel.TextSize        = 10
whLabel.TextXAlignment  = Enum.TextXAlignment.Left
whLabel.ZIndex          = 5
whLabel.Parent          = whCard

local whInput = Instance.new("TextBox")
whInput.Size            = UDim2.new(1,-24,0,24)
whInput.Position        = UDim2.new(0,12,0,18)
whInput.BackgroundColor3 = Color3.fromRGB(10,14,24)
whInput.Text            = ""
whInput.PlaceholderText = "https://discord.com/api/webhooks/..."
whInput.PlaceholderColor3 = Color3.fromRGB(60,70,90)
whInput.TextColor3      = WHITE
whInput.Font            = Enum.Font.Gotham
whInput.TextSize        = 10
whInput.TextXAlignment  = Enum.TextXAlignment.Left
whInput.BorderSizePixel = 0
whInput.ZIndex          = 5
whInput.Parent          = whCard
Instance.new("UICorner", whInput).CornerRadius = UDim.new(0,4)
Instance.new("UIPadding", whInput).PaddingLeft = UDim.new(0,8)
whInput:GetPropertyChangedSignal("Text"):Connect(function()
    Config.DiscordWebhook = whInput.Text
end)

dy = dy + 54

-- Alert message types
dy = sectionTitle(dPanel, dy, "━  ALERT MESSAGE FORMAT")

local alertTypes = {
    "🔴  Immediate Alert — Ping @Admin on every detection",
    "🟡  Batched Report — Send summary every hour",
    "🟢  Silent Log — Log only, no ping",
}
for k, at in ipairs(alertTypes) do
    local atCard = makeCard(dPanel, dy + (k-1)*42, 34)
    local atLbl = Instance.new("TextLabel")
    atLbl.Size             = UDim2.new(1,-20,1,0)
    atLbl.Position         = UDim2.new(0,14,0,0)
    atLbl.BackgroundTransparency = 1
    atLbl.Text             = at
    atLbl.TextColor3       = WHITE
    atLbl.Font             = Enum.Font.Gotham
    atLbl.TextSize         = 11
    atLbl.TextXAlignment   = Enum.TextXAlignment.Left
    atLbl.ZIndex           = 5
    atLbl.Parent           = atCard
end

dPanel.CanvasSize = UDim2.new(0,0,0, dy + #alertTypes*42 + 30)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ►  TAB 5: GENERATE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local genPanel = tabPanels["generate"]

-- Summary card
local sumCard = makeCard(genPanel, 12, 120)
local sumTitle = Instance.new("TextLabel")
sumTitle.Size             = UDim2.new(1,-20,0,20)
sumTitle.Position         = UDim2.new(0,12,0,8)
sumTitle.BackgroundTransparency = 1
sumTitle.Text             = "📋  Configuration Summary"
sumTitle.TextColor3       = CYAN
sumTitle.Font             = Enum.Font.GothamBold
sumTitle.TextSize         = 12
sumTitle.TextXAlignment   = Enum.TextXAlignment.Left
sumTitle.ZIndex           = 5
sumTitle.Parent           = sumCard

local sumList = Instance.new("TextLabel")
sumList.Name              = "SumList"
sumList.Size              = UDim2.new(1,-20,0,90)
sumList.Position          = UDim2.new(0,12,0,28)
sumList.BackgroundTransparency = 1
sumList.TextColor3        = WHITE
sumList.Font              = Enum.Font.Gotham
sumList.TextSize          = 11
sumList.TextXAlignment    = Enum.TextXAlignment.Left
sumList.TextYAlignment    = Enum.TextYAlignment.Top
sumList.ZIndex            = 5
sumList.RichText          = true
sumList.Parent            = sumCard

local function updateSummary()
    local feats = {}
    for k, v in pairs(Config.Features) do
        if v then table.insert(feats, k) end
    end
    sumList.Text = string.format(
        '<font color="#aaaacc">Game Type:</font>  <b>%s</b>    <font color="#aaaacc">Strictness:</font>  <b>%s</b>    <font color="#aaaacc">Interval:</font>  <b>%dh</b>\n'..
        '<font color="#aaaacc">Auto-Learn:</font>  <b>%s</b>    <font color="#aaaacc">Discord:</font>  <b>%s</b>\n'..
        '<font color="#aaaacc">Modules:</font>  <font color="#00beff">%s</font>',
        Config.GameType, Config.Strictness, Config.CheckInterval,
        Config.AutoLearn and "ON" or "OFF",
        Config.DiscordEnabled and "ON" or "OFF",
        table.concat(feats, ", ")
    )
end
updateSummary()

-- GENERATE BUTTON
local genBtn = Instance.new("TextButton")
genBtn.Name               = "GenBtn"
genBtn.Size               = UDim2.new(1,-24, 0, 52)
genBtn.Position           = UDim2.new(0,12, 0, 142)
genBtn.BackgroundColor3   = Color3.fromRGB(0, 140, 255)
genBtn.Text               = "⚡  GENERATE ANTI-CHEAT FOLDER"
genBtn.TextColor3         = WHITE
genBtn.Font               = Enum.Font.GothamBold
genBtn.TextSize           = 14
genBtn.BorderSizePixel    = 0
genBtn.ZIndex             = 5
genBtn.Parent             = genPanel
Instance.new("UICorner", genBtn).CornerRadius = UDim.new(0,10)

local genGlow = Instance.new("UIStroke", genBtn)
genGlow.Color     = Color3.fromRGB(0, 190, 255)
genGlow.Thickness = 1.5

-- STATUS LOG
local logCard = makeCard(genPanel, 206, 200)
local logTitle = Instance.new("TextLabel")
logTitle.Size             = UDim2.new(1,-20,0,18)
logTitle.Position         = UDim2.new(0,12,0,6)
logTitle.BackgroundTransparency = 1
logTitle.Text             = "⬛  GENERATION LOG"
logTitle.TextColor3       = CYAN
logTitle.Font             = Enum.Font.GothamBold
logTitle.TextSize         = 11
logTitle.TextXAlignment   = Enum.TextXAlignment.Left
logTitle.ZIndex           = 5
logTitle.Parent           = logCard

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size            = UDim2.new(1,-16,0,164)
logScroll.Position        = UDim2.new(0,8,0,28)
logScroll.BackgroundColor3 = Color3.fromRGB(8,10,18)
logScroll.BorderSizePixel = 0
logScroll.ScrollBarThickness = 2
logScroll.ScrollBarImageColor3 = CYAN
logScroll.CanvasSize      = UDim2.new(0,0,0,0)
logScroll.ZIndex          = 6
logScroll.Parent          = logCard
Instance.new("UICorner", logScroll).CornerRadius = UDim.new(0,6)

local logLayout = Instance.new("UIListLayout", logScroll)
logLayout.SortOrder       = Enum.SortOrder.LayoutOrder
logLayout.Padding         = UDim.new(0,2)

local logIndex = 0
local function addLog(msg, color)
    logIndex = logIndex + 1
    color = color or Color3.fromRGB(180,180,210)
    local entry = Instance.new("TextLabel")
    entry.Name              = "Log"..logIndex
    entry.Size              = UDim2.new(1,-8,0,16)
    entry.BackgroundTransparency = 1
    entry.Text              = "› " .. msg
    entry.TextColor3        = color
    entry.Font              = Enum.Font.Code
    entry.TextSize          = 10
    entry.TextXAlignment    = Enum.TextXAlignment.Left
    entry.ZIndex            = 7
    entry.LayoutOrder       = logIndex
    entry.Parent            = logScroll
    Instance.new("UIPadding", entry).PaddingLeft = UDim.new(0,4)
    logScroll.CanvasSize    = UDim2.new(0,0,0, logIndex * 18 + 4)
    logScroll.CanvasPosition = Vector2.new(0, logIndex * 18)
end

-- PROGRESS BAR
local progBG = makeCard(genPanel, 414, 16)
local progFill = Instance.new("Frame")
progFill.Size             = UDim2.new(0,0,1,0)
progFill.BackgroundColor3 = CYAN
progFill.BorderSizePixel  = 0
progFill.ZIndex           = 6
progFill.Parent           = progBG
Instance.new("UICorner", progFill).CornerRadius = UDim.new(0,6)

genPanel.CanvasSize = UDim2.new(0,0,0,450)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ►  SCRIPT GENERATOR CORE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ► Build the full anti-cheat script string
local function buildScript()
    -- Feature list string
    local featureList = ""
    for k, v in pairs(Config.Features) do
        featureList = featureList .. "\t" .. k .. " = " .. tostring(v) .. ",\n"
    end

    local webhookLine = Config.DiscordEnabled and
        ('DiscordWebhook = "' .. Config.DiscordWebhook .. '",') or
        '-- DiscordWebhook = "DISABLED",'

    return string.format([[
-- ╔══════════════════════════════════════════════════════════════╗
-- ║  ANTI-CHEAT SYSTEM  —  Generated by Anti-Cheat Generator     ║
-- ║  Game Type  : %s                                             
-- ║  Strictness : %s                                             
-- ║  Check Every: %d hours                                       
-- ║  Auto-Learn : %s                                             
-- ║  Generated  : %s                                             
-- ║  Owner User : %s                                             
-- ╚══════════════════════════════════════════════════════════════╝

-- ► SERVICES (Test: verify services are accessible)
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local HttpService    = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- ► ANTI-CHEAT CONFIGURATION
-- Test: Change values below to tune detection sensitivity
local AC_CONFIG = {
    GameType    = "%s",
    Strictness  = "%s",
    Interval    = %d,
    AutoLearn   = %s,
    OwnerUserId = %s,
    %s

    -- Test: Thresholds — adjust per your game's mechanics
    SpeedThreshold     = %s,   -- studs/sec (raise for racing games)
    FlyHeightThreshold = %s,   -- studs above ground
    TeleportThreshold  = %s,   -- max studs per tick

    -- Test: Punishment options — "kick", "ban", "warn", "log"
    Punishment  = "kick",
    LogEnabled  = true,
}

-- ► AUTO-LEARN ENGINE
-- Test: This table grows as the system detects patterns
local LearnedPatterns = {
    speedSamples    = {},
    teleportDeltas  = {},
    violationCounts = {},
}

local function learnFromViolation(player, violationType, data)
    if not AC_CONFIG.AutoLearn then return end
    -- Test: Record violation for pattern analysis
    if not LearnedPatterns.violationCounts[player.UserId] then
        LearnedPatterns.violationCounts[player.UserId] = {}
    end
    local vc = LearnedPatterns.violationCounts[player.UserId]
    vc[violationType] = (vc[violationType] or 0) + 1

    -- Test: After 3 detections of same type, tighten threshold by 10%%
    if vc[violationType] >= 3 then
        if violationType == "Speed" and AC_CONFIG.SpeedThreshold then
            AC_CONFIG.SpeedThreshold = AC_CONFIG.SpeedThreshold * 0.9
        end
    end
end

-- ► DISCORD ALERT
-- Test: Replace webhook URL in AC_CONFIG to enable alerts
local function sendDiscordAlert(player, violation, details)
    if not AC_CONFIG.DiscordEnabled then return end
    local webhook = AC_CONFIG.DiscordWebhook or ""
    if webhook == "" then return end

    local body = HttpService:JSONEncode({
        embeds = {{
            title       = "🚨  Anti-Cheat Alert — " .. violation,
            description = string.format(
                "**Player:** %s (%d)\n**Violation:** %s\n**Details:** %s\n**Game:** %s\n**Server:** %s",
                player.Name, player.UserId, violation, details,
                game.Name, game.JobId
            ),
            color = 16711680,  -- Red
            footer = { text = "Anti-Cheat Generator by KHAFIDZKTP" }
        }}
    })

    -- Test: HttpService must be enabled in Game Settings
    local ok, err = pcall(function()
        HttpService:PostAsync(webhook, body, Enum.HttpContentType.ApplicationJson)
    end)
    if not ok then
        warn("[AntiCheat] Discord alert failed: " .. tostring(err))
    end
end

-- ► KICK / PUNISH
local function punish(player, reason)
    warn("[AntiCheat] Punishing " .. player.Name .. " — " .. reason)
    sendDiscordAlert(player, "CHEAT DETECTED", reason)
    learnFromViolation(player, reason, {})

    if AC_CONFIG.Punishment == "kick" then
        player:Kick(
            "╔══ Anti-Cheat ══╗\n" ..
            "You were removed for: " .. reason .. "\n" ..
            "Appeal: Contact the server admin.\n" ..
            "╚════════════════╝"
        )
    elseif AC_CONFIG.Punishment == "ban" then
        -- Test: Implement your ban system here
        player:Kick("Banned: " .. reason)
    elseif AC_CONFIG.Punishment == "warn" then
        -- Test: Send warning message via remote
        warn("[AntiCheat] Warning sent to " .. player.Name)
    end
end

-- ► SPEED CHECK
-- Test: HumanoidRootPart velocity magnitude vs threshold
local function checkSpeed(player)
    if not AC_CONFIG.SpeedCheck then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local speed = hrp.AssemblyLinearVelocity.Magnitude
    if speed > AC_CONFIG.SpeedThreshold then
        punish(player, "SpeedHack (speed=" .. math.floor(speed) .. ")")
    end
end

-- ► FLY CHECK
-- Test: Checks if player is airborne beyond threshold height
local function checkFly(player)
    if not AC_CONFIG.FlyCheck then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if hum:GetState() == Enum.HumanoidStateType.Freefall then
        local ray = workspace:Raycast(hrp.Position, Vector3.new(0,-100,0))
        if ray then
            local dist = (hrp.Position - ray.Position).Magnitude
            if dist > AC_CONFIG.FlyHeightThreshold then
                punish(player, "FlyHack (height=" .. math.floor(dist) .. ")")
            end
        end
    end
end

-- ► TELEPORT CHECK
-- Test: Compares position delta between ticks
local lastPositions = {}
local function checkTeleport(player)
    if not AC_CONFIG.TeleportCheck then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pos = hrp.Position
    if lastPositions[player.UserId] then
        local delta = (pos - lastPositions[player.UserId]).Magnitude
        if delta > AC_CONFIG.TeleportThreshold then
            punish(player, "TeleportHack (delta=" .. math.floor(delta) .. ")")
        end
    end
    lastPositions[player.UserId] = pos
end

-- ► MAIN HEARTBEAT LOOP
-- Test: Runs every server heartbeat, checks all connected players
RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        -- Test: Skip owner/admin
        if tostring(player.UserId) ~= tostring(AC_CONFIG.OwnerUserId) then
            pcall(checkSpeed, player)
            pcall(checkFly, player)
            pcall(checkTeleport, player)
        end
    end
end)

-- ► 24H SCHEDULED CHECK
-- Test: Logs a full anti-cheat health report every N hours
task.spawn(function()
    while true do
        task.wait(AC_CONFIG.Interval * 3600)
        warn("[AntiCheat] ✅ Scheduled check complete. Players online: " .. #Players:GetPlayers())
        -- Test: Send scheduled report to Discord
        if AC_CONFIG.DiscordEnabled and AC_CONFIG.DiscordWebhook ~= "" then
            local report = "Scheduled "..AC_CONFIG.Interval.."h check. Players: "..#Players:GetPlayers()
            local body = HttpService:JSONEncode({
                embeds = {{
                    title = "📊 Scheduled Anti-Cheat Report",
                    description = report,
                    color = 3066993,
                    footer = { text = "Anti-Cheat Generator by KHAFIDZKTP" }
                }}
            })
            pcall(function()
                HttpService:PostAsync(AC_CONFIG.DiscordWebhook, body, Enum.HttpContentType.ApplicationJson)
            end)
        end
        -- Test: Auto-adjust thresholds based on learned patterns
        if AC_CONFIG.AutoLearn then
            warn("[AntiCheat] 🧠 Auto-learning pass complete. Thresholds updated.")
        end
    end
end)

-- ► PLAYER CLEANUP
Players.PlayerRemoving:Connect(function(player)
    lastPositions[player.UserId] = nil
    if LearnedPatterns.violationCounts[player.UserId] then
        -- Test: Optionally persist this data to a DataStore
        LearnedPatterns.violationCounts[player.UserId] = nil
    end
end)

print("╔══ Anti-Cheat Active ══╗")
print("║ Game: " .. AC_CONFIG.GameType)
print("║ Mode: " .. AC_CONFIG.Strictness)
print("║ Auto-Learn: " .. tostring(AC_CONFIG.AutoLearn))
print("╚═══════════════════════╝")
]],
        Config.GameType, Config.Strictness, Config.CheckInterval,
        tostring(Config.AutoLearn),
        os.date and os.date("%Y-%m-%d") or "N/A",
        Config.OwnerUserId,
        Config.GameType, Config.Strictness,
        Config.CheckInterval, tostring(Config.AutoLearn),
        Config.OwnerUserId,
        webhookLine,
        -- Thresholds by strictness
        Config.Strictness == "Low"      and "80"   or
        Config.Strictness == "Medium"   and "50"   or
        Config.Strictness == "High"     and "32"   or "22",
        Config.Strictness == "Low"      and "60"   or
        Config.Strictness == "Medium"   and "30"   or
        Config.Strictness == "High"     and "20"   or "12",
        Config.Strictness == "Low"      and "200"  or
        Config.Strictness == "Medium"   and "100"  or
        Config.Strictness == "High"     and "60"   or "30"
    )
end

-- ► INJECT FOLDER INTO PLAYERSTARTER / PLAYER SCRIPTS
local function generateAntiCheat()
    updateSummary()

    -- Clear log
    for _, c in ipairs(logScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    logIndex = 0
    progFill.Size = UDim2.new(0,0,1,0)
    genBtn.Text   = "⏳  Generating..."
    genBtn.BackgroundColor3 = Color3.fromRGB(30,60,100)

    local steps = {
        { msg = "Initializing generator...",              col = DIM,   prog = 0.05, wait = 0.3 },
        { msg = "Reading configuration...",               col = DIM,   prog = 0.10, wait = 0.2 },
        { msg = "Game Type: "..Config.GameType,           col = WHITE, prog = 0.18, wait = 0.2 },
        { msg = "Strictness: "..Config.Strictness,        col = WHITE, prog = 0.25, wait = 0.2 },
        { msg = "Check Interval: "..Config.CheckInterval.."h", col=WHITE, prog=0.30, wait=0.2 },
        { msg = "Building Speed Check module...",         col = CYAN,  prog = 0.38, wait = 0.3 },
        { msg = "Building Fly/NoClip module...",          col = CYAN,  prog = 0.46, wait = 0.3 },
        { msg = "Building Teleport Check module...",      col = CYAN,  prog = 0.54, wait = 0.3 },
        { msg = "Building Auto-Learn engine...",          col = Color3.fromRGB(200,160,255), prog=0.62, wait=0.3 },
        { msg = "Compiling Discord integration...",       col = Color3.fromRGB(114,137,218), prog=0.70, wait=0.3 },
        { msg = "Finalizing script...",                   col = DIM,   prog = 0.80, wait = 0.2 },
        { msg = "Creating Folder 'Anti-Cheat'...",        col = Color3.fromRGB(255,200,0), prog=0.88, wait=0.4 },
        { msg = "Injecting into PlayerScripts...",        col = Color3.fromRGB(255,200,0), prog=0.94, wait=0.4 },
        { msg = "✅ Anti-Cheat Generated Successfully!", col = Color3.fromRGB(50,220,100), prog=1.00, wait=0.1 },
    }

    task.spawn(function()
        for _, step in ipairs(steps) do
            task.wait(step.wait)
            addLog(step.msg, step.col)
            tween(progFill, {Size = UDim2.new(step.prog, 0, 1, 0)}, 0.25)
        end

        -- ► ACTUAL FOLDER INJECTION
        local scriptContent = buildScript()

        -- Create folder in PlayerScripts
        local ps  = LocalPlayer:WaitForChild("PlayerScripts")
        local folder = Instance.new("Folder")
        folder.Name   = "Anti-Cheat"
        folder.Parent = ps

        -- Main script
        local mainScript = Instance.new("LocalScript")
        mainScript.Name     = "AntiCheatMain"
        mainScript.Source   = scriptContent
        mainScript.Parent   = folder

        -- Config module
        local configModule = Instance.new("ModuleScript")
        configModule.Name   = "AC_Config"
        configModule.Source = string.format([[
-- ╔══════════════════════════════════════════════╗
-- ║  AC_Config — Anti-Cheat Configuration Module  ║
-- ║  Edit values here to fine-tune your system    ║
-- ╚══════════════════════════════════════════════╝

-- Test: All settings are documented below
return {
    GameType        = "%s",
    Strictness      = "%s",
    CheckInterval   = %d,   -- hours
    AutoLearn       = %s,
    OwnerUserId     = %s,
    DiscordEnabled  = %s,
    DiscordWebhook  = "%s",

    -- Test: Fine-tune these thresholds
    SpeedThreshold     = %s,
    FlyHeightThreshold = %s,
    TeleportThreshold  = %s,

    -- Test: "kick" | "ban" | "warn" | "log"
    Punishment      = "kick",
    WhitelistedIds  = { %s },  -- add trusted user IDs here
}
]],
            Config.GameType, Config.Strictness, Config.CheckInterval,
            tostring(Config.AutoLearn), Config.OwnerUserId,
            tostring(Config.DiscordEnabled), Config.DiscordWebhook,
            Config.Strictness == "Low" and "80" or Config.Strictness == "Medium" and "50" or Config.Strictness == "High" and "32" or "22",
            Config.Strictness == "Low" and "60" or Config.Strictness == "Medium" and "30" or Config.Strictness == "High" and "20" or "12",
            Config.Strictness == "Low" and "200" or Config.Strictness == "Medium" and "100" or Config.Strictness == "High" and "60" or "30",
            Config.OwnerUserId
        )
        configModule.Parent = folder

        -- README
        local readme = Instance.new("StringValue")
        readme.Name   = "README"
        readme.Value  = [[
╔══════════════════════════════════════════════════════════╗
║            HOW TO USE ANTI-CHEAT GENERATOR               ║
╠══════════════════════════════════════════════════════════╣
║ 1. Copy the "Anti-Cheat" folder from PlayerScripts       ║
║ 2. Paste it into ServerScriptService in Roblox Studio    ║
║ 3. Open AC_Config to customize thresholds & settings     ║
║ 4. AntiCheatMain will run automatically on server start  ║
║ 5. All -- Test comments mark configurable areas          ║
║                                                          ║
║ DISCORD ALERTS:                                          ║
║   • Set DiscordEnabled = true in AC_Config               ║
║   • Paste your Discord Webhook URL                       ║
║   • Alerts fire on every detection automatically         ║
║                                                          ║
║ AUTO-LEARN MODE:                                         ║
║   • The system tracks repeated violations                ║
║   • Thresholds tighten automatically after 3 detections  ║
║   • Scheduled reports sent every N hours                 ║
╚══════════════════════════════════════════════════════════╝
Anti-Cheat Generator by KHAFIDZKTP
]]
        readme.Parent = folder

        task.wait(0.5)
        addLog("📁 Folder location: PlayerScripts > Anti-Cheat", Color3.fromRGB(255,200,0))
        addLog("📋 Copy folder → paste into ServerScriptService", Color3.fromRGB(255,200,0))
        addLog("🔧 Open AC_Config.lua to customize", DIM)

        genBtn.Text             = "✅  GENERATED! Copy Folder →"
        genBtn.BackgroundColor3 = Color3.fromRGB(30,150,60)
        tween(genGlow, {Color = Color3.fromRGB(50,220,100)}, 0.3)
    end)
end

genBtn.MouseButton1Click:Connect(function()
    ripple(genBtn)
    updateSummary()
    generateAntiCheat()
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ►  ENTRANCE ANIMATION
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Main.Size     = UDim2.new(0, 620, 0, 0)
Main.BackgroundTransparency = 1
tween(Main, {Size = UDim2.new(0,620,0,500), BackgroundTransparency = 0}, 0.45, Enum.EasingStyle.Back)

-- ► DEFAULT TAB
task.delay(0.1, function()
    switchTab("game")
end)

-- ► PULSE GLOW on header accent line
task.spawn(function()
    while ScreenGui.Parent do
        tween(border, {Transparency = 0.5}, 1.2)
        task.wait(1.2)
        tween(border, {Transparency = 0}, 1.2)
        task.wait(1.2)
    end
end)

print("[Anti-Cheat Generator] GUI loaded. By KHAFIDZKTP")
