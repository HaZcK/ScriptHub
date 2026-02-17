-- [[ MEGA PLAYER MANAGER - ULTIMATE ALL-IN-ONE (EXTENDED) ]] --
-- Fitur: Auto-list, Teleport, Spectate, Inv Check, ESP Highlight, Speed Boost, Self-Actions

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variables
local SelectedPlayer = nil
local Spectating = false
local CurrentHighlight = nil -- Untuk fitur ESP

-- === DATABASE NEGARA ===
local CountryMap = {
    ["en-us"] = "USA 🇺🇸", ["en-gb"] = "UK 🇬🇧", ["id-id"] = "Indonesia 🇮🇩",
    ["ms-my"] = "Malaysia 🇲🇾", ["pt-br"] = "Brazil 🇧🇷", ["es-es"] = "Spain 🇪🇸",
    ["th-th"] = "Thailand 🇹🇭", ["vi-vn"] = "Vietnam 🇻🇳", ["ja-jp"] = "Japan 🇯🇵",
    ["ko-kr"] = "Korea 🇰🇷", ["zh-cn"] = "China 🇨🇳", ["de-de"] = "Germany 🇩🇪",
    ["fr-fr"] = "France 🇫🇷", ["ru-ru"] = "Russia 🇷🇺"
}

-- === PEMBUATAN UI UTAMA ===
local ScreenGui = Instance.new("ScreenGui")
-- Gunakan CoreGui jika support (agar aman dari game), kalau tidak pakai PlayerGui
local success = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
ScreenGui.Name = "UltimateManagerGui"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = " 🛠️ OMNI PLAYER MANAGER PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local PlayerList = Instance.new("ScrollingFrame", MainFrame)
PlayerList.Size = UDim2.new(0, 180, 0, 320)
PlayerList.Position = UDim2.new(0, 10, 0, 50)
PlayerList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PlayerList.ScrollBarThickness = 6
local UIList = Instance.new("UIListLayout", PlayerList)
UIList.Padding = UDim.new(0, 5)

local InfoPanel = Instance.new("TextLabel", MainFrame)
InfoPanel.Size = UDim2.new(0, 310, 0, 120)
InfoPanel.Position = UDim2.new(0, 200, 0, 50)
InfoPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
InfoPanel.Text = "Pilih Player dari list di kiri..."
InfoPanel.TextColor3 = Color3.fromRGB(0, 255, 150)
InfoPanel.TextXAlignment = Enum.TextXAlignment.Left
InfoPanel.TextYAlignment = Enum.TextYAlignment.Top
InfoPanel.RichText = true
InfoPanel.TextSize = 14
Instance.new("UICorner", InfoPanel)

-- Wadah Tombol dengan UIGridLayout (Biar rapi otomatis)
local ButtonContainer = Instance.new("ScrollingFrame", MainFrame)
ButtonContainer.Size = UDim2.new(0, 310, 0, 190)
ButtonContainer.Position = UDim2.new(0, 200, 0, 180)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.ScrollBarThickness = 4

local Grid = Instance.new("UIGridLayout", ButtonContainer)
Grid.CellSize = UDim2.new(0, 148, 0, 35)
Grid.CellPadding = UDim2.new(0, 8, 0, 8)

-- === FUNGSI HELPER ===
local function createBtn(text, color, callback)
    local b = Instance.new("TextButton", ButtonContainer)
    b.Text = text
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function clearESP()
    if CurrentHighlight then
        CurrentHighlight:Destroy()
        CurrentHighlight = nil
    end
end

-- === LOGIKA UPDATE MENU & TOMBOL ===
local function updateMenu()
    -- Bersihkan tombol lama
    for _, v in pairs(ButtonContainer:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    clearESP()
    
    if not SelectedPlayer then return end

    if SelectedPlayer == LocalPlayer then
        -- [ MENU DIRI SENDIRI ]
        InfoPanel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        createBtn("💀 KILL ME", Color3.fromRGB(180, 0, 0), function()
            LocalPlayer.Character.Humanoid.Health = 0
        end)
        
        createBtn("💥 DESTROY CHAR", Color3.fromRGB(150, 75, 0), function()
            LocalPlayer.Character:Destroy()
        end)
        
        createBtn("⚡ SPEED BOOST", Color3.fromRGB(0, 150, 150), function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 50
                print("Speed disetel ke 50!")
            end
        end)
        
        createBtn("🦘 HIGH JUMP", Color3.fromRGB(0, 150, 50), function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.UseJumpPower = true
                LocalPlayer.Character.Humanoid.JumpPower = 100
                print("JumpPower disetel ke 100!")
            end
        end)

        createBtn("🚪 KICK TEST", Color3.fromRGB(50, 50, 50), function()
            LocalPlayer:Kick("Successfully Kicked! (Self-Test)")
        end)
        
    else
        -- [ MENU ORANG LAIN ]
        InfoPanel.TextColor3 = Color3.fromRGB(0, 255, 150)
        
        createBtn("📍 TELEPORT", Color3.fromRGB(0, 100, 200), function()
            if SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
            end
        end)

        createBtn("🎥 SPECTATE", Color3.fromRGB(120, 0, 180), function()
            if Spectating then
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
                Spectating = false
            elseif SelectedPlayer.Character then
                Camera.CameraSubject = SelectedPlayer.Character.Humanoid
                Spectating = true
            end
        end)

        createBtn("🎒 CHECK INV", Color3.fromRGB(200, 130, 0), function()
            print("\n---🎒 INVENTORY: " .. SelectedPlayer.Name .. " ---")
            -- Cek Tas
            local items = SelectedPlayer.Backpack:GetChildren()
            if #items > 0 then
                for _, t in pairs(items) do print("[Tas]: " .. t.Name) end
            else
                print("[Tas]: Kosong")
            end
            -- Cek Tangan
            if SelectedPlayer.Character then
                for _, t in pairs(SelectedPlayer.Character:GetChildren()) do
                    if t:IsA("Tool") then print("[Dipegang]: " .. t.Name) end
                end
            end
        end)

        createBtn("🎯 ESP TARGET", Color3.fromRGB(200, 0, 100), function()
            clearESP()
            if SelectedPlayer.Character then
                CurrentHighlight = Instance.new("Highlight")
                CurrentHighlight.Parent = SelectedPlayer.Character
                CurrentHighlight.FillColor = Color3.fromRGB(255, 0, 0)
                CurrentHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                print("ESP Nyala untuk: " .. SelectedPlayer.Name)
            end
        end)

        createBtn("📋 COPY ID", Color3.fromRGB(80, 80, 80), function()
            if setclipboard then
                setclipboard(tostring(SelectedPlayer.UserId))
                print("UserID disalin ke clipboard!")
            else
                print("UserID (Manual Copy): " .. SelectedPlayer.UserId)
            end
        end)
    end
end

-- === LOGIKA INFORMASI & UPDATE LIST ===
local function refreshInfo()
    if SelectedPlayer then
        local dist = "N/A"
        if SelectedPlayer.Character and SelectedPlayer ~= LocalPlayer then
            local p1 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local p2 = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if p1 and p2 then
                dist = math.floor((p1.Position - p2.Position).Magnitude) .. " studs"
            end
        elseif SelectedPlayer == LocalPlayer then
            dist = "0 (Dirimu Sendiri)"
        end

        local loc = SelectedPlayer.LocaleId:lower()
        local cName = CountryMap[loc] or "Unknown ("..loc..")"

        InfoPanel.Text = string.format(
            " <b>DISPLAY:</b> %s\n" ..
            " <b>USERNAME:</b> @%s\n" ..
            " <b>USER ID:</b> %s\n" ..
            " <b>JARAK:</b> %s\n" ..
            " <b>NEGARA:</b> %s",
            SelectedPlayer.DisplayName, SelectedPlayer.Name, SelectedPlayer.UserId, dist, cName
        )
    end
end

local function refreshList()
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, p in pairs(Players:GetPlayers()) do
        local b = Instance.new("TextButton", PlayerList)
        b.Size = UDim2.new(1, -10, 0, 35)
        b.Text = (p == LocalPlayer and "🟢 [YOU] " or "👤 ") .. p.DisplayName
        b.BackgroundColor3 = (p == LocalPlayer and Color3.fromRGB(50, 70, 40) or Color3.fromRGB(45, 45, 45))
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.Gotham
        b.TextSize = 13
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

        b.MouseButton1Click:Connect(function()
            SelectedPlayer = p
            refreshInfo()
            updateMenu()
        end)
    end
end

-- Loop Real-time Jarak
task.spawn(function()
    while task.wait(0.5) do refreshInfo() end
end)

Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)
refreshList()

print("✅ OMNI Player Manager Loaded!")
