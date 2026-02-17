-- LOADER UTAMA
-- Cara dapat link raw: Buka file di GitHub -> Klik tombol "Raw" -> Copy Link-nya

-- 1. Load Main Logic
loadstring(game:HttpGet("https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/Player%20manager/Main.lua?token=GHSAT0AAAAAADTPB3T3RBUHRZQJY4QFEIBE2MUKR4A"))()

-- 2. Beri jeda sebentar agar UI terbuat
task.wait(0.2)

-- 3. Load Player List Logic
loadstring(game:HttpGet("https://raw.githubusercontent.com/HaZcK/ScriptHub/main/Script/Player%20manager/PlayerList.lua"))()

print("Script Player Manager Loaded Successfully!")

