-- 🌙 SkyMoon ScriptHub | Mainscript.lua
-- by KHAFIDZKTP | github.com/HaZcK/ScriptHub

local RAW_PLACELIST = "https://raw.githubusercontent.com/HaZcK/ScriptHub/main/SkyMoon/PlaceList.json"
local UBUNTU_LOGO_URL = "https://fs.buttercms.com/resize=width:885/QFGDOkGGTeSUMSRKOjOQ"

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

local grad = Instance.new("UIGradient", mainFrame)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25)),
})
grad.Rotation = 135

local outerStroke = Instance.new("UIStroke", mainFrame)
outerStroke.Color = Color3.fromRGB(80, 100, 200)
outerStroke.Thickness = 1.5
outerStroke.Transparency = 0.4

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

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🌙  S K Y M O O N"
titleLabel.TextColor3 = Color3.fromRGB(180, 190, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13

local divider = Instance.new("Frame", mainFrame)
divider.Size = UDim2.new(0.85, 0, 0, 1)
divider.Position = UDim2.new(0.075, 0, 0, 38)
divider.BackgroundColor3 = Color3.fromRGB(80, 100, 200)
divider.BorderSizePixel = 0
divider.BackgroundTransparency = 0.6

local subLabel = Instance.new("TextLabel", mainFrame)
subLabel.Size = UDim2.new(1, 0, 0, 20)
subLabel.Position = UDim2.new(0, 0, 0, 46)
subLabel.BackgroundTransparency = 1
subLabel.Text = "Game Script Hub"
subLabel.TextColor3 = Color3.fromRGB(100, 110, 160)
subLabel.Font = Enum.Font.Gotham
subLabel.TextSize = 11

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
-- DUPLICATE GUI DIALOG
----------------------------------------------------
local function showDuplicateDialog(guiName, entry, onFinish)
    -- Overlay gelap
    local overlay = Instance.new("Frame", cmdFrame)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 40

    -- Dialog box
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

    local function makeDialog(questionText, onYes, onNo)
        -- Clear dialog isi lama
        for _, c in ipairs(dialog:GetChildren()) do
            if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("Frame") then
                c:Destroy()
            end
        end

        local q = Instance.new("TextLabel", dialog)
        q.Size = UDim2.new(1, -20, 0, 80)
        q.Position = UDim2.new(0, 10, 0, 10)
        q.BackgroundTransparency = 1
        q.Text = questionText
        q.TextColor3 = Color3.fromRGB(180, 200, 255)
        q.Font = Enum.Font.GothamBold
        q.TextSize = 13
        q.TextWrapped = true
        q.RichText = true
        q.ZIndex = 42

        -- YES button
        local yesBtn = Instance.new("TextButton", dialog)
        yesBtn.Size = UDim2.new(0, 120, 0, 36)
        yesBtn.Position = UDim2.new(0.5, -130, 0, 100)
        yesBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 160)
        yesBtn.Text = "Yes"
        yesBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
        yesBtn.Font = Enum.Font.GothamBold
        yesBtn.TextSize = 13
        yesBtn.BorderSizePixel = 0
        yesBtn.ZIndex = 42
        Instance.new("UICorner", yesBtn).CornerRadius = UDim.new(0, 6)

        -- NO button
        local noBtn = Instance.new("TextButton", dialog)
        noBtn.Size = UDim2.new(0, 120, 0, 36)
        noBtn.Position = UDim2.new(0.5, 10, 0, 100)
        noBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
        noBtn.Text = "No"
        noBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
        noBtn.Font = Enum.Font.GothamBold
        noBtn.TextSize = 13
        noBtn.BorderSizePixel = 0
        noBtn.ZIndex = 42
        Instance.new("UICorner", noBtn).CornerRadius = UDim.new(0, 6)

        yesBtn.MouseButton1Click:Connect(onYes)
        noBtn.MouseButton1Click:Connect(onNo)
    end

    -- Step 1: Do you want to duplicate?
    makeDialog(
        string.format('<font color="#4466ff">There.Are.Two.Same.Gui</font>\n"%s" already exists!\n\nDo.You.Want.To.Duplicate.This.Gui?', guiName),
        function()
            -- YES → jalankan script dulu (duplicate)
            makeDialog(
                '<font color="#4466ff">Do.You.Want.Delete.Gui.Old?</font>\n\nDelete the old GUI and keep the new one?',
                function()
                    -- YES → hapus gui lama, run script baru
                    pcall(function()
                        local playerGui = game.Players.LocalPlayer.PlayerGui
                        local old = playerGui:FindFirstChild(guiName)
                        if old then old:Destroy() end
                    end)
                    overlay:Destroy()
                    -- Run script baru
                    local scriptOk, scriptRes = pcall(function()
                        return game:HttpGet(entry.script)
                    end)
                    if scriptOk and scriptRes then
                        pcall(loadstring(scriptRes))
                    end
                    onFinish("run_done")
                end,
                function()
                    -- NO → hapus gui baru (gak jadi duplicate), close skymoon
                    overlay:Destroy()
                    onFinish("cancel")
                end
            )
        end,
        function()
            -- NO → tutup semua
            overlay:Destroy()
            onFinish("cancel")
        end
    )
end

----------------------------------------------------
-- WORKSPACE SCAN (dengan duplicate GUI detection)
----------------------------------------------------
local function scanWorkspace(output, entry)
    local LocalPlayer = game:GetService("Players").LocalPlayer

    local services = {
        {svc = game:GetService("Workspace"),         label = "Workspace"},
        {svc = game:GetService("ReplicatedStorage"),  label = "ReplicatedStorage"},
        {svc = game:GetService("ReplicatedFirst"),    label = "ReplicatedFirst"},
        {svc = game:GetService("StarterGui"),         label = "StarterGui"},
        {svc = game:GetService("StarterPack"),        label = "StarterPack"},
        {svc = game:GetService("StarterPlayer"),      label = "StarterPlayer"},
        {svc = game:GetService("Lighting"),           label = "Lighting"},
        {svc = LocalPlayer,                           label = "LocalPlayer"},
    }
    pcall(function()
        table.insert(services, {svc = LocalPlayer:WaitForChild("PlayerGui", 1), label = "PlayerGui"})
        table.insert(services, {svc = LocalPlayer:WaitForChild("Backpack", 1),  label = "Backpack"})
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
                instance = child,
            })
            collectItems(child, depth + 1, parentLabel)
        end
    end

    for _, s in ipairs(services) do
        pcall(function() collectItems(s.svc, 0, s.label) end)
    end

    local total = #allItems
    if total == 0 then total = 1 end

    local lineCount = 0
    local duplicateFound = nil

    for i, item in ipairs(allItems) do
        local pct = math.floor((i / total) * 100)
        local indent = string.rep("  ", item.depth)
        local line = string.format('%s[KHAFIDZKTP, %s] %s  (%d%%)', indent, item.label, item.name, pct)

        output.Text = output.Text .. string.format('<font color="#00ff44">%s</font>\n', escapeRich(line))
        lineCount = lineCount + 1

        if lineCount >= 25 then
            output.Text = ""
            lineCount = 0
        end

        -- Cek duplicate GUI di PlayerGui
        if entry and item.label == "PlayerGui" and item.class == "ScreenGui" then
            -- Cek apakah ada ScreenGui dengan nama yang sama di PlayerGui
            local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
            local existing = playerGui:FindFirstChild(item.name)
            if existing then
                -- Teks deteksi berhenti
                output.Text = output.Text .. string.format(
                    '<font color="#4466ff">[KHAFIDZKTP, PlayerGui] %s  -- DUPLICATE DETECTED!</font>\n',
                    escapeRich(item.name)
                )
                duplicateFound = item.name
                break
            end
        end

        if i % 10 == 0 then task.wait() end
    end

    if not duplicateFound then
        output.Text = ""
        output.Text = '<font color="#00ffaa">Check_This_Game... 100%</font>\n'
        task.wait(0.3)
    end

    return duplicateFound
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

    -- Fetch PlaceList
    local db = fetchPlaceList()
    local placeId = tostring(game.PlaceId)
    local entry = db and db[placeId]

    -- Workspace scan (pass entry supaya bisa detect duplicate)
    typeTextFast(output, "Check_This_Game:;", "00ff88", 0.06)
    newLine(output)
    task.wait(0.2)
    local duplicateGui = scanWorkspace(output, entry)

    -- Kalau duplicate ditemukan → tampil dialog
    if duplicateGui then
        typeTextFast(output, "There.Are.Two.Same.Gui", "4466ff", 0.05)
        newLine(output)
        task.wait(0.5)

        local finished = false
        local finishResult = nil

        showDuplicateDialog(duplicateGui, entry, function(result)
            finishResult = result
            finished = true
        end)

        -- Tunggu user pilih
        while not finished do task.wait(0.1) end

        if finishResult == "cancel" then
            pcall(function() sg:Destroy() end)
            return
        elseif finishResult == "run_done" then
            pcall(function() sg:Destroy() end)
            return
        end
        return
    end

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

    local entry2 = db and db[placeId]

    if not entry2 then
        typeTextFast(output, "This.Game.Not.support!", "ff4444", 0.08)
        newLine(output)
        task.wait(0.3)
        typeTextFast(output, "Not Supported!", "ff2222", 0.07)
        newLine(output)
        task.wait(0.5)
        glitchFadeOut()
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
