-- [[ MAIN LOGIC & UI SETUP ]] --
_G.PlayerManager = {
    SelectedPlayer = nil,
    Spectating = false,
    CountryMap = {
        ["en-us"] = "USA 🇺🇸", ["id-id"] = "Indonesia 🇮🇩", ["ms-my"] = "Malaysia 🇲🇾",
        ["pt-br"] = "Brazil 🇧🇷", ["ja-jp"] = "Japan 🇯🇵", ["en-gb"] = "UK 🇬🇧"
    }
}

local PM = _G.PlayerManager
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- UI Creation
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "ManagerGui"
PM.MainFrame = Instance.new("Frame", ScreenGui)
PM.MainFrame.Size = UDim2.new(0, 500, 0, 350)
PM.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
PM.MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PM.MainFrame.Draggable = true
PM.MainFrame.Active = true

-- Info Panel
PM.InfoPanel = Instance.new("TextLabel", PM.MainFrame)
PM.InfoPanel.Size = UDim2.new(0, 280, 0, 130)
PM.InfoPanel.Position = UDim2.new(0, 205, 0, 50)
PM.InfoPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
PM.InfoPanel.TextColor3 = Color3.fromRGB(0, 255, 0)
PM.InfoPanel.RichText = true

-- Button Container
PM.BtnContainer = Instance.new("Frame", PM.MainFrame)
PM.BtnContainer.Size = UDim2.new(0, 280, 0, 150)
PM.BtnContainer.Position = UDim2.new(0, 205, 0, 190)
PM.BtnContainer.BackgroundTransparency = 1

-- Fungsi Create Button
PM.CreateBtn = function(text, pos, color, callback)
    local b = Instance.new("TextButton", PM.BtnContainer)
    b.Size = UDim2.new(0, 130, 0, 35)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- Fungsi Update Menu saat player diklik
PM.UpdateMenu = function()
    for _, v in pairs(PM.BtnContainer:GetChildren()) do v:Destroy() end
    if not PM.SelectedPlayer then return end

    if PM.SelectedPlayer == LocalPlayer then
        PM.CreateBtn("KILL ME", UDim2.new(0,0,0,0), Color3.fromRGB(200, 0, 0), function()
            LocalPlayer.Character.Humanoid.Health = 0
        end)
        PM.CreateBtn("KICK TEST", UDim2.new(0, 140, 0, 0), Color3.fromRGB(50, 50, 50), function()
            LocalPlayer:Kick("Successfully Kicked!")
        end)
    else
        PM.CreateBtn("Teleport", UDim2.new(0,0,0,0), Color3.fromRGB(0, 100, 200), function()
            LocalPlayer.Character.HumanoidRootPart.CFrame = PM.SelectedPlayer.Character.HumanoidRootPart.CFrame
        end)
    end
end

print("Main.lua Loaded")

