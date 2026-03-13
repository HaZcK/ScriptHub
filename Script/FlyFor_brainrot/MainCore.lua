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
local Flying = false
local FlySpeed = 50
local BodyVel, BodyGyro

-- Function Fly (Perbaikan dari URL yang error)
local function ToggleFly()
    local lp = game.Players.LocalPlayer
    local mouse = lp:GetMouse()
    
    if Flying then
        Flying = false
        if BodyVel then BodyVel:Destroy() end
        if BodyGyro then BodyGyro:Destroy() end
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.PlatformStand = false
        end
    else
        Flying = true
        local char = lp.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        char.Humanoid.PlatformStand = true
        
        BodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart)
        BodyGyro.P = 9e4
        BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        BodyGyro.cframe = char.HumanoidRootPart.CFrame
        
        BodyVel = Instance.new("BodyVelocity", char.HumanoidRootPart)
        BodyVel.velocity = Vector3.new(0, 0.1, 0)
        BodyVel.maxForce = Vector3.new(9e9, 9e9, 9e9)
        
        task.spawn(function()
            while Flying and char and char:FindFirstChild("HumanoidRootPart") do
                BodyVel.velocity = ((workspace.CurrentCamera.CFrame.LookVector * (FlySpeed)) + (Vector3.new(0, 0.1, 0)))
                BodyGyro.cframe = workspace.CurrentCamera.CFrame
                task.wait()
            end
        end)
    end
end

-- 1. Dropdown List Pulau
local Dropdown = Tab:Dropdown({
    Title = "Daftar Pulau",
    Desc = "Pilih pulau tujuan",
    Values = {},
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(option) 
        SelectedIslands = option 
    end
})

-- 2. Tombol Refresh (Otomatis Cek Model/Part)
Tab:Button({
    Title = "Refresh List",
    Desc = "Cari pulau di Workspace.Map.Islands",
    Callback = function()
        local newList = {}
        local path = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Islands")
        
        if path then
            for _, item in pairs(path:GetChildren()) do
                table.insert(newList, item.Name)
            end
            Dropdown:SetValues(newList)
            WindUI:Notify({Title = "Success", Content = "List pulau diperbarui!", Duration = 2})
        else
            WindUI:Notify({Title = "Error", Content = "Folder Islands tidak ditemukan!", Duration = 3})
        end
    end
})

-- 3. Tombol Teleport (Dengan Offset Tinggi agar tidak stuck)
Tab:Button({
    Title = "Teleport to Island",
    Desc = "Teleport ke atas pulau (Y + 150)",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        for _, name in pairs(SelectedIslands) do
            local target = workspace.Map.Islands:FindFirstChild(name)
            if target then
                -- Teleport ke posisi pulau + 150 stud ke atas
                char.HumanoidRootPart.CFrame = target:GetPivot() * CFrame.new(0, 150, 0)
                break -- Teleport ke yang pertama dipilih saja
            end
        end
    end
})

-- 4. Fitur Fly Toggle
Tab:Toggle({
    Title = "Flight Mode",
    Desc = "Terbang di sekitar map",
    Value = false,
    Callback = function(state)
        if Flying ~= state then
            ToggleFly()
        end
    end
})

-- 5. Speed Slider untuk Fly
Tab:Slider({
    Title = "Fly Speed",
    Desc = "Kecepatan terbang",
    Min = 10,
    Max = 300,
    Value = 50,
    Callback = function(val)
        FlySpeed = val
    end
})
