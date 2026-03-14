-- 🌙 SkyMoon ScriptHub | Mainscript.lua
-- by KHAFIDZKTP | github.com/HaZcK/ScriptHub

local RAW_PLACELIST = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/PlaceList.json"
local RAW_UNIVERSAL = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/Universal.json"
local UBUNTU_LOGO_URL = "https://tkj.smkdarmasiswasidoarjo.sch.id/wp-content/uploads/2024/08/61ef634e-0b5f-4d27-9fb6-c64d526c595c.png"
local GETKEY_URL = "https://hazck.github.io/ScriptHub/" -- ganti URL ini

-- Forward declarations
local openScriptList
local openMiniCmd
local showNotifSimple
local openAdminAuth
local openAdminPanel
local openGetKeyFrame
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
-- MAIN GUI
----------------------------------------------------
local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0, 280, 0, 140)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -70)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false -- hidden until key verified
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
-- KEY MEMORY SYSTEM
----------------------------------------------------
local KEY_MEMORY_FILE = "SkyMoon/KeyMemory.json"

local function loadKeyMemory()
    local default = {
        Key = "Null",
        Expired = false,
        SaveKey = true,
        CompletedAt = 0,
        DayNum = 0
    }
    pcall(function()
        if not isfolder("SkyMoon") then makefolder("SkyMoon") end
        if isfile(KEY_MEMORY_FILE) then
            local raw = readfile(KEY_MEMORY_FILE)
            if raw and raw ~= "" then
                local parsed = HttpService:JSONDecode(raw)
                for k, v in pairs(parsed) do default[k] = v end
            end
        end
    end)
    return default
end

local function saveKeyMemory(km)
    pcall(function()
        if not isfolder("SkyMoon") then makefolder("SkyMoon") end
        writefile(KEY_MEMORY_FILE, HttpService:JSONEncode(km))
    end)
end

-- Daily key algo (sama dengan HTML)
local function getDailyKey()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local dayNum = math.floor(os.time() / 86400)
    local state = (dayNum * 2654435761) % 4294967296
    local function lcg()
        state = (state * 1664525 + 1013904223) % 4294967296
        return state
    end
    local p1, p2 = "", ""
    for _ = 1, 4 do local idx=(lcg()%36)+1; p1=p1..chars:sub(idx,idx) end
    for _ = 1, 4 do local idx=(lcg()%36)+1; p2=p2..chars:sub(idx,idx) end
    return "SKY-"..p1.."-"..p2, math.floor(os.time()/86400)
end

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

    makeRow(buildTab, "🟦 Spawn Block Part", "Spawn", Color3.fromRGB(30,80,60), function() spawnPart(nil, nil, nil) end)
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
    end
    refreshGui()

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

-- Key auth prompt for /Open_Admin (terkoneksi ke KeyMemory.json)
openAdminAuth = function()
    local ok, err = pcall(function()
        local km = loadKeyMemory()
        local todayKey, todayDay = getDailyKey()

        if km.Key ~= "Null" and km.Key == todayKey and km.DayNum == todayDay and not km.Expired then
            local sSg = Instance.new("ScreenGui")
            sSg.Name = "SkyMoon_AdminCheck"
            sSg.ResetOnSpawn = false
            pcall(function() sSg.Parent = game.CoreGui end)
            if not sSg.Parent then sSg.Parent = LocalPlayer.PlayerGui end

            local frame = Instance.new("Frame", sSg)
            frame.Size = UDim2.new(0, 320, 0, 80)
            frame.Position = UDim2.new(0.5, -160, 0.5, -40)
            frame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
            frame.BorderSizePixel = 0
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
            local fs = Instance.new("UIStroke", frame)
            fs.Color = Color3.fromRGB(60, 80, 220)
            fs.Thickness = 1.5

            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1, -20, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "🔑 Status: Checking the Key..."
            lbl.TextColor3 = Color3.fromRGB(255, 200, 80)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local bar = Instance.new("Frame", frame)
            bar.Size = UDim2.new(0, 0, 0, 3)
            bar.Position = UDim2.new(0, 0, 1, -3)
            bar.BackgroundColor3 = Color3.fromRGB(60, 80, 220)
            bar.BorderSizePixel = 0
            TweenService:Create(bar, TweenInfo.new(1.2), {Size = UDim2.new(1, 0, 0, 3)}):Play()

            task.spawn(function()
                task.wait(1.2)
                lbl.Text = "✅ Status: Verifying the key has been completed!"
                lbl.TextColor3 = Color3.fromRGB(80, 220, 120)
                fs.Color = Color3.fromRGB(80, 220, 120)
                task.wait(1)
                sSg:Destroy()
                pcall(openAdminPanel)
            end)
            return
        end

        if km.Key ~= "Null" and km.Expired then
            showNotifSimple("🔑 Key expired! Get a new key at KeyMoon.", Color3.fromRGB(255, 80, 80))
        end

        -- Manual key input
        local authSg = Instance.new("ScreenGui")
        authSg.Name = "SkyMoon_Auth"
        authSg.ResetOnSpawn = false
        pcall(function() authSg.Parent = game.CoreGui end)
        if not authSg.Parent then authSg.Parent = LocalPlayer.PlayerGui end

        local win = Instance.new("Frame", authSg)
        win.Size = UDim2.new(0, 320, 0, 160)
        win.Position = UDim2.new(0.5, -160, 0.5, -80)
        win.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
        win.BorderSizePixel = 0
        win.Active = true
        win.Draggable = true
        Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)
        local ws = Instance.new("UIStroke", win)
        ws.Color = Color3.fromRGB(60, 80, 220)
        ws.Thickness = 1.5

        local tbar = Instance.new("Frame", win)
        tbar.Size = UDim2.new(1, 0, 0, 30)
        tbar.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
        tbar.BorderSizePixel = 0
        Instance.new("UICorner", tbar).CornerRadius = UDim.new(0, 12)
        local tfix = Instance.new("Frame", tbar)
        tfix.Size = UDim2.new(1, 0, 0.5, 0)
        tfix.Position = UDim2.new(0, 0, 0.5, 0)
        tfix.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
        tfix.BorderSizePixel = 0
        local tlbl = Instance.new("TextLabel", tbar)
        tlbl.Size = UDim2.new(1, 0, 1, 0)
        tlbl.BackgroundTransparency = 1
        tlbl.Text = "🔑 SkyMoon Admin — Enter Key"
        tlbl.TextColor3 = Color3.fromRGB(180, 190, 255)
        tlbl.Font = Enum.Font.GothamBold
        tlbl.TextSize = 12

        local hint = Instance.new("TextLabel", win)
        hint.Size = UDim2.new(1, -20, 0, 20)
        hint.Position = UDim2.new(0, 10, 0, 36)
        hint.BackgroundTransparency = 1
        hint.Text = "Get key: hazck.github.io/ScriptHub/KeyMoon.html"
        hint.TextColor3 = Color3.fromRGB(100, 110, 160)
        hint.Font = Enum.Font.Code
        hint.TextSize = 10
        hint.TextXAlignment = Enum.TextXAlignment.Left

        local inputBar = Instance.new("Frame", win)
        inputBar.Size = UDim2.new(1, -16, 0, 32)
        inputBar.Position = UDim2.new(0, 8, 0, 62)
        inputBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
        inputBar.BorderSizePixel = 0
        Instance.new("UICorner", inputBar).CornerRadius = UDim.new(0, 6)
        local ibs = Instance.new("UIStroke", inputBar)
        ibs.Color = Color3.fromRGB(60, 80, 180)
        ibs.Thickness = 1

        local inputBox = Instance.new("TextBox", inputBar)
        inputBox.Size = UDim2.new(1, -10, 1, 0)
        inputBox.Position = UDim2.new(0, 8, 0, 0)
        inputBox.BackgroundTransparency = 1
        inputBox.Text = ""
        inputBox.PlaceholderText = "SKY-XXXX-XXXX"
        inputBox.PlaceholderColor3 = Color3.fromRGB(60, 60, 90)
        inputBox.TextColor3 = Color3.fromRGB(200, 210, 255)
        inputBox.Font = Enum.Font.Code
        inputBox.TextSize = 13
        inputBox.ClearTextOnFocus = false

        local statusLbl = Instance.new("TextLabel", win)
        statusLbl.Size = UDim2.new(1, -16, 0, 20)
        statusLbl.Position = UDim2.new(0, 8, 0, 100)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = ""
        statusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
        statusLbl.Font = Enum.Font.Code
        statusLbl.TextSize = 12

        local enterBtn = Instance.new("TextButton", win)
        enterBtn.Size = UDim2.new(1, -16, 0, 30)
        enterBtn.Position = UDim2.new(0, 8, 1, -38)
        enterBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 160)
        enterBtn.Text = "Enter"
        enterBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
        enterBtn.Font = Enum.Font.GothamBold
        enterBtn.TextSize = 13
        enterBtn.BorderSizePixel = 0
        Instance.new("UICorner", enterBtn).CornerRadius = UDim.new(0, 6)

        local function tryAuth()
            local typed = inputBox.Text:match("^%s*(.-)%s*$")
            local validKey, validDay = getDailyKey()
            if typed == validKey then
                local kmNew = loadKeyMemory()
                kmNew.Key = validKey
                kmNew.Expired = false
                kmNew.DayNum = validDay
                kmNew.CompletedAt = os.time()
                saveKeyMemory(kmNew)
                statusLbl.Text = "✅ Verified!"
                statusLbl.TextColor3 = Color3.fromRGB(80, 220, 120)
                ibs.Color = Color3.fromRGB(80, 220, 120)
                task.wait(0.8)
                authSg:Destroy()
                pcall(openAdminPanel)
            else
                statusLbl.Text = "❌ Wrong key! Get it from KeyMoon.html"
                ibs.Color = Color3.fromRGB(255, 80, 80)
                TweenService:Create(win, TweenInfo.new(0.05), {Position = UDim2.new(0.5,-155,0.5,-80)}):Play()
                task.wait(0.05)
                TweenService:Create(win, TweenInfo.new(0.05), {Position = UDim2.new(0.5,-165,0.5,-80)}):Play()
                task.wait(0.05)
                TweenService:Create(win, TweenInfo.new(0.05), {Position = UDim2.new(0.5,-160,0.5,-80)}):Play()
                task.wait(1)
                ibs.Color = Color3.fromRGB(60, 80, 180)
            end
        end

        enterBtn.MouseButton1Click:Connect(function() pcall(tryAuth) end)
        inputBox.FocusLost:Connect(function(enter) if enter then pcall(tryAuth) end end)
    end)

    if not ok then
        warn("[SkyMoon] openAdminAuth error: " .. tostring(err))
        showNotifSimple("❌ Admin error: " .. tostring(err):sub(1,40), Color3.fromRGB(255,80,80))
    end
end

-- openMainHub: tampilkan main GUI
openMainHub = function()
    mainFrame.Visible = true
    TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 280, 0, 140)
    }):Play()
end

----------------------------------------------------
-- STATUS CHECK FRAME
----------------------------------------------------
local function showStatusCheck(onSuccess, onFail)
    local sSg = Instance.new("ScreenGui")
    sSg.Name = "SkyMoon_StatusCheck"
    sSg.ResetOnSpawn = false
    pcall(function() sSg.Parent = game.CoreGui end)
    if not sSg.Parent then sSg.Parent = LocalPlayer.PlayerGui end

    local frame = Instance.new("Frame", sSg)
    frame.Size = UDim2.new(0, 320, 0, 100)
    frame.Position = UDim2.new(0.5, -160, 0.5, -50)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local fs = Instance.new("UIStroke", frame)
    fs.Color = Color3.fromRGB(60, 80, 220)
    fs.Thickness = 1.5

    local icon = Instance.new("TextLabel", frame)
    icon.Size = UDim2.new(1, 0, 0, 30)
    icon.Position = UDim2.new(0, 0, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Text = "🔑 SkyMoon Key Verification"
    icon.TextColor3 = Color3.fromRGB(180, 190, 255)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 13

    local statusLbl = Instance.new("TextLabel", frame)
    statusLbl.Size = UDim2.new(1, -20, 0, 24)
    statusLbl.Position = UDim2.new(0, 10, 0, 44)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Status: Checking the Key..."
    statusLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
    statusLbl.Font = Enum.Font.Code
    statusLbl.TextSize = 12
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(0, 0, 0, 3)
    bar.Position = UDim2.new(0, 0, 1, -3)
    bar.BackgroundColor3 = Color3.fromRGB(60, 80, 220)
    bar.BorderSizePixel = 0
    TweenService:Create(bar, TweenInfo.new(1.5), {Size = UDim2.new(1, 0, 0, 3)}):Play()

    task.spawn(function()
        task.wait(1.2)

        local km = loadKeyMemory()
        local todayKey, todayDay = getDailyKey()

        -- Cek apakah key masih valid (hari sama)
        if km.Key == todayKey and km.DayNum == todayDay and not km.Expired then
            statusLbl.Text = "Status: Verifying the key has been completed!"
            statusLbl.TextColor3 = Color3.fromRGB(80, 220, 120)
            fs.Color = Color3.fromRGB(80, 220, 120)
            task.wait(1.2)
            sSg:Destroy()
            onSuccess()
        else
            -- Key expired atau berbeda hari
            if km.Key ~= "Null" then
                km.Expired = true
                saveKeyMemory(km)
                statusLbl.Text = "Status: Key expired! Get a new key."
                statusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
                fs.Color = Color3.fromRGB(255, 80, 80)
                task.wait(1.5)
            end
            sSg:Destroy()
            onFail()
        end
    end)
end

----------------------------------------------------
-- GET KEY FRAME
----------------------------------------------------
openGetKeyFrame = function()
    local gSg = Instance.new("ScreenGui")
    gSg.Name = "SkyMoon_GetKey"
    gSg.ResetOnSpawn = false
    pcall(function() gSg.Parent = game.CoreGui end)
    if not gSg.Parent then gSg.Parent = LocalPlayer.PlayerGui end

    local win = Instance.new("Frame", gSg)
    win.Size = UDim2.new(0, 340, 0, 260)
    win.Position = UDim2.new(0.5, -170, 0.5, -130)
    win.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 14)
    local ws = Instance.new("UIStroke", win)
    ws.Color = Color3.fromRGB(60, 80, 220)
    ws.Thickness = 1.5

    -- Gradient
    local wg = Instance.new("UIGradient", win)
    wg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 26)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 16)),
    })
    wg.Rotation = 135

    -- Title
    local tbar = Instance.new("Frame", win)
    tbar.Size = UDim2.new(1, 0, 0, 36)
    tbar.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
    tbar.BorderSizePixel = 0
    Instance.new("UICorner", tbar).CornerRadius = UDim.new(0, 14)
    local tfix = Instance.new("Frame", tbar)
    tfix.Size = UDim2.new(1, 0, 0.5, 0)
    tfix.Position = UDim2.new(0, 0, 0.5, 0)
    tfix.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
    tfix.BorderSizePixel = 0
    local tlbl = Instance.new("TextLabel", tbar)
    tlbl.Size = UDim2.new(1, 0, 1, 0)
    tlbl.BackgroundTransparency = 1
    tlbl.Text = "🌙  SkyMoon — Get Your Key"
    tlbl.TextColor3 = Color3.fromRGB(180, 190, 255)
    tlbl.Font = Enum.Font.GothamBold
    tlbl.TextSize = 13

    -- Step 1: Get Key URL
    local step1Lbl = Instance.new("TextLabel", win)
    step1Lbl.Size = UDim2.new(1, -20, 0, 16)
    step1Lbl.Position = UDim2.new(0, 10, 0, 44)
    step1Lbl.BackgroundTransparency = 1
    step1Lbl.Text = "STEP 1 — Complete the puzzle to get your key:"
    step1Lbl.TextColor3 = Color3.fromRGB(100, 110, 160)
    step1Lbl.Font = Enum.Font.Code
    step1Lbl.TextSize = 11
    step1Lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- URL bar
    local urlBar = Instance.new("Frame", win)
    urlBar.Size = UDim2.new(1, -16, 0, 32)
    urlBar.Position = UDim2.new(0, 8, 0, 64)
    urlBar.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
    urlBar.BorderSizePixel = 0
    Instance.new("UICorner", urlBar).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", urlBar).Color = Color3.fromRGB(50, 60, 160)

    local urlLbl = Instance.new("TextLabel", urlBar)
    urlLbl.Size = UDim2.new(1, -90, 1, 0)
    urlLbl.Position = UDim2.new(0, 8, 0, 0)
    urlLbl.BackgroundTransparency = 1
    urlLbl.Text = GETKEY_URL
    urlLbl.TextColor3 = Color3.fromRGB(120, 140, 220)
    urlLbl.Font = Enum.Font.Code
    urlLbl.TextSize = 11
    urlLbl.TextXAlignment = Enum.TextXAlignment.Left
    urlLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local copyUrlBtn = Instance.new("TextButton", urlBar)
    copyUrlBtn.Size = UDim2.new(0, 80, 0, 24)
    copyUrlBtn.Position = UDim2.new(1, -84, 0.5, -12)
    copyUrlBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 180)
    copyUrlBtn.Text = "Copy URL"
    copyUrlBtn.TextColor3 = Color3.fromRGB(200, 210, 255)
    copyUrlBtn.Font = Enum.Font.GothamBold
    copyUrlBtn.TextSize = 11
    copyUrlBtn.BorderSizePixel = 0
    Instance.new("UICorner", copyUrlBtn).CornerRadius = UDim.new(0, 5)

    copyUrlBtn.MouseButton1Click:Connect(function()
        -- Copy ke clipboard executor
        pcall(function() setclipboard(GETKEY_URL) end)
        copyUrlBtn.Text = "Copied!"
        copyUrlBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
        task.wait(2)
        copyUrlBtn.Text = "Copy URL"
        copyUrlBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 180)
    end)

    -- Step 2: Enter Key
    local step2Lbl = Instance.new("TextLabel", win)
    step2Lbl.Size = UDim2.new(1, -20, 0, 16)
    step2Lbl.Position = UDim2.new(0, 10, 0, 106)
    step2Lbl.BackgroundTransparency = 1
    step2Lbl.Text = "STEP 2 — Paste your key below:"
    step2Lbl.TextColor3 = Color3.fromRGB(100, 110, 160)
    step2Lbl.Font = Enum.Font.Code
    step2Lbl.TextSize = 11
    step2Lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Key input
    local inputBar = Instance.new("Frame", win)
    inputBar.Size = UDim2.new(1, -16, 0, 34)
    inputBar.Position = UDim2.new(0, 8, 0, 126)
    inputBar.BackgroundColor3 = Color3.fromRGB(16, 16, 28)
    inputBar.BorderSizePixel = 0
    Instance.new("UICorner", inputBar).CornerRadius = UDim.new(0, 6)
    local ibs = Instance.new("UIStroke", inputBar)
    ibs.Color = Color3.fromRGB(60, 80, 180)
    ibs.Thickness = 1

    local inputBox = Instance.new("TextBox", inputBar)
    inputBox.Size = UDim2.new(1, -12, 1, 0)
    inputBox.Position = UDim2.new(0, 8, 0, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.Text = ""
    inputBox.PlaceholderText = "SKY-XXXX-XXXX"
    inputBox.PlaceholderColor3 = Color3.fromRGB(60, 60, 90)
    inputBox.TextColor3 = Color3.fromRGB(200, 210, 255)
    inputBox.Font = Enum.Font.Code
    inputBox.TextSize = 14
    inputBox.ClearTextOnFocus = false
    inputBox.TextXAlignment = Enum.TextXAlignment.Center

    -- Status
    local statusLbl = Instance.new("TextLabel", win)
    statusLbl.Size = UDim2.new(1, -20, 0, 18)
    statusLbl.Position = UDim2.new(0, 10, 0, 168)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = ""
    statusLbl.Font = Enum.Font.Code
    statusLbl.TextSize = 11
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- SaveKey toggle
    local saveFrame = Instance.new("Frame", win)
    saveFrame.Size = UDim2.new(1, -16, 0, 24)
    saveFrame.Position = UDim2.new(0, 8, 0, 190)
    saveFrame.BackgroundTransparency = 1
    saveFrame.BorderSizePixel = 0

    local saveCheck = Instance.new("TextButton", saveFrame)
    saveCheck.Size = UDim2.new(0, 20, 0, 20)
    saveCheck.Position = UDim2.new(0, 0, 0, 2)
    saveCheck.BackgroundColor3 = Color3.fromRGB(40, 60, 180)
    saveCheck.Text = "✓"
    saveCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveCheck.Font = Enum.Font.GothamBold
    saveCheck.TextSize = 12
    saveCheck.BorderSizePixel = 0
    Instance.new("UICorner", saveCheck).CornerRadius = UDim.new(0, 4)

    local saveVal = true
    local saveLbl = Instance.new("TextLabel", saveFrame)
    saveLbl.Size = UDim2.new(1, -28, 1, 0)
    saveLbl.Position = UDim2.new(0, 26, 0, 0)
    saveLbl.BackgroundTransparency = 1
    saveLbl.Text = "SaveKey — Remember key, skip next time"
    saveLbl.TextColor3 = Color3.fromRGB(120, 130, 180)
    saveLbl.Font = Enum.Font.Code
    saveLbl.TextSize = 11
    saveLbl.TextXAlignment = Enum.TextXAlignment.Left

    saveCheck.MouseButton1Click:Connect(function()
        saveVal = not saveVal
        saveCheck.Text = saveVal and "✓" or ""
        saveCheck.BackgroundColor3 = saveVal and Color3.fromRGB(40,60,180) or Color3.fromRGB(30,30,40)
    end)

    -- Verify button
    local verifyBtn = Instance.new("TextButton", win)
    verifyBtn.Size = UDim2.new(1, -16, 0, 34)
    verifyBtn.Position = UDim2.new(0, 8, 1, -42)
    verifyBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 160)
    verifyBtn.Text = "🔑  Verify Key"
    verifyBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.TextSize = 14
    verifyBtn.BorderSizePixel = 0
    Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 8)
    local vs = Instance.new("UIStroke", verifyBtn)
    vs.Color = Color3.fromRGB(80, 120, 255)
    vs.Thickness = 1

    local function tryVerify()
        local typed = inputBox.Text:match("^%s*(.-)%s*$")
        local todayKey, todayDay = getDailyKey()

        if typed == todayKey then
            -- ✅ Correct
            statusLbl.Text = "✅ Key verified!"
            statusLbl.TextColor3 = Color3.fromRGB(80, 220, 120)
            ibs.Color = Color3.fromRGB(80, 220, 120)
            verifyBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 60)

            -- Save to KeyMemory.json
            local km = loadKeyMemory()
            km.Key = todayKey
            km.Expired = false
            km.SaveKey = saveVal
            km.CompletedAt = os.time()
            km.DayNum = todayDay
            saveKeyMemory(km)

            task.wait(1)
            gSg:Destroy()
            openMainHub()
        else
            -- ❌ Wrong
            statusLbl.Text = "❌ Wrong key! Complete the puzzle at the URL above."
            statusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
            ibs.Color = Color3.fromRGB(255, 80, 80)
            -- Shake
            TweenService:Create(win, TweenInfo.new(0.05), {Position = UDim2.new(0.5,-165,0.5,-130)}):Play()
            task.wait(0.05)
            TweenService:Create(win, TweenInfo.new(0.05), {Position = UDim2.new(0.5,-175,0.5,-130)}):Play()
            task.wait(0.05)
            TweenService:Create(win, TweenInfo.new(0.05), {Position = UDim2.new(0.5,-170,0.5,-130)}):Play()
            task.wait(1)
            ibs.Color = Color3.fromRGB(60, 80, 180)
        end
    end

    verifyBtn.MouseButton1Click:Connect(tryVerify)
    inputBox.FocusLost:Connect(function(enter) if enter then tryVerify() end end)
end

----------------------------------------------------
-- STARTUP FLOW
----------------------------------------------------
task.spawn(function()
    task.wait(0.3) -- tunggu sebentar biar game load

    local km = loadKeyMemory()
    local todayKey, todayDay = getDailyKey()

    if km.SaveKey and km.Key ~= "Null" and km.DayNum == todayDay and not km.Expired then
        -- Key tersimpan dan masih valid → status check
        showStatusCheck(
            function() openMainHub() end,   -- success
            function() openGetKeyFrame() end -- fail/expired
        )
    else
        -- Belum punya key / expired → GetKey frame
        openGetKeyFrame()
    end
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
        task.spawn(openAdminAuth)
    end
end)
