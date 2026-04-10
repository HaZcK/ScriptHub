local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/src/init.lua"))()

local Window = WindUI:CreateWindow({
    Title = "VianHub - Premium Menu",
    Icon = "rbxassetid://10723343321",
    Author = "Vian",
    Folder = "VianHubConfigs"
})

-- // KEY SYSTEM \\ --
WindUI:KeySystem({
    Key = {"vianhub"},
    Note = "Masukkan Key: vianhub",
    URL = "https://discord.gg/vianhub",
    OnSuccess = function()
        WindUI:Notify({
            Title = "Access Granted",
            Content = "Welcome to VianHub!",
            Duration = 5
        })
    end
})

-- // TABS \\ --
local MainTab = Window:CreateTab("Main", "home")
local VisualTab = Window:CreateTab("Visuals", "eye")

-- // VARIABLES \\ --
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local NoclipEnabled = false

-- // MAIN TAB \\ --
MainTab:AddSlider({
    Title = "Walk Speed",
    Desc = "Kecepatan lari (Maksimal 100)",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(v)
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end
})

MainTab:AddToggle({
    Title = "Noclip",
    Desc = "Tembus tembok/objek apapun",
    Default = false,
    Callback = function(state)
        NoclipEnabled = state

        -- Restore collision saat dimatikan
        if not state and Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

RunService.Stepped:Connect(function()
    if NoclipEnabled and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- // VISUAL TAB: ESP \\ --
local function addESP(p)
    if p == Player or not p.Character then return end
    if p.Character:FindFirstChild("VianESP") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "VianESP"
    hl.FillColor = Color3.fromRGB(0, 255, 127)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.Parent = p.Character
end

local function removeESP(p)
    if p.Character and p.Character:FindFirstChild("VianESP") then
        p.Character.VianESP:Destroy()
    end
end

local espPlayerAdded
local espCharAdded = {}

VisualTab:AddToggle({
    Title = "Player ESP",
    Desc = "Melihat pemain lain melalui tembok",
    Default = false,
    Callback = function(state)
        _G.ESPVisible = state

        if state then
            for _, p in pairs(game.Players:GetPlayers()) do
                addESP(p)
                -- Handle respawn
                espCharAdded[p] = p.CharacterAdded:Connect(function()
                    task.wait(0.1)
                    if _G.ESPVisible then addESP(p) end
                end)
            end
            espPlayerAdded = game.Players.PlayerAdded:Connect(function(p)
                p.CharacterAdded:Connect(function()
                    task.wait(0.1)
                    if _G.ESPVisible then addESP(p) end
                end)
            end)
        else
            for _, p in pairs(game.Players:GetPlayers()) do
                removeESP(p)
                if espCharAdded[p] then
                    espCharAdded[p]:Disconnect()
                    espCharAdded[p] = nil
                end
            end
            if espPlayerAdded then
                espPlayerAdded:Disconnect()
                espPlayerAdded = nil
            end
        end
    end
})
