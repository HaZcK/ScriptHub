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
            collectItems(child, depth + 1, parentLabel)
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

        -- Cek duplicate dulu sebelum tampil
        if entry and item.label == "PlayerGui" and item.class == "ScreenGui" then
            local pg = LP.PlayerGui
            if pg:FindFirstChild(item.name) then
                -- Tampil deteksi
                output.Text = output.Text .. string.format(
                    '<font color="#4466ff">[KHAFIDZKTP, PlayerGui] %s  (%d%%) -- DUPLICATE!</font>\n',
                    escapeRich(item.name), pct
                )
                lineCount = lineCount + 1

                -- Pause scan, tunggu user pilih
                local resumed = false
                showDuplicateDialog(item.name, function()
                    resumed = true
                end)

                -- Tunggu dialog selesai
                while not resumed do task.wait(0.05) end

                -- Lanjut item berikutnya
                if i % 10 == 0 then task.wait() end
                return
            end
        end

        output.Text = output.Text .. string.format('<font color="#00ff44">%s</font>\n', escapeRich(line))
        lineCount = lineCount + 1

        if lineCount >= 25 then
            output.Text = ""
            lineCount = 0
        end

        if i % 10 == 0 then task.wait() end
    end

    -- Run semua item
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

    -- Fetch PlaceList
    local db = fetchPlaceList()
    local placeId = tostring(game.PlaceId)
    local entry = db and db[placeId]

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

-- Panggil increment tiap kali script berhasil run (patch di scanBtn handler diatas via pcall)
pcall(incrementMemory, game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)

----------------------------------------------------
-- MINI CMD (/Open_Cmd)
----------------------------------------------------
local miniCmdOpen = false

local function openMiniCmd()
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
    local function processCheckIn(cmd)
        local inner = cmd:match("[Cc]heck [Ii]n %[(.-)%]")
        if not inner then
            appendOut("Unknown command.", "ff4444")
            appendOut("Usage: Check In [Username, Folder] or [Username, Folder, Object]", "888888")
            return
        end

        local parts = {}
        for p in inner:gmatch("[^,]+") do
            table.insert(parts, p:match("^%s*(.-)%s*$"))
        end

        local username  = parts[1]
        local folderName = parts[2]
        local objectName = parts[3]

        if not username or not folderName then
            appendOut("Invalid format!", "ff4444")
            return
        end

        appendOut(string.format(">> Scanning [%s] %s / %s ...",
            objectName or "ALL", username, folderName), "aaaaff")

        -- Cari player
        local targetPlayer = nil
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p.Name:lower() == username:lower() then
                targetPlayer = p break
            end
        end
        if not targetPlayer then
            appendOut("Player '" .. username .. "' not found!", "ff4444") return
        end

        -- Cari folder
        local targetFolder = nil
        local LP = game.Players.LocalPlayer
        if folderName == "PlayerGui" then
            pcall(function() targetFolder = targetPlayer:FindFirstChild("PlayerGui") end)
        elseif folderName == "Backpack" then
            pcall(function() targetFolder = targetPlayer:FindFirstChild("Backpack") end)
        elseif folderName == "Character" then
            pcall(function() targetFolder = targetPlayer.Character end)
        else
            pcall(function() targetFolder = targetPlayer:FindFirstChild(folderName) end)
        end

        if not targetFolder then
            appendOut("Folder '" .. folderName .. "' not found!", "ff4444") return
        end

        -- Scan
        local found = {}
        local function scanF(parent, depth)
            if depth > 3 then return end
            for _, child in ipairs(parent:GetChildren()) do
                if not objectName or child.Name:lower():find(objectName:lower(), 1, true) then
                    table.insert(found, {name=child.Name, class=child.ClassName, depth=depth})
                end
                scanF(child, depth+1)
            end
        end
        pcall(function() scanF(targetFolder, 0) end)

        if #found == 0 then
            appendOut("Nothing found.", "ff8800") return
        end

        -- Clear output lalu tampil hasil
        outLabel.Text = ""
        appendOut(string.format("Found %d object(s) in %s/%s:", #found, username, folderName), "00ffcc")

        local duplicates = {}
        for _, item in ipairs(found) do
            local indent = string.rep("  ", item.depth)
            appendOut(string.format("%s[%s] %s", indent, item.class, item.name), "00ff44")
            -- Cek duplicate ScreenGui di PlayerGui local
            if item.class == "ScreenGui" and targetPlayer == LP then
                local pg = LP:FindFirstChild("PlayerGui")
                if pg and pg:FindFirstChild(item.name) then
                    appendOut(string.format('  !! DUPLICATE: "%s" exists in PlayerGui!', item.name), "4466ff")
                    table.insert(duplicates, item.name)
                end
            end
            task.wait(0.01)
        end

        -- Kalau ada duplicate → tawarin hapus
        if #duplicates > 0 then
            appendOut("", "ffffff")
            appendOut("Do.You.Want.To.Delete.The.New.GUI?", "4466ff")
            showYesNo(
                function()
                    -- YES → hapus new GUI
                    pcall(function()
                        local pg = LP:FindFirstChild("PlayerGui")
                        if pg then
                            for _, dn in ipairs(duplicates) do
                                local g = pg:FindFirstChild(dn)
                                if g then g:Destroy() end
                            end
                        end
                    end)
                    appendOut("New GUI(s) deleted.", "00ff88")
                    task.wait(0.5)
                    miniCmdOpen = false
                    mSg:Destroy()
                end,
                function()
                    -- NO → cuma tutup CMD
                    miniCmdOpen = false
                    mSg:Destroy()
                end
            )
        end
    end

    inputBox.FocusLost:Connect(function(enterPressed)
        if not enterPressed then return end
        local cmd = inputBox.Text
        if cmd == "" then return end
        appendOut("> " .. cmd, "cccccc")
        inputBox.Text = ""
        task.spawn(processCheckIn, cmd)
    end)
end

----------------------------------------------------
-- CHAT COMMAND /Open_Cmd
----------------------------------------------------
game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
    if msg:lower() == "/open_cmd" then
        task.spawn(openMiniCmd)
    end
end)