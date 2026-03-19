local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "UniverseHub",
    Icon = "aperture", -- lucide icon
    Author = "Khafidz",
    Folder = "GlobalHub",
    
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
        print("Display Name: " .. player.DisplayName)
        print("Username: " .. player.Name)
        print("ID: " .. player.UserId)
        
    WindUI:Notify({
        Title = "Info Player",
        Content = "Logged: " .. player.DisplayName,
        Duration = 5,
    }),
  } ,
})

  Window:Tag({
    Title = "1.0",
    Icon = "file-text",
    Color = Color3.fromHex("#87CEEB"),
    Radius = 0.5, -- from 0 to 13
})
  
  local Updatelog = Window:Tab({
    Title = "Update Log",
    Icon = "scroll-text", -- optional
    Locked = false,
})
      
Tab:Select()
  
local Paragraph = Updatelog:Paragraph({
    Title = "Update_Log",
    Desc = "WHERE IS THERE AN UPDATE THAT IS STILL RELEASED",
    Color = "Blue",
    Locked = false,
})

    
