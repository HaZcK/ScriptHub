-- ██████████████████████████████████████████
--         פרחים  |  THE FLOWER
--   LocalScript — hanya terlihat oleh executer
-- ██████████████████████████████████████████

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local Chat          = game:GetService("Chat")
local SoundService  = game:GetService("SoundService")

local LocalPlayer   = Players.LocalPlayer

-- ════════════════════════════════════════════
--  CONFIG
-- ════════════════════════════════════════════
local FLOWER_SOUND_ID   = "rbxassetid://117135792761068"
local SOUND_PITCH       = 0.01   -- PlaybackSpeed
local SOUND_VOLUME      = 99

local SPAWN_DELAY       = 8      -- detik sebelum NPC muncul
local TRIGGER_WAIT      = 5      -- detik "..." sebelum transform
local CHASE_SPEED       = 24
local NORMAL_SPEED      = 14
local CHAT_INTERVAL_MIN = 5
local CHAT_INTERVAL_MAX = 9
local KILL_DISTANCE     = 4      -- studs, NPC menyentuh = player mati

-- Kata kunci trigger
local TRIGGER_KEYWORDS = {
	"strange","aneh","ganjil","weird","étrange","extraño","seltsam","странный",
	"bot","bots","bot's","robot","robots","robot's","нпс","npc",
	"робот","ботс","fake","palsu","bohong","imitasi","creepy","sus","suspicious",
	"not real","not human","impostor","imposter","automated","machine",
}

-- Chat NPC mode player (20 baris)
local NPC_CHATS = {
	"Hai bro!",
	"Let's playing!",
	"Wanna team up?",
	"This game is fun haha",
	"Hey! What are you doing?",
	"Bro come here!",
	"Let's go explore!",
	"Hiii :D",
	"Ayo main bareng!",
	"Seru banget nih game",
	"You seem kinda fun to play with!",
	"Have you been here long?",
	"I just joined, is this place good?",
	"Bro your outfit is cool ngl",
	"Can you show me around?",
	"I keep getting lost lol",
	"What server is this?",
	"Do you hear anything weird?",
	"I feel like we've met before...",
	"Stay close, okay?",
}

-- ════════════════════════════════════════════
--  BLOOD EFFECT — merah ↔ hitam loop
-- ════════════════════════════════════════════
local effectGui = nil

local function createBloodEffect()
	if effectGui then effectGui:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name              = "FlowerEffect"
	gui.ResetOnSpawn      = false
	gui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset    = true
	gui.Parent            = LocalPlayer.PlayerGui

	local bg = Instance.new("Frame")
	bg.Name                   = "BG"
	bg.Size                   = UDim2.new(1,0,1,0)
	bg.BackgroundColor3       = Color3.fromRGB(180, 0, 0)
	bg.BackgroundTransparency = 0
	bg.BorderSizePixel        = 0
	bg.ZIndex                 = 10
	bg.Parent                 = gui

	-- Vignette (tepi gelap)
	local vig = Instance.new("ImageLabel")
	vig.Size                  = UDim2.new(1,0,1,0)
	vig.BackgroundTransparency = 1
	vig.Image                 = "rbxassetid://1316045217"
	vig.ImageColor3           = Color3.fromRGB(0,0,0)
	vig.ImageTransparency     = 0
	vig.ZIndex                = 11
	vig.Parent                = gui

	effectGui = gui

	-- Loop merah → hitam → merah
	task.spawn(function()
		local info = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		while effectGui and effectGui.Parent do
			local frame = effectGui:FindFirstChild("BG")
			if not frame then break end

			-- → hitam
			TweenService:Create(frame, info, {
				BackgroundColor3 = Color3.fromRGB(5, 0, 0)
			}):Play()
			task.wait(1.2)

			if not effectGui or not effectGui.Parent then break end
			frame = effectGui:FindFirstChild("BG")
			if not frame then break end

			-- → merah
			TweenService:Create(frame, info, {
				BackgroundColor3 = Color3.fromRGB(180, 0, 0)
			}):Play()
			task.wait(1.2)
		end
	end)
end

local function removeBloodEffect()
	if effectGui then effectGui:Destroy(); effectGui = nil end
end

-- ════════════════════════════════════════════
--  SOUND
-- ════════════════════════════════════════════
local flowerSound = nil

local function playFlowerSound()
	if flowerSound then flowerSound:Destroy() end
	local snd = Instance.new("Sound")
	snd.SoundId       = FLOWER_SOUND_ID
	snd.Volume        = SOUND_VOLUME
	snd.PlaybackSpeed = SOUND_PITCH
	snd.Looped        = true
	snd.Parent        = SoundService
	snd:Play()
	flowerSound = snd
end

local function stopFlowerSound()
	if flowerSound then
		flowerSound:Stop(); flowerSound:Destroy(); flowerSound = nil
	end
end

-- ════════════════════════════════════════════
--  BUILD MODEL פרחים (pitch black, tall, jitter)
-- ════════════════════════════════════════════
local function buildFlowerModel(parent)
	local BLACK = Color3.fromRGB(5, 5, 5)

	local model    = Instance.new("Model")
	model.Name     = "פרחים"
	model.Parent   = parent

	local function part(name, size, cf)
		local p = Instance.new("Part")
		p.Name        = name
		p.Size        = size
		p.CFrame      = cf
		p.Color       = BLACK
		p.Material    = Enum.Material.SmoothPlastic
		p.CastShadow  = false
		p.CanCollide  = false
		p.Anchored    = false
		p.Parent      = model
		return p
	end

	local root  = part("HumanoidRootPart", Vector3.new(2,2,1),     CFrame.new(0,5,0))
	root.Transparency = 1

	-- Tubuh
	part("UpperTorso",    Vector3.new(2, 3,   1),   CFrame.new(0, 5.5,  0))
	part("LowerTorso",    Vector3.new(2, 1.5, 1),   CFrame.new(0, 3.5,  0))
	-- Kepala memanjang (ciri khas)
	part("Head",          Vector3.new(1.5, 3.5, 1.2), CFrame.new(0, 9.75, 0))
	-- Lengan panjang
	part("LeftUpperArm",  Vector3.new(0.9,2.5,0.9), CFrame.new(-1.7, 5.5, 0))
	part("LeftLowerArm",  Vector3.new(0.8,2.5,0.8), CFrame.new(-1.7, 2.8, 0))
	part("LeftHand",      Vector3.new(0.8,1.2,0.8), CFrame.new(-1.7, 0.8, 0))
	part("RightUpperArm", Vector3.new(0.9,2.5,0.9), CFrame.new( 1.7, 5.5, 0))
	part("RightLowerArm", Vector3.new(0.8,2.5,0.8), CFrame.new( 1.7, 2.8, 0))
	part("RightHand",     Vector3.new(0.8,1.2,0.8), CFrame.new( 1.7, 0.8, 0))
	-- Kaki
	part("LeftUpperLeg",  Vector3.new(0.9,2.5,0.9), CFrame.new(-0.7, 1.5,  0))
	part("LeftLowerLeg",  Vector3.new(0.8,2.5,0.8), CFrame.new(-0.7,-1.2,  0))
	part("LeftFoot",      Vector3.new(1.0,0.7,1.3), CFrame.new(-0.7,-2.9,  0))
	part("RightUpperLeg", Vector3.new(0.9,2.5,0.9), CFrame.new( 0.7, 1.5,  0))
	part("RightLowerLeg", Vector3.new(0.8,2.5,0.8), CFrame.new( 0.7,-1.2,  0))
	part("RightFoot",     Vector3.new(1.0,0.7,1.3), CFrame.new( 0.7,-2.9,  0))

	-- Weld semua ke root
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") and p ~= root then
			local w = Instance.new("WeldConstraint")
			w.Part0  = root
			w.Part1  = p
			w.Parent = model
		end
	end

	-- Humanoid
	local hum          = Instance.new("Humanoid")
	hum.WalkSpeed      = CHASE_SPEED
	hum.MaxHealth      = math.huge
	hum.Health         = math.huge
	hum.DisplayName    = "פרחים"
	hum.Parent         = model

	model.PrimaryPart  = root

	-- Jitter effect
	task.spawn(function()
		while model and model.Parent do
			if root and root.Parent then
				local jx = (math.random()-0.5) * 0.12
				local jy = (math.random()-0.5) * 0.06
				local jz = (math.random()-0.5) * 0.12
				root.CFrame = root.CFrame * CFrame.new(jx,jy,jz)
			end
			task.wait(0.05)
		end
	end)

	return model, hum, root
end

-- ════════════════════════════════════════════
--  AVATAR PICKER
-- ════════════════════════════════════════════
local function pickUserId()
	local friends, others = {}, {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local ok, isFriend = pcall(function()
				return LocalPlayer:IsFriendsWith(p.UserId)
			end)
			if ok and isFriend then table.insert(friends, p.UserId)
			else table.insert(others, p.UserId) end
		end
	end
	if #friends > 0 then return friends[math.random(#friends)]
	elseif #others > 0 then return others[math.random(#others)]
	else return 1 end
end

local function buildPlayerAvatar(userId, name, parent)
	local model
	pcall(function()
		local desc = Players:GetHumanoidDescriptionFromUserId(userId)
		model = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
	end)

	if not model then
		model = Instance.new("Model")
		local root = Instance.new("Part")
		root.Name = "HumanoidRootPart"; root.Size = Vector3.new(2,2,1)
		root.Transparency = 1; root.CanCollide = false; root.Parent = model
		local t = Instance.new("Part")
		t.Name = "UpperTorso"; t.Size = Vector3.new(2,2,1); t.Parent = model
		local w = Instance.new("WeldConstraint")
		w.Part0 = root; w.Part1 = t; w.Parent = model
		Instance.new("Humanoid").Parent = model
		model.PrimaryPart = root
	end

	model.Name = name
	model.Parent = parent

	local hum  = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	if hum then hum.WalkSpeed = NORMAL_SPEED; hum.DisplayName = name end
	return model, hum, root
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
local npcModel = nil
local npcHum   = nil
local npcRoot  = nil
local isFlower = false
local triggered = false
local chatConn  = nil
local chaseConn = nil
local lastPos   = Vector3.new(0,5,0)

local function destroyAll()
	isFlower = false; triggered = false
	if chatConn  then chatConn:Disconnect();  chatConn  = nil end
	if chaseConn then chaseConn:Disconnect(); chaseConn = nil end
	if npcModel and npcModel.Parent then npcModel:Destroy() end
	npcModel = nil; npcHum = nil; npcRoot = nil
	removeBloodEffect()
	stopFlowerSound()
end

local function voidGuard()
	if npcRoot then
		if npcRoot.Position.Y < -80 then
			npcRoot.CFrame = CFrame.new(lastPos + Vector3.new(0,5,0))
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

	local model, hum, root = buildFlowerModel(workspace)
	npcModel = model; npcHum = hum; npcRoot = root
	root.CFrame = CFrame.new(oldPos + Vector3.new(0,5,0))
	lastPos = root.Position

	createBloodEffect()
	playFlowerSound()

	-- Chase + kill
	if chaseConn then chaseConn:Disconnect() end
	chaseConn = RunService.Heartbeat:Connect(function()
		if not npcHum or not npcRoot then return end
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
--  NPC CHAT
-- ════════════════════════════════════════════
local function npcSay(text)
	if npcModel then
		local head = npcModel:FindFirstChild("Head")
		if head then Chat:Chat(head, text, Enum.ChatColor.White) end
	end
end

-- ════════════════════════════════════════════
--  KEYWORD CHECK
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

	local char = LocalPlayer.Character
	if char then
		local pr = char:FindFirstChild("HumanoidRootPart")
		if pr then
			root.CFrame = pr.CFrame * CFrame.new(math.random(-8,8), 0, math.random(-6,6))
		end
	end
	lastPos = root.Position

	-- Chat loop
	task.spawn(function()
		task.wait(2)
		while not isFlower and npcModel and npcModel.Parent do
			npcSay(NPC_CHATS[math.random(#NPC_CHATS)])
			task.wait(math.random(CHAT_INTERVAL_MIN, CHAT_INTERVAL_MAX))
		end
	end)

	-- Wander
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

	-- Chat listener (hanya player sendiri)
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
	local uid   = pickUserId()
	local name  = fakeName()
	local model, hum, root = buildPlayerAvatar(uid, name, workspace)
	if not hum or not root then model:Destroy(); return end
	startPlayerMode(model, hum, root)
end

LocalPlayer.CharacterRemoving:Connect(destroyAll)
execute()
