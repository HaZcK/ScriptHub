-- THE FLOWER LocalScript
-- Hanya terlihat oleh si player yang execute (client-side)
-- Made in one file

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Chat = game:GetService("Chat")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =====================
-- CONFIG
-- =====================
local FLOWER_SOUND_ID = "rbxassetid://117135792761068"
local CHAT_DELAY = 5          -- detik sebelum berubah setelah "..."
local SPAWN_DELAY = 8         -- detik sebelum NPC muncul setelah execute
local CHASE_SPEED = 22        -- WalkSpeed NPC saat mode Flower
local NORMAL_SPEED = 14       -- WalkSpeed NPC saat mode Player
local CHAT_INTERVAL = 6       -- detik antar obrolan NPC

-- Kata kunci trigger (semua bahasa, case-insensitive)
local TRIGGER_KEYWORDS = {
	-- Strange & variasi
	"strange", "aneh", "ganjil", "weird", "étrange", "extraño", "seltsam", "странный",
	-- Bot & variasi
	"bot", "bots", "bot's", "robot", "robots", "robot's", "нпс", "npc",
	"робот", "робот'с", "ботс",
	-- Tambahan umum
	"fake", "palsu", "bohong", "imitasi",
}

-- Obrolan NPC saat mode player (random)
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
}

-- =====================
-- BLOOD RED EFFECT (hanya client)
-- =====================
local bloodEffect = nil

local function createBloodEffect()
	if bloodEffect then bloodEffect:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FlowerBloodEffect"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = LocalPlayer.PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
	frame.BackgroundTransparency = 0.4
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	-- Vignette effect (gradient dari tepi)
	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 0.85),
		NumberSequenceKeypoint.new(1, 0),
	})
	gradient.Rotation = 90
	gradient.Parent = frame

	bloodEffect = screenGui

	-- Flicker effect
	task.spawn(function()
		while bloodEffect and bloodEffect.Parent do
			local t = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.6})
			t:Play()
			task.wait(0.4)
			local t2 = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.3})
			t2:Play()
			task.wait(0.4)
		end
	end)
end

local function removeBloodEffect()
	if bloodEffect then
		bloodEffect:Destroy()
		bloodEffect = nil
	end
end

-- =====================
-- SOUND
-- =====================
local flowerSound = nil

local function playFlowerSound()
	if flowerSound then flowerSound:Destroy() end
	flowerSound = Instance.new("Sound")
	flowerSound.SoundId = FLOWER_SOUND_ID
	flowerSound.Volume = 2
	flowerSound.Looped = true
	flowerSound.RollOffMaxDistance = 9999
	flowerSound.Parent = SoundService
	flowerSound:Play()
end

local function stopFlowerSound()
	if flowerSound then
		flowerSound:Stop()
		flowerSound:Destroy()
		flowerSound = nil
	end
end

-- =====================
-- AMBIL AVATAR
-- =====================
local function getAvatarModel(userId)
	-- Ambil HumanoidDescription dari userId
	local success, desc = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(userId)
	end)
	if not success then return nil end

	local model = Instance.new("Model")
	model.Name = "FlowerNPC"

	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = model

	-- Buat karakter dummy pakai R15 default lalu apply description
	local char = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
	if not char then return nil end

	char.Name = "FlowerNPC"
	return char
end

local function pickAvatarUserId()
	-- Prioritas: teman di server
	local friends = {}
	local others = {}

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local isFriend = false
			pcall(function()
				isFriend = LocalPlayer:IsFriendsWith(p.UserId)
			end)
			if isFriend then
				table.insert(friends, p.UserId)
			else
				table.insert(others, p.UserId)
			end
		end
	end

	if #friends > 0 then
		return friends[math.random(1, #friends)]
	elseif #others > 0 then
		return others[math.random(1, #others)]
	else
		-- Fallback: avatar default (guest-like)
		return 1 -- Roblox default
	end
end

-- =====================
-- RANDOM NAME GENERATOR
-- =====================
local function generateFakeName()
	local prefixes = {"xX", "Pro", "Ultra", "Super", "Dark", "Cool", "Real", "TheOnly"}
	local names = {"Player", "Gamer", "Noob", "Legend", "Shadow", "Storm", "Fire", "Ice"}
	local suffixes = {"123", "456", "YT", "_lol", "xD", "pro", "777", "HD"}

	local r = math.random(1, 3)
	if r == 1 then
		return prefixes[math.random(#prefixes)] .. names[math.random(#names)] .. suffixes[math.random(#suffixes)]
	elseif r == 2 then
		return names[math.random(#names)] .. suffixes[math.random(#suffixes)]
	else
		return prefixes[math.random(#prefixes)] .. names[math.random(#names)]
	end
end

-- =====================
-- NPC CONTROLLER
-- =====================
local npcModel = nil
local npcHumanoid = nil
local npcRoot = nil
local isFlowerMode = false
local triggered = false
local chatConnection = nil
local chaseLoop = nil
local lastPos = nil -- untuk respawn dari void

local function destroyNPC()
	isFlowerMode = false
	triggered = false
	if chaseLoop then
		chaseLoop:Disconnect()
		chaseLoop = nil
	end
	if npcModel then
		npcModel:Destroy()
		npcModel = nil
		npcHumanoid = nil
		npcRoot = nil
	end
	removeBloodEffect()
	stopFlowerSound()
end

local function checkVoid()
	-- Kalau NPC jatuh ke void, spawn ulang di posisi terakhir
	if npcRoot and lastPos then
		if npcRoot.Position.Y < -100 then
			npcRoot.CFrame = CFrame.new(lastPos + Vector3.new(0, 5, 0))
		else
			lastPos = npcRoot.Position
		end
	end
end

local function startChaseMode()
	isFlowerMode = true

	-- Ubah nama jadi "???"
	if npcModel then
		npcModel.Name = "???"
		-- Ubah warna jadi gelap
		for _, part in ipairs(npcModel:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Color = Color3.fromRGB(10, 10, 10)
			end
		end
	end

	if npcHumanoid then
		npcHumanoid.WalkSpeed = CHASE_SPEED
	end

	-- Efek darah + suara
	createBloodEffect()
	playFlowerSound()

	-- Chase loop
	if chaseLoop then chaseLoop:Disconnect() end
	chaseLoop = RunService.Heartbeat:Connect(function()
		if not npcHumanoid or not npcRoot then return end

		local char = LocalPlayer.Character
		if not char then return end
		local playerRoot = char:FindFirstChild("HumanoidRootPart")
		if not playerRoot then return end

		-- Simpan posisi untuk respawn void
		lastPos = npcRoot.Position
		checkVoid()

		-- Gerak menuju player
		npcHumanoid:MoveTo(playerRoot.Position)
	end)
end

local function npcChat(text)
	if npcModel then
		Chat:Chat(npcModel:FindFirstChild("Head") or npcRoot, text, Enum.ChatColor.White)
	end
end

local function startPlayerMode(model, fakeName)
	npcModel = model
	npcHumanoid = model:FindFirstChildOfClass("Humanoid")
	npcRoot = model:FindFirstChild("HumanoidRootPart")

	if not npcHumanoid or not npcRoot then
		model:Destroy()
		return
	end

	npcHumanoid.WalkSpeed = NORMAL_SPEED
	npcModel.Name = fakeName
	lastPos = npcRoot.Position

	-- Spawn dekat player
	local char = LocalPlayer.Character
	if char then
		local playerRoot = char:FindFirstChild("HumanoidRootPart")
		if playerRoot then
			npcRoot.CFrame = playerRoot.CFrame * CFrame.new(math.random(-8, 8), 0, math.random(-8, 8))
		end
	end

	npcModel.Parent = workspace

	-- Gerak idle / wander
	local wanderLoop
	wanderLoop = RunService.Heartbeat:Connect(function()
		if isFlowerMode then
			wanderLoop:Disconnect()
			return
		end
		if not npcHumanoid or not npcRoot then
			wanderLoop:Disconnect()
			return
		end
		lastPos = npcRoot.Position
		checkVoid()
	end)

	-- Chat random
	task.spawn(function()
		task.wait(2)
		while not isFlowerMode and npcModel and npcModel.Parent do
			npcChat(NPC_CHATS[math.random(#NPC_CHATS)])
			task.wait(CHAT_INTERVAL + math.random(0, 3))
		end
	end)

	-- Wander mendekati player
	task.spawn(function()
		while not isFlowerMode and npcModel and npcModel.Parent do
			local char2 = LocalPlayer.Character
			if char2 then
				local pr = char2:FindFirstChild("HumanoidRootPart")
				if pr then
					local offset = Vector3.new(math.random(-6, 6), 0, math.random(-6, 6))
					npcHumanoid:MoveTo(pr.Position + offset)
				end
			end
			task.wait(3 + math.random(0, 2))
		end
	end)
end

-- =====================
-- KEYWORD CHECK
-- =====================
local function containsTrigger(message)
	local lower = message:lower()
	for _, kw in ipairs(TRIGGER_KEYWORDS) do
		if lower:find(kw, 1, true) then
			return true
		end
	end
	return false
end

local function setupChatListener()
	-- Hanya cek chat si LocalPlayer sendiri
	chatConnection = Players.LocalPlayer.Chatted:Connect(function(message)
		if triggered then return end
		if not npcModel then return end

		if containsTrigger(message) then
			triggered = true
			if chatConnection then
				chatConnection:Disconnect()
				chatConnection = nil
			end

			-- NPC chat "..."
			npcChat("...")

			task.wait(CHAT_DELAY)

			-- Mulai mode Flower
			startChaseMode()
		end
	end)
end

-- =====================
-- MAIN EXECUTE
-- =====================
local function execute()
	destroyNPC() -- reset kalau ada sisa

	task.wait(SPAWN_DELAY)

	-- Pilih avatar
	local userId = pickAvatarUserId()
	local fakeName = generateFakeName()

	local model = nil
	local success = false

	pcall(function()
		model = Players:CreateHumanoidModelFromDescription(
			Players:GetHumanoidDescriptionFromUserId(userId),
			Enum.HumanoidRigType.R15
		)
		success = model ~= nil
	end)

	if not success or not model then
		-- Fallback model sederhana
		model = Instance.new("Model")
		model.Name = fakeName

		local root = Instance.new("Part")
		root.Name = "HumanoidRootPart"
		root.Size = Vector3.new(2, 2, 1)
		root.Transparency = 1
		root.CFrame = CFrame.new(0, 5, 0)
		root.Parent = model

		local torso = Instance.new("Part")
		torso.Name = "UpperTorso"
		torso.Size = Vector3.new(2, 2, 1)
		torso.Color = Color3.fromRGB(30, 30, 30)
		torso.CFrame = root.CFrame
		torso.Parent = model

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = torso
		weld.Parent = model

		local hum = Instance.new("Humanoid")
		hum.Parent = model

		model.PrimaryPart = root
	else
		model.Name = fakeName
		if not model.PrimaryPart then
			model.PrimaryPart = model:FindFirstChild("HumanoidRootPart")
		end
	end

	startPlayerMode(model, fakeName)
	setupChatListener()
end

-- =====================
-- LEAVE CLEANUP
-- =====================
Players.LocalPlayer.CharacterRemoving:Connect(function()
	destroyNPC()
end)

game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
	destroyNPC()
end)

-- JALANKAN
execute()
