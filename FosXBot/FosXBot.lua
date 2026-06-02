-- ============================================================
--  FosXBot.lua  |  by Khafidz_3
--  HTTP method  : BloxyAI-style DoRequest() fallback chain
--  AI response  : ReplyBot:Set() paragraph (bukan Notify)
--  Pipeline     : Text → JSON → DoRequest → JSON → Text → Set
-- ============================================================

-- ── GLOBAL SCOPE ────────────────────────────────────────────
_G.isProcessing   = false
_G.lastInputTime  = 0
_G.lastAIResponse = ""

-- ── SERVICES ────────────────────────────────────────────────
local Players     = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TCS         = game:GetService("TextChatService")
local LP          = Players.LocalPlayer

-- ── CORE MEMORY ─────────────────────────────────────────────
local MaxCoreSlots = 10
local CoreMemories = {}
for i = 1, MaxCoreSlots do CoreMemories[i] = "" end

-- ── CHAT HISTORY ────────────────────────────────────────────
local ChatHistory = {
    {
        role    = "system",
        content = "You are FosX, a helpful and friendly AI assistant inside a Roblox executor. Keep responses concise and clear. Remember what the user tells you about themselves."
    }
}

-- ── HTTP ENGINE (BloxyAI-style fallback chain) ───────────────
--  Mencoba semua metode HTTP yang tersedia di executor:
--  request → syn.request → http_request → http.request
local function DoRequest(url, method, headers, body)
    local fn = request
        or (syn and syn.request)
        or http_request
        or (http and http.request)

    if not fn then
        warn("[FosXBot] Tidak ada HTTP method yang tersedia di executor ini!")
        return nil
    end

    local ok, res = pcall(fn, {
        Url     = url,
        Method  = method or "GET",
        Headers = headers or {},
        Body    = body,
    })

    if not ok then
        warn("[FosXBot] Request error: " .. tostring(res))
        return nil
    end

    return res
end

-- ── ERROR HINTS TABLE ────────────────────────────────────────
local ERROR_HINTS = {
    [400] = "Bad request — cek format payload.",
    [401] = "API Key invalid — cek tab Config.",
    [429] = "Rate limit — tunggu sebentar lalu coba lagi.",
    [500] = "Groq server error — coba beberapa saat lagi.",
    [503] = "Model tidak tersedia saat ini.",
}

-- ── RAYFIELD INIT ────────────────────────────────────────────
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name             = "FosX ",
    Icon             = 0,
    LoadingTitle     = "FosXbots Loading...",
    LoadingSubtitle  = "by Khafidz_3",
    ShowText         = "FosX",
    Theme            = "DarkBlue",
    ToggleUIKeybind  = "Q",

    DisableRayfieldPrompts = false,
    DisableBuildWarnings   = false,

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

-- ── TAB 1: PUBLIC BOT ────────────────────────────────────────
local Tab1 = Window:CreateTab("PublicBot", "bot")

Tab1:CreateParagraph({
    Title   = "Coming Soon!",
    Content = "I need more knowledge to be able to create a chatbot that can interact with other people and can also auto walk and other people can run commands from this bot but it is still in the development stage."
})

-- ── TAB 2: PRIVATE BOT ──────────────────────────────────────
local Tab2 = Window:CreateTab("PrivateBot", "eye-off")

-- Paragraph utama tempat response AI ditampilkan via :Set()
local ReplyBot = Tab2:CreateParagraph({
    Title   = "Reply From Bot",
    Content = "What do you want to ask?"
})

Tab2:CreateButton({
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

Tab2:CreateSection("Giving Answers")

-- Input box dengan anti-spam 2 detik + _G guard
Tab2:CreateInput({
    Name                     = "Answer",
    CurrentValue             = "",
    PlaceholderText          = "Give your answer..",
    RemoveTextAfterFocusLost = true,
    Flag                     = "UserAnswerToBot",
    Callback = function(Text)
        if Text == "" then return end

        if _G.isProcessing then
            Rayfield:Notify({
                Title    = "Please Wait",
                Content  = "Bot sedang memproses permintaan sebelumnya!",
                Duration = 2,
                Image    = "loader"
            })
            return
        end

        -- Anti-spam: jeda minimal 2 detik
        local now = os.time()
        if now - _G.lastInputTime < 2 then
            Rayfield:Notify({
                Title    = "Spam Detected",
                Content  = "Tunggu 2 detik sebelum mengirim pesan lagi!",
                Duration = 2,
                Image    = "ban"
            })
            return
        end

        _G.isProcessing  = true
        _G.lastInputTime = now

        ProcessAIRequest(Text)
    end,
})

-- ── TAB 3: CONFIG ────────────────────────────────────────────
local Tab3 = Window:CreateTab("Config", "cog")

Tab3:CreateParagraph({
    Title   = "How to get API Key",
    Content = "1. Go to console.groq.com\n2. Login with Google/GitHub\n3. Click 'API Keys' on left sidebar\n4. Click 'Create API Key'\n5. Name it and copy the gsk_... key\n6. Paste it below!"
})

Tab3:CreateSection("Api Configuration ⚙️")

local ServerSignal = Tab3:CreateLabel("Disconnected", "ban")

Tab3:CreateInput({
    Name                     = "Api Key",
    CurrentValue             = "",
    PlaceholderText          = "gsk_*********",
    RemoveTextAfterFocusLost = false,
    Flag                     = "ApiKeyFosX",
    Callback = function(Text)
        local CleanedKey = Text:gsub("%s+", "")
        if CleanedKey == "" then
            ServerSignal:Set("Disconnected", "ban")
            return
        end

        -- Validasi key dengan hit endpoint /models Groq
        local res = DoRequest(
            "https://api.groq.com/openai/v1/models",
            "GET",
            {
                ["Authorization"] = "Bearer " .. CleanedKey,
                ["Content-Type"]  = "application/json"
            },
            nil
        )

        if res and res.StatusCode == 200 then
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

-- ── TAB 4: MEMORY ────────────────────────────────────────────
local Tab4 = Window:CreateTab("Memory", "history")

Tab4:CreateParagraph({
    Title   = "Memory Management System",
    Content = "This section serves as the dedicated long-term memory configuration for FosX AI. It automatically syncs, tracks, and stores your local private chat history to maintain conversational context and deliver personalized responses. If you wish to wipe out all stored data, identity logs, and previous chat records, simply use the 'Clear All Memory' function below to completely reset the AI's memory matrix back to factory defaults."
})

Tab4:CreateDivider()

-- Paragraph 10-slot core memory — diupdate via :Set()
local MemoryText = Tab4:CreateParagraph({
    Title   = "Conversation History",
    Content = "1. No core memory stored.\n2. \n3. \n4. \n5. \n6. \n7. \n8. \n9. \n10. \nAnd others..."
})

-- ── UPDATE MEMORY UI ─────────────────────────────────────────
local function UpdateMemoryUI()
    local lines = {}
    for i = 1, MaxCoreSlots do
        if CoreMemories[i] ~= "" then
            lines[i] = i .. ". " .. CoreMemories[i]
        else
            lines[i] = i .. ". "
        end
    end
    table.insert(lines, "And others...")
    MemoryText:Set({
        Title   = "Conversation History",
        Content = table.concat(lines, "\n")
    })
end

-- ── CLEAR ALL MEMORY BUTTON ──────────────────────────────────
Tab4:CreateButton({
    Name = "Clear All Memory",
    Callback = function()
        -- Reset chat history (pertahankan system prompt)
        ChatHistory = {
            {
                role    = "system",
                content = "You are FosX, a helpful and friendly AI assistant inside a Roblox executor. Keep responses concise and clear. Remember what the user tells you about themselves."
            }
        }

        -- Kosongkan semua 10 slot core memory
        for i = 1, MaxCoreSlots do
            CoreMemories[i] = ""
        end

        -- Update visual paragraph kembali ke state awal
        UpdateMemoryUI()

        -- Reset global state
        _G.lastAIResponse = ""
        _G.isProcessing   = false

        -- Reset ReplyBot paragraph
        ReplyBot:Set({
            Title   = "Reply From Bot",
            Content = "What do you want to ask?"
        })

        Rayfield:Notify({
            Title    = "Memory Cleared",
            Content  = "Semua memori dan riwayat chat telah dihapus!",
            Duration = 3,
            Image    = "trash-2"
        })
    end,
})

-- ── LOAD CONFIG ──────────────────────────────────────────────
Rayfield:LoadConfiguration()

-- ════════════════════════════════════════════════════════════
--  BACKEND ENGINE
--  DoRequest fallback chain (BloxyAI-style)
--  Response ditampilkan via ReplyBot:Set() (bukan Notify)
-- ════════════════════════════════════════════════════════════

-- Filter pattern untuk deteksi identitas user → simpan ke CoreMemories
local MemoryPatterns = {
    "my name is ([%w%s]+)",
    "nama saya ([%w%s]+)",
    "nama aku ([%w%s]+)",
    "i am ([%a%s]+)",
    "aku adalah ([%w%s]+)",
    "i like ([%w%s]+)",
    "aku suka ([%w%s]+)",
    "saya suka ([%w%s]+)",
    "i love ([%w%s]+)",
    "aku cinta ([%w%s]+)",
    "i play ([%w%s]+)",
    "aku main ([%w%s]+)",
    "umur aku ([%d]+)",
    "i am ([%d]+) years",
    "i work ([%w%s]+)",
}

local function TrySaveToMemory(rawInput)
    local lower = rawInput:lower()
    for _, pattern in ipairs(MemoryPatterns) do
        local matched = lower:match(pattern)
        if matched then
            matched = matched:match("^%s*(.-)%s*$") -- trim
            if matched == "" then break end

            -- Deduplication
            for i = 1, MaxCoreSlots do
                if CoreMemories[i]:lower() == matched then return end
            end

            -- Simpan ke slot kosong pertama
            for i = 1, MaxCoreSlots do
                if CoreMemories[i] == "" then
                    CoreMemories[i] = matched
                    UpdateMemoryUI()
                    return
                end
            end
            return -- Semua slot penuh
        end
    end
end

-- ── MAIN AI REQUEST ──────────────────────────────────────────
-- Pipeline: Text → JSONEncode → DoRequest POST → JSONDecode → ReplyBot:Set()
function ProcessAIRequest(userRawText)
    -- Tampilkan "Thinking..." di paragraph
    ReplyBot:Set({Title = "Reply From Bot", Content = "⏳ Thinking..."})

    -- Ambil API key dari flag
    local ApiKey = (Rayfield.Flags.ApiKeyFosX and Rayfield.Flags.ApiKeyFosX.CurrentValue or "")
        :gsub("%s+", "")

    if ApiKey == "" or ApiKey == "gsk_*********" then
        ReplyBot:Set({Title = "Reply From Bot", Content = "⚠️ API Key belum diisi!\nPergi ke tab Config lalu paste key Groq kamu."})
        _G.isProcessing = false
        return
    end

    -- Append pesan user ke history
    table.insert(ChatHistory, {role = "user", content = userRawText})

    -- Encode payload → JSON body
    local encodeOk, payload = pcall(function()
        return HttpService:JSONEncode({
            model       = "llama3-8b-8192",
            messages    = ChatHistory,
            temperature = 0.5,
            max_tokens  = 1024,
            stream      = false,
        })
    end)

    if not encodeOk then
        ReplyBot:Set({Title = "Reply From Bot", Content = "❌ Gagal encode request."})
        _G.isProcessing = false
        return
    end

    -- Kirim async agar UI tidak freeze
    task.spawn(function()
        local MAX_RETRIES = 3
        local res = nil

        -- Retry loop (seperti BloxyAI)
        for attempt = 1, MAX_RETRIES do
            res = DoRequest(
                "https://api.groq.com/openai/v1/chat/completions",
                "POST",
                {
                    ["Authorization"] = "Bearer " .. ApiKey,
                    ["Content-Type"]  = "application/json",
                },
                payload
            )

            if not res then
                warn(string.format("[FosXBot] Attempt %d/%d — no response", attempt, MAX_RETRIES))
            elseif res.StatusCode == 200 then
                break -- Sukses, keluar loop
            else
                local hint = ERROR_HINTS[res.StatusCode] or ("HTTP " .. tostring(res.StatusCode))
                warn(string.format("[FosXBot] Attempt %d/%d — %s", attempt, MAX_RETRIES, hint))

                -- Jangan retry untuk error client-side (4xx selain 429)
                if res.StatusCode ~= 429 and res.StatusCode < 500 then
                    ReplyBot:Set({Title = "Reply From Bot", Content = "❌ " .. hint})
                    _G.isProcessing = false
                    return
                end

                if attempt < MAX_RETRIES then
                    task.wait(2)
                end
            end
        end

        _G.isProcessing = false

        -- Cek hasil akhir setelah retry
        if not res or res.StatusCode ~= 200 then
            local hint = res and (ERROR_HINTS[res.StatusCode] or "HTTP " .. tostring(res.StatusCode))
                or "Network error / executor tidak support HTTP"
            ReplyBot:Set({Title = "Reply From Bot", Content = "❌ " .. hint})
            return
        end

        -- Decode JSON response dari Groq
        local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, res.Body)

        if not decodeOk or not data or not data.choices or not data.choices[1] then
            ReplyBot:Set({Title = "Reply From Bot", Content = "❌ Gagal decode response Groq."})
            return
        end

        -- Ambil teks AI dari choices[1]
        local aiText = data.choices[1].message.content

        -- Simpan untuk tombol Copy
        _G.lastAIResponse = aiText

        -- Append ke history
        table.insert(ChatHistory, {role = "assistant", content = aiText})

        -- Batasi history max 20 entry (seperti BloxyAI)
        while #ChatHistory > 20 do table.remove(ChatHistory, 2) end

        -- ── TAMPILKAN RESPONSE VIA PARAGRAPH :Set() ──────────
        ReplyBot:Set({
            Title   = "Reply From Bot",
            Content = aiText
        })

        -- Jalankan memory filter pada input user
        TrySaveToMemory(userRawText)
    end)
end

-- ── BACKGROUND CHAT LISTENER ─────────────────────────────────
-- Dual-listener: TCS.MessageReceived + LP.Chatted fallback
-- Trigger prefix: "!ask " atau "!fosx "
task.spawn(function()
    local function HandleMessage(msgText, senderName)
        if not msgText or msgText == "" then return end
        local lower = msgText:lower()

        local prefix5 = lower:sub(1, 5)  -- "!ask "
        local prefix7 = lower:sub(1, 7)  -- "!fosx "

        if prefix5 ~= "!ask " and prefix7 ~= "!fosx " then return end

        local query = msgText:sub(prefix5 == "!ask " and 6 or 8)
        if query == "" then return end
        if _G.isProcessing then return end

        local now = os.time()
        if now - _G.lastInputTime < 2 then return end

        _G.isProcessing  = true
        _G.lastInputTime = now
        ProcessAIRequest(query)
    end

    -- Listener baru (TextChatService 2022+)
    if TCS and TCS.MessageReceived then
        TCS.MessageReceived:Connect(function(msg)
            if msg and msg.Text and msg.TextSource then
                HandleMessage(msg.Text, msg.TextSource.Name or "Unknown")
            end
        end)
    end

    -- Fallback: LP.Chatted (sistem chat lama)
    if LP then
        LP.Chatted:Connect(function(msg)
            HandleMessage(msg, LP.Name)
        end)
    end
end)
