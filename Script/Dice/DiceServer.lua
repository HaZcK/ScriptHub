-- ╔══════════════════════════════════════════════════════╗
-- ║                  DICE SERVER                         ║
-- ║  Taruh MANUAL di: ServerScriptService > DiceServer   ║
-- ║  Script ini yang "membuka pintu" supaya DiceCore     ║
-- ║  bisa jalankan efek yang keliatan semua player       ║
-- ╚══════════════════════════════════════════════════════╝

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ══════════════════════════════
--  BUAT REMOTE EVENT "FREEDICE"
--  Ini tanda bahwa server support aktif
-- ══════════════════════════════
local remote = Instance.new("RemoteEvent")
remote.Name   = "FREEDICE"
remote.Parent = ReplicatedStorage

print("[DiceServer] ✅ FREEDICE RemoteEvent aktif — Server support ON")

-- ══════════════════════════════
--  HANDLER DARI CLIENT
-- ══════════════════════════════
remote.OnServerEvent:Connect(function(player, action, data)

	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- ── APPLY SKILL ──
	if action == "ApplySkill" then
		local skillId = data

		-- WalkSpeed
		if skillId == "speed_demon" then
			humanoid.WalkSpeed = 100

		elseif skillId == "super_jump" then
			humanoid.JumpPower = 200

		-- Giant Head
		elseif skillId == "giant_head" then
			local head = character:FindFirstChild("Head")
			if head then head.Size = Vector3.new(5,5,5) end

		-- Tiny Legs
		elseif skillId == "tiny_legs" then
			for _, name in ipairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do
				local p = character:FindFirstChild(name)
				if p then p.Size = Vector3.new(0.4,0.4,0.4) end
			end

		-- Buff Arms
		elseif skillId == "buff_arms" then
			for _, name in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
				local p = character:FindFirstChild(name)
				if p then p.Size = Vector3.new(2.5,2.5,2.5) end
			end

		-- Noodle Arms
		elseif skillId == "noodle_arms" then
			for _, name in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
				local p = character:FindFirstChild(name)
				if p then p.Size = Vector3.new(0.3,3.5,0.3) end
			end

		-- Phantom
		elseif skillId == "phantom" then
			for _,p in ipairs(character:GetDescendants()) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					p.Transparency = 0.8
				end
			end

		-- Golden
		elseif skillId == "golden_skin" then
			for _,p in ipairs(character:GetDescendants()) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					p.BrickColor = BrickColor.new("Bright yellow")
					p.Material = Enum.Material.SmoothPlastic
				end
			end

		-- Ice
		elseif skillId == "ice_body" then
			for _,p in ipairs(character:GetDescendants()) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					p.BrickColor = BrickColor.new("Pastel blue")
					p.Material = Enum.Material.Ice
					p.Transparency = 0.35
				end
			end

		-- Anti Gravity
		elseif skillId == "anti_gravity" then
			humanoid.JumpPower = 150
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local old = hrp:FindFirstChild("_AntiGrav")
				if old then old:Destroy() end
				local bf = Instance.new("BodyForce")
				bf.Name  = "_AntiGrav"
				bf.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass() * 0.75, 0)
				bf.Parent = hrp
			end

		-- Lava Trail
		elseif skillId == "lava_trail" then
			-- Server spawn lava tiap player bergerak via loop
			task.spawn(function()
				local lastSpawn = 0
				while character and character.Parent do
					local now = tick()
					local hum2 = character:FindFirstChildOfClass("Humanoid")
					local hrp  = character:FindFirstChild("HumanoidRootPart")
					if hrp and hum2 and hum2.MoveDirection.Magnitude > 0.1 and now - lastSpawn > 0.15 then
						lastSpawn = now
						local fire = Instance.new("Part")
						fire.Size = Vector3.new(1.5,0.2,1.5)
						fire.CFrame = CFrame.new(hrp.Position - Vector3.new(0,3,0))
						fire.Anchored = true
						fire.CanCollide = false
						fire.BrickColor = BrickColor.new("Bright orange")
						fire.Material = Enum.Material.Neon
						fire.Parent = workspace
						local f = Instance.new("Fire", fire)
						f.Heat = 8 ; f.Size = 5
						game:GetService("Debris"):AddItem(fire, 2)
					end
					-- Cek kalau skill sudah di-remove
					local stillActive = character:GetAttribute("skill_lava_trail")
					if not stillActive then break end
					task.wait(0.05)
				end
			end)

		-- Ant Size
		elseif skillId == "ant_size" then
			humanoid.WalkSpeed = 10
			for _,p in ipairs(character:GetDescendants()) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					p.Size = p.Size * 0.3
				end
			end

		-- Giant Mode
		elseif skillId == "giant_mode" then
			humanoid.WalkSpeed = 24
			humanoid.JumpPower = 80
			for _,p in ipairs(character:GetDescendants()) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					p.Size = p.Size * 3
				end
			end

		-- Magnet Body
		elseif skillId == "magnet_body" then
			task.spawn(function()
				while character and character.Parent do
					local hrp = character:FindFirstChild("HumanoidRootPart")
					if not hrp then break end
					for _,obj in ipairs(workspace:GetChildren()) do
						if obj:IsA("BasePart") and not obj.Anchored
							and obj ~= hrp and not character:IsAncestorOf(obj) then
							local dist = (obj.Position - hrp.Position).Magnitude
							if dist < 25 and dist > 0.1 then
								obj.AssemblyLinearVelocity = obj.AssemblyLinearVelocity
									+ (hrp.Position - obj.Position).Unit * (180/dist)
							end
						end
					end
					local stillActive = character:GetAttribute("skill_magnet_body")
					if not stillActive then break end
					task.wait(0.05)
				end
			end)

		-- Time Warp
		elseif skillId == "time_warp" then
			workspace.Gravity = 20
			humanoid.WalkSpeed = 80
			humanoid.JumpPower = 120

		-- God Mode
		elseif skillId == "god_mode" then
			humanoid.WalkSpeed = 80
			humanoid.JumpPower = 180
			local head = character:FindFirstChild("Head")
			if head then head.Size = Vector3.new(5,5,5) end
			-- Rainbow loop server-side
			task.spawn(function()
				local colors = {
					Color3.fromRGB(255,50,50), Color3.fromRGB(255,150,0),
					Color3.fromRGB(255,255,0), Color3.fromRGB(0,220,0),
					Color3.fromRGB(0,100,255), Color3.fromRGB(180,0,255),
				}
				local idx = 1
				while character and character.Parent do
					idx = (idx % #colors) + 1
					for _,p in ipairs(character:GetDescendants()) do
						if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
							p.Color = colors[idx]
							p.Material = Enum.Material.Neon
						end
					end
					local stillActive = character:GetAttribute("skill_god_mode")
					if not stillActive then break end
					task.wait(0.1)
				end
			end)

		-- Rainbow Body
		elseif skillId == "rainbow_body" then
			task.spawn(function()
				local colors = {
					Color3.fromRGB(255,60,60), Color3.fromRGB(255,165,0),
					Color3.fromRGB(255,240,0), Color3.fromRGB(60,210,60),
					Color3.fromRGB(40,120,255), Color3.fromRGB(160,40,255),
				}
				local idx = 1
				while character and character.Parent do
					idx = (idx % #colors) + 1
					for _,p in ipairs(character:GetDescendants()) do
						if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
							p.Color = colors[idx]
						end
					end
					local stillActive = character:GetAttribute("skill_rainbow_body")
					if not stillActive then break end
					task.wait(0.1)
				end
			end)

		-- Spinning Head
		elseif skillId == "spinning_head" then
			task.spawn(function()
				while character and character.Parent do
					local head = character:FindFirstChild("Head")
					if head then
						head.CFrame = head.CFrame * CFrame.Angles(0, math.rad(15), 0)
					end
					local stillActive = character:GetAttribute("skill_spinning_head")
					if not stillActive then break end
					task.wait(0.05)
				end
			end)
		end

		-- Tandai skill aktif via Attribute (untuk loop checker)
		character:SetAttribute("skill_" .. skillId, true)
		print("[DiceServer] ✅ "..player.Name.." applied skill: "..skillId)

	-- ── REMOVE SKILL ──
	elseif action == "RemoveSkill" then
		local skillId = data

		-- Hapus attribute (menghentikan loop)
		character:SetAttribute("skill_" .. skillId, nil)

		-- Reset stats
		if skillId == "speed_demon" then
			humanoid.WalkSpeed = 16
		elseif skillId == "super_jump" then
			humanoid.JumpPower = 50
		elseif skillId == "anti_gravity" then
			humanoid.JumpPower = 50
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local bf = hrp:FindFirstChild("_AntiGrav")
				if bf then bf:Destroy() end
			end
		elseif skillId == "time_warp" then
			workspace.Gravity = 196.2
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
		elseif skillId == "god_mode" then
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
			for _,p in ipairs(character:GetDescendants()) do
				if p:IsA("BasePart") then
					p.Material = Enum.Material.SmoothPlastic
					p.Color = Color3.fromRGB(163,162,165)
				end
			end
		elseif skillId == "ant_size" or skillId == "giant_mode" then
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
		elseif skillId == "phantom" then
			for _,p in ipairs(character:GetDescendants()) do
				if p:IsA("BasePart") then p.Transparency = 0 end
			end
		elseif skillId == "rainbow_body" then
			for _,p in ipairs(character:GetDescendants()) do
				if p:IsA("BasePart") then p.Color = Color3.fromRGB(163,162,165) end
			end
		elseif skillId == "ice_body" then
			for _,p in ipairs(character:GetDescendants()) do
				if p:IsA("BasePart") then
					p.Material = Enum.Material.SmoothPlastic
					p.Transparency = 0
				end
			end
		end

		print("[DiceServer] 🗑 "..player.Name.." removed skill: "..skillId)

	-- ── CLEAR ALL ──
	elseif action == "ClearAll" then
		-- Hapus semua attribute
		for _, attr in ipairs({
			"skill_speed_demon","skill_super_jump","skill_giant_head",
			"skill_tiny_legs","skill_buff_arms","skill_noodle_arms",
			"skill_phantom","skill_golden_skin","skill_rainbow_body",
			"skill_anti_gravity","skill_ice_body","skill_lava_trail",
			"skill_spinning_head","skill_ant_size","skill_giant_mode",
			"skill_backwards_brain","skill_magnet_body","skill_time_warp","skill_god_mode"
		}) do
			character:SetAttribute(attr, nil)
		end
		-- Reset semua stat
		humanoid.WalkSpeed = 16
		humanoid.JumpPower  = 50
		workspace.Gravity   = 196.2
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local bf = hrp:FindFirstChild("_AntiGrav")
			if bf then bf:Destroy() end
		end
		for _,p in ipairs(character:GetDescendants()) do
			if p:IsA("BasePart") then
				p.Transparency = 0
				p.Material = Enum.Material.SmoothPlastic
				p.Color = Color3.fromRGB(163,162,165)
			end
		end
		print("[DiceServer] 🗑 "..player.Name.." cleared all skills")
	end
end)

print("[DiceServer] 🎲 Ready! Waiting for players...")
