-- ╔══════════════════════════════════════════════════════════════╗
-- ║                 DICE OF FATE — DiceCore v5                   ║
-- ║          Full overhaul: Trade, GiveAll, History,             ║
-- ║          Smooth animations, Sound effects, Server sync       ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService      = game:GetService("SoundService")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")

-- ══════════════════════════════════════════════════════
--  CONNECTION MANAGER
-- ══════════════════════════════════════════════════════
local Connections = {}
local function storeConn(key, conn)
	if Connections[key] then pcall(function() Connections[key]:Disconnect() end) end
	Connections[key] = conn
end
local function removeConn(key)
	if Connections[key] then pcall(function() Connections[key]:Disconnect() end) Connections[key] = nil end
end

-- ══════════════════════════════════════════════════════
--  ORIGINAL SIZES
-- ══════════════════════════════════════════════════════
local OriginalSizes = {}
local function saveOriginalSizes()
	OriginalSizes = {}
	for _,p in ipairs(character:GetDescendants()) do
		if p:IsA("BasePart") then OriginalSizes[p.Name] = p.Size end
	end
end
saveOriginalSizes()

local function getChar()
	character = player.Character or character
	humanoid  = character and character:FindFirstChildOfClass("Humanoid") or humanoid
	return character, humanoid
end

-- ══════════════════════════════════════════════════════
--  SERVER DETECTION
-- ══════════════════════════════════════════════════════
local serverMode  = false
local REMOTE      = nil  -- DICE_ACTION
local TRADE_REMOTE= nil  -- DICE_TRADE
local GIVE_REMOTE = nil  -- DICE_GIVEGUI
local PING_REMOTE = nil  -- DICE_PING

local function checkServer()
	PING_REMOTE = ReplicatedStorage:FindFirstChild("DICE_PING")
	if PING_REMOTE and PING_REMOTE:IsA("RemoteFunction") then
		local ok, result = pcall(function()
			return PING_REMOTE:InvokeServer()
		end)
		if ok and result == true then
			serverMode   = true
			REMOTE       = ReplicatedStorage:FindFirstChild("DICE_ACTION")
			TRADE_REMOTE = ReplicatedStorage:FindFirstChild("DICE_TRADE")
			GIVE_REMOTE  = ReplicatedStorage:FindFirstChild("DICE_GIVEGUI")
			return true
		end
	end
	serverMode = false
	return false
end

local function fireServer(action, data)
	if serverMode and REMOTE then
		pcall(function() REMOTE:FireServer(action, data) end)
	end
end

-- ══════════════════════════════════════════════════════
--  SOUND SYSTEM
-- ══════════════════════════════════════════════════════
local Sounds = {}
local function createSound(id, volume, pitch)
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://"..id
	s.Volume = volume or 0.5
	s.PlaybackSpeed = pitch or 1
	s.Parent = SoundService
	return s
end

-- Roblox free sound IDs
Sounds.roll    = createSound("9120232869", 0.4)   -- dice roll
Sounds.common  = createSound("9113564284", 0.5)   -- common pop
Sounds.rare    = createSound("9119777278", 0.6)   -- rare chime
Sounds.epic    = createSound("9119817677", 0.7)   -- epic whoosh
Sounds.legend  = createSound("9120237401", 0.8)   -- legendary fanfare
Sounds.use     = createSound("9113460963", 0.5)   -- confirm
Sounds.skip    = createSound("9120239737", 0.3)   -- cancel
Sounds.trade   = createSound("9119817200", 0.6)   -- trade ping

local function playSound(key)
	local s = Sounds[key]
	if s then pcall(function() s:Play() end) end
end

-- ══════════════════════════════════════════════════════
--  SKILL DATABASE
--  ┌──────────────────────────────────────────────────┐
--  │  CARA TAMBAH CUSTOM SKILL:                        │
--  │  1. Copy salah satu blok skill di bawah           │
--  │  2. Ganti id, name, icon, rarity, desc            │
--  │  3. Isi fungsi apply() dan remove()               │
--  │  4. Tambahkan juga di DiceServer.lua              │
--  │     SkillRegistry["id_kamu"] = { apply, remove }  │
--  │  5. Rarity pilihan: Common Rare Epic Legendary    │
--  └──────────────────────────────────────────────────┘
-- ══════════════════════════════════════════════════════

local SkillDB = {}

SkillDB.Rarity = {
	Common    = { color=Color3.fromRGB(180,180,180), glow=Color3.fromRGB(220,220,220), weight=50, soundKey="common"  },
	Rare      = { color=Color3.fromRGB(80,140,255),  glow=Color3.fromRGB(120,180,255), weight=30, soundKey="rare"    },
	Epic      = { color=Color3.fromRGB(180,80,255),  glow=Color3.fromRGB(220,120,255), weight=15, soundKey="epic"    },
	Legendary = { color=Color3.fromRGB(255,180,0),   glow=Color3.fromRGB(255,220,80),  weight=5,  soundKey="legend"  },
}

-- ── FORMAT TIAP SKILL ──
-- id       : string unik (harus sama dengan DiceServer SkillRegistry key)
-- name     : nama tampilan
-- icon     : emoji
-- rarity   : "Common" | "Rare" | "Epic" | "Legendary"
-- desc     : deskripsi singkat
-- flavor   : kalimat flavor text (opsional, muncul di card)
-- apply()  : efek lokal saat dipakai
-- remove() : balik ke normal

SkillDB.Skills = {

	-- ══ COMMON ══
	{
		id="speed_demon", name="Speed Demon", icon="💨", rarity="Common",
		desc="WalkSpeed jadi 100.",
		flavor="Angin aja kalah!",
		apply=function() local c,h=getChar(); h.WalkSpeed=100; fireServer("Apply","speed_demon") end,
		remove=function() local c,h=getChar(); h.WalkSpeed=16; fireServer("Remove","speed_demon") end,
	},
	{
		id="super_jump", name="Super Jump", icon="🚀", rarity="Common",
		desc="JumpPower jadi 200.",
		flavor="Gravity? Belum kenal.",
		apply=function() local c,h=getChar(); h.JumpPower=200; fireServer("Apply","super_jump") end,
		remove=function() local c,h=getChar(); h.JumpPower=50; fireServer("Remove","super_jump") end,
	},
	{
		id="giant_head", name="Giant Head", icon="🗿", rarity="Common",
		desc="Kepala jadi 5x lebih gede.",
		flavor="Braincell makin besar.",
		apply=function()
			local c,h=getChar()
			local head=c:FindFirstChild("Head")
			if head then head.Size=Vector3.new(5,5,5) end
			fireServer("Apply","giant_head")
		end,
		remove=function()
			local c,h=getChar()
			local head=c:FindFirstChild("Head")
			if head and OriginalSizes["Head"] then head.Size=OriginalSizes["Head"] end
			fireServer("Remove","giant_head")
		end,
	},
	{
		id="tiny_legs", name="Tiny Legs", icon="🦵", rarity="Common",
		desc="Kaki mengecil. Jalannya jadi lucu.",
		flavor="Kaki kamu mana??",
		apply=function()
			local c,h=getChar()
			for _,n in ipairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do
				local p=c:FindFirstChild(n); if p then p.Size=Vector3.new(0.4,0.4,0.4) end
			end
			fireServer("Apply","tiny_legs")
		end,
		remove=function()
			local c,h=getChar()
			for _,n in ipairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do
				local p=c:FindFirstChild(n); if p and OriginalSizes[n] then p.Size=OriginalSizes[n] end
			end
			fireServer("Remove","tiny_legs")
		end,
	},
	{
		id="buff_arms", name="Buff Arms", icon="💪", rarity="Common",
		desc="Lengan jadi super gede.",
		flavor="Siap angkat planet.",
		apply=function()
			local c,h=getChar()
			for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
				local p=c:FindFirstChild(n); if p then p.Size=Vector3.new(2.5,2.5,2.5) end
			end
			fireServer("Apply","buff_arms")
		end,
		remove=function()
			local c,h=getChar()
			for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
				local p=c:FindFirstChild(n); if p and OriginalSizes[n] then p.Size=OriginalSizes[n] end
			end
			fireServer("Remove","buff_arms")
		end,
	},
	{
		id="noodle_arms", name="Noodle Arms", icon="🍜", rarity="Common",
		desc="Lengan super panjang menjuntai.",
		flavor="Nyampe lantai dari berdiri.",
		apply=function()
			local c,h=getChar()
			for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
				local p=c:FindFirstChild(n); if p then p.Size=Vector3.new(0.3,3.5,0.3) end
			end
			fireServer("Apply","noodle_arms")
		end,
		remove=function()
			local c,h=getChar()
			for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
				local p=c:FindFirstChild(n); if p and OriginalSizes[n] then p.Size=OriginalSizes[n] end
			end
			fireServer("Remove","noodle_arms")
		end,
	},
	{
		id="phantom", name="Phantom Mode", icon="👻", rarity="Common",
		desc="Badan transparan 80%.",
		flavor="Boo!",
		apply=function()
			local c,h=getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency=0.8 end
			end
			fireServer("Apply","phantom")
		end,
		remove=function()
			local c,h=getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Transparency=0 end
			end
			fireServer("Remove","phantom")
		end,
	},
	{
		id="golden_skin", name="Golden Touch", icon="✨", rarity="Common",
		desc="Seluruh badan jadi emas.",
		flavor="Midas wishes.",
		apply=function()
			local c,h=getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.BrickColor=BrickColor.new("Bright yellow") end
			end
			fireServer("Apply","golden_skin")
		end,
		remove=function()
			local c,h=getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Color=Color3.fromRGB(163,162,165) end
			end
			fireServer("Remove","golden_skin")
		end,
	},

	-- ══ RARE ══
	{
		id="rainbow_body", name="Rainbow Body", icon="🌈", rarity="Rare",
		desc="Warna badan berubah pelangi nonstop.",
		flavor="Serotonin overload.",
		apply=function()
			fireServer("Apply","rainbow_body")
			if not serverMode then
				local conn=RunService.Heartbeat:Connect(function()
					local t=tick()
					local c2=player.Character; if not c2 then return end
					for _,p in ipairs(c2:GetDescendants()) do
						if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
							p.Color=Color3.fromHSV((t*0.5+p.Name:len()*0.05)%1,1,1)
						end
					end
				end)
				storeConn("rainbow",conn)
			end
		end,
		remove=function()
			removeConn("rainbow")
			fireServer("Remove","rainbow_body")
			local c,h=getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Color=Color3.fromRGB(163,162,165) end
			end
		end,
	},
	{
		id="anti_gravity", name="Anti Gravity", icon="🪐", rarity="Rare",
		desc="Gravitasi berkurang, lompat melayang.",
		flavor="Space walk vibes.",
		apply=function()
			local c,h=getChar(); h.JumpPower=150
			local hrp=c:FindFirstChild("HumanoidRootPart")
			if hrp then
				local old=hrp:FindFirstChild("_AntiGrav"); if old then old:Destroy() end
				local bf=Instance.new("BodyForce")
				bf.Name="_AntiGrav"; bf.Force=Vector3.new(0,workspace.Gravity*hrp:GetMass()*0.75,0); bf.Parent=hrp
			end
			fireServer("Apply","anti_gravity")
		end,
		remove=function()
			local c,h=getChar(); h.JumpPower=50
			local hrp=c:FindFirstChild("HumanoidRootPart")
			if hrp then local bf=hrp:FindFirstChild("_AntiGrav"); if bf then bf:Destroy() end end
			fireServer("Remove","anti_gravity")
		end,
	},
	{
		id="ice_body", name="Frozen Soul", icon="🧊", rarity="Rare",
		desc="Badan jadi es transparan biru.",
		flavor="Dingin sampe jiwa membeku.",
		apply=function()
			local c,h=getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
					p.BrickColor=BrickColor.new("Pastel blue"); p.Material=Enum.Material.Ice; p.Transparency=0.35
				end
			end
			fireServer("Apply","ice_body")
		end,
		remove=function()
			local c,h=getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Material=Enum.Material.SmoothPlastic; p.Transparency=0 end
			end
			fireServer("Remove","ice_body")
		end,
	},
	{
		id="lava_trail", name="Lava Trail", icon="🔥", rarity="Rare",
		desc="Ninggalin jejak api saat berjalan.",
		flavor="Floor is literally lava.",
		apply=function()
			fireServer("Apply","lava_trail")
			if not serverMode then
				local last=0
				local conn=RunService.Heartbeat:Connect(function()
					local now=tick(); if now-last<0.15 then return end
					local c2=player.Character; local h2=c2 and c2:FindFirstChildOfClass("Humanoid")
					local hrp=c2 and c2:FindFirstChild("HumanoidRootPart")
					if not hrp or not h2 or h2.MoveDirection.Magnitude<0.1 then return end
					last=now
					local f=Instance.new("Part"); f.Size=Vector3.new(1.5,0.2,1.5)
					f.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3,0)); f.Anchored=true; f.CanCollide=false
					f.BrickColor=BrickColor.new("Bright orange"); f.Material=Enum.Material.Neon; f.Parent=workspace
					local fi=Instance.new("Fire",f); fi.Heat=8; fi.Size=5
					game:GetService("Debris"):AddItem(f,2)
				end)
				storeConn("lava",conn)
			end
		end,
		remove=function()
			removeConn("lava"); fireServer("Remove","lava_trail")
		end,
	},
	{
		id="spinning_head", name="Spinning Head", icon="🌀", rarity="Rare",
		desc="Kepala muter nonstop.",
		flavor="Pusing lihatnya.",
		apply=function()
			fireServer("Apply","spinning_head")
			if not serverMode then
				local conn=RunService.Heartbeat:Connect(function(dt)
					local c2=player.Character; if not c2 then return end
					local head=c2:FindFirstChild("Head")
					if head then head.CFrame=head.CFrame*CFrame.Angles(0,math.rad(300*dt),0) end
				end)
				storeConn("spin",conn)
			end
		end,
		remove=function()
			removeConn("spin"); fireServer("Remove","spinning_head")
		end,
	},

	-- ══ EPIC ══
	{
		id="ant_size", name="Ant Size", icon="🐜", rarity="Epic",
		desc="Tubuh mengecil jadi 0.3x.",
		flavor="Siapa kamu? Mana kamu?",
		apply=function()
			local c,h=getChar(); h.WalkSpeed=10
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Size=p.Size*0.3 end
			end
			fireServer("Apply","ant_size")
		end,
		remove=function()
			local c,h=getChar(); h.WalkSpeed=16
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and OriginalSizes[p.Name] then p.Size=OriginalSizes[p.Name] end
			end
			fireServer("Remove","ant_size")
		end,
	},
	{
		id="giant_mode", name="Giant Mode", icon="🏔️", rarity="Epic",
		desc="Tumbuh jadi raksasa 3x ukuran.",
		flavor="Fee-fi-fo-fum.",
		apply=function()
			local c,h=getChar(); h.WalkSpeed=24; h.JumpPower=80
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Size=p.Size*3 end
			end
			fireServer("Apply","giant_mode")
		end,
		remove=function()
			local c,h=getChar(); h.WalkSpeed=16; h.JumpPower=50
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and OriginalSizes[p.Name] then p.Size=OriginalSizes[p.Name] end
			end
			fireServer("Remove","giant_mode")
		end,
	},
	{
		id="backwards_brain", name="Backwards Brain", icon="🔄", rarity="Epic",
		desc="Kamera terbalik 180°.",
		flavor="Maju itu mundur.",
		apply=function()
			local cam=workspace.CurrentCamera
			cam.CameraType=Enum.CameraType.Scriptable
			local conn=RunService.Heartbeat:Connect(function()
				local c2=player.Character; if not c2 then return end
				local hrp=c2:FindFirstChild("HumanoidRootPart")
				if hrp then cam.CFrame=CFrame.new(hrp.Position+Vector3.new(0,6,14))*CFrame.Angles(-0.12,math.pi,0) end
			end)
			storeConn("backwards",conn)
		end,
		remove=function()
			removeConn("backwards")
			workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
		end,
	},
	{
		id="magnet_body", name="Magnet Body", icon="🧲", rarity="Epic",
		desc="Benda sekitar tertarik ke kamu.",
		flavor="Personal gravitational field.",
		apply=function()
			fireServer("Apply","magnet_body")
			if not serverMode then
				local conn=RunService.Heartbeat:Connect(function()
					local c2=player.Character; if not c2 then return end
					local hrp=c2:FindFirstChild("HumanoidRootPart"); if not hrp then return end
					for _,obj in ipairs(workspace:GetChildren()) do
						if obj:IsA("BasePart") and not obj.Anchored and obj~=hrp and not c2:IsAncestorOf(obj) then
							local dist=(obj.Position-hrp.Position).Magnitude
							if dist<25 and dist>0.1 then
								obj.AssemblyLinearVelocity=obj.AssemblyLinearVelocity+(hrp.Position-obj.Position).Unit*(180/dist)
							end
						end
					end
				end)
				storeConn("magnet",conn)
			end
		end,
		remove=function()
			removeConn("magnet"); fireServer("Remove","magnet_body")
		end,
	},

	-- ══ LEGENDARY ══
	{
		id="time_warp", name="Time Warp", icon="⏳", rarity="Legendary",
		desc="Gravitasi drop ke 20. Kamu tetap kenceng.",
		flavor="LEGENDARY — Waktu itu relatif.",
		apply=function()
			local c,h=getChar(); workspace.Gravity=20; h.WalkSpeed=80; h.JumpPower=120
			fireServer("Apply","time_warp")
		end,
		remove=function()
			local c,h=getChar(); workspace.Gravity=196.2; h.WalkSpeed=16; h.JumpPower=50
			fireServer("Remove","time_warp")
		end,
	},
	{
		id="god_mode", name="God Mode", icon="⚡", rarity="Legendary",
		desc="Speed + Jump + Giant Head + Rainbow Neon.",
		flavor="LEGENDARY — Chaos personified.",
		apply=function()
			local c,h=getChar(); h.WalkSpeed=80; h.JumpPower=180
			local head=c:FindFirstChild("Head"); if head then head.Size=Vector3.new(5,5,5) end
			fireServer("Apply","god_mode")
			if not serverMode then
				local conn=RunService.Heartbeat:Connect(function()
					local t=tick(); local c2=player.Character; if not c2 then return end
					for _,p in ipairs(c2:GetDescendants()) do
						if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
							p.Color=Color3.fromHSV((t*1.5+p.Name:len()*0.1)%1,1,1)
							p.Material=Enum.Material.Neon
						end
					end
				end)
				storeConn("god",conn)
			end
		end,
		remove=function()
			removeConn("god")
			local c,h=getChar(); h.WalkSpeed=16; h.JumpPower=50
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Material=Enum.Material.SmoothPlastic; p.Color=Color3.fromRGB(163,162,165) end
			end
			local head=c:FindFirstChild("Head"); if head and OriginalSizes["Head"] then head.Size=OriginalSizes["Head"] end
			fireServer("Remove","god_mode")
		end,
	},

	-- ══════════════════════════════════════════════════════
	--  CUSTOM SKILL TEMPLATE
	--  Copy blok ini, ganti isinya, taruh di bawah sini!
	--
	-- {
	--     id      = "nama_unik",       -- harus sama di DiceServer juga!
	--     name    = "Nama Skill",
	--     icon    = "🎯",              -- emoji bebas
	--     rarity  = "Common",          -- Common | Rare | Epic | Legendary
	--     desc    = "Deskripsi singkat.",
	--     flavor  = "Kalimat keren.",  -- opsional
	--     apply = function()
	--         local c, h = getChar()
	--         -- tulis efek di sini
	--         fireServer("Apply", "nama_unik")
	--     end,
	--     remove = function()
	--         local c, h = getChar()
	--         -- tulis cara reset di sini
	--         fireServer("Remove", "nama_unik")
	--     end,
	-- },
	-- ══════════════════════════════════════════════════════
}

-- Weighted random pick
function SkillDB.Pick(excludeIds, streakBonus)
	excludeIds = excludeIds or {}
	local excSet = {}
	for _,id in ipairs(excludeIds) do excSet[id]=true end
	local pool = {}
	for _,skill in ipairs(SkillDB.Skills) do
		if not excSet[skill.id] then
			local w = SkillDB.Rarity[skill.rarity].weight
			if skill.rarity=="Legendary" and streakBonus then w=w+(streakBonus*4) end
			for _=1,w do table.insert(pool,skill) end
		end
	end
	if #pool==0 then return nil end
	return pool[math.random(1,#pool)]
end

-- ══════════════════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════════════════
local activeSkills  = {}   -- { skill=..., addedAt=tick() }
local activeIds     = {}
local rollHistory   = {}   -- max 20 entri
local isRolling     = false
local waitingChoice = false
local pendingSkill  = nil
local rollStreak    = 0
local MAX_SLOTS     = 5
local MAX_HISTORY   = 20
local tradeEnabled  = false
local giveAllActive = false

-- ══════════════════════════════════════════════════════
--  COLOR / RARITY HELPERS
-- ══════════════════════════════════════════════════════
local RE = { Common="⚪", Rare="🔵", Epic="🟣", Legendary="🟡" }
local function rC(r)  return SkillDB.Rarity[r] and SkillDB.Rarity[r].color or Color3.fromRGB(200,200,200) end
local function rG(r)  return SkillDB.Rarity[r] and SkillDB.Rarity[r].glow  or Color3.fromRGB(200,200,200) end
local function rS(r)  return SkillDB.Rarity[r] and SkillDB.Rarity[r].soundKey or "common" end

-- ══════════════════════════════════════════════════════
--  TWEEN HELPERS
-- ══════════════════════════════════════════════════════
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
local TWEEN_MED  = TweenInfo.new(0.28, Enum.EasingStyle.Quart)
local TWEEN_BACK = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function tween(obj, props, info)
	TweenService:Create(obj, info or TWEEN_MED, props):Play()
end

-- ══════════════════════════════════════════════════════
--  BUILD GUI
-- ══════════════════════════════════════════════════════
local oldGui = player.PlayerGui:FindFirstChild("DiceOfFateGui")
if oldGui then oldGui:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name="DiceOfFateGui"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=player.PlayerGui

-- ── WINDOW ──
local WIN_W, WIN_H = 420, 680
local win = Instance.new("Frame", SG)
win.Name="Window"; win.Size=UDim2.new(0,WIN_W,0,WIN_H)
win.Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
win.BackgroundColor3=Color3.fromRGB(13,11,20)
win.BorderSizePixel=0; win.ClipsDescendants=true
Instance.new("UICorner",win).CornerRadius=UDim.new(0,16)
local winStroke=Instance.new("UIStroke",win)
winStroke.Color=Color3.fromRGB(100,60,180); winStroke.Thickness=1.5; winStroke.Transparency=0.4

-- ── TITLE BAR ──
local tbar=Instance.new("Frame",win)
tbar.Size=UDim2.new(1,0,0,48); tbar.BackgroundColor3=Color3.fromRGB(20,15,38)
tbar.BorderSizePixel=0; tbar.ZIndex=5
Instance.new("UICorner",tbar).CornerRadius=UDim.new(0,16)
local tbarFill=Instance.new("Frame",tbar)
tbarFill.Size=UDim2.new(1,0,0,16); tbarFill.Position=UDim2.new(0,0,1,-16)
tbarFill.BackgroundColor3=Color3.fromRGB(20,15,38); tbarFill.BorderSizePixel=0

local titleTxt=Instance.new("TextLabel",tbar)
titleTxt.Size=UDim2.new(1,-160,1,0); titleTxt.Position=UDim2.new(0,16,0,0)
titleTxt.BackgroundTransparency=1; titleTxt.Text="🎲  DICE OF FATE"
titleTxt.TextColor3=Color3.fromRGB(200,160,255); titleTxt.Font=Enum.Font.GothamBold
titleTxt.TextSize=15; titleTxt.TextXAlignment=Enum.TextXAlignment.Left; titleTxt.ZIndex=6

local serverBadge=Instance.new("TextLabel",tbar)
serverBadge.Size=UDim2.new(0,100,0,22); serverBadge.Position=UDim2.new(1,-162,0.5,-11)
serverBadge.BackgroundColor3=Color3.fromRGB(35,35,35)
serverBadge.Text="⚫ OFFLINE"; serverBadge.TextSize=10; serverBadge.Font=Enum.Font.GothamBold
serverBadge.TextColor3=Color3.fromRGB(150,150,150); serverBadge.BorderSizePixel=0; serverBadge.ZIndex=6
Instance.new("UICorner",serverBadge).CornerRadius=UDim.new(0,6)

local function makeCtrl(pos,bg,txt)
	local b=Instance.new("TextButton",tbar)
	b.Size=UDim2.new(0,22,0,22); b.Position=pos; b.BackgroundColor3=bg
	b.Text=txt; b.TextColor3=Color3.fromRGB(255,255,255)
	b.TextSize=11; b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0; b.ZIndex=7
	Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
	return b
end
local closeBtn=makeCtrl(UDim2.new(1,-32,0.5,-11), Color3.fromRGB(220,65,80),  "✕")
local minBtn  =makeCtrl(UDim2.new(1,-58,0.5,-11), Color3.fromRGB(240,160,30), "─")

-- ── TAB BAR ──
local tabBar=Instance.new("Frame",win)
tabBar.Size=UDim2.new(1,-32,0,36); tabBar.Position=UDim2.new(0,16,0,54)
tabBar.BackgroundColor3=Color3.fromRGB(20,16,34); tabBar.BorderSizePixel=0
Instance.new("UICorner",tabBar).CornerRadius=UDim.new(0,10)
local tabLayout=Instance.new("UIListLayout",tabBar)
tabLayout.FillDirection=Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment=Enum.VerticalAlignment.Center
tabLayout.Padding=UDim.new(0,4)
Instance.new("UIPadding",tabBar).PaddingLeft=UDim.new(0,6)
Instance.new("UIPadding",tabBar).PaddingRight=UDim.new(0,6)

local function makeTab(txt, active)
	local b=Instance.new("TextButton",tabBar)
	b.Size=UDim2.new(0,88,0,28)
	b.BackgroundColor3=active and Color3.fromRGB(100,55,200) or Color3.fromRGB(30,24,48)
	b.Text=txt; b.TextColor3=active and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,120,180)
	b.Font=Enum.Font.GothamBold; b.TextSize=12; b.BorderSizePixel=0
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
	return b
end

local tabMain    = makeTab("🎲 Roll",   true)
local tabHistory = makeTab("📜 History",false)
local tabTrade   = makeTab("🤝 Trade",  false)
local tabSettings= makeTab("⚙️ Settings",false)

-- ── PAGES ──
local function makePage()
	local f=Instance.new("Frame",win)
	f.Size=UDim2.new(1,-32,1,-100); f.Position=UDim2.new(0,16,0,98)
	f.BackgroundTransparency=1; f.Visible=false
	return f
end

local pageMain    = makePage(); pageMain.Visible=true
local pageHistory = makePage()
local pageTrade   = makePage()
local pageSettings= makePage()

local allPages = {pageMain, pageHistory, pageTrade, pageSettings}
local allTabs  = {tabMain, tabHistory, tabTrade, tabSettings}

local function switchTab(idx)
	for i,pg in ipairs(allPages) do
		pg.Visible = (i==idx)
		local active=(i==idx)
		tween(allTabs[i], {
			BackgroundColor3=active and Color3.fromRGB(100,55,200) or Color3.fromRGB(30,24,48),
			TextColor3=active and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,120,180)
		}, TWEEN_FAST)
	end
end

tabMain.MouseButton1Click:Connect(function() switchTab(1) end)
tabHistory.MouseButton1Click:Connect(function() switchTab(2) end)
tabTrade.MouseButton1Click:Connect(function() switchTab(3) end)
tabSettings.MouseButton1Click:Connect(function() switchTab(4) end)

-- ════════════════════════════
--  PAGE 1: MAIN (ROLL)
-- ════════════════════════════

-- Dice card
local diceCard=Instance.new("Frame",pageMain)
diceCard.Size=UDim2.new(1,0,0,200); diceCard.Position=UDim2.new(0,0,0,0)
diceCard.BackgroundColor3=Color3.fromRGB(18,14,32); diceCard.BorderSizePixel=0
Instance.new("UICorner",diceCard).CornerRadius=UDim.new(0,16)
local diceCardStroke=Instance.new("UIStroke",diceCard)
diceCardStroke.Color=Color3.fromRGB(100,60,180); diceCardStroke.Thickness=1.5; diceCardStroke.Transparency=0.5

-- dice emoji
local diceLbl=Instance.new("TextLabel",diceCard)
diceLbl.Size=UDim2.new(0,90,0,90); diceLbl.Position=UDim2.new(0,12,0.5,-45)
diceLbl.BackgroundColor3=Color3.fromRGB(26,18,50); diceLbl.Text="🎲"
diceLbl.TextSize=48; diceLbl.Font=Enum.Font.Gotham; diceLbl.TextColor3=Color3.fromRGB(220,190,255)
diceLbl.BorderSizePixel=0
Instance.new("UICorner",diceLbl).CornerRadius=UDim.new(0,14)
local diceGlow=Instance.new("UIStroke",diceLbl)
diceGlow.Color=Color3.fromRGB(140,90,255); diceGlow.Thickness=2; diceGlow.Transparency=0.5

-- skill info panel (right of dice)
local infoPanel=Instance.new("Frame",diceCard)
infoPanel.Size=UDim2.new(1,-118,1,-16); infoPanel.Position=UDim2.new(0,110,0,8)
infoPanel.BackgroundTransparency=1

local rarityTag=Instance.new("TextLabel",infoPanel)
rarityTag.Size=UDim2.new(0,110,0,22); rarityTag.Position=UDim2.new(0,0,0,4)
rarityTag.BackgroundColor3=Color3.fromRGB(30,22,55)
rarityTag.Text=""; rarityTag.TextSize=11; rarityTag.Font=Enum.Font.GothamBold
rarityTag.TextColor3=Color3.fromRGB(200,180,255); rarityTag.BorderSizePixel=0; rarityTag.Visible=false
Instance.new("UICorner",rarityTag).CornerRadius=UDim.new(0,6)

local skillNameLbl=Instance.new("TextLabel",infoPanel)
skillNameLbl.Size=UDim2.new(1,0,0,28); skillNameLbl.Position=UDim2.new(0,0,0,30)
skillNameLbl.BackgroundTransparency=1; skillNameLbl.Text="Roll the dice!"
skillNameLbl.TextColor3=Color3.fromRGB(215,185,255); skillNameLbl.Font=Enum.Font.GothamBold
skillNameLbl.TextSize=17; skillNameLbl.TextXAlignment=Enum.TextXAlignment.Left

local skillDescLbl=Instance.new("TextLabel",infoPanel)
skillDescLbl.Size=UDim2.new(1,0,0,40); skillDescLbl.Position=UDim2.new(0,0,0,60)
skillDescLbl.BackgroundTransparency=1; skillDescLbl.Text="Tekan ROLL untuk dapat skill acak!"
skillDescLbl.TextColor3=Color3.fromRGB(150,130,190); skillDescLbl.Font=Enum.Font.Gotham
skillDescLbl.TextSize=13; skillDescLbl.TextXAlignment=Enum.TextXAlignment.Left; skillDescLbl.TextWrapped=true

local flavorLbl=Instance.new("TextLabel",infoPanel)
flavorLbl.Size=UDim2.new(1,0,0,22); flavorLbl.Position=UDim2.new(0,0,0,104)
flavorLbl.BackgroundTransparency=1; flavorLbl.Text=""
flavorLbl.TextColor3=Color3.fromRGB(100,85,140); flavorLbl.Font=Enum.Font.GothamItalic
flavorLbl.TextSize=12; flavorLbl.TextXAlignment=Enum.TextXAlignment.Left; flavorLbl.TextWrapped=true

-- USE / SKIP
local useBtn=Instance.new("TextButton",pageMain)
useBtn.Size=UDim2.new(0.47,0,0,48); useBtn.Position=UDim2.new(0,0,0,210)
useBtn.BackgroundColor3=Color3.fromRGB(60,185,100); useBtn.Text="✅  USE"
useBtn.TextColor3=Color3.fromRGB(255,255,255); useBtn.Font=Enum.Font.GothamBold
useBtn.TextSize=15; useBtn.BorderSizePixel=0; useBtn.Visible=false
Instance.new("UICorner",useBtn).CornerRadius=UDim.new(0,12)

local skipBtn=Instance.new("TextButton",pageMain)
skipBtn.Size=UDim2.new(0.47,0,0,48); skipBtn.Position=UDim2.new(0.53,0,0,210)
skipBtn.BackgroundColor3=Color3.fromRGB(190,60,60); skipBtn.Text="⏭  SKIP"
skipBtn.TextColor3=Color3.fromRGB(255,255,255); skipBtn.Font=Enum.Font.GothamBold
skipBtn.TextSize=15; skipBtn.BorderSizePixel=0; skipBtn.Visible=false
Instance.new("UICorner",skipBtn).CornerRadius=UDim.new(0,12)

-- Check Server
local checkBtn=Instance.new("TextButton",pageMain)
checkBtn.Size=UDim2.new(1,0,0,38); checkBtn.Position=UDim2.new(0,0,0,210)
checkBtn.BackgroundColor3=Color3.fromRGB(25,70,150); checkBtn.Text="🔍  CHECK SERVER SUPPORT"
checkBtn.TextColor3=Color3.fromRGB(255,255,255); checkBtn.Font=Enum.Font.GothamBold
checkBtn.TextSize=13; checkBtn.BorderSizePixel=0
Instance.new("UICorner",checkBtn).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",checkBtn).Color=Color3.fromRGB(60,130,255)

-- Roll Button
local rollBtn=Instance.new("TextButton",pageMain)
rollBtn.Size=UDim2.new(1,0,0,54); rollBtn.Position=UDim2.new(0,0,0,258)
rollBtn.BackgroundColor3=Color3.fromRGB(105,50,210); rollBtn.Text="🎲  ROLL THE DICE"
rollBtn.TextColor3=Color3.fromRGB(255,255,255); rollBtn.Font=Enum.Font.GothamBold
rollBtn.TextSize=16; rollBtn.BorderSizePixel=0
Instance.new("UICorner",rollBtn).CornerRadius=UDim.new(0,14)
local rollStroke=Instance.new("UIStroke",rollBtn)
rollStroke.Color=Color3.fromRGB(170,110,255); rollStroke.Thickness=1.5

-- Streak
local streakLbl=Instance.new("TextLabel",pageMain)
streakLbl.Size=UDim2.new(1,0,0,22); streakLbl.Position=UDim2.new(0,0,0,320)
streakLbl.BackgroundTransparency=1; streakLbl.Text=""
streakLbl.TextColor3=Color3.fromRGB(255,195,50); streakLbl.Font=Enum.Font.GothamBold
streakLbl.TextSize=12; streakLbl.TextXAlignment=Enum.TextXAlignment.Center

-- Slots header
local slotsHeader=Instance.new("TextLabel",pageMain)
slotsHeader.Size=UDim2.new(1,0,0,18); slotsHeader.Position=UDim2.new(0,0,0,350)
slotsHeader.BackgroundTransparency=1; slotsHeader.Text="ACTIVE SKILL SLOTS  [0/"..MAX_SLOTS.."]"
slotsHeader.TextColor3=Color3.fromRGB(110,85,160); slotsHeader.Font=Enum.Font.GothamBold
slotsHeader.TextSize=11; slotsHeader.TextXAlignment=Enum.TextXAlignment.Left

-- Slots frame
local slotsFrame=Instance.new("Frame",pageMain)
slotsFrame.Size=UDim2.new(1,0,0,70); slotsFrame.Position=UDim2.new(0,0,0,372)
slotsFrame.BackgroundColor3=Color3.fromRGB(18,14,30); slotsFrame.BorderSizePixel=0
Instance.new("UICorner",slotsFrame).CornerRadius=UDim.new(0,12)
local slotsLayout=Instance.new("UIListLayout",slotsFrame)
slotsLayout.FillDirection=Enum.FillDirection.Horizontal
slotsLayout.Padding=UDim.new(0,6); slotsLayout.VerticalAlignment=Enum.VerticalAlignment.Center
Instance.new("UIPadding",slotsFrame).PaddingLeft=UDim.new(0,8)

-- Clear all
local clearBtn=Instance.new("TextButton",pageMain)
clearBtn.Size=UDim2.new(1,0,0,36); clearBtn.Position=UDim2.new(0,0,0,450)
clearBtn.BackgroundColor3=Color3.fromRGB(45,30,70); clearBtn.Text="🗑  Clear All Skills"
clearBtn.TextColor3=Color3.fromRGB(170,135,210); clearBtn.Font=Enum.Font.Gotham
clearBtn.TextSize=13; clearBtn.BorderSizePixel=0
Instance.new("UICorner",clearBtn).CornerRadius=UDim.new(0,10)

-- ════════════════════════════
--  PAGE 2: HISTORY
-- ════════════════════════════
local histTitle=Instance.new("TextLabel",pageHistory)
histTitle.Size=UDim2.new(1,0,0,24); histTitle.BackgroundTransparency=1
histTitle.Text="📜 Roll History (last 20)"; histTitle.TextColor3=Color3.fromRGB(200,170,255)
histTitle.Font=Enum.Font.GothamBold; histTitle.TextSize=14; histTitle.TextXAlignment=Enum.TextXAlignment.Left

local histScroll=Instance.new("ScrollingFrame",pageHistory)
histScroll.Size=UDim2.new(1,0,1,-32); histScroll.Position=UDim2.new(0,0,0,28)
histScroll.BackgroundColor3=Color3.fromRGB(16,12,26); histScroll.BorderSizePixel=0
histScroll.ScrollBarThickness=4; histScroll.ScrollBarImageColor3=Color3.fromRGB(100,60,180)
histScroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",histScroll).CornerRadius=UDim.new(0,12)
local histLayout=Instance.new("UIListLayout",histScroll)
histLayout.Padding=UDim.new(0,4)
Instance.new("UIPadding",histScroll).PaddingTop=UDim.new(0,6)
Instance.new("UIPadding",histScroll).PaddingLeft=UDim.new(0,8)
Instance.new("UIPadding",histScroll).PaddingRight=UDim.new(0,8)

local function addHistoryEntry(skill, wasUsed)
	-- Tambah ke tabel
	table.insert(rollHistory, 1, {skill=skill, used=wasUsed, time=os.clock()})
	if #rollHistory > MAX_HISTORY then table.remove(rollHistory) end
	-- Rebuild history UI
	for _,c in ipairs(histScroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	for i, entry in ipairs(rollHistory) do
		local row=Instance.new("Frame",histScroll)
		row.Size=UDim2.new(1,-8,0,36); row.BackgroundColor3=Color3.fromRGB(22,17,38)
		row.BorderSizePixel=0
		Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
		local stroke=Instance.new("UIStroke",row)
		stroke.Color=rC(entry.skill.rarity); stroke.Thickness=1; stroke.Transparency=0.6
		local icon=Instance.new("TextLabel",row)
		icon.Size=UDim2.new(0,32,1,0); icon.BackgroundTransparency=1
		icon.Text=entry.skill.icon; icon.TextSize=18; icon.Font=Enum.Font.Gotham
		local nameLbl=Instance.new("TextLabel",row)
		nameLbl.Size=UDim2.new(1,-80,1,0); nameLbl.Position=UDim2.new(0,34,0,0)
		nameLbl.BackgroundTransparency=1; nameLbl.Text=entry.skill.name
		nameLbl.TextColor3=rC(entry.skill.rarity); nameLbl.Font=Enum.Font.GothamBold
		nameLbl.TextSize=13; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
		local statusLbl=Instance.new("TextLabel",row)
		statusLbl.Size=UDim2.new(0,50,1,0); statusLbl.Position=UDim2.new(1,-52,0,0)
		statusLbl.BackgroundTransparency=1
		statusLbl.Text=entry.used and "✅ Used" or "⏭ Skip"
		statusLbl.TextColor3=entry.used and Color3.fromRGB(100,220,130) or Color3.fromRGB(200,100,100)
		statusLbl.Font=Enum.Font.Gotham; statusLbl.TextSize=11
	end
	histScroll.CanvasSize=UDim2.new(0,0,0,#rollHistory*40+10)
end

-- ════════════════════════════
--  PAGE 3: TRADE
-- ════════════════════════════
local tradeLockedLbl=Instance.new("TextLabel",pageTrade)
tradeLockedLbl.Size=UDim2.new(1,0,0,60); tradeLockedLbl.Position=UDim2.new(0,0,0.3,0)
tradeLockedLbl.BackgroundTransparency=1
tradeLockedLbl.Text="🔒 Trade dinonaktifkan\nAktifkan di tab ⚙️ Settings"
tradeLockedLbl.TextColor3=Color3.fromRGB(140,120,170); tradeLockedLbl.Font=Enum.Font.Gotham
tradeLockedLbl.TextSize=14; tradeLockedLbl.TextXAlignment=Enum.TextXAlignment.Center; tradeLockedLbl.TextWrapped=true

local tradePanel=Instance.new("Frame",pageTrade)
tradePanel.Size=UDim2.new(1,0,1,0); tradePanel.BackgroundTransparency=1; tradePanel.Visible=false

local tradeTitleLbl=Instance.new("TextLabel",tradePanel)
tradeTitleLbl.Size=UDim2.new(1,0,0,24); tradeTitleLbl.BackgroundTransparency=1
tradeTitleLbl.Text="🤝 Trade Skill ke Player"; tradeTitleLbl.TextColor3=Color3.fromRGB(200,170,255)
tradeTitleLbl.Font=Enum.Font.GothamBold; tradeTitleLbl.TextSize=14; tradeTitleLbl.TextXAlignment=Enum.TextXAlignment.Left

-- Player list scroll
local playerScroll=Instance.new("ScrollingFrame",tradePanel)
playerScroll.Size=UDim2.new(1,0,0,120); playerScroll.Position=UDim2.new(0,0,0,30)
playerScroll.BackgroundColor3=Color3.fromRGB(16,12,26); playerScroll.BorderSizePixel=0
playerScroll.ScrollBarThickness=4; playerScroll.ScrollBarImageColor3=Color3.fromRGB(100,60,180)
playerScroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",playerScroll).CornerRadius=UDim.new(0,10)
local playerLayout=Instance.new("UIListLayout",playerScroll)
playerLayout.Padding=UDim.new(0,4)
Instance.new("UIPadding",playerScroll).PaddingLeft=UDim.new(0,6)
Instance.new("UIPadding",playerScroll).PaddingTop=UDim.new(0,6)

local selectedTradeTarget = nil
local selectedTradeSkill  = nil

-- Skill selector for trade
local tradeSlotsTitle=Instance.new("TextLabel",tradePanel)
tradeSlotsTitle.Size=UDim2.new(1,0,0,20); tradeSlotsTitle.Position=UDim2.new(0,0,0,158)
tradeSlotsTitle.BackgroundTransparency=1; tradeSlotsTitle.Text="Pilih skill yang mau di-trade:"
tradeSlotsTitle.TextColor3=Color3.fromRGB(160,140,200); tradeSlotsTitle.Font=Enum.Font.Gotham
tradeSlotsTitle.TextSize=12; tradeSlotsTitle.TextXAlignment=Enum.TextXAlignment.Left

local tradeSkillScroll=Instance.new("ScrollingFrame",tradePanel)
tradeSkillScroll.Size=UDim2.new(1,0,0,100); tradeSkillScroll.Position=UDim2.new(0,0,0,180)
tradeSkillScroll.BackgroundColor3=Color3.fromRGB(16,12,26); tradeSkillScroll.BorderSizePixel=0
tradeSkillScroll.ScrollBarThickness=4; tradeSkillScroll.ScrollBarImageColor3=Color3.fromRGB(100,60,180)
tradeSkillScroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",tradeSkillScroll).CornerRadius=UDim.new(0,10)
local tradeSkillLayout=Instance.new("UIListLayout",tradeSkillScroll)
tradeSkillLayout.FillDirection=Enum.FillDirection.Horizontal; tradeSkillLayout.Padding=UDim.new(0,6)
tradeSkillLayout.VerticalAlignment=Enum.VerticalAlignment.Center
Instance.new("UIPadding",tradeSkillScroll).PaddingLeft=UDim.new(0,8)

local sendTradeBtn=Instance.new("TextButton",tradePanel)
sendTradeBtn.Size=UDim2.new(1,0,0,44); sendTradeBtn.Position=UDim2.new(0,0,0,290)
sendTradeBtn.BackgroundColor3=Color3.fromRGB(50,130,220); sendTradeBtn.Text="📤  Send Trade Offer"
sendTradeBtn.TextColor3=Color3.fromRGB(255,255,255); sendTradeBtn.Font=Enum.Font.GothamBold
sendTradeBtn.TextSize=14; sendTradeBtn.BorderSizePixel=0
Instance.new("UICorner",sendTradeBtn).CornerRadius=UDim.new(0,12)

local tradeStatusLbl=Instance.new("TextLabel",tradePanel)
tradeStatusLbl.Size=UDim2.new(1,0,0,30); tradeStatusLbl.Position=UDim2.new(0,0,0,342)
tradeStatusLbl.BackgroundTransparency=1; tradeStatusLbl.Text=""
tradeStatusLbl.TextColor3=Color3.fromRGB(180,160,220); tradeStatusLbl.Font=Enum.Font.Gotham
tradeStatusLbl.TextSize=13; tradeStatusLbl.TextXAlignment=Enum.TextXAlignment.Center; tradeStatusLbl.TextWrapped=true

-- Trade incoming notification
local tradeNotif=Instance.new("Frame",SG)
tradeNotif.Size=UDim2.new(0,340,0,110); tradeNotif.Position=UDim2.new(0.5,-170,1,-130)
tradeNotif.BackgroundColor3=Color3.fromRGB(18,14,32); tradeNotif.BorderSizePixel=0
tradeNotif.Visible=false
Instance.new("UICorner",tradeNotif).CornerRadius=UDim.new(0,14)
local notifStroke=Instance.new("UIStroke",tradeNotif)
notifStroke.Color=Color3.fromRGB(50,130,220); notifStroke.Thickness=1.5
local notifTitle=Instance.new("TextLabel",tradeNotif)
notifTitle.Size=UDim2.new(1,-16,0,28); notifTitle.Position=UDim2.new(0,12,0,8)
notifTitle.BackgroundTransparency=1; notifTitle.Text="🤝 Incoming Trade!"
notifTitle.TextColor3=Color3.fromRGB(100,180,255); notifTitle.Font=Enum.Font.GothamBold
notifTitle.TextSize=14; notifTitle.TextXAlignment=Enum.TextXAlignment.Left
local notifDesc=Instance.new("TextLabel",tradeNotif)
notifDesc.Size=UDim2.new(1,-16,0,28); notifDesc.Position=UDim2.new(0,12,0,34)
notifDesc.BackgroundTransparency=1; notifDesc.Text="Player wants to trade..."
notifDesc.TextColor3=Color3.fromRGB(180,160,220); notifDesc.Font=Enum.Font.Gotham
notifDesc.TextSize=13; notifDesc.TextWrapped=true
local notifAccept=Instance.new("TextButton",tradeNotif)
notifAccept.Size=UDim2.new(0.45,0,0,32); notifAccept.Position=UDim2.new(0.04,0,1,-40)
notifAccept.BackgroundColor3=Color3.fromRGB(60,185,100); notifAccept.Text="✅ Accept"
notifAccept.TextColor3=Color3.fromRGB(255,255,255); notifAccept.Font=Enum.Font.GothamBold
notifAccept.TextSize=13; notifAccept.BorderSizePixel=0
Instance.new("UICorner",notifAccept).CornerRadius=UDim.new(0,8)
local notifDecline=Instance.new("TextButton",tradeNotif)
notifDecline.Size=UDim2.new(0.45,0,0,32); notifDecline.Position=UDim2.new(0.51,0,1,-40)
notifDecline.BackgroundColor3=Color3.fromRGB(190,60,60); notifDecline.Text="❌ Decline"
notifDecline.TextColor3=Color3.fromRGB(255,255,255); notifDecline.Font=Enum.Font.GothamBold
notifDecline.TextSize=13; notifDecline.BorderSizePixel=0
Instance.new("UICorner",notifDecline).CornerRadius=UDim.new(0,8)

local pendingTradeOffer = nil

-- ════════════════════════════
--  PAGE 4: SETTINGS
-- ════════════════════════════
local function makeToggle(parent, yPos, labelTxt, defaultOn)
	local row=Instance.new("Frame",parent)
	row.Size=UDim2.new(1,0,0,48); row.Position=UDim2.new(0,0,0,yPos)
	row.BackgroundColor3=Color3.fromRGB(18,14,30); row.BorderSizePixel=0
	Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
	local lbl=Instance.new("TextLabel",row)
	lbl.Size=UDim2.new(1,-70,1,0); lbl.Position=UDim2.new(0,14,0,0)
	lbl.BackgroundTransparency=1; lbl.Text=labelTxt
	lbl.TextColor3=Color3.fromRGB(200,180,240); lbl.Font=Enum.Font.Gotham
	lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextWrapped=true
	local toggle=Instance.new("TextButton",row)
	toggle.Size=UDim2.new(0,52,0,28); toggle.Position=UDim2.new(1,-62,0.5,-14)
	toggle.BackgroundColor3=defaultOn and Color3.fromRGB(80,200,120) or Color3.fromRGB(60,50,80)
	toggle.Text=defaultOn and "ON" or "OFF"
	toggle.TextColor3=Color3.fromRGB(255,255,255); toggle.Font=Enum.Font.GothamBold
	toggle.TextSize=12; toggle.BorderSizePixel=0
	Instance.new("UICorner",toggle).CornerRadius=UDim.new(0,8)
	local state=defaultOn
	toggle.MouseButton1Click:Connect(function()
		state=not state
		tween(toggle,{BackgroundColor3=state and Color3.fromRGB(80,200,120) or Color3.fromRGB(60,50,80)},TWEEN_FAST)
		toggle.Text=state and "ON" or "OFF"
	end)
	return toggle, function() return state end
end

local settingsTitle=Instance.new("TextLabel",pageSettings)
settingsTitle.Size=UDim2.new(1,0,0,24); settingsTitle.BackgroundTransparency=1
settingsTitle.Text="⚙️ Settings"; settingsTitle.TextColor3=Color3.fromRGB(200,170,255)
settingsTitle.Font=Enum.Font.GothamBold; settingsTitle.TextSize=14; settingsTitle.TextXAlignment=Enum.TextXAlignment.Left

local tradeToggle, getTradeState = makeToggle(pageSettings, 30, "🤝 Enable Trade System\nIzinkan trade skill ke player lain", false)
local giveToggle, getGiveState   = makeToggle(pageSettings, 86, "📡 Give All — Bagikan GUI\nSemua player di server dapat GUI ini", false)
local soundToggle, getSoundState = makeToggle(pageSettings, 142,"🔊 Sound Effects\nNyalakan efek suara saat roll & skill", true)

-- Give All button
local giveAllBtn=Instance.new("TextButton",pageSettings)
giveAllBtn.Size=UDim2.new(1,0,0,44); giveAllBtn.Position=UDim2.new(0,0,0,198)
giveAllBtn.BackgroundColor3=Color3.fromRGB(40,100,200); giveAllBtn.Text="📡  Broadcast GUI ke Semua Player"
giveAllBtn.TextColor3=Color3.fromRGB(255,255,255); giveAllBtn.Font=Enum.Font.GothamBold
giveAllBtn.TextSize=13; giveAllBtn.BorderSizePixel=0
Instance.new("UICorner",giveAllBtn).CornerRadius=UDim.new(0,12)

local settingsNote=Instance.new("TextLabel",pageSettings)
settingsNote.Size=UDim2.new(1,0,0,40); settingsNote.Position=UDim2.new(0,0,0,250)
settingsNote.BackgroundTransparency=1
settingsNote.Text="⚠️ Give All & Trade butuh Server Support (FREEDICE).\nCheck Server di tab 🎲 Roll dulu."
settingsNote.TextColor3=Color3.fromRGB(180,140,80); settingsNote.Font=Enum.Font.Gotham
settingsNote.TextSize=11; settingsNote.TextXAlignment=Enum.TextXAlignment.Left; settingsNote.TextWrapped=true

-- ══════════════════════════════════════════════════════
--  SLOT BUILDER
-- ══════════════════════════════════════════════════════
local slotObjects = {}

local function buildTradeSkillPicker()
	for _,c in ipairs(tradeSkillScroll:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	selectedTradeSkill=nil
	local total=0
	for _,entry in ipairs(activeSkills) do
		local s=entry.skill
		local btn=Instance.new("TextButton",tradeSkillScroll)
		btn.Size=UDim2.new(0,56,0,56); btn.BackgroundColor3=Color3.fromRGB(26,20,44)
		btn.Text=s.icon; btn.TextSize=24; btn.Font=Enum.Font.Gotham
		btn.TextColor3=Color3.fromRGB(255,255,255); btn.BorderSizePixel=0
		Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
		local str=Instance.new("UIStroke",btn); str.Color=rC(s.rarity); str.Thickness=2
		btn.MouseButton1Click:Connect(function()
			selectedTradeSkill=s
			for _,c2 in ipairs(tradeSkillScroll:GetChildren()) do
				if c2:IsA("TextButton") then
					tween(c2,{BackgroundColor3=Color3.fromRGB(26,20,44)},TWEEN_FAST)
				end
			end
			tween(btn,{BackgroundColor3=Color3.fromRGB(60,40,100)},TWEEN_FAST)
			tradeStatusLbl.Text="Skill dipilih: "..s.icon.." "..s.name
		end)
		total=total+1
	end
	tradeSkillScroll.CanvasSize=UDim2.new(0,total*62,0,0)
end

local function buildPlayerList()
	for _,c in ipairs(playerScroll:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	selectedTradeTarget=nil
	local count=0
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=player then
			local btn=Instance.new("TextButton",playerScroll)
			btn.Size=UDim2.new(1,-12,0,30); btn.BackgroundColor3=Color3.fromRGB(22,17,36)
			btn.Text="👤 "..p.Name; btn.Font=Enum.Font.Gotham; btn.TextSize=13
			btn.TextColor3=Color3.fromRGB(200,180,240); btn.BorderSizePixel=0
			btn.TextXAlignment=Enum.TextXAlignment.Left
			Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
			local pad=Instance.new("UIPadding",btn); pad.PaddingLeft=UDim.new(0,10)
			btn.MouseButton1Click:Connect(function()
				selectedTradeTarget=p.Name
				for _,c2 in ipairs(playerScroll:GetChildren()) do
					if c2:IsA("TextButton") then tween(c2,{BackgroundColor3=Color3.fromRGB(22,17,36)},TWEEN_FAST) end
				end
				tween(btn,{BackgroundColor3=Color3.fromRGB(40,30,70)},TWEEN_FAST)
				tradeStatusLbl.Text="Target: "..p.Name
			end)
			count=count+1
		end
	end
	playerScroll.CanvasSize=UDim2.new(0,0,0,count*34+8)
	if count==0 then
		local none=Instance.new("TextLabel",playerScroll)
		none.Size=UDim2.new(1,-12,0,30); none.BackgroundTransparency=1
		none.Text="Tidak ada player lain di server"; none.TextColor3=Color3.fromRGB(130,110,160)
		none.Font=Enum.Font.Gotham; none.TextSize=13
	end
end

local function rebuildSlots()
	for _,s in ipairs(slotObjects) do s:Destroy() end
	slotObjects={}
	slotsHeader.Text="ACTIVE SKILL SLOTS  ["..#activeSkills.."/"..MAX_SLOTS.."]"
	for i,entry in ipairs(activeSkills) do
		local s=entry.skill
		local slot=Instance.new("Frame",slotsFrame)
		slot.Size=UDim2.new(0,56,0,56); slot.BackgroundColor3=Color3.fromRGB(26,20,44)
		slot.BorderSizePixel=0
		Instance.new("UICorner",slot).CornerRadius=UDim.new(0,10)
		local str=Instance.new("UIStroke",slot); str.Color=rC(s.rarity); str.Thickness=2
		local iconLbl=Instance.new("TextLabel",slot)
		iconLbl.Size=UDim2.new(1,0,0.65,0); iconLbl.BackgroundTransparency=1
		iconLbl.Text=s.icon; iconLbl.TextSize=22; iconLbl.Font=Enum.Font.Gotham
		iconLbl.TextColor3=Color3.fromRGB(255,255,255)
		local rarLbl=Instance.new("TextLabel",slot)
		rarLbl.Size=UDim2.new(1,-2,0.35,0); rarLbl.Position=UDim2.new(0,1,0.65,0)
		rarLbl.BackgroundTransparency=1
		rarLbl.Text=s.rarity=="Legendary" and "LGND" or s.rarity
		rarLbl.TextSize=8; rarLbl.Font=Enum.Font.GothamBold; rarLbl.TextColor3=rC(s.rarity)
		local rb=Instance.new("TextButton",slot); rb.Size=UDim2.new(1,0,1,0)
		rb.BackgroundTransparency=1; rb.Text=""; rb.ZIndex=10
		rb.MouseEnter:Connect(function()
			iconLbl.Text="✕"
			tween(slot,{BackgroundColor3=Color3.fromRGB(90,25,25)},TWEEN_FAST)
		end)
		rb.MouseLeave:Connect(function()
			iconLbl.Text=s.icon
			tween(slot,{BackgroundColor3=Color3.fromRGB(26,20,44)},TWEEN_FAST)
		end)
		rb.MouseButton1Click:Connect(function()
			pcall(s.remove)
			table.remove(activeSkills,i)
			activeIds[s.id]=nil
			rebuildSlots()
			buildTradeSkillPicker()
		end)
		table.insert(slotObjects,slot)
	end
	for _=1,MAX_SLOTS-#activeSkills do
		local empty=Instance.new("Frame",slotsFrame)
		empty.Size=UDim2.new(0,56,0,56); empty.BackgroundColor3=Color3.fromRGB(18,14,26)
		empty.BorderSizePixel=0
		Instance.new("UICorner",empty).CornerRadius=UDim.new(0,10)
		local es=Instance.new("UIStroke",empty)
		es.Color=Color3.fromRGB(50,40,75); es.Thickness=1.5; es.Transparency=0.6
		local el=Instance.new("TextLabel",empty)
		el.Size=UDim2.new(1,0,1,0); el.BackgroundTransparency=1
		el.Text="+"; el.TextSize=22; el.Font=Enum.Font.GothamBold
		el.TextColor3=Color3.fromRGB(50,40,70)
		table.insert(slotObjects,empty)
	end
end
rebuildSlots()

-- ══════════════════════════════════════════════════════
--  DRAG
-- ══════════════════════════════════════════════════════
local dragging,dragStart,startPos=false,nil,nil
tbar.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		dragging=true; dragStart=i.Position; startPos=win.Position
	end
end)
tbar.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
		local d=i.Position-dragStart
		win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
	end
end)
tbar.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)

-- ══════════════════════════════════════════════════════
--  MINIMIZE & CLOSE
-- ══════════════════════════════════════════════════════
local minimized=false
minBtn.MouseButton1Click:Connect(function()
	minimized=not minimized
	if minimized then
		local allFrames={tabBar,pageMain,pageHistory,pageTrade,pageSettings}
		for _,f in ipairs(allFrames) do f.Visible=false end
		tween(win,{Size=UDim2.new(0,WIN_W,0,48)},TWEEN_MED)
		minBtn.Text="□"
	else
		tween(win,{Size=UDim2.new(0,WIN_W,0,WIN_H)},TWEEN_BACK)
		task.wait(0.3)
		tabBar.Visible=true; pageMain.Visible=true
		minBtn.Text="─"
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	for k,_ in pairs(Connections) do removeConn(k) end
	tween(win,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In),{
		Size=UDim2.new(0,0,0,0),
		Position=UDim2.new(win.Position.X.Scale,win.Position.X.Offset+WIN_W/2,
			win.Position.Y.Scale,win.Position.Y.Offset+WIN_H/2)
	})
	task.wait(0.25); SG:Destroy()
end)

-- ══════════════════════════════════════════════════════
--  ROLL LOGIC
-- ══════════════════════════════════════════════════════
local diceEmojis={"⚀","⚁","⚂","⚃","⚄","⚅"}

local function showChoice(skill)
	pendingSkill=skill; waitingChoice=true
	-- Animate in
	useBtn.Visible=true; skipBtn.Visible=true
	checkBtn.Visible=false; rollBtn.Visible=false
	useBtn.BackgroundTransparency=1; skipBtn.BackgroundTransparency=1
	tween(useBtn,{BackgroundTransparency=0},TWEEN_FAST)
	tween(skipBtn,{BackgroundTransparency=0},TWEEN_FAST)
	-- Rarity effects
	tween(diceGlow,{Color=rG(skill.rarity),Transparency=0},TWEEN_MED)
	tween(diceCardStroke,{Color=rG(skill.rarity),Transparency=0.2},TWEEN_MED)
	rarityTag.Text=RE[skill.rarity].."  "..skill.rarity:upper()
	rarityTag.TextColor3=rC(skill.rarity)
	tween(rarityTag,{BackgroundColor3=rC(skill.rarity):Lerp(Color3.fromRGB(0,0,0),0.7)},TWEEN_FAST)
	rarityTag.Visible=true
	-- Skill info
	skillNameLbl.Text=skill.name; skillNameLbl.TextColor3=rC(skill.rarity)
	skillDescLbl.Text=skill.desc
	flavorLbl.Text=skill.flavor or ""
	-- Sound
	if getSoundState() then playSound(rS(skill.rarity)) end
end

local function hideChoice()
	useBtn.Visible=false; skipBtn.Visible=false
	checkBtn.Visible=not checkDone and true or false
	rollBtn.Visible=true
	waitingChoice=false; pendingSkill=nil
	tween(diceGlow,{Color=Color3.fromRGB(140,90,255),Transparency=0.5},TWEEN_MED)
	tween(diceCardStroke,{Color=Color3.fromRGB(100,60,180),Transparency=0.5},TWEEN_MED)
	rarityTag.Visible=false
end

local checkDone=false

local function updateStreak()
	if rollStreak>=3 then
		streakLbl.Text="🔥 Streak: "..rollStreak.."x — Legendary chance naik!"
		streakLbl.TextColor3=Color3.fromRGB(255,160,40)
	elseif rollStreak>0 then
		streakLbl.Text="Skip streak: "..rollStreak.."x"
		streakLbl.TextColor3=Color3.fromRGB(200,200,200)
	else streakLbl.Text="" end
end

rollBtn.MouseButton1Click:Connect(function()
	if isRolling or waitingChoice then return end
	if #activeSkills>=MAX_SLOTS then
		skillNameLbl.Text="⚠️ Slot penuh!"; skillDescLbl.Text="Remove skill dulu."
		return
	end
	isRolling=true
	rollBtn.Text="Rolling..."; tween(rollBtn,{BackgroundColor3=Color3.fromRGB(60,35,120)},TWEEN_FAST)
	skillNameLbl.Text="Rolling..."; skillDescLbl.Text=""; flavorLbl.Text=""
	rarityTag.Visible=false
	if getSoundState() then playSound("roll") end
	local elapsed,interval=0,0.07
	while elapsed<1.4 do
		diceLbl.Text=diceEmojis[math.random(1,#diceEmojis)]
		task.wait(interval); elapsed=elapsed+interval; interval=math.min(interval+0.013,0.22)
	end
	local excList={}
	for id in pairs(activeIds) do table.insert(excList,id) end
	local skill=SkillDB.Pick(excList, rollStreak>=3 and rollStreak or nil)
	tween(rollBtn,{BackgroundColor3=Color3.fromRGB(105,50,210)},TWEEN_FAST)
	rollBtn.Text="🎲  ROLL THE DICE"; isRolling=false
	if not skill then
		diceLbl.Text="😵"; skillNameLbl.Text="Semua skill aktif!"
		skillDescLbl.Text="Clear dulu beberapa skill."
		return
	end
	diceLbl.Text=skill.icon
	showChoice(skill)
end)

useBtn.MouseButton1Click:Connect(function()
	if not pendingSkill then return end
	local skill=pendingSkill
	local ok,err=pcall(skill.apply)
	if ok then
		table.insert(activeSkills,{skill=skill,addedAt=tick()})
		activeIds[skill.id]=true
		rollStreak=0; updateStreak(); rebuildSlots(); buildTradeSkillPicker()
		addHistoryEntry(skill, true)
		skillNameLbl.Text="✅ "..skill.name; skillNameLbl.TextColor3=rC(skill.rarity)
		local modeStr=serverMode and " 🌐" or " 💻"
		skillDescLbl.Text="Skill aktif!"..modeStr
		flavorLbl.Text=skill.flavor or ""
		if getSoundState() then playSound("use") end
	else
		skillNameLbl.Text="❌ Error"; skillDescLbl.Text=tostring(err)
		skillNameLbl.TextColor3=Color3.fromRGB(255,100,100)
		warn("[DiceCore] Apply error:",err)
	end
	hideChoice()
end)

skipBtn.MouseButton1Click:Connect(function()
	if not pendingSkill then return end
	addHistoryEntry(pendingSkill, false)
	rollStreak=rollStreak+1; updateStreak()
	skillNameLbl.Text="Roll the dice!"; skillNameLbl.TextColor3=Color3.fromRGB(215,185,255)
	skillDescLbl.Text="Dilewatin! Roll lagi."; flavorLbl.Text=""
	diceLbl.Text="🎲"
	if getSoundState() then playSound("skip") end
	hideChoice()
end)

clearBtn.MouseButton1Click:Connect(function()
	for _,entry in ipairs(activeSkills) do pcall(entry.skill.remove) end
	if serverMode and REMOTE then REMOTE:FireServer("ClearAll","") end
	for k,_ in pairs(Connections) do removeConn(k) end
	activeSkills={}; activeIds={}; rollStreak=0; updateStreak(); rebuildSlots(); buildTradeSkillPicker()
	local c=player.Character
	if c then
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and OriginalSizes[p.Name] then
				pcall(function() p.Size=OriginalSizes[p.Name] end)
			end
		end
	end
	workspace.Gravity=196.2
	local h2=c and c:FindFirstChildOfClass("Humanoid")
	if h2 then h2.WalkSpeed=16; h2.JumpPower=50 end
	skillNameLbl.Text="Roll the dice!"; skillNameLbl.TextColor3=Color3.fromRGB(215,185,255)
	skillDescLbl.Text="Semua skill di-reset!"; flavorLbl.Text=""; diceLbl.Text="🎲"
end)

-- ══════════════════════════════════════════════════════
--  CHECK SERVER
-- ══════════════════════════════════════════════════════
checkBtn.MouseButton1Click:Connect(function()
	checkBtn.Text="⏳ Searching FREEDICE..."
	tween(checkBtn,{BackgroundColor3=Color3.fromRGB(40,40,60)},TWEEN_FAST)
	tween(serverBadge,{BackgroundColor3=Color3.fromRGB(40,40,40)},TWEEN_FAST)
	task.wait(1.2)
	local found=checkServer()
	checkDone=true
	checkBtn.Visible=false
	if found then
		tween(serverBadge,{BackgroundColor3=Color3.fromRGB(20,90,45)},TWEEN_FAST)
		serverBadge.Text="🌐 SERVER MODE"
		serverBadge.TextColor3=Color3.fromRGB(100,255,150)
		skillDescLbl.Text="Server support aktif!\nEfek keliatan semua orang 🌐"
	else
		tween(serverBadge,{BackgroundColor3=Color3.fromRGB(80,50,20)},TWEEN_FAST)
		serverBadge.Text="💻 LOCAL ONLY"
		serverBadge.TextColor3=Color3.fromRGB(255,175,70)
		skillDescLbl.Text="No server. Efek local only 💻"
	end
end)

-- ══════════════════════════════════════════════════════
--  SETTINGS ACTIONS
-- ══════════════════════════════════════════════════════
tradeToggle.MouseButton1Click:Connect(function()
	task.wait(0.05)
	tradeEnabled=getTradeState()
	tradeLockedLbl.Visible=not tradeEnabled
	tradePanel.Visible=tradeEnabled
	if tradeEnabled then buildPlayerList() end
end)

giveAllBtn.MouseButton1Click:Connect(function()
	if not serverMode or not GIVE_REMOTE then
		settingsNote.Text="❌ Butuh server support! Check server dulu di tab 🎲 Roll."
		tween(settingsNote,{TextColor3=Color3.fromRGB(220,80,80)},TWEEN_FAST)
		return
	end
	GIVE_REMOTE:FireServer("GiveAll")
	giveAllBtn.Text="✅ GUI Broadcasted!"
	tween(giveAllBtn,{BackgroundColor3=Color3.fromRGB(30,130,70)},TWEEN_FAST)
	task.wait(3)
	giveAllBtn.Text="📡  Broadcast GUI ke Semua Player"
	tween(giveAllBtn,{BackgroundColor3=Color3.fromRGB(40,100,200)},TWEEN_FAST)
	settingsNote.Text="⚠️ Give All & Trade butuh Server Support.\nCheck Server di tab 🎲 Roll dulu."
	tween(settingsNote,{TextColor3=Color3.fromRGB(180,140,80)},TWEEN_FAST)
end)

-- ══════════════════════════════════════════════════════
--  SEND TRADE
-- ══════════════════════════════════════════════════════
sendTradeBtn.MouseButton1Click:Connect(function()
	if not serverMode or not TRADE_REMOTE then
		tradeStatusLbl.Text="❌ Butuh server support!"
		return
	end
	if not selectedTradeTarget then
		tradeStatusLbl.Text="⚠️ Pilih player dulu!"; return
	end
	if not selectedTradeSkill then
		tradeStatusLbl.Text="⚠️ Pilih skill dulu!"; return
	end
	local offerData={
		from=player.Name,
		skillId=selectedTradeSkill.id,
		skillName=selectedTradeSkill.name,
		skillIcon=selectedTradeSkill.icon,
		skillRarity=selectedTradeSkill.rarity,
	}
	TRADE_REMOTE:FireServer("Offer", selectedTradeTarget, offerData)
	tradeStatusLbl.Text="📤 Offer terkirim ke "..selectedTradeTarget.."!"
	if getSoundState() then playSound("trade") end
end)

-- ══════════════════════════════════════════════════════
--  TRADE INCOMING HANDLER
-- ══════════════════════════════════════════════════════
local function handleTradeRemote(action, ...)
	local args={...}
	if action=="IncomingOffer" then
		local senderName,offerData=args[1],args[2]
		pendingTradeOffer=offerData
		notifTitle.Text="🤝 Trade dari "..senderName.."!"
		notifDesc.Text=offerData.skillIcon.." "..offerData.skillName.." ("..offerData.skillRarity..")"
		tradeNotif.Visible=true
		tween(tradeNotif,{Position=UDim2.new(0.5,-170,1,-130)},TWEEN_BACK)
		if getSoundState() then playSound("trade") end

	elseif action=="TradeAccepted" then
		local accepterName,data=args[1],args[2]
		-- Hapus skill dari slot sender
		for i,entry in ipairs(activeSkills) do
			if entry.skill.id==data.skillId then
				pcall(entry.skill.remove)
				table.remove(activeSkills,i)
				activeIds[data.skillId]=nil
				break
			end
		end
		rebuildSlots(); buildTradeSkillPicker()
		tradeStatusLbl.Text="✅ "..accepterName.." menerima trade!"

	elseif action=="TradeComplete" then
		-- Receiver dapat skill baru
		local data=args[1]
		for _,skill in ipairs(SkillDB.Skills) do
			if skill.id==data.skillId then
				if #activeSkills<MAX_SLOTS then
					local ok=pcall(skill.apply)
					if ok then
						table.insert(activeSkills,{skill=skill,addedAt=tick()})
						activeIds[skill.id]=true
						rebuildSlots(); buildTradeSkillPicker()
						skillNameLbl.Text="🎁 Dapat "..skill.name.." dari trade!"
						skillNameLbl.TextColor3=rC(skill.rarity)
					end
				end
				break
			end
		end

	elseif action=="TradeDeclined" then
		tradeStatusLbl.Text="❌ "..args[1].." menolak trade."
	end
end

-- Connect trade remote kalau server mode aktif
local function connectTradeRemote()
	if TRADE_REMOTE then
		TRADE_REMOTE.OnClientEvent:Connect(function(action,...)
			handleTradeRemote(action,...)
		end)
	end
end

-- Accept / Decline trade notif
notifAccept.MouseButton1Click:Connect(function()
	if not pendingTradeOffer or not TRADE_REMOTE then return end
	TRADE_REMOTE:FireServer("Accept", pendingTradeOffer.from, pendingTradeOffer)
	tradeNotif.Visible=false; pendingTradeOffer=nil
end)
notifDecline.MouseButton1Click:Connect(function()
	if not pendingTradeOffer or not TRADE_REMOTE then return end
	TRADE_REMOTE:FireServer("Decline", pendingTradeOffer.from, pendingTradeOffer)
	tradeNotif.Visible=false; pendingTradeOffer=nil
end)

-- ══════════════════════════════════════════════════════
--  GIVE ALL — receive GUI
-- ══════════════════════════════════════════════════════
-- Kalau server ada, listen untuk event DICE_GIVEGUI
task.spawn(function()
	task.wait(2) -- tunggu sebentar biar game load
	local gr=ReplicatedStorage:FindFirstChild("DICE_GIVEGUI")
	if gr then
		gr.OnClientEvent:Connect(function(action)
			if action=="ReceiveGUI" then
				-- Script ini sudah jalan, GUI sudah ada
				-- Kalau belum ada, ini trigger re-execute
				if not player.PlayerGui:FindFirstChild("DiceOfFateGui") then
					-- Re-spawn GUI
					warn("[DiceCore] GUI tidak ditemukan, reload...")
				else
					-- Flash notification
					local notifFlash=Instance.new("Frame",SG)
					notifFlash.Size=UDim2.new(0,280,0,50)
					notifFlash.Position=UDim2.new(0.5,-140,0,20)
					notifFlash.BackgroundColor3=Color3.fromRGB(40,100,200)
					notifFlash.BorderSizePixel=0
					Instance.new("UICorner",notifFlash).CornerRadius=UDim.new(0,10)
					local fl=Instance.new("TextLabel",notifFlash)
					fl.Size=UDim2.new(1,0,1,0); fl.BackgroundTransparency=1
					fl.Text="🎲 Dice of Fate tersedia! Cek GUI kamu."; fl.TextWrapped=true
					fl.TextColor3=Color3.fromRGB(255,255,255); fl.Font=Enum.Font.GothamBold; fl.TextSize=13
					tween(notifFlash,{BackgroundTransparency=0},TWEEN_FAST)
					task.wait(3)
					tween(notifFlash,{BackgroundTransparency=1},TWEEN_MED)
					task.wait(0.3); notifFlash:Destroy()
				end
			end
		end)
	end
end)

-- ══════════════════════════════════════════════════════
--  HOVER EFFECTS
-- ══════════════════════════════════════════════════════
local function hover(btn,n,h)
	btn.MouseEnter:Connect(function() tween(btn,{BackgroundColor3=h},TWEEN_FAST) end)
	btn.MouseLeave:Connect(function() tween(btn,{BackgroundColor3=n},TWEEN_FAST) end)
end
hover(rollBtn,   Color3.fromRGB(105,50,210),  Color3.fromRGB(135,75,255))
hover(useBtn,    Color3.fromRGB(60,185,100),  Color3.fromRGB(45,215,90))
hover(skipBtn,   Color3.fromRGB(190,60,60),   Color3.fromRGB(220,45,45))
hover(clearBtn,  Color3.fromRGB(45,30,70),    Color3.fromRGB(65,48,105))
hover(checkBtn,  Color3.fromRGB(25,70,150),   Color3.fromRGB(40,100,210))
hover(giveAllBtn,Color3.fromRGB(40,100,200),  Color3.fromRGB(55,125,240))
hover(sendTradeBtn,Color3.fromRGB(50,130,220),Color3.fromRGB(70,155,255))

-- ══════════════════════════════════════════════════════
--  OPEN ANIMATION
-- ══════════════════════════════════════════════════════
win.Size=UDim2.new(0,0,0,0); win.Position=UDim2.new(0.5,0,0.5,0)
tabBar.Visible=false; pageMain.Visible=false; task.wait(0.05)
tween(win,TWEEN_BACK,{Size=UDim2.new(0,WIN_W,0,WIN_H),Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)})
task.wait(0.3); tabBar.Visible=true; pageMain.Visible=true

-- Connect trade remote setelah GUI ready
task.spawn(function()
	task.wait(1)
	connectTradeRemote()
end)

print("[DiceCore v5] ✅ Loaded! Tabs: Roll | History | Trade | Settings 🎲")
