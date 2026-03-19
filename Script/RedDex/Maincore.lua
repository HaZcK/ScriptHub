-- ╔══════════════════════════════════════════╗
-- ║         UniverseHub - Maincore           ║
-- ║         Author: Khafidz (KHAFIDZKTP)    ║
-- ╚══════════════════════════════════════════╝
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/RedDex/Maincore.lua"))()

-- ══════════════════════════════════════════
--               SERVICES
-- ══════════════════════════════════════════
local Players      = game:GetService("Players")
local HttpService  = game:GetService("HttpService")
local UIS          = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ══════════════════════════════════════════
--           FOLDER & JSON SETUP
-- ══════════════════════════════════════════
local FOLDER    = "GlobalHub"
local JSON_FILE = FOLDER .. "/ScriptUser.json"

if not isfolder(FOLDER) then makefolder(FOLDER) end

local scriptList = {}
if isfile(JSON_FILE) then
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(JSON_FILE))
    end)
    if ok and type(data) == "table" then
        scriptList = data
    end
end

local function saveScripts()
    writefile(JSON_FILE, HttpService:JSONEncode(scriptList))
end

-- ══════════════════════════════════════════
--           VALIDATION FUNCTIONS
-- ══════════════════════════════════════════

-- Cek format tanggal D/M/YYYY
local function validateDate(dateStr)
    if not dateStr or dateStr == "" then return false, "Tanggal wajib diisi!" end
    local d, m, y = dateStr:match("^(%d+)/(%d+)/(%d+)$")
    if not d then return false, "Format tanggal salah! Contoh: 1/7/2025" end
    d, m, y = tonumber(d), tonumber(m), tonumber(y)
    if d < 1 or d > 31 then return false, "Hari tidak valid! (1-31)" end
    if m < 1 or m > 12 then return false, "Bulan tidak valid! (1-12)" end
    if y < 2000 or y > 2100 then return false, "Tahun tidak valid!" end
    return true
end

-- Cek validitas kode script (panjang + syntax)
local function validateCode(code)
    if not code or code == "" then return false, "Script wajib diisi!" end
    if #code < 5 then return false, "Script terlalu pendek / tidak valid!" end
    -- Cek syntax via loadstring
    local fn, err = loadstring(code)
    if not fn then
        -- Potong pesan error agar lebih ramah
        local short = tostring(err):match("%[.-%]:(.+)") or tostring(err)
        return false, "Syntax Error: " .. short
    end
    return true
end

-- Cek apakah nama game ada di Roblox (case-sensitive exact match)
local function validateGame(gameName)
    if not gameName or gameName == "" then return false, "Nama game wajib diisi!" end
    local ok, result = pcall(function()
        local encoded = HttpService:UrlEncode(gameName)
        local url = "https://games.roblox.com/v1/games/search?keyword=" .. encoded .. "&limit=25"
        local raw = game:HttpGet(url)
        local data = HttpService:JSONDecode(raw)
        if data and data.data then
            for _, g in ipairs(data.data) do
                if g.name == gameName then   -- exact case-sensitive match
                    return true
                end
            end
        end
        return false
    end)
    if not ok then
        return false, "Gagal menghubungi Roblox API!"
    end
    if not result then
        return false, "Game Not Found!"
    end
    return true
end

-- ══════════════════════════════════════════
--               WINDUI SETUP
-- ══════════════════════════════════════════
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title  = "UniverseHub",
    Icon   = "aperture",
    Author = "Khafidz",
    Folder = FOLDER,
    User   = {
        Enabled   = true,
        Anonymous = false,
        Callback  = function()
            print("Display Name : " .. player.DisplayName)
            print("Username     : " .. player.Name)
            print("ID           : " .. tostring(player.UserId))
            WindUI:Notify({
                Title   = "Info Player",
                Content = "Logged in sebagai: " .. player.DisplayName,
                Duration = 4,
            })
        end,
    },
})

Window:Tag({
    Title  = "1.0",
    Icon   = "file-text",
    Color  = Color3.fromHex("#87CEEB"),
    Radius = 0.5,
})

local TabScripts = Window:Tab({ Title = "Scripts",    Icon = "library"  })
local TabAdd     = Window:Tab({ Title = "Add Script", Icon = "plus"     })
local TabLog     = Window:Tab({ Title = "Update Log", Icon = "scroll-text" })

-- ══════════════════════════════════════════
--         UPDATE LOG TAB
-- ══════════════════════════════════════════
TabLog:Paragraph({
    Title = "Update Log",
    Desc  = "WHERE IS THERE AN UPDATE THAT IS STILL RELEASED",
    Color = "Blue",
})

-- ══════════════════════════════════════════
--          CODERBOX GUI (Roblox Frame)
-- ══════════════════════════════════════════
local Gui = Instance.new("ScreenGui")
Gui.Name           = "CoderBox"
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent         = player.PlayerGui

-- Overlay gelap
local Overlay = Instance.new("Frame")
Overlay.Size                = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3    = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.5
Overlay.BorderSizePixel     = 0
Overlay.Visible             = false
Overlay.ZIndex              = 5
Overlay.Parent              = Gui

-- Main frame
local BG = Instance.new("Frame")
BG.Size             = UDim2.new(0, 540, 0, 450)
BG.Position         = UDim2.new(0.5, -270, 0.5, -225)
BG.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
BG.BorderSizePixel  = 0
BG.Visible          = false
BG.ZIndex           = 6
BG.Parent           = Gui
Instance.new("UICorner", BG).CornerRadius = UDim.new(0, 12)

-- Header bar
local Header = Instance.new("Frame")
Header.Size             = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
Header.BorderSizePixel  = 0
Header.ZIndex           = 7
Header.Parent           = BG
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local HeaderFix = Instance.new("Frame")
HeaderFix.Size             = UDim2.new(1, 0, 0.5, 0)
HeaderFix.Position         = UDim2.new(0, 0, 0.5, 0)
HeaderFix.BackgroundColor3 = Color3.fromRGB(22, 22, 38)
HeaderFix.BorderSizePixel  = 0
HeaderFix.ZIndex           = 7
HeaderFix.Parent           = Header

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size               = UDim2.new(1, -60, 1, 0)
HeaderLabel.Position           = UDim2.new(0, 16, 0, 0)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text               = "📝  CoderBox"
HeaderLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
HeaderLabel.Font               = Enum.Font.GothamBold
HeaderLabel.TextSize           = 15
HeaderLabel.TextXAlignment     = Enum.TextXAlignment.Left
HeaderLabel.ZIndex             = 8
HeaderLabel.Parent             = Header

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size               = UDim2.new(0, 32, 0, 32)
CloseBtn.Position           = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3   = Color3.fromRGB(200, 60, 60)
CloseBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
CloseBtn.Font               = Enum.Font.GothamBold
CloseBtn.TextSize           = 16
CloseBtn.Text               = "✕"
CloseBtn.BorderSizePixel    = 0
CloseBtn.ZIndex             = 8
CloseBtn.Parent             = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- CodeBox TextBox
local CodeBox = Instance.new("TextBox")
CodeBox.Size             = UDim2.new(1, -24, 1, -108)
CodeBox.Position         = UDim2.new(0, 12, 0, 58)
CodeBox.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
CodeBox.TextColor3       = Color3.fromHex("#87CEEB")
CodeBox.Font             = Enum.Font.Code
CodeBox.TextSize         = 13
CodeBox.Text             = ""
CodeBox.PlaceholderText  = "-- Write your script here...\n-- Contoh: loadstring(game:HttpGet('url'))()"
CodeBox.PlaceholderColor3 = Color3.fromRGB(70, 70, 95)
CodeBox.MultiLine        = true
CodeBox.ClearTextOnFocus = false
CodeBox.TextXAlignment   = Enum.TextXAlignment.Left
CodeBox.TextYAlignment   = Enum.TextYAlignment.Top
CodeBox.BorderSizePixel  = 0
CodeBox.ZIndex           = 7
CodeBox.Parent           = BG
Instance.new("UICorner", CodeBox).CornerRadius = UDim.new(0, 8)

local CBPad = Instance.new("UIPadding")
CBPad.PaddingLeft  = UDim.new(0, 10)
CBPad.PaddingTop   = UDim.new(0, 8)
CBPad.PaddingRight = UDim.new(0, 8)
CBPad.Parent       = CodeBox

-- Done Button
local DoneBtn = Instance.new("TextButton")
DoneBtn.Size             = UDim2.new(0, 160, 0, 40)
DoneBtn.Position         = UDim2.new(0.5, -80, 1, -50)
DoneBtn.BackgroundColor3 = Color3.fromHex("#87CEEB")
DoneBtn.TextColor3       = Color3.fromRGB(10, 10, 20)
DoneBtn.Font             = Enum.Font.GothamBold
DoneBtn.TextSize         = 14
DoneBtn.Text             = "✓  Done"
DoneBtn.BorderSizePixel  = 0
DoneBtn.ZIndex           = 7
DoneBtn.Parent           = BG
Instance.new("UICorner", DoneBtn).CornerRadius = UDim.new(0, 8)

local function openCoderBox()
    Overlay.Visible = true
    BG.Visible      = true
end

local function closeCoderBox()
    Overlay.Visible = false
    BG.Visible      = false
end

CloseBtn.MouseButton1Click:Connect(closeCoderBox)

-- ══════════════════════════════════════════
--           FORM STATE
-- ══════════════════════════════════════════
local form = {
    title    = "",
    desc     = "",
    code     = "",
    canRemix = false,
    forGame  = false,
    nameGame = "",
    release  = "",
}

local function resetForm()
    form = {
        title    = "",
        desc     = "",
        code     = "",
        canRemix = false,
        forGame  = false,
        nameGame = "",
        release  = "",
    }
    CodeBox.Text = ""
end

-- ══════════════════════════════════════════
--           RENDER SCRIPT CARD
-- ══════════════════════════════════════════
local function renderCard(entry)
    local gameTag  = entry.Game and ("🎮 " .. (entry.NameGame or "?")) or "🌐 General"
    local remixTag = entry.CanRemix and "✅ Remix" or "🔒 No Remix"

    local CardBtn = TabScripts:Button({
        Title = entry.Title,
        Desc  = "👤 " .. entry.Username
              .. "  •  " .. gameTag
              .. "  •  " .. remixTag
              .. "  •  📅 " .. entry.Release,
        Icon  = "code-2",
        Callback = function()
            WindUI:Notify({
                Title   = entry.Title,
                Content = entry.Description,
                Duration = 5,
            })
        end,
    })

    -- Hold to Remix detection
    if CardBtn and CardBtn.Frame then
        local holding    = false
        local holdThread = nil

        CardBtn.Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                holding    = true
                holdThread = task.delay(0.65, function()
                    if not holding then return end
                    if not entry.CanRemix then
                        WindUI:Notify({
                            Title   = "🔒 Remix Ditolak",
                            Content = "Creator does not allow to be remixed!",
                            Duration = 4,
                        })
                    else
                        WindUI:Notify({
                            Title   = "⏳ Wait...",
                            Content = "Mengambil script dari " .. entry.Username .. "...",
                            Duration = 2,
                        })
                        task.wait(1.5)
                        WindUI:Notify({
                            Title   = "📋 " .. entry.Title,
                            Content = entry.Code,
                            Duration = 10,
                        })
                    end
                end)
            end
        end)

        CardBtn.Frame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                holding = false
            end
        end)
    end
end

-- Render existing scripts dari JSON
for _, entry in ipairs(scriptList) do
    renderCard(entry)
end

-- ══════════════════════════════════════════
--          ADD SCRIPT TAB - FORM
-- ══════════════════════════════════════════
TabAdd:Section({ Title = "Script Info" })

TabAdd:Input({
    Title       = "Title",
    Placeholder = "Nama script kamu...",
    Callback    = function(v) form.title = v end,
})

TabAdd:Input({
    Title       = "Description",
    Placeholder = "Jelaskan tujuan script ini...",
    Callback    = function(v) form.desc = v end,
})

TabAdd:Input({
    Title       = "Release Date",
    Placeholder = "Format: D/M/YYYY  →  contoh: 1/7/2025",
    Callback    = function(v) form.release = v end,
})

TabAdd:Separator()
TabAdd:Section({ Title = "Game Info" })

TabAdd:Toggle({
    Title    = "For Specific Game",
    Default  = false,
    Callback = function(v) form.forGame = v end,
})

TabAdd:Input({
    Title       = "Game Name",
    Placeholder = "Nama game PERSIS seperti di Roblox (Case Sensitive!)",
    Callback    = function(v) form.nameGame = v end,
})

TabAdd:Separator()
TabAdd:Section({ Title = "Permission" })

TabAdd:Toggle({
    Title    = "Allow Remix",
    Default  = false,
    Callback = function(v) form.canRemix = v end,
})

TabAdd:Separator()
TabAdd:Section({ Title = "Code" })

TabAdd:Button({
    Title    = "Open CoderBox",
    Icon     = "terminal",
    Callback = function()
        CodeBox.Text = form.code
        openCoderBox()
    end,
})

TabAdd:Separator()

-- ══════════════════════════════════════════
--         ADD BUTTON + VALIDATION
-- ══════════════════════════════════════════
local function showError(title, msg)
    WindUI:Notify({
        Title   = "❌ " .. title,
        Content = msg .. "\n\nPerbaiki lalu klik Add lagi.",
        Duration = 6,
    })
end

TabAdd:Button({
    Title    = "✚  Add Script",
    Icon     = "plus-circle",
    Callback = function()

        -- 1) Cek Title
        if form.title == "" then
            showError("Validation Error", "Title wajib diisi!")
            return
        end

        -- 2) Cek Description
        if form.desc == "" then
            showError("Validation Error", "Description wajib diisi!")
            return
        end

        -- 3) Cek Tanggal
        local dateOk, dateErr = validateDate(form.release)
        if not dateOk then
            showError("Date Error", dateErr)
            return
        end

        -- 4) Cek Code
        local codeOk, codeErr = validateCode(form.code)
        if not codeOk then
            showError("Code Error", codeErr)
            return
        end

        -- 5) Cek Game Name (jika For Specific Game aktif)
        if form.forGame then
            if form.nameGame == "" then
                showError("Game Error", "Nama game wajib diisi jika 'For Specific Game' aktif!")
                return
            end

            -- Notifikasi loading
            WindUI:Notify({
                Title   = "🔍 Checking...",
                Content = "Memvalidasi nama game di Roblox...",
                Duration = 3,
            })

            local gameOk, gameErr = validateGame(form.nameGame)
            if not gameOk then
                showError("Game Error", gameErr)
                return
            end
        end

        -- ✅ Semua valid → simpan
        local entry = {
            Username    = player.Name,
            Title       = form.title,
            Code        = form.code,
            CanRemix    = form.canRemix,
            Release     = form.release,
            Description = form.desc,
            Game        = form.forGame,
            NameGame    = form.forGame and form.nameGame or nil,
        }

        table.insert(scriptList, entry)
        saveScripts()
        renderCard(entry)

        WindUI:Notify({
            Title   = "✅ Berhasil!",
            Content = "\"" .. form.title .. "\" berhasil ditambahkan!",
            Duration = 4,
        })

        resetForm()
    end,
})

-- ══════════════════════════════════════════
--         CODERBOX DONE BUTTON
-- ══════════════════════════════════════════
DoneBtn.MouseButton1Click:Connect(function()
    local code = CodeBox.Text

    -- Validasi cepat di CoderBox
    local ok, err = validateCode(code)
    if not ok then
        WindUI:Notify({
            Title   = "❌ Code Error",
            Content = err .. "\n\nFix script kamu lalu klik Done lagi.",
            Duration = 5,
        })
        return
    end

    form.code = code
    closeCoderBox()
    WindUI:Notify({
        Title   = "✅ CoderBox",
        Content = "Script tersimpan! Klik Add Script untuk submit.",
        Duration = 3,
    })
end)
