-- 🌙 SkyMoon ScriptHub | Mainscript.lua
-- by KHAFIDZKTP | github.com/HaZcK/ScriptHub

local RAW_PLACELIST = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/PlaceList.json"

-- Notification UI
local function showNotif(msg, color)
    pcall(function()
        local existing = game.CoreGui:FindFirstChild("SkyMoon_Notif")
        if existing then existing:Destroy() end
    end)

    local sg = Instance.new("ScreenGui")
    sg.Name = "SkyMoon_Notif"
    sg.ResetOnSpawn = false

    pcall(function() sg.Parent = game.CoreGui end)
    if not sg.Parent then sg.Parent = game.Players.LocalPlayer.PlayerGui end

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 320, 0, 60)
    frame.Position = UDim2.new(0.5, -160, 0, 24)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    frame.BorderSizePixel = 0

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = color or Color3.fromRGB(100, 180, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.4

    local accent = Instance.new("Frame", frame)
    accent.Size = UDim2.new(0, 4, 0.7, 0)
    accent.Position = UDim2.new(0, 10, 0.15, 0)
    accent.BackgroundColor3 = color or Color3.fromRGB(100, 180, 255)
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 22, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Text = msg
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true

    return sg
end

-- Fetch PlaceList
local ok, res = pcall(function()
    return game:HttpGet(RAW_PLACELIST)
end)

if not ok or not res then
    local n = showNotif("❌ Failed to reach SkyMoon!", Color3.fromRGB(255, 80, 80))
    task.wait(2) pcall(function() n:Destroy() end)
    return
end

local db
pcall(function()
    db = game:GetService("HttpService"):JSONDecode(res)
end)

if not db then
    local n = showNotif("❌ PlaceList corrupted!", Color3.fromRGB(255, 80, 80))
    task.wait(2) pcall(function() n:Destroy() end)
    return
end

-- Check PlaceId
local placeId = tostring(game.PlaceId)
local entry = db[placeId]

if not entry then
    local n = showNotif("❌ Not on the list!", Color3.fromRGB(255, 80, 80))
    task.wait(2) pcall(function() n:Destroy() end)
    return
end

-- Load script
local loadNotif = showNotif("⏳ Loading " .. entry.name .. "...", Color3.fromRGB(150, 120, 255))

local scriptOk, scriptRes = pcall(function()
    return game:HttpGet(entry.script)
end)

if not scriptOk or not scriptRes then
    pcall(function() loadNotif:Destroy() end)
    local n = showNotif("❌ Failed to load " .. entry.name, Color3.fromRGB(255, 80, 80))
    task.wait(2) pcall(function() n:Destroy() end)
    return
end

local execOk, execErr = pcall(loadstring(scriptRes))
pcall(function() loadNotif:Destroy() end)

if execOk then
    local n = showNotif("✅ " .. entry.name .. " loaded!", Color3.fromRGB(80, 220, 120))
    task.wait(2) pcall(function() n:Destroy() end)
else
    local n = showNotif("❌ Error: " .. tostring(execErr):sub(1, 40), Color3.fromRGB(255, 80, 80))
    task.wait(2) pcall(function() n:Destroy() end)
end
