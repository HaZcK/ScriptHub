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
