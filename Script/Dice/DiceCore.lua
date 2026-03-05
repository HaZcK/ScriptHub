-- ╔══════════════════════════════════════════════╗
-- ║            DICECORE - LocalScript            ║
-- ║  Taruh di: StarterPlayer > StarterPlayerScripts ║
-- ║  Pastikan Skill_List ada di ReplicatedStorage   ║
-- ╚══════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RS           = game:GetService("ReplicatedStorage")

local SkillList = require(RS:WaitForChild("Skill_List"))

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")

-- ══════════════════════════════
--  STATE
-- ══════════════════════════════
local activeSkills    = {}   -- { skill, slotIndex }
local activeIds       = {}   -- set of active skill ids
local isRolling       = false
local waitingChoice   = false
local pendingSkill    = nil
local rollStreak      = 0    -- berapa kali roll berturut-turut tanpa USE
local MAX_SLOTS       = 5

-- ══════════════════════════════
--  RARITY COLOR HELPER
-- ══════════════════════════════
local function rarityColor(rarity)
	return SkillList.RarityData[rarity] and SkillList.RarityData[rarity].color
		or Color3.fromRGB(200,200,200)
end

local function rarityGlow(rarity)
	return SkillList.RarityData[rarity] and SkillList.RarityData[rarity].glow
		or Color3.fromRGB(200,200,200)
end

local rarityEmoji = {
	Common    = "⚪",
	Rare      = "🔵",
	Epic      = "🟣",
	Legendary = "🟡",
}

-- ══════════════════════════════
--  BUILD SCREEN GUI
-- ══════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name        = "DiceOfFateGui"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = player.PlayerGui

-- ── Window ──
local win = Instance.new("Frame")
win.Name = "Window"
win.Size = UDim2.new(0, 400, 0, 600)
win.Position = UDim2.new(0.5, -200, 0.5, -300)
win.BackgroundColor3 = Color3.fromRGB(14, 12, 22)
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Parent = SG
Instance.new("UICorner", win).CornerRadius = UDim.new(0,14)
local winStroke = Instance.new("UIStroke", win)
winStroke.Color = Color3.fromRGB(120,80,200)
winStroke.Thickness = 1.5
winStroke.Transparency = 0.5

-- subtle grid bg
local bg = Instance.new("Frame", win)
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundTransparency = 1
bg.ZIndex = 0

-- ── Title Bar ──
local tbar = Instance.new("Frame", win)
tbar.Name = "TitleBar"
tbar.Size = UDim2.new(1,0,0,46)
tbar.BackgroundColor3 = Color3.fromRGB(24,18,42)
tbar.BorderSizePixel = 0
tbar.ZIndex = 5
Instance.new("UICorner", tbar).CornerRadius = UDim.new(0,14)
-- cover bottom round corners
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

-- ── Control Buttons ──
local function makeCtrlBtn(parent, pos, bg_, txt)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0,22,0,22)
	b.Position = pos
	b.BackgroundColor3 = bg_
	b.Text = txt
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.TextSize = 11
	b.Font = Enum.Font.GothamBold
	b.BorderSizePixel = 0
	b.ZIndex = 7
	Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
	return b
end

local closeBtn = makeCtrlBtn(tbar, UDim2.new(1,-32,0.5,-11),
	Color3.fromRGB(231,76,94), "✕")
local minBtn   = makeCtrlBtn(tbar, UDim2.new(1,-58,0.5,-11),
	Color3.fromRGB(245,166,35), "─")

-- ── Content ──
local cont = Instance.new("Frame", win)
cont.Name = "Content"
cont.Size = UDim2.new(1,0,1,-46)
cont.Position = UDim2.new(0,0,0,46)
cont.BackgroundTransparency = 1

-- ─── Dice Box ───
local diceFrame = Instance.new("Frame", cont)
diceFrame.Size = UDim2.new(0,120,0,120)
diceFrame.Position = UDim2.new(0.5,-60,0,20)
diceFrame.BackgroundColor3 = Color3.fromRGB(26,18,48)
diceFrame.BorderSizePixel = 0
Instance.new("UICorner", diceFrame).CornerRadius = UDim.new(0,18)
local diceStroke = Instance.new("UIStroke", diceFrame)
diceStroke.Color = Color3.fromRGB(140,90,255)
diceStroke.Thickness = 2
diceStroke.Transparency = 0.5

local diceLbl = Instance.new("TextLabel", diceFrame)
diceLbl.Size = UDim2.new(1,0,1,0)
diceLbl.BackgroundTransparency = 1
diceLbl.Text = "🎲"
diceLbl.TextSize = 56
diceLbl.Font = Enum.Font.Gotham
diceLbl.TextColor3 = Color3.fromRGB(220,190,255)

-- Rarity Badge (bawah dice)
local rarityBadge = Instance.new("TextLabel", cont)
rarityBadge.Size = UDim2.new(0,130,0,26)
rarityBadge.Position = UDim2.new(0.5,-65,0,148)
rarityBadge.BackgroundColor3 = Color3.fromRGB(30,22,55)
rarityBadge.Text = ""
rarityBadge.TextSize = 12
rarityBadge.Font = Enum.Font.GothamBold
rarityBadge.TextColor3 = Color3.fromRGB(200,180,255)
rarityBadge.BorderSizePixel = 0
rarityBadge.Visible = false
Instance.new("UICorner", rarityBadge).CornerRadius = UDim.new(0,8)

-- Skill Name
local skillName = Instance.new("TextLabel", cont)
skillName.Size = UDim2.new(1,-40,0,32)
skillName.Position = UDim2.new(0,20,0,182)
skillName.BackgroundTransparency = 1
skillName.Text = "Roll the dice!"
skillName.TextColor3 = Color3.fromRGB(215,185,255)
skillName.Font = Enum.Font.GothamBold
skillName.TextSize = 18
skillName.TextXAlignment = Enum.TextXAlignment.Center

-- Skill Desc
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

-- ── Choice Buttons ──
local function makeChoiceBtn(xOff, bg_, txt)
	local b = Instance.new("TextButton", cont)
	b.Size = UDim2.new(0,148,0,48)
	b.Position = UDim2.new(0.5, xOff, 0, 274)
	b.BackgroundColor3 = bg_
	b.Text = txt
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 15
	b.BorderSizePixel = 0
	b.Visible = false
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)
	return b
end

local useBtn  = makeChoiceBtn(-158, Color3.fromRGB(70,195,110),  "✅  USE")
local skipBtn = makeChoiceBtn(10,   Color3.fromRGB(200,70,70),   "⏭  SKIP")

-- ── Roll Button ──
local rollBtn = Instance.new("TextButton", cont)
rollBtn.Size = UDim2.new(1,-48,0,54)
rollBtn.Position = UDim2.new(0,24,0,336)
rollBtn.BackgroundColor3 = Color3.fromRGB(110,55,215)
rollBtn.Text = "🎲  ROLL THE DICE"
rollBtn.TextColor3 = Color3.fromRGB(255,255,255)
rollBtn.Font = Enum.Font.GothamBold
rollBtn.TextSize = 16
rollBtn.BorderSizePixel = 0
Instance.new("UICorner", rollBtn).CornerRadius = UDim.new(0,14)
local rollStroke = Instance.new("UIStroke", rollBtn)
rollStroke.Color = Color3.fromRGB(180,120,255)
rollStroke.Thickness = 1.5

-- ── Streak Counter ──
local streakLabel = Instance.new("TextLabel", cont)
streakLabel.Size = UDim2.new(1,-48,0,24)
streakLabel.Position = UDim2.new(0,24,0,398)
streakLabel.BackgroundTransparency = 1
streakLabel.Text = ""
streakLabel.TextColor3 = Color3.fromRGB(255,200,60)
streakLabel.Font = Enum.Font.GothamBold
streakLabel.TextSize = 13
streakLabel.TextXAlignment = Enum.TextXAlignment.Center

-- ── SKILL SLOTS SECTION ──
local slotsTitle = Instance.new("TextLabel", cont)
slotsTitle.Size = UDim2.new(1,-40,0,20)
slotsTitle.Position = UDim2.new(0,20,0,428)
slotsTitle.BackgroundTransparency = 1
slotsTitle.Text = "ACTIVE SKILL SLOTS  [0/"..MAX_SLOTS.."]"
slotsTitle.TextColor3 = Color3.fromRGB(120,95,175)
slotsTitle.Font = Enum.Font.GothamBold
slotsTitle.TextSize = 11
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

-- ── Clear All ──
local clearBtn = Instance.new("TextButton", cont)
clearBtn.Size = UDim2.new(1,-40,0,36)
clearBtn.Position = UDim2.new(0,20,0,534)
clearBtn.BackgroundColor3 = Color3.fromRGB(50,35,75)
clearBtn.Text = "🗑  Clear All Skills"
clearBtn.TextColor3 = Color3.fromRGB(175,140,215)
clearBtn.Font = Enum.Font.Gotham
clearBtn.TextSize = 13
clearBtn.BorderSizePixel = 0
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0,10)

-- ══════════════════════════════
--  SLOT UI BUILDER
-- ══════════════════════════════
local slotObjects = {}

local function rebuildSlots()
	for _, s in ipairs(slotObjects) do s:Destroy() end
	slotObjects = {}
	slotsTitle.Text = "ACTIVE SKILL SLOTS  ["..#activeSkills.."/"..MAX_SLOTS.."]"

	for i, entry in ipairs(activeSkills) do
		local slot = Instance.new("Frame", slotsFrame)
		slot.Size = UDim2.new(0, 54, 0, 54)
		slot.BackgroundColor3 = Color3.fromRGB(30,22,52)
		slot.BorderSizePixel = 0
		Instance.new("UICorner", slot).CornerRadius = UDim.new(0,10)

		local slotStroke = Instance.new("UIStroke", slot)
		slotStroke.Color = rarityColor(entry.skill.rarity)
		slotStroke.Thickness = 2

		local icon = Instance.new("TextLabel", slot)
		icon.Size = UDim2.new(1,0,0.62,0)
		icon.BackgroundTransparency = 1
		icon.Text = entry.skill.icon
		icon.TextSize = 22
		icon.Font = Enum.Font.Gotham
		icon.TextColor3 = Color3.fromRGB(255,255,255)

		local nameLbl = Instance.new("TextLabel", slot)
		nameLbl.Size = UDim2.new(1,-2,0.38,0)
		nameLbl.Position = UDim2.new(0,1,0.62,0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = entry.skill.rarity == "Legendary" and "LGND" or entry.skill.rarity
		nameLbl.TextSize = 9
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextColor3 = rarityColor(entry.skill.rarity)

		-- Hover to remove
		local removeHint = Instance.new("TextButton", slot)
		removeHint.Size = UDim2.new(1,0,1,0)
		removeHint.BackgroundTransparency = 1
		removeHint.Text = ""
		removeHint.ZIndex = 10
		local hovered = false
		removeHint.MouseEnter:Connect(function()
			hovered = true
			icon.Text = "✕"
			TweenService:Create(slot, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(100,30,30)
			}):Play()
		end)
		removeHint.MouseLeave:Connect(function()
			hovered = false
			icon.Text = entry.skill.icon
			TweenService:Create(slot, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(30,22,52)
			}):Play()
		end)
		removeHint.MouseButton1Click:Connect(function()
			pcall(entry.skill.remove, character, humanoid)
			table.remove(activeSkills, i)
			activeIds[entry.skill.id] = nil
			rebuildSlots()
		end)

		table.insert(slotObjects, slot)
	end

	-- Empty slots
	for i = #activeSkills + 1, MAX_SLOTS do
		local empty = Instance.new("Frame", slotsFrame)
		empty.Size = UDim2.new(0,54,0,54)
		empty.BackgroundColor3 = Color3.fromRGB(22,16,38)
		empty.BorderSizePixel = 0
		Instance.new("UICorner", empty).CornerRadius = UDim.new(0,10)
		local emptStroke = Instance.new("UIStroke", empty)
		emptStroke.Color = Color3.fromRGB(60,45,90)
		emptStroke.Thickness = 1.5
		emptStroke.Transparency = 0.5
		local emptyLbl = Instance.new("TextLabel", empty)
		emptyLbl.Size = UDim2.new(1,0,1,0)
		emptyLbl.BackgroundTransparency = 1
		emptyLbl.Text = "+"
		emptyLbl.TextSize = 22
		emptyLbl.Font = Enum.Font.GothamBold
		emptyLbl.TextColor3 = Color3.fromRGB(60,45,80)
		table.insert(slotObjects, empty)
	end
end

rebuildSlots()

-- ══════════════════════════════
--  DRAGGING
-- ══════════════════════════════
local dragging, dragStart, startPos = false, nil, nil

tbar.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1
	or inp.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = inp.Position
		startPos = win.Position
	end
end)
tbar.InputChanged:Connect(function(inp)
	if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
	or inp.UserInputType == Enum.UserInputType.Touch) then
		local d = inp.Position - dragStart
		win.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y
		)
	end
end)
tbar.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1
	or inp.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- ══════════════════════════════
--  MINIMIZE & CLOSE
-- ══════════════════════════════
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		cont.Visible = false
		TweenService:Create(win, TweenInfo.new(0.28, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0,400,0,46)
		}):Play()
		minBtn.Text = "□"
	else
		TweenService:Create(win, TweenInfo.new(0.28, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0,400,0,600)
		}):Play()
		task.wait(0.28)
		cont.Visible = true
		minBtn.Text = "─"
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Size = UDim2.new(0,0,0,0),
		Position = UDim2.new(
			win.Position.X.Scale, win.Position.X.Offset + 200,
			win.Position.Y.Scale, win.Position.Y.Offset + 300
		)
	}):Play()
	task.wait(0.25)
	SG:Destroy()
end)

-- ══════════════════════════════
--  CHOICE SHOW / HIDE
-- ══════════════════════════════
local function showChoice(skill)
	pendingSkill = skill
	waitingChoice = true
	useBtn.Visible = true
	skipBtn.Visible = true
	rollBtn.Visible = false
	-- Tween dice glow to rarity color
	TweenService:Create(diceStroke, TweenInfo.new(0.3), {
		Color = rarityGlow(skill.rarity),
		Transparency = 0
	}):Play()
	rarityBadge.Text = rarityEmoji[skill.rarity] .. "  " .. skill.rarity:upper()
	rarityBadge.TextColor3 = rarityColor(skill.rarity)
	rarityBadge.Visible = true
end

local function hideChoice()
	useBtn.Visible = false
	skipBtn.Visible = false
	rollBtn.Visible = true
	waitingChoice = false
	pendingSkill = nil
	TweenService:Create(diceStroke, TweenInfo.new(0.3), {
		Color = Color3.fromRGB(140,90,255),
		Transparency = 0.5
	}):Play()
	rarityBadge.Visible = false
end

-- ══════════════════════════════
--  STREAK DISPLAY
-- ══════════════════════════════
local function updateStreak()
	if rollStreak >= 3 then
		streakLabel.Text = "🔥 Skip streak: " .. rollStreak .. "x — Legendary chance meningkat!"
		streakLabel.TextColor3 = Color3.fromRGB(255,160,40)
	elseif rollStreak > 0 then
		streakLabel.Text = "Skip streak: " .. rollStreak .. "x"
		streakLabel.TextColor3 = Color3.fromRGB(200,200,200)
	else
		streakLabel.Text = ""
	end
end

-- ══════════════════════════════
--  ROLL LOGIC
-- ══════════════════════════════
local diceEmojis = {"⚀","⚁","⚂","⚃","⚄","⚅"}

rollBtn.MouseButton1Click:Connect(function()
	if isRolling or waitingChoice then return end
	if #activeSkills >= MAX_SLOTS then
		skillName.Text = "⚠️ Slot penuh!"
		skillDesc.Text = "Remove salah satu skill dulu (hover & klik slot)."
		return
	end
	isRolling = true
	rollBtn.Text = "Rolling..."
	rollBtn.BackgroundColor3 = Color3.fromRGB(65,38,130)
	skillName.Text = "Rolling..."
	skillDesc.Text = ""

	local elapsed, interval = 0, 0.07
	while elapsed < 1.4 do
		diceLbl.Text = diceEmojis[math.random(1,#diceEmojis)]
		task.wait(interval)
		elapsed = elapsed + interval
		interval = math.min(interval + 0.012, 0.22)
	end

	-- Streak bonus: lebih banyak skip = +chance legendary
	local excludeList = {}
	for id in pairs(activeIds) do table.insert(excludeList, id) end

	-- Inject streak bonus by temporarily boosting legendary weight
	local originalWeight
	if rollStreak >= 3 then
		originalWeight = SkillList.RarityData.Legendary.weight
		SkillList.RarityData.Legendary.weight = originalWeight + rollStreak * 4
	end

	local skill = SkillList.PickRandom(excludeList)

	if rollStreak >= 3 and originalWeight then
		SkillList.RarityData.Legendary.weight = originalWeight
	end

	rollBtn.Text = "🎲  ROLL THE DICE"
	rollBtn.BackgroundColor3 = Color3.fromRGB(110,55,215)
	isRolling = false

	if not skill then
		diceLbl.Text = "😵"
		skillName.Text = "Semua skill sudah aktif!"
		skillDesc.Text = "Clear dulu beberapa skill."
		return
	end

	diceLbl.Text = skill.icon
	skillName.Text = skill.name
	skillName.TextColor3 = rarityColor(skill.rarity)
	skillDesc.Text = skill.desc

	showChoice(skill)
end)

-- ── USE ──
useBtn.MouseButton1Click:Connect(function()
	if not pendingSkill then return end
	local skill = pendingSkill
	local ok, err = pcall(skill.apply, character, humanoid)
	if ok then
		table.insert(activeSkills, { skill = skill })
		activeIds[skill.id] = true
		rollStreak = 0
		updateStreak()
		rebuildSlots()
		skillName.Text = "✅ " .. skill.name
		skillName.TextColor3 = rarityColor(skill.rarity)
		skillDesc.Text = "Skill aktif! Hover slot untuk remove."
	else
		skillName.Text = "❌ Gagal!"
		skillDesc.Text = tostring(err)
		skillName.TextColor3 = Color3.fromRGB(255,100,100)
	end
	hideChoice()
end)

-- ── SKIP ──
skipBtn.MouseButton1Click:Connect(function()
	rollStreak = rollStreak + 1
	updateStreak()
	skillName.Text = "Roll the dice!"
	skillName.TextColor3 = Color3.fromRGB(215,185,255)
	skillDesc.Text = "Dilewatin! Roll lagi buat skill baru."
	diceLbl.Text = "🎲"
	hideChoice()
end)

-- ── CLEAR ALL ──
clearBtn.MouseButton1Click:Connect(function()
	for _, entry in ipairs(activeSkills) do
		pcall(entry.skill.remove, character, humanoid)
	end
	activeSkills = {}
	activeIds = {}
	rollStreak = 0
	updateStreak()
	rebuildSlots()
	skillName.Text = "Roll the dice!"
	skillName.TextColor3 = Color3.fromRGB(215,185,255)
	skillDesc.Text = "Semua skill di-reset! ✨"
	diceLbl.Text = "🎲"
end)

-- ══════════════════════════════
--  HOVER EFFECTS
-- ══════════════════════════════
local function hover(btn, n, h)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = h}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = n}):Play()
	end)
end
hover(rollBtn,  Color3.fromRGB(110,55,215),  Color3.fromRGB(140,75,255))
hover(useBtn,   Color3.fromRGB(70,195,110),  Color3.fromRGB(50,225,90))
hover(skipBtn,  Color3.fromRGB(200,70,70),   Color3.fromRGB(230,50,50))
hover(clearBtn, Color3.fromRGB(50,35,75),    Color3.fromRGB(70,50,110))

-- ══════════════════════════════
--  OPEN ANIMATION
-- ══════════════════════════════
win.Size = UDim2.new(0,0,0,0)
win.Position = UDim2.new(0.5,0,0.5,0)
cont.Visible = false
task.wait(0.05)
TweenService:Create(win, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.new(0,400,0,600),
	Position = UDim2.new(0.5,-200,0.5,-300)
}):Play()
task.wait(0.3)
cont.Visible = true

print("[DiceCore] Loaded! Skill_List connected ✅  Semoga dapat Legendary 🟡")
