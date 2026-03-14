# 🌙 SkyMoon ScriptHub v2.0

> A powerful modular Roblox script hub with a fake CMD interface, Ubuntu boot sequence, admin panel, key system, universal scripts, and a full in-game builder — all in one executor script.

Made by **KHAFIDZKTP** | [HaZcK/ScriptHub](https://github.com/HaZcK/ScriptHub)

---

## ✨ What's New in v2.0

- 🔑 **Key System** — Daily key via puzzle at KeyMoon.html (expires every 24h)
- 🛡️ **Admin Panel** — 5 tabs, 15+ actions each, key-protected
- 🌍 **Universal Script List** — Runs when game is not supported
- 🏗️ **Real Builder** — Full in-game Roblox Studio-like builder
- 🖥️ **Console** — Live game output via LogService
- 💾 **Memory System** — Tracks execute history in `SkyMoon/` folder
- 💬 **Chat Commands** — `/Open_Cmd`, `/Open_Admin`, `/console`, `/Reset_Skymoon`

---

## 🚀 How It Works

1. Run `Mainscript.lua` in your executor
2. **GetKey frame** appears — copy the URL, solve the puzzle, paste your key
3. If `SaveKey` is enabled — next time it auto-verifies from `KeyMemory.json`
4. Main hub appears with a **Scan** button
5. Scan runs Ubuntu boot sequence → hacker mode → workspace scan → game check
6. **Supported game** → loads the matching script from `PlaceList.json`
7. **Unsupported game** → shows `Universal Script List` to pick a script

---

## 📂 Repository Structure

```
SkyMoon/
├── Mainscript.lua          ← Run this in your executor
├── PlaceList.json          ← Supported games database
├── Universal.json          ← Universal scripts list
├── Real_Builder.lua        ← In-game Studio builder
├── KeyMoon.html            ← Daily key puzzle page (GitHub Pages)
├── Scripts/
│   ├── Flygui.lua
│   ├── Speedhack.lua
│   ├── INFJUMP.lua
│   └── Emote-R15.lua
└── Games/
    ├── Fly_For_brainrot.lua
    └── Valley-Prison.lua
```

---

## 🔑 Key System

Keys are generated daily using a deterministic algorithm seeded by the UTC day number. The same algorithm runs in both `KeyMoon.html` and `Mainscript.lua`, so they always match.

**How to get your key:**
1. Open: `https://hazck.github.io/ScriptHub/KeyMoon.html`
2. Solve the word puzzle
3. Copy the key (`SKY-XXXX-XXXX`)
4. Paste it into the in-game key prompt

**Key details:**
- Format: `SKY-XXXX-XXXX`
- Expires: Every 24 hours at `00:00 UTC`
- Saved to: `SkyMoon/KeyMemory.json` in your executor folder
- `SaveKey: true` — skips puzzle on next execute if key is still valid

---

## 💬 Chat Commands

| Command | Action |
|---|---|
| `/Open_Cmd` | Open the Mini CMD window |
| `/Open_Admin` | Open Admin Panel (requires key) |
| `/console` | Open live game console |
| `/Reset_Skymoon` | Reset memory (execute count → 0) |

### Mini CMD Commands
| Command | Action |
|---|---|
| `Check In [Username, Folder]` | Scan a player's folder |
| `Check In [Username, Folder, Object]` | Find specific object |
| `RunConsole` | Open console from Mini CMD |

---

## 🛡️ Admin Panel

Access via `/Open_Admin` — requires daily key verification.

**On first use:** Enter key manually
**On repeat use:** Auto-verifies from `KeyMemory.json` with status animation

| Tab | Features |
|---|---|
| 👥 Players | List all players, TP, God Mode, Anti-AFK, NoClip, Inf Jump, save position, and more |
| 🏃 Move | WalkSpeed, JumpPower, Fly Mode, gravity control, slow motion, moon gravity |
| 🔧 Build | Spawn parts (Block/Sphere/Wedge/Neon/Glass/Metal), delete, anchor, color, **Real Builder** |
| 📍 TP | Teleport by coords/player/spawn/sky, save & load position, random TP |
| 🖥️ GUI | List, hide, show, delete GUIs in PlayerGui |

---

## 🏗️ Real Builder

Access from **Admin Panel → Build tab → Real Builder → Run**

A full in-game Roblox Studio experience:

- **Explorer** — Tree view of Workspace, ReplicatedStorage, StarterGui, Lighting, LocalPlayer
- **Properties** — Edit Name, Size, Anchored, Transparency, Color, Material, and more
- **Tools** — Select, Move, Scale, Rotate
- **Insert Menu** — 28+ object types: Part, Sphere, Wedge, Model, Folder, LocalScript, ModuleScript, PointLight, ParticleEmitter, Sound, RemoteEvent, Fire, Smoke, WeldConstraint, and more
- **Play/Stop** — Toggle play mode to walk around your creation
- **Auto-refresh** — Explorer updates every 3 seconds

---

## 🎮 Supported Games

| Game | PlaceId | Script |
|---|---|---|
| Fly For Brainrots | 74277864669743 | Games/Fly_For_brainrot.lua |
| Valley Prison | 15784744207 | Games/Valley-Prison.lua |

### Adding a New Game

Add an entry to `PlaceList.json`:

```json
{
  "YOUR_PLACE_ID": {
    "name": "Game Name",
    "script": "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/Games/YourScript.lua"
  }
}
```

---

## 🌍 Universal Scripts

Shown when current game is **not in PlaceList**. Edit `Universal.json`:

```json
{
  "1": {
    "name": "FlyAway",
    "script": "https://raw.githubusercontent.com/HaZcK/.../Flygui.lua"
  }
}
```

---

## 💾 Executor Folder Structure

Files saved to your executor's `SkyMoon/` folder:

| File | Contents |
|---|---|
| `memory.json` | Execute count + game log (last 50) |
| `KeyMemory.json` | Key, expiry status, day number, SaveKey toggle |
| `KeyMoon` | Current daily key (plain text) |

---

## ⚠️ Requirements

- Roblox executor with `HttpGet`, `readfile`, `writefile`, `makefolder` support
- Examples: Delta, Ronix, Synapse X, Solara
- Internet connection (for fetching scripts from GitHub)

---

## 📜 License

For educational purposes only. Use responsibly.
The author is not responsible for any misuse of this project.
