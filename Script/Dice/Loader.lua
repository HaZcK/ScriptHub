-- ╔══════════════════════════════════════════════════╗
-- ║           DICE OF FATE — LOADER                  ║
-- ║  Paste script ini ke Delta Executor, lalu Execute ║
-- ╚══════════════════════════════════════════════════╝

-- ══════════════════════════════
--  ⚙️  GANTI INI SESUAI REPO KAMU
-- ══════════════════════════════
local GITHUB_USER = "HaZck"       -- ← ganti username GitHub kamu
local GITHUB_REPO = "ScriptHub"           -- ← ganti nama repo kamu
local GITHUB_BRANCH = "main"         -- ← ganti kalau branch kamu "master"

-- ══════════════════════════════
--  URL BUILDER
-- ══════════════════════════════
local RAW = "https://raw.githubusercontent.com/"
	.. GITHUB_USER .. "/"
	.. GITHUB_REPO .. "/"
	.. GITHUB_BRANCH .. "/Script/Dice/"

local URL_SKILL_LIST = RAW .. "Skill_List.lua"
local URL_DICE_CORE  = RAW .. "DiceCore.lua"

-- ══════════════════════════════
--  SERVICES
-- ══════════════════════════════
local HttpService    = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ══════════════════════════════
--  HELPER: Fetch + Loadstring
-- ══════════════════════════════
local function fetchAndLoad(url, label)
	local ok, result = pcall(function()
		return game:HttpGetAsync(url)
	end)

	if not ok or not result or result == "" then
		warn("[DiceLoader] ❌ Gagal fetch " .. label .. " dari:\n" .. url)
		warn("[DiceLoader] Error: " .. tostring(result))
		return nil
	end

	local fn, err = loadstring(result)
	if not fn then
		warn("[DiceLoader] ❌ Gagal loadstring " .. label .. ": " .. tostring(err))
		return nil
	end

	print("[DiceLoader] ✅ " .. label .. " berhasil dimuat!")
	return fn
end

-- ══════════════════════════════
--  STEP 1: Load Skill_List
--  → Inject ke ReplicatedStorage
--  supaya DiceCore bisa require()
-- ══════════════════════════════
print("[DiceLoader] 🔄 Memuat Skill_List...")

local skillListFn = fetchAndLoad(URL_SKILL_LIST, "Skill_List")
if not skillListFn then
	warn("[DiceLoader] ❌ Berhenti — Skill_List gagal dimuat.")
	return
end

-- Hapus module lama kalau ada (re-execute safe)
local oldModule = ReplicatedStorage:FindFirstChild("Skill_List")
if oldModule then oldModule:Destroy() end

-- Buat ModuleScript baru di ReplicatedStorage
local skillModule = Instance.new("ModuleScript")
skillModule.Name   = "Skill_List"
skillModule.Source = "" -- source kosong, kita override returnnya
skillModule.Parent = ReplicatedStorage

-- Karena executor tidak bisa set .Source langsung di runtime,
-- kita pakai metode inject via _G sebagai bridge
_G._DiceSkillList = skillListFn()

-- Override module supaya return dari _G bridge
-- (workaround standar untuk executor environment)
local bridgeSource = [[
	return _G._DiceSkillList
]]
skillModule.Source = bridgeSource

print("[DiceLoader] ✅ Skill_List di-inject ke ReplicatedStorage!")

-- ══════════════════════════════
--  STEP 2: Load & Run DiceCore
-- ══════════════════════════════
print("[DiceLoader] 🔄 Memuat DiceCore...")

local diceFn = fetchAndLoad(URL_DICE_CORE, "DiceCore")
if not diceFn then
	warn("[DiceLoader] ❌ Berhenti — DiceCore gagal dimuat.")
	return
end

-- Jalankan DiceCore
local ok2, err2 = pcall(diceFn)
if not ok2 then
	warn("[DiceLoader] ❌ DiceCore error saat dijalankan: " .. tostring(err2))
	return
end

-- ══════════════════════════════
--  DONE
-- ══════════════════════════════
print([[
[DiceLoader] ══════════════════════════════
[DiceLoader] 🎲 DICE OF FATE loaded!
[DiceLoader] 📦 Skill_List  → ReplicatedStorage ✅
[DiceLoader] 🎮 DiceCore    → Running ✅
[DiceLoader] ══════════════════════════════
]])
