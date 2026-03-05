-- ╔══════════════════════════════════════════════════╗
-- ║           DICE OF FATE — LOADER v2               ║
-- ║        Paste ke Delta Executor → Execute         ║
-- ╚══════════════════════════════════════════════════╝

local BASE = "https://raw.githubusercontent.com/HaZcK/ScriptHub/main/Script/Dice/"

-- Step 1: Load Skill_List
print("[DiceLoader] 🔄 Memuat Skill_List...")
loadstring(game:HttpGet(BASE .. "Skill_List.lua"))()
print("[DiceLoader] ✅ Skill_List loaded!")

-- Step 2: Load DiceCore
print("[DiceLoader] 🔄 Memuat DiceCore...")
loadstring(game:HttpGet(BASE .. "DiceCore.lua"))()
print("[DiceLoader] ✅ DiceCore loaded!")

print("[DiceLoader] 🎲 DICE OF FATE siap!")
