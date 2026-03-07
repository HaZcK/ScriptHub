-- ╔══════════════════════════════════════════════════════════════╗
-- ║                DICE OF FATE — DiceLibrary.lua                ║
-- ║                     ENGINE — Jangan diedit                   ║
-- ║      Semua function ada di sini. Edit di DicePlayer.lua      ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")

local _Conns = {}
local function _save(k,c) if _Conns[k] then pcall(function() _Conns[k]:Disconnect() end) end _Conns[k]=c end
local function _drop(k)   if _Conns[k] then pcall(function() _Conns[k]:Disconnect() end) _Conns[k]=nil end end

local _Orig = {}
for _,p in ipairs(character:GetDescendants()) do
	if p:IsA("BasePart") then _Orig[p.Name]=p.Size end
end

local function _gc()
	character = player.Character or character
	humanoid  = character and character:FindFirstChildOfClass("Humanoid") or humanoid
	return character, humanoid
end

local TF = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
local TM = TweenInfo.new(0.28, Enum.EasingStyle.Quart)
local TB = TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local function _tw(o,p,t) TweenService:Create(o,t or TM,p):Play() end

-- Server
local _srv=false; local _RA,_RT,_RG=nil,nil,nil
local function _csrv()
	local pk=ReplicatedStorage:FindFirstChild("DICE_PING")
	if pk and pk:IsA("RemoteFunction") then
		local ok,r=pcall(function() return pk:InvokeServer() end)
		if ok and r==true then
			_srv=true
			_RA=ReplicatedStorage:FindFirstChild("DICE_ACTION")
			_RT=ReplicatedStorage:FindFirstChild("DICE_TRADE")
			_RG=ReplicatedStorage:FindFirstChild("DICE_GIVEGUI")
			return true
		end
	end
	_srv=false; return false
end

-- Kirim effect ke server
local function _fx(skillId, effectData)
	if _srv and _RA then
		pcall(function() _RA:FireServer("Effect", skillId, effectData) end)
	end
end
local function _stopLoop(skillId)
	if _srv and _RA then pcall(function() _RA:FireServer("StopLoop", skillId) end) end
end

-- Rarity
local _R={
	Common    ={col=Color3.fromRGB(180,180,180),glow=Color3.fromRGB(215,215,215),w=50},
	Rare      ={col=Color3.fromRGB(80,140,255), glow=Color3.fromRGB(120,180,255),w=30},
	Epic      ={col=Color3.fromRGB(180,80,255), glow=Color3.fromRGB(210,120,255),w=15},
	Legendary ={col=Color3.fromRGB(255,180,0),  glow=Color3.fromRGB(255,220,80), w=5 },
}
local _RI={Common="⚪",Rare="🔵",Epic="🟣",Legendary="🟡"}
local function _rc(r) return _R[r] and _R[r].col  or Color3.fromRGB(200,200,200) end
local function _rg(r) return _R[r] and _R[r].glow or Color3.fromRGB(200,200,200) end

-- State
local _skills={};local _active={};local _aIds={};local _hist={}
local _rolling=false;local _wait=false;local _pend=nil;local _streak=0
local _chkDone=false;local _MAX=5;local _selT=nil;local _selS=nil
local _pendO=nil;local _tradEn=false

local function _pick(excL,bonus)
	local ex={}; for _,id in ipairs(excL or {}) do ex[id]=true end
	local pool={}
	for _,sk in ipairs(_skills) do
		if not ex[sk.id] then
			local w=(_R[sk.rarity] and _R[sk.rarity].w) or 10
			if sk.rarity=="Legendary" and bonus then w=w+bonus*4 end
			for _=1,w do table.insert(pool,sk) end
		end
	end
	return #pool>0 and pool[math.random(1,#pool)] or nil
end

-- GUI
local W,H=420,680
local old=player.PlayerGui:FindFirstChild("DiceGui"); if old then old:Destroy() end
local SG=Instance.new("ScreenGui"); SG.Name="DiceGui"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=player.PlayerGui

local win=Instance.new("Frame",SG)
win.Size=UDim2.new(0,W,0,H); win.Position=UDim2.new(0.5,-W/2,0.5,-H/2)
win.BackgroundColor3=Color3.fromRGB(12,10,20); win.BorderSizePixel=0; win.ClipsDescendants=true
Instance.new("UICorner",win).CornerRadius=UDim.new(0,16)
local wS=Instance.new("UIStroke",win); wS.Color=Color3.fromRGB(85,48,165); wS.Thickness=2; wS.Transparency=0.35

local tb=Instance.new("Frame",win); tb.Size=UDim2.new(1,0,0,48)
tb.BackgroundColor3=Color3.fromRGB(17,13,32); tb.BorderSizePixel=0; tb.ZIndex=10
Instance.new("UICorner",tb).CornerRadius=UDim.new(0,16)
local tbB=Instance.new("Frame",tb); tbB.Size=UDim2.new(1,0,0,16); tbB.Position=UDim2.new(0,0,1,-16)
tbB.BackgroundColor3=Color3.fromRGB(17,13,32); tbB.BorderSizePixel=0; tbB.ZIndex=10

local _titLbl=Instance.new("TextLabel",tb)
_titLbl.Size=UDim2.new(1,-170,1,0); _titLbl.Position=UDim2.new(0,14,0,0)
_titLbl.BackgroundTransparency=1; _titLbl.Text="🎲  DICE OF FATE"
_titLbl.TextColor3=Color3.fromRGB(200,155,255); _titLbl.Font=Enum.Font.GothamBold
_titLbl.TextSize=15; _titLbl.TextXAlignment=Enum.TextXAlignment.Left; _titLbl.ZIndex=11

local _badge=Instance.new("TextLabel",tb)
_badge.Size=UDim2.new(0,94,0,24); _badge.Position=UDim2.new(1,-154,0.5,-12)
_badge.BackgroundColor3=Color3.fromRGB(28,28,28); _badge.Text="⚫ OFFLINE"
_badge.TextSize=10; _badge.Font=Enum.Font.GothamBold
_badge.TextColor3=Color3.fromRGB(140,140,140); _badge.BorderSizePixel=0; _badge.ZIndex=11
Instance.new("UICorner",_badge).CornerRadius=UDim.new(0,6)

local function _cBtn(xOff,bg,lbl)
	local b=Instance.new("TextButton",tb)
	b.Size=UDim2.new(0,24,0,24); b.Position=UDim2.new(1,xOff,0.5,-12)
	b.BackgroundColor3=bg; b.Text=lbl; b.TextColor3=Color3.fromRGB(255,255,255)
	b.TextSize=12; b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0; b.ZIndex=11
	Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
	return b
end
local bClose=_cBtn(-30,Color3.fromRGB(205,58,68),"✕")
local bMin  =_cBtn(-58,Color3.fromRGB(225,145,18),"─")

local tabBar=Instance.new("Frame",win)
tabBar.Size=UDim2.new(1,-24,0,36); tabBar.Position=UDim2.new(0,12,0,54)
tabBar.BackgroundColor3=Color3.fromRGB(17,13,30); tabBar.BorderSizePixel=0; tabBar.ZIndex=9
Instance.new("UICorner",tabBar).CornerRadius=UDim.new(0,10)
local tLL=Instance.new("UIListLayout",tabBar)
tLL.FillDirection=Enum.FillDirection.Horizontal
tLL.HorizontalAlignment=Enum.HorizontalAlignment.Center
tLL.VerticalAlignment=Enum.VerticalAlignment.Center; tLL.Padding=UDim.new(0,4)
local tPad=Instance.new("UIPadding",tabBar); tPad.PaddingLeft=UDim.new(0,5); tPad.PaddingRight=UDim.new(0,5)

local function _mkTab(lbl,on)
	local b=Instance.new("TextButton",tabBar)
	b.Size=UDim2.new(0,88,0,28)
	b.BackgroundColor3=on and Color3.fromRGB(90,44,195) or Color3.fromRGB(26,20,42)
	b.Text=lbl; b.Font=Enum.Font.GothamBold; b.TextSize=11; b.BorderSizePixel=0
	b.TextColor3=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(125,105,165)
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
	return b
end
local tR=_mkTab("🎲 Roll",true); local tH=_mkTab("📜 History",false)
local tT=_mkTab("🤝 Trade",false); local tS=_mkTab("⚙️ Settings",false)

local PY,PH=98,H-98-10
local function _mkPg()
	local f=Instance.new("Frame",win)
	f.Size=UDim2.new(1,-24,0,PH); f.Position=UDim2.new(0,12,0,PY)
	f.BackgroundTransparency=1; f.Visible=false; f.ClipsDescendants=false
	return f
end
local pR=_mkPg(); pR.Visible=true
local pH=_mkPg(); local pT=_mkPg(); local pS=_mkPg()
local PGS={pR,pH,pT,pS}; local TBS={tR,tH,tT,tS}

local function _goTab(n)
	for i,pg in ipairs(PGS) do
		pg.Visible=(i==n); local on=(i==n)
		_tw(TBS[i],{BackgroundColor3=on and Color3.fromRGB(90,44,195) or Color3.fromRGB(26,20,42),
			TextColor3=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(125,105,165)},TF)
	end
end
tR.MouseButton1Click:Connect(function() _goTab(1) end)
tH.MouseButton1Click:Connect(function() _goTab(2) end)
tT.MouseButton1Click:Connect(function() _goTab(3) end)
tS.MouseButton1Click:Connect(function() _goTab(4) end)

-- PAGE 1: ROLL
local card=Instance.new("Frame",pR); card.Size=UDim2.new(1,0,0,150)
card.BackgroundColor3=Color3.fromRGB(15,11,26); card.BorderSizePixel=0
Instance.new("UICorner",card).CornerRadius=UDim.new(0,14)
local cS=Instance.new("UIStroke",card); cS.Color=Color3.fromRGB(85,48,165); cS.Thickness=1.5; cS.Transparency=0.4
local dBox=Instance.new("Frame",card); dBox.Size=UDim2.new(0,96,0,96); dBox.Position=UDim2.new(0,12,0.5,-48)
dBox.BackgroundColor3=Color3.fromRGB(20,15,40); dBox.BorderSizePixel=0
Instance.new("UICorner",dBox).CornerRadius=UDim.new(0,14)
local dS=Instance.new("UIStroke",dBox); dS.Color=Color3.fromRGB(125,75,235); dS.Thickness=2; dS.Transparency=0.4
local dTxt=Instance.new("TextLabel",dBox); dTxt.Size=UDim2.new(1,0,1,0); dTxt.BackgroundTransparency=1
dTxt.Text="🎲"; dTxt.TextSize=48; dTxt.Font=Enum.Font.Gotham
local iBox=Instance.new("Frame",card); iBox.Size=UDim2.new(1,-122,1,-12); iBox.Position=UDim2.new(0,118,0,6)
iBox.BackgroundTransparency=1
local rarLbl=Instance.new("TextLabel",iBox); rarLbl.Size=UDim2.new(0,96,0,20)
rarLbl.BackgroundColor3=Color3.fromRGB(26,18,48); rarLbl.Text=""; rarLbl.TextSize=10; rarLbl.Font=Enum.Font.GothamBold
rarLbl.TextColor3=Color3.fromRGB(200,175,255); rarLbl.BorderSizePixel=0; rarLbl.Visible=false
Instance.new("UICorner",rarLbl).CornerRadius=UDim.new(0,6)
local namLbl=Instance.new("TextLabel",iBox); namLbl.Size=UDim2.new(1,0,0,24); namLbl.Position=UDim2.new(0,0,0,26)
namLbl.BackgroundTransparency=1; namLbl.Text="Roll the dice!"
namLbl.TextColor3=Color3.fromRGB(215,185,255); namLbl.Font=Enum.Font.GothamBold
namLbl.TextSize=15; namLbl.TextXAlignment=Enum.TextXAlignment.Left
local dscLbl=Instance.new("TextLabel",iBox); dscLbl.Size=UDim2.new(1,0,0,36); dscLbl.Position=UDim2.new(0,0,0,54)
dscLbl.BackgroundTransparency=1; dscLbl.Text="Tekan ROLL untuk dapat skill acak!"
dscLbl.TextColor3=Color3.fromRGB(140,120,180); dscLbl.Font=Enum.Font.Gotham
dscLbl.TextSize=12; dscLbl.TextXAlignment=Enum.TextXAlignment.Left; dscLbl.TextWrapped=true
local flvLbl=Instance.new("TextLabel",iBox); flvLbl.Size=UDim2.new(1,0,0,18); flvLbl.Position=UDim2.new(0,0,0,94)
flvLbl.BackgroundTransparency=1; flvLbl.Text=""; flvLbl.TextColor3=Color3.fromRGB(90,75,125)
flvLbl.Font=Enum.Font.Gotham; flvLbl.TextSize=11; flvLbl.TextXAlignment=Enum.TextXAlignment.Left; flvLbl.TextWrapped=true

local function _btn(par,px,py,pw,ph,bg,txt,sz)
	local b=Instance.new("TextButton",par)
	b.Size=UDim2.new(pw,0,0,ph); b.Position=UDim2.new(px,0,0,py)
	b.BackgroundColor3=bg; b.Text=txt
	b.TextColor3=Color3.fromRGB(255,255,255); b.Font=Enum.Font.GothamBold
	b.TextSize=sz or 14; b.BorderSizePixel=0
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,12)
	return b
end

local chkBtn=_btn(pR,0,158,1,42,Color3.fromRGB(20,62,140),"🔍  CHECK SERVER",13)
Instance.new("UIStroke",chkBtn).Color=Color3.fromRGB(50,110,245)
local useBtn=_btn(pR,0,158,0.48,42,Color3.fromRGB(48,170,88),"✅  USE",15); useBtn.Visible=false
local skpBtn=_btn(pR,0.52,158,0.48,42,Color3.fromRGB(175,52,52),"⏭  SKIP",15); skpBtn.Visible=false
local rolBtn=_btn(pR,0,208,1,52,Color3.fromRGB(95,44,200),"🎲  ROLL THE DICE",17)
Instance.new("UIStroke",rolBtn).Color=Color3.fromRGB(160,100,255)

local strLbl=Instance.new("TextLabel",pR); strLbl.Size=UDim2.new(1,0,0,18); strLbl.Position=UDim2.new(0,0,0,268)
strLbl.BackgroundTransparency=1; strLbl.Text=""; strLbl.TextColor3=Color3.fromRGB(255,188,40)
strLbl.Font=Enum.Font.GothamBold; strLbl.TextSize=12; strLbl.TextXAlignment=Enum.TextXAlignment.Center

local slHdr=Instance.new("TextLabel",pR); slHdr.Size=UDim2.new(1,0,0,16); slHdr.Position=UDim2.new(0,0,0,294)
slHdr.BackgroundTransparency=1; slHdr.Text="ACTIVE SKILL SLOTS  [0/5]"
slHdr.TextColor3=Color3.fromRGB(95,75,145); slHdr.Font=Enum.Font.GothamBold
slHdr.TextSize=11; slHdr.TextXAlignment=Enum.TextXAlignment.Left

local slFr=Instance.new("Frame",pR); slFr.Size=UDim2.new(1,0,0,66); slFr.Position=UDim2.new(0,0,0,314)
slFr.BackgroundColor3=Color3.fromRGB(15,11,24); slFr.BorderSizePixel=0
Instance.new("UICorner",slFr).CornerRadius=UDim.new(0,12)
local slLL=Instance.new("UIListLayout",slFr)
slLL.FillDirection=Enum.FillDirection.Horizontal; slLL.Padding=UDim.new(0,6)
slLL.VerticalAlignment=Enum.VerticalAlignment.Center
Instance.new("UIPadding",slFr).PaddingLeft=UDim.new(0,8)

local clrBtn=_btn(pR,0,388,1,36,Color3.fromRGB(38,26,62),"🗑  Clear All Skills",13)
clrBtn.TextColor3=Color3.fromRGB(160,128,200)

-- PAGE 2: HISTORY
local hHdr=Instance.new("TextLabel",pH); hHdr.Size=UDim2.new(1,0,0,22); hHdr.BackgroundTransparency=1
hHdr.Text="📜 Roll History (last 20)"; hHdr.TextColor3=Color3.fromRGB(190,160,245)
hHdr.Font=Enum.Font.GothamBold; hHdr.TextSize=14; hHdr.TextXAlignment=Enum.TextXAlignment.Left
local hSF=Instance.new("ScrollingFrame",pH); hSF.Size=UDim2.new(1,0,1,-26); hSF.Position=UDim2.new(0,0,0,24)
hSF.BackgroundColor3=Color3.fromRGB(13,10,22); hSF.BorderSizePixel=0
hSF.ScrollBarThickness=4; hSF.ScrollBarImageColor3=Color3.fromRGB(85,48,165); hSF.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",hSF).CornerRadius=UDim.new(0,12)
local hLL=Instance.new("UIListLayout",hSF); hLL.Padding=UDim.new(0,4)
local hPd=Instance.new("UIPadding",hSF)
hPd.PaddingTop=UDim.new(0,6); hPd.PaddingLeft=UDim.new(0,8); hPd.PaddingRight=UDim.new(0,8)

local function _rebHist()
	for _,c in ipairs(hSF:GetChildren()) do
		if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
	end
	if #_hist==0 then
		local e=Instance.new("TextLabel",hSF); e.Size=UDim2.new(1,-8,0,36); e.BackgroundTransparency=1
		e.Text="Belum ada history."; e.TextColor3=Color3.fromRGB(110,95,145)
		e.Font=Enum.Font.Gotham; e.TextSize=13; e.TextXAlignment=Enum.TextXAlignment.Center; return
	end
	for _,en in ipairs(_hist) do
		local row=Instance.new("Frame",hSF); row.Size=UDim2.new(1,-8,0,36)
		row.BackgroundColor3=Color3.fromRGB(19,15,32); row.BorderSizePixel=0
		Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
		local rs=Instance.new("UIStroke",row); rs.Color=_rc(en.skill.rarity); rs.Thickness=1; rs.Transparency=0.6
		local ic=Instance.new("TextLabel",row); ic.Size=UDim2.new(0,34,1,0); ic.BackgroundTransparency=1
		ic.Text=en.skill.icon; ic.TextSize=18; ic.Font=Enum.Font.Gotham
		local nl=Instance.new("TextLabel",row); nl.Size=UDim2.new(1,-80,1,0); nl.Position=UDim2.new(0,34,0,0)
		nl.BackgroundTransparency=1; nl.Text=en.skill.name; nl.TextColor3=_rc(en.skill.rarity)
		nl.Font=Enum.Font.GothamBold; nl.TextSize=13; nl.TextXAlignment=Enum.TextXAlignment.Left
		local st=Instance.new("TextLabel",row); st.Size=UDim2.new(0,54,1,0); st.Position=UDim2.new(1,-56,0,0)
		st.BackgroundTransparency=1; st.Text=en.used and "✅ Used" or "⏭ Skip"
		st.TextColor3=en.used and Color3.fromRGB(75,205,115) or Color3.fromRGB(195,85,85)
		st.Font=Enum.Font.Gotham; st.TextSize=11
	end
	hSF.CanvasSize=UDim2.new(0,0,0,#_hist*40+10)
end
_rebHist()

-- PAGE 3: TRADE
local tLkLbl=Instance.new("TextLabel",pT); tLkLbl.Size=UDim2.new(1,0,0,56); tLkLbl.Position=UDim2.new(0,0,0.32,0)
tLkLbl.BackgroundTransparency=1; tLkLbl.Text="🔒 Trade dinonaktifkan\nAktifkan di tab ⚙️ Settings"
tLkLbl.TextColor3=Color3.fromRGB(125,105,155); tLkLbl.Font=Enum.Font.Gotham
tLkLbl.TextSize=14; tLkLbl.TextXAlignment=Enum.TextXAlignment.Center; tLkLbl.TextWrapped=true
local tPanel=Instance.new("Frame",pT); tPanel.Size=UDim2.new(1,0,1,0); tPanel.BackgroundTransparency=1; tPanel.Visible=false
local tpH=Instance.new("TextLabel",tPanel); tpH.Size=UDim2.new(1,0,0,20); tpH.BackgroundTransparency=1
tpH.Text="🤝 Trade Skill ke Player Lain"; tpH.TextColor3=Color3.fromRGB(190,160,245)
tpH.Font=Enum.Font.GothamBold; tpH.TextSize=13; tpH.TextXAlignment=Enum.TextXAlignment.Left
local plSF=Instance.new("ScrollingFrame",tPanel); plSF.Size=UDim2.new(1,0,0,105); plSF.Position=UDim2.new(0,0,0,26)
plSF.BackgroundColor3=Color3.fromRGB(13,10,22); plSF.BorderSizePixel=0
plSF.ScrollBarThickness=4; plSF.ScrollBarImageColor3=Color3.fromRGB(85,48,165); plSF.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",plSF).CornerRadius=UDim.new(0,10)
local plLL=Instance.new("UIListLayout",plSF); plLL.Padding=UDim.new(0,4)
local plPd=Instance.new("UIPadding",plSF); plPd.PaddingLeft=UDim.new(0,6); plPd.PaddingTop=UDim.new(0,6)
local skH=Instance.new("TextLabel",tPanel); skH.Size=UDim2.new(1,0,0,16); skH.Position=UDim2.new(0,0,0,138)
skH.BackgroundTransparency=1; skH.Text="Pilih skill yang mau di-trade:"; skH.TextColor3=Color3.fromRGB(150,130,190)
skH.Font=Enum.Font.Gotham; skH.TextSize=12; skH.TextXAlignment=Enum.TextXAlignment.Left
local skSF=Instance.new("ScrollingFrame",tPanel); skSF.Size=UDim2.new(1,0,0,76); skSF.Position=UDim2.new(0,0,0,158)
skSF.BackgroundColor3=Color3.fromRGB(13,10,22); skSF.BorderSizePixel=0
skSF.ScrollBarThickness=4; skSF.ScrollBarImageColor3=Color3.fromRGB(85,48,165); skSF.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",skSF).CornerRadius=UDim.new(0,10)
local skLL=Instance.new("UIListLayout",skSF); skLL.FillDirection=Enum.FillDirection.Horizontal; skLL.Padding=UDim.new(0,6)
skLL.VerticalAlignment=Enum.VerticalAlignment.Center; Instance.new("UIPadding",skSF).PaddingLeft=UDim.new(0,8)
local sndBtn=_btn(tPanel,0,244,1,42,Color3.fromRGB(42,115,210),"📤  Send Trade Offer",14)
local trStat=Instance.new("TextLabel",tPanel); trStat.Size=UDim2.new(1,0,0,26); trStat.Position=UDim2.new(0,0,0,294)
trStat.BackgroundTransparency=1; trStat.Text=""; trStat.TextColor3=Color3.fromRGB(170,150,210)
trStat.Font=Enum.Font.Gotham; trStat.TextSize=13; trStat.TextXAlignment=Enum.TextXAlignment.Center; trStat.TextWrapped=true

-- PAGE 4: SETTINGS
local stH=Instance.new("TextLabel",pS); stH.Size=UDim2.new(1,0,0,22); stH.BackgroundTransparency=1
stH.Text="⚙️ Settings"; stH.TextColor3=Color3.fromRGB(190,160,245)
stH.Font=Enum.Font.GothamBold; stH.TextSize=14; stH.TextXAlignment=Enum.TextXAlignment.Left

local function _mkTog(par,y,main,sub,def)
	local row=Instance.new("Frame",par); row.Size=UDim2.new(1,0,0,50); row.Position=UDim2.new(0,0,0,y)
	row.BackgroundColor3=Color3.fromRGB(15,11,24); row.BorderSizePixel=0
	Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
	local m=Instance.new("TextLabel",row); m.Size=UDim2.new(1,-70,0,24); m.Position=UDim2.new(0,12,0,4)
	m.BackgroundTransparency=1; m.Text=main; m.TextColor3=Color3.fromRGB(198,178,232)
	m.Font=Enum.Font.GothamBold; m.TextSize=13; m.TextXAlignment=Enum.TextXAlignment.Left
	local s=Instance.new("TextLabel",row); s.Size=UDim2.new(1,-70,0,16); s.Position=UDim2.new(0,12,0,28)
	s.BackgroundTransparency=1; s.Text=sub; s.TextColor3=Color3.fromRGB(115,96,148)
	s.Font=Enum.Font.Gotham; s.TextSize=11; s.TextXAlignment=Enum.TextXAlignment.Left
	local tog=Instance.new("TextButton",row); tog.Size=UDim2.new(0,52,0,26); tog.Position=UDim2.new(1,-60,0.5,-13)
	tog.BackgroundColor3=def and Color3.fromRGB(65,185,105) or Color3.fromRGB(52,42,76)
	tog.Text=def and "ON" or "OFF"; tog.TextColor3=Color3.fromRGB(255,255,255)
	tog.Font=Enum.Font.GothamBold; tog.TextSize=12; tog.BorderSizePixel=0
	Instance.new("UICorner",tog).CornerRadius=UDim.new(0,8)
	local st=def
	tog.MouseButton1Click:Connect(function()
		st=not st
		_tw(tog,{BackgroundColor3=st and Color3.fromRGB(65,185,105) or Color3.fromRGB(52,42,76)},TF)
		tog.Text=st and "ON" or "OFF"
	end)
	return tog, function() return st end
end

local togTr,getTr=_mkTog(pS,26,"🤝 Enable Trade","Izinkan trade skill ke player lain",false)
local togGv,getGv=_mkTog(pS,84,"📡 Give All GUI","Broadcast GUI ke semua player",false)
local gvBtn=_btn(pS,0,142,1,42,Color3.fromRGB(32,90,188),"📡  Broadcast GUI ke Semua Player",13)
local stNote=Instance.new("TextLabel",pS); stNote.Size=UDim2.new(1,0,0,34); stNote.Position=UDim2.new(0,0,0,192)
stNote.BackgroundTransparency=1
stNote.Text="⚠️ Give All & Trade butuh Server Support.\nCheck server dulu di tab 🎲 Roll."
stNote.TextColor3=Color3.fromRGB(170,130,72); stNote.Font=Enum.Font.Gotham
stNote.TextSize=11; stNote.TextXAlignment=Enum.TextXAlignment.Left; stNote.TextWrapped=true

-- Trade notif
local tnF=Instance.new("Frame",SG); tnF.Size=UDim2.new(0,310,0,106); tnF.Position=UDim2.new(0.5,-155,1,10)
tnF.BackgroundColor3=Color3.fromRGB(14,11,24); tnF.BorderSizePixel=0; tnF.Visible=false
Instance.new("UICorner",tnF).CornerRadius=UDim.new(0,14)
local tnS=Instance.new("UIStroke",tnF); tnS.Color=Color3.fromRGB(42,115,210); tnS.Thickness=1.5
local tnTit=Instance.new("TextLabel",tnF); tnTit.Size=UDim2.new(1,-10,0,24); tnTit.Position=UDim2.new(0,10,0,6)
tnTit.BackgroundTransparency=1; tnTit.Text="🤝 Incoming Trade!"; tnTit.TextColor3=Color3.fromRGB(85,165,255)
tnTit.Font=Enum.Font.GothamBold; tnTit.TextSize=13; tnTit.TextXAlignment=Enum.TextXAlignment.Left
local tnDsc=Instance.new("TextLabel",tnF); tnDsc.Size=UDim2.new(1,-10,0,24); tnDsc.Position=UDim2.new(0,10,0,28)
tnDsc.BackgroundTransparency=1; tnDsc.Text="..."; tnDsc.TextColor3=Color3.fromRGB(168,148,205)
tnDsc.Font=Enum.Font.Gotham; tnDsc.TextSize=12; tnDsc.TextWrapped=true
local tnAc=_btn(tnF,0.03,nil,0.44,28,Color3.fromRGB(48,170,88),"✅ Accept",12); tnAc.Position=UDim2.new(0.03,0,1,-36)
local tnDc=_btn(tnF,0.52,nil,0.44,28,Color3.fromRGB(175,52,52),"❌ Decline",12); tnDc.Position=UDim2.new(0.52,0,1,-36)

-- Slots & trade
local _slObjs={}
local function _rebTskSk()
	for _,c in ipairs(skSF:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
	_selS=nil; local tot=0
	for _,en in ipairs(_active) do
		local sk=en.skill; tot=tot+1
		local b=Instance.new("TextButton",skSF); b.Size=UDim2.new(0,58,0,60)
		b.BackgroundColor3=Color3.fromRGB(20,16,36); b.Text=sk.icon; b.TextSize=26
		b.Font=Enum.Font.Gotham; b.TextColor3=Color3.fromRGB(255,255,255); b.BorderSizePixel=0
		Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
		local bs=Instance.new("UIStroke",b); bs.Color=_rc(sk.rarity); bs.Thickness=2
		b.MouseButton1Click:Connect(function()
			_selS=sk
			for _,c2 in ipairs(skSF:GetChildren()) do
				if c2:IsA("TextButton") then _tw(c2,{BackgroundColor3=Color3.fromRGB(20,16,36)},TF) end
			end
			_tw(b,{BackgroundColor3=Color3.fromRGB(50,34,85)},TF); trStat.Text="Dipilih: "..sk.icon.." "..sk.name
		end)
	end
	skSF.CanvasSize=UDim2.new(0,tot*64+8,0,0)
end
local function _rebPlrs()
	for _,c in ipairs(plSF:GetChildren()) do
		if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
	end
	_selT=nil; local cnt=0
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=player then cnt=cnt+1
			local b=Instance.new("TextButton",plSF); b.Size=UDim2.new(1,-10,0,28)
			b.BackgroundColor3=Color3.fromRGB(19,15,30); b.Text="👤  "..p.Name
			b.Font=Enum.Font.Gotham; b.TextSize=13; b.TextColor3=Color3.fromRGB(190,170,228)
			b.BorderSizePixel=0; b.TextXAlignment=Enum.TextXAlignment.Left
			Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
			Instance.new("UIPadding",b).PaddingLeft=UDim.new(0,10)
			b.MouseButton1Click:Connect(function()
				_selT=p.Name
				for _,c2 in ipairs(plSF:GetChildren()) do
					if c2:IsA("TextButton") then _tw(c2,{BackgroundColor3=Color3.fromRGB(19,15,30)},TF) end
				end
				_tw(b,{BackgroundColor3=Color3.fromRGB(36,26,62)},TF); trStat.Text="Target: "..p.Name
			end)
		end
	end
	plSF.CanvasSize=UDim2.new(0,0,0,cnt*32+8)
	if cnt==0 then
		local nl=Instance.new("TextLabel",plSF); nl.Size=UDim2.new(1,-10,0,28); nl.BackgroundTransparency=1
		nl.Text="Tidak ada player lain."; nl.TextColor3=Color3.fromRGB(115,96,148); nl.Font=Enum.Font.Gotham; nl.TextSize=13
	end
end
local function _rebSlots()
	for _,s in ipairs(_slObjs) do s:Destroy() end; _slObjs={}
	slHdr.Text="ACTIVE SKILL SLOTS  ["..#_active.."/".. _MAX .."]"
	for i,en in ipairs(_active) do
		local sk=en.skill
		local sl=Instance.new("Frame",slFr); sl.Size=UDim2.new(0,54,0,54)
		sl.BackgroundColor3=Color3.fromRGB(20,16,36); sl.BorderSizePixel=0
		Instance.new("UICorner",sl).CornerRadius=UDim.new(0,10)
		local ss=Instance.new("UIStroke",sl); ss.Color=_rc(sk.rarity); ss.Thickness=2
		local ic=Instance.new("TextLabel",sl); ic.Size=UDim2.new(1,0,0.64,0); ic.BackgroundTransparency=1
		ic.Text=sk.icon; ic.TextSize=21; ic.Font=Enum.Font.Gotham; ic.TextColor3=Color3.fromRGB(255,255,255)
		local rl=Instance.new("TextLabel",sl); rl.Size=UDim2.new(1,-2,0.36,0); rl.Position=UDim2.new(0,1,0.64,0)
		rl.BackgroundTransparency=1; rl.Text=sk.rarity=="Legendary" and "LGND" or sk.rarity
		rl.TextSize=8; rl.Font=Enum.Font.GothamBold; rl.TextColor3=_rc(sk.rarity)
		local rb=Instance.new("TextButton",sl); rb.Size=UDim2.new(1,0,1,0)
		rb.BackgroundTransparency=1; rb.Text=""; rb.ZIndex=10
		rb.MouseEnter:Connect(function() ic.Text="✕"; _tw(sl,{BackgroundColor3=Color3.fromRGB(80,20,20)},TF) end)
		rb.MouseLeave:Connect(function() ic.Text=sk.icon; _tw(sl,{BackgroundColor3=Color3.fromRGB(20,16,36)},TF) end)
		rb.MouseButton1Click:Connect(function()
			pcall(sk.remove); table.remove(_active,i); _aIds[sk.id]=nil; _rebSlots(); _rebTskSk()
		end)
		table.insert(_slObjs,sl)
	end
	for _=1,_MAX-#_active do
		local e=Instance.new("Frame",slFr); e.Size=UDim2.new(0,54,0,54)
		e.BackgroundColor3=Color3.fromRGB(14,11,22); e.BorderSizePixel=0
		Instance.new("UICorner",e).CornerRadius=UDim.new(0,10)
		local es=Instance.new("UIStroke",e); es.Color=Color3.fromRGB(42,32,68); es.Thickness=1.5; es.Transparency=0.5
		local el=Instance.new("TextLabel",e); el.Size=UDim2.new(1,0,1,0); el.BackgroundTransparency=1
		el.Text="+"; el.TextSize=20; el.Font=Enum.Font.GothamBold; el.TextColor3=Color3.fromRGB(42,32,65)
		table.insert(_slObjs,e)
	end
end
_rebSlots()

-- Drag
local drg=false; local drgS=nil; local drgW=nil
tb.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		drg=true; drgS=i.Position; drgW=win.Position end
end)
tb.InputChanged:Connect(function(i)
	if drg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
		local d=i.Position-drgS
		win.Position=UDim2.new(drgW.X.Scale,drgW.X.Offset+d.X,drgW.Y.Scale,drgW.Y.Offset+d.Y) end
end)
tb.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=false end
end)

local mini=false
bMin.MouseButton1Click:Connect(function()
	mini=not mini
	if mini then
		for _,pg in ipairs(PGS) do pg.Visible=false end
		tabBar.Visible=false; _tw(win,{Size=UDim2.new(0,W,0,48)},TM); bMin.Text="□"
	else
		_tw(win,{Size=UDim2.new(0,W,0,H)},TB)
		task.wait(0.35); tabBar.Visible=true; pR.Visible=true; bMin.Text="─"
	end
end)
bClose.MouseButton1Click:Connect(function()
	for k in pairs(_Conns) do _drop(k) end
	_tw(win,{Size=UDim2.new(0,0,0,0),
		Position=UDim2.new(win.Position.X.Scale,win.Position.X.Offset+W/2,
			win.Position.Y.Scale,win.Position.Y.Offset+H/2)},
		TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In))
	task.wait(0.25); SG:Destroy()
end)

local function _showPk(sk)
	_pend=sk; _wait=true; chkBtn.Visible=false; rolBtn.Visible=false
	useBtn.Visible=true; skpBtn.Visible=true
	_tw(dS,{Color=_rg(sk.rarity),Transparency=0.1},TM)
	_tw(cS,{Color=_rg(sk.rarity),Transparency=0.2},TM)
	rarLbl.Text=(_RI[sk.rarity] or "⚫").."  "..sk.rarity:upper()
	rarLbl.TextColor3=_rc(sk.rarity); rarLbl.Visible=true
	namLbl.Text=sk.name; namLbl.TextColor3=_rc(sk.rarity)
	dscLbl.Text=sk.desc or ""; flvLbl.Text=sk.flavor or ""
end
local function _hidePk()
	_pend=nil; _wait=false; useBtn.Visible=false; skpBtn.Visible=false
	chkBtn.Visible=not _chkDone; rolBtn.Visible=true
	_tw(dS,{Color=Color3.fromRGB(125,75,235),Transparency=0.4},TM)
	_tw(cS,{Color=Color3.fromRGB(85,48,165), Transparency=0.4},TM); rarLbl.Visible=false
end
local function _updStr()
	if _streak>=3 then strLbl.Text="🔥 Streak ".._streak.."x — Legendary chance naik!"; strLbl.TextColor3=Color3.fromRGB(255,185,38)
	elseif _streak>0 then strLbl.Text="Skip streak: ".._streak.."x"; strLbl.TextColor3=Color3.fromRGB(185,185,185)
	else strLbl.Text="" end
end

local DF={"⚀","⚁","⚂","⚃","⚄","⚅"}
rolBtn.MouseButton1Click:Connect(function()
	if _rolling or _wait then return end
	if #_active>=_MAX then namLbl.Text="⚠️ Slot penuh!"; dscLbl.Text="Hover slot lalu klik untuk remove."; return end
	_rolling=true; _tw(rolBtn,{BackgroundColor3=Color3.fromRGB(52,28,110)},TF); rolBtn.Text="Rolling..."
	namLbl.Text="Rolling..."; dscLbl.Text=""; flvLbl.Text=""; rarLbl.Visible=false
	local el,iv=0,0.07
	while el<1.4 do dTxt.Text=DF[math.random(1,6)]; task.wait(iv); el=el+iv; iv=math.min(iv+0.013,0.22) end
	local excL={}; for id in pairs(_aIds) do table.insert(excL,id) end
	local sk=_pick(excL,_streak>=3 and _streak or nil)
	_tw(rolBtn,{BackgroundColor3=Color3.fromRGB(95,44,200)},TF); rolBtn.Text="🎲  ROLL THE DICE"; _rolling=false
	if not sk then dTxt.Text="😵"; namLbl.Text="Semua skill aktif!"; dscLbl.Text="Clear dulu beberapa skill."; return end
	dTxt.Text=sk.icon; _showPk(sk)
end)
useBtn.MouseButton1Click:Connect(function()
	if not _pend then return end; local sk=_pend
	local ok,err=pcall(sk.apply)
	if ok then
		table.insert(_active,{skill=sk}); _aIds[sk.id]=true
		_streak=0; _updStr(); _rebSlots(); _rebTskSk()
		table.insert(_hist,1,{skill=sk,used=true}); if #_hist>20 then table.remove(_hist) end
		_rebHist(); namLbl.Text="✅ "..sk.name; namLbl.TextColor3=_rc(sk.rarity)
		dscLbl.Text="Aktif!"..((_srv) and " 🌐" or " 💻"); flvLbl.Text=sk.flavor or ""
	else
		namLbl.Text="❌ Error!"; dscLbl.Text=tostring(err); namLbl.TextColor3=Color3.fromRGB(255,85,85)
		warn("[DiceLibrary] Apply error:",err)
	end
	_hidePk()
end)
skpBtn.MouseButton1Click:Connect(function()
	if not _pend then return end
	table.insert(_hist,1,{skill=_pend,used=false}); if #_hist>20 then table.remove(_hist) end
	_rebHist(); _streak=_streak+1; _updStr()
	namLbl.Text="Roll the dice!"; namLbl.TextColor3=Color3.fromRGB(215,185,255)
	dscLbl.Text="Dilewatin! Roll lagi."; flvLbl.Text=""; dTxt.Text="🎲"; _hidePk()
end)
clrBtn.MouseButton1Click:Connect(function()
	for _,en in ipairs(_active) do pcall(en.skill.remove) end
	if _srv and _RA then pcall(function() _RA:FireServer("ClearAll","","") end) end
	for k in pairs(_Conns) do _drop(k) end
	_active={}; _aIds={}; _streak=0; _updStr(); _rebSlots(); _rebTskSk()
	local c=player.Character
	if c then
		for _,p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") and _Orig[p.Name] then pcall(function() p.Size=_Orig[p.Name] end) end
		end
		local h2=c:FindFirstChildOfClass("Humanoid"); if h2 then h2.WalkSpeed=16; h2.JumpPower=50 end
	end
	workspace.Gravity=196.2
	namLbl.Text="Roll the dice!"; namLbl.TextColor3=Color3.fromRGB(215,185,255)
	dscLbl.Text="Semua skill di-reset!"; flvLbl.Text=""; dTxt.Text="🎲"
end)
chkBtn.MouseButton1Click:Connect(function()
	chkBtn.Text="⏳ Mencari FREEDICE..."; _tw(chkBtn,{BackgroundColor3=Color3.fromRGB(32,32,50)},TF)
	task.wait(1.2)
	local found=_csrv(); _chkDone=true; chkBtn.Visible=false
	if found then
		_badge.Text="🌐 SERVER MODE"; _badge.TextColor3=Color3.fromRGB(85,240,140)
		_tw(_badge,{BackgroundColor3=Color3.fromRGB(16,80,40)},TF); dscLbl.Text="Server aktif! Efek keliatan semua 🌐"
		if _RT then
			_RT.OnClientEvent:Connect(function(action,...)
				local a={...}
				if action=="IncomingOffer" then
					_pendO=a[2]; tnTit.Text="🤝 Trade dari "..a[1].."!"
					tnDsc.Text=a[2].skillIcon.." "..a[2].skillName.." ("..a[2].skillRarity..")"
					tnF.Visible=true; _tw(tnF,{Position=UDim2.new(0.5,-155,1,-115)},TB)
				elseif action=="TradeAccepted" then
					for i,en in ipairs(_active) do
						if en.skill.id==a[2].skillId then pcall(en.skill.remove); table.remove(_active,i); _aIds[a[2].skillId]=nil; break end
					end
					_rebSlots(); _rebTskSk(); trStat.Text="✅ "..a[1].." menerima trade!"
				elseif action=="TradeComplete" then
					for _,sk in ipairs(_skills) do
						if sk.id==a[1].skillId and #_active<_MAX then
							pcall(sk.apply); table.insert(_active,{skill=sk}); _aIds[sk.id]=true
							_rebSlots(); _rebTskSk(); namLbl.Text="🎁 Dapat "..sk.name.."!"; namLbl.TextColor3=_rc(sk.rarity); break
						end
					end
				elseif action=="TradeDeclined" then trStat.Text="❌ "..a[1].." menolak trade." end
			end)
		end
	else
		_badge.Text="💻 LOCAL ONLY"; _badge.TextColor3=Color3.fromRGB(255,168,62)
		_tw(_badge,{BackgroundColor3=Color3.fromRGB(72,46,16)},TF); dscLbl.Text="No server. Efek local only 💻"
	end
end)
togTr.MouseButton1Click:Connect(function()
	task.wait(0.05); _tradEn=getTr(); tLkLbl.Visible=not _tradEn; tPanel.Visible=_tradEn
	if _tradEn then _rebPlrs(); _rebTskSk() end
end)
gvBtn.MouseButton1Click:Connect(function()
	if not _srv or not _RG then
		_tw(stNote,{TextColor3=Color3.fromRGB(210,72,72)},TF); stNote.Text="❌ Butuh server support!"
		task.wait(2.5); _tw(stNote,{TextColor3=Color3.fromRGB(170,130,72)},TF)
		stNote.Text="⚠️ Give All & Trade butuh Server Support.\nCheck server dulu di tab 🎲 Roll."; return
	end
	pcall(function() _RG:FireServer("GiveAll") end)
	gvBtn.Text="✅ GUI Terbroadcast!"; _tw(gvBtn,{BackgroundColor3=Color3.fromRGB(26,115,58)},TF)
	task.wait(3); gvBtn.Text="📡  Broadcast GUI ke Semua Player"; _tw(gvBtn,{BackgroundColor3=Color3.fromRGB(32,90,188)},TF)
end)
sndBtn.MouseButton1Click:Connect(function()
	if not _srv or not _RT then trStat.Text="❌ Butuh server support!"; return end
	if not _selT then trStat.Text="⚠️ Pilih player dulu!"; return end
	if not _selS  then trStat.Text="⚠️ Pilih skill dulu!"; return end
	pcall(function()
		_RT:FireServer("Offer",_selT,{from=player.Name,skillId=_selS.id,skillName=_selS.name,skillIcon=_selS.icon,skillRarity=_selS.rarity})
	end)
	trStat.Text="📤 Offer terkirim ke ".._selT.."!"
end)
tnAc.MouseButton1Click:Connect(function()
	if not _pendO or not _RT then return end
	pcall(function() _RT:FireServer("Accept",_pendO.from,_pendO) end); tnF.Visible=false; _pendO=nil
end)
tnDc.MouseButton1Click:Connect(function()
	if not _pendO or not _RT then return end
	pcall(function() _RT:FireServer("Decline",_pendO.from,_pendO) end); tnF.Visible=false; _pendO=nil
end)

local function _hov(b,n,h)
	b.MouseEnter:Connect(function() _tw(b,{BackgroundColor3=h},TF) end)
	b.MouseLeave:Connect(function() _tw(b,{BackgroundColor3=n},TF) end)
end
_hov(rolBtn,Color3.fromRGB(95,44,200),Color3.fromRGB(122,68,245))
_hov(useBtn,Color3.fromRGB(48,170,88),Color3.fromRGB(36,205,78))
_hov(skpBtn,Color3.fromRGB(175,52,52),Color3.fromRGB(210,38,38))
_hov(clrBtn,Color3.fromRGB(38,26,62),Color3.fromRGB(55,40,90))
_hov(chkBtn,Color3.fromRGB(20,62,140),Color3.fromRGB(34,92,198))
_hov(gvBtn,Color3.fromRGB(32,90,188),Color3.fromRGB(48,118,235))
_hov(sndBtn,Color3.fromRGB(42,115,210),Color3.fromRGB(62,142,255))

-- ════════════════════════════════════════════════════════
--  PUBLIC API
-- ════════════════════════════════════════════════════════
local Dice = {}

function Dice.AddSkill(sk)
	assert(type(sk.id)=="string","[Dice] id harus string")
	assert(type(sk.name)=="string","[Dice] name harus string")
	assert(type(sk.apply)=="function","[Dice] apply harus function")
	assert(type(sk.remove)=="function","[Dice] remove harus function")
	assert(_R[sk.rarity],"[Dice] rarity '"..tostring(sk.rarity).."' tidak valid")
	for _,ex in ipairs(_skills) do
		if ex.id==sk.id then warn("[Dice] id '"..sk.id.."' duplikat, diabaikan."); return end
	end
	table.insert(_skills,sk)
end

-- Ambil character & humanoid
function Dice.GetChar() return _gc() end

-- Ambil ukuran asli part
function Dice.GetOrigSize(n) return _Orig[n] end

-- Simpan / hapus connection loop
function Dice.SaveConn(k,c) _save(k,c) end
function Dice.DropConn(k)   _drop(k) end

-- ════════════════════════════════════════════════════════
--  Dice.FX(skillId, effectData)
--  Kirim effect ke SERVER supaya keliatan semua player.
--  Dipanggil di dalam apply() / remove().
--
--  Contoh effectData:
--  { effect="SetSpeed",       value=100 }
--  { effect="SetJump",        value=200 }
--  { effect="SetGravity",     value=20  }
--  { effect="ScalePart",      part="Head", size={5,5,5} }
--  { effect="ScaleGroup",     parts={"LeftUpperArm",...}, size={2.5,2.5,2.5} }
--  { effect="ScaleAll",       mult=3 }
--  { effect="SetColor",       color={255,180,0} }
--  { effect="SetColor",       brickColor="Bright yellow" }
--  { effect="SetMaterial",    material="Ice" }
--  { effect="SetTransparency",value=0.8 }
--  { effect="Rainbow"  }   -- loop otomatis di server
--  { effect="LavaTrail"}   -- loop otomatis di server
--  { effect="SpinHead" }   -- loop otomatis di server
--  { effect="Magnet"   }   -- loop otomatis di server
--  { effect="GodMode"  }   -- loop otomatis di server
--  { effect="AntiGravity"       }
--  { effect="RemoveAntiGravity" }
--  { effect="StopLoop"  }  -- stop loop server skill ini
--  { effect="ResetBody" }  -- reset semua
--  { effect="ResetColor"}
--  { effect="ResetPart",      part="Head" }
--  { effect="ResetGroup",     parts={"LeftUpperArm",...} }
--  { effect="ResetAllParts"   }
-- ════════════════════════════════════════════════════════
function Dice.FX(skillId, effectData)
	_fx(skillId, effectData)
end

-- Stop loop server untuk skill ini
function Dice.StopLoop(skillId)
	_stopLoop(skillId)
end

-- Ganti judul window
function Dice.SetTitle(t) _titLbl.Text=t end

-- Ganti max slot (default 5)
function Dice.SetMaxSlots(n) _MAX=n end

-- Tampilkan GUI — panggil SETELAH semua AddSkill
function Dice.Launch()
	win.Size=UDim2.new(0,0,0,0); win.Position=UDim2.new(0.5,0,0.5,0)
	tabBar.Visible=false; pR.Visible=false; task.wait(0.06)
	_tw(win,{Size=UDim2.new(0,W,0,H),Position=UDim2.new(0.5,-W/2,0.5,-H/2)},TB)
	task.wait(0.36); tabBar.Visible=true; pR.Visible=true
	print("[DiceLibrary] ✅ Launched! "..(#_skills).." skills registered.")
end

return Dice
