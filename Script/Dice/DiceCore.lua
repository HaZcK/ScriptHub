-- ╔══════════════════════════════════════════════════════════════╗
-- ║                 DICE OF FATE — DiceCore v5.1                 ║
-- ║         Fixed: Font, Sound IDs, Layout, Buttons              ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")

-- ══════════════════════════════════════════════
--  CONNECTION MANAGER
-- ══════════════════════════════════════════════
local Connections = {}
local function storeConn(key, conn)
	if Connections[key] then pcall(function() Connections[key]:Disconnect() end) end
	Connections[key] = conn
end
local function removeConn(key)
	if Connections[key] then pcall(function() Connections[key]:Disconnect() end) Connections[key] = nil end
end

-- ══════════════════════════════════════════════
--  ORIGINAL SIZES
-- ══════════════════════════════════════════════
local OriginalSizes = {}
for _,p in ipairs(character:GetDescendants()) do
	if p:IsA("BasePart") then OriginalSizes[p.Name] = p.Size end
end

local function getChar()
	character = player.Character or character
	humanoid  = character and character:FindFirstChildOfClass("Humanoid") or humanoid
	return character, humanoid
end

-- ══════════════════════════════════════════════
--  SERVER DETECTION
-- ══════════════════════════════════════════════
local serverMode   = false
local REMOTE       = nil
local TRADE_REMOTE = nil
local GIVE_REMOTE  = nil

local function checkServer()
	local ping = ReplicatedStorage:FindFirstChild("DICE_PING")
	if ping and ping:IsA("RemoteFunction") then
		local ok, res = pcall(function() return ping:InvokeServer() end)
		if ok and res == true then
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
	if serverMode and REMOTE then pcall(function() REMOTE:FireServer(action, data) end) end
end

-- ══════════════════════════════════════════════
--  SOUND SYSTEM (valid Roblox free audio IDs)
-- ══════════════════════════════════════════════
local soundEnabled = true
local SFX = {}
local validSounds = {
	roll   = "131961136",   -- dice roll click
	use    = "131070398",   -- confirm
	skip   = "131070300",   -- whoosh
	common = "131070371",   -- soft pop
	rare   = "131070376",   -- chime
	epic   = "131070380",   -- power up
	legend = "131070383",   -- fanfare
	trade  = "131070393",   -- ping
}
for key, id in pairs(validSounds) do
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. id
	s.Volume = 0.5
	s.Parent = game:GetService("SoundService")
	SFX[key] = s
end

local function playSound(key)
	if not soundEnabled then return end
	local s = SFX[key]
	if s then pcall(function() s:Play() end) end
end

-- ══════════════════════════════════════════════
--  TWEEN HELPERS
-- ══════════════════════════════════════════════
local TW_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
local TW_MED  = TweenInfo.new(0.28, Enum.EasingStyle.Quart)
local TW_BACK = TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function tw(obj, props, info)
	TweenService:Create(obj, info or TW_MED, props):Play()
end

-- ══════════════════════════════════════════════
--  RARITY DATA
-- ══════════════════════════════════════════════
local Rarity = {
	Common    = { color=Color3.fromRGB(180,180,180), glow=Color3.fromRGB(220,220,220), weight=50, sfx="common"  },
	Rare      = { color=Color3.fromRGB(80,140,255),  glow=Color3.fromRGB(120,180,255), weight=30, sfx="rare"    },
	Epic      = { color=Color3.fromRGB(180,80,255),  glow=Color3.fromRGB(220,120,255), weight=15, sfx="epic"    },
	Legendary = { color=Color3.fromRGB(255,180,0),   glow=Color3.fromRGB(255,220,80),  weight=5,  sfx="legend"  },
}
local RE = { Common="⚪", Rare="🔵", Epic="🟣", Legendary="🟡" }
local function rC(r) return Rarity[r] and Rarity[r].color or Color3.fromRGB(200,200,200) end
local function rG(r) return Rarity[r] and Rarity[r].glow  or Color3.fromRGB(200,200,200) end

-- ══════════════════════════════════════════════
--  SKILL DATABASE
--
--  CARA TAMBAH CUSTOM SKILL:
--  1. Copy salah satu blok skill di bawah
--  2. Ganti: id, name, icon, rarity, desc, flavor
--  3. Isi fungsi apply() dan remove()
--  4. Tambahkan juga di DiceServer.lua
--     SkillRegistry["id_kamu"] = { apply=..., remove=... }
--  5. Rarity: "Common" | "Rare" | "Epic" | "Legendary"
-- ══════════════════════════════════════════════
local Skills = {

	-- ══ COMMON ══
	{
		id="speed_demon", name="Speed Demon", icon="💨", rarity="Common",
		desc="WalkSpeed jadi 100.", flavor="Angin aja kalah!",
		apply=function()  local c,h=getChar(); h.WalkSpeed=100;  fireServer("Apply","speed_demon")  end,
		remove=function() local c,h=getChar(); h.WalkSpeed=16;   fireServer("Remove","speed_demon") end,
	},
	{
		id="super_jump", name="Super Jump", icon="🚀", rarity="Common",
		desc="JumpPower jadi 200.", flavor="Gravity? Belum kenal.",
		apply=function()  local c,h=getChar(); h.JumpPower=200; fireServer("Apply","super_jump")  end,
		remove=function() local c,h=getChar(); h.JumpPower=50;  fireServer("Remove","super_jump") end,
	},
	{
		id="giant_head", name="Giant Head", icon="🗿", rarity="Common",
		desc="Kepala jadi 5x gede.", flavor="Braincell makin besar.",
		apply=function()
			local c,h=getChar()
			local head=c:FindFirstChild("Head"); if head then head.Size=Vector3.new(5,5,5) end
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
		desc="Kaki mengecil. Jalannya lucu.", flavor="Kaki kamu mana??",
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
		desc="Lengan jadi super gede.", flavor="Siap angkat planet.",
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
		desc="Lengan super panjang menjuntai.", flavor="Nyampe lantai dari berdiri.",
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
		desc="Badan transparan 80%.", flavor="Boo!",
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
		desc="Seluruh badan jadi emas.", flavor="Midas wishes.",
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
		desc="Warna badan berubah pelangi nonstop.", flavor="Serotonin overload.",
		apply=function()
			fireServer("Apply","rainbow_body")
			if not serverMode then
				local conn=RunService.Heartbeat:Connect(function()
					local t=tick(); local c2=player.Character; if not c2 then return end
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
			removeConn("rainbow"); fireServer("Remove","rainbow_body")
			local c,h=getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Color=Color3.fromRGB(163,162,165) end
			end
		end,
	},
	{
		id="anti_gravity", name="Anti Gravity", icon="🪐", rarity="Rare",
		desc="Gravitasi berkurang, lompat melayang.", flavor="Space walk vibes.",
		apply=function()
			local c,h=getChar(); h.JumpPower=150
			local hrp=c:FindFirstChild("HumanoidRootPart")
			if hrp then
				local old=hrp:FindFirstChild("_AntiGrav"); if old then old:Destroy() end
				local bf=Instance.new("BodyForce"); bf.Name="_AntiGrav"
				bf.Force=Vector3.new(0,workspace.Gravity*hrp:GetMass()*0.75,0); bf.Parent=hrp
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
		desc="Badan jadi es transparan biru.", flavor="Dingin sampe jiwa membeku.",
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
		desc="Ninggalin jejak api saat berjalan.", flavor="Floor is literally lava.",
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
		remove=function() removeConn("lava"); fireServer("Remove","lava_trail") end,
	},
	{
		id="spinning_head", name="Spinning Head", icon="🌀", rarity="Rare",
		desc="Kepala muter nonstop.", flavor="Pusing lihatnya.",
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
		remove=function() removeConn("spin"); fireServer("Remove","spinning_head") end,
	},

	-- ══ EPIC ══
	{
		id="ant_size", name="Ant Size", icon="🐜", rarity="Epic",
		desc="Tubuh mengecil jadi 0.3x.", flavor="Siapa kamu? Mana kamu?",
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
		desc="Tumbuh jadi raksasa 3x ukuran.", flavor="Fee-fi-fo-fum.",
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
		desc="Kamera terbalik 180°.", flavor="Maju itu mundur.",
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
			removeConn("backwards"); workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
		end,
	},
	{
		id="magnet_body", name="Magnet Body", icon="🧲", rarity="Epic",
		desc="Benda sekitar tertarik ke kamu.", flavor="Personal gravitational field.",
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
		remove=function() removeConn("magnet"); fireServer("Remove","magnet_body") end,
	},

	-- ══ LEGENDARY ══
	{
		id="time_warp", name="Time Warp", icon="⏳", rarity="Legendary",
		desc="Gravitasi drop ke 20. Kamu tetap kenceng.", flavor="LEGENDARY — Waktu itu relatif.",
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
		desc="Speed + Jump + Giant Head + Rainbow Neon.", flavor="LEGENDARY — Chaos personified.",
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
			local head=c:FindFirstChild("Head")
			if head and OriginalSizes["Head"] then head.Size=OriginalSizes["Head"] end
			fireServer("Remove","god_mode")
		end,
	},

	--[[
	══════════════════════════════════════════
	  CUSTOM SKILL TEMPLATE
	  Copy blok ini dan taruh di atas baris --]]
	--  Ganti semua nilainya sesuai skill kamu!
	--
	-- {
	--     id      = "nama_unik",
	--     name    = "Nama Skill",
	--     icon    = "🎯",
	--     rarity  = "Common",
	--     desc    = "Deskripsi singkat.",
	--     flavor  = "Kalimat keren.",
	--     apply = function()
	--         local c, h = getChar()
	--         -- tulis efek di sini
	--         h.WalkSpeed = 50
	--         fireServer("Apply", "nama_unik")
	--     end,
	--     remove = function()
	--         local c, h = getChar()
	--         -- balik ke normal
	--         h.WalkSpeed = 16
	--         fireServer("Remove", "nama_unik")
	--     end,
	-- },
	--[[
	══════════════════════════════════════════
	--]]
}

local function pickSkill(excludeIds, streakBonus)
	excludeIds = excludeIds or {}
	local excSet = {}
	for _,id in ipairs(excludeIds) do excSet[id]=true end
	local pool = {}
	for _,skill in ipairs(Skills) do
		if not excSet[skill.id] then
			local w = Rarity[skill.rarity].weight
			if skill.rarity=="Legendary" and streakBonus then w=w+(streakBonus*4) end
			for _=1,w do table.insert(pool,skill) end
		end
	end
	if #pool==0 then return nil end
	return pool[math.random(1,#pool)]
end

-- ══════════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════════
local activeSkills  = {}
local activeIds     = {}
local rollHistory   = {}
local isRolling     = false
local waitingChoice = false
local pendingSkill  = nil
local rollStreak    = 0
local checkDone     = false
local MAX_SLOTS     = 5
local MAX_HISTORY   = 20
local selectedTarget= nil
local selectedSkill = nil

-- ══════════════════════════════════════════════
--  GUI SETUP
-- ══════════════════════════════════════════════
local old = player.PlayerGui:FindFirstChild("DiceOfFateGui")
if old then old:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name="DiceOfFateGui"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=player.PlayerGui

local W,H = 420, 700

-- ── WINDOW ──
local win = Instance.new("Frame",SG)
win.Name="Win"; win.Size=UDim2.new(0,W,0,H)
win.Position=UDim2.new(0.5,-W/2,0.5,-H/2)
win.BackgroundColor3=Color3.fromRGB(12,10,20)
win.BorderSizePixel=0; win.ClipsDescendants=true
Instance.new("UICorner",win).CornerRadius=UDim.new(0,16)
local winStroke=Instance.new("UIStroke",win)
winStroke.Color=Color3.fromRGB(90,50,170); winStroke.Thickness=2; winStroke.Transparency=0.3

-- ── TITLE BAR ──
local tbar=Instance.new("Frame",win)
tbar.Size=UDim2.new(1,0,0,50); tbar.Position=UDim2.new(0,0,0,0)
tbar.BackgroundColor3=Color3.fromRGB(18,14,34); tbar.BorderSizePixel=0; tbar.ZIndex=5
Instance.new("UICorner",tbar).CornerRadius=UDim.new(0,16)
-- Fill bottom corners
local tbarFix=Instance.new("Frame",tbar)
tbarFix.Size=UDim2.new(1,0,0,16); tbarFix.Position=UDim2.new(0,0,1,-16)
tbarFix.BackgroundColor3=Color3.fromRGB(18,14,34); tbarFix.BorderSizePixel=0

local titleLbl=Instance.new("TextLabel",tbar)
titleLbl.Size=UDim2.new(1,-170,1,0); titleLbl.Position=UDim2.new(0,14,0,0)
titleLbl.BackgroundTransparency=1; titleLbl.Text="🎲  DICE OF FATE"
titleLbl.TextColor3=Color3.fromRGB(200,160,255); titleLbl.Font=Enum.Font.GothamBold
titleLbl.TextSize=15; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.ZIndex=6

local serverBadge=Instance.new("TextLabel",tbar)
serverBadge.Size=UDim2.new(0,96,0,24); serverBadge.Position=UDim2.new(1,-156,0.5,-12)
serverBadge.BackgroundColor3=Color3.fromRGB(30,30,30); serverBadge.Text="⚫ OFFLINE"
serverBadge.TextSize=10; serverBadge.Font=Enum.Font.GothamBold
serverBadge.TextColor3=Color3.fromRGB(140,140,140); serverBadge.BorderSizePixel=0; serverBadge.ZIndex=6
Instance.new("UICorner",serverBadge).CornerRadius=UDim.new(0,6)

local function makeCtrl(xOff, bg, txt)
	local b=Instance.new("TextButton",tbar)
	b.Size=UDim2.new(0,24,0,24); b.Position=UDim2.new(1,xOff,0.5,-12)
	b.BackgroundColor3=bg; b.Text=txt; b.TextColor3=Color3.fromRGB(255,255,255)
	b.TextSize=12; b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0; b.ZIndex=7
	Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
	return b
end
local closeBtn=makeCtrl(-30, Color3.fromRGB(210,60,70), "✕")
local minBtn  =makeCtrl(-58, Color3.fromRGB(230,150,20), "─")

-- ── TAB BAR ──
local tabBar=Instance.new("Frame",win)
tabBar.Size=UDim2.new(1,-24,0,38); tabBar.Position=UDim2.new(0,12,0,56)
tabBar.BackgroundColor3=Color3.fromRGB(18,14,30); tabBar.BorderSizePixel=0
Instance.new("UICorner",tabBar).CornerRadius=UDim.new(0,10)
local tabLL=Instance.new("UIListLayout",tabBar)
tabLL.FillDirection=Enum.FillDirection.Horizontal
tabLL.HorizontalAlignment=Enum.HorizontalAlignment.Center
tabLL.VerticalAlignment=Enum.VerticalAlignment.Center
tabLL.Padding=UDim.new(0,4)
local tabPad=Instance.new("UIPadding",tabBar); tabPad.PaddingLeft=UDim.new(0,5); tabPad.PaddingRight=UDim.new(0,5)

local function makeTabBtn(label, isActive)
	local b=Instance.new("TextButton",tabBar)
	b.Size=UDim2.new(0,90,0,30)
	b.BackgroundColor3=isActive and Color3.fromRGB(95,48,200) or Color3.fromRGB(28,22,44)
	b.Text=label; b.Font=Enum.Font.GothamBold; b.TextSize=12; b.BorderSizePixel=0
	b.TextColor3=isActive and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,110,170)
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
	return b
end
local TAB_ROLL = makeTabBtn("🎲 Roll",    true)
local TAB_HIST = makeTabBtn("📜 History", false)
local TAB_TRAD = makeTabBtn("🤝 Trade",   false)
local TAB_SETT = makeTabBtn("⚙️ Settings",false)

-- ── PAGES ──
local pageY = 100  -- starting Y for all pages
local pageH = H - pageY - 8

local function makePage()
	local f=Instance.new("Frame",win)
	f.Size=UDim2.new(1,-24,0,pageH); f.Position=UDim2.new(0,12,0,pageY)
	f.BackgroundTransparency=1; f.Visible=false; f.ClipsDescendants=false
	return f
end

local pageRoll = makePage(); pageRoll.Visible=true
local pageHist = makePage()
local pageTrad = makePage()
local pageSett = makePage()

local allPages={pageRoll,pageHist,pageTrad,pageSett}
local allTabs ={TAB_ROLL,TAB_HIST,TAB_TRAD,TAB_SETT}

local function switchTab(idx)
	for i,pg in ipairs(allPages) do
		pg.Visible=(i==idx)
		local on=(i==idx)
		tw(allTabs[i],{
			BackgroundColor3=on and Color3.fromRGB(95,48,200) or Color3.fromRGB(28,22,44),
			TextColor3=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,110,170)
		},TW_FAST)
	end
end
TAB_ROLL.MouseButton1Click:Connect(function() switchTab(1) end)
TAB_HIST.MouseButton1Click:Connect(function() switchTab(2) end)
TAB_TRAD.MouseButton1Click:Connect(function() switchTab(3) end)
TAB_SETT.MouseButton1Click:Connect(function() switchTab(4) end)

-- ══════════════════════════════════════════════
--  PAGE 1: ROLL
-- ══════════════════════════════════════════════

-- Skill card (top)
local card=Instance.new("Frame",pageRoll)
card.Size=UDim2.new(1,0,0,160); card.Position=UDim2.new(0,0,0,0)
card.BackgroundColor3=Color3.fromRGB(16,12,28); card.BorderSizePixel=0
Instance.new("UICorner",card).CornerRadius=UDim.new(0,14)
local cardStroke=Instance.new("UIStroke",card)
cardStroke.Color=Color3.fromRGB(90,50,170); cardStroke.Thickness=1.5; cardStroke.Transparency=0.4

-- dice box (left of card)
local diceBox=Instance.new("Frame",card)
diceBox.Size=UDim2.new(0,100,0,100); diceBox.Position=UDim2.new(0,14,0.5,-50)
diceBox.BackgroundColor3=Color3.fromRGB(22,16,42); diceBox.BorderSizePixel=0
Instance.new("UICorner",diceBox).CornerRadius=UDim.new(0,14)
local diceStroke=Instance.new("UIStroke",diceBox)
diceStroke.Color=Color3.fromRGB(130,80,240); diceStroke.Thickness=2; diceStroke.Transparency=0.4

local diceEmoji=Instance.new("TextLabel",diceBox)
diceEmoji.Size=UDim2.new(1,0,1,0); diceEmoji.BackgroundTransparency=1
diceEmoji.Text="🎲"; diceEmoji.TextSize=50; diceEmoji.Font=Enum.Font.Gotham

-- Info right side
local infoBox=Instance.new("Frame",card)
infoBox.Size=UDim2.new(1,-130,1,-16); infoBox.Position=UDim2.new(0,124,0,8)
infoBox.BackgroundTransparency=1

local rarTag=Instance.new("TextLabel",infoBox)
rarTag.Size=UDim2.new(0,100,0,20); rarTag.BackgroundColor3=Color3.fromRGB(28,20,50)
rarTag.Text=""; rarTag.TextSize=10; rarTag.Font=Enum.Font.GothamBold
rarTag.TextColor3=Color3.fromRGB(200,180,255); rarTag.BorderSizePixel=0; rarTag.Visible=false
Instance.new("UICorner",rarTag).CornerRadius=UDim.new(0,6)

local skillTitle=Instance.new("TextLabel",infoBox)
skillTitle.Size=UDim2.new(1,0,0,26); skillTitle.Position=UDim2.new(0,0,0,26)
skillTitle.BackgroundTransparency=1; skillTitle.Text="Roll the dice!"
skillTitle.TextColor3=Color3.fromRGB(220,190,255); skillTitle.Font=Enum.Font.GothamBold
skillTitle.TextSize=16; skillTitle.TextXAlignment=Enum.TextXAlignment.Left

local skillDesc=Instance.new("TextLabel",infoBox)
skillDesc.Size=UDim2.new(1,0,0,38); skillDesc.Position=UDim2.new(0,0,0,56)
skillDesc.BackgroundTransparency=1; skillDesc.Text="Tekan ROLL untuk dapat skill acak!"
skillDesc.TextColor3=Color3.fromRGB(145,125,185); skillDesc.Font=Enum.Font.Gotham
skillDesc.TextSize=12; skillDesc.TextXAlignment=Enum.TextXAlignment.Left; skillDesc.TextWrapped=true

local flavorLbl=Instance.new("TextLabel",infoBox)
flavorLbl.Size=UDim2.new(1,0,0,20); flavorLbl.Position=UDim2.new(0,0,0,98)
flavorLbl.BackgroundTransparency=1; flavorLbl.Text=""
flavorLbl.TextColor3=Color3.fromRGB(95,80,130); flavorLbl.Font=Enum.Font.Gotham
flavorLbl.TextSize=11; flavorLbl.TextXAlignment=Enum.TextXAlignment.Left; flavorLbl.TextWrapped=true

-- ── BUTTONS AREA ──
-- Check Server button
local checkBtn=Instance.new("TextButton",pageRoll)
checkBtn.Size=UDim2.new(1,0,0,40); checkBtn.Position=UDim2.new(0,0,0,168)
checkBtn.BackgroundColor3=Color3.fromRGB(22,65,145); checkBtn.Text="🔍  CHECK SERVER SUPPORT"
checkBtn.TextColor3=Color3.fromRGB(255,255,255); checkBtn.Font=Enum.Font.GothamBold
checkBtn.TextSize=13; checkBtn.BorderSizePixel=0
Instance.new("UICorner",checkBtn).CornerRadius=UDim.new(0,12)
local checkStroke=Instance.new("UIStroke",checkBtn)
checkStroke.Color=Color3.fromRGB(55,120,255); checkStroke.Thickness=1.5

-- USE / SKIP (hidden initially)
local useBtn=Instance.new("TextButton",pageRoll)
useBtn.Size=UDim2.new(0.48,0,0,40); useBtn.Position=UDim2.new(0,0,0,168)
useBtn.BackgroundColor3=Color3.fromRGB(50,175,90); useBtn.Text="✅  USE"
useBtn.TextColor3=Color3.fromRGB(255,255,255); useBtn.Font=Enum.Font.GothamBold
useBtn.TextSize=15; useBtn.BorderSizePixel=0; useBtn.Visible=false
Instance.new("UICorner",useBtn).CornerRadius=UDim.new(0,12)

local skipBtn=Instance.new("TextButton",pageRoll)
skipBtn.Size=UDim2.new(0.48,0,0,40); skipBtn.Position=UDim2.new(0.52,0,0,168)
skipBtn.BackgroundColor3=Color3.fromRGB(180,55,55); skipBtn.Text="⏭  SKIP"
skipBtn.TextColor3=Color3.fromRGB(255,255,255); skipBtn.Font=Enum.Font.GothamBold
skipBtn.TextSize=15; skipBtn.BorderSizePixel=0; skipBtn.Visible=false
Instance.new("UICorner",skipBtn).CornerRadius=UDim.new(0,12)

-- Roll Button
local rollBtn=Instance.new("TextButton",pageRoll)
rollBtn.Size=UDim2.new(1,0,0,52); rollBtn.Position=UDim2.new(0,0,0,216)
rollBtn.BackgroundColor3=Color3.fromRGB(100,48,205); rollBtn.Text="🎲  ROLL THE DICE"
rollBtn.TextColor3=Color3.fromRGB(255,255,255); rollBtn.Font=Enum.Font.GothamBold
rollBtn.TextSize=17; rollBtn.BorderSizePixel=0
Instance.new("UICorner",rollBtn).CornerRadius=UDim.new(0,14)
local rollStroke=Instance.new("UIStroke",rollBtn)
rollStroke.Color=Color3.fromRGB(165,105,255); rollStroke.Thickness=2

-- Streak label
local streakLbl=Instance.new("TextLabel",pageRoll)
streakLbl.Size=UDim2.new(1,0,0,20); streakLbl.Position=UDim2.new(0,0,0,276)
streakLbl.BackgroundTransparency=1; streakLbl.Text=""
streakLbl.TextColor3=Color3.fromRGB(255,190,45); streakLbl.Font=Enum.Font.GothamBold
streakLbl.TextSize=12; streakLbl.TextXAlignment=Enum.TextXAlignment.Center

-- Slots header
local slotsHdr=Instance.new("TextLabel",pageRoll)
slotsHdr.Size=UDim2.new(1,0,0,16); slotsHdr.Position=UDim2.new(0,0,0,304)
slotsHdr.BackgroundTransparency=1; slotsHdr.Text="ACTIVE SKILL SLOTS  [0/5]"
slotsHdr.TextColor3=Color3.fromRGB(100,80,150); slotsHdr.Font=Enum.Font.GothamBold
slotsHdr.TextSize=11; slotsHdr.TextXAlignment=Enum.TextXAlignment.Left

-- Slots frame
local slotsFrame=Instance.new("Frame",pageRoll)
slotsFrame.Size=UDim2.new(1,0,0,68); slotsFrame.Position=UDim2.new(0,0,0,324)
slotsFrame.BackgroundColor3=Color3.fromRGB(16,12,26); slotsFrame.BorderSizePixel=0
Instance.new("UICorner",slotsFrame).CornerRadius=UDim.new(0,12)
local slotsLL=Instance.new("UIListLayout",slotsFrame)
slotsLL.FillDirection=Enum.FillDirection.Horizontal
slotsLL.Padding=UDim.new(0,6); slotsLL.VerticalAlignment=Enum.VerticalAlignment.Center
local slotsPad=Instance.new("UIPadding",slotsFrame); slotsPad.PaddingLeft=UDim.new(0,8)

-- Clear all
local clearBtn=Instance.new("TextButton",pageRoll)
clearBtn.Size=UDim2.new(1,0,0,36); clearBtn.Position=UDim2.new(0,0,0,400)
clearBtn.BackgroundColor3=Color3.fromRGB(40,28,65); clearBtn.Text="🗑  Clear All Skills"
clearBtn.TextColor3=Color3.fromRGB(165,130,205); clearBtn.Font=Enum.Font.Gotham
clearBtn.TextSize=13; clearBtn.BorderSizePixel=0
Instance.new("UICorner",clearBtn).CornerRadius=UDim.new(0,10)

-- ══════════════════════════════════════════════
--  PAGE 2: HISTORY
-- ══════════════════════════════════════════════
local histHdr=Instance.new("TextLabel",pageHist)
histHdr.Size=UDim2.new(1,0,0,22); histHdr.BackgroundTransparency=1
histHdr.Text="📜 Roll History (last 20)"; histHdr.TextColor3=Color3.fromRGB(195,165,250)
histHdr.Font=Enum.Font.GothamBold; histHdr.TextSize=14; histHdr.TextXAlignment=Enum.TextXAlignment.Left

local histScroll=Instance.new("ScrollingFrame",pageHist)
histScroll.Size=UDim2.new(1,0,1,-28); histScroll.Position=UDim2.new(0,0,0,26)
histScroll.BackgroundColor3=Color3.fromRGB(14,11,24); histScroll.BorderSizePixel=0
histScroll.ScrollBarThickness=4; histScroll.ScrollBarImageColor3=Color3.fromRGB(90,50,170)
histScroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",histScroll).CornerRadius=UDim.new(0,12)
local histLL=Instance.new("UIListLayout",histScroll); histLL.Padding=UDim.new(0,4)
local histPad=Instance.new("UIPadding",histScroll)
histPad.PaddingTop=UDim.new(0,6); histPad.PaddingLeft=UDim.new(0,8); histPad.PaddingRight=UDim.new(0,8)

local function refreshHistory()
	for _,c in ipairs(histScroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	if #rollHistory==0 then
		local empty=Instance.new("TextLabel",histScroll)
		empty.Size=UDim2.new(1,-8,0,40); empty.BackgroundTransparency=1
		empty.Text="Belum ada roll history."; empty.TextColor3=Color3.fromRGB(120,100,155)
		empty.Font=Enum.Font.Gotham; empty.TextSize=13; empty.TextXAlignment=Enum.TextXAlignment.Center
	end
	for _,entry in ipairs(rollHistory) do
		local row=Instance.new("Frame",histScroll)
		row.Size=UDim2.new(1,-8,0,38); row.BackgroundColor3=Color3.fromRGB(20,16,34)
		row.BorderSizePixel=0
		Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
		local rs=Instance.new("UIStroke",row); rs.Color=rC(entry.skill.rarity); rs.Thickness=1; rs.Transparency=0.6
		local ic=Instance.new("TextLabel",row)
		ic.Size=UDim2.new(0,36,1,0); ic.BackgroundTransparency=1
		ic.Text=entry.skill.icon; ic.TextSize=20; ic.Font=Enum.Font.Gotham
		local nl=Instance.new("TextLabel",row)
		nl.Size=UDim2.new(1,-86,1,0); nl.Position=UDim2.new(0,36,0,0)
		nl.BackgroundTransparency=1; nl.Text=entry.skill.name
		nl.TextColor3=rC(entry.skill.rarity); nl.Font=Enum.Font.GothamBold
		nl.TextSize=13; nl.TextXAlignment=Enum.TextXAlignment.Left
		local sl=Instance.new("TextLabel",row)
		sl.Size=UDim2.new(0,56,1,0); sl.Position=UDim2.new(1,-58,0,0)
		sl.BackgroundTransparency=1
		sl.Text=entry.used and "✅ Used" or "⏭ Skip"
		sl.TextColor3=entry.used and Color3.fromRGB(80,210,120) or Color3.fromRGB(200,90,90)
		sl.Font=Enum.Font.Gotham; sl.TextSize=11
	end
	histScroll.CanvasSize=UDim2.new(0,0,0,#rollHistory*42+10)
end
refreshHistory()

-- ══════════════════════════════════════════════
--  PAGE 3: TRADE
-- ══════════════════════════════════════════════
local tradeLocked=Instance.new("TextLabel",pageTrad)
tradeLocked.Size=UDim2.new(1,0,0,60); tradeLocked.Position=UDim2.new(0,0,0.35,0)
tradeLocked.BackgroundTransparency=1
tradeLocked.Text="🔒 Trade dinonaktifkan\nAktifkan di tab ⚙️ Settings"
tradeLocked.TextColor3=Color3.fromRGB(130,110,160); tradeLocked.Font=Enum.Font.Gotham
tradeLocked.TextSize=14; tradeLocked.TextXAlignment=Enum.TextXAlignment.Center; tradeLocked.TextWrapped=true

local tradePanel=Instance.new("Frame",pageTrad)
tradePanel.Size=UDim2.new(1,0,1,0); tradePanel.BackgroundTransparency=1; tradePanel.Visible=false

local tradeTitleLbl=Instance.new("TextLabel",tradePanel)
tradeTitleLbl.Size=UDim2.new(1,0,0,22); tradeTitleLbl.BackgroundTransparency=1
tradeTitleLbl.Text="🤝 Trade Skill ke Player Lain"
tradeTitleLbl.TextColor3=Color3.fromRGB(195,165,250); tradeTitleLbl.Font=Enum.Font.GothamBold
tradeTitleLbl.TextSize=14; tradeTitleLbl.TextXAlignment=Enum.TextXAlignment.Left

-- Player list
local playerScroll=Instance.new("ScrollingFrame",tradePanel)
playerScroll.Size=UDim2.new(1,0,0,110); playerScroll.Position=UDim2.new(0,0,0,28)
playerScroll.BackgroundColor3=Color3.fromRGB(14,11,24); playerScroll.BorderSizePixel=0
playerScroll.ScrollBarThickness=4; playerScroll.ScrollBarImageColor3=Color3.fromRGB(90,50,170)
playerScroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",playerScroll).CornerRadius=UDim.new(0,10)
local playerLL=Instance.new("UIListLayout",playerScroll); playerLL.Padding=UDim.new(0,4)
local playerPad=Instance.new("UIPadding",playerScroll)
playerPad.PaddingLeft=UDim.new(0,6); playerPad.PaddingTop=UDim.new(0,6)

-- Skill selector
local tradeSkillHdr=Instance.new("TextLabel",tradePanel)
tradeSkillHdr.Size=UDim2.new(1,0,0,18); tradeSkillHdr.Position=UDim2.new(0,0,0,146)
tradeSkillHdr.BackgroundTransparency=1; tradeSkillHdr.Text="Pilih skill yang mau di-trade:"
tradeSkillHdr.TextColor3=Color3.fromRGB(155,135,195); tradeSkillHdr.Font=Enum.Font.Gotham
tradeSkillHdr.TextSize=12; tradeSkillHdr.TextXAlignment=Enum.TextXAlignment.Left

local tradeSkillScroll=Instance.new("ScrollingFrame",tradePanel)
tradeSkillScroll.Size=UDim2.new(1,0,0,80); tradeSkillScroll.Position=UDim2.new(0,0,0,168)
tradeSkillScroll.BackgroundColor3=Color3.fromRGB(14,11,24); tradeSkillScroll.BorderSizePixel=0
tradeSkillScroll.ScrollBarThickness=4; tradeSkillScroll.ScrollBarImageColor3=Color3.fromRGB(90,50,170)
tradeSkillScroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",tradeSkillScroll).CornerRadius=UDim.new(0,10)
local tsLL=Instance.new("UIListLayout",tradeSkillScroll)
tsLL.FillDirection=Enum.FillDirection.Horizontal; tsLL.Padding=UDim.new(0,6)
tsLL.VerticalAlignment=Enum.VerticalAlignment.Center
Instance.new("UIPadding",tradeSkillScroll).PaddingLeft=UDim.new(0,8)

local sendTradeBtn=Instance.new("TextButton",tradePanel)
sendTradeBtn.Size=UDim2.new(1,0,0,42); sendTradeBtn.Position=UDim2.new(0,0,0,258)
sendTradeBtn.BackgroundColor3=Color3.fromRGB(45,120,215); sendTradeBtn.Text="📤  Send Trade Offer"
sendTradeBtn.TextColor3=Color3.fromRGB(255,255,255); sendTradeBtn.Font=Enum.Font.GothamBold
sendTradeBtn.TextSize=14; sendTradeBtn.BorderSizePixel=0
Instance.new("UICorner",sendTradeBtn).CornerRadius=UDim.new(0,12)

local tradeStatus=Instance.new("TextLabel",tradePanel)
tradeStatus.Size=UDim2.new(1,0,0,28); tradeStatus.Position=UDim2.new(0,0,0,308)
tradeStatus.BackgroundTransparency=1; tradeStatus.Text=""
tradeStatus.TextColor3=Color3.fromRGB(175,155,215); tradeStatus.Font=Enum.Font.Gotham
tradeStatus.TextSize=13; tradeStatus.TextXAlignment=Enum.TextXAlignment.Center; tradeStatus.TextWrapped=true

-- ══════════════════════════════════════════════
--  PAGE 4: SETTINGS
-- ══════════════════════════════════════════════
local settHdr=Instance.new("TextLabel",pageSett)
settHdr.Size=UDim2.new(1,0,0,22); settHdr.BackgroundTransparency=1
settHdr.Text="⚙️ Settings"; settHdr.TextColor3=Color3.fromRGB(195,165,250)
settHdr.Font=Enum.Font.GothamBold; settHdr.TextSize=14; settHdr.TextXAlignment=Enum.TextXAlignment.Left

local tradeEnabled = false
local giveAllState = false

local function makeToggleRow(parent, y, label, sublabel, defaultOn)
	local row=Instance.new("Frame",parent)
	row.Size=UDim2.new(1,0,0,52); row.Position=UDim2.new(0,0,0,y)
	row.BackgroundColor3=Color3.fromRGB(16,12,26); row.BorderSizePixel=0
	Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
	local lbl=Instance.new("TextLabel",row)
	lbl.Size=UDim2.new(1,-70,0,26); lbl.Position=UDim2.new(0,12,0,4)
	lbl.BackgroundTransparency=1; lbl.Text=label
	lbl.TextColor3=Color3.fromRGB(200,180,235); lbl.Font=Enum.Font.GothamBold
	lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left
	local sub=Instance.new("TextLabel",row)
	sub.Size=UDim2.new(1,-70,0,18); sub.Position=UDim2.new(0,12,0,28)
	sub.BackgroundTransparency=1; sub.Text=sublabel
	sub.TextColor3=Color3.fromRGB(120,100,155); sub.Font=Enum.Font.Gotham
	sub.TextSize=11; sub.TextXAlignment=Enum.TextXAlignment.Left
	local tog=Instance.new("TextButton",row)
	tog.Size=UDim2.new(0,54,0,28); tog.Position=UDim2.new(1,-62,0.5,-14)
	tog.BackgroundColor3=defaultOn and Color3.fromRGB(70,190,110) or Color3.fromRGB(55,45,80)
	tog.Text=defaultOn and "ON" or "OFF"; tog.TextColor3=Color3.fromRGB(255,255,255)
	tog.Font=Enum.Font.GothamBold; tog.TextSize=12; tog.BorderSizePixel=0
	Instance.new("UICorner",tog).CornerRadius=UDim.new(0,8)
	local state=defaultOn
	tog.MouseButton1Click:Connect(function()
		state=not state
		tw(tog,{BackgroundColor3=state and Color3.fromRGB(70,190,110) or Color3.fromRGB(55,45,80)},TW_FAST)
		tog.Text=state and "ON" or "OFF"
	end)
	return tog, function() return state end
end

local togTrade, getTrade = makeToggleRow(pageSett, 28,  "🤝 Enable Trade",   "Izinkan trade skill ke player lain", false)
local togGive,  getGive  = makeToggleRow(pageSett, 88,  "📡 Give All GUI",   "Semua player dapat GUI ini", false)
local togSound, getSound = makeToggleRow(pageSett, 148, "🔊 Sound Effects",  "Efek suara saat roll & skill", true)

local giveBtn=Instance.new("TextButton",pageSett)
giveBtn.Size=UDim2.new(1,0,0,42); giveBtn.Position=UDim2.new(0,0,0,210)
giveBtn.BackgroundColor3=Color3.fromRGB(35,95,195); giveBtn.Text="📡  Broadcast GUI ke Semua Player"
giveBtn.TextColor3=Color3.fromRGB(255,255,255); giveBtn.Font=Enum.Font.GothamBold
giveBtn.TextSize=13; giveBtn.BorderSizePixel=0
Instance.new("UICorner",giveBtn).CornerRadius=UDim.new(0,12)

local settNote=Instance.new("TextLabel",pageSett)
settNote.Size=UDim2.new(1,0,0,36); settNote.Position=UDim2.new(0,0,0,260)
settNote.BackgroundTransparency=1
settNote.Text="⚠️ Give All & Trade butuh Server Support aktif.\nCheck server dulu di tab 🎲 Roll."
settNote.TextColor3=Color3.fromRGB(175,135,75); settNote.Font=Enum.Font.Gotham
settNote.TextSize=11; settNote.TextXAlignment=Enum.TextXAlignment.Left; settNote.TextWrapped=true

-- ══════════════════════════════════════════════
--  TRADE INCOMING NOTIF (floating)
-- ══════════════════════════════════════════════
local tradeNotif=Instance.new("Frame",SG)
tradeNotif.Size=UDim2.new(0,320,0,108); tradeNotif.Position=UDim2.new(0.5,-160,1,-10)
tradeNotif.BackgroundColor3=Color3.fromRGB(16,12,26); tradeNotif.BorderSizePixel=0; tradeNotif.Visible=false
Instance.new("UICorner",tradeNotif).CornerRadius=UDim.new(0,14)
local tnStroke=Instance.new("UIStroke",tradeNotif)
tnStroke.Color=Color3.fromRGB(45,120,215); tnStroke.Thickness=1.5

local tnTitle=Instance.new("TextLabel",tradeNotif)
tnTitle.Size=UDim2.new(1,-12,0,26); tnTitle.Position=UDim2.new(0,10,0,6)
tnTitle.BackgroundTransparency=1; tnTitle.Text="🤝 Incoming Trade!"
tnTitle.TextColor3=Color3.fromRGB(90,170,255); tnTitle.Font=Enum.Font.GothamBold
tnTitle.TextSize=14; tnTitle.TextXAlignment=Enum.TextXAlignment.Left

local tnDesc=Instance.new("TextLabel",tradeNotif)
tnDesc.Size=UDim2.new(1,-12,0,26); tnDesc.Position=UDim2.new(0,10,0,30)
tnDesc.BackgroundTransparency=1; tnDesc.Text="..."; tnDesc.TextColor3=Color3.fromRGB(175,155,215)
tnDesc.Font=Enum.Font.Gotham; tnDesc.TextSize=12; tnDesc.TextWrapped=true

local tnAccept=Instance.new("TextButton",tradeNotif)
tnAccept.Size=UDim2.new(0.45,0,0,30); tnAccept.Position=UDim2.new(0.03,0,1,-38)
tnAccept.BackgroundColor3=Color3.fromRGB(50,175,90); tnAccept.Text="✅ Accept"
tnAccept.TextColor3=Color3.fromRGB(255,255,255); tnAccept.Font=Enum.Font.GothamBold
tnAccept.TextSize=13; tnAccept.BorderSizePixel=0
Instance.new("UICorner",tnAccept).CornerRadius=UDim.new(0,8)

local tnDecline=Instance.new("TextButton",tradeNotif)
tnDecline.Size=UDim2.new(0.45,0,0,30); tnDecline.Position=UDim2.new(0.52,0,1,-38)
tnDecline.BackgroundColor3=Color3.fromRGB(180,55,55); tnDecline.Text="❌ Decline"
tnDecline.TextColor3=Color3.fromRGB(255,255,255); tnDecline.Font=Enum.Font.GothamBold
tnDecline.TextSize=13; tnDecline.BorderSizePixel=0
Instance.new("UICorner",tnDecline).CornerRadius=UDim.new(0,8)

local pendingOffer = nil

-- ══════════════════════════════════════════════
--  SLOT BUILDER
-- ══════════════════════════════════════════════
local slotObjs={}

local function buildTradeSkillPicker()
	for _,c in ipairs(tradeSkillScroll:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	selectedSkill=nil
	local total=0
	for _,entry in ipairs(activeSkills) do
		local s=entry.skill; total=total+1
		local btn=Instance.new("TextButton",tradeSkillScroll)
		btn.Size=UDim2.new(0,58,0,58); btn.BackgroundColor3=Color3.fromRGB(22,17,38)
		btn.Text=s.icon; btn.TextSize=26; btn.Font=Enum.Font.Gotham
		btn.TextColor3=Color3.fromRGB(255,255,255); btn.BorderSizePixel=0
		Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
		local bstr=Instance.new("UIStroke",btn); bstr.Color=rC(s.rarity); bstr.Thickness=2
		btn.MouseButton1Click:Connect(function()
			selectedSkill=s
			for _,c2 in ipairs(tradeSkillScroll:GetChildren()) do
				if c2:IsA("TextButton") then tw(c2,{BackgroundColor3=Color3.fromRGB(22,17,38)},TW_FAST) end
			end
			tw(btn,{BackgroundColor3=Color3.fromRGB(55,38,90)},TW_FAST)
			tradeStatus.Text="Skill dipilih: "..s.icon.." "..s.name
		end)
	end
	tradeSkillScroll.CanvasSize=UDim2.new(0,total*64+8,0,0)
end

local function buildPlayerList()
	for _,c in ipairs(playerScroll:GetChildren()) do
		if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
	end
	selectedTarget=nil
	local count=0
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=player then
			count=count+1
			local btn=Instance.new("TextButton",playerScroll)
			btn.Size=UDim2.new(1,-10,0,30); btn.BackgroundColor3=Color3.fromRGB(20,16,32)
			btn.Text="👤  "..p.Name; btn.Font=Enum.Font.Gotham; btn.TextSize=13
			btn.TextColor3=Color3.fromRGB(195,175,235); btn.BorderSizePixel=0
			btn.TextXAlignment=Enum.TextXAlignment.Left
			Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
			Instance.new("UIPadding",btn).PaddingLeft=UDim.new(0,10)
			btn.MouseButton1Click:Connect(function()
				selectedTarget=p.Name
				for _,c2 in ipairs(playerScroll:GetChildren()) do
					if c2:IsA("TextButton") then tw(c2,{BackgroundColor3=Color3.fromRGB(20,16,32)},TW_FAST) end
				end
				tw(btn,{BackgroundColor3=Color3.fromRGB(38,28,65)},TW_FAST)
				tradeStatus.Text="Target: "..p.Name
			end)
		end
	end
	playerScroll.CanvasSize=UDim2.new(0,0,0,count*34+8)
	if count==0 then
		local nl=Instance.new("TextLabel",playerScroll)
		nl.Size=UDim2.new(1,-10,0,30); nl.BackgroundTransparency=1
		nl.Text="Tidak ada player lain di server"
		nl.TextColor3=Color3.fromRGB(120,100,150); nl.Font=Enum.Font.Gotham; nl.TextSize=13
	end
end

local function rebuildSlots()
	for _,s in ipairs(slotObjs) do s:Destroy() end
	slotObjs={}
	slotsHdr.Text="ACTIVE SKILL SLOTS  ["..#activeSkills.."/"..MAX_SLOTS.."]"
	for i,entry in ipairs(activeSkills) do
		local s=entry.skill
		local slot=Instance.new("Frame",slotsFrame)
		slot.Size=UDim2.new(0,56,0,56); slot.BackgroundColor3=Color3.fromRGB(22,17,38)
		slot.BorderSizePixel=0
		Instance.new("UICorner",slot).CornerRadius=UDim.new(0,10)
		local ss=Instance.new("UIStroke",slot); ss.Color=rC(s.rarity); ss.Thickness=2
		local ic=Instance.new("TextLabel",slot)
		ic.Size=UDim2.new(1,0,0.64,0); ic.BackgroundTransparency=1
		ic.Text=s.icon; ic.TextSize=22; ic.Font=Enum.Font.Gotham; ic.TextColor3=Color3.fromRGB(255,255,255)
		local rl=Instance.new("TextLabel",slot)
		rl.Size=UDim2.new(1,-2,0.36,0); rl.Position=UDim2.new(0,1,0.64,0)
		rl.BackgroundTransparency=1; rl.Text=s.rarity=="Legendary" and "LGND" or s.rarity
		rl.TextSize=8; rl.Font=Enum.Font.GothamBold; rl.TextColor3=rC(s.rarity)
		local rb=Instance.new("TextButton",slot); rb.Size=UDim2.new(1,0,1,0)
		rb.BackgroundTransparency=1; rb.Text=""; rb.ZIndex=10
		rb.MouseEnter:Connect(function()
			ic.Text="✕"; tw(slot,{BackgroundColor3=Color3.fromRGB(85,22,22)},TW_FAST)
		end)
		rb.MouseLeave:Connect(function()
			ic.Text=s.icon; tw(slot,{BackgroundColor3=Color3.fromRGB(22,17,38)},TW_FAST)
		end)
		rb.MouseButton1Click:Connect(function()
			pcall(s.remove); table.remove(activeSkills,i); activeIds[s.id]=nil
			rebuildSlots(); buildTradeSkillPicker()
		end)
		table.insert(slotObjs,slot)
	end
	for _=1,MAX_SLOTS-#activeSkills do
		local e=Instance.new("Frame",slotsFrame)
		e.Size=UDim2.new(0,56,0,56); e.BackgroundColor3=Color3.fromRGB(16,12,24); e.BorderSizePixel=0
		Instance.new("UICorner",e).CornerRadius=UDim.new(0,10)
		local es=Instance.new("UIStroke",e); es.Color=Color3.fromRGB(45,35,70); es.Thickness=1.5; es.Transparency=0.5
		local el=Instance.new("TextLabel",e); el.Size=UDim2.new(1,0,1,0); el.BackgroundTransparency=1
		el.Text="+"; el.TextSize=22; el.Font=Enum.Font.GothamBold; el.TextColor3=Color3.fromRGB(45,35,65)
		table.insert(slotObjs,e)
	end
end
rebuildSlots()

-- ══════════════════════════════════════════════
--  DRAGGING
-- ══════════════════════════════════════════════
local drag,dragStart,winStart=false,nil,nil
tbar.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		drag=true; dragStart=i.Position; winStart=win.Position
	end
end)
tbar.InputChanged:Connect(function(i)
	if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
		local d=i.Position-dragStart
		win.Position=UDim2.new(winStart.X.Scale,winStart.X.Offset+d.X,winStart.Y.Scale,winStart.Y.Offset+d.Y)
	end
end)
tbar.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

-- ══════════════════════════════════════════════
--  MINIMIZE & CLOSE
-- ══════════════════════════════════════════════
local minimized=false
minBtn.MouseButton1Click:Connect(function()
	minimized=not minimized
	if minimized then
		for _,pg in ipairs(allPages) do pg.Visible=false end
		tabBar.Visible=false
		tw(win,{Size=UDim2.new(0,W,0,50)},TW_MED)
		minBtn.Text="□"
	else
		tw(win,{Size=UDim2.new(0,W,0,H)},TW_BACK)
		task.wait(0.32); tabBar.Visible=true; pageRoll.Visible=true
		minBtn.Text="─"
	end
end)
closeBtn.MouseButton1Click:Connect(function()
	for k in pairs(Connections) do removeConn(k) end
	tw(win,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In),{
		Size=UDim2.new(0,0,0,0),
		Position=UDim2.new(win.Position.X.Scale,win.Position.X.Offset+W/2,
			win.Position.Y.Scale,win.Position.Y.Offset+H/2)
	})
	task.wait(0.25); SG:Destroy()
end)

-- ══════════════════════════════════════════════
--  ROLL LOGIC
-- ══════════════════════════════════════════════
local DICE_FACES={"⚀","⚁","⚂","⚃","⚄","⚅"}

local function showChoice(skill)
	pendingSkill=skill; waitingChoice=true
	checkBtn.Visible=false; rollBtn.Visible=false
	useBtn.Visible=true; skipBtn.Visible=true
	tw(diceStroke,{Color=rG(skill.rarity),Transparency=0.1},TW_MED)
	tw(cardStroke,{Color=rG(skill.rarity),Transparency=0.2},TW_MED)
	rarTag.Text=RE[skill.rarity].."  "..skill.rarity:upper()
	rarTag.TextColor3=rC(skill.rarity); rarTag.Visible=true
	skillTitle.Text=skill.name; skillTitle.TextColor3=rC(skill.rarity)
	skillDesc.Text=skill.desc; flavorLbl.Text=skill.flavor or ""
	soundEnabled=getSound()
	playSound(Rarity[skill.rarity].sfx)
end

local function hideChoice()
	pendingSkill=nil; waitingChoice=false
	useBtn.Visible=false; skipBtn.Visible=false
	checkBtn.Visible=not checkDone
	rollBtn.Visible=true
	tw(diceStroke,{Color=Color3.fromRGB(130,80,240),Transparency=0.4},TW_MED)
	tw(cardStroke,{Color=Color3.fromRGB(90,50,170),Transparency=0.4},TW_MED)
	rarTag.Visible=false
end

local function updateStreak()
	if rollStreak>=3 then
		streakLbl.Text="🔥 Streak "..rollStreak.."x — Legendary chance naik!"
		streakLbl.TextColor3=Color3.fromRGB(255,185,40)
	elseif rollStreak>0 then
		streakLbl.Text="Skip streak: "..rollStreak.."x"
		streakLbl.TextColor3=Color3.fromRGB(190,190,190)
	else streakLbl.Text="" end
end

rollBtn.MouseButton1Click:Connect(function()
	if isRolling or waitingChoice then return end
	if #activeSkills>=MAX_SLOTS then
		skillTitle.Text="⚠️ Slot penuh!"; skillDesc.Text="Remove skill dulu (hover slot)."
		return
	end
	isRolling=true
	tw(rollBtn,{BackgroundColor3=Color3.fromRGB(55,32,115)},TW_FAST)
	rollBtn.Text="Rolling..."
	skillTitle.Text="Rolling..."; skillDesc.Text=""; flavorLbl.Text=""; rarTag.Visible=false
	soundEnabled=getSound(); playSound("roll")
	local elapsed,interval=0,0.07
	while elapsed<1.4 do
		diceEmoji.Text=DICE_FACES[math.random(1,6)]
		task.wait(interval); elapsed=elapsed+interval; interval=math.min(interval+0.013,0.22)
	end
	local excList={}
	for id in pairs(activeIds) do table.insert(excList,id) end
	local skill=pickSkill(excList, rollStreak>=3 and rollStreak or nil)
	tw(rollBtn,{BackgroundColor3=Color3.fromRGB(100,48,205)},TW_FAST)
	rollBtn.Text="🎲  ROLL THE DICE"; isRolling=false
	if not skill then
		diceEmoji.Text="😵"; skillTitle.Text="Semua skill aktif!"
		skillDesc.Text="Clear dulu beberapa skill."; return
	end
	diceEmoji.Text=skill.icon
	showChoice(skill)
end)

useBtn.MouseButton1Click:Connect(function()
	if not pendingSkill then return end
	local skill=pendingSkill
	local ok,err=pcall(skill.apply)
	if ok then
		table.insert(activeSkills,{skill=skill}); activeIds[skill.id]=true
		rollStreak=0; updateStreak(); rebuildSlots(); buildTradeSkillPicker()
		table.insert(rollHistory,1,{skill=skill,used=true})
		if #rollHistory>MAX_HISTORY then table.remove(rollHistory) end
		refreshHistory()
		skillTitle.Text="✅ "..skill.name; skillTitle.TextColor3=rC(skill.rarity)
		skillDesc.Text="Aktif!"..(serverMode and " 🌐" or " 💻"); flavorLbl.Text=skill.flavor or ""
		soundEnabled=getSound(); playSound("use")
	else
		skillTitle.Text="❌ Error!"; skillDesc.Text=tostring(err)
		skillTitle.TextColor3=Color3.fromRGB(255,90,90)
		warn("[DiceCore] Error apply:",err)
	end
	hideChoice()
end)

skipBtn.MouseButton1Click:Connect(function()
	if not pendingSkill then return end
	table.insert(rollHistory,1,{skill=pendingSkill,used=false})
	if #rollHistory>MAX_HISTORY then table.remove(rollHistory) end
	refreshHistory()
	rollStreak=rollStreak+1; updateStreak()
	skillTitle.Text="Roll the dice!"; skillTitle.TextColor3=Color3.fromRGB(220,190,255)
	skillDesc.Text="Dilewatin! Roll lagi."; flavorLbl.Text=""; diceEmoji.Text="🎲"
	soundEnabled=getSound(); playSound("skip")
	hideChoice()
end)

clearBtn.MouseButton1Click:Connect(function()
	for _,e in ipairs(activeSkills) do pcall(e.skill.remove) end
	if serverMode and REMOTE then pcall(function() REMOTE:FireServer("ClearAll","") end) end
	for k in pairs(Connections) do removeConn(k) end
	activeSkills={}; activeIds={}; rollStreak=0; updateStreak()
	rebuildSlots(); buildTradeSkillPicker()
	local c=player.Character
	if c then
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and OriginalSizes[p.Name] then pcall(function() p.Size=OriginalSizes[p.Name] end) end
		end
		local h2=c:FindFirstChildOfClass("Humanoid")
		if h2 then h2.WalkSpeed=16; h2.JumpPower=50 end
	end
	workspace.Gravity=196.2
	skillTitle.Text="Roll the dice!"; skillTitle.TextColor3=Color3.fromRGB(220,190,255)
	skillDesc.Text="Semua skill di-reset!"; flavorLbl.Text=""; diceEmoji.Text="🎲"
end)

-- ══════════════════════════════════════════════
--  CHECK SERVER
-- ══════════════════════════════════════════════
checkBtn.MouseButton1Click:Connect(function()
	checkBtn.Text="⏳ Mencari FREEDICE..."
	tw(checkBtn,{BackgroundColor3=Color3.fromRGB(35,35,55)},TW_FAST)
	task.wait(1.2)
	local found=checkServer(); checkDone=true
	checkBtn.Visible=false
	if found then
		serverBadge.Text="🌐 SERVER MODE"
		tw(serverBadge,{BackgroundColor3=Color3.fromRGB(18,85,42)},TW_FAST)
		serverBadge.TextColor3=Color3.fromRGB(90,245,145)
		skillDesc.Text="Server aktif! Efek keliatan semua 🌐"
		-- Connect trade remote
		if TRADE_REMOTE then
			TRADE_REMOTE.OnClientEvent:Connect(function(action,...)
				local args={...}
				if action=="IncomingOffer" then
					local from,data=args[1],args[2]; pendingOffer=data
					tnTitle.Text="🤝 Trade dari "..from.."!"
					tnDesc.Text=data.skillIcon.." "..data.skillName.." ("..data.skillRarity..")"
					tradeNotif.Visible=true
					tw(tradeNotif,{Position=UDim2.new(0.5,-160,1,-120)},TW_BACK)
					soundEnabled=getSound(); playSound("trade")
				elseif action=="TradeAccepted" then
					local who,data=args[1],args[2]
					for i,e in ipairs(activeSkills) do
						if e.skill.id==data.skillId then
							pcall(e.skill.remove); table.remove(activeSkills,i); activeIds[data.skillId]=nil; break
						end
					end
					rebuildSlots(); buildTradeSkillPicker()
					tradeStatus.Text="✅ "..who.." menerima trade!"
				elseif action=="TradeComplete" then
					local data=args[1]
					for _,sk in ipairs(Skills) do
						if sk.id==data.skillId and #activeSkills<MAX_SLOTS then
							pcall(sk.apply); table.insert(activeSkills,{skill=sk}); activeIds[sk.id]=true
							rebuildSlots(); buildTradeSkillPicker()
							skillTitle.Text="🎁 Dapat "..sk.name.." dari trade!"
							skillTitle.TextColor3=rC(sk.rarity); break
						end
					end
				elseif action=="TradeDeclined" then
					tradeStatus.Text="❌ "..args[1].." menolak trade."
				end
			end)
		end
	else
		serverBadge.Text="💻 LOCAL ONLY"
		tw(serverBadge,{BackgroundColor3=Color3.fromRGB(75,48,18)},TW_FAST)
		serverBadge.TextColor3=Color3.fromRGB(255,170,65)
		skillDesc.Text="No server. Efek local only 💻"
	end
end)

-- ══════════════════════════════════════════════
--  SETTINGS ACTIONS
-- ══════════════════════════════════════════════
togTrade.MouseButton1Click:Connect(function()
	task.wait(0.05)
	tradeEnabled=getTrade()
	tradeLocked.Visible=not tradeEnabled
	tradePanel.Visible=tradeEnabled
	if tradeEnabled then buildPlayerList(); buildTradeSkillPicker() end
end)

giveBtn.MouseButton1Click:Connect(function()
	if not serverMode or not GIVE_REMOTE then
		settNote.Text="❌ Butuh server support! Check server dulu."
		tw(settNote,{TextColor3=Color3.fromRGB(215,75,75)},TW_FAST)
		task.wait(2)
		settNote.Text="⚠️ Give All & Trade butuh Server Support aktif.\nCheck server dulu di tab 🎲 Roll."
		tw(settNote,{TextColor3=Color3.fromRGB(175,135,75)},TW_FAST)
		return
	end
	pcall(function() GIVE_REMOTE:FireServer("GiveAll") end)
	giveBtn.Text="✅ GUI Terbroadcast!"
	tw(giveBtn,{BackgroundColor3=Color3.fromRGB(28,120,62)},TW_FAST)
	task.wait(3)
	giveBtn.Text="📡  Broadcast GUI ke Semua Player"
	tw(giveBtn,{BackgroundColor3=Color3.fromRGB(35,95,195)},TW_FAST)
end)

-- ══════════════════════════════════════════════
--  TRADE ACTIONS
-- ══════════════════════════════════════════════
sendTradeBtn.MouseButton1Click:Connect(function()
	if not serverMode or not TRADE_REMOTE then
		tradeStatus.Text="❌ Butuh server support!"; return
	end
	if not selectedTarget then tradeStatus.Text="⚠️ Pilih player dulu!"; return end
	if not selectedSkill  then tradeStatus.Text="⚠️ Pilih skill dulu!"; return end
	pcall(function()
		TRADE_REMOTE:FireServer("Offer", selectedTarget, {
			from=player.Name, skillId=selectedSkill.id,
			skillName=selectedSkill.name, skillIcon=selectedSkill.icon,
			skillRarity=selectedSkill.rarity,
		})
	end)
	tradeStatus.Text="📤 Offer terkirim ke "..selectedTarget.."!"
	soundEnabled=getSound(); playSound("trade")
end)

tnAccept.MouseButton1Click:Connect(function()
	if not pendingOffer or not TRADE_REMOTE then return end
	pcall(function() TRADE_REMOTE:FireServer("Accept", pendingOffer.from, pendingOffer) end)
	tradeNotif.Visible=false; pendingOffer=nil
end)
tnDecline.MouseButton1Click:Connect(function()
	if not pendingOffer or not TRADE_REMOTE then return end
	pcall(function() TRADE_REMOTE:FireServer("Decline", pendingOffer.from, pendingOffer) end)
	tradeNotif.Visible=false; pendingOffer=nil
end)

-- ══════════════════════════════════════════════
--  HOVER EFFECTS
-- ══════════════════════════════════════════════
local function hover(btn, n, h)
	btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=h},TW_FAST) end)
	btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=n},TW_FAST) end)
end
hover(rollBtn,   Color3.fromRGB(100,48,205),  Color3.fromRGB(130,72,255))
hover(useBtn,    Color3.fromRGB(50,175,90),   Color3.fromRGB(38,210,80))
hover(skipBtn,   Color3.fromRGB(180,55,55),   Color3.fromRGB(215,40,40))
hover(clearBtn,  Color3.fromRGB(40,28,65),    Color3.fromRGB(58,44,95))
hover(checkBtn,  Color3.fromRGB(22,65,145),   Color3.fromRGB(36,95,200))
hover(giveBtn,   Color3.fromRGB(35,95,195),   Color3.fromRGB(50,120,240))
hover(sendTradeBtn,Color3.fromRGB(45,120,215),Color3.fromRGB(65,148,255))

-- ══════════════════════════════════════════════
--  OPEN ANIMATION
-- ══════════════════════════════════════════════
win.Size=UDim2.new(0,0,0,0); win.Position=UDim2.new(0.5,0,0.5,0)
tabBar.Visible=false; pageRoll.Visible=false
task.wait(0.05)
tw(win,TW_BACK,{Size=UDim2.new(0,W,0,H),Position=UDim2.new(0.5,-W/2,0.5,-H/2)})
task.wait(0.35); tabBar.Visible=true; pageRoll.Visible=true

print("[DiceCore v5.1] ✅ Loaded!")
print("  Tabs: 🎲 Roll | 📜 History | 🤝 Trade | ⚙️ Settings")
print("  Server: Klik CHECK SERVER untuk detect")
