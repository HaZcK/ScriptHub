-- 🌙 SkyMoon Real Builder v2
-- by KHAFIDZKTP | github.com/HaZcK/ScriptHub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

----------------------------------------------------
-- COREGUI
----------------------------------------------------
local sg = Instance.new("ScreenGui")
sg.Name = "SkyMoon_RealBuilder"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = game:GetService("CoreGui")

----------------------------------------------------
-- THEME
----------------------------------------------------
local T = {
    bg      = Color3.fromRGB(38,38,38),
    panel   = Color3.fromRGB(46,46,46),
    dark    = Color3.fromRGB(30,30,30),
    darker  = Color3.fromRGB(20,20,20),
    accent  = Color3.fromRGB(0,162,255),
    text    = Color3.fromRGB(220,220,220),
    dimText = Color3.fromRGB(140,140,140),
    sel     = Color3.fromRGB(0,100,210),
    border  = Color3.fromRGB(60,60,60),
    green   = Color3.fromRGB(50,180,60),
    red     = Color3.fromRGB(200,50,50),
    yellow  = Color3.fromRGB(220,180,0),
    handle_x = Color3.fromRGB(220,50,50),
    handle_y = Color3.fromRGB(50,200,60),
    handle_z = Color3.fromRGB(50,100,220),
}
local PANEL_ALPHA = 0.08

----------------------------------------------------
-- STATE
----------------------------------------------------
local selectedObj   = nil
local selBox        = nil
local currentTool   = "Select"
local playMode      = false
local freeCamActive = false
local freeCamConn   = nil
local noClipConn    = nil
local spawnedObjs   = {}
local expanded      = {}
local savedCharCF   = nil
local colorTarget   = nil -- which property to apply color to

----------------------------------------------------
-- HELPERS
----------------------------------------------------
local function mkCorner(r,p) local c=Instance.new("UICorner",p) c.CornerRadius=UDim.new(0,r) return c end
local function mkStroke(col,t,p) local s=Instance.new("UIStroke",p) s.Color=col s.Thickness=t or 1 return s end

local function mkFrame(parent, size, pos, bg, alpha)
    local f = Instance.new("Frame", parent)
    f.Size = size
    f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = bg or T.panel
    f.BackgroundTransparency = alpha or PANEL_ALPHA
    f.BorderSizePixel = 0
    return f
end

local function mkLabel(parent, text, size, pos, fs, color, xalign)
    local l = Instance.new("TextLabel", parent)
    l.Size = size; l.Position = pos or UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1
    l.Text = text; l.Font = Enum.Font.Code
    l.TextSize = fs or 12; l.TextColor3 = color or T.text
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.TextWrapped = true
    return l
end

local function mkBtn(parent, text, size, pos, bg, tc)
    local b = Instance.new("TextButton", parent)
    b.Size=size; b.Position=pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = bg or T.dark
    b.BackgroundTransparency = PANEL_ALPHA
    b.Text=text; b.TextColor3=tc or T.text
    b.Font=Enum.Font.GothamBold; b.TextSize=11
    b.BorderSizePixel=0; b.AutoButtonColor=false
    mkCorner(4,b)
    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=T.sel,BackgroundTransparency=0}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=bg or T.dark,BackgroundTransparency=PANEL_ALPHA}):Play()
    end)
    return b
end

local function mkInput(parent, size, pos, placeholder, defaultText)
    local b = Instance.new("TextBox", parent)
    b.Size=size; b.Position=pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3=T.darker; b.BackgroundTransparency=0
    b.Text=defaultText or ""; b.PlaceholderText=placeholder or ""
    b.PlaceholderColor3=T.dimText; b.TextColor3=T.text
    b.Font=Enum.Font.Code; b.TextSize=11
    b.BorderSizePixel=0; b.ClearTextOnFocus=false
    mkCorner(3,b)
    return b
end

----------------------------------------------------
-- LAYOUT
----------------------------------------------------
-- Topbar
local topbar = mkFrame(sg, UDim2.new(1,0,0,32), UDim2.new(0,0,0,0), T.darker, 0)
topbar.ZIndex = 20
mkLabel(topbar,"🌙  SkyMoon Real Builder v2",UDim2.new(0,260,1,0),UDim2.new(0,10,0,0),13,T.accent)

-- Explorer panel (left, resizable)
local explorerW = 220
local explorerPanel = mkFrame(sg,UDim2.new(0,explorerW,1,-72),UDim2.new(0,0,0,32),T.darker,0)
explorerPanel.ZIndex = 10
mkStroke(T.border,1,explorerPanel)

local explorerHeader = mkFrame(explorerPanel,UDim2.new(1,0,0,24),UDim2.new(0,0,0,0),T.dark,0)
mkLabel(explorerHeader,"  Explorer",UDim2.new(1,-40,1,0),UDim2.new(0,0,0,0),11,T.dimText)

-- Resize handle for explorer
local exResizeHandle = Instance.new("Frame", explorerPanel)
exResizeHandle.Size = UDim2.new(0, 5, 1, 0)
exResizeHandle.Position = UDim2.new(1, -5, 0, 0)
exResizeHandle.BackgroundColor3 = T.border
exResizeHandle.BorderSizePixel = 0
exResizeHandle.ZIndex = 15
exResizeHandle.Active = true

local explorerScroll = Instance.new("ScrollingFrame", explorerPanel)
explorerScroll.Size = UDim2.new(1,0,1,-24)
explorerScroll.Position = UDim2.new(0,0,0,24)
explorerScroll.BackgroundTransparency = 1
explorerScroll.BorderSizePixel = 0
explorerScroll.ScrollBarThickness = 4
explorerScroll.ScrollBarImageColor3 = T.accent
explorerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
explorerScroll.CanvasSize = UDim2.new(0,0,0,0)
Instance.new("UIListLayout",explorerScroll).Padding = UDim.new(0,1)

-- Properties panel (right, resizable)
local propsW = 220
local propsPanel = mkFrame(sg,UDim2.new(0,propsW,1,-72),UDim2.new(1,-propsW,0,32),T.darker,0)
propsPanel.ZIndex = 10
mkStroke(T.border,1,propsPanel)

local propsHeader = mkFrame(propsPanel,UDim2.new(1,0,0,24),UDim2.new(0,0,0,0),T.dark,0)
mkLabel(propsHeader,"  Properties",UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),11,T.dimText)

-- Resize handle for props
local prResizeHandle = Instance.new("Frame", propsPanel)
prResizeHandle.Size = UDim2.new(0,5,1,0)
prResizeHandle.Position = UDim2.new(0,0,0,0)
prResizeHandle.BackgroundColor3 = T.border
prResizeHandle.BorderSizePixel = 0
prResizeHandle.ZIndex = 15
prResizeHandle.Active = true

local propsScroll = Instance.new("ScrollingFrame", propsPanel)
propsScroll.Size = UDim2.new(1,0,1,-24)
propsScroll.Position = UDim2.new(0,0,0,24)
propsScroll.BackgroundTransparency = 1
propsScroll.BorderSizePixel = 0
propsScroll.ScrollBarThickness = 4
propsScroll.ScrollBarImageColor3 = T.accent
propsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
propsScroll.CanvasSize = UDim2.new(0,0,0,0)
Instance.new("UIListLayout",propsScroll).Padding = UDim.new(0,0)

-- Toolbar
local toolbarFrame = mkFrame(sg,UDim2.new(1,-440,0,32),UDim2.new(0,explorerW,0,32),T.dark,0)
toolbarFrame.ZIndex = 15
local tbLayout = Instance.new("UIListLayout",toolbarFrame)
tbLayout.FillDirection = Enum.FillDirection.Horizontal
tbLayout.Padding = UDim.new(0,3)
local tbPad = Instance.new("UIPadding",toolbarFrame)
tbPad.PaddingLeft = UDim.new(0,4)
tbPad.PaddingTop = UDim.new(0,3)
tbPad.PaddingBottom = UDim.new(0,3)

-- Bottom bar
local bottomBar = mkFrame(sg,UDim2.new(1,0,0,40),UDim2.new(0,0,1,-40),T.darker,0)
bottomBar.ZIndex = 20
mkStroke(T.border,1,bottomBar)

local statusLbl = mkLabel(bottomBar,"🌙 Ready.",UDim2.new(0,340,1,0),UDim2.new(0,10,0,0),11,T.dimText)

----------------------------------------------------
-- PANEL RESIZE
----------------------------------------------------
local function setupResize(handle, getPanel, isLeft, updateCb)
    local dragging = false
    local startX = 0
    local startW = 0

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startX = inp.Position.X
            startW = getPanel().AbsoluteSize.X
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or
           inp.UserInputType == Enum.UserInputType.Touch then
            local delta = inp.Position.X - startX
            local newW = math.clamp(startW + (isLeft and delta or -delta), 140, 380)
            if updateCb then updateCb(newW) end
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or
           inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

setupResize(exResizeHandle, function() return explorerPanel end, false, function(w)
    explorerW = w
    explorerPanel.Size = UDim2.new(0,w,1,-72)
    toolbarFrame.Position = UDim2.new(0,w,0,32)
    toolbarFrame.Size = UDim2.new(1,-(w+propsW),0,32)
end)

setupResize(prResizeHandle, function() return propsPanel end, true, function(w)
    propsW = w
    propsPanel.Size = UDim2.new(0,w,1,-72)
    propsPanel.Position = UDim2.new(1,-w,0,32)
    toolbarFrame.Size = UDim2.new(1,-(explorerW+w),0,32)
end)

----------------------------------------------------
-- TOOL BUTTONS
----------------------------------------------------
local toolBtns = {}
local TOOLS = {{"🔲 Select","Select"},{"✢ Move","Move"},{"⊡ Scale","Scale"},{"↻ Rotate","Rotate"}}
for _, t in ipairs(TOOLS) do
    local b = mkBtn(toolbarFrame,t[1],UDim2.new(0,76,0,26))
    b.ZIndex = 16
    b.MouseButton1Click:Connect(function()
        currentTool = t[2]
        for _, tb in ipairs(toolBtns) do
            tb.BackgroundColor3 = T.dark
            tb.BackgroundTransparency = PANEL_ALPHA
        end
        b.BackgroundColor3 = T.sel
        b.BackgroundTransparency = 0
        updateHandles()
    end)
    table.insert(toolBtns, b)
end
toolBtns[1].BackgroundColor3 = T.sel
toolBtns[1].BackgroundTransparency = 0

-- Insert button
local insertBtn = mkBtn(toolbarFrame,"⊕ Insert",UDim2.new(0,72,0,26),nil,T.accent,Color3.new(1,1,1))
insertBtn.BackgroundTransparency = 0
insertBtn.ZIndex = 16

-- Color Picker button
local colorBtn = mkBtn(toolbarFrame,"🎨 Color",UDim2.new(0,66,0,26),nil,T.dark)
colorBtn.ZIndex = 16

-- Play/Stop in bottombar
local playBtn = mkBtn(bottomBar,"▶ Play",UDim2.new(0,80,0,28),UDim2.new(0.5,-92,0,6),T.green,Color3.new(0,0,0))
playBtn.BackgroundTransparency = 0
local stopBtn = mkBtn(bottomBar,"■ Stop",UDim2.new(0,80,0,28),UDim2.new(0.5,12,0,6),T.red,Color3.new(1,1,1))
stopBtn.BackgroundTransparency = 0
local closeBtn = mkBtn(bottomBar,"✕ Close",UDim2.new(0,70,0,28),UDim2.new(1,-78,0,6),T.darker)
closeBtn.BackgroundTransparency = 0
mkStroke(T.red,1,closeBtn)

----------------------------------------------------
-- SELECTION BOX + CORNER HANDLES
----------------------------------------------------
local handleParts = {}

local function clearHandles()
    for _, h in ipairs(handleParts) do pcall(function() h:Destroy() end) end
    handleParts = {}
    if selBox then pcall(function() selBox:Destroy() end) selBox = nil end
end

local function makeHandle(pos, color)
    local h = Instance.new("Part")
    h.Name = "_SkyMoonHandle"
    h.Size = Vector3.new(0.4,0.4,0.4)
    h.Shape = Enum.PartType.Ball
    h.Color = color
    h.Material = Enum.Material.Neon
    h.Anchored = true
    h.CanCollide = false
    h.CastShadow = false
    h.CFrame = CFrame.new(pos)
    h.Parent = workspace
    table.insert(handleParts, h)
    return h
end

local function makeArrow(cframe, color)
    local h = Instance.new("Part")
    h.Name = "_SkyMoonArrow"
    h.Size = Vector3.new(0.2, 1.2, 0.2)
    h.Color = color
    h.Material = Enum.Material.Neon
    h.Anchored = true
    h.CanCollide = false
    h.CastShadow = false
    h.CFrame = cframe
    h.Parent = workspace
    table.insert(handleParts, h)
    return h
end

local function showSelectionHandles(obj)
    clearHandles()
    if not obj or not obj:IsA("BasePart") then return end

    -- SelectionBox
    selBox = Instance.new("SelectionBox")
    selBox.Adornee = obj
    selBox.Color3 = T.accent
    selBox.LineThickness = 0.06
    selBox.SurfaceTransparency = 0.85
    selBox.SurfaceColor3 = T.accent
    selBox.Parent = workspace

    local cf = obj.CFrame
    local s = obj.Size / 2

    if currentTool == "Move" then
        -- 3 arrows: red=X, green=Y, blue=Z
        makeArrow(cf * CFrame.new(s.X+1.2,0,0) * CFrame.Angles(0,0,-math.pi/2), T.handle_x) -- X right
        makeArrow(cf * CFrame.new(-s.X-1.2,0,0) * CFrame.Angles(0,0,math.pi/2), T.handle_x)  -- X left
        makeArrow(cf * CFrame.new(0,s.Y+1.2,0), T.handle_y)                                   -- Y up
        makeArrow(cf * CFrame.new(0,-s.Y-1.2,0) * CFrame.Angles(math.pi,0,0), T.handle_y)    -- Y down
        makeArrow(cf * CFrame.new(0,0,s.Z+1.2) * CFrame.Angles(math.pi/2,0,0), T.handle_z)  -- Z fwd
        makeArrow(cf * CFrame.new(0,0,-s.Z-1.2) * CFrame.Angles(-math.pi/2,0,0), T.handle_z)-- Z back
    elseif currentTool == "Scale" then
        -- 3 sphere handles per axis
        makeHandle((cf * CFrame.new(s.X+0.8,0,0)).Position, T.handle_x)
        makeHandle((cf * CFrame.new(-s.X-0.8,0,0)).Position, T.handle_x)
        makeHandle((cf * CFrame.new(0,s.Y+0.8,0)).Position, T.handle_y)
        makeHandle((cf * CFrame.new(0,-s.Y-0.8,0)).Position, T.handle_y)
        makeHandle((cf * CFrame.new(0,0,s.Z+0.8)).Position, T.handle_z)
        makeHandle((cf * CFrame.new(0,0,-s.Z-0.8)).Position, T.handle_z)
    else
        -- Corner dots for Select/Rotate
        for _, xs in ipairs({s.X,-s.X}) do
            for _, ys in ipairs({s.Y,-s.Y}) do
                for _, zs in ipairs({s.Z,-s.Z}) do
                    makeHandle((cf*CFrame.new(xs,ys,zs)).Position, T.accent)
                end
            end
        end
    end
end

function updateHandles()
    if selectedObj and selectedObj:IsA("BasePart") then
        showSelectionHandles(selectedObj)
    end
end

----------------------------------------------------
-- FREE CAM
----------------------------------------------------
local function startFreeCam()
    if freeCamActive then return end
    freeCamActive = true

    -- Teleport to Y:999
    savedCharCF = nil
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedCharCF = char.HumanoidRootPart.CFrame
            char.HumanoidRootPart.CFrame = CFrame.new(0, 999, 0)
        end
        -- Freeze humanoid
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 0
            char.Humanoid.JumpPower = 0
        end
    end)

    -- NoCl ip
    noClipConn = RunService.Stepped:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end)

    -- Free camera
    local cam = workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Scriptable

    local camCF = CFrame.new(0, 999, 20)
    cam.CFrame = camCF

    local moveSpeed = 30
    freeCamConn = RunService.RenderStepped:Connect(function(dt)
        local vel = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.E) then vel = vel + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then vel = vel - Vector3.new(0,1,0) end

        local spd = UIS:IsKeyDown(Enum.KeyCode.LeftShift) and moveSpeed*3 or moveSpeed
        cam.CFrame = cam.CFrame + vel * spd * dt
    end)

    statusLbl.Text = "FreeCam ON — WASD/QE to move, Shift=fast"
end

local function stopFreeCam()
    if not freeCamActive then return end
    freeCamActive = false

    if freeCamConn then freeCamConn:Disconnect() freeCamConn = nil end
    if noClipConn then noClipConn:Disconnect() noClipConn = nil end

    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
            char.Humanoid.JumpPower = 50
        end
    end)
end

startFreeCam()

----------------------------------------------------
-- PLAY / STOP
----------------------------------------------------
playBtn.MouseButton1Click:Connect(function()
    if playMode then return end
    playMode = true
    playBtn.BackgroundColor3 = Color3.fromRGB(20,80,20)
    statusLbl.Text = "▶ Play Mode — Walk around!"
    clearHandles()

    stopFreeCam()

    -- Teleport back to saved or ground
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = savedCharCF or CFrame.new(0, 5, 0)
        end
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
            char.Humanoid.JumpPower = 50
        end
    end)
end)

stopBtn.MouseButton1Click:Connect(function()
    if not playMode then return end
    playMode = false
    playBtn.BackgroundColor3 = T.green
    statusLbl.Text = "■ Stopped — back to builder"
    startFreeCam()
    updateHandles()
end)

----------------------------------------------------
-- COLOR PICKER
----------------------------------------------------
local colorPicker = mkFrame(sg, UDim2.new(0,220,0,260), UDim2.new(0.5,-110,0.5,-130), T.darker, 0)
colorPicker.ZIndex = 50
colorPicker.Visible = false
mkCorner(8, colorPicker)
mkStroke(T.border, 1, colorPicker)

local cpHeader = mkFrame(colorPicker, UDim2.new(1,0,0,24), UDim2.new(0,0,0,0), T.dark, 0)
mkLabel(cpHeader,"  🎨 Color Picker",UDim2.new(1,-30,1,0),UDim2.new(0,0,0,0),11,T.dimText)
local cpClose = mkBtn(cpHeader,"✕",UDim2.new(0,24,0,20),UDim2.new(1,-26,0,2),T.red,Color3.new(1,1,1))
cpClose.BackgroundTransparency = 0
cpClose.MouseButton1Click:Connect(function() colorPicker.Visible = false end)

-- HSV Canvas
local hsvCanvas = Instance.new("ImageLabel", colorPicker)
hsvCanvas.Size = UDim2.new(1,-16,0,140)
hsvCanvas.Position = UDim2.new(0,8,0,28)
hsvCanvas.BackgroundColor3 = Color3.fromRGB(255,0,0)
hsvCanvas.BorderSizePixel = 0
hsvCanvas.Image = "rbxassetid://4155801252" -- SatVal picker texture
mkCorner(4, hsvCanvas)

-- Hue bar
local hueBar = Instance.new("ImageLabel", colorPicker)
hueBar.Size = UDim2.new(1,-16,0,16)
hueBar.Position = UDim2.new(0,8,0,174)
hueBar.Image = "rbxassetid://698052001" -- hue gradient
hueBar.BorderSizePixel = 0
mkCorner(4, hueBar)

-- Cursor on canvas
local cpCursor = Instance.new("Frame", hsvCanvas)
cpCursor.Size = UDim2.new(0,10,0,10)
cpCursor.Position = UDim2.new(0.5,-5,0.5,-5)
cpCursor.BackgroundTransparency = 1
cpCursor.BorderSizePixel = 0
mkStroke(Color3.new(1,1,1),2,cpCursor)
mkCorner(5,cpCursor)

-- Hue cursor
local hueCursor = Instance.new("Frame", hueBar)
hueCursor.Size = UDim2.new(0,4,1,0)
hueCursor.Position = UDim2.new(0,0,0,0)
hueCursor.BackgroundColor3 = Color3.new(1,1,1)
hueCursor.BorderSizePixel = 0

-- Color preview
local cpPreview = Instance.new("Frame", colorPicker)
cpPreview.Size = UDim2.new(0,40,0,28)
cpPreview.Position = UDim2.new(0,8,0,196)
cpPreview.BackgroundColor3 = Color3.new(1,0,0)
cpPreview.BorderSizePixel = 0
mkCorner(4, cpPreview)

-- RGB display
local rInput = mkInput(colorPicker,UDim2.new(0,38,0,24),UDim2.new(0,52,0,198),"R","255")
local gInput = mkInput(colorPicker,UDim2.new(0,38,0,24),UDim2.new(0,94,0,198),"G","0")
local bInput = mkInput(colorPicker,UDim2.new(0,38,0,24),UDim2.new(0,136,0,198),"B","0")
mkLabel(colorPicker,"R",UDim2.new(0,16,0,24),UDim2.new(0,52,0,196),10,T.handle_x)
mkLabel(colorPicker,"G",UDim2.new(0,16,0,24),UDim2.new(0,94,0,196),10,T.handle_y)
mkLabel(colorPicker,"B",UDim2.new(0,16,0,24),UDim2.new(0,136,0,196),10,T.handle_z)

-- Copy hex
local copyHexBtn = mkBtn(colorPicker,"Copy RGB",UDim2.new(0,64,0,24),UDim2.new(0,154,0,198),T.accent,Color3.new(1,1,1))
copyHexBtn.BackgroundTransparency = 0

-- Apply button
local applyColorBtn = mkBtn(colorPicker,"Apply",UDim2.new(1,-16,0,26),UDim2.new(0,8,1,-30),T.sel,Color3.new(1,1,1))
applyColorBtn.BackgroundTransparency = 0

-- Color state
local currentH, currentS, currentV = 0, 1, 1

local function updateColorUI()
    local col = Color3.fromHSV(currentH, currentS, currentV)
    cpPreview.BackgroundColor3 = col
    hsvCanvas.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
    local r,g,b = math.round(col.R*255), math.round(col.G*255), math.round(col.B*255)
    rInput.Text = tostring(r)
    gInput.Text = tostring(g)
    bInput.Text = tostring(b)
    cpCursor.Position = UDim2.new(currentS,-5,1-currentV,-5)
    hueCursor.Position = UDim2.new(currentH,-2,0,0)
end

-- HSV canvas click
local draggingCanvas = false
local draggingHue = false

hsvCanvas.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        draggingCanvas = true
    end
end)
hueBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        draggingHue = true
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        draggingCanvas = false
        draggingHue = false
    end
end)

UIS.InputChanged:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement and
       inp.UserInputType ~= Enum.UserInputType.Touch then return end

    if draggingCanvas then
        local absPos = hsvCanvas.AbsolutePosition
        local absSize = hsvCanvas.AbsoluteSize
        local rx = math.clamp((inp.Position.X - absPos.X) / absSize.X, 0, 1)
        local ry = math.clamp((inp.Position.Y - absPos.Y) / absSize.Y, 0, 1)
        currentS = rx
        currentV = 1 - ry
        updateColorUI()
    end
    if draggingHue then
        local absPos = hueBar.AbsolutePosition
        local absSize = hueBar.AbsoluteSize
        currentH = math.clamp((inp.Position.X - absPos.X) / absSize.X, 0, 1)
        updateColorUI()
    end
end)

-- RGB inputs
local function rgbToColor()
    local r = math.clamp(tonumber(rInput.Text) or 255, 0, 255) / 255
    local g = math.clamp(tonumber(gInput.Text) or 0, 0, 255) / 255
    local b = math.clamp(tonumber(bInput.Text) or 0, 0, 255) / 255
    local col = Color3.new(r, g, b)
    local h,s,v = Color3.toHSV(col)
    currentH, currentS, currentV = h, s, v
    updateColorUI()
end
rInput.FocusLost:Connect(rgbToColor)
gInput.FocusLost:Connect(rgbToColor)
bInput.FocusLost:Connect(rgbToColor)

copyHexBtn.MouseButton1Click:Connect(function()
    local r,g,b = rInput.Text, gInput.Text, bInput.Text
    pcall(function() setclipboard(r..","..g..","..b) end)
    copyHexBtn.Text = "Copied!"
    task.wait(1.5)
    copyHexBtn.Text = "Copy RGB"
end)

applyColorBtn.MouseButton1Click:Connect(function()
    if not selectedObj then return end
    local col = Color3.fromHSV(currentH, currentS, currentV)
    pcall(function()
        if selectedObj:IsA("BasePart") then
            selectedObj.Color = col
        elseif selectedObj:IsA("GuiObject") then
            selectedObj.BackgroundColor3 = col
        elseif selectedObj:IsA("TextLabel") or selectedObj:IsA("TextButton") or selectedObj:IsA("TextBox") then
            selectedObj.TextColor3 = col
        end
    end)
    colorPicker.Visible = false
    refreshProperties()
end)

colorBtn.MouseButton1Click:Connect(function()
    colorPicker.Visible = not colorPicker.Visible
    updateColorUI()
end)

updateColorUI()

----------------------------------------------------
-- INSERT MENU
----------------------------------------------------
local insertMenu = mkFrame(sg, UDim2.new(0,200,0,420), UDim2.new(0,explorerW,0,64), T.darker, 0)
insertMenu.ZIndex = 30
insertMenu.Visible = false
mkCorner(6, insertMenu)
mkStroke(T.border, 1, insertMenu)

local insHeader = mkFrame(insertMenu, UDim2.new(1,0,0,22), UDim2.new(0,0,0,0), T.dark, 0)
mkLabel(insHeader,"  Insert Object",UDim2.new(1,0,1,0),nil,11,T.dimText)

local insSearch = mkInput(insertMenu, UDim2.new(1,-8,0,22), UDim2.new(0,4,0,24), "Search...", "")
insSearch.ZIndex = 31

local insScroll = Instance.new("ScrollingFrame", insertMenu)
insScroll.Size = UDim2.new(1,0,1,-48)
insScroll.Position = UDim2.new(0,0,0,48)
insScroll.BackgroundTransparency = 1
insScroll.BorderSizePixel = 0
insScroll.ScrollBarThickness = 3
insScroll.ScrollBarImageColor3 = T.accent
insScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
insScroll.CanvasSize = UDim2.new(0,0,0,0)
insScroll.ZIndex = 31
Instance.new("UIListLayout", insScroll).Padding = UDim.new(0,2)

local INSERTABLE = {
    -- Parts
    {"🟦 Part",              "Part"},
    {"⚽ Sphere Part",       "Part_Sphere"},
    {"🔺 Wedge Part",        "WedgePart"},
    {"🔷 Corner Wedge",      "CornerWedgePart"},
    {"🧱 Truss",             "TrussPart"},
    -- Models
    {"📁 Model",             "Model"},
    {"📂 Folder",            "Folder"},
    -- Scripts
    {"📜 Script",            "Script"},
    {"📄 LocalScript",       "LocalScript"},
    {"📦 ModuleScript",      "ModuleScript"},
    -- GUI
    {"🖼 ScreenGui",         "ScreenGui"},
    {"🔲 Frame",             "Frame"},
    {"📝 TextLabel",         "TextLabel"},
    {"🔘 TextButton",        "TextButton"},
    {"✏️ TextBox",           "TextBox"},
    {"🖼 ImageLabel",        "ImageLabel"},
    {"🖱 ImageButton",       "ImageButton"},
    {"📜 ScrollingFrame",    "ScrollingFrame"},
    -- Lighting
    {"💡 PointLight",        "PointLight"},
    {"🔦 SpotLight",         "SpotLight"},
    {"☀️ SurfaceLight",     "SurfaceLight"},
    -- Effects
    {"✨ ParticleEmitter",   "ParticleEmitter"},
    {"🔥 Fire",              "Fire"},
    {"💨 Smoke",             "Smoke"},
    {"⚡ Sparkles",          "Sparkles"},
    -- Physics
    {"🧲 BodyVelocity",      "BodyVelocity"},
    {"📌 BodyPosition",      "BodyPosition"},
    {"🔒 WeldConstraint",    "WeldConstraint"},
    {"🔧 HingeConstraint",   "HingeConstraint"},
    {"🔗 BallSocketConstraint","BallSocketConstraint"},
    -- Misc
    {"🎵 Sound",             "Sound"},
    {"📡 RemoteEvent",       "RemoteEvent"},
    {"📡 RemoteFunction",    "RemoteFunction"},
    {"🔗 BindableEvent",     "BindableEvent"},
    {"💫 Attachment",        "Attachment"},
    {"🌊 SpecialMesh",       "SpecialMesh"},
    {"🎨 Decal",             "Decal"},
    {"🌐 SurfaceAppearance", "SurfaceAppearance"},
    {"📷 Camera",            "Camera"},
    {"🌀 BillboardGui",      "BillboardGui"},
    {"📌 SurfaceGui",        "SurfaceGui"},
}

local allInsButtons = {}

local function buildInsertList(filter)
    for _, c in ipairs(insScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, item in ipairs(INSERTABLE) do
        if filter == "" or item[1]:lower():find(filter:lower(), 1, true) then
            local btn = Instance.new("TextButton", insScroll)
            btn.Size = UDim2.new(1,-4,0,24)
            btn.BackgroundColor3 = T.panel
            btn.BackgroundTransparency = PANEL_ALPHA
            btn.Text = item[1]
            btn.TextColor3 = T.text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 11
            btn.BorderSizePixel = 0
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 32
            local pad = Instance.new("UIPadding", btn) pad.PaddingLeft = UDim.new(0,8)
            btn.MouseEnter:Connect(function() btn.BackgroundColor3=T.sel btn.BackgroundTransparency=0 end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3=T.panel btn.BackgroundTransparency=PANEL_ALPHA end)
            btn.MouseButton1Click:Connect(function()
                local parent = selectedObj or workspace
                local className = item[2]
                pcall(function()
                    local obj
                    if className == "Part_Sphere" then
                        obj = Instance.new("Part")
                        obj.Shape = Enum.PartType.Ball
                    else
                        obj = Instance.new(className)
                    end
                    if obj:IsA("BasePart") then
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local cam = workspace.CurrentCamera
                        obj.CFrame = hrp and hrp.CFrame + Vector3.new(0,3,-6) or cam.CFrame * CFrame.new(0,0,-8)
                        obj.Size = Vector3.new(4,4,4)
                        obj.Anchored = true
                        obj.BrickColor = BrickColor.new("Bright blue")
                        table.insert(spawnedObjs, obj)
                    end
                    if obj:IsA("GuiObject") or obj:IsA("ScreenGui") then
                        obj.Parent = LocalPlayer:FindFirstChild("PlayerGui") or parent
                    else
                        obj.Parent = parent
                    end
                    statusLbl.Text = "Inserted: " .. className
                    insertMenu.Visible = false
                    task.defer(refreshExplorer)
                    selectObject(obj)
                end)
            end)
        end
    end
end

buildInsertList("")
insSearch.Changed:Connect(function()
    if insSearch:GetPropertyChangedSignal("Text") then
        buildInsertList(insSearch.Text)
    end
end)
insSearch:GetPropertyChangedSignal("Text"):Connect(function()
    buildInsertList(insSearch.Text)
end)

insertBtn.MouseButton1Click:Connect(function()
    insertMenu.Visible = not insertMenu.Visible
end)

----------------------------------------------------
-- SELECT OBJECT
----------------------------------------------------
local function refreshProperties() end -- forward
local function refreshExplorer() end   -- forward

local function selectObject(obj)
    selectedObj = obj
    showSelectionHandles(obj)
    refreshProperties()
    -- Refresh explorer to highlight
    task.defer(refreshExplorer)
end

----------------------------------------------------
-- EXPLORER
----------------------------------------------------
local function getIcon(obj)
    if obj:IsA("BasePart") then return "🟦"
    elseif obj:IsA("Model") then return "📁"
    elseif obj:IsA("Folder") then return "📂"
    elseif obj:IsA("LocalScript") then return "📄"
    elseif obj:IsA("Script") then return "📜"
    elseif obj:IsA("ModuleScript") then return "📦"
    elseif obj:IsA("Light") then return "💡"
    elseif obj:IsA("ParticleEmitter") then return "✨"
    elseif obj:IsA("Sound") then return "🎵"
    elseif obj:IsA("ScreenGui") then return "🖼"
    elseif obj:IsA("GuiObject") then return "🔲"
    elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then return "📡"
    elseif obj:IsA("Camera") then return "📷"
    else return "📄" end
end

function refreshExplorer()
    for _, c in ipairs(explorerScroll:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
    end

    local SERVICES = {
        {workspace, "Workspace", "🌍"},
        {game:GetService("ReplicatedStorage"), "ReplicatedStorage", "📦"},
        {game:GetService("ReplicatedFirst"), "ReplicatedFirst", "⚡"},
        {game:GetService("StarterGui"), "StarterGui", "🖥"},
        {game:GetService("StarterPack"), "StarterPack", "🎒"},
        {game:GetService("Lighting"), "Lighting", "💡"},
        {LocalPlayer, LocalPlayer.Name, "👤"},
    }

    local function addNode(obj, depth)
        local children = {}
        pcall(function() children = obj:GetChildren() end)
        local hasChildren = #children > 0
        local isExpanded = expanded[obj]
        local isSelected = (obj == selectedObj)

        local row = Instance.new("TextButton", explorerScroll)
        row.Size = UDim2.new(1,0,0,20)
        row.BackgroundColor3 = isSelected and T.sel or T.panel
        row.BackgroundTransparency = isSelected and 0 or PANEL_ALPHA
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = false

        local pad = Instance.new("UIPadding", row)
        pad.PaddingLeft = UDim.new(0, 4 + depth*14)

        -- Arrow toggle
        if hasChildren then
            local arrowBtn = mkBtn(row, isExpanded and "▾" or "▸",
                UDim2.new(0,16,1,0), UDim2.new(0,0,0,0), Color3.new(0,0,0), T.dimText)
            arrowBtn.BackgroundTransparency = 1
            arrowBtn.ZIndex = row.ZIndex + 1
            arrowBtn.MouseButton1Click:Connect(function()
                expanded[obj] = not expanded[obj]
                task.defer(refreshExplorer)
            end)
        end

        local icon = getIcon(obj)
        local nameLabel = mkLabel(row,
            (hasChildren and "  " or "  ") .. icon .. " " .. obj.Name,
            UDim2.new(1,-20,1,0), UDim2.new(0,16,0,0), 11,
            isSelected and Color3.new(1,1,1) or T.text
        )

        row.MouseButton1Click:Connect(function()
            selectObject(obj)
        end)

        row.MouseEnter:Connect(function()
            if obj ~= selectedObj then
                row.BackgroundColor3 = T.hover or T.sel
                row.BackgroundTransparency = 0.5
            end
        end)
        row.MouseLeave:Connect(function()
            if obj ~= selectedObj then
                row.BackgroundColor3 = T.panel
                row.BackgroundTransparency = PANEL_ALPHA
            end
        end)

        if isExpanded and hasChildren then
            for _, child in ipairs(children) do
                addNode(child, depth + 1)
            end
        end
    end

    for _, svc in ipairs(SERVICES) do
        addNode(svc[1], 0)
    end
end

----------------------------------------------------
-- PROPERTIES
----------------------------------------------------
function refreshProperties()
    for _, c in ipairs(propsScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end

    if not selectedObj then
        local row = Instance.new("Frame", propsScroll)
        row.Size = UDim2.new(1,0,0,30)
        row.BackgroundTransparency = 1
        row.BorderSizePixel = 0
        mkLabel(row,"  No selection.",UDim2.new(1,0,1,0),nil,11,T.dimText)
        return
    end

    -- Class header
    local hRow = Instance.new("Frame", propsScroll)
    hRow.Size = UDim2.new(1,0,0,26)
    hRow.BackgroundColor3 = T.dark
    hRow.BackgroundTransparency = 0
    hRow.BorderSizePixel = 0
    mkLabel(hRow,"  "..selectedObj.ClassName,UDim2.new(0.6,0,1,0),nil,11,T.accent)
    mkLabel(hRow,selectedObj.Name,UDim2.new(0.4,-4,1,0),UDim2.new(0.6,2,0,0),10,T.text,Enum.TextXAlignment.Right)

    local function addPropRow(propName)
        local ok, val = pcall(function() return selectedObj[propName] end)
        if not ok then return end

        local row = Instance.new("Frame", propsScroll)
        row.Size = UDim2.new(1,0,0,26)
        row.BackgroundColor3 = T.panel
        row.BackgroundTransparency = PANEL_ALPHA
        row.BorderSizePixel = 0

        mkLabel(row,propName,UDim2.new(0.44,-2,1,0),UDim2.new(0,6,0,0),10,T.dimText)

        local div = Instance.new("Frame",row)
        div.Size=UDim2.new(0,1,0.6,0) div.Position=UDim2.new(0.44,-1,0.2,0)
        div.BackgroundColor3=T.border div.BorderSizePixel=0

        local vt = typeof(val)

        if vt == "boolean" then
            local tb = mkBtn(row, val and "✓ true" or "✗ false",
                UDim2.new(0.55,-4,0,20), UDim2.new(0.45,2,0,3),
                val and T.green or T.red, Color3.new(1,1,1))
            tb.BackgroundTransparency = 0
            tb.TextSize = 10
            tb.MouseButton1Click:Connect(function()
                pcall(function()
                    selectedObj[propName] = not selectedObj[propName]
                    refreshProperties()
                end)
            end)

        elseif vt == "number" then
            local inp = mkInput(row, UDim2.new(0.55,-4,0,20), UDim2.new(0.45,2,0,3),
                "", tostring(math.floor(val*100)/100))
            inp.FocusLost:Connect(function()
                local n = tonumber(inp.Text)
                if n then pcall(function() selectedObj[propName]=n end) end
            end)

        elseif vt == "string" then
            local inp = mkInput(row, UDim2.new(0.55,-4,0,20), UDim2.new(0.45,2,0,3), "", val:sub(1,40))
            inp.FocusLost:Connect(function()
                pcall(function() selectedObj[propName]=inp.Text end)
                task.defer(refreshExplorer)
            end)

        elseif vt == "Vector3" then
            local vRow = Instance.new("Frame", propsScroll)
            vRow.Size = UDim2.new(1,0,0,26)
            vRow.BackgroundColor3 = T.panel
            vRow.BackgroundTransparency = PANEL_ALPHA
            vRow.BorderSizePixel = 0
            row.Size = UDim2.new(1,0,0,26)
            local xI = mkInput(vRow,UDim2.new(0.33,-2,0,20),UDim2.new(0,2,0,3),"X",tostring(math.floor(val.X*10)/10))
            local yI = mkInput(vRow,UDim2.new(0.33,-2,0,20),UDim2.new(0.33,0,0,3),"Y",tostring(math.floor(val.Y*10)/10))
            local zI = mkInput(vRow,UDim2.new(0.33,-2,0,20),UDim2.new(0.66,0,0,3),"Z",tostring(math.floor(val.Z*10)/10))
            local function applyV3()
                local x,y,z = tonumber(xI.Text), tonumber(yI.Text), tonumber(zI.Text)
                if x and y and z then
                    pcall(function() selectedObj[propName]=Vector3.new(x,y,z) end)
                    updateHandles()
                end
            end
            xI.FocusLost:Connect(applyV3) yI.FocusLost:Connect(applyV3) zI.FocusLost:Connect(applyV3)

        elseif vt == "Color3" then
            local swatch = Instance.new("TextButton", row)
            swatch.Size = UDim2.new(0,40,0,18)
            swatch.Position = UDim2.new(0.45,2,0,4)
            swatch.BackgroundColor3 = val
            swatch.BackgroundTransparency = 0
            swatch.Text = ""
            swatch.BorderSizePixel = 0
            mkCorner(3,swatch)
            mkLabel(row,string.format("%.0f,%.0f,%.0f",val.R*255,val.G*255,val.B*255),
                UDim2.new(0.3,0,1,0),UDim2.new(0.6,2,0,0),9,T.dimText)
            swatch.MouseButton1Click:Connect(function()
                colorTarget = propName
                -- Set picker to current color
                local h,s,v = Color3.toHSV(val)
                currentH,currentS,currentV = h,s,v
                updateColorUI()
                colorPicker.Visible = true
                applyColorBtn.MouseButton1Click:Connect(function()
                    local c = Color3.fromHSV(currentH,currentS,currentV)
                    pcall(function() selectedObj[propName]=c end)
                    refreshProperties()
                end)
            end)

        elseif vt == "BrickColor" then
            mkLabel(row,tostring(val),UDim2.new(0.55,-4,1,0),UDim2.new(0.45,2,0,0),10,Color3.fromRGB(255,180,100))

        elseif vt == "EnumItem" then
            mkLabel(row,tostring(val),UDim2.new(0.55,-4,1,0),UDim2.new(0.45,2,0,0),10,Color3.fromRGB(180,255,180))

        elseif vt == "CFrame" then
            mkLabel(row,string.format("%.0f,%.0f,%.0f",val.X,val.Y,val.Z),
                UDim2.new(0.55,-4,1,0),UDim2.new(0.45,2,0,0),10,Color3.fromRGB(255,200,100))
        else
            mkLabel(row,tostring(val):sub(1,24),UDim2.new(0.55,-4,1,0),UDim2.new(0.45,2,0,0),10,T.dimText)
        end

        -- Bottom divider
        local bdiv = Instance.new("Frame",row)
        bdiv.Size=UDim2.new(1,0,0,1) bdiv.Position=UDim2.new(0,0,1,-1)
        bdiv.BackgroundColor3=T.border bdiv.BorderSizePixel=0 bdiv.BackgroundTransparency=0.5
    end

    -- Properties per class
    local PROPS = {
        BasePart = {"Name","Anchored","CanCollide","CastShadow","Locked","Transparency","Reflectance",
                    "Color","BrickColor","Material","Size","Position","Rotation"},
        Model    = {"Name"},
        Folder   = {"Name"},
        Script   = {"Name","Disabled"},
        LocalScript = {"Name","Disabled"},
        ModuleScript = {"Name"},
        Sound    = {"Name","SoundId","Volume","Looped","Playing","RollOffMaxDistance"},
        Light    = {"Name","Brightness","Color","Range","Enabled"},
        ParticleEmitter = {"Name","Rate","Lifetime","Speed","Rotation","RotSpeed","Enabled"},
        GuiObject = {"Name","Visible","BackgroundColor3","BackgroundTransparency","ZIndex","Size","Position"},
        TextLabel = {"Name","Text","TextColor3","TextSize","Font","Visible","BackgroundColor3","BackgroundTransparency"},
        TextButton = {"Name","Text","TextColor3","TextSize","Font","Visible","BackgroundColor3"},
        TextBox   = {"Name","Text","PlaceholderText","TextColor3","TextSize","Visible"},
        ImageLabel = {"Name","Image","ImageColor3","ImageTransparency","Visible"},
        ScreenGui  = {"Name","Enabled","ResetOnSpawn","IgnoreGuiInset"},
        Camera     = {"Name","FieldOfView","CameraType"},
    }

    local seen = {}
    local function addProps(class, list)
        if not selectedObj:IsA(class) then return end
        for _, p in ipairs(list) do
            if not seen[p] then seen[p]=true addPropRow(p) end
        end
    end

    for class, list in pairs(PROPS) do addProps(class, list) end
    if not next(seen) then addPropRow("Name") end

    -- Action buttons
    local actRow = Instance.new("Frame", propsScroll)
    actRow.Size = UDim2.new(1,0,0,30)
    actRow.BackgroundTransparency = 1
    actRow.BorderSizePixel = 0

    local delBtn = mkBtn(actRow,"🗑 Delete",UDim2.new(0.5,-3,0,24),UDim2.new(0,2,0,3),T.red,Color3.new(1,1,1))
    delBtn.BackgroundTransparency = 0
    delBtn.MouseButton1Click:Connect(function()
        clearHandles()
        pcall(function() selectedObj:Destroy() end)
        selectedObj = nil
        refreshProperties()
        task.defer(refreshExplorer)
    end)

    if selectedObj and selectedObj:IsA("BasePart") then
        local dupBtn = mkBtn(actRow,"⎘ Duplicate",UDim2.new(0.5,-3,0,24),UDim2.new(0.5,1,0,3),T.accentDim or T.sel,Color3.new(1,1,1))
        dupBtn.BackgroundTransparency = 0
        dupBtn.MouseButton1Click:Connect(function()
            pcall(function()
                local clone = selectedObj:Clone()
                clone.CFrame = clone.CFrame + Vector3.new(4,0,0)
                clone.Parent = selectedObj.Parent
                table.insert(spawnedObjs, clone)
                selectObject(clone)
                task.defer(refreshExplorer)
            end)
        end)
    end
end

----------------------------------------------------
-- MOUSE DRAG TO MOVE/SCALE/ROTATE
----------------------------------------------------
local isDragging = false
local lastMouse = nil

UIS.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        lastMouse = inp.Position
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
        lastMouse = nil
        if selectedObj then updateHandles() refreshProperties() end
    end
end)
UIS.InputChanged:Connect(function(inp)
    if not isDragging then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    if not selectedObj or not selectedObj:IsA("BasePart") then return end
    if not lastMouse then return end

    local delta = inp.Position - lastMouse
    lastMouse = inp.Position

    pcall(function()
        if currentTool == "Move" then
            local cam = workspace.CurrentCamera
            local right = cam.CFrame.RightVector
            local up = cam.CFrame.UpVector
            selectedObj.CFrame = selectedObj.CFrame
                + right * delta.X * 0.12
                + up * (-delta.Y) * 0.12
            updateHandles()
        elseif currentTool == "Scale" then
            local s = selectedObj.Size
            selectedObj.Size = Vector3.new(
                math.max(0.2, s.X + delta.X * 0.06),
                math.max(0.2, s.Y - delta.Y * 0.06),
                s.Z
            )
            updateHandles()
        elseif currentTool == "Rotate" then
            selectedObj.CFrame = selectedObj.CFrame
                * CFrame.Angles(0, math.rad(delta.X * 0.6), 0)
            updateHandles()
        end
    end)
end)

----------------------------------------------------
-- CLOSE
----------------------------------------------------
closeBtn.MouseButton1Click:Connect(function()
    clearHandles()
    stopFreeCam()
    sg:Destroy()
end)

----------------------------------------------------
-- INIT
----------------------------------------------------
refreshExplorer()
refreshProperties()

-- Auto-refresh explorer
task.spawn(function()
    while sg.Parent do
        task.wait(4)
        if not playMode then pcall(refreshExplorer) end
    end
end)

-- Handle updates when selected part moves
RunService.Heartbeat:Connect(function()
    if selectedObj and selectedObj:IsA("BasePart") and not isDragging then
        if selBox then pcall(function() selBox.Adornee = selectedObj end) end
    end
end)

statusLbl.Text = "🌙 Real Builder v2 — FreeCam ON | Use WASD/QE to navigate"
