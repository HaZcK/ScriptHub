-- ╔══════════════════════════════════════════════════════╗
-- ║            DICE OF FATE  —  DiceCore v6              ║
-- ║   Clean rebuild: No sound, fixed tween, all buttons  ║
-- ╚══════════════════════════════════════════════════════╝

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")

-- ══════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════
local Conns = {}
local function saveConn(k, c)
	if Conns[k] then pcall(function() Conns[k]:Disconnect() end) end
	Conns[k] = c
end
local function dropConn(k)
	if Conns[k] then pcall(function() Conns[k]:Disconnect() end) Conns[k] = nil end
end

local OrigSize = {}
for _, p in ipairs(character:GetDescendants()) do
	if p:IsA("BasePart") then OrigSize[p.Name] = p.Size end
end

local function getChar()
	character = player.Character or character
	humanoid  = character and character:FindFirstChildOfClass("Humanoid") or humanoid
	return character, humanoid
end

-- Tween helper — urutan SELALU (object, properties, tweenInfo)
local TI_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
local TI_MED  = TweenInfo.new(0.28, Enum.EasingStyle.Quart)
local TI_BACK = TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local function T(obj, props, ti)
	TweenService:Create(obj, ti or TI_MED, props):Play()
end

-- ══════════════════════════════════════════════
--  SERVER
-- ══════════════════════════════════════════════
local serverMode  = false
local R_ACTION    = nil
local R_TRADE     = nil
local R_GIVE      = nil

local function checkServer()
	local ping = ReplicatedStorage:FindFirstChild("DICE_PING")
	if ping and ping:IsA("RemoteFunction") then
		local ok, res = pcall(function() return ping:InvokeServer() end)
		if ok and res == true then
			serverMode = true
			R_ACTION   = ReplicatedStorage:FindFirstChild("DICE_ACTION")
			R_TRADE    = ReplicatedStorage:FindFirstChild("DICE_TRADE")
			R_GIVE     = ReplicatedStorage:FindFirstChild("DICE_GIVEGUI")
			return true
		end
	end
	serverMode = false
	return false
end

local function fireAction(action, data)
	if serverMode and R_ACTION then
		pcall(function() R_ACTION:FireServer(action, data) end)
	end
end

-- ══════════════════════════════════════════════
--  RARITY
-- ══════════════════════════════════════════════
local RAR = {
	Common    = { col=Color3.fromRGB(180,180,180), glow=Color3.fromRGB(210,210,210), w=50 },
	Rare      = { col=Color3.fromRGB(80,140,255),  glow=Color3.fromRGB(120,180,255), w=30 },
	Epic      = { col=Color3.fromRGB(180,80,255),  glow=Color3.fromRGB(210,120,255), w=15 },
	Legendary = { col=Color3.fromRGB(255,180,0),   glow=Color3.fromRGB(255,220,80),  w=5  },
}
local RICON = { Common="⚪", Rare="🔵", Epic="🟣", Legendary="🟡" }
local function rc(r)  return RAR[r] and RAR[r].col  or Color3.fromRGB(200,200,200) end
local function rg(r)  return RAR[r] and RAR[r].glow or Color3.fromRGB(200,200,200) end

-- ══════════════════════════════════════════════
--  SKILL DATABASE
-- ══════════════════════════════════════════════
--
--  CARA TAMBAH CUSTOM SKILL:
--  1. Copy blok skill di bawah (antara { ... },)
--  2. Ganti id, name, icon, rarity, desc, flavor
--  3. Isi apply() dan remove()
--  4. Tambahkan entry yang sama di DiceServer.lua
--     SkillRegistry["id_kamu"] = { apply=..., remove=... }
--
local SKILLS = {

	-- ══ COMMON ══
	{
		id="speed_demon", name="Speed Demon", icon="💨", rarity="Common",
		desc="WalkSpeed jadi 100. Ngebut banget!",
		flavor="Angin aja kalah.",
		apply  = function() local c,h=getChar(); h.WalkSpeed=100;  fireAction("Apply","speed_demon")  end,
		remove = function() local c,h=getChar(); h.WalkSpeed=16;   fireAction("Remove","speed_demon") end,
	},
	{
		id="super_jump", name="Super Jump", icon="🚀", rarity="Common",
		desc="JumpPower jadi 200. Bisa nyentuh langit!",
		flavor="Gravity? Belum kenal.",
		apply  = function() local c,h=getChar(); h.JumpPower=200; fireAction("Apply","super_jump")  end,
		remove = function() local c,h=getChar(); h.JumpPower=50;  fireAction("Remove","super_jump") end,
	},
	{
		id="giant_head", name="Giant Head", icon="🗿", rarity="Common",
		desc="Kepala jadi 5x lebih gede.",
		flavor="Braincell makin banyak.",
		apply = function()
			local c,h = getChar()
			local head = c:FindFirstChild("Head")
			if head then head.Size = Vector3.new(5,5,5) end
			fireAction("Apply","giant_head")
		end,
		remove = function()
			local c,h = getChar()
			local head = c:FindFirstChild("Head")
			if head and OrigSize["Head"] then head.Size = OrigSize["Head"] end
			fireAction("Remove","giant_head")
		end,
	},
	{
		id="tiny_legs", name="Tiny Legs", icon="🦵", rarity="Common",
		desc="Kaki mengecil drastis. Lucu banget.",
		flavor="Kaki kamu mana??",
		apply = function()
			local c,h = getChar()
			for _,n in ipairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do
				local p=c:FindFirstChild(n); if p then p.Size=Vector3.new(0.4,0.4,0.4) end
			end
			fireAction("Apply","tiny_legs")
		end,
		remove = function()
			local c,h = getChar()
			for _,n in ipairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do
				local p=c:FindFirstChild(n); if p and OrigSize[n] then p.Size=OrigSize[n] end
			end
			fireAction("Remove","tiny_legs")
		end,
	},
	{
		id="buff_arms", name="Buff Arms", icon="💪", rarity="Common",
		desc="Lengan super gede. Siap tinju meteor.",
		flavor="Arms day everyday.",
		apply = function()
			local c,h = getChar()
			for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
				local p=c:FindFirstChild(n); if p then p.Size=Vector3.new(2.5,2.5,2.5) end
			end
			fireAction("Apply","buff_arms")
		end,
		remove = function()
			local c,h = getChar()
			for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
				local p=c:FindFirstChild(n); if p and OrigSize[n] then p.Size=OrigSize[n] end
			end
			fireAction("Remove","buff_arms")
		end,
	},
	{
		id="noodle_arms", name="Noodle Arms", icon="🍜", rarity="Common",
		desc="Lengan super panjang menjuntai.",
		flavor="Nyampe lantai dari berdiri.",
		apply = function()
			local c,h = getChar()
			for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
				local p=c:FindFirstChild(n); if p then p.Size=Vector3.new(0.3,3.5,0.3) end
			end
			fireAction("Apply","noodle_arms")
		end,
		remove = function()
			local c,h = getChar()
			for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
				local p=c:FindFirstChild(n); if p and OrigSize[n] then p.Size=OrigSize[n] end
			end
			fireAction("Remove","noodle_arms")
		end,
	},
	{
		id="phantom", name="Phantom Mode", icon="👻", rarity="Common",
		desc="Badan transparan 80%. Kayak hantu!",
		flavor="Boo!",
		apply = function()
			local c,h = getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency=0.8 end
			end
			fireAction("Apply","phantom")
		end,
		remove = function()
			local c,h = getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Transparency=0 end
			end
			fireAction("Remove","phantom")
		end,
	},
	{
		id="golden_skin", name="Golden Touch", icon="✨", rarity="Common",
		desc="Seluruh badan jadi emas berkilau.",
		flavor="Midas wishes.",
		apply = function()
			local c,h = getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
					p.BrickColor=BrickColor.new("Bright yellow")
				end
			end
			fireAction("Apply","golden_skin")
		end,
		remove = function()
			local c,h = getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Color=Color3.fromRGB(163,162,165) end
			end
			fireAction("Remove","golden_skin")
		end,
	},

	-- ══ RARE ══
	{
		id="rainbow_body", name="Rainbow Body", icon="🌈", rarity="Rare",
		desc="Warna badan berubah pelangi nonstop.",
		flavor="Serotonin overload.",
		apply = function()
			fireAction("Apply","rainbow_body")
			if not serverMode then
				saveConn("rainbow", RunService.Heartbeat:Connect(function()
					local t = tick()
					local c2 = player.Character; if not c2 then return end
					for _,p in ipairs(c2:GetDescendants()) do
						if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
							p.Color = Color3.fromHSV((t*0.5 + p.Name:len()*0.05) % 1, 1, 1)
						end
					end
				end))
			end
		end,
		remove = function()
			dropConn("rainbow")
			local c,h = getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Color=Color3.fromRGB(163,162,165) end
			end
			fireAction("Remove","rainbow_body")
		end,
	},
	{
		id="anti_gravity", name="Anti Gravity", icon="🪐", rarity="Rare",
		desc="Gravitasi berkurang. Lompat terasa melayang.",
		flavor="Space walk vibes.",
		apply = function()
			local c,h = getChar(); h.JumpPower=150
			local hrp = c:FindFirstChild("HumanoidRootPart")
			if hrp then
				local old = hrp:FindFirstChild("_AG"); if old then old:Destroy() end
				local bf = Instance.new("BodyForce")
				bf.Name="_AG"; bf.Force=Vector3.new(0, workspace.Gravity*hrp:GetMass()*0.75, 0); bf.Parent=hrp
			end
			fireAction("Apply","anti_gravity")
		end,
		remove = function()
			local c,h = getChar(); h.JumpPower=50
			local hrp = c:FindFirstChild("HumanoidRootPart")
			if hrp then local bf=hrp:FindFirstChild("_AG"); if bf then bf:Destroy() end end
			fireAction("Remove","anti_gravity")
		end,
	},
	{
		id="ice_body", name="Frozen Soul", icon="🧊", rarity="Rare",
		desc="Badan jadi es transparan biru dingin.",
		flavor="Dingin sampai jiwa.",
		apply = function()
			local c,h = getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
					p.BrickColor=BrickColor.new("Pastel blue"); p.Material=Enum.Material.Ice; p.Transparency=0.35
				end
			end
			fireAction("Apply","ice_body")
		end,
		remove = function()
			local c,h = getChar()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Material=Enum.Material.SmoothPlastic; p.Transparency=0 end
			end
			fireAction("Remove","ice_body")
		end,
	},
	{
		id="lava_trail", name="Lava Trail", icon="🔥", rarity="Rare",
		desc="Ninggalin jejak api saat berjalan.",
		flavor="Floor is literally lava.",
		apply = function()
			fireAction("Apply","lava_trail")
			if not serverMode then
				local last = 0
				saveConn("lava", RunService.Heartbeat:Connect(function()
					local now = tick(); if now-last < 0.15 then return end
					local c2=player.Character; local h2=c2 and c2:FindFirstChildOfClass("Humanoid")
					local hrp=c2 and c2:FindFirstChild("HumanoidRootPart")
					if not hrp or not h2 or h2.MoveDirection.Magnitude<0.1 then return end
					last = now
					local f=Instance.new("Part"); f.Size=Vector3.new(1.5,0.2,1.5)
					f.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3,0))
					f.Anchored=true; f.CanCollide=false
					f.BrickColor=BrickColor.new("Bright orange"); f.Material=Enum.Material.Neon; f.Parent=workspace
					local fi=Instance.new("Fire",f); fi.Heat=8; fi.Size=5
					game:GetService("Debris"):AddItem(f,2)
				end))
			end
		end,
		remove = function()
			dropConn("lava"); fireAction("Remove","lava_trail")
		end,
	},
	{
		id="spinning_head", name="Spinning Head", icon="🌀", rarity="Rare",
		desc="Kepala muter nonstop. Pusing lihatnya.",
		flavor="360 no scope.",
		apply = function()
			fireAction("Apply","spinning_head")
			if not serverMode then
				saveConn("spin", RunService.Heartbeat:Connect(function(dt)
					local c2=player.Character; if not c2 then return end
					local head=c2:FindFirstChild("Head")
					if head then head.CFrame=head.CFrame*CFrame.Angles(0,math.rad(300*dt),0) end
				end))
			end
		end,
		remove = function()
			dropConn("spin"); fireAction("Remove","spinning_head")
		end,
	},

	-- ══ EPIC ══
	{
		id="ant_size", name="Ant Size", icon="🐜", rarity="Epic",
		desc="Tubuh mengecil jadi 0.3x ukuran normal.",
		flavor="Siapa kamu? Mana kamu?",
		apply = function()
			local c,h = getChar(); h.WalkSpeed=10
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Size=p.Size*0.3 end
			end
			fireAction("Apply","ant_size")
		end,
		remove = function()
			local c,h = getChar(); h.WalkSpeed=16
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and OrigSize[p.Name] then p.Size=OrigSize[p.Name] end
			end
			fireAction("Remove","ant_size")
		end,
	},
	{
		id="giant_mode", name="Giant Mode", icon="🏔️", rarity="Epic",
		desc="Tumbuh jadi raksasa 3x ukuran.",
		flavor="Fee-fi-fo-fum.",
		apply = function()
			local c,h = getChar(); h.WalkSpeed=24; h.JumpPower=80
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Size=p.Size*3 end
			end
			fireAction("Apply","giant_mode")
		end,
		remove = function()
			local c,h = getChar(); h.WalkSpeed=16; h.JumpPower=50
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and OrigSize[p.Name] then p.Size=OrigSize[p.Name] end
			end
			fireAction("Remove","giant_mode")
		end,
	},
	{
		id="backwards_brain", name="Backwards Brain", icon="🔄", rarity="Epic",
		desc="Kamera terbalik 180°. Maju jadi mundur.",
		flavor="Lain di mulut lain di hati.",
		apply = function()
			local cam = workspace.CurrentCamera
			cam.CameraType = Enum.CameraType.Scriptable
			saveConn("cam", RunService.Heartbeat:Connect(function()
				local c2=player.Character; if not c2 then return end
				local hrp=c2:FindFirstChild("HumanoidRootPart")
				if hrp then
					cam.CFrame = CFrame.new(hrp.Position+Vector3.new(0,6,14)) * CFrame.Angles(-0.12,math.pi,0)
				end
			end))
		end,
		remove = function()
			dropConn("cam"); workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
		end,
	},
	{
		id="magnet_body", name="Magnet Body", icon="🧲", rarity="Epic",
		desc="Benda-benda sekitar tertarik ke kamu.",
		flavor="Personal gravitational field.",
		apply = function()
			fireAction("Apply","magnet_body")
			if not serverMode then
				saveConn("magnet", RunService.Heartbeat:Connect(function()
					local c2=player.Character; if not c2 then return end
					local hrp=c2:FindFirstChild("HumanoidRootPart"); if not hrp then return end
					for _,obj in ipairs(workspace:GetChildren()) do
						if obj:IsA("BasePart") and not obj.Anchored and obj~=hrp and not c2:IsAncestorOf(obj) then
							local d=(obj.Position-hrp.Position).Magnitude
							if d<25 and d>0.1 then
								obj.AssemblyLinearVelocity = obj.AssemblyLinearVelocity
									+ (hrp.Position-obj.Position).Unit*(180/d)
							end
						end
					end
				end))
			end
		end,
		remove = function()
			dropConn("magnet"); fireAction("Remove","magnet_body")
		end,
	},

	-- ══ LEGENDARY ══
	{
		id="time_warp", name="Time Warp", icon="⏳", rarity="Legendary",
		desc="Gravitasi drop ke 20. Kamu tetap kenceng.",
		flavor="LEGENDARY — Waktu itu relatif.",
		apply = function()
			local c,h=getChar(); workspace.Gravity=20; h.WalkSpeed=80; h.JumpPower=120
			fireAction("Apply","time_warp")
		end,
		remove = function()
			local c,h=getChar(); workspace.Gravity=196.2; h.WalkSpeed=16; h.JumpPower=50
			fireAction("Remove","time_warp")
		end,
	},
	{
		id="god_mode", name="God Mode", icon="⚡", rarity="Legendary",
		desc="Speed + Jump + Giant Head + Rainbow Neon.",
		flavor="LEGENDARY — Pure chaos.",
		apply = function()
			local c,h=getChar(); h.WalkSpeed=80; h.JumpPower=180
			local head=c:FindFirstChild("Head"); if head then head.Size=Vector3.new(5,5,5) end
			fireAction("Apply","god_mode")
			if not serverMode then
				saveConn("god", RunService.Heartbeat:Connect(function()
					local t=tick(); local c2=player.Character; if not c2 then return end
					for _,p in ipairs(c2:GetDescendants()) do
						if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
							p.Color=Color3.fromHSV((t*1.5+p.Name:len()*0.1)%1,1,1)
							p.Material=Enum.Material.Neon
						end
					end
				end))
			end
		end,
		remove = function()
			dropConn("god")
			local c,h=getChar(); h.WalkSpeed=16; h.JumpPower=50
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Material=Enum.Material.SmoothPlastic; p.Color=Color3.fromRGB(163,162,165) end
			end
			local head=c:FindFirstChild("Head")
			if head and OrigSize["Head"] then head.Size=OrigSize["Head"] end
			fireAction("Remove","god_mode")
		end,
	},

	--[[ ════════════════════════════════════════════
	  CUSTOM SKILL TEMPLATE — copy blok ini!

	{
		id      = "nama_unik",        -- harus sama di DiceServer
		name    = "Nama Skill",
		icon    = "🎯",
		rarity  = "Common",           -- Common | Rare | Epic | Legendary
		desc    = "Deskripsi singkat.",
		flavor  = "Kalimat keren.",
		apply = function()
			local c, h = getChar()
			-- efek di sini
			h.WalkSpeed = 50
			fireAction("Apply", "nama_unik")
		end,
		remove = function()
			local c, h = getChar()
			-- reset di sini
			h.WalkSpeed = 16
			fireAction("Remove", "nama_unik")
		end,
	},
	════════════════════════════════════════════ --]]
}

local function pickSkill(excIds, bonus)
	local excSet = {}
	for _,id in ipairs(excIds or {}) do excSet[id]=true end
	local pool = {}
	for _,sk in ipairs(SKILLS) do
		if not excSet[sk.id] then
			local w = RAR[sk.rarity].w
			if sk.rarity=="Legendary" and bonus then w=w+bonus*4 end
			for _=1,w do table.insert(pool,sk) end
		end
	end
	return #pool>0 and pool[math.random(1,#pool)] or nil
end

-- ══════════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════════
local activeSkills  = {}   -- { skill }
local activeIds     = {}
local history       = {}   -- { skill, used }
local isRolling     = false
local waiting       = false
local pendingSkill  = nil
local streak        = 0
local checkDone     = false
local MAX_SLOTS     = 5

-- ══════════════════════════════════════════════
--  GUI  —  Window dimensions
-- ══════════════════════════════════════════════
local W, H = 420, 680

local old = player.PlayerGui:FindFirstChild("DiceGui")
if old then old:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name="DiceGui"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=player.PlayerGui

-- ── Window frame ──
local win = Instance.new("Frame", SG)
win.Size=UDim2.new(0,W,0,H)
win.Position=UDim2.new(0.5,-W/2, 0.5,-H/2)
win.BackgroundColor3=Color3.fromRGB(12,10,20)
win.BorderSizePixel=0; win.ClipsDescendants=true
Instance.new("UICorner",win).CornerRadius=UDim.new(0,16)
local winS=Instance.new("UIStroke",win)
winS.Color=Color3.fromRGB(85,48,165); winS.Thickness=2; winS.Transparency=0.35

-- ── Title bar ──
local tbar = Instance.new("Frame",win)
tbar.Size=UDim2.new(1,0,0,48)
tbar.Position=UDim2.new(0,0,0,0)
tbar.BackgroundColor3=Color3.fromRGB(17,13,32)
tbar.BorderSizePixel=0; tbar.ZIndex=10
Instance.new("UICorner",tbar).CornerRadius=UDim.new(0,16)
-- plug bottom round corners
local tbarBot=Instance.new("Frame",tbar)
tbarBot.Size=UDim2.new(1,0,0,16); tbarBot.Position=UDim2.new(0,0,1,-16)
tbarBot.BackgroundColor3=Color3.fromRGB(17,13,32); tbarBot.BorderSizePixel=0; tbarBot.ZIndex=10

local titleLbl=Instance.new("TextLabel",tbar)
titleLbl.Size=UDim2.new(1,-170,1,0); titleLbl.Position=UDim2.new(0,14,0,0)
titleLbl.BackgroundTransparency=1; titleLbl.Text="🎲  DICE OF FATE"
titleLbl.TextColor3=Color3.fromRGB(200,155,255); titleLbl.Font=Enum.Font.GothamBold
titleLbl.TextSize=15; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.ZIndex=11

local badge=Instance.new("TextLabel",tbar)
badge.Size=UDim2.new(0,94,0,24); badge.Position=UDim2.new(1,-154,0.5,-12)
badge.BackgroundColor3=Color3.fromRGB(28,28,28); badge.Text="⚫ OFFLINE"
badge.TextSize=10; badge.Font=Enum.Font.GothamBold
badge.TextColor3=Color3.fromRGB(140,140,140); badge.BorderSizePixel=0; badge.ZIndex=11
Instance.new("UICorner",badge).CornerRadius=UDim.new(0,6)

local function ctrlBtn(xOff, bg, lbl)
	local b=Instance.new("TextButton",tbar)
	b.Size=UDim2.new(0,24,0,24); b.Position=UDim2.new(1,xOff,0.5,-12)
	b.BackgroundColor3=bg; b.Text=lbl; b.TextColor3=Color3.fromRGB(255,255,255)
	b.TextSize=12; b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0; b.ZIndex=11
	Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
	return b
end
local btnClose = ctrlBtn(-30, Color3.fromRGB(205,58,68), "✕")
local btnMin   = ctrlBtn(-58, Color3.fromRGB(225,145,18), "─")

-- ── Tab bar ──
local tabBar=Instance.new("Frame",win)
tabBar.Size=UDim2.new(1,-24,0,36); tabBar.Position=UDim2.new(0,12,0,54)
tabBar.BackgroundColor3=Color3.fromRGB(17,13,30); tabBar.BorderSizePixel=0; tabBar.ZIndex=9
Instance.new("UICorner",tabBar).CornerRadius=UDim.new(0,10)
local tabLL=Instance.new("UIListLayout",tabBar)
tabLL.FillDirection=Enum.FillDirection.Horizontal
tabLL.HorizontalAlignment=Enum.HorizontalAlignment.Center
tabLL.VerticalAlignment=Enum.VerticalAlignment.Center
tabLL.Padding=UDim.new(0,4)
local tPad=Instance.new("UIPadding",tabBar); tPad.PaddingLeft=UDim.new(0,5); tPad.PaddingRight=UDim.new(0,5)

local function mkTab(label, active)
	local b=Instance.new("TextButton",tabBar)
	b.Size=UDim2.new(0,88,0,28)
	b.BackgroundColor3=active and Color3.fromRGB(90,44,195) or Color3.fromRGB(26,20,42)
	b.Text=label; b.Font=Enum.Font.GothamBold; b.TextSize=11; b.BorderSizePixel=0
	b.TextColor3=active and Color3.fromRGB(255,255,255) or Color3.fromRGB(125,105,165)
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
	return b
end
local tRoll=mkTab("🎲 Roll",    true)
local tHist=mkTab("📜 History", false)
local tTrad=mkTab("🤝 Trade",   false)
local tSett=mkTab("⚙️ Settings",false)

-- ── Pages (content area below tabs) ──
local PY = 98  -- page start Y
local PH = H - PY - 10

local function mkPage()
	local f=Instance.new("Frame",win)
	f.Size=UDim2.new(1,-24,0,PH); f.Position=UDim2.new(0,12,0,PY)
	f.BackgroundTransparency=1; f.Visible=false; f.ClipsDescendants=false
	return f
end
local pageRoll = mkPage(); pageRoll.Visible=true
local pageHist = mkPage()
local pageTrad = mkPage()
local pageSett = mkPage()

local PAGES={pageRoll,pageHist,pageTrad,pageSett}
local TABS={tRoll,tHist,tTrad,tSett}

local function goTab(n)
	for i,pg in ipairs(PAGES) do
		pg.Visible=(i==n)
		local on=(i==n)
		T(TABS[i],{
			BackgroundColor3=on and Color3.fromRGB(90,44,195) or Color3.fromRGB(26,20,42),
			TextColor3=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(125,105,165)
		},TI_FAST)
	end
end
tRoll.MouseButton1Click:Connect(function() goTab(1) end)
tHist.MouseButton1Click:Connect(function() goTab(2) end)
tTrad.MouseButton1Click:Connect(function() goTab(3) end)
tSett.MouseButton1Click:Connect(function() goTab(4) end)

-- ════════════════════════════════════════════════
--  PAGE 1 — ROLL
-- ════════════════════════════════════════════════

-- Skill card
local card=Instance.new("Frame",pageRoll)
card.Size=UDim2.new(1,0,0,150); card.Position=UDim2.new(0,0,0,0)
card.BackgroundColor3=Color3.fromRGB(15,11,26); card.BorderSizePixel=0
Instance.new("UICorner",card).CornerRadius=UDim.new(0,14)
local cardS=Instance.new("UIStroke",card)
cardS.Color=Color3.fromRGB(85,48,165); cardS.Thickness=1.5; cardS.Transparency=0.4

-- dice box left
local diceBox=Instance.new("Frame",card)
diceBox.Size=UDim2.new(0,96,0,96); diceBox.Position=UDim2.new(0,12,0.5,-48)
diceBox.BackgroundColor3=Color3.fromRGB(20,15,40); diceBox.BorderSizePixel=0
Instance.new("UICorner",diceBox).CornerRadius=UDim.new(0,14)
local diceS=Instance.new("UIStroke",diceBox)
diceS.Color=Color3.fromRGB(125,75,235); diceS.Thickness=2; diceS.Transparency=0.4

local diceTxt=Instance.new("TextLabel",diceBox)
diceTxt.Size=UDim2.new(1,0,1,0); diceTxt.BackgroundTransparency=1
diceTxt.Text="🎲"; diceTxt.TextSize=48; diceTxt.Font=Enum.Font.Gotham

-- info right
local info=Instance.new("Frame",card)
info.Size=UDim2.new(1,-122,1,-12); info.Position=UDim2.new(0,118,0,6)
info.BackgroundTransparency=1

local rarLbl=Instance.new("TextLabel",info)
rarLbl.Size=UDim2.new(0,96,0,20); rarLbl.Position=UDim2.new(0,0,0,2)
rarLbl.BackgroundColor3=Color3.fromRGB(26,18,48); rarLbl.Text=""
rarLbl.TextSize=10; rarLbl.Font=Enum.Font.GothamBold
rarLbl.TextColor3=Color3.fromRGB(200,175,255); rarLbl.BorderSizePixel=0; rarLbl.Visible=false
Instance.new("UICorner",rarLbl).CornerRadius=UDim.new(0,6)

local nameLbl=Instance.new("TextLabel",info)
nameLbl.Size=UDim2.new(1,0,0,24); nameLbl.Position=UDim2.new(0,0,0,26)
nameLbl.BackgroundTransparency=1; nameLbl.Text="Roll the dice!"
nameLbl.TextColor3=Color3.fromRGB(215,185,255); nameLbl.Font=Enum.Font.GothamBold
nameLbl.TextSize=15; nameLbl.TextXAlignment=Enum.TextXAlignment.Left

local descLbl=Instance.new("TextLabel",info)
descLbl.Size=UDim2.new(1,0,0,36); descLbl.Position=UDim2.new(0,0,0,54)
descLbl.BackgroundTransparency=1; descLbl.Text="Tekan ROLL untuk dapat skill acak!"
descLbl.TextColor3=Color3.fromRGB(140,120,180); descLbl.Font=Enum.Font.Gotham
descLbl.TextSize=12; descLbl.TextXAlignment=Enum.TextXAlignment.Left; descLbl.TextWrapped=true

local flavorLbl=Instance.new("TextLabel",info)
flavorLbl.Size=UDim2.new(1,0,0,18); flavorLbl.Position=UDim2.new(0,0,0,94)
flavorLbl.BackgroundTransparency=1; flavorLbl.Text=""
flavorLbl.TextColor3=Color3.fromRGB(90,75,125); flavorLbl.Font=Enum.Font.Gotham
flavorLbl.TextSize=11; flavorLbl.TextXAlignment=Enum.TextXAlignment.Left; flavorLbl.TextWrapped=true

-- ── Buttons layout ──
-- Y=158: CHECK btn  (full width, hidden after check done)
-- Y=158: USE + SKIP (half + half, hidden initially)
-- Y=206: ROLL btn   (full width)
-- Y=266: Streak     (label)
-- Y=290: Slots hdr  (label)
-- Y=308: Slots frame
-- Y=382: Clear btn

local function mkBtn(px,py,pw,ph, bg, txt, sz)
	local b=Instance.new("TextButton",pageRoll)
	b.Size=UDim2.new(pw,0,0,ph); b.Position=UDim2.new(px,0,0,py)
	b.BackgroundColor3=bg; b.Text=txt
	b.TextColor3=Color3.fromRGB(255,255,255); b.Font=Enum.Font.GothamBold
	b.TextSize=sz or 14; b.BorderSizePixel=0
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,12)
	return b
end

local checkBtn = mkBtn(0,158, 1,42, Color3.fromRGB(20,62,140), "🔍  CHECK SERVER", 13)
Instance.new("UIStroke",checkBtn).Color=Color3.fromRGB(50,110,245)

local useBtn  = mkBtn(0,   158, 0.48,42, Color3.fromRGB(48,170,88),  "✅  USE",  15)
local skipBtn = mkBtn(0.52,158, 0.48,42, Color3.fromRGB(175,52,52),  "⏭  SKIP", 15)
useBtn.Visible=false; skipBtn.Visible=false

local rollBtn = mkBtn(0,208, 1,52, Color3.fromRGB(95,44,200), "🎲  ROLL THE DICE", 17)
Instance.new("UIStroke",rollBtn).Color=Color3.fromRGB(160,100,255)

local streakLbl=Instance.new("TextLabel",pageRoll)
streakLbl.Size=UDim2.new(1,0,0,18); streakLbl.Position=UDim2.new(0,0,0,268)
streakLbl.BackgroundTransparency=1; streakLbl.Text=""
streakLbl.TextColor3=Color3.fromRGB(255,188,40); streakLbl.Font=Enum.Font.GothamBold
streakLbl.TextSize=12; streakLbl.TextXAlignment=Enum.TextXAlignment.Center

local slotsHdr=Instance.new("TextLabel",pageRoll)
slotsHdr.Size=UDim2.new(1,0,0,16); slotsHdr.Position=UDim2.new(0,0,0,294)
slotsHdr.BackgroundTransparency=1; slotsHdr.Text="ACTIVE SKILL SLOTS  [0/5]"
slotsHdr.TextColor3=Color3.fromRGB(95,75,145); slotsHdr.Font=Enum.Font.GothamBold
slotsHdr.TextSize=11; slotsHdr.TextXAlignment=Enum.TextXAlignment.Left

local slotsF=Instance.new("Frame",pageRoll)
slotsF.Size=UDim2.new(1,0,0,66); slotsF.Position=UDim2.new(0,0,0,314)
slotsF.BackgroundColor3=Color3.fromRGB(15,11,24); slotsF.BorderSizePixel=0
Instance.new("UICorner",slotsF).CornerRadius=UDim.new(0,12)
local sLL=Instance.new("UIListLayout",slotsF)
sLL.FillDirection=Enum.FillDirection.Horizontal; sLL.Padding=UDim.new(0,6)
sLL.VerticalAlignment=Enum.VerticalAlignment.Center
Instance.new("UIPadding",slotsF).PaddingLeft=UDim.new(0,8)

local clearBtn=mkBtn(0,388, 1,36, Color3.fromRGB(38,26,62), "🗑  Clear All Skills", 13)
clearBtn.TextColor3=Color3.fromRGB(160,128,200)

-- ════════════════════════════════════════════════
--  PAGE 2 — HISTORY
-- ════════════════════════════════════════════════
local histHdr=Instance.new("TextLabel",pageHist)
histHdr.Size=UDim2.new(1,0,0,22); histHdr.BackgroundTransparency=1
histHdr.Text="📜 Roll History (last 20)"; histHdr.TextColor3=Color3.fromRGB(190,160,245)
histHdr.Font=Enum.Font.GothamBold; histHdr.TextSize=14; histHdr.TextXAlignment=Enum.TextXAlignment.Left

local histSF=Instance.new("ScrollingFrame",pageHist)
histSF.Size=UDim2.new(1,0,1,-26); histSF.Position=UDim2.new(0,0,0,24)
histSF.BackgroundColor3=Color3.fromRGB(13,10,22); histSF.BorderSizePixel=0
histSF.ScrollBarThickness=4; histSF.ScrollBarImageColor3=Color3.fromRGB(85,48,165)
histSF.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",histSF).CornerRadius=UDim.new(0,12)
local hLL=Instance.new("UIListLayout",histSF); hLL.Padding=UDim.new(0,4)
local hPad=Instance.new("UIPadding",histSF)
hPad.PaddingTop=UDim.new(0,6); hPad.PaddingLeft=UDim.new(0,8); hPad.PaddingRight=UDim.new(0,8)

local function rebuildHistory()
	for _,c in ipairs(histSF:GetChildren()) do
		if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
	end
	if #history==0 then
		local e=Instance.new("TextLabel",histSF)
		e.Size=UDim2.new(1,-8,0,36); e.BackgroundTransparency=1
		e.Text="Belum ada history."; e.TextColor3=Color3.fromRGB(110,95,145)
		e.Font=Enum.Font.Gotham; e.TextSize=13; e.TextXAlignment=Enum.TextXAlignment.Center
		return
	end
	for _,ent in ipairs(history) do
		local row=Instance.new("Frame",histSF)
		row.Size=UDim2.new(1,-8,0,36); row.BackgroundColor3=Color3.fromRGB(19,15,32); row.BorderSizePixel=0
		Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
		local rs=Instance.new("UIStroke",row); rs.Color=rc(ent.skill.rarity); rs.Thickness=1; rs.Transparency=0.6
		local ic=Instance.new("TextLabel",row)
		ic.Size=UDim2.new(0,34,1,0); ic.BackgroundTransparency=1
		ic.Text=ent.skill.icon; ic.TextSize=18; ic.Font=Enum.Font.Gotham
		local nl=Instance.new("TextLabel",row)
		nl.Size=UDim2.new(1,-80,1,0); nl.Position=UDim2.new(0,34,0,0)
		nl.BackgroundTransparency=1; nl.Text=ent.skill.name
		nl.TextColor3=rc(ent.skill.rarity); nl.Font=Enum.Font.GothamBold
		nl.TextSize=13; nl.TextXAlignment=Enum.TextXAlignment.Left
		local st=Instance.new("TextLabel",row)
		st.Size=UDim2.new(0,54,1,0); st.Position=UDim2.new(1,-56,0,0)
		st.BackgroundTransparency=1
		st.Text=ent.used and "✅ Used" or "⏭ Skip"
		st.TextColor3=ent.used and Color3.fromRGB(75,205,115) or Color3.fromRGB(195,85,85)
		st.Font=Enum.Font.Gotham; st.TextSize=11
	end
	histSF.CanvasSize=UDim2.new(0,0,0,#history*40+10)
end
rebuildHistory()

-- ════════════════════════════════════════════════
--  PAGE 3 — TRADE
-- ════════════════════════════════════════════════
local tradeLockLbl=Instance.new("TextLabel",pageTrad)
tradeLockLbl.Size=UDim2.new(1,0,0,56); tradeLockLbl.Position=UDim2.new(0,0,0.32,0)
tradeLockLbl.BackgroundTransparency=1
tradeLockLbl.Text="🔒 Trade dinonaktifkan\nAktifkan di tab ⚙️ Settings"
tradeLockLbl.TextColor3=Color3.fromRGB(125,105,155); tradeLockLbl.Font=Enum.Font.Gotham
tradeLockLbl.TextSize=14; tradeLockLbl.TextXAlignment=Enum.TextXAlignment.Center; tradeLockLbl.TextWrapped=true

local tradePanel=Instance.new("Frame",pageTrad)
tradePanel.Size=UDim2.new(1,0,1,0); tradePanel.BackgroundTransparency=1; tradePanel.Visible=false

local tpHdr=Instance.new("TextLabel",tradePanel)
tpHdr.Size=UDim2.new(1,0,0,20); tpHdr.BackgroundTransparency=1
tpHdr.Text="🤝 Trade Skill ke Player Lain"
tpHdr.TextColor3=Color3.fromRGB(190,160,245); tpHdr.Font=Enum.Font.GothamBold
tpHdr.TextSize=13; tpHdr.TextXAlignment=Enum.TextXAlignment.Left

-- player list
local plrSF=Instance.new("ScrollingFrame",tradePanel)
plrSF.Size=UDim2.new(1,0,0,105); plrSF.Position=UDim2.new(0,0,0,26)
plrSF.BackgroundColor3=Color3.fromRGB(13,10,22); plrSF.BorderSizePixel=0
plrSF.ScrollBarThickness=4; plrSF.ScrollBarImageColor3=Color3.fromRGB(85,48,165)
plrSF.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",plrSF).CornerRadius=UDim.new(0,10)
local plrLL=Instance.new("UIListLayout",plrSF); plrLL.Padding=UDim.new(0,4)
local plrPad=Instance.new("UIPadding",plrSF)
plrPad.PaddingLeft=UDim.new(0,6); plrPad.PaddingTop=UDim.new(0,6)

local tskHdr=Instance.new("TextLabel",tradePanel)
tskHdr.Size=UDim2.new(1,0,0,16); tskHdr.Position=UDim2.new(0,0,0,138)
tskHdr.BackgroundTransparency=1; tskHdr.Text="Pilih skill yang mau di-trade:"
tskHdr.TextColor3=Color3.fromRGB(150,130,190); tskHdr.Font=Enum.Font.Gotham
tskHdr.TextSize=12; tskHdr.TextXAlignment=Enum.TextXAlignment.Left

local tskSF=Instance.new("ScrollingFrame",tradePanel)
tskSF.Size=UDim2.new(1,0,0,76); tskSF.Position=UDim2.new(0,0,0,158)
tskSF.BackgroundColor3=Color3.fromRGB(13,10,22); tskSF.BorderSizePixel=0
tskSF.ScrollBarThickness=4; tskSF.ScrollBarImageColor3=Color3.fromRGB(85,48,165)
tskSF.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",tskSF).CornerRadius=UDim.new(0,10)
local tskLL=Instance.new("UIListLayout",tskSF)
tskLL.FillDirection=Enum.FillDirection.Horizontal; tskLL.Padding=UDim.new(0,6)
tskLL.VerticalAlignment=Enum.VerticalAlignment.Center
Instance.new("UIPadding",tskSF).PaddingLeft=UDim.new(0,8)

local sendBtn=Instance.new("TextButton",tradePanel)
sendBtn.Size=UDim2.new(1,0,0,42); sendBtn.Position=UDim2.new(0,0,0,244)
sendBtn.BackgroundColor3=Color3.fromRGB(42,115,210); sendBtn.Text="📤  Send Trade Offer"
sendBtn.TextColor3=Color3.fromRGB(255,255,255); sendBtn.Font=Enum.Font.GothamBold
sendBtn.TextSize=14; sendBtn.BorderSizePixel=0
Instance.new("UICorner",sendBtn).CornerRadius=UDim.new(0,12)

local tradeStat=Instance.new("TextLabel",tradePanel)
tradeStat.Size=UDim2.new(1,0,0,26); tradeStat.Position=UDim2.new(0,0,0,294)
tradeStat.BackgroundTransparency=1; tradeStat.Text=""
tradeStat.TextColor3=Color3.fromRGB(170,150,210); tradeStat.Font=Enum.Font.Gotham
tradeStat.TextSize=13; tradeStat.TextXAlignment=Enum.TextXAlignment.Center; tradeStat.TextWrapped=true

local selTarget=nil; local selSkill=nil

-- ════════════════════════════════════════════════
--  PAGE 4 — SETTINGS
-- ════════════════════════════════════════════════
local settHdr=Instance.new("TextLabel",pageSett)
settHdr.Size=UDim2.new(1,0,0,22); settHdr.BackgroundTransparency=1
settHdr.Text="⚙️ Settings"; settHdr.TextColor3=Color3.fromRGB(190,160,245)
settHdr.Font=Enum.Font.GothamBold; settHdr.TextSize=14; settHdr.TextXAlignment=Enum.TextXAlignment.Left

local tradeEnabled=false

local function mkToggleRow(parent, y, main, sub, def)
	local row=Instance.new("Frame",parent)
	row.Size=UDim2.new(1,0,0,50); row.Position=UDim2.new(0,0,0,y)
	row.BackgroundColor3=Color3.fromRGB(15,11,24); row.BorderSizePixel=0
	Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
	local m=Instance.new("TextLabel",row)
	m.Size=UDim2.new(1,-70,0,24); m.Position=UDim2.new(0,12,0,4)
	m.BackgroundTransparency=1; m.Text=main
	m.TextColor3=Color3.fromRGB(198,178,232); m.Font=Enum.Font.GothamBold
	m.TextSize=13; m.TextXAlignment=Enum.TextXAlignment.Left
	local s=Instance.new("TextLabel",row)
	s.Size=UDim2.new(1,-70,0,16); s.Position=UDim2.new(0,12,0,28)
	s.BackgroundTransparency=1; s.Text=sub
	s.TextColor3=Color3.fromRGB(115,96,148); s.Font=Enum.Font.Gotham
	s.TextSize=11; s.TextXAlignment=Enum.TextXAlignment.Left
	local tog=Instance.new("TextButton",row)
	tog.Size=UDim2.new(0,52,0,26); tog.Position=UDim2.new(1,-60,0.5,-13)
	tog.BackgroundColor3=def and Color3.fromRGB(65,185,105) or Color3.fromRGB(52,42,76)
	tog.Text=def and "ON" or "OFF"; tog.TextColor3=Color3.fromRGB(255,255,255)
	tog.Font=Enum.Font.GothamBold; tog.TextSize=12; tog.BorderSizePixel=0
	Instance.new("UICorner",tog).CornerRadius=UDim.new(0,8)
	local st=def
	tog.MouseButton1Click:Connect(function()
		st=not st
		T(tog,{BackgroundColor3=st and Color3.fromRGB(65,185,105) or Color3.fromRGB(52,42,76)},TI_FAST)
		tog.Text=st and "ON" or "OFF"
	end)
	return tog, function() return st end
end

local togTrade,getTrade = mkToggleRow(pageSett, 26,  "🤝 Enable Trade",   "Izinkan trade skill ke player lain", false)
local togGive, getGive  = mkToggleRow(pageSett, 84,  "📡 Give All GUI",   "Broadcast GUI ke semua player",      false)

local giveBtn=Instance.new("TextButton",pageSett)
giveBtn.Size=UDim2.new(1,0,0,42); giveBtn.Position=UDim2.new(0,0,0,142)
giveBtn.BackgroundColor3=Color3.fromRGB(32,90,188); giveBtn.Text="📡  Broadcast GUI ke Semua Player"
giveBtn.TextColor3=Color3.fromRGB(255,255,255); giveBtn.Font=Enum.Font.GothamBold
giveBtn.TextSize=13; giveBtn.BorderSizePixel=0
Instance.new("UICorner",giveBtn).CornerRadius=UDim.new(0,12)

local settNote=Instance.new("TextLabel",pageSett)
settNote.Size=UDim2.new(1,0,0,34); settNote.Position=UDim2.new(0,0,0,192)
settNote.BackgroundTransparency=1
settNote.Text="⚠️ Give All & Trade butuh Server Support.\nCheck server dulu di tab 🎲 Roll."
settNote.TextColor3=Color3.fromRGB(170,130,72); settNote.Font=Enum.Font.Gotham
settNote.TextSize=11; settNote.TextXAlignment=Enum.TextXAlignment.Left; settNote.TextWrapped=true

-- ════════════════════════════════════════════════
--  TRADE NOTIF (floating bottom)
-- ════════════════════════════════════════════════
local tNotif=Instance.new("Frame",SG)
tNotif.Size=UDim2.new(0,310,0,106); tNotif.Position=UDim2.new(0.5,-155,1,10)
tNotif.BackgroundColor3=Color3.fromRGB(14,11,24); tNotif.BorderSizePixel=0; tNotif.Visible=false
Instance.new("UICorner",tNotif).CornerRadius=UDim.new(0,14)
local tnS=Instance.new("UIStroke",tNotif); tnS.Color=Color3.fromRGB(42,115,210); tnS.Thickness=1.5

local tnTitle=Instance.new("TextLabel",tNotif)
tnTitle.Size=UDim2.new(1,-10,0,24); tnTitle.Position=UDim2.new(0,10,0,6)
tnTitle.BackgroundTransparency=1; tnTitle.Text="🤝 Incoming Trade!"
tnTitle.TextColor3=Color3.fromRGB(85,165,255); tnTitle.Font=Enum.Font.GothamBold
tnTitle.TextSize=13; tnTitle.TextXAlignment=Enum.TextXAlignment.Left

local tnDesc=Instance.new("TextLabel",tNotif)
tnDesc.Size=UDim2.new(1,-10,0,24); tnDesc.Position=UDim2.new(0,10,0,28)
tnDesc.BackgroundTransparency=1; tnDesc.Text="..."
tnDesc.TextColor3=Color3.fromRGB(168,148,205); tnDesc.Font=Enum.Font.Gotham
tnDesc.TextSize=12; tnDesc.TextWrapped=true

local tnAcc=Instance.new("TextButton",tNotif)
tnAcc.Size=UDim2.new(0.44,0,0,28); tnAcc.Position=UDim2.new(0.03,0,1,-36)
tnAcc.BackgroundColor3=Color3.fromRGB(48,170,88); tnAcc.Text="✅ Accept"
tnAcc.TextColor3=Color3.fromRGB(255,255,255); tnAcc.Font=Enum.Font.GothamBold
tnAcc.TextSize=12; tnAcc.BorderSizePixel=0
Instance.new("UICorner",tnAcc).CornerRadius=UDim.new(0,8)

local tnDec=Instance.new("TextButton",tNotif)
tnDec.Size=UDim2.new(0.44,0,0,28); tnDec.Position=UDim2.new(0.52,0,1,-36)
tnDec.BackgroundColor3=Color3.fromRGB(175,52,52); tnDec.Text="❌ Decline"
tnDec.TextColor3=Color3.fromRGB(255,255,255); tnDec.Font=Enum.Font.GothamBold
tnDec.TextSize=12; tnDec.BorderSizePixel=0
Instance.new("UICorner",tnDec).CornerRadius=UDim.new(0,8)

local pendOffer=nil

-- ════════════════════════════════════════════════
--  SLOT BUILDER
-- ════════════════════════════════════════════════
local slotObjs={}

local function rebuildTradeSkills()
	for _,c in ipairs(tskSF:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	selSkill=nil; local tot=0
	for _,ent in ipairs(activeSkills) do
		local sk=ent.skill; tot=tot+1
		local b=Instance.new("TextButton",tskSF)
		b.Size=UDim2.new(0,58,0,60); b.BackgroundColor3=Color3.fromRGB(20,16,36)
		b.Text=sk.icon; b.TextSize=26; b.Font=Enum.Font.Gotham
		b.TextColor3=Color3.fromRGB(255,255,255); b.BorderSizePixel=0
		Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
		local bs=Instance.new("UIStroke",b); bs.Color=rc(sk.rarity); bs.Thickness=2
		b.MouseButton1Click:Connect(function()
			selSkill=sk
			for _,c2 in ipairs(tskSF:GetChildren()) do
				if c2:IsA("TextButton") then T(c2,{BackgroundColor3=Color3.fromRGB(20,16,36)},TI_FAST) end
			end
			T(b,{BackgroundColor3=Color3.fromRGB(50,34,85)},TI_FAST)
			tradeStat.Text="Dipilih: "..sk.icon.." "..sk.name
		end)
	end
	tskSF.CanvasSize=UDim2.new(0,tot*64+8,0,0)
end

local function rebuildPlayerList()
	for _,c in ipairs(plrSF:GetChildren()) do
		if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
	end
	selTarget=nil; local cnt=0
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=player then cnt=cnt+1
			local b=Instance.new("TextButton",plrSF)
			b.Size=UDim2.new(1,-10,0,28); b.BackgroundColor3=Color3.fromRGB(19,15,30)
			b.Text="👤  "..p.Name; b.Font=Enum.Font.Gotham; b.TextSize=13
			b.TextColor3=Color3.fromRGB(190,170,228); b.BorderSizePixel=0
			b.TextXAlignment=Enum.TextXAlignment.Left
			Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
			Instance.new("UIPadding",b).PaddingLeft=UDim.new(0,10)
			b.MouseButton1Click:Connect(function()
				selTarget=p.Name
				for _,c2 in ipairs(plrSF:GetChildren()) do
					if c2:IsA("TextButton") then T(c2,{BackgroundColor3=Color3.fromRGB(19,15,30)},TI_FAST) end
				end
				T(b,{BackgroundColor3=Color3.fromRGB(36,26,62)},TI_FAST)
				tradeStat.Text="Target: "..p.Name
			end)
		end
	end
	plrSF.CanvasSize=UDim2.new(0,0,0,cnt*32+8)
	if cnt==0 then
		local nl=Instance.new("TextLabel",plrSF)
		nl.Size=UDim2.new(1,-10,0,28); nl.BackgroundTransparency=1
		nl.Text="Tidak ada player lain."; nl.TextColor3=Color3.fromRGB(115,96,148)
		nl.Font=Enum.Font.Gotham; nl.TextSize=13
	end
end

local function rebuildSlots()
	for _,s in ipairs(slotObjs) do s:Destroy() end
	slotObjs={}
	slotsHdr.Text="ACTIVE SKILL SLOTS  ["..#activeSkills.."/"..MAX_SLOTS.."]"
	for i,ent in ipairs(activeSkills) do
		local sk=ent.skill
		local slot=Instance.new("Frame",slotsF)
		slot.Size=UDim2.new(0,54,0,54); slot.BackgroundColor3=Color3.fromRGB(20,16,36); slot.BorderSizePixel=0
		Instance.new("UICorner",slot).CornerRadius=UDim.new(0,10)
		local ss=Instance.new("UIStroke",slot); ss.Color=rc(sk.rarity); ss.Thickness=2
		local ic=Instance.new("TextLabel",slot)
		ic.Size=UDim2.new(1,0,0.64,0); ic.BackgroundTransparency=1
		ic.Text=sk.icon; ic.TextSize=21; ic.Font=Enum.Font.Gotham; ic.TextColor3=Color3.fromRGB(255,255,255)
		local rl=Instance.new("TextLabel",slot)
		rl.Size=UDim2.new(1,-2,0.36,0); rl.Position=UDim2.new(0,1,0.64,0)
		rl.BackgroundTransparency=1; rl.Text=sk.rarity=="Legendary" and "LGND" or sk.rarity
		rl.TextSize=8; rl.Font=Enum.Font.GothamBold; rl.TextColor3=rc(sk.rarity)
		local rb=Instance.new("TextButton",slot); rb.Size=UDim2.new(1,0,1,0)
		rb.BackgroundTransparency=1; rb.Text=""; rb.ZIndex=10
		rb.MouseEnter:Connect(function()
			ic.Text="✕"; T(slot,{BackgroundColor3=Color3.fromRGB(80,20,20)},TI_FAST)
		end)
		rb.MouseLeave:Connect(function()
			ic.Text=sk.icon; T(slot,{BackgroundColor3=Color3.fromRGB(20,16,36)},TI_FAST)
		end)
		rb.MouseButton1Click:Connect(function()
			pcall(sk.remove); table.remove(activeSkills,i); activeIds[sk.id]=nil
			rebuildSlots(); rebuildTradeSkills()
		end)
		table.insert(slotObjs,slot)
	end
	for _=1,MAX_SLOTS-#activeSkills do
		local e=Instance.new("Frame",slotsF)
		e.Size=UDim2.new(0,54,0,54); e.BackgroundColor3=Color3.fromRGB(14,11,22); e.BorderSizePixel=0
		Instance.new("UICorner",e).CornerRadius=UDim.new(0,10)
		local es=Instance.new("UIStroke",e); es.Color=Color3.fromRGB(42,32,68); es.Thickness=1.5; es.Transparency=0.5
		local el=Instance.new("TextLabel",e); el.Size=UDim2.new(1,0,1,0); el.BackgroundTransparency=1
		el.Text="+"; el.TextSize=20; el.Font=Enum.Font.GothamBold; el.TextColor3=Color3.fromRGB(42,32,65)
		table.insert(slotObjs,e)
	end
end
rebuildSlots()

-- ════════════════════════════════════════════════
--  DRAG
-- ════════════════════════════════════════════════
local drag=false; local dragS=nil; local winS2=nil
tbar.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		drag=true; dragS=i.Position; winS2=win.Position
	end
end)
tbar.InputChanged:Connect(function(i)
	if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
		local d=i.Position-dragS
		win.Position=UDim2.new(winS2.X.Scale,winS2.X.Offset+d.X,winS2.Y.Scale,winS2.Y.Offset+d.Y)
	end
end)
tbar.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

-- ════════════════════════════════════════════════
--  MINIMIZE / CLOSE
-- ════════════════════════════════════════════════
local minimized=false
btnMin.MouseButton1Click:Connect(function()
	minimized=not minimized
	if minimized then
		for _,pg in ipairs(PAGES) do pg.Visible=false end
		tabBar.Visible=false
		T(win,{Size=UDim2.new(0,W,0,48)},TI_MED)
		btnMin.Text="□"
	else
		T(win,{Size=UDim2.new(0,W,0,H)},TI_BACK)
		task.wait(0.35); tabBar.Visible=true; pageRoll.Visible=true
		btnMin.Text="─"
	end
end)

btnClose.MouseButton1Click:Connect(function()
	for k in pairs(Conns) do dropConn(k) end
	T(win,{
		Size=UDim2.new(0,0,0,0),
		Position=UDim2.new(win.Position.X.Scale, win.Position.X.Offset+W/2,
			win.Position.Y.Scale, win.Position.Y.Offset+H/2)
	}, TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In))
	task.wait(0.25); SG:Destroy()
end)

-- ════════════════════════════════════════════════
--  ROLL LOGIC
-- ════════════════════════════════════════════════
local FACES={"⚀","⚁","⚂","⚃","⚄","⚅"}

local function showPick(sk)
	pendingSkill=sk; waiting=true
	checkBtn.Visible=false; rollBtn.Visible=false
	useBtn.Visible=true; skipBtn.Visible=true
	T(diceS,  {Color=rg(sk.rarity), Transparency=0.1}, TI_MED)
	T(cardS,  {Color=rg(sk.rarity), Transparency=0.2}, TI_MED)
	rarLbl.Text=RICON[sk.rarity].."  "..sk.rarity:upper()
	rarLbl.TextColor3=rc(sk.rarity); rarLbl.Visible=true
	nameLbl.Text=sk.name; nameLbl.TextColor3=rc(sk.rarity)
	descLbl.Text=sk.desc; flavorLbl.Text=sk.flavor or ""
end

local function hidePick()
	pendingSkill=nil; waiting=false
	useBtn.Visible=false; skipBtn.Visible=false
	checkBtn.Visible=not checkDone; rollBtn.Visible=true
	T(diceS, {Color=Color3.fromRGB(125,75,235), Transparency=0.4}, TI_MED)
	T(cardS, {Color=Color3.fromRGB(85,48,165),  Transparency=0.4}, TI_MED)
	rarLbl.Visible=false
end

local function updateStreak()
	if streak>=3 then
		streakLbl.Text="🔥 Streak "..streak.."x — Legendary chance naik!"
		streakLbl.TextColor3=Color3.fromRGB(255,185,38)
	elseif streak>0 then
		streakLbl.Text="Skip streak: "..streak.."x"
		streakLbl.TextColor3=Color3.fromRGB(185,185,185)
	else
		streakLbl.Text=""
	end
end

rollBtn.MouseButton1Click:Connect(function()
	if isRolling or waiting then return end
	if #activeSkills>=MAX_SLOTS then
		nameLbl.Text="⚠️ Slot penuh!"; descLbl.Text="Hover slot lalu klik untuk remove."
		return
	end
	isRolling=true
	T(rollBtn,{BackgroundColor3=Color3.fromRGB(52,28,110)},TI_FAST)
	rollBtn.Text="Rolling..."
	nameLbl.Text="Rolling..."; descLbl.Text=""; flavorLbl.Text=""; rarLbl.Visible=false
	local el,iv=0,0.07
	while el<1.4 do
		diceTxt.Text=FACES[math.random(1,6)]
		task.wait(iv); el=el+iv; iv=math.min(iv+0.013,0.22)
	end
	local excL={}
	for id in pairs(activeIds) do table.insert(excL,id) end
	local sk=pickSkill(excL, streak>=3 and streak or nil)
	T(rollBtn,{BackgroundColor3=Color3.fromRGB(95,44,200)},TI_FAST)
	rollBtn.Text="🎲  ROLL THE DICE"; isRolling=false
	if not sk then
		diceTxt.Text="😵"; nameLbl.Text="Semua skill aktif!"
		descLbl.Text="Clear dulu beberapa skill."; return
	end
	diceTxt.Text=sk.icon; showPick(sk)
end)

useBtn.MouseButton1Click:Connect(function()
	if not pendingSkill then return end
	local sk=pendingSkill
	local ok,err=pcall(sk.apply)
	if ok then
		table.insert(activeSkills,{skill=sk}); activeIds[sk.id]=true
		streak=0; updateStreak(); rebuildSlots(); rebuildTradeSkills()
		table.insert(history,1,{skill=sk,used=true})
		if #history>20 then table.remove(history) end
		rebuildHistory()
		nameLbl.Text="✅ "..sk.name; nameLbl.TextColor3=rc(sk.rarity)
		descLbl.Text="Aktif!"..(serverMode and " 🌐" or " 💻")
		flavorLbl.Text=sk.flavor or ""
	else
		nameLbl.Text="❌ Error!"; descLbl.Text=tostring(err)
		nameLbl.TextColor3=Color3.fromRGB(255,85,85)
		warn("[DiceCore] Apply error:",err)
	end
	hidePick()
end)

skipBtn.MouseButton1Click:Connect(function()
	if not pendingSkill then return end
	table.insert(history,1,{skill=pendingSkill,used=false})
	if #history>20 then table.remove(history) end
	rebuildHistory()
	streak=streak+1; updateStreak()
	nameLbl.Text="Roll the dice!"; nameLbl.TextColor3=Color3.fromRGB(215,185,255)
	descLbl.Text="Dilewatin! Roll lagi."; flavorLbl.Text=""; diceTxt.Text="🎲"
	hidePick()
end)

clearBtn.MouseButton1Click:Connect(function()
	for _,ent in ipairs(activeSkills) do pcall(ent.skill.remove) end
	if serverMode and R_ACTION then pcall(function() R_ACTION:FireServer("ClearAll","") end) end
	for k in pairs(Conns) do dropConn(k) end
	activeSkills={}; activeIds={}; streak=0; updateStreak()
	rebuildSlots(); rebuildTradeSkills()
	local c=player.Character
	if c then
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and OrigSize[p.Name] then
				pcall(function() p.Size=OrigSize[p.Name] end)
			end
		end
		local h2=c:FindFirstChildOfClass("Humanoid")
		if h2 then h2.WalkSpeed=16; h2.JumpPower=50 end
	end
	workspace.Gravity=196.2
	nameLbl.Text="Roll the dice!"; nameLbl.TextColor3=Color3.fromRGB(215,185,255)
	descLbl.Text="Semua skill di-reset!"; flavorLbl.Text=""; diceTxt.Text="🎲"
end)

-- ════════════════════════════════════════════════
--  CHECK SERVER
-- ════════════════════════════════════════════════
checkBtn.MouseButton1Click:Connect(function()
	checkBtn.Text="⏳ Mencari FREEDICE..."; T(checkBtn,{BackgroundColor3=Color3.fromRGB(32,32,50)},TI_FAST)
	task.wait(1.2)
	local found=checkServer(); checkDone=true; checkBtn.Visible=false
	if found then
		badge.Text="🌐 SERVER MODE"; badge.TextColor3=Color3.fromRGB(85,240,140)
		T(badge,{BackgroundColor3=Color3.fromRGB(16,80,40)},TI_FAST)
		descLbl.Text="Server aktif! Efek keliatan semua 🌐"
		-- connect trade
		if R_TRADE then
			R_TRADE.OnClientEvent:Connect(function(action,...)
				local a={...}
				if action=="IncomingOffer" then
					pendOffer=a[2]
					tnTitle.Text="🤝 Trade dari "..a[1].."!"
					tnDesc.Text=a[2].skillIcon.." "..a[2].skillName.." ("..a[2].skillRarity..")"
					tNotif.Visible=true
					T(tNotif,{Position=UDim2.new(0.5,-155,1,-115)},TI_BACK)
				elseif action=="TradeAccepted" then
					for i,ent in ipairs(activeSkills) do
						if ent.skill.id==a[2].skillId then
							pcall(ent.skill.remove); table.remove(activeSkills,i); activeIds[a[2].skillId]=nil; break
						end
					end
					rebuildSlots(); rebuildTradeSkills(); tradeStat.Text="✅ "..a[1].." menerima trade!"
				elseif action=="TradeComplete" then
					for _,sk in ipairs(SKILLS) do
						if sk.id==a[1].skillId and #activeSkills<MAX_SLOTS then
							pcall(sk.apply); table.insert(activeSkills,{skill=sk}); activeIds[sk.id]=true
							rebuildSlots(); rebuildTradeSkills()
							nameLbl.Text="🎁 Dapat "..sk.name.."!"; nameLbl.TextColor3=rc(sk.rarity)
							break
						end
					end
				elseif action=="TradeDeclined" then
					tradeStat.Text="❌ "..a[1].." menolak trade."
				end
			end)
		end
	else
		badge.Text="💻 LOCAL ONLY"; badge.TextColor3=Color3.fromRGB(255,168,62)
		T(badge,{BackgroundColor3=Color3.fromRGB(72,46,16)},TI_FAST)
		descLbl.Text="No server. Efek local only 💻"
	end
end)

-- ════════════════════════════════════════════════
--  SETTINGS ACTIONS
-- ════════════════════════════════════════════════
togTrade.MouseButton1Click:Connect(function()
	task.wait(0.05); tradeEnabled=getTrade()
	tradeLockLbl.Visible=not tradeEnabled; tradePanel.Visible=tradeEnabled
	if tradeEnabled then rebuildPlayerList(); rebuildTradeSkills() end
end)

giveBtn.MouseButton1Click:Connect(function()
	if not serverMode or not R_GIVE then
		T(settNote,{TextColor3=Color3.fromRGB(210,72,72)},TI_FAST)
		settNote.Text="❌ Butuh server support! Check server dulu."
		task.wait(2.5)
		T(settNote,{TextColor3=Color3.fromRGB(170,130,72)},TI_FAST)
		settNote.Text="⚠️ Give All & Trade butuh Server Support.\nCheck server dulu di tab 🎲 Roll."
		return
	end
	pcall(function() R_GIVE:FireServer("GiveAll") end)
	giveBtn.Text="✅ GUI Terbroadcast!"
	T(giveBtn,{BackgroundColor3=Color3.fromRGB(26,115,58)},TI_FAST)
	task.wait(3); giveBtn.Text="📡  Broadcast GUI ke Semua Player"
	T(giveBtn,{BackgroundColor3=Color3.fromRGB(32,90,188)},TI_FAST)
end)

-- ════════════════════════════════════════════════
--  TRADE SEND / ACCEPT / DECLINE
-- ════════════════════════════════════════════════
sendBtn.MouseButton1Click:Connect(function()
	if not serverMode or not R_TRADE then tradeStat.Text="❌ Butuh server support!"; return end
	if not selTarget then tradeStat.Text="⚠️ Pilih player dulu!"; return end
	if not selSkill   then tradeStat.Text="⚠️ Pilih skill dulu!"; return end
	pcall(function()
		R_TRADE:FireServer("Offer", selTarget, {
			from=player.Name, skillId=selSkill.id, skillName=selSkill.name,
			skillIcon=selSkill.icon, skillRarity=selSkill.rarity,
		})
	end)
	tradeStat.Text="📤 Offer terkirim ke "..selTarget.."!"
end)

tnAcc.MouseButton1Click:Connect(function()
	if not pendOffer or not R_TRADE then return end
	pcall(function() R_TRADE:FireServer("Accept", pendOffer.from, pendOffer) end)
	tNotif.Visible=false; pendOffer=nil
end)
tnDec.MouseButton1Click:Connect(function()
	if not pendOffer or not R_TRADE then return end
	pcall(function() R_TRADE:FireServer("Decline", pendOffer.from, pendOffer) end)
	tNotif.Visible=false; pendOffer=nil
end)

-- ════════════════════════════════════════════════
--  HOVER EFFECTS
-- ════════════════════════════════════════════════
local function hover(b,n,h)
	b.MouseEnter:Connect(function() T(b,{BackgroundColor3=h},TI_FAST) end)
	b.MouseLeave:Connect(function() T(b,{BackgroundColor3=n},TI_FAST) end)
end
hover(rollBtn,  Color3.fromRGB(95,44,200),   Color3.fromRGB(122,68,245))
hover(useBtn,   Color3.fromRGB(48,170,88),   Color3.fromRGB(36,205,78))
hover(skipBtn,  Color3.fromRGB(175,52,52),   Color3.fromRGB(210,38,38))
hover(clearBtn, Color3.fromRGB(38,26,62),    Color3.fromRGB(55,40,90))
hover(checkBtn, Color3.fromRGB(20,62,140),   Color3.fromRGB(34,92,198))
hover(giveBtn,  Color3.fromRGB(32,90,188),   Color3.fromRGB(48,118,235))
hover(sendBtn,  Color3.fromRGB(42,115,210),  Color3.fromRGB(62,142,255))

-- ════════════════════════════════════════════════
--  OPEN ANIMATION
-- ════════════════════════════════════════════════
win.Size=UDim2.new(0,0,0,0)
win.Position=UDim2.new(0.5,0,0.5,0)
tabBar.Visible=false; pageRoll.Visible=false
task.wait(0.06)
T(win, {Size=UDim2.new(0,W,0,H), Position=UDim2.new(0.5,-W/2,0.5,-H/2)}, TI_BACK)
task.wait(0.36); tabBar.Visible=true; pageRoll.Visible=true

print("[DiceCore v6] ✅ Loaded — Roll | History | Trade | Settings")
