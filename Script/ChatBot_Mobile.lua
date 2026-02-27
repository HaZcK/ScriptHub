local ui = game:GetService("CoreGui"):FindFirstChild("AI")
if ui then ui:Destroy() end

-- This chatbot is powered by https://pollinations.ai
-- Mobile-optimized version + CodeBox support

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local isStudio = RunService:IsStudio()
local http_func = request or http and http.request or http_request or syn and syn.request
local REQUIRED_PROMPT = "\n"

-- ============================================================
-- UI SETUP
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Container utama
local Container = Instance.new("Frame", ScreenGui)
Container.Name = "Container"
Container.Position = UDim2.new(0.5, 0, 0.5, 0)
Container.Size = UDim2.new(0.95, 0, 0.88, 0)
Container.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.BorderSizePixel = 0
Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 18)
local cs = Instance.new("UIStroke", Container)
cs.Color = Color3.fromRGB(40, 40, 40)

-- Header
local Header = Instance.new("Frame", Container)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 56)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 18)

local IconLeft = Instance.new("ImageLabel", Header)
IconLeft.Position = UDim2.new(0, 12, 0.5, 0)
IconLeft.Size = UDim2.new(0, 36, 0, 36)
IconLeft.AnchorPoint = Vector2.new(0, 0.5)
IconLeft.BackgroundTransparency = 1
IconLeft.Image = "rbxassetid://125966901198850"

local IconRight = Instance.new("ImageLabel", Header)
IconRight.Position = UDim2.new(1, -12, 0.5, 0)
IconRight.Size = UDim2.new(0, 36, 0, 36)
IconRight.AnchorPoint = Vector2.new(1, 0.5)
IconRight.BackgroundTransparency = 1
IconRight.Image = "rbxassetid://73985599900390"

-- Area chat (ScrollingFrame)
local Messages = Instance.new("ScrollingFrame", Container)
Messages.Name = "Messages"
Messages.Position = UDim2.new(0, 0, 0, 60)
Messages.Size = UDim2.new(1, 0, 1, -130)
Messages.BackgroundTransparency = 1
Messages.BorderSizePixel = 0
Messages.ScrollBarThickness = 6
Messages.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
Messages.AutomaticCanvasSize = Enum.AutomaticSize.Y
Messages.CanvasSize = UDim2.new(0, 0, 0, 0)

local MsgLayout = Instance.new("UIListLayout", Messages)
MsgLayout.SortOrder = Enum.SortOrder.LayoutOrder
MsgLayout.Padding = UDim.new(0, 10)

local MsgPad = Instance.new("UIPadding", Messages)
MsgPad.PaddingTop = UDim.new(0, 10)
MsgPad.PaddingBottom = UDim.new(0, 10)
MsgPad.PaddingLeft = UDim.new(0, 10)
MsgPad.PaddingRight = UDim.new(0, 10)

-- Input bar (bawah)
local InputBar = Instance.new("Frame", Container)
InputBar.Name = "InputBar"
InputBar.Position = UDim2.new(0, 8, 1, -68)
InputBar.Size = UDim2.new(1, -16, 0, 60)
InputBar.BackgroundTransparency = 1
InputBar.BorderSizePixel = 0

local Bar = Instance.new("TextBox", InputBar)
Bar.Name = "Bar"
Bar.Position = UDim2.new(0, 0, 0.5, 0)
Bar.Size = UDim2.new(1, -72, 0, 48)
Bar.AnchorPoint = Vector2.new(0, 0.5)
Bar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Bar.BorderSizePixel = 0
Bar.Font = Enum.Font.GothamMedium
Bar.TextColor3 = Color3.fromRGB(220, 220, 220)
Bar.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
Bar.TextSize = 19
Bar.Text = ""
Bar.PlaceholderText = "Tanya sesuatu..."
Bar.TextWrapped = true
Bar.TextXAlignment = Enum.TextXAlignment.Left
Bar.MultiLine = true
Bar.ClearTextOnFocus = false
Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 22)
local barPad = Instance.new("UIPadding", Bar)
barPad.PaddingLeft = UDim.new(0, 14)
barPad.PaddingRight = UDim.new(0, 14)
barPad.PaddingTop = UDim.new(0, 8)
barPad.PaddingBottom = UDim.new(0, 8)
local barStroke = Instance.new("UIStroke", Bar)
barStroke.Color = Color3.fromRGB(60, 60, 60)
barStroke.Thickness = 1
barStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local SendBtn = Instance.new("TextButton", InputBar)
SendBtn.Name = "SendButton"
SendBtn.Position = UDim2.new(1, -62, 0.5, 0)
SendBtn.Size = UDim2.new(0, 58, 0, 48)
SendBtn.AnchorPoint = Vector2.new(0, 0.5)
SendBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 200)
SendBtn.BorderSizePixel = 0
SendBtn.Font = Enum.Font.GothamBold
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.TextSize = 15
SendBtn.Text = "Kirim"
Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0, 22)

-- ============================================================
-- FUNGSI BANTU
-- ============================================================

local msgCount = 0

local function scrollToBottom()
	task.wait()
	Messages.CanvasPosition = Vector2.new(0, math.huge)
end

-- Buat bubble teks biasa
local function createTextBubble(isUser, text)
	msgCount += 1
	local bubble = Instance.new("Frame", Messages)
	bubble.Name = isUser and "UserMsg" or "SysMsg"
	bubble.LayoutOrder = msgCount
	bubble.BackgroundTransparency = 1
	bubble.Size = UDim2.new(1, 0, 0, 0)
	bubble.AutomaticSize = Enum.AutomaticSize.Y
	bubble.BorderSizePixel = 0

	local inner = Instance.new("Frame", bubble)
	inner.AutomaticSize = Enum.AutomaticSize.XY
	inner.BackgroundColor3 = isUser and Color3.fromRGB(40, 90, 200) or Color3.fromRGB(30, 30, 30)
	inner.BorderSizePixel = 0
	if isUser then
		inner.AnchorPoint = Vector2.new(1, 0)
		inner.Position = UDim2.new(1, 0, 0, 0)
	else
		inner.AnchorPoint = Vector2.new(0, 0)
		inner.Position = UDim2.new(0, 0, 0, 0)
	end
	Instance.new("UICorner", inner).CornerRadius = UDim.new(0, 16)

	local label = Instance.new("TextLabel", inner)
	label.Name = "Message"
	label.AutomaticSize = Enum.AutomaticSize.XY
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 20
	label.TextColor3 = isUser and Color3.fromRGB(255,255,255) or Color3.fromRGB(210,210,210)
	label.TextWrapped = true
	label.RichText = true
	label.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
	label.Text = text
	local lp = Instance.new("UIPadding", label)
	lp.PaddingTop = UDim.new(0, 8)
	lp.PaddingBottom = UDim.new(0, 8)
	lp.PaddingLeft = UDim.new(0, 14)
	lp.PaddingRight = UDim.new(0, 14)

	scrollToBottom()
	return label
end

-- ============================================================
-- CODEBOX: Kotak khusus untuk blok kode
-- ============================================================

local function createCodeBox(lang, code)
	msgCount += 1
	local wrapper = Instance.new("Frame", Messages)
	wrapper.Name = "CodeBox"
	wrapper.LayoutOrder = msgCount
	wrapper.Size = UDim2.new(1, 0, 0, 0)
	wrapper.AutomaticSize = Enum.AutomaticSize.Y
	wrapper.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	wrapper.BorderSizePixel = 0
	Instance.new("UICorner", wrapper).CornerRadius = UDim.new(0, 12)
	local ws = Instance.new("UIStroke", wrapper)
	ws.Color = Color3.fromRGB(60, 60, 90)
	ws.Thickness = 1

	-- Header codebox (nama bahasa + tombol salin)
	local codeHeader = Instance.new("Frame", wrapper)
	codeHeader.Name = "CodeHeader"
	codeHeader.Size = UDim2.new(1, 0, 0, 38)
	codeHeader.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
	codeHeader.BorderSizePixel = 0
	-- Buat sudut atas melengkung, bawah datar
	Instance.new("UICorner", codeHeader).CornerRadius = UDim.new(0, 12)

	local langLabel = Instance.new("TextLabel", codeHeader)
	langLabel.Position = UDim2.new(0, 14, 0, 0)
	langLabel.Size = UDim2.new(0.6, 0, 1, 0)
	langLabel.BackgroundTransparency = 1
	langLabel.Font = Enum.Font.GothamBold
	langLabel.TextSize = 14
	langLabel.TextColor3 = Color3.fromRGB(130, 160, 255)
	langLabel.TextXAlignment = Enum.TextXAlignment.Left
	langLabel.Text = (lang ~= "" and lang or "code"):upper()

	local copyBtn = Instance.new("TextButton", codeHeader)
	copyBtn.Name = "CopyCode"
	copyBtn.Position = UDim2.new(1, -8, 0.5, 0)
	copyBtn.Size = UDim2.new(0, 90, 0, 28)
	copyBtn.AnchorPoint = Vector2.new(1, 0.5)
	copyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 68)
	copyBtn.BorderSizePixel = 0
	copyBtn.Font = Enum.Font.GothamMedium
	copyBtn.TextColor3 = Color3.fromRGB(190, 200, 255)
	copyBtn.TextSize = 14
	copyBtn.Text = "📋  Salin"
	Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 8)

	-- Area kode: ScrollingFrame horizontal + vertikal
	local codeScroll = Instance.new("ScrollingFrame", wrapper)
	codeScroll.Name = "CodeScroll"
	codeScroll.Position = UDim2.new(0, 0, 0, 38)
	codeScroll.Size = UDim2.new(1, 0, 0, 0)
	codeScroll.AutomaticSize = Enum.AutomaticSize.Y
	codeScroll.BackgroundTransparency = 1
	codeScroll.BorderSizePixel = 0
	codeScroll.ScrollBarThickness = 5
	codeScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 130)
	codeScroll.ElasticBehavior = Enum.ElasticBehavior.Never
	codeScroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
	codeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	codeScroll.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	codeScroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

	local codeLabel = Instance.new("TextLabel", codeScroll)
	codeLabel.Name = "CodeText"
	codeLabel.AutomaticSize = Enum.AutomaticSize.XY
	codeLabel.BackgroundTransparency = 1
	codeLabel.Font = Enum.Font.Code           -- Font monospace
	codeLabel.TextSize = 16
	codeLabel.TextColor3 = Color3.fromRGB(190, 230, 160)
	codeLabel.TextWrapped = false             -- Biarkan scroll horizontal
	codeLabel.RichText = false
	codeLabel.TextXAlignment = Enum.TextXAlignment.Left
	codeLabel.TextYAlignment = Enum.TextYAlignment.Top
	codeLabel.Text = code
	local cp = Instance.new("UIPadding", codeLabel)
	cp.PaddingTop = UDim.new(0, 10)
	cp.PaddingBottom = UDim.new(0, 14)
	cp.PaddingLeft = UDim.new(0, 14)
	cp.PaddingRight = UDim.new(0, 14)

	-- Logika tombol Salin kode
	local function doCopy()
		if isStudio then
			print("[CodeBox Copy]\n" .. code)
		else
			pcall(setclipboard, code)
		end
		copyBtn.Text = "✅  Disalin!"
		copyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 50)
		task.delay(2, function()
			if copyBtn and copyBtn.Parent then
				copyBtn.Text = "📋  Salin"
				copyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 68)
			end
		end)
	end
	copyBtn.MouseButton1Click:Connect(doCopy)
	copyBtn.TouchTap:Connect(doCopy)

	scrollToBottom()
	return wrapper
end

-- ============================================================
-- PARSER: Pisahkan teks biasa & blok kode ```...```
-- ============================================================

local function richText(txt)
	txt = txt:gsub("%*%*([^\n%*]+)%*%*", "<b>%1</b>")
	txt = txt:gsub("~~([^\n~]+)~~", "<strike>%1</strike>")
	return txt
end

local function renderAIMessage(fullText)
	local segments = {}
	local pos = 1

	while pos <= #fullText do
		-- Cari pembuka ```
		local openS, openE, lang = fullText:find("```([^\n]*)\n", pos)
		if openS then
			-- Teks sebelum blok kode
			if openS > pos then
				local before = fullText:sub(pos, openS - 1):gsub("^%s+", ""):gsub("%s+$", "")
				if before ~= "" then
					table.insert(segments, { type = "text", content = before })
				end
			end
			-- Cari penutup ```
			local closeS, closeE = fullText:find("\n```", openE + 1)
			if closeS then
				local code = fullText:sub(openE + 1, closeS)
				table.insert(segments, { type = "code", lang = lang or "", content = code })
				pos = closeE + 1
			else
				-- Tidak ada penutup → perlakukan sebagai teks
				table.insert(segments, { type = "text", content = fullText:sub(openS) })
				pos = #fullText + 1
			end
		else
			-- Sisa semua teks biasa
			local rest = fullText:sub(pos):gsub("^%s+", ""):gsub("%s+$", "")
			if rest ~= "" then
				table.insert(segments, { type = "text", content = rest })
			end
			break
		end
	end

	if #segments == 0 then
		createTextBubble(false, richText(fullText))
		return
	end

	for _, seg in ipairs(segments) do
		if seg.type == "text" then
			createTextBubble(false, richText(seg.content))
		elseif seg.type == "code" then
			createCodeBox(seg.lang, seg.content)
		end
	end
end

-- ============================================================
-- KIRIM PESAN & TERIMA BALASAN
-- ============================================================

local messages = {
	{
		role = "system",
		content = "You are a helpful AI assistant." .. REQUIRED_PROMPT
	}
}

local isGenerating = false

local function sendMessage()
	if isGenerating or Bar.Text:match("^%s*$") then return end

	local Prompt = Bar.Text
	Bar.Text = ""

	createTextBubble(true, Prompt)
	table.insert(messages, { role = "user", content = Prompt })

	isGenerating = true

	-- Animasi "sedang berpikir..."
	local thinkLabel = createTextBubble(false, "Sedang berpikir...")
	task.spawn(function()
		local dots = 0
		while isGenerating do
			dots = (dots % 3) + 1
			if thinkLabel and thinkLabel.Parent then
				thinkLabel.Text = "Sedang berpikir" .. string.rep(".", dots)
			end
			task.wait(0.35)
		end
	end)

	local Data = {
		Url = "https://text.pollinations.ai/openai",
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = { messages = messages }
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

	-- Hapus bubble "sedang berpikir..."
	if thinkLabel and thinkLabel.Parent and thinkLabel.Parent.Parent then
		thinkLabel.Parent.Parent:Destroy()
	end

	if not ok or not Result then
		createTextBubble(false, "❌ Gagal terhubung: " .. tostring(err))
		return
	end

	local Msg = (
		Result.choices
		and Result.choices[1]
		or { message = { content = "Gagal mendapat balasan." } }
	).message.content or "?"

	table.insert(messages, { role = "system", content = Msg })
	renderAIMessage(Msg)
	scrollToBottom()
end

-- ============================================================
-- EVENT: Tombol Kirim & Enter keyboard
-- ============================================================

SendBtn.MouseButton1Click:Connect(sendMessage)
SendBtn.TouchTap:Connect(sendMessage)

local lastBox, lastFocusReleased
UserInputService.TextBoxFocusReleased:Connect(function(box)
	lastBox, lastFocusReleased = box, tick()
end)

UserInputService.InputBegan:Connect(function(Input, GPE)
	if Input.KeyCode == Enum.KeyCode.Return then
		local shifting = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
		if lastBox == Bar and shifting then
			Bar.Text ..= "\n"
			Bar:CaptureFocus()
		elseif lastBox == Bar then
			sendMessage()
		end
	end
end)
