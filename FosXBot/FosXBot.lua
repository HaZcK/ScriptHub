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

local Tab1 = Window:CreateTab("PublicBot", "bot")

local Paragraph1 = Tab1:CreateParagraph({Title = "Coming Soon!", Content = "I need more knowledge to be able to create a chatbot that can interact with other people and can also auto walk and other people can run commands from this bot but it is still in the development stage."})

local Tab2 = Window:CreateTab("PrivateBot", "eye-off")

local ReplyBot = Tab2:CreateParagraph({Title = "Reply From Bot", Content = "What do you want to ask?"})

local CopyButton = Tab2:CreateButton({
   Name = "Copy Massage From Bot",
   Callback = function()
         -- Ambil isi teks yang sedang tampil di paragraf ReplyBot
      local textToCopy = ReplyBot.CurrentContent or ReplyBot.Content or "..."
      
      -- Validasi jika teks masih bawaan kosong, jangan di-copy
      if textToCopy ~= "..." and textToCopy ~= "" then
          if setclipboard then
              setclipboard(textToCopy)
          elseif toclipboard then
              toclipboard(textToCopy)
          end
         end
   end,
})

local SectionTabs2 = Tab2:CreateSection("Giving Answers")

local UserAnswer = Tab2:CreateInput({
   Name = "Answer",
   CurrentValue = "",
   PlaceholderText = "Give You answer..",
   RemoveTextAfterFocusLost = false,
   Flag = "UserAnswerToBot",
   Callback = function(Text)
       -- Jalankan efek prank jika user memasukkan teks (tidak kosong)
      if Text ~= "" then
         -- Loop animasi titik-titik biar kelihatan meyakinkan
         ReplyBot:Set({Title = "Reply From Bot", Content = "Thinking."})
         task.wait(0.5)
         ReplyBot:Set({Title = "Reply From Bot", Content = "Thinking.."})
         task.wait(0.5)
         ReplyBot:Set({Title = "Reply From Bot", Content = "Thinking..."})
         task.wait(0.5)
         ReplyBot:Set({Title = "Reply From Bot", Content = "Thinking."})
         task.wait(0.4)
         ReplyBot:Set({Title = "Reply From Bot", Content = "Thinking.."})
         task.wait(0.4)
         ReplyBot:Set({Title = "Reply From Bot", Content = "Thinking..."})
         task.wait(0.4)
         
         -- Setelah total ~2.7 detik, tembak teks aslinya wkwk
         ReplyBot:Set({
            Title = "Reply From Bot",
            Content = "System Bot Not connected yet, still in development stage."
         })
      end
   end,
})

local Tab3 = Window:CreateTab("Config", "cog")

local Info = Tab3:CreateParagraph({Title = "How get Api", Content = "1. Go to console.groq.com\n2. Login with Google/GitHub\n3. Click 'API Keys' on left sidebar\n4. Click 'Create API Key'\n5. Name it and copy the gsk_... key\n6. Paste it below!"})

local SectionApikey = Tab3:CreateSection("Api Configuration⚙️")

local ServerSignal = Tab3:CreateLabel("Disconnected", "ban")

local ApiKeyInput = Tab3:CreateInput({
   Name = "Api key",
   CurrentValue = "",
   PlaceholderText = "gsk_*********",
   RemoveTextAfterFocusLost = false,
   Flag = "ApiKeyFosX",
   Callback = function(Text)
   -- Jangan jalanin sistem kalau teks kosong
      if Text == "" then return end
      
      -- 1. Notifikasi awal: Memulai Real Loading ke Server
      Rayfield:Notify({
         Title = "System Connection",
         Content = "Connecting to Groq Server... Please wait.",
         Duration = 3,
         Image = "refresh-cw",
      })
      
      -- 2. Proses Real Loading: Kirim request tes singkat ke Groq
      local HttpService = game:GetService("HttpService")
      local success, response = pcall(function()
         return request({
            Url = "https://api.groq.com/openai/v1/chat/completions",
            Method = "POST",
            Headers = {
               ["Content-Type"] = "application/json",
               ["Authorization"] = "Bearer " .. Text
            },
            Body = HttpService:JSONEncode({
               model = "llama3-8b-8192",
               messages = {{role = "user", content = "ping"}}
            })
         })
      end)
      
      -- 3. Cek hasil komunikasi dari perintah server system
      if success and response and response.StatusCode == 200 then
         -- Perintah mengubah label & ikon jika SELESAI & BERHASIL
         ServerSignal:Set("Connected", "globe")
         
         Rayfield:Notify({
            Title = "System Connection",
            Content = "Success! Server connected and authenticated.",
            Duration = 4,
            Image = "check-circle",
         })
      else
         -- Jika gagal atau API Key salah, kembalikan ke disconnected
         ServerSignal:Set("Disconnected", "globe-off")
         
         Rayfield:Notify({
            Title = "Connection Failed",
            Content = "Invalid API Key or Server Error. Check your key!",
            Duration = 4,
            Image = "x-circle",
         })
      end
   end,
})

Rayfield:LoadConfiguration()
