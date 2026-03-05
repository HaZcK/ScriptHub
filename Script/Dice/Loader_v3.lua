-- ╔══════════════════════════════════════════════════╗
-- ║           DICE OF FATE — LOADER v3               ║
-- ║        Paste ke Delta Executor → Execute         ║
-- ╚══════════════════════════════════════════════════╝

-- ⚙️ GANTI URL DI BAWAH INI DENGAN RAW URL KAMU
local URL_SKILL_LIST = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/Dice/Skill_List.lua?token=GHSAT0AAAAAADTPB3T2JXYJ2UHADBVX6XQY2NJOIDQ"  -- ← raw URL Skill_List.lua kamu
local URL_DICE_CORE  = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/Dice/DiceCore.lua?token=GHSAT0AAAAAADTPB3T3NN7WQVFI575MSKK22NJOI5Q"  -- ← raw URL DiceCore.lua kamu

-- ══════════════════════════════
-- JANGAN UBAH BAGIAN BAWAH INI
-- ══════════════════════════════

print("[DiceLoader] 🔄 Memuat Skill_List...")
loadstring(game:HttpGet(URL_SKILL_LIST))()
print("[DiceLoader] ✅ Skill_List loaded!")

print("[DiceLoader] 🔄 Memuat DiceCore...")
loadstring(game:HttpGet(URL_DICE_CORE))()
print("[DiceLoader] ✅ DiceCore loaded!")

print("[DiceLoader] 🎲 DICE OF FATE siap!")
