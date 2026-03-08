--[[
╔══════════════════════════════════════════════════════════════════╗
║           SANITY GAME - COMPLETE PACK (ALL-IN-ONE)              ║
║                                                                  ║
║  CARA PASANG:                                                    ║
║  1. Buka Roblox Studio                                           ║
║  2. Di Explorer: StarterPlayer → StarterCharacterScripts         ║
║  3. Buat LocalScript baru                                        ║
║  4. Paste SELURUH isi file ini                                   ║
║  5. Play!                                                        ║
║                                                                  ║
║  SISTEM YANG ADA:                                                ║
║  ✓ GUI "Kuwarasan: X%" di kanan atas                             ║
║  ✓ Teleport otomatis ke White Room                               ║
║  ✓ Room 1: lorong + jebakan + 8 tombol tersebar                  ║
║  ✓ Room 2: super terang + 10 tombol tersembunyi                  ║
║  ✓ Guess Phase: tebak jebakan/NPC/trap                           ║
║  ✓ Efek sanity bertahap (70% / 50% / 20% / 10%)                 ║
║  ✓ NPC halusinasi (kejar lalu hilang)                            ║
║  ✓ NPC nyata (serang 5 detik lalu hilang)                        ║
║  ✓ Lost control penuh di < 10%                                   ║
╚══════════════════════════════════════════════════════════════════╝
--]]

-- ================================================================
--  SERVICES
-- ================================================================
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")

-- ================================================================
--  PLAYER & CHARACTER
-- ================================================================
local player    = Players.LocalPlayer
local playerGui = player.PlayerGui
local camera    = workspace.CurrentCamera

local character, humanoid, hrp
local function refreshCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid  = character:WaitForChild("Humanoid")
    hrp       = character:WaitForChild("HumanoidRootPart")
end
refreshCharacter()
player.CharacterAdded:Connect(refreshCharacter)

-- ================================================================
--  SANITY STATE
-- ================================================================
local sanity      = 100
local lastSanity  = 100
local lostControl = false

-- ================================================================
--  WORLD FOLDERS
-- ================================================================
local worldFolder = workspace:FindFirstChild("SanityWorld") or Instance.new("Folder")
worldFolder.Name   = "SanityWorld"
worldFolder.Parent = workspace

-- ================================================================
--  BUILD WORLD (hanya sekali, cek dulu)
-- ================================================================
local worldBuilt = false

local function makePart(parent, size, cf, brickColor, material, transparency, canCollide)
    local p = Instance.new("Part")
    p.Size            = size
    p.CFrame          = cf
    p.BrickColor      = BrickColor.new(brickColor or "White")
    p.Material        = material or Enum.Material.SmoothPlastic
    p.Anchored        = true
    p.CanCollide      = canCollide ~= false
    p.Transparency    = transparency or 0
    p.CastShadow      = false
    p.Parent          = parent
    return p
end

local function buildRoom(folder, origin, sx, sy, sz, col)
    -- Floor
    makePart(folder, Vector3.new(sx, 1, sz),
        CFrame.new(origin + Vector3.new(0, -0.5, 0)), col)
    -- Ceiling
    makePart(folder, Vector3.new(sx, 1, sz),
        CFrame.new(origin + Vector3.new(0, sy + 0.5, 0)), col)
    -- Walls
    makePart(folder, Vector3.new(sx, sy, 1),
        CFrame.new(origin + Vector3.new(0, sy/2, -sz/2)), col)
    makePart(folder, Vector3.new(sx, sy, 1),
        CFrame.new(origin + Vector3.new(0, sy/2,  sz/2)), col)
    makePart(folder, Vector3.new(1, sy, sz),
        CFrame.new(origin + Vector3.new(-sx/2, sy/2, 0)), col)
    makePart(folder, Vector3.new(1, sy, sz),
        CFrame.new(origin + Vector3.new( sx/2, sy/2, 0)), col)
end

local function addLight(parent, pos, brightness, range, color)
    local lp = makePart(parent, Vector3.new(0.5, 0.5, 0.5),
        CFrame.new(pos), "White", Enum.Material.SmoothPlastic, 1, false)
    local pl = Instance.new("PointLight")
    pl.Brightness = brightness or 2
    pl.Range      = range      or 40
    pl.Color      = color      or Color3.fromRGB(255,255,255)
    pl.Parent     = lp
    return lp
end

-- ── ORIGIN POINTS ──────────────────────────────────────────────
local SPAWN_ORIGIN = Vector3.new(0,   0,   0)
local ROOM1_ORIGIN = Vector3.new(0,   0, -90)
local CORR_ORIGIN  = Vector3.new(0,   0, -145)
local ROOM2_ORIGIN = Vector3.new(0,   0, -210)

local SPAWN_SPAWN_POS = SPAWN_ORIGIN + Vector3.new(0, 3,  0)
local ROOM1_ENTER_POS = ROOM1_ORIGIN + Vector3.new(0, 3, 22)
local ROOM2_ENTER_POS = ROOM2_ORIGIN + Vector3.new(0, 3, 28)

-- ── TRAP POSITIONS (lorong) ─────────────────────────────────────
local TRAP_POSITIONS = {
    CORR_ORIGIN + Vector3.new( 0, 0.15, -8),
    CORR_ORIGIN + Vector3.new( 0, 0.15,  0),
    CORR_ORIGIN + Vector3.new( 0, 0.15,  8),
}

-- ── BUTTON POSITIONS ────────────────────────────────────────────
local R1_BTN_POS = {
    ROOM1_ORIGIN + Vector3.new( 16,  1, -5),
    ROOM1_ORIGIN + Vector3.new(-16,  1,  0),
    ROOM1_ORIGIN + Vector3.new( 14,  1, 10),
    ROOM1_ORIGIN + Vector3.new(-14,  1,-10),
    ROOM1_ORIGIN + Vector3.new(  5,  1,-18),
    ROOM1_ORIGIN + Vector3.new( -5,  1, 15),
    ROOM1_ORIGIN + Vector3.new( 10,  1, -2),
    ROOM1_ORIGIN + Vector3.new(-10,  1,  8),
}

local R2_BTN_POS = {
    ROOM2_ORIGIN + Vector3.new( 22,  1, -5),
    ROOM2_ORIGIN + Vector3.new(-22,  1,  0),
    ROOM2_ORIGIN + Vector3.new( 18,  5, 10),
    ROOM2_ORIGIN + Vector3.new(-18,  1,-10),
    ROOM2_ORIGIN + Vector3.new(  0,  1,-22),
    ROOM2_ORIGIN + Vector3.new( 12,  1,-15),
    ROOM2_ORIGIN + Vector3.new(-12,  1,-18),
    ROOM2_ORIGIN + Vector3.new( 20,  1, 15),
    ROOM2_ORIGIN + Vector3.new(-20,  1, 12),
    ROOM2_ORIGIN + Vector3.new(  0,  9,  0), -- langit-langit
}

-- ── BUILD ────────────────────────────────────────────────────────
local r1ButtonsFound  = 0
local r2ButtonsFound  = 0
local enteredRoom2    = false
local guessPhaseActive= false
local trapParts       = {}
local r1BtnParts      = {}
local r2BtnParts      = {}
local portalToR1, portalToR2

local function buildWorld()
    if worldBuilt then return end
    worldBuilt = true

    -- ── SPAWN ROOM ─────────────────────────────────────────────
    local spawnF = Instance.new("Folder"); spawnF.Name="SpawnRoom"; spawnF.Parent=worldFolder
    buildRoom(spawnF, SPAWN_ORIGIN, 22, 8, 22, "Dark grey")
    addLight(spawnF, SPAWN_ORIGIN + Vector3.new(0, 7, 0), 1.5, 25,
        Color3.fromRGB(180, 180, 220))

    -- Portal pad ke Room 1
    portalToR1 = makePart(spawnF, Vector3.new(5, 0.4, 5),
        CFrame.new(SPAWN_ORIGIN + Vector3.new(0, 0.2, -8)),
        "Cyan", Enum.Material.Neon, 0.4)
    local bb1 = Instance.new("BillboardGui"); bb1.Size=UDim2.new(0,180,0,36)
    bb1.StudsOffset=Vector3.new(0,1,0); bb1.Parent=portalToR1
    local t1 = Instance.new("TextLabel"); t1.Size=UDim2.new(1,0,1,0)
    t1.BackgroundTransparency=1; t1.Text="[ SENTUH UNTUK MASUK ]"
    t1.TextColor3=Color3.fromRGB(0,220,255); t1.Font=Enum.Font.Code
    t1.TextSize=16; t1.Parent=bb1

    -- Spawn location part (untuk teleport awal)
    local spawnLoc = makePart(spawnF, Vector3.new(4,1,4),
        CFrame.new(SPAWN_SPAWN_POS - Vector3.new(0,1,0)),
        "Dark grey", Enum.Material.SmoothPlastic, 0)

    -- ── ROOM 1 ─────────────────────────────────────────────────
    local r1F = Instance.new("Folder"); r1F.Name="Room1"; r1F.Parent=worldFolder
    buildRoom(r1F, ROOM1_ORIGIN, 40, 10, 50, "White")
    addLight(r1F, ROOM1_ORIGIN + Vector3.new(0,9,0), 2, 55,
        Color3.fromRGB(255,255,250))

    -- 8 Tombol Room 1
    for i, pos in ipairs(R1_BTN_POS) do
        local btn = makePart(r1F, Vector3.new(2,2,2),
            CFrame.new(pos), "Bright green", Enum.Material.Neon, 0.15)
        btn.Name = "R1_Btn_"..i
        local bbb = Instance.new("BillboardGui"); bbb.Size=UDim2.new(0,100,0,28)
        bbb.StudsOffset=Vector3.new(0,1.5,0); bbb.Parent=btn
        local btxt = Instance.new("TextLabel"); btxt.Size=UDim2.new(1,0,1,0)
        btxt.BackgroundTransparency=1; btxt.Text="⬡ "..i
        btxt.TextColor3=Color3.fromRGB(255,255,255)
        btxt.Font=Enum.Font.Code; btxt.TextSize=18; btxt.Parent=bbb
        table.insert(r1BtnParts, btn)
    end

    -- ── LORONG ─────────────────────────────────────────────────
    local corrF = Instance.new("Folder"); corrF.Name="Corridor"; corrF.Parent=worldFolder
    buildRoom(corrF, CORR_ORIGIN, 8, 9, 44, "Light grey")
    addLight(corrF, CORR_ORIGIN + Vector3.new(0,8,0), 1, 45,
        Color3.fromRGB(210, 210, 210))

    -- Jebakan
    for _, tpos in ipairs(TRAP_POSITIONS) do
        local trap = makePart(corrF, Vector3.new(6, 0.3, 4),
            CFrame.new(tpos), "Bright red", Enum.Material.Neon, 0.25)
        trap.Name = "Trap"
        local tbb = Instance.new("BillboardGui"); tbb.Size=UDim2.new(0,120,0,24)
        tbb.StudsOffset=Vector3.new(0,0.5,0); tbb.Parent=trap
        local ttxt = Instance.new("TextLabel"); ttxt.Size=UDim2.new(1,0,1,0)
        ttxt.BackgroundTransparency=1; ttxt.Text="⚠ BAHAYA"
        ttxt.TextColor3=Color3.fromRGB(255,80,80)
        ttxt.Font=Enum.Font.Code; ttxt.TextSize=14; ttxt.Parent=tbb
        table.insert(trapParts, trap)
    end

    -- ── ROOM 2 ─────────────────────────────────────────────────
    local r2F = Instance.new("Folder"); r2F.Name="Room2"; r2F.Parent=worldFolder
    buildRoom(r2F, ROOM2_ORIGIN, 50, 10, 60, "White")

    -- Banyak lampu biar super terang (kayak brightness HP max)
    for _, off in ipairs({
        Vector3.new(0,9,0), Vector3.new(12,9,12), Vector3.new(-12,9,-12),
        Vector3.new(12,9,-12), Vector3.new(-12,9,12),
        Vector3.new(0,9,20), Vector3.new(0,9,-20),
    }) do
        addLight(r2F, ROOM2_ORIGIN + off, 4, 45, Color3.fromRGB(255,255,255))
    end

    -- Portal dari Room 1 ke Room 2
    portalToR2 = makePart(r2F, Vector3.new(6, 0.4, 6),
        CFrame.new(ROOM2_ORIGIN + Vector3.new(0, 0.2, 27)),
        "Bright yellow", Enum.Material.Neon, 0.4)
    portalToR2.Name = "PortalR2"
    local bb2 = Instance.new("BillboardGui"); bb2.Size=UDim2.new(0,200,0,36)
    bb2.StudsOffset=Vector3.new(0,1,0); bb2.Parent=portalToR2
    local t2 = Instance.new("TextLabel"); t2.Size=UDim2.new(1,0,1,0)
    t2.BackgroundTransparency=1; t2.Text="[ KUMPULKAN SEMUA TOMBOL DULU ]"
    t2.TextColor3=Color3.fromRGB(255,220,0); t2.Font=Enum.Font.Code
    t2.TextSize=14; t2.Parent=bb2

    -- 10 Tombol Room 2 (lebih tersembunyi)
    for i, pos in ipairs(R2_BTN_POS) do
        local btn2 = makePart(r2F, Vector3.new(1.5,1.5,1.5),
            CFrame.new(pos), "Bright yellow", Enum.Material.Neon, 0.1)
        btn2.Name = "R2_Btn_"..i
        local b2bb = Instance.new("BillboardGui"); b2bb.Size=UDim2.new(0,80,0,24)
        b2bb.StudsOffset=Vector3.new(0,1.2,0); b2bb.Parent=btn2
        local b2txt = Instance.new("TextLabel"); b2txt.Size=UDim2.new(1,0,1,0)
        b2txt.BackgroundTransparency=1; b2txt.Text="★ "..i
        b2txt.TextColor3=Color3.fromRGB(255,240,100)
        b2txt.Font=Enum.Font.Code; b2txt.TextSize=16; b2txt.Parent=b2bb
        table.insert(r2BtnParts, btn2)
    end
end

-- ================================================================
--  GUI SETUP
-- ================================================================
local gui = Instance.new("ScreenGui")
gui.Name            = "SanityGameGui"
gui.ResetOnSpawn    = false
gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
gui.Parent          = playerGui

-- ── SANITY HUD (kanan atas) ────────────────────────────────────
local hudFrame = Instance.new("Frame")
hudFrame.Size                = UDim2.new(0, 200, 0, 56)
hudFrame.Position            = UDim2.new(1, -215, 0, 12)
hudFrame.BackgroundColor3    = Color3.fromRGB(10, 10, 10)
hudFrame.BackgroundTransparency = 0.4
hudFrame.BorderSizePixel     = 0
hudFrame.Parent              = gui
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 8)

local hudStroke = Instance.new("UIStroke", hudFrame)
hudStroke.Color     = Color3.fromRGB(0, 255, 136)
hudStroke.Thickness = 1.5

local sanityLabel = Instance.new("TextLabel")
sanityLabel.Size               = UDim2.new(1, -10, 0, 28)
sanityLabel.Position           = UDim2.new(0, 5, 0, 4)
sanityLabel.BackgroundTransparency = 1
sanityLabel.Text               = "Kuwarasan: 100%"
sanityLabel.TextColor3         = Color3.fromRGB(0, 255, 136)
sanityLabel.TextSize           = 17
sanityLabel.Font               = Enum.Font.Code
sanityLabel.TextXAlignment     = Enum.TextXAlignment.Right
sanityLabel.Parent             = hudFrame

local barBg = Instance.new("Frame")
barBg.Size              = UDim2.new(1, -16, 0, 7)
barBg.Position          = UDim2.new(0, 8, 0, 36)
barBg.BackgroundColor3  = Color3.fromRGB(30, 30, 30)
barBg.BorderSizePixel   = 0
barBg.Parent            = hudFrame
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame")
barFill.Size            = UDim2.new(1, 0, 1, 0)
barFill.BackgroundColor3= Color3.fromRGB(0, 255, 136)
barFill.BorderSizePixel = 0
barFill.Parent          = barBg
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

-- ── VIGNETTE ──────────────────────────────────────────────────
local vignette = Instance.new("ImageLabel")
vignette.Size               = UDim2.new(1, 0, 1, 0)
vignette.BackgroundTransparency = 1
vignette.Image              = "rbxassetid://1768714171"
vignette.ImageColor3        = Color3.fromRGB(160, 0, 0)
vignette.ImageTransparency  = 1
vignette.ZIndex             = 5
vignette.Parent             = gui

-- ── STATIC OVERLAY ────────────────────────────────────────────
local staticOverlay = Instance.new("Frame")
staticOverlay.Size              = UDim2.new(1, 0, 1, 0)
staticOverlay.BackgroundColor3  = Color3.fromRGB(255, 255, 255)
staticOverlay.BackgroundTransparency = 1
staticOverlay.ZIndex            = 10
staticOverlay.Parent            = gui

-- ── HALUSINASI TEKS ───────────────────────────────────────────
local halaText = Instance.new("TextLabel")
halaText.Size               = UDim2.new(0.6, 0, 0, 50)
halaText.AnchorPoint        = Vector2.new(0.5, 0.5)
halaText.Position           = UDim2.new(0.5, 0, 0.5, 0)
halaText.BackgroundTransparency = 1
halaText.Text               = ""
halaText.TextColor3         = Color3.fromRGB(255, 40, 40)
halaText.TextSize           = 28
halaText.Font               = Enum.Font.Code
halaText.TextTransparency   = 1
halaText.ZIndex             = 12
halaText.TextWrapped        = true
halaText.Parent             = gui

-- ── PESAN SISTEM ──────────────────────────────────────────────
local sysMsg = Instance.new("TextLabel")
sysMsg.Size               = UDim2.new(0.6, 0, 0, 32)
sysMsg.AnchorPoint        = Vector2.new(0.5, 1)
sysMsg.Position           = UDim2.new(0.5, 0, 1, -45)
sysMsg.BackgroundTransparency = 1
sysMsg.Text               = ""
sysMsg.TextColor3         = Color3.fromRGB(220, 220, 220)
sysMsg.TextSize           = 15
sysMsg.Font               = Enum.Font.Code
sysMsg.TextTransparency   = 1
sysMsg.ZIndex             = 15
sysMsg.Parent             = gui

-- ── TOMBOL PALSU CONTAINER ────────────────────────────────────
local fakeButtons = {}

-- ── WHITE FLASH (Room 2) ──────────────────────────────────────
local whiteFlash = Instance.new("Frame")
whiteFlash.Size               = UDim2.new(1, 0, 1, 0)
whiteFlash.BackgroundColor3   = Color3.fromRGB(255, 255, 255)
whiteFlash.BackgroundTransparency = 1
whiteFlash.ZIndex             = 50
whiteFlash.Parent             = gui

-- ── GUESS PHASE OVERLAY ───────────────────────────────────────
local guessOverlay = Instance.new("Frame")
guessOverlay.Size               = UDim2.new(1, 0, 1, 0)
guessOverlay.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
guessOverlay.BackgroundTransparency = 1
guessOverlay.ZIndex             = 60
guessOverlay.Visible            = false
guessOverlay.Parent             = gui

-- ================================================================
--  HELPER FUNCTIONS
-- ================================================================
local function showSysMsg(txt, col, duration)
    col      = col      or Color3.fromRGB(200, 200, 200)
    duration = duration or 3
    sysMsg.Text       = txt
    sysMsg.TextColor3 = col
    TweenService:Create(sysMsg, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    task.delay(duration, function()
        TweenService:Create(sysMsg, TweenInfo.new(0.6), {TextTransparency = 1}):Play()
    end)
end

local function updateHUD()
    local s = math.clamp(sanity, 0, 100)
    sanityLabel.Text = string.format("Kuwarasan: %d%%", math.floor(s))

    -- Bar fill
    TweenService:Create(barFill, TweenInfo.new(0.35), {
        Size = UDim2.new(s/100, 0, 1, 0)
    }):Play()

    -- Warna
    local r, g, b, sr, sg, sb
    if s > 70 then
        r,g,b = 0,255,136;  sr,sg,sb = 0,255,136
    elseif s > 50 then
        r,g,b = 255,200,0;  sr,sg,sb = 255,200,0
    elseif s > 20 then
        r,g,b = 255,80,0;   sr,sg,sb = 255,80,0
    else
        r,g,b = 255,30,30;  sr,sg,sb = 255,30,30
    end
    sanityLabel.TextColor3    = Color3.fromRGB(r, g, b)
    barFill.BackgroundColor3  = Color3.fromRGB(r, g, b)
    hudStroke.Color           = Color3.fromRGB(sr, sg, sb)
end

local function flash(duration, transparency)
    staticOverlay.BackgroundTransparency = transparency or 0.5
    task.delay(duration or 0.12, function()
        staticOverlay.BackgroundTransparency = 1
    end)
end

-- ================================================================
--  CAMERA SHAKE
-- ================================================================
local shakeIntensity = 0
local shakeTick      = 0

local function getCameraShake(dt)
    if shakeIntensity <= 0 then return CFrame.new() end
    shakeTick += dt * 8
    local x = math.sin(shakeTick * 1.4) * shakeIntensity
    local y = math.cos(shakeTick * 0.8) * shakeIntensity * 0.5
    local tilt = math.sin(shakeTick * 0.45) * shakeIntensity * 0.015
    return CFrame.new(x, y, 0) * CFrame.Angles(0, 0, tilt)
end

-- ================================================================
--  HALUSINASI TEKS
-- ================================================================
local halaMessages = {
    "kamu tidak sendiri",   "matikan permainan ini",
    "dia ada di belakangmu","LARI",
    "tombol itu palsu",     "...........",
    "JANGAN PENCET",        "kamu sudah mati",
    "ini bukan nyata",      "BANTUAN",
    "dia melihatmu",        "404 ERROR REALITAS",
    "PERGI",                "kamu tidak akan keluar",
    "BERBALIK",             "aku di sini",
}
local lastHalaTime = 0
local halaMinInterval = 5

local function tryHalaText()
    if tick() - lastHalaTime < halaMinInterval then return end
    lastHalaTime = tick()
    halaText.Text      = halaMessages[math.random(#halaMessages)]
    halaText.Position  = UDim2.new(0.05 + math.random()*0.6, 0,
                                    0.1  + math.random()*0.7, 0)
    halaText.TextSize  = math.random(18, 44)
    TweenService:Create(halaText, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    task.delay(1.2 + math.random(), function()
        TweenService:Create(halaText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    end)
end

-- ================================================================
--  NPC HALUSINASI (client-side, hanya kejar lalu hilang)
-- ================================================================
local halaNPCs        = {}
local halaSpawnCD     = 0

local function spawnHalaNPC()
    local npcM = Instance.new("Model"); npcM.Name="HalaNPC"; npcM.Parent=workspace
    local angle = math.random() * math.pi * 2
    local dist  = math.random(18, 35)
    local spawnPos = hrp.Position + Vector3.new(
        math.cos(angle)*dist, 0, math.sin(angle)*dist)

    local torso = Instance.new("Part")
    torso.Size        = Vector3.new(2, 2.5, 1)
    torso.BrickColor  = BrickColor.new("White")
    torso.Material    = Enum.Material.SmoothPlastic
    torso.Anchored    = true
    torso.CanCollide  = false
    torso.CastShadow  = false
    torso.Transparency= 0.3
    torso.CFrame      = CFrame.new(spawnPos, hrp.Position)
    torso.Parent      = npcM

    local head = torso:Clone()
    head.Size   = Vector3.new(1.5, 1.5, 1.5)
    head.CFrame = torso.CFrame * CFrame.new(0, 2.2, 0)
    head.Parent = npcM
    npcM.PrimaryPart = torso

    table.insert(halaNPCs, {
        model = npcM, torso = torso, head = head,
        timer = 0, alive = true
    })
end

local function updateHalaNPCs(dt)
    for i = #halaNPCs, 1, -1 do
        local n = halaNPCs[i]
        if not n.alive or not n.model.Parent then
            table.remove(halaNPCs, i); continue
        end

        n.timer += dt
        local toP = hrp.Position - n.torso.Position
        local dist = toP.Magnitude

        -- Gerak ke player
        if dist > 2 then
            local spd = (sanity < 20) and 20 or 13
            n.torso.CFrame = CFrame.new(
                n.torso.Position + toP.Unit * spd * dt,
                hrp.Position
            )
            n.head.CFrame = n.torso.CFrame * CFrame.new(0, 2.2, 0)
        end

        -- Kalau dekat atau terlalu lama → hilang
        if dist < 4 or n.timer > 9 then
            n.alive = false
            local mdl = n.model
            task.spawn(function()
                for j = 1, 12 do
                    for _, p in ipairs(mdl:GetChildren()) do
                        if p:IsA("BasePart") then
                            p.Transparency = j/12
                        end
                    end
                    task.wait(0.04)
                end
                mdl:Destroy()
            end)
            table.remove(halaNPCs, i)
            if dist < 4 then
                shakeIntensity = math.max(shakeIntensity, 0.18)
                flash(0.15, 0.65)
            end
        end
    end
end

-- ================================================================
--  NPC NYATA (< 20% sanity) — serang 5 detik lalu hilang
-- ================================================================
local realNPCCD     = 0
local realNPCActive = false

local function spawnRealNPC()
    if realNPCActive then return end
    realNPCActive = true
    showSysMsg("⚠ SESUATU MENDEKAT...", Color3.fromRGB(255, 50, 50))

    local npcM = Instance.new("Model"); npcM.Name="RealNPC"; npcM.Parent=workspace
    local angle = math.random() * math.pi * 2
    local sp = hrp.Position + Vector3.new(math.cos(angle)*25, 0, math.sin(angle)*25)

    local torso = Instance.new("Part")
    torso.Size        = Vector3.new(2, 2.8, 1)
    torso.BrickColor  = BrickColor.new("Really black")
    torso.Material    = Enum.Material.SmoothPlastic
    torso.Anchored    = true
    torso.CanCollide  = false
    torso.CastShadow  = false
    torso.CFrame      = CFrame.new(sp, hrp.Position)
    torso.Parent      = npcM

    local eyeL = Instance.new("Part"); eyeL.Size=Vector3.new(0.35,0.35,0.2)
    eyeL.BrickColor=BrickColor.new("Bright red"); eyeL.Material=Enum.Material.Neon
    eyeL.Anchored=true; eyeL.CanCollide=false; eyeL.CastShadow=false
    eyeL.CFrame = torso.CFrame * CFrame.new(-0.4, 0.5, -0.55)
    eyeL.Parent = npcM

    local eyeR = eyeL:Clone()
    eyeR.CFrame = torso.CFrame * CFrame.new(0.4, 0.5, -0.55)
    eyeR.Parent = npcM
    npcM.PrimaryPart = torso

    local alive = true
    task.delay(5, function() alive = false end)

    task.spawn(function()
        local t = 0
        while alive and npcM.Parent do
            t += task.wait(1/30)
            local toP  = hrp.Position - torso.Position
            local dist = toP.Magnitude
            if dist > 1.5 then
                local newPos = torso.Position + toP.Unit * 24 * (1/30)
                torso.CFrame = CFrame.new(newPos, hrp.Position)
                eyeL.CFrame  = torso.CFrame * CFrame.new(-0.4, 0.5, -0.55)
                eyeR.CFrame  = torso.CFrame * CFrame.new( 0.4, 0.5, -0.55)
            end
            if dist < 3 then
                sanity = math.max(0, sanity - 0.4)
                shakeIntensity = 0.35
                flash(0.08, 0.55)
            end
        end

        -- Fade out
        for j = 1, 12 do
            for _, p in ipairs(npcM:GetChildren()) do
                if p:IsA("BasePart") then p.Transparency = j/12 end
            end
            task.wait(0.04)
        end
        npcM:Destroy()
        realNPCActive = false
        showSysMsg("...pergi.", Color3.fromRGB(150,150,150))
    end)
end

-- ================================================================
--  10 NPC MASSAL (< 10% sanity)
-- ================================================================
local massNPCCD     = 0
local massNPCActive = false

local function spawnMassNPCs()
    if massNPCActive then return end
    massNPCActive = true
    showSysMsg("MEREKA SEMUA DATANG.", Color3.fromRGB(255, 0, 0), 5)
    flash(0.3, 0.3)

    for i = 1, 10 do
        task.spawn(function()
            task.wait(i * 0.25)
            local npcM = Instance.new("Model")
            npcM.Name = "MassNPC_"..i; npcM.Parent = workspace
            local angle = (i/10) * math.pi * 2 + math.random()*0.5
            local sp = hrp.Position + Vector3.new(
                math.cos(angle)*32, 0, math.sin(angle)*32)

            local torso = Instance.new("Part")
            torso.Size       = Vector3.new(1.8, 2.5, 1)
            torso.BrickColor = BrickColor.new("Really black")
            torso.Material   = Enum.Material.SmoothPlastic
            torso.Anchored   = true; torso.CanCollide=false; torso.CastShadow=false
            torso.CFrame     = CFrame.new(sp, hrp.Position)
            torso.Parent     = npcM
            npcM.PrimaryPart = torso

            local eye = Instance.new("Part"); eye.Size=Vector3.new(0.3,0.3,0.2)
            eye.BrickColor=BrickColor.new("Bright red"); eye.Material=Enum.Material.Neon
            eye.Anchored=true; eye.CanCollide=false; eye.CastShadow=false
            eye.CFrame = torso.CFrame * CFrame.new(0, 0.5, -0.55); eye.Parent=npcM

            local alive2 = true
            task.delay(10, function() alive2=false; if npcM.Parent then npcM:Destroy() end end)

            while alive2 and npcM.Parent do
                task.wait(1/30)
                local toP  = hrp.Position - torso.Position
                local dist = toP.Magnitude
                if dist > 1.5 then
                    local np = torso.Position + toP.Unit * 20 * (1/30)
                    torso.CFrame = CFrame.new(np, hrp.Position)
                    eye.CFrame   = torso.CFrame * CFrame.new(0, 0.5, -0.55)
                end
                if dist < 3 then
                    sanity = math.max(0, sanity - 0.15)
                    shakeIntensity = 0.45
                end
            end
        end)
    end

    task.delay(12, function() massNPCActive = false end)
end

-- ================================================================
--  TOMBOL PALSU GUI (< 20%)
-- ================================================================
local fakeBtnCD   = 0
local fakeBtnList = {}

local function spawnFakeBtn()
    if #fakeBtnList >= 3 then return end
    fakeBtnCD = math.random(4, 9)

    local fb = Instance.new("TextButton")
    fb.Size             = UDim2.new(0, 130, 0, 42)
    fb.Position         = UDim2.new(0.05 + math.random()*0.65, 0,
                                     0.08 + math.random()*0.6, 0)
    fb.BackgroundColor3 = Color3.fromRGB(40, 180, 60)
    fb.Text             = "[ TEKAN INI ]"
    fb.Font             = Enum.Font.Code
    fb.TextSize         = 14
    fb.TextColor3       = Color3.fromRGB(0, 0, 0)
    fb.ZIndex           = 20
    fb.Parent           = gui
    Instance.new("UICorner", fb).CornerRadius = UDim.new(0, 6)

    table.insert(fakeBtnList, fb)

    fb.MouseButton1Click:Connect(function()
        sanity = math.max(0, sanity - 4)
        showSysMsg("...kamu menekan udara.", Color3.fromRGB(255, 80, 80))
        shakeIntensity = math.max(shakeIntensity, 0.25)
        fb:Destroy()
        local idx = table.find(fakeBtnList, fb)
        if idx then table.remove(fakeBtnList, idx) end
    end)

    task.delay(7, function()
        if fb.Parent then fb:Destroy() end
        local idx = table.find(fakeBtnList, fb)
        if idx then table.remove(fakeBtnList, idx) end
    end)
end

-- ================================================================
--  LOST CONTROL (< 10%)
-- ================================================================
local lcTimer    = 0
local jumpCD     = 0
local partialCD  = 0

local function applyLostControl(dt)
    lcTimer += dt; jumpCD -= dt

    if lcTimer > 0.45 then
        lcTimer = 0
        local rd = Vector3.new(math.random(-1,1), 0, math.random(-1,1))
        if rd.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = rd.Unit * 22
        end
    end

    if jumpCD <= 0 and math.random() < 0.025 then
        humanoid.Jump = true
        jumpCD = math.random(1, 4)
    end
end

local function applyPartialControl(dt)
    partialCD -= dt
    if partialCD <= 0 then
        partialCD = math.random(3, 6)
        if math.random() < 0.45 then
            local rd = Vector3.new(math.random(-1,1), 0, math.random(-1,1))
            if rd.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = rd.Unit * 11
                task.delay(0.35, function()
                    if hrp and hrp.Parent then
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end)
            end
        end
    end
end

-- ================================================================
--  TOUCH DETECTION — Tombol & Jebakan
-- ================================================================
local function setupTouchDetection()
    -- Jebakan di lorong
    for _, trap in ipairs(trapParts) do
        trap.Touched:Connect(function(hit)
            if hit.Parent == character then
                sanity = math.max(0, sanity - 10)
                humanoid.Health -= 18
                shakeIntensity = math.max(shakeIntensity, 0.5)
                flash(0.2, 0.4)
                showSysMsg("JEBAKAN!", Color3.fromRGB(255, 50, 50))
            end
        end)
    end

    -- Tombol Room 1
    for _, btn in ipairs(r1BtnParts) do
        btn.Touched:Connect(function(hit)
            if hit.Parent == character and btn.Parent then
                r1ButtonsFound += 1
                sanity = math.min(100, sanity + 3)
                btn:Destroy()
                showSysMsg(string.format("Tombol (%d/%d) ditemukan!", r1ButtonsFound, #r1BtnParts),
                    Color3.fromRGB(100, 255, 150))

                if r1ButtonsFound >= #r1BtnParts then
                    showSysMsg("SEMUA TOMBOL ROOM 1 TERKUMPUL! Lanjut →",
                        Color3.fromRGB(0, 255, 136), 5)
                    -- Update portal label
                    if portalToR2 then
                        local bb = portalToR2:FindFirstChildOfClass("BillboardGui")
                        if bb then
                            local tl = bb:FindFirstChildOfClass("TextLabel")
                            if tl then tl.Text = "[ MASUK ROOM 2 ]" end
                        end
                        portalToR2.BrickColor = BrickColor.new("Bright green")
                    end
                end
            end
        end)
    end

    -- Portal ke Room 1
    if portalToR1 then
        portalToR1.Touched:Connect(function(hit)
            if hit.Parent == character then
                hrp.CFrame = CFrame.new(ROOM1_ENTER_POS)
                showSysMsg("Kamu memasuki Ruangan Putih 1.", Color3.fromRGB(200,200,200))
            end
        end)
    end

    -- Portal ke Room 2 (hanya bisa kalau tombol R1 sudah semua)
    if portalToR2 then
        portalToR2.Touched:Connect(function(hit)
            if hit.Parent == character then
                if r1ButtonsFound < #r1BtnParts then
                    showSysMsg(string.format("Masih kurang %d tombol!",
                        #r1BtnParts - r1ButtonsFound),
                        Color3.fromRGB(255,150,50))
                    return
                end
                hrp.CFrame = CFrame.new(ROOM2_ENTER_POS)
                showSysMsg("Kamu memasuki Ruangan Putih 2...", Color3.fromRGB(200,200,200))
                task.delay(0.5, function()
                    -- Efek silau
                    TweenService:Create(whiteFlash, TweenInfo.new(0.6),
                        {BackgroundTransparency = 0}):Play()
                    task.delay(1, function()
                        TweenService:Create(whiteFlash, TweenInfo.new(2),
                            {BackgroundTransparency = 0.82}):Play()
                        TweenService:Create(game.Lighting, TweenInfo.new(2), {
                            Brightness = 4
                        }):Play()
                    end)
                    showSysMsg("matamu terasa sakit... ini terlalu terang.",
                        Color3.fromRGB(220,220,220), 4)
                    enteredRoom2 = true
                end)
            end
        end)
    end

    -- Tombol Room 2
    for _, btn2 in ipairs(r2BtnParts) do
        btn2.Touched:Connect(function(hit)
            if hit.Parent == character and btn2.Parent then
                r2ButtonsFound += 1
                sanity = math.min(100, sanity + 2)
                btn2:Destroy()
                showSysMsg(string.format("★ Tombol R2 (%d/10) ditemukan!", r2ButtonsFound),
                    Color3.fromRGB(255, 240, 80))

                if r2ButtonsFound >= 10 and not guessPhaseActive then
                    guessPhaseActive = true
                    task.delay(2, function()
                        sanity = math.max(0, sanity - 15)
                        showSysMsg("SEMUA TERKUMPUL. SEKARANG TEBAK.", Color3.fromRGB(255,0,0), 4)
                        task.delay(4, function()
                            startGuessPhase()
                        end)
                    end)
                end
            end
        end)
    end
end

-- ================================================================
--  GUESS PHASE
-- ================================================================
local GUESS_SCENARIOS = {
    {
        q = "Kamu mendengar langkah kaki tepat di belakangmu.\nApa yang ada di sana?",
        opts = {"Tidak ada siapa-siapa", "NPC jahat", "Jebakan tersembunyi", "Pintu keluar"},
        correct = 1,
        wrongMsg = "Salah. Itu bukan halusinasi.",
        wrongSanity = -12,
    },
    {
        q = "Lantai merah di depanmu bersinar.\nApakah aman dilewati?",
        opts = {"Ya, aman saja", "Tidak, itu jebakan", "Melompatinya", "Putar balik"},
        correct = 2,
        wrongMsg = "KAMU MENGINJAK JEBAKAN!",
        wrongSanity = -10,
        wrongDmg = 25,
    },
    {
        q = "Ada tombol hijau dan tombol merah.\nMana yang membuka pintu?",
        opts = {"Tombol Hijau", "Tombol Merah", "Keduanya sekaligus", "Tidak ada"},
        correct = 1,
        wrongMsg = "Alarm berbunyi keras. Mereka tahu kamu di sini.",
        wrongSanity = -15,
    },
    {
        q = "NPC berdiri diam di sudut, tidak bergerak.\nApa yang harus kamu lakukan?",
        opts = {"Dekati dia", "Abaikan dan lewat", "Lari sekencang mungkin", "Ajak bicara"},
        correct = 2,
        wrongMsg = "Kontak mata. Dia mulai bergerak.",
        wrongSanity = -18,
    },
    {
        q = "Suara gemuruh keras dari atas langit-langit.\nItu adalah...",
        opts = {"Halusinasi jet tempur", "Tikus di plafon", "Kipas angin rusak", "Bukan apa-apa"},
        correct = 1,
        wrongMsg = "Kamu tidak percaya matamu sendiri.",
        wrongSanity = -10,
    },
    {
        q = "Kamu melihat dirimu sendiri berdiri di ujung lorong.\nApa yang kamu lakukan?",
        opts = {"Lari menjauhi", "Dekati sosok itu", "Pejamkan mata", "Teriaki dia"},
        correct = 1,
        wrongMsg = "Kamu berjalan menuju dirimu sendiri... dan menghilang.",
        wrongSanity = -20,
    },
}

local guessRound = 0

function startGuessPhase()
    guessRound += 1
    if guessRound > #GUESS_SCENARIOS then
        -- Selesai semua soal = menang
        showSysMsg("KAMU SELAMAT. ATAU TIDAK?", Color3.fromRGB(0, 255, 136), 8)
        guessPhaseActive = false
        return
    end

    local sc = GUESS_SCENARIOS[guessRound]
    guessOverlay.Visible            = true
    guessOverlay.BackgroundTransparency = 0.4

    -- Hapus isi lama
    for _, ch in ipairs(guessOverlay:GetChildren()) do ch:Destroy() end

    -- Panel
    local panel = Instance.new("Frame")
    panel.Size              = UDim2.new(0, 520, 0, 310)
    panel.AnchorPoint       = Vector2.new(0.5, 0.5)
    panel.Position          = UDim2.new(0.5, 0, 0.5, 0)
    panel.BackgroundColor3  = Color3.fromRGB(8, 8, 8)
    panel.BorderSizePixel   = 0
    panel.ZIndex            = 61
    panel.Parent            = guessOverlay
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

    local panelStroke = Instance.new("UIStroke", panel)
    panelStroke.Color     = Color3.fromRGB(255, 40, 40)
    panelStroke.Thickness = 2

    -- Header
    local header = Instance.new("TextLabel")
    header.Size               = UDim2.new(1, 0, 0, 38)
    header.Position           = UDim2.new(0, 0, 0, 8)
    header.BackgroundTransparency = 1
    header.Text               = "⚠  TEBAK ATAU MATI  ⚠   ["..guessRound.."/"..#GUESS_SCENARIOS.."]"
    header.TextColor3         = Color3.fromRGB(255, 40, 40)
    header.Font               = Enum.Font.Code
    header.TextSize           = 18
    header.ZIndex             = 62
    header.Parent             = panel

    -- Timer bar
    local tBarBg = Instance.new("Frame")
    tBarBg.Size             = UDim2.new(0.9, 0, 0, 6)
    tBarBg.Position         = UDim2.new(0.05, 0, 0, 48)
    tBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tBarBg.BorderSizePixel  = 0
    tBarBg.ZIndex           = 62
    tBarBg.Parent           = panel
    Instance.new("UICorner", tBarBg).CornerRadius = UDim.new(1, 0)

    local tBar = Instance.new("Frame")
    tBar.Size            = UDim2.new(1, 0, 1, 0)
    tBar.BackgroundColor3= Color3.fromRGB(255, 200, 0)
    tBar.BorderSizePixel = 0
    tBar.ZIndex          = 63
    tBar.Parent          = tBarBg
    Instance.new("UICorner", tBar).CornerRadius = UDim.new(1, 0)

    -- Pertanyaan
    local qLabel = Instance.new("TextLabel")
    qLabel.Size               = UDim2.new(0.9, 0, 0, 72)
    qLabel.Position           = UDim2.new(0.05, 0, 0, 60)
    qLabel.BackgroundTransparency = 1
    qLabel.Text               = sc.q
    qLabel.TextColor3         = Color3.fromRGB(215, 215, 215)
    qLabel.Font               = Enum.Font.Code
    qLabel.TextSize           = 16
    qLabel.TextWrapped        = true
    qLabel.ZIndex             = 62
    qLabel.Parent             = panel

    -- Jawaban (2x2 grid)
    local answered = false
    local btnLayout = {
        {UDim2.new(0.04,0,0,140), UDim2.new(0.44,0,0,52)},
        {UDim2.new(0.52,0,0,140), UDim2.new(0.44,0,0,52)},
        {UDim2.new(0.04,0,0,200), UDim2.new(0.44,0,0,52)},
        {UDim2.new(0.52,0,0,200), UDim2.new(0.44,0,0,52)},
    }

    for i, opt in ipairs(sc.opts) do
        local ansBtn = Instance.new("TextButton")
        ansBtn.Position         = btnLayout[i][1]
        ansBtn.Size             = btnLayout[i][2]
        ansBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        ansBtn.Text             = opt
        ansBtn.TextColor3       = Color3.fromRGB(200, 200, 200)
        ansBtn.Font             = Enum.Font.Code
        ansBtn.TextSize         = 14
        ansBtn.TextWrapped      = true
        ansBtn.ZIndex           = 62
        ansBtn.Parent           = panel
        Instance.new("UICorner", ansBtn).CornerRadius = UDim.new(0, 6)
        local stroke2 = Instance.new("UIStroke", ansBtn)
        stroke2.Color = Color3.fromRGB(55, 55, 55); stroke2.Thickness = 1

        ansBtn.MouseEnter:Connect(function()
            ansBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end)
        ansBtn.MouseLeave:Connect(function()
            ansBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        end)

        ansBtn.MouseButton1Click:Connect(function()
            if answered then return end
            answered = true

            if i == sc.correct then
                ansBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 50)
                task.delay(1.8, function()
                    guessOverlay.Visible = false
                    for _, ch in ipairs(guessOverlay:GetChildren()) do ch:Destroy() end
                    task.delay(3, function()
                        startGuessPhase()
                    end)
                end)
            else
                ansBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
                sanity = math.max(0, sanity + (sc.wrongSanity or -10))
                if sc.wrongDmg then
                    humanoid.Health = humanoid.Health - sc.wrongDmg
                end
                shakeIntensity = math.max(shakeIntensity, 0.4)
                flash(0.25, 0.4)

                local wrongLbl = Instance.new("TextLabel")
                wrongLbl.Size               = UDim2.new(0.9, 0, 0, 28)
                wrongLbl.Position           = UDim2.new(0.05, 0, 0, 265)
                wrongLbl.BackgroundTransparency = 1
                wrongLbl.Text               = sc.wrongMsg
                wrongLbl.TextColor3         = Color3.fromRGB(255, 50, 50)
                wrongLbl.Font               = Enum.Font.Code
                wrongLbl.TextSize           = 14
                wrongLbl.ZIndex             = 62
                wrongLbl.Parent             = panel

                task.delay(2.5, function()
                    guessOverlay.Visible = false
                    for _, ch in ipairs(guessOverlay:GetChildren()) do ch:Destroy() end
                    -- Salah = ulangi soal yang sama + tambah NPC
                    if sanity < 20 and not realNPCActive then spawnRealNPC() end
                    task.delay(4, function()
                        startGuessPhase()
                    end)
                end)
            end
        end)
    end

    -- Timer 15 detik
    local timeLimit = 15
    task.spawn(function()
        local startT = tick()
        while tick()-startT < timeLimit and guessOverlay.Visible and not answered do
            local frac = 1 - (tick()-startT)/timeLimit
            tBar.Size = UDim2.new(frac, 0, 1, 0)
            tBar.BackgroundColor3 = frac < 0.3
                and Color3.fromRGB(255,50,50)
                or (frac < 0.6 and Color3.fromRGB(255,200,0) or Color3.fromRGB(0,200,100))
            task.wait(1/30)
        end

        if not answered and guessOverlay.Visible then
            answered = true
            sanity = math.max(0, sanity - 20)
            shakeIntensity = 0.5

            local toLbl = Instance.new("TextLabel")
            toLbl.Size               = UDim2.new(1, 0, 0, 28)
            toLbl.Position           = UDim2.new(0, 0, 0, 265)
            toLbl.BackgroundTransparency = 1
            toLbl.Text               = "WAKTU HABIS. KONSEKUENSINYA NYATA."
            toLbl.TextColor3         = Color3.fromRGB(255, 0, 0)
            toLbl.Font               = Enum.Font.Code
            toLbl.TextSize           = 14
            toLbl.ZIndex             = 62
            toLbl.Parent             = panel

            task.delay(2.5, function()
                guessOverlay.Visible = false
                for _, ch in ipairs(guessOverlay:GetChildren()) do ch:Destroy() end
                task.delay(4, function() startGuessPhase() end)
            end)
        end
    end)
end

-- ================================================================
--  TELEPORT AWAL KE SPAWN ROOM
-- ================================================================
task.wait(1.5)
buildWorld()
task.wait(0.5)
hrp.CFrame = CFrame.new(SPAWN_SPAWN_POS)
setupTouchDetection()
showSysMsg("Kamu terbangun di sini. Ada tombol biru di sana.",
    Color3.fromRGB(180, 180, 180), 5)

-- ================================================================
--  TOMBOL FLOAT ANIMATION
-- ================================================================
task.spawn(function()
    local t = 0
    while true do
        t += task.wait(1/30)
        for _, btn in ipairs(r1BtnParts) do
            if btn.Parent then
                local base = R1_BTN_POS[table.find(r1BtnParts, btn)]
                if base then
                    btn.CFrame = CFrame.new(Vector3.new(
                        base.X, base.Y + math.sin(t*2 + table.find(r1BtnParts,btn))*0.4, base.Z
                    ))
                end
            end
        end
        for _, btn in ipairs(r2BtnParts) do
            if btn.Parent then
                local base = R2_BTN_POS[table.find(r2BtnParts, btn)]
                if base then
                    btn.CFrame = CFrame.new(Vector3.new(
                        base.X, base.Y + math.sin(t*2 + table.find(r2BtnParts,btn)+5)*0.35, base.Z
                    ))
                end
            end
        end
    end
end)

-- ================================================================
--  MAIN RENDER LOOP
-- ================================================================
local notifsShown = {["70"]=false, ["50"]=false, ["20"]=false, ["10"]=false}

RunService.RenderStepped:Connect(function(dt)
    local s = math.clamp(sanity, 0, 100)

    -- HUD
    updateHUD()

    -- ── TIER 1: < 70% ───────────────────────────────────────────
    if s < 70 then
        local intensity = (70 - s) / 70 * 0.055
        shakeIntensity = math.max(shakeIntensity, intensity)
        vignette.ImageTransparency = 1 - ((70-s)/70 * 0.55)

        if not notifsShown["70"] then
            notifsShown["70"] = true
            showSysMsg("Kepalamu mulai terasa berat...", Color3.fromRGB(255,200,0), 4)
        end
    else
        vignette.ImageTransparency = math.min(vignette.ImageTransparency + dt*2, 1)
    end

    -- ── TIER 2: < 50% ───────────────────────────────────────────
    if s < 50 then
        shakeIntensity = math.max(shakeIntensity, 0.07)
        vignette.ImageTransparency = math.min(vignette.ImageTransparency, 0.35)
        halaMinInterval = 4

        -- NPC halusinasi
        halaSpawnCD -= dt
        if halaSpawnCD <= 0 and #halaNPCs < 2 then
            halaSpawnCD = math.random(6, 13)
            spawnHalaNPC()
        end

        tryHalaText()

        if not notifsShown["50"] then
            notifsShown["50"] = true
            showSysMsg("Kamu mulai melihat bayangan yang bergerak.",
                Color3.fromRGB(255,100,0), 4)
        end
    end

    -- ── TIER 3: < 20% ───────────────────────────────────────────
    if s < 20 then
        shakeIntensity = math.max(shakeIntensity, 0.16)
        vignette.ImageTransparency = math.min(vignette.ImageTransparency, 0.08)
        halaMinInterval = 2

        -- Tombol palsu
        fakeBtnCD -= dt
        if fakeBtnCD <= 0 then
            fakeBtnCD = math.random(4, 9)
            spawnFakeBtn()
        end

        -- NPC nyata
        realNPCCD -= dt
        if realNPCCD <= 0 and not realNPCActive then
            realNPCCD = math.random(8, 16)
            spawnRealNPC()
        end

        applyPartialControl(dt)

        if not notifsShown["20"] then
            notifsShown["20"] = true
            showSysMsg("REALITAS MULAI RETAK.", Color3.fromRGB(255,30,30), 4)
        end
    end

    -- ── TIER 4: < 10% ───────────────────────────────────────────
    if s < 10 then
        shakeIntensity = 0.32
        vignette.ImageTransparency = 0

        -- Static noise
        if math.random() < 0.06 then
            flash(0.06, 0.55 + math.random()*0.3)
        end

        applyLostControl(dt)

        massNPCCD -= dt
        if massNPCCD <= 0 and not massNPCActive then
            massNPCCD = 22
            spawnMassNPCs()
        end

        if not notifsShown["10"] then
            notifsShown["10"] = true
            showSysMsg("K A M U   T I D A K   B I S A   B E R H E N T I",
                Color3.fromRGB(255,0,0), 6)
        end
    end

    -- Camera shake
    if shakeIntensity > 0 then
        camera.CFrame = camera.CFrame * getCameraShake(dt)
        shakeIntensity = math.max(0, shakeIntensity - dt * 1.8)
    end

    -- Update hala NPCs
    updateHalaNPCs(dt)

    lastSanity = s
end)

print("╔══════════════════════════════╗")
print("║   SANITY GAME — LOADED ✓     ║")
print("║  Kuwarasan awal:", sanity, "%      ║")
print("╚══════════════════════════════╝")
