-- ╔══════════════════════════════════════════════════╗
-- ║           DICE OF FATE — LOADER v3               ║
-- ║        Paste ke Delta Executor → Execute         ║
-- ╚══════════════════════════════════════════════════╝

-- ⚙️ GANTI URL DI BAWAH INI DENGAN RAW URL KAMU
local URL_SKILL_LIST = ""  -- ← raw URL Skill_List.lua kamu
local URL_DICE_CORE  = ""  -- ← raw URL DiceCore.lua kamu

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
