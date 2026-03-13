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

-- Variabel untuk menyimpan pilihan saat ini
local SelectedIslands = {}

-- 1. Buat Dropdown (Awalnya kosong)
local Dropdown = Tab:Dropdown({
    Title = "Daftar Pulau",
    Desc = "Pilih pulau tujuanmu",
    Values = {}, -- Akan diisi saat tombol Refresh diklik
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(option) 
        SelectedIslands = option -- Update list yang dipilih
    end
})

-- 2. Tombol Refresh List
Tab:Button({
    Title = "Refresh List",
    Desc = "Scan ulang folder Workspace.Map.Islands",
    Icon = "list-restart"
    Callback = function()
        local newList = {}
        local IslandsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Islands")
        
        if IslandsFolder then
            for _, item in pairs(IslandsFolder:GetChildren()) do
                -- Pastikan hanya mengambil Model atau BasePart
                if item:IsA("Model") or item:IsA("BasePart") then
                    table.insert(newList, item.Name)
                end
            end
            
            -- Update nilai di Dropdown WindUI
            Dropdown:SetValues(newList)
            
            WindUI:Notify({
                Title = "Selesai",
                Content = "Berhasil menemukan " .. #newList .. " pulau.",
                Duration = 2
            })
        else
            warn("Folder Workspace.Map.Islands tidak ditemukan!")
        end
    end
})

-- 3. Tombol Teleport to Island
Tab:Button({
    Title = "Teleport to Island",
    Desc = "Teleport ke pulau yang dipilih dengan offset tinggi",
    Callback = function()
        local character = game.Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if not rootPart then return end
        
        -- Loop melalui semua pulau yang dicentang di Dropdown
        for _, islandName in pairs(SelectedIslands) do
            local target = workspace.Map.Islands:FindFirstChild(islandName)
            
            if target then
                -- Ambil posisi target menggunakan Pivot
                local targetCFrame = target:GetPivot()
                
                -- Tambahkan offset tinggi (Y + 100) supaya tidak stuck
                -- Kamu bisa ubah angka 100 sesuai keinginan
                local offset = Vector3.new(0, 100, 0)
                rootPart.CFrame = targetCFrame + offset
                
                WindUI:Notify({
                    Title = "Teleporting...",
                    Content = "Sedang menuju ke " .. islandName,
                    Duration = 2
                })
                
                -- Jika hanya ingin teleport ke pulau pertama yang dipilih, tambahkan 'break'
                -- break 
            end
        end
    end
})


