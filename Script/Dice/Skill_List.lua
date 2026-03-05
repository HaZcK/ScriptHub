-- ╔══════════════════════════════════════════════╗
-- ║              SKILL_LIST ModuleScript         ║
-- ║  Taruh di: ReplicatedStorage > Skill_List   ║
-- ╚══════════════════════════════════════════════╝
-- Tambah skill baru tinggal copy format dibawah!

local RunService = game:GetService("RunService")

local SkillList = {}

-- ══════════════════════════════════════════
--  RARITY SYSTEM
--  "Common"   = 50% chance
--  "Rare"     = 30% chance
--  "Epic"     = 15% chance
--  "Legendary"= 5%  chance
-- ══════════════════════════════════════════

SkillList.Skills = {

	-- ───────────── COMMON ─────────────
	{
		id       = "speed_demon",
		name     = "💨 Speed Demon",
		desc     = "WalkSpeed jadi 100. Ngebut kayak angin!",
		icon     = "💨",
		rarity   = "Common",
		apply = function(char, hum)
			hum.WalkSpeed = 100
		end,
		remove = function(char, hum)
			hum.WalkSpeed = 16
		end
	},

	{
		id       = "super_jump",
		name     = "🚀 Super Jump",
		desc     = "JumpPower jadi 200. Bisa nyentuh orbit!",
		icon     = "🚀",
		rarity   = "Common",
		apply = function(char, hum)
			hum.JumpPower = 200
		end,
		remove = function(char, hum)
			hum.JumpPower = 50
		end
	},

	{
		id       = "giant_head",
		name     = "🗿 Giant Head",
		desc     = "Kepala jadi SUPER GEDE kayak batu gajah.",
		icon     = "🗿",
		rarity   = "Common",
		apply = function(char, hum)
			local head = char:FindFirstChild("Head")
			if head then head.Size = Vector3.new(4, 4, 4) end
		end,
		remove = function(char, hum)
			local head = char:FindFirstChild("Head")
			if head then head.Size = Vector3.new(2, 1, 1) end
		end
	},

	{
		id       = "tiny_legs",
		name     = "🦵 Tiny Legs",
		desc     = "Kaki mengecil drastis. Jalannya lucu banget.",
		icon     = "🦵",
		rarity   = "Common",
		apply = function(char, hum)
			hum.BodyHeightScale.Value = 0.6
		end,
		remove = function(char, hum)
			hum.BodyHeightScale.Value = 1
		end
	},

	{
		id       = "fat_arms",
		name     = "💪 Buff Arms",
		desc     = "Lengan super gede. Siap tinju meteor!",
		icon     = "💪",
		rarity   = "Common",
		apply = function(char, hum)
			hum.BodyWidthScale.Value = 2.2
		end,
		remove = function(char, hum)
			hum.BodyWidthScale.Value = 1
		end
	},

	{
		id       = "noodle_arms",
		name     = "🍜 Noodle Arms",
		desc     = "Lengan super panjang menjuntai ke tanah.",
		icon     = "🍜",
		rarity   = "Common",
		apply = function(char, hum)
			hum.BodyDepthScale.Value = 0.4
			hum.BodyWidthScale.Value = 0.4
		end,
		remove = function(char, hum)
			hum.BodyDepthScale.Value = 1
			hum.BodyWidthScale.Value = 1
		end
	},

	{
		id       = "invisible",
		name     = "👻 Phantom Mode",
		desc     = "Badan transparan 80%. Kayak hantu!",
		icon     = "👻",
		rarity   = "Common",
		apply = function(char, hum)
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.Transparency = 0.8
				end
			end
		end,
		remove = function(char, hum)
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 0
				end
			end
		end
	},

	{
		id       = "golden_skin",
		name     = "✨ Golden Touch",
		desc     = "Seluruh badan jadi emas berkilau!",
		icon     = "✨",
		rarity   = "Common",
		apply = function(char, hum)
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.BrickColor = BrickColor.new("Bright yellow")
					part.Material = Enum.Material.SmoothPlastic
				end
			end
		end,
		remove = function(char, hum)
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.BrickColor = BrickColor.new("Medium stone grey")
					part.Material = Enum.Material.SmoothPlastic
				end
			end
		end
	},

	-- ───────────── RARE ─────────────
	{
		id       = "rainbow_body",
		name     = "🌈 Rainbow Body",
		desc     = "Warna badan berubah pelangi terus-menerus!",
		icon     = "🌈",
		rarity   = "Rare",
		apply = function(char, hum)
			local colors = {
				Color3.fromRGB(255,60,60),
				Color3.fromRGB(255,165,0),
				Color3.fromRGB(255,240,0),
				Color3.fromRGB(60,210,60),
				Color3.fromRGB(40,120,255),
				Color3.fromRGB(160,40,255),
			}
			local idx = 1
			local conn
			conn = RunService.Heartbeat:Connect(function()
				if not char or not char.Parent then conn:Disconnect() return end
				idx = (idx % #colors) + 1
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						part.Color = colors[idx]
					end
				end
			end)
			char:SetAttribute("RainbowConn", tostring(conn))
			-- store conn reference in char attributes workaround
			rawset(char, "_rainbowConn", conn)
		end,
		remove = function(char, hum)
			local conn = rawget(char, "_rainbowConn")
			if conn then conn:Disconnect() end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Color = Color3.fromRGB(163,162,165)
				end
			end
		end
	},

	{
		id       = "anti_gravity",
		name     = "🪐 Anti Gravity",
		desc     = "Gravitasi berkurang. Lompat terasa melayang!",
		icon     = "🪐",
		rarity   = "Rare",
		apply = function(char, hum)
			hum.JumpPower = 130
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local bf = Instance.new("BodyForce")
				bf.Name = "_AntiGrav"
				bf.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass() * 0.72, 0)
				bf.Parent = hrp
			end
		end,
		remove = function(char, hum)
			hum.JumpPower = 50
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local bf = hrp:FindFirstChild("_AntiGrav")
				if bf then bf:Destroy() end
			end
		end
	},

	{
		id       = "ice_body",
		name     = "🧊 Frozen Soul",
		desc     = "Badan jadi es transparan biru. Dingin sampe jiwa.",
		icon     = "🧊",
		rarity   = "Rare",
		apply = function(char, hum)
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.BrickColor = BrickColor.new("Pastel blue")
					part.Material = Enum.Material.Ice
					part.Transparency = 0.35
				end
			end
		end,
		remove = function(char, hum)
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Material = Enum.Material.SmoothPlastic
					part.Transparency = 0
				end
			end
		end
	},

	{
		id       = "lava_trail",
		name     = "🔥 Lava Trail",
		desc     = "Ninggalin jejak api lava di mana pun kamu jalan!",
		icon     = "🔥",
		rarity   = "Rare",
		apply = function(char, hum)
			local conn
			conn = RunService.Heartbeat:Connect(function()
				if not char or not char.Parent then conn:Disconnect() return end
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp and hum.MoveDirection.Magnitude > 0.1 then
					local fire = Instance.new("Part")
					fire.Size = Vector3.new(1.2, 0.2, 1.2)
					fire.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
					fire.Anchored = true
					fire.CanCollide = false
					fire.BrickColor = BrickColor.new("Bright orange")
					fire.Material = Enum.Material.Neon
					fire.Parent = workspace
					local f = Instance.new("Fire")
					f.Heat = 6
					f.Size = 4
					f.Parent = fire
					game:GetService("Debris"):AddItem(fire, 1.8)
				end
			end)
			rawset(char, "_lavaConn", conn)
		end,
		remove = function(char, hum)
			local conn = rawget(char, "_lavaConn")
			if conn then conn:Disconnect() end
		end
	},

	{
		id       = "spinning_head",
		name     = "🌀 Spinning Head",
		desc     = "Kepala muter nonstop. Pusing liatnya!",
		icon     = "🌀",
		rarity   = "Rare",
		apply = function(char, hum)
			local conn
			conn = RunService.Heartbeat:Connect(function(dt)
				if not char or not char.Parent then conn:Disconnect() return end
				local head = char:FindFirstChild("Head")
				if head then
					head.CFrame = head.CFrame * CFrame.Angles(0, math.rad(280 * dt), 0)
				end
			end)
			rawset(char, "_spinConn", conn)
		end,
		remove = function(char, hum)
			local conn = rawget(char, "_spinConn")
			if conn then conn:Disconnect() end
		end
	},

	-- ───────────── EPIC ─────────────
	{
		id       = "ant_size",
		name     = "🐜 Ant Size",
		desc     = "Tubuh mengecil jadi 0.3x ukuran normal. Super imut!",
		icon     = "🐜",
		rarity   = "Epic",
		apply = function(char, hum)
			hum.BodyDepthScale.Value  = 0.3
			hum.BodyHeightScale.Value = 0.3
			hum.BodyWidthScale.Value  = 0.3
			hum.HeadScale.Value       = 0.3
		end,
		remove = function(char, hum)
			hum.BodyDepthScale.Value  = 1
			hum.BodyHeightScale.Value = 1
			hum.BodyWidthScale.Value  = 1
			hum.HeadScale.Value       = 1
		end
	},

	{
		id       = "giant_mode",
		name     = "🏔️ Giant Mode",
		desc     = "Tumbuh jadi raksasa 3x ukuran normal!",
		icon     = "🏔️",
		rarity   = "Epic",
		apply = function(char, hum)
			hum.BodyDepthScale.Value  = 3
			hum.BodyHeightScale.Value = 3
			hum.BodyWidthScale.Value  = 3
			hum.HeadScale.Value       = 3
		end,
		remove = function(char, hum)
			hum.BodyDepthScale.Value  = 1
			hum.BodyHeightScale.Value = 1
			hum.BodyWidthScale.Value  = 1
			hum.HeadScale.Value       = 1
		end
	},

	{
		id       = "backwards_brain",
		name     = "🔄 Backwards Brain",
		desc     = "Kamera terbalik 180°! Maju jadi mundur.",
		icon     = "🔄",
		rarity   = "Epic",
		apply = function(char, hum)
			local cam = workspace.CurrentCamera
			cam.CameraType = Enum.CameraType.Scriptable
			local conn
			conn = RunService.Heartbeat:Connect(function()
				if not char or not char.Parent then conn:Disconnect() return end
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 6, 12))
						* CFrame.Angles(-0.15, math.pi, 0)
				end
			end)
			rawset(char, "_backConn", conn)
		end,
		remove = function(char, hum)
			local conn = rawget(char, "_backConn")
			if conn then conn:Disconnect() end
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		end
	},

	{
		id       = "magnet_body",
		name     = "🧲 Magnet Body",
		desc     = "Benda-benda di sekitar kamu tertarik kayak magnet!",
		icon     = "🧲",
		rarity   = "Epic",
		apply = function(char, hum)
			local conn
			conn = RunService.Heartbeat:Connect(function()
				if not char or not char.Parent then conn:Disconnect() return end
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				for _, obj in ipairs(workspace:GetChildren()) do
					if obj:IsA("BasePart") and not obj.Anchored
						and obj ~= hrp and not char:IsAncestorOf(obj) then
						local dist = (obj.Position - hrp.Position).Magnitude
						if dist < 20 then
							local dir = (hrp.Position - obj.Position).Unit
							obj.Velocity = obj.Velocity + dir * (200 / dist)
						end
					end
				end
			end)
			rawset(char, "_magnetConn", conn)
		end,
		remove = function(char, hum)
			local conn = rawget(char, "_magnetConn")
			if conn then conn:Disconnect() end
		end
	},

	-- ───────────── LEGENDARY ─────────────
	{
		id       = "time_slow",
		name     = "⏳ Time Warp",
		desc     = "LEGENDARY! Waktu melambat tapi kamu tetap cepat!",
		icon     = "⏳",
		rarity   = "Legendary",
		apply = function(char, hum)
			-- Slowing other players visually via workspace speed (solo only!)
			workspace.Gravity = 19.6  -- 1/5 gravity
			hum.WalkSpeed = 80
			hum.JumpPower = 100
		end,
		remove = function(char, hum)
			workspace.Gravity = 196.2
			hum.WalkSpeed = 16
			hum.JumpPower = 50
		end
	},

	{
		id       = "god_mode",
		name     = "⚡ God Mode",
		desc     = "LEGENDARY! Kamu dapat SEMUA buff sekaligus. Pure chaos!",
		icon     = "⚡",
		rarity   = "Legendary",
		apply = function(char, hum)
			hum.WalkSpeed = 80
			hum.JumpPower = 180
			hum.BodyDepthScale.Value  = 1.5
			hum.BodyHeightScale.Value = 1.5
			hum.BodyWidthScale.Value  = 1.5
			hum.HeadScale.Value       = 2

			local conn
			conn = RunService.Heartbeat:Connect(function(dt)
				if not char or not char.Parent then conn:Disconnect() return end
				local t = tick()
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						part.Color = Color3.fromHSV((t * 0.5 + part.Name:len() * 0.1) % 1, 1, 1)
					end
				end
			end)
			rawset(char, "_godConn", conn)
		end,
		remove = function(char, hum)
			local conn = rawget(char, "_godConn")
			if conn then conn:Disconnect() end
			hum.WalkSpeed = 16
			hum.JumpPower = 50
			hum.BodyDepthScale.Value  = 1
			hum.BodyHeightScale.Value = 1
			hum.BodyWidthScale.Value  = 1
			hum.HeadScale.Value       = 1
		end
	},

}

-- ══════════════════════════════════════════
--  RARITY CONFIG (warna & bobot)
-- ══════════════════════════════════════════
SkillList.RarityData = {
	Common    = { color = Color3.fromRGB(180,180,180), weight = 50, glow = Color3.fromRGB(200,200,200) },
	Rare      = { color = Color3.fromRGB(80,140,255),  weight = 30, glow = Color3.fromRGB(100,160,255) },
	Epic      = { color = Color3.fromRGB(180,80,255),  weight = 15, glow = Color3.fromRGB(200,100,255) },
	Legendary = { color = Color3.fromRGB(255,180,0),   weight = 5,  glow = Color3.fromRGB(255,220,80)  },
}

-- ══════════════════════════════════════════
--  WEIGHTED RANDOM PICK
-- ══════════════════════════════════════════
function SkillList.PickRandom(excludeIds)
	excludeIds = excludeIds or {}
	local excludeSet = {}
	for _, id in ipairs(excludeIds) do excludeSet[id] = true end

	-- Build weighted pool
	local pool = {}
	for _, skill in ipairs(SkillList.Skills) do
		if not excludeSet[skill.id] then
			local w = SkillList.RarityData[skill.rarity].weight
			for _ = 1, w do
				table.insert(pool, skill)
			end
		end
	end

	if #pool == 0 then return nil end
	return pool[math.random(1, #pool)]
end

return SkillList
