-- ██████████████████████████████████████████
--         פרחים  |  THE FLOWER
--   LocalScript — hanya terlihat oleh executer
-- ██████████████████████████████████████████

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Chat         = game:GetService("Chat")
local SoundService = game:GetService("SoundService")

local LocalPlayer  = Players.LocalPlayer

-- ════════════════════════════════════════════
--  CONFIG
-- ════════════════════════════════════════════
local FLOWER_SOUND_ID   = "rbxassetid://117135792761068"
local SOUND_PITCH       = 0.01
local SOUND_VOLUME      = 99
local SPAWN_DELAY       = 8
local TRIGGER_WAIT      = 5
local CHASE_SPEED       = 24
local NORMAL_SPEED      = 14
local CHAT_INTERVAL_MIN = 5
local CHAT_INTERVAL_MAX = 9
local KILL_DISTANCE     = 4

local TRIGGER_KEYWORDS = {
	"strange","aneh","ganjil","weird","étrange","extraño","seltsam","странный",
	"bot","bots","bot's","robot","robots","robot's","нпс","npc",
	"робот","ботс","fake","palsu","bohong","imitasi","creepy","sus","suspicious",
	"not real","not human","impostor","imposter","automated","machine",
}

local NPC_CHATS = {
	"Hai bro!","Let's playing!","Wanna team up?","This game is fun haha",
	"Hey! What are you doing?","Bro come here!","Let's go explore!",
	"Hiii :D","Ayo main bareng!","Seru banget nih game",
	"You seem kinda fun to play with!","Have you been here long?",
	"I just joined, is this place good?","Bro your outfit is cool ngl",
	"Can you show me around?","I keep getting lost lol",
	"What server is this?","Do you hear anything weird?",
	"I feel like we've met before...","Stay close, okay?",
}

-- ════════════════════════════════════════════
--  HELPER: buat Part + Weld ke root
-- ════════════════════════════════════════════
local function makePart(model, root, name, size, offsetCF, color, transparency)
	local p = Instance.new("Part")
	p.Name         = name
	p.Size         = size
	p.Color        = color or Color3.fromRGB(163,162,165)
	p.Material     = Enum.Material.SmoothPlastic
	p.CanCollide   = false
	p.Anchored     = false
	p.Transparency = transparency or 0
	p.CastShadow   = false
	p.Parent       = model

	local w = Instance.new("Motor6D")
	w.Name   = name.."_weld"
	w.Part0  = root
	w.Part1  = p
	w.C1     = offsetCF:Inverse()
	w.Parent = root

	return p
end

-- ════════════════════════════════════════════
--  BUILD: Avatar player biasa (warna skin default)
-- ════════════════════════════════════════════
local function buildPlayerModel(fakeName, spawnCF)
	local SKIN  = Color3.fromRGB(255, 204, 153)
	local SHIRT = Color3.fromRGB(math.random(50,200), math.random(50,200), math.random(50,200))
	local PANTS = Color3.fromRGB(math.random(30,120), math.random(30,120), math.random(30,120))
	local HAIR  = Color3.fromRGB(math.random(20,180), math.random(20,80), math.random(10,50))

	local model = Instance.new("Model")
	model.Name  = fakeName

	-- Root (invisible)
	local root = Instance.new("Part")
	root.Name        = "HumanoidRootPart"
	root.Size        = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.CanCollide  = false
	root.Anchored    = false
	root.CFrame      = spawnCF
	root.Parent      = model
	model.PrimaryPart = root

	-- Torso
	makePart(model, root, "Torso",      Vector3.new(2,2,1),     CFrame.new(0,  1,   0), SHIRT)
	-- Kepala
	local head = makePart(model, root, "Head", Vector3.new(2,1,1), CFrame.new(0, 2.5, 0), SKIN)
	-- Rambut (block di atas kepala)
	makePart(model, root, "Hair",       Vector3.new(2,0.4,1.1), CFrame.new(0, 3.15, 0), HAIR)
	-- Lengan
	makePart(model, root, "LeftArm",    Vector3.new(1,2,1),     CFrame.new(-1.5, 1, 0),  SKIN)
	makePart(model, root, "RightArm",   Vector3.new(1,2,1),     CFrame.new( 1.5, 1, 0),  SKIN)
	-- Kaki
	makePart(model, root, "LeftLeg",    Vector3.new(1,2,1),     CFrame.new(-0.5,-1, 0),  PANTS)
	makePart(model, root, "RightLeg",   Vector3.new(1,2,1),     CFrame.new( 0.5,-1, 0),  PANTS)

	-- Mata (2 Part kecil hitam)
	makePart(model, root, "LeftEye",    Vector3.new(0.3,0.3,0.1), CFrame.new(-0.35, 2.55, -0.5), Color3.new(0,0,0))
	makePart(model, root, "RightEye",   Vector3.new(0.3,0.3,0.1), CFrame.new( 0.35, 2.55, -0.5), Color3.new(0,0,0))

	-- Humanoid
	local hum = Instance.new("Humanoid")
	hum.WalkSpeed   = NORMAL_SPEED
	hum.DisplayName = fakeName
	hum.Parent      = model

	-- Billboard nama
	local bb = Instance.new("BillboardGui")
	bb.Size          = UDim2.new(0, 120, 0, 30)
	bb.StudsOffset   = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop   = false
	bb.Parent        = head

	local lbl = Instance.new("TextLabel")
	lbl.Size            = UDim2.new(1,0,1,0)
	lbl.BackgroundTransparency = 1
	lbl.Text            = fakeName
	lbl.TextColor3      = Color3.new(1,1,1)
	lbl.TextStrokeColor3 = Color3.new(0,0,0)
	lbl.TextStrokeTransparency = 0
	lbl.Font            = Enum.Font.GothamBold
	lbl.TextScaled      = true
	lbl.Parent          = bb

	model.Parent = workspace
	return model, hum, root
end

-- ════════════════════════════════════════════
--  BUILD: Model The Flower (פרחים) — pitch black, tall, jitter
-- ════════════════════════════════════════════
local function buildFlowerModel(spawnCF)
	local BLACK = Color3.fromRGB(5, 5, 5)

	local model = Instance.new("Model")
	model.Name  = "פרחים"

	local root = Instance.new("Part")
	root.Name        = "HumanoidRootPart"
	root.Size        = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.CanCollide  = false
	root.Anchored    = false
	root.CFrame      = spawnCF
	root.Parent      = model
	model.PrimaryPart = root

	-- Tubuh
	makePart(model, root, "UpperTorso",    Vector3.new(2, 3,   1),   CFrame.new(0,  1.5,  0), BLACK)
	makePart(model, root, "LowerTorso",    Vector3.new(2, 1.5, 1),   CFrame.new(0, -0.25, 0), BLACK)
	-- Kepala tinggi (ciri khas פרחים)
	makePart(model, root, "Head",          Vector3.new(1.5, 3.8, 1.2), CFrame.new(0, 4.9, 0), BLACK)
	-- Lengan panjang menjuntai
	makePart(model, root, "LeftUpperArm",  Vector3.new(0.9,2.5,0.9), CFrame.new(-1.7,  1.5,  0), BLACK)
	makePart(model, root, "LeftLowerArm",  Vector3.new(0.8,2.5,0.8), CFrame.new(-1.7, -1.2,  0), BLACK)
	makePart(model, root, "LeftHand",      Vector3.new(0.8,1.2,0.8), CFrame.new(-1.7, -3.1,  0), BLACK)
	makePart(model, root, "RightUpperArm", Vector3.new(0.9,2.5,0.9), CFrame.new( 1.7,  1.5,  0), BLACK)
	makePart(model, root, "RightLowerArm", Vector3.new(0.8,2.5,0.8), CFrame.new( 1.7, -1.2,  0), BLACK)
	makePart(model, root, "RightHand",     Vector3.new(0.8,1.2,0.8), CFrame.new( 1.7, -3.1,  0), BLACK)
	-- Kaki
	makePart(model, root, "LeftUpperLeg",  Vector3.new(0.9,2.5,0.9), CFrame.new(-0.7, -1.75, 0), BLACK)
	makePart(model, root, "LeftLowerLeg",  Vector3.new(0.8,2.5,0.8), CFrame.new(-0.7, -4.25, 0), BLACK)
	makePart(model, root, "LeftFoot",      Vector3.new(1.0,0.7,1.3), CFrame.new(-0.7, -5.95, 0), BLACK)
	makePart(model, root, "RightUpperLeg", Vector3.new(0.9,2.5,0.9), CFrame.new( 0.7, -1.75, 0), BLACK)
	makePart(model, root, "RightLowerLeg", Vector3.new(0.8,2.5,0.8), CFrame.new( 0.7, -4.25, 0), BLACK)
	makePart(model, root, "RightFoot",     Vector3.new(1.0,0.7,1.3), CFrame.new( 0.7, -5.95, 0), BLACK)

	-- Mata putih menyala (2 titik)
	makePart(model, root, "LeftEye",  Vector3.new(0.3,0.3,0.1), CFrame.new(-0.35, 5.1, -0.62), Color3.new(1,1,1))
	makePart(model, root, "RightEye", Vector3.new(0.3,0.3,0.1), CFrame.new( 0.35, 5.1, -0.62), Color3.new(1,1,1))

	-- Humanoid
	local hum = Instance.new("Humanoid")
	hum.WalkSpeed   = CHASE_SPEED
	hum.MaxHealth   = math.huge
	hum.Health      = math.huge
	hum.DisplayName = "פרחים"
	hum.Parent      = model

	model.Parent = workspace

	-- Jitter terus-menerus
	task.spawn(function()
		while model and model.Parent do
			local jx = (math.random() - 0.5) * 0.14
			local jy = (math.random() - 0.5) * 0.07
			local jz = (math.random() - 0.5) * 0.14
			root.CFrame = root.CFrame * CFrame.new(jx, jy, jz)
			task.wait(0.05)
		end
	end)

	return model, hum, root
end

-- ════════════════════════════════════════════
--  SCREEN EFFECT — vignette merah ↔ hitam transparan
--  (tengah transparan, tepi merah/hitam bergantian)
-- ════════════════════════════════════════════
local effectGui = nil

local function createEffect()
	if effectGui then effectGui:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name           = "FlowerEffect"
	gui.ResetOnSpawn   = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent         = LocalPlayer.PlayerGui

	-- 4 frame tepi: atas, bawah, kiri, kanan
	-- Masing-masing pakai UIGradient untuk fade ke transparan ke tengah
	local sides = {
		{size = UDim2.new(1,0,0.35,0), pos = UDim2.new(0,0,0,0),    rot = 0},   -- atas
		{size = UDim2.new(1,0,0.35,0), pos = UDim2.new(0,0,0.65,0), rot = 180}, -- bawah
		{size = UDim2.new(0.3,0,1,0),  pos = UDim2.new(0,0,0,0),    rot = 270}, -- kiri
		{size = UDim2.new(0.3,0,1,0),  pos = UDim2.new(0.7,0,0,0),  rot = 90},  -- kanan
	}

	local frames = {}
	for _, s in ipairs(sides) do
		local f = Instance.new("Frame")
		f.Size                   = s.size
		f.Position               = s.pos
		f.BackgroundColor3       = Color3.fromRGB(180, 0, 0)
		f.BackgroundTransparency = 0
		f.BorderSizePixel        = 0
		f.ZIndex                 = 10
		f.Parent                 = gui

		local g = Instance.new("UIGradient")
		g.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),    -- tepi: opaque
			NumberSequenceKeypoint.new(1, 1),    -- tengah: transparan
		})
		g.Rotation = s.rot
		g.Parent   = f

		table.insert(frames, f)
	end

	effectGui = gui

	-- Loop transisi warna: merah → hitam → merah
	task.spawn(function()
		local info = TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		while effectGui and effectGui.Parent do
			-- → hitam pekat
			for _, f in ipairs(frames) do
				TweenService:Create(f, info, {
					BackgroundColor3 = Color3.fromRGB(5, 0, 0)
				}):Play()
			end
			task.wait(1.4)
			if not effectGui or not effectGui.Parent then break end
			-- → merah
			for _, f in ipairs(frames) do
				TweenService:Create(f, info, {
					BackgroundColor3 = Color3.fromRGB(180, 0, 0)
				}):Play()
			end
			task.wait(1.4)
		end
	end)
end

local function removeEffect()
	if effectGui then effectGui:Destroy(); effectGui = nil end
end

-- ════════════════════════════════════════════
--  SOUND
-- ════════════════════════════════════════════
local flowerSound = nil

local function playSound()
	if flowerSound then flowerSound:Destroy() end
	local s = Instance.new("Sound")
	s.SoundId       = FLOWER_SOUND_ID
	s.Volume        = SOUND_VOLUME
	s.PlaybackSpeed = SOUND_PITCH
	s.Looped        = true
	s.Parent        = SoundService
	s:Play()
	flowerSound = s
end

local function stopSound()
	if flowerSound then flowerSound:Stop(); flowerSound:Destroy(); flowerSound = nil end
end

-- ════════════════════════════════════════════
--  RANDOM NAME
-- ════════════════════════════════════════════
local function fakeName()
	local a = {"xX","Pro","Ultra","Dark","Ghost","Hyper","Shadow","Real"}
	local b = {"Player","Gamer","Storm","Void","Fire","Ice","Blade","Edge"}
	local c = {"123","456","YT","_lol","777","HD","_gg","xD"}
	return a[math.random(#a)]..b[math.random(#b)]..c[math.random(#c)]
end

-- ════════════════════════════════════════════
--  STATE
-- ════════════════════════════════════════════
local npcModel  = nil
local npcHum    = nil
local npcRoot   = nil
local isFlower  = false
local triggered = false
local chatConn  = nil
local chaseConn = nil
local lastPos   = Vector3.new(0, 5, 0)

local function destroyAll()
	isFlower = false; triggered = false
	if chatConn  then chatConn:Disconnect();  chatConn  = nil end
	if chaseConn then chaseConn:Disconnect(); chaseConn = nil end
	if npcModel and npcModel.Parent then npcModel:Destroy() end
	npcModel = nil; npcHum = nil; npcRoot = nil
	removeEffect()
	stopSound()
end

local function voidGuard()
	if npcRoot and npcRoot.Parent then
		if npcRoot.Position.Y < -80 then
			npcRoot.CFrame = CFrame.new(lastPos + Vector3.new(0, 5, 0))
		else
			lastPos = npcRoot.Position
		end
	end
end

local function killPlayer()
	local char = LocalPlayer.Character
	if not char then return end
	local h = char:FindFirstChildOfClass("Humanoid")
	if h then h.Health = 0 end
end

-- ════════════════════════════════════════════
--  TRANSFORM → THE FLOWER
-- ════════════════════════════════════════════
local function transformToFlower()
	isFlower = true
	local oldPos = lastPos

	if npcModel and npcModel.Parent then npcModel:Destroy() end
	npcModel = nil; npcHum = nil; npcRoot = nil

	local spawnCF = CFrame.new(oldPos + Vector3.new(0, 3, 0))
	local model, hum, root = buildFlowerModel(spawnCF)
	npcModel = model; npcHum = hum; npcRoot = root
	lastPos = root.Position

	createEffect()
	playSound()

	if chaseConn then chaseConn:Disconnect() end
	chaseConn = RunService.Heartbeat:Connect(function()
		if not npcHum or not npcRoot or not npcRoot.Parent then return end
		local char = LocalPlayer.Character
		if not char then return end
		local pr = char:FindFirstChild("HumanoidRootPart")
		if not pr then return end

		voidGuard()
		npcHum:MoveTo(pr.Position)

		if (npcRoot.Position - pr.Position).Magnitude <= KILL_DISTANCE then
			killPlayer()
		end
	end)
end

-- ════════════════════════════════════════════
--  NPC SAY
-- ════════════════════════════════════════════
local function npcSay(text)
	if npcModel then
		local head = npcModel:FindFirstChild("Head")
		if head then Chat:Chat(head, text, Enum.ChatColor.White) end
	end
end

-- ════════════════════════════════════════════
--  TRIGGER CHECK
-- ════════════════════════════════════════════
local function hasTrigger(msg)
	local low = msg:lower()
	for _, kw in ipairs(TRIGGER_KEYWORDS) do
		if low:find(kw, 1, true) then return true end
	end
	return false
end

-- ════════════════════════════════════════════
--  MODE PLAYER
-- ════════════════════════════════════════════
local function startPlayerMode(model, hum, root)
	npcModel = model; npcHum = hum; npcRoot = root
	lastPos = root.Position

	-- Chat random loop
	task.spawn(function()
		task.wait(2)
		while not isFlower and npcModel and npcModel.Parent do
			npcSay(NPC_CHATS[math.random(#NPC_CHATS)])
			task.wait(math.random(CHAT_INTERVAL_MIN, CHAT_INTERVAL_MAX))
		end
	end)

	-- Wander mendekati player
	task.spawn(function()
		while not isFlower and npcModel and npcModel.Parent do
			local c = LocalPlayer.Character
			if c then
				local pr = c:FindFirstChild("HumanoidRootPart")
				if pr and hum then
					hum:MoveTo(pr.Position + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
				end
			end
			voidGuard()
			task.wait(3 + math.random(0,2))
		end
	end)

	-- Listen chat player
	chatConn = LocalPlayer.Chatted:Connect(function(msg)
		if triggered then return end
		if hasTrigger(msg) then
			triggered = true
			if chatConn then chatConn:Disconnect(); chatConn = nil end
			npcSay("...")
			task.wait(TRIGGER_WAIT)
			transformToFlower()
		end
	end)
end

-- ════════════════════════════════════════════
--  EXECUTE
-- ════════════════════════════════════════════
local function execute()
	destroyAll()
	task.wait(SPAWN_DELAY)

	local name = fakeName()

	-- Spawn dekat player
	local spawnCF = CFrame.new(0, 5, 0)
	local char = LocalPlayer.Character
	if char then
		local pr = char:FindFirstChild("HumanoidRootPart")
		if pr then
			spawnCF = pr.CFrame * CFrame.new(math.random(-8,8), 0, math.random(-6,6))
		end
	end

	local model, hum, root = buildPlayerModel(name, spawnCF)
	startPlayerMode(model, hum, root)
end

LocalPlayer.CharacterRemoving:Connect(destroyAll)
execute()
