-- ╔══════════════════════════════════════════════╗
-- ║         DICE OF FATE — DiceCore v2           ║
-- ║   Standalone, tidak butuh ModuleScript       ║
-- ║   Jalankan via Loader di Delta Executor      ║
-- ╚══════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")

-- ══════════════════════════════════════════════
--  SKILL_LIST (inline, tidak butuh require)
-- ══════════════════════════════════════════════
local SkillList = {}

SkillList.RarityData = {
	Common    = { color = Color3.fromRGB(180,180,180), weight = 50, glow = Color3.fromRGB(200,200,200) },
	Rare      = { color = Color3.fromRGB(80,140,255),  weight = 30, glow = Color3.fromRGB(100,160,255) },
	Epic      = { color = Color3.fromRGB(180,80,255),  weight = 15, glow = Color3.fromRGB(200,100,255) },
	Legendary = { color = Color3.fromRGB(255,180,0),   weight = 5,  glow = Color3.fromRGB(255,220,80)  },
}

SkillList.Skills = {

	-- ───────────── COMMON ─────────────
	{
		id = "speed_demon", name = "💨 Speed Demon", icon = "💨", rarity = "Common",
		desc = "WalkSpeed jadi 100. Ngebut kayak angin!",
		apply  = function(c,h) h.WalkSpeed = 100 end,
		remove = function(c,h) h.WalkSpeed = 16  end,
	},
	{
		id = "super_jump", name = "🚀 Super Jump", icon = "🚀", rarity = "Common",
		desc = "JumpPower jadi 200. Bisa nyentuh orbit!",
		apply  = function(c,h) h.JumpPower = 200 end,
		remove = function(c,h) h.JumpPower = 50  end,
	},
	{
		id = "giant_head", name = "🗿 Giant Head", icon = "🗿", rarity = "Common",
		desc = "Kepala jadi SUPER GEDE kayak batu gajah.",
		apply = function(c,h)
			local head = c:FindFirstChild("Head")
			if head then head.Size = Vector3.new(4,4,4) end
		end,
		remove = function(c,h)
			local head = c:FindFirstChild("Head")
			if head then head.Size = Vector3.new(2,1,1) end
		end,
	},
	{
		id = "tiny_legs", name = "🦵 Tiny Legs", icon = "🦵", rarity = "Common",
		desc = "Kaki mengecil drastis. Jalannya lucu banget.",
		apply  = function(c,h) h.BodyHeightScale.Value = 0.6 end,
		remove = function(c,h) h.BodyHeightScale.Value = 1   end,
	},
	{
		id = "buff_arms", name = "💪 Buff Arms", icon = "💪", rarity = "Common",
		desc = "Lengan super gede. Siap tinju meteor!",
		apply  = function(c,h) h.BodyWidthScale.Value = 2.2 end,
		remove = function(c,h) h.BodyWidthScale.Value = 1   end,
	},
	{
		id = "noodle_arms", name = "🍜 Noodle Arms", icon = "🍜", rarity = "Common",
		desc = "Lengan super panjang menjuntai ke tanah.",
		apply = function(c,h)
			h.BodyDepthScale.Value = 0.4
			h.BodyWidthScale.Value = 0.4
		end,
		remove = function(c,h)
			h.BodyDepthScale.Value = 1
			h.BodyWidthScale.Value = 1
		end,
	},
	{
		id = "phantom", name = "👻 Phantom Mode", icon = "👻", rarity = "Common",
		desc = "Badan transparan 80%. Kayak hantu!",
		apply = function(c,h)
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					p.Transparency = 0.8
				end
			end
		end,
		remove = function(c,h)
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Transparency = 0 end
			end
		end,
	},
	{
		id = "golden_skin", name = "✨ Golden Touch", icon = "✨", rarity = "Common",
		desc = "Seluruh badan jadi emas berkilau!",
		apply = function(c,h)
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					p.BrickColor = BrickColor.new("Bright yellow")
					p.Material = Enum.Material.SmoothPlastic
				end
			end
		end,
		remove = function(c,h)
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then
					p.BrickColor = BrickColor.new("Medium stone grey")
					p.Material = Enum.Material.SmoothPlastic
				end
			end
		end,
	},

	-- ───────────── RARE ─────────────
	{
		id = "rainbow_body", name = "🌈 Rainbow Body", icon = "🌈", rarity = "Rare",
		desc = "Warna badan berubah pelangi terus-menerus!",
		apply = function(c,h)
			local colors = {
				Color3.fromRGB(255,60,60), Color3.fromRGB(255,165,0),
				Color3.fromRGB(255,240,0), Color3.fromRGB(60,210,60),
				Color3.fromRGB(40,120,255), Color3.fromRGB(160,40,255),
			}
			local idx = 1
			local conn
			conn = RunService.Heartbeat:Connect(function()
				if not c or not c.Parent then conn:Disconnect() return end
				idx = (idx % #colors) + 1
				for _,p in ipairs(c:GetDescendants()) do
					if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
						p.Color = colors[idx]
					end
				end
			end)
			rawset(c, "_rainbowConn", conn)
		end,
		remove = function(c,h)
			local conn = rawget(c, "_rainbowConn")
			if conn then conn:Disconnect() end
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then p.Color = Color3.fromRGB(163,162,165) end
			end
		end,
	},
	{
		id = "anti_gravity", name = "🪐 Anti Gravity", icon = "🪐", rarity = "Rare",
		desc = "Gravitasi berkurang. Lompat terasa melayang!",
		apply = function(c,h)
			h.JumpPower = 130
			local hrp = c:FindFirstChild("HumanoidRootPart")
			if hrp then
				local bf = Instance.new("BodyForce")
				bf.Name = "_AntiGrav"
				bf.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass() * 0.72, 0)
				bf.Parent = hrp
			end
		end,
		remove = function(c,h)
			h.JumpPower = 50
			local hrp = c:FindFirstChild("HumanoidRootPart")
			if hrp then
				local bf = hrp:FindFirstChild("_AntiGrav")
				if bf then bf:Destroy() end
			end
		end,
	},
	{
		id = "ice_body", name = "🧊 Frozen Soul", icon = "🧊", rarity = "Rare",
		desc = "Badan jadi es transparan biru. Dingin sampe jiwa.",
		apply = function(c,h)
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					p.BrickColor = BrickColor.new("Pastel blue")
					p.Material = Enum.Material.Ice
					p.Transparency = 0.35
				end
			end
		end,
		remove = function(c,h)
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") then
					p.Material = Enum.Material.SmoothPlastic
					p.Transparency = 0
				end
			end
		end,
	},
	{
		id = "lava_trail", name = "🔥 Lava Trail", icon = "🔥", rarity = "Rare",
		desc = "Ninggalin jejak api lava di mana pun kamu jalan!",
		apply = function(c,h)
			local conn
			conn = RunService.Heartbeat:Connect(function()
				if not c or not c.Parent then conn:Disconnect() return end
				local hrp = c:FindFirstChild("HumanoidRootPart")
				if hrp and h.MoveDirection.Magnitude > 0.1 then
					local fire = Instance.new("Part")
					fire.Size = Vector3.new(1.2,0.2,1.2)
					fire.CFrame = hrp.CFrame * CFrame.new(0,-3,0)
					fire.Anchored = true
					fire.CanCollide = false
					fire.BrickColor = BrickColor.new("Bright orange")
					fire.Material = Enum.Material.Neon
					fire.Parent = workspace
					local f = Instance.new("Fire")
					f.Heat = 6 ; f.Size = 4
					f.Parent = fire
					game:GetService("Debris"):AddItem(fire, 1.8)
				end
			end)
			rawset(c, "_lavaConn", conn)
		end,
		remove = function(c,h)
			local conn = rawget(c, "_lavaConn")
			if conn then conn:Disconnect() end
		end,
	},
	{
		id = "spinning_head", name = "🌀 Spinning Head", icon = "🌀", rarity = "Rare",
		desc = "Kepala muter nonstop. Pusing liatnya!",
		apply = function(c,h)
			local conn
			conn = RunService.Heartbeat:Connect(function(dt)
				if not c or not c.Parent then conn:Disconnect() return end
				local head = c:FindFirstChild("Head")
				if head then head.CFrame = head.CFrame * CFrame.Angles(0, math.rad(280*dt), 0) end
			end)
			rawset(c, "_spinConn", conn)
		end,
		remove = function(c,h)
			local conn = rawget(c, "_spinConn")
			if conn then conn:Disconnect() end
		end,
	},

	-- ───────────── EPIC ─────────────
	{
		id = "ant_size", name = "🐜 Ant Size", icon = "🐜", rarity = "Epic",
		desc = "Tubuh mengecil jadi 0.3x ukuran normal. Super imut!",
		apply = function(c,h)
			h.BodyDepthScale.Value=0.3 ; h.BodyHeightScale.Value=0.3
			h.BodyWidthScale.Value=0.3 ; h.HeadScale.Value=0.3
		end,
		remove = function(c,h)
			h.BodyDepthScale.Value=1 ; h.BodyHeightScale.Value=1
			h.BodyWidthScale.Value=1 ; h.HeadScale.Value=1
		end,
	},
	{
		id = "giant_mode", name = "🏔️ Giant Mode", icon = "🏔️", rarity = "Epic",
		desc = "Tumbuh jadi raksasa 3x ukuran normal!",
		apply = function(c,h)
			h.BodyDepthScale.Value=3 ; h.BodyHeightScale.Value=3
			h.BodyWidthScale.Value=3 ; h.HeadScale.Value=3
		end,
		remove = function(c,h)
			h.BodyDepthScale.Value=1 ; h.BodyHeightScale.Value=1
			h.BodyWidthScale.Value=1 ; h.HeadScale.Value=1
		end,
	},
	{
		id = "backwards_brain", name = "🔄 Backwards Brain", icon = "🔄", rarity = "Epic",
		desc = "Kamera terbalik 180°! Maju jadi mundur.",
		apply = function(c,h)
			local cam = workspace.CurrentCamera
			cam.CameraType = Enum.CameraType.Scriptable
			local conn
			conn = RunService.Heartbeat:Connect(function()
				if not c or not c.Parent then conn:Disconnect() return end
				local hrp = c:FindFirstChild("HumanoidRootPart")
				if hrp then
					cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0,6,12))
						* CFrame.Angles(-0.15, math.pi, 0)
				end
			end)
			rawset(c, "_backConn", conn)
		end,
		remove = function(c,h)
			local conn = rawget(c, "_backConn")
			if conn then conn:Disconnect() end
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		end,
	},
	{
		id = "magnet_body", name = "🧲 Magnet Body", icon = "🧲", rarity = "Epic",
		desc = "Benda-benda di sekitar kamu tertarik kayak magnet!",
		apply = function(c,h)
			local conn
			conn = RunService.Heartbeat:Connect(function()
				if not c or not c.Parent then conn:Disconnect() return end
				local hrp = c:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				for _,obj in ipairs(workspace:GetChildren()) do
					if obj:IsA("BasePart") and not obj.Anchored
						and obj ~= hrp and not c:IsAncestorOf(obj) then
						local dist = (obj.Position - hrp.Position).Magnitude
						if dist < 20 then
							local dir = (hrp.Position - obj.Position).Unit
							obj.Velocity = obj.Velocity + dir * (200/dist)
						end
					end
				end
			end)
			rawset(c, "_magnetConn", conn)
		end,
		remove = function(c,h)
			local conn = rawget(c, "_magnetConn")
			if conn then conn:Disconnect() end
		end,
	},

	-- ───────────── LEGENDARY ─────────────
	{
		id = "time_warp", name = "⏳ Time Warp", icon = "⏳", rarity = "Legendary",
		desc = "LEGENDARY! Gravitasi drop drastis, kamu tetap cepat!",
		apply = function(c,h)
			workspace.Gravity = 19.6
			h.WalkSpeed = 80 ; h.JumpPower = 100
		end,
		remove = function(c,h)
			workspace.Gravity = 196.2
			h.WalkSpeed = 16 ; h.JumpPower = 50
		end,
	},
	{
		id = "god_mode", name = "⚡ God Mode", icon = "⚡", rarity = "Legendary",
		desc = "LEGENDARY! Semua buff sekaligus. Pure chaos!",
		apply = function(c,h)
			h.WalkSpeed=80 ; h.JumpPower=180
			h.BodyDepthScale.Value=1.5 ; h.BodyHeightScale.Value=1.5
			h.BodyWidthScale.Value=1.5 ; h.HeadScale.Value=2
			local conn
			conn = RunService.Heartbeat:Connect(function()
				if not c or not c.Parent then conn:Disconnect() return end
				local t = tick()
				for _,p in ipairs(c:GetDescendants()) do
					if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
						p.Color = Color3.fromHSV((t*0.5 + p.Name:len()*0.1) % 1, 1, 1)
					end
				end
			end)
			rawset(c, "_godConn", conn)
		end,
		remove = function(c,h)
			local conn = rawget(c, "_godConn")
			if conn then conn:Disconnect() end
			h.WalkSpeed=16 ; h.JumpPower=50
			h.BodyDepthScale.Value=1 ; h.BodyHeightScale.Value=1
			h.BodyWidthScale.Value=1 ; h.HeadScale.Value=1
		end,
	},
}

function SkillList.PickRandom(excludeIds)
	excludeIds = excludeIds or {}
	local excludeSet = {}
	for _,id in ipairs(excludeIds) do excludeSet[id] = true end
	local pool = {}
	for _,skill in ipairs(SkillList.Skills) do
		if not excludeSet[skill.id] then
			local w = SkillList.RarityData[skill.rarity].weight
			for _ = 1, w do table.insert(pool, skill) end
		end
	end
	if #pool == 0 then return nil end
	return pool[math.random(1, #pool)]
end

-- ══════════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════════
local activeSkills  = {}
local activeIds     = {}
local isRolling     = false
local waitingChoice = false
local pendingSkill  = nil
local rollStreak    = 0
local MAX_SLOTS     = 5

-- ══════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════
local function rCol(r)  return SkillList.RarityData[r] and SkillList.RarityData[r].color or Color3.fromRGB(200,200,200) end
local function rGlow(r) return SkillList.RarityData[r] and SkillList.RarityData[r].glow  or Color3.fromRGB(200,200,200) end
local rarityEmoji = { Common="⚪", Rare="🔵", Epic="🟣", Legendary="🟡" }

-- ══════════════════════════════════════════════
--  BUILD GUI
-- ══════════════════════════════════════════════
local oldGui = player.PlayerGui:FindFirstChild("DiceOfFateGui")
if oldGui then oldGui:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name = "DiceOfFateGui"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = player.PlayerGui

local win = Instance.new("Frame", SG)
win.Size = UDim2.new(0,400,0,600)
win.Position = UDim2.new(0.5,-200,0.5,-300)
win.BackgroundColor3 = Color3.fromRGB(14,12,22)
win.BorderSizePixel = 0
win.ClipsDescendants = true
Instance.new("UICorner", win).CornerRadius = UDim.new(0,14)
local winStroke = Instance.new("UIStroke", win)
winStroke.Color = Color3.fromRGB(120,80,200)
winStroke.Thickness = 1.5 ; winStroke.Transparency = 0.5

local tbar = Instance.new("Frame", win)
tbar.Size = UDim2.new(1,0,0,46)
tbar.BackgroundColor3 = Color3.fromRGB(24,18,42)
tbar.BorderSizePixel = 0 ; tbar.ZIndex = 5
Instance.new("UICorner", tbar).CornerRadius = UDim.new(0,14)
local tbarFill = Instance.new("Frame", tbar)
tbarFill.Size = UDim2.new(1,0,0,14)
tbarFill.Position = UDim2.new(0,0,1,-14)
tbarFill.BackgroundColor3 = Color3.fromRGB(24,18,42)
tbarFill.BorderSizePixel = 0

local titleTxt = Instance.new("TextLabel", tbar)
titleTxt.Size = UDim2.new(1,-110,1,0)
titleTxt.Position = UDim2.new(0,18,0,0)
titleTxt.BackgroundTransparency = 1
titleTxt.Text = "🎲  DICE OF FATE"
titleTxt.TextColor3 = Color3.fromRGB(200,160,255)
titleTxt.Font = Enum.Font.GothamBold
titleTxt.TextSize = 15
titleTxt.TextXAlignment = Enum.TextXAlignment.Left
titleTxt.ZIndex = 6

local function makeCtrlBtn(pos, bg_, txt)
	local b = Instance.new("TextButton", tbar)
	b.Size = UDim2.new(0,22,0,22) ; b.Position = pos
	b.BackgroundColor3 = bg_ ; b.Text = txt
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.TextSize = 11 ; b.Font = Enum.Font.GothamBold
	b.BorderSizePixel = 0 ; b.ZIndex = 7
	Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
	return b
end
local closeBtn = makeCtrlBtn(UDim2.new(1,-32,0.5,-11), Color3.fromRGB(231,76,94),  "✕")
local minBtn   = makeCtrlBtn(UDim2.new(1,-58,0.5,-11), Color3.fromRGB(245,166,35), "─")

local cont = Instance.new("Frame", win)
cont.Size = UDim2.new(1,0,1,-46)
cont.Position = UDim2.new(0,0,0,46)
cont.BackgroundTransparency = 1

local diceFrame = Instance.new("Frame", cont)
diceFrame.Size = UDim2.new(0,120,0,120)
diceFrame.Position = UDim2.new(0.5,-60,0,20)
diceFrame.BackgroundColor3 = Color3.fromRGB(26,18,48)
diceFrame.BorderSizePixel = 0
Instance.new("UICorner", diceFrame).CornerRadius = UDim.new(0,18)
local diceStroke = Instance.new("UIStroke", diceFrame)
diceStroke.Color = Color3.fromRGB(140,90,255)
diceStroke.Thickness = 2 ; diceStroke.Transparency = 0.5

local diceLbl = Instance.new("TextLabel", diceFrame)
diceLbl.Size = UDim2.new(1,0,1,0)
diceLbl.BackgroundTransparency = 1
diceLbl.Text = "🎲" ; diceLbl.TextSize = 56
diceLbl.Font = Enum.Font.Gotham
diceLbl.TextColor3 = Color3.fromRGB(220,190,255)

local rarityBadge = Instance.new("TextLabel", cont)
rarityBadge.Size = UDim2.new(0,130,0,26)
rarityBadge.Position = UDim2.new(0.5,-65,0,148)
rarityBadge.BackgroundColor3 = Color3.fromRGB(30,22,55)
rarityBadge.Text = "" ; rarityBadge.TextSize = 12
rarityBadge.Font = Enum.Font.GothamBold
rarityBadge.TextColor3 = Color3.fromRGB(200,180,255)
rarityBadge.BorderSizePixel = 0 ; rarityBadge.Visible = false
Instance.new("UICorner", rarityBadge).CornerRadius = UDim.new(0,8)

local skillName = Instance.new("TextLabel", cont)
skillName.Size = UDim2.new(1,-40,0,32)
skillName.Position = UDim2.new(0,20,0,182)
skillName.BackgroundTransparency = 1
skillName.Text = "Roll the dice!"
skillName.TextColor3 = Color3.fromRGB(215,185,255)
skillName.Font = Enum.Font.GothamBold
skillName.TextSize = 18
skillName.TextXAlignment = Enum.TextXAlignment.Center

local skillDesc = Instance.new("TextLabel", cont)
skillDesc.Size = UDim2.new(1,-48,0,50)
skillDesc.Position = UDim2.new(0,24,0,216)
skillDesc.BackgroundTransparency = 1
skillDesc.Text = "Tekan ROLL untuk dapat skill acak!\nSkill punya rarity masing-masing 🎰"
skillDesc.TextColor3 = Color3.fromRGB(155,135,195)
skillDesc.Font = Enum.Font.Gotham
skillDesc.TextSize = 13
skillDesc.TextXAlignment = Enum.TextXAlignment.Center
skillDesc.TextWrapped = true

local useBtn = Instance.new("TextButton", cont)
useBtn.Size = UDim2.new(0,148,0,48)
useBtn.Position = UDim2.new(0.5,-158,0,274)
useBtn.BackgroundColor3 = Color3.fromRGB(70,195,110)
useBtn.Text = "✅  USE" ; useBtn.TextColor3 = Color3.fromRGB(255,255,255)
useBtn.Font = Enum.Font.GothamBold ; useBtn.TextSize = 15
useBtn.BorderSizePixel = 0 ; useBtn.Visible = false
Instance.new("UICorner", useBtn).CornerRadius = UDim.new(0,12)

local skipBtn = Instance.new("TextButton", cont)
skipBtn.Size = UDim2.new(0,148,0,48)
skipBtn.Position = UDim2.new(0.5,10,0,274)
skipBtn.BackgroundColor3 = Color3.fromRGB(200,70,70)
skipBtn.Text = "⏭  SKIP" ; skipBtn.TextColor3 = Color3.fromRGB(255,255,255)
skipBtn.Font = Enum.Font.GothamBold ; skipBtn.TextSize = 15
skipBtn.BorderSizePixel = 0 ; skipBtn.Visible = false
Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0,12)

local rollBtn = Instance.new("TextButton", cont)
rollBtn.Size = UDim2.new(1,-48,0,54)
rollBtn.Position = UDim2.new(0,24,0,336)
rollBtn.BackgroundColor3 = Color3.fromRGB(110,55,215)
rollBtn.Text = "🎲  ROLL THE DICE"
rollBtn.TextColor3 = Color3.fromRGB(255,255,255)
rollBtn.Font = Enum.Font.GothamBold ; rollBtn.TextSize = 16
rollBtn.BorderSizePixel = 0
Instance.new("UICorner", rollBtn).CornerRadius = UDim.new(0,14)
local rollStroke = Instance.new("UIStroke", rollBtn)
rollStroke.Color = Color3.fromRGB(180,120,255) ; rollStroke.Thickness = 1.5

local streakLabel = Instance.new("TextLabel", cont)
streakLabel.Size = UDim2.new(1,-48,0,24)
streakLabel.Position = UDim2.new(0,24,0,398)
streakLabel.BackgroundTransparency = 1 ; streakLabel.Text = ""
streakLabel.TextColor3 = Color3.fromRGB(255,200,60)
streakLabel.Font = Enum.Font.GothamBold ; streakLabel.TextSize = 13
streakLabel.TextXAlignment = Enum.TextXAlignment.Center

local slotsTitle = Instance.new("TextLabel", cont)
slotsTitle.Size = UDim2.new(1,-40,0,20)
slotsTitle.Position = UDim2.new(0,20,0,428)
slotsTitle.BackgroundTransparency = 1
slotsTitle.Text = "ACTIVE SKILL SLOTS  [0/"..MAX_SLOTS.."]"
slotsTitle.TextColor3 = Color3.fromRGB(120,95,175)
slotsTitle.Font = Enum.Font.GothamBold ; slotsTitle.TextSize = 11
slotsTitle.TextXAlignment = Enum.TextXAlignment.Left

local slotsFrame = Instance.new("Frame", cont)
slotsFrame.Size = UDim2.new(1,-40,0,72)
slotsFrame.Position = UDim2.new(0,20,0,450)
slotsFrame.BackgroundColor3 = Color3.fromRGB(20,15,35)
slotsFrame.BorderSizePixel = 0
Instance.new("UICorner", slotsFrame).CornerRadius = UDim.new(0,12)
local slotsLayout = Instance.new("UIListLayout", slotsFrame)
slotsLayout.FillDirection = Enum.FillDirection.Horizontal
slotsLayout.Padding = UDim.new(0,6)
slotsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
Instance.new("UIPadding", slotsFrame).PaddingLeft = UDim.new(0,10)

local clearBtn = Instance.new("TextButton", cont)
clearBtn.Size = UDim2.new(1,-40,0,36)
clearBtn.Position = UDim2.new(0,20,1,-50)
clearBtn.BackgroundColor3 = Color3.fromRGB(50,35,75)
clearBtn.Text = "🗑  Clear All Skills"
clearBtn.TextColor3 = Color3.fromRGB(175,140,215)
clearBtn.Font = Enum.Font.Gotham ; clearBtn.TextSize = 13
clearBtn.BorderSizePixel = 0
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0,10)

-- ══════════════════════════════════════════════
--  SLOT BUILDER
-- ══════════════════════════════════════════════
local slotObjects = {}
local function rebuildSlots()
	for _,s in ipairs(slotObjects) do s:Destroy() end
	slotObjects = {}
	slotsTitle.Text = "ACTIVE SKILL SLOTS  ["..#activeSkills.."/"..MAX_SLOTS.."]"
	for i, entry in ipairs(activeSkills) do
		local slot = Instance.new("Frame", slotsFrame)
		slot.Size = UDim2.new(0,54,0,54)
		slot.BackgroundColor3 = Color3.fromRGB(30,22,52)
		slot.BorderSizePixel = 0
		Instance.new("UICorner", slot).CornerRadius = UDim.new(0,10)
		local ss = Instance.new("UIStroke", slot)
		ss.Color = rCol(entry.skill.rarity) ; ss.Thickness = 2
		local icon = Instance.new("TextLabel", slot)
		icon.Size = UDim2.new(1,0,0.62,0)
		icon.BackgroundTransparency = 1
		icon.Text = entry.skill.icon
		icon.TextSize = 22 ; icon.Font = Enum.Font.Gotham
		icon.TextColor3 = Color3.fromRGB(255,255,255)
		local nl = Instance.new("TextLabel", slot)
		nl.Size = UDim2.new(1,-2,0.38,0)
		nl.Position = UDim2.new(0,1,0.62,0)
		nl.BackgroundTransparency = 1
		nl.Text = entry.skill.rarity=="Legendary" and "LGND" or entry.skill.rarity
		nl.TextSize = 9 ; nl.Font = Enum.Font.GothamBold
		nl.TextColor3 = rCol(entry.skill.rarity)
		local rb = Instance.new("TextButton", slot)
		rb.Size = UDim2.new(1,0,1,0)
		rb.BackgroundTransparency = 1
		rb.Text = "" ; rb.ZIndex = 10
		rb.MouseEnter:Connect(function()
			icon.Text = "✕"
			TweenService:Create(slot,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(100,30,30)}):Play()
		end)
		rb.MouseLeave:Connect(function()
			icon.Text = entry.skill.icon
			TweenService:Create(slot,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(30,22,52)}):Play()
		end)
		rb.MouseButton1Click:Connect(function()
			pcall(entry.skill.remove, character, humanoid)
			table.remove(activeSkills, i)
			activeIds[entry.skill.id] = nil
			rebuildSlots()
		end)
		table.insert(slotObjects, slot)
	end
	for _ = #activeSkills+1, MAX_SLOTS do
		local empty = Instance.new("Frame", slotsFrame)
		empty.Size = UDim2.new(0,54,0,54)
		empty.BackgroundColor3 = Color3.fromRGB(22,16,38)
		empty.BorderSizePixel = 0
		Instance.new("UICorner", empty).CornerRadius = UDim.new(0,10)
		local es = Instance.new("UIStroke", empty)
		es.Color = Color3.fromRGB(60,45,90) ; es.Thickness=1.5 ; es.Transparency=0.5
		local el = Instance.new("TextLabel", empty)
		el.Size = UDim2.new(1,0,1,0) ; el.BackgroundTransparency=1
		el.Text="+" ; el.TextSize=22 ; el.Font=Enum.Font.GothamBold
		el.TextColor3 = Color3.fromRGB(60,45,80)
		table.insert(slotObjects, empty)
	end
end
rebuildSlots()

-- ══════════════════════════════════════════════
--  DRAGGING
-- ══════════════════════════════════════════════
local dragging, dragStart, startPos = false, nil, nil
tbar.InputBegan:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.MouseButton1
	or inp.UserInputType==Enum.UserInputType.Touch then
		dragging=true ; dragStart=inp.Position ; startPos=win.Position
	end
end)
tbar.InputChanged:Connect(function(inp)
	if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement
	or inp.UserInputType==Enum.UserInputType.Touch) then
		local d = inp.Position - dragStart
		win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
			startPos.Y.Scale, startPos.Y.Offset+d.Y)
	end
end)
tbar.InputEnded:Connect(function(inp)
	if inp.UserInputType==Enum.UserInputType.MouseButton1
	or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)

-- ══════════════════════════════════════════════
--  MINIMIZE & CLOSE
-- ══════════════════════════════════════════════
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		cont.Visible = false
		TweenService:Create(win,TweenInfo.new(0.28,Enum.EasingStyle.Quart),{Size=UDim2.new(0,400,0,46)}):Play()
		minBtn.Text = "□"
	else
		TweenService:Create(win,TweenInfo.new(0.28,Enum.EasingStyle.Quart),{Size=UDim2.new(0,400,0,600)}):Play()
		task.wait(0.28) ; cont.Visible=true ; minBtn.Text="─"
	end
end)
closeBtn.MouseButton1Click:Connect(function()
	TweenService:Create(win,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In),{
		Size=UDim2.new(0,0,0,0),
		Position=UDim2.new(win.Position.X.Scale,win.Position.X.Offset+200,
			win.Position.Y.Scale,win.Position.Y.Offset+300)
	}):Play()
	task.wait(0.25) ; SG:Destroy()
end)

-- ══════════════════════════════════════════════
--  CHOICE & STREAK
-- ══════════════════════════════════════════════
local function showChoice(skill)
	pendingSkill=skill ; waitingChoice=true
	useBtn.Visible=true ; skipBtn.Visible=true ; rollBtn.Visible=false
	TweenService:Create(diceStroke,TweenInfo.new(0.3),{Color=rGlow(skill.rarity),Transparency=0}):Play()
	rarityBadge.Text = rarityEmoji[skill.rarity].."  "..skill.rarity:upper()
	rarityBadge.TextColor3 = rCol(skill.rarity)
	rarityBadge.Visible = true
end
local function hideChoice()
	useBtn.Visible=false ; skipBtn.Visible=false ; rollBtn.Visible=true
	waitingChoice=false ; pendingSkill=nil
	TweenService:Create(diceStroke,TweenInfo.new(0.3),{Color=Color3.fromRGB(140,90,255),Transparency=0.5}):Play()
	rarityBadge.Visible=false
end
local function updateStreak()
	if rollStreak >= 3 then
		streakLabel.Text = "🔥 Skip streak: "..rollStreak.."x — Legendary chance meningkat!"
		streakLabel.TextColor3 = Color3.fromRGB(255,160,40)
	elseif rollStreak > 0 then
		streakLabel.Text = "Skip streak: "..rollStreak.."x"
		streakLabel.TextColor3 = Color3.fromRGB(200,200,200)
	else
		streakLabel.Text = ""
	end
end

-- ══════════════════════════════════════════════
--  ROLL
-- ══════════════════════════════════════════════
local diceEmojis = {"⚀","⚁","⚂","⚃","⚄","⚅"}
rollBtn.MouseButton1Click:Connect(function()
	if isRolling or waitingChoice then return end
	if #activeSkills >= MAX_SLOTS then
		skillName.Text = "⚠️ Slot penuh!"
		skillDesc.Text = "Hover slot lalu klik untuk remove skill."
		return
	end
	isRolling=true
	rollBtn.Text="Rolling..." ; rollBtn.BackgroundColor3=Color3.fromRGB(65,38,130)
	skillName.Text="Rolling..." ; skillDesc.Text=""
	local elapsed, interval = 0, 0.07
	while elapsed < 1.4 do
		diceLbl.Text = diceEmojis[math.random(1,#diceEmojis)]
		task.wait(interval)
		elapsed = elapsed+interval
		interval = math.min(interval+0.012, 0.22)
	end
	local excludeList = {}
	for id in pairs(activeIds) do table.insert(excludeList, id) end
	local origW
	if rollStreak >= 3 then
		origW = SkillList.RarityData.Legendary.weight
		SkillList.RarityData.Legendary.weight = origW + rollStreak*4
	end
	local skill = SkillList.PickRandom(excludeList)
	if rollStreak >= 3 and origW then
		SkillList.RarityData.Legendary.weight = origW
	end
	rollBtn.Text="🎲  ROLL THE DICE" ; rollBtn.BackgroundColor3=Color3.fromRGB(110,55,215)
	isRolling=false
	if not skill then
		diceLbl.Text="😵"
		skillName.Text="Semua skill sudah aktif!"
		skillDesc.Text="Clear dulu beberapa skill."
		return
	end
	diceLbl.Text=skill.icon
	skillName.Text=skill.name ; skillName.TextColor3=rCol(skill.rarity)
	skillDesc.Text=skill.desc
	showChoice(skill)
end)

useBtn.MouseButton1Click:Connect(function()
	if not pendingSkill then return end
	local skill = pendingSkill
	local ok,err = pcall(skill.apply, character, humanoid)
	if ok then
		table.insert(activeSkills, {skill=skill})
		activeIds[skill.id]=true
		rollStreak=0 ; updateStreak() ; rebuildSlots()
		skillName.Text="✅ "..skill.name
		skillName.TextColor3=rCol(skill.rarity)
		skillDesc.Text="Skill aktif! Hover slot untuk remove."
	else
		skillName.Text="❌ Gagal!" ; skillDesc.Text=tostring(err)
		skillName.TextColor3=Color3.fromRGB(255,100,100)
	end
	hideChoice()
end)

skipBtn.MouseButton1Click:Connect(function()
	rollStreak=rollStreak+1 ; updateStreak()
	skillName.Text="Roll the dice!" ; skillName.TextColor3=Color3.fromRGB(215,185,255)
	skillDesc.Text="Dilewatin! Roll lagi buat skill baru."
	diceLbl.Text="🎲" ; hideChoice()
end)

clearBtn.MouseButton1Click:Connect(function()
	for _,entry in ipairs(activeSkills) do pcall(entry.skill.remove, character, humanoid) end
	activeSkills={} ; activeIds={} ; rollStreak=0 ; updateStreak() ; rebuildSlots()
	skillName.Text="Roll the dice!" ; skillName.TextColor3=Color3.fromRGB(215,185,255)
	skillDesc.Text="Semua skill di-reset! ✨" ; diceLbl.Text="🎲"
end)

-- ══════════════════════════════════════════════
--  HOVER
-- ══════════════════════════════════════════════
local function hover(btn,n,h)
	btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=h}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=n}):Play() end)
end
hover(rollBtn, Color3.fromRGB(110,55,215), Color3.fromRGB(140,75,255))
hover(useBtn,  Color3.fromRGB(70,195,110), Color3.fromRGB(50,225,90))
hover(skipBtn, Color3.fromRGB(200,70,70),  Color3.fromRGB(230,50,50))
hover(clearBtn,Color3.fromRGB(50,35,75),   Color3.fromRGB(70,50,110))

-- ══════════════════════════════════════════════
--  OPEN ANIMATION
-- ══════════════════════════════════════════════
win.Size = UDim2.new(0,0,0,0)
win.Position = UDim2.new(0.5,0,0.5,0)
cont.Visible = false
task.wait(0.05)
TweenService:Create(win,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
	Size=UDim2.new(0,400,0,600),
	Position=UDim2.new(0.5,-200,0.5,-300)
}):Play()
task.wait(0.3) ; cont.Visible=true

print("[DiceCore] ✅ Loaded! Skill_List inline, no require needed. Semoga dapat Legendary 🟡")
