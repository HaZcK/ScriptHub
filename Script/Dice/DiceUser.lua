-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║                    DICE OF FATE — DiceUser.lua                       ║
-- ║                                                                      ║
-- ║  This is YOUR file. Full freedom to customize anything here.         ║
-- ║  Add custom skills, change the GUI, add new tabs — go wild!          ║
-- ║                                                                      ║
-- ║  HOW TO USE:                                                         ║
-- ║  1. Upload DiceLibrary.lua & DicePlayer.lua to GitHub                ║
-- ║  2. Replace RAW_URL_PLAYER below with the raw URL of DicePlayer.lua  ║
-- ║  3. Execute THIS file in your executor (not DicePlayer!)             ║
-- ╚══════════════════════════════════════════════════════════════════════╝

-- ── Load DicePlayer (which loads DiceLibrary automatically) ─────────────
local RAW_URL_PLAYER = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/Dice/DicePlayer.lua"

local Dice = loadstring(game:HttpGet(RAW_URL_PLAYER))()
-- DicePlayer tidak Launch GUI sendiri, DiceUser yang Launch di bawah

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  FULL API REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Dice.AddSkill(data)        — Register a new skill into the pool
  Dice.GetChar()             — Returns (character, humanoid)
  Dice.GetOrigSize(partName) — Returns original size of a part (Vector3)
  Dice.SaveConn(key, conn)   — Save a loop connection (RBXScriptConnection)
  Dice.DropConn(key)         — Disconnect & remove a saved connection
  Dice.SetTitle(text)        — Change the GUI window title
  Dice.SetMaxSlots(number)   — Change max active skill slots (default 5)
  Dice.Launch()              — Show the GUI (call AFTER all AddSkill)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SKILL TEMPLATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Dice.AddSkill({
      id      = "unique_id",     -- must be unique across all skills
      name    = "Skill Name",    -- display name in GUI
      icon    = "🎯",            -- any emoji
      rarity  = "Common",        -- Common | Rare | Epic | Legendary
      desc    = "Short description.",
      flavor  = "Cool flavor text.",  -- optional, shows small below desc
      apply = function()
          local c, h = Dice.GetChar()  -- c = Character, h = Humanoid
          -- write your effect here
      end,
      remove = function()
          local c, h = Dice.GetChar()
          -- undo your effect here
      end,
  })

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  RARITY WEIGHTS (chance of rolling)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Common    — 50 weight  (~50% chance)
  Rare      — 30 weight  (~30% chance)
  Epic      — 15 weight  (~15% chance)
  Legendary —  5 weight  (~5%  chance, +4 per skip streak)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]]

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ════════════════════════════════════════════════════════════════════
--  ★  EXAMPLE 1 — Simple skill (no loop)
--     Effect: doubles walk speed
-- ════════════════════════════════════════════════════════════════════
Dice.AddSkill({
    id      = "example_speed",
    name    = "Hyperdrive",
    icon    = "🏎️",
    rarity  = "Rare",
    desc    = "Doubles your walk speed instantly.",
    flavor  = "Zoom zoom.",
    apply = function()
        local c, h = Dice.GetChar()
        h.WalkSpeed = h.WalkSpeed * 2
    end,
    remove = function()
        local c, h = Dice.GetChar()
        h.WalkSpeed = 16
    end,
})

-- ════════════════════════════════════════════════════════════════════
--  ★  EXAMPLE 2 — Loop skill (continuous effect)
--     Effect: character flickers between visible/invisible
-- ════════════════════════════════════════════════════════════════════
Dice.AddSkill({
    id      = "example_flicker",
    name    = "Flicker",
    icon    = "⚡",
    rarity  = "Epic",
    desc    = "Your body rapidly flickers in and out of existence.",
    flavor  = "Now you see me...",
    apply = function()
        local last = 0
        Dice.SaveConn("flicker_loop", RunService.Heartbeat:Connect(function()
            local now = tick()
            if now - last < 0.08 then return end
            last = now
            local c = Players.LocalPlayer.Character
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.Transparency = p.Transparency > 0 and 0 or 0.9
                end
            end
        end))
    end,
    remove = function()
        Dice.DropConn("flicker_loop")
        local c = Players.LocalPlayer.Character
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency = 0 end
        end
    end,
})

-- ════════════════════════════════════════════════════════════════════
--  ★  EXAMPLE 3 — Part scaling skill
--     Effect: makes torso huge
-- ════════════════════════════════════════════════════════════════════
Dice.AddSkill({
    id      = "example_bigtorso",
    name    = "Big Body",
    icon    = "🫃",
    rarity  = "Common",
    desc    = "Your torso inflates to an absurd size.",
    flavor  = "Extra large please.",
    apply = function()
        local c, h = Dice.GetChar()
        local torso = c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
        if torso then torso.Size = Vector3.new(6, 6, 4) end
    end,
    remove = function()
        local c, h = Dice.GetChar()
        local torso = c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
        local orig  = Dice.GetOrigSize("UpperTorso") or Dice.GetOrigSize("Torso")
        if torso and orig then torso.Size = orig end
    end,
})

-- ════════════════════════════════════════════════════════════════════
--  ★  EXAMPLE 4 — Legendary skill with multiple effects + loop
--     Effect: neon rainbow + insane speed + float
-- ════════════════════════════════════════════════════════════════════
Dice.AddSkill({
    id      = "example_ascend",
    name    = "Ascension",
    icon    = "🌟",
    rarity  = "Legendary",
    desc    = "Rainbow neon body, max speed, and low gravity.",
    flavor  = "Touch grass? I live above the clouds.",
    apply = function()
        local c, h = Dice.GetChar()
        h.WalkSpeed = 120
        h.JumpPower = 200
        workspace.Gravity = 30

        Dice.SaveConn("ascend_loop", RunService.Heartbeat:Connect(function()
            local c2 = Players.LocalPlayer.Character
            if not c2 then return end
            local t = tick()
            for _, p in ipairs(c2:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.Color    = Color3.fromHSV((t * 2 + p.Name:len() * 0.08) % 1, 1, 1)
                    p.Material = Enum.Material.Neon
                end
            end
        end))
    end,
    remove = function()
        Dice.DropConn("ascend_loop")
        local c, h = Dice.GetChar()
        h.WalkSpeed   = 16
        h.JumpPower   = 50
        workspace.Gravity = 196.2
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Material = Enum.Material.SmoothPlastic
                p.Color    = Color3.fromRGB(163, 162, 165)
            end
        end
    end,
})

-- ════════════════════════════════════════════════════════════════════
--  ★  EXAMPLE 5 — Screen effect skill (GUI overlay)
--     Effect: red tint vignette when active
-- ════════════════════════════════════════════════════════════════════
Dice.AddSkill({
    id      = "example_bloodvision",
    name    = "Blood Vision",
    icon    = "🩸",
    rarity  = "Epic",
    desc    = "A crimson vignette clouds your vision.",
    flavor  = "Everything looks... red.",
    apply = function()
        local player = Players.LocalPlayer
        local old = player.PlayerGui:FindFirstChild("BloodVisionGui")
        if old then old:Destroy() end

        local sg = Instance.new("ScreenGui")
        sg.Name = "BloodVisionGui"; sg.ResetOnSpawn = false
        sg.DisplayOrder = 995; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = player.PlayerGui

        local function makeEdge(anchor, pos, size, rot)
            local f = Instance.new("Frame", sg)
            f.AnchorPoint = anchor; f.Position = pos; f.Size = size
            f.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            f.BackgroundTransparency = 1; f.BorderSizePixel = 0
            local g = Instance.new("UIGradient", f)
            g.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new(0.6, 0.6),
                NumberSequenceKeypoint.new(1, 1),
            })
            g.Rotation = rot
            TweenService:Create(f, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {BackgroundTransparency=0}):Play()
            return f
        end

        makeEdge(Vector2.new(0.5,0), UDim2.new(0.5,0,0,0),    UDim2.new(1,0,0.5,0), 270)
        makeEdge(Vector2.new(0.5,1), UDim2.new(0.5,0,1,0),    UDim2.new(1,0,0.5,0), 90)
        makeEdge(Vector2.new(0,0.5), UDim2.new(0,0,0.5,0),    UDim2.new(0.4,0,1,0), 0)
        makeEdge(Vector2.new(1,0.5), UDim2.new(1,0,0.5,0),    UDim2.new(0.4,0,1,0), 180)
    end,
    remove = function()
        local sg = Players.LocalPlayer.PlayerGui:FindFirstChild("BloodVisionGui")
        if sg then
            for _, f in ipairs(sg:GetChildren()) do
                if f:IsA("Frame") then
                    TweenService:Create(f, TweenInfo.new(1, Enum.EasingStyle.Quad), {BackgroundTransparency=1}):Play()
                end
            end
            task.delay(1.1, function() if sg and sg.Parent then sg:Destroy() end end)
        end
    end,
})

Dice.AddSkill({
    id      = "F3X",
    name    = "F3X Btools",
    icon    = "🔨",
    rarity  = "Legendary",
    desc    = "Gives you F3X Building Tools. Build anything!",
    flavor  = "With this, you can organize your world.",
    apply = function()
        local player = game:GetService("Players").LocalPlayer
        local TweenService = game:GetService("TweenService")

        -- Server yang insert F3X ke backpack
        Dice.FX("F3X", { effect = "GiveF3X" })

        -- Notif GUI slide up dari bawah
        local old = player.PlayerGui:FindFirstChild("F3XNotif")
        if old then old:Destroy() end

        local sg = Instance.new("ScreenGui")
        sg.Name = "F3XNotif"; sg.ResetOnSpawn = false
        sg.DisplayOrder = 997; sg.Parent = player.PlayerGui

        local frame = Instance.new("Frame", sg)
        frame.Size = UDim2.new(0, 280, 0, 60)
        frame.Position = UDim2.new(0.5, -140, 1, 10)
        frame.BackgroundColor3 = Color3.fromRGB(18, 14, 30)
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
        local fs = Instance.new("UIStroke", frame)
        fs.Color = Color3.fromRGB(255, 180, 0); fs.Thickness = 1.5

        local icon = Instance.new("TextLabel", frame)
        icon.Size = UDim2.new(0, 50, 1, 0)
        icon.BackgroundTransparency = 1
        icon.Text = "🔨"; icon.TextSize = 26; icon.Font = Enum.Font.Gotham

        local txt = Instance.new("TextLabel", frame)
        txt.Size = UDim2.new(1, -55, 0.5, 0)
        txt.Position = UDim2.new(0, 50, 0, 4)
        txt.BackgroundTransparency = 1
        txt.Text = "F3X Btools — Active!"
        txt.TextColor3 = Color3.fromRGB(255, 180, 0)
        txt.Font = Enum.Font.GothamBold; txt.TextSize = 13
        txt.TextXAlignment = Enum.TextXAlignment.Left

        local sub = Instance.new("TextLabel", frame)
        sub.Size = UDim2.new(1, -55, 0.5, 0)
        sub.Position = UDim2.new(0, 50, 0.5, -2)
        sub.BackgroundTransparency = 1
        sub.Text = "Check your Backpack 🎒"
        sub.TextColor3 = Color3.fromRGB(160, 130, 200)
        sub.Font = Enum.Font.Gotham; sub.TextSize = 11
        sub.TextXAlignment = Enum.TextXAlignment.Left

        -- Slide in
        TweenService:Create(frame,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = UDim2.new(0.5, -140, 1, -75)}
        ):Play()

        -- Auto hide setelah 4 detik
        task.delay(4, function()
            if frame and frame.Parent then
                TweenService:Create(frame,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quad),
                    {Position = UDim2.new(0.5, -140, 1, 10)}
                ):Play()
                task.wait(0.35)
                if sg and sg.Parent then sg:Destroy() end
            end
        end)
    end,
    remove = function()
        local player = game:GetService("Players").LocalPlayer

        -- Server hapus F3X dari backpack
        Dice.FX("F3X", { effect = "RemoveF3X" })

        -- Hapus GUI notif
        local sg = player.PlayerGui:FindFirstChild("F3XNotif")
        if sg then sg:Destroy() end
    end,
})
-- ════════════════════════════════════════════════════════════════════
--  ✏️  YOUR CUSTOM SKILLS — add them below here!
--      Copy any example above, change the id/name/icon/rarity,
--      then write your own apply() and remove().
-- ════════════════════════════════════════════════════════════════════

--[[

Dice.AddSkill({
    id      = "my_skill",
    name    = "My Skill",
    icon    = "🎯",
    rarity  = "Common",   -- Common | Rare | Epic | Legendary
    desc    = "What it does.",
    flavor  = "Cool quote.",
    apply = function()
        local c, h = Dice.GetChar()
        -- your effect here
    end,
    remove = function()
        local c, h = Dice.GetChar()
        -- undo effect here
    end,
})

--]]

-- ════════════════════════════════════════════════════════════════════
--  OPTIONAL CUSTOMIZATION
-- ════════════════════════════════════════════════════════════════════

-- Change the window title:
-- Dice.SetTitle("🎲  MY DICE MOD")

-- Change max skill slots (default is 5):
-- Dice.SetMaxSlots(8)

-- ════════════════════════════════════════════════════════════════════
--  LAUNCH — must stay at the very bottom!
-- ════════════════════════════════════════════════════════════════════
Dice.Launch()
