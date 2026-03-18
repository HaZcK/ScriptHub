-- 🌙 SkyMoon Real Builder v3
-- by KHAFIDZKTP | github.com/HaZcK/ScriptHub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- CoreGui
local sg = Instance.new("ScreenGui")
sg.Name = "SkyMoon_RealBuilder"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() sg.Parent = game:GetService("CoreGui") end)
if not sg.Parent then sg.Parent = LP.PlayerGui end

-- Theme
local T = {
    bg=Color3.fromRGB(30,30,36), panel=Color3.fromRGB(38,38,46),
    dark=Color3.fromRGB(22,22,28), accent=Color3.fromRGB(0,162,255),
    text=Color3.fromRGB(220,220,220), dim=Color3.fromRGB(130,130,140),
    sel=Color3.fromRGB(0,100,215), border=Color3.fromRGB(55,55,65),
    green=Color3.fromRGB(50,180,60), red=Color3.fromRGB(200,50,50),
    hx=Color3.fromRGB(220,60,60), hy=Color3.fromRGB(60,200,70), hz=Color3.fromRGB(60,110,220),
}

-- State
local selectedObj, selBox = nil, nil
local currentTool = "Select"
local playMode, freeCamActive = false, false
local freeCamConn, noClipConn, rmhConn = nil, nil, nil
local camYaw, camPitch = 0, -20
local rmhHeld = false
local touchCamDelta = Vector2.new(0,0)
local joystickDir = Vector2.new(0,0)
local joystickSpeed = 1.0
local savedCharCF = nil
local charYBase = -15
local lastCamPos = Vector3.new(0,20,30)
local expanded = {}
local spawnedObjs = {}
local clipboard = nil
local frozenParts = {}
local handleParts = {}
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local joyActive, joyTouchId, camTouchId = false, nil, nil
local joyCenter = Vector2.new(0,0)
local JOY_RADIUS = 60
local holdingHandle, holdingAxis, holdingType = nil, nil, nil
local isDragging, dragStarted = false, false
local lastInputPos, clickStartPos = nil, nil
local KEY_STEP, KEY_ROT, KEY_SCL = 1, 15, 0.5
local CLICK_THRESH = 8

-- Helpers
local function mkCorner(r,p) local c=Instance.new("UICorner",p) c.CornerRadius=UDim.new(0,r) end
local function mkStroke(col,t,p) local s=Instance.new("UIStroke",p) s.Color=col s.Thickness=t end
local function mkLabel(parent,text,size,pos,fs,col,xa)
    local l=Instance.new("TextLabel",parent)
    l.Size=size l.Position=pos or UDim2.new(0,0,0,0)
    l.BackgroundTransparency=1 l.Text=text l.Font=Enum.Font.Code
    l.TextSize=fs or 11 l.TextColor3=col or T.text
    l.TextXAlignment=xa or Enum.TextXAlignment.Left l.TextWrapped=true
    return l
end
local function mkBtn(parent,text,size,pos,bg,tc)
    local b=Instance.new("TextButton",parent)
    b.Size=size b.Position=pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3=bg or T.dark b.Text=text b.TextColor3=tc or T.text
    b.Font=Enum.Font.GothamBold b.TextSize=11 b.BorderSizePixel=0
    b.AutoButtonColor=false
    mkCorner(4,b)
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=T.sel}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=bg or T.dark}):Play() end)
    return b
end
local function mkInput(parent,size,pos,ph,def)
    local b=Instance.new("TextBox",parent)
    b.Size=size b.Position=pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3=T.dark b.Text=def or "" b.PlaceholderText=ph or ""
    b.PlaceholderColor3=T.dim b.TextColor3=T.text b.Font=Enum.Font.Code
    b.TextSize=11 b.BorderSizePixel=0 b.ClearTextOnFocus=false
    mkCorner(3,b)
    return b
end

-- Layout
local topbar = Instance.new("Frame",sg)
topbar.Size=UDim2.new(1,0,0,32) topbar.BackgroundColor3=T.dark topbar.BorderSizePixel=0 topbar.ZIndex=20
mkLabel(topbar,"🌙  SkyMoon Real Builder v3",UDim2.new(0,260,1,0),UDim2.new(0,10,0,0),13,T.accent)

-- Explorer panel (resizable)
local explorerW = 210
local explorerPanel = Instance.new("Frame",sg)
explorerPanel.Size=UDim2.new(0,explorerW,1,-72) explorerPanel.Position=UDim2.new(0,0,0,32)
explorerPanel.BackgroundColor3=T.dark explorerPanel.BorderSizePixel=0
mkStroke(T.border,1,explorerPanel)

local exHeader = Instance.new("Frame",explorerPanel)
exHeader.Size=UDim2.new(1,0,0,22) exHeader.BackgroundColor3=T.bg exHeader.BorderSizePixel=0
mkLabel(exHeader,"  Explorer",UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),11,T.dim)

local exScroll = Instance.new("ScrollingFrame",explorerPanel)
exScroll.Size=UDim2.new(1,0,1,-22) exScroll.Position=UDim2.new(0,0,0,22)
exScroll.BackgroundTransparency=1 exScroll.BorderSizePixel=0
exScroll.ScrollBarThickness=3 exScroll.ScrollBarImageColor3=T.accent
exScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y exScroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UIListLayout",exScroll).Padding=UDim.new(0,0)

-- Properties panel
local propsW = 210
local propsPanel = Instance.new("Frame",sg)
propsPanel.Size=UDim2.new(0,propsW,1,-72) propsPanel.Position=UDim2.new(1,-propsW,0,32)
propsPanel.BackgroundColor3=T.dark propsPanel.BorderSizePixel=0
mkStroke(T.border,1,propsPanel)

local prHeader = Instance.new("Frame",propsPanel)
prHeader.Size=UDim2.new(1,0,0,22) prHeader.BackgroundColor3=T.bg prHeader.BorderSizePixel=0
mkLabel(prHeader,"  Properties",UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),11,T.dim)

local prScroll = Instance.new("ScrollingFrame",propsPanel)
prScroll.Size=UDim2.new(1,0,1,-22) prScroll.Position=UDim2.new(0,0,0,22)
prScroll.BackgroundTransparency=1 prScroll.BorderSizePixel=0
prScroll.ScrollBarThickness=3 prScroll.ScrollBarImageColor3=T.accent
prScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y prScroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UIListLayout",prScroll).Padding=UDim.new(0,0)

-- Toolbar
local toolbar = Instance.new("Frame",sg)
toolbar.Size=UDim2.new(1,-(explorerW+propsW),0,32) toolbar.Position=UDim2.new(0,explorerW,0,32)
toolbar.BackgroundColor3=T.bg toolbar.BorderSizePixel=0 toolbar.ZIndex=15
local tbLayout=Instance.new("UIListLayout",toolbar)
tbLayout.FillDirection=Enum.FillDirection.Horizontal tbLayout.Padding=UDim.new(0,3)
Instance.new("UIPadding",toolbar).PaddingLeft=UDim.new(0,4)
Instance.new("UIPadding",toolbar).PaddingTop=UDim.new(0,4)

-- Bottom
local bottomBar = Instance.new("Frame",sg)
bottomBar.Size=UDim2.new(1,0,0,40) bottomBar.Position=UDim2.new(0,0,1,-40)
bottomBar.BackgroundColor3=T.dark bottomBar.BorderSizePixel=0 bottomBar.ZIndex=20
mkStroke(T.border,1,bottomBar)

local statusLbl = mkLabel(bottomBar,"🌙 Loading...",UDim2.new(0.5,0,1,0),UDim2.new(0,10,0,0),10,T.dim)

local playBtn = mkBtn(bottomBar,"▶ Play",UDim2.new(0,80,0,28),UDim2.new(0.5,-92,0,6),T.green,Color3.new(0,0,0))
local stopBtn = mkBtn(bottomBar,"■ Stop",UDim2.new(0,80,0,28),UDim2.new(0.5,12,0,6),T.red,Color3.new(1,1,1))
local closeBtn = mkBtn(bottomBar,"✕",UDim2.new(0,50,0,28),UDim2.new(1,-56,0,6),T.dark,T.dim)

-- Tool buttons
local toolBtns = {}
local TOOLS = {{"🔲 Select","Select"},{"✢ Move","Move"},{"⊡ Scale","Scale"},{"↻ Rotate","Rotate"}}
for _,t in ipairs(TOOLS) do
    local b = mkBtn(toolbar,t[1],UDim2.new(0,76,0,24))
    b.ZIndex=16
    b.MouseButton1Click:Connect(function()
        currentTool=t[2]
        for _,tb in ipairs(toolBtns) do tb.BackgroundColor3=T.dark end
        b.BackgroundColor3=T.sel
    end)
    table.insert(toolBtns,b)
end
toolBtns[1].BackgroundColor3=T.sel

local insertBtn = mkBtn(toolbar,"⊕ Insert",UDim2.new(0,70,0,24),nil,T.accent,Color3.new(1,1,1))
insertBtn.ZIndex=16
local cutBtn = mkBtn(toolbar,"✂ Cut",UDim2.new(0,50,0,24),nil,T.dark,T.text)
cutBtn.ZIndex=16
local pasteBtn = mkBtn(toolbar,"📋",UDim2.new(0,34,0,24),nil,T.dark,T.text)
pasteBtn.ZIndex=16
local colorBtn = mkBtn(toolbar,"🎨",UDim2.new(0,30,0,24),nil,T.dark,T.text)
colorBtn.ZIndex=16

-- Selection handles
local function clearHandles()
    for _,h in ipairs(handleParts) do pcall(function() h:Destroy() end) end
    handleParts={}
    if selBox then pcall(function() selBox:Destroy() end) selBox=nil end
end

local function makeHandle(pos,col,name)
    local h=Instance.new("Part")
    h.Name=name or "_SkyMoonHandle"
    h.Size=Vector3.new(0.5,0.5,0.5) h.Shape=Enum.PartType.Ball
    h.Color=col h.Material=Enum.Material.SmoothPlastic
    h.Anchored=true h.CanCollide=false h.CastShadow=false
    h.CFrame=CFrame.new(pos) h.Parent=workspace
    table.insert(handleParts,h)
    return h
end

local function makeArrow(cf,col)
    local h=Instance.new("Part")
    h.Name="_SkyMoonHandle"
    h.Size=Vector3.new(0.25,1.4,0.25)
    h.Color=col h.Material=Enum.Material.SmoothPlastic
    h.Anchored=true h.CanCollide=false h.CastShadow=false
    h.CFrame=cf h.Parent=workspace
    table.insert(handleParts,h)
    return h
end

local function updateHandles()
    clearHandles()
    if not selectedObj or not selectedObj:IsA("BasePart") then return end
    local cf = selectedObj.CFrame
    local s = selectedObj.Size/2
    selBox = Instance.new("SelectionBox")
    selBox.Adornee=selectedObj selBox.Color3=T.accent
    selBox.LineThickness=0.06 selBox.SurfaceTransparency=0.85
    selBox.SurfaceColor3=T.accent selBox.Parent=workspace
    if currentTool=="Move" then
        makeArrow(cf*CFrame.new(s.X+1.2,0,0)*CFrame.Angles(0,0,-math.pi/2),T.hx)
        makeArrow(cf*CFrame.new(-s.X-1.2,0,0)*CFrame.Angles(0,0,math.pi/2),T.hx)
        makeArrow(cf*CFrame.new(0,s.Y+1.2,0),T.hy)
        makeArrow(cf*CFrame.new(0,-s.Y-1.2,0)*CFrame.Angles(math.pi,0,0),T.hy)
        makeArrow(cf*CFrame.new(0,0,s.Z+1.2)*CFrame.Angles(math.pi/2,0,0),T.hz)
        makeArrow(cf*CFrame.new(0,0,-s.Z-1.2)*CFrame.Angles(-math.pi/2,0,0),T.hz)
    elseif currentTool=="Scale" then
        makeHandle((cf*CFrame.new(s.X+0.9,0,0)).Position,T.hx)
        makeHandle((cf*CFrame.new(-s.X-0.9,0,0)).Position,T.hx)
        makeHandle((cf*CFrame.new(0,s.Y+0.9,0)).Position,T.hy)
        makeHandle((cf*CFrame.new(0,-s.Y-0.9,0)).Position,T.hy)
        makeHandle((cf*CFrame.new(0,0,s.Z+0.9)).Position,T.hz)
        makeHandle((cf*CFrame.new(0,0,-s.Z-0.9)).Position,T.hz)
    else
        for _,xs in ipairs({s.X,-s.X}) do
            for _,ys in ipairs({s.Y,-s.Y}) do
                for _,zs in ipairs({s.Z,-s.Z}) do
                    makeHandle((cf*CFrame.new(xs,ys,zs)).Position,T.accent)
                end
            end
        end
    end
end

-- forward declare
local refreshExplorer, refreshProperties, openRenamePopup, selectObject

-- Select
selectObject = function(obj)
    selectedObj=obj
    updateHandles()
    refreshProperties()
    task.defer(refreshExplorer)
end

-- Physics freeze
local function freezePhysics()
    frozenParts={}
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name~="_SkyMoonHandle" then
                table.insert(frozenParts,{part=obj,was=obj.Anchored})
                obj.Anchored=true
            end
        end
    end)
end

local function unfreezePhysics()
    for _,info in ipairs(frozenParts) do
        pcall(function() info.part.Anchored=info.was end)
    end
    frozenParts={}
end

-- getCharY
local function getCharY(camPos)
    local closest=math.huge
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name~="_SkyMoonHandle" then
                local d=(obj.Position-camPos).Magnitude
                if d<closest then closest=d end
            end
        end
    end)
    if closest<=5 then return -22
    elseif closest<=15 then return -18
    else return charYBase end
end

-- FreeCam
local function startFreeCam()
    if freeCamActive then return end
    freeCamActive=true
    -- Disable Roblox controls
    pcall(function()
        local PM=require(LP.PlayerScripts:WaitForChild("PlayerModule"))
        PM:GetControls():Disable()
    end)
    pcall(function()
        local cg=game:GetService("CoreGui"):FindFirstChild("ControlGui")
        if cg then cg.Enabled=false end
    end)
    pcall(function()
        local char=LP.Character
        if char then
            local hrp=char:FindFirstChild("HumanoidRootPart")
            if hrp then
                savedCharCF=hrp.CFrame
                hrp.Anchored=true
                hrp.CFrame=CFrame.new(0,charYBase,0)
            end
            local h=char:FindFirstChild("Humanoid")
            if h then h.WalkSpeed=0 h.JumpPower=0 h.AutoRotate=false end
        end
    end)
    noClipConn=RunService.Stepped:Connect(function()
        pcall(function()
            for _,p in ipairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end)
    end)
    local cam=workspace.CurrentCamera
    cam.CameraType=Enum.CameraType.Scriptable
    camYaw=180 camPitch=-20
    lastCamPos=Vector3.new(0,20,30)
    cam.CFrame=CFrame.new(lastCamPos)*CFrame.Angles(0,math.rad(camYaw),0)*CFrame.Angles(math.rad(camPitch),0,0)
    local rmbDown=UIS.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton2 then
            rmhHeld=true UIS.MouseBehavior=Enum.MouseBehavior.LockCurrentPosition
        end
    end)
    local rmbUp=UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton2 then
            rmhHeld=false UIS.MouseBehavior=Enum.MouseBehavior.Default
        end
    end)
    freeCamConn=RunService.RenderStepped:Connect(function(dt)
        -- Mouse rotation
        if rmhHeld then
            local d=UIS:GetMouseDelta()
            camYaw=camYaw-d.X*0.3
            camPitch=math.clamp(camPitch-d.Y*0.3,-89,89)
        end
        -- Touch swipe rotation
        if touchCamDelta.Magnitude>0 then
            camYaw=camYaw-touchCamDelta.X*0.25
            camPitch=math.clamp(camPitch-touchCamDelta.Y*0.25,-89,89)
            touchCamDelta=Vector2.new(0,0)
        end
        local rotCF=CFrame.new(cam.CFrame.Position)*CFrame.Angles(0,math.rad(camYaw),0)*CFrame.Angles(math.rad(camPitch),0,0)
        local vel=Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then vel=vel+rotCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then vel=vel-rotCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then vel=vel-rotCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then vel=vel+rotCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.E) then vel=vel+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then vel=vel-Vector3.new(0,1,0) end
        if joystickDir.Magnitude>0.05 then
            vel=vel+rotCF.LookVector*(-joystickDir.Y)+rotCF.RightVector*joystickDir.X
        end
        local spd=UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 160 or (40*joystickSpeed)
        local newPos=cam.CFrame.Position+vel*spd*dt
        cam.CFrame=CFrame.new(newPos)*CFrame.Angles(0,math.rad(camYaw),0)*CFrame.Angles(math.rad(camPitch),0,0)
        -- Invisible man
        local camVel=(newPos-lastCamPos).Magnitude/math.max(dt,0.001)
        lastCamPos=newPos
        local targetY=getCharY(newPos)
        pcall(function()
            local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local tp=Vector3.new(newPos.X,targetY,newPos.Z)
                if camVel>60 then hrp.CFrame=CFrame.new(tp)
                else hrp.CFrame=CFrame.new(hrp.Position:Lerp(tp,math.clamp(dt*8,0,1))) end
            end
        end)
        -- Force scriptable camera
        if cam.CameraType~=Enum.CameraType.Scriptable then
            cam.CameraType=Enum.CameraType.Scriptable
        end
    end)
    rmhConn={rmbDown,rmbUp}
    statusLbl.Text=isMobile and "FreeCam | WASD=move | Swipe=look" or "FreeCam | RMB+drag=look | WASD/QE=move | Shift=fast"
end

local function stopFreeCam()
    if not freeCamActive then return end
    freeCamActive=false rmhHeld=false
    UIS.MouseBehavior=Enum.MouseBehavior.Default
    if freeCamConn then freeCamConn:Disconnect() freeCamConn=nil end
    if noClipConn then noClipConn:Disconnect() noClipConn=nil end
    if rmhConn then for _,c in ipairs(rmhConn) do pcall(function() c:Disconnect() end) end rmhConn=nil end
    workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
    pcall(function()
        local PM=require(LP.PlayerScripts:WaitForChild("PlayerModule"))
        PM:GetControls():Enable()
    end)
    pcall(function()
        local cg=game:GetService("CoreGui"):FindFirstChild("ControlGui")
        if cg then cg.Enabled=true end
    end)
    pcall(function()
        local char=LP.Character
        if char then
            local hrp=char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored=false hrp.CFrame=savedCharCF or CFrame.new(0,5,0) end
            local h=char:FindFirstChild("Humanoid")
            if h then h.WalkSpeed=16 h.JumpPower=50 h.AutoRotate=true end
        end
    end)
end

-- Play/Stop
playBtn.MouseButton1Click:Connect(function()
    if playMode then return end
    playMode=true
    playBtn.BackgroundColor3=Color3.fromRGB(20,80,20)
    statusLbl.Text="▶ Play — physics ON!"
    clearHandles()
    unfreezePhysics()
    stopFreeCam()
end)

stopBtn.MouseButton1Click:Connect(function()
    if not playMode then return end
    playMode=false
    playBtn.BackgroundColor3=T.green
    statusLbl.Text="■ Stopped — builder mode"
    freezePhysics()
    startFreeCam()
    updateHandles()
end)

closeBtn.MouseButton1Click:Connect(function()
    clearHandles()
    stopFreeCam()
    sg:Destroy()
end)

-- Void disable
RunService.Heartbeat:Connect(function()
    pcall(function()
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y<-200 then
            hrp.CFrame=savedCharCF or CFrame.new(0,charYBase,0)
        end
    end)
end)

-- Class icons & colors
local CLASS_INFO={
    Part={i="🟦",c=Color3.fromRGB(100,160,255)}, WedgePart={i="🔺",c=Color3.fromRGB(100,160,255)},
    CornerWedgePart={i="🔷",c=Color3.fromRGB(100,160,255)}, MeshPart={i="🌐",c=Color3.fromRGB(120,180,255)},
    Model={i="📁",c=Color3.fromRGB(220,170,80)}, Folder={i="📂",c=Color3.fromRGB(200,200,100)},
    Script={i="📜",c=Color3.fromRGB(100,220,100)}, LocalScript={i="📄",c=Color3.fromRGB(80,200,80)},
    ModuleScript={i="📦",c=Color3.fromRGB(60,180,140)},
    ScreenGui={i="🖼",c=Color3.fromRGB(200,120,220)}, Frame={i="▭",c=Color3.fromRGB(180,100,200)},
    TextLabel={i="🔤",c=Color3.fromRGB(180,100,200)}, TextButton={i="🔘",c=Color3.fromRGB(160,80,200)},
    TextBox={i="✏️",c=Color3.fromRGB(160,80,200)}, ImageLabel={i="🖼",c=Color3.fromRGB(200,100,180)},
    PointLight={i="💡",c=Color3.fromRGB(255,240,100)}, SpotLight={i="🔦",c=Color3.fromRGB(255,220,80)},
    ParticleEmitter={i="✨",c=Color3.fromRGB(255,180,80)}, Fire={i="🔥",c=Color3.fromRGB(255,120,60)},
    Smoke={i="💨",c=Color3.fromRGB(180,180,180)}, Sparkles={i="⚡",c=Color3.fromRGB(255,255,100)},
    Sound={i="🎵",c=Color3.fromRGB(100,255,180)},
    RemoteEvent={i="📡",c=Color3.fromRGB(255,150,100)}, RemoteFunction={i="📡",c=Color3.fromRGB(255,150,100)},
    WeldConstraint={i="🔒",c=Color3.fromRGB(150,150,200)}, HingeConstraint={i="🔧",c=Color3.fromRGB(150,150,200)},
    Attachment={i="💫",c=Color3.fromRGB(180,200,255)}, Camera={i="📷",c=Color3.fromRGB(180,220,255)},
    Workspace={i="🌍",c=Color3.fromRGB(100,200,100)}, ReplicatedStorage={i="📦",c=Color3.fromRGB(200,180,100)},
    StarterGui={i="🖥",c=Color3.fromRGB(180,120,220)}, Lighting={i="💡",c=Color3.fromRGB(255,240,100)},
    Player={i="👤",c=Color3.fromRGB(100,200,255)}, Humanoid={i="🤖",c=Color3.fromRGB(255,200,200)},
}
local function getCI(obj)
    local info=CLASS_INFO[obj.ClassName]
    if info then return info.i, info.c end
    if obj:IsA("BasePart") then return "🟦",Color3.fromRGB(100,160,255) end
    if obj:IsA("Model") then return "📁",Color3.fromRGB(220,170,80) end
    if obj:IsA("GuiObject") then return "🔲",Color3.fromRGB(180,100,200) end
    return "📄",Color3.fromRGB(160,160,160)
end

-- Rename popup
openRenamePopup = function(obj)
    local rSg=Instance.new("ScreenGui")
    rSg.Name="SkyMoon_Rename" rSg.ResetOnSpawn=false rSg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    pcall(function() rSg.Parent=game:GetService("CoreGui") end)
    if not rSg.Parent then rSg.Parent=LP.PlayerGui end
    local win=Instance.new("Frame",rSg)
    win.Size=UDim2.new(0,280,0,80) win.Position=UDim2.new(0.5,-140,0.5,-40)
    win.BackgroundColor3=Color3.fromRGB(22,22,30) win.BorderSizePixel=0
    win.Active=true win.Draggable=true win.ZIndex=200
    mkCorner(8,win) mkStroke(T.accent,1.5,win)
    mkLabel(win,"✏️ Rename",UDim2.new(1,0,0,20),UDim2.new(0,8,0,4),11,T.dim)
    local inp=Instance.new("TextBox",win)
    inp.Size=UDim2.new(1,-16,0,28) inp.Position=UDim2.new(0,8,0,26)
    inp.BackgroundColor3=Color3.fromRGB(30,30,40) inp.Text=obj.Name
    inp.TextColor3=T.text inp.Font=Enum.Font.GothamBold inp.TextSize=13
    inp.BorderSizePixel=0 inp.ClearTextOnFocus=false inp.ZIndex=201
    mkCorner(4,inp)
    inp.FocusLost:Connect(function(enter)
        if enter and inp.Text~="" then
            pcall(function() obj.Name=inp.Text end)
            task.defer(refreshExplorer) refreshProperties()
        end
        rSg:Destroy()
    end)
    task.defer(function() inp:CaptureFocus() end)
end

-- CoderScript
local function openCoderScript(obj)
    local cSg=Instance.new("ScreenGui")
    cSg.Name="SkyMoon_CoderScript" cSg.ResetOnSpawn=false cSg.IgnoreGuiInset=true
    cSg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    pcall(function() cSg.Parent=game:GetService("CoreGui") end)
    if not cSg.Parent then cSg.Parent=LP.PlayerGui end
    local win=Instance.new("Frame",cSg)
    win.Size=UDim2.new(0.8,0,0.8,0) win.Position=UDim2.new(0.1,0,0.1,0)
    win.BackgroundColor3=Color3.fromRGB(14,14,20) win.BorderSizePixel=0
    win.Active=true win.Draggable=true win.ZIndex=100
    mkCorner(8,win) mkStroke(T.accent,1.5,win)
    local tbar=Instance.new("Frame",win)
    tbar.Size=UDim2.new(1,0,0,30) tbar.BackgroundColor3=Color3.fromRGB(10,10,16)
    tbar.BorderSizePixel=0 tbar.ZIndex=101 mkCorner(8,tbar)
    local tfix=Instance.new("Frame",tbar)
    tfix.Size=UDim2.new(1,0,0.5,0) tfix.Position=UDim2.new(0,0,0.5,0)
    tfix.BackgroundColor3=Color3.fromRGB(10,10,16) tfix.BorderSizePixel=0
    mkLabel(tbar,"📝 CoderScript — "..obj.Name,UDim2.new(1,-80,1,0),UDim2.new(0,8,0,0),12,T.accent)
    local cClose=mkBtn(tbar,"✕",UDim2.new(0,22,0,22),UDim2.new(1,-26,0,4),T.red,Color3.new(1,1,1))
    local runBtn=mkBtn(tbar,"▶ Run",UDim2.new(0,52,0,22),UDim2.new(1,-82,0,4),T.green,Color3.new(0,0,0))
    cClose.MouseButton1Click:Connect(function() cSg:Destroy() end)
    local edBg=Instance.new("Frame",win)
    edBg.Size=UDim2.new(1,-8,0.72,-34) edBg.Position=UDim2.new(0,4,0,34)
    edBg.BackgroundColor3=Color3.fromRGB(12,12,18) edBg.BorderSizePixel=0 edBg.ZIndex=101
    mkCorner(4,edBg)
    local codeBox=Instance.new("TextBox",edBg)
    codeBox.Size=UDim2.new(1,-8,1,-4) codeBox.Position=UDim2.new(0,4,0,2)
    codeBox.BackgroundTransparency=1 codeBox.Text="-- Write your code here\nprint('Hello!')"
    codeBox.TextColor3=Color3.fromRGB(200,220,255) codeBox.Font=Enum.Font.Code
    codeBox.TextSize=13 codeBox.TextXAlignment=Enum.TextXAlignment.Left
    codeBox.TextYAlignment=Enum.TextYAlignment.Top
    codeBox.MultiLine=true codeBox.TextWrapped=false codeBox.ClearTextOnFocus=false codeBox.ZIndex=102
    local outBg=Instance.new("Frame",win)
    outBg.Size=UDim2.new(1,-8,0.28,-8) outBg.Position=UDim2.new(0,4,0.72,2)
    outBg.BackgroundColor3=Color3.fromRGB(10,10,14) outBg.BorderSizePixel=0 outBg.ZIndex=101
    mkCorner(4,outBg)
    local outLbl=Instance.new("TextLabel",outBg)
    outLbl.Size=UDim2.new(1,-8,1,-4) outLbl.Position=UDim2.new(0,4,0,2)
    outLbl.BackgroundTransparency=1 outLbl.Text='<font color="#444466">-- Output --</font>'
    outLbl.Font=Enum.Font.Code outLbl.TextSize=11 outLbl.TextColor3=T.text
    outLbl.TextXAlignment=Enum.TextXAlignment.Left outLbl.TextYAlignment=Enum.TextYAlignment.Top
    outLbl.TextWrapped=true outLbl.RichText=true outLbl.ZIndex=102
    runBtn.MouseButton1Click:Connect(function()
        local outputs={}
        local function esc(s) return tostring(s):gsub("&","and"):gsub("<","["):gsub(">","]") end
        local env=setmetatable({
            print=function(...) local p={} for _,v in ipairs({...}) do table.insert(p,tostring(v)) end
                table.insert(outputs,'<font color="#88ff88">'..esc(table.concat(p,"\t")).."</font>")
                outLbl.Text=table.concat(outputs,"\n") end,
            warn=function(...) local p={} for _,v in ipairs({...}) do table.insert(p,tostring(v)) end
                table.insert(outputs,'<font color="#ffcc44">⚠ '..esc(table.concat(p,"\t")).."</font>")
                outLbl.Text=table.concat(outputs,"\n") end,
            game=game,workspace=workspace,task=task,script=obj,
            Vector3=Vector3,CFrame=CFrame,Instance=Instance,Color3=Color3,
            math=math,string=string,table=table,pcall=pcall,pairs=pairs,ipairs=ipairs,
        },{__index=_G})
        outLbl.Text=""
        local fn,err=loadstring(codeBox.Text)
        if not fn then
            outLbl.Text='<font color="#ff5555">❌ '..esc(tostring(err)).."</font>"
            return
        end
        setfenv(fn,env)
        local ok,runErr=pcall(fn)
        if not ok then
            table.insert(outputs,'<font color="#ff5555">❌ '..esc(tostring(runErr)).."</font>")
            outLbl.Text=table.concat(outputs,"\n")
        elseif #outputs==0 then
            outLbl.Text='<font color="#444466">-- No output --</font>'
        end
    end)
end

-- Explorer
refreshExplorer = function()
    for _,c in ipairs(exScroll:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
    end
    local SERVICES={
        {workspace,"Workspace","🌍",Color3.fromRGB(100,200,100)},
        {game:GetService("ReplicatedStorage"),"ReplicatedStorage","📦",Color3.fromRGB(200,180,100)},
        {game:GetService("ReplicatedFirst"),"ReplicatedFirst","⚡",Color3.fromRGB(255,200,50)},
        {game:GetService("StarterGui"),"StarterGui","🖥",Color3.fromRGB(180,120,220)},
        {game:GetService("StarterPack"),"StarterPack","🎒",Color3.fromRGB(200,150,80)},
        {game:GetService("Lighting"),"Lighting","💡",Color3.fromRGB(255,240,100)},
        {LP,"LocalPlayer","👤",Color3.fromRGB(100,200,255)},
    }
    local function addNode(obj,depth)
        local children={}
        pcall(function() children=obj:GetChildren() end)
        local hasChildren=#children>0
        local isExp=expanded[obj]
        local isSel=(obj==selectedObj)
        local icon,col=getCI(obj)
        local row=Instance.new("TextButton",exScroll)
        row.Size=UDim2.new(1,0,0,20) row.BackgroundColor3=isSel and T.sel or T.panel
        row.BorderSizePixel=0 row.Text="" row.AutoButtonColor=false
        local pad=Instance.new("UIPadding",row) pad.PaddingLeft=UDim.new(0,4+depth*14)
        local accent=Instance.new("Frame",row)
        accent.Size=UDim2.new(0,2,0.8,0) accent.Position=UDim2.new(0,0,0.1,0)
        accent.BackgroundColor3=col accent.BorderSizePixel=0
        if hasChildren then
            local arr=Instance.new("TextButton",row)
            arr.Size=UDim2.new(0,16,1,0) arr.BackgroundTransparency=1
            arr.Text=isExp and "▾" or "▸" arr.TextColor3=T.dim
            arr.Font=Enum.Font.GothamBold arr.TextSize=11 arr.BorderSizePixel=0 arr.ZIndex=row.ZIndex+1
            arr.MouseButton1Click:Connect(function() expanded[obj]=not expanded[obj] task.defer(refreshExplorer) end)
        end
        local iLbl=Instance.new("TextLabel",row)
        iLbl.Size=UDim2.new(0,16,1,0) iLbl.Position=UDim2.new(0,16,0,0)
        iLbl.BackgroundTransparency=1 iLbl.Text=icon iLbl.TextSize=12 iLbl.Font=Enum.Font.Code
        iLbl.TextColor3=col
        local nLbl=Instance.new("TextLabel",row)
        nLbl.Size=UDim2.new(1,-36,1,0) nLbl.Position=UDim2.new(0,32,0,0)
        nLbl.BackgroundTransparency=1 nLbl.Text=obj.Name nLbl.Font=Enum.Font.Code
        nLbl.TextSize=11 nLbl.TextColor3=isSel and Color3.new(1,1,1) or T.text
        nLbl.TextXAlignment=Enum.TextXAlignment.Left nLbl.TextTruncate=Enum.TextTruncate.AtEnd
        local div=Instance.new("Frame",row)
        div.Size=UDim2.new(1,0,0,1) div.Position=UDim2.new(0,0,1,-1)
        div.BackgroundColor3=Color3.fromRGB(45,45,55) div.BorderSizePixel=0
        -- Click handlers
        local lastClick=0
        row.MouseButton1Click:Connect(function()
            local now=tick()
            if now-lastClick<0.35 then
                task.spawn(openRenamePopup,obj)
            else
                selectObject(obj)
            end
            lastClick=now
        end)
        -- Long press = insert here
        local lpt=nil
        row.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                lpt=task.delay(0.6,function()
                    selectObject(obj)
                    row.BackgroundColor3=T.accent
                    task.wait(0.15) row.BackgroundColor3=T.sel
                    statusLbl.Text="📂 Insert into: "..obj.Name
                end)
            end
        end)
        row.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                if lpt then task.cancel(lpt) lpt=nil end
            end
        end)
        row.MouseEnter:Connect(function() if obj~=selectedObj then row.BackgroundColor3=Color3.fromRGB(50,50,60) end end)
        row.MouseLeave:Connect(function() if obj~=selectedObj then row.BackgroundColor3=T.panel end end)
        if isExp and hasChildren then
            for _,child in ipairs(children) do addNode(child,depth+1) end
        end
    end
    for _,s in ipairs(SERVICES) do addNode(s[1],0) end
end

-- Properties
refreshProperties = function()
    for _,c in ipairs(prScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    if not selectedObj then
        local r=Instance.new("Frame",prScroll) r.Size=UDim2.new(1,0,0,30) r.BackgroundTransparency=1 r.BorderSizePixel=0
        mkLabel(r,"  No selection.",UDim2.new(1,0,1,0),nil,11,T.dim)
        return
    end
    local icon,col=getCI(selectedObj)
    local hRow=Instance.new("Frame",prScroll)
    hRow.Size=UDim2.new(1,0,0,34) hRow.BackgroundColor3=Color3.fromRGB(52,52,60) hRow.BorderSizePixel=0
    local iLbl=Instance.new("TextLabel",hRow)
    iLbl.Size=UDim2.new(0,20,1,0) iLbl.Position=UDim2.new(0,4,0,0)
    iLbl.BackgroundTransparency=1 iLbl.Text=icon iLbl.TextSize=16 iLbl.Font=Enum.Font.Code iLbl.TextColor3=col
    mkLabel(hRow,selectedObj.ClassName,UDim2.new(1,-28,0,18),UDim2.new(0,26,0,2),12,col)
    mkLabel(hRow,selectedObj.Name,UDim2.new(1,-28,0,14),UDim2.new(0,26,0,18),10,T.dim)
    local colHead=Instance.new("Frame",prScroll)
    colHead.Size=UDim2.new(1,0,0,16) colHead.BackgroundColor3=Color3.fromRGB(30,30,36) colHead.BorderSizePixel=0
    mkLabel(colHead,"Property",UDim2.new(0.46,0,1,0),UDim2.new(0,6,0,0),9,T.dim)
    mkLabel(colHead,"Value",UDim2.new(0.54,0,1,0),UDim2.new(0.46,4,0,0),9,T.dim)
    local rowAlt=false
    local function addCat(label,bg)
        local cat=Instance.new("Frame",prScroll) cat.Size=UDim2.new(1,0,0,16)
        cat.BackgroundColor3=bg or Color3.fromRGB(45,45,55) cat.BorderSizePixel=0
        mkLabel(cat,label,UDim2.new(1,-8,1,0),UDim2.new(0,8,0,0),10,Color3.fromRGB(200,200,200))
    end
    local function addProp(propName,override,ro)
        local ok,val=pcall(function() if override~=nil then return override end return selectedObj[propName] end)
        if not ok then return end
        rowAlt=not rowAlt
        local row=Instance.new("Frame",prScroll) row.Size=UDim2.new(1,0,0,22)
        row.BackgroundColor3=rowAlt and Color3.fromRGB(40,40,48) or Color3.fromRGB(36,36,44) row.BorderSizePixel=0
        local nL=Instance.new("TextLabel",row) nL.Size=UDim2.new(0.46,0,1,0) nL.Position=UDim2.new(0,4,0,0)
        nL.BackgroundTransparency=1 nL.Text=propName nL.Font=Enum.Font.Code nL.TextSize=11
        nL.TextColor3=T.dim nL.TextXAlignment=Enum.TextXAlignment.Left nL.TextTruncate=Enum.TextTruncate.AtEnd
        local mid=Instance.new("Frame",row) mid.Size=UDim2.new(0,1,0.7,0) mid.Position=UDim2.new(0.46,0,0.15,0)
        mid.BackgroundColor3=Color3.fromRGB(65,65,75) mid.BorderSizePixel=0
        local vt=typeof(val)
        if ro then
            mkLabel(row,tostring(val):sub(1,28),UDim2.new(0.54,-4,1,0),UDim2.new(0.46,4,0,0),11,T.dim)
        elseif vt=="boolean" then
            local ck=Instance.new("TextButton",row) ck.Size=UDim2.new(0,14,0,14) ck.Position=UDim2.new(0.46,4,0.5,-7)
            ck.BackgroundColor3=val and T.accent or Color3.fromRGB(50,50,55) ck.Text=val and "✓" or ""
            ck.TextColor3=Color3.new(1,1,1) ck.Font=Enum.Font.GothamBold ck.TextSize=9 ck.BorderSizePixel=0
            mkCorner(3,ck)
            local vL=mkLabel(row,tostring(val),UDim2.new(0.3,0,1,0),UDim2.new(0.46,22,0,0),11,val and T.hy or T.dim)
            ck.MouseButton1Click:Connect(function()
                pcall(function() selectedObj[propName]=not selectedObj[propName] refreshProperties() end)
            end)
        elseif vt=="number" then
            local inp=mkInput(row,UDim2.new(0.54,-4,0,18),UDim2.new(0.46,2,0.5,-9),"",tostring(math.floor(val*100)/100))
            inp.TextColor3=Color3.fromRGB(200,230,255)
            inp.FocusLost:Connect(function()
                local n=tonumber(inp.Text)
                if n then pcall(function() selectedObj[propName]=n end) updateHandles() end
            end)
        elseif vt=="string" then
            local inp=mkInput(row,UDim2.new(0.54,-4,0,18),UDim2.new(0.46,2,0.5,-9),"",val:sub(1,50))
            inp.TextColor3=Color3.fromRGB(255,220,150)
            inp.FocusLost:Connect(function()
                pcall(function() selectedObj[propName]=inp.Text end) task.defer(refreshExplorer)
            end)
        elseif vt=="Vector3" then
            local axes={"X","Y","Z"} local vals={val.X,val.Y,val.Z}
            local cols={T.hx,T.hy,T.hz} local inps={}
            for i,ax in ipairs(axes) do
                local aL=Instance.new("TextLabel",row) aL.Size=UDim2.new(0,10,0,18)
                aL.Position=UDim2.new(0.46,2+(i-1)*56,0.5,-9) aL.BackgroundTransparency=1
                aL.Text=ax aL.Font=Enum.Font.GothamBold aL.TextSize=9 aL.TextColor3=cols[i] aL.TextXAlignment=Enum.TextXAlignment.Center
                local inp=mkInput(row,UDim2.new(0,42,0,18),UDim2.new(0.46,12+(i-1)*56,0.5,-9),"",tostring(math.floor(vals[i]*10)/10))
                inp.TextColor3=cols[i] table.insert(inps,inp)
            end
            local function applyV3()
                local x,y,z=tonumber(inps[1].Text),tonumber(inps[2].Text),tonumber(inps[3].Text)
                if x and y and z then pcall(function() selectedObj[propName]=Vector3.new(x,y,z) end) updateHandles() end
            end
            for _,inp in ipairs(inps) do inp.FocusLost:Connect(applyV3) end
        elseif vt=="Color3" then
            local sw=Instance.new("TextButton",row) sw.Size=UDim2.new(0,32,0,14) sw.Position=UDim2.new(0.46,4,0.5,-7)
            sw.BackgroundColor3=val sw.Text="" sw.BorderSizePixel=0 mkCorner(3,sw) mkStroke(Color3.fromRGB(80,80,80),1,sw)
            mkLabel(row,string.format("%d,%d,%d",math.round(val.R*255),math.round(val.G*255),math.round(val.B*255)),
                UDim2.new(0.3,0,1,0),UDim2.new(0.46,40,0,0),10,T.dim)
        elseif vt=="BrickColor" then
            mkLabel(row,tostring(val),UDim2.new(0.54,-4,1,0),UDim2.new(0.46,4,0,0),11,Color3.fromRGB(255,180,100))
        elseif vt=="EnumItem" then
            mkLabel(row,tostring(val):gsub("Enum%.%w+%.",""),UDim2.new(0.54,-4,1,0),UDim2.new(0.46,4,0,0),11,Color3.fromRGB(150,255,150))
        elseif vt=="CFrame" then
            mkLabel(row,string.format("%.1f,%.1f,%.1f",val.X,val.Y,val.Z),UDim2.new(0.54,-4,1,0),UDim2.new(0.46,4,0,0),11,Color3.fromRGB(255,200,100))
        else
            mkLabel(row,tostring(val):sub(1,26),UDim2.new(0.54,-4,1,0),UDim2.new(0.46,4,0,0),11,T.dim)
        end
    end
    -- Data
    addCat("▸ Data",Color3.fromRGB(40,40,55))
    addProp("Name") addProp("ClassName",selectedObj.ClassName,true) addProp("Parent",selectedObj.Parent and selectedObj.Parent.Name or "nil",true)
    -- Behavior
    if selectedObj:IsA("BasePart") or selectedObj:IsA("BaseScript") or selectedObj:IsA("GuiObject") then
        addCat("▸ Behavior",Color3.fromRGB(40,55,40))
        if selectedObj:IsA("BasePart") then addProp("Anchored") addProp("CanCollide") addProp("CastShadow") addProp("Locked") end
        if selectedObj:IsA("BaseScript") then addProp("Disabled") end
        if selectedObj:IsA("GuiObject") then addProp("Visible") addProp("Active") end
    end
    -- Appearance
    addCat("▸ Appearance",Color3.fromRGB(55,40,40))
    if selectedObj:IsA("BasePart") then
        addProp("Color") addProp("BrickColor") addProp("Material") addProp("Transparency") addProp("Reflectance")
    end
    if selectedObj:IsA("GuiObject") then addProp("BackgroundColor3") addProp("BackgroundTransparency") addProp("ZIndex") end
    if selectedObj:IsA("TextLabel") or selectedObj:IsA("TextButton") or selectedObj:IsA("TextBox") then
        addProp("Text") addProp("TextColor3") addProp("TextSize") addProp("Font")
    end
    if selectedObj:IsA("ImageLabel") or selectedObj:IsA("ImageButton") then addProp("Image") addProp("ImageColor3") addProp("ImageTransparency") end
    if selectedObj:IsA("ScreenGui") then addProp("Enabled") addProp("ResetOnSpawn") addProp("DisplayOrder") end
    -- Transform
    if selectedObj:IsA("BasePart") then
        addCat("▸ Transform",Color3.fromRGB(40,40,65))
        addProp("Size") addProp("Position") addProp("Rotation") addProp("CFrame")
    end
    if selectedObj:IsA("GuiObject") then
        addCat("▸ Transform",Color3.fromRGB(40,40,65))
        addProp("Size") addProp("Position") addProp("Rotation")
    end
    -- Surface
    if selectedObj:IsA("BasePart") then
        addCat("▸ Surface",Color3.fromRGB(55,50,40))
        addProp("TopSurface") addProp("BottomSurface") addProp("FrontSurface") addProp("BackSurface") addProp("LeftSurface") addProp("RightSurface")
    end
    -- Sound/Light/Particle
    if selectedObj:IsA("Sound") then addCat("▸ Sound",Color3.fromRGB(40,55,55)) addProp("SoundId") addProp("Volume") addProp("Looped") addProp("Playing") end
    if selectedObj:IsA("Light") then addCat("▸ Light",Color3.fromRGB(55,55,35)) addProp("Brightness") addProp("Color") addProp("Range") addProp("Enabled") end
    if selectedObj:IsA("ParticleEmitter") then addCat("▸ Particle",Color3.fromRGB(55,45,55)) addProp("Rate") addProp("Lifetime") addProp("Speed") addProp("Enabled") end
    -- Actions
    local sp=Instance.new("Frame",prScroll) sp.Size=UDim2.new(1,0,0,4) sp.BackgroundTransparency=1 sp.BorderSizePixel=0
    local actRow=Instance.new("Frame",prScroll) actRow.Size=UDim2.new(1,0,0,28) actRow.BackgroundTransparency=1 actRow.BorderSizePixel=0
    local delBtn=mkBtn(actRow,"🗑 Delete",UDim2.new(0.5,-3,0,26),UDim2.new(0,2,0,1),T.red,Color3.new(1,1,1))
    delBtn.MouseButton1Click:Connect(function()
        clearHandles() pcall(function() selectedObj:Destroy() end)
        selectedObj=nil refreshProperties() task.defer(refreshExplorer)
    end)
    if selectedObj:IsA("BasePart") then
        local dupBtn=mkBtn(actRow,"⎘ Dup",UDim2.new(0.5,-3,0,26),UDim2.new(0.5,1,0,1),T.sel,Color3.new(1,1,1))
        dupBtn.MouseButton1Click:Connect(function()
            pcall(function()
                local cl=selectedObj:Clone() cl.CFrame=cl.CFrame+Vector3.new(4,0,0)
                cl.Parent=selectedObj.Parent table.insert(spawnedObjs,cl) selectObject(cl) task.defer(refreshExplorer)
            end)
        end)
    end
    -- CoderScript for scripts
    if selectedObj:IsA("BaseScript") or selectedObj:IsA("ModuleScript") then
        local codeRow=Instance.new("Frame",prScroll) codeRow.Size=UDim2.new(1,0,0,28) codeRow.BackgroundTransparency=1 codeRow.BorderSizePixel=0
        local codeBtn=mkBtn(codeRow,"📝 Insert Inside (CoderScript)",UDim2.new(1,-4,0,26),UDim2.new(0,2,0,1),T.accent,Color3.new(1,1,1))
        codeBtn.MouseButton1Click:Connect(function() task.spawn(openCoderScript,selectedObj) end)
    end
end

-- Insert menu
local insertMenu=Instance.new("Frame",sg)
insertMenu.Size=UDim2.new(0,200,0,400) insertMenu.Position=UDim2.new(0,explorerW,0,64)
insertMenu.BackgroundColor3=T.dark insertMenu.BorderSizePixel=0 insertMenu.Visible=false insertMenu.ZIndex=30
mkCorner(6,insertMenu) mkStroke(T.border,1,insertMenu)
mkLabel(insertMenu,"  Insert Object",UDim2.new(1,0,0,22),UDim2.new(0,0,0,0),11,T.dim)
local insSearch=mkInput(insertMenu,UDim2.new(1,-8,0,22),UDim2.new(0,4,0,24),"Search...","")
insSearch.ZIndex=31
local insScroll=Instance.new("ScrollingFrame",insertMenu)
insScroll.Size=UDim2.new(1,0,1,-48) insScroll.Position=UDim2.new(0,0,0,48)
insScroll.BackgroundTransparency=1 insScroll.BorderSizePixel=0
insScroll.ScrollBarThickness=3 insScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y insScroll.CanvasSize=UDim2.new(0,0,0,0) insScroll.ZIndex=31
Instance.new("UIListLayout",insScroll).Padding=UDim.new(0,2)

local INSERTABLE={
    {"🟦 Part","Part"},{"⚽ Sphere","Part_Sphere"},{"🔺 Wedge","WedgePart"},{"🔷 CornerWedge","CornerWedgePart"},
    {"📁 Model","Model"},{"📂 Folder","Folder"},
    {"📜 Script","Script"},{"📄 LocalScript","LocalScript"},{"📦 ModuleScript","ModuleScript"},
    {"🖼 ScreenGui","ScreenGui"},{"▭ Frame","Frame"},{"🔤 TextLabel","TextLabel"},
    {"🔘 TextButton","TextButton"},{"✏️ TextBox","TextBox"},{"🖼 ImageLabel","ImageLabel"},
    {"💡 PointLight","PointLight"},{"🔦 SpotLight","SpotLight"},{"☀️ SurfaceLight","SurfaceLight"},
    {"✨ ParticleEmitter","ParticleEmitter"},{"🔥 Fire","Fire"},{"💨 Smoke","Smoke"},{"⚡ Sparkles","Sparkles"},
    {"🎵 Sound","Sound"},{"📡 RemoteEvent","RemoteEvent"},{"📡 RemoteFunction","RemoteFunction"},
    {"🔒 WeldConstraint","WeldConstraint"},{"🔧 HingeConstraint","HingeConstraint"},{"💫 Attachment","Attachment"},
    {"🌊 SpecialMesh","SpecialMesh"},{"🎨 Decal","Decal"},{"🌐 SurfaceAppearance","SurfaceAppearance"},
    {"📷 Camera","Camera"},{"📌 BillboardGui","BillboardGui"},{"📌 SurfaceGui","SurfaceGui"},
}

local function buildInsertList(filter)
    for _,c in ipairs(insScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _,item in ipairs(INSERTABLE) do
        if filter=="" or item[1]:lower():find(filter:lower(),1,true) then
            local btn=Instance.new("TextButton",insScroll)
            btn.Size=UDim2.new(1,-4,0,24) btn.BackgroundColor3=T.panel btn.Text=item[1]
            btn.TextColor3=T.text btn.Font=Enum.Font.Gotham btn.TextSize=11
            btn.BorderSizePixel=0 btn.TextXAlignment=Enum.TextXAlignment.Left btn.ZIndex=32
            local pad=Instance.new("UIPadding",btn) pad.PaddingLeft=UDim.new(0,8)
            btn.MouseEnter:Connect(function() btn.BackgroundColor3=T.sel end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3=T.panel end)
            btn.MouseButton1Click:Connect(function()
                local parent=selectedObj or workspace
                if selectedObj and not (selectedObj:IsA("Model") or selectedObj:IsA("Folder") or selectedObj:IsA("BasePart") or selectedObj==workspace) then
                    parent=selectedObj.Parent or workspace
                end
                local className=item[2]
                pcall(function()
                    local obj
                    if className=="Part_Sphere" then obj=Instance.new("Part") obj.Shape=Enum.PartType.Ball
                    else obj=Instance.new(className) end
                    if obj:IsA("BasePart") then
                        local cam=workspace.CurrentCamera
                        local bp=workspace:FindFirstChild("Baseplate")
                        local spawnY=bp and (bp.Position.Y+bp.Size.Y/2+2) or 5
                        obj.CFrame=CFrame.new(cam.CFrame.Position.X,spawnY,cam.CFrame.Position.Z-10)
                        obj.Size=Vector3.new(4,4,4) obj.Anchored=true
                        obj.BrickColor=BrickColor.new("Bright blue") obj.Material=Enum.Material.SmoothPlastic
                        table.insert(spawnedObjs,obj)
                        -- Freeze new part too (builder mode)
                        if not playMode then table.insert(frozenParts,{part=obj,was=true}) end
                    end
                    if obj:IsA("GuiObject") or obj:IsA("ScreenGui") then obj.Parent=LP:FindFirstChild("PlayerGui") or parent
                    else obj.Parent=parent end
                    statusLbl.Text="Inserted: "..className.." → "..parent.Name
                    insertMenu.Visible=false
                    task.defer(refreshExplorer) selectObject(obj)
                end)
            end)
        end
    end
end
buildInsertList("")
insSearch:GetPropertyChangedSignal("Text"):Connect(function() buildInsertList(insSearch.Text) end)
insertBtn.MouseButton1Click:Connect(function() insertMenu.Visible=not insertMenu.Visible end)

-- Cut/Paste
cutBtn.MouseButton1Click:Connect(function()
    if not selectedObj then return end
    clipboard={obj=selectedObj,parent=selectedObj.Parent}
    statusLbl.Text="✂ Cut: "..selectedObj.Name.." — select target then Paste"
end)
pasteBtn.MouseButton1Click:Connect(function()
    if not clipboard then statusLbl.Text="Nothing to paste!" return end
    local target=selectedObj or workspace
    if not (target:IsA("Model") or target:IsA("Folder") or target:IsA("BasePart") or target==workspace) then
        target=target.Parent or workspace
    end
    pcall(function()
        clipboard.obj.Parent=target
        statusLbl.Text="📋 Pasted: "..clipboard.obj.Name.." → "..target.Name
        selectObject(clipboard.obj) clipboard=nil task.defer(refreshExplorer)
    end)
end)

-- Raycast select + handle detection
local function getHandleAt(pos)
    local cam=workspace.CurrentCamera
    local ok,ray=pcall(function() return cam:ScreenPointToRay(pos.X,pos.Y) end)
    if not ok then return nil,nil end
    local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Include params.FilterDescendantsInstances=handleParts
    local result=workspace:Raycast(ray.Origin,ray.Direction*500,params)
    if result then return result.Instance,result.Instance.Color end
    return nil,nil
end

local function selectFromRay(pos)
    if rmhHeld or holdingHandle then return end
    local cam=workspace.CurrentCamera
    local ok,ray=pcall(function() return cam:ScreenPointToRay(pos.X,pos.Y) end)
    if not ok then return end
    local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude
    local excl={}
    for _,h in ipairs(handleParts) do table.insert(excl,h) end
    pcall(function() local char=LP.Character if char then table.insert(excl,char) end end)
    params.FilterDescendantsInstances=excl
    local result=workspace:Raycast(ray.Origin,ray.Direction*2000,params)
    if result and result.Instance and result.Instance.Name~="_SkyMoonHandle" then
        selectObject(result.Instance)
        statusLbl.Text="Selected: "..result.Instance.Name.." ["..result.Instance.ClassName.."]"
    end
end

local function getAxis(col)
    if col==T.hx then return "X" elseif col==T.hy then return "Y" elseif col==T.hz then return "Z" end
    return nil
end

-- Input handlers
UIS.InputBegan:Connect(function(inp,gp)
    if gp then return end
    local isM1=inp.UserInputType==Enum.UserInputType.MouseButton1
    local isT=inp.UserInputType==Enum.UserInputType.Touch
    if isM1 or isT then
        local h,col=getHandleAt(inp.Position)
        if h then
            holdingHandle=h holdingAxis=getAxis(col)
            holdingType=(currentTool=="Scale") and "scale" or "move"
            pcall(function() h.Material=Enum.Material.Neon h.Color=Color3.new(1,1,1) end)
        end
        isDragging=true dragStarted=false
        lastInputPos=inp.Position clickStartPos=inp.Position
    end
end)

UIS.InputEnded:Connect(function(inp)
    local isM1=inp.UserInputType==Enum.UserInputType.MouseButton1
    local isT=inp.UserInputType==Enum.UserInputType.Touch
    if isM1 or isT then
        if holdingHandle then
            local origCol=holdingAxis=="X" and T.hx or (holdingAxis=="Y" and T.hy or T.hz)
            if holdingAxis then pcall(function() holdingHandle.Material=Enum.Material.SmoothPlastic holdingHandle.Color=origCol end) end
            holdingHandle=nil holdingAxis=nil holdingType=nil
        end
        if not dragStarted and clickStartPos then selectFromRay(clickStartPos) end
        isDragging=false dragStarted=false lastInputPos=nil clickStartPos=nil
        if selectedObj and selectedObj:IsA("BasePart") then updateHandles() refreshProperties() end
    end
end)

UIS.InputChanged:Connect(function(inp)
    if not isDragging then return end
    if inp.UserInputType~=Enum.UserInputType.MouseMovement and inp.UserInputType~=Enum.UserInputType.Touch then return end
    if not lastInputPos then return end
    local delta=inp.Position-lastInputPos lastInputPos=inp.Position
    if not dragStarted then
        if clickStartPos and (inp.Position-clickStartPos).Magnitude<CLICK_THRESH then return end
        dragStarted=true
    end
    if not holdingHandle then return end
    if not selectedObj or not selectedObj:IsA("BasePart") then return end
    pcall(function()
        local cam=workspace.CurrentCamera
        local sens=0.15
        local worldDelta=Vector3.new(0,0,0)
        if holdingAxis=="X" then worldDelta=cam.CFrame.RightVector*delta.X*sens
        elseif holdingAxis=="Y" then worldDelta=cam.CFrame.UpVector*(-delta.Y)*sens
        elseif holdingAxis=="Z" then worldDelta=cam.CFrame.LookVector*(-delta.Y)*sens
        else worldDelta=cam.CFrame.RightVector*delta.X*sens+cam.CFrame.UpVector*(-delta.Y)*sens end
        if holdingType=="move" then
            selectedObj.CFrame=selectedObj.CFrame+worldDelta
        elseif holdingType=="scale" then
            local s=selectedObj.Size
            local mag=worldDelta.Magnitude*(delta.X+delta.Y>0 and 1 or -1)
            if holdingAxis=="X" then selectedObj.Size=Vector3.new(math.max(0.2,s.X+mag),s.Y,s.Z)
            elseif holdingAxis=="Y" then selectedObj.Size=Vector3.new(s.X,math.max(0.2,s.Y+mag),s.Z)
            elseif holdingAxis=="Z" then selectedObj.Size=Vector3.new(s.X,s.Y,math.max(0.2,s.Z+mag))
            else selectedObj.Size=Vector3.new(math.max(0.2,s.X+mag),math.max(0.2,s.Y+mag),s.Z) end
        elseif currentTool=="Rotate" then
            selectedObj.CFrame=selectedObj.CFrame*CFrame.Angles(0,math.rad(delta.X*0.6),0)
        end
        updateHandles()
    end)
end)

-- Keyboard shortcuts
UIS.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if not selectedObj or not selectedObj:IsA("BasePart") then return end
    local k=inp.KeyCode
    pcall(function()
        local s=selectedObj.Size
        if currentTool=="Move" then
            if k==Enum.KeyCode.Right then selectedObj.CFrame=selectedObj.CFrame+Vector3.new(KEY_STEP,0,0)
            elseif k==Enum.KeyCode.Left then selectedObj.CFrame=selectedObj.CFrame-Vector3.new(KEY_STEP,0,0)
            elseif k==Enum.KeyCode.PageUp then selectedObj.CFrame=selectedObj.CFrame+Vector3.new(0,KEY_STEP,0)
            elseif k==Enum.KeyCode.PageDown then selectedObj.CFrame=selectedObj.CFrame-Vector3.new(0,KEY_STEP,0)
            elseif k==Enum.KeyCode.Up then selectedObj.CFrame=selectedObj.CFrame-Vector3.new(0,0,KEY_STEP)
            elseif k==Enum.KeyCode.Down then selectedObj.CFrame=selectedObj.CFrame+Vector3.new(0,0,KEY_STEP) end
        elseif currentTool=="Scale" then
            if k==Enum.KeyCode.KeypadEight then selectedObj.Size=Vector3.new(s.X,math.max(0.2,s.Y+KEY_SCL),s.Z)
            elseif k==Enum.KeyCode.KeypadTwo then selectedObj.Size=Vector3.new(s.X,math.max(0.2,s.Y-KEY_SCL),s.Z)
            elseif k==Enum.KeyCode.KeypadSix then selectedObj.Size=Vector3.new(math.max(0.2,s.X+KEY_SCL),s.Y,s.Z)
            elseif k==Enum.KeyCode.KeypadFour then selectedObj.Size=Vector3.new(math.max(0.2,s.X-KEY_SCL),s.Y,s.Z)
            elseif k==Enum.KeyCode.KeypadNine then selectedObj.Size=Vector3.new(s.X,s.Y,math.max(0.2,s.Z+KEY_SCL))
            elseif k==Enum.KeyCode.KeypadSeven then selectedObj.Size=Vector3.new(s.X,s.Y,math.max(0.2,s.Z-KEY_SCL)) end
        elseif currentTool=="Rotate" then
            if k==Enum.KeyCode.KeypadOne then selectedObj.CFrame=selectedObj.CFrame*CFrame.Angles(0,math.rad(-KEY_ROT),0)
            elseif k==Enum.KeyCode.KeypadThree then selectedObj.CFrame=selectedObj.CFrame*CFrame.Angles(0,math.rad(KEY_ROT),0) end
        end
        updateHandles() refreshProperties()
    end)
end)

-- Mobile WASD
if isMobile then
    local wasdC=Instance.new("Frame",sg)
    wasdC.Size=UDim2.new(0,128,0,128) wasdC.Position=UDim2.new(0,10,1,-143)
    wasdC.BackgroundColor3=Color3.fromRGB(0,0,0) wasdC.BackgroundTransparency=0.5
    wasdC.BorderSizePixel=0 wasdC.ZIndex=25 mkCorner(12,wasdC)
    local held={W=false,A=false,S=false,D=false,E=false,Q=false}
    local function mkW(lbl,pos,dir,col)
        local b=mkBtn(wasdC,lbl,UDim2.new(0,36,0,36),pos,Color3.fromRGB(35,35,45),col or T.text)
        b.ZIndex=26
        b.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then
                held[dir]=true b.BackgroundColor3=T.accent
            end
        end)
        b.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then
                held[dir]=false b.BackgroundColor3=Color3.fromRGB(35,35,45)
            end
        end)
    end
    mkW("W",UDim2.new(0,46,0,4),"W",T.hy)
    mkW("A",UDim2.new(0,4,0,46),"A",T.hy)
    mkW("S",UDim2.new(0,46,0,46),"S",T.hy)
    mkW("D",UDim2.new(0,88,0,46),"D",T.hy)
    mkW("↑",UDim2.new(0,88,0,4),"E",T.accent)
    mkW("↓",UDim2.new(0,4,0,4),"Q",T.accent)
    RunService.RenderStepped:Connect(function()
        if not freeCamActive then return end
        local dir=Vector2.new(0,0)
        if held.D then dir=dir+Vector2.new(1,0) end
        if held.A then dir=dir-Vector2.new(1,0) end
        if held.S then dir=dir+Vector2.new(0,1) end
        if held.W then dir=dir-Vector2.new(0,1) end
        joystickDir=dir.Magnitude>0 and dir.Unit or Vector2.new(0,0)
        if held.E then joystickDir=Vector2.new(joystickDir.X,joystickDir.Y-0.5) end
        if held.Q then joystickDir=Vector2.new(joystickDir.X,joystickDir.Y+0.5) end
    end)
    -- Touch swipe for camera
    local lastTP=nil
    local camTch=nil
    UIS.TouchStarted:Connect(function(t,gp)
        if gp then return end
        if camTch==nil then camTch=t lastTP=Vector2.new(t.Position.X,t.Position.Y) end
    end)
    UIS.TouchMoved:Connect(function(t,gp)
        if gp then return end
        if t==camTch then
            local pos=Vector2.new(t.Position.X,t.Position.Y)
            if lastTP then touchCamDelta=touchCamDelta+(pos-lastTP) end
            lastTP=pos
        end
    end)
    UIS.TouchEnded:Connect(function(t,gp)
        if t==camTch then camTch=nil lastTP=nil end
    end)
end

-- Init
freezePhysics()
startFreeCam()
refreshExplorer()
refreshProperties()

task.spawn(function()
    while sg.Parent do
        task.wait(5)
        if not playMode then pcall(refreshExplorer) end
    end
end)

RunService.Heartbeat:Connect(function()
    if selectedObj and selectedObj:IsA("BasePart") and not isDragging then
        if selBox then pcall(function() selBox.Adornee=selectedObj end) end
    end
end)

statusLbl.Text="🌙 Real Builder v3 | Click=select | Tap handle=move/scale | Double-click=rename | Long press=insert here"
