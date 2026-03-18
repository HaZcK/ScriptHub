-- 🌙 SkyMoon ScriptHub | Mainscript.lua
-- by KHAFIDZKTP | github.com/HaZcK/ScriptHub

local RAW_PLACELIST  = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/PlaceList.json"
local RAW_UNIVERSAL  = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/Universal.json"
local ALL_TOOLS_URL  = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/All_tools.lua"
local UBUNTU_LOGO_URL = "https://tkj.smkdarmasiswasidoarjo.sch.id/wp-content/uploads/2024/08/61ef634e-0b5f-4d27-9fb6-c64d526c595c.png"
local GETKEY_URL = "https://hazck.github.io/ScriptHub/"
local RealBuilder_URL = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/Real_Builder.lua" -- ganti URL ini

-- Forward declarations
local openScriptList
local openMiniCmd
local showNotifSimple
local openAdminAuth
local openAdminPanel
local openMainHub
local openConsole

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ScreenGui
local sg = Instance.new("ScreenGui")
sg.Name = "SkyMoon_Hub"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() sg.Parent = game.CoreGui end)
if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end

----------------------------------------------------
-- LOADING SCREEN
----------------------------------------------------
local loadSg = Instance.new("ScreenGui")
loadSg.Name = "SkyMoon_Loading"
loadSg.ResetOnSpawn = false
loadSg.IgnoreGuiInset = true
loadSg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadSg.DisplayOrder = 9999
pcall(function() loadSg.Parent = game.CoreGui end)
if not loadSg.Parent then loadSg.Parent = LocalPlayer.PlayerGui end

local loadBg = Instance.new("Frame", loadSg)
loadBg.Size = UDim2.new(1, 0, 1, 0)
loadBg.BackgroundColor3 = Color3.fromRGB(4, 4, 10)
loadBg.BorderSizePixel = 0
loadBg.ZIndex = 100

-- Subtle grid background
local gridFrame = Instance.new("Frame", loadBg)
gridFrame.Size = UDim2.new(1, 0, 1, 0)
gridFrame.BackgroundTransparency = 1
gridFrame.BorderSizePixel = 0
gridFrame.ZIndex = 101
do
    for i = 0, 20 do
        local line = Instance.new("Frame", gridFrame)
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 0, i * 40)
        line.BackgroundColor3 = Color3.fromRGB(20, 15, 45)
        line.BackgroundTransparency = 0.7
        line.BorderSizePixel = 0
    end
    for i = 0, 30 do
        local line = Instance.new("Frame", gridFrame)
        line.Size = UDim2.new(0, 1, 1, 0)
        line.Position = UDim2.new(0, i * 50, 0, 0)
        line.BackgroundColor3 = Color3.fromRGB(20, 15, 45)
        line.BackgroundTransparency = 0.7
        line.BorderSizePixel = 0
    end
end

-- Center container
local loadCenter = Instance.new("Frame", loadBg)
loadCenter.Size = UDim2.new(0, 280, 0, 220)
loadCenter.Position = UDim2.new(0.5, -140, 0.5, -110)
loadCenter.BackgroundTransparency = 1
loadCenter.BorderSizePixel = 0
loadCenter.ZIndex = 102

-- Spinning ring (outer)
local ringOuter = Instance.new("ImageLabel", loadCenter)
ringOuter.Size = UDim2.new(0, 90, 0, 90)
ringOuter.Position = UDim2.new(0.5, -45, 0, 0)
ringOuter.BackgroundTransparency = 1
ringOuter.Image = "rbxassetid://6031094678" -- ring/circle image
ringOuter.ImageColor3 = Color3.fromRGB(110, 70, 255)
ringOuter.ImageTransparency = 0.2
ringOuter.ZIndex = 103

-- Spinning ring (inner)
local ringInner = Instance.new("ImageLabel", loadCenter)
ringInner.Size = UDim2.new(0, 60, 0, 60)
ringInner.Position = UDim2.new(0.5, -30, 0, 15)
ringInner.BackgroundTransparency = 1
ringInner.Image = "rbxassetid://6031094678"
ringInner.ImageColor3 = Color3.fromRGB(0, 200, 170)
ringInner.ImageTransparency = 0.4
ringInner.ZIndex = 103

-- Moon icon
local moonIcon = Instance.new("TextLabel", loadCenter)
moonIcon.Size = UDim2.new(0, 90, 0, 90)
moonIcon.Position = UDim2.new(0.5, -45, 0, 0)
moonIcon.BackgroundTransparency = 1
moonIcon.Text = "🌙"
moonIcon.Font = Enum.Font.GothamBold
moonIcon.TextSize = 34
moonIcon.ZIndex = 104

-- Title
local loadTitle = Instance.new("TextLabel", loadCenter)
loadTitle.Size = UDim2.new(1, 0, 0, 32)
loadTitle.Position = UDim2.new(0, 0, 0, 96)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "SKYMOON"
loadTitle.Font = Enum.Font.GothamBold
loadTitle.TextSize = 22
loadTitle.TextColor3 = Color3.fromRGB(160, 130, 255)
loadTitle.ZIndex = 103

-- Subtitle
local loadSub = Instance.new("TextLabel", loadCenter)
loadSub.Size = UDim2.new(1, 0, 0, 18)
loadSub.Position = UDim2.new(0, 0, 0, 126)
loadSub.BackgroundTransparency = 1
loadSub.Text = "SCRIPT HUB  ·  BY KHAFIDZKTP"
loadSub.Font = Enum.Font.GothamBold
loadSub.TextSize = 9
loadSub.TextColor3 = Color3.fromRGB(60, 50, 100)
loadSub.ZIndex = 103

-- Progress bar background
local loadBarBg = Instance.new("Frame", loadCenter)
loadBarBg.Size = UDim2.new(1, 0, 0, 4)
loadBarBg.Position = UDim2.new(0, 0, 0, 154)
loadBarBg.BackgroundColor3 = Color3.fromRGB(20, 15, 40)
loadBarBg.BorderSizePixel = 0
loadBarBg.ZIndex = 103
Instance.new("UICorner", loadBarBg).CornerRadius = UDim.new(0, 2)

local loadBarFill = Instance.new("Frame", loadBarBg)
loadBarFill.Size = UDim2.new(0, 0, 1, 0)
loadBarFill.BackgroundColor3 = Color3.fromRGB(110, 70, 255)
loadBarFill.BorderSizePixel = 0
loadBarFill.ZIndex = 104
Instance.new("UICorner", loadBarFill).CornerRadius = UDim.new(0, 2)

local barGrad = Instance.new("UIGradient", loadBarFill)
barGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 60, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 180)),
})

-- Status text
local loadStatus = Instance.new("TextLabel", loadCenter)
loadStatus.Size = UDim2.new(1, 0, 0, 16)
loadStatus.Position = UDim2.new(0, 0, 0, 162)
loadStatus.BackgroundTransparency = 1
loadStatus.Text = "Initializing..."
loadStatus.Font = Enum.Font.Code
loadStatus.TextSize = 10
loadStatus.TextColor3 = Color3.fromRGB(70, 60, 110)
loadStatus.ZIndex = 103

-- Version
local loadVer = Instance.new("TextLabel", loadBg)
loadVer.Size = UDim2.new(0, 200, 0, 16)
loadVer.Position = UDim2.new(1, -208, 1, -24)
loadVer.BackgroundTransparency = 1
loadVer.Text = "v2.0  ·  github.com/HaZcK/ScriptHub"
loadVer.Font = Enum.Font.Code
loadVer.TextSize = 9
loadVer.TextColor3 = Color3.fromRGB(40, 35, 70)
loadVer.ZIndex = 102

-- Ring spin animations
local spinConn = RunService.RenderStepped:Connect(function(dt)
    ringOuter.Rotation = ringOuter.Rotation + 80 * dt
    ringInner.Rotation = ringInner.Rotation - 120 * dt
end)

-- Loading steps
local LOAD_STEPS = {
    {pct = 0.12, msg = "Loading modules..."},
    {pct = 0.28, msg = "Connecting to ScriptHub..."},
    {pct = 0.45, msg = "Fetching game database..."},
    {pct = 0.62, msg = "Verifying key memory..."},
    {pct = 0.78, msg = "Preparing executor..."},
    {pct = 0.90, msg = "Almost ready..."},
    {pct = 1.00, msg = "Done!"},
}

local function runLoadingSequence(onComplete)
    local totalTime = 2.8
    local stepTime = totalTime / #LOAD_STEPS
    for _, step in ipairs(LOAD_STEPS) do
        loadStatus.Text = step.msg
        TweenService:Create(loadBarFill, TweenInfo.new(stepTime * 0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(step.pct, 0, 1, 0)
        }):Play()
        task.wait(stepTime)
    end
    -- Fade out
    task.wait(0.2)
    TweenService:Create(loadBg, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(loadCenter, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -140, 0.4, -110)
    }):Play()
    task.wait(0.55)
    spinConn:Disconnect()
    loadSg:Destroy()
    onComplete()
end
local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0, 300, 0, 160)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -80)
mainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

-- Gradient overlay
local grad = Instance.new("UIGradient", mainFrame)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,  Color3.fromRGB(22, 18, 40)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(12, 14, 30)),
    ColorSequenceKeypoint.new(1,  Color3.fromRGB(8,  12, 24)),
})
grad.Rotation = 145

-- Glowing border (accent color mix)
local outerStroke = Instance.new("UIStroke", mainFrame)
outerStroke.Color = Color3.fromRGB(80, 60, 200)
outerStroke.Thickness = 1.5
outerStroke.Transparency = 0.2

-- Accent line on top
local accentLine = Instance.new("Frame", mainFrame)
accentLine.Size = UDim2.new(0.6, 0, 0, 2)
accentLine.Position = UDim2.new(0.2, 0, 0, 0)
accentLine.BackgroundColor3 = Color3.fromRGB(110, 80, 255)
accentLine.BorderSizePixel = 0
local accentGrad = Instance.new("UIGradient", accentLine)
accentGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80,60,255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160,80,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,200,180)),
})

-- Titlebar
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundTransparency = 1
titleBar.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🌙  S K Y M O O N"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
local titleGrad = Instance.new("UIGradient", titleLabel)
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180,160,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100,220,200)),
})
titleGrad.Rotation = 0

-- Version badge
local verBadge = Instance.new("Frame", titleBar)
verBadge.Size = UDim2.new(0, 44, 0, 18)
verBadge.Position = UDim2.new(1, -52, 0.5, -9)
verBadge.BackgroundColor3 = Color3.fromRGB(60, 40, 120)
verBadge.BackgroundTransparency = 0
verBadge.BorderSizePixel = 0
Instance.new("UICorner", verBadge).CornerRadius = UDim.new(0, 9)
local verLbl = Instance.new("TextLabel", verBadge)
verLbl.Size = UDim2.new(1, 0, 1, 0)
verLbl.BackgroundTransparency = 1
verLbl.Text = "v2.0"
verLbl.Font = Enum.Font.GothamBold
verLbl.TextSize = 9
verLbl.TextColor3 = Color3.fromRGB(200, 180, 255)

-- Divider with glow
local divider = Instance.new("Frame", mainFrame)
divider.Size = UDim2.new(1, -32, 0, 1)
divider.Position = UDim2.new(0, 16, 0, 44)
divider.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
divider.BorderSizePixel = 0
divider.BackgroundTransparency = 0.5
local divGrad = Instance.new("UIGradient", divider)
divGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(120,80,255)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(60,200,180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
})

-- Sub label
local subLabel = Instance.new("TextLabel", mainFrame)
subLabel.Size = UDim2.new(1, -32, 0, 18)
subLabel.Position = UDim2.new(0, 16, 0, 50)
subLabel.BackgroundTransparency = 1
subLabel.Text = "Script Hub  ·  Game Executor  ·  KHAFIDZKTP"
subLabel.TextColor3 = Color3.fromRGB(70, 60, 110)
subLabel.Font = Enum.Font.Gotham
subLabel.TextSize = 9
subLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Scan button (pill style)
local scanBtn = Instance.new("TextButton", mainFrame)
scanBtn.Size = UDim2.new(0, 160, 0, 36)
scanBtn.Position = UDim2.new(0.5, -80, 0, 78)
scanBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 150)
scanBtn.BorderSizePixel = 0
scanBtn.Text = "⟳  Scan Game"
scanBtn.TextColor3 = Color3.fromRGB(230, 220, 255)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 13
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 18)

local btnGrad = Instance.new("UIGradient", scanBtn)
btnGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 60, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 200)),
})
btnGrad.Rotation = 135

local btnStroke = Instance.new("UIStroke", scanBtn)
btnStroke.Color = Color3.fromRGB(140, 100, 255)
btnStroke.Thickness = 1
btnStroke.Transparency = 0.4

scanBtn.MouseEnter:Connect(function()
    TweenService:Create(scanBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(90, 60, 190),
        Size = UDim2.new(0, 166, 0, 36)
    }):Play()
    TweenService:Create(scanBtn, TweenInfo.new(0.15), {Position = UDim2.new(0.5, -83, 0, 78)}):Play()
end)
scanBtn.MouseLeave:Connect(function()
    TweenService:Create(scanBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(60, 40, 150),
        Size = UDim2.new(0, 160, 0, 36)
    }):Play()
    TweenService:Create(scanBtn, TweenInfo.new(0.15), {Position = UDim2.new(0.5, -80, 0, 78)}):Play()
end)

-- Bottom status strip
local statusStrip = Instance.new("Frame", mainFrame)
statusStrip.Size = UDim2.new(1, 0, 0, 24)
statusStrip.Position = UDim2.new(0, 0, 1, -24)
statusStrip.BackgroundColor3 = Color3.fromRGB(6, 6, 14)
statusStrip.BackgroundTransparency = 0
statusStrip.BorderSizePixel = 0
Instance.new("UICorner", statusStrip).CornerRadius = UDim.new(0, 16)
local stripFix = Instance.new("Frame", statusStrip)
stripFix.Size = UDim2.new(1, 0, 0.5, 0)
stripFix.BackgroundColor3 = Color3.fromRGB(6, 6, 14)
stripFix.BorderSizePixel = 0
local stripLbl = Instance.new("TextLabel", statusStrip)
stripLbl.Size = UDim2.new(1, -16, 1, 0)
stripLbl.Position = UDim2.new(0, 8, 0, 0)
stripLbl.BackgroundTransparency = 1
stripLbl.Text = "● Ready  ·  by KHAFIDZKTP"
stripLbl.Font = Enum.Font.Code
stripLbl.TextSize = 9
stripLbl.TextColor3 = Color3.fromRGB(60, 50, 100)
stripLbl.TextXAlignment = Enum.TextXAlignment.Left

----------------------------------------------------
-- SOUND
----------------------------------------------------
local function playKeySound()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://9113145819"
    s.Volume = 0.8
    s.Parent = SoundService
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

----------------------------------------------------
-- CMD FULLSCREEN
----------------------------------------------------
local cmdFrame, output, logoImg

local function createCMD()
    cmdFrame = Instance.new("Frame", sg)
    cmdFrame.Size = UDim2.new(1, 0, 1, 0)
    cmdFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    cmdFrame.BorderSizePixel = 0
    cmdFrame.ZIndex = 10

    local topBar = Instance.new("Frame", cmdFrame)
    topBar.Size = UDim2.new(1, 0, 0, 28)
    topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 11

    local topLabel = Instance.new("TextLabel", topBar)
    topLabel.Size = UDim2.new(1, 0, 1, 0)
    topLabel.BackgroundTransparency = 1
    topLabel.Text = "SkyMoon CMD  —  Administrator"
    topLabel.TextColor3 = Color3.fromRGB(150, 160, 255)
    topLabel.Font = Enum.Font.Code
    topLabel.TextSize = 12
    topLabel.ZIndex = 12

    -- Ubuntu logo (tengah atas)
    logoImg = Instance.new("ImageLabel", cmdFrame)
    logoImg.Size = UDim2.new(0, 80, 0, 80)
    logoImg.Position = UDim2.new(0.5, -40, 0, 34)
    logoImg.BackgroundTransparency = 1
    logoImg.Image = UBUNTU_LOGO_URL
    logoImg.ZIndex = 11

    -- ScrollingFrame sebagai container output
    local scrollFrame = Instance.new("ScrollingFrame", cmdFrame)
    scrollFrame.Size = UDim2.new(1, -20, 1, -130)
    scrollFrame.Position = UDim2.new(0, 10, 0, 124)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 100, 200)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollFrame.ZIndex = 11

    -- TextLabel di dalam ScrollingFrame
    output = Instance.new("TextLabel", scrollFrame)
    output.Size = UDim2.new(1, -6, 0, 0)
    output.AutomaticSize = Enum.AutomaticSize.Y
    output.BackgroundTransparency = 1
    output.Font = Enum.Font.Code
    output.TextSize = 13
    output.TextXAlignment = Enum.TextXAlignment.Left
    output.TextYAlignment = Enum.TextYAlignment.Top
    output.TextWrapped = true
    output.RichText = true
    output.ZIndex = 12
    output.Text = ""

    -- Auto scroll ke bawah tiap teks berubah
    output:GetPropertyChangedSignal("Text"):Connect(function()
        task.defer(function()
            scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.AbsoluteCanvasSize.Y)
        end)
    end)

    return cmdFrame, output
end

----------------------------------------------------
-- TYPING HELPERS
----------------------------------------------------
-- Escape karakter berbahaya untuk RichText
local function escapeRich(str)
    str = str:gsub("&", "and")
    str = str:gsub("<", "[")
    str = str:gsub(">", "]")
    str = str:gsub('"', "'")
    return str
end

-- Lambat (user style) + sound
local function typeText(output, text, color, speed)
    speed = speed or 0.5
    color = color or "ffffff"
    local current = output.Text
    for i = 1, #text do
        local safeChar = escapeRich(text:sub(i, i))
        current = current .. string.format('<font color="#%s">%s</font>', color, safeChar)
        output.Text = current
        playKeySound()
        task.wait(speed)
    end
end

-- Cepat (CMD style)
local function typeTextFast(output, text, color, speed)
    speed = speed or 0.07
    color = color or "00ff88"
    local current = output.Text
    for i = 1, #text do
        local safeChar = escapeRich(text:sub(i, i))
        current = current .. string.format('<font color="#%s">%s</font>', color, safeChar)
        output.Text = current
        task.wait(speed)
    end
end

-- Ultra cepat (scan style) - per baris langsung, bukan per huruf
local function typeTextUltra(output, text, color)
    color = color or "00ff44"
    text = escapeRich(text)
    output.Text = output.Text .. string.format('<font color="#%s">%s</font>', color, text)
    task.wait(0.01)
end

local function newLine(output)
    output.Text = output.Text .. "\n"
end

----------------------------------------------------
-- FETCH PLACELIST (retry 3x)
----------------------------------------------------
local function fetchPlaceList()
    for attempt = 1, 3 do
        local ok, res = pcall(function() return game:HttpGet(RAW_PLACELIST) end)
        if ok and res and res ~= "" then
            local db
            local parseOk = pcall(function() db = HttpService:JSONDecode(res) end)
            if parseOk and db then return db end
        end
        task.wait(1)
    end
    return nil
end

----------------------------------------------------
-- CODEBOX
----------------------------------------------------
local function showCodeBox(db)
    local count = 0
    for _ in pairs(db) do count = count + 1 end

    local box = Instance.new("Frame", cmdFrame)
    box.Size = UDim2.new(0, 440, 0, 42 + (count * 26))
    box.Position = UDim2.new(0.5, -220, 0.5, -((42 + count * 26) / 2))
    box.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    box.BorderSizePixel = 0
    box.ZIndex = 20
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)

    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color = Color3.fromRGB(80, 100, 220)
    boxStroke.Thickness = 1.5

    local header = Instance.new("Frame", box)
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    header.BorderSizePixel = 0
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

    local headerFix = Instance.new("Frame", header)
    headerFix.Size = UDim2.new(1, 0, 0.5, 0)
    headerFix.Position = UDim2.new(0, 0, 0.5, 0)
    headerFix.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    headerFix.BorderSizePixel = 0

    local headerLabel = Instance.new("TextLabel", header)
    headerLabel.Size = UDim2.new(1, -10, 1, 0)
    headerLabel.Position = UDim2.new(0, 10, 0, 0)
    headerLabel.BackgroundTransparency = 1
    headerLabel.Text = "📋  PlaceList — Supported Games"
    headerLabel.TextColor3 = Color3.fromRGB(160, 170, 255)
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.TextSize = 12
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.ZIndex = 21

    local yOffset = 34
    local rowCount = 0
    for placeId, entry in pairs(db) do
        rowCount = rowCount + 1
        local row = Instance.new("Frame", box)
        row.Size = UDim2.new(1, -16, 0, 22)
        row.Position = UDim2.new(0, 8, 0, yOffset)
        row.BackgroundColor3 = rowCount % 2 == 0 and Color3.fromRGB(20, 20, 35) or Color3.fromRGB(16, 16, 28)
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
        row.ZIndex = 21

        local rowText = Instance.new("TextLabel", row)
        rowText.Size = UDim2.new(1, -8, 1, 0)
        rowText.Position = UDim2.new(0, 6, 0, 0)
        rowText.BackgroundTransparency = 1
        rowText.RichText = true
        rowText.Text = string.format(
            '<font color="#6080ff">%s</font>   <font color="#00dd88">%s</font>   <font color="#444466">[SCRIPT PRIVATE]</font>',
            placeId, entry.name
        )
        rowText.Font = Enum.Font.Code
        rowText.TextSize = 12
        rowText.TextXAlignment = Enum.TextXAlignment.Left
        rowText.TextColor3 = Color3.fromRGB(200, 200, 200)
        rowText.ZIndex = 22
        yOffset = yOffset + 26
    end

    task.delay(4, function()
        TweenService:Create(box, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        task.wait(0.4)
        pcall(function() box:Destroy() end)
    end)
end

----------------------------------------------------
-- DUPLICATE GUI DIALOG (pause scan, lanjut setelah pilih)
----------------------------------------------------
local function showDuplicateDialog(guiName, onDone)
    local overlay = Instance.new("Frame", cmdFrame)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 40

    local dialog = Instance.new("Frame", overlay)
    dialog.Size = UDim2.new(0, 360, 0, 160)
    dialog.Position = UDim2.new(0.5, -180, 0.5, -80)
    dialog.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
    dialog.BorderSizePixel = 0
    dialog.ZIndex = 41
    Instance.new("UICorner", dialog).CornerRadius = UDim.new(0, 10)
    local ds = Instance.new("UIStroke", dialog)
    ds.Color = Color3.fromRGB(40, 60, 180)
    ds.Thickness = 1.5

    local function clearDialog()
        for _, c in ipairs(dialog:GetChildren()) do c:Destroy() end
    end

    local function makeButtons(yesText, noText, onYes, onNo)
        local yesBtn = Instance.new("TextButton", dialog)
        yesBtn.Size = UDim2.new(0, 120, 0, 36)
        yesBtn.Position = UDim2.new(0.5, -130, 0, 108)
        yesBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 160)
        yesBtn.Text = yesText
        yesBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
        yesBtn.Font = Enum.Font.GothamBold
        yesBtn.TextSize = 13
        yesBtn.BorderSizePixel = 0
        yesBtn.ZIndex = 42
        Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 6)

        local noBtn = Instance.new("TextButton", dialog)
        noBtn.Size = UDim2.new(0, 120, 0, 36)
        noBtn.Position = UDim2.new(0.5, 10, 0, 108)
        noBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
        noBtn.Text = noText
        noBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
        noBtn.Font = Enum.Font.GothamBold
        noBtn.TextSize = 13
        noBtn.BorderSizePixel = 0
        noBtn.ZIndex = 42
        Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 6)

        yesBtn.MouseButton1Click:Connect(function() yesBtn.Active = false noBtn.Active = false onYes() end)
        noBtn.MouseButton1Click:Connect(function() yesBtn.Active = false noBtn.Active = false onNo() end)
    end

    local function makeLabel(txt)
        local q = Instance.new("TextLabel", dialog)
        q.Size = UDim2.new(1, -20, 0, 100)
        q.Position = UDim2.new(0, 10, 0, 8)
        q.BackgroundTransparency = 1
        q.Text = txt
        q.TextColor3 = Color3.fromRGB(180, 200, 255)
        q.Font = Enum.Font.GothamBold
        q.TextSize = 13
        q.TextWrapped = true
        q.RichText = true
        q.ZIndex = 42
    end

    -- Step 1: Duplicate detected
    clearDialog()
    makeLabel(string.format(
        '<font color="#4466ff">There.Are.Two.Same.Gui</font>\n\n"%s" sudah ada di PlayerGui!\n\nDo.You.Want.To.Duplicate.This.Gui?',
        guiName
    ))
    makeButtons("Yes", "No",
        function()
            -- YES → Step 2: delete old?
            clearDialog()
            makeLabel('<font color="#4466ff">Do.You.Want.Delete.Gui.Old?</font>\n\nHapus GUI lama dan pakai yang baru?')
            makeButtons("Yes", "No",
                function()
                    -- YES → hapus GUI lama
                    pcall(function()
                        local pg = game.Players.LocalPlayer.PlayerGui
                        local old = pg:FindFirstChild(guiName)
                        if old then old:Destroy() end
                    end)
                    overlay:Destroy()
                    onDone() -- lanjut scan
                end,
                function()
                    -- NO → biarkan dua-duanya, lanjut scan
                    overlay:Destroy()
                    onDone()
                end
            )
        end,
        function()
            -- NO di step 1 → lanjut scan tanpa ubah apapun
            overlay:Destroy()
            onDone()
        end
    )
end

----------------------------------------------------
-- WORKSPACE SCAN (dengan duplicate detection, lanjut terus)
----------------------------------------------------
local function scanWorkspace(output, entry)
    local LP = game:GetService("Players").LocalPlayer

    local services = {
        {svc = game:GetService("Workspace"),        label = "Workspace"},
        {svc = game:GetService("ReplicatedStorage"), label = "ReplicatedStorage"},
        {svc = game:GetService("ReplicatedFirst"),   label = "ReplicatedFirst"},
        {svc = game:GetService("StarterGui"),        label = "StarterGui"},
        {svc = game:GetService("StarterPack"),       label = "StarterPack"},
        {svc = game:GetService("StarterPlayer"),     label = "StarterPlayer"},
        {svc = game:GetService("Lighting"),          label = "Lighting"},
        {svc = LP,                                   label = "LocalPlayer"},
    }
    pcall(function()
        table.insert(services, {svc = LP:WaitForChild("PlayerGui", 1), label = "PlayerGui"})
        table.insert(services, {svc = LP:WaitForChild("Backpack", 1),  label = "Backpack"})
    end)

    local allItems = {}
    local function collectItems(parent, depth, parentLabel)
        if depth > 2 then return end
        for _, child in ipairs(parent:GetChildren()) do
            table.insert(allItems, {
                name = child.Name,
                class = child.ClassName,
                depth = depth,
                label = parentLabel,
            })
            -- Model → show name only, do NOT recurse into children
            -- Folder, BasePart, Script → allow recursion
            if not child:IsA("Model") then
                collectItems(child, depth + 1, parentLabel)
            end
        end
    end
    for _, s in ipairs(services) do
        pcall(function() collectItems(s.svc, 0, s.label) end)
    end

    local total = #allItems
    if total == 0 then total = 1 end

    local lineCount = 0
    local i = 0

    local function processNext()
        i = i + 1
        if i > total then return end

        local item = allItems[i]
        local pct = math.floor((i / total) * 100)
        local indent = string.rep("  ", item.depth)
        local line = string.format('%s[KHAFIDZKTP, %s] %s  (%d%%)', indent, item.label, item.name, pct)

        -- Skip default Roblox/system GUIs
        local ROBLOX_DEFAULT_GUIS = {
            "RobloxGui","TopBarApp","ChatApp","EmotesApp","ChatBarParentApp",
            "HealthGui","BackpackGui","PlayerListGui","TouchGui","InspectAndBuyGui",
            "VoiceChatGui","ControlGui","CoreGui","RobloxLoadingGui","BubbleChatScreenGui",
            "ShareGameGui","NotificationGui","LuaApp","screengui","UIEffects",
        }
        if item.class == "ScreenGui" or item.class == "Frame" then
            local isDefault = false
            for _, defName in ipairs(ROBLOX_DEFAULT_GUIS) do
                if item.name == defName or item.name:lower():find("roblox",1,true) then
                    isDefault = true break
                end
            end
            if isDefault then
                i = i + 1
                return
            end
        end

        -- Check for duplicates before displaying
        if entry and item.label == "PlayerGui" and item.class == "ScreenGui" then
            local pg = LP.PlayerGui
            if pg:FindFirstChild(item.name) then
                -- Show detection
                output.Text = output.Text .. string.format(
                    '<font color="#4466ff">[KHAFIDZKTP, PlayerGui] %s  (%d%%) -- DUPLICATE!</font>\n',
                    escapeRich(item.name), pct
                )
                lineCount = lineCount + 1

                -- Pause scan, wait for user choice
                local resumed = false
                showDuplicateDialog(item.name, function()
                    resumed = true
                end)

                -- Wait for dialog to close
                while not resumed do task.wait(0.05) end

                -- Continue to next item
                if i % 10 == 0 then task.wait() end
                return
            end
        end

        -- 4 items per line when many objects share the same parent
        local shortLine = string.format('%s[%s] %s', indent, item.label, item.name)
        if lineCount > 0 and lineCount % 4 ~= 0 then
            -- Append to same line with separator
            local lines = output.Text:split("\n")
            if #lines > 0 then
                lines[#lines] = lines[#lines] .. string.format(
                    '  <font color="#00cc44">%s</font>', escapeRich(item.name)
                )
                output.Text = table.concat(lines, "\n")
            else
                output.Text = output.Text .. string.format('<font color="#00ff44">%s</font>\n', escapeRich(shortLine))
            end
        else
            output.Text = output.Text .. string.format(
                '<font color="#00ff44">%s</font>\n', escapeRich(line)
            )
        end
        lineCount = lineCount + 1

        if lineCount >= 25 then
            output.Text = ""
            lineCount = 0
        end

        if i % 10 == 0 then task.wait() end
    end

    -- Process all items
    for _ = 1, total do
        processNext()
    end

    output.Text = ""
    output.Text = '<font color="#00ffaa">Check_This_Game... 100%</font>\n'
    task.wait(0.3)
end

----------------------------------------------------
-- GLITCH FADE OUT EFFECT
----------------------------------------------------
local glitchChars = {"#","@","!","%","&","*","?","X","█","▓","░"}
local function glitchFadeOut()
    local overlay = Instance.new("Frame", cmdFrame)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 30

    local glitchLabel = Instance.new("TextLabel", overlay)
    glitchLabel.Size = UDim2.new(1, 0, 1, 0)
    glitchLabel.BackgroundTransparency = 1
    glitchLabel.Font = Enum.Font.Code
    glitchLabel.TextSize = 16
    glitchLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    glitchLabel.TextWrapped = true
    glitchLabel.RichText = false
    glitchLabel.ZIndex = 31

    -- Glitch text cycles
    for cycle = 1, 12 do
        local glitchStr = ""
        local lineLen = 40
        local lines = 20
        for l = 1, lines do
            for c = 1, lineLen do
                glitchStr = glitchStr .. glitchChars[math.random(1, #glitchChars)]
            end
            glitchStr = glitchStr .. "\n"
        end
        glitchLabel.Text = glitchStr

        -- Overlay flash
        local alpha = cycle / 12
        TweenService:Create(overlay, TweenInfo.new(0.05), {BackgroundTransparency = 1 - (alpha * 0.6)}):Play()
        task.wait(0.08)
    end

    -- Fade everything out
    TweenService:Create(cmdFrame, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
    TweenService:Create(glitchLabel, TweenInfo.new(0.6), {TextTransparency = 1}):Play()
    task.wait(0.7)
    pcall(function() sg:Destroy() end)
end

----------------------------------------------------
-- HACKER MODE INSTALL SEQUENCE
----------------------------------------------------
local function hackerInstallSequence(output)
    -- Ubuntu header (aman, tanpa karakter berbahaya untuk RichText)
    local ubuntuAscii = {
        "  ================================",
        "   UBUNTU 22.04.3 LTS",
        "   SkyMoon Build - Administrator",
        "  ================================",
        "",
    }

    for _, line in ipairs(ubuntuAscii) do
        typeTextUltra(output, line, "e95420")
        newLine(output)
    end
    task.wait(0.2)

    -- Fake install lines
    local installLines = {
        "Initializing package manager...",
        "Reading package lists... Done",
        "Building dependency tree... Done",
        "Installing SkyMoon-core [########] 100%",
        "Installing executor-bridge [########] 100%",
        "Installing game-detector [########] 100%",
        "Configuring environment... Done",
        "Loading modules... Done",
        "System ready.",
        "",
    }
    for _, line in ipairs(installLines) do
        typeTextUltra(output, line, "00ff88")
        newLine(output)
        task.wait(0.04)
    end
    task.wait(0.2)

    -- Hacker mode random data
    typeTextUltra(output, ">> ENTERING HACKER MODE <<", "ffff00")
    newLine(output)
    task.wait(0.1)

    local countries = {"US","RU","CN","DE","JP","BR","KR","FR","GB","ID","SG","AU"}
    for i = 1, 18 do
        local ip = string.format("%d.%d.%d.%d", math.random(1,255), math.random(0,255), math.random(0,255), math.random(0,255))
        local country = countries[math.random(1, #countries)]
        local status = math.random() > 0.3 and "CONNECTED" or "PING..."
        typeTextUltra(output,
            string.format("[%s]  %-18s  %s", country, ip, status),
            i % 3 == 0 and "ffaa00" or "00ff88"
        )
        newLine(output)
        task.wait(0.03)
    end

    typeTextUltra(output, ">> ACCESS GRANTED <<", "00ffff")
    newLine(output)
    task.wait(0.3)
end

----------------------------------------------------
-- SCAN CLICK
----------------------------------------------------
scanBtn.MouseButton1Click:Connect(function()
    scanBtn.Active = false
    mainFrame.Visible = false

    createCMD()
    task.wait(0.3)

    -- "Cmd" putih → clear → hijau
    typeText(output, "Cmd", "ffffff", 0.5)
    task.wait(0.3)
    output.Text = ""

    -- Ubuntu logo visible, hide after sequence
    task.wait(0.2)

    -- Hacker install sequence
    hackerInstallSequence(output)

    -- Hide logo after install
    pcall(function()
        TweenService:Create(logoImg, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
    end)
    task.wait(0.3)

    -- Executor
    typeTextFast(output, "Executor:;", "00ff88", 0.07)
    newLine(output)

    local execName = "Unknown"
    pcall(function()
        if identifyexecutor then execName = identifyexecutor() end
    end)
    typeTextFast(output, "Executor." .. execName, "00ff88", 0.07)
    newLine(output)
    task.wait(0.3)

    -- Fetch PlaceList + GameId verification
    local db = fetchPlaceList()
    local placeId = tostring(game.PlaceId)
    local entry = db and db[placeId]

    -- If PlaceId doesn't match, check via GameId (handles VoiceChat server teleport)
    -- game.GameId = root game ID, game.PlaceId bisa beda kalau di sub-place
    if not entry and db then
        local gameId = tostring(game.GameId)
        for pid, data in pairs(db) do
            -- Check if place ini bagian dari game yang sama via MarketplaceService
            local ok, info = pcall(function()
                return game:GetService("MarketplaceService"):GetProductInfo(tonumber(pid))
            end)
            if ok and info then
                -- If same game name or creator, treat as same game
                local myInfo = pcall(function()
                    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
                end)
                -- Simple heuristic: cek game root place
                local rootOk, rootPlace = pcall(function()
                    return game:GetService("TeleportService"):GetLocalPlayerTeleportData()
                end)
                -- Use GameId match — if PlaceId is in db and GameId matches
                local testOk, testInfo = pcall(function()
                    return game:GetService("MarketplaceService"):GetProductInfo(tonumber(pid))
                end)
                if testOk and testInfo and testInfo.Creator then
                    local myCreatorOk, myInfo2 = pcall(function()
                        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
                    end)
                    if myCreatorOk and myInfo2 and myInfo2.Creator then
                        if testInfo.Creator.Id == myInfo2.Creator.Id and
                           testInfo.Creator.Name == myInfo2.Creator.Name then
                            entry = data
                            break
                        end
                    end
                end
            end
            if entry then break end
        end
    end

    -- Workspace scan
    typeTextFast(output, "Check_This_Game:;", "00ff88", 0.06)
    newLine(output)
    task.wait(0.2)
    scanWorkspace(output, entry)

    -- CheckList
    typeTextFast(output, "CheckList:;", "00ff88", 0.07)
    newLine(output)
    task.wait(0.2)

    if db then
        showCodeBox(db)
        task.wait(4.5)
    else
        typeTextFast(output, "  > Failed to load list!", "ff4444", 0.05)
        newLine(output)
    end

    -- Support check
    typeTextFast(output, "Run _Support_Script_in_This_Game:;", "00ff88", 0.05)
    newLine(output)
    typeTextFast(output, "ExecuteScript", "00ff88", 0.06)
    newLine(output)
    task.wait(0.5)

    local entry2 = entry

    if not entry2 then
        typeTextFast(output, "This.Game.Not.support!", "ff4444", 0.08)
        newLine(output)
        task.wait(0.3)
        typeTextFast(output, "Loading Universal Scripts...", "ffaa00", 0.06)
        newLine(output)
        task.wait(0.5)
        -- Fade CMD lalu buka Script List
        TweenService:Create(cmdFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        pcall(function() cmdFrame:Destroy() end)
        task.spawn(openScriptList)
    else
        typeTextFast(output, "This.Game.support", "00ff88", 0.07)
        newLine(output)
        task.wait(0.2)
        typeTextFast(output, "Run.The.Script", "00ff88", 0.07)
        task.wait(1.5)

        local scriptOk, scriptRes = pcall(function()
            return game:HttpGet(entry2.script)
        end)
        if scriptOk and scriptRes then
            pcall(loadstring(scriptRes))
        end

        TweenService:Create(cmdFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        pcall(function() sg:Destroy() end)
    end
end)

----------------------------------------------------
-- MEMORY SYSTEM
----------------------------------------------------
local function loadMemory()
    local mem = {executeCount = 0, log = {}}
    pcall(function()
        local raw = readfile and readfile("SkyMoon/memory.json")
        if raw and raw ~= "" then
            mem = HttpService:JSONDecode(raw)
        end
    end)
    return mem
end

local function saveMemory(mem)
    pcall(function()
        if not isfolder("SkyMoon") then makefolder("SkyMoon") end
        writefile("SkyMoon/memory.json", HttpService:JSONEncode(mem))
    end)
end

local function incrementMemory(gameName)
    local mem = loadMemory()
    mem.executeCount = (mem.executeCount or 0) + 1
    table.insert(mem.log, {game = gameName or "Unknown", time = os.time(), count = mem.executeCount})
    if #mem.log > 50 then table.remove(mem.log, 1) end
    saveMemory(mem)
    return mem.executeCount
end

-- Increment memory saat execute
pcall(function()
    local gameName = "Unknown"
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    incrementMemory(gameName)
end)

----------------------------------------------------
-- MINI CMD (/Open_Cmd)
----------------------------------------------------
local miniCmdOpen = false

openMiniCmd = function()
    if miniCmdOpen then return end
    miniCmdOpen = true

    local mem = loadMemory()

    local mSg = Instance.new("ScreenGui")
    mSg.Name = "SkyMoon_MiniCmd"
    mSg.ResetOnSpawn = false
    pcall(function() mSg.Parent = game.CoreGui end)
    if not mSg.Parent then mSg.Parent = game.Players.LocalPlayer.PlayerGui end

    local win = Instance.new("Frame", mSg)
    win.Size = UDim2.new(0, 430, 0, 320)
    win.Position = UDim2.new(0.5, -215, 0.5, -160)
    win.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
    local ws = Instance.new("UIStroke", win)
    ws.Color = Color3.fromRGB(60, 80, 200)
    ws.Thickness = 1.5

    -- Title bar
    local tbar = Instance.new("Frame", win)
    tbar.Size = UDim2.new(1, 0, 0, 28)
    tbar.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    tbar.BorderSizePixel = 0
    Instance.new("UICorner", tbar).CornerRadius = UDim.new(0, 10)
    local tfix = Instance.new("Frame", tbar)
    tfix.Size = UDim2.new(1, 0, 0.5, 0)
    tfix.Position = UDim2.new(0, 0, 0.5, 0)
    tfix.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    tfix.BorderSizePixel = 0

    local tlabel = Instance.new("TextLabel", tbar)
    tlabel.Size = UDim2.new(1, -120, 1, 0)
    tlabel.Position = UDim2.new(0, 10, 0, 0)
    tlabel.BackgroundTransparency = 1
    tlabel.Text = "🌙 SkyMoon CMD"
    tlabel.TextColor3 = Color3.fromRGB(160, 170, 255)
    tlabel.Font = Enum.Font.GothamBold
    tlabel.TextSize = 12
    tlabel.TextXAlignment = Enum.TextXAlignment.Left

    local memLabel = Instance.new("TextLabel", tbar)
    memLabel.Size = UDim2.new(0, 110, 1, 0)
    memLabel.Position = UDim2.new(1, -138, 0, 0)
    memLabel.BackgroundTransparency = 1
    memLabel.Text = "Executes: " .. (mem.executeCount or 0)
    memLabel.TextColor3 = Color3.fromRGB(100, 200, 120)
    memLabel.Font = Enum.Font.Code
    memLabel.TextSize = 11
    memLabel.TextXAlignment = Enum.TextXAlignment.Right

    local closeBtn = Instance.new("TextButton", tbar)
    closeBtn.Size = UDim2.new(0, 24, 0, 20)
    closeBtn.Position = UDim2.new(1, -28, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 11
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    closeBtn.MouseButton1Click:Connect(function()
        miniCmdOpen = false
        mSg:Destroy()
    end)

    -- Output scroll
    local scroll = Instance.new("ScrollingFrame", win)
    scroll.Size = UDim2.new(1, -10, 1, -80)
    scroll.Position = UDim2.new(0, 5, 0, 32)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80,100,200)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y

    local outLabel = Instance.new("TextLabel", scroll)
    outLabel.Size = UDim2.new(1, -6, 0, 0)
    outLabel.AutomaticSize = Enum.AutomaticSize.Y
    outLabel.BackgroundTransparency = 1
    outLabel.Font = Enum.Font.Code
    outLabel.TextSize = 12
    outLabel.TextXAlignment = Enum.TextXAlignment.Left
    outLabel.TextYAlignment = Enum.TextYAlignment.Top
    outLabel.TextWrapped = true
    outLabel.RichText = true
    outLabel.Text = '<font color="#555577">SkyMoon CMD ready.\nUsage: Check In [Username, Folder]\n       Check In [Username, Folder, Object]\n</font>'

    outLabel:GetPropertyChangedSignal("Text"):Connect(function()
        task.defer(function()
            scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
        end)
    end)

    -- Input bar
    local inputBar = Instance.new("Frame", win)
    inputBar.Size = UDim2.new(1, -10, 0, 32)
    inputBar.Position = UDim2.new(0, 5, 1, -38)
    inputBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    inputBar.BorderSizePixel = 0
    Instance.new("UICorner", inputBar).CornerRadius = UDim.new(0, 6)
    local ibs = Instance.new("UIStroke", inputBar)
    ibs.Color = Color3.fromRGB(60, 80, 180)
    ibs.Thickness = 1

    local prompt = Instance.new("TextLabel", inputBar)
    prompt.Size = UDim2.new(0, 26, 1, 0)
    prompt.BackgroundTransparency = 1
    prompt.Text = ">"
    prompt.TextColor3 = Color3.fromRGB(80, 180, 255)
    prompt.Font = Enum.Font.Code
    prompt.TextSize = 13

    local inputBox = Instance.new("TextBox", inputBar)
    inputBox.Size = UDim2.new(1, -30, 1, 0)
    inputBox.Position = UDim2.new(0, 28, 0, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.Text = ""
    inputBox.PlaceholderText = "Check In [Username, Folder, Object?]"
    inputBox.PlaceholderColor3 = Color3.fromRGB(60, 60, 80)
    inputBox.TextColor3 = Color3.fromRGB(200, 210, 255)
    inputBox.Font = Enum.Font.Code
    inputBox.TextSize = 12
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.ClearTextOnFocus = false

    local function appendOut(text, color)
        color = color or "00ff88"
        outLabel.Text = outLabel.Text .. string.format('<font color="#%s">%s</font>\n', color, escapeRich(text))
    end

    -- Show Yes/No buttons (replace inputBar)
    local function showYesNo(onYes, onNo)
        inputBar.Visible = false
        local btnFrame = Instance.new("Frame", win)
        btnFrame.Size = UDim2.new(1, -10, 0, 36)
        btnFrame.Position = UDim2.new(0, 5, 1, -40)
        btnFrame.BackgroundTransparency = 1
        btnFrame.BorderSizePixel = 0

        local yBtn = Instance.new("TextButton", btnFrame)
        yBtn.Size = UDim2.new(0, 120, 0, 30)
        yBtn.Position = UDim2.new(0.5, -130, 0, 3)
        yBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 160)
        yBtn.Text = "Yes"
        yBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
        yBtn.Font = Enum.Font.GothamBold
        yBtn.TextSize = 13
        yBtn.BorderSizePixel = 0
        Instance.new("UICorner", yBtn).CornerRadius = UDim.new(0, 6)

        local nBtn = Instance.new("TextButton", btnFrame)
        nBtn.Size = UDim2.new(0, 120, 0, 30)
        nBtn.Position = UDim2.new(0.5, 10, 0, 3)
        nBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
        nBtn.Text = "No"
        nBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
        nBtn.Font = Enum.Font.GothamBold
        nBtn.TextSize = 13
        nBtn.BorderSizePixel = 0
        Instance.new("UICorner", nBtn).CornerRadius = UDim.new(0, 6)

        yBtn.MouseButton1Click:Connect(function()
            yBtn.Active = false nBtn.Active = false
            btnFrame:Destroy()
            onYes()
        end)
        nBtn.MouseButton1Click:Connect(function()
            yBtn.Active = false nBtn.Active = false
            btnFrame:Destroy()
            onNo()
        end)
    end

    -- Process Check In command
    -- Format: Check In [Folder, SubFolder, ..., TargetName]
    -- No username needed — searches from known services
    local function processCheckIn(cmd)
        local inner = cmd:match("[Cc]heck [Ii]n %[(.-)%]")
        if not inner then
            appendOut("Unknown command.", "ff4444")
            appendOut("Usage: Check In [Folder, SubFolder, ..., Name]", "888888")
            appendOut("Example: Check In [Workspace, Tycoon, Plots, Door]", "555566")
            return
        end

        -- Parse path parts
        local pathParts = {}
        for p in inner:gmatch("[^,]+") do
            local trimmed = p:match("^%s*(.-)%s*$")
            if trimmed ~= "" then table.insert(pathParts, trimmed) end
        end

        if #pathParts < 2 then
            appendOut("Need at least 2 parts: [Service, ObjectName]", "ff4444")
            return
        end

        -- Resolve root service
        local rootName = pathParts[1]
        local targetName = pathParts[#pathParts]
        local midPath = {}
        for i = 2, #pathParts - 1 do table.insert(midPath, pathParts[i]) end

        local serviceMap = {
            Workspace           = workspace,
            ReplicatedStorage   = game:GetService("ReplicatedStorage"),
            ReplicatedFirst     = game:GetService("ReplicatedFirst"),
            StarterGui          = game:GetService("StarterGui"),
            StarterPack         = game:GetService("StarterPack"),
            StarterPlayer       = game:GetService("StarterPlayer"),
            Lighting            = game:GetService("Lighting"),
            Players             = game:GetService("Players"),
            PlayerGui           = LocalPlayer:FindFirstChild("PlayerGui"),
            Backpack            = LocalPlayer:FindFirstChild("Backpack"),
            Character           = LocalPlayer.Character,
        }

        local root = serviceMap[rootName]
        if not root then
            -- Try LocalPlayer children
            pcall(function() root = LocalPlayer:FindFirstChild(rootName) end)
        end
        if not root then
            pcall(function() root = game:GetService(rootName) end)
        end
        if not root then
            appendOut("Service/Folder '" .. rootName .. "' not found!", "ff4444")
            return
        end

        -- Navigate mid path
        local current = root
        for _, part in ipairs(midPath) do
            local found = nil
            pcall(function() found = current:FindFirstChild(part) end)
            if not found then
                appendOut("Path not found: '" .. part .. "' in " .. current.Name, "ff4444")
                return
            end
            current = found
        end

        appendOut(string.format(">> Scanning '%s' in %s ...", targetName,
            rootName .. (#midPath > 0 and "/" .. table.concat(midPath, "/") or "")), "aaaaff")
        task.wait(0.05)

        -- Helper: check if object is a vehicle interior (has VehicleSeat)
        local function isVehicle(obj)
            if not obj:IsA("Model") then return false end
            for _, c in ipairs(obj:GetChildren()) do
                if c:IsA("VehicleSeat") then return true end
            end
            return false
        end

        -- Helper: get "signature" of object for duplicate detection
        local function getSignature(obj)
            local childNames = {}
            pcall(function()
                for _, c in ipairs(obj:GetChildren()) do
                    table.insert(childNames, c.ClassName .. ":" .. c.Name)
                end
            end)
            table.sort(childNames)
            return obj.ClassName .. "|" .. table.concat(childNames, ",")
        end

        -- Collect all matching objects in current
        local matches = {}
        local function collectMatches(parent, depth)
            if depth > 8 then return end
            -- Skip CoreGui
            if parent == game:GetService("CoreGui") then return end

            pcall(function()
                for _, child in ipairs(parent:GetChildren()) do
                    if child.Name == targetName then
                        table.insert(matches, {obj = child, parent = parent, depth = depth})
                    end

                    -- Decide whether to recurse
                    if child:IsA("Model") then
                        if isVehicle(child) then
                            -- Skip vehicle interior
                        else
                            -- Model: recurse but don't show contents in output
                            collectMatches(child, depth + 1)
                        end
                    elseif child:IsA("BaseScript") or child:IsA("ModuleScript") then
                        -- Script: recurse into children (LocalScript can have children)
                        collectMatches(child, depth + 1)
                    elseif child:IsA("Folder") then
                        collectMatches(child, depth + 1)
                    elseif child:IsA("BasePart") then
                        -- Parts: recurse only 1 more level
                        if depth < 5 then collectMatches(child, depth + 1) end
                    end
                end
            end)
        end
        collectMatches(current, 0)

        if #matches == 0 then
            appendOut("Nothing named '" .. targetName .. "' found.", "ff8800")
            return
        end

        outLabel.Text = ""
        appendOut(string.format("Found %d match(es) named '%s':", #matches, targetName), "00ffcc")
        task.wait(0.02)

        -- Group by parent to find same-folder duplicates
        local parentGroups = {}
        for _, m in ipairs(matches) do
            local key = tostring(m.parent)
            if not parentGroups[key] then
                parentGroups[key] = {parent = m.parent, items = {}}
            end
            table.insert(parentGroups[key].items, m)
        end

        -- Process each group
        local function processGroup(group, callback)
            local items = group.items
            local parentObj = group.parent

            -- Check ScreenGui mirror: if in PlayerGui and same exists in CoreGui children → natural, skip
            local function isNaturalGui(obj)
                if not obj:IsA("ScreenGui") then return false end
                local coreGui = game:GetService("CoreGui")
                local inCore = coreGui:FindFirstChild(obj.Name)
                -- If it exists in CoreGui too → it's a mirror, natural
                return inCore ~= nil
            end

            for _, m in ipairs(items) do
                local indent = string.rep("  ", m.depth)
                local path = m.parent.Name .. "/" .. m.obj.Name
                appendOut(string.format("%s[%s] %s  (in: %s)", indent, m.obj.ClassName, m.obj.Name, path), "00ff44")
                task.wait(0.01)
            end

            -- Find same-folder duplicates (same name + same signature)
            if #items >= 2 then
                local sig1 = getSignature(items[1].obj)
                local sig2 = getSignature(items[2].obj)

                if sig1 == sig2 then
                    -- Natural GUI mirror check
                    if isNaturalGui(items[1].obj) then
                        appendOut("  ↳ Same GUI exists in CoreGui mirror — natural, skipping.", "555577")
                        if callback then callback() end
                        return
                    end

                    appendOut("", "ffffff")
                    appendOut(string.format('!! DUPLICATE: 2x "%s" with same contents in %s', targetName, parentObj.Name), "4466ff")
                    appendOut("Do.You.Want.To.Delete.The.New.GUI?", "4466ff")

                    showYesNo(
                        function()
                            -- YES → hapus yang kedua (index 2)
                            pcall(function() items[2].obj:Destroy() end)
                            appendOut("✓ Duplicate removed.", "00ff88")
                            task.wait(0.3)
                            if callback then callback() end
                        end,
                        function()
                            -- NO → lanjut
                            appendOut("Skipped.", "888888")
                            if callback then callback() end
                        end
                    )
                else
                    appendOut(string.format("  ↳ %d items found, contents differ — not a duplicate.", #items), "ffaa44")
                    if callback then callback() end
                end
            else
                if callback then callback() end
            end
        end

        -- Process groups sequentially
        local groupList = {}
        for _, g in pairs(parentGroups) do table.insert(groupList, g) end

        local idx = 0
        local function nextGroup()
            idx = idx + 1
            if idx > #groupList then
                appendOut("✓ Scan complete.", "00ffaa")
                return
            end
            processGroup(groupList[idx], nextGroup)
        end
        nextGroup()
    end

    inputBox.FocusLost:Connect(function(enterPressed)
        if not enterPressed then return end
        local cmd = inputBox.Text
        if cmd == "" then return end
        appendOut("> " .. cmd, "cccccc")
        inputBox.Text = ""

        if cmd:lower() == "runconsole" then
            task.spawn(openConsole)
        else
            task.spawn(processCheckIn, cmd)
        end
    end)
end

----------------------------------------------------
-- NOTIF HELPER (reusable)
----------------------------------------------------
showNotifSimple = function(msg, color)
    local nSg = Instance.new("ScreenGui")
    nSg.Name = "SkyMoon_Notif_Simple"
    nSg.ResetOnSpawn = false
    pcall(function() nSg.Parent = game.CoreGui end)
    if not nSg.Parent then nSg.Parent = game.Players.LocalPlayer.PlayerGui end

    local frame = Instance.new("Frame", nSg)
    frame.Size = UDim2.new(0, 320, 0, 52)
    frame.Position = UDim2.new(0.5, -160, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local fs = Instance.new("UIStroke", frame)
    fs.Color = color or Color3.fromRGB(100, 180, 255)
    fs.Thickness = 1.5

    local accent = Instance.new("Frame", frame)
    accent.Size = UDim2.new(0, 4, 0.7, 0)
    accent.Position = UDim2.new(0, 8, 0.15, 0)
    accent.BackgroundColor3 = color or Color3.fromRGB(100, 180, 255)
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -22, 1, 0)
    lbl.Position = UDim2.new(0, 18, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = msg
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true

    task.delay(3, function()
        TweenService:Create(frame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(lbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        task.wait(0.5)
        pcall(function() nSg:Destroy() end)
    end)
end

----------------------------------------------------
-- UNIVERSAL SCRIPT LIST
----------------------------------------------------
local RAW_UNIVERSAL = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/Universal.json"

openScriptList = function()
    -- Fetch Universal.json
    local uDb = nil
    pcall(function()
        local res = game:HttpGet(RAW_UNIVERSAL)
        uDb = HttpService:JSONDecode(res)
    end)

    local uSg = Instance.new("ScreenGui")
    uSg.Name = "SkyMoon_ScriptList"
    uSg.ResetOnSpawn = false
    pcall(function() uSg.Parent = game.CoreGui end)
    if not uSg.Parent then uSg.Parent = LocalPlayer.PlayerGui end

    -- Main frame
    local frame = Instance.new("Frame", uSg)
    frame.Size = UDim2.new(0, 320, 0, 400)
    frame.Position = UDim2.new(0.5, -160, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local fs = Instance.new("UIStroke", frame)
    fs.Color = Color3.fromRGB(80, 100, 220)
    fs.Thickness = 1.5

    -- Title
    local tbar = Instance.new("Frame", frame)
    tbar.Size = UDim2.new(1, 0, 0, 36)
    tbar.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    tbar.BorderSizePixel = 0
    Instance.new("UICorner", tbar).CornerRadius = UDim.new(0, 12)
    local tfix = Instance.new("Frame", tbar)
    tfix.Size = UDim2.new(1, 0, 0.5, 0)
    tfix.Position = UDim2.new(0, 0, 0.5, 0)
    tfix.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    tfix.BorderSizePixel = 0
    local tlbl = Instance.new("TextLabel", tbar)
    tlbl.Size = UDim2.new(1, -40, 1, 0)
    tlbl.Position = UDim2.new(0, 12, 0, 0)
    tlbl.BackgroundTransparency = 1
    tlbl.Text = "🌙 Universal Script List"
    tlbl.TextColor3 = Color3.fromRGB(180, 190, 255)
    tlbl.Font = Enum.Font.GothamBold
    tlbl.TextSize = 13
    tlbl.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton", tbar)
    closeBtn.Size = UDim2.new(0, 24, 0, 20)
    closeBtn.Position = UDim2.new(1, -28, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 11
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    closeBtn.MouseButton1Click:Connect(function()
        uSg:Destroy()
        pcall(function() sg:Destroy() end)
    end)

    -- Subtitle
    local sub = Instance.new("TextLabel", frame)
    sub.Size = UDim2.new(1, -20, 0, 20)
    sub.Position = UDim2.new(0, 10, 0, 40)
    sub.BackgroundTransparency = 1
    sub.Text = "Game not supported. Pick a universal script:"
    sub.TextColor3 = Color3.fromRGB(120, 130, 180)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left

    -- Scroll list
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -16, 1, -100)
    scroll.Position = UDim2.new(0, 8, 0, 66)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 100, 200)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Status label
    local statusLbl = Instance.new("TextLabel", frame)
    statusLbl.Size = UDim2.new(1, -16, 0, 24)
    statusLbl.Position = UDim2.new(0, 8, 1, -30)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = uDb and ("✅ " .. (function() local c=0 for _ in pairs(uDb) do c=c+1 end return c end)() .. " scripts loaded") or "❌ Failed to load Universal.json"
    statusLbl.TextColor3 = uDb and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(255, 80, 80)
    statusLbl.Font = Enum.Font.Code
    statusLbl.TextSize = 11
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left

    if not uDb then return end

    -- Build script buttons
    local order = 0
    for id, entry in pairs(uDb) do
        order = order + 1
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1, -6, 0, 44)
        btn.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.LayoutOrder = order
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local bs = Instance.new("UIStroke", btn)
        bs.Color = Color3.fromRGB(50, 60, 160)
        bs.Thickness = 1

        local nameLbl = Instance.new("TextLabel", btn)
        nameLbl.Size = UDim2.new(1, -16, 0.6, 0)
        nameLbl.Position = UDim2.new(0, 10, 0, 4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = "▶  " .. entry.name
        nameLbl.TextColor3 = Color3.fromRGB(200, 210, 255)
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 13
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left

        local urlLbl = Instance.new("TextLabel", btn)
        urlLbl.Size = UDim2.new(1, -16, 0.4, 0)
        urlLbl.Position = UDim2.new(0, 10, 0.55, 0)
        urlLbl.BackgroundTransparency = 1
        urlLbl.Text = entry.script:sub(1, 45) .. "..."
        urlLbl.TextColor3 = Color3.fromRGB(70, 80, 120)
        urlLbl.Font = Enum.Font.Code
        urlLbl.TextSize = 10
        urlLbl.TextXAlignment = Enum.TextXAlignment.Left

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 30, 50)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18, 18, 30)}):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            btn.Active = false
            nameLbl.Text = "⏳ Running..."
            nameLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
            local ok, res = pcall(function() return game:HttpGet(entry.script) end)
            if ok and res then pcall(loadstring(res)) end
            nameLbl.Text = "✅ " .. entry.name
            nameLbl.TextColor3 = Color3.fromRGB(80, 220, 120)
            task.wait(2)
            uSg:Destroy()
            pcall(function() sg:Destroy() end)
        end)
    end
end

----------------------------------------------------
-- KEYMOON SYSTEM
----------------------------------------------------


----------------------------------------------------
-- ADMIN PANEL
----------------------------------------------------
local adminOpen = false

openAdminPanel = function()
    if adminOpen then return end
    adminOpen = true

    local aSg = Instance.new("ScreenGui")
    aSg.Name = "SkyMoon_Admin"
    aSg.ResetOnSpawn = false
    pcall(function() aSg.Parent = game.CoreGui end)
    if not aSg.Parent then aSg.Parent = LocalPlayer.PlayerGui end

    -- Main window
    local win = Instance.new("Frame", aSg)
    win.Size = UDim2.new(0, 500, 0, 420)
    win.Position = UDim2.new(0.5, -250, 0.5, -210)
    win.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)
    local ws = Instance.new("UIStroke", win)
    ws.Color = Color3.fromRGB(60, 80, 220)
    ws.Thickness = 1.5

    -- Title bar
    local tbar = Instance.new("Frame", win)
    tbar.Size = UDim2.new(1, 0, 0, 32)
    tbar.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
    tbar.BorderSizePixel = 0
    Instance.new("UICorner", tbar).CornerRadius = UDim.new(0, 12)
    local tfix = Instance.new("Frame", tbar)
    tfix.Size = UDim2.new(1, 0, 0.5, 0)
    tfix.Position = UDim2.new(0, 0, 0.5, 0)
    tfix.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
    tfix.BorderSizePixel = 0
    local tlbl = Instance.new("TextLabel", tbar)
    tlbl.Size = UDim2.new(1, -40, 1, 0)
    tlbl.Position = UDim2.new(0, 12, 0, 0)
    tlbl.BackgroundTransparency = 1
    tlbl.Text = "🌙 SkyMoon Admin Panel"
    tlbl.TextColor3 = Color3.fromRGB(180, 190, 255)
    tlbl.Font = Enum.Font.GothamBold
    tlbl.TextSize = 13
    tlbl.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton", tbar)
    closeBtn.Size = UDim2.new(0, 24, 0, 20)
    closeBtn.Position = UDim2.new(1, -28, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 11
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    closeBtn.MouseButton1Click:Connect(function()
        adminOpen = false
        aSg:Destroy()
    end)

    -- Tab bar
    local tabBar = Instance.new("Frame", win)
    tabBar.Size = UDim2.new(1, -16, 0, 32)
    tabBar.Position = UDim2.new(0, 8, 0, 36)
    tabBar.BackgroundTransparency = 1
    tabBar.BorderSizePixel = 0
    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)

    -- Content area
    local content = Instance.new("Frame", win)
    content.Size = UDim2.new(1, -16, 1, -80)
    content.Position = UDim2.new(0, 8, 0, 72)
    content.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
    content.BorderSizePixel = 0
    Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8)

    local tabs = {}
    local tabFrames = {}
    local activeTab = nil

    local function makeTab(name, icon)
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(0, 88, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        btn.BorderSizePixel = 0
        btn.Text = icon .. " " .. name
        btn.TextColor3 = Color3.fromRGB(140, 150, 200)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local tabContent = Instance.new("ScrollingFrame", content)
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 3
        tabContent.ScrollBarImageColor3 = Color3.fromRGB(60, 80, 180)
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = false
        local cl = Instance.new("UIListLayout", tabContent)
        cl.Padding = UDim.new(0, 4)
        local cp = Instance.new("UIPadding", tabContent)
        cp.PaddingLeft = UDim.new(0, 6)
        cp.PaddingRight = UDim.new(0, 6)
        cp.PaddingTop = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            for _, tf in pairs(tabFrames) do tf.Visible = false end
            for _, tb in pairs(tabs) do
                tb.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
                tb.TextColor3 = Color3.fromRGB(140, 150, 200)
            end
            tabContent.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(40, 60, 180)
            btn.TextColor3 = Color3.fromRGB(220, 230, 255)
            activeTab = name
        end)

        table.insert(tabs, btn)
        table.insert(tabFrames, tabContent)
        return tabContent, btn
    end

    -- Row helper
    local function makeRow(parent, labelText, actionText, color, onClick)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 36)
        row.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -80, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(200, 210, 255)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true

        if actionText then
            local abtn = Instance.new("TextButton", row)
            abtn.Size = UDim2.new(0, 70, 0, 26)
            abtn.Position = UDim2.new(1, -74, 0.5, -13)
            abtn.BackgroundColor3 = color or Color3.fromRGB(30, 60, 160)
            abtn.Text = actionText
            abtn.TextColor3 = Color3.fromRGB(220, 230, 255)
            abtn.Font = Enum.Font.GothamBold
            abtn.TextSize = 11
            abtn.BorderSizePixel = 0
            Instance.new("UICorner", abtn).CornerRadius = UDim.new(0, 5)
            if onClick then
                abtn.MouseButton1Click:Connect(onClick)
            end
        end
        return row, lbl
    end

    -- Input row helper
    local function makeInputRow(parent, labelText, placeholder, btnText, onClick)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 36)
        row.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0, 90, 1, 0)
        lbl.Position = UDim2.new(0, 6, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(160, 170, 220)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local input = Instance.new("TextBox", row)
        input.Size = UDim2.new(1, -170, 0, 24)
        input.Position = UDim2.new(0, 98, 0.5, -12)
        input.BackgroundColor3 = Color3.fromRGB(22, 22, 36)
        input.BorderSizePixel = 0
        input.Text = ""
        input.PlaceholderText = placeholder or ""
        input.PlaceholderColor3 = Color3.fromRGB(60, 60, 90)
        input.TextColor3 = Color3.fromRGB(200, 210, 255)
        input.Font = Enum.Font.Code
        input.TextSize = 11
        input.ClearTextOnFocus = false
        Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)

        local abtn = Instance.new("TextButton", row)
        abtn.Size = UDim2.new(0, 60, 0, 26)
        abtn.Position = UDim2.new(1, -64, 0.5, -13)
        abtn.BackgroundColor3 = Color3.fromRGB(30, 60, 160)
        abtn.Text = btnText or "Run"
        abtn.TextColor3 = Color3.fromRGB(220, 230, 255)
        abtn.Font = Enum.Font.GothamBold
        abtn.TextSize = 11
        abtn.BorderSizePixel = 0
        Instance.new("UICorner", abtn).CornerRadius = UDim.new(0, 5)
        if onClick then
            abtn.MouseButton1Click:Connect(function() onClick(input.Text) end)
        end
        return row, input
    end

    -- ===== TAB 1: PLAYERS =====
    local playersTab, playersBtn = makeTab("Players", "👥")
    local savedPos = nil
    local noClipActive = false
    local noClipConn = nil
    local infJumpConn = nil
    local infJumpActive = false

    local function refreshPlayers()
        for _, c in ipairs(playersTab:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            local char = p.Character
            local hp = char and char:FindFirstChild("Humanoid") and math.floor(char.Humanoid.Health) or 0
            local maxHp = char and char:FindFirstChild("Humanoid") and math.floor(char.Humanoid.MaxHealth) or 100
            local team = p.Team and p.Team.Name or "None"
            makeRow(playersTab,
                string.format("👤 %s  HP:%d/%d  Team:%s", p.Name, hp, maxHp, team),
                "TP", Color3.fromRGB(30, 100, 60),
                function()
                    pcall(function()
                        local myChar = LocalPlayer.Character
                        if myChar and char then
                            myChar.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(3,0,0)
                        end
                    end)
                end
            )
        end
        makeRow(playersTab, "── Static Controls ──", nil, nil, nil)
    end
    refreshPlayers()

    makeRow(playersTab, "🔄 Refresh list", "Run", Color3.fromRGB(60,60,120), refreshPlayers)
    makeRow(playersTab, "💀 Reset my character", "Run", Color3.fromRGB(120,40,40), function()
        pcall(function() LocalPlayer:LoadCharacter() end)
    end)
    makeRow(playersTab, "❤️ God Mode (max HP)", "Run", Color3.fromRGB(30,100,60), function()
        pcall(function()
            LocalPlayer.Character.Humanoid.Health = math.huge
            LocalPlayer.Character.Humanoid.MaxHealth = math.huge
        end)
    end)
    makeRow(playersTab, "🛡️ Anti-AFK (keep alive)", "Run", Color3.fromRGB(40,60,120), function()
        pcall(function()
            local VirtualUser = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
        showNotifSimple("✅ Anti-AFK enabled!", Color3.fromRGB(80,220,120))
    end)
    makeInputRow(playersTab, "Set HP", "100", "Set", function(val)
        local n = tonumber(val)
        if n then pcall(function() LocalPlayer.Character.Humanoid.Health = n end) end
    end)
    makeRow(playersTab, "🪑 Sit down", "Run", Color3.fromRGB(60,40,100), function()
        pcall(function() LocalPlayer.Character.Humanoid.Sit = true end)
    end)
    makeRow(playersTab, "🚶 Stand up", "Run", Color3.fromRGB(60,40,100), function()
        pcall(function() LocalPlayer.Character.Humanoid.Sit = false end)
    end)
    makeRow(playersTab, "📍 Save current position", "Save", Color3.fromRGB(40,80,40), function()
        pcall(function()
            savedPos = LocalPlayer.Character.HumanoidRootPart.CFrame
            showNotifSimple("✅ Position saved!", Color3.fromRGB(80,220,120))
        end)
    end)
    makeRow(playersTab, "📍 Load saved position", "Load", Color3.fromRGB(40,80,40), function()
        if savedPos then
            pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = savedPos end)
        end
    end)
    makeRow(playersTab, "👻 NoClip toggle", "Toggle", Color3.fromRGB(80,40,120), function()
        noClipActive = not noClipActive
        if noClipActive then
            noClipConn = RunService.Stepped:Connect(function()
                if not noClipActive then noClipConn:Disconnect() return end
                pcall(function()
                    for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end)
            end)
        end
        showNotifSimple(noClipActive and "👻 NoClip ON" or "👻 NoClip OFF", Color3.fromRGB(150,100,255))
    end)
    makeRow(playersTab, "🦘 Infinite Jump toggle", "Toggle", Color3.fromRGB(60,40,120), function()
        infJumpActive = not infJumpActive
        if infJumpActive and not infJumpConn then
            infJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                if infJumpActive then
                    pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
                end
            end)
        end
        showNotifSimple(infJumpActive and "🦘 Inf Jump ON" or "🦘 Inf Jump OFF", Color3.fromRGB(100,200,255))
    end)
    makeRow(playersTab, "📋 Print all players", "Print", Color3.fromRGB(40,60,100), function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do table.insert(names, p.Name) end
        showNotifSimple("Players: " .. table.concat(names, ", "), Color3.fromRGB(150,180,255))
    end)
    makeRow(playersTab, "🔢 Player count", "Show", Color3.fromRGB(40,60,100), function()
        showNotifSimple("Players online: " .. #Players:GetPlayers(), Color3.fromRGB(150,180,255))
    end)
    makeRow(playersTab, "── Extra Controls ──", nil, nil, nil)
    makeRow(playersTab, "🎯 Follow nearest player", "Run", Color3.fromRGB(60,30,80), function()
        pcall(function()
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
            local nearest, dist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                    if d < dist then dist=d nearest=p end
                end
            end
            if nearest then
                LocalPlayer.Character.HumanoidRootPart.CFrame = nearest.Character.HumanoidRootPart.CFrame + Vector3.new(3,0,0)
                showNotifSimple("Followed: "..nearest.Name, Color3.fromRGB(150,100,255))
            end
        end)
    end)
    makeRow(playersTab, "🌀 Spin character", "Run", Color3.fromRGB(80,40,80), function()
        task.spawn(function()
            for i=1,36 do
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame =
                        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(10),0)
                end)
                task.wait(0.03)
            end
        end)
    end)
    makeRow(playersTab, "🤸 Ragdoll toggle", "Toggle", Color3.fromRGB(80,40,40), function()
        pcall(function()
            for _, j in ipairs(LocalPlayer.Character:GetDescendants()) do
                if j:IsA("Motor6D") then j.Enabled = not j.Enabled end
            end
        end)
    end)
    makeRow(playersTab, "👁 Invisible (local)", "Run", Color3.fromRGB(40,40,80), function()
        pcall(function()
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.LocalTransparencyModifier = 1 end
            end
        end)
    end)
    makeRow(playersTab, "👁 Visible again", "Run", Color3.fromRGB(40,60,80), function()
        pcall(function()
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
            end
        end)
    end)
    makeRow(playersTab, "⚡ Instant respawn", "Run", Color3.fromRGB(120,60,20), function()
        pcall(function() LocalPlayer:LoadCharacter() end)
    end)
    makeRow(playersTab, "🔒 Freeze character", "Run", Color3.fromRGB(40,60,100), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.Anchored = true
        end)
    end)
    makeRow(playersTab, "🔓 Unfreeze character", "Run", Color3.fromRGB(40,80,60), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.Anchored = false
        end)
    end)
    makeInputRow(playersTab, "Set Name tag", "Display Name", "Set", function(val)
        pcall(function()
            local overhead = LocalPlayer.Character:FindFirstChild("Head")
            if overhead then
                local bg = overhead:FindFirstChildOfClass("BillboardGui") or Instance.new("BillboardGui", overhead)
                bg.Size = UDim2.new(0,100,0,30)
                bg.StudsOffset = Vector3.new(0,2,0)
                local lbl = bg:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel", bg)
                lbl.Size = UDim2.new(1,0,1,0)
                lbl.BackgroundTransparency = 1
                lbl.Text = val
                lbl.TextColor3 = Color3.new(1,1,1)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 14
            end
        end)
    end)
    makeRow(playersTab, "🎨 Random character color", "Run", Color3.fromRGB(80,40,80), function()
        pcall(function()
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Color = Color3.fromHSV(math.random(), 0.8, 0.9)
                end
            end
        end)
    end)
    makeRow(playersTab, "💎 Shiny metallic skin", "Run", Color3.fromRGB(60,60,80), function()
        pcall(function()
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Material = Enum.Material.Metal
                    p.Reflectance = 0.8
                end
            end
        end)
    end)
    makeRow(playersTab, "🌟 Neon skin", "Run", Color3.fromRGB(60,40,100), function()
        pcall(function()
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Material = Enum.Material.Neon
                end
            end
        end)
    end)
    makeRow(playersTab, "🔄 Reset skin to normal", "Run", Color3.fromRGB(60,60,60), function()
        pcall(function()
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Material = Enum.Material.SmoothPlastic
                    p.Reflectance = 0
                    p.LocalTransparencyModifier = 0
                end
            end
        end)
    end)
    makeRow(playersTab, "── Extra 2 ──", nil, nil, nil)
    makeRow(playersTab, "🏋️ Set Humanoid MaxHealth", "Run", Color3.fromRGB(60,40,80), function()
        pcall(function() LocalPlayer.Character.Humanoid.MaxHealth = 1000 LocalPlayer.Character.Humanoid.Health = 1000 end)
        showNotifSimple("MaxHealth = 1000", Color3.fromRGB(80,220,120))
    end)
    makeRow(playersTab, "💀 Set Health to 1", "Run", Color3.fromRGB(120,30,30), function()
        pcall(function() LocalPlayer.Character.Humanoid.Health = 1 end)
    end)
    makeRow(playersTab, "🔇 Mute all sounds", "Run", Color3.fromRGB(40,40,60), function()
        pcall(function()
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") then s.Volume = 0 end
            end
        end)
        showNotifSimple("All sounds muted!", Color3.fromRGB(150,150,255))
    end)
    makeRow(playersTab, "🔊 Unmute all sounds", "Run", Color3.fromRGB(40,60,40), function()
        pcall(function()
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") then s.Volume = 1 end
            end
        end)
    end)
    makeRow(playersTab, "🌈 Rainbow walk effect", "Run", Color3.fromRGB(80,40,80), function()
        task.spawn(function()
            local h = 0
            for _ = 1, 120 do
                pcall(function()
                    for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.Color = Color3.fromHSV(h,0.9,1) end
                    end
                end)
                h = (h + 0.008) % 1
                task.wait(0.05)
            end
        end)
    end)
    makeRow(playersTab, "🔭 Long camera zoom", "Run", Color3.fromRGB(40,60,80), function()
        pcall(function() LocalPlayer.CameraMaxZoomDistance = 500 end)
        showNotifSimple("Camera zoom: 500 studs", Color3.fromRGB(150,180,255))
    end)
    makeRow(playersTab, "📸 First person camera", "Run", Color3.fromRGB(40,60,100), function()
        pcall(function()
            LocalPlayer.CameraMaxZoomDistance = 0.5
            LocalPlayer.CameraMinZoomDistance = 0.5
        end)
    end)
    makeRow(playersTab, "🔙 Reset camera zoom", "Run", Color3.fromRGB(40,60,80), function()
        pcall(function()
            LocalPlayer.CameraMaxZoomDistance = 400
            LocalPlayer.CameraMinZoomDistance = 0.5
        end)
    end)
    makeRow(playersTab, "🎭 Copy character look", "Run", Color3.fromRGB(60,40,60), function()
        pcall(function()
            local userId = LocalPlayer.UserId
            local desc = game:GetService("Players"):GetCharacterAppearanceInfoAsync(userId)
            showNotifSimple("UserID: "..userId, Color3.fromRGB(150,180,255))
        end)
    end)
    makeRow(playersTab, "⏱ Show ping", "Show", Color3.fromRGB(40,60,100), function()
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        showNotifSimple(string.format("Ping: %.0f ms", ping), Color3.fromRGB(150,220,255))
    end)
    makeRow(playersTab, "📊 Show FPS", "Show", Color3.fromRGB(40,60,100), function()
        local fps = math.floor(1/game:GetService("RunService").RenderStepped:Wait())
        showNotifSimple("FPS: "..fps, Color3.fromRGB(150,220,255))
    end)
    makeRow(playersTab, "🚪 Leave game", "Leave", Color3.fromRGB(120,30,30), function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end)

    -- ===== TAB 2: MOVEMENT =====
    local moveTab, moveBtn = makeTab("Move", "🏃")
    local flyActive = false
    local flyConn = nil

    makeInputRow(moveTab, "WalkSpeed", "16", "Set", function(val)
        local n = tonumber(val)
        if n then pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = n end) end
    end)
    makeInputRow(moveTab, "JumpPower", "50", "Set", function(val)
        local n = tonumber(val)
        if n then pcall(function() LocalPlayer.Character.Humanoid.JumpPower = n end) end
    end)
    makeRow(moveTab, "🔁 Reset speed & jump", "Reset", Color3.fromRGB(60,60,100), function()
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end)
    end)
    makeRow(moveTab, "⚡ Speed x2", "Run", Color3.fromRGB(30,80,120), function()
        pcall(function()
            local h = LocalPlayer.Character.Humanoid
            h.WalkSpeed = h.WalkSpeed * 2
        end)
    end)
    makeRow(moveTab, "🐢 Speed /2 (slow)", "Run", Color3.fromRGB(60,60,80), function()
        pcall(function()
            local h = LocalPlayer.Character.Humanoid
            h.WalkSpeed = math.max(1, h.WalkSpeed / 2)
        end)
    end)
    makeRow(moveTab, "🚄 Max Speed (500)", "Run", Color3.fromRGB(30,100,60), function()
        pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 500 end)
    end)
    makeRow(moveTab, "🐌 Slow Motion (speed 3)", "Run", Color3.fromRGB(60,60,80), function()
        pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 3 end)
    end)
    makeRow(moveTab, "🦘 Super Jump (500)", "Run", Color3.fromRGB(30,80,120), function()
        pcall(function() LocalPlayer.Character.Humanoid.JumpPower = 500 end)
    end)
    makeRow(moveTab, "🪂 Low Gravity Jump (200)", "Run", Color3.fromRGB(40,60,100), function()
        pcall(function() LocalPlayer.Character.Humanoid.JumpPower = 200 end)
    end)
    makeRow(moveTab, "🚀 Fly Mode (WASD+Space)", flyActive and "Stop" or "Start",
        Color3.fromRGB(60,40,140), function()
            flyActive = not flyActive
            if flyActive then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bv = Instance.new("BodyVelocity", hrp)
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                    local bg = Instance.new("BodyGyro", hrp)
                    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
                    bg.P = 1e4
                    flyConn = RunService.RenderStepped:Connect(function()
                        if not flyActive then bv:Destroy() bg:Destroy() flyConn:Disconnect() return end
                        local uis = game:GetService("UserInputService")
                        local cam = workspace.CurrentCamera
                        local spd = 40
                        local vel = Vector3.new(0,0,0)
                        if uis:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector*spd end
                        if uis:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector*spd end
                        if uis:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector*spd end
                        if uis:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector*spd end
                        if uis:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,spd,0) end
                        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0,spd,0) end
                        bv.Velocity = vel
                        bg.CFrame = cam.CFrame
                    end)
                end
            end
        end
    )
    makeRow(moveTab, "📷 TP to camera target", "Run", Color3.fromRGB(40,80,80), function()
        pcall(function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0,0,-10)
        end)
    end)
    makeInputRow(moveTab, "Gravity", "196", "Set", function(val)
        local n = tonumber(val)
        if n then workspace.Gravity = n end
    end)
    makeRow(moveTab, "🌍 Reset gravity (196)", "Reset", Color3.fromRGB(60,60,80), function()
        workspace.Gravity = 196
    end)
    makeRow(moveTab, "🌙 Moon gravity (30)", "Run", Color3.fromRGB(40,60,100), function()
        workspace.Gravity = 30
    end)
    makeRow(moveTab, "── Extra Movement ──", nil, nil, nil)
    makeRow(moveTab, "🚀 Launch upward", "Run", Color3.fromRGB(30,80,120), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Velocity = Vector3.new(0,120,0)
            bv.MaxForce = Vector3.new(0,1e6,0)
            game:GetService("Debris"):AddItem(bv, 0.3)
        end)
    end)
    makeRow(moveTab, "💨 Dash forward", "Run", Color3.fromRGB(30,80,100), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Velocity = hrp.CFrame.LookVector * 120
            bv.MaxForce = Vector3.new(1e6,0,1e6)
            game:GetService("Debris"):AddItem(bv, 0.25)
        end)
    end)
    makeRow(moveTab, "🌀 Zero gravity (0)", "Run", Color3.fromRGB(40,40,80), function()
        workspace.Gravity = 0
    end)
    makeRow(moveTab, "🪐 Heavy gravity (600)", "Run", Color3.fromRGB(80,40,20), function()
        workspace.Gravity = 600
    end)
    makeRow(moveTab, "🏊 Swim speed (200)", "Run", Color3.fromRGB(20,60,80), function()
        pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 200 end)
    end)
    makeRow(moveTab, "🐇 Bunny hop speed (80)", "Run", Color3.fromRGB(40,80,40), function()
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = 80
            LocalPlayer.Character.Humanoid.JumpPower = 120
        end)
    end)
    makeRow(moveTab, "🧊 Ice physics (no friction)", "Run", Color3.fromRGB(60,80,100), function()
        pcall(function()
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CustomPhysicalProperties = PhysicalProperties.new(0.3,0,0,0,0)
                end
            end
        end)
    end)
    makeRow(moveTab, "🔄 Reset physics", "Run", Color3.fromRGB(60,60,60), function()
        pcall(function()
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CustomPhysicalProperties = PhysicalProperties.new(Enum.Material.SmoothPlastic) end
            end
        end)
    end)
    makeInputRow(moveTab, "Speed preset", "16/50/100/200", "Set", function(val)
        local n = tonumber(val)
        if n then pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = n end) end
    end)
    makeRow(moveTab, "🏄 Slide (speed+noclip)", "Run", Color3.fromRGB(40,60,100), function()
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = 60
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end)
    makeRow(moveTab, "🎯 Lock rotation", "Run", Color3.fromRGB(60,40,60), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local bg = Instance.new("BodyGyro", hrp)
            bg.MaxTorque = Vector3.new(1e6,0,1e6)
            bg.CFrame = hrp.CFrame
        end)
    end)
    makeRow(moveTab, "🔓 Unlock rotation", "Run", Color3.fromRGB(40,60,40), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            for _, v in ipairs(hrp:GetChildren()) do
                if v:IsA("BodyGyro") then v:Destroy() end
            end
        end)
    end)
    makeRow(moveTab, "📡 Print velocity", "Print", Color3.fromRGB(40,60,100), function()
        pcall(function()
            local v = LocalPlayer.Character.HumanoidRootPart.Velocity
            showNotifSimple(string.format("Vel: %.1f,%.1f,%.1f | Mag:%.1f",v.X,v.Y,v.Z,v.Magnitude), Color3.fromRGB(150,180,255))
        end)
    end)
    makeRow(moveTab, "── Extra 2 ──", nil, nil, nil)
    makeRow(moveTab, "🏊 Swim mode (low gravity + speed)", "Run", Color3.fromRGB(20,60,80), function()
        pcall(function()
            workspace.Gravity = 50
            LocalPlayer.Character.Humanoid.WalkSpeed = 28
        end)
    end)
    makeRow(moveTab, "🚁 Hover (gravity=0 + speed 1)", "Run", Color3.fromRGB(40,60,80), function()
        pcall(function()
            workspace.Gravity = 0
            LocalPlayer.Character.Humanoid.WalkSpeed = 1
        end)
    end)
    makeRow(moveTab, "⚽ Ball physics (speed + no friction)", "Run", Color3.fromRGB(60,60,80), function()
        pcall(function()
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CustomPhysicalProperties = PhysicalProperties.new(0.1,0,0,0,0) end
            end
            LocalPlayer.Character.Humanoid.WalkSpeed = 50
        end)
    end)
    makeRow(moveTab, "🔄 Auto-spin (loop rotate)", "Toggle", Color3.fromRGB(80,40,80), function()
        task.spawn(function()
            for _ = 1, 200 do
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame =
                        LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(5), 0)
                end)
                task.wait(0.03)
            end
        end)
    end)
    makeRow(moveTab, "💨 Speed burst (+100 for 2s)", "Run", Color3.fromRGB(30,80,60), function()
        pcall(function()
            local h = LocalPlayer.Character.Humanoid
            local orig = h.WalkSpeed
            h.WalkSpeed = orig + 100
            task.wait(2)
            h.WalkSpeed = orig
        end)
    end)
    makeInputRow(moveTab, "Jump Height (JumpHeight)", "7.2", "Set", function(val)
        local n = tonumber(val)
        if n then pcall(function() LocalPlayer.Character.Humanoid.JumpHeight = n end) end
    end)
    makeRow(moveTab, "🌊 Wave walk effect", "Run", Color3.fromRGB(20,60,100), function()
        task.spawn(function()
            local t = 0
            for _ = 1, 100 do
                pcall(function()
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    hrp.CFrame = hrp.CFrame + Vector3.new(0, math.sin(t) * 0.3, 0)
                    t = t + 0.3
                end)
                task.wait(0.05)
            end
        end)
    end)
    makeRow(moveTab, "🧲 Attract to nearest player", "Run", Color3.fromRGB(60,30,80), function()
        pcall(function()
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
            local nearest, dist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                    if d < dist then dist=d nearest=p end
                end
            end
            if nearest then
                local bv = Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart)
                local dir = (nearest.Character.HumanoidRootPart.Position - myPos).Unit
                bv.Velocity = dir * 80
                bv.MaxForce = Vector3.new(1e6,1e6,1e6)
                game:GetService("Debris"):AddItem(bv, 0.4)
            end
        end)
    end)
    makeRow(moveTab, "🏔️ Climb speed x3", "Run", Color3.fromRGB(60,40,40), function()
        pcall(function() LocalPlayer.Character.Humanoid.ClimbSpeed = LocalPlayer.Character.Humanoid.ClimbSpeed * 3 end)
    end)
    makeRow(moveTab, "🔁 Teleport every 3s (loop x5)", "Run", Color3.fromRGB(80,40,60), function()
        task.spawn(function()
            for _ = 1, 5 do
                pcall(function()
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local cam = workspace.CurrentCamera
                    hrp.CFrame = cam.CFrame * CFrame.new(0,0,-20)
                end)
                task.wait(3)
            end
        end)
    end)
    makeRow(moveTab, "📐 Print position XYZ", "Print", Color3.fromRGB(40,60,100), function()
        pcall(function()
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            showNotifSimple(string.format("X:%.1f Y:%.1f Z:%.1f",pos.X,pos.Y,pos.Z), Color3.fromRGB(150,180,255))
        end)
    end)

    -- ===== TAB 3: BUILD =====
    local buildTab, buildBtn = makeTab("Build", "🔧")
    local partColors = {"Really red","Bright blue","Lime green","Bright yellow","Hot pink","White","Dark orange","Cyan","Magenta"}
    local spawnedParts = {}

    local function spawnPart(shape, material, size, extraFn)
        pcall(function()
            local p = Instance.new("Part")
            if shape then p.Shape = shape end
            p.Size = size or Vector3.new(4,4,4)
            p.BrickColor = BrickColor.new(partColors[math.random(1,#partColors)])
            p.Material = material or Enum.Material.SmoothPlastic
            p.Anchored = true
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            p.CFrame = hrp and hrp.CFrame + Vector3.new(0,5,-6) or CFrame.new(0,10,0)
            p.Parent = workspace
            if extraFn then extraFn(p) end
            table.insert(spawnedParts, p)
        end)
    end

    makeRow(buildTab, "🔥 Real Builder — Full Studio Mode", "Run", Color3.fromRGB(0, 100, 180), function()
        showNotifSimple("⏳ Loading Real Builder...", Color3.fromRGB(100,180,255))
        task.spawn(function()
            local ok, res = pcall(function()
                return game:HttpGet(RealBuilder_URL)
            end)
            if not ok then
                showNotifSimple("❌ HttpGet failed: " .. tostring(res):sub(1,40), Color3.fromRGB(255,80,80))
                return
            end
            if not res or res == "" then
                showNotifSimple("❌ Empty response from Real Builder URL", Color3.fromRGB(255,80,80))
                return
            end
            local fn, err = loadstring(res)
            if not fn then
                showNotifSimple("❌ Parse error: " .. tostring(err):sub(1,50), Color3.fromRGB(255,80,80))
                return
            end
            local runOk, runErr = pcall(fn)
            if not runOk then
                showNotifSimple("❌ Run error: " .. tostring(runErr):sub(1,50), Color3.fromRGB(255,80,80))
            end
        end)
    end)
    makeRow(buildTab, "── Spawn Objects ──", nil, nil, nil)
    makeRow(buildTab, "🔵 Spawn Sphere Ball", "Spawn", Color3.fromRGB(30,80,60), function() spawnPart(Enum.PartType.Ball, nil, nil) end)
    makeRow(buildTab, "🔺 Spawn Wedge", "Spawn", Color3.fromRGB(30,80,60), function() spawnPart(Enum.PartType.Wedge, nil, nil) end)
    makeRow(buildTab, "🟩 Spawn Big Block (10x1x10)", "Spawn", Color3.fromRGB(30,80,60), function() spawnPart(nil, nil, Vector3.new(10,1,10)) end)
    makeRow(buildTab, "🔦 Spawn Neon Part", "Spawn", Color3.fromRGB(80,60,30), function()
        spawnPart(nil, Enum.Material.Neon, nil)
    end)
    makeRow(buildTab, "💎 Spawn Glass Part", "Spawn", Color3.fromRGB(40,80,80), function()
        spawnPart(nil, Enum.Material.Glass, nil, function(p)
            p.Transparency = 0.5
            p.BrickColor = BrickColor.new("Cyan")
        end)
    end)
    makeRow(buildTab, "🪨 Spawn Metal Part", "Spawn", Color3.fromRGB(60,60,60), function()
        spawnPart(nil, Enum.Material.Metal, nil, function(p)
            p.BrickColor = BrickColor.new("Dark grey")
        end)
    end)
    makeRow(buildTab, "🌊 Spawn ForceField Part", "Spawn", Color3.fromRGB(40,60,120), function()
        spawnPart(nil, Enum.Material.ForceField, nil)
    end)
    makeRow(buildTab, "🗑️ Delete last spawned part", "Delete", Color3.fromRGB(120,30,30), function()
        if #spawnedParts > 0 then
            local last = spawnedParts[#spawnedParts]
            pcall(function() last:Destroy() end)
            table.remove(spawnedParts, #spawnedParts)
        end
    end)
    makeRow(buildTab, "🗑️ Delete ALL spawned parts", "Delete", Color3.fromRGB(160,30,30), function()
        for _, p in ipairs(spawnedParts) do pcall(function() p:Destroy() end) end
        spawnedParts = {}
    end)
    makeRow(buildTab, "⚓ Anchor last part", "Run", Color3.fromRGB(60,60,80), function()
        if #spawnedParts > 0 then
            pcall(function() spawnedParts[#spawnedParts].Anchored = true end)
        end
    end)
    makeRow(buildTab, "🏄 Unanchor last part", "Run", Color3.fromRGB(60,60,80), function()
        if #spawnedParts > 0 then
            pcall(function() spawnedParts[#spawnedParts].Anchored = false end)
        end
    end)
    makeRow(buildTab, "👁️ Make last invisible", "Run", Color3.fromRGB(60,60,80), function()
        if #spawnedParts > 0 then
            pcall(function() spawnedParts[#spawnedParts].Transparency = 1 end)
        end
    end)
    makeRow(buildTab, "👁️ Make last visible", "Run", Color3.fromRGB(60,60,80), function()
        if #spawnedParts > 0 then
            pcall(function() spawnedParts[#spawnedParts].Transparency = 0 end)
        end
    end)
    makeRow(buildTab, "🎨 Random color last part", "Run", Color3.fromRGB(80,50,30), function()
        if #spawnedParts > 0 then
            pcall(function()
                spawnedParts[#spawnedParts].BrickColor = BrickColor.new(partColors[math.random(1,#partColors)])
            end)
        end
    end)
    makeRow(buildTab, string.format("📦 Spawned: %d parts", #spawnedParts), nil, nil, nil)
    makeRow(buildTab, "── Extra Build ──", nil, nil, nil)
    makeRow(buildTab, "🌐 Spawn platform (40x1x40)", "Spawn", Color3.fromRGB(30,80,60), function()
        spawnPart(nil, Enum.Material.SmoothPlastic, Vector3.new(40,1,40), function(p)
            p.BrickColor = BrickColor.new("Medium stone grey")
        end)
    end)
    makeRow(buildTab, "🏠 Spawn wall (1x20x10)", "Spawn", Color3.fromRGB(30,80,60), function()
        spawnPart(nil, nil, Vector3.new(1,20,10))
    end)
    makeRow(buildTab, "🪟 Spawn window (glass)", "Spawn", Color3.fromRGB(40,80,80), function()
        spawnPart(nil, Enum.Material.Glass, Vector3.new(6,8,0.5), function(p)
            p.BrickColor = BrickColor.new("Cyan")
            p.Transparency = 0.5
        end)
    end)
    makeRow(buildTab, "💡 Spawn neon cube", "Spawn", Color3.fromRGB(80,40,120), function()
        spawnPart(nil, Enum.Material.Neon, Vector3.new(2,2,2), function(p)
            p.Color = Color3.fromHSV(math.random(), 0.9, 1)
        end)
    end)
    makeRow(buildTab, "📌 Attach last to character", "Run", Color3.fromRGB(60,40,80), function()
        if #spawnedParts > 0 then
            pcall(function()
                local p = spawnedParts[#spawnedParts]
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = hrp
                weld.Part1 = p
                weld.Parent = p
                p.Anchored = false
                p.CFrame = hrp.CFrame + Vector3.new(0,4,0)
            end)
        end
    end)
    makeRow(buildTab, "📐 Resize last x2", "Run", Color3.fromRGB(60,60,80), function()
        if #spawnedParts > 0 then
            pcall(function()
                local p = spawnedParts[#spawnedParts]
                p.Size = p.Size * 2
            end)
        end
    end)
    makeRow(buildTab, "📐 Resize last /2", "Run", Color3.fromRGB(60,60,80), function()
        if #spawnedParts > 0 then
            pcall(function()
                local p = spawnedParts[#spawnedParts]
                p.Size = p.Size / 2
            end)
        end
    end)
    makeInputRow(buildTab, "Set size last", "4,4,4", "Set", function(val)
        if #spawnedParts > 0 then
            local coords = {}
            for n in val:gmatch("[%-]?%d+%.?%d*") do table.insert(coords, tonumber(n)) end
            if #coords >= 3 then
                pcall(function() spawnedParts[#spawnedParts].Size = Vector3.new(coords[1],coords[2],coords[3]) end)
            end
        end
    end)
    makeRow(buildTab, "🌈 Cycle color last part", "Run", Color3.fromRGB(80,40,80), function()
        if #spawnedParts > 0 then
            task.spawn(function()
                local p = spawnedParts[#spawnedParts]
                for h = 0, 1, 0.05 do
                    pcall(function() p.Color = Color3.fromHSV(h,1,1) end)
                    task.wait(0.05)
                end
            end)
        end
    end)
    makeRow(buildTab, "🔗 Weld last 2 parts", "Run", Color3.fromRGB(40,60,80), function()
        if #spawnedParts >= 2 then
            pcall(function()
                local p1 = spawnedParts[#spawnedParts-1]
                local p2 = spawnedParts[#spawnedParts]
                local w = Instance.new("WeldConstraint")
                w.Part0 = p1; w.Part1 = p2; w.Parent = p1
                p2.Anchored = false
            end)
        end
    end)
    makeRow(buildTab, "💥 Explode last part", "Run", Color3.fromRGB(120,40,20), function()
        if #spawnedParts > 0 then
            pcall(function()
                local p = spawnedParts[#spawnedParts]
                local e = Instance.new("Explosion")
                e.Position = p.Position
                e.BlastRadius = 10
                e.Parent = workspace
            end)
        end
    end)
    makeRow(buildTab, "🔄 Rotate last 45°", "Run", Color3.fromRGB(60,40,80), function()
        if #spawnedParts > 0 then
            pcall(function()
                local p = spawnedParts[#spawnedParts]
                p.CFrame = p.CFrame * CFrame.Angles(0, math.rad(45), 0)
            end)
        end
    end)

    -- ===== TAB 4: TELEPORT =====
    local tpTab, tpBtn = makeTab("TP", "📍")
    local tpSavedPos = nil

    makeInputRow(tpTab, "X,Y,Z Coords", "0,50,0", "Go", function(val)
        local coords = {}
        for n in val:gmatch("[%-]?%d+%.?%d*") do table.insert(coords, tonumber(n)) end
        if #coords >= 3 then
            pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(coords[1],coords[2],coords[3]) end)
        end
    end)
    makeInputRow(tpTab, "TP to Player", "Username", "Go", function(val)
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name:lower() == val:lower() and p.Character then
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(3,0,0)
                end)
            end
        end
    end)
    makeRow(tpTab, "🏠 TP to Spawn (0,5,0)", "Go", Color3.fromRGB(30,80,60), function()
        pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0,5,0) end)
    end)
    makeRow(tpTab, "🌌 TP to Sky (0,1000,0)", "Go", Color3.fromRGB(30,60,100), function()
        pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0,1000,0) end)
    end)
    makeRow(tpTab, "📷 TP to Camera target", "Go", Color3.fromRGB(40,70,80), function()
        pcall(function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0,0,-10)
        end)
    end)
    makeRow(tpTab, "⬆️ TP Up +50", "Go", Color3.fromRGB(40,60,100), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + Vector3.new(0,50,0)
        end)
    end)
    makeRow(tpTab, "⬇️ TP Down -20", "Go", Color3.fromRGB(40,60,100), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + Vector3.new(0,-20,0)
        end)
    end)
    makeRow(tpTab, "➡️ TP Forward +20", "Go", Color3.fromRGB(40,60,100), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 20
        end)
    end)
    makeRow(tpTab, "💾 Save current position", "Save", Color3.fromRGB(40,80,40), function()
        pcall(function()
            tpSavedPos = LocalPlayer.Character.HumanoidRootPart.CFrame
            showNotifSimple("✅ Position saved!", Color3.fromRGB(80,220,120))
        end)
    end)
    makeRow(tpTab, "📂 Load saved position", "Load", Color3.fromRGB(40,80,40), function()
        if tpSavedPos then
            pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = tpSavedPos end)
        else
            showNotifSimple("❌ No saved position!", Color3.fromRGB(255,80,80))
        end
    end)
    makeRow(tpTab, "🎲 TP to random player", "Go", Color3.fromRGB(80,40,80), function()
        local plrs = Players:GetPlayers()
        local target = plrs[math.random(1, #plrs)]
        if target and target.Character then
            pcall(function()
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(3,0,0)
            end)
            showNotifSimple("TP to: " .. target.Name, Color3.fromRGB(150,100,255))
        end
    end)
    makeRow(tpTab, "🎯 Print my position", "Print", Color3.fromRGB(40,60,100), function()
        pcall(function()
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            showNotifSimple(string.format("Pos: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z), Color3.fromRGB(150,180,255))
        end)
    end)
    makeRow(tpTab, "🏃 TP forward sprint x5", "Go", Color3.fromRGB(40,60,80), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 100
        end)
    end)
    makeRow(tpTab, "🔄 TP to map center", "Go", Color3.fromRGB(40,60,80), function()
        pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0,50,0) end)
    end)
    makeRow(tpTab, "↩️ TP behind camera", "Go", Color3.fromRGB(40,60,80), function()
        pcall(function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.CurrentCamera.CFrame
        end)
    end)
    makeRow(tpTab, "── Extra TP ──", nil, nil, nil)
    makeRow(tpTab, "🏁 TP to world origin (0,0,0)", "Go", Color3.fromRGB(40,60,80), function()
        pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0,0,0) end)
    end)
    makeRow(tpTab, "🌊 TP to water level (0,0,0 Y:0)", "Go", Color3.fromRGB(20,60,80), function()
        pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0,0,0) end)
    end)
    makeRow(tpTab, "⬆️ TP Up +100", "Go", Color3.fromRGB(40,60,100), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + Vector3.new(0,100,0)
        end)
    end)
    makeRow(tpTab, "⬇️ TP Down -50", "Go", Color3.fromRGB(40,60,100), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + Vector3.new(0,-50,0)
        end)
    end)
    makeRow(tpTab, "↗️ TP diagonal +50,+50", "Go", Color3.fromRGB(40,60,100), function()
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + Vector3.new(50,0,50)
        end)
    end)
    makeInputRow(tpTab, "TP offset X,Y,Z", "5,0,0", "Go", function(val)
        local coords = {}
        for n in val:gmatch("[%-]?%d+%.?%d*") do table.insert(coords, tonumber(n)) end
        if #coords >= 3 then
            pcall(function()
                local hrp = LocalPlayer.Character.HumanoidRootPart
                hrp.CFrame = hrp.CFrame + Vector3.new(coords[1],coords[2],coords[3])
            end)
        end
    end)
    makeRow(tpTab, "🔄 TP to last spawned part", "Go", Color3.fromRGB(40,60,80), function()
        if #spawnedParts > 0 then
            pcall(function()
                LocalPlayer.Character.HumanoidRootPart.CFrame =
                    spawnedParts[#spawnedParts].CFrame + Vector3.new(0,4,0)
            end)
        end
    end)
    makeRow(tpTab, "🎯 TP to camera focus point", "Go", Color3.fromRGB(40,70,80), function()
        pcall(function()
            local cam = workspace.CurrentCamera
            local ray = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 200)
            if ray then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(ray.Position + Vector3.new(0,3,0))
            end
        end)
    end)
    makeRow(tpTab, "🔁 Teleport loop (orbit)", "Run", Color3.fromRGB(80,40,80), function()
        task.spawn(function()
            local center = LocalPlayer.Character.HumanoidRootPart.Position
            for i = 0, 360, 15 do
                pcall(function()
                    local rad = math.rad(i)
                    LocalPlayer.Character.HumanoidRootPart.CFrame =
                        CFrame.new(center + Vector3.new(math.cos(rad)*15, 0, math.sin(rad)*15))
                end)
                task.wait(0.05)
            end
        end)
    end)
    makeRow(tpTab, "🏃 TP forward x10 fast", "Go", Color3.fromRGB(30,80,80), function()
        task.spawn(function()
            for i = 1, 10 do
                pcall(function()
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 10
                end)
                task.wait(0.03)
            end
        end)
    end)
    makeRow(tpTab, "🗺️ TP to random location", "Go", Color3.fromRGB(80,40,60), function()
        pcall(function()
            local x = math.random(-500,500)
            local z = math.random(-500,500)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x,50,z)
            showNotifSimple(string.format("TP to %.0f, 50, %.0f",x,z), Color3.fromRGB(150,180,255))
        end)
    end)
    makeRow(tpTab, "📐 TP to exact grid (snap)", "Go", Color3.fromRGB(40,60,80), function()
        pcall(function()
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            local snapped = Vector3.new(math.round(pos.X/4)*4, pos.Y, math.round(pos.Z/4)*4)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(snapped)
        end)
    end)
    makeRow(tpTab, "📏 Distance to nearest player", "Show", Color3.fromRGB(40,60,100), function()
        pcall(function()
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
            local nearest, dist = "none", math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                    if d < dist then dist=d nearest=p.Name end
                end
            end
            showNotifSimple(string.format("Nearest: %s (%.0f studs)", nearest, dist), Color3.fromRGB(150,180,255))
        end)
    end)

    -- ===== TAB 5: GUI =====
    local guiTab, guiBtn = makeTab("GUI", "🖥️")
    local function refreshGui()
        for _, c in ipairs(guiTab:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            makeRow(guiTab, "PlayerGui not found", nil, nil, nil)
            return
        end
        local guiList = pg:GetChildren()
        makeRow(guiTab, string.format("📊 Total GUIs: %d", #guiList), nil, nil, nil)
        for _, gui in ipairs(guiList) do
            local enabled = gui:IsA("ScreenGui") and gui.Enabled
            makeRow(guiTab,
                string.format("[%s] %s %s", gui.ClassName, gui.Name, enabled == false and "⚫" or "🟢"),
                "Delete", Color3.fromRGB(120,30,30),
                function() pcall(function() gui:Destroy() end) refreshGui() end
            )
        end
        makeRow(guiTab, "── Bulk Actions ──", nil, nil, nil)
        makeRow(guiTab, "🔄 Refresh GUI list", "Run", Color3.fromRGB(60,60,120), refreshGui)
        makeRow(guiTab, "🙈 Hide ALL GUIs", "Run", Color3.fromRGB(80,60,20), function()
            pcall(function()
                for _, g in ipairs(pg:GetChildren()) do
                    if g:IsA("ScreenGui") then g.Enabled = false end
                end
            end)
            refreshGui()
        end)
        makeRow(guiTab, "👁️ Show ALL GUIs", "Run", Color3.fromRGB(30,80,30), function()
            pcall(function()
                for _, g in ipairs(pg:GetChildren()) do
                    if g:IsA("ScreenGui") then g.Enabled = true end
                end
            end)
            refreshGui()
        end)
        makeRow(guiTab, "💥 DELETE ALL GUIs", "Run", Color3.fromRGB(160,20,20), function()
            pcall(function()
                for _, g in ipairs(pg:GetChildren()) do
                    if g.Name ~= "SkyMoon_Admin" then g:Destroy() end
                end
            end)
            refreshGui()
        end)
        makeRow(guiTab, "📋 Print GUI names", "Run", Color3.fromRGB(40,60,100), function()
            local names = {}
            for _, g in ipairs(pg:GetChildren()) do table.insert(names, g.Name) end
            showNotifSimple(table.concat(names, ", "):sub(1,80), Color3.fromRGB(150,180,255))
        end)
        makeRow(guiTab, "🔍 Count ScreenGuis", "Run", Color3.fromRGB(40,60,100), function()
            local count = 0
            for _, g in ipairs(pg:GetChildren()) do
                if g:IsA("ScreenGui") then count = count + 1 end
            end
            showNotifSimple("ScreenGuis: " .. count, Color3.fromRGB(150,180,255))
        end)
        makeRow(guiTab, "── Extra GUI ──", nil, nil, nil)
        makeRow(guiTab, "📌 Pin SkyMoon (keep on top)", "Run", Color3.fromRGB(40,60,120), function()
            pcall(function()
                local sky = pg:FindFirstChild("SkyMoon_Admin")
                if sky then sky.DisplayOrder = 999 end
            end)
            showNotifSimple("SkyMoon pinned to top!", Color3.fromRGB(80,220,120))
        end)
        makeRow(guiTab, "🔲 Add test Frame to PlayerGui", "Run", Color3.fromRGB(30,60,80), function()
            pcall(function()
                local sg2 = Instance.new("ScreenGui", pg)
                sg2.Name = "TestFrame_" .. math.random(100,999)
                local f = Instance.new("Frame", sg2)
                f.Size = UDim2.new(0,100,0,100)
                f.Position = UDim2.new(0.5,-50,0.5,-50)
                f.BackgroundColor3 = Color3.fromHSV(math.random(),0.8,0.9)
                Instance.new("UICorner",f).CornerRadius = UDim.new(0,8)
            end)
            refreshGui()
        end)
        makeRow(guiTab, "📝 Add TextLabel to PlayerGui", "Run", Color3.fromRGB(30,60,80), function()
            pcall(function()
                local sg2 = Instance.new("ScreenGui", pg)
                sg2.Name = "TestLabel_" .. math.random(100,999)
                local l = Instance.new("TextLabel", sg2)
                l.Size = UDim2.new(0,200,0,40)
                l.Position = UDim2.new(0.5,-100,0.1,0)
                l.BackgroundColor3 = Color3.fromRGB(20,20,30)
                l.TextColor3 = Color3.new(1,1,1)
                l.Text = "SkyMoon Label"
                l.Font = Enum.Font.GothamBold
                l.TextSize = 14
                Instance.new("UICorner",l).CornerRadius = UDim.new(0,6)
            end)
            refreshGui()
        end)
        makeRow(guiTab, "🎯 List CoreGui children", "Show", Color3.fromRGB(40,40,80), function()
            local names = {}
            pcall(function()
                for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
                    table.insert(names, g.Name)
                end
            end)
            showNotifSimple("CoreGui: " .. table.concat(names,", "):sub(1,80), Color3.fromRGB(150,180,255))
        end)
        makeRow(guiTab, "🙈 Hide SkyMoon temporarily", "Run", Color3.fromRGB(80,60,20), function()
            pcall(function()
                local sky = pg:FindFirstChild("SkyMoon_Admin")
                if sky then sky.Enabled = false
                    task.delay(3, function() pcall(function() sky.Enabled = true end) end)
                end
            end)
        end)
        makeRow(guiTab, "📏 Print GUI sizes", "Print", Color3.fromRGB(40,60,100), function()
            local info = {}
            pcall(function()
                for _, g in ipairs(pg:GetChildren()) do
                    if g:IsA("ScreenGui") then
                        table.insert(info, g.Name.."(".. #g:GetDescendants() ..")")
                    end
                end
            end)
            showNotifSimple(table.concat(info,", "):sub(1,80), Color3.fromRGB(150,180,255))
        end)
        makeRow(guiTab, "🔄 Reset all GUI DisplayOrder", "Run", Color3.fromRGB(60,60,80), function()
            pcall(function()
                for _, g in ipairs(pg:GetChildren()) do
                    if g:IsA("ScreenGui") then g.DisplayOrder = 0 end
                end
            end)
        end)
        makeRow(guiTab, "⚡ Enable all ScreenGuis", "Run", Color3.fromRGB(30,80,30), function()
            pcall(function()
                for _, g in ipairs(pg:GetChildren()) do
                    if g:IsA("ScreenGui") then g.Enabled = true end
                end
            end)
            refreshGui()
        end)
        makeRow(guiTab, "🌀 Spin all GUI frames", "Run", Color3.fromRGB(80,40,80), function()
            task.spawn(function()
                pcall(function()
                    for _, g in ipairs(pg:GetChildren()) do
                        if g:IsA("ScreenGui") then
                            for _, d in ipairs(g:GetDescendants()) do
                                if d:IsA("Frame") then
                                    for i=0,360,10 do
                                        d.Rotation = i
                                        task.wait(0.01)
                                    end
                                    d.Rotation = 0
                                end
                            end
                        end
                    end
                end)
            end)
        end)
        makeRow(guiTab, "🎨 Rainbow BG all frames", "Run", Color3.fromRGB(80,40,60), function()
            task.spawn(function()
                pcall(function()
                    local h = 0
                    for _ = 1, 60 do
                        for _, g in ipairs(pg:GetChildren()) do
                            if g:IsA("ScreenGui") then
                                for _, d in ipairs(g:GetDescendants()) do
                                    if d:IsA("Frame") then
                                        d.BackgroundColor3 = Color3.fromHSV(h,0.8,0.9)
                                    end
                                end
                            end
                        end
                        h = (h + 0.017) % 1
                        task.wait(0.05)
                    end
                end)
            end)
        end)
        makeRow(guiTab, "🔍 Find GUI by name...", "Search", Color3.fromRGB(40,60,80), function()
            showNotifSimple("Use Check In [PlayerGui, GuiName] in /Open_Cmd!", Color3.fromRGB(150,180,255))
        end)
        makeRow(guiTab, "📊 GUI tree depth count", "Count", Color3.fromRGB(40,60,100), function()
            local total = 0
            pcall(function()
                for _, g in ipairs(pg:GetDescendants()) do total = total + 1 end
            end)
            showNotifSimple("Total GUI descendants: "..total, Color3.fromRGB(150,180,255))
        end)
        makeRow(guiTab, "🔒 Lock all GUIs (Active=false)", "Run", Color3.fromRGB(80,40,20), function()
            pcall(function()
                for _, g in ipairs(pg:GetDescendants()) do
                    if g:IsA("GuiObject") then g.Active = false end
                end
            end)
        end)
        makeRow(guiTab, "🔓 Unlock all GUIs (Active=true)", "Run", Color3.fromRGB(30,80,30), function()
            pcall(function()
                for _, g in ipairs(pg:GetDescendants()) do
                    if g:IsA("GuiObject") then g.Active = true end
                end
            end)
        end)
    end
    refreshGui()

    -- ===== TAB 6: SOUND =====
    local soundTab, soundBtn = makeTab("Sound", "🔊")

    -- State
    local customSoundObj = nil
    local customSoundPaused = false
    local soundMuted = false
    local allSoundConns = {}
    local volSliderVal = 1.0

    -- Mute/Unmute all game sounds (local only)
    makeRow(soundTab, "🔇 Mute all game sounds", "Mute", Color3.fromRGB(80,40,20), function()
        soundMuted = true
        pcall(function()
            local SoundService = game:GetService("SoundService")
            SoundService.RespectFilteringEnabled = true
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") then s.Volume = 0 end
            end
            for _, s in ipairs(game:GetService("SoundService"):GetDescendants()) do
                if s:IsA("Sound") then s.Volume = 0 end
            end
        end)
        showNotifSimple("🔇 All sounds muted (local only)", Color3.fromRGB(255,150,80))
    end)

    makeRow(soundTab, "🔊 Unmute all sounds", "Unmute", Color3.fromRGB(30,80,30), function()
        soundMuted = false
        pcall(function()
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") then s.Volume = 1 end
            end
            for _, s in ipairs(game:GetService("SoundService"):GetDescendants()) do
                if s:IsA("Sound") then s.Volume = 1 end
            end
        end)
        showNotifSimple("🔊 All sounds restored", Color3.fromRGB(80,220,120))
    end)

    makeRow(soundTab, "── Volume Control ──", nil, nil, nil)

    makeInputRow(soundTab, "Set global vol (0-1)", "0.5", "Set", function(val)
        local v = math.clamp(tonumber(val) or 1, 0, 1)
        pcall(function()
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") then s.Volume = v end
            end
        end)
        showNotifSimple("Volume set to "..v, Color3.fromRGB(150,180,255))
    end)

    makeRow(soundTab, "🔉 Volume 50%", "Set", Color3.fromRGB(40,60,80), function()
        pcall(function()
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") then s.Volume = 0.5 end
            end
        end)
    end)
    makeRow(soundTab, "🔊 Volume 100%", "Set", Color3.fromRGB(40,80,60), function()
        pcall(function()
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") then s.Volume = 1 end
            end
        end)
    end)

    makeRow(soundTab, "── Custom Song ──", nil, nil, nil)

    -- Custom song ID input
    local customSongFrame = Instance.new("Frame", soundTab)
    customSongFrame.Size = UDim2.new(1, -8, 0, 100)
    customSongFrame.Position = UDim2.new(0, 4, 0, 0)
    customSongFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    customSongFrame.BorderSizePixel = 0
    Instance.new("UICorner", customSongFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", customSongFrame).Color = Color3.fromRGB(50, 50, 80)
    Instance.new("UIListLayout", soundTab).Padding = UDim.new(0, 2)

    local songIdInput = Instance.new("TextBox", customSongFrame)
    songIdInput.Size = UDim2.new(1, -8, 0, 28)
    songIdInput.Position = UDim2.new(0, 4, 0, 6)
    songIdInput.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    songIdInput.Text = ""
    songIdInput.PlaceholderText = "Sound ID (e.g. 139132289)"
    songIdInput.PlaceholderColor3 = Color3.fromRGB(60, 60, 90)
    songIdInput.TextColor3 = Color3.fromRGB(200, 210, 255)
    songIdInput.Font = Enum.Font.Code
    songIdInput.TextSize = 12
    songIdInput.BorderSizePixel = 0
    songIdInput.ClearTextOnFocus = false
    Instance.new("UICorner", songIdInput).CornerRadius = UDim.new(0, 4)

    -- Where to play buttons
    local whereLabel = Instance.new("TextLabel", customSongFrame)
    whereLabel.Size = UDim2.new(1, -8, 0, 16)
    whereLabel.Position = UDim2.new(0, 4, 0, 38)
    whereLabel.BackgroundTransparency = 1
    whereLabel.Text = "Play di mana:"
    whereLabel.TextColor3 = Color3.fromRGB(100, 100, 140)
    whereLabel.Font = Enum.Font.Code
    whereLabel.TextSize = 10
    whereLabel.TextXAlignment = Enum.TextXAlignment.Left

    local function makeWhereBtn(label, xpos)
        local b = Instance.new("TextButton", customSongFrame)
        b.Size = UDim2.new(0, 68, 0, 22)
        b.Position = UDim2.new(0, xpos, 0, 56)
        b.BackgroundColor3 = Color3.fromRGB(30, 40, 80)
        b.Text = label
        b.TextColor3 = Color3.fromRGB(180, 200, 255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        return b
    end

    local btn_workspace = makeWhereBtn("🌍 World", 4)
    local btn_local = makeWhereBtn("👤 Local", 76)
    local btn_camera = makeWhereBtn("📷 Camera", 148)

    local function playCustomSong(parent)
        local id = songIdInput.Text:match("%d+")
        if not id then
            showNotifSimple("❌ Enter a valid Sound ID!", Color3.fromRGB(255,80,80))
            return
        end
        -- Stop previous
        if customSoundObj then
            pcall(function() customSoundObj:Stop() customSoundObj:Destroy() end)
            customSoundObj = nil
        end
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://" .. id
            s.Volume = volSliderVal
            s.Looped = true
            s.Parent = parent
            s:Play()
            customSoundObj = s
            showNotifSimple("🎵 Playing: " .. id, Color3.fromRGB(80,220,120))
        end)
        -- Show player controls
        customSongFrame.Size = UDim2.new(1,-8,0,100)
    end

    btn_workspace.MouseButton1Click:Connect(function()
        btn_workspace.BackgroundColor3 = Color3.fromRGB(0,100,200)
        btn_local.BackgroundColor3 = Color3.fromRGB(30,40,80)
        btn_camera.BackgroundColor3 = Color3.fromRGB(30,40,80)
        playCustomSong(workspace)
    end)
    btn_local.MouseButton1Click:Connect(function()
        btn_workspace.BackgroundColor3 = Color3.fromRGB(30,40,80)
        btn_local.BackgroundColor3 = Color3.fromRGB(0,100,200)
        btn_camera.BackgroundColor3 = Color3.fromRGB(30,40,80)
        playCustomSong(LocalPlayer)
    end)
    btn_camera.MouseButton1Click:Connect(function()
        btn_workspace.BackgroundColor3 = Color3.fromRGB(30,40,80)
        btn_local.BackgroundColor3 = Color3.fromRGB(30,40,80)
        btn_camera.BackgroundColor3 = Color3.fromRGB(0,100,200)
        playCustomSong(workspace.CurrentCamera)
    end)

    -- ── Player controls ──
    makeRow(soundTab, "── Player Controls ──", nil, nil, nil)

    -- Volume slider row
    local volRow = Instance.new("Frame", soundTab)
    volRow.Size = UDim2.new(1,-8,0,32)
    volRow.BackgroundColor3 = Color3.fromRGB(18,18,30)
    volRow.BorderSizePixel=0
    Instance.new("UICorner",volRow).CornerRadius=UDim.new(0,6)

    local volLbl = Instance.new("TextLabel",volRow)
    volLbl.Size=UDim2.new(0,56,1,0) volLbl.BackgroundTransparency=1
    volLbl.Text="Vol: 100%" volLbl.Font=Enum.Font.Code volLbl.TextSize=10
    volLbl.TextColor3=Color3.fromRGB(150,180,255) volLbl.TextXAlignment=Enum.TextXAlignment.Left
    local pad=Instance.new("UIPadding",volLbl) pad.PaddingLeft=UDim.new(0,6)

    local volMinus = Instance.new("TextButton",volRow)
    volMinus.Size=UDim2.new(0,24,0,22) volMinus.Position=UDim2.new(0,58,0.5,-11)
    volMinus.BackgroundColor3=Color3.fromRGB(30,40,80) volMinus.Text="-"
    volMinus.TextColor3=Color3.fromRGB(200,210,255) volMinus.Font=Enum.Font.GothamBold
    volMinus.TextSize=14 volMinus.BorderSizePixel=0
    Instance.new("UICorner",volMinus).CornerRadius=UDim.new(0,4)

    local volBar = Instance.new("Frame",volRow)
    volBar.Size=UDim2.new(0,80,0,6) volBar.Position=UDim2.new(0,86,0.5,-3)
    volBar.BackgroundColor3=Color3.fromRGB(40,40,60) volBar.BorderSizePixel=0
    Instance.new("UICorner",volBar).CornerRadius=UDim.new(0,3)
    local volFill=Instance.new("Frame",volBar)
    volFill.Size=UDim2.new(1,0,1,0) volFill.BackgroundColor3=Color3.fromRGB(0,162,255)
    volFill.BorderSizePixel=0 Instance.new("UICorner",volFill).CornerRadius=UDim.new(0,3)

    local volPlus = Instance.new("TextButton",volRow)
    volPlus.Size=UDim2.new(0,24,0,22) volPlus.Position=UDim2.new(0,170,0.5,-11)
    volPlus.BackgroundColor3=Color3.fromRGB(30,40,80) volPlus.Text="+"
    volPlus.TextColor3=Color3.fromRGB(200,210,255) volPlus.Font=Enum.Font.GothamBold
    volPlus.TextSize=14 volPlus.BorderSizePixel=0
    Instance.new("UICorner",volPlus).CornerRadius=UDim.new(0,4)

    local function updateVol(delta)
        volSliderVal = math.clamp(volSliderVal + delta, 0, 1)
        volFill.Size = UDim2.new(volSliderVal, 0, 1, 0)
        volLbl.Text = "Vol: " .. math.floor(volSliderVal*100) .. "%"
        if customSoundObj then pcall(function() customSoundObj.Volume = volSliderVal end) end
    end
    volMinus.MouseButton1Click:Connect(function() updateVol(-0.1) end)
    volPlus.MouseButton1Click:Connect(function() updateVol(0.1) end)

    -- Pause/Play/Stop row
    local ppRow = Instance.new("Frame", soundTab)
    ppRow.Size=UDim2.new(1,-8,0,32) ppRow.BackgroundColor3=Color3.fromRGB(18,18,30)
    ppRow.BorderSizePixel=0 Instance.new("UICorner",ppRow).CornerRadius=UDim.new(0,6)
    local ppLayout=Instance.new("UIListLayout",ppRow)
    ppLayout.FillDirection=Enum.FillDirection.Horizontal ppLayout.Padding=UDim.new(0,6)
    ppLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center ppLayout.VerticalAlignment=Enum.VerticalAlignment.Center

    local function mkPPBtn(txt, col)
        local b = Instance.new("TextButton", ppRow)
        b.Size=UDim2.new(0,60,0,24)
        b.BackgroundColor3=col b.Text=txt b.TextColor3=Color3.new(1,1,1)
        b.Font=Enum.Font.GothamBold b.TextSize=11 b.BorderSizePixel=0
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
        return b
    end

    local playPPBtn = mkPPBtn("▶ Play", Color3.fromRGB(0,140,60))
    local pauseBtn  = mkPPBtn("⏸ Pause", Color3.fromRGB(150,100,0))
    local stopBtn2  = mkPPBtn("⏹ Stop", Color3.fromRGB(160,30,30))

    playPPBtn.MouseButton1Click:Connect(function()
        if customSoundObj then
            pcall(function()
                customSoundObj:Play()
                customSoundPaused = false
                showNotifSimple("▶ Resumed", Color3.fromRGB(80,220,120))
            end)
        end
    end)
    pauseBtn.MouseButton1Click:Connect(function()
        if customSoundObj then
            pcall(function()
                customSoundObj:Pause()
                customSoundPaused = true
                showNotifSimple("⏸ Paused", Color3.fromRGB(220,180,80))
            end)
        end
    end)
    stopBtn2.MouseButton1Click:Connect(function()
        if customSoundObj then
            pcall(function() customSoundObj:Stop() customSoundObj:Destroy() end)
            customSoundObj = nil
            showNotifSimple("⏹ Stopped", Color3.fromRGB(255,80,80))
        end
    end)

    makeRow(soundTab, "── Sound List ──", nil, nil, nil)

    makeRow(soundTab, "📋 List all sounds in workspace", "Show", Color3.fromRGB(40,60,100), function()
        local sounds = {}
        pcall(function()
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") then
                    table.insert(sounds, s.Name .. " (" .. tostring(s.SoundId):match("%d+") .. ")")
                end
            end
        end)
        if #sounds == 0 then
            showNotifSimple("No sounds found in workspace", Color3.fromRGB(150,150,255))
        else
            showNotifSimple(table.concat(sounds, ", "):sub(1,80), Color3.fromRGB(150,200,255))
        end
    end)

    makeRow(soundTab, "🎵 Play ambient bg sound", "Play", Color3.fromRGB(40,40,80), function()
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://139132289200391"
            s.Volume = 0.4
            s.Looped = true
            s.Parent = workspace
            s:Play()
            customSoundObj = s
            showNotifSimple("🎵 Ambient BG playing", Color3.fromRGB(80,220,120))
        end)
    end)

    makeRow(soundTab, "🔁 Toggle loop custom song", "Toggle", Color3.fromRGB(40,60,80), function()
        if customSoundObj then
            pcall(function()
                customSoundObj.Looped = not customSoundObj.Looped
                showNotifSimple("Loop: " .. tostring(customSoundObj.Looped), Color3.fromRGB(150,180,255))
            end)
        else
            showNotifSimple("No custom song active", Color3.fromRGB(255,150,80))
        end
    end)

    makeRow(soundTab, "⏩ Set playback speed 2x", "Set", Color3.fromRGB(40,60,80), function()
        if customSoundObj then
            pcall(function() customSoundObj.PlaybackSpeed = 2 end)
        end
    end)
    makeRow(soundTab, "⏪ Playback speed normal", "Set", Color3.fromRGB(40,60,80), function()
        if customSoundObj then
            pcall(function() customSoundObj.PlaybackSpeed = 1 end)
        end
    end)

    -- Activate Players tab by default
    for _, tf in pairs(tabFrames) do tf.Visible = false end
    for _, tb in pairs(tabs) do
        tb.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        tb.TextColor3 = Color3.fromRGB(140, 150, 200)
    end
    if tabFrames[1] then tabFrames[1].Visible = true end
    if tabs[1] then
        tabs[1].BackgroundColor3 = Color3.fromRGB(40, 60, 180)
        tabs[1].TextColor3 = Color3.fromRGB(220, 230, 255)
    end
end

----------------------------------------------------
-- STARTUP FLOW
----------------------------------------------------
task.spawn(function()
    -- Run loading screen first, then proceed to key check
    runLoadingSequence(function()
        task.wait(0.1)

        -- No key system — go straight to main hub
        openMainHub()

        -- Load tools in background
        task.spawn(function()
            local ok, res = pcall(function() return game:HttpGet(ALL_TOOLS_URL) end)
            if ok and res and res ~= "" then
                local fn, err = loadstring(res)
                if fn then pcall(fn) end
            end
        end)
    end)
end)

----------------------------------------------------
-- CONSOLE (RunConsole / /console)
----------------------------------------------------
local consoleOpen = false

openConsole = function()
    if consoleOpen then return end
    consoleOpen = true

    local cSg = Instance.new("ScreenGui")
    cSg.Name = "SkyMoon_Console"
    cSg.ResetOnSpawn = false
    pcall(function() cSg.Parent = game.CoreGui end)
    if not cSg.Parent then cSg.Parent = LocalPlayer.PlayerGui end

    -- Window
    local win = Instance.new("Frame", cSg)
    win.Size = UDim2.new(0, 500, 0, 320)
    win.Position = UDim2.new(0.5, -250, 0.5, -160)
    win.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
    local ws = Instance.new("UIStroke", win)
    ws.Color = Color3.fromRGB(50, 70, 180)
    ws.Thickness = 1.5

    -- Title bar
    local tbar = Instance.new("Frame", win)
    tbar.Size = UDim2.new(1, 0, 0, 30)
    tbar.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
    tbar.BorderSizePixel = 0
    Instance.new("UICorner", tbar).CornerRadius = UDim.new(0, 10)
    local tfix = Instance.new("Frame", tbar)
    tfix.Size = UDim2.new(1, 0, 0.5, 0)
    tfix.Position = UDim2.new(0, 0, 0.5, 0)
    tfix.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
    tfix.BorderSizePixel = 0

    local tlbl = Instance.new("TextLabel", tbar)
    tlbl.Size = UDim2.new(1, -110, 1, 0)
    tlbl.Position = UDim2.new(0, 10, 0, 0)
    tlbl.BackgroundTransparency = 1
    tlbl.Text = "🖥️  SkyMoon Console"
    tlbl.TextColor3 = Color3.fromRGB(160, 170, 255)
    tlbl.Font = Enum.Font.GothamBold
    tlbl.TextSize = 12
    tlbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Clear button
    local clearBtn = Instance.new("TextButton", tbar)
    clearBtn.Size = UDim2.new(0, 52, 0, 20)
    clearBtn.Position = UDim2.new(1, -82, 0, 5)
    clearBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    clearBtn.Text = "Clear"
    clearBtn.TextColor3 = Color3.fromRGB(180, 180, 220)
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 11
    clearBtn.BorderSizePixel = 0
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 4)

    -- Close button
    local closeBtn = Instance.new("TextButton", tbar)
    closeBtn.Size = UDim2.new(0, 24, 0, 20)
    closeBtn.Position = UDim2.new(1, -28, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 11
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    closeBtn.MouseButton1Click:Connect(function()
        consoleOpen = false
        cSg:Destroy()
    end)

    -- Stats bar
    local statsBar = Instance.new("Frame", win)
    statsBar.Size = UDim2.new(1, 0, 0, 22)
    statsBar.Position = UDim2.new(0, 0, 0, 30)
    statsBar.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    statsBar.BorderSizePixel = 0

    local statsLbl = Instance.new("TextLabel", statsBar)
    statsLbl.Size = UDim2.new(1, -10, 1, 0)
    statsLbl.Position = UDim2.new(0, 8, 0, 0)
    statsLbl.BackgroundTransparency = 1
    statsLbl.Font = Enum.Font.Code
    statsLbl.TextSize = 10
    statsLbl.TextColor3 = Color3.fromRGB(80, 90, 130)
    statsLbl.TextXAlignment = Enum.TextXAlignment.Left
    statsLbl.RichText = true

    -- Output scroll
    local scroll = Instance.new("ScrollingFrame", win)
    scroll.Size = UDim2.new(1, -8, 1, -56)
    scroll.Position = UDim2.new(0, 4, 0, 54)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 80, 180)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y

    local outLabel = Instance.new("TextLabel", scroll)
    outLabel.Size = UDim2.new(1, -6, 0, 0)
    outLabel.AutomaticSize = Enum.AutomaticSize.Y
    outLabel.BackgroundTransparency = 1
    outLabel.Font = Enum.Font.Code
    outLabel.TextSize = 11
    outLabel.TextXAlignment = Enum.TextXAlignment.Left
    outLabel.TextYAlignment = Enum.TextYAlignment.Top
    outLabel.TextWrapped = true
    outLabel.RichText = true
    outLabel.Text = '<font color="#333355">-- SkyMoon Console ready --\n</font>'

    outLabel:GetPropertyChangedSignal("Text"):Connect(function()
        task.defer(function()
            scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
        end)
    end)

    -- Log counts
    local logCount = 0
    local warnCount = 0
    local errCount = 0

    local function updateStats()
        statsLbl.Text = string.format(
            '<font color="#aaaaff">Logs: %d</font>  <font color="#ffcc44">Warns: %d</font>  <font color="#ff5555">Errors: %d</font>',
            logCount, warnCount, errCount
        )
    end
    updateStats()

    local function appendLog(msg, logType)
        -- Escape rich text
        msg = msg:gsub("&","and"):gsub("<","["):gsub(">","]")
        local color, prefix
        if logType == "warn" then
            color = "ffcc44"
            prefix = "⚠ "
            warnCount = warnCount + 1
        elseif logType == "error" then
            color = "ff5555"
            prefix = "✗ "
            errCount = errCount + 1
        else
            color = "ccddff"
            prefix = "  "
            logCount = logCount + 1
        end

        -- Limit teks (clear tiap 200 baris biar gak overflow)
        local lineCount = select(2, outLabel.Text:gsub("\n", "\n"))
        if lineCount > 200 then
            outLabel.Text = '<font color="#333355">-- [console cleared: too many logs] --\n</font>'
        end

        outLabel.Text = outLabel.Text ..
            string.format('<font color="#%s">%s%s</font>\n', color, prefix, msg)
        updateStats()
    end

    -- Clear button
    clearBtn.MouseButton1Click:Connect(function()
        outLabel.Text = '<font color="#333355">-- [cleared] --\n</font>'
        logCount = 0
        warnCount = 0
        errCount = 0
        updateStats()
    end)

    -- Hook print / warn via LogService
    local LogService = game:GetService("LogService")
    local logConn = LogService.MessageOut:Connect(function(msg, msgType)
        if not consoleOpen then return end
        if msgType == Enum.MessageType.MessageWarning then
            appendLog(msg, "warn")
        elseif msgType == Enum.MessageType.MessageError then
            appendLog(msg, "error")
        else
            appendLog(msg, "log")
        end
    end)

    -- Cleanup on close
    closeBtn.MouseButton1Click:Connect(function()
        logConn:Disconnect()
        consoleOpen = false
        cSg:Destroy()
    end)

    clearBtn.MouseButton1Click:Connect(function()
        -- sudah di-handle di atas
    end)

    appendLog("Console connected to Roblox LogService.", "log")
    appendLog("All game print/warn/error will appear here.", "log")
end

----------------------------------------------------
-- CHAT COMMANDS
----------------------------------------------------
game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
    local lower = msg:lower()

    if lower == "/open_cmd" then
        task.spawn(openMiniCmd)

    elseif lower == "/console" then
        task.spawn(openConsole)

    elseif lower == "/reset_skymoon" then
        pcall(function()
            if not isfolder("SkyMoon") then makefolder("SkyMoon") end
            writefile("SkyMoon/memory.json", '{"log":[],"executeCount":0}')
        end)
        showNotifSimple("✅ SkyMoon Folder Reset successfully!", Color3.fromRGB(80, 220, 120))

    elseif lower == "/open_admin" then
        task.spawn(openAdminPanel)
    end
end)

-- openAdminAuth alias (no key required)
openAdminAuth = openAdminPanel