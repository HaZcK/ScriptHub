local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "VianHub - Premium Menu",
    Icon = "rbxassetid://10723343321",
    Author = "Vian",
    Folder = "VianHubConfigs",
}),

-- // KEY SYSTEM \\ --
Window:KeySystem({
    Key = {"vianhub"}, -- Key yang kamu minta
    Note = "Masukkan Key: vianhub",
    URL = "https://discord.gg/vianhub", -- Ganti dengan link kamu jika ada
    OnSuccess = function()
        WindUI:Notify({
            Title = "Access Granted",
            Content = "Welcome to VianHub!",
            Duration = 5
        }),
    end,
})

-- // TABS \\ --
local MainTab = Window:CreateTab("Main", "home")
local VisualTab = Window:CreateTab("Visuals", "eye")

-- // VARIABLES \\ --
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local NoclipEnabled = false

-- // MAIN TAB: WALKSPEED & NOCLIP \\ --
MainTab:AddSlider({
    Title = "Walk Speed",
    Desc = "Kecepatan lari (Maksimal 100)",
    Min = 16, 
    Max = 100,
    Default = 16,
    Callback = function(v)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = v
        end
    end
})

MainTab:AddToggle({
    Title = "Noclip",
    Desc = "Tembus tembok/objek apapun",
    Default = false,
    Callback = function(state)
        NoclipEnabled = state
    end
})

-- Loop Noclip agar tetap aktif
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
VisualTab:AddToggle({
    Title = "Player ESP",
    Desc = "Melihat pemain lain melalui tembok",
    Default = false,
    Callback = function(state)
        _G.ESPVisible = state
        
        if state then
            -- Memberikan Highlight ke semua player yang sudah ada
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= Player and p.Character then
                    local hl = Instance.new("Highlight")
                    hl.Name = "VianESP"
                    hl.FillColor = Color3.fromRGB(0, 255, 127)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = p.Character
                end
            end
        else
            -- Menghapus Highlight
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("VianESP") then
                    p.Character.VianESP:Destroy()
                end
            end
        end
    end
})
