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
      Key = {"I Femboy", "Me Femboy", "You Femboy", "EZZ"} -- List of keys that the system will accept, can be RAW file links (pastebin, github, etc.) or simple strings ("hello", "key22")
   }
})

local Tab1 = Window:CreateTab("PublicBot", "bot")

local Paragraph1 = Tab1:CreateParagraph({Title = "Coming Soon!", Content = "I need more knowledge to be able to create a chatbot that can interact with other people and can also auto walk and other people can run commands from this bot but it is still in the development stage."})

local Tab2 = Window:CreateTab("PrivateBot", "eye-off")

local ReplyBot = Tab2:CreateParagraph({Title = "Reply From Bot", Content = "What do you want to ask?"})

-- Variabel penampung teks jawaban AI asli (Solusi biar button copy jalan!)
local lastAIResponse = ""
-- 2. Pengunci sistem (Biar gak dobel request pemicu rate limit palsu)
local isProcessing = false
-- Variabel lokal untuk menyimpan waktu terakhir kirim (Anti-Spam)
local lastInputTime = 0

local CopyButton = Tab2:CreateButton({
   Name = "Copy Massage From Bot",
   Callback = function()
         -- Validasi jika variabel penampung tidak kosong, langsung copy!
      if lastAIResponse ~= "" and lastAIResponse ~= "..." then
         if setclipboard then
            setclipboard(lastAIResponse)
         elseif toclipboard then
            tclipboard(lastAIResponse)
         end
         
         Rayfield:Notify({
            Title = "Clipboard",
            Content = "Jawaban berhasil disalin!",
            Duration = 2,
            Image = "check-circle"
         })
      else
         Rayfield:Notify({
            Title = "Clipboard Error",
            Content = "Belum ada jawaban yang bisa disalin!",
            Duration = 2,
            Image = "ban"
         })
      end
   end,
})

local SectionTabs2 = Tab2:CreateSection("Giving Answers")

local UserAnswer = Tab2:CreateInput({
   Name = "Answer",
   CurrentValue = "",
   PlaceholderText = "Give You answer..",
   RemoveTextAfterFocusLost = true,
   Flag = "UserAnswerToBot",
   Callback = function(Text)
         if Text == "" then return end
      if isProcessing then return end
      
      -- Anti-spam jeda input lokal (Biar gak crash)
      local currentTime = os.time()
      if currentTime - lastInputTime < 2 then
         Rayfield:Notify({
            Title = "Spam Detected",
            Content = "Tunggu jeda 1-2 detik sebelum mengirim pesan lagi!",
            Duration = 2,
            Image = "ban"
         })
         return
      end
      
      isProcessing = true
      lastInputTime = currentTime
      
      ReplyBot:Set({Title = "Reply From Bot", Content = "Thinking..."})
      
      local RawKey = Rayfield.Flags.ApiKeyFosX.CurrentValue or ""
      local CleanedKey = string.gsub(RawKey, "%s+", "")
      
      local HttpService = game:GetService("HttpService")
      
      -- ========================================================
      -- 1. PROSES CHATTING: Text = Json = ai = server -> Tampilkan Jawaban
      -- ========================================================
      local success, response = pcall(function()
         return HttpService:RequestAsync({
            Url = "https://api.groq.com/openai/v1/chat/completions",
            Method = "POST",
            Headers = {
               ["Authorization"] = "Bearer " .. CleanedKey,
               ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
               model = "llama3-8b-8192",
               messages = {
                  { role = "system", content = "You are FosX AI, a helpful Roblox assistant." },
                  { role = "user", content = Text }
               },
               temperature = 0.7
            })
         })
      end)
      
      if success and response and response.StatusCode == 200 then
         local data = HttpService:JSONDecode(response.Body)
         local aiAnswer = data.choices[1].message.content
         
         lastAIResponse = aiAnswer
         -- Server = Json = text = ai (Jawaban sukses nampil!)
         ReplyBot:Set({Title = "FosX AI Result", Content = aiAnswer})
         
         -- ========================================================
         -- 2. KONSEP LU: System = server -> Cek apakah setelah ini limit?
         -- ========================================================
         local checkSuccess, checkResponse = pcall(function()
            return HttpService:RequestAsync({
               Url = "https://api.groq.com/openai/v1/models", -- Sinyal ringan buat nanya status key
               Method = "GET",
               Headers = {
                  ["Authorization"] = "Bearer " .. CleanedKey,
                  ["Content-Type"] = "application/json"
               }
            })
         end)
         
         -- Server = system = Json = text = notif
         if checkSuccess and checkResponse and (checkResponse.StatusCode == 429 or checkResponse.StatusCode == 400) then
            Rayfield:Notify({
               Title = "Rate Limit Warning",
               Content = "Peringatan: Penggunaan baru saja mencapai limit server! Jeda berikutnya mungkin akan melambat.",
               Duration = 8, -- Durasi agak lama sesuai req lu
               Image = "ban"
            })
         end
         
      else
         -- Jika dari request chat awal emang udah eror/limit
         lastAIResponse = "..."
         ReplyBot:Set({Title = "Reply From Bot", Content = ". . ."})
         Rayfield:Notify({
            Title = "Server Error / Limit",
            Content = "Gagal memproses pesan atau API Key limit.",
            Duration = 5,
            Image = "ban"
         })
      end
      
      isProcessing = false
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
    -- Trik sakti: Bersihkan spasi gaib di depan/belakang otomatis
      local CleanedKey = string.gsub(Text, "%s+", "")
      
      if CleanedKey == "" then 
         ServerSignal:Set("Disconnected", "ban")
         return 
      end
      
      -- Menjalankan Real Loading / Pengecekan ke Server Groq
      local HttpService = game:GetService("HttpService")
      local success, response = pcall(function()
         return HttpService:RequestAsync({
            Url = "https://api.groq.com/openai/v1/models", -- Cek model untuk tes validitas key
            Method = "GET",
            Headers = {
               ["Authorization"] = "Bearer " .. CleanedKey,
               ["Content-Type"] = "application/json"
            }
         })
      end)
      
      if success and response and response.StatusCode == 200 then
         -- SUCCESS: Berhasil terhubung, ganti jadi icon "globe"!
         ServerSignal:Set("Connected", "globe")
         
         Rayfield:Notify({
            Title = "System Connection",
            Content = "Success! Server connected and authenticated.",
            Duration = 4,
            Image = "globe",
         })
      else
         -- FAILED: Key invalid atau server error, balikin ke icon "ban"!
         ServerSignal:Set("Invalid API Key", "ban")
         
         Rayfield:Notify({
            Title = "Connection Failed",
            Content = "Invalid API Key or Server Error.",
            Duration = 4,
            Image = "ban",
         })
      end
   end,
})

local Tab4 = Window:CreateTab("Memory", "database-search")

Rayfield:LoadConfiguration()
