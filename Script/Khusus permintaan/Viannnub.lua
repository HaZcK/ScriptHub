-- =============================================
-- CARA PAKAI VIANHUB - BACA DULU YA!
-- 1. Copy semua script ini
-- 2. Paste di executor (Delta, dll)
-- 3. Execute / jalankan
-- 4. Masukkan key: vianhub
-- =============================================

-- [LOAD LIBRARY] -- Jangan diubah, ini yang menjalankan UI-nya
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- =============================================
-- [KEY SYSTEM] -- Sistem kunci agar tidak semua orang bisa pakai
-- Ganti "vianhub" di bawah jika ingin ganti key
-- Ganti "VianHubKey" jika ingin ganti nama file penyimpanan key
-- =============================================
Rayfield:AuthenticateUser({
    Key = "vianhub",         -- << GANTI KEY DI SINI
    FileName = "VianHubKey"  -- << Nama file key yang tersimpan di executor
})

-- =============================================
-- [WINDOW / JENDELA UTAMA]
-- Name        = Judul menu yang muncul di layar
-- LoadingTitle/Subtitle = Teks saat loading
-- FolderName  = Nama folder penyimpanan config di executor
-- FileName    = Nama file config yang tersimpan
-- =============================================
local Window = Rayfield:CreateWindow({
    Name = "VianHub - Premium Menu", -- << Ganti nama menu di sini
    LoadingTitle = "VianHub",
    LoadingSubtitle = "by Vian",     -- << Ganti nama author di sini
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "VianHubConfigs", -- << Nama folder config
        FileName = "VianHub"
    },
    Discord = {
        Enabled = false,       -- << Ganti true jika ingin popup Discord
        Invite = "vianhub",    -- << Isi kode invite Discord kamu
        RememberJoins = true
    },
    KeySystem = false -- Key sudah dihandle AuthenticateUser di atas
})

-- =============================================
-- [TABS] -- Tab adalah halaman/menu di dalam window
-- Angka di parameter ke-2 adalah ID icon dari Roblox
-- Cari icon ID di: roblox.com/catalog
-- =============================================
local MainTab = Window:CreateTab("Main", 4483362458)    -- Tab utama
local VisualTab = Window:CreateTab("Visuals", 4483345875) -- Tab visual/ESP

-- =============================================
-- [VARIABEL INTERNAL] -- Jangan diubah kecuali kamu paham
-- =============================================
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local NoclipEnabled = false -- Menyimpan status noclip (aktif/tidak)

-- =============================================
-- [MAIN TAB - WALK SPEED]
-- Range   = {min, max} -- batas kecepatan
-- Increment = kelipatan slider
-- CurrentValue = nilai default saat pertama dibuka
-- =============================================
MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},    -- << Ganti angka max jika ingin lebih cepat
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,    -- << Kecepatan default (16 = normal Roblox)
    Flag = "WalkSpeed",
    Callback = function(v)
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v -- Terapkan kecepatan ke karakter
        end
    end
})

-- =============================================
-- [MAIN TAB - NOCLIP]
-- Noclip = karakter bisa tembus tembok/objek
-- CurrentValue = false artinya default mati
-- =============================================
MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false, -- << Ganti true jika ingin default menyala
    Flag = "Noclip",
    Callback = function(state)
        NoclipEnabled = state
        -- Saat dimatikan, kembalikan collision normal
        if not state and Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true -- Kembalikan tabrakan normal
                end
            end
        end
    end
})

-- [LOOP NOCLIP] -- Loop ini yang terus-menerus matikan collision saat noclip aktif
-- Jangan dihapus, tanpa ini noclip tidak akan bekerja
RunService.Stepped:Connect(function()
    if NoclipEnabled and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- =============================================
-- [VISUAL TAB - ESP]
-- ESP = bisa lihat pemain lain lewat tembok
-- Highlight berwarna hijau (FillColor) dengan outline putih
-- =============================================

-- Fungsi menambah highlight ke 1 pemain
-- Ganti FillColor / OutlineColor untuk ubah warna ESP
local function addESP(p)
    if p == Player or not p.Character then return end
    if p.Character:FindFirstChild("VianESP") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "VianESP"
    hl.FillColor = Color3.fromRGB(0, 255, 127)   -- << Warna isi ESP
    hl.OutlineColor = Color3.fromRGB(255, 255, 255) -- << Warna outline ESP
    hl.Parent = p.Character
end

-- Fungsi menghapus highlight dari 1 pemain
local function removeESP(p)
    if p.Character and p.Character:FindFirstChild("VianESP") then
        p.Character.VianESP:Destroy()
    end
end

local espPlayerAdded
local espCharAdded = {}

VisualTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false, -- << Ganti true jika ingin ESP default menyala
    Flag = "PlayerESP",
    Callback = function(state)
        _G.ESPVisible = state
        if state then
            -- Pasang ESP ke semua pemain yang sudah ada di server
            for _, p in pairs(game.Players:GetPlayers()) do
                addESP(p)
                -- Pasang ulang ESP saat pemain respawn
                espCharAdded[p] = p.CharacterAdded:Connect(function()
                    task.wait(0.1)
                    if _G.ESPVisible then addESP(p) end
                end)
            end
            -- Pasang ESP ke pemain yang baru join
            espPlayerAdded = game.Players.PlayerAdded:Connect(function(p)
                p.CharacterAdded:Connect(function()
                    task.wait(0.1)
                    if _G.ESPVisible then addESP(p) end
                end)
            end)
        else
            -- Hapus semua ESP dan disconnect listener saat dimatikan
            for _, p in pairs(game.Players:GetPlayers()) do
                removeESP(p)
                if espCharAdded[p] then
                    espCharAdded[p]:Disconnect()
                    espCharAdded[p] = nil
                end
            end
            if espPlayerAdded then
                espPlayerAdded:Disconnect()
                espPlayerAdded = nil
            end
        end
    end
})

-- [LOAD CONFIG] -- Otomatis load pengaturan terakhir saat script dijalankan
-- Jangan dihapus agar slider/toggle ingat posisi terakhir
Rayfield:LoadConfiguration()
