local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local player = game.Players.LocalPlayer

local Window = WindUI:CreateWindow({
    Title = "UniverseHub",
    Icon = "aperture",
    Author = "Khafidz",
    Folder = "GlobalHub",
        
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("Display Name: " .. player.DisplayName)
            print("Username: " .. player.Name)
            print("ID: " .. player.UserId)

            WindUI:Notify({
                Title = "Info Player",
                Content = "Logged: " .. player.DisplayName,
                Duration = 5,
            })
        end,
    },
})

Window:Tag({
    Title = "1.0",
    Icon = "file-text",
    Color = Color3.fromHex("#87CEEB"),
    Radius = 1,
})

local Updatelog = Window:Tab({
    Title = "Update Log",
    Icon = "scroll-text",
    Locked = false,
})

local Paragraph = Updatelog:Paragraph({
    Title = "Update_Log",
    Desc = "WHERE IS THERE AN UPDATE THAT IS STILL RELEASED",
    Color = "black",
    Locked = false
})
