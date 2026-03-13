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

local SelectedIslands = {}

-- 1. Dropdown (Kita buat kosong dulu)
local Dropdown = Tab:Dropdown({
    Title = "Daftar Pulau",
    Desc = "Pilih pulau tujuan",
    Values = {"Belum di-scan"},
    Value = {},
    Multi = true,
    Callback = function(option) 
        SelectedIslands = option 
    end
})

-- 2. Tombol Refresh dengan Fitur Auto-Search
Tab:Button({
    Title = "Refresh List",
    Desc = "Klik ini untuk mencari pulau",
    Callback = function()
        local newList = {}
        
        -- Coba cari di path utama kamu dulu
        local targetFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Islands")
        
        -- Kalau tidak ketemu, cari folder bernama "Islands" di MANAPUN (Recursive search)
        if not targetFolder then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Islands" and (v:IsA("Folder") or v:IsA("Model")) then
                    targetFolder = v
                    break
                end
            end
        end

        if targetFolder then
            for _, item in pairs(targetFolder:GetChildren()) do
                -- Hanya masukkan yang punya nama (bukan part tanpa nama)
                if item.Name ~= "" then
                    table.insert(newList, item.Name)
                end
            end
            
            -- Sortir nama pulau A-Z supaya rapi
            table.sort(newList)

            if #newList > 0 then
                -- Update dropdown
                Dropdown:SetValues(newList)
                
                WindUI:Notify({
                    Title = "Scan Berhasil",
                    Content = "Ditemukan " .. #newList .. " lokasi di: " .. targetFolder:GetFullName(),
                    Duration = 4
                })
            else
                WindUI:Notify({Title = "Kosong", Content = "Folder ketemu, tapi isinya kosong.", Duration = 3})
            end
        else
            WindUI:Notify({Title = "Error", Content = "Folder 'Islands' tidak ditemukan di Workspace!", Duration = 5})
        end
    end
})

-- 3. Teleport dengan Jarak Aman
Tab:Button({
    Title = "Teleport to Island",
    Desc = "Pindah ke atas pulau terpilih",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not root or #SelectedIslands == 0 then return end

        for _, name in pairs(SelectedIslands) do
            -- Kita cari lagi objeknya berdasarkan nama yang dipilih
            local found = workspace:FindFirstChild(name, true) 
            if found and (found:IsA("Model") or found:IsA("BasePart")) then
                -- Teleport 150 stud di atasnya
                root.CFrame = found:GetPivot() * CFrame.new(0, 150, 0)
                
                WindUI:Notify({Title = "Teleported", Content = "Otw ke " .. name, Duration = 2})
                break
            end
        end
    end
})
