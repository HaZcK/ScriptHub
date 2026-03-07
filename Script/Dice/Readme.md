# 🎲 Dice of Fate

> **Roll the dice. Embrace the chaos. No two games are the same.**

A fully modular Roblox skill system where every roll gives you a random ability — from tiny legs to god mode. Built for executors. Easy to extend. Made to be shared.

---

## ✨ Features

- 🎲 **Random skill rolls** with weighted rarity system
- 🔥 **Streak bonus** — skip skills to increase Legendary chances
- 🧩 **5 active skill slots** with hover-to-remove
- 📜 **Roll history** — last 20 rolls tracked
- 🤝 **Trade system** — send skills to other players
- 📡 **Server sync** — effects visible to everyone (with DiceServer)
- 🛠️ **Fully customizable** via `DiceUser.lua`

---

## 📁 File Structure

```
Dice/
├── DiceLibrary.lua   — Core engine. Do NOT edit.
├── DiceServer.lua    — Server script (ServerScriptService). Do NOT edit.
├── DicePlayer.lua    — Default skills. Do NOT edit.
└── DiceUser.lua      — YOUR file. Edit freely!
```

> ⚠️ You only ever need to touch **`DiceUser.lua`**.

---

## 🚀 Quick Start

### Step 1 — Set up the server (Roblox Studio)

Place `DiceServer.lua` inside **ServerScriptService** in your game.

```
ServerScriptService/
└── DiceServer  (Script)
```

### Step 2 — Upload files to GitHub

Upload `DiceLibrary.lua` and `DicePlayer.lua` to your public GitHub repo.

> The repo **must be public** so `game:HttpGet()` can access the raw URLs.

### Step 3 — Edit DiceUser.lua

Open `DiceUser.lua` and make sure the URL points to your `DicePlayer.lua`:

```lua
local RAW_URL_PLAYER = "https://raw.githubusercontent.com/YourName/YourRepo/main/Script/Dice/DicePlayer.lua"
```

### Step 4 — Execute

Inject your executor and run `DiceUser.lua`. That's it! 🎉

---

## 🧪 Adding Custom Skills

All custom skills go inside `DiceUser.lua`, **above** `Dice.Launch()`.

### Skill Template

```lua
Dice.AddSkill({
    id      = "unique_id",        -- must be unique!
    name    = "Skill Name",       -- shown in GUI
    icon    = "🎯",               -- any emoji
    rarity  = "Common",           -- Common | Rare | Epic | Legendary
    desc    = "Short description.",
    flavor  = "Cool flavor text.",
    apply = function()
        local c, h = Dice.GetChar()   -- c = Character, h = Humanoid
        -- write your effect here
    end,
    remove = function()
        local c, h = Dice.GetChar()
        -- undo your effect here
    end,
})
```

---

## 📖 Examples

### ⚡ Simple — Change Walk Speed

```lua
Dice.AddSkill({
    id = "fast_feet", name = "Fast Feet", icon = "👟", rarity = "Common",
    desc = "Run at 3x normal speed.",
    apply = function()
        local c, h = Dice.GetChar()
        h.WalkSpeed = 48
    end,
    remove = function()
        local c, h = Dice.GetChar()
        h.WalkSpeed = 16
    end,
})
```

---

### 🔄 Loop — Continuous Effect

Use `Dice.SaveConn()` for effects that run every frame.
Always call `Dice.DropConn()` in `remove()` to stop the loop!

```lua
Dice.AddSkill({
    id = "color_shift", name = "Color Shift", icon = "🌈", rarity = "Rare",
    desc = "Your body cycles through colors continuously.",
    apply = function()
        local RunService = game:GetService("RunService")
        Dice.SaveConn("color_loop", RunService.Heartbeat:Connect(function()
            local c = game:GetService("Players").LocalPlayer.Character
            if not c then return end
            local t = tick()
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.Color = Color3.fromHSV(t % 1, 1, 1)
                end
            end
        end))
    end,
    remove = function()
        Dice.DropConn("color_loop")
        local c = game:GetService("Players").LocalPlayer.Character
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.Color = Color3.fromRGB(163, 162, 165) end
        end
    end,
})
```

---

### 🗿 Part Scaling — Resize Body Parts

Use `Dice.GetOrigSize()` to restore original sizes in `remove()`.

```lua
Dice.AddSkill({
    id = "huge_head", name = "Big Brain", icon = "🗿", rarity = "Common",
    desc = "Your head grows to an enormous size.",
    apply = function()
        local c, h = Dice.GetChar()
        local head = c:FindFirstChild("Head")
        if head then head.Size = Vector3.new(6, 6, 6) end
    end,
    remove = function()
        local c, h = Dice.GetChar()
        local head = c:FindFirstChild("Head")
        local orig = Dice.GetOrigSize("Head")
        if head and orig then head.Size = orig end
    end,
})
```

---

### 🌚 Screen Effect — GUI Overlay

You can create ScreenGui overlays for visual effects!

```lua
Dice.AddSkill({
    id = "darkness", name = "Darkness", icon = "🌚", rarity = "Epic",
    desc = "A thick black fog surrounds you.",
    apply = function()
        local player = game:GetService("Players").LocalPlayer
        local sg = Instance.new("ScreenGui")
        sg.Name = "DarkGui"; sg.DisplayOrder = 998
        sg.ResetOnSpawn = false; sg.Parent = player.PlayerGui

        local f = Instance.new("Frame", sg)
        f.Size = UDim2.new(1,0,1,0)
        f.BackgroundColor3 = Color3.fromRGB(0,0,0)
        f.BackgroundTransparency = 0.3
        f.BorderSizePixel = 0
    end,
    remove = function()
        local sg = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("DarkGui")
        if sg then sg:Destroy() end
    end,
})
```

---

## 🎛️ Optional Settings

You can configure these **before** `Dice.Launch()`:

```lua
-- Change the GUI window title
Dice.SetTitle("🎲  MY DICE MOD")

-- Change max active skill slots (default: 5)
Dice.SetMaxSlots(8)
```

---

## 🎰 Rarity System

| Rarity | Weight | Base Chance | Color |
|--------|--------|-------------|-------|
| ⚪ Common | 50 | ~50% | Gray |
| 🔵 Rare | 30 | ~30% | Blue |
| 🟣 Epic | 15 | ~15% | Purple |
| 🟡 Legendary | 5 | ~5% | Gold |

> 💡 **Streak Bonus** — Every skill you **Skip** adds +4 weight to Legendary.
> Skip 5 times? That's +20 extra weight toward Legendary on your next roll!

---

## 🔑 Full API Reference

| Function | Description |
|----------|-------------|
| `Dice.AddSkill(data)` | Register a skill into the roll pool |
| `Dice.GetChar()` | Returns `(character, humanoid)` |
| `Dice.GetOrigSize(partName)` | Returns original `Vector3` size of a part |
| `Dice.SaveConn(key, connection)` | Save a loop connection to stop it later |
| `Dice.DropConn(key)` | Disconnect and remove a saved connection |
| `Dice.SetTitle(text)` | Change the GUI window title |
| `Dice.SetMaxSlots(n)` | Set max active skill slots |
| `Dice.Launch()` | Show the GUI — **must be last line** |

---

## 💡 Tips & Best Practices

- ✅ Always use a **unique `id`** for each skill — duplicates are ignored
- ✅ Always call `Dice.DropConn()` in `remove()` if you used `Dice.SaveConn()` in `apply()`
- ✅ Use `Dice.GetOrigSize()` to safely restore part sizes
- ✅ Test your skill by rolling and using it, then removing it from the slot
- ❌ Don't call `Dice.Launch()` more than once
- ❌ Don't edit `DiceLibrary.lua`, `DiceServer.lua`, or `DicePlayer.lua`

---

## 🤝 Trade System

The trade system lets you send skills to other players in the same server.

1. Go to **⚙️ Settings** tab → Enable Trade toggle
2. Go to **🤝 Trade** tab
3. Select a player and a skill from your active slots
4. Hit **Send Trade Offer**
5. The other player gets a notification to Accept or Decline

> Requires `DiceServer.lua` in ServerScriptService to work!

---

## 🌐 Server Mode vs Local Mode

| | Server Mode 🌐 | Local Mode 💻 |
|---|---|---|
| Effects visible to others | ✅ Yes | ❌ No |
| Trade system | ✅ Yes | ❌ No |
| Give All GUI | ✅ Yes | ❌ No |
| Still playable | ✅ Yes | ✅ Yes |

Hit **🔍 CHECK SERVER** in the Roll tab to detect which mode you're in.

---

## 📜 License

This project is open-source and free to use, modify, and share.
Credit appreciated but not required. Have fun! 🎲

---

<div align="center">

**Made with 🎲 by HaZcK**

*Roll the dice. Embrace the chaos.*

</div>
