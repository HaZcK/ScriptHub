-- ╔══════════════════════════════════════════════════════════════╗
-- ║                DICE OF FATE — DicePlayer.lua                 ║
-- ║                                                              ║
-- ║  SATU-SATUNYA FILE yang perlu kamu edit.                     ║
-- ║  Tambah skill di sini, server sync otomatis.                 ║
-- ║  Tidak perlu edit DiceLibrary atau DiceServer sama sekali.   ║
-- ╚══════════════════════════════════════════════════════════════╝

local RAW_URL_LIBRARY = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/Dice/DiceLibrary.lua"

local Dice = loadstring(game:HttpGet(RAW_URL_LIBRARY))()

-- ── Konfigurasi ─────────────────────────────────────────────────────
Dice.SetTitle("🎲  DICE OF FATE")
Dice.SetMaxSlots(5)

-- ════════════════════════════════════════════════════════════════════
--  SHORTCUT LOKAL — biar apply/remove lebih ringkas
-- ════════════════════════════════════════════════════════════════════
local RunService = game:GetService("RunService")

local function getChar()
	return Dice.GetChar()
end

-- ════════════════════════════════════════════════════════════════════
--  SKILL BAWAAN
-- ════════════════════════════════════════════════════════════════════

-- ── COMMON ──────────────────────────────────────────────────────────

Dice.AddSkill({
	id = "speed_demon", name = "Speed Demon", icon = "💨", rarity = "Common",
	desc = "WalkSpeed jadi 100. Ngebut banget!", flavor = "Angin aja kalah.",
	apply = function()
		local c,h = getChar(); h.WalkSpeed = 100
	end,
	remove = function()
		local c,h = getChar(); h.WalkSpeed = 16
	end,
})

Dice.AddSkill({
	id = "super_jump", name = "Super Jump", icon = "🚀", rarity = "Common",
	desc = "JumpPower jadi 200. Nyentuh langit!", flavor = "Gravity? Belum kenal.",
	apply = function()
		local c,h = getChar(); h.JumpPower = 200
	end,
	remove = function()
		local c,h = getChar(); h.JumpPower = 50
	end,
})

Dice.AddSkill({
	id = "giant_head", name = "Giant Head", icon = "🗿", rarity = "Common",
	desc = "Kepala jadi 5x lebih gede.", flavor = "Braincell makin banyak.",
	apply = function()
		local c,h = getChar()
		local head = c:FindFirstChild("Head")
		if head then head.Size = Vector3.new(5,5,5) end
	end,
	remove = function()
		local c,h = getChar()
		local head = c:FindFirstChild("Head")
		local orig = Dice.GetOrigSize("Head")
		if head and orig then head.Size = orig end
	end,
})

Dice.AddSkill({
	id = "tiny_legs", name = "Tiny Legs", icon = "🦵", rarity = "Common",
	desc = "Kaki mengecil drastis. Lucu banget.", flavor = "Kaki kamu mana??",
	apply = function()
		local c,h = getChar()
		for _,n in ipairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do
			local p = c:FindFirstChild(n); if p then p.Size = Vector3.new(0.4,0.4,0.4) end
		end
	end,
	remove = function()
		local c,h = getChar()
		for _,n in ipairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do
			local p = c:FindFirstChild(n); local orig = Dice.GetOrigSize(n)
			if p and orig then p.Size = orig end
		end
	end,
})

Dice.AddSkill({
	id = "buff_arms", name = "Buff Arms", icon = "💪", rarity = "Common",
	desc = "Lengan super gede. Siap tinju meteor.", flavor = "Arms day everyday.",
	apply = function()
		local c,h = getChar()
		for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
			local p = c:FindFirstChild(n); if p then p.Size = Vector3.new(2.5,2.5,2.5) end
		end
	end,
	remove = function()
		local c,h = getChar()
		for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
			local p = c:FindFirstChild(n); local orig = Dice.GetOrigSize(n)
			if p and orig then p.Size = orig end
		end
	end,
})

Dice.AddSkill({
	id = "noodle_arms", name = "Noodle Arms", icon = "🍜", rarity = "Common",
	desc = "Lengan super panjang menjuntai.", flavor = "Nyampe lantai dari berdiri.",
	apply = function()
		local c,h = getChar()
		for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
			local p = c:FindFirstChild(n); if p then p.Size = Vector3.new(0.3,3.5,0.3) end
		end
	end,
	remove = function()
		local c,h = getChar()
		for _,n in ipairs({"LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"}) do
			local p = c:FindFirstChild(n); local orig = Dice.GetOrigSize(n)
			if p and orig then p.Size = orig end
		end
	end,
})

Dice.AddSkill({
	id = "phantom", name = "Phantom Mode", icon = "👻", rarity = "Common",
	desc = "Badan transparan 80%.", flavor = "Boo!",
	apply = function()
		local c,h = getChar()
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency=0.8 end
		end
	end,
	remove = function()
		local c,h = getChar()
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.Transparency=0 end
		end
	end,
})

Dice.AddSkill({
	id = "golden_skin", name = "Golden Touch", icon = "✨", rarity = "Common",
	desc = "Seluruh badan jadi emas berkilau.", flavor = "Midas wishes.",
	apply = function()
		local c,h = getChar()
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
				p.BrickColor = BrickColor.new("Bright yellow")
			end
		end
	end,
	remove = function()
		local c,h = getChar()
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.Color = Color3.fromRGB(163,162,165) end
		end
	end,
})

-- ── RARE ────────────────────────────────────────────────────────────

Dice.AddSkill({
	id = "rainbow_body", name = "Rainbow Body", icon = "🌈", rarity = "Rare",
	desc = "Warna badan berubah pelangi nonstop.", flavor = "Serotonin overload.",
	apply = function()
		Dice.SaveConn("rainbow", RunService.Heartbeat:Connect(function()
			local c = game:GetService("Players").LocalPlayer.Character; if not c then return end
			local t = tick()
			for _,p in ipairs(c:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
					p.Color = Color3.fromHSV((t*0.5 + p.Name:len()*0.05)%1, 1, 1)
				end
			end
		end))
	end,
	remove = function()
		Dice.DropConn("rainbow")
		local c,h = getChar()
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.Color = Color3.fromRGB(163,162,165) end
		end
	end,
})

Dice.AddSkill({
	id = "anti_gravity", name = "Anti Gravity", icon = "🪐", rarity = "Rare",
	desc = "Gravitasi berkurang. Lompat terasa melayang.", flavor = "Space walk vibes.",
	apply = function()
		local c,h = getChar(); h.JumpPower = 150
		local hrp = c:FindFirstChild("HumanoidRootPart")
		if hrp then
			local old = hrp:FindFirstChild("_AG"); if old then old:Destroy() end
			local bf = Instance.new("BodyForce")
			bf.Name = "_AG"; bf.Force = Vector3.new(0, workspace.Gravity*hrp:GetMass()*0.75, 0); bf.Parent = hrp
		end
	end,
	remove = function()
		local c,h = getChar(); h.JumpPower = 50
		local hrp = c:FindFirstChild("HumanoidRootPart")
		if hrp then local bf = hrp:FindFirstChild("_AG"); if bf then bf:Destroy() end end
	end,
})

Dice.AddSkill({
	id = "ice_body", name = "Frozen Soul", icon = "🧊", rarity = "Rare",
	desc = "Badan jadi es transparan biru dingin.", flavor = "Dingin sampai jiwa.",
	apply = function()
		local c,h = getChar()
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
				p.BrickColor = BrickColor.new("Pastel blue"); p.Material = Enum.Material.Ice; p.Transparency = 0.35
			end
		end
	end,
	remove = function()
		local c,h = getChar()
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.Material = Enum.Material.SmoothPlastic; p.Transparency = 0 end
		end
	end,
})

Dice.AddSkill({
	id = "lava_trail", name = "Lava Trail", icon = "🔥", rarity = "Rare",
	desc = "Ninggalin jejak api saat berjalan.", flavor = "Floor is literally lava.",
	apply = function()
		local last = 0
		Dice.SaveConn("lava", RunService.Heartbeat:Connect(function()
			local now = tick(); if now-last < 0.15 then return end
			local lp = game:GetService("Players").LocalPlayer
			local c2 = lp.Character; local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
			local hrp = c2 and c2:FindFirstChild("HumanoidRootPart")
			if not hrp or not h2 or h2.MoveDirection.Magnitude < 0.1 then return end
			last = now
			local f = Instance.new("Part"); f.Size = Vector3.new(1.5,0.2,1.5)
			f.CFrame = CFrame.new(hrp.Position - Vector3.new(0,3,0))
			f.Anchored = true; f.CanCollide = false
			f.BrickColor = BrickColor.new("Bright orange"); f.Material = Enum.Material.Neon; f.Parent = workspace
			local fi = Instance.new("Fire",f); fi.Heat = 8; fi.Size = 5
			game:GetService("Debris"):AddItem(f, 2)
		end))
	end,
	remove = function()
		Dice.DropConn("lava")
	end,
})

Dice.AddSkill({
	id = "spinning_head", name = "Spinning Head", icon = "🌀", rarity = "Rare",
	desc = "Kepala muter nonstop.", flavor = "360 no scope.",
	apply = function()
		Dice.SaveConn("spin", RunService.Heartbeat:Connect(function(dt)
			local c = game:GetService("Players").LocalPlayer.Character; if not c then return end
			local head = c:FindFirstChild("Head")
			if head then head.CFrame = head.CFrame * CFrame.Angles(0, math.rad(300*dt), 0) end
		end))
	end,
	remove = function()
		Dice.DropConn("spin")
	end,
})

-- ── EPIC ────────────────────────────────────────────────────────────

Dice.AddSkill({
	id = "ant_size", name = "Ant Size", icon = "🐜", rarity = "Epic",
	desc = "Tubuh mengecil jadi 0.3x.", flavor = "Siapa kamu? Mana kamu?",
	apply = function()
		local c,h = getChar(); h.WalkSpeed = 10
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
				pcall(function() p.Size = p.Size * 0.3 end)
			end
		end
	end,
	remove = function()
		local c,h = getChar(); h.WalkSpeed = 16
		for _,p in ipairs(c:GetDescendants()) do
			local orig = Dice.GetOrigSize(p.Name)
			if p:IsA("BasePart") and orig then pcall(function() p.Size = orig end) end
		end
	end,
})

Dice.AddSkill({
	id = "giant_mode", name = "Giant Mode", icon = "🏔️", rarity = "Epic",
	desc = "Tumbuh jadi raksasa 3x ukuran.", flavor = "Fee-fi-fo-fum.",
	apply = function()
		local c,h = getChar(); h.WalkSpeed = 24; h.JumpPower = 80
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
				pcall(function() p.Size = p.Size * 3 end)
			end
		end
	end,
	remove = function()
		local c,h = getChar(); h.WalkSpeed = 16; h.JumpPower = 50
		for _,p in ipairs(c:GetDescendants()) do
			local orig = Dice.GetOrigSize(p.Name)
			if p:IsA("BasePart") and orig then pcall(function() p.Size = orig end) end
		end
	end,
})

Dice.AddSkill({
	id = "backwards_brain", name = "Backwards Brain", icon = "🔄", rarity = "Epic",
	desc = "Kamera terbalik 180°. Maju jadi mundur.", flavor = "Lain di mulut lain di hati.",
	apply = function()
		local cam = workspace.CurrentCamera; cam.CameraType = Enum.CameraType.Scriptable
		Dice.SaveConn("cam", RunService.Heartbeat:Connect(function()
			local c = game:GetService("Players").LocalPlayer.Character; if not c then return end
			local hrp = c:FindFirstChild("HumanoidRootPart")
			if hrp then cam.CFrame = CFrame.new(hrp.Position+Vector3.new(0,6,14))*CFrame.Angles(-0.12,math.pi,0) end
		end))
	end,
	remove = function()
		Dice.DropConn("cam"); workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end,
})

Dice.AddSkill({
	id = "magnet_body", name = "Magnet Body", icon = "🧲", rarity = "Epic",
	desc = "Benda-benda sekitar tertarik ke kamu.", flavor = "Personal gravitational field.",
	apply = function()
		Dice.SaveConn("magnet", RunService.Heartbeat:Connect(function()
			local c = game:GetService("Players").LocalPlayer.Character; if not c then return end
			local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
			for _,obj in ipairs(workspace:GetChildren()) do
				if obj:IsA("BasePart") and not obj.Anchored and obj~=hrp and not c:IsAncestorOf(obj) then
					local d = (obj.Position-hrp.Position).Magnitude
					if d < 25 and d > 0.1 then
						obj.AssemblyLinearVelocity = obj.AssemblyLinearVelocity + (hrp.Position-obj.Position).Unit*(180/d)
					end
				end
			end
		end))
	end,
	remove = function()
		Dice.DropConn("magnet")
	end,
})

Dice.AddSkill({
	id      = "Darkness",
	name    = "Dark",
	icon    = "🌚",
	rarity  = "Epic",
	desc    = "Fog hitam pekat menyelimuti sekitarmu.",
	flavor  = "Kamu tidak bisa menduga apa yang ada di depan.",
	apply = function()
		local player     = game:GetService("Players").LocalPlayer
		local TweenService = game:GetService("TweenService")

		local oldGui = player.PlayerGui:FindFirstChild("DarkFogGui")
		if oldGui then oldGui:Destroy() end

		local sg = Instance.new("ScreenGui")
		sg.Name = "DarkFogGui"; sg.ResetOnSpawn = false
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		sg.DisplayOrder = 998; sg.Parent = player.PlayerGui

		-- Background hitam penuh
		local bg = Instance.new("Frame", sg)
		bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
		bg.BackgroundTransparency = 1; bg.BorderSizePixel = 0; bg.ZIndex = 998

		-- Fog dari 4 sisi — menyisakan lubang kecil di tengah
		local function makeFog(anchor, pos, size, rotation)
			local f = Instance.new("Frame", bg)
			f.AnchorPoint = anchor; f.Position = pos; f.Size = size
			f.BackgroundColor3 = Color3.fromRGB(0,0,0)
			f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ZIndex = 999
			local g = Instance.new("UIGradient", f)
			g.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			g.Rotation = rotation
			return f
		end

		local fogT = makeFog(Vector2.new(0.5,0), UDim2.new(0.5,0,0,0),    UDim2.new(1,0,0.62,0), 270)
		local fogB = makeFog(Vector2.new(0.5,1), UDim2.new(0.5,0,1,0),    UDim2.new(1,0,0.62,0), 90)
		local fogL = makeFog(Vector2.new(0,0.5), UDim2.new(0,0,0.5,0),    UDim2.new(0.52,0,1,0), 0)
		local fogR = makeFog(Vector2.new(1,0.5), UDim2.new(1,0,0.5,0),    UDim2.new(0.52,0,1,0), 180)

		-- Sudut biar tidak ada celah
		local function makeCorner(anchor, pos)
			local f = Instance.new("Frame", bg)
			f.AnchorPoint = anchor; f.Position = pos; f.Size = UDim2.new(0.42,0,0.42,0)
			f.BackgroundColor3 = Color3.fromRGB(0,0,0)
			f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ZIndex = 999
			local g = Instance.new("UIGradient", f)
			g.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.65, 0),
				NumberSequenceKeypoint.new(1, 1),
			})
			g.Rotation = 45
			return f
		end

		local cTL = makeCorner(Vector2.new(0,0), UDim2.new(0,0,0,0))
		local cTR = makeCorner(Vector2.new(1,0), UDim2.new(1,0,0,0))
		local cBL = makeCorner(Vector2.new(0,1), UDim2.new(0,0,1,0))
		local cBR = makeCorner(Vector2.new(1,1), UDim2.new(1,0,1,0))

		local allFogs = {fogT, fogB, fogL, fogR, cTL, cTR, cBL, cBR}

		-- Fade in semua fog
		TweenService:Create(bg, TweenInfo.new(2, Enum.EasingStyle.Quad), {BackgroundTransparency=0.02}):Play()
		for _,f in ipairs(allFogs) do
			TweenService:Create(f, TweenInfo.new(2, Enum.EasingStyle.Quad), {BackgroundTransparency=0}):Play()
		end

		-- Pulse: fog bernapas pelan (efek horror)
		Dice.SaveConn("dark_pulse", RunService.Heartbeat:Connect(function()
			local t = tick()
			local pulse = math.sin(t * 0.7) * 0.025
			fogT.Size = UDim2.new(1,0,0.62+pulse,0)
			fogB.Size = UDim2.new(1,0,0.62+pulse,0)
			fogL.Size = UDim2.new(0.52+pulse,0,1,0)
			fogR.Size = UDim2.new(0.52+pulse,0,1,0)
		end))
	end,
	remove = function()
		Dice.DropConn("dark_pulse")
		local player = game:GetService("Players").LocalPlayer
		local TweenService = game:GetService("TweenService")
		local sg = player.PlayerGui:FindFirstChild("DarkFogGui")
		if sg then
			for _,f in ipairs(sg:GetDescendants()) do
				if f:IsA("Frame") then
					TweenService:Create(f, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {BackgroundTransparency=1}):Play()
				end
			end
			task.delay(1.6, function() if sg and sg.Parent then sg:Destroy() end end)
		end
	end,
})

-- ── LEGENDARY ───────────────────────────────────────────────────────

Dice.AddSkill({
	id = "time_warp", name = "Time Warp", icon = "⏳", rarity = "Legendary",
	desc = "Gravitasi drop ke 20. Kamu tetap kenceng.", flavor = "Waktu itu relatif.",
	apply = function()
		local c,h = getChar(); workspace.Gravity = 20; h.WalkSpeed = 80; h.JumpPower = 120
	end,
	remove = function()
		local c,h = getChar(); workspace.Gravity = 196.2; h.WalkSpeed = 16; h.JumpPower = 50
	end,
})

Dice.AddSkill({
	id = "god_mode", name = "God Mode", icon = "⚡", rarity = "Legendary",
	desc = "Speed + Jump + Giant Head + Rainbow Neon.", flavor = "Pure chaos.",
	apply = function()
		local c,h = getChar(); h.WalkSpeed = 80; h.JumpPower = 180
		local head = c:FindFirstChild("Head"); if head then head.Size = Vector3.new(5,5,5) end
		Dice.SaveConn("god", RunService.Heartbeat:Connect(function()
			local c2 = game:GetService("Players").LocalPlayer.Character; if not c2 then return end
			local t = tick()
			for _,p in ipairs(c2:GetDescendants()) do
				if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
					p.Color = Color3.fromHSV((t*1.5+p.Name:len()*0.1)%1,1,1); p.Material = Enum.Material.Neon
				end
			end
		end))
	end,
	remove = function()
		Dice.DropConn("god")
		local c,h = getChar(); h.WalkSpeed = 16; h.JumpPower = 50
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.Material = Enum.Material.SmoothPlastic; p.Color = Color3.fromRGB(163,162,165) end
		end
		local head = c:FindFirstChild("Head"); local orig = Dice.GetOrigSize("Head")
		if head and orig then head.Size = orig end
	end,
})

-- ════════════════════════════════════════════════════════════════════
--  CUSTOM SKILL — tambah skill kamu di sini!
--  Template siap pakai, tinggal copy & isi.
-- ════════════════════════════════════════════════════════════════════

--[[

Dice.AddSkill({
	id      = "nama_unik",        -- WAJIB unik, tidak boleh sama dengan skill lain
	name    = "Nama Skill",       -- nama tampilan di GUI
	icon    = "🎯",               -- emoji bebas
	rarity  = "Common",           -- Common | Rare | Epic | Legendary
	desc    = "Deskripsi singkat.",
	flavor  = "Kalimat keren.",   -- opsional
	apply = function()
		local c, h = getChar()   -- c = Character, h = Humanoid

		-- Contoh efek sederhana:
		h.WalkSpeed = 50

		-- Contoh efek dengan loop (terus-menerus):
		Dice.SaveConn("key_unik", RunService.Heartbeat:Connect(function(dt)
			-- kode loop di sini
		end))
	end,
	remove = function()
		local c, h = getChar()
		Dice.DropConn("key_unik")  -- wajib stop loop kalau pakai SaveConn
		h.WalkSpeed = 16
	end,
})

--]]

-- ════════════════════════════════════════════════════════════════════
--  Jangan hapus return ini!
--  DiceUser.lua butuh ini untuk tambah skill custom.
-- ════════════════════════════════════════════════════════════════════
return Dice
