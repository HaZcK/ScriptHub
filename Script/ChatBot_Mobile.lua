local ui = game:GetService("CoreGui"):FindFirstChild("AI")
if ui then ui:Destroy() end

-- This chatbot is powered by https://pollinations.ai
-- Mobile-optimized version

local uiElements = {
	["AI"] = Instance.new("ScreenGui"),
	["Container"] = Instance.new("Frame"),
	["UICorner"] = Instance.new("UICorner"),
	["Chat"] = Instance.new("Frame"),
	["Messages"] = Instance.new("ScrollingFrame"),
	["UserTemplate"] = Instance.new("Frame"),
	["UICorner_1"] = Instance.new("UICorner"),
	["Message"] = Instance.new("TextLabel"),
	["UIPadding"] = Instance.new("UIPadding"),
	["UISizeConstraint"] = Instance.new("UISizeConstraint"),
	["UIPadding_1"] = Instance.new("UIPadding"),
	["SysTemplate"] = Instance.new("Frame"),
	["UICorner_2"] = Instance.new("UICorner"),
	["Message_1"] = Instance.new("TextLabel"),
	["UIPadding_2"] = Instance.new("UIPadding"),
	["UISizeConstraint_1"] = Instance.new("UISizeConstraint"),
	["Buttons"] = Instance.new("Frame"),
	["UIListLayout"] = Instance.new("UIListLayout"),
	["UIPadding_3"] = Instance.new("UIPadding"),
	["Copy"] = Instance.new("ImageButton"),
	["Header"] = Instance.new("Frame"),
	["Icon"] = Instance.new("ImageLabel"),
	["Icon1"] = Instance.new("ImageLabel"),
	["UICorner_3"] = Instance.new("UICorner"),
	["UIStroke"] = Instance.new("UIStroke"),
	["InputBar"] = Instance.new("Frame"),
	["Bar"] = Instance.new("TextBox"),
	["SendButton"] = Instance.new("TextButton"), -- Tombol Send khusus HP
	["UICorner_5"] = Instance.new("UICorner"),
	["UIPadding_4"] = Instance.new("UIPadding"),
	["UICorner_4"] = Instance.new("UICorner"),
	["UIStroke_1"] = Instance.new("UIStroke"),
	["LocalScript"] = Instance.new("LocalScript")
}

uiElements["AI"].Parent = game:GetService("CoreGui")
uiElements["AI"].Name = "AI"

-- Container: lebih besar & penuh di HP
uiElements["Container"].Parent = uiElements["AI"]
uiElements["Container"].Position = UDim2.new(0.5, 0, 0.5, 0)
uiElements["Container"].Size = UDim2.new(0.95, 0, 0.88, 0) -- Hampir penuh layar HP
uiElements["Container"].BackgroundColor3 = Color3.fromRGB(15, 15, 15)
uiElements["Container"].AnchorPoint = Vector2.new(0.5, 0.5)

uiElements["UICorner"].Parent = uiElements["Container"]
uiElements["UICorner"].CornerRadius = UDim.new(0, 18)

uiElements["Chat"].Parent = uiElements["Container"]
uiElements["Chat"].Size = UDim2.new(1, 0, 0.9, -80) -- Sisakan ruang untuk input bar
uiElements["Chat"].BackgroundTransparency = 1

uiElements["Messages"].Parent = uiElements["Chat"]
uiElements["Messages"].Position = UDim2.new(0, 0, 0.1, 0)
uiElements["Messages"].Size = UDim2.new(1, 0, 0.9, 0)
uiElements["Messages"].BorderSizePixel = 0
uiElements["Messages"].BackgroundTransparency = 1
uiElements["Messages"].AutomaticCanvasSize = Enum.AutomaticSize.Y
uiElements["Messages"].CanvasSize = UDim2.new(0, 0, 0, 68)
uiElements["Messages"].ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
uiElements["Messages"].ScrollBarThickness = 6 -- Lebih tipis agar tidak mengganggu

-- Template pesan user (kanan)
uiElements["UserTemplate"].Parent = uiElements["Messages"]
uiElements["UserTemplate"].Position = UDim2.new(1, 0, 0, 0)
uiElements["UserTemplate"].Size = UDim2.new(0, 100, 0, 30)
uiElements["UserTemplate"].BackgroundColor3 = Color3.fromRGB(40, 90, 200)
uiElements["UserTemplate"].AnchorPoint = Vector2.new(1, 0)
uiElements["UserTemplate"].AutomaticSize = Enum.AutomaticSize.XY
uiElements["UserTemplate"].BorderColor3 = Color3.fromRGB(0, 0, 0)
uiElements["UserTemplate"].BorderSizePixel = 0
uiElements["UserTemplate"].Visible = false

uiElements["UICorner_1"].Parent = uiElements["UserTemplate"]
uiElements["UICorner_1"].CornerRadius = UDim.new(0, 16)

uiElements["Message"].Parent = uiElements["UserTemplate"]
uiElements["Message"].Size = UDim2.new(1, 0, 1, 0)
uiElements["Message"].BackgroundTransparency = 1
uiElements["Message"].AutomaticSize = Enum.AutomaticSize.XY
uiElements["Message"].BorderSizePixel = 0
uiElements["Message"].Font = Enum.Font.GothamMedium
uiElements["Message"].TextColor3 = Color3.fromRGB(255, 255, 255)
uiElements["Message"].TextSize = 20 -- Lebih besar untuk HP
uiElements["Message"].RichText = true
uiElements["Message"].Text = "X"
uiElements["Message"].TextWrapped = true

uiElements["UIPadding"].Parent = uiElements["Message"]
uiElements["UIPadding"].PaddingTop = UDim.new(0, 8)
uiElements["UIPadding"].PaddingBottom = UDim.new(0, 8)
uiElements["UIPadding"].PaddingLeft = UDim.new(0, 14)
uiElements["UIPadding"].PaddingRight = UDim.new(0, 14)

uiElements["UISizeConstraint"].Parent = uiElements["UserTemplate"]

uiElements["UIPadding_1"].Parent = uiElements["Messages"]
uiElements["UIPadding_1"].PaddingTop = UDim.new(0, 8)
uiElements["UIPadding_1"].PaddingRight = UDim.new(0, 10)
uiElements["UIPadding_1"].PaddingLeft = UDim.new(0, 10)

-- Template pesan AI (kiri)
uiElements["SysTemplate"].Parent = uiElements["Messages"]
uiElements["SysTemplate"].Size = UDim2.new(0, 100, 0, 30)
uiElements["SysTemplate"].BackgroundColor3 = Color3.fromRGB(30, 30, 30)
uiElements["SysTemplate"].AutomaticSize = Enum.AutomaticSize.XY
uiElements["SysTemplate"].BorderSizePixel = 0
uiElements["SysTemplate"].Visible = false
uiElements["SysTemplate"].BackgroundTransparency = 0

uiElements["UICorner_2"].Parent = uiElements["SysTemplate"]
uiElements["UICorner_2"].CornerRadius = UDim.new(0, 16)

uiElements["Message_1"].Parent = uiElements["SysTemplate"]
uiElements["Message_1"].Size = UDim2.new(1, 0, 1, 0)
uiElements["Message_1"].BackgroundTransparency = 1
uiElements["Message_1"].AutomaticSize = Enum.AutomaticSize.XY
uiElements["Message_1"].BorderSizePixel = 0
uiElements["Message_1"].Font = Enum.Font.GothamMedium
uiElements["Message_1"].TextColor3 = Color3.fromRGB(210, 210, 210)
uiElements["Message_1"].TextSize = 20 -- Lebih besar untuk HP
uiElements["Message_1"].RichText = true
uiElements["Message_1"].Text = "Y"
uiElements["Message_1"].TextWrapped = true
uiElements["Message_1"].TextXAlignment = Enum.TextXAlignment.Left

uiElements["UIPadding_2"].Parent = uiElements["Message_1"]
uiElements["UIPadding_2"].PaddingTop = UDim.new(0, 8)
uiElements["UIPadding_2"].PaddingBottom = UDim.new(0, 8)
uiElements["UIPadding_2"].PaddingLeft = UDim.new(0, 14)
uiElements["UIPadding_2"].PaddingRight = UDim.new(0, 14)

uiElements["UISizeConstraint_1"].Parent = uiElements["SysTemplate"]

-- Tombol Copy (lebih besar untuk jari)
uiElements["Buttons"].Parent = uiElements["SysTemplate"]
uiElements["Buttons"].Position = UDim2.new(0, 0, 1, 4)
uiElements["Buttons"].Size = UDim2.new(1, 0, 0, 28)
uiElements["Buttons"].BackgroundTransparency = 1

uiElements["UIListLayout"].Parent = uiElements["Buttons"]
uiElements["UIListLayout"].Padding = UDim.new(0, 4)
uiElements["UIListLayout"].FillDirection = Enum.FillDirection.Horizontal
uiElements["UIListLayout"].SortOrder = Enum.SortOrder.LayoutOrder

uiElements["UIPadding_3"].Parent = uiElements["Buttons"]
uiElements["UIPadding_3"].PaddingLeft = UDim.new(0, 4)

uiElements["Copy"].Parent = uiElements["Buttons"]
uiElements["Copy"].Size = UDim2.new(0, 28, 1, 0) -- Lebih besar untuk jari
uiElements["Copy"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
uiElements["Copy"].Active = true
uiElements["Copy"].BorderSizePixel = 0
uiElements["Copy"].BackgroundTransparency = 1
uiElements["Copy"].Image = "rbxassetid://93531807477279"

-- Header
uiElements["Header"].Parent = uiElements["Chat"]
uiElements["Header"].Size = UDim2.new(1, 0, 0, 56) -- Tinggi fixed untuk HP
uiElements["Header"].BackgroundColor3 = Color3.fromRGB(20, 20, 20)
uiElements["Header"].BorderSizePixel = 0

uiElements["Icon"].Parent = uiElements["Header"]
uiElements["Icon"].Position = UDim2.new(0, 12, 0.5, 0)
uiElements["Icon"].Size = UDim2.new(0, 36, 0, 36)
uiElements["Icon"].AnchorPoint = Vector2.new(0, 0.5)
uiElements["Icon"].BackgroundTransparency = 1
uiElements["Icon"].Image = "rbxassetid://125966901198850"

uiElements["Icon1"].Parent = uiElements["Header"]
uiElements["Icon1"].Position = UDim2.new(1, -12, 0.5, 0)
uiElements["Icon1"].Size = UDim2.new(0, 36, 0, 36)
uiElements["Icon1"].AnchorPoint = Vector2.new(1, 0.5)
uiElements["Icon1"].BackgroundTransparency = 1
uiElements["Icon1"].Image = "rbxassetid://73985599900390"

uiElements["UICorner_3"].Parent = uiElements["Header"]
uiElements["UICorner_3"].CornerRadius = UDim.new(0, 18)

uiElements["UIStroke"].Parent = uiElements["Container"]
uiElements["UIStroke"].Color = Color3.fromRGB(40, 40, 40)

-- Input bar (bawah layar, mobile-friendly)
uiElements["InputBar"].Parent = uiElements["Container"]
uiElements["InputBar"].Position = UDim2.new(0, 0, 1, 0)
uiElements["InputBar"].Size = UDim2.new(1, 0, 0, 0)
uiElements["InputBar"].BackgroundTransparency = 1
uiElements["InputBar"].AnchorPoint = Vector2.new(0, 1)
uiElements["InputBar"].AutomaticSize = Enum.AutomaticSize.Y

-- TextBox input
uiElements["Bar"].Parent = uiElements["InputBar"]
uiElements["Bar"].Position = UDim2.new(0, 10, 1, -8)
uiElements["Bar"].Size = UDim2.new(1, -80, 1, 0) -- Sisakan ruang untuk tombol Send
uiElements["Bar"].BackgroundColor3 = Color3.fromRGB(30, 30, 30)
uiElements["Bar"].AnchorPoint = Vector2.new(0, 1)
uiElements["Bar"].AutomaticSize = Enum.AutomaticSize.Y
uiElements["Bar"].BorderSizePixel = 0
uiElements["Bar"].Font = Enum.Font.GothamMedium
uiElements["Bar"].TextColor3 = Color3.fromRGB(220, 220, 220)
uiElements["Bar"].TextSize = 20 -- Lebih besar untuk HP
uiElements["Bar"].Text = ""
uiElements["Bar"].PlaceholderText = "Tanya sesuatu..."
uiElements["Bar"].TextWrapped = true
uiElements["Bar"].TextXAlignment = Enum.TextXAlignment.Left
uiElements["Bar"].MultiLine = true
uiElements["Bar"].ClearTextOnFocus = false

uiElements["UIPadding_4"].Parent = uiElements["Bar"]
uiElements["UIPadding_4"].PaddingTop = UDim.new(0, 10)
uiElements["UIPadding_4"].PaddingBottom = UDim.new(0, 10)
uiElements["UIPadding_4"].PaddingLeft = UDim.new(0, 16)
uiElements["UIPadding_4"].PaddingRight = UDim.new(0, 16)

uiElements["UICorner_4"].Parent = uiElements["Bar"]
uiElements["UICorner_4"].CornerRadius = UDim.new(0, 22)

uiElements["UIStroke_1"].Parent = uiElements["Bar"]
uiElements["UIStroke_1"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiElements["UIStroke_1"].Color = Color3.fromRGB(60, 60, 60)
uiElements["UIStroke_1"].Thickness = 1

-- Tombol SEND (khusus HP - tap untuk kirim)
uiElements["SendButton"].Parent = uiElements["InputBar"]
uiElements["SendButton"].Position = UDim2.new(1, -8, 1, -8)
uiElements["SendButton"].Size = UDim2.new(0, 58, 0, 48) -- Ukuran besar agar mudah ditekan
uiElements["SendButton"].AnchorPoint = Vector2.new(1, 1)
uiElements["SendButton"].BackgroundColor3 = Color3.fromRGB(40, 90, 200)
uiElements["SendButton"].BorderSizePixel = 0
uiElements["SendButton"].Font = Enum.Font.GothamBold
uiElements["SendButton"].TextColor3 = Color3.fromRGB(255, 255, 255)
uiElements["SendButton"].TextSize = 16
uiElements["SendButton"].Text = "Kirim"

uiElements["UICorner_5"].Parent = uiElements["SendButton"]
uiElements["UICorner_5"].CornerRadius = UDim.new(0, 22)

-- Fix naming
for name, i in next, uiElements do i.Name = name:gsub("_%d+", "") end

local script = Instance.new("LocalScript", uiElements["Bar"])

local user = game:GetService("UserInputService")
local box = script.Parent
local messagesList = uiElements["Messages"]
local userTemplate, sysTemplate = uiElements.UserTemplate, uiElements.SysTemplate
local sendButton = uiElements["SendButton"]
local lastBox, lastFocusReleased, isGenerating;
local isStudio = game:GetService("RunService"):IsStudio()
local currentOffset = 0

local http_func = request or http and http.request or http_request or syn and syn.request
local REQUIRED_PROMPT = "\n"

user.TextBoxFocusReleased:Connect(function(Box)
	lastBox, lastFocusReleased = Box, tick()
end)

local messages = {
	{
		role = "system",
		content = "You are a helpful AI assistant." .. REQUIRED_PROMPT
	}
}

local function richText(txt)
	txt = txt:gsub("%*%*([^\n%*]+)%*%*", "<b>%1</b>")
	txt = txt:gsub("~~([^\n~]+)~~", "<strike>%1</strike>")
	txt = txt:gsub("^(#+)([^\n]+)", function(h, t) if #h > 6 then return end return `<font size = "{25 - #h * 2}">{t}</font>` end)
	return txt
end

local function copy(b)
	if isStudio then
		print("Cannot copy on studio.")
	else
		setclipboard(b.Text)
	end
end

local function createMessage(IsUser, Message)
	local Clone = IsUser and userTemplate:Clone() or sysTemplate:Clone()
	if IsUser then
		Clone.AnchorPoint = Vector2.new(1, 0)
	else
		Clone.AnchorPoint = Vector2.new(0, 0)
		Clone.Buttons.Copy.MouseButton1Click:Connect(function()
			copy(Clone.Message)
		end)
		-- Untuk HP: support tap/touch juga
		Clone.Buttons.Copy.TouchTap:Connect(function()
			copy(Clone.Message)
		end)
	end

	Clone.Message.Text = richText(Message)
	Clone.Visible = true
	Clone.Parent = messagesList
	Clone.Size = UDim2.new(Clone.Size.X.Scale, Clone.Size.X.Offset, 0, Clone.Message.TextBounds.Y + 2)

	local yOffset = 0
	for _, child in ipairs(messagesList:GetChildren()) do
		if child:IsA("Frame") and child.Visible then
			yOffset += child.AbsoluteSize.Y
		end
	end
	Clone.Position = UDim2.new(Clone.AnchorPoint.X, 0, 0, yOffset + 14) -- padding lebih besar

	messagesList.CanvasSize = UDim2.new(0, 0, 0, yOffset + Clone.AbsoluteSize.Y)
	messagesList.CanvasPosition = Vector2.new(0, yOffset + Clone.AbsoluteSize.Y)

	return Clone
end

local function sendMessage()
	if isGenerating or box.Text == "" then return end

	local Prompt = box.Text
	box.Text = ""

	currentOffset += createMessage(true, Prompt).AbsoluteSize.Y
	table.insert(messages, {
		role = "user",
		content = Prompt
	})

	isGenerating = true

	local Response = createMessage(false, "Sedang berpikir...")
	task.spawn(function()
		local Dots = 3
		while task.wait(.33) do
			if not isGenerating then return end
			Dots = (Dots % 3) + 1
			Response.Message.Text = `Sedang berpikir{string.rep(".", Dots)}`
		end
	end)

	local Data = {
		Url = "https://text.pollinations.ai/openai",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = {
			messages = messages
		}
	}

	local Result;
	if isStudio then
		Result = game.ReplicatedStorage.HTTP:InvokeServer(Data)
	else
		if not http_func then
			return createMessage(false, "Tidak ada fungsi HTTP!")
		end
		Data.Body = game:GetService("HttpService"):JSONEncode(Data.Body)
		Result = game:GetService("HttpService"):JSONDecode(http_func(Data).Body)
	end

	isGenerating = false
	local Msg = (Result.choices and Result.choices[1] or { message = { content = "Gagal mendapat balasan :(" } }).message.content or "Tidak ada konten???"
	table.insert(messages, {
		role = "system",
		content = Msg
	})

	Response.Message.Text = richText(Msg)
	currentOffset += Response.AbsoluteSize.Y
	messagesList.CanvasSize += Response.Size
end

-- Tombol Send (tap) - khusus HP
sendButton.MouseButton1Click:Connect(sendMessage)
sendButton.TouchTap:Connect(sendMessage)

-- Tetap support Enter dari keyboard fisik (opsional)
user.InputBegan:Connect(function(Input, GPE)
	local Code = Input.KeyCode
	if Code == Enum.KeyCode.Return then
		local IsShifting = user:IsKeyDown(Enum.KeyCode.LeftShift) or user:IsKeyDown(Enum.KeyCode.RightShift)
		if lastBox == box and IsShifting and tick() - (lastFocusReleased or 0) < 0.01 then
			box.Text ..= "\n"
			box.CursorPosition = #box.Text + 1
			box:CaptureFocus()
		elseif lastBox == box then
			sendMessage()
		end
	end
end)
