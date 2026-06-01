local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "FosX ",
   Icon = astroid, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "FosXbots Loading...",
   LoadingSubtitle = "by Khafidz_3",
   ShowText = "FosX", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "DarkBlue", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "Q", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

   -- ScriptID = "sid_xxxxxxxxxxxx", -- Your Script ID from developer.sirius.menu — enables analytics, managed keys, and script hosting

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "FosXConfig", -- Create a custom folder for your hub/game
      FileName = "MainFile"
   },
    
   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "Enter Key!",
      Subtitle = "Key system",
      Note = "Just Say You a Femboy :3", -- Use this to tell the user how to get a key
      FileName = "FosXKey_Only", -- It is recommended to use something unique, as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"I Femboy", "Me Femboy", "You Femboy", "EZ"} -- List of keys that the system will accept, can be RAW file links (pastebin, github, etc.) or simple strings ("hello", "key22")
   }
})

local Tab1 = Window:CreateTab("PublicBot", "app-window")

local Paragraph1 = Tab1:CreateParagraph({Title = "Coming Soon!", Content = "I need more knowledge to be able to create a chatbot that can interact with other people and can also auto walk and other people can run commands from this bot but it is still in the development stage."})

Rayfield:LoadConfiguration()
