local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local defaultGround = Workspace:WaitForChild("DefaultMap"):WaitForChild("Ground")
local activeBrainrots = Workspace:WaitForChild("ActiveBrainrots")

local Window = WindUI:CreateWindow({
    Title = "TsunamiHub",
    Icon = "waves", -- lucide icon
    Author = "by: KHAFIDZKTP",
    Folder = "TsunamiHub",
    
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            local playerName = game.Players.LocalPlayer.Name
        
        print("Hello" .. playerName)
      end,
    },
        -- ↓ Optional. You can remove it.
        -- API = {} ← Services. Read about it below ↓
    },
})

local Tab = Window:Tab({
    Title = "Tab Title",
    Icon = "angry", -- optional
    Locked = false,
})

Tab:Select() -- Select Tab

-- ==========================================
-- 1. PENGATURAN AWAL
-- =========================================

local selectedFolder = nil
local isAutoFarming = false

-- Fungsi ringkas untuk mengambil daftar folder
local function getFolderNames()
    local list = {}
    for _, item in pairs(activeBrainrots:GetChildren()) do
        if item:IsA("Folder") or item:IsA("Model") then
            table.insert(list, item.Name)
        end
    end
    return list
end

-- ==========================================
-- 2. PEMBUATAN ELEMEN UI (WINDUI)
-- ==========================================

-- A. Membuat Dropdown (Single Selection)
local TargetDropdown = Tab:Dropdown({
    Title = "Pilih Folder Target",
    Desc = "Pilih item yang ingin di-farm secara otomatis",
    Values = getFolderNames(), -- Ambil data awal saat UI dimuat
    Value = nil, 
    Multi = false, -- Diubah jadi false agar milih 1 aja
    AllowNone = true,
    Callback = function(option) 
        selectedFolder = option
        print("Folder dipilih: " .. tostring(option))
    end
})

-- B. Membuat Button Refresh Manual
local RefreshButton = Tab:Button({
    Title = "Refresh Selection",
    Desc = "Perbarui daftar folder jika nyangkut",
    Locked = false,
    Callback = function()
        local newList = getFolderNames()
        
        -- Memperbarui Dropdown 
        -- Catatan: Gunakan :SetValues() atau :Refresh() tergantung versi WindUI kamu
        if TargetDropdown.SetValues then
            TargetDropdown:SetValues(newList)
        elseif TargetDropdown.Refresh then
            TargetDropdown:Refresh(newList)
        end
        
        WindUI:Notify({
            Title = "Sukses!",
            Content = "Daftar folder berhasil diperbarui.",
            Duration = 3,
            Icon = "check",
        })
    end
})

-- C. Membuat Toggle Auto Farm
local FarmToggle = Tab:Toggle({
    Title = "Mulai Auto Farm",
    Desc = "Teleport ke item dan otomatis kembali ke Ground",
    Icon = "zap",
    Type = "Checkbox",
    Value = false, 
    Callback = function(state) 
        isAutoFarming = state
        local statusText = state and "AKTIF" or "MATI"
        
        WindUI:Notify({
            Title = "Status Auto Farm",
            Content = "Auto Farm sekarang: " .. statusText,
            Duration = 3,
            Icon = "info",
        })
    end
})

-- ==========================================
-- 3. LOOP AUTO UPDATE DROPDOWN (Tiap 5 Detik)
-- ==========================================
task.spawn(function()
    while task.wait(5) do
        local newList = getFolderNames()
        if TargetDropdown.SetValues then
            TargetDropdown:SetValues(newList)
        elseif TargetDropdown.Refresh then
            TargetDropdown:Refresh(newList)
        end
    end
end)

-- ==========================================
-- 4. LOOP LOGIKA AUTO FARM (Teleport & Ambil)
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do -- Dicek super cepat
        if isAutoFarming and selectedFolder and selectedFolder ~= "" then
            local char = LocalPlayer.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            local targetFolder = activeBrainrots:FindFirstChild(selectedFolder)
            
            if rootPart and targetFolder then
                -- Mencari item di dalam folder
                local item = targetFolder:FindFirstChildWhichIsA("Model") or targetFolder:FindFirstChildWhichIsA("Part")
                
                if item then
                    -- 1. Teleport ke Item
                    -- Menggunakan Pivot() untuk Model, dan CFrame untuk Part biasa
                    rootPart.CFrame = item:IsA("Model") and item:GetPivot() or item.CFrame 
                    task.wait(0.2) -- Jeda biar render sekitar
                    
                    -- 2. Picu ProximityPrompt
                    local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        fireproximityprompt(prompt)
                        task.wait(0.5) -- Jeda selesai ngambil
                    end
                    
                    -- 3. Balik ke Ground (ketinggian + 10)
                    rootPart.CFrame = defaultGround.CFrame + Vector3.new(0, 10, 0)
                    task.wait(0.5) -- Istirahat bentar sebelum lanjut ngambil lagi
                    
                else
                    -- Jika folder kosong (item sudah diambil semua)
                    -- Balik nunggu di Ground
                    rootPart.CFrame = defaultGround.CFrame + Vector3.new(0, 10, 0)
                    task.wait(1) 
                end
            end
        end
    end
end)
