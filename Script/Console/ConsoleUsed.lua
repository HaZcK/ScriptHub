-- ╔══════════════════════════════════════════════════════════════╗
-- ║           Console Used  v1.0  ─  by HaZcK                   ║
-- ║   Elegant black terminal GUI for Delta / Synapse executor    ║
-- ║   Features: LogService mirror · loadstring cmdbar            ║
-- ║             filter toggles · history · drag · minimize       ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LogService   = game:GetService("LogService")

local LP   = Players.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui")

-- ──────────── Cleanup ────────────
pcall(function()
    local old = PGui:FindFirstChild("ConsoleUsed_v1")
    if old then old:Destroy() end
end)

-- ──────────── Palette ────────────
local P = {
    bg1  = Color3.fromRGB(7,   7,  10),   -- deepest bg
    bg2  = Color3.fromRGB(13,  13, 17),   -- panel bg
    bg3  = Color3.fromRGB(18,  18, 23),   -- inner bg
    bg4  = Color3.fromRGB(26,  26, 34),   -- button bg
    acc  = Color3.fromRGB(0,   215, 165), -- teal accent
    txt  = Color3.fromRGB(200, 200, 218), -- primary text
    dim  = Color3.fromRGB(58,  58,  80),  -- muted text
    err  = Color3.fromRGB(255, 72,  72),  -- error red
    warn = Color3.fromRGB(255, 188, 42),  -- warn yellow
    ok   = Color3.fromRGB(75,  225, 130), -- success green
    sys  = Color3.fromRGB(90,  172, 255), -- system blue
    out  = Color3.fromRGB(178, 178, 204), -- output grey-blue
}

-- ──────────── State ────────────
local msgs    = {}
local msgN    = 0
local fErr    = true
local fWarn   = true
local fOut    = true
local fSys    = true
local hist    = {}
local histI   = 0
local initBlock = false  -- blocks LogService during init sequence

-- ──────────── UI Helpers ────────────
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = obj
    return c
end

local function newStroke(obj, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.new(1,1,1)
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.Parent = obj
    return s
end

local function mkFrame(parent, bg, size, pos, zi)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = bg
    f.BorderSizePixel  = 0
    f.Size             = size
    f.Position         = pos or UDim2.new(0,0,0,0)
    f.ZIndex           = zi or 10
    f.Parent           = parent
    return f
end

local function mkLabel(parent, text, tsz, font, col, size, pos, zi, xa)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text             = text or ""
    l.TextSize         = tsz or 13
    l.Font             = font or Enum.Font.Code
    l.TextColor3       = col or P.txt
    l.Size             = size or UDim2.new(1,0,1,0)
    l.Position         = pos or UDim2.new(0,0,0,0)
    l.ZIndex           = zi or 11
    l.TextXAlignment   = xa or Enum.TextXAlignment.Left
    l.BorderSizePixel  = 0
    l.Parent           = parent
    return l
end

local function mkBtn(parent, text, bg, tc, size, pos, zi)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = bg or P.bg4
    b.BorderSizePixel  = 0
    b.Text             = text or ""
    b.TextColor3       = tc or P.txt
    b.TextSize         = 11
    b.Font             = Enum.Font.Code
    b.Size             = size or UDim2.new(0,60,0,20)
    b.Position         = pos or UDim2.new(0,0,0,0)
    b.ZIndex           = zi or 12
    b.AutoButtonColor  = false
    b.Parent           = parent
    corner(b, 3)
    -- Hover effect
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(38,38,50)
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = bg or P.bg4
        }):Play()
    end)
    return b
end

-- ════════════════════════════════════════════════════════
--  SCREEN GUI
-- ════════════════════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name            = "ConsoleUsed_v1"
SG.ResetOnSpawn    = false
SG.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset  = true
SG.Parent          = PGui

-- ════════════════════════════════════════════════════════
--  LOADING SCREEN
-- ════════════════════════════════════════════════════════
local LF = mkFrame(SG, P.bg1, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 50)

-- Subtle grid texture (decorative horizontal lines)
for i = 0, 20 do
    local line = mkFrame(LF, Color3.fromRGB(18,18,24),
        UDim2.new(1,0,0,1), UDim2.new(0,0,0,i*40), 51)
    line.BackgroundTransparency = 0.85
end

local LTitle = mkLabel(LF, "", 52, Enum.Font.Code, P.acc,
    UDim2.new(0,640,0,80), UDim2.new(0.5,-320,0.5,-100), 53)
LTitle.RichText = true

local LSub = mkLabel(LF, "", 13, Enum.Font.Code, P.dim,
    UDim2.new(0,520,0,24), UDim2.new(0.5,-260,0.5,5), 53)

-- Progress track
local LPTrack = mkFrame(LF, P.bg4,
    UDim2.new(0,440,0,3), UDim2.new(0.5,-220,0.5,48), 53)
corner(LPTrack, 2)
local LPFill = mkFrame(LPTrack, P.acc,
    UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), 54)
corner(LPFill, 2)

-- Accent glow behind progress
local LPGlow = mkFrame(LF, P.acc,
    UDim2.new(0,0,0,7), UDim2.new(0.5,-220,0.5,47), 52)
LPGlow.BackgroundTransparency = 0.88

-- Scan line
local LScan = mkFrame(LF, P.acc, UDim2.new(1,0,0,1),
    UDim2.new(0,0,0,0), 54)
LScan.BackgroundTransparency = 0.78

-- Version watermark
local LVer = mkLabel(LF, "Console Used  ─  v1.0  ─  by HaZcK",
    12, Enum.Font.Code, Color3.fromRGB(24,24,36),
    UDim2.new(1,0,0,24), UDim2.new(0,0,1,-32), 52,
    Enum.TextXAlignment.Center)

-- ════════════════════════════════════════════════════════
--  MAIN FRAME  (720 × 520)
-- ════════════════════════════════════════════════════════
local MF = mkFrame(SG, P.bg1,
    UDim2.new(0,720,0,520), UDim2.new(0.5,-360,0.5,-260), 10)
MF.Visible = false
corner(MF, 8)
newStroke(MF, Color3.fromRGB(0,130,100), 1, 0.45)

-- ── TITLE BAR ──────────────────────────────────────────
local TB = mkFrame(MF, P.bg2, UDim2.new(1,0,0,38), UDim2.new(0,0,0,0), 11)
-- Round top corners only (fix bottom)
corner(TB, 8)
local TBFix = mkFrame(TB, P.bg2, UDim2.new(1,0,0.5,0), UDim2.new(0,0,0.5,0), 11)
-- Bottom accent line
local TBAcc = mkFrame(TB, P.acc, UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), 12)
TBAcc.BackgroundTransparency = 0.65

-- Decorative terminal dots
local function dot(x, col)
    local d = mkFrame(TB, col, UDim2.new(0,11,0,11),
        UDim2.new(0,x,0.5,-5.5), 12)
    corner(d, 10)
    return d
end
dot(10, Color3.fromRGB(255, 85, 75))
dot(25, Color3.fromRGB(255, 185, 28))
dot(40, Color3.fromRGB(42,  200, 88))

local TBTitle = mkLabel(TB, "Console Used  ─  PlaceId: " .. tostring(game.PlaceId),
    12, Enum.Font.Code, P.dim,
    UDim2.new(1,-135,1,0), UDim2.new(0,58,0,0), 12)

-- Close button
local BClose = Instance.new("TextButton")
BClose.Size             = UDim2.new(0,34,0,24)
BClose.Position         = UDim2.new(1,-39,0.5,-12)
BClose.BackgroundColor3 = Color3.fromRGB(50,22,22)
BClose.Text             = "✕"
BClose.TextColor3       = P.err
BClose.TextSize         = 13
BClose.Font             = Enum.Font.GothamBold
BClose.BorderSizePixel  = 0
BClose.AutoButtonColor  = false
BClose.ZIndex           = 13
BClose.Parent           = TB
corner(BClose, 4)
BClose.MouseEnter:Connect(function()
    TweenService:Create(BClose,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(180,40,40)}):Play()
end)
BClose.MouseLeave:Connect(function()
    TweenService:Create(BClose,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(50,22,22)}):Play()
end)

-- Minimize button
local BMin = Instance.new("TextButton")
BMin.Size             = UDim2.new(0,34,0,24)
BMin.Position         = UDim2.new(1,-77,0.5,-12)
BMin.BackgroundColor3 = Color3.fromRGB(44,38,18)
BMin.Text             = "▂"
BMin.TextColor3       = P.warn
BMin.TextSize         = 13
BMin.Font             = Enum.Font.GothamBold
BMin.BorderSizePixel  = 0
BMin.AutoButtonColor  = false
BMin.ZIndex           = 13
BMin.Parent           = TB
corner(BMin, 4)
BMin.MouseEnter:Connect(function()
    TweenService:Create(BMin,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(160,120,20)}):Play()
end)
BMin.MouseLeave:Connect(function()
    TweenService:Create(BMin,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(44,38,18)}):Play()
end)

-- ── TOOLBAR ────────────────────────────────────────────
local TOOL = mkFrame(MF, P.bg2, UDim2.new(1,0,0,30), UDim2.new(0,0,0,38), 11)
mkFrame(TOOL, Color3.fromRGB(28,28,38), UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), 12)

local BClear = mkBtn(TOOL,"  CLEAR  ",P.bg4,P.txt,
    UDim2.new(0,58,0,20), UDim2.new(0,8,0.5,-10), 12)
local BErr   = mkBtn(TOOL,"ERR: ON",P.bg4,P.err,
    UDim2.new(0,64,0,20), UDim2.new(0,74,0.5,-10), 12)
local BWarn  = mkBtn(TOOL,"WRN: ON",P.bg4,P.warn,
    UDim2.new(0,64,0,20), UDim2.new(0,146,0.5,-10), 12)
local BOut   = mkBtn(TOOL,"OUT: ON",P.bg4,P.out,
    UDim2.new(0,64,0,20), UDim2.new(0,218,0.5,-10), 12)
local BSys   = mkBtn(TOOL,"SYS: ON",P.bg4,P.sys,
    UDim2.new(0,64,0,20), UDim2.new(0,290,0.5,-10), 12)

local MsgCtr = mkLabel(TOOL, "0 msgs", 11, Enum.Font.Code, P.dim,
    UDim2.new(0,110,1,0), UDim2.new(1,-116,0,0), 12, Enum.TextXAlignment.Right)

-- ── CONSOLE OUTPUT AREA ────────────────────────────────
-- Layout: Y=76, H=374  →  bottom at 450
local ConFrame = mkFrame(MF, P.bg3,
    UDim2.new(1,-16,0,374), UDim2.new(0,8,0,76), 11)
corner(ConFrame, 5)
newStroke(ConFrame, Color3.fromRGB(28,28,40), 1, 0)

local ConScroll = Instance.new("ScrollingFrame")
ConScroll.Size                    = UDim2.new(1,-6,1,-6)
ConScroll.Position                = UDim2.new(0,3,0,3)
ConScroll.BackgroundTransparency  = 1
ConScroll.BorderSizePixel         = 0
ConScroll.ScrollBarThickness      = 4
ConScroll.ScrollBarImageColor3    = P.acc
ConScroll.ScrollBarImageTransparency = 0.4
ConScroll.CanvasSize              = UDim2.new(0,0,0,0)
ConScroll.AutomaticCanvasSize     = Enum.AutomaticSize.Y
ConScroll.ZIndex                  = 12
ConScroll.Parent                  = ConFrame

local ConLayout = Instance.new("UIListLayout")
ConLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConLayout.Padding   = UDim.new(0,0)
ConLayout.Parent    = ConScroll

local ConPad = Instance.new("UIPadding")
ConPad.PaddingLeft   = UDim.new(0,5)
ConPad.PaddingRight  = UDim.new(0,5)
ConPad.PaddingTop    = UDim.new(0,3)
ConPad.PaddingBottom = UDim.new(0,3)
ConPad.Parent        = ConScroll

-- ── COMMAND BAR ────────────────────────────────────────
-- Y=458 (1,-62), H=36  →  bottom at 494
local CmdFrame = mkFrame(MF, P.bg3,
    UDim2.new(1,-16,0,36), UDim2.new(0,8,1,-62), 11)
corner(CmdFrame, 5)
local CmdStroke = newStroke(CmdFrame, Color3.fromRGB(28,28,40), 1, 0.5)

-- Prompt glyph
local CmdPre = mkLabel(CmdFrame, " ❯", 15, Enum.Font.Code, P.acc,
    UDim2.new(0,28,1,0), UDim2.new(0,0,0,0), 12)

local CmdBox = Instance.new("TextBox")
CmdBox.BackgroundTransparency = 1
CmdBox.Size                   = UDim2.new(1,-78,1,-6)
CmdBox.Position               = UDim2.new(0,28,0,3)
CmdBox.Text                   = ""
CmdBox.PlaceholderText        = "Lua code... loadstring() ✓  ·  require() ✗  ·  ↑↓ history"
CmdBox.TextColor3             = P.txt
CmdBox.PlaceholderColor3      = P.dim
CmdBox.TextSize               = 12
CmdBox.Font                   = Enum.Font.Code
CmdBox.TextXAlignment         = Enum.TextXAlignment.Left
CmdBox.ClearTextOnFocus       = false
CmdBox.MultiLine              = false
CmdBox.BorderSizePixel        = 0
CmdBox.ZIndex                 = 12
CmdBox.Parent                 = CmdFrame

-- Focus glow via stroke color change
CmdBox.Focused:Connect(function()
    TweenService:Create(CmdStroke, TweenInfo.new(0.18), {
        Color = P.acc, Transparency = 0.15
    }):Play()
    TweenService:Create(CmdPre, TweenInfo.new(0.18), {
        TextColor3 = Color3.fromRGB(0, 255, 200)
    }):Play()
end)
CmdBox.FocusLost:Connect(function(enter)
    TweenService:Create(CmdStroke, TweenInfo.new(0.18), {
        Color = Color3.fromRGB(28,28,40), Transparency = 0.5
    }):Play()
    TweenService:Create(CmdPre, TweenInfo.new(0.18), {TextColor3 = P.acc}):Play()
    if enter then
        local c = CmdBox.Text; CmdBox.Text = ""
        task.spawn(execCmd, c)
    end
end)

local BRun = Instance.new("TextButton")
BRun.BackgroundColor3 = P.acc
BRun.BorderSizePixel  = 0
BRun.Text             = "RUN"
BRun.TextColor3       = P.bg1
BRun.TextSize         = 11
BRun.Font             = Enum.Font.GothamBold
BRun.Size             = UDim2.new(0,44,0,24)
BRun.Position         = UDim2.new(1,-50,0.5,-12)
BRun.ZIndex           = 12
BRun.AutoButtonColor  = false
BRun.Parent           = CmdFrame
corner(BRun, 4)
BRun.MouseEnter:Connect(function()
    TweenService:Create(BRun,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(0,255,200)}):Play()
end)
BRun.MouseLeave:Connect(function()
    TweenService:Create(BRun,TweenInfo.new(0.12),{BackgroundColor3=P.acc}):Play()
end)

-- ── STATUS BAR ─────────────────────────────────────────
-- Y=498 (1,-22), H=22
local StatBar = mkFrame(MF, P.bg2, UDim2.new(1,0,0,22), UDim2.new(0,0,1,-22), 11)
corner(StatBar, 8)
-- Fix top corners
mkFrame(StatBar, P.bg2, UDim2.new(1,0,0.5,0), UDim2.new(0,0,0,0), 11)
mkFrame(StatBar, Color3.fromRGB(28,28,38), UDim2.new(1,0,0,1), UDim2.new(0,0,0,0), 12)

local StatTxt = mkLabel(StatBar, "Ready", 11, Enum.Font.Code, P.dim,
    UDim2.new(0.65,0,1,0), UDim2.new(0,10,0,0), 12)
local StatVer = mkLabel(StatBar, "Console Used v1.0  ", 11, Enum.Font.Code,
    Color3.fromRGB(30,30,46),
    UDim2.new(0.35,0,1,0), UDim2.new(0.65,0,0,0), 12, Enum.TextXAlignment.Right)

-- ════════════════════════════════════════════════════════
--  CORE FUNCTIONS
-- ════════════════════════════════════════════════════════
local typeColor = {
    ERROR="err", WARN="warn", OK="ok", SYSTEM="sys", PRINT="out"
}
local typePfx = {
    ERROR="[ERR] ", WARN="[WRN] ", OK="[OK ] ", SYSTEM="[SYS] ", PRINT="[OUT] "
}

local function isVis(t)
    if t=="ERROR"  then return fErr  end
    if t=="WARN"   then return fWarn end
    if t=="PRINT"  then return fOut  end
    return fSys
end

local function updateUI()
    local n = #msgs
    MsgCtr.Text  = n .. " msgs"
    StatTxt.Text = ("Ready  │  %d msgs  │  %s"):format(n, os.date("%H:%M:%S"))
end

local function scrollBottom()
    task.defer(function()
        if ConScroll and ConScroll.Parent then
            ConScroll.CanvasPosition = Vector2.new(0, 1e6)
        end
    end)
end

local function addMsg(mtype, text)
    msgN += 1
    if #msgs >= 500 then
        local old = table.remove(msgs, 1)
        if old.lbl and old.lbl.Parent then old.lbl:Destroy() end
    end
    
    local col = P[typeColor[mtype]] or P.out
    local pfx = typePfx[mtype]     or "[OUT] "
    local ts  = os.date("[%H:%M:%S] ")
    
    local row = Instance.new("TextLabel")
    row.BackgroundTransparency = 1
    row.Size                   = UDim2.new(1,-2,0,0)
    row.AutomaticSize          = Enum.AutomaticSize.Y
    row.Text                   = ts .. pfx .. tostring(text)
    row.TextColor3             = col
    row.TextSize               = 12
    row.Font                   = Enum.Font.Code
    row.TextXAlignment         = Enum.TextXAlignment.Left
    row.TextWrapped            = true
    row.Visible                = isVis(mtype)
    row.LayoutOrder            = msgN
    row.ZIndex                 = 13
    row.Parent                 = ConScroll
    
    table.insert(msgs, {type=mtype, lbl=row})
    scrollBottom()
    updateUI()
end

-- ──────────── Execute Command ────────────
function execCmd(code)
    if not code or code:gsub("%s+","") == "" then return end
    
    -- History
    if hist[1] ~= code then
        table.insert(hist, 1, code)
        if #hist > 100 then table.remove(hist) end
    end
    histI = 0
    
    addMsg("SYSTEM", "❯ " .. code)
    
    -- Block require (security)
    if code:match("require%s*%(") then
        addMsg("ERROR", "require() is blocked. Use loadstring(game:HttpGet(...))() for external loading.")
        return
    end
    
    -- Compile via loadstring
    local fn, cerr = loadstring(code)
    if not fn then
        addMsg("ERROR", "Syntax Error: " .. tostring(cerr))
        return
    end
    
    -- Execute in pcall
    local ok, rerr = pcall(fn)
    if ok then
        addMsg("OK", "Executed without runtime errors.")
    else
        addMsg("ERROR", "Runtime Error: " .. tostring(rerr))
    end
end

-- ──────────── LogService Hook ────────────
-- Mirrors ALL Roblox console output (print, warn, error, game scripts, etc.)
pcall(function()
    LogService.MessageOut:Connect(function(msg, mtype)
        if initBlock then return end
        local t
        if     mtype == Enum.MessageType.MessageError   then t = "ERROR"
        elseif mtype == Enum.MessageType.MessageWarning then t = "WARN"
        elseif mtype == Enum.MessageType.MessageInfo    then t = "SYSTEM"
        else                                                 t = "PRINT"
        end
        pcall(addMsg, t, msg)
    end)
end)

-- ──────────── Toolbar Events ────────────
BClear.MouseButton1Click:Connect(function()
    for _,m in ipairs(msgs) do
        if m.lbl and m.lbl.Parent then m.lbl:Destroy() end
    end
    msgs = {}; msgN = 0
    addMsg("SYSTEM","Console cleared.")
end)

BErr.MouseButton1Click:Connect(function()
    fErr = not fErr
    BErr.Text       = fErr and "ERR: ON" or "ERR: OFF"
    BErr.TextColor3 = fErr and P.err or P.dim
    for _,m in ipairs(msgs) do
        if m.type=="ERROR" and m.lbl then m.lbl.Visible = fErr end
    end
end)

BWarn.MouseButton1Click:Connect(function()
    fWarn = not fWarn
    BWarn.Text       = fWarn and "WRN: ON" or "WRN: OFF"
    BWarn.TextColor3 = fWarn and P.warn or P.dim
    for _,m in ipairs(msgs) do
        if m.type=="WARN" and m.lbl then m.lbl.Visible = fWarn end
    end
end)

BOut.MouseButton1Click:Connect(function()
    fOut = not fOut
    BOut.Text       = fOut and "OUT: ON" or "OUT: OFF"
    BOut.TextColor3 = fOut and P.out or P.dim
    for _,m in ipairs(msgs) do
        if m.type=="PRINT" and m.lbl then m.lbl.Visible = fOut end
    end
end)

BSys.MouseButton1Click:Connect(function()
    fSys = not fSys
    BSys.Text       = fSys and "SYS: ON" or "SYS: OFF"
    BSys.TextColor3 = fSys and P.sys or P.dim
    for _,m in ipairs(msgs) do
        if (m.type=="SYSTEM" or m.type=="OK") and m.lbl then
            m.lbl.Visible = fSys
        end
    end
end)

BRun.MouseButton1Click:Connect(function()
    local c = CmdBox.Text; CmdBox.Text = ""
    task.spawn(execCmd, c)
end)

-- ──────────── Command History (↑ ↓) ────────────
UIS.InputBegan:Connect(function(inp, gp)
    if not CmdBox:IsFocused() then return end
    if inp.KeyCode == Enum.KeyCode.Up then
        histI = math.min(histI+1, #hist)
        if hist[histI] then CmdBox.Text = hist[histI] end
        task.defer(function() CmdBox.CursorPosition = #CmdBox.Text+1 end)
    elseif inp.KeyCode == Enum.KeyCode.Down then
        histI = math.max(histI-1, 0)
        CmdBox.Text = hist[histI] or ""
        task.defer(function() CmdBox.CursorPosition = #CmdBox.Text+1 end)
    end
end)

-- ──────────── Dragging ────────────
do
    local dragging, dragStart, frameStart = false, nil, nil

    TB.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            dragStart  = inp.Position
            frameStart = MF.Position
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - dragStart
            MF.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + d.X,
                frameStart.Y.Scale, frameStart.Y.Offset + d.Y
            )
        end
    end)
end

-- ──────────── Close / Minimize ────────────
BClose.MouseButton1Click:Connect(function()
    TweenService:Create(MF, TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.In), {
        Size = UDim2.new(0,720,0,0),
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.22, function() MF.Visible = false end)
end)

local minimized = false
BMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ConFrame.Visible = false
        TOOL.Visible     = false
        CmdFrame.Visible = false
        StatBar.Visible  = false
        TweenService:Create(MF, TweenInfo.new(0.2,Enum.EasingStyle.Quint), {
            Size = UDim2.new(0,720,0,38)
        }):Play()
        BMin.Text = "□"
    else
        TweenService:Create(MF, TweenInfo.new(0.22,Enum.EasingStyle.Quint), {
            Size = UDim2.new(0,720,0,520)
        }):Play()
        task.delay(0.23, function()
            ConFrame.Visible = true
            TOOL.Visible     = true
            CmdFrame.Visible = true
            StatBar.Visible  = true
        end)
        BMin.Text = "▂"
    end
end)

-- ════════════════════════════════════════════════════════
--  LOADING ANIMATION SEQUENCE
-- ════════════════════════════════════════════════════════

-- Scan line loop (runs during loading)
task.spawn(function()
    while LF and LF.Parent do
        LScan.Position = UDim2.new(0,0,0,0)
        TweenService:Create(LScan, TweenInfo.new(2.8, Enum.EasingStyle.Linear), {
            Position = UDim2.new(0,0,1,0)
        }):Play()
        task.wait(2.8)
    end
end)

-- Main loading sequence
task.spawn(function()
    local FULL = "Console Used"
    
    -- ── 1. Typing animation ──
    for i = 1, #FULL do
        LTitle.Text = string.sub(FULL,1,i)
        task.wait(0.072)
    end
    
    -- ── 2. Cursor blink ──
    for _ = 1, 4 do
        LTitle.Text = FULL .. "<font color='#00D7A5'>█</font>"
        task.wait(0.20)
        LTitle.Text = FULL
        task.wait(0.20)
    end
    
    -- ── 3. Progress bar steps ──
    local steps = {
        { 0.18, "Initializing interface components..." },
        { 0.40, "Connecting to LogService hook..."     },
        { 0.62, "Building command engine..."           },
        { 0.82, "Preparing output mirror..."           },
        { 1.00, "All systems ready."                   },
    }
    
    for _, s in ipairs(steps) do
        LSub.Text = s[2]
        TweenService:Create(LPFill, TweenInfo.new(0.48, Enum.EasingStyle.Quint), {
            Size = UDim2.new(s[1], 0, 1, 0)
        }):Play()
        TweenService:Create(LPGlow, TweenInfo.new(0.48, Enum.EasingStyle.Quint), {
            Size = UDim2.new(s[1]*440/720, 0, 0, 7)
        }):Play()
        task.wait(0.60)
    end
    
    task.wait(0.35)
    
    -- ── 4. Fade out loading frame ──
    local function fadeOut(obj, prop)
        TweenService:Create(obj, TweenInfo.new(0.38), {[prop] = 1}):Play()
    end
    fadeOut(LTitle,   "TextTransparency")
    fadeOut(LSub,     "TextTransparency")
    fadeOut(LVer,     "TextTransparency")
    fadeOut(LPTrack,  "BackgroundTransparency")
    fadeOut(LPFill,   "BackgroundTransparency")
    fadeOut(LPGlow,   "BackgroundTransparency")
    TweenService:Create(LF, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    
    task.wait(0.5)
    LF:Destroy()
    
    -- ── 5. Reveal main GUI ──
    MF.Visible              = true
    MF.BackgroundTransparency = 1
    MF.Position             = UDim2.new(0.5,-360,0.56,-260)
    
    TweenService:Create(MF, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position               = UDim2.new(0.5,-360,0.5,-260)
    }):Play()
    
    task.wait(0.18)
    
    -- ── 6. Welcome messages ──
    initBlock = true
    addMsg("SYSTEM","══════════════════════════════════════════════════════")
    addMsg("SYSTEM","  Console Used  v1.0  │  by HaZcK  │  Delta Compatible ")
    addMsg("SYSTEM","══════════════════════════════════════════════════════")
    addMsg("SYSTEM","PlaceId  : " .. tostring(game.PlaceId))
    addMsg("SYSTEM","JobId    : " .. tostring(game.JobId):sub(1,18) .. "...")
    addMsg("SYSTEM","Client   : " .. tostring(LP.Name) .. "  (UserId: " .. tostring(LP.UserId) .. ")")
    addMsg("SYSTEM","──────────────────────────────────────────────────────")
    addMsg("SYSTEM","LogService hook active — mirroring ALL console output.")
    addMsg("SYSTEM","Command bar: loadstring() ✓   require() ✗ (blocked)")
    addMsg("SYSTEM","History nav: ↑ / ↓ arrow keys in command bar.")
    addMsg("SYSTEM","Drag: hold & drag title bar.  Min: ▂  Close: ✕")
    addMsg("SYSTEM","══════════════════════════════════════════════════════")
    initBlock = false
    
    -- ── 7. Async game name ──
    task.spawn(function()
        local ok, info = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        end)
        initBlock = true
        if ok and info and info.Name then
            addMsg("SYSTEM","Game     : " .. tostring(info.Name))
        end
        initBlock = false
    end)
end)
