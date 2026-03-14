-- 🌙 SkyMoon Real Builder
-- by KHAFIDZKTP | github.com/HaZcK/ScriptHub
-- Roblox Studio-like builder for executors

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SelectionService = game:GetService("Selection")
local LocalPlayer = Players.LocalPlayer

-- ScreenGui
local sg = Instance.new("ScreenGui")
sg.Name = "SkyMoon_RealBuilder"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
pcall(function() sg.Parent = game.CoreGui end)
if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end

----------------------------------------------------
-- THEME
----------------------------------------------------
local T = {
    bg        = Color3.fromRGB(46, 46, 46),
    panel     = Color3.fromRGB(38, 38, 38),
    dark      = Color3.fromRGB(30, 30, 30),
    darker    = Color3.fromRGB(22, 22, 22),
    accent    = Color3.fromRGB(0, 162, 255),
    accentDim = Color3.fromRGB(0, 100, 180),
    text      = Color3.fromRGB(220, 220, 220),
    textDim   = Color3.fromRGB(150, 150, 150),
    selected  = Color3.fromRGB(0, 120, 215),
    hover     = Color3.fromRGB(55, 55, 55),
    border    = Color3.fromRGB(60, 60, 60),
    green     = Color3.fromRGB(70, 200, 80),
    red       = Color3.fromRGB(200, 60, 60),
    yellow    = Color3.fromRGB(230, 180, 0),
}

----------------------------------------------------
-- STATE
----------------------------------------------------
local selectedObj = nil
local selectedBox = nil
local playMode = false
local currentTool = "Select" -- Select, Move, Scale, Rotate
local spawnedObjects = {}
local savedCFrame = nil
local explorerNodes = {}
local propertiesConn = nil

----------------------------------------------------
-- HELPERS
----------------------------------------------------
local function makeCorner(r, p)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r)
    return c
end

local function makeStroke(color, thick, p)
    local s = Instance.new("UIStroke", p)
    s.Color = color
    s.Thickness = thick or 1
    return s
end

local function makeLabel(parent, text, size, pos, font, textSize, color, xAlign)
    local l = Instance.new("TextLabel", parent)
    l.Size = size
    l.Position = pos or UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = font or Enum.Font.GothamBold
    l.TextSize = textSize or 12
    l.TextColor3 = color or T.text
    l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    l.TextWrapped = true
    return l
end

local function makeBtn(parent, text, size, pos, bg, textColor)
    local b = Instance.new("TextButton", parent)
    b.Size = size
    b.Position = pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = bg or T.panel
    b.Text = text
    b.TextColor3 = textColor or T.text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    makeCorner(4, b)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = T.hover}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = bg or T.panel}):Play()
    end)
    return b
end

----------------------------------------------------
-- MAIN LAYOUT
----------------------------------------------------
-- Topbar
local topbar = Instance.new("Frame", sg)
topbar.Size = UDim2.new(1, 0, 0, 36)
topbar.BackgroundColor3 = T.darker
topbar.BorderSizePixel = 0
topbar.ZIndex = 10

makeLabel(topbar, "🌙 SkyMoon Real Builder", UDim2.new(0,200,1,0), UDim2.new(0,10,0,0), Enum.Font.GothamBold, 13, T.accent)

-- Explorer (left panel)
local explorerPanel = Instance.new("Frame", sg)
explorerPanel.Size = UDim2.new(0, 220, 1, -76)
explorerPanel.Position = UDim2.new(0, 0, 0, 36)
explorerPanel.BackgroundColor3 = T.panel
explorerPanel.BorderSizePixel = 0

local explorerHeader = Instance.new("Frame", explorerPanel)
explorerHeader.Size = UDim2.new(1, 0, 0, 24)
explorerHeader.BackgroundColor3 = T.dark
explorerHeader.BorderSizePixel = 0
makeLabel(explorerHeader, "  Explorer", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Enum.Font.GothamBold, 11, T.textDim)

local explorerScroll = Instance.new("ScrollingFrame", explorerPanel)
explorerScroll.Size = UDim2.new(1, 0, 1, -24)
explorerScroll.Position = UDim2.new(0, 0, 0, 24)
explorerScroll.BackgroundTransparency = 1
explorerScroll.BorderSizePixel = 0
explorerScroll.ScrollBarThickness = 4
explorerScroll.ScrollBarImageColor3 = T.accent
explorerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
explorerScroll.CanvasSize = UDim2.new(0,0,0,0)

local explorerLayout = Instance.new("UIListLayout", explorerScroll)
explorerLayout.Padding = UDim.new(0, 1)

-- Properties (right panel)
local propsPanel = Instance.new("Frame", sg)
propsPanel.Size = UDim2.new(0, 220, 1, -76)
propsPanel.Position = UDim2.new(1, -220, 0, 36)
propsPanel.BackgroundColor3 = T.panel
propsPanel.BorderSizePixel = 0

local propsHeader = Instance.new("Frame", propsPanel)
propsHeader.Size = UDim2.new(1, 0, 0, 24)
propsHeader.BackgroundColor3 = T.dark
propsHeader.BorderSizePixel = 0
makeLabel(propsHeader, "  Properties", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Enum.Font.GothamBold, 11, T.textDim)

local propsScroll = Instance.new("ScrollingFrame", propsPanel)
propsScroll.Size = UDim2.new(1, 0, 1, -24)
propsScroll.Position = UDim2.new(0, 0, 0, 24)
propsScroll.BackgroundTransparency = 1
propsScroll.BorderSizePixel = 0
propsScroll.ScrollBarThickness = 4
propsScroll.ScrollBarImageColor3 = T.accent
propsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
propsScroll.CanvasSize = UDim2.new(0,0,0,0)

local propsLayout = Instance.new("UIListLayout", propsScroll)
propsLayout.Padding = UDim.new(0, 1)

-- Toolbar (below topbar)
local toolbar = Instance.new("Frame", sg)
toolbar.Size = UDim2.new(1, -440, 0, 36)
toolbar.Position = UDim2.new(0, 220, 0, 36)
toolbar.BackgroundColor3 = T.dark
toolbar.BorderSizePixel = 0
toolbar.ZIndex = 5

local toolbarLayout = Instance.new("UIListLayout", toolbar)
toolbarLayout.FillDirection = Enum.FillDirection.Horizontal
toolbarLayout.Padding = UDim.new(0, 4)
local toolbarPad = Instance.new("UIPadding", toolbar)
toolbarPad.PaddingLeft = UDim.new(0, 6)
toolbarPad.PaddingTop = UDim.new(0, 4)
toolbarPad.PaddingBottom = UDim.new(0, 4)

-- Bottom bar
local bottombar = Instance.new("Frame", sg)
bottombar.Size = UDim2.new(1, 0, 0, 40)
bottombar.Position = UDim2.new(0, 0, 1, -40)
bottombar.BackgroundColor3 = T.darker
bottombar.BorderSizePixel = 0
bottombar.ZIndex = 10

----------------------------------------------------
-- TOOL BUTTONS
----------------------------------------------------
local toolBtns = {}
local tools = {
    {"🔲 Select", "Select"},
    {"✢ Move", "Move"},
    {"⊡ Scale", "Scale"},
    {"↻ Rotate", "Rotate"},
}

for _, t in ipairs(tools) do
    local btn = makeBtn(toolbar, t[1], UDim2.new(0, 76, 0, 28), nil, T.panel)
    btn.ZIndex = 6
    btn.MouseButton1Click:Connect(function()
        currentTool = t[2]
        for _, b in ipairs(toolBtns) do
            b.BackgroundColor3 = T.panel
        end
        btn.BackgroundColor3 = T.selected
    end)
    table.insert(toolBtns, btn)
end
toolBtns[1].BackgroundColor3 = T.selected

-- Separator
local sep = Instance.new("Frame", toolbar)
sep.Size = UDim2.new(0, 1, 0, 28)
sep.BackgroundColor3 = T.border
sep.BorderSizePixel = 0

-- Insert button
local insertBtn = makeBtn(toolbar, "⊕ Insert", UDim2.new(0, 76, 0, 28), nil, T.accentDim, Color3.new(1,1,1))
insertBtn.ZIndex = 6

-- Play/Stop buttons in bottombar
local playBtn = makeBtn(bottombar, "▶  Play", UDim2.new(0, 90, 0, 30), UDim2.new(0.5, -100, 0, 5), T.green, Color3.new(0,0,0))
local stopBtn = makeBtn(bottombar, "■  Stop", UDim2.new(0, 90, 0, 30), UDim2.new(0.5, 10, 0, 5), T.red, Color3.new(1,1,1))

-- Close button
local closeBtn = makeBtn(bottombar, "✕  Close Builder", UDim2.new(0, 120, 0, 28), UDim2.new(1, -128, 0, 6), T.darker)
makeStroke(T.red, 1, closeBtn)

-- Status label
local statusLbl = makeLabel(bottombar, "Ready.", UDim2.new(0, 300, 1, 0), UDim2.new(0, 10, 0, 0), Enum.Font.Code, 11, T.textDim)

----------------------------------------------------
-- INSERT MENU
----------------------------------------------------
local insertMenu = Instance.new("Frame", sg)
insertMenu.Size = UDim2.new(0, 180, 0, 340)
insertMenu.Position = UDim2.new(0, 220, 0, 72)
insertMenu.BackgroundColor3 = T.darker
insertMenu.BorderSizePixel = 0
insertMenu.Visible = false
insertMenu.ZIndex = 20
makeCorner(6, insertMenu)
makeStroke(T.border, 1, insertMenu)

local insertHeader = makeLabel(insertMenu, "  Insert Object", UDim2.new(1,0,0,24), UDim2.new(0,0,0,0), Enum.Font.GothamBold, 11, T.textDim)

local insertScroll = Instance.new("ScrollingFrame", insertMenu)
insertScroll.Size = UDim2.new(1, -4, 1, -28)
insertScroll.Position = UDim2.new(0, 2, 0, 26)
insertScroll.BackgroundTransparency = 1
insertScroll.BorderSizePixel = 0
insertScroll.ScrollBarThickness = 3
insertScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
insertScroll.CanvasSize = UDim2.new(0,0,0,0)
insertScroll.ZIndex = 21
local insertLayout = Instance.new("UIListLayout", insertScroll)
insertLayout.Padding = UDim.new(0, 2)

local INSERTABLE = {
    {"🟦 Part",           "Part"},
    {"⚽ Sphere Part",     "SpherePart"},
    {"🔺 Wedge Part",     "WedgePart"},
    {"📁 Model",          "Model"},
    {"📂 Folder",         "Folder"},
    {"📜 Script",         "LocalScript"},
    {"📄 LocalScript",    "LocalScript"},
    {"📦 ModuleScript",   "ModuleScript"},
    {"💡 PointLight",     "PointLight"},
    {"🌟 SpotLight",      "SpotLight"},
    {"✨ ParticleEmitter","ParticleEmitter"},
    {"🎵 Sound",          "Sound"},
    {"📡 RemoteEvent",    "RemoteEvent"},
    {"📡 RemoteFunction", "RemoteFunction"},
    {"🔗 BindableEvent",  "BindableEvent"},
    {"💫 Attachment",     "Attachment"},
    {"🔵 SelectionBox",   "SelectionBox"},
    {"🌀 SpecialMesh",    "SpecialMesh"},
    {"🎨 Decal",          "Decal"},
    {"🌊 Smoke",          "Smoke"},
    {"⚡ Fire",           "Fire"},
    {"💧 Sparkles",       "Sparkles"},
    {"🧲 BodyVelocity",   "BodyVelocity"},
    {"🧲 BodyPosition",   "BodyPosition"},
    {"🔒 WeldConstraint", "WeldConstraint"},
    {"🔧 HingeConstraint","HingeConstraint"},
    {"📷 Camera",         "Camera"},
    {"🌐 SurfaceAppearance","SurfaceAppearance"},
}

local function insertObject(className)
    local parent = selectedObj or workspace
    local ok, obj = pcall(function()
        local o = Instance.new(className)
        if o:IsA("BasePart") then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            o.CFrame = hrp and hrp.CFrame + Vector3.new(0,3,-6) or CFrame.new(0,5,0)
            o.Size = Vector3.new(4,4,4)
            o.Anchored = true
            o.BrickColor = BrickColor.new("Bright blue")
            table.insert(spawnedObjects, o)
        end
        o.Parent = parent
        return o
    end)
    if ok then
        statusLbl.Text = "Inserted: " .. className
        insertMenu.Visible = false
        -- Refresh explorer
        task.defer(refreshExplorer)
    else
        statusLbl.Text = "Failed: " .. className
    end
end

for _, item in ipairs(INSERTABLE) do
    local btn = Instance.new("TextButton", insertScroll)
    btn.Size = UDim2.new(1, -4, 0, 24)
    btn.BackgroundColor3 = T.panel
    btn.Text = item[1]
    btn.TextColor3 = T.text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 22
    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 8)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = T.selected end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = T.panel end)
    btn.MouseButton1Click:Connect(function() insertObject(item[2]) end)
end

insertBtn.MouseButton1Click:Connect(function()
    insertMenu.Visible = not insertMenu.Visible
end)

----------------------------------------------------
-- SELECTION BOX
----------------------------------------------------
local function selectObject(obj)
    if selectedBox then pcall(function() selectedBox:Destroy() end) end
    selectedObj = obj
    if obj and obj:IsA("BasePart") then
        local box = Instance.new("SelectionBox")
        box.Adornee = obj
        box.Color3 = T.accent
        box.LineThickness = 0.05
        box.SurfaceTransparency = 0.8
        box.SurfaceColor3 = T.accent
        box.Parent = workspace
        selectedBox = box
    end
    refreshProperties()
end

----------------------------------------------------
-- EXPLORER
----------------------------------------------------
local expandedNodes = {}

function refreshExplorer()
    -- Clear
    for _, c in ipairs(explorerScroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end

    local services = {
        {workspace, "Workspace", "🌍"},
        {game:GetService("ReplicatedStorage"), "ReplicatedStorage", "📦"},
        {game:GetService("ReplicatedFirst"), "ReplicatedFirst", "⚡"},
        {game:GetService("StarterGui"), "StarterGui", "🖥"},
        {game:GetService("StarterPack"), "StarterPack", "🎒"},
        {game:GetService("Lighting"), "Lighting", "💡"},
        {LocalPlayer, LocalPlayer.Name, "👤"},
    }

    local function addNode(obj, depth, icon)
        local row = Instance.new("TextButton", explorerScroll)
        row.Size = UDim2.new(1, 0, 0, 20)
        row.BackgroundColor3 = selectedObj == obj and T.selected or T.panel
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = false

        local indent = Instance.new("UIPadding", row)
        indent.PaddingLeft = UDim.new(0, 6 + depth * 14)

        local lbl = makeLabel(row,
            (icon or "📄") .. " " .. obj.Name,
            UDim2.new(1, -20, 1, 0),
            UDim2.new(0, 0, 0, 0),
            Enum.Font.Code, 11, T.text
        )

        local children = obj:GetChildren()
        if #children > 0 then
            local arrow = makeLabel(row, expandedNodes[obj] and "▾" or "▸",
                UDim2.new(0, 14, 1, 0), UDim2.new(1, -16, 0, 0),
                Enum.Font.GothamBold, 11, T.textDim, Enum.TextXAlignment.Center)
        end

        row.MouseButton1Click:Connect(function()
            selectObject(obj)
            -- Refresh to update selection highlight
            for _, r in ipairs(explorerScroll:GetChildren()) do
                if r:IsA("TextButton") then
                    r.BackgroundColor3 = T.panel
                end
            end
            row.BackgroundColor3 = T.selected
        end)

        row.MouseButton2Click:Connect(function()
            -- Toggle expand
            expandedNodes[obj] = not expandedNodes[obj]
            task.defer(refreshExplorer)
        end)

        if expandedNodes[obj] and #children > 0 then
            for _, child in ipairs(children) do
                local cIcon = "📄"
                if child:IsA("BasePart") then cIcon = "🟦"
                elseif child:IsA("Model") then cIcon = "📁"
                elseif child:IsA("LocalScript") then cIcon = "📜"
                elseif child:IsA("Script") then cIcon = "📜"
                elseif child:IsA("ModuleScript") then cIcon = "📦"
                elseif child:IsA("Folder") then cIcon = "📂"
                elseif child:IsA("Light") then cIcon = "💡"
                elseif child:IsA("ParticleEmitter") then cIcon = "✨"
                elseif child:IsA("Sound") then cIcon = "🎵"
                end
                addNode(child, depth + 1, cIcon)
            end
        end
    end

    for _, s in ipairs(services) do
        addNode(s[1], 0, s[3])
    end
end

-- Double click to expand
refreshExplorer()

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------
local EDITABLE_PROPS = {
    BasePart = {"Name","Anchored","CanCollide","CastShadow","Transparency","Reflectance","BrickColor","Material","Size","Position"},
    Model    = {"Name","PrimaryPart"},
    Folder   = {"Name"},
    Script   = {"Name","Disabled","Source"},
    LocalScript = {"Name","Disabled","Source"},
    Sound    = {"Name","SoundId","Volume","Looped","Playing"},
    Light    = {"Name","Brightness","Color","Range"},
    ParticleEmitter = {"Name","Rate","Lifetime","Speed","RotSpeed","Rotation"},
}

function refreshProperties()
    for _, c in ipairs(propsScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    if propertiesConn then propertiesConn:Disconnect() end
    if not selectedObj then
        makeLabel(propsScroll, "  No object selected.", UDim2.new(1,0,0,24), nil, Enum.Font.Code, 11, T.textDim)
        return
    end

    -- Class header
    local classRow = Instance.new("Frame", propsScroll)
    classRow.Size = UDim2.new(1, 0, 0, 24)
    classRow.BackgroundColor3 = T.dark
    classRow.BorderSizePixel = 0
    makeLabel(classRow, "  " .. selectedObj.ClassName, UDim2.new(1,0,1,0), nil, Enum.Font.GothamBold, 11, T.accent)

    -- Build property list
    local props = {}
    for class, list in pairs(EDITABLE_PROPS) do
        if selectedObj:IsA(class) then
            for _, p in ipairs(list) do
                table.insert(props, p)
            end
        end
    end
    if #props == 0 then
        -- fallback: show Name
        props = {"Name"}
    end

    -- Remove dupes
    local seen = {}
    local uniqueProps = {}
    for _, p in ipairs(props) do
        if not seen[p] then seen[p] = true table.insert(uniqueProps, p) end
    end

    for _, propName in ipairs(uniqueProps) do
        local ok, val = pcall(function() return selectedObj[propName] end)
        if not ok then continue end

        local row = Instance.new("Frame", propsScroll)
        row.Size = UDim2.new(1, 0, 0, 28)
        row.BackgroundColor3 = T.panel
        row.BorderSizePixel = 0

        makeLabel(row, propName, UDim2.new(0.45, 0, 1, 0), UDim2.new(0, 6, 0, 0), Enum.Font.Code, 10, T.textDim)

        local valType = typeof(val)

        if valType == "boolean" then
            local toggle = makeBtn(row, val and "✓ true" or "✗ false",
                UDim2.new(0.5, -4, 0, 20), UDim2.new(0.5, 2, 0, 4),
                val and Color3.fromRGB(40,120,40) or Color3.fromRGB(100,40,40))
            toggle.TextSize = 10
            toggle.MouseButton1Click:Connect(function()
                pcall(function()
                    selectedObj[propName] = not selectedObj[propName]
                    local v = selectedObj[propName]
                    toggle.Text = v and "✓ true" or "✗ false"
                    toggle.BackgroundColor3 = v and Color3.fromRGB(40,120,40) or Color3.fromRGB(100,40,40)
                end)
            end)

        elseif valType == "number" then
            local input = Instance.new("TextBox", row)
            input.Size = UDim2.new(0.5, -4, 0, 20)
            input.Position = UDim2.new(0.5, 2, 0, 4)
            input.BackgroundColor3 = T.dark
            input.Text = tostring(math.floor(val * 100) / 100)
            input.TextColor3 = T.text
            input.Font = Enum.Font.Code
            input.TextSize = 10
            input.BorderSizePixel = 0
            input.ClearTextOnFocus = false
            makeCorner(3, input)
            input.FocusLost:Connect(function()
                local n = tonumber(input.Text)
                if n then pcall(function() selectedObj[propName] = n end) end
                task.defer(refreshExplorer)
            end)

        elseif valType == "string" then
            local input = Instance.new("TextBox", row)
            input.Size = UDim2.new(0.5, -4, 0, 20)
            input.Position = UDim2.new(0.5, 2, 0, 4)
            input.BackgroundColor3 = T.dark
            input.Text = val:sub(1, 30)
            input.TextColor3 = T.text
            input.Font = Enum.Font.Code
            input.TextSize = 10
            input.BorderSizePixel = 0
            input.ClearTextOnFocus = false
            makeCorner(3, input)
            input.FocusLost:Connect(function()
                pcall(function() selectedObj[propName] = input.Text end)
                task.defer(refreshExplorer)
            end)

        elseif valType == "Vector3" then
            makeLabel(row,
                string.format("%.1f, %.1f, %.1f", val.X, val.Y, val.Z),
                UDim2.new(0.5, -4, 1, 0), UDim2.new(0.5, 2, 0, 0),
                Enum.Font.Code, 10, Color3.fromRGB(100, 200, 255))

        elseif valType == "CFrame" then
            makeLabel(row,
                string.format("%.0f, %.0f, %.0f", val.X, val.Y, val.Z),
                UDim2.new(0.5, -4, 1, 0), UDim2.new(0.5, 2, 0, 0),
                Enum.Font.Code, 10, Color3.fromRGB(255, 200, 100))

        elseif valType == "Color3" then
            local swatch = Instance.new("Frame", row)
            swatch.Size = UDim2.new(0, 50, 0, 18)
            swatch.Position = UDim2.new(0.5, 2, 0, 5)
            swatch.BackgroundColor3 = val
            swatch.BorderSizePixel = 0
            makeCorner(3, swatch)

        elseif valType == "BrickColor" then
            makeLabel(row, tostring(val), UDim2.new(0.5, -4, 1, 0), UDim2.new(0.5, 2, 0, 0),
                Enum.Font.Code, 10, Color3.fromRGB(255, 180, 100))

        elseif valType == "EnumItem" then
            makeLabel(row, tostring(val), UDim2.new(0.5, -4, 1, 0), UDim2.new(0.5, 2, 0, 0),
                Enum.Font.Code, 10, Color3.fromRGB(180, 255, 180))
        else
            makeLabel(row, tostring(val):sub(1,20), UDim2.new(0.5, -4, 1, 0), UDim2.new(0.5, 2, 0, 0),
                Enum.Font.Code, 10, T.textDim)
        end

        -- Divider
        local div = Instance.new("Frame", row)
        div.Size = UDim2.new(1, 0, 0, 1)
        div.Position = UDim2.new(0, 0, 1, -1)
        div.BackgroundColor3 = T.border
        div.BorderSizePixel = 0
    end

    -- Delete button
    local delRow = Instance.new("Frame", propsScroll)
    delRow.Size = UDim2.new(1, 0, 0, 32)
    delRow.BackgroundTransparency = 1
    delRow.BorderSizePixel = 0
    local delBtn = makeBtn(delRow, "🗑 Delete Object", UDim2.new(1, -8, 0, 26), UDim2.new(0, 4, 0, 3), T.red, Color3.new(1,1,1))
    delBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if selectedBox then selectedBox:Destroy() selectedBox = nil end
            selectedObj:Destroy()
            selectedObj = nil
            refreshProperties()
            task.defer(refreshExplorer)
        end)
    end)

    -- Anchor/Unanchor
    if selectedObj:IsA("BasePart") then
        local anchorRow = Instance.new("Frame", propsScroll)
        anchorRow.Size = UDim2.new(1, 0, 0, 32)
        anchorRow.BackgroundTransparency = 1
        anchorRow.BorderSizePixel = 0

        local isAnchored = selectedObj.Anchored
        local anchorBtn = makeBtn(anchorRow,
            isAnchored and "🔓 Unanchor" or "⚓ Anchor",
            UDim2.new(0.5, -6, 0, 26), UDim2.new(0, 4, 0, 3),
            isAnchored and Color3.fromRGB(80,60,20) or Color3.fromRGB(20,60,80))
        anchorBtn.MouseButton1Click:Connect(function()
            pcall(function()
                selectedObj.Anchored = not selectedObj.Anchored
                refreshProperties()
            end)
        end)

        local dupBtn = makeBtn(anchorRow, "⎘ Duplicate", UDim2.new(0.5, -6, 0, 26), UDim2.new(0.5, 2, 0, 3), T.accentDim, Color3.new(1,1,1))
        dupBtn.MouseButton1Click:Connect(function()
            pcall(function()
                local clone = selectedObj:Clone()
                clone.CFrame = clone.CFrame + Vector3.new(4,0,0)
                clone.Parent = selectedObj.Parent
                table.insert(spawnedObjects, clone)
                selectObject(clone)
                task.defer(refreshExplorer)
            end)
        end)
    end
end

refreshProperties()

----------------------------------------------------
-- MOVE / SCALE / ROTATE HANDLES
----------------------------------------------------
local dragConn = nil
local isDragging = false
local dragStartPos = nil
local objStartCFrame = nil

local function enableHandles()
    if dragConn then dragConn:Disconnect() end
    if not selectedObj or not selectedObj:IsA("BasePart") then return end

    dragConn = UserInputService.InputChanged:Connect(function(input)
        if not isDragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        pcall(function()
            local delta = input.Delta
            if currentTool == "Move" then
                selectedObj.CFrame = selectedObj.CFrame * CFrame.new(delta.X * 0.1, -delta.Y * 0.1, 0)
            elseif currentTool == "Scale" then
                local s = selectedObj.Size
                selectedObj.Size = Vector3.new(
                    math.max(0.2, s.X + delta.X * 0.05),
                    math.max(0.2, s.Y - delta.Y * 0.05),
                    s.Z
                )
            elseif currentTool == "Rotate" then
                selectedObj.CFrame = selectedObj.CFrame * CFrame.Angles(0, math.rad(delta.X * 0.5), 0)
            end
            refreshProperties()
        end)
    end)
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        enableHandles()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

----------------------------------------------------
-- PLAY / STOP
----------------------------------------------------
playBtn.MouseButton1Click:Connect(function()
    if playMode then return end
    playMode = true
    statusLbl.Text = "▶ Play mode active. Press Stop to return."
    playBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 30)

    -- Hide builder UI
    explorerPanel.Visible = false
    propsPanel.Visible = false
    toolbar.Visible = false
    topbar.Visible = false
    bottombar.Visible = true -- keep stop visible

    -- Restore character movement
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local h = char:FindFirstChild("Humanoid")
            if h then
                h.WalkSpeed = 16
                h.JumpPower = 50
            end
        end
    end)
end)

stopBtn.MouseButton1Click:Connect(function()
    if not playMode then return end
    playMode = false
    statusLbl.Text = "■ Stopped. Ready."
    playBtn.BackgroundColor3 = T.green

    -- Show builder UI
    explorerPanel.Visible = true
    propsPanel.Visible = true
    toolbar.Visible = true
    topbar.Visible = true

    task.defer(refreshExplorer)
end)

----------------------------------------------------
-- CLOSE
----------------------------------------------------
closeBtn.MouseButton1Click:Connect(function()
    if selectedBox then pcall(function() selectedBox:Destroy() end) end
    if dragConn then dragConn:Disconnect() end
    sg:Destroy()
end)

----------------------------------------------------
-- AUTO REFRESH EXPLORER (setiap 3 detik)
----------------------------------------------------
task.spawn(function()
    while sg.Parent do
        task.wait(3)
        if not playMode then
            pcall(refreshExplorer)
        end
    end
end)

statusLbl.Text = "🌙 SkyMoon Real Builder loaded!"
