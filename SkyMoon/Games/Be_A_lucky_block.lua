local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer
local Plots = workspace:WaitForChild("Plots")

-- Memori untuk menyimpan lokasi plot agar tidak mencari terus-menerus
local cachedPart = nil

-- Fungsi mencari Plot
local function getMyPlotPart()
    if cachedPart then return cachedPart end
    
    for _, plotFolder in pairs(Plots:GetChildren()) do
        -- Cari tanda pengenal plot kamu
        local sign = plotFolder:FindFirstChild("KHAFIDZKTP_FloatingPlotSign", true)
        if sign then
            -- Jika ketemu, cari part tujuan di dalam folder Leftover
            local leftover = plotFolder:FindFirstChild("Leftover", true)
            local target = leftover and leftover:FindFirstChild("Part")
            if target then
                cachedPart = target
                return target
            end
        end
    end
    return nil
end

-- Hapus GUI lama jika sudah ada (biar tidak tumpang tindih saat execute ulang)
if CoreGui:FindFirstChild("KhafidzTeleportUI") then
    CoreGui:FindFirstChild("KhafidzTeleportUI"):Destroy()
end

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KhafidzTeleportUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false -- Kunci utama agar tidak hilang saat mati

-- Button Utama (Modern & Elegan)
local MainButton = Instance.new("TextButton")
MainButton.Name = "MainButton"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(0, 102, 255) -- Biru Elegan
MainButton.Position = UDim2.new(0.5, -75, 0.1, 0) -- Posisi default atas tengah
MainButton.Size = UDim2.new(0, 150, 0, 45)
MainButton.Font = Enum.Font.GothamMedium
MainButton.Text = "Teleport to Base"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.TextSize = 14
MainButton.AutoButtonColor = true
MainButton.ClipsDescendants = true

-- Membuat Tombol Bulat (Bukan Kotak)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainButton

-- Efek Shadow/Bayangan agar terlihat "Floating"
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.8
UIStroke.Parent = MainButton

-- Logic Teleport
MainButton.MouseButton1Click:Connect(function()
    local target = getMyPlotPart()
    if target then
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = target.CFrame * CFrame.new(0, 3, 0)
        end
    else
        MainButton.Text = "Plot Tidak Ditemukan!"
        task.wait(2)
        MainButton.Text = "Teleport to Base"
    end
end)

-- SCRIPT AGAR TOMBOL BISA DIGESER (DRAGGABLE)
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

print("Script Teleport persistent berhasil dijalankan!")

