-- 🌙 SkyMoon ScriptHub | Mainscript.lua
-- by KHAFIDZKTP | github.com/HaZcK/ScriptHub

local RAW_PLACELIST = "https://raw.githubusercontent.com/HaZcK/ScriptHub/main/SkyMoon/PlaceList.json"
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ScreenGui
local sg = Instance.new("ScreenGui")
sg.Name = "SkyMoon_Hub"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() sg.Parent = game.CoreGui end)
if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end

-- Main GUI (abu-abu)
local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0, 260, 0, 120)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(80, 80, 90)
stroke.Thickness = 1

-- Title bar
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

local titleFix = Instance.new("Frame", titleBar)
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
titleFix.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🌙 SkyMoon"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13

-- Scan button (biru tua)
local scanBtn = Instance.new("TextButton", mainFrame)
scanBtn.Size = UDim2.new(0, 120, 0, 36)
scanBtn.Position = UDim2.new(0.5, -60, 0.5, 8)
scanBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 130)
scanBtn.BorderSizePixel = 0
scanBtn.Text = "Scan"
scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 14
Instance.new("UICorner", scanBtn).CornerRadius = UDim.new(0, 6)

scanBtn.MouseEnter:Connect(function()
    TweenService:Create(scanBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 80, 170)}):Play()
end)
scanBtn.MouseLeave:Connect(function()
    TweenService:Create(scanBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 60, 130)}):Play()
end)

-- CMD Fullscreen
local function createCMD()
    local cmdFrame = Instance.new("Frame", sg)
    cmdFrame.Size = UDim2.new(1, 0, 1, 0)
    cmdFrame.Position = UDim2.new(0, 0, 0, 0)
    cmdFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    cmdFrame.BorderSizePixel = 0
    cmdFrame.ZIndex = 10

    local output = Instance.new("TextLabel", cmdFrame)
    output.Size = UDim2.new(1, -20, 1, -20)
    output.Position = UDim2.new(0, 10, 0, 10)
    output.BackgroundTransparency = 1
    output.TextColor3 = Color3.fromRGB(255, 255, 255)
    output.Font = Enum.Font.Code
    output.TextSize = 14
    output.TextXAlignment = Enum.TextXAlignment.Left
    output.TextYAlignment = Enum.TextYAlignment.Top
    output.TextWrapped = true
    output.RichText = true
    output.ZIndex = 11
    output.Text = ""

    return cmdFrame, output
end

local function typeText(output, text, speed, color)
    speed = speed or 0.04
    color = color or "ffffff"
    local current = output.Text
    for i = 1, #text do
        current = current .. string.format('<font color="#%s">%s</font>', color, text:sub(i, i))
        output.Text = current
        task.wait(speed)
    end
end

local function newLine(output)
    output.Text = output.Text .. "\n"
end

local function fetchPlaceList()
    local ok, res = pcall(function()
        return game:HttpGet(RAW_PLACELIST)
    end)
    if not ok or not res then return nil end
    local db
    pcall(function() db = HttpService:JSONDecode(res) end)
    return db
end

-- Scan click
scanBtn.MouseButton1Click:Connect(function()
    scanBtn.Active = false
    mainFrame.Visible = false

    local cmdFrame, output = createCMD()

    task.wait(0.3)

    -- "Cmd" putih dulu
    typeText(output, "Cmd", 0.07, "ffffff")
    task.wait(0.4)
    output.Text = ""
    task.wait(0.1)

    -- Executor:;
    typeText(output, "Executor:;", 0.05, "00ff00")
    newLine(output)
    task.wait(0.3)

    local execName = "Unknown"
    pcall(function()
        if identifyexecutor then
            execName = identifyexecutor()
        end
    end)
    typeText(output, "Executor." .. execName, 0.05, "00ff00")
    newLine(output)
    task.wait(0.5)

    -- Fetch list
    local db = fetchPlaceList()

    typeText(output, "CheckList:;", 0.05, "00ff00")
    newLine(output)
    task.wait(0.3)

    if db then
        for _, entry in pairs(db) do
            typeText(output, "  > " .. entry.name, 0.04, "00ff00")
            newLine(output)
            task.wait(0.1)
        end
    else
        typeText(output, "  > Failed to load list!", 0.04, "ff4444")
        newLine(output)
    end
    task.wait(0.4)

    -- Support check
    typeText(output, "Run _Support_Script_in_This_Game&:;", 0.04, "00ff00")
    newLine(output)
    task.wait(0.3)
    typeText(output, "ExecuteScript", 0.06, "00ff00")
    newLine(output)
    task.wait(1)

    local placeId = tostring(game.PlaceId)
    local entry = db and db[placeId]

    if not entry then
        typeText(output, "This.Game.Not.support!", 0.05, "ff4444")
        newLine(output)
        task.wait(0.5)
        typeText(output, "Destroyed_Gui", 0.05, "ff4444")
        task.wait(1)
        cmdFrame:Destroy()
        sg:Destroy()
    else
        typeText(output, "This.Game.support", 0.05, "00ff00")
        newLine(output)
        task.wait(0.4)
        typeText(output, "Run.The.Script", 0.05, "00ff00")
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
