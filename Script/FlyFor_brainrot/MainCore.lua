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

-- 1. Inisialisasi Dropdown dengan nilai awal (agar tidak error 'Default')
local Dropdown = Tab:Dropdown({
    Title = "Daftar Pulau",
    Desc = "Pilih pulau tujuan",
    Values = {"None"}, -- Beri isi awal supaya tidak nil
    Value = {"None"},
    Multi = true,
    AllowNone = true,
    Callback = function(option) 
        SelectedIslands = option 
        print("Pulau dipilih: " .. table.concat(option, ", "))
    end
})

-- 2. Fungsi Refresh yang diperbaiki
Tab:Button({
    Title = "Refresh List",
    Desc = "Cari model di Workspace.Map.Islands",
    Callback = function()
        local newList = {}
        
        -- Cari folder secara lebih aman (pcall)
        local success, folder = pcall(function()
            return workspace.Map.Islands
        end)
        
        if success and folder then
            local children = folder:GetChildren()
            print("Isi folder Islands: " .. #children .. " item ditemukan.")
            
            for _, item in pairs(children) do
                -- Masukkan semua nama model/part ke tabel
                table.insert(newList, item.Name)
            end
            
            if #newList > 0 then
                -- Gunakan fungsi Refresh dari WindUI (jika tersedia) atau SetValues
                Dropdown:SetValues(newList)
                
                WindUI:Notify({
                    Title = "Success",
                    Content = "Berhasil menemukan " .. #newList .. " pulau!",
                    Duration = 3
                })
            else
                warn("Folder ada, tapi kosong!")
                WindUI:Notify({Title = "Warning", Content = "Folder Islands kosong!", Duration = 3})
            end
        else
            warn("Path Workspace.Map.Islands TIDAK DITEMUKAN!")
            WindUI:Notify({Title = "Error", Content = "Folder Map/Islands tidak ada!", Duration = 3})
        end
    end
})

-- 3. Tombol Teleport (Dengan Safe-Offset)
Tab:Button({
    Title = "Teleport to Island",
    Desc = "Pindah ke pulau dengan posisi aman",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not root then return end

        for _, name in pairs(SelectedIslands) do
            if name == "None" then continue end
            
            local target = workspace.Map.Islands:FindFirstChild(name)
            if target then
                -- Offset 150 ke atas supaya tidak nyangkut (stuck)
                root.CFrame = target:GetPivot() * CFrame.new(0, 150, 0)
                
                WindUI:Notify({
                    Title = "Teleported",
                    Content = "Sampai di " .. name,
                    Duration = 2
                })
                break
            end
        end
    end
})
