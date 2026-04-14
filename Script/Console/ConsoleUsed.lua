-- ╔══════════════════════════════════════════════════════════════╗
-- ║   Console Used  v2.0  ─  by HaZcK                           ║
-- ║   Delta / Synapse compatible  ·  Mobile-friendly            ║
-- ║                                                              ║
-- ║   NEW IN v2.0:                                               ║
-- ║   · Milestone notifications (auto-remove on scroll)         ║
-- ║   · /AdminConsole → player list, details, thumbnail         ║
-- ║   · JobId copy + teleport to target server                   ║
-- ║   · Server mode detection (ConsoleScript check)             ║
-- ║   · Permission-based: clone appearance, control player      ║
-- ║   · require() allowed in SERVER mode                        ║
-- ║   · Auto USERNAME-PLAYER → target name in require()         ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ─────────────────────────────────────────────────────────────
--  NOTE: For full cross-player features (control, permission),
--  place "ConsoleScript" (Script) in ServerScriptService with:
--
--    local RS = game:GetService("ReplicatedStorage")
--    local R = Instance.new("RemoteEvent",RS); R.Name="CU_Bridge"
--    R.OnServerEvent:Connect(function(sender,t,a,b)
--        local tp=game.Players:GetPlayerByUserId(a)
--        if tp then R:FireClient(tp,t,sender.UserId,sender.Name,b) end
--    end)
--
--  Without ConsoleScript → CLIENT mode (still mirrors all logs)
-- ─────────────────────────────────────────────────────────────

local Players         = game:GetService("Players")
local UIS             = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local LogService      = game:GetService("LogService")
local RunService      = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local LP   = Players.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui")

pcall(function()
    for _,n in ipairs({"ConsoleUsed_v1","ConsoleUsed_v2"}) do
        local o = PGui:FindFirstChild(n); if o then o:Destroy() end
    end
end)

-- ══════════════════════  PALETTE  ══════════════════════════
local P = {
    bg1  = Color3.fromRGB(7,   7,  10),
    bg2  = Color3.fromRGB(13,  13, 17),
    bg3  = Color3.fromRGB(18,  18, 23),
    bg4  = Color3.fromRGB(26,  26, 34),
    acc  = Color3.fromRGB(0,   215, 165),
    txt  = Color3.fromRGB(200, 200, 218),
    dim  = Color3.fromRGB(58,  58,  80),
    err  = Color3.fromRGB(255, 72,  72),
    warn = Color3.fromRGB(255, 188, 42),
    ok   = Color3.fromRGB(75,  225, 130),
    sys  = Color3.fromRGB(90,  172, 255),
    out  = Color3.fromRGB(178, 178, 204),
    mile = Color3.fromRGB(255, 215, 80),
}

-- ══════════════════════  STATE  ════════════════════════════
local msgs, msgN     = {}, 0
local fErr,fWarn     = true,true
local fOut,fSys      = true,true
local hist, histI    = {}, 0
local initBlock      = false
local isServerMode   = false
local selectedTarget = nil
local controlTarget  = nil
local controlConn    = nil
local joinTimes      = {}
local CUBridge       = nil  -- RemoteEvent for cross-player comms
local pendingPerm    = nil  -- pending permission request info
local TitleLabel     = nil  -- reference updated later

local LOCALE_TZ = {
    ["id-id"]={n="WIB",o=7},   ["en-us"]={n="EST",o=-5},
    ["en-gb"]={n="GMT",o=0},   ["ja-jp"]={n="JST",o=9},
    ["ko-kr"]={n="KST",o=9},   ["zh-cn"]={n="CST",o=8},
    ["zh-tw"]={n="CST",o=8},   ["de-de"]={n="CET",o=1},
    ["fr-fr"]={n="CET",o=1},   ["pt-br"]={n="BRT",o=-3},
    ["es-es"]={n="CET",o=1},   ["ru-ru"]={n="MSK",o=3},
    ["tr-tr"]={n="TRT",o=3},   ["th-th"]={n="ICT",o=7},
    ["vi-vn"]={n="ICT",o=7},   ["ms-my"]={n="MYT",o=8},
    ["pl-pl"]={n="CET",o=1},   ["it-it"]={n="CET",o=1},
    ["es-mx"]={n="CST",o=-6},  ["ar-001"]={n="AST",o=3},
    ["nl-nl"]={n="CET",o=1},   ["sv-se"]={n="CET",o=1},
    ["fi-fi"]={n="EET",o=2},   ["nb-no"]={n="CET",o=1},
}

-- ══════════════════════  UI HELPERS  ═══════════════════════
local function corner(o,r)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 6); c.Parent=o; return c
end
local function stroke(o,col,th,tr)
    local s=Instance.new("UIStroke"); s.Color=col or P.dim
    s.Thickness=th or 1; s.Transparency=tr or 0; s.Parent=o; return s
end
local function frame(par,bg,sz,pos,zi)
    local f=Instance.new("Frame"); f.BackgroundColor3=bg; f.BorderSizePixel=0
    f.Size=sz; f.Position=pos or UDim2.new(0,0,0,0); f.ZIndex=zi or 10; f.Parent=par; return f
end
local function label(par,txt,tsz,font,col,sz,pos,zi,xa)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1
    l.Text=txt or ""; l.TextSize=tsz or 13; l.Font=font or Enum.Font.Code
    l.TextColor3=col or P.txt; l.Size=sz or UDim2.new(1,0,1,0)
    l.Position=pos or UDim2.new(0,0,0,0); l.ZIndex=zi or 11
    l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.BorderSizePixel=0; l.Parent=par; return l
end
local function btn(par,txt,bg,tc,sz,pos,zi)
    local b=Instance.new("TextButton"); b.BackgroundColor3=bg or P.bg4
    b.BorderSizePixel=0; b.Text=txt or ""; b.TextColor3=tc or P.txt
    b.TextSize=11; b.Font=Enum.Font.Code; b.Size=sz or UDim2.new(0,60,0,20)
    b.Position=pos or UDim2.new(0,0,0,0); b.ZIndex=zi or 12
    b.AutoButtonColor=false; b.Parent=par; corner(b,3)
    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(38,38,50)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=bg or P.bg4}):Play()
    end)
    return b
end
local function textbox(par,ph,sz,pos,zi)
    local t=Instance.new("TextBox"); t.BackgroundTransparency=1
    t.PlaceholderText=ph or ""; t.Text=""; t.TextColor3=P.txt
    t.PlaceholderColor3=P.dim; t.TextSize=12; t.Font=Enum.Font.Code
    t.TextXAlignment=Enum.TextXAlignment.Left; t.ClearTextOnFocus=false
    t.MultiLine=false; t.BorderSizePixel=0; t.Size=sz; t.Position=pos
    t.ZIndex=zi or 12; t.Parent=par; return t
end
local function draggable(handle,target)
    local drag,ds,ts=false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=i.Position; ts=target.Position
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-ds
            target.Position=UDim2.new(ts.X.Scale,ts.X.Offset+d.X,ts.Y.Scale,ts.Y.Offset+d.Y)
        end
    end)
end

-- ═══════════════════════  SCREEN GUI  ══════════════════════
local SG=Instance.new("ScreenGui")
SG.Name="ConsoleUsed_v2"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset=true; SG.Parent=PGui

-- ═══════════════════  LOADING SCREEN  ══════════════════════
local LF=frame(SG,P.bg1,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),50)
for i=0,20 do
    local ln=frame(LF,Color3.fromRGB(18,18,24),UDim2.new(1,0,0,1),UDim2.new(0,0,0,i*40),51)
    ln.BackgroundTransparency=0.85
end
local LTitle=label(LF,"",52,Enum.Font.Code,P.acc,
    UDim2.new(0,640,0,80),UDim2.new(0.5,-320,0.5,-100),53)
LTitle.RichText=true
local LSub=label(LF,"",13,Enum.Font.Code,P.dim,
    UDim2.new(0,520,0,24),UDim2.new(0.5,-260,0.5,5),53)
local LPTrack=frame(LF,P.bg4,UDim2.new(0,440,0,3),UDim2.new(0.5,-220,0.5,48),53)
corner(LPTrack,2)
local LPFill=frame(LPTrack,P.acc,UDim2.new(0,0,1,0),UDim2.new(0,0,0,0),54)
corner(LPFill,2)
local LPGlow=frame(LF,P.acc,UDim2.new(0,0,0,7),UDim2.new(0.5,-220,0.5,47),52)
LPGlow.BackgroundTransparency=0.88
local LScan=frame(LF,P.acc,UDim2.new(1,0,0,1),UDim2.new(0,0,0,0),54)
LScan.BackgroundTransparency=0.78
local LVer=label(LF,"Console Used  v2.0  ─  by HaZcK",12,Enum.Font.Code,
    Color3.fromRGB(24,24,36),UDim2.new(1,0,0,24),UDim2.new(0,0,1,-32),52,
    Enum.TextXAlignment.Center)

-- ═══════════════════  MAIN FRAME  ══════════════════════════
local MF=frame(SG,P.bg1,UDim2.new(0,740,0,530),UDim2.new(0.5,-370,0.5,-265),10)
MF.Visible=false; corner(MF,8); stroke(MF,Color3.fromRGB(0,130,100),1,0.45)

-- ─── TITLE BAR ───────────────────────────────────────────
local TB=frame(MF,P.bg2,UDim2.new(1,0,0,38),UDim2.new(0,0,0,0),11)
corner(TB,8)
frame(TB,P.bg2,UDim2.new(1,0,0.5,0),UDim2.new(0,0,0.5,0),11)
frame(TB,P.acc,UDim2.new(1,0,0,1),UDim2.new(0,0,1,-1),12).BackgroundTransparency=0.65
local function dot(x,c) local d=frame(TB,c,UDim2.new(0,11,0,11),UDim2.new(0,x,0.5,-5.5),12); corner(d,10); return d end
dot(10,Color3.fromRGB(255,85,75)); dot(25,Color3.fromRGB(255,185,28)); dot(40,Color3.fromRGB(42,200,88))

TitleLabel = label(TB,"Console Used",14,Enum.Font.GothamBold,P.acc,
    UDim2.new(1,-200,1,0),UDim2.new(0,58,0,0),12)

local ModeBadge=frame(TB,P.bg4,UDim2.new(0,90,0,20),UDim2.new(0,210,0.5,-10),13)
corner(ModeBadge,4)
local ModeLbl=label(ModeBadge,"CLIENT",11,Enum.Font.GothamBold,P.dim,
    UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),14,Enum.TextXAlignment.Center)

local function mkWinBtn(xoff,bg,txt,tc)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(0,34,0,24)
    b.Position=UDim2.new(1,xoff,0.5,-12); b.BackgroundColor3=bg
    b.Text=txt; b.TextColor3=tc; b.TextSize=13; b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0; b.AutoButtonColor=false; b.ZIndex=13; b.Parent=TB; corner(b,4)
    return b
end
local BClose=mkWinBtn(-39,Color3.fromRGB(50,22,22),"✕",P.err)
local BMin  =mkWinBtn(-77,Color3.fromRGB(44,38,18),"▂",P.warn)

BClose.MouseEnter:Connect(function() TweenService:Create(BClose,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(180,40,40)}):Play() end)
BClose.MouseLeave:Connect(function() TweenService:Create(BClose,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(50,22,22)}):Play() end)
BMin.MouseEnter:Connect(function() TweenService:Create(BMin,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(160,120,20)}):Play() end)
BMin.MouseLeave:Connect(function() TweenService:Create(BMin,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(44,38,18)}):Play() end)
draggable(TB,MF)

-- ─── TOOLBAR ─────────────────────────────────────────────
local TOOL=frame(MF,P.bg2,UDim2.new(1,0,0,30),UDim2.new(0,0,0,38),11)
frame(TOOL,Color3.fromRGB(28,28,38),UDim2.new(1,0,0,1),UDim2.new(0,0,1,-1),12)
local BClear=btn(TOOL," CLEAR ",P.bg4,P.txt,UDim2.new(0,52,0,20),UDim2.new(0,8,0.5,-10),12)
local BErr  =btn(TOOL,"ERR:ON",P.bg4,P.err, UDim2.new(0,58,0,20),UDim2.new(0,68,0.5,-10),12)
local BWarn =btn(TOOL,"WRN:ON",P.bg4,P.warn,UDim2.new(0,58,0,20),UDim2.new(0,134,0.5,-10),12)
local BOut  =btn(TOOL,"OUT:ON",P.bg4,P.out, UDim2.new(0,58,0,20),UDim2.new(0,200,0.5,-10),12)
local BSys  =btn(TOOL,"SYS:ON",P.bg4,P.sys, UDim2.new(0,58,0,20),UDim2.new(0,266,0.5,-10),12)
local MsgCtr=label(TOOL,"0 msgs",11,Enum.Font.Code,P.dim,
    UDim2.new(0,90,1,0),UDim2.new(1,-96,0,0),12,Enum.TextXAlignment.Right)

-- ─── CONSOLE SCROLL AREA ─────────────────────────────────
local ConFrame=frame(MF,P.bg3,UDim2.new(1,-16,0,376),UDim2.new(0,8,0,76),11)
corner(ConFrame,5); stroke(ConFrame,Color3.fromRGB(28,28,40),1,0)
local ConScroll=Instance.new("ScrollingFrame")
ConScroll.Size=UDim2.new(1,-6,1,-6); ConScroll.Position=UDim2.new(0,3,0,3)
ConScroll.BackgroundTransparency=1; ConScroll.BorderSizePixel=0
ConScroll.ScrollBarThickness=4; ConScroll.ScrollBarImageColor3=P.acc
ConScroll.ScrollBarImageTransparency=0.4; ConScroll.CanvasSize=UDim2.new(0,0,0,0)
ConScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; ConScroll.ZIndex=12
ConScroll.Parent=ConFrame
local ConLayout=Instance.new("UIListLayout")
ConLayout.SortOrder=Enum.SortOrder.LayoutOrder; ConLayout.Padding=UDim.new(0,0)
ConLayout.Parent=ConScroll
local ConPad=Instance.new("UIPadding")
ConPad.PaddingLeft=UDim.new(0,5); ConPad.PaddingRight=UDim.new(0,5)
ConPad.PaddingTop=UDim.new(0,3); ConPad.PaddingBottom=UDim.new(0,3)
ConPad.Parent=ConScroll

-- ─── COMMAND BAR ─────────────────────────────────────────
local CmdFrame=frame(MF,P.bg3,UDim2.new(1,-16,0,36),UDim2.new(0,8,1,-62),11)
corner(CmdFrame,5)
local CmdSt=stroke(CmdFrame,Color3.fromRGB(28,28,40),1,0.5)
local CmdPre=label(CmdFrame," ❯",15,Enum.Font.Code,P.acc,UDim2.new(0,28,1,0),UDim2.new(0,0,0,0),12)
local CmdBox=Instance.new("TextBox")
CmdBox.BackgroundTransparency=1; CmdBox.Size=UDim2.new(1,-78,1,-6)
CmdBox.Position=UDim2.new(0,28,0,3); CmdBox.Text=""
CmdBox.PlaceholderText="Lua code...  loadstring() ✓  ·  /AdminConsole  ·  ↑↓ history"
CmdBox.TextColor3=P.txt; CmdBox.PlaceholderColor3=P.dim; CmdBox.TextSize=12
CmdBox.Font=Enum.Font.Code; CmdBox.TextXAlignment=Enum.TextXAlignment.Left
CmdBox.ClearTextOnFocus=false; CmdBox.MultiLine=false; CmdBox.BorderSizePixel=0
CmdBox.ZIndex=12; CmdBox.Parent=CmdFrame
local BRun=Instance.new("TextButton")
BRun.BackgroundColor3=P.acc; BRun.BorderSizePixel=0; BRun.Text="RUN"
BRun.TextColor3=P.bg1; BRun.TextSize=11; BRun.Font=Enum.Font.GothamBold
BRun.Size=UDim2.new(0,44,0,24); BRun.Position=UDim2.new(1,-50,0.5,-12)
BRun.ZIndex=12; BRun.AutoButtonColor=false; BRun.Parent=CmdFrame; corner(BRun,4)

-- ─── STATUS BAR ──────────────────────────────────────────
local StatBar=frame(MF,P.bg2,UDim2.new(1,0,0,22),UDim2.new(0,0,1,-22),11)
corner(StatBar,8); frame(StatBar,P.bg2,UDim2.new(1,0,0.5,0),UDim2.new(0,0,0,0),11)
frame(StatBar,Color3.fromRGB(28,28,38),UDim2.new(1,0,0,1),UDim2.new(0,0,0,0),12)
local StatTxt=label(StatBar,"Ready",11,Enum.Font.Code,P.dim,
    UDim2.new(0.7,0,1,0),UDim2.new(0,10,0,0),12)
label(StatBar,"Console Used v2.0  ",11,Enum.Font.Code,
    Color3.fromRGB(30,30,46),UDim2.new(0.3,0,1,0),UDim2.new(0.7,0,0,0),12,
    Enum.TextXAlignment.Right)

-- ═══════════════  ADMIN CONSOLE PANEL  ═════════════════════
local AC=frame(SG,P.bg1,UDim2.new(0,660,0,440),UDim2.new(0.5,-330,0.5,-220),20)
AC.Visible=false; corner(AC,8); stroke(AC,Color3.fromRGB(0,100,75),1,0.4)

local ACTB=frame(AC,P.bg2,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),21)
corner(ACTB,8); frame(ACTB,P.bg2,UDim2.new(1,0,0.5,0),UDim2.new(0,0,0.5,0),21)
frame(ACTB,P.acc,UDim2.new(1,0,0,1),UDim2.new(0,0,1,-1),22).BackgroundTransparency=0.7
dot(10,Color3.fromRGB(255,85,75)) -- reuse dot function on ACTB
label(ACTB," ⚙  ADMIN CONSOLE  ─  PlaceId: "..tostring(game.PlaceId),
    12,Enum.Font.Code,P.acc,UDim2.new(1,-80,1,0),UDim2.new(0,0,0,0),22)
local ACClose=Instance.new("TextButton")
ACClose.Size=UDim2.new(0,34,0,24); ACClose.Position=UDim2.new(1,-39,0.5,-12)
ACClose.BackgroundColor3=Color3.fromRGB(50,22,22); ACClose.Text="✕"
ACClose.TextColor3=P.err; ACClose.TextSize=13; ACClose.Font=Enum.Font.GothamBold
ACClose.BorderSizePixel=0; ACClose.AutoButtonColor=false; ACClose.ZIndex=23; ACClose.Parent=ACTB
corner(ACClose,4)
draggable(ACTB,AC)

-- JobId bar
local JBar=frame(AC,P.bg3,UDim2.new(1,-16,0,58),UDim2.new(0,8,0,44),21)
corner(JBar,5); stroke(JBar,Color3.fromRGB(28,28,40),1,0)
label(JBar,"  CURRENT SERVER JOB ID :",11,Enum.Font.Code,P.dim,
    UDim2.new(1,-100,0,18),UDim2.new(0,0,0,0),22)

local JIdBox=frame(JBar,P.bg4,UDim2.new(1,-110,0,20),UDim2.new(0,6,0,18),22)
corner(JIdBox,3)
local JIdLbl=label(JIdBox,"  "..tostring(game.JobId),11,Enum.Font.Code,P.sys,
    UDim2.new(1,-36,1,0),UDim2.new(0,0,0,0),23)
local BJCopy=btn(JBar,"📋 COPY",P.acc,P.bg1,UDim2.new(0,80,0,20),UDim2.new(1,-88,0,18),23)

-- Teleport input
local TpFrame=frame(AC,P.bg3,UDim2.new(1,-16,0,30),UDim2.new(0,8,0,110),21)
corner(TpFrame,5); stroke(TpFrame,Color3.fromRGB(28,28,40),1,0)
label(TpFrame,"  ❯",14,Enum.Font.Code,P.warn,UDim2.new(0,22,1,0),UDim2.new(0,0,0,0),22)
local TpBox=textbox(TpFrame,"Paste JobId here → press Enter or click GO  (teleports to that server)",
    UDim2.new(1,-82,1,-6),UDim2.new(0,26,0,3),22)
local BTpGo=btn(TpFrame,"▶ GO",Color3.fromRGB(180,110,0),P.bg1,
    UDim2.new(0,58,0,22),UDim2.new(1,-64,0.5,-11),23)
local BTpGoStk=stroke(TpFrame,P.warn,1,0.4)

-- Player list (left column)
local PLFrame=frame(AC,P.bg3,UDim2.new(0,180,1,-155),UDim2.new(0,8,0,148),21)
corner(PLFrame,5); stroke(PLFrame,Color3.fromRGB(28,28,40),1,0)
label(PLFrame,"  PLAYERS",11,Enum.Font.GothamBold,P.acc,
    UDim2.new(1,0,0,22),UDim2.new(0,0,0,0),22)
frame(PLFrame,Color3.fromRGB(28,28,40),UDim2.new(1,0,0,1),UDim2.new(0,0,0,22),22)
local PLScroll=Instance.new("ScrollingFrame")
PLScroll.Size=UDim2.new(1,0,1,-24); PLScroll.Position=UDim2.new(0,0,0,24)
PLScroll.BackgroundTransparency=1; PLScroll.BorderSizePixel=0
PLScroll.ScrollBarThickness=3; PLScroll.ScrollBarImageColor3=P.acc
PLScroll.CanvasSize=UDim2.new(0,0,0,0); PLScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
PLScroll.ZIndex=22; PLScroll.Parent=PLFrame
local PLLayout=Instance.new("UIListLayout")
PLLayout.SortOrder=Enum.SortOrder.LayoutOrder; PLLayout.Padding=UDim.new(0,1)
PLLayout.Parent=PLScroll

-- Player detail (right column)
local PDFrame=frame(AC,P.bg3,UDim2.new(1,-204,1,-155),UDim2.new(0,196,0,148),21)
corner(PDFrame,5); stroke(PDFrame,Color3.fromRGB(28,28,40),1,0)

local PDThumb=frame(PDFrame,P.bg4,UDim2.new(0,80,0,80),UDim2.new(0,10,0,8),22)
corner(PDThumb,6); stroke(PDThumb,Color3.fromRGB(0,130,100),1,0.5)
local PDThumbImg=Instance.new("ImageLabel")
PDThumbImg.Size=UDim2.new(1,0,1,0); PDThumbImg.BackgroundTransparency=1
PDThumbImg.Image=""; PDThumbImg.ZIndex=23; PDThumbImg.Parent=PDThumb
corner(PDThumbImg,6)

local PDInfo=frame(PDFrame,Color3.fromRGB(0,0,0),
    UDim2.new(1,-105,1,-110),UDim2.new(0,100,0,8),22)
PDInfo.BackgroundTransparency=1
local PDScroll=Instance.new("ScrollingFrame")
PDScroll.Size=UDim2.new(1,0,1,-100); PDScroll.Position=UDim2.new(0,0,0,0)
PDScroll.BackgroundTransparency=1; PDScroll.BorderSizePixel=0
PDScroll.ScrollBarThickness=2; PDScroll.ScrollBarImageColor3=P.acc
PDScroll.CanvasSize=UDim2.new(0,0,0,0); PDScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
PDScroll.ZIndex=22; PDScroll.Parent=PDFrame
PDScroll.Size=UDim2.new(1,-10,1,-110); PDScroll.Position=UDim2.new(0,5,0,95)
local PDLayout=Instance.new("UIListLayout"); PDLayout.Padding=UDim.new(0,2); PDLayout.Parent=PDScroll

local PDNoSel=label(PDFrame,"Select a player →",13,Enum.Font.Code,P.dim,
    UDim2.new(1,-110,1,-110),UDim2.new(0,100,0,8),22)

-- Control buttons bar
local CBBar=frame(AC,P.bg2,UDim2.new(1,-16,0,32),UDim2.new(0,8,1,-40),21)
corner(CBBar,5); stroke(CBBar,Color3.fromRGB(28,28,40),1,0)
local BClone=btn(CBBar,"🎭 CLONE SKIN",P.bg4,P.ok,
    UDim2.new(0,110,0,22),UDim2.new(0,4,0.5,-11),22)
local BCtrl=btn(CBBar,"🕹 CONTROL",P.bg4,P.acc,
    UDim2.new(0,96,0,22),UDim2.new(0,122,0.5,-11),22)
local BStopCtrl=btn(CBBar,"⏹ STOP",P.bg4,P.err,
    UDim2.new(0,74,0,22),UDim2.new(0,226,0.5,-11),22)
BStopCtrl.Visible=false
local ACStatus=label(CBBar,"No player selected",11,Enum.Font.Code,P.dim,
    UDim2.new(0,200,1,0),UDim2.new(1,-208,0,0),22,Enum.TextXAlignment.Right)

-- ═══════════════  PERMISSION REQUEST UI  ═══════════════════
-- (Shown to the TARGET player when someone wants to control them)
local PermUI=frame(SG,P.bg1,UDim2.new(0,360,0,200),UDim2.new(0.5,-180,0.5,-100),30)
PermUI.Visible=false; corner(PermUI,10)
stroke(PermUI,P.warn,1,0.3)
local PermGrad=Instance.new("UIGradient")
PermGrad.Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(12,10,5)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(7,7,10)),
}
PermGrad.Rotation=135; PermGrad.Parent=PermUI

local PermIcon=label(PermUI,"⚠",38,Enum.Font.GothamBold,P.warn,
    UDim2.new(1,0,0,44),UDim2.new(0,0,0,12),31,Enum.TextXAlignment.Center)
local PermTitle=label(PermUI,"CHARACTER ACCESS REQUEST",14,Enum.Font.GothamBold,P.txt,
    UDim2.new(1,-20,0,22),UDim2.new(0,10,0,56),31,Enum.TextXAlignment.Center)
local PermMsg=label(PermUI,"",12,Enum.Font.Code,P.dim,
    UDim2.new(1,-20,0,42),UDim2.new(0,10,0,80),31,Enum.TextXAlignment.Center)
PermMsg.TextWrapped=true
local BPermYes=Instance.new("TextButton")
BPermYes.BackgroundColor3=Color3.fromRGB(20,80,50); BPermYes.BorderSizePixel=0
BPermYes.Text="  ✓  ALLOW  "; BPermYes.TextColor3=P.ok; BPermYes.TextSize=12
BPermYes.Font=Enum.Font.GothamBold; BPermYes.Size=UDim2.new(0,140,0,34)
BPermYes.Position=UDim2.new(0.5,-148,1,-46); BPermYes.ZIndex=31
BPermYes.AutoButtonColor=false; BPermYes.Parent=PermUI; corner(BPermYes,5)
stroke(BPermYes,P.ok,1,0.6)
local BPermNo=Instance.new("TextButton")
BPermNo.BackgroundColor3=Color3.fromRGB(80,15,15); BPermNo.BorderSizePixel=0
BPermNo.Text="  ✕  DENY  "; BPermNo.TextColor3=P.err; BPermNo.TextSize=12
BPermNo.Font=Enum.Font.GothamBold; BPermNo.Size=UDim2.new(0,140,0,34)
BPermNo.Position=UDim2.new(0.5,8,1,-46); BPermNo.ZIndex=31
BPermNo.AutoButtonColor=false; BPermNo.Parent=PermUI; corner(BPermNo,5)
stroke(BPermNo,P.err,1,0.6)

-- ═══════════════════════  CORE LOGIC  ══════════════════════

local typeColor = {ERROR="err",WARN="warn",OK="ok",SYSTEM="sys",PRINT="out",MILE="mile"}
local typePfx   = {ERROR="[ERR] ",WARN="[WRN] ",OK="[OK ] ",SYSTEM="[SYS] ",PRINT="[OUT] ",MILE="[───] "}

local function isVis(t)
    if t=="ERROR" then return fErr end
    if t=="WARN"  then return fWarn end
    if t=="PRINT" then return fOut  end
    if t=="MILE"  then return true  end
    return fSys
end

local function scrollBottom()
    task.defer(function()
        if ConScroll and ConScroll.Parent then
            ConScroll.CanvasPosition=Vector2.new(0,1e6)
        end
    end)
end

local function updateUI()
    local n=#msgs
    MsgCtr.Text=n.." msgs"
    StatTxt.Text=("Ready  │  %d msgs  │  %s"):format(n,os.date("%H:%M:%S"))
end

-- ─── addMsg ──────────────────────────────────────────────
local function addMsg(mtype, text)
    msgN+=1
    if #msgs>=600 then
        local old=table.remove(msgs,1)
        if old.lbl and old.lbl.Parent then old.lbl:Destroy() end
    end

    local col=P[typeColor[mtype]] or P.out
    local pfx=typePfx[mtype] or "[OUT] "
    local ts=os.date("[%H:%M:%S] ")

    local isMile=(mtype=="MILE")
    local row=Instance.new("TextLabel")
    row.BackgroundTransparency=isMile and 0.82 or 1
    if isMile then row.BackgroundColor3=Color3.fromRGB(50,40,10) end
    row.Size=UDim2.new(1,-2,0,0)
    row.AutomaticSize=Enum.AutomaticSize.Y
    if isMile then
        row.Text=text
    else
        row.Text=ts..pfx..tostring(text)
    end
    row.TextColor3=col
    row.TextSize=isMile and 13 or 12
    row.Font=isMile and Enum.Font.GothamBold or Enum.Font.Code
    row.TextXAlignment=Enum.TextXAlignment.Left
    row.TextWrapped=true
    row.Visible=isVis(mtype)
    row.LayoutOrder=msgN
    row.ZIndex=13
    if isMile then corner(row,3) end
    row.Parent=ConScroll

    table.insert(msgs,{type=mtype,lbl=row})

    -- Auto-remove milestone row when scrolled above viewport
    if isMile then
        local conn; conn=ConScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if not row.Parent then if conn then conn:Disconnect() end return end
            local rowBot=row.AbsolutePosition.Y+row.AbsoluteSize.Y
            local viewTop=ConScroll.AbsolutePosition.Y
            if rowBot<viewTop then
                TweenService:Create(row,TweenInfo.new(0.3),{TextTransparency=1,BackgroundTransparency=1}):Play()
                task.delay(0.32,function() pcall(function() row:Destroy() end) end)
                conn:Disconnect()
            end
        end)
    end

    scrollBottom(); updateUI()

    -- Milestone check
    local n=#msgs
    if n>0 and n%100==0 and not isMile then
        task.defer(function()
            local milestone=n
            local bar=("─"):rep(20)
            addMsg("MILE","  "..bar.."  🎯  "..milestone.." MESSAGES REACHED  "..bar.."  ")
        end)
    end
end

-- ─── Server Mode Detection ────────────────────────────────
local function detectServerMode()
    local locs={
        game:GetService("ServerScriptService"),
        workspace,
        game:GetService("ReplicatedStorage"),
    }
    for _,loc in ipairs(locs) do
        local ok,res=pcall(function()
            return loc:FindFirstChild("ConsoleScript")~=nil
        end)
        if ok and res then return true end
    end
    return false
end

local function applyServerMode(sm)
    isServerMode=sm
    if sm then
        TitleLabel.Text="ConsoleDev [SERVER🧾]"
        TitleLabel.TextColor3=P.ok
        ModeLbl.Text="SERVER 🧾"
        ModeLbl.TextColor3=P.ok
        ModeBadge.BackgroundColor3=Color3.fromRGB(14,42,28)
    else
        TitleLabel.Text="Console Used"
        TitleLabel.TextColor3=P.acc
        ModeLbl.Text="CLIENT"
        ModeLbl.TextColor3=P.dim
        ModeBadge.BackgroundColor3=P.bg4
    end
end

-- ─── Remote Bridge Setup ─────────────────────────────────
local function setupBridge()
    local RS=game:GetService("ReplicatedStorage")
    local ok,res=pcall(function()
        return RS:WaitForChild("CU_Bridge",2)
    end)
    if ok and res then
        CUBridge=res
        -- Listen for incoming messages
        CUBridge.OnClientEvent:Connect(function(msgType, senderUID, senderName, data)
            if msgType=="PERMISSION_REQUEST" then
                -- Someone wants to control us
                PermMsg.Text='"'..tostring(senderName)..'" wants to take full\ncontrol of your character.\n\nAllows: Move · Clone Appearance'
                pendingPerm={uid=senderUID, name=senderName}
                PermUI.Visible=true
                TweenService:Create(PermUI,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
                    Size=UDim2.new(0,360,0,200),Position=UDim2.new(0.5,-180,0.5,-100)
                }):Play()
            elseif msgType=="PERMISSION_RESPONSE" then
                if data==true then
                    addMsg("OK","Player "..tostring(senderName).." ALLOWED control access.")
                    -- start mirroring character
                    if selectedTarget then
                        controlTarget=selectedTarget
                        BStopCtrl.Visible=true
                        ACStatus.Text="Controlling: "..tostring(senderName)
                        startControlMirror()
                    end
                else
                    addMsg("WARN","Player "..tostring(senderName).." DENIED control access.")
                end
            elseif msgType=="CONTROL_UPDATE" then
                -- We are being controlled — move our character
                local char=LP.Character
                if char and char:FindFirstChild("HumanoidRootPart") and data then
                    local hum=char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:MoveTo(data) end) end
                end
            end
        end)
        return true
    end
    return false
end

-- ─── Control Mirror ──────────────────────────────────────
function startControlMirror()
    if controlConn then controlConn:Disconnect() end
    controlConn=RunService.Heartbeat:Connect(function()
        if not controlTarget or not controlTarget.Parent then
            controlConn:Disconnect(); return
        end
        local char=LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") and CUBridge then
            local pos=char.HumanoidRootPart.Position
            pcall(function()
                CUBridge:FireServer("CONTROL_UPDATE",controlTarget.UserId,pos)
            end)
        end
    end)
end

local function stopControl()
    if controlConn then controlConn:Disconnect(); controlConn=nil end
    controlTarget=nil
    BStopCtrl.Visible=false
    ACStatus.Text="Control stopped."
end

-- ─── Clone Appearance ────────────────────────────────────
local function cloneAppearance(target)
    if not target then addMsg("ERROR","No player selected."); return end
    local char=LP.Character
    if not char then addMsg("ERROR","Your character not found."); return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum then addMsg("ERROR","No Humanoid found."); return end
    addMsg("SYSTEM","Fetching appearance of "..target.Name.."...")
    task.spawn(function()
        local ok,desc=pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(target.UserId)
        end)
        if ok and desc then
            local ok2,err2=pcall(function() hum:ApplyDescription(desc) end)
            if ok2 then
                addMsg("OK","Appearance cloned from "..target.Name.." ✓")
            else
                addMsg("ERROR","ApplyDescription failed: "..tostring(err2))
            end
        else
            addMsg("ERROR","Could not fetch description: "..tostring(desc))
        end
    end)
end

-- ─── Request Control ─────────────────────────────────────
local function requestControl(target)
    if not target then addMsg("ERROR","No player selected."); return end
    if not CUBridge then
        addMsg("ERROR","SERVER MODE required for player control.")
        addMsg("WARN","Install ConsoleScript in ServerScriptService.")
        return
    end
    addMsg("SYSTEM","Sending control request to "..target.Name.."...")
    pcall(function()
        CUBridge:FireServer("PERMISSION_REQUEST",target.UserId)
    end)
end

-- ─── Player List Builder ──────────────────────────────────
local function buildPlayerList()
    -- Clear old rows
    for _,c in ipairs(PLScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local plist=Players:GetPlayers()
    for i,p in ipairs(plist) do
        local row=Instance.new("TextButton")
        row.BackgroundColor3=p==LP and Color3.fromRGB(20,32,28) or P.bg4
        row.BorderSizePixel=0; row.Text=""
        row.Size=UDim2.new(1,0,0,36); row.LayoutOrder=i
        row.ZIndex=23; row.Parent=PLScroll; row.AutoButtonColor=false
        -- Online dot
        local d=frame(row,p==LP and P.ok or P.acc,
            UDim2.new(0,8,0,8),UDim2.new(0,6,0.5,-4),24)
        corner(d,10)
        -- Name
        local nl=label(row,p.DisplayName,12,Enum.Font.GothamBold,P.txt,
            UDim2.new(1,-20,0,18),UDim2.new(0,18,0,2),24)
        label(row,"@"..p.Name,10,Enum.Font.Code,P.dim,
            UDim2.new(1,-20,0,14),UDim2.new(0,18,0,20),24)
        row.MouseEnter:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(28,40,34)}):Play()
        end)
        row.MouseLeave:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=p==LP and Color3.fromRGB(20,32,28) or P.bg4}):Play()
        end)
        row.MouseButton1Click:Connect(function()
            selectedTarget=p
            showPlayerDetail(p)
            ACStatus.Text="Selected: "..p.Name
        end)
    end
end

-- ─── Player Detail Panel ─────────────────────────────────
function showPlayerDetail(p)
    PDNoSel.Visible=false
    -- Clear old detail rows
    for _,c in ipairs(PDScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end

    -- Load thumbnail
    PDThumbImg.Image="rbxthumb://type=AvatarHeadShot&id="..p.UserId.."&w=100&h=100"

    -- Compute data
    local accountAge = p.AccountAge or 0
    local firstJoined = os.date("%d %b %Y", os.time() - accountAge*86400)
    local locale = pcall(function() return p.LocaleId end) and p.LocaleId or "unknown"
    local tz = LOCALE_TZ[locale]
    local tzStr = tz and (tz.n.." UTC"..((tz.o>=0 and "+" or "")..tz.o)) or "Unknown"
    local approxTime = "Unknown"
    if tz then
        local offsetSec=tz.o*3600
        local t=os.time()+offsetSec
        approxTime=os.date("!%H:%M",t)
    end

    local membership = tostring(p.MembershipType):match("%.(.+)") or "None"
    local teamName = p.Team and p.Team.Name or "None"
    local health="N/A"; local maxHp="N/A"; local pos="N/A"
    local char=p.Character
    if char then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then
            health=tostring(math.floor(hum.Health))
            maxHp=tostring(math.floor(hum.MaxHealth))
        end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if hrp then
            pos=("%.1f, %.1f, %.1f"):format(hrp.Position.X,hrp.Position.Y,hrp.Position.Z)
        end
    end

    local sessionStart=joinTimes[p.UserId]
    local sessionDur="Unknown"
    if sessionStart then
        local s=math.floor(os.time()-sessionStart)
        sessionDur=("%d:%02d"):format(math.floor(s/60),s%60).." min"
    end

    local lines = {
        {"Username",    p.Name},
        {"Display",     p.DisplayName},
        {"User ID",     tostring(p.UserId)},
        {"Membership",  membership},
        {"Acct Age",    accountAge.." days"},
        {"First Joined",firstJoined},
        {"Locale",      locale~="unknown" and locale or "N/A"},
        {"Timezone",    tzStr},
        {"Local ~Time", approxTime},
        {"Health",      health.." / "..maxHp},
        {"Position",    pos},
        {"Team",        teamName},
        {"In Session",  sessionDur},
        {"Same Server", "YES ─ "..tostring(game.JobId):sub(1,8).."..."},
    }

    for i,row in ipairs(lines) do
        local l=Instance.new("TextLabel")
        l.BackgroundTransparency=1; l.Size=UDim2.new(1,0,0,16)
        l.AutomaticSize=Enum.AutomaticSize.Y
        l.Text="  <font color='#3AACFF'>"..row[1].."</font>  <font color='#C8C8DA'>"..row[2].."</font>"
        l.RichText=true; l.TextSize=11; l.Font=Enum.Font.Code
        l.TextXAlignment=Enum.TextXAlignment.Left; l.TextWrapped=true
        l.LayoutOrder=i; l.ZIndex=23; l.Parent=PDScroll
        -- Alternate row shading
        if i%2==0 then l.BackgroundTransparency=0.92; l.BackgroundColor3=P.bg4 end
    end
end

-- ─── Open / Close AdminConsole ───────────────────────────
local ACOpen=false
local function openAdminConsole()
    ACOpen=true
    buildPlayerList()
    AC.Visible=true; AC.BackgroundTransparency=1
    AC.Position=UDim2.new(0.5,-330,0.44,-220)
    TweenService:Create(AC,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        BackgroundTransparency=0,Position=UDim2.new(0.5,-330,0.5,-220)
    }):Play()
    addMsg("SYSTEM","AdminConsole opened.  "..#Players:GetPlayers().." players in session.")
end

ACClose.MouseButton1Click:Connect(function()
    TweenService:Create(AC,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.In),{
        BackgroundTransparency=1,Position=UDim2.new(0.5,-330,0.44,-220)
    }):Play()
    task.delay(0.2,function() AC.Visible=false; ACOpen=false end)
end)

-- ─── Execute Command ─────────────────────────────────────
local execCmd  -- forward declare

execCmd = function(code)
    if not code or code:gsub("%s+","")=="" then return end

    -- History
    if hist[1]~=code then
        table.insert(hist,1,code)
        if #hist>100 then table.remove(hist) end
    end
    histI=0

    -- Built-in commands
    local cmd=code:lower():gsub("^%s+","")

    if cmd=="/adminconsole" or cmd=="adminconsole" then
        openAdminConsole(); return
    end
    if cmd=="/clear" or cmd=="clear()" then
        for _,m in ipairs(msgs) do
            if m.lbl and m.lbl.Parent then m.lbl:Destroy() end
        end
        msgs={}; msgN=0
        addMsg("SYSTEM","Console cleared."); return
    end
    if cmd=="/servermode" then
        local sm=detectServerMode()
        applyServerMode(sm)
        if sm then
            addMsg("SYSTEM","SYS: MODE SERVER [STILL BETA]")
            task.spawn(setupBridge)
        else
            addMsg("WARN","ConsoleScript not found — staying in CLIENT mode.")
        end
        return
    end

    addMsg("SYSTEM","❯ "..code)

    -- In client mode, block require()
    if not isServerMode and code:match("require%s*%(") then
        addMsg("ERROR","require() blocked in CLIENT mode.")
        addMsg("WARN","Use /ServerMode to enable, or use loadstring() instead.")
        return
    end

    -- Auto-replace USERNAME-PLAYER placeholder (server mode)
    if isServerMode and selectedTarget then
        code=code:gsub('"USERNAME%-PLAYER"', '"'..selectedTarget.Name..'"')
        code=code:gsub("'USERNAME%-PLAYER'", "'"..selectedTarget.Name.."'")
    end

    local fn,cerr=loadstring(code)
    if not fn then addMsg("ERROR","Syntax: "..tostring(cerr)); return end

    local ok,rerr=pcall(fn)
    if ok then addMsg("OK","Executed successfully.")
    else       addMsg("ERROR","Runtime: "..tostring(rerr)) end
end

-- ══════════════════  TOOLBAR EVENTS  ═══════════════════════
BClear.MouseButton1Click:Connect(function()
    for _,m in ipairs(msgs) do
        if m.lbl and m.lbl.Parent then m.lbl:Destroy() end
    end
    msgs={}; msgN=0; addMsg("SYSTEM","Console cleared.")
end)
local function toggle(state,tbtn,mtype,onCol,offLabel,onLabel)
    return function()
        local new=not state
        tbtn.Text=new and onLabel or offLabel
        tbtn.TextColor3=new and onCol or P.dim
        for _,m in ipairs(msgs) do
            if m.type==mtype and m.lbl then m.lbl.Visible=new end
        end
        return new
    end
end
BErr.MouseButton1Click:Connect(function()
    fErr=not fErr; BErr.Text="ERR:"..(fErr and "ON" or "OFF")
    BErr.TextColor3=fErr and P.err or P.dim
    for _,m in ipairs(msgs) do if m.type=="ERROR" and m.lbl then m.lbl.Visible=fErr end end
end)
BWarn.MouseButton1Click:Connect(function()
    fWarn=not fWarn; BWarn.Text="WRN:"..(fWarn and "ON" or "OFF")
    BWarn.TextColor3=fWarn and P.warn or P.dim
    for _,m in ipairs(msgs) do if m.type=="WARN" and m.lbl then m.lbl.Visible=fWarn end end
end)
BOut.MouseButton1Click:Connect(function()
    fOut=not fOut; BOut.Text="OUT:"..(fOut and "ON" or "OFF")
    BOut.TextColor3=fOut and P.out or P.dim
    for _,m in ipairs(msgs) do if m.type=="PRINT" and m.lbl then m.lbl.Visible=fOut end end
end)
BSys.MouseButton1Click:Connect(function()
    fSys=not fSys; BSys.Text="SYS:"..(fSys and "ON" or "OFF")
    BSys.TextColor3=fSys and P.sys or P.dim
    for _,m in ipairs(msgs) do
        if (m.type=="SYSTEM" or m.type=="OK") and m.lbl then m.lbl.Visible=fSys end
    end
end)

-- ══════════════════  CMDBOX EVENTS  ════════════════════════
CmdBox.Focused:Connect(function()
    TweenService:Create(CmdSt,TweenInfo.new(0.18),{Color=P.acc,Transparency=0.15}):Play()
    TweenService:Create(CmdPre,TweenInfo.new(0.18),{TextColor3=Color3.fromRGB(0,255,200)}):Play()
end)
CmdBox.FocusLost:Connect(function(enter)
    TweenService:Create(CmdSt,TweenInfo.new(0.18),{Color=Color3.fromRGB(28,28,40),Transparency=0.5}):Play()
    TweenService:Create(CmdPre,TweenInfo.new(0.18),{TextColor3=P.acc}):Play()
    if enter then local c=CmdBox.Text; CmdBox.Text=""; task.spawn(execCmd,c) end
end)
BRun.MouseButton1Click:Connect(function()
    local c=CmdBox.Text; CmdBox.Text=""; task.spawn(execCmd,c)
end)
BRun.MouseEnter:Connect(function() TweenService:Create(BRun,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(0,255,200)}):Play() end)
BRun.MouseLeave:Connect(function() TweenService:Create(BRun,TweenInfo.new(0.12),{BackgroundColor3=P.acc}):Play() end)

-- History nav
UIS.InputBegan:Connect(function(inp,gp)
    if not CmdBox:IsFocused() then return end
    if inp.KeyCode==Enum.KeyCode.Up then
        histI=math.min(histI+1,#hist)
        if hist[histI] then CmdBox.Text=hist[histI] end
        task.defer(function() CmdBox.CursorPosition=#CmdBox.Text+1 end)
    elseif inp.KeyCode==Enum.KeyCode.Down then
        histI=math.max(histI-1,0)
        CmdBox.Text=hist[histI] or ""
        task.defer(function() CmdBox.CursorPosition=#CmdBox.Text+1 end)
    end
end)

-- ══════════════════  ADMIN CONSOLE EVENTS  ═════════════════
BJCopy.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(tostring(game.JobId)) end)
    addMsg("OK","JobId copied to clipboard.")
    BJCopy.Text="✓ COPIED"
    task.delay(1.5,function() BJCopy.Text="📋 COPY" end)
end)

TpBox.FocusLost:Connect(function(enter)
    if enter then
        local jid=TpBox.Text:gsub("%s+","")
        if #jid>8 then
            addMsg("SYSTEM","Teleporting to server: "..jid:sub(1,12).."...")
            task.spawn(function()
                local ok,err=pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, jid, LP)
                end)
                if not ok then addMsg("ERROR","Teleport failed: "..tostring(err)) end
            end)
        end
    end
end)
BTpGo.MouseButton1Click:Connect(function()
    local jid=TpBox.Text:gsub("%s+","")
    if #jid>8 then
        addMsg("SYSTEM","Teleporting to server: "..jid:sub(1,12).."...")
        task.spawn(function()
            local ok,err=pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, jid, LP)
            end)
            if not ok then addMsg("ERROR","Teleport failed: "..tostring(err)) end
        end)
    else addMsg("ERROR","Invalid JobId (too short).") end
end)
BTpGo.MouseEnter:Connect(function() TweenService:Create(BTpGoStk,TweenInfo.new(0.12),{Transparency=0,Color=P.warn}):Play() end)
BTpGo.MouseLeave:Connect(function() TweenService:Create(BTpGoStk,TweenInfo.new(0.12),{Transparency=0.4,Color=P.warn}):Play() end)

BClone.MouseButton1Click:Connect(function() cloneAppearance(selectedTarget) end)
BCtrl.MouseButton1Click:Connect(function() requestControl(selectedTarget) end)
BStopCtrl.MouseButton1Click:Connect(stopControl)

-- ── Permission buttons ──────────────────────────────────
BPermYes.MouseButton1Click:Connect(function()
    PermUI.Visible=false
    if pendingPerm and CUBridge then
        pcall(function()
            CUBridge:FireServer("PERMISSION_RESPONSE", pendingPerm.uid, true)
        end)
        addMsg("OK","Allowed control access to "..tostring(pendingPerm.name)..".")
    end
    pendingPerm=nil
end)
BPermNo.MouseButton1Click:Connect(function()
    PermUI.Visible=false
    if pendingPerm and CUBridge then
        pcall(function()
            CUBridge:FireServer("PERMISSION_RESPONSE", pendingPerm.uid, false)
        end)
        addMsg("WARN","Denied control access to "..tostring(pendingPerm.name)..".")
    end
    pendingPerm=nil
end)

-- ── Window controls ─────────────────────────────────────
BClose.MouseButton1Click:Connect(function()
    TweenService:Create(MF,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.In),{
        Size=UDim2.new(0,740,0,0),BackgroundTransparency=1
    }):Play()
    task.delay(0.22,function() MF.Visible=false end)
end)
local minimized=false
BMin.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then
        for _,c in ipairs({ConFrame,TOOL,CmdFrame,StatBar}) do c.Visible=false end
        TweenService:Create(MF,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Size=UDim2.new(0,740,0,38)}):Play()
        BMin.Text="□"
    else
        TweenService:Create(MF,TweenInfo.new(0.22,Enum.EasingStyle.Quint),{Size=UDim2.new(0,740,0,530)}):Play()
        task.delay(0.23,function()
            for _,c in ipairs({ConFrame,TOOL,CmdFrame,StatBar}) do c.Visible=true end
        end)
        BMin.Text="▂"
    end
end)

-- ── LogService Hook ─────────────────────────────────────
pcall(function()
    LogService.MessageOut:Connect(function(msg,mtype)
        if initBlock then return end
        local t
        if     mtype==Enum.MessageType.MessageError   then t="ERROR"
        elseif mtype==Enum.MessageType.MessageWarning then t="WARN"
        elseif mtype==Enum.MessageType.MessageInfo    then t="SYSTEM"
        else                                               t="PRINT" end
        pcall(addMsg,t,msg)
    end)
end)

-- ── Track session join times ─────────────────────────────
for _,p in ipairs(Players:GetPlayers()) do
    joinTimes[p.UserId]=os.time()-math.random(5,60)
end
Players.PlayerAdded:Connect(function(p)
    joinTimes[p.UserId]=os.time()
    if AC.Visible then buildPlayerList() end
    if not initBlock then addMsg("SYSTEM","➕ "..p.Name.." joined the server.") end
end)
Players.PlayerRemoving:Connect(function(p)
    if not initBlock then addMsg("WARN","➖ "..p.Name.." left the server.") end
    if AC.Visible then task.defer(buildPlayerList) end
end)

-- ═══════════════  LOADING SEQUENCE  ════════════════════════

task.spawn(function()
    while LF and LF.Parent do
        LScan.Position=UDim2.new(0,0,0,0)
        TweenService:Create(LScan,TweenInfo.new(2.8,Enum.EasingStyle.Linear),{Position=UDim2.new(0,0,1,0)}):Play()
        task.wait(2.8)
    end
end)

task.spawn(function()
    local FULL="Console Used"
    for i=1,#FULL do LTitle.Text=FULL:sub(1,i); task.wait(0.072) end
    for _=1,4 do
        LTitle.Text=FULL.."<font color='#00D7A5'>█</font>"; task.wait(0.20)
        LTitle.Text=FULL; task.wait(0.20)
    end

    local steps={
        {0.15,"Initializing interface..."},
        {0.35,"Connecting LogService hook..."},
        {0.55,"Detecting server mode..."},
        {0.75,"Building command engine..."},
        {0.92,"Preparing output mirror..."},
        {1.00,"All systems ready."},
    }
    for _,s in ipairs(steps) do
        LSub.Text=s[2]
        TweenService:Create(LPFill,TweenInfo.new(0.48,Enum.EasingStyle.Quint),{Size=UDim2.new(s[1],0,1,0)}):Play()
        TweenService:Create(LPGlow,TweenInfo.new(0.48,Enum.EasingStyle.Quint),{Size=UDim2.new(s[1]*440/740,0,0,7)}):Play()
        task.wait(0.56)
    end
    task.wait(0.3)

    for _,o in ipairs({LTitle,LSub,LVer,LPTrack,LPFill,LPGlow}) do
        TweenService:Create(o,TweenInfo.new(0.38),{
            [o:IsA("TextLabel") and "TextTransparency" or "BackgroundTransparency"]=1
        }):Play()
    end
    TweenService:Create(LF,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play()
    task.wait(0.52); LF:Destroy()

    -- Reveal main GUI
    MF.Visible=true; MF.BackgroundTransparency=1
    MF.Position=UDim2.new(0.5,-370,0.56,-265)
    TweenService:Create(MF,TweenInfo.new(0.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        BackgroundTransparency=0,Position=UDim2.new(0.5,-370,0.5,-265)
    }):Play()
    task.wait(0.18)

    -- Detect server mode
    local sm=detectServerMode()
    applyServerMode(sm)

    -- Welcome log
    initBlock=true
    addMsg("SYSTEM","══════════════════════════════════════════════════════════")
    addMsg("SYSTEM","  Console Used v2.0  │  by HaZcK  │  Delta Compatible")
    addMsg("SYSTEM","══════════════════════════════════════════════════════════")
    addMsg("SYSTEM","PlaceId  : "..tostring(game.PlaceId))
    addMsg("SYSTEM","JobId    : "..tostring(game.JobId):sub(1,20).."...")
    addMsg("SYSTEM","Client   : "..LP.Name.."  (UID: "..LP.UserId..")")
    if sm then
        addMsg("SYSTEM","SYS: MODE SERVER [STILL BETA]")
        addMsg("OK","ConsoleScript detected → SERVER mode activated.")
    else
        addMsg("WARN","ConsoleScript not found → CLIENT mode. Type /ServerMode to recheck.")
    end
    addMsg("SYSTEM","──────────────────────────────────────────────────────────")
    addMsg("SYSTEM","Commands:  /AdminConsole  ·  /ServerMode  ·  /Clear")
    addMsg("SYSTEM","Bar:  loadstring() ✓  ·  require() ✓ (SERVER only)  ·  ↑↓ history")
    addMsg("SYSTEM","Milestones shown every 100 messages — scroll to dismiss.")
    addMsg("SYSTEM","══════════════════════════════════════════════════════════")
    initBlock=false

    -- Setup bridge if server mode
    if sm then task.spawn(setupBridge) end

    -- Async game name
    task.spawn(function()
        local ok,info=pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        end)
        initBlock=true
        if ok and info and info.Name then
            addMsg("SYSTEM","Game     : "..tostring(info.Name))
        end
        initBlock=false
    end)
end)
