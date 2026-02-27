-- ════════════════════════════════════════════════════════════
--   AI ChatBot - Mobile Edition
--   Powered by pollinations.ai
--   Fitur: Drag • Minimize • Hapus Chat • Ganti Model • Counter
-- ════════════════════════════════════════════════════════════

local existing = game:GetService("CoreGui"):FindFirstChild("AI")
if existing then existing:Destroy() end

local CoreGui       = game:GetService("CoreGui")
local HttpService   = game:GetService("HttpService")
local RunService    = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")

local isStudio  = RunService:IsStudio()
local http_func = request or (http and http.request) or http_request or (syn and syn.request)

-- ── Konfigurasi ──────────────────────────────────────────────
local CONFIG = {
    models = {
        { id = "openai",        label = "GPT-4o"       },
        { id = "openai-large",  label = "GPT-4o Large" },
        { id = "mistral",       label = "Mistral"      },
        { id = "claude-hybridspace", label = "Claude" },
    },
    currentModel = 1,
    systemPrompt = "You are a helpful AI assistant. Be concise and clear.",
    maxHistory   = 40,   -- batas pesan agar tidak terlalu panjang
}

-- ── Warna ────────────────────────────────────────────────────
local C = {
    bg          = Color3.fromRGB(14, 14, 18),
    header      = Color3.fromRGB(22, 22, 30),
    headerBtn   = Color3.fromRGB(35, 35, 50),
    userBubble  = Color3.fromRGB(40, 90, 210),
    aiBubble    = Color3.fromRGB(28, 28, 38),
    inputBg     = Color3.fromRGB(28, 28, 38),
    sendBtn     = Color3.fromRGB(40, 90, 210),
    codeBg      = Color3.fromRGB(18, 18, 26),
    codeHeader  = Color3.fromRGB(26, 26, 40),
    codeCopyBtn = Color3.fromRGB(44, 44, 66),
    border      = Color3.fromRGB(50, 50, 70),
    textPrim    = Color3.fromRGB(230, 230, 240),
    textSec     = Color3.fromRGB(140, 140, 160),
    accent      = Color3.fromRGB(100, 140, 255),
    danger      = Color3.fromRGB(200, 60, 60),
    success     = Color3.fromRGB(60, 180, 100),
    miniBtn     = Color3.fromRGB(255, 190, 40),
    closeBtn    = Color3.fromRGB(220, 60, 60),
}

-- ════════════════════════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════════════════════════
local function corner(inst, r)
    local uc = Instance.new("UICorner", inst)
    uc.CornerRadius = UDim.new(0, r or 12)
    return uc
end
local function stroke(inst, color, thick)
    local us = Instance.new("UIStroke", inst)
    us.Color = color or C.border
    us.Thickness = thick or 1
    us.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return us
end
local function pad(inst, t, b, l, r)
    local p = Instance.new("UIPadding", inst)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
end
local function tween(inst, props, t)
    TweenService:Create(inst, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad), props):Play()
end

-- ════════════════════════════════════════════════════════════
--  ROOT GUI
-- ════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

-- ── Container ────────────────────────────────────────────────
local Container = Instance.new("Frame", ScreenGui)
Container.Name = "Container"
Container.Size = UDim2.new(0.94, 0, 0.86, 0)
Container.Position = UDim2.new(0.03, 0, 0.07, 0)
Container.BackgroundColor3 = C.bg
Container.BorderSizePixel = 0
corner(Container, 20)
stroke(Container, C.border, 1)

-- ════════════════════════════════════════════════════════════
--  HEADER
-- ════════════════════════════════════════════════════════════
local Header = Instance.new("Frame", Container)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 54)
Header.BackgroundColor3 = C.header
Header.BorderSizePixel = 0
corner(Header, 20)

-- Teks judul di header
local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Position = UDim2.new(0, 56, 0, 0)
TitleLabel.Size = UDim2.new(0.45, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextColor3 = C.textPrim
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "✦ AI Chat"

-- Counter pesan
local CounterLabel = Instance.new("TextLabel", Header)
CounterLabel.Position = UDim2.new(0, 56, 0, 0)
CounterLabel.Size = UDim2.new(0.45, 0, 1, 0)
CounterLabel.BackgroundTransparency = 1
CounterLabel.Font = Enum.Font.Gotham
CounterLabel.TextSize = 13
CounterLabel.TextColor3 = C.textSec
CounterLabel.TextXAlignment = Enum.TextXAlignment.Left
CounterLabel.Position = UDim2.new(0, 56, 0.52, 0)
CounterLabel.Text = "0 pesan"

-- ── Tombol Header (kanan) ────────────────────────────────────
local function makeHeaderBtn(icon, xOffset, bgColor)
    local btn = Instance.new("TextButton", Header)
    btn.Size = UDim2.new(0, 36, 0, 36)
    btn.Position = UDim2.new(1, xOffset, 0.5, 0)
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.BackgroundColor3 = bgColor or C.headerBtn
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = icon
    corner(btn, 10)
    return btn
end

local BtnClose    = makeHeaderBtn("✕", -8,  C.closeBtn)
local BtnMinimize = makeHeaderBtn("─", -50, C.miniBtn)
local BtnClear    = makeHeaderBtn("🗑", -94, C.headerBtn)
local BtnModel    = makeHeaderBtn("⚙", -136, C.headerBtn)

-- Icon kiri header
local HeaderIcon = Instance.new("ImageLabel", Header)
HeaderIcon.Position = UDim2.new(0, 10, 0.5, 0)
HeaderIcon.Size = UDim2.new(0, 34, 0, 34)
HeaderIcon.AnchorPoint = Vector2.new(0, 0.5)
HeaderIcon.BackgroundTransparency = 1
HeaderIcon.Image = "rbxassetid://125966901198850"

-- ════════════════════════════════════════════════════════════
--  MODEL PICKER (dropdown sederhana, muncul di bawah header)
-- ════════════════════════════════════════════════════════════
local ModelPicker = Instance.new("Frame", Container)
ModelPicker.Name = "ModelPicker"
ModelPicker.Position = UDim2.new(1, -196, 0, 58)
ModelPicker.Size = UDim2.new(0, 188, 0, 0)
ModelPicker.BackgroundColor3 = C.codeHeader
ModelPicker.BorderSizePixel = 0
ModelPicker.Visible = false
ModelPicker.ZIndex = 20
corner(ModelPicker, 12)
stroke(ModelPicker, C.border)

local MPLayout = Instance.new("UIListLayout", ModelPicker)
MPLayout.SortOrder = Enum.SortOrder.LayoutOrder
MPLayout.Padding = UDim.new(0, 2)
pad(ModelPicker, 6, 6, 6, 6)

local modelBtns = {}
for i, m in ipairs(CONFIG.models) do
    local mb = Instance.new("TextButton", ModelPicker)
    mb.Size = UDim2.new(1, 0, 0, 38)
    mb.BackgroundColor3 = i == CONFIG.currentModel and C.accent or C.headerBtn
    mb.BorderSizePixel = 0
    mb.Font = Enum.Font.GothamMedium
    mb.TextSize = 14
    mb.TextColor3 = Color3.fromRGB(230, 230, 255)
    mb.Text = (i == CONFIG.currentModel and "● " or "  ") .. m.label
    mb.ZIndex = 21
    mb.LayoutOrder = i
    corner(mb, 8)
    modelBtns[i] = mb
end
ModelPicker.Size = UDim2.new(0, 188, 0, (#CONFIG.models * 40) + 12)

-- ════════════════════════════════════════════════════════════
--  AREA PESAN
-- ════════════════════════════════════════════════════════════
local Messages = Instance.new("ScrollingFrame", Container)
Messages.Name = "Messages"
Messages.Position = UDim2.new(0, 0, 0, 58)
Messages.Size = UDim2.new(1, 0, 1, -126)
Messages.BackgroundTransparency = 1
Messages.BorderSizePixel = 0
Messages.ScrollBarThickness = 5
Messages.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 100)
Messages.AutomaticCanvasSize = Enum.AutomaticSize.Y
Messages.CanvasSize = UDim2.new(0,0,0,0)

local MsgLayout = Instance.new("UIListLayout", Messages)
MsgLayout.SortOrder = Enum.SortOrder.LayoutOrder
MsgLayout.Padding = UDim.new(0, 10)
pad(Messages, 10, 10, 10, 10)

-- ════════════════════════════════════════════════════════════
--  INPUT BAR
-- ════════════════════════════════════════════════════════════
local InputBar = Instance.new("Frame", Container)
InputBar.Position = UDim2.new(0, 8, 1, -66)
InputBar.Size = UDim2.new(1, -16, 0, 58)
InputBar.BackgroundTransparency = 1
InputBar.BorderSizePixel = 0

local Bar = Instance.new("TextBox", InputBar)
Bar.Position = UDim2.new(0, 0, 0.5, 0)
Bar.Size = UDim2.new(1, -70, 0, 46)
Bar.AnchorPoint = Vector2.new(0, 0.5)
Bar.BackgroundColor3 = C.inputBg
Bar.BorderSizePixel = 0
Bar.Font = Enum.Font.GothamMedium
Bar.TextColor3 = C.textPrim
Bar.PlaceholderColor3 = C.textSec
Bar.TextSize = 18
Bar.PlaceholderText = "Tanya sesuatu..."
Bar.TextWrapped = true
Bar.TextXAlignment = Enum.TextXAlignment.Left
Bar.MultiLine = true
Bar.ClearTextOnFocus = false
corner(Bar, 22)
pad(Bar, 8, 8, 16, 16)
stroke(Bar, C.border, 1)

local SendBtn = Instance.new("TextButton", InputBar)
SendBtn.Position = UDim2.new(1, -62, 0.5, 0)
SendBtn.Size = UDim2.new(0, 56, 0, 46)
SendBtn.AnchorPoint = Vector2.new(0, 0.5)
SendBtn.BackgroundColor3 = C.sendBtn
SendBtn.BorderSizePixel = 0
SendBtn.Font = Enum.Font.GothamBold
SendBtn.TextColor3 = Color3.fromRGB(255,255,255)
SendBtn.TextSize = 20
SendBtn.Text = "➤"
corner(SendBtn, 22)

-- ════════════════════════════════════════════════════════════
--  MINIMIZE BAR (bar kecil muncul saat minimize)
-- ════════════════════════════════════════════════════════════
local MiniBar = Instance.new("Frame", ScreenGui)
MiniBar.Name = "MiniBar"
MiniBar.Size = UDim2.new(0, 140, 0, 44)
MiniBar.Position = UDim2.new(0.03, 0, 0.07, 0)
MiniBar.BackgroundColor3 = C.header
MiniBar.BorderSizePixel = 0
MiniBar.Visible = false
corner(MiniBar, 22)
stroke(MiniBar, C.border)

local MiniIcon = Instance.new("ImageLabel", MiniBar)
MiniIcon.Position = UDim2.new(0, 10, 0.5, 0)
MiniIcon.Size = UDim2.new(0, 28, 0, 28)
MiniIcon.AnchorPoint = Vector2.new(0, 0.5)
MiniIcon.BackgroundTransparency = 1
MiniIcon.Image = "rbxassetid://125966901198850"

local MiniLabel = Instance.new("TextLabel", MiniBar)
MiniLabel.Position = UDim2.new(0, 46, 0, 0)
MiniLabel.Size = UDim2.new(1, -46, 1, 0)
MiniLabel.BackgroundTransparency = 1
MiniLabel.Font = Enum.Font.GothamBold
MiniLabel.TextSize = 14
MiniLabel.TextColor3 = C.textPrim
MiniLabel.TextXAlignment = Enum.TextXAlignment.Left
MiniLabel.Text = "✦ AI Chat"

-- ════════════════════════════════════════════════════════════
--  STATE
-- ════════════════════════════════════════════════════════════
local msgCount    = 0
local userMsgCount = 0
local isGenerating = false
local isMinimized  = false
local modelPickerOpen = false

local messages = {
    { role = "system", content = CONFIG.systemPrompt }
}

-- ════════════════════════════════════════════════════════════
--  DRAG (geser) — bekerja di HP & PC
-- ════════════════════════════════════════════════════════════
local function makeDraggable(frame, handle)
    local dragging, dragStart, startPos = false, nil, nil

    local function onStart(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end
    local function onMove(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
    local function onEnd(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end

    handle.InputBegan:Connect(onStart)
    UIS.InputChanged:Connect(onMove)
    UIS.InputEnded:Connect(onEnd)
end

makeDraggable(Container, Header)
makeDraggable(MiniBar,   MiniBar)

-- ════════════════════════════════════════════════════════════
--  FUNGSI UI
-- ════════════════════════════════════════════════════════════
local function scrollToBottom()
    task.wait(0.05)
    Messages.CanvasPosition = Vector2.new(0, math.huge)
end

local function updateCounter()
    CounterLabel.Text = userMsgCount .. " pesan"
end

-- Buat bubble teks
local function createTextBubble(isUser, text)
    msgCount += 1
    local row = Instance.new("Frame", Messages)
    row.Name = isUser and "UserRow" or "AIRow"
    row.LayoutOrder = msgCount
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BorderSizePixel = 0

    local bubble = Instance.new("Frame", row)
    bubble.AutomaticSize = Enum.AutomaticSize.XY
    bubble.BackgroundColor3 = isUser and C.userBubble or C.aiBubble
    bubble.BorderSizePixel = 0
    bubble.AnchorPoint = Vector2.new(isUser and 1 or 0, 0)
    bubble.Position = UDim2.new(isUser and 1 or 0, 0, 0, 0)
    corner(bubble, 16)

    local label = Instance.new("TextLabel", bubble)
    label.Name = "Message"
    label.AutomaticSize = Enum.AutomaticSize.XY
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 18
    label.TextColor3 = isUser and Color3.fromRGB(255,255,255) or C.textPrim
    label.TextWrapped = true
    label.RichText = true
    label.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
    label.Text = text
    pad(label, 10, 10, 14, 14)

    -- Animasi muncul
    bubble.BackgroundTransparency = 1
    tween(bubble, { BackgroundTransparency = 0 }, 0.15)

    scrollToBottom()
    return label
end

-- ════════════════════════════════════════════════════════════
--  CODEBOX
-- ════════════════════════════════════════════════════════════
local function createCodeBox(lang, code)
    msgCount += 1
    local wrapper = Instance.new("Frame", Messages)
    wrapper.Name = "CodeBox"
    wrapper.LayoutOrder = msgCount
    wrapper.Size = UDim2.new(1, 0, 0, 0)
    wrapper.AutomaticSize = Enum.AutomaticSize.Y
    wrapper.BackgroundColor3 = C.codeBg
    wrapper.BorderSizePixel = 0
    corner(wrapper, 14)
    stroke(wrapper, C.border, 1)

    -- Header codebox
    local ch = Instance.new("Frame", wrapper)
    ch.Size = UDim2.new(1, 0, 0, 40)
    ch.BackgroundColor3 = C.codeHeader
    ch.BorderSizePixel = 0
    corner(ch, 14)

    local ll = Instance.new("TextLabel", ch)
    ll.Position = UDim2.new(0, 14, 0, 0)
    ll.Size = UDim2.new(0.6, 0, 1, 0)
    ll.BackgroundTransparency = 1
    ll.Font = Enum.Font.GothamBold
    ll.TextSize = 13
    ll.TextColor3 = C.accent
    ll.TextXAlignment = Enum.TextXAlignment.Left
    ll.Text = (lang ~= "" and lang or "code"):upper()

    local cpBtn = Instance.new("TextButton", ch)
    cpBtn.Position = UDim2.new(1, -8, 0.5, 0)
    cpBtn.Size = UDim2.new(0, 90, 0, 28)
    cpBtn.AnchorPoint = Vector2.new(1, 0.5)
    cpBtn.BackgroundColor3 = C.codeCopyBtn
    cpBtn.BorderSizePixel = 0
    cpBtn.Font = Enum.Font.GothamMedium
    cpBtn.TextColor3 = Color3.fromRGB(190, 205, 255)
    cpBtn.TextSize = 13
    cpBtn.Text = "📋 Salin"
    corner(cpBtn, 8)

    -- Scroll area kode
    local cs2 = Instance.new("ScrollingFrame", wrapper)
    cs2.Position = UDim2.new(0, 0, 0, 40)
    cs2.Size = UDim2.new(1, 0, 0, 0)
    cs2.AutomaticSize = Enum.AutomaticSize.Y
    cs2.BackgroundTransparency = 1
    cs2.BorderSizePixel = 0
    cs2.ScrollBarThickness = 4
    cs2.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 120)
    cs2.AutomaticCanvasSize = Enum.AutomaticSize.XY
    cs2.CanvasSize = UDim2.new(0,0,0,0)
    cs2.ElasticBehavior = Enum.ElasticBehavior.Never

    local cl = Instance.new("TextLabel", cs2)
    cl.AutomaticSize = Enum.AutomaticSize.XY
    cl.BackgroundTransparency = 1
    cl.Font = Enum.Font.Code
    cl.TextSize = 15
    cl.TextColor3 = Color3.fromRGB(180, 230, 150)
    cl.TextWrapped = false
    cl.RichText = false
    cl.TextXAlignment = Enum.TextXAlignment.Left
    cl.TextYAlignment = Enum.TextYAlignment.Top
    cl.Text = code
    pad(cl, 10, 14, 14, 14)

    -- Tombol salin
    local function doCopy()
        pcall(function()
            if isStudio then print("[COPY]\n"..code) else setclipboard(code) end
        end)
        cpBtn.Text = "✅ Disalin!"
        cpBtn.BackgroundColor3 = Color3.fromRGB(30, 90, 55)
        task.delay(2, function()
            if cpBtn.Parent then
                cpBtn.Text = "📋 Salin"
                cpBtn.BackgroundColor3 = C.codeCopyBtn
            end
        end)
    end
    cpBtn.MouseButton1Click:Connect(doCopy)
    cpBtn.TouchTap:Connect(doCopy)

    scrollToBottom()
    return wrapper
end

-- ════════════════════════════════════════════════════════════
--  RICH TEXT & PARSER
-- ════════════════════════════════════════════════════════════
local function richText(txt)
    txt = txt:gsub("%*%*(.-)%*%*", "<b>%1</b>")
    txt = txt:gsub("_(.-)_",       "<i>%1</i>")
    txt = txt:gsub("~~(.-)~~",     "<strike>%1</strike>")
    txt = txt:gsub("`([^`]+)`",    '<font color="rgb(160,210,120)" face="Code">%1</font>')
    return txt
end

local function renderAIMessage(fullText)
    local pos = 1
    local rendered = false
    while pos <= #fullText do
        local openS, openE, lang = fullText:find("```([^\n]*)\n", pos)
        if openS then
            if openS > pos then
                local before = fullText:sub(pos, openS-1):gsub("^%s+",""):gsub("%s+$","")
                if before ~= "" then createTextBubble(false, richText(before)) end
            end
            local closeS, closeE = fullText:find("\n```", openE+1)
            if closeS then
                createCodeBox(lang or "", fullText:sub(openE+1, closeS))
                pos = closeE + 1
            else
                createTextBubble(false, richText(fullText:sub(openS)))
                pos = #fullText + 1
            end
            rendered = true
        else
            local rest = fullText:sub(pos):gsub("^%s+",""):gsub("%s+$","")
            if rest ~= "" then createTextBubble(false, richText(rest)) rendered = true end
            break
        end
    end
    if not rendered then createTextBubble(false, richText(fullText)) end
end

-- ════════════════════════════════════════════════════════════
--  KIRIM PESAN
-- ════════════════════════════════════════════════════════════
local function sendMessage()
    if isGenerating or Bar.Text:match("^%s*$") then return end

    local prompt = Bar.Text
    Bar.Text = ""
    userMsgCount += 1
    updateCounter()

    createTextBubble(true, prompt)
    table.insert(messages, { role = "user", content = prompt })

    -- Potong history jika terlalu panjang
    while #messages > CONFIG.maxHistory do
        table.remove(messages, 2)
    end

    isGenerating = true
    tween(SendBtn, { BackgroundColor3 = Color3.fromRGB(30, 60, 140) })

    local thinkLabel = createTextBubble(false, "⏳ Sedang berpikir...")
    task.spawn(function()
        local d = 0
        while isGenerating do
            d = (d % 3) + 1
            if thinkLabel and thinkLabel.Parent then
                thinkLabel.Text = "⏳ Sedang berpikir" .. string.rep(".", d)
            end
            task.wait(0.35)
        end
    end)

    local model = CONFIG.models[CONFIG.currentModel].id
    local Data = {
        Url = "https://text.pollinations.ai/openai",
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = { model = model, messages = messages }
    }

    local Result
    local ok, err = pcall(function()
        if isStudio then
            Result = game.ReplicatedStorage.HTTP:InvokeServer(Data)
        else
            if not http_func then error("Tidak ada fungsi HTTP!") end
            Data.Body = HttpService:JSONEncode(Data.Body)
            Result = HttpService:JSONDecode(http_func(Data).Body)
        end
    end)

    isGenerating = false
    tween(SendBtn, { BackgroundColor3 = C.sendBtn })

    if thinkLabel and thinkLabel.Parent and thinkLabel.Parent.Parent then
        thinkLabel.Parent.Parent:Destroy()
    end

    if not ok or not Result then
        createTextBubble(false, "❌ Error: " .. tostring(err))
        return
    end

    local Msg = (Result.choices and Result.choices[1] or {message={content="Gagal mendapat balasan."}}).message.content or "?"
    table.insert(messages, { role = "assistant", content = Msg })
    renderAIMessage(Msg)
    scrollToBottom()
end

-- ════════════════════════════════════════════════════════════
--  HAPUS CHAT
-- ════════════════════════════════════════════════════════════
local function clearChat()
    for _, child in ipairs(Messages:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    messages = { { role = "system", content = CONFIG.systemPrompt } }
    msgCount = 0
    userMsgCount = 0
    updateCounter()
    createTextBubble(false, "💬 Chat dihapus. Mulai percakapan baru!")
end

-- ════════════════════════════════════════════════════════════
--  MINIMIZE / MAXIMIZE
-- ════════════════════════════════════════════════════════════
local function minimize()
    isMinimized = true
    -- Simpan posisi container ke minibar
    MiniBar.Position = UDim2.new(
        Container.Position.X.Scale,
        Container.Position.X.Offset,
        Container.Position.Y.Scale,
        Container.Position.Y.Offset
    )
    tween(Container, { Size = UDim2.new(Container.Size.X.Scale, Container.Size.X.Offset, 0, 0) }, 0.2)
    task.delay(0.2, function()
        Container.Visible = false
        MiniBar.Visible = true
    end)
end

local function maximize()
    isMinimized = false
    Container.Position = MiniBar.Position
    Container.Visible = true
    Container.Size = UDim2.new(0.94, 0, 0, 0)
    MiniBar.Visible = false
    tween(Container, { Size = UDim2.new(0.94, 0, 0.86, 0) }, 0.2)
end

-- ════════════════════════════════════════════════════════════
--  MODEL PICKER TOGGLE
-- ════════════════════════════════════════════════════════════
local function toggleModelPicker()
    modelPickerOpen = not modelPickerOpen
    ModelPicker.Visible = modelPickerOpen
end

local function selectModel(i)
    CONFIG.currentModel = i
    for j, mb in ipairs(modelBtns) do
        mb.Text = (j == i and "● " or "  ") .. CONFIG.models[j].label
        mb.BackgroundColor3 = j == i and C.accent or C.headerBtn
    end
    ModelPicker.Visible = false
    modelPickerOpen = false
    TitleLabel.Text = "✦ " .. CONFIG.models[i].label
end

for i, mb in ipairs(modelBtns) do
    mb.MouseButton1Click:Connect(function() selectModel(i) end)
    mb.TouchTap:Connect(function() selectModel(i) end)
end

-- ════════════════════════════════════════════════════════════
--  EVENT CONNECTIONS
-- ════════════════════════════════════════════════════════════

-- Tombol header
BtnClose.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
BtnClose.TouchTap:Connect(function() ScreenGui:Destroy() end)

BtnMinimize.MouseButton1Click:Connect(minimize)
BtnMinimize.TouchTap:Connect(minimize)

BtnClear.MouseButton1Click:Connect(clearChat)
BtnClear.TouchTap:Connect(clearChat)

BtnModel.MouseButton1Click:Connect(toggleModelPicker)
BtnModel.TouchTap:Connect(toggleModelPicker)

-- MiniBar: tap untuk maximize
MiniBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        maximize()
    end
end)

-- Kirim pesan
SendBtn.MouseButton1Click:Connect(sendMessage)
SendBtn.TouchTap:Connect(sendMessage)

local lastBox, lastFocusReleased
UIS.TextBoxFocusReleased:Connect(function(box)
    lastBox, lastFocusReleased = box, tick()
end)
UIS.InputBegan:Connect(function(Input, GPE)
    if Input.KeyCode == Enum.KeyCode.Return then
        local shift = UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)
        if lastBox == Bar and shift then
            Bar.Text ..= "\n"; Bar:CaptureFocus()
        elseif lastBox == Bar then
            sendMessage()
        end
    end
end)

-- Tutup model picker saat tap di luar
UIS.InputBegan:Connect(function(inp)
    if modelPickerOpen then
        if inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            task.wait(0.05)
            if modelPickerOpen then
                ModelPicker.Visible = false
                modelPickerOpen = false
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════
--  PESAN SELAMAT DATANG
-- ════════════════════════════════════════════════════════════
task.delay(0.3, function()
    createTextBubble(false,
        "👋 <b>Halo! Aku AI Asisten.</b>\n\n"
        .. "Kamu bisa:\n"
        .. "• <b>Geser</b> jendela ini ke mana saja\n"
        .. "• Tekan <b>─</b> untuk minimize\n"
        .. "• Tekan <b>⚙</b> untuk ganti model AI\n"
        .. "• Tekan <b>🗑</b> untuk hapus chat\n"
        .. "• Kode akan tampil di <b>codebox</b> khusus ✦"
    )
end)
