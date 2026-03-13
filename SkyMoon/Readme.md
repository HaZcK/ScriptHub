# 🌙 SkyMoon — ScriptHub

> A modular Roblox script hub that automatically detects the current game by **PlaceId** and loads the corresponding script.

Made by **KHAFIDZKTP** | [HaZcK/ScriptHub](https://github.com/HaZcK/ScriptHub)

---

## 🚀 How It Works

1. Run `Mainscript.lua` in your executor
2. The script fetches `PlaceList.json` from GitHub
3. It checks your current game's **PlaceId**
4. If the game is supported → the matching script loads automatically
5. If not supported → a notification appears: **"Not on the list!"** and closes after 2 seconds

---

## 📂 Folder Structure

```
SkyMoon/
├── Mainscript.lua       ← Run this in your executor
├── PlaceList.json       ← Database of supported games (PlaceId → Script URL)
└── Games/
    └── Fly_For_brainrot.lua   ← Example game script
```

---

## 🎮 Supported Games

| Game Name | PlaceId | Script |
|-----------|---------|--------|
| Fly For Brainrot | *(see PlaceList.json)* | Games/Fly_For_brainrot.lua |

> More games will be added over time.

---

## ➕ How to Add a New Game

1. Open `PlaceList.json`
2. Add a new entry:
```json
{
  "YOUR_PLACE_ID": {
    "name": "Game Name",
    "script": "https://raw.githubusercontent.com/HaZcK/ScriptHub/main/SkyMoon/Games/YourScript.lua"
  }
}
```
3. Upload your game script to the `Games/` folder
4. Done!

---

## ⚠️ Requirements

- A Roblox script executor that supports `HttpGet` (e.g. Delta, Ronix, Synapse)
- Internet connection (for fetching scripts from GitHub)

---

## 📜 License

This project is for educational purposes only.
Use responsibly. The author is not responsible for any misuse.

