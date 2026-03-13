-- 🌙 SkyMoon ScriptHub | Mainscript.lua
-- by KHAFIDZKTP | github.com/HaZcK/ScriptHub

local RAW_PLACELIST = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/PlaceList.json"
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

-- ScreenGui
local sg = Instance.new("ScreenGui")
sg.Name = "SkyMoon_Hub"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() sg.Parent = game.CoreGui end)
if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end

----------------------------------------------------
-- MAIN GUI
----------------------------------------------------
local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0, 280, 0, 140)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -70)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Gradient
local grad = Instance.new("UIGradient", mainFrame)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25)),
})
grad.Rotation = 135

-- Outer stroke
local outerStroke = Instance.new("UIStroke", mainFrame)
outerStroke.Color = Color3.fromRGB(80, 100, 200)
outerStroke.Thickness = 1.5
outerStroke.Transparency = 0.4

-- Title bar
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleFix = Instance.new("Frame", titleBar)
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
titleFix.BorderSizePixel = 0

-- Moon icon + title
local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🌙  S K Y M O O N"
titleLabel.TextColor3 = Color3.fromRGB(180, 190, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13

-- Divider
local divider = Instance.new("Frame", mainFrame)
divider.Size = UDim2.new(0.85, 0, 0, 1)
divider.Position = UDim2.new(0.075, 0, 0, 38)
divider.BackgroundColor3 = Color3.fromRGB(80, 100, 200)
divider.BorderSizePixel = 0
divider.BackgroundTransparency = 0.6

-- Subtitle
local subLabel = Instance.new("TextLabel", mainFrame)
subLabel.Size = UDim2.new(1, 0, 0, 20)
subLabel.Position = UDim2.new(0, 0, 0, 46)
subLabel.BackgroundTransparency = 1
subLabel.Text = "Game Script Hub"
subLabel.TextColor3 = Color3.fromRGB(100, 110, 160)
subLabel.Font = Enum.Font.Gotham
subLabel.TextSize = 11

-- Scan button
local scanBtn = Instance.new("TextButton", mainFrame)
scanBtn.Size = UDim2.new(0, 140, 0, 38)
scanBtn.Position = UDim2.new(0.5, -70, 0, 78)
scanBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 160)
scanBtn.BorderSizePixel = 0
scanBtn.Text = "⟳  Scan Game"
scanBtn.TextColor3 = Color3.fromRGB(220, 225, 255)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 13
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 8)

local btnStroke = Instance.new("UIStroke", scanBtn)
btnStroke.Color = Color3.fromRGB(100, 130, 255)
btnStroke.Thickness = 1
btnStroke.Transparency = 0.5

scanBtn.MouseEnter:Connect(function()
    TweenService:Create(scanBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 90, 210)}):Play()
end)
scanBtn.MouseLeave:Connect(function()
    TweenService:Create(scanBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 60, 160)}):Play()
end)

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
local function createCMD()
    local cmdFrame = Instance.new("Frame", sg)
    cmdFrame.Size = UDim2.new(1, 0, 1, 0)
    cmdFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    cmdFrame.BorderSizePixel = 0
    cmdFrame.ZIndex = 10

    -- Top bar CMD
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

    -- Prompt prefix
    local prefix = Instance.new("TextLabel", cmdFrame)
    prefix.Size = UDim2.new(0, 120, 0, 20)
    prefix.Position = UDim2.new(0, 10, 0, 34)
    prefix.BackgroundTransparency = 1
    prefix.Text = "C:\\SkyMoon>"
    prefix.TextColor3 = Color3.fromRGB(80, 180, 255)
    prefix.Font = Enum.Font.Code
    prefix.TextSize = 13
    prefix.TextXAlignment = Enum.TextXAlignment.Left
    prefix.ZIndex = 11

    -- Output area
    local output = Instance.new("TextLabel", cmdFrame)
    output.Size = UDim2.new(1, -20, 1, -40)
    output.Position = UDim2.new(0, 10, 0, 34)
    output.BackgroundTransparency = 1
    output.TextColor3 = Color3.fromRGB(255, 255, 255)
    output.Font = Enum.Font.Code
    output.TextSize = 13
    output.TextXAlignment = Enum.TextXAlignment.Left
    output.TextYAlignment = Enum.TextYAlignment.Top
    output.TextWrapped = true
    output.RichText = true
    output.ZIndex = 11
    output.Text = ""

    return cmdFrame, output
end

-- Typing per huruf
local function typeText(output, text, color)
    color = color or "ffffff"
    local current = output.Text
    for i = 1, #text do
        local char = text:sub(i, i)
        current = current .. string.format('<font color="#%s">%s</font>', color, char)
        output.Text = current
        playKeySound()
        task.wait(0.5)
    end
end

local function newLine(output)
    output.Text = output.Text .. "\n"
end

----------------------------------------------------
-- CODEBOX (frame, bukan textbox)
----------------------------------------------------
local function showCodeBox(cmdFrame, db)
    local box = Instance.new("Frame", cmdFrame)
    box.Size = UDim2.new(0, 420, 0, 36 + (#db * 26))
    box.Position = UDim2.new(0.5, -210, 0.5, -((36 + (#db * 26)) / 2))
    box.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    box.BorderSizePixel = 0
    box.ZIndex = 20
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)

    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color = Color3.fromRGB(80, 100, 220)
    boxStroke.Thickness = 1.5

    -- Header
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

    -- List entries
    local yOffset = 34
    local count = 0
    for placeId, entry in pairs(db) do
        count = count + 1
        local row = Instance.new("Frame", box)
        row.Size = UDim2.new(1, -16, 0, 22)
        row.Position = UDim2.new(0, 8, 0, yOffset)
        row.BackgroundColor3 = count % 2 == 0 and Color3.fromRGB(20, 20, 35) or Color3.fromRGB(16, 16, 28)
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
        row.ZIndex = 21

        local rowText = Instance.new("TextLabel", row)
        rowText.Size = UDim2.new(1, -8, 1, 0)
        rowText.Position = UDim2.new(0, 6, 0, 0)
        rowText.BackgroundTransparency = 1
        rowText.Text = string.format(
            '<font color="#6080ff">%s</font>   <font color="#00dd88">%s</font>   <font color="#555577">[SCRIPT PRIVATE]</font>',
            placeId, entry.name
        )
        rowText.RichText = true
        rowText.Font = Enum.Font.Code
        rowText.TextSize = 12
        rowText.TextXAlignment = Enum.TextXAlignment.Left
        rowText.TextColor3 = Color3.fromRGB(200, 200, 200)
        rowText.ZIndex = 22

        yOffset = yOffset + 26
    end

    -- Auto close after 4 seconds
    task.delay(4, function()
        TweenService:Create(box, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        task.wait(0.4)
        pcall(function() box:Destroy() end)
    end)
end

----------------------------------------------------
-- FETCH PLACELIST
----------------------------------------------------
local function fetchPlaceList()
    local ok, res = pcall(function()
        return game:HttpGet(RAW_PLACELIST)
    end)
    if not ok or not res then return nil end
    local db
    pcall(function() db = HttpService:JSONDecode(res) end)
    return db
end

----------------------------------------------------
-- SCAN CLICK
----------------------------------------------------
scanBtn.MouseButton1Click:Connect(function()
    scanBtn.Active = false
    mainFrame.Visible = false

    local cmdFrame, output = createCMD()
    task.wait(0.3)

    -- "Cmd" putih → clear → hijau
    typeText(output, "Cmd", "ffffff")
    task.wait(0.4)
    output.Text = ""
    task.wait(0.1)

    -- Executor
    typeText(output, "Executor:;", "00ff88")
    newLine(output)
    task.wait(0.3)

    local execName = "Unknown"
    pcall(function()
        if identifyexecutor then execName = identifyexecutor() end
    end)
    typeText(output, "Executor." .. execName, "00ff88")
    newLine(output)
    task.wait(0.5)

    -- Fetch list
    local db = fetchPlaceList()

    -- CheckList
    typeText(output, "CheckList:;", "00ff88")
    newLine(output)
    task.wait(0.3)

    -- Codebox muncul
    if db then
        -- Hitung jumlah entry untuk ukuran box
        local count = 0
        for _ in pairs(db) do count = count + 1 end
        local fakeDb = {}
        for k, v in pairs(db) do table.insert(fakeDb, {id=k, name=v.name}) end

        -- Buat tabel sementara untuk showCodeBox
        local dbArr = {}
        for _ in pairs(db) do table.insert(dbArr, true) end

        showCodeBox(cmdFrame, db)
        task.wait(4.5)
    else
        typeText(output, "  > Failed to load list!", "ff4444")
        newLine(output)
    end

    -- Support check
    typeText(output, "Run _Support_Script_in_This_Game&:;", "00ff88")
    newLine(output)
    task.wait(0.3)
    typeText(output, "ExecuteScript", "00ff88")
    newLine(output)
    task.wait(1)

    local placeId = tostring(game.PlaceId)
    local entry = db and db[placeId]

    if not entry then
        typeText(output, "This.Game.Not.support!", "ff4444")
        newLine(output)
        task.wait(0.5)
        typeText(output, "Destroyed_Gui", "ff4444")
        task.wait(1)
        cmdFrame:Destroy()
        sg:Destroy()
    else
        typeText(output, "This.Game.support", "00ff88")
        newLine(output)
        task.wait(0.4)
        typeText(output, "Run.The.Script", "00ff88")
        task.wait(2)

        local scriptOk, scriptRes = pcall(function()
            return game:HttpGet(entry.script)
        end)
        if scriptOk and scriptRes then
            pcall(loadstring(scriptRes))
        end

        cmdFrame:Destroy()
        sg:Destroy()
    end
end)
