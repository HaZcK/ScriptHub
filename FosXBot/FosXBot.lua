-- ============================================================
--  FosXBot.lua  |  by Khafidz_3
--  Refactored: Full Groq AI Backend Pipeline
--  Pipeline: Text → JSON → Server → JSON → Text → AI
-- ============================================================

-- ── GLOBAL SCOPE VARIABLES (must be at very top) ────────────
_G.isProcessing   = false
_G.lastInputTime  = 0
_G.lastAIResponse = ""

-- ── CORE MEMORY SYSTEM SETUP ────────────────────────────────
local MaxCoreSlots = 10
local CoreMemories = {}
for i = 1, MaxCoreSlots do CoreMemories[i] = "" end

-- ── CHAT HISTORY TABLE ──────────────────────────────────────
local ChatHistory = {
    {
        role    = "system",
        content = "You are FosX, a helpful and friendly AI assistant built into a Roblox executor script. Keep responses concise and clear. You remember what the user tells you about themselves."
    }
}

-- ── RAYFIELD INIT ───────────────────────────────────────────
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name             = "FosX ",
    Icon             = 0,
    LoadingTitle     = "FosXbots Loading...",
    LoadingSubtitle  = "by Khafidz_3",
    ShowText         = "FosX",
    Theme            = "DarkBlue",
    ToggleUIKeybind  = "Q",

    DisableRayfieldPrompts  = false,
    DisableBuildWarnings    = false,

    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "FosXConfig",
        FileName   = "MainFile"
    },

    KeySystem = true,
    KeySettings = {
        Title      = "Enter Key!",
        Subtitle   = "Key system",
        Note       = "Just Say You a Femboy :3",
        FileName   = "FosXKey_Only",
        SaveKey    = true,
        GrabKeyFromSite = false,
        Key        = {"I Femboy", "Me Femboy", "You Femboy", "EZZ"}
    }
})

-- ── TAB 1: PUBLIC BOT ───────────────────────────────────────
local Tab1 = Window:CreateTab("PublicBot", "bot")

local Paragraph1 = Tab1:CreateParagraph({
    Title   = "Coming Soon!",
    Content = "I need more knowledge to be able to create a chatbot that can interact with other people and can also auto walk and other people can run commands from this bot but it is still in the development stage."
})

-- ── TAB 2: PRIVATE BOT ──────────────────────────────────────
local Tab2 = Window:CreateTab("PrivateBot", "eye-off")

local ReplyBot = Tab2:CreateParagraph({
    Title   = "Reply From Bot",
    Content = "What do you want to ask?"
})

local CopyButton = Tab2:CreateButton({
    Name = "Copy Message From Bot",
    Callback = function()
        if _G.lastAIResponse ~= "" and _G.lastAIResponse ~= "..." then
            if setclipboard then
                setclipboard(_G.lastAIResponse)
            elseif toclipboard then
                toclipboard(_G.lastAIResponse)
            end
            Rayfield:Notify({
                Title    = "Clipboard",
                Content  = "Jawaban berhasil disalin!",
                Duration = 2,
                Image    = "check-circle"
            })
        else
            Rayfield:Notify({
                Title    = "Clipboard Error",
                Content  = "Belum ada jawaban yang bisa disalin!",
                Duration = 2,
                Image    = "ban"
            })
        end
    end,
})

local SectionTabs2 = Tab2:CreateSection("Giving Answers")

-- ── INPUT BOX: USERANSWER (with anti-spam + _G guards) ──────
local UserAnswer = Tab2:CreateInput({
    Name                    = "Answer",
    CurrentValue            = "",
    PlaceholderText         = "Give your answer..",
    RemoveTextAfterFocusLost = true,
    Flag                    = "UserAnswerToBot",
    Callback = function(Text)
        -- Guard: empty input
        if Text == "" then return end

        -- Guard: AI is already processing a previous request
        if _G.isProcessing then
            Rayfield:Notify({
                Title    = "Please Wait",
                Content  = "Bot sedang memproses permintaan sebelumnya!",
                Duration = 2,
                Image    = "loader"
            })
            return
        end

        -- Anti-spam: 2-second cooldown using _G.lastInputTime
        local currentTime = os.time()
        if currentTime - _G.lastInputTime < 2 then
            Rayfield:Notify({
                Title    = "Spam Detected",
                Content  = "Tunggu jeda 2 detik sebelum mengirim pesan lagi!",
                Duration = 2,
                Image    = "ban"
            })
            return
        end

        -- Toggle processing state and update timestamp
        _G.isProcessing  = true
        _G.lastInputTime = currentTime

        -- Fire the AI backend engine
        ProcessAIRequest(Text)
    end,
})

-- ── TAB 3: CONFIG ───────────────────────────────────────────
local Tab3 = Window:CreateTab("Config", "cog")

local Info = Tab3:CreateParagraph({
    Title   = "How to get API Key",
    Content = "1. Go to console.groq.com\n2. Login with Google/GitHub\n3. Click 'API Keys' on left sidebar\n4. Click 'Create API Key'\n5. Name it and copy the gsk_... key\n6. Paste it below!"
})

local SectionApikey = Tab3:CreateSection("Api Configuration ⚙️")

local ServerSignal = Tab3:CreateLabel("Disconnected", "ban")

local ApiKeyInput = Tab3:CreateInput({
    Name                    = "Api Key",
    CurrentValue            = "",
    PlaceholderText         = "gsk_*********",
    RemoveTextAfterFocusLost = false,
    Flag                    = "ApiKeyFosX",
    Callback = function(Text)
        local CleanedKey = string.gsub(Text, "%s+", "")
        if CleanedKey == "" then
            ServerSignal:Set("Disconnected", "ban")
            return
        end

        local HttpService = game:GetService("HttpService")
        local success, response = pcall(function()
            return HttpService:RequestAsync({
                Url    = "https://api.groq.com/openai/v1/models",
                Method = "GET",
                Headers = {
                    ["Authorization"] = "Bearer " .. CleanedKey,
                    ["Content-Type"]  = "application/json"
                }
            })
        end)

        if success and response and response.StatusCode == 200 then
            ServerSignal:Set("Connected", "globe")
            Rayfield:Notify({
                Title    = "System Connection",
                Content  = "Success! Server connected and authenticated.",
                Duration = 4,
                Image    = "globe",
            })
        else
            ServerSignal:Set("Invalid API Key", "ban")
            Rayfield:Notify({
                Title    = "Connection Failed",
                Content  = "Invalid API Key or Server Error.",
                Duration = 4,
                Image    = "ban",
            })
        end
    end,
})

-- ── TAB 4: MEMORY ───────────────────────────────────────────
local Tab4 = Window:CreateTab("Memory", "history")

local InfoMemory = Tab4:CreateParagraph({
    Title   = "Memory Management System",
    Content = "This section serves as the dedicated long-term memory configuration for FosX AI. It automatically syncs, tracks, and stores your local private chat history to maintain conversational context and deliver personalized responses. If you wish to wipe out all stored data, identity logs, and previous chat records, simply use the 'Clear All Memory' function below to completely reset the AI's memory matrix back to factory defaults."
})

local Divider = Tab4:CreateDivider()

local MemoryText = Tab4:CreateParagraph({
    Title   = "Conversation History",
    Content = "1. No core memory stored.\n2. \n3. \n4. \n5. \n6. \n7. \n8. \n9. \n10. \nAnd others..."
})

-- ── MEMORY UI UPDATE FUNCTION ────────────────────────────────
-- Rebuilds the MemoryText paragraph from the CoreMemories table
local function UpdateMemoryUI()
    local lines = {}
    for i = 1, MaxCoreSlots do
        if CoreMemories[i] ~= "" then
            table.insert(lines, i .. ". " .. CoreMemories[i])
        else
            table.insert(lines, i .. ". ")
        end
    end
    table.insert(lines, "And others...")
    MemoryText:Set({
        Title   = "Conversation History",
        Content = table.concat(lines, "\n")
    })
end

-- ── CLEAR MEMORY BUTTON ─────────────────────────────────────
local ClearMemoryButton = Tab4:CreateButton({
    Name = "Clear All Memory",
    Callback = function()
        -- Wipe ChatHistory (keep system prompt)
        ChatHistory = {
            {
                role    = "system",
                content = "You are FosX, a helpful and friendly AI assistant built into a Roblox executor script. Keep responses concise and clear. You remember what the user tells you about themselves."
            }
        }

        -- Reset all 10 core memory slots to empty
        for i = 1, MaxCoreSlots do
            CoreMemories[i] = ""
        end

        -- Visually reset MemoryText back to empty states
        UpdateMemoryUI()

        -- Reset global response cache
        _G.lastAIResponse = ""
        _G.isProcessing   = false

        -- Reset ReplyBot display
        if ReplyBot then
            ReplyBot:Set({Title = "Reply From Bot", Content = "What do you want to ask?"})
        end

        Rayfield:Notify({
            Title    = "Memory Cleared",
            Content  = "Semua memori dan riwayat chat telah dihapus!",
            Duration = 3,
            Image    = "trash-2"
        })
    end,
})

-- ── LOAD SAVED CONFIGURATION ────────────────────────────────
Rayfield:LoadConfiguration()

-- ════════════════════════════════════════════════════════════
--  BACKEND ENGINE  (ProcessAIRequest + Chat Listener)
--  Placed at the very bottom so all UI references above are
--  already declared before this function runs.
-- ════════════════════════════════════════════════════════════

-- ── MEMORY FILTER PATTERNS ──────────────────────────────────
-- Regex patterns that detect high-value user identity info
local MemoryPatterns = {
    "my name is ([%w%s]+)",
    "nama saya ([%w%s]+)",
    "nama aku ([%w%s]+)",
    "i am ([%w%s]+)",
    "aku adalah ([%w%s]+)",
    "i like ([%w%s]+)",
    "aku suka ([%w%s]+)",
    "saya suka ([%w%s]+)",
    "i love ([%w%s]+)",
    "aku cinta ([%w%s]+)",
    "i play ([%w%s]+)",
    "i work ([%w%s]+)",
    "umur aku ([%w%s]+)",
    "i am ([%d]+) years",
    "aku berumur ([%d]+)",
}

-- Tries to extract a memory fragment and save it into a free slot
local function TrySaveToMemory(rawInput)
    local lowerInput = rawInput:lower()
    for _, pattern in ipairs(MemoryPatterns) do
        local matched = string.match(lowerInput, pattern)
        if matched then
            -- Clean up captured fragment
            matched = matched:gsub("^%s+", ""):gsub("%s+$", "")
            if matched == "" then break end

            -- Deduplicate: skip if already stored
            for i = 1, MaxCoreSlots do
                if CoreMemories[i]:lower() == matched then return end
            end

            -- Find the first free slot and save
            for i = 1, MaxCoreSlots do
                if CoreMemories[i] == "" then
                    CoreMemories[i] = matched
                    UpdateMemoryUI()
                    return
                end
            end
            -- All slots full — silently skip (oldest not overwritten)
            return
        end
    end
end

-- ── MAIN AI REQUEST FUNCTION ─────────────────────────────────
-- Pipeline: Text → JSON → POST /v1/chat/completions → JSON → Text → UI
function ProcessAIRequest(userRawText)
    -- Show thinking state immediately
    if ReplyBot then
        ReplyBot:Set({Title = "Reply From Bot", Content = "⏳ Thinking..."})
    end

    -- Append user message to conversation history
    table.insert(ChatHistory, {role = "user", content = userRawText})

    -- ── STEP 1: Text → JSON (encode request body) ────────────
    local encodeSuccess, requestPayload = pcall(function()
        return game:GetService("HttpService"):JSONEncode({
            model       = "llama3-8b-8192",
            messages    = ChatHistory,
            temperature = 0.5,
            max_tokens  = 1024
        })
    end)
    if not encodeSuccess then
        _G.isProcessing = false
        if ReplyBot then
            ReplyBot:Set({Title = "Reply From Bot", Content = "❌ Failed to encode request."})
        end
        return
    end

    -- ── STEP 2: Get API Key ──────────────────────────────────
    local ApiKey = string.gsub(
        (Rayfield.Flags.ApiKeyFosX and Rayfield.Flags.ApiKeyFosX.CurrentValue) or "",
        "%s+", ""
    )
    if ApiKey == "" or ApiKey == "gsk_*********" then
        _G.isProcessing = false
        if ReplyBot then
            ReplyBot:Set({Title = "Reply From Bot", Content = "⚠️ API Key belum diisi! Pergi ke tab Config."})
        end
        return
    end

    -- ── STEP 3: JSON → Server (async HTTP POST to Groq) ──────
    task.spawn(function()
        local responseSuccess, serverResponse = pcall(function()
            return game:GetService("HttpService"):RequestAsync({
                Url    = "https://api.groq.com/openai/v1/chat/completions",
                Method = "POST",
                Headers = {
                    ["Authorization"] = "Bearer " .. ApiKey,
                    ["Content-Type"]  = "application/json"
                },
                Body = requestPayload
            })
        end)

        -- Release processing lock
        _G.isProcessing = false

        -- ── STEP 4: Server → JSON (decode response) ──────────
        if responseSuccess and serverResponse and serverResponse.StatusCode == 200 then
            local decodeSuccess, decodedData = pcall(function()
                return game:GetService("HttpService"):JSONDecode(serverResponse.Body)
            end)

            if decodeSuccess and decodedData and decodedData.choices and decodedData.choices[1] then
                -- ── STEP 5: JSON → Text → AI (display to user) ──
                local aiResponseText = decodedData.choices[1].message.content

                -- Store last response for Copy button
                _G.lastAIResponse = aiResponseText

                -- Append AI reply to conversation history
                table.insert(ChatHistory, {role = "assistant", content = aiResponseText})

                -- Update ReplyBot paragraph with actual AI response
                if ReplyBot then
                    ReplyBot:Set({Title = "Reply From Bot", Content = aiResponseText})
                end

                -- Run memory filter on user's original input
                TrySaveToMemory(userRawText)

            else
                if ReplyBot then
                    ReplyBot:Set({Title = "Reply From Bot", Content = "❌ Gagal decode response dari Groq."})
                end
            end

        elseif responseSuccess and serverResponse then
            -- Non-200 status code (rate limit, invalid key at runtime, etc.)
            local errMsg = "Server Error (HTTP " .. tostring(serverResponse.StatusCode) .. ")"
            if serverResponse.StatusCode == 429 then
                errMsg = "⚠️ Rate limit exceeded. Tunggu sebentar lalu coba lagi."
            elseif serverResponse.StatusCode == 401 then
                errMsg = "❌ API Key tidak valid atau sudah expired."
            end
            if ReplyBot then
                ReplyBot:Set({Title = "Reply From Bot", Content = errMsg})
            end
        else
            if ReplyBot then
                ReplyBot:Set({Title = "Reply From Bot", Content = "❌ Network error. Cek koneksi atau key kamu."})
            end
        end
    end)
end

-- ── BACKGROUND LISTENER: TextChatService.MessageReceived ────
-- Listens to in-game chat, filters messages directed at the bot
-- (prefix: "!ask " or "!fosx "), then pipes them into the AI engine
task.spawn(function()
    local TextChatService = game:GetService("TextChatService")

    -- Dual-listener approach: handles both old and new chat systems
    local function HandleChatMessage(message, speakerName)
        if not message or message == "" then return end
        local lower = message:lower()

        -- Only react to messages with the bot trigger prefix
        if lower:sub(1, 5) == "!ask " or lower:sub(1, 7) == "!fosx " then
            local query = message:sub(lower:sub(1,5) == "!ask " and 6 or 8)
            if query == "" then return end
            if _G.isProcessing then return end

            -- Anti-spam for chat listener too
            local now = os.time()
            if now - _G.lastInputTime < 2 then return end

            _G.isProcessing  = true
            _G.lastInputTime = now
            ProcessAIRequest(query)
        end
    end

    -- New TextChatService (2022+)
    if TextChatService.MessageReceived then
        TextChatService.MessageReceived:Connect(function(msg)
            if msg and msg.Text then
                local speaker = (msg.TextSource and msg.TextSource.Name) or "Unknown"
                HandleChatMessage(msg.Text, speaker)
            end
        end)
    end

    -- Legacy Players.LocalPlayer.Chatted fallback
    local Players = game:GetService("Players")
    local LP = Players.LocalPlayer
    if LP then
        LP.Chatted:Connect(function(msg)
            HandleChatMessage(msg, LP.Name)
        end)
    end
end)
