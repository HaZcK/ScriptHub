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
local colorTarget   = nil

-- Mobile detection
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- Mobile joystick state
local joystickDir   = Vector2.new(0,0)   -- normalized direction dari joystick
local joystickSpeed = 1.0                -- multiplier kecepatan (bisa di-setting)
local touchCamDelta = Vector2.new(0,0)   -- delta swipe untuk rotasi kamera
local joyActive     = false
local joyTouchId    = nil
local camTouchId    = nil
local joyCenter     = Vector2.new(0,0)   -- center joystick saat finger down
local JOY_RADIUS    = 60                 -- radius max joystick dalam pixel

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

local camYaw    = 0
local camPitch  = 0
local rmhHeld   = false
local rmhConn   = nil
local charYBase = -15
local lastCamPos = Vector3.new(0,0,0)

local function getCharY(camPos)
    -- Cek apakah kamera dekat part apapun di workspace
    local closestDist = math.huge
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "_SkyMoonHandle" and obj.Name ~= "_SkyMoonArrow" then
                local dist = (obj.Position - camPos).Magnitude
                if dist < closestDist then closestDist = dist end
            end
        end
    end)
    -- Kalau dekat ≤5 studs → lebih dalam
    if closestDist <= 5 then return -20
    elseif closestDist <= 15 then return -18
    else return charYBase end
end

local function startFreeCam()
    if freeCamActive then return end
    freeCamActive = true

    -- Disable Roblox default controls (jump button + joystick)
    pcall(function()
        local PlayerModule = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
        PlayerModule:GetControls():Disable()
    end)
    -- Backup: hide ControlGui
    pcall(function()
        local cg = game:GetService("CoreGui"):FindFirstChild("ControlGui")
        if cg then cg.Enabled = false end
    end)

    -- Simpan posisi char sebelumnya
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedCharCF = char.HumanoidRootPart.CFrame
        end
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 0
            char.Humanoid.JumpPower = 0
            char.Humanoid.AutoRotate = false
        end
    end)

    -- Taruh char di underground awal
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, charYBase, 0)
            char.HumanoidRootPart.Anchored = true
        end
    end)

    -- NoClip
    noClipConn = RunService.Stepped:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end)

    -- Setup kamera
    local cam = workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Scriptable
    camYaw   = 180
    camPitch = -20
    local startPos = Vector3.new(0, 20, 30)
    cam.CFrame = CFrame.new(startPos)
        * CFrame.Angles(0, math.rad(camYaw), 0)
        * CFrame.Angles(math.rad(camPitch), 0, 0)
    lastCamPos = startPos

    -- RMB untuk look (PC)
    local rmbDown = UIS.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton2 then
            rmhHeld = true
            UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
        end
    end)
    local rmbUp = UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton2 then
            rmhHeld = false
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)

    local moveSpeed = 40

    freeCamConn = RunService.RenderStepped:Connect(function(dt)
        if rmhHeld then
            local delta = UIS:GetMouseDelta()
            camYaw   = camYaw   - delta.X * 0.3
            camPitch = math.clamp(camPitch - delta.Y * 0.3, -89, 89)
        end
        if touchCamDelta.X ~= 0 or touchCamDelta.Y ~= 0 then
            camYaw   = camYaw   - touchCamDelta.X * 0.25
            camPitch = math.clamp(camPitch - touchCamDelta.Y * 0.25, -89, 89)
            touchCamDelta = Vector2.new(0,0)
        end
        local rotCF = CFrame.new(cam.CFrame.Position)
            * CFrame.Angles(0, math.rad(camYaw), 0)
            * CFrame.Angles(math.rad(camPitch), 0, 0)
        local vel = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then vel = vel + rotCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel = vel - rotCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel = vel - rotCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel = vel + rotCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.E) then vel = vel + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then vel = vel - Vector3.new(0,1,0) end
        if joystickDir.Magnitude > 0.05 then
            vel = vel + rotCF.LookVector * (-joystickDir.Y)
            vel = vel + rotCF.RightVector * joystickDir.X
        end
        local spd = UIS:IsKeyDown(Enum.KeyCode.LeftShift) and moveSpeed*4 or (moveSpeed * joystickSpeed)
        local newPos = cam.CFrame.Position + vel * spd * dt
        cam.CFrame = CFrame.new(newPos)
            * CFrame.Angles(0, math.rad(camYaw), 0)
            * CFrame.Angles(math.rad(camPitch), 0, 0)
        local camVelocity = (newPos - lastCamPos).Magnitude / dt
        lastCamPos = newPos
        local targetY = getCharY(newPos)
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local curCharPos = hrp.Position
                local targetPos = Vector3.new(newPos.X, targetY, newPos.Z)
                if camVelocity > 50 then hrp.CFrame = CFrame.new(targetPos)
                else hrp.CFrame = CFrame.new(curCharPos:Lerp(targetPos, math.clamp(dt*8,0,1))) end
            end
        end)
    end)

    rmhConn = {rmbDown, rmbUp}
    statusLbl.Text = isMobile
        and "🌙 FreeCam | WASD=gerak | Swipe=lihat | Tap=select"
        or  "🌙 FreeCam | RMB+drag=look | WASD/QE=move | Shift=fast"
end

local function stopFreeCam()
    if not freeCamActive then return end
    freeCamActive = false
    rmhHeld = false
    UIS.MouseBehavior = Enum.MouseBehavior.Default

    if freeCamConn then freeCamConn:Disconnect() freeCamConn = nil end
    if noClipConn  then noClipConn:Disconnect()  noClipConn  = nil end
    if rmhConn then
        for _, c in ipairs(rmhConn) do pcall(function() c:Disconnect() end) end
        rmhConn = nil
    end

    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

    -- Re-enable Roblox default controls
    pcall(function()
        local PlayerModule = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
        PlayerModule:GetControls():Enable()
    end)
    pcall(function()
        local cg = game:GetService("CoreGui"):FindFirstChild("ControlGui")
        if cg then cg.Enabled = true end
    end)

    -- Kembalikan char
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = false
            hrp.CFrame = savedCharCF or CFrame.new(0, 5, 0)
        end
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
            char.Humanoid.JumpPower = 50
            char.Humanoid.AutoRotate = true
        end
    end)

----------------------------------------------------
-- MOBILE JOYSTICK UI + TOUCH CAMERA
----------------------------------------------------
-- WASD BUTTONS (mobile) + touch swipe camera
-- Selalu tampil di HP, WASD buttons menggantikan joystick
if isMobile then
    -- Container WASD
    local wasdContainer = Instance.new("Frame", sg)
    wasdContainer.Size = UDim2.new(0, 130, 0, 130)
    wasdContainer.Position = UDim2.new(0, 10, 1, -145)
    wasdContainer.BackgroundColor3 = Color3.fromRGB(0,0,0)
    wasdContainer.BackgroundTransparency = 0.5
    wasdContainer.BorderSizePixel = 0
    wasdContainer.ZIndex = 25
    mkCorner(12, wasdContainer)

    -- Fungsi buat tombol WASD
    local wasdHeld = {W=false,A=false,S=false,D=false,Q=false,E=false}

    local function mkWasd(label, pos, dir)
        local b = Instance.new("TextButton", wasdContainer)
        b.Size = UDim2.new(0,38,0,38)
        b.Position = pos
        b.BackgroundColor3 = Color3.fromRGB(40,40,50)
        b.BackgroundTransparency = 0
        b.Text = label
        b.TextColor3 = Color3.fromRGB(200,220,255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.BorderSizePixel = 0
        b.ZIndex = 26
        mkCorner(8, b)
        mkStroke(T.border, 1, b)

        b.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                wasdHeld[dir] = true
                b.BackgroundColor3 = T.accent
                b.BackgroundTransparency = 0
            end
        end)
        b.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                wasdHeld[dir] = false
                b.BackgroundColor3 = Color3.fromRGB(40,40,50)
            end
        end)
        return b
    end

    -- Layout: W di atas tengah, A/S/D di bawah
    mkWasd("W", UDim2.new(0,46,0,4),  "W")
    mkWasd("A", UDim2.new(0,4,0,46),  "A")
    mkWasd("S", UDim2.new(0,46,0,46), "S")
    mkWasd("D", UDim2.new(0,88,0,46), "D")

    -- Up/Down (Q/E) di sisi kanan
    mkWasd("↑", UDim2.new(0,88,0,4),  "E")
    mkWasd("↓", UDim2.new(0,4,0,4),   "Q")

    -- Inject wasdHeld ke freecam loop
    RunService.RenderStepped:Connect(function()
        if not freeCamActive then return end
        local dir = Vector2.new(0,0)
        if wasdHeld.D then dir = dir + Vector2.new(1,0) end
        if wasdHeld.A then dir = dir - Vector2.new(1,0) end
        if wasdHeld.S then dir = dir + Vector2.new(0,1) end
        if wasdHeld.W then dir = dir - Vector2.new(0,1) end
        joystickDir = dir.Magnitude > 0 and dir.Unit or Vector2.new(0,0)
        -- Q/E inject langsung ke touchCamDelta sebagai vertical
        if wasdHeld.E then touchCamDelta = touchCamDelta + Vector2.new(0,5) end
        if wasdHeld.Q then touchCamDelta = touchCamDelta - Vector2.new(0,5) end
    end)

    -- Touch swipe untuk rotasi kamera
    local lastCamTouchPos = nil
    UIS.TouchStarted:Connect(function(touch, gp)
        if gp then return end
        if camTouchId == nil then
            camTouchId = touch
            lastCamTouchPos = Vector2.new(touch.Position.X, touch.Position.Y)
        end
    end)
    UIS.TouchMoved:Connect(function(touch, gp)
        if gp then return end
        if touch == camTouchId then
            local pos = Vector2.new(touch.Position.X, touch.Position.Y)
            if lastCamTouchPos then
                touchCamDelta = touchCamDelta + (pos - lastCamTouchPos)
            end
            lastCamTouchPos = pos
        end
    end)
    UIS.TouchEnded:Connect(function(touch, gp)
        if touch == camTouchId then
            camTouchId = nil
            lastCamTouchPos = nil
        end
    end)
end

----------------------------------------------------
-- PLAY / STOP handled in INIT section below
----------------------------------------------------

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
                -- Parent: selectedObj kalau folder/model, otherwise workspace
                local parent = workspace
                if selectedObj then
                    if selectedObj:IsA("Model") or selectedObj:IsA("Folder")
                    or selectedObj:IsA("BasePart") or selectedObj == workspace then
                        parent = selectedObj
                    else
                        parent = selectedObj.Parent or workspace
                    end
                end

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
                        -- Spawn di atas baseplate atau di depan kamera
                        local cam = workspace.CurrentCamera
                        local baseplate = workspace:FindFirstChild("Baseplate")
                        local spawnY = baseplate and (baseplate.Position.Y + baseplate.Size.Y/2 + 2) or 5
                        local camPos = cam.CFrame.Position
                        obj.CFrame = CFrame.new(camPos.X, spawnY, camPos.Z - 10)
                        obj.Size = Vector3.new(4,4,4)
                        obj.Anchored = true
                        obj.BrickColor = BrickColor.new("Bright blue")
                        obj.Material = Enum.Material.SmoothPlastic
                        table.insert(spawnedObjs, obj)
                    end

                    if obj:IsA("GuiObject") or obj:IsA("ScreenGui") then
                        obj.Parent = LocalPlayer:FindFirstChild("PlayerGui") or parent
                    else
                        obj.Parent = parent
                    end

                    statusLbl.Text = "Inserted: " .. className .. " → " .. parent.Name
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
-- Icon + color per class
local CLASS_INFO = {
    -- Parts
    Part            = {icon="🟦", color=Color3.fromRGB(100,160,255)},
    WedgePart       = {icon="🔺", color=Color3.fromRGB(100,160,255)},
    CornerWedgePart = {icon="🔷", color=Color3.fromRGB(100,160,255)},
    TrussPart       = {icon="🧱", color=Color3.fromRGB(100,160,255)},
    UnionOperation  = {icon="⬡",  color=Color3.fromRGB(120,180,255)},
    MeshPart        = {icon="🌐", color=Color3.fromRGB(120,180,255)},
    SpecialMesh     = {icon="🌀", color=Color3.fromRGB(140,180,220)},
    -- Models/Folders
    Model           = {icon="📁", color=Color3.fromRGB(220,170,80)},
    Folder          = {icon="📂", color=Color3.fromRGB(200,200,100)},
    -- Scripts
    Script          = {icon="📜", color=Color3.fromRGB(100,220,100)},
    LocalScript     = {icon="📄", color=Color3.fromRGB(80,200,80)},
    ModuleScript    = {icon="📦", color=Color3.fromRGB(60,180,140)},
    -- GUI
    ScreenGui       = {icon="🖼", color=Color3.fromRGB(200,120,220)},
    Frame           = {icon="▭",  color=Color3.fromRGB(180,100,200)},
    TextLabel       = {icon="🔤", color=Color3.fromRGB(180,100,200)},
    TextButton      = {icon="🔘", color=Color3.fromRGB(160,80,200)},
    TextBox         = {icon="✏️", color=Color3.fromRGB(160,80,200)},
    ImageLabel      = {icon="🖼", color=Color3.fromRGB(200,100,180)},
    ImageButton     = {icon="🖱", color=Color3.fromRGB(200,100,180)},
    ScrollingFrame  = {icon="📜", color=Color3.fromRGB(180,80,180)},
    BillboardGui    = {icon="📌", color=Color3.fromRGB(200,120,200)},
    SurfaceGui      = {icon="📌", color=Color3.fromRGB(200,120,200)},
    -- Lighting
    PointLight      = {icon="💡", color=Color3.fromRGB(255,240,100)},
    SpotLight       = {icon="🔦", color=Color3.fromRGB(255,220,80)},
    SurfaceLight    = {icon="☀️", color=Color3.fromRGB(255,200,60)},
    Sky             = {icon="🌌", color=Color3.fromRGB(100,150,255)},
    Atmosphere      = {icon="🌫", color=Color3.fromRGB(140,180,200)},
    -- Effects
    ParticleEmitter = {icon="✨", color=Color3.fromRGB(255,180,80)},
    Fire            = {icon="🔥", color=Color3.fromRGB(255,120,60)},
    Smoke           = {icon="💨", color=Color3.fromRGB(180,180,180)},
    Sparkles        = {icon="⚡", color=Color3.fromRGB(255,255,100)},
    Explosion       = {icon="💥", color=Color3.fromRGB(255,100,50)},
    -- Physics
    BodyVelocity    = {icon="🧲", color=Color3.fromRGB(100,200,255)},
    BodyPosition    = {icon="📌", color=Color3.fromRGB(100,200,255)},
    WeldConstraint  = {icon="🔒", color=Color3.fromRGB(150,150,200)},
    HingeConstraint = {icon="🔧", color=Color3.fromRGB(150,150,200)},
    BallSocketConstraint = {icon="🔗", color=Color3.fromRGB(150,150,200)},
    Attachment      = {icon="💫", color=Color3.fromRGB(180,200,255)},
    -- Network
    RemoteEvent     = {icon="📡", color=Color3.fromRGB(255,150,100)},
    RemoteFunction  = {icon="📡", color=Color3.fromRGB(255,150,100)},
    BindableEvent   = {icon="🔗", color=Color3.fromRGB(200,150,100)},
    -- Audio
    Sound           = {icon="🎵", color=Color3.fromRGB(100,255,180)},
    SoundGroup      = {icon="🎶", color=Color3.fromRGB(80,220,160)},
    -- Other
    Camera          = {icon="📷", color=Color3.fromRGB(180,220,255)},
    Humanoid        = {icon="🤖", color=Color3.fromRGB(255,200,200)},
    AnimationController = {icon="🎬",color=Color3.fromRGB(200,200,255)},
    Animation       = {icon="▶",  color=Color3.fromRGB(180,180,255)},
    Decal           = {icon="🎨", color=Color3.fromRGB(220,180,140)},
    Texture         = {icon="🖌", color=Color3.fromRGB(220,180,140)},
    SelectionBox    = {icon="🔲", color=Color3.fromRGB(0,162,255)},
    SurfaceAppearance={icon="🌐",color=Color3.fromRGB(140,200,180)},
    -- Services
    Workspace       = {icon="🌍", color=Color3.fromRGB(100,200,100)},
    ReplicatedStorage={icon="📦",color=Color3.fromRGB(200,180,100)},
    ReplicatedFirst = {icon="⚡", color=Color3.fromRGB(255,200,50)},
    StarterGui      = {icon="🖥", color=Color3.fromRGB(180,120,220)},
    StarterPack     = {icon="🎒", color=Color3.fromRGB(200,150,80)},
    StarterPlayer   = {icon="👤", color=Color3.fromRGB(200,200,255)},
    Lighting        = {icon="💡", color=Color3.fromRGB(255,240,100)},
    Player          = {icon="👤", color=Color3.fromRGB(100,200,255)},
}

local function getClassInfo(obj)
    local info = CLASS_INFO[obj.ClassName]
    if info then return info.icon, info.color end
    if obj:IsA("BasePart") then return "🟦", Color3.fromRGB(100,160,255) end
    if obj:IsA("Model")    then return "📁", Color3.fromRGB(220,170,80) end
    if obj:IsA("GuiObject") then return "🔲", Color3.fromRGB(180,100,200) end
    if obj:IsA("Script")   then return "📜", Color3.fromRGB(100,220,100) end
    if obj:IsA("Light")    then return "💡", Color3.fromRGB(255,240,100) end
    return "📄", Color3.fromRGB(160,160,160)
end

local function getIcon(obj)
    local icon, _ = getClassInfo(obj)
    return icon
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
        local icon, classColor = getClassInfo(obj)

        local row = Instance.new("TextButton", explorerScroll)
        row.Size = UDim2.new(1,0,0,20)
        row.BackgroundColor3 = isSelected and T.sel or Color3.fromRGB(38,38,38)
        row.BackgroundTransparency = isSelected and 0 or 0
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = false

        local pad = Instance.new("UIPadding", row)
        pad.PaddingLeft = UDim.new(0, 4 + depth*14)

        -- Color accent bar on left
        local accent = Instance.new("Frame", row)
        accent.Size = UDim2.new(0, 2, 1, 0)
        accent.BackgroundColor3 = classColor
        accent.BorderSizePixel = 0
        accent.BackgroundTransparency = isSelected and 0 or 0.5

        -- Arrow toggle
        if hasChildren then
            local arrowBtn = Instance.new("TextButton", row)
            arrowBtn.Size = UDim2.new(0,16,1,0)
            arrowBtn.Position = UDim2.new(0,2,0,0)
            arrowBtn.BackgroundTransparency = 1
            arrowBtn.Text = isExpanded and "▾" or "▸"
            arrowBtn.TextColor3 = T.dimText
            arrowBtn.Font = Enum.Font.GothamBold
            arrowBtn.TextSize = 11
            arrowBtn.BorderSizePixel = 0
            arrowBtn.ZIndex = row.ZIndex + 1
            arrowBtn.MouseButton1Click:Connect(function()
                expanded[obj] = not expanded[obj]
                task.defer(refreshExplorer)
            end)
        end

        -- Icon label
        local iconLbl = Instance.new("TextLabel", row)
        iconLbl.Size = UDim2.new(0,18,1,0)
        iconLbl.Position = UDim2.new(0,18,0,0)
        iconLbl.BackgroundTransparency = 1
        iconLbl.Text = icon
        iconLbl.TextSize = 12
        iconLbl.Font = Enum.Font.Code
        iconLbl.TextColor3 = classColor
        iconLbl.TextXAlignment = Enum.TextXAlignment.Left

        -- Name label
        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size = UDim2.new(1,-40,1,0)
        nameLabel.Position = UDim2.new(0,36,0,0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = obj.Name
        nameLabel.Font = Enum.Font.Code
        nameLabel.TextSize = 11
        nameLabel.TextColor3 = isSelected and Color3.new(1,1,1) or T.text
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd

        -- Bottom divider
        local div = Instance.new("Frame", row)
        div.Size = UDim2.new(1,0,0,1)
        div.Position = UDim2.new(0,0,1,-1)
        div.BackgroundColor3 = Color3.fromRGB(50,50,50)
        div.BorderSizePixel = 0
        div.BackgroundTransparency = 0.7

        -- Single click = select, Double click = rename
        local lastClickTime2 = 0
        row.MouseButton1Click:Connect(function()
            local now = tick()
            if now - lastClickTime2 < 0.35 then
                -- Double click → rename
                task.spawn(function() openRenamePopup(obj) end)
            else
                selectObject(obj)
            end
            lastClickTime2 = now
        end)

        -- Long press (tahan) → set sebagai insert target + buka insert menu
        local longPressTimer = nil
        row.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                longPressTimer = task.delay(0.6, function()
                    if obj:IsA("Model") or obj:IsA("Folder")
                    or obj:IsA("BasePart") or obj == workspace then
                        selectObject(obj)
                        row.BackgroundColor3 = T.accent
                        task.wait(0.15)
                        row.BackgroundColor3 = T.sel
                        statusLbl.Text = "📂 Insert into: " .. obj.Name
                        insertMenu.Visible = true
                        insertMenu.Position = UDim2.new(0, explorerW, 0, 64)
                    end
                end)
            end
        end)
        row.InputEnded:Connect(function(inp)
            if longPressTimer then
                task.cancel(longPressTimer)
                longPressTimer = nil
            end
        end)

        row.MouseEnter:Connect(function()
            if obj ~= selectedObj then row.BackgroundColor3 = Color3.fromRGB(55,55,55) end
        end)
        row.MouseLeave:Connect(function()
            if obj ~= selectedObj then row.BackgroundColor3 = Color3.fromRGB(38,38,38) end
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
-- PROPERTIES (Roblox Studio style dengan kategori)
----------------------------------------------------
function refreshProperties()
    for _, c in ipairs(propsScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end

    if not selectedObj then
        local row = Instance.new("Frame", propsScroll)
        row.Size = UDim2.new(1,0,0,40)
        row.BackgroundTransparency = 1
        row.BorderSizePixel = 0
        mkLabel(row,"  No selection.",UDim2.new(1,0,1,0),nil,11,T.dimText)
        return
    end

    -- Class header
    local hRow = Instance.new("Frame", propsScroll)
    hRow.Size = UDim2.new(1,0,0,36)
    hRow.BackgroundColor3 = Color3.fromRGB(55,55,60)
    hRow.BackgroundTransparency = 0
    hRow.BorderSizePixel = 0

    local hIcon, hColor = getClassInfo(selectedObj)
    local iconLbl = Instance.new("TextLabel", hRow)
    iconLbl.Size = UDim2.new(0,22,1,0)
    iconLbl.Position = UDim2.new(0,4,0,0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = hIcon
    iconLbl.TextSize = 16
    iconLbl.Font = Enum.Font.Code
    iconLbl.TextColor3 = hColor
    local classLbl = Instance.new("TextLabel", hRow)
    classLbl.Size = UDim2.new(1,-30,0,18)
    classLbl.Position = UDim2.new(0,28,0,2)
    classLbl.BackgroundTransparency = 1
    classLbl.Text = selectedObj.ClassName
    classLbl.Font = Enum.Font.GothamBold
    classLbl.TextSize = 12
    classLbl.TextColor3 = hColor
    classLbl.TextXAlignment = Enum.TextXAlignment.Left
    local nameLbl2 = Instance.new("TextLabel", hRow)
    nameLbl2.Size = UDim2.new(1,-30,0,14)
    nameLbl2.Position = UDim2.new(0,28,0,20)
    nameLbl2.BackgroundTransparency = 1
    nameLbl2.Text = selectedObj.Name
    nameLbl2.Font = Enum.Font.Code
    nameLbl2.TextSize = 10
    nameLbl2.TextColor3 = T.dimText
    nameLbl2.TextXAlignment = Enum.TextXAlignment.Left

    -- Column headers
    local colHeader = Instance.new("Frame", propsScroll)
    colHeader.Size = UDim2.new(1,0,0,18)
    colHeader.BackgroundColor3 = Color3.fromRGB(35,35,35)
    colHeader.BackgroundTransparency = 0
    colHeader.BorderSizePixel = 0
    local colProp = Instance.new("TextLabel", colHeader)
    colProp.Size = UDim2.new(0.46,0,1,0)
    colProp.Position = UDim2.new(0,6,0,0)
    colProp.BackgroundTransparency = 1
    colProp.Text = "Property"
    colProp.Font = Enum.Font.GothamBold
    colProp.TextSize = 9
    colProp.TextColor3 = Color3.fromRGB(130,130,130)
    colProp.TextXAlignment = Enum.TextXAlignment.Left
    local colVal = Instance.new("TextLabel", colHeader)
    colVal.Size = UDim2.new(0.54,0,1,0)
    colVal.Position = UDim2.new(0.46,4,0,0)
    colVal.BackgroundTransparency = 1
    colVal.Text = "Value"
    colVal.Font = Enum.Font.GothamBold
    colVal.TextSize = 9
    colVal.TextColor3 = Color3.fromRGB(130,130,130)
    colVal.TextXAlignment = Enum.TextXAlignment.Left

    -- Category header
    local function addCatHeader(label, bgColor)
        local cat = Instance.new("Frame", propsScroll)
        cat.Size = UDim2.new(1,0,0,18)
        cat.BackgroundColor3 = bgColor or Color3.fromRGB(50,50,50)
        cat.BackgroundTransparency = 0
        cat.BorderSizePixel = 0
        local lbl = Instance.new("TextLabel", cat)
        lbl.Size = UDim2.new(1,-8,1,0)
        lbl.Position = UDim2.new(0,8,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextColor3 = Color3.fromRGB(200,200,200)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
    end

    local rowAlt = false
    local function addPropRow(propName, override, readOnly)
        local ok, val = pcall(function()
            if override ~= nil then return override end
            return selectedObj[propName]
        end)
        if not ok then return end
        rowAlt = not rowAlt
        local row = Instance.new("Frame", propsScroll)
        row.Size = UDim2.new(1,0,0,22)
        row.BackgroundColor3 = rowAlt and Color3.fromRGB(42,42,42) or Color3.fromRGB(38,38,38)
        row.BackgroundTransparency = 0
        row.BorderSizePixel = 0

        local nLbl = Instance.new("TextLabel", row)
        nLbl.Size = UDim2.new(0.46,-1,1,0)
        nLbl.Position = UDim2.new(0,4,0,0)
        nLbl.BackgroundTransparency = 1
        nLbl.Text = propName
        nLbl.Font = Enum.Font.Code
        nLbl.TextSize = 11
        nLbl.TextColor3 = Color3.fromRGB(180,180,180)
        nLbl.TextXAlignment = Enum.TextXAlignment.Left
        nLbl.TextTruncate = Enum.TextTruncate.AtEnd

        local mid = Instance.new("Frame", row)
        mid.Size = UDim2.new(0,1,0.7,0)
        mid.Position = UDim2.new(0.46,0,0.15,0)
        mid.BackgroundColor3 = Color3.fromRGB(70,70,70)
        mid.BorderSizePixel = 0

        local vt = typeof(val)
        if readOnly then
            local l = Instance.new("TextLabel", row)
            l.Size = UDim2.new(0.54,-4,1,0)
            l.Position = UDim2.new(0.46,4,0,0)
            l.BackgroundTransparency = 1
            l.Text = tostring(val):sub(1,28)
            l.Font = Enum.Font.Code
            l.TextSize = 11
            l.TextColor3 = T.dimText
            l.TextXAlignment = Enum.TextXAlignment.Left
            return
        end

        if vt == "boolean" then
            local check = Instance.new("TextButton", row)
            check.Size = UDim2.new(0,14,0,14)
            check.Position = UDim2.new(0.46,6,0.5,-7)
            check.BackgroundColor3 = val and Color3.fromRGB(0,120,215) or Color3.fromRGB(50,50,50)
            check.Text = val and "✓" or ""
            check.TextColor3 = Color3.new(1,1,1)
            check.Font = Enum.Font.GothamBold
            check.TextSize = 9
            check.BorderSizePixel = 0
            mkCorner(3,check)
            local vl = Instance.new("TextLabel", row)
            vl.Size = UDim2.new(0.35,0,1,0)
            vl.Position = UDim2.new(0.46,24,0,0)
            vl.BackgroundTransparency = 1
            vl.Text = tostring(val)
            vl.Font = Enum.Font.Code
            vl.TextSize = 11
            vl.TextColor3 = val and Color3.fromRGB(100,220,100) or T.dimText
            vl.TextXAlignment = Enum.TextXAlignment.Left
            check.MouseButton1Click:Connect(function()
                pcall(function() selectedObj[propName]=not selectedObj[propName] refreshProperties() end)
            end)
        elseif vt == "number" then
            local inp = Instance.new("TextBox", row)
            inp.Size = UDim2.new(0.54,-4,0,18)
            inp.Position = UDim2.new(0.46,2,0.5,-9)
            inp.BackgroundColor3 = Color3.fromRGB(30,30,30)
            inp.Text = tostring(math.floor(val*100)/100)
            inp.TextColor3 = Color3.fromRGB(200,230,255)
            inp.Font = Enum.Font.Code
            inp.TextSize = 11
            inp.BorderSizePixel = 0
            inp.ClearTextOnFocus = false
            mkCorner(2,inp)
            inp.FocusLost:Connect(function()
                local n = tonumber(inp.Text)
                if n then pcall(function() selectedObj[propName]=n end) updateHandles() end
            end)
        elseif vt == "string" then
            local inp = Instance.new("TextBox", row)
            inp.Size = UDim2.new(0.54,-4,0,18)
            inp.Position = UDim2.new(0.46,2,0.5,-9)
            inp.BackgroundColor3 = Color3.fromRGB(30,30,30)
            inp.Text = val:sub(1,50)
            inp.TextColor3 = Color3.fromRGB(255,220,150)
            inp.Font = Enum.Font.Code
            inp.TextSize = 11
            inp.BorderSizePixel = 0
            inp.ClearTextOnFocus = false
            mkCorner(2,inp)
            inp.FocusLost:Connect(function()
                pcall(function() selectedObj[propName]=inp.Text end)
                task.defer(refreshExplorer)
            end)
        elseif vt == "Vector3" then
            local axes = {"X","Y","Z"}
            local vals3 = {val.X,val.Y,val.Z}
            local inps = {}
            for i,ax in ipairs(axes) do
                local al = Instance.new("TextLabel",row)
                al.Size=UDim2.new(0,10,0,18) al.Position=UDim2.new(0.46,2+(i-1)*58,0.5,-9)
                al.BackgroundTransparency=1 al.Text=ax al.Font=Enum.Font.GothamBold al.TextSize=9
                al.TextColor3=i==1 and T.handle_x or(i==2 and T.handle_y or T.handle_z)
                al.TextXAlignment=Enum.TextXAlignment.Center
                local inp=Instance.new("TextBox",row)
                inp.Size=UDim2.new(0,42,0,18) inp.Position=UDim2.new(0.46,12+(i-1)*58,0.5,-9)
                inp.BackgroundColor3=Color3.fromRGB(30,30,30) inp.Text=tostring(math.floor(vals3[i]*10)/10)
                inp.TextColor3=i==1 and T.handle_x or(i==2 and T.handle_y or T.handle_z)
                inp.Font=Enum.Font.Code inp.TextSize=10 inp.BorderSizePixel=0 inp.ClearTextOnFocus=false
                mkCorner(2,inp) table.insert(inps,inp)
            end
            local function applyV3()
                local x,y,z=tonumber(inps[1].Text),tonumber(inps[2].Text),tonumber(inps[3].Text)
                if x and y and z then pcall(function() selectedObj[propName]=Vector3.new(x,y,z) end) updateHandles() end
            end
            for _,inp in ipairs(inps) do inp.FocusLost:Connect(applyV3) end
        elseif vt == "Color3" then
            local sw = Instance.new("TextButton",row)
            sw.Size=UDim2.new(0,34,0,16) sw.Position=UDim2.new(0.46,4,0.5,-8)
            sw.BackgroundColor3=val sw.Text="" sw.BorderSizePixel=0
            mkCorner(3,sw) mkStroke(Color3.fromRGB(80,80,80),1,sw)
            local rl=Instance.new("TextLabel",row)
            rl.Size=UDim2.new(0.3,0,1,0) rl.Position=UDim2.new(0.46,42,0,0)
            rl.BackgroundTransparency=1
            rl.Text=string.format("%d,%d,%d",math.round(val.R*255),math.round(val.G*255),math.round(val.B*255))
            rl.Font=Enum.Font.Code rl.TextSize=10 rl.TextColor3=T.dimText rl.TextXAlignment=Enum.TextXAlignment.Left
            sw.MouseButton1Click:Connect(function()
                local h,s,v2=Color3.toHSV(val) currentH,currentS,currentV=h,s,v2
                updateColorUI() colorPicker.Visible=true
            end)
        elseif vt == "BrickColor" then
            local l=Instance.new("TextLabel",row)
            l.Size=UDim2.new(0.54,-4,1,0) l.Position=UDim2.new(0.46,4,0,0)
            l.BackgroundTransparency=1 l.Text=tostring(val)
            l.Font=Enum.Font.Code l.TextSize=11 l.TextColor3=Color3.fromRGB(255,180,100) l.TextXAlignment=Enum.TextXAlignment.Left
        elseif vt == "EnumItem" then
            local l=Instance.new("TextLabel",row)
            l.Size=UDim2.new(0.54,-4,1,0) l.Position=UDim2.new(0.46,4,0,0)
            l.BackgroundTransparency=1 l.Text=tostring(val):gsub("Enum%.%w+%.","")
            l.Font=Enum.Font.Code l.TextSize=11 l.TextColor3=Color3.fromRGB(150,255,150) l.TextXAlignment=Enum.TextXAlignment.Left
        elseif vt == "CFrame" then
            local l=Instance.new("TextLabel",row)
            l.Size=UDim2.new(0.54,-4,1,0) l.Position=UDim2.new(0.46,4,0,0)
            l.BackgroundTransparency=1 l.Text=string.format("%.1f, %.1f, %.1f",val.X,val.Y,val.Z)
            l.Font=Enum.Font.Code l.TextSize=11 l.TextColor3=Color3.fromRGB(255,200,100) l.TextXAlignment=Enum.TextXAlignment.Left
        else
            local l=Instance.new("TextLabel",row)
            l.Size=UDim2.new(0.54,-4,1,0) l.Position=UDim2.new(0.46,4,0,0)
            l.BackgroundTransparency=1 l.Text=tostring(val):sub(1,26)
            l.Font=Enum.Font.Code l.TextSize=11 l.TextColor3=T.dimText l.TextXAlignment=Enum.TextXAlignment.Left
        end
    end

    -- DATA
    addCatHeader("▸ Data", Color3.fromRGB(45,45,55))
    addPropRow("Name")
    pcall(function() addPropRow("ClassName", selectedObj.ClassName, true) end)
    pcall(function() addPropRow("Parent", selectedObj.Parent and selectedObj.Parent.Name or "nil", true) end)

    -- BEHAVIOR
    if selectedObj:IsA("BasePart") or selectedObj:IsA("Script") or selectedObj:IsA("LocalScript") or selectedObj:IsA("GuiObject") then
        addCatHeader("▸ Behavior", Color3.fromRGB(45,55,45))
        if selectedObj:IsA("BasePart") then
            addPropRow("Anchored") addPropRow("CanCollide") addPropRow("CastShadow") addPropRow("Locked")
        end
        if selectedObj:IsA("Script") or selectedObj:IsA("LocalScript") then addPropRow("Disabled") end
        if selectedObj:IsA("GuiObject") then addPropRow("Visible") addPropRow("Active") end
    end

    -- APPEARANCE
    addCatHeader("▸ Appearance", Color3.fromRGB(55,45,45))
    if selectedObj:IsA("BasePart") then
        addPropRow("Color") addPropRow("BrickColor") addPropRow("Material")
        addPropRow("Transparency") addPropRow("Reflectance")
    end
    if selectedObj:IsA("GuiObject") then
        addPropRow("BackgroundColor3") addPropRow("BackgroundTransparency") addPropRow("ZIndex")
    end
    if selectedObj:IsA("TextLabel") or selectedObj:IsA("TextButton") or selectedObj:IsA("TextBox") then
        addPropRow("Text") addPropRow("TextColor3") addPropRow("TextSize") addPropRow("Font")
    end
    if selectedObj:IsA("ImageLabel") or selectedObj:IsA("ImageButton") then
        addPropRow("Image") addPropRow("ImageColor3") addPropRow("ImageTransparency")
    end
    if selectedObj:IsA("ScreenGui") then
        addPropRow("Enabled") addPropRow("ResetOnSpawn") addPropRow("DisplayOrder")
    end

    -- TRANSFORM
    if selectedObj:IsA("BasePart") then
        addCatHeader("▸ Transform", Color3.fromRGB(45,45,65))
        addPropRow("Size") addPropRow("Position") addPropRow("Rotation") addPropRow("CFrame")
    end
    if selectedObj:IsA("GuiObject") then
        addCatHeader("▸ Transform", Color3.fromRGB(45,45,65))
        addPropRow("Size") addPropRow("Position") addPropRow("Rotation")
    end

    -- SURFACE
    if selectedObj:IsA("BasePart") then
        addCatHeader("▸ Surface", Color3.fromRGB(55,50,40))
        addPropRow("TopSurface") addPropRow("BottomSurface")
        addPropRow("FrontSurface") addPropRow("BackSurface")
        addPropRow("LeftSurface") addPropRow("RightSurface")
    end

    -- SOUND / LIGHT / PARTICLE
    if selectedObj:IsA("Sound") then
        addCatHeader("▸ Sound", Color3.fromRGB(40,55,55))
        addPropRow("SoundId") addPropRow("Volume") addPropRow("Looped")
        addPropRow("Playing") addPropRow("RollOffMaxDistance")
    end
    if selectedObj:IsA("Light") then
        addCatHeader("▸ Light", Color3.fromRGB(55,55,35))
        addPropRow("Brightness") addPropRow("Color") addPropRow("Range") addPropRow("Enabled")
    end
    if selectedObj:IsA("ParticleEmitter") then
        addCatHeader("▸ Particle", Color3.fromRGB(55,45,55))
        addPropRow("Rate") addPropRow("Lifetime") addPropRow("Speed")
        addPropRow("Rotation") addPropRow("RotSpeed") addPropRow("Enabled")
    end

    -- ACTIONS
    local spacer = Instance.new("Frame", propsScroll)
    spacer.Size=UDim2.new(1,0,0,4) spacer.BackgroundTransparency=1 spacer.BorderSizePixel=0

    local actRow = Instance.new("Frame", propsScroll)
    actRow.Size=UDim2.new(1,0,0,28) actRow.BackgroundTransparency=1 actRow.BorderSizePixel=0

    local delBtn = mkBtn(actRow,"🗑 Delete",UDim2.new(0.5,-3,0,26),UDim2.new(0,2,0,1),T.red,Color3.new(1,1,1))
    delBtn.BackgroundTransparency=0
    delBtn.MouseButton1Click:Connect(function()
        clearHandles()
        pcall(function() selectedObj:Destroy() end)
        selectedObj=nil refreshProperties() task.defer(refreshExplorer)
    end)

    if selectedObj and selectedObj:IsA("BasePart") then
        local dupBtn=mkBtn(actRow,"⎘ Dup",UDim2.new(0.5,-3,0,26),UDim2.new(0.5,1,0,1),T.sel,Color3.new(1,1,1))
        dupBtn.BackgroundTransparency=0
        dupBtn.MouseButton1Click:Connect(function()
            pcall(function()
                local clone=selectedObj:Clone()
                clone.CFrame=clone.CFrame+Vector3.new(4,0,0)
                clone.Parent=selectedObj.Parent
                table.insert(spawnedObjs,clone)
                selectObject(clone) task.defer(refreshExplorer)
            end)
        end)
    end

    -- CoderScript untuk Script/LocalScript/ModuleScript
    if selectedObj and (selectedObj:IsA("BaseScript") or selectedObj:IsA("ModuleScript")) then
        local codeRow = Instance.new("Frame", propsScroll)
        codeRow.Size=UDim2.new(1,0,0,28) codeRow.BackgroundTransparency=1 codeRow.BorderSizePixel=0

        local codeBtn = mkBtn(codeRow,"📝 Insert Inside (CoderScript)",
            UDim2.new(1,-4,0,26),UDim2.new(0,2,0,1),T.accent,Color3.new(1,1,1))
        codeBtn.BackgroundTransparency=0
        codeBtn.MouseButton1Click:Connect(function()
            -- Buka CoderScript editor
            local cSg = Instance.new("ScreenGui")
            cSg.Name = "SkyMoon_CoderScript"
            cSg.ResetOnSpawn = false
            cSg.IgnoreGuiInset = true
            cSg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            pcall(function() cSg.Parent = game:GetService("CoreGui") end)
            if not cSg.Parent then cSg.Parent = LocalPlayer.PlayerGui end

            local win = Instance.new("Frame", cSg)
            win.Size = UDim2.new(0.8, 0, 0.8, 0)
            win.Position = UDim2.new(0.1, 0, 0.1, 0)
            win.BackgroundColor3 = Color3.fromRGB(18,18,24)
            win.BorderSizePixel = 0
            win.Active = true
            win.Draggable = true
            win.ZIndex = 100
            mkCorner(8, win)
            mkStroke(T.accent, 1.5, win)

            -- Title
            local tbar = Instance.new("Frame", win)
            tbar.Size = UDim2.new(1,0,0,32)
            tbar.BackgroundColor3 = Color3.fromRGB(12,12,20)
            tbar.BorderSizePixel = 0
            tbar.ZIndex = 101
            mkCorner(8, tbar)
            local tfix = Instance.new("Frame", tbar)
            tfix.Size = UDim2.new(1,0,0.5,0)
            tfix.Position = UDim2.new(0,0,0.5,0)
            tfix.BackgroundColor3 = Color3.fromRGB(12,12,20)
            tfix.BorderSizePixel = 0
            local tlbl = Instance.new("TextLabel", tbar)
            tlbl.Size = UDim2.new(1,-80,1,0)
            tlbl.Position = UDim2.new(0,10,0,0)
            tlbl.BackgroundTransparency = 1
            tlbl.Text = "📝 CoderScript — " .. selectedObj.Name
            tlbl.Font = Enum.Font.GothamBold
            tlbl.TextSize = 12
            tlbl.TextColor3 = T.accent
            tlbl.TextXAlignment = Enum.TextXAlignment.Left
            tlbl.ZIndex = 102

            -- Close
            local closeC = mkBtn(tbar,"✕",UDim2.new(0,24,0,22),UDim2.new(1,-28,0,5),T.red,Color3.new(1,1,1))
            closeC.BackgroundTransparency=0 closeC.ZIndex=102
            closeC.MouseButton1Click:Connect(function() cSg:Destroy() end)

            -- Run button
            local runBtn = mkBtn(tbar,"▶ Run",UDim2.new(0,54,0,22),UDim2.new(1,-86,0,5),T.green,Color3.new(0,0,0))
            runBtn.BackgroundTransparency=0 runBtn.ZIndex=102

            -- Code editor
            local editorBg = Instance.new("Frame", win)
            editorBg.Size = UDim2.new(1,-8,0.75,-36)
            editorBg.Position = UDim2.new(0,4,0,36)
            editorBg.BackgroundColor3 = Color3.fromRGB(14,14,20)
            editorBg.BorderSizePixel=0 editorBg.ZIndex=101
            mkCorner(4, editorBg)

            local lineNumsBg = Instance.new("Frame", editorBg)
            lineNumsBg.Size = UDim2.new(0,32,1,0)
            lineNumsBg.BackgroundColor3 = Color3.fromRGB(20,20,28)
            lineNumsBg.BorderSizePixel=0 lineNumsBg.ZIndex=102

            local codeBox = Instance.new("TextBox", editorBg)
            codeBox.Size = UDim2.new(1,-36,1,-4)
            codeBox.Position = UDim2.new(0,34,0,2)
            codeBox.BackgroundTransparency = 1
            codeBox.Text = "-- Write your script here\nprint('Hello from CoderScript!')"
            codeBox.TextColor3 = Color3.fromRGB(200,220,255)
            codeBox.Font = Enum.Font.Code
            codeBox.TextSize = 13
            codeBox.TextXAlignment = Enum.TextXAlignment.Left
            codeBox.TextYAlignment = Enum.TextYAlignment.Top
            codeBox.MultiLine = true
            codeBox.TextWrapped = false
            codeBox.ClearTextOnFocus = false
            codeBox.ZIndex = 103

            -- Output panel
            local outputBg = Instance.new("Frame", win)
            outputBg.Size = UDim2.new(1,-8,0.25,-4)
            outputBg.Position = UDim2.new(0,4,0.75,0)
            outputBg.BackgroundColor3 = Color3.fromRGB(10,10,16)
            outputBg.BorderSizePixel=0 outputBg.ZIndex=101
            mkCorner(4, outputBg)
            mkLabel(outputBg,"Output:",UDim2.new(1,0,0,16),UDim2.new(0,4,0,0),10,T.dimText)

            local outputScroll = Instance.new("ScrollingFrame", outputBg)
            outputScroll.Size = UDim2.new(1,-4,1,-18)
            outputScroll.Position = UDim2.new(0,2,0,18)
            outputScroll.BackgroundTransparency=1 outputScroll.BorderSizePixel=0
            outputScroll.ScrollBarThickness=3 outputScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
            outputScroll.CanvasSize=UDim2.new(0,0,0,0) outputScroll.ZIndex=102

            local outputLbl = Instance.new("TextLabel", outputScroll)
            outputLbl.Size = UDim2.new(1,-4,0,0)
            outputLbl.AutomaticSize = Enum.AutomaticSize.Y
            outputLbl.BackgroundTransparency=1
            outputLbl.Text="" outputLbl.Font=Enum.Font.Code
            outputLbl.TextSize=11 outputLbl.TextColor3=T.text
            outputLbl.TextXAlignment=Enum.TextXAlignment.Left
            outputLbl.TextYAlignment=Enum.TextYAlignment.Top
            outputLbl.TextWrapped=true outputLbl.RichText=true outputLbl.ZIndex=103

            outputLbl:GetPropertyChangedSignal("Text"):Connect(function()
                task.defer(function()
                    outputScroll.CanvasPosition=Vector2.new(0,outputScroll.AbsoluteCanvasSize.Y)
                end)
            end)

            -- Run button logic
            runBtn.MouseButton1Click:Connect(function()
                local code = codeBox.Text
                outputLbl.Text = ""
                -- Hook print
                local oldPrint = print
                local outputs = {}
                local env = setmetatable({
                    print = function(...)
                        local parts = {}
                        for _, v in ipairs({...}) do table.insert(parts, tostring(v)) end
                        local msg = table.concat(parts, "\t")
                        table.insert(outputs, '<font color="#aaffaa">'..msg:gsub("&","and"):gsub("<","["):gsub(">","]")..'</font>')
                        outputLbl.Text = table.concat(outputs, "\n")
                    end,
                    warn = function(...)
                        local parts = {}
                        for _, v in ipairs({...}) do table.insert(parts, tostring(v)) end
                        local msg = table.concat(parts, "\t")
                        table.insert(outputs, '<font color="#ffcc44">⚠ '..msg:gsub("&","and"):gsub("<","["):gsub(">","]")..'</font>')
                        outputLbl.Text = table.concat(outputs, "\n")
                    end,
                    game = game, workspace = workspace, script = selectedObj,
                    task = task, Vector3 = Vector3, CFrame = CFrame,
                    Instance = Instance, Color3 = Color3, math = math,
                    string = string, table = table, pcall = pcall,
                }, {__index = _G})

                local fn, err = loadstring(code)
                if not fn then
                    outputLbl.Text = '<font color="#ff5555">❌ Parse Error: '..tostring(err):gsub("&","and"):gsub("<","["):gsub(">","]")..'</font>'
                    return
                end
                setfenv(fn, env)
                local ok, runErr = pcall(fn)
                if not ok then
                    table.insert(outputs, '<font color="#ff5555">❌ Error: '..tostring(runErr):gsub("&","and"):gsub("<","["):gsub(">","]")..'</font>')
                    outputLbl.Text = table.concat(outputs, "\n")
                elseif #outputs == 0 then
                    outputLbl.Text = '<font color="#555577">-- No output --</font>'
                end
            end)
        end)
    end
end



----------------------------------------------------
-- RAYCAST SELECTION + HANDLE HOLDING
----------------------------------------------------
local holdingHandle = nil    -- handle yang sedang dipegang
local holdingAxis   = nil    -- "X","Y","Z" dari handle yang dipegang
local holdingType   = nil    -- "move" atau "scale"

local function trySelectFromRaycast(screenPos)
    if rmhHeld then return end
    if holdingHandle then return end -- sedang pegang handle, jangan select

    local cam = workspace.CurrentCamera
    local ok, ray = pcall(function() return cam:ScreenPointToRay(screenPos.X, screenPos.Y) end)
    if not ok then return end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = {}
    for _, h in ipairs(handleParts) do table.insert(exclude, h) end
    pcall(function()
        local char = LocalPlayer.Character
        if char then table.insert(exclude, char) end
    end)
    params.FilterDescendantsInstances = exclude

    local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    if result and result.Instance then
        local obj = result.Instance
        if obj.Name == "_SkyMoonHandle" or obj.Name == "_SkyMoonArrow" then return end
        selectObject(obj)
        statusLbl.Text = "Selected: " .. obj.Name .. " [" .. obj.ClassName .. "]"
    end
end

-- Cek apakah screenPos kena handle, return handle part atau nil
local function getHandleAtScreen(screenPos)
    local cam = workspace.CurrentCamera
    local ok, ray = pcall(function() return cam:ScreenPointToRay(screenPos.X, screenPos.Y) end)
    if not ok then return nil, nil end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = handleParts

    local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
    if result and result.Instance then
        return result.Instance, result.Instance.Color
    end
    return nil, nil
end

-- Axes dari warna handle
local function getAxisFromColor(color)
    if color == T.handle_x then return "X"
    elseif color == T.handle_y then return "Y"
    elseif color == T.handle_z then return "Z"
    else return nil end
end

----------------------------------------------------
-- DRAG - hanya bergerak kalau pegang handle
----------------------------------------------------
local isDragging    = false
local lastInputPos  = nil
local dragStarted   = false
local clickStartPos = nil
local CLICK_THRESH  = 8

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    local isMouse1  = inp.UserInputType == Enum.UserInputType.MouseButton1
    local isTouch   = inp.UserInputType == Enum.UserInputType.Touch

    if isMouse1 or isTouch then
        -- Cek apakah kena handle dulu
        local handle, col = getHandleAtScreen(inp.Position)
        if handle then
            -- Pegang handle → neon
            holdingHandle = handle
            holdingAxis   = getAxisFromColor(col)
            holdingType   = (currentTool == "Scale") and "scale" or "move"
            pcall(function()
                handle.Material = Enum.Material.Neon
                handle.Color = Color3.new(1,1,1)
            end)
        end

        isDragging  = true
        dragStarted = false
        lastInputPos  = inp.Position
        clickStartPos = inp.Position
    end
end)

UIS.InputEnded:Connect(function(inp)
    local isMouse1 = inp.UserInputType == Enum.UserInputType.MouseButton1
    local isTouch  = inp.UserInputType == Enum.UserInputType.Touch

    if isMouse1 or isTouch then
        -- Lepas handle → smooth plastik
        if holdingHandle then
            pcall(function()
                holdingHandle.Material = Enum.Material.SmoothPlastic
                holdingHandle.Color = holdingHandle.Color -- keep color
            end)
            holdingHandle = nil
            holdingAxis   = nil
            holdingType   = nil
        end

        -- Kalau tidak drag → raycast select
        if not dragStarted and clickStartPos then
            trySelectFromRaycast(clickStartPos)
        end

        isDragging  = false
        dragStarted = false
        lastInputPos  = nil
        clickStartPos = nil

        if selectedObj and selectedObj:IsA("BasePart") then
            updateHandles()
            refreshProperties()
        end
    end
end)

UIS.InputChanged:Connect(function(inp)
    if not isDragging then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement
    and inp.UserInputType ~= Enum.UserInputType.Touch then return end
    if not lastInputPos then return end

    local delta = inp.Position - lastInputPos
    lastInputPos = inp.Position

    -- Cek drag threshold
    if not dragStarted then
        if clickStartPos and (inp.Position - clickStartPos).Magnitude < CLICK_THRESH then return end
        dragStarted = true
    end

    -- Hanya gerakkan kalau pegang handle DAN ada selectedObj
    if not holdingHandle then return end
    if not selectedObj or not selectedObj:IsA("BasePart") then return end

    pcall(function()
        local cam = workspace.CurrentCamera
        local sensitivity = 0.15

        -- Tentukan arah berdasarkan axis handle
        local worldDelta = Vector3.new(0,0,0)
        if holdingAxis == "X" then
            worldDelta = cam.CFrame.RightVector * delta.X * sensitivity
        elseif holdingAxis == "Y" then
            worldDelta = cam.CFrame.UpVector * (-delta.Y) * sensitivity
        elseif holdingAxis == "Z" then
            worldDelta = cam.CFrame.LookVector * (-delta.Y) * sensitivity
        else
            -- Handle corner (select tool) - gerak bebas
            worldDelta = cam.CFrame.RightVector * delta.X * sensitivity
                       + cam.CFrame.UpVector * (-delta.Y) * sensitivity
        end

        if holdingType == "move" then
            selectedObj.CFrame = selectedObj.CFrame + worldDelta
        elseif holdingType == "scale" then
            local s = selectedObj.Size
            local mag = worldDelta.Magnitude * (delta.X + delta.Y > 0 and 1 or -1)
            if holdingAxis == "X" then
                selectedObj.Size = Vector3.new(math.max(0.2, s.X + mag), s.Y, s.Z)
            elseif holdingAxis == "Y" then
                selectedObj.Size = Vector3.new(s.X, math.max(0.2, s.Y + mag), s.Z)
            elseif holdingAxis == "Z" then
                selectedObj.Size = Vector3.new(s.X, s.Y, math.max(0.2, s.Z + mag))
            end
        elseif currentTool == "Rotate" then
            selectedObj.CFrame = selectedObj.CFrame
                * CFrame.Angles(0, math.rad(delta.X * 0.6), 0)
        end
        updateHandles()
    end)
end)

----------------------------------------------------
-- KEYBOARD SHORTCUTS (Move/Scale/Rotate dengan arrows)
-- Move:   Arrow keys + PageUp/Down
-- Scale:  Numpad 8/2 (Y), Numpad 4/6 (X), Numpad 7/9 (Z)
-- Rotate: Numpad 1/3
----------------------------------------------------
local KEY_STEP = 1   -- stud per press
local KEY_ROT  = 15  -- degrees per press
local KEY_SCL  = 0.5 -- studs scale per press

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if not selectedObj or not selectedObj:IsA("BasePart") then return end

    local k = inp.KeyCode
    pcall(function()
        if currentTool == "Move" then
            if k == Enum.KeyCode.Right    then selectedObj.CFrame = selectedObj.CFrame + Vector3.new(KEY_STEP,0,0) end
            if k == Enum.KeyCode.Left     then selectedObj.CFrame = selectedObj.CFrame - Vector3.new(KEY_STEP,0,0) end
            if k == Enum.KeyCode.PageUp   then selectedObj.CFrame = selectedObj.CFrame + Vector3.new(0,KEY_STEP,0) end
            if k == Enum.KeyCode.PageDown then selectedObj.CFrame = selectedObj.CFrame - Vector3.new(0,KEY_STEP,0) end
            if k == Enum.KeyCode.Up       then selectedObj.CFrame = selectedObj.CFrame - Vector3.new(0,0,KEY_STEP) end
            if k == Enum.KeyCode.Down     then selectedObj.CFrame = selectedObj.CFrame + Vector3.new(0,0,KEY_STEP) end
        elseif currentTool == "Scale" then
            -- Numpad: 8=Y+, 2=Y-, 4=X-, 6=X+, 7=Z-, 9=Z+
            local s = selectedObj.Size
            if k == Enum.KeyCode.KeypadEight then selectedObj.Size = Vector3.new(s.X,math.max(0.2,s.Y+KEY_SCL),s.Z) end
            if k == Enum.KeyCode.KeypadTwo   then selectedObj.Size = Vector3.new(s.X,math.max(0.2,s.Y-KEY_SCL),s.Z) end
            if k == Enum.KeyCode.KeypadFour  then selectedObj.Size = Vector3.new(math.max(0.2,s.X-KEY_SCL),s.Y,s.Z) end
            if k == Enum.KeyCode.KeypadSix   then selectedObj.Size = Vector3.new(math.max(0.2,s.X+KEY_SCL),s.Y,s.Z) end
            if k == Enum.KeyCode.KeypadSeven then selectedObj.Size = Vector3.new(s.X,s.Y,math.max(0.2,s.Z-KEY_SCL)) end
            if k == Enum.KeyCode.KeypadNine  then selectedObj.Size = Vector3.new(s.X,s.Y,math.max(0.2,s.Z+KEY_SCL)) end
        elseif currentTool == "Rotate" then
            if k == Enum.KeyCode.KeypadOne   then selectedObj.CFrame = selectedObj.CFrame * CFrame.Angles(0,math.rad(-KEY_ROT),0) end
            if k == Enum.KeyCode.KeypadThree then selectedObj.CFrame = selectedObj.CFrame * CFrame.Angles(0,math.rad( KEY_ROT),0) end
            if k == Enum.KeyCode.KeypadFive  then selectedObj.CFrame = selectedObj.CFrame * CFrame.Angles(math.rad(KEY_ROT),0,0) end
        end
        updateHandles()
        refreshProperties()
    end)
end)

----------------------------------------------------
-- MOBILE CONTROLS (D-pad UI untuk move/scale/rotate)
----------------------------------------------------
local mobileCtrl = Instance.new("Frame", sg)
mobileCtrl.Size = UDim2.new(0, 180, 0, 160)
mobileCtrl.Position = UDim2.new(1, -190, 1, -170)
mobileCtrl.BackgroundColor3 = Color3.fromRGB(20,20,20)
mobileCtrl.BackgroundTransparency = 0.3
mobileCtrl.BorderSizePixel = 0
mobileCtrl.ZIndex = 15
mkCorner(10, mobileCtrl)
mkStroke(T.border, 1, mobileCtrl)

mkLabel(mobileCtrl,"Move/Scale/Rotate",UDim2.new(1,0,0,16),UDim2.new(0,0,0,2),9,T.dimText,Enum.TextXAlignment.Center)

-- D-pad layout: ↑↓←→ + PageUp/Down
local DPAD = {
    {label="↑",  pos=UDim2.new(0.5,-20,0,18),  axis="Z-"},
    {label="↓",  pos=UDim2.new(0.5,-20,0,72),  axis="Z+"},
    {label="←",  pos=UDim2.new(0,-2,0,45),      axis="X-"},
    {label="→",  pos=UDim2.new(1,-40,0,45),     axis="X+"},
    {label="▲",  pos=UDim2.new(0.5,-50,0,45),   axis="Y+"},
    {label="▼",  pos=UDim2.new(0.5,10,0,45),    axis="Y-"},
}

for _, d in ipairs(DPAD) do
    local b = mkBtn(mobileCtrl, d.label, UDim2.new(0,36,0,24), d.pos, T.dark, T.text)
    b.BackgroundTransparency = 0
    b.ZIndex = 16
    b.MouseButton1Click:Connect(function()
        if not selectedObj or not selectedObj:IsA("BasePart") then return end
        pcall(function()
            local step = KEY_STEP
            if currentTool == "Scale" then step = KEY_SCL end
            if d.axis == "X+" then
                if currentTool=="Move" then selectedObj.CFrame=selectedObj.CFrame+Vector3.new(step,0,0)
                elseif currentTool=="Scale" then local s=selectedObj.Size selectedObj.Size=Vector3.new(s.X+step,s.Y,s.Z) end
            elseif d.axis == "X-" then
                if currentTool=="Move" then selectedObj.CFrame=selectedObj.CFrame-Vector3.new(step,0,0)
                elseif currentTool=="Scale" then local s=selectedObj.Size selectedObj.Size=Vector3.new(math.max(0.2,s.X-step),s.Y,s.Z) end
            elseif d.axis == "Y+" then
                if currentTool=="Move" then selectedObj.CFrame=selectedObj.CFrame+Vector3.new(0,step,0)
                elseif currentTool=="Scale" then local s=selectedObj.Size selectedObj.Size=Vector3.new(s.X,s.Y+step,s.Z) end
            elseif d.axis == "Y-" then
                if currentTool=="Move" then selectedObj.CFrame=selectedObj.CFrame-Vector3.new(0,step,0)
                elseif currentTool=="Scale" then local s=selectedObj.Size selectedObj.Size=Vector3.new(s.X,math.max(0.2,s.Y-step),s.Z) end
            elseif d.axis == "Z+" then
                if currentTool=="Move" then selectedObj.CFrame=selectedObj.CFrame+Vector3.new(0,0,step)
                elseif currentTool=="Scale" then local s=selectedObj.Size selectedObj.Size=Vector3.new(s.X,s.Y,s.Z+step) end
            elseif d.axis == "Z-" then
                if currentTool=="Move" then selectedObj.CFrame=selectedObj.CFrame-Vector3.new(0,0,step)
                elseif currentTool=="Scale" then local s=selectedObj.Size selectedObj.Size=Vector3.new(s.X,s.Y,math.max(0.2,s.Z-step)) end
            end
            updateHandles()
            refreshProperties()
        end)
    end)
end

-- Rotate buttons
local rotLeft = mkBtn(mobileCtrl,"↺",UDim2.new(0,36,0,24),UDim2.new(0,2,1,-28),T.dark,T.handle_z)
rotLeft.BackgroundTransparency=0 rotLeft.ZIndex=16
rotLeft.MouseButton1Click:Connect(function()
    if selectedObj and selectedObj:IsA("BasePart") then
        pcall(function() selectedObj.CFrame=selectedObj.CFrame*CFrame.Angles(0,math.rad(-KEY_ROT),0) end)
        updateHandles() refreshProperties()
    end
end)
local rotRight = mkBtn(mobileCtrl,"↻",UDim2.new(0,36,0,24),UDim2.new(1,-38,1,-28),T.dark,T.handle_z)
rotRight.BackgroundTransparency=0 rotRight.ZIndex=16
rotRight.MouseButton1Click:Connect(function()
    if selectedObj and selectedObj:IsA("BasePart") then
        pcall(function() selectedObj.CFrame=selectedObj.CFrame*CFrame.Angles(0,math.rad(KEY_ROT),0) end)
        updateHandles() refreshProperties()
    end
end)

-- Step size label
local stepLbl = mkLabel(mobileCtrl,"Step: "..KEY_STEP,UDim2.new(1,0,0,14),UDim2.new(0,0,1,-14),9,T.dimText,Enum.TextXAlignment.Center)

----------------------------------------------------
-- CLOSE
----------------------------------------------------
closeBtn.MouseButton1Click:Connect(function()
    clearHandles()
    stopFreeCam()
    sg:Destroy()
end)

----------------------------------------------------
-- PHYSICS FREEZE (semua part anchored di builder mode)
-- Baru unanchor saat Play
----------------------------------------------------
local frozenParts = {} -- {part, wasAnchored}

local function freezePhysics()
    frozenParts = {}
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "_SkyMoonHandle" and obj.Name ~= "_SkyMoonArrow" then
                table.insert(frozenParts, {part=obj, was=obj.Anchored})
                obj.Anchored = true
            end
        end
    end)
end

local function unfreezePhysics()
    for _, info in ipairs(frozenParts) do
        pcall(function() info.part.Anchored = info.was end)
    end
    frozenParts = {}
end

-- Override Play/Stop buttons untuk handle physics
local origPlayClick = nil
playBtn.MouseButton1Click:Connect(function()
    if playMode then return end
    playMode = true
    playBtn.BackgroundColor3 = Color3.fromRGB(20,80,20)
    statusLbl.Text = "▶ Play — physics ON!"
    clearHandles()
    unfreezePhysics() -- baru unanchor sekarang
    stopFreeCam()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = savedCharCF or CFrame.new(0,5,0)
            char.HumanoidRootPart.Anchored = false
        end
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
            char.Humanoid.JumpPower = 50
            char.Humanoid.AutoRotate = true
        end
    end)
end)

stopBtn.MouseButton1Click:Connect(function()
    if not playMode then return end
    playMode = false
    playBtn.BackgroundColor3 = T.green
    statusLbl.Text = "■ Stopped — physics OFF"
    freezePhysics() -- anchor lagi
    startFreeCam()
    updateHandles()
end)

----------------------------------------------------
-- DISABLE VOID (jangan matikan karakter)
----------------------------------------------------
local voidConn = RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y < -200 then
            hrp.CFrame = savedCharCF or CFrame.new(0, charYBase, 0)
        end
    end)
end)

----------------------------------------------------
-- FORCE SCRIPTABLE CAMERA (jangan ikuti player)
----------------------------------------------------
local camForceConn = RunService.RenderStepped:Connect(function()
    if freeCamActive then
        local cam = workspace.CurrentCamera
        if cam.CameraType ~= Enum.CameraType.Scriptable then
            cam.CameraType = Enum.CameraType.Scriptable
        end
    end
end)

----------------------------------------------------
-- CUT / PASTE SYSTEM
----------------------------------------------------
local clipboard = nil -- {obj, originalParent}

-- Tambah Cut/Paste ke toolbar
local cutBtn = mkBtn(toolbarFrame,"✂ Cut",UDim2.new(0,56,0,26),nil,T.dark,T.text)
cutBtn.ZIndex = 16
cutBtn.MouseButton1Click:Connect(function()
    if not selectedObj then return end
    clipboard = {obj=selectedObj, originalParent=selectedObj.Parent}
    -- Visual: ubah warna jadi orange tanda akan dipindah
    pcall(function()
        if selectedObj:IsA("BasePart") then
            selectedObj.BrickColor = BrickColor.new("Bright orange")
        end
    end)
    statusLbl.Text = "✂ Cut: " .. selectedObj.Name .. " — select target then Paste"
end)

local pasteBtn = mkBtn(toolbarFrame,"📋 Paste",UDim2.new(0,66,0,26),nil,T.dark,T.text)
pasteBtn.ZIndex = 16
pasteBtn.MouseButton1Click:Connect(function()
    if not clipboard then
        statusLbl.Text = "Nothing to paste!"
        return
    end
    local targetParent = selectedObj or workspace
    -- Kalau target bukan valid parent
    if not (targetParent:IsA("Model") or targetParent:IsA("Folder") or targetParent:IsA("BasePart") or targetParent == workspace) then
        targetParent = targetParent.Parent or workspace
    end
    pcall(function()
        clipboard.obj.Parent = targetParent
        statusLbl.Text = "📋 Pasted: " .. clipboard.obj.Name .. " → " .. targetParent.Name
        selectObject(clipboard.obj)
        clipboard = nil
        task.defer(refreshExplorer)
    end)
end)

----------------------------------------------------
-- DOUBLE-CLICK RENAME in Explorer
-- (di addNode row sudah ada single click = select,
--  double click → popup rename)
----------------------------------------------------
-- Ini dihandle via flag di addNode - lihat refreshExplorer
-- Tambah rename popup function
local function openRenamePopup(obj)
    local rSg = Instance.new("ScreenGui")
    rSg.Name = "SkyMoon_Rename"
    rSg.ResetOnSpawn = false
    rSg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() rSg.Parent = game:GetService("CoreGui") end)
    if not rSg.Parent then rSg.Parent = LocalPlayer.PlayerGui end

    local win = Instance.new("Frame", rSg)
    win.Size = UDim2.new(0,280,0,80)
    win.Position = UDim2.new(0.5,-140,0.5,-40)
    win.BackgroundColor3 = Color3.fromRGB(22,22,30)
    win.BorderSizePixel=0 win.Active=true win.Draggable=true win.ZIndex=200
    mkCorner(8,win) mkStroke(T.accent,1.5,win)

    mkLabel(win,"✏️ Rename: "..obj.ClassName,UDim2.new(1,-10,0,20),UDim2.new(0,8,0,4),11,T.dimText)

    local inp = Instance.new("TextBox", win)
    inp.Size = UDim2.new(1,-16,0,28)
    inp.Position = UDim2.new(0,8,0,26)
    inp.BackgroundColor3 = Color3.fromRGB(30,30,40)
    inp.Text = obj.Name
    inp.TextColor3 = T.text
    inp.Font = Enum.Font.GothamBold
    inp.TextSize = 13
    inp.BorderSizePixel=0 inp.ClearTextOnFocus=false inp.ZIndex=201
    mkCorner(4,inp)

    inp.FocusLost:Connect(function(enter)
        if enter and inp.Text ~= "" then
            pcall(function() obj.Name = inp.Text end)
            statusLbl.Text = "Renamed to: " .. inp.Text
            task.defer(refreshExplorer)
            refreshProperties()
        end
        rSg:Destroy()
    end)

    task.defer(function() inp:CaptureFocus() end)
end

-- Patch refreshExplorer untuk double-click rename
-- Ini sudah di-handle di addNode dengan lastClickTime

----------------------------------------------------
-- INIT
----------------------------------------------------
freezePhysics() -- anchor semua part saat builder dibuka
startFreeCam()  -- mulai freecam
refreshExplorer()
refreshProperties()

task.spawn(function()
    while sg.Parent do
        task.wait(4)
        if not playMode then pcall(refreshExplorer) end
    end
end)

RunService.Heartbeat:Connect(function()
    if selectedObj and selectedObj:IsA("BasePart") and not isDragging then
        if selBox then pcall(function() selBox.Adornee = selectedObj end) end
    end
end)

statusLbl.Text = "🌙 Real Builder v2 | Click=select | RMB+drag=look | WASD=move | ✂Cut 📋Paste"
