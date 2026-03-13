local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Fly Away",
    Icon = "brain", -- lucide icon
    Author = "Khafidz",
    Folder = "Fly Over",
    
    -- ↓ Optional. You can remove it.
    --[[ You can set 'rbxassetid://' or video to Background.
        'rbxassetid://':
            Background = "rbxassetid://", -- rbxassetid
        Video:
            Background = "video:YOUR-RAW-LINK-TO-VIDEO.webm", -- video 
    --]]
    
    -- ↓ Optional. You can remove it.
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("hi")
        end,
    },
})

local Tab = Window:Tab({
    Title = "Main",
    Icon = "sticky-note", -- optional
    Locked = false,
})

Tab:Select() -- Select Tab

-- 1. Variabel Lokal untuk menyimpan data
local SelectedOptions = {}
local IslandFolder = workspace:WaitForChild("Map"):WaitForChild("Islands")

-- Fungsi untuk mengambil nama semua model di folder Islands
local function GetIslandNames()
    local names = {}
    for _, item in pairs(IslandFolder:GetChildren()) do
        -- Sesuai gambar Dex, kita ambil semua nama anak di folder Islands
        table.insert(names, item.Name)
    end
    table.sort(names) -- Biar urut A-Z
    return names
end

-- 2. Buat Dropdown (Langsung diisi pas awal biar gak "None")
local Dropdown = Tab:Dropdown({
    Title = "Daftar Pulau",
    Desc = "Pilih lokasi teleport",
    Values = GetIslandNames(), -- Langsung panggil fungsi scan
    Value = {},
    Multi = true,
    Callback = function(t)
        SelectedOptions = t
    end
})

-- 3. Tombol Refresh (Jika ada pulau baru muncul)
Tab:Button({
    Title = "Refresh List",
    Desc = "Update daftar pulau jika ada yang baru",
    Callback = function()
        local updatedList = GetIslandNames()
        Dropdown:SetValues(updatedList) -- Paksa WindUI ganti isi list
        
        WindUI:Notify({
            Title = "Updated!",
            Content = "Ditemukan " .. #updatedList .. " pulau.",
            Duration = 3
        })
    end
})

-- 4. Tombol Teleport (Logika +150 Studs)
Tab:Button({
    Title = "Teleport to Island",
    Desc = "Klik untuk terbang ke lokasi (Safe Mode)",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not root then return end
        
        -- Cek apakah ada yang dipilih di dropdown
        if #SelectedOptions == 0 then
            WindUI:Notify({Title = "Error", Content = "Pilih pulau dulu di dropdown!", Duration = 3})
            return
        end

        -- Teleport ke pilihan pertama yang dicentang
        local targetName = SelectedOptions[1] 
        local targetObj = IslandFolder:FindFirstChild(targetName)
        
        if targetObj then
            -- Ambil posisi model dan tambah tinggi 150 agar tidak nyangkut
            local targetPos = targetObj:GetPivot()
            root.CFrame = targetPos * CFrame.new(0, 150, 0)
            
            WindUI:Notify({
                Title = "Success",
                Content = "Teleport ke " .. targetName .. " (Di atas langit)",
                Duration = 3
            })
        end
    end
})

-- Tambahkan variabel ini di bagian atas (di bawah deklarasi Tab)
-- Variabel ini berfungsi sebagai "Ingatan" script
local MyLockedPlot = nil

-- Tombol 1: Untuk mendeteksi dan mengunci base
Tab:Button({
    Title = "Lock My Base (Klik saat di base)",
    Desc = "Mencari base terdekat dan menyimpannya di memori",
    Callback = function()
        local lp = game.Players.LocalPlayer
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not root then return end
        
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then
            WindUI:Notify({Title = "Error", Content = "Folder Plots tidak ditemukan!", Duration = 3})
            return
        end
        
        local closestDist = math.huge
        local closestPlot = nil
        
        -- Cari part "Spawn" paling dekat dengan posisi kita sekarang
        for _, plot in pairs(plotsFolder:GetChildren()) do
            local spawnPart = plot:FindFirstChild("Spawn")
            
            if spawnPart and spawnPart:IsA("BasePart") then
                local dist = (root.Position - spawnPart.Position).Magnitude
                
                if dist < closestDist then
                    closestDist = dist
                    closestPlot = plot
                end
            end
        end
        
        if closestPlot then
            MyLockedPlot = closestPlot -- Simpan ke memori script
            WindUI:Notify({
                Title = "Base Dikunci!",
                Content = "Base kamu terdeteksi di: " .. closestPlot.Name,
                Duration = 4
            })
        else
            WindUI:Notify({Title = "Gagal", Content = "Tidak menemukan part 'Spawn' di dekatmu.", Duration = 3})
        end
    end
})

-- Tombol 2: Untuk Teleport kembali ke base yang sudah dikunci
Tab:Button({
    Title = "Teleport to Base",
    Desc = "Kembali ke base yang sudah di-lock (Anti-Stuck)",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not root then return end
        
        -- Cek apakah kita sudah nge-lock base sebelumnya
        if MyLockedPlot then
            local spawnPart = MyLockedPlot:FindFirstChild("Spawn")
            if spawnPart then
                -- Teleport ke atas part Spawn dengan tinggi +100 stud agar tidak stuck
                root.CFrame = spawnPart.CFrame * CFrame.new(0, 100, 0)
                
                WindUI:Notify({
                    Title = "Teleported",
                    Content = "Berhasil kembali ke " .. MyLockedPlot.Name,
                    Duration = 2
                })
            else
                WindUI:Notify({Title = "Error", Content = "Part 'Spawn' di base kamu hilang!", Duration = 3})
            end
        else
            -- Kalau belum di-lock, suruh user lock dulu
            WindUI:Notify({
                Title = "Perhatian",
                Content = "Silakan klik 'Lock My Base' saat kamu berada di plotmu terlebih dahulu!",
                Duration = 4
            })
        end
    end
})

