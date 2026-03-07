-- ╔══════════════════════════════════════════════════════════════╗
-- ║               DICE OF FATE — DiceServer.lua                  ║
-- ║                                                              ║
-- ║  Taruh di ServerScriptService                                ║
-- ║  Tidak perlu edit apapun di sini.                            ║
-- ║  Semua skill custom cukup di DicePlayer.lua saja.            ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

-- ── Buat Remote Events / Functions ──────────────────────────────────
local function mkRemote(name, class)
	local r = ReplicatedStorage:FindFirstChild(name)
	if not r then
		r = Instance.new(class); r.Name = name; r.Parent = ReplicatedStorage
	end
	return r
end

local FREEDICE  = mkRemote("FREEDICE",    "RemoteEvent")
local R_PING    = mkRemote("DICE_PING",   "RemoteFunction")
local R_ACTION  = mkRemote("DICE_ACTION", "RemoteEvent")
local R_TRADE   = mkRemote("DICE_TRADE",  "RemoteEvent")
local R_GIVE    = mkRemote("DICE_GIVEGUI","RemoteEvent")

-- ── Ping handler ─────────────────────────────────────────────────────
R_PING.OnServerInvoke = function(player)
	return true
end

-- ══════════════════════════════════════════════════════════════════
--  UNIVERSAL SKILL HANDLER
--  Server tidak perlu tahu isi skill.
--  Client kirim efek apa yang harus dijalankan (EffectType + data).
--  Server apply ke character player yang bersangkutan.
-- ══════════════════════════════════════════════════════════════════

-- Simpan loop connections per player per skill
local ActiveLoops = {}  -- ActiveLoops[player][skillId] = connection

local function getLoop(plr, id)
	if not ActiveLoops[plr] then ActiveLoops[plr] = {} end
	return ActiveLoops[plr][id]
end
local function saveLoop(plr, id, conn)
	if not ActiveLoops[plr] then ActiveLoops[plr] = {} end
	if ActiveLoops[plr][id] then
		pcall(function() ActiveLoops[plr][id]:Disconnect() end)
	end
	ActiveLoops[plr][id] = conn
end
local function dropLoop(plr, id)
	if ActiveLoops[plr] and ActiveLoops[plr][id] then
		pcall(function() ActiveLoops[plr][id]:Disconnect() end)
		ActiveLoops[plr][id] = nil
	end
end
local function dropAllLoops(plr)
	if ActiveLoops[plr] then
		for id, conn in pairs(ActiveLoops[plr]) do
			pcall(function() conn:Disconnect() end)
		end
		ActiveLoops[plr] = nil
	end
end

-- Simpan original sizes per player
local OrigSizes = {}

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		OrigSizes[plr] = {}
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then OrigSizes[plr][p.Name] = p.Size end
		end
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	dropAllLoops(plr)
	OrigSizes[plr] = nil
end)

-- ── Helpers ──────────────────────────────────────────────────────────
local function getChar(plr)
	local char = plr.Character
	local hum  = char and char:FindFirstChildOfClass("Humanoid")
	return char, hum
end

local function resetBody(plr)
	local char, hum = getChar(plr)
	if not char then return end
	if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
	local orig = OrigSizes[plr] or {}
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") and orig[p.Name] then
			pcall(function() p.Size = orig[p.Name] end)
		end
	end
	pcall(function() workspace.Gravity = 196.2 end)
end

-- ── Built-in server effects ───────────────────────────────────────────
--  Client bisa kirim "EffectApply" dengan data:
--  { effect = "SetSpeed", value = 100 }
--  { effect = "SetJump",  value = 200 }
--  { effect = "ScalePart", part = "Head", size = {5,5,5} }
--  { effect = "SetColor", color = {255,180,0} }
--  { effect = "SetMaterial", material = "Ice" }
--  { effect = "SetTransparency", value = 0.8 }
--  { effect = "SetGravity", value = 20 }
--  { effect = "Rainbow" }
--  { effect = "LavaTrail" }
--  { effect = "SpinHead" }
--  { effect = "Magnet" }
--  { effect = "ResetBody" }

local function applyEffect(plr, skillId, data)
	local char, hum = getChar(plr)
	if not char then return end

	local eff = data.effect

	if eff == "SetSpeed" then
		if hum then hum.WalkSpeed = data.value or 16 end

	elseif eff == "SetJump" then
		if hum then hum.JumpPower = data.value or 50 end

	elseif eff == "SetGravity" then
		workspace.Gravity = data.value or 196.2

	elseif eff == "ScalePart" then
		local part = char:FindFirstChild(data.part)
		if part and data.size then
			part.Size = Vector3.new(data.size[1], data.size[2], data.size[3])
		end

	elseif eff == "ScaleGroup" then
		-- data.parts = {"LeftUpperArm","LeftLowerArm",...}
		-- data.size  = {x,y,z}
		for _, name in ipairs(data.parts or {}) do
			local p = char:FindFirstChild(name)
			if p and data.size then
				p.Size = Vector3.new(data.size[1], data.size[2], data.size[3])
			end
		end

	elseif eff == "ScaleAll" then
		-- data.mult = 3 (kali semua part)
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
				pcall(function() p.Size = p.Size * (data.mult or 1) end)
			end
		end

	elseif eff == "SetColor" then
		local col = data.color and Color3.fromRGB(data.color[1], data.color[2], data.color[3])
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
				if col then p.Color = col
				elseif data.brickColor then p.BrickColor = BrickColor.new(data.brickColor) end
			end
		end

	elseif eff == "SetMaterial" then
		local mat = Enum.Material[data.material] or Enum.Material.SmoothPlastic
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
				p.Material = mat
			end
		end

	elseif eff == "SetTransparency" then
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
				p.Transparency = data.value or 0
			end
		end

	elseif eff == "Rainbow" then
		saveLoop(plr, skillId, RunService.Heartbeat:Connect(function()
			local c2 = plr.Character; if not c2 then return end
			local t = tick()
			for _, p in ipairs(c2:GetDescendants()) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					p.Color = Color3.fromHSV((t * 0.5 + p.Name:len() * 0.05) % 1, 1, 1)
				end
			end
		end))

	elseif eff == "LavaTrail" then
		local last = 0
		saveLoop(plr, skillId, RunService.Heartbeat:Connect(function()
			local now = tick(); if now - last < 0.15 then return end
			local c2 = plr.Character
			local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
			local hrp = c2 and c2:FindFirstChild("HumanoidRootPart")
			if not hrp or not h2 or h2.MoveDirection.Magnitude < 0.1 then return end
			last = now
			local f = Instance.new("Part")
			f.Size = Vector3.new(2, 0.2, 2)
			f.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 3, 0))
			f.Anchored = true; f.CanCollide = false
			f.BrickColor = BrickColor.new("Bright orange")
			f.Material = Enum.Material.Neon; f.Parent = workspace
			Instance.new("Fire", f).Heat = 8
			game:GetService("Debris"):AddItem(f, 2)
		end))

	elseif eff == "SpinHead" then
		saveLoop(plr, skillId, RunService.Heartbeat:Connect(function(dt)
			local c2 = plr.Character; if not c2 then return end
			local head = c2:FindFirstChild("Head")
			if head then head.CFrame = head.CFrame * CFrame.Angles(0, math.rad(300 * dt), 0) end
		end))

	elseif eff == "Magnet" then
		saveLoop(plr, skillId, RunService.Heartbeat:Connect(function()
			local c2 = plr.Character; if not c2 then return end
			local hrp = c2:FindFirstChild("HumanoidRootPart"); if not hrp then return end
			for _, obj in ipairs(workspace:GetChildren()) do
				if obj:IsA("BasePart") and not obj.Anchored and obj ~= hrp and not c2:IsAncestorOf(obj) then
					local d = (obj.Position - hrp.Position).Magnitude
					if d < 25 and d > 0.1 then
						obj.AssemblyLinearVelocity = obj.AssemblyLinearVelocity
							+ (hrp.Position - obj.Position).Unit * (180 / d)
					end
				end
			end
		end))

	elseif eff == "GodMode" then
		if hum then hum.WalkSpeed = 80; hum.JumpPower = 180 end
		local head = char:FindFirstChild("Head")
		if head then head.Size = Vector3.new(5, 5, 5) end
		saveLoop(plr, skillId, RunService.Heartbeat:Connect(function()
			local c2 = plr.Character; if not c2 then return end
			local t = tick()
			for _, p in ipairs(c2:GetDescendants()) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					p.Color = Color3.fromHSV((t * 1.5 + p.Name:len() * 0.1) % 1, 1, 1)
					p.Material = Enum.Material.Neon
				end
			end
		end))

	elseif eff == "ResetBody" then
		dropAllLoops(plr)
		resetBody(plr)

	elseif eff == "StopLoop" then
		dropLoop(plr, skillId)

	elseif eff == "ResetColor" then
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				p.Color = Color3.fromRGB(163, 162, 165)
				p.Material = Enum.Material.SmoothPlastic
				p.Transparency = 0
			end
		end

	elseif eff == "ResetPart" then
		local orig = OrigSizes[plr] or {}
		if data.part then
			local p = char:FindFirstChild(data.part)
			if p and orig[data.part] then p.Size = orig[data.part] end
		end

	elseif eff == "ResetGroup" then
		local orig = OrigSizes[plr] or {}
		for _, name in ipairs(data.parts or {}) do
			local p = char:FindFirstChild(name)
			if p and orig[name] then p.Size = orig[name] end
		end

	elseif eff == "ResetAllParts" then
		local orig = OrigSizes[plr] or {}
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and orig[p.Name] then
				pcall(function() p.Size = orig[p.Name] end)
			end
		end

	elseif eff == "GiveF3X" then
		local ok, model = pcall(function()
			return game:GetService("InsertService"):LoadAsset(142785488)
		end)
		if ok and model then
			local bp = plr:FindFirstChild("Backpack")
			if bp then
				for _, t in ipairs(bp:GetChildren()) do
					if t:IsA("Tool") and (t.Name:find("Build") or t.Name:find("F3X")) then t:Destroy() end
				end
			end
			if char then
				for _, t in ipairs(char:GetChildren()) do
					if t:IsA("Tool") and (t.Name:find("Build") or t.Name:find("F3X")) then t:Destroy() end
				end
			end
			local tool = model:FindFirstChildOfClass("Tool")
			if tool then tool.Parent = plr.Backpack end
			model:Destroy()
		end

	elseif eff == "RemoveF3X" then
		local bp = plr:FindFirstChild("Backpack")
		if bp then
			for _, t in ipairs(bp:GetChildren()) do
				if t:IsA("Tool") and (t.Name:find("Build") or t.Name:find("F3X")) then t:Destroy() end
			end
		end
		if char then
			for _, t in ipairs(char:GetChildren()) do
				if t:IsA("Tool") and (t.Name:find("Build") or t.Name:find("F3X")) then t:Destroy() end
			end
		end

	elseif eff == "AntiGravity" then
		if hum then hum.JumpPower = 150 end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local old = hrp:FindFirstChild("_AG"); if old then old:Destroy() end
			local bf = Instance.new("BodyForce")
			bf.Name = "_AG"
			bf.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass() * 0.75, 0)
			bf.Parent = hrp
		end

	elseif eff == "RemoveAntiGravity" then
		if hum then hum.JumpPower = 50 end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then local bf = hrp:FindFirstChild("_AG"); if bf then bf:Destroy() end end
	end
end

-- ── Main action handler ───────────────────────────────────────────────
R_ACTION.OnServerEvent:Connect(function(plr, action, skillId, effectData)
	if action == "Effect" then
		-- Client kirim effect langsung
		-- effectData = { effect = "SetSpeed", value = 100 }
		pcall(function() applyEffect(plr, skillId, effectData or {}) end)

	elseif action == "StopLoop" then
		dropLoop(plr, skillId)

	elseif action == "ClearAll" then
		dropAllLoops(plr)
		resetBody(plr)
	end
end)

-- ── Trade handler ─────────────────────────────────────────────────────
R_TRADE.OnServerEvent:Connect(function(fromPlr, action, targetName, data)
	if action == "Offer" then
		local target = Players:FindFirstChild(targetName)
		if target then R_TRADE:FireClient(target, "IncomingOffer", fromPlr.Name, data) end

	elseif action == "Accept" then
		local from = Players:FindFirstChild(targetName)
		if from then
			R_TRADE:FireClient(from,    "TradeAccepted", fromPlr.Name, data)
			R_TRADE:FireClient(fromPlr, "TradeComplete", data)
		end

	elseif action == "Decline" then
		local from = Players:FindFirstChild(targetName)
		if from then R_TRADE:FireClient(from, "TradeDeclined", fromPlr.Name) end
	end
end)

-- ── Give All handler ──────────────────────────────────────────────────
R_GIVE.OnServerEvent:Connect(function(plr, action)
	if action == "GiveAll" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= plr then R_GIVE:FireClient(p, "ReceiveGUI") end
		end
	end
end)

print("[DiceServer] ✅ Ready — Universal skill handler aktif")
