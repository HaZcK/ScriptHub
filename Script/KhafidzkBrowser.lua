--[[
    ██╗  ██╗██████╗     ██████╗ ██████╗  ██████╗ ██╗    ██╗███████╗███████╗██████╗
    ██║ ██╔╝██╔══██╗    ██╔══██╗██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔════╝██╔══██╗
    █████╔╝ ██████╔╝    ██████╔╝██████╔╝██║   ██║██║ █╗ ██║███████╗█████╗  ██████╔╝
    ██╔═██╗ ██╔══██╗    ██╔══██╗██╔══██╗██║   ██║██║███╗██║╚════██║██╔══╝  ██╔══██╗
    ██║  ██╗██████╔╝    ██████╔╝██║  ██║╚██████╔╝╚███╔███╔╝███████║███████╗██║  ██║
    ╚═╝  ╚═╝╚═════╝     ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚══════╝╚══════╝╚═╝  ╚═╝
    
    Script oleh KHAFIDZKTP
    Layar Browser Roblox — Login → Browse → Salin/Download
    Posisi layar: Y = 120 (tidak menghalangi map)
--]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")
local LocalPlayer    = Players.LocalPlayer

-- ============================================================
-- AKUN DEMO (username = password)
-- Tambah akun sesuai kebutuhan
-- ============================================================
local ACCOUNTS = {
    ["Agus"]    = "67677",
    ["Yanto"]   = "yanto99",
    ["Admin"]   = "admin123",
    ["KHAFIDZ"] = "ktp2024",
    ["Guest"]   = "guest",
}

-- ============================================================
-- WARNA TEMA
-- ============================================================
local C = {
    BG       = Color3.fromRGB(12, 12, 18),
    PANEL    = Color3.fromRGB(22, 22, 34),
    PANEL2   = Color3.fromRGB(32, 32, 50),
    ACCENT   = Color3.fromRGB(80, 160, 255),
    ACCENT2  = Color3.fromRGB(120, 90, 255),
    SUCCESS  = Color3.fromRGB(60, 210, 120),
    DANGER   = Color3.fromRGB(255, 75, 75),
    WARNING  = Color3.fromRGB(255, 200, 60),
    TEXT     = Color3.fromRGB(220, 225, 240),
    SUBTEXT  = Color3.fromRGB(120, 125, 150),
    WHITE    = Color3.fromRGB(255, 255, 255),
    BLACK    = Color3.fromRGB(8, 8, 12),
    LOADBAR  = Color3.fromRGB(80, 160, 255),
}

-- ============================================================
-- HELPER: Buat corner radius
-- ============================================================
local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or C.ACCENT
    s.Thickness = thickness or 1.5
    s.Transparency = 0.6
    s.Parent = parent
end

local function Tween(obj, props, duration, style, direction)
    return TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        props
    )
end

-- ============================================================
-- BUAT BASEPLATE (jika belum ada)
-- ============================================================
local function EnsureBaseplate()
    if not workspace:FindFirstChild("Baseplate") then
        local bp = Instance.new("Part")
        bp.Name       = "Baseplate"
        bp.Size       = Vector3.new(512, 1, 512)
        bp.Position   = Vector3.new(0, -0.5, 0)
        bp.Anchored   = true
        bp.Material   = Enum.Material.SmoothPlastic
        bp.Color      = Color3.fromRGB(80, 90, 75)
        bp.Parent     = workspace
    end
end

EnsureBaseplate()

-- ============================================================
-- BUAT TIANG PENYANGGA + LAYAR DI Y = 120
-- ============================================================

-- Tiang
local pole = Instance.new("Part")
pole.Name      = "BrowserPole"
pole.Size      = Vector3.new(1, 120, 1)
pole.Position  = Vector3.new(0, 60, -2)
pole.Anchored  = true
pole.CanCollide = false
pole.Material  = Enum.Material.Metal
pole.Color     = Color3.fromRGB(40, 40, 55)
pole.Parent    = workspace

-- Bingkai layar
local frame = Instance.new("Part")
frame.Name      = "BrowserFrame"
frame.Size      = Vector3.new(44, 25, 0.6)
frame.Position  = Vector3.new(0, 120, -2)
frame.Anchored  = true
frame.CanCollide = false
frame.Material  = Enum.Material.SmoothPlastic
frame.Color     = Color3.fromRGB(18, 18, 28)
frame.CastShadow = false
frame.Parent    = workspace
Corner(frame, 10)

-- Layar utama (sedikit masuk ke dalam bingkai)
local screen = Instance.new("Part")
screen.Name      = "BrowserScreen"
screen.Size      = Vector3.new(43, 24, 0.1)
screen.Position  = Vector3.new(0, 120, -1.65)
screen.Anchored  = true
screen.CanCollide = false
screen.Material  = Enum.Material.SmoothPlastic
screen.Color     = Color3.fromRGB(5, 5, 10)
screen.CastShadow = false
screen.Parent    = workspace

-- ============================================================
-- SURFACE GUI
-- ============================================================
local sg = Instance.new("SurfaceGui")
sg.Name           = "KBrowserGui"
sg.Face           = Enum.NormalId.Front
sg.SizingMode     = Enum.SurfaceGuiSizingMode.PixelsPerStud
sg.PixelsPerStud  = 50
sg.CanvasSize     = Vector2.new(2150, 1200)
sg.AlwaysOnTop    = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = screen

-- Root container
local root = Instance.new("Frame")
root.Size                = UDim2.new(1, 0, 1, 0)
root.BackgroundColor3    = C.BG
root.BorderSizePixel     = 0
root.ClipsDescendants    = true
root.Parent              = sg

-- ============================================================
-- ================  LOGIN SCREEN  ============================
-- ============================================================
local loginPage = Instance.new("Frame")
loginPage.Name             = "LoginPage"
loginPage.Size             = UDim2.new(1, 0, 1, 0)
loginPage.BackgroundColor3 = C.BG
loginPage.BorderSizePixel  = 0
loginPage.ZIndex           = 10
loginPage.Parent           = root

-- Background gradient
local loginGrad = Instance.new("UIGradient")
loginGrad.Color    = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 10, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 22)),
})
loginGrad.Rotation = 135
loginGrad.Parent   = loginPage

-- Card container
local card = Instance.new("Frame")
card.Size             = UDim2.new(0, 700, 0, 600)
card.Position         = UDim2.new(0.5, -350, 0.5, -300)
card.BackgroundColor3 = C.PANEL
card.BorderSizePixel  = 0
card.ZIndex           = 11
card.Parent           = loginPage
Corner(card, 20)
Stroke(card, C.ACCENT2, 1.5)

-- Card gradient
local cardGrad = Instance.new("UIGradient")
cardGrad.Color    = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 25, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 32)),
})
cardGrad.Rotation = 180
cardGrad.Parent   = card

-- Logo / title
local logo = Instance.new("TextLabel")
logo.Size             = UDim2.new(0.85, 0, 0, 70)
logo.Position         = UDim2.new(0.075, 0, 0, 50)
logo.BackgroundTransparency = 1
logo.Text             = "🌐  KHAFIDZ BROWSER"
logo.TextColor3       = C.WHITE
logo.Font             = Enum.Font.GothamBold
logo.TextSize         = 44
logo.ZIndex           = 12
logo.Parent           = card

-- Subtitle
local sub = Instance.new("TextLabel")
sub.Size             = UDim2.new(0.85, 0, 0, 36)
sub.Position         = UDim2.new(0.075, 0, 0, 120)
sub.BackgroundTransparency = 1
sub.Text             = "Masuk untuk mulai menjelajah"
sub.TextColor3       = C.SUBTEXT
sub.Font             = Enum.Font.Gotham
sub.TextSize         = 26
sub.ZIndex           = 12
sub.Parent           = card

-- Divider
local div = Instance.new("Frame")
div.Size             = UDim2.new(0.85, 0, 0, 1.5)
div.Position         = UDim2.new(0.075, 0, 0, 168)
div.BackgroundColor3 = C.ACCENT2
div.BackgroundTransparency = 0.7
div.BorderSizePixel  = 0
div.ZIndex           = 12
div.Parent           = card

-- Username label
local userLbl = Instance.new("TextLabel")
userLbl.Size             = UDim2.new(0.85, 0, 0, 28)
userLbl.Position         = UDim2.new(0.075, 0, 0, 190)
userLbl.BackgroundTransparency = 1
userLbl.Text             = "USERNAME"
userLbl.TextColor3       = C.SUBTEXT
userLbl.Font             = Enum.Font.GothamBold
userLbl.TextSize         = 20
userLbl.TextXAlignment   = Enum.TextXAlignment.Left
userLbl.ZIndex           = 12
userLbl.Parent           = card

-- Username box
local userBox = Instance.new("TextBox")
userBox.Size             = UDim2.new(0.85, 0, 0, 62)
userBox.Position         = UDim2.new(0.075, 0, 0, 222)
userBox.BackgroundColor3 = C.PANEL2
userBox.BorderSizePixel  = 0
userBox.Text             = ""
userBox.PlaceholderText  = "Masukkan username..."
userBox.TextColor3       = C.TEXT
userBox.PlaceholderColor3= C.SUBTEXT
userBox.Font             = Enum.Font.Gotham
userBox.TextSize         = 28
userBox.ZIndex           = 12
userBox.ClearTextOnFocus = false
userBox.Parent           = card
Corner(userBox, 10)
Stroke(userBox, C.ACCENT, 1.5)

-- Password label
local passLbl = Instance.new("TextLabel")
passLbl.Size             = UDim2.new(0.85, 0, 0, 28)
passLbl.Position         = UDim2.new(0.075, 0, 0, 300)
passLbl.BackgroundTransparency = 1
passLbl.Text             = "PASSWORD"
passLbl.TextColor3       = C.SUBTEXT
passLbl.Font             = Enum.Font.GothamBold
passLbl.TextSize         = 20
passLbl.TextXAlignment   = Enum.TextXAlignment.Left
passLbl.ZIndex           = 12
passLbl.Parent           = card

-- Password box
local passBox = Instance.new("TextBox")
passBox.Size             = UDim2.new(0.85, 0, 0, 62)
passBox.Position         = UDim2.new(0.075, 0, 0, 332)
passBox.BackgroundColor3 = C.PANEL2
passBox.BorderSizePixel  = 0
passBox.Text             = ""
passBox.PlaceholderText  = "Masukkan password..."
passBox.TextColor3       = C.TEXT
passBox.PlaceholderColor3= C.SUBTEXT
passBox.Font             = Enum.Font.Gotham
passBox.TextSize         = 28
passBox.ZIndex           = 12
passBox.ClearTextOnFocus = false
passBox.Parent           = card
Corner(passBox, 10)
Stroke(passBox, C.ACCENT, 1.5)

-- Hide password (•••)
passBox:GetPropertyChangedSignal("Text"):Connect(function()
    -- Roblox TextBox tidak punya mode password bawaan
    -- kita simpan nilai asli dan tampilkan bintang via label overlay
end)

-- Password star overlay
local passOverlay = Instance.new("TextLabel")
passOverlay.Size             = UDim2.new(1, -20, 1, 0)
passOverlay.Position         = UDim2.new(0, 10, 0, 0)
passOverlay.BackgroundTransparency = 1
passOverlay.Text             = ""
passOverlay.TextColor3       = C.TEXT
passOverlay.Font             = Enum.Font.Gotham
passOverlay.TextSize         = 28
passOverlay.TextXAlignment   = Enum.TextXAlignment.Left
passOverlay.ZIndex           = 13
passOverlay.Parent           = passBox

local realPass = ""
passBox:GetPropertyChangedSignal("Text"):Connect(function()
    local new = passBox.Text
    if #new > #realPass then
        realPass = realPass .. new:sub(#realPass + 1)
    elseif #new < #realPass then
        realPass = realPass:sub(1, #new)
    end
    passBox.Text = string.rep("•", #realPass)
    passOverlay.Text = string.rep("•", #realPass)
end)

-- Status msg
local loginStatus = Instance.new("TextLabel")
loginStatus.Size             = UDim2.new(0.85, 0, 0, 36)
loginStatus.Position         = UDim2.new(0.075, 0, 0, 408)
loginStatus.BackgroundTransparency = 1
loginStatus.Text             = ""
loginStatus.TextColor3       = C.DANGER
loginStatus.Font             = Enum.Font.Gotham
loginStatus.TextSize         = 24
loginStatus.ZIndex           = 12
loginStatus.Parent           = card

-- Login button
local loginBtn = Instance.new("TextButton")
loginBtn.Size             = UDim2.new(0.85, 0, 0, 64)
loginBtn.Position         = UDim2.new(0.075, 0, 0, 454)
loginBtn.BackgroundColor3 = C.ACCENT
loginBtn.BorderSizePixel  = 0
loginBtn.Text             = "  MASUK"
loginBtn.TextColor3       = C.BLACK
loginBtn.Font             = Enum.Font.GothamBold
loginBtn.TextSize         = 30
loginBtn.ZIndex           = 12
loginBtn.AutoButtonColor  = false
loginBtn.Parent           = card
Corner(loginBtn, 12)

-- Button hover effect
loginBtn.MouseEnter:Connect(function()
    Tween(loginBtn, {BackgroundColor3 = C.ACCENT2}, 0.2):Play()
    Tween(loginBtn, {TextColor3 = C.WHITE}, 0.2):Play()
end)
loginBtn.MouseLeave:Connect(function()
    Tween(loginBtn, {BackgroundColor3 = C.ACCENT}, 0.2):Play()
    Tween(loginBtn, {TextColor3 = C.BLACK}, 0.2):Play()
end)

-- Hint
local hint = Instance.new("TextLabel")
hint.Size             = UDim2.new(0.85, 0, 0, 30)
hint.Position         = UDim2.new(0.075, 0, 0, 538)
hint.BackgroundTransparency = 1
hint.Text             = 'Contoh: Username "Agus" | Password "67677"'
hint.TextColor3       = C.SUBTEXT
hint.Font             = Enum.Font.Gotham
hint.TextSize         = 18
hint.ZIndex           = 12
hint.Parent           = card

-- ============================================================
-- ================  BROWSER SCREEN  =========================
-- ============================================================
local browserPage = Instance.new("Frame")
browserPage.Name             = "BrowserPage"
browserPage.Size             = UDim2.new(1, 0, 1, 0)
browserPage.BackgroundColor3 = C.BG
browserPage.BorderSizePixel  = 0
browserPage.Visible          = false
browserPage.Parent           = root

-- ── Top Bar ──────────────────────────────────────────────────
local topBar = Instance.new("Frame")
topBar.Size             = UDim2.new(1, 0, 0, 72)
topBar.BackgroundColor3 = C.PANEL
topBar.BorderSizePixel  = 0
topBar.Parent           = browserPage

local topGrad = Instance.new("UIGradient")
topGrad.Color    = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 22, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 32)),
})
topGrad.Rotation = 90
topGrad.Parent   = topBar

-- Logo kecil di kiri
local bLogo = Instance.new("TextLabel")
bLogo.Size             = UDim2.new(0, 110, 1, 0)
bLogo.Position         = UDim2.new(0, 8, 0, 0)
bLogo.BackgroundTransparency = 1
bLogo.Text             = "🌐 KB"
bLogo.TextColor3       = C.ACCENT
bLogo.Font             = Enum.Font.GothamBold
bLogo.TextSize         = 32
bLogo.Parent           = topBar

-- Tombol navigasi: Back, Forward, Refresh
local function NavBtn(icon, xPos)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, 52, 0, 46)
    b.Position         = UDim2.new(0, xPos, 0.5, -23)
    b.BackgroundColor3 = C.PANEL2
    b.BorderSizePixel  = 0
    b.Text             = icon
    b.TextColor3       = C.TEXT
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 26
    b.AutoButtonColor  = false
    b.Parent           = topBar
    Corner(b, 8)

    b.MouseEnter:Connect(function()
        Tween(b, {BackgroundColor3 = C.ACCENT}, 0.15):Play()
        Tween(b, {TextColor3 = C.BLACK}, 0.15):Play()
    end)
    b.MouseLeave:Connect(function()
        Tween(b, {BackgroundColor3 = C.PANEL2}, 0.15):Play()
        Tween(b, {TextColor3 = C.TEXT}, 0.15):Play()
    end)
    return b
end

local btnBack    = NavBtn("◀", 120)
local btnForward = NavBtn("▶", 180)
local btnRefresh = NavBtn("↻", 240)

-- URL bar
local urlBar = Instance.new("TextBox")
urlBar.Size             = UDim2.new(0, 1040, 0, 46)
urlBar.Position         = UDim2.new(0, 306, 0.5, -23)
urlBar.BackgroundColor3 = C.PANEL2
urlBar.BorderSizePixel  = 0
urlBar.Text             = ""
urlBar.PlaceholderText  = "Masukkan URL  •  https://www.tiktok.com"
urlBar.TextColor3       = C.TEXT
urlBar.PlaceholderColor3= C.SUBTEXT
urlBar.Font             = Enum.Font.Gotham
urlBar.TextSize         = 26
urlBar.ClearTextOnFocus = false
urlBar.Parent           = topBar
Corner(urlBar, 10)
Stroke(urlBar, C.ACCENT, 1.5)

-- GO button
local btnGo = Instance.new("TextButton")
btnGo.Size             = UDim2.new(0, 90, 0, 46)
btnGo.Position         = UDim2.new(0, 1358, 0.5, -23)
btnGo.BackgroundColor3 = C.ACCENT
btnGo.BorderSizePixel  = 0
btnGo.Text             = "GO"
btnGo.TextColor3       = C.BLACK
btnGo.Font             = Enum.Font.GothamBold
btnGo.TextSize         = 28
btnGo.AutoButtonColor  = false
btnGo.Parent           = topBar
Corner(btnGo, 10)

btnGo.MouseEnter:Connect(function()
    Tween(btnGo, {BackgroundColor3 = C.SUCCESS}, 0.15):Play()
end)
btnGo.MouseLeave:Connect(function()
    Tween(btnGo, {BackgroundColor3 = C.ACCENT}, 0.15):Play()
end)

-- Quality button
local btnQuality = Instance.new("TextButton")
btnQuality.Size             = UDim2.new(0, 160, 0, 46)
btnQuality.Position         = UDim2.new(0, 1462, 0.5, -23)
btnQuality.BackgroundColor3 = C.PANEL2
btnQuality.BorderSizePixel  = 0
btnQuality.Text             = "⚙  Auto"
btnQuality.TextColor3       = C.TEXT
btnQuality.Font             = Enum.Font.Gotham
btnQuality.TextSize         = 24
btnQuality.AutoButtonColor  = false
btnQuality.Parent           = topBar
Corner(btnQuality, 10)
Stroke(btnQuality, C.ACCENT2, 1)

-- Copy button
local btnCopy = Instance.new("TextButton")
btnCopy.Size             = UDim2.new(0, 90, 0, 46)
btnCopy.Position         = UDim2.new(0, 1636, 0.5, -23)
btnCopy.BackgroundColor3 = Color3.fromRGB(40, 130, 80)
btnCopy.BorderSizePixel  = 0
btnCopy.Text             = "📋"
btnCopy.TextColor3       = C.WHITE
btnCopy.Font             = Enum.Font.GothamBold
btnCopy.TextSize         = 28
btnCopy.AutoButtonColor  = false
btnCopy.Parent           = topBar
Corner(btnCopy, 10)

-- Download button
local btnDL = Instance.new("TextButton")
btnDL.Size             = UDim2.new(0, 90, 0, 46)
btnDL.Position         = UDim2.new(0, 1740, 0.5, -23)
btnDL.BackgroundColor3 = Color3.fromRGB(50, 80, 180)
btnDL.BorderSizePixel  = 0
btnDL.Text             = "⬇"
btnDL.TextColor3       = C.WHITE
btnDL.Font             = Enum.Font.GothamBold
btnDL.TextSize         = 28
btnDL.AutoButtonColor  = false
btnDL.Parent           = topBar
Corner(btnDL, 10)

-- Logout button (kanan jauh)
local btnLogout = Instance.new("TextButton")
btnLogout.Size             = UDim2.new(0, 90, 0, 46)
btnLogout.Position         = UDim2.new(0, 1848, 0.5, -23)
btnLogout.BackgroundColor3 = C.DANGER
btnLogout.BorderSizePixel  = 0
btnLogout.Text             = "⏏"
btnLogout.TextColor3       = C.WHITE
btnLogout.Font             = Enum.Font.GothamBold
btnLogout.TextSize         = 28
btnLogout.AutoButtonColor  = false
btnLogout.Parent           = topBar
Corner(btnLogout, 10)

-- ── Loading bar (di bawah topbar) ────────────────────────────
local loadTrack = Instance.new("Frame")
loadTrack.Size             = UDim2.new(1, 0, 0, 4)
loadTrack.Position         = UDim2.new(0, 0, 0, 72)
loadTrack.BackgroundColor3 = C.PANEL2
loadTrack.BorderSizePixel  = 0
loadTrack.Parent           = browserPage

local loadFill = Instance.new("Frame")
loadFill.Size             = UDim2.new(0, 0, 1, 0)
loadFill.BackgroundColor3 = C.LOADBAR
loadFill.BorderSizePixel  = 0
loadFill.Parent           = loadTrack

local loadGrad = Instance.new("UIGradient")
loadGrad.Color  = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.ACCENT2),
    ColorSequenceKeypoint.new(1, C.ACCENT),
})
loadGrad.Parent = loadFill

-- ── Tab bar ──────────────────────────────────────────────────
local tabBar = Instance.new("Frame")
tabBar.Size             = UDim2.new(1, 0, 0, 40)
tabBar.Position         = UDim2.new(0, 0, 0, 76)
tabBar.BackgroundColor3 = Color3.fromRGB(16, 16, 26)
tabBar.BorderSizePixel  = 0
tabBar.Parent           = browserPage

local tabList = Instance.new("UIListLayout")
tabList.FillDirection = Enum.FillDirection.Horizontal
tabList.VerticalAlignment = Enum.VerticalAlignment.Center
tabList.Padding = UDim.new(0, 4)
tabList.Parent = tabBar

-- Tab aktif (satu tab saja)
local activeTab = Instance.new("Frame")
activeTab.Size             = UDim2.new(0, 300, 0, 32)
activeTab.BackgroundColor3 = C.PANEL
activeTab.BorderSizePixel  = 0
activeTab.Parent           = tabBar
Corner(activeTab, 6)

local tabTitle = Instance.new("TextLabel")
tabTitle.Size             = UDim2.new(1, -8, 1, 0)
tabTitle.Position         = UDim2.new(0, 8, 0, 0)
tabTitle.BackgroundTransparency = 1
tabTitle.Text             = "Tab Baru"
tabTitle.TextColor3       = C.TEXT
tabTitle.Font             = Enum.Font.Gotham
tabTitle.TextSize         = 20
tabTitle.TextXAlignment   = Enum.TextXAlignment.Left
tabTitle.TextTruncate     = Enum.TextTruncate.AtEnd
tabTitle.Parent           = activeTab

-- ── Content area ─────────────────────────────────────────────
local contentArea = Instance.new("Frame")
contentArea.Size             = UDim2.new(1, 0, 1, -160)
contentArea.Position         = UDim2.new(0, 0, 0, 116)
contentArea.BackgroundColor3 = Color3.fromRGB(235, 238, 248)
contentArea.BorderSizePixel  = 0
contentArea.ClipsDescendants = true
contentArea.Parent           = browserPage

-- Welcome / halaman konten
local contentBg = Instance.new("Frame")
contentBg.Size             = UDim2.new(1, 0, 1, 0)
contentBg.BackgroundColor3 = Color3.fromRGB(240, 242, 252)
contentBg.BorderSizePixel  = 0
contentBg.Parent           = contentArea

local contentText = Instance.new("TextLabel")
contentText.Size             = UDim2.new(0.9, 0, 0.9, 0)
contentText.Position         = UDim2.new(0.05, 0, 0.05, 0)
contentText.BackgroundTransparency = 1
contentText.Text             = "🌐  Selamat Datang di KHAFIDZ Browser\n\nMasukkan URL di atas dan tekan GO untuk mulai menjelajah.\n\n📌  Contoh situs:\n• https://www.tiktok.com\n• https://www.youtube.com\n• https://www.google.com\n• https://www.instagram.com\n\n💡  Tips: Gunakan tombol ⚙ untuk mengatur kualitas\n         Gunakan 📋 untuk menyalin URL\n         Gunakan ⬇ untuk mengunduh"
contentText.TextColor3       = Color3.fromRGB(30, 30, 60)
contentText.Font             = Enum.Font.Gotham
contentText.TextSize         = 32
contentText.TextWrapped      = true
contentText.TextYAlignment   = Enum.TextYAlignment.Top
contentText.TextXAlignment   = Enum.TextXAlignment.Left
contentText.ZIndex           = 2
contentText.Parent           = contentBg

-- Overlay loading
local loadOverlay = Instance.new("Frame")
loadOverlay.Size             = UDim2.new(1, 0, 1, 0)
loadOverlay.BackgroundColor3 = Color3.fromRGB(235, 238, 248)
loadOverlay.BackgroundTransparency = 1
loadOverlay.BorderSizePixel  = 0
loadOverlay.ZIndex           = 10
loadOverlay.Visible          = false
loadOverlay.Parent           = contentArea

local loadSpinner = Instance.new("TextLabel")
loadSpinner.Size             = UDim2.new(0, 200, 0, 60)
loadSpinner.Position         = UDim2.new(0.5, -100, 0.45, -30)
loadSpinner.BackgroundTransparency = 1
loadSpinner.Text             = "⏳ Memuat..."
loadSpinner.TextColor3       = C.ACCENT
loadSpinner.Font             = Enum.Font.GothamBold
loadSpinner.TextSize         = 36
loadSpinner.ZIndex           = 11
loadSpinner.Parent           = loadOverlay

-- ── Status bar (bawah) ───────────────────────────────────────
local statusBar = Instance.new("Frame")
statusBar.Size             = UDim2.new(1, 0, 0, 36)
statusBar.Position         = UDim2.new(0, 0, 1, -36)
statusBar.BackgroundColor3 = C.PANEL
statusBar.BorderSizePixel  = 0
statusBar.Parent           = browserPage

local statusTxt = Instance.new("TextLabel")
statusTxt.Size             = UDim2.new(0.7, 0, 1, 0)
statusTxt.Position         = UDim2.new(0, 12, 0, 0)
statusTxt.BackgroundTransparency = 1
statusTxt.Text             = "Siap"
statusTxt.TextColor3       = C.SUBTEXT
statusTxt.Font             = Enum.Font.Gotham
statusTxt.TextSize         = 20
statusTxt.TextXAlignment   = Enum.TextXAlignment.Left
statusTxt.Parent           = statusBar

-- Akun info (kanan status bar)
local userInfo = Instance.new("TextLabel")
userInfo.Size             = UDim2.new(0.28, 0, 1, 0)
userInfo.Position         = UDim2.new(0.71, 0, 0, 0)
userInfo.BackgroundTransparency = 1
userInfo.Text             = ""
userInfo.TextColor3       = C.ACCENT
userInfo.Font             = Enum.Font.GothamBold
userInfo.TextSize         = 20
userInfo.TextXAlignment   = Enum.TextXAlignment.Right
userInfo.Parent           = statusBar

-- ── Quality Panel (dropdown) ─────────────────────────────────
local qPanel = Instance.new("Frame")
qPanel.Size             = UDim2.new(0, 200, 0, 260)
qPanel.Position         = UDim2.new(0, 1462, 0, 72)
qPanel.BackgroundColor3 = C.PANEL
qPanel.BorderSizePixel  = 0
qPanel.Visible          = false
qPanel.ZIndex           = 50
qPanel.Parent           = browserPage
Corner(qPanel, 10)
Stroke(qPanel, C.ACCENT2, 1.5)

local qualities = {"🔵 Auto", "🟣 1080p", "🔷 720p", "🟤 480p", "⚪ 360p"}
local qLayout = Instance.new("UIListLayout")
qLayout.FillDirection = Enum.FillDirection.Vertical
qLayout.Padding = UDim.new(0, 4)
qLayout.Parent = qPanel
local qPad = Instance.new("UIPadding")
qPad.PaddingTop    = UDim.new(0, 6)
qPad.PaddingLeft   = UDim.new(0, 6)
qPad.PaddingRight  = UDim.new(0, 6)
qPad.Parent        = qPanel

for _, q in ipairs(qualities) do
    local qb = Instance.new("TextButton")
    qb.Size             = UDim2.new(1, 0, 0, 44)
    qb.BackgroundColor3 = C.PANEL2
    qb.BorderSizePixel  = 0
    qb.Text             = q
    qb.TextColor3       = C.TEXT
    qb.Font             = Enum.Font.Gotham
    qb.TextSize         = 24
    qb.ZIndex           = 51
    qb.AutoButtonColor  = false
    qb.Parent           = qPanel
    Corner(qb, 6)

    qb.MouseEnter:Connect(function()
        Tween(qb, {BackgroundColor3 = C.ACCENT}, 0.1):Play()
        Tween(qb, {TextColor3 = C.BLACK}, 0.1):Play()
    end)
    qb.MouseLeave:Connect(function()
        Tween(qb, {BackgroundColor3 = C.PANEL2}, 0.1):Play()
        Tween(qb, {TextColor3 = C.TEXT}, 0.1):Play()
    end)
    qb.MouseButton1Click:Connect(function()
        local label = q:match("%S+%s+(.+)") or q
        btnQuality.Text = "⚙  " .. label
        qPanel.Visible  = false
        statusTxt.Text  = "Kualitas diatur ke: " .. label
    end)
end

-- ============================================================
-- LOGIKA BROWSER
-- ============================================================
local history      = {}
local histIdx      = 0
local currentURL   = ""
local loggedUser   = ""
local isLoading    = false

-- Spinner animasi
local spinners = {"⏳", "⌛"}
local spinI    = 1
RunService.Heartbeat:Connect(function()
    if isLoading then
        spinI = (spinI % #spinners) + 1
        loadSpinner.Text = spinners[spinI] .. " Memuat..."
    end
end)

-- Animasi loading bar
local function AnimateLoadBar(duration)
    loadFill.Size = UDim2.new(0, 0, 1, 0)
    local t1 = Tween(loadFill, {Size = UDim2.new(0.8, 0, 1, 0)}, duration * 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    t1:Play()
    t1.Completed:Wait()
    local t2 = Tween(loadFill, {Size = UDim2.new(1, 0, 1, 0)}, duration * 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    t2:Play()
    t2.Completed:Wait()
    task.wait(0.1)
    loadFill.Size = UDim2.new(0, 0, 1, 0)
end

-- Format URL
local function FormatURL(raw)
    raw = raw:match("^%s*(.-)%s*$") -- trim
    if raw == "" then return "" end
    if not raw:match("^https?://") then
        if raw:match("^www%.") then
            raw = "https://" .. raw
        elseif raw:match("%.%a+") then
            raw = "https://" .. raw
        else
            raw = "https://www.google.com/search?q=" .. raw:gsub(" ", "+")
        end
    end
    return raw
end

-- Dapat nama situs dari URL
local function SiteName(url)
    local host = url:match("https?://([^/]+)") or url
    return host:gsub("^www%.", "")
end

-- Navigate ke URL
local function Navigate(rawUrl)
    if isLoading then return end
    local url = FormatURL(rawUrl)
    if url == "" then return end

    isLoading = true
    loadOverlay.Visible = true

    -- Tambah ke history
    if url ~= currentURL then
        while #history > histIdx do
            table.remove(history)
        end
        table.insert(history, url)
        histIdx    = #history
        currentURL = url
    end

    urlBar.Text     = url
    tabTitle.Text   = SiteName(url)
    statusTxt.Text  = "Memuat " .. url .. "..."

    -- Simulasi loading
    local loadTime = 1.2 + math.random() * 0.8
    task.spawn(AnimateLoadBar, loadTime)
    task.wait(loadTime)

    -- Tampilkan konten
    local siteName = SiteName(url)
    contentText.Text =
        "✅  " .. siteName:upper() .. "\n" ..
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n" ..
        "🔗  URL Aktif:\n" .. url .. "\n\n" ..
        "ℹ️  Tentang Halaman:\n" ..
        "Roblox tidak dapat merender HTML penuh secara native.\n" ..
        "URL telah diproses & dicatat oleh KHAFIDZ Browser.\n\n" ..
        "🛠  Aksi tersedia:\n" ..
        "  📋  Salin URL → tombol kiri atas (hijau)\n" ..
        "  ⬇   Download  → tombol biru\n" ..
        "  ⚙   Kualitas  → pilih resolusi\n" ..
        "  ◀▶  Navigasi  → back / forward\n\n" ..
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" ..
        "👤  Login: " .. loggedUser

    statusTxt.Text      = "✔  " .. url
    loadOverlay.Visible = false
    isLoading           = false
end

-- ============================================================
-- KONEKSI EVENT
-- ============================================================

-- LOGIN
loginBtn.MouseButton1Click:Connect(function()
    local u = userBox.Text:match("^%s*(.-)%s*$")
    local p = realPass

    if u == "" or p == "" then
        loginStatus.TextColor3 = C.WARNING
        loginStatus.Text = "⚠  Isi username dan password!"
        return
    end

    loginStatus.TextColor3 = C.ACCENT
    loginStatus.Text = "⏳  Memeriksa akun..."
    loginBtn.Text    = "⏳  MEMUAT..."
    task.wait(1.2)

    local valid = false
    for name, pw in pairs(ACCOUNTS) do
        if name:lower() == u:lower() and pw == p then
            valid     = true
            loggedUser = name
            break
        end
    end

    if valid then
        loginStatus.TextColor3 = C.SUCCESS
        loginStatus.Text = "✅  Login berhasil! Halo, " .. loggedUser .. "!"
        task.wait(0.7)

        -- Transisi ke browser
        Tween(loginPage, {BackgroundTransparency = 1}, 0.4):Play()
        task.wait(0.4)
        loginPage.Visible   = false
        browserPage.Visible = true
        userInfo.Text       = "👤 " .. loggedUser
        statusTxt.Text      = "Selamat datang, " .. loggedUser .. "!"
    else
        loginStatus.TextColor3 = C.DANGER
        loginStatus.Text = "❌  Username atau password salah!"
        loginBtn.Text    = "  MASUK"
    end

    loginBtn.Text = "  MASUK"
end)

-- GO
btnGo.MouseButton1Click:Connect(function()
    Navigate(urlBar.Text)
end)

-- Enter di URL bar
urlBar.FocusLost:Connect(function(entered)
    if entered then Navigate(urlBar.Text) end
end)

-- BACK
btnBack.MouseButton1Click:Connect(function()
    if histIdx > 1 then
        histIdx    = histIdx - 1
        currentURL = history[histIdx]
        Navigate(currentURL)
    else
        statusTxt.Text = "⚠  Tidak ada halaman sebelumnya"
    end
end)

-- FORWARD
btnForward.MouseButton1Click:Connect(function()
    if histIdx < #history then
        histIdx    = histIdx + 1
        currentURL = history[histIdx]
        Navigate(currentURL)
    else
        statusTxt.Text = "⚠  Tidak ada halaman berikutnya"
    end
end)

-- REFRESH
btnRefresh.MouseButton1Click:Connect(function()
    if currentURL ~= "" then
        Navigate(currentURL)
    end
end)

-- QUALITY toggle
btnQuality.MouseButton1Click:Connect(function()
    qPanel.Visible = not qPanel.Visible
end)

-- COPY URL
btnCopy.MouseButton1Click:Connect(function()
    if currentURL ~= "" then
        local ok, err = pcall(function()
            setclipboard(currentURL)
        end)
        if ok then
            btnCopy.Text = "✅"
            statusTxt.Text = "📋  URL disalin: " .. currentURL
        else
            statusTxt.Text = "⚠  Clipboard tidak didukung executor ini"
        end
        task.wait(1.5)
        btnCopy.Text = "📋"
    else
        statusTxt.Text = "⚠  Belum ada URL untuk disalin"
    end
end)

-- DOWNLOAD simulasi
btnDL.MouseButton1Click:Connect(function()
    if currentURL ~= "" then
        btnDL.Text     = "⏳"
        statusTxt.Text = "⬇  Mengunduh dari " .. currentURL .. "..."
        task.wait(2.5)
        btnDL.Text     = "⬇"
        statusTxt.Text = "✅  Download selesai — " .. SiteName(currentURL)
    else
        statusTxt.Text = "⚠  Belum ada URL untuk diunduh"
    end
end)

-- LOGOUT
btnLogout.MouseButton1Click:Connect(function()
    browserPage.Visible = false
    loginPage.Visible   = true
    loginPage.BackgroundTransparency = 0
    loginStatus.Text    = ""
    userBox.Text        = ""
    realPass            = ""
    passBox.Text        = ""
    passOverlay.Text    = ""
    loggedUser          = ""
    currentURL          = ""
    history             = {}
    histIdx             = 0
    contentText.Text    = "🌐  Selamat Datang di KHAFIDZ Browser\n\nMasukkan URL di atas dan tekan GO untuk mulai menjelajah."
    urlBar.Text         = ""
    tabTitle.Text       = "Tab Baru"
end)

-- Tutup quality panel kalau klik di luar
root.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        qPanel.Visible = false
    end
end)

-- ============================================================
-- SELESAI
-- ============================================================
print("╔══════════════════════════════════════╗")
print("║   KHAFIDZ BROWSER — Berhasil dimuat  ║")
print("║   Layar ada di Y = 120               ║")
print("║   Akun demo: Agus / 67677            ║")
print("╚══════════════════════════════════════╝")
