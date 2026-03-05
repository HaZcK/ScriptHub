-- ╔══════════════════════════════════════════════════════════════╗
-- ║                   DICE OF FATE — DiceServer                  ║
-- ║         Taruh MANUAL di: ServerScriptService > DiceServer    ║
-- ║                        Version 2.0                           ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")

-- ══════════════════════════════════════════════════════
--  REMOTE SETUP
-- ══════════════════════════════════════════════════════
local function makeRemote(name, parent, class)
	local old = parent:FindFirstChild(name)
	if old then old:Destroy() end
	local r = Instance.new(class or "RemoteEvent")
	r.Name = name
	r.Parent = parent
	return r
end

-- FREEDICE   = tanda server support aktif
-- DICE_ACTION = skill apply/remove/clearall
-- DICE_TRADE  = trade skill antar player
-- DICE_GIVEGUI= broadcast GUI ke semua player
local FREEDICE    = makeRemote("FREEDICE",    ReplicatedStorage)
local DICE_ACTION = makeRemote("DICE_ACTION", ReplicatedStorage)
local DICE_TRADE  = makeRemote("DICE_TRADE",  ReplicatedStorage)
local DICE_GIVEGUI= makeRemote("DICE_GIVEGUI",ReplicatedStorage)
local DICE_PING   = makeRemote("DICE_PING",   ReplicatedStorage, "RemoteFunction")

-- Ping handler — client tanya "server ada?" server jawab true
DICE_PING.OnServerInvoke = function(player)
	return true
end

print("[DiceServer] ✅ All remotes created")

-- ══════════════════════════════════════════════════════
--  SKILL REGISTRY
--  Semua efek server-side didefinisikan di sini.
--  Format setiap skill:
--
--  ["skill_id"] = {
--      apply  = function(char, hum) ... end,
--      remove = function(char, hum) ... end,
--      loop   = true/false,  -- kalau true, server loop tiap 0.1s
--      loopFn = function(char, hum) ... end,  -- isi loop
--  }
--
--  Untuk tambah custom skill:
--  1. Tambah entry baru di bawah dengan id yang sama seperti di DiceCore
--  2. Isi apply dan remove
--  3. Kalau butuh efek terus-menerus (rainbow, lava, dll) set loop=true
-- ══════════════════════════════════════════════════════
local SkillRegistry = {}

-- ── HELPER ──
local function resetBody(char, hum)
	hum.WalkSpeed = 16
	hum.JumpPower = 50
	for _,p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Transparency = 0
			p.Material = Enum.Material.SmoothPlastic
			p.Color = Color3.fromRGB(163,162,165)
		end
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		local bf = hrp:FindFirstChild("_AntiGrav")
		if bf then bf:Destroy() end
	end
end

-- ══════════════════════════════
--  ⬇ SKILL DEFINITIONS ⬇
-- ══════════════════════════════

SkillRegistry["speed_demon"] = {
	apply = function(c,h) h.WalkSpeed = 100 end,
	remove = function(c,h) h.WalkSpeed = 16 end,
}

SkillRegistry["super_jump"] = {
	apply = function(c,h) h.JumpPower = 200 end,
	remove = function(c,h) h.JumpPower = 50 end,
}

SkillRegistry["giant_head"] = {
	apply = function(c,h)
		local head = c:FindFirstChild("Head")
		if head then head.Size = Vector3.new(5,5,5) end
	end,
	remove = function(c,h)
		local head = c:FindFirstChild("Head")
		if head then head.Size = Vector3.new(2,1,1) end
	end,
}

SkillRegistry["tiny_legs"] = {
	apply = function(c,h)
		for _,n in ipairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do
			local p = c:FindFirstChild(n)
			if p then p.Size = Vector3.new(0.4,0.4,0.4) end
		end
	end,
	remove = function(c,h)
		for _,n in ipairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do
			local p = c:FindFirstChild(n)
			if p then p.Size = Vector3.new(1,1,1) end
		end
	end,
}

SkillRegistry["buff_arms"] = {
	apply = function(c,h)
		for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
			local p = c:FindFirstChild(n)
			if p then p.Size = Vector3.new(2.5,2.5,2.5) end
		end
	end,
	remove = function(c,h)
		for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
			local p = c:FindFirstChild(n)
			if p then p.Size = Vector3.new(1,1,1) end
		end
	end,
}

SkillRegistry["noodle_arms"] = {
	apply = function(c,h)
		for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
			local p = c:FindFirstChild(n)
			if p then p.Size = Vector3.new(0.3,3.5,0.3) end
		end
	end,
	remove = function(c,h)
		for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
			local p = c:FindFirstChild(n)
			if p then p.Size = Vector3.new(1,1,1) end
		end
	end,
}

SkillRegistry["phantom"] = {
	apply = function(c,h)
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0.8 end
		end
	end,
	remove = function(c,h)
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.Transparency = 0 end
		end
	end,
}

SkillRegistry["golden_skin"] = {
	apply = function(c,h)
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
				p.BrickColor = BrickColor.new("Bright yellow")
			end
		end
	end,
	remove = function(c,h)
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.Color = Color3.fromRGB(163,162,165) end
		end
	end,
}

SkillRegistry["rainbow_body"] = {
	loop = true,
	loopFn = function(c,h)
		local t = tick()
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
				p.Color = Color3.fromHSV((t*0.5 + p.Name:len()*0.05) % 1, 1, 1)
			end
		end
	end,
	apply = function(c,h) end,
	remove = function(c,h)
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.Color = Color3.fromRGB(163,162,165) end
		end
	end,
}

SkillRegistry["anti_gravity"] = {
	apply = function(c,h)
		h.JumpPower = 150
		local hrp = c:FindFirstChild("HumanoidRootPart")
		if hrp then
			local old = hrp:FindFirstChild("_AntiGrav")
			if old then old:Destroy() end
			local bf = Instance.new("BodyForce")
			bf.Name = "_AntiGrav"
			bf.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass() * 0.75, 0)
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
}

SkillRegistry["ice_body"] = {
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
}

SkillRegistry["lava_trail"] = {
	loop = true,
	loopFn = function(c,h)
		local hrp = c:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		if h.MoveDirection.Magnitude < 0.1 then return end
		local fire = Instance.new("Part")
		fire.Size = Vector3.new(1.5,0.2,1.5)
		fire.CFrame = CFrame.new(hrp.Position - Vector3.new(0,3,0))
		fire.Anchored = true ; fire.CanCollide = false
		fire.BrickColor = BrickColor.new("Bright orange")
		fire.Material = Enum.Material.Neon
		fire.Parent = workspace
		local f = Instance.new("Fire", fire)
		f.Heat = 8 ; f.Size = 5
		game:GetService("Debris"):AddItem(fire, 2)
	end,
	apply = function(c,h) end,
	remove = function(c,h) end,
}

SkillRegistry["spinning_head"] = {
	loop = true,
	loopFn = function(c,h)
		local head = c:FindFirstChild("Head")
		if head then head.CFrame = head.CFrame * CFrame.Angles(0, math.rad(15), 0) end
	end,
	apply = function(c,h) end,
	remove = function(c,h) end,
}

SkillRegistry["ant_size"] = {
	apply = function(c,h)
		h.WalkSpeed = 10
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Size = p.Size * 0.3 end
		end
	end,
	remove = function(c,h)
		h.WalkSpeed = 16
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Size = p.Size / 0.3 end
		end
	end,
}

SkillRegistry["giant_mode"] = {
	apply = function(c,h)
		h.WalkSpeed = 24 ; h.JumpPower = 80
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Size = p.Size * 3 end
		end
	end,
	remove = function(c,h)
		h.WalkSpeed = 16 ; h.JumpPower = 50
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Size = p.Size / 3 end
		end
	end,
}

SkillRegistry["magnet_body"] = {
	loop = true,
	loopFn = function(c,h)
		local hrp = c:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		for _,obj in ipairs(workspace:GetChildren()) do
			if obj:IsA("BasePart") and not obj.Anchored and obj ~= hrp and not c:IsAncestorOf(obj) then
				local dist = (obj.Position - hrp.Position).Magnitude
				if dist < 25 and dist > 0.1 then
					obj.AssemblyLinearVelocity = obj.AssemblyLinearVelocity
						+ (hrp.Position - obj.Position).Unit * (180/dist)
				end
			end
		end
	end,
	apply = function(c,h) end,
	remove = function(c,h) end,
}

SkillRegistry["time_warp"] = {
	apply = function(c,h)
		workspace.Gravity = 20
		h.WalkSpeed = 80 ; h.JumpPower = 120
	end,
	remove = function(c,h)
		workspace.Gravity = 196.2
		h.WalkSpeed = 16 ; h.JumpPower = 50
	end,
}

SkillRegistry["god_mode"] = {
	loop = true,
	loopFn = function(c,h)
		local t = tick()
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
				p.Color = Color3.fromHSV((t*1.5 + p.Name:len()*0.1) % 1, 1, 1)
				p.Material = Enum.Material.Neon
			end
		end
	end,
	apply = function(c,h)
		h.WalkSpeed = 80 ; h.JumpPower = 180
		local head = c:FindFirstChild("Head")
		if head then head.Size = Vector3.new(5,5,5) end
	end,
	remove = function(c,h)
		h.WalkSpeed = 16 ; h.JumpPower = 50
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then
				p.Material = Enum.Material.SmoothPlastic
				p.Color = Color3.fromRGB(163,162,165)
			end
		end
		local head = c:FindFirstChild("Head")
		if head then head.Size = Vector3.new(2,1,1) end
	end,
}

-- ══════════════════════════════════════════════════════
--  CUSTOM SKILL TEMPLATE
--  Copy blok ini dan ganti isinya untuk tambah skill baru!
--
-- SkillRegistry["id_skill_kamu"] = {
--     apply = function(c, h)
--         -- c = Character, h = Humanoid
--         -- Tulis efek saat skill diaktifkan di sini
--         h.WalkSpeed = 50
--     end,
--     remove = function(c, h)
--         -- Tulis cara balik ke normal di sini
--         h.WalkSpeed = 16
--     end,
--     -- Opsional: kalau butuh efek loop (terus jalan)
--     loop = true,
--     loopFn = function(c, h)
--         -- Ini dipanggil tiap 0.1 detik selama skill aktif
--     end,
-- }
-- ══════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════
--  LOOP MANAGER
-- ══════════════════════════════════════════════════════
local activeLoops = {}  -- [userId] = { [skillId] = thread }

local function startLoop(player, skillId, char, hum)
	local reg = SkillRegistry[skillId]
	if not reg or not reg.loop then return end
	local userId = player.UserId
	if not activeLoops[userId] then activeLoops[userId] = {} end
	-- Stop existing loop kalau ada
	if activeLoops[userId][skillId] then
		task.cancel(activeLoops[userId][skillId])
	end
	activeLoops[userId][skillId] = task.spawn(function()
		while char and char.Parent and char:GetAttribute("skill_"..skillId) do
			pcall(reg.loopFn, char, hum)
			task.wait(0.1)
		end
	end)
end

local function stopLoop(player, skillId)
	local userId = player.UserId
	if activeLoops[userId] and activeLoops[userId][skillId] then
		task.cancel(activeLoops[userId][skillId])
		activeLoops[userId][skillId] = nil
	end
end

-- ══════════════════════════════════════════════════════
--  MAIN ACTION HANDLER
-- ══════════════════════════════════════════════════════
DICE_ACTION.OnServerEvent:Connect(function(player, action, data)
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if action == "Apply" then
		local skillId = data
		local reg = SkillRegistry[skillId]
		if not reg then
			warn("[DiceServer] Unknown skill:", skillId)
			return
		end
		pcall(reg.apply, char, hum)
		char:SetAttribute("skill_"..skillId, true)
		startLoop(player, skillId, char, hum)
		print("[DiceServer] ✅ "..player.Name.." → Apply: "..skillId)

	elseif action == "Remove" then
		local skillId = data
		local reg = SkillRegistry[skillId]
		char:SetAttribute("skill_"..skillId, nil)
		stopLoop(player, skillId)
		if reg then pcall(reg.remove, char, hum) end
		print("[DiceServer] 🗑 "..player.Name.." → Remove: "..skillId)

	elseif action == "ClearAll" then
		-- Stop semua loop
		for skillId, _ in pairs(activeLoops[player.UserId] or {}) do
			stopLoop(player, skillId)
		end
		-- Remove semua skill
		for skillId, reg in pairs(SkillRegistry) do
			char:SetAttribute("skill_"..skillId, nil)
			pcall(reg.remove, char, hum)
		end
		-- Hard reset
		pcall(resetBody, char, hum)
		workspace.Gravity = 196.2
		print("[DiceServer] 🗑 "..player.Name.." → Clear All")
	end
end)

-- ══════════════════════════════════════════════════════
--  TRADE HANDLER
-- ══════════════════════════════════════════════════════
DICE_TRADE.OnServerEvent:Connect(function(sender, action, targetName, skillData)

	if action == "Offer" then
		-- Cari target player
		local target = Players:FindFirstChild(targetName)
		if not target then return end
		-- Forward offer ke target
		DICE_TRADE:FireClient(target, "IncomingOffer", sender.Name, skillData)
		print("[DiceServer] 🤝 Trade offer: "..sender.Name.." → "..targetName)

	elseif action == "Accept" then
		-- skillData = { senderName, skillId, skillName, skillIcon, skillRarity }
		local senderName = skillData.from
		local senderPlayer = Players:FindFirstChild(senderName)
		if not senderPlayer then return end
		-- Konfirmasi ke sender bahwa trade diterima
		DICE_TRADE:FireClient(senderPlayer, "TradeAccepted", sender.Name, skillData)
		-- Konfirmasi ke receiver
		DICE_TRADE:FireClient(sender, "TradeComplete", skillData)
		print("[DiceServer] ✅ Trade accepted: "..senderName.." ↔ "..sender.Name)

	elseif action == "Decline" then
		local senderName = skillData.from
		local senderPlayer = Players:FindFirstChild(senderName)
		if senderPlayer then
			DICE_TRADE:FireClient(senderPlayer, "TradeDeclined", sender.Name)
		end
		print("[DiceServer] ❌ Trade declined by "..sender.Name)
	end
end)

-- ══════════════════════════════════════════════════════
--  GIVE ALL GUI HANDLER
--  Ketika host aktifkan "Give All", semua player dapat GUI
-- ══════════════════════════════════════════════════════
DICE_GIVEGUI.OnServerEvent:Connect(function(sender, action)
	if action == "GiveAll" then
		print("[DiceServer] 📡 "..sender.Name.." broadcasting GUI to all players...")
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= sender then
				DICE_GIVEGUI:FireClient(p, "ReceiveGUI")
			end
		end
	end
end)

-- Cleanup saat player leave
Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	if activeLoops[userId] then
		for skillId, _ in pairs(activeLoops[userId]) do
			stopLoop(player, skillId)
		end
		activeLoops[userId] = nil
	end
end)

print("[DiceServer] 🎲 Version 2.0 Ready!")
print("[DiceServer] Remotes: FREEDICE | DICE_ACTION | DICE_TRADE | DICE_GIVEGUI | DICE_PING")
