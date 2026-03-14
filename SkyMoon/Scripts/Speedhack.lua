local RunService = game:GetService("RunService")
local targetSpeed = 100 -- Ubah angka ini sesuai keinginan

RunService.Stepped:Connect(function()
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = targetSpeed
        end
    end
end)
