-- [[ PLAYER LIST LOGIC ]] --
local PM = _G.PlayerManager
local Players = game:GetService("Players")

local ScrollingFrame = Instance.new("ScrollingFrame", PM.MainFrame)
ScrollingFrame.Size = UDim2.new(0, 180, 0, 280)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local UIList = Instance.new("UIListLayout", ScrollingFrame)
UIList.Padding = UDim.new(0, 5)

PM.RefreshList = function()
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, p in pairs(Players:GetPlayers()) do
        local b = Instance.new("TextButton", ScrollingFrame)
        b.Size = UDim2.new(1, -10, 0, 35)
        b.Text = (p == Players.LocalPlayer and "[YOU] " or "") .. p.DisplayName
        b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        b.TextColor3 = Color3.new(1,1,1)

        b.MouseButton1Click:Connect(function()
            PM.SelectedPlayer = p
            PM.UpdateMenu()
            -- Logic update info simpel
            local loc = p.LocaleId:lower()
            local cName = PM.CountryMap[loc] or "Unknown"
            PM.InfoPanel.Text = "<b>USER:</b> " .. p.Name .. "\n<b>NEGARA:</b> " .. cName
        end)
    end
end

Players.PlayerAdded:Connect(PM.RefreshList)
Players.PlayerRemoving:Connect(PM.RefreshList)
PM.RefreshList()

print("PlayerList.lua Loaded")

