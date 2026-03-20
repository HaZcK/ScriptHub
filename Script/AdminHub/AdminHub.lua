-- ╔══════════════════════════════════════════╗
-- ║           AdminHub - Khafidz            ║
-- ║         Author: Khafidz (KHAFIDZKTP)    ║
-- ╚══════════════════════════════════════════╝
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/AdminHub/AdminHub.lua"))()

local Players      = game:GetService("Players")
local HttpService  = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local TS           = game:GetService("TeleportService")
local player       = Players.LocalPlayer

-- ══════════════════════════════════════════
--    HTTP COMPAT
-- ══════════════════════════════════════════
local httpRequest = (syn and syn.request) or (http and http.request)
    or (http_request) or (request)
    or function(o) return {Body=game:HttpGet(o.Url), StatusCode=200} end

-- ══════════════════════════════════════════
--    FOLDER SETUP
-- ══════════════════════════════════════════
local ROOT   = "Delta/Workspace"
local FOLDER = ROOT.."AdminHub"
local ASSETS = ROOT.."AdminHub/assets"
local SCRIPTS_FOLDER = ROOT.."AdminHub/scripts"
local CFG_JSON = ASSETS.."/config.json"

for _, f in ipairs({FOLDER, ASSETS, SCRIPTS_FOLDER}) do
    if not isfolder(f) then pcall(makefolder, f) end
end

-- ══════════════════════════════════════════
--    CONFIG
-- ══════════════════════════════════════════
local GH_PAT    = ""
local GH_OWNER  = "HaZcK"
local GH_REPO   = "ScriptHub"
local GH_BRANCH = "main"
local GH_PATH   = "Script/AdminHub"
local GH_RAW    = "https://raw.githubusercontent.com/"..GH_OWNER.."/"..GH_REPO.."/"..GH_BRANCH.."/"..GH_PATH.."/"
local GH_API    = "https://api.github.com/repos/"..GH_OWNER.."/"..GH_REPO.."/contents/"..GH_PATH.."/"

local function loadConfig()
    if isfile(CFG_JSON) then
        local ok, d = pcall(function() return HttpService:JSONDecode(readfile(CFG_JSON)) end)
        if ok and type(d)=="table" then
            GH_PAT    = d.PAT    or ""
            GH_OWNER  = d.Owner  or GH_OWNER
            GH_REPO   = d.Repo   or GH_REPO
            GH_BRANCH = d.Branch or GH_BRANCH
            GH_PATH   = d.Path   or GH_PATH
            GH_RAW = "https://raw.githubusercontent.com/"..GH_OWNER.."/"..GH_REPO.."/"..GH_BRANCH.."/"..GH_PATH.."/"
            GH_API = "https://api.github.com/repos/"..GH_OWNER.."/"..GH_REPO.."/contents/"..GH_PATH.."/"
        end
    end
end
loadConfig()

-- ══════════════════════════════════════════
--    BASE64
-- ══════════════════════════════════════════
local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64Encode(data)
    return ((data:gsub(".",function(x)
        local r,b="",x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and "1" or "0") end return r
    end).."0000"):gsub("%d%d%d?%d?%d?%d?",function(x)
        if #x<6 then return "" end
        local c=0 for i=1,6 do c=c+(x:sub(i,i)=="1" and 2^(6-i) or 0) end
        return b64:sub(c+1,c+1)
    end)..({""," ==","="})[#data%3+1])
end

local function b64Decode(s)
    s=s:gsub("[^"..b64.."=]","")
    return (s:gsub(".",function(x)
        if x=="=" then return "" end
        local r,f="",b64:find(x)-1
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and "1" or "0") end return r
    end):gsub("%d%d%d%d%d%d%d%d",function(x)
        local c=0 for i=1,8 do c=c+(x:sub(i,i)=="1" and 2^(8-i) or 0) end return string.char(c)
    end))
end

-- ══════════════════════════════════════════
--    GITHUB READ / WRITE
-- ══════════════════════════════════════════
local function ghGet(path)
    local ok, data = pcall(function()
        local h = {["User-Agent"]="AdminHub",["Cache-Control"]="no-cache"}
        if GH_PAT~="" then h["Authorization"]="token "..GH_PAT end
        local res = httpRequest({Url=GH_API..path, Method="GET", Headers=h})
        if not res or not res.Body then return nil end
        local meta = HttpService:JSONDecode(res.Body)
        if meta and meta.content then
            return HttpService:JSONDecode(b64Decode(meta.content))
        end
        return nil
    end)
    if ok and data then return data end
    local ok2, d2 = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(GH_RAW..path.."?t="..os.time()..math.random(1000,9999)))
    end)
    return ok2 and d2 or nil
end

local function ghGetRaw(path)
    -- Ambil konten raw (bukan JSON parse)
    local ok, data = pcall(function()
        local h = {["User-Agent"]="AdminHub",["Cache-Control"]="no-cache"}
        if GH_PAT~="" then h["Authorization"]="token "..GH_PAT end
        local res = httpRequest({Url=GH_API..path, Method="GET", Headers=h})
        if not res or not res.Body then return nil end
        local meta = HttpService:JSONDecode(res.Body)
        if meta and meta.content then return b64Decode(meta.content) end
        return nil
    end)
    return ok and data or nil
end

local function ghGetSHA(path)
    local ok, sha = pcall(function()
        local h = {["User-Agent"]="AdminHub"}
        if GH_PAT~="" then h["Authorization"]="token "..GH_PAT end
        local res = httpRequest({Url=GH_API..path, Method="GET", Headers=h})
        if res and res.Body then
            local meta = HttpService:JSONDecode(res.Body)
            return meta and meta.sha or nil
        end
        return nil
    end)
    return ok and sha or nil
end

local function ghWrite(path, content, isRaw)
    -- isRaw=true → content sudah string, false → encode JSON dulu
    if GH_PAT=="" then return false, "PAT tidak diset!" end
    local strContent = isRaw and content or HttpService:JSONEncode(content)
    local sha = ghGetSHA(path)
    local body = HttpService:JSONEncode({
        message = "AdminHub: update "..path,
        content = b64Encode(strContent),
        sha     = sha,
        branch  = GH_BRANCH
    })
    local ok, err = pcall(function()
        local res = httpRequest({
            Url    = GH_API..path,
            Method = "PUT",
            Headers = {
                ["Authorization"] = "token "..GH_PAT,
                ["Content-Type"]  = "application/json",
                ["User-Agent"]    = "AdminHub"
            },
            Body = body
        })
        if res.StatusCode and res.StatusCode >= 400 then
            error("GitHub error "..tostring(res.StatusCode))
        end
    end)
    return ok, err
end

-- ══════════════════════════════════════════
--    ONLINE & SIGNALS
-- ══════════════════════════════════════════
local processedSignals = {}
local signalsReady     = false

local function registerOnline()
    local online = ghGet("online.json") or {}
    for i=#online,1,-1 do
        if tostring(online[i].Id)==tostring(player.UserId) then table.remove(online,i) end
    end
    table.insert(online, {
        Id       = tostring(player.UserId),
        Username = player.Name,
        Display  = player.DisplayName,
        LastSeen = os.time()
    })
    ghWrite("online.json", online)
end

local function heartbeat()
    while true do
        task.wait(25)
        pcall(function()
            local online = ghGet("online.json") or {}
            for _,e in ipairs(online) do
                if tostring(e.Id)==tostring(player.UserId) then
                    e.LastSeen=os.time() break
                end
            end
            ghWrite("online.json", online)
        end)
    end
end

player.AncestryChanged:Connect(function()
    if not player.Parent then
        pcall(function()
            local online = ghGet("online.json") or {}
            for i=#online,1,-1 do
                if tostring(online[i].Id)==tostring(player.UserId) then table.remove(online,i) end
            end
            ghWrite("online.json", online)
        end)
    end
end)

-- ══════════════════════════════════════════
--    MESSAGE FRAME GUI
-- ══════════════════════════════════════════
local msgGui = Instance.new("ScreenGui")
msgGui.Name="AdminHubMsgFrame" msgGui.ResetOnSpawn=false
msgGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
msgGui.IgnoreGuiInset=true msgGui.Enabled=false
msgGui.Parent=player.PlayerGui

local msgBG=Instance.new("Frame",msgGui)
msgBG.Size=UDim2.new(0,380,0,200) msgBG.Position=UDim2.new(0.5,-190,0.5,-100)
msgBG.BackgroundColor3=Color3.fromRGB(10,12,22) msgBG.BorderSizePixel=0 msgBG.ZIndex=30
do Instance.new("UICorner",msgBG).CornerRadius=UDim.new(0,14) end
do local s=Instance.new("UIStroke",msgBG) s.Color=Color3.fromHex("#87CEEB") s.Thickness=1.5 end
do local g=Instance.new("Frame",msgBG) g.Size=UDim2.new(1,0,0,2) g.BackgroundColor3=Color3.fromHex("#87CEEB") g.BorderSizePixel=0 g.ZIndex=31 Instance.new("UICorner",g).CornerRadius=UDim.new(0,2) end

local msgH=Instance.new("Frame",msgBG) msgH.Size=UDim2.new(1,0,0,46) msgH.BackgroundColor3=Color3.fromRGB(18,22,44) msgH.BorderSizePixel=0 msgH.ZIndex=31
do Instance.new("UICorner",msgH).CornerRadius=UDim.new(0,14) end
do local f=Instance.new("Frame",msgH) f.Size=UDim2.new(1,0,0.5,0) f.Position=UDim2.new(0,0,0.5,0) f.BackgroundColor3=Color3.fromRGB(18,22,44) f.BorderSizePixel=0 f.ZIndex=31 end

local msgFromLbl=Instance.new("TextLabel",msgH) msgFromLbl.Size=UDim2.new(1,-50,1,0) msgFromLbl.Position=UDim2.new(0,14,0,0) msgFromLbl.BackgroundTransparency=1 msgFromLbl.Text="📨  Message" msgFromLbl.TextColor3=Color3.fromRGB(220,230,255) msgFromLbl.Font=Enum.Font.GothamBold msgFromLbl.TextSize=14 msgFromLbl.TextXAlignment=Enum.TextXAlignment.Left msgFromLbl.ZIndex=32

local msgXBtn=Instance.new("TextButton",msgH) msgXBtn.Size=UDim2.new(0,28,0,28) msgXBtn.Position=UDim2.new(1,-38,0.5,-14) msgXBtn.BackgroundColor3=Color3.fromRGB(180,50,50) msgXBtn.TextColor3=Color3.fromRGB(255,255,255) msgXBtn.Font=Enum.Font.GothamBold msgXBtn.TextSize=13 msgXBtn.Text="✕" msgXBtn.BorderSizePixel=0 msgXBtn.ZIndex=32
do Instance.new("UICorner",msgXBtn).CornerRadius=UDim.new(0,6) end

local msgBodyLbl=Instance.new("TextLabel",msgBG) msgBodyLbl.Size=UDim2.new(1,-28,0,88) msgBodyLbl.Position=UDim2.new(0,14,0,56) msgBodyLbl.BackgroundTransparency=1 msgBodyLbl.Text="" msgBodyLbl.TextColor3=Color3.fromRGB(180,200,240) msgBodyLbl.Font=Enum.Font.Gotham msgBodyLbl.TextSize=13 msgBodyLbl.TextWrapped=true msgBodyLbl.TextXAlignment=Enum.TextXAlignment.Left msgBodyLbl.TextYAlignment=Enum.TextYAlignment.Top msgBodyLbl.ZIndex=31

local msgOK=Instance.new("TextButton",msgBG) msgOK.Size=UDim2.new(0,120,0,34) msgOK.Position=UDim2.new(0.5,-60,1,-44) msgOK.BackgroundColor3=Color3.fromHex("#87CEEB") msgOK.TextColor3=Color3.fromRGB(8,10,20) msgOK.Font=Enum.Font.GothamBold msgOK.TextSize=13 msgOK.Text="✓  OK" msgOK.BorderSizePixel=0 msgOK.ZIndex=32
do Instance.new("UICorner",msgOK).CornerRadius=UDim.new(0,8) end

local function showMsg(from, msg)
    msgFromLbl.Text="📨  From: "..from
    msgBodyLbl.Text=msg
    msgGui.Enabled=true
end
msgXBtn.MouseButton1Click:Connect(function() msgGui.Enabled=false end)
msgOK.MouseButton1Click:Connect(function() msgGui.Enabled=false end)

-- ══════════════════════════════════════════
--    PROCESS SIGNAL
-- ══════════════════════════════════════════
local function processSignal(sig)
    if processedSignals[sig.id] then return end
    processedSignals[sig.id]=true
    local t=sig.type local by=sig.by or "System"

    if t=="kick" then
        player:Kick('You have been kicked by "'..by..'"')
    elseif t=="ban" then
        pcall(function()
            local d=sig.data or {}
            local devs=ghGet("online.json") or {}
            -- simpan ban ke config lokal
            local banData={BanExpiry=(d.expiry or os.time()+60)}
            writefile(ASSETS.."/ban.json", HttpService:JSONEncode(banData))
        end)
        local d=sig.data or {}
        player:Kick(string.format('You been Ban Time Day %d hours %d Minute %d Second %d By "%s"',
            d.day or 0,d.hour or 0,d.min or 0,d.sec or 0,by))
    elseif t=="reset" then
        pcall(function() player:LoadCharacter() end)
    elseif t=="message" then
        local msg=(sig.data and sig.data.text) or "No message"
        showMsg(by, msg)
    end
end

local function preloadSignals()
    pcall(function()
        local sigs=ghGet("signals.json") or {}
        for _,s in ipairs(sigs) do processedSignals[s.id]=true end
    end)
    signalsReady=true
end

local function pollSignals()
    while not signalsReady do task.wait(0.5) end
    while true do
        task.wait(3)
        pcall(function()
            local sigs=ghGet("signals.json") or {}
            local updated=false
            for _,sig in ipairs(sigs) do
                if not processedSignals[sig.id] and sig.target==player.Name then
                    processSignal(sig)
                    sig.processed=true
                    updated=true
                end
            end
            if updated then ghWrite("signals.json", sigs) end
        end)
    end
end

-- ══════════════════════════════════════════
--    BAN CHECK ON START
-- ══════════════════════════════════════════
local function checkBan()
    if isfile(ASSETS.."/ban.json") then
        local ok,d=pcall(function() return HttpService:JSONDecode(readfile(ASSETS.."/ban.json")) end)
        if ok and d and d.BanExpiry then
            local now=os.time()
            if d.BanExpiry>now then
                local r=d.BanExpiry-now
                local dd=math.floor(r/86400)
                local hh=math.floor((r%86400)/3600)
                local mm=math.floor((r%3600)/60)
                local ss=r%60
                player:Kick(string.format("You been Ban Time Day %d hours %d Minute %d Second %d",dd,hh,mm,ss))
                return
            else
                -- expired, hapus
                pcall(function() writefile(ASSETS.."/ban.json","{}") end)
            end
        end
    end
end
checkBan()

-- ══════════════════════════════════════════
--    WINDUI
-- ══════════════════════════════════════════
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title  = "AdminHub",
    Icon   = "box",
    Author = "Khafidz",
    Folder = FOLDER,
})

Window:Tag({Title="1.0", Icon="terminal", Color=Color3.fromHex("#87CEEB"), Radius=0.5})

local TabInject   = Window:Tab({Title="Injector",  Icon="shield-alert"       })
local TabControls = Window:Tab({Title="Controls",  Icon="sliders-horizontal" })
local TabTest     = Window:Tab({Title="Test",       Icon="flask-conical"      })
local TabSettings = Window:Tab({Title="Settings",   Icon="settings"           })

-- ══════════════════════════════════════════
--    HELPER GUI
-- ══════════════════════════════════════════
local Gui=Instance.new("ScreenGui",player.PlayerGui)
Gui.Name="AdminHubGui" Gui.ResetOnSpawn=false
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling Gui.IgnoreGuiInset=true

local D1=Color3.fromRGB(10,12,22) local D2=Color3.fromRGB(16,18,32) local D3=Color3.fromRGB(22,26,46)
local AC=Color3.fromHex("#87CEEB") local TX=Color3.fromRGB(220,230,255) local ST=Color3.fromRGB(120,140,180)

local function mkC(p,r) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r or 10) end
local function mkS(p,c,t) for _,ch in ipairs(p:GetChildren()) do if ch:IsA("UIStroke") then ch:Destroy() end end local s=Instance.new("UIStroke",p) s.Color=c or Color3.fromRGB(60,80,120) s.Thickness=t or 1 end
local function mkP(p,l,r,t,b) local x=Instance.new("UIPadding",p) x.PaddingLeft=UDim.new(0,l or 0) x.PaddingRight=UDim.new(0,r or 0) x.PaddingTop=UDim.new(0,t or 0) x.PaddingBottom=UDim.new(0,b or 0) end
local function mkDrag(frame,handle)
    local drag,ds,sp
    handle.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true ds=i.Position sp=frame.Position end end)
    UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-ds frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
end

-- ══════════════════════════════════════════
--    INJECT FRAME (draggable)
-- ══════════════════════════════════════════
local OV=Instance.new("TextButton",Gui) OV.Size=UDim2.fromScale(1,1) OV.BackgroundColor3=Color3.fromRGB(0,0,0) OV.BackgroundTransparency=0.6 OV.BorderSizePixel=0 OV.Visible=false OV.ZIndex=8 OV.Text="" OV.AutoButtonColor=false

local IF=Instance.new("Frame",Gui) IF.Size=UDim2.new(0,500,0,520) IF.Position=UDim2.new(0.5,-250,0.5,-260) IF.BackgroundColor3=D1 IF.BorderSizePixel=0 IF.Visible=false IF.ZIndex=9 mkC(IF,14) mkS(IF,Color3.fromRGB(40,70,130),1.5)
do local g=Instance.new("Frame",IF) g.Size=UDim2.new(1,0,0,2) g.BackgroundColor3=AC g.BorderSizePixel=0 g.ZIndex=10 mkC(g,2) end

local IH=Instance.new("Frame",IF) IH.Size=UDim2.new(1,0,0,52) IH.BackgroundColor3=D3 IH.BorderSizePixel=0 IH.ZIndex=10 mkC(IH,14)
do local f=Instance.new("Frame",IH) f.Size=UDim2.new(1,0,0.5,0) f.Position=UDim2.new(0,0,0.5,0) f.BackgroundColor3=D3 f.BorderSizePixel=0 f.ZIndex=10 end
local IHIcon=Instance.new("TextLabel",IH) IHIcon.Size=UDim2.new(0,36,0,36) IHIcon.Position=UDim2.new(0,14,0.5,-18) IHIcon.BackgroundColor3=Color3.fromRGB(30,40,80) IHIcon.BorderSizePixel=0 IHIcon.Text="⚡" IHIcon.TextColor3=AC IHIcon.Font=Enum.Font.GothamBold IHIcon.TextSize=18 IHIcon.ZIndex=11 mkC(IHIcon,8)
local IHT=Instance.new("TextLabel",IH) IHT.Size=UDim2.new(1,-120,1,0) IHT.Position=UDim2.new(0,58,0,0) IHT.BackgroundTransparency=1 IHT.Text="Script Injector" IHT.TextColor3=TX IHT.Font=Enum.Font.GothamBold IHT.TextSize=15 IHT.TextXAlignment=Enum.TextXAlignment.Left IHT.ZIndex=11
local IXBtn=Instance.new("TextButton",IH) IXBtn.Size=UDim2.new(0,30,0,30) IXBtn.Position=UDim2.new(1,-42,0.5,-15) IXBtn.BackgroundColor3=Color3.fromRGB(180,50,50) IXBtn.TextColor3=Color3.fromRGB(255,255,255) IXBtn.Font=Enum.Font.GothamBold IXBtn.TextSize=14 IXBtn.Text="✕" IXBtn.BorderSizePixel=0 IXBtn.ZIndex=12 mkC(IXBtn,6)
mkDrag(IF,IH)

-- File name input
local FNWrap=Instance.new("Frame",IF) FNWrap.Size=UDim2.new(1,-24,0,38) FNWrap.Position=UDim2.new(0,12,0,62) FNWrap.BackgroundColor3=D2 FNWrap.BorderSizePixel=0 FNWrap.ZIndex=10 mkC(FNWrap,8) mkS(FNWrap,Color3.fromRGB(35,50,90),1)
local FNBox=Instance.new("TextBox",FNWrap) FNBox.Size=UDim2.new(1,0,1,0) FNBox.BackgroundTransparency=1 FNBox.PlaceholderText="Nama file (contoh: myscript.lua)" FNBox.PlaceholderColor3=ST FNBox.TextColor3=TX FNBox.Font=Enum.Font.Gotham FNBox.TextSize=13 FNBox.Text="" FNBox.ClearTextOnFocus=false FNBox.TextXAlignment=Enum.TextXAlignment.Left FNBox.ZIndex=11 mkP(FNBox,10,10,0,0)
FNBox.Focused:Connect(function() TweenService:Create(FNWrap,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(20,25,50)}):Play() mkS(FNWrap,AC,1.2) end)
FNBox.FocusLost:Connect(function() TweenService:Create(FNWrap,TweenInfo.new(0.2),{BackgroundColor3=D2}):Play() mkS(FNWrap,Color3.fromRGB(35,50,90),1) end)

-- File name label
local FNLbl=Instance.new("TextLabel",IF) FNLbl.Size=UDim2.new(1,-24,0,14) FNLbl.Position=UDim2.new(0,12,0,54) FNLbl.BackgroundTransparency=1 FNLbl.Text="File Name" FNLbl.TextColor3=ST FNLbl.Font=Enum.Font.GothamMedium FNLbl.TextSize=10 FNLbl.TextXAlignment=Enum.TextXAlignment.Left FNLbl.ZIndex=10

-- Code area
local SWrap=Instance.new("Frame",IF) SWrap.Size=UDim2.new(1,-24,0,300) SWrap.Position=UDim2.new(0,12,0,112) SWrap.BackgroundColor3=Color3.fromRGB(8,9,18) SWrap.BorderSizePixel=0 SWrap.ZIndex=10 mkC(SWrap,8) mkS(SWrap,Color3.fromRGB(30,45,90),1)
local SBox=Instance.new("TextBox",SWrap) SBox.Size=UDim2.new(1,0,1,0) SBox.BackgroundTransparency=1 SBox.PlaceholderText="-- Paste script kamu di sini...\n-- Bisa berupa apapun: print(), GUI, loadstring(), dll." SBox.PlaceholderColor3=ST SBox.TextColor3=Color3.fromHex("#87CEEB") SBox.Font=Enum.Font.Code SBox.TextSize=12 SBox.Text="" SBox.MultiLine=true SBox.ClearTextOnFocus=false SBox.TextXAlignment=Enum.TextXAlignment.Left SBox.TextYAlignment=Enum.TextYAlignment.Top SBox.ZIndex=11 mkP(SBox,10,10,8,8)
local SLbl=Instance.new("TextLabel",IF) SLbl.Size=UDim2.new(1,-24,0,14) SLbl.Position=UDim2.new(0,12,0,104) SLbl.BackgroundTransparency=1 SLbl.Text="Script Content" SLbl.TextColor3=ST SLbl.Font=Enum.Font.GothamMedium SLbl.TextSize=10 SLbl.TextXAlignment=Enum.TextXAlignment.Left SLbl.ZIndex=10

-- Status label
local StatusLbl=Instance.new("TextLabel",IF) StatusLbl.Size=UDim2.new(1,-140,0,16) StatusLbl.Position=UDim2.new(0,12,1,-50) StatusLbl.BackgroundTransparency=1 StatusLbl.Text="" StatusLbl.TextColor3=ST StatusLbl.Font=Enum.Font.Gotham StatusLbl.TextSize=11 StatusLbl.TextXAlignment=Enum.TextXAlignment.Left StatusLbl.ZIndex=10

-- Inject button
local InjectBtn=Instance.new("TextButton",IF) InjectBtn.Size=UDim2.new(0,120,0,38) InjectBtn.Position=UDim2.new(1,-132,1,-48) InjectBtn.BackgroundColor3=AC InjectBtn.TextColor3=Color3.fromRGB(8,10,20) InjectBtn.Font=Enum.Font.GothamBold InjectBtn.TextSize=14 InjectBtn.Text="⚡ Inject" InjectBtn.BorderSizePixel=0 InjectBtn.ZIndex=10 mkC(InjectBtn,8)

-- Raw URL copy frame (muncul setelah inject berhasil)
local URLFrame=Instance.new("Frame",IF) URLFrame.Size=UDim2.new(1,-24,0,0) URLFrame.Position=UDim2.new(0,12,0,420) URLFrame.BackgroundColor3=D2 URLFrame.BorderSizePixel=0 URLFrame.ZIndex=10 URLFrame.Visible=false mkC(URLFrame,8) mkS(URLFrame,AC,1)
local URLLbl=Instance.new("TextLabel",URLFrame) URLLbl.Size=UDim2.new(1,-100,1,0) URLLbl.Position=UDim2.new(0,8,0,0) URLLbl.BackgroundTransparency=1 URLLbl.Text="" URLLbl.TextColor3=Color3.fromHex("#87CEEB") URLLbl.Font=Enum.Font.Code URLLbl.TextSize=10 URLLbl.TextWrapped=true URLLbl.TextXAlignment=Enum.TextXAlignment.Left URLLbl.ZIndex=11
local CopyBtn=Instance.new("TextButton",URLFrame) CopyBtn.Size=UDim2.new(0,80,0,28) CopyBtn.Position=UDim2.new(1,-88,0.5,-14) CopyBtn.BackgroundColor3=Color3.fromRGB(30,80,160) CopyBtn.TextColor3=Color3.fromRGB(220,230,255) CopyBtn.Font=Enum.Font.GothamBold CopyBtn.TextSize=11 CopyBtn.Text="📋 Copy" CopyBtn.BorderSizePixel=0 CopyBtn.ZIndex=11 mkC(CopyBtn,6)

-- ══════════════════════════════════════════
--    INJECT LOGIC
-- ══════════════════════════════════════════
local lastRawURL = ""

local function setStatus(msg, color)
    StatusLbl.Text=msg StatusLbl.TextColor3=color or ST
end

local function injectScript()
    local fname = FNBox.Text:gsub("^%s*(.-)%s*$","%1")
    local code  = SBox.Text

    -- Validasi nama file
    if fname=="" then
        setStatus("❌ Nama file tidak boleh kosong!", Color3.fromRGB(224,85,85)) return
    end
    if not fname:match("%.lua$") then fname=fname..".lua" end
    if fname:match("[/\\%*%?<>|\":]") then
        setStatus("❌ Nama file mengandung karakter tidak valid!", Color3.fromRGB(224,85,85)) return
    end

    -- Validasi kode
    if code=="" then
        setStatus("❌ Script tidak boleh kosong!", Color3.fromRGB(224,85,85)) return
    end
    local fn, err = loadstring(code)
    if not fn then
        local short = tostring(err):match("%[.-%]:(.+)") or tostring(err)
        setStatus("❌ Syntax Error: "..short, Color3.fromRGB(224,85,85)) return
    end

    -- Simpan lokal dulu
    pcall(function() writefile(SCRIPTS_FOLDER.."/"..fname, code) end)

    -- Upload ke GitHub
    setStatus("⏳ Mengupload ke GitHub...", Color3.fromRGB(224,196,85))
    InjectBtn.Text="⏳..."
    InjectBtn.Active=false

    task.spawn(function()
        local ghPath = "scripts/"..fname
        local ok, ghErr = ghWrite(ghPath, code, true)

        if ok then
            lastRawURL = "https://raw.githubusercontent.com/"..GH_OWNER.."/"..GH_REPO.."/"..GH_BRANCH.."/"..GH_PATH.."/scripts/"..fname
            URLLbl.Text = lastRawURL
            URLFrame.Size = UDim2.new(1,-24,0,42)
            URLFrame.Visible = true
            setStatus("✅ Script berhasil di-inject!", Color3.fromRGB(85,224,154))
            WindUI:Notify({Title="✅ Inject Berhasil!",Content=fname.." tersimpan di GitHub.\nRaw URL sudah siap disalin.",Duration=5})
        else
            setStatus("❌ Upload gagal: "..tostring(ghErr), Color3.fromRGB(224,85,85))
            WindUI:Notify({Title="❌ Inject Gagal",Content=tostring(ghErr),Duration=5})
        end

        InjectBtn.Text="⚡ Inject"
        InjectBtn.Active=true
    end)
end

InjectBtn.MouseButton1Click:Connect(injectScript)
IXBtn.MouseButton1Click:Connect(function() IF.Visible=false OV.Visible=false end)
OV.MouseButton1Click:Connect(function() IF.Visible=false OV.Visible=false end)

CopyBtn.MouseButton1Click:Connect(function()
    if lastRawURL~="" then
        setclipboard(lastRawURL)
        CopyBtn.Text="✓ Copied!"
        task.wait(2)
        CopyBtn.Text="📋 Copy"
    end
end)

-- ══════════════════════════════════════════
--    INJECTOR TAB
-- ══════════════════════════════════════════
TabInject:Paragraph({
    Title="⚡ Script Injector",
    Desc ="Upload script ke GitHub repo. Script tersimpan di folder /scripts dan auto-generate raw URL.",
    Color="Blue"
})
TabInject:Button({Title="Open Injector",Icon="shield-alert",Callback=function()
    FNBox.Text="" SBox.Text="" StatusLbl.Text="" URLFrame.Visible=false URLFrame.Size=UDim2.new(1,-24,0,0) lastRawURL=""
    OV.Visible=true IF.Visible=true
    IF:TweenPosition(UDim2.new(0.5,-250,0.5,-260),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.3,true)
end})

-- Daftar script yang sudah ada di folder lokal
TabInject:Paragraph({Title="📁 Scripts Lokal",Desc="Script yang tersimpan di DeltaWorkspace/AdminHub/scripts/",Color="Blue"})

local scriptFiles = {}
pcall(function()
    scriptFiles = listfiles(SCRIPTS_FOLDER) or {}
end)

if #scriptFiles==0 then
    TabInject:Paragraph({Title="Kosong",Desc="Belum ada script. Inject dulu!",Color="Blue"})
else
    for _, fpath in ipairs(scriptFiles) do
        local fname = fpath:match("([^/\\]+)$") or fpath
        TabInject:Button({
            Title=fname, Icon="file-code",
            Callback=function()
                WindUI:Notify({Title="⏳ Running...",Content="Menjalankan "..fname,Duration=2})
                local code=readfile(fpath)
                local fn,err=loadstring(code)
                if fn then
                    task.spawn(fn)
                    WindUI:Notify({Title="✅ Ran!",Content=fname.." berhasil dijalankan.",Duration=3})
                else
                    WindUI:Notify({Title="❌ Error",Content=tostring(err),Duration=5})
                end
            end
        })
    end
end

TabInject:Button({Title="🗑  Reset / Clear Scripts",Icon="trash-2",Callback=function()
    WindUI:Notify({Title="⏳",Content="Menghapus semua script lokal...",Duration=2})
    pcall(function()
        local files=listfiles(SCRIPTS_FOLDER) or {}
        for _,f in ipairs(files) do pcall(delfile,f) end
    end)
    WindUI:Notify({Title="✅ Cleared!",Content="Semua script lokal dihapus. Re-inject untuk mengisi ulang.",Duration=4})
end})

-- ══════════════════════════════════════════
--    CONTROLS TAB
-- ══════════════════════════════════════════
local ctrlTarget = ""

TabControls:Paragraph({Title="🎯 Target Player",Desc="Pilih target dulu sebelum menjalankan aksi.",Color="Blue"})
TabControls:Input({Title="Target Username",Placeholder="Username player...",Callback=function(v) ctrlTarget=v end})

local function sendSignal(type_, data)
    if ctrlTarget=="" then
        WindUI:Notify({Title="❌",Content="Target username kosong!",Duration=3}) return
    end
    WindUI:Notify({Title="⏳ Sending...",Content="Mengirim sinyal "..type_.." ke "..ctrlTarget,Duration=2})
    task.spawn(function()
        local sigs=ghGet("signals.json") or {}
        table.insert(sigs,{
            id        = tostring(os.time())..tostring(math.random(1000,9999)),
            type      = type_,
            target    = ctrlTarget,
            by        = player.Name,
            data      = data or {},
            processed = false,
            timestamp = os.time()
        })
        local ok=ghWrite("signals.json", sigs)
        if ok then
            WindUI:Notify({Title="✅ Sent!",Content='Sinyal "'..type_..'" terkirim ke '..ctrlTarget,Duration=3})
        else
            WindUI:Notify({Title="❌ Gagal",Content="Gagal kirim sinyal. Cek PAT!",Duration=4})
        end
    end)
end

-- Kick
TabControls:Button({Title="👢 Kick",Icon="user-x",Callback=function()
    sendSignal("kick",{})
end})

-- Ban Time
local bD,bH,bM,bS=0,0,0,0
TabControls:Paragraph({Title="⏱️ Ban Time",Desc="Maksimal: 3 hari, 24 jam, 60 menit, 60 detik.",Color="Blue"})
TabControls:Input({Title="Day (max 3)",Placeholder="0",Callback=function(v) bD=tonumber(v) or 0 end})
TabControls:Input({Title="Hour (max 24)",Placeholder="0",Callback=function(v) bH=tonumber(v) or 0 end})
TabControls:Input({Title="Minute (max 60)",Placeholder="0",Callback=function(v) bM=tonumber(v) or 0 end})
TabControls:Input({Title="Second (max 60)",Placeholder="0",Callback=function(v) bS=tonumber(v) or 0 end})
TabControls:Button({Title="⏱️ Apply Ban Time",Icon="clock",Callback=function()
    if (bD or 0)>3 or (bH or 0)>24 or (bM or 0)>60 or (bS or 0)>60 then
        WindUI:Notify({Title="❌",Content="Melebihi batas maksimum!",Duration=3}) return end
    if bD==0 and bH==0 and bM==0 and bS==0 then
        WindUI:Notify({Title="❌",Content="Durasi tidak boleh 0!",Duration=3}) return end
    local expiry=os.time()+(bD or 0)*86400+(bH or 0)*3600+(bM or 0)*60+(bS or 0)
    sendSignal("ban",{day=bD,hour=bH,min=bM,sec=bS,expiry=expiry})
end})

-- Reset
TabControls:Button({Title="🔄 Reset Character",Icon="rotate-cw",Callback=function()
    sendSignal("reset",{})
end})

-- Message
local msgInput=""
TabControls:Input({Title="Message",Placeholder="Tulis pesan...",Callback=function(v) msgInput=v end})
TabControls:Button({Title="📨 Send Message",Icon="message-square",Callback=function()
    if msgInput=="" then WindUI:Notify({Title="❌",Content="Pesan kosong!",Duration=3}) return end
    sendSignal("message",{text=msgInput})
end})

-- Teleport
TabControls:Button({Title="🚀 Teleport To Player",Icon="navigation",Callback=function()
    if ctrlTarget=="" then WindUI:Notify({Title="❌",Content="Target kosong!",Duration=3}) return end
    WindUI:Notify({Title="⏳",Content="Mencari game "..ctrlTarget.."...",Duration=2})
    task.spawn(function()
        local ok2,userId=pcall(function()
            local d=HttpService:JSONDecode(game:HttpGet("https://users.roblox.com/v1/users/search?keyword="..HttpService:UrlEncode(ctrlTarget).."&limit=5"))
            if d and d.data then for _,u in ipairs(d.data) do if u.name==ctrlTarget then return u.id end end end
            return nil
        end)
        if not ok2 or not userId then WindUI:Notify({Title="❌",Content="User tidak ditemukan!",Duration=4}) return end
        local ok3,presence=pcall(function()
            local res=httpRequest({Url="https://presence.roblox.com/v1/presence/users",Method="POST",Headers={["Content-Type"]="application/json"},Body=HttpService:JSONEncode({userIds={userId}})})
            if res and res.Body then return HttpService:JSONDecode(res.Body) end
            return nil
        end)
        if not ok3 or not presence then WindUI:Notify({Title="❌",Content="Gagal cek presence!",Duration=4}) return end
        local up=presence.userPresences and presence.userPresences[1]
        if not up or not up.placeId or up.placeId==0 then
            WindUI:Notify({Title="❌",Content=ctrlTarget.." tidak sedang bermain game!",Duration=4}) return
        end
        TS:Teleport(up.placeId,player)
    end)
end})

-- ══════════════════════════════════════════
--    TEST TAB
-- ══════════════════════════════════════════
TabTest:Paragraph({Title="🧪 Test Controls",Desc="Lihat siapa yang pakai AdminHub dan test fitur ke mereka.",Color="Blue"})

TabTest:Button({Title="🔍 Refresh Online Players",Icon="refresh-cw",Callback=function()
    WindUI:Notify({Title="⏳",Content="Memuat daftar online...",Duration=2})
    task.spawn(function()
        local online=ghGet("online.json") or {}
        local now=os.time()
        local active={}
        for _,p in ipairs(online) do
            if (now-(p.LastSeen or 0))<60 then table.insert(active,p) end
        end
        if #active==0 then
            WindUI:Notify({Title="📋 Online",Content="Tidak ada player online saat ini.",Duration=5}) return
        end
        local lines={"🟢 "..#active.." player online:\n"}
        for _,p in ipairs(active) do
            table.insert(lines,"• "..p.Username..(p.Display~=p.Username and " ("..p.Display..")" or ""))
        end
        WindUI:Notify({Title="🟢 Online Players",Content=table.concat(lines,"\n"),Duration=8})
    end)
end})

-- Test ke diri sendiri
TabTest:Paragraph({Title="🎯 Test ke diri sendiri",Desc="Fitur sama persis seperti Controls tapi target = kamu sendiri.",Color="Blue"})

TabTest:Button({Title="Test Reset",Icon="rotate-cw",Callback=function()
    WindUI:Notify({Title="⏳",Content="Testing reset...",Duration=1})
    task.wait(1)
    pcall(function() player:LoadCharacter() end)
end})

local testMsg=""
TabTest:Input({Title="Test Message",Placeholder="Tulis pesan tes...",Callback=function(v) testMsg=v end})
TabTest:Button({Title="Test Message Frame",Icon="message-square",Callback=function()
    if testMsg=="" then WindUI:Notify({Title="❌",Content="Pesan kosong!",Duration=3}) return end
    showMsg("Test (You)", testMsg)
end})

-- ══════════════════════════════════════════
--    SETTINGS TAB
-- ══════════════════════════════════════════
TabSettings:Paragraph({Title="⚙️ Config",Desc="PAT dan repo config tersimpan di DeltaWorkspace/AdminHub/assets/config.json",Color="Blue"})

local cfgPAT,cfgOwner,cfgRepo,cfgBranch,cfgPath=GH_PAT,GH_OWNER,GH_REPO,GH_BRANCH,GH_PATH
TabSettings:Input({Title="GitHub PAT",Placeholder="ghp_...",Callback=function(v) cfgPAT=v end})
TabSettings:Input({Title="Repo Owner",Placeholder=GH_OWNER,Callback=function(v) cfgOwner=v end})
TabSettings:Input({Title="Repo Name",Placeholder=GH_REPO,Callback=function(v) cfgRepo=v end})
TabSettings:Input({Title="Branch",Placeholder=GH_BRANCH,Callback=function(v) cfgBranch=v end})
TabSettings:Input({Title="Path",Placeholder=GH_PATH,Callback=function(v) cfgPath=v end})
TabSettings:Button({Title="💾 Save Config",Icon="save",Callback=function()
    local cfg={PAT=cfgPAT,Owner=cfgOwner,Repo=cfgRepo,Branch=cfgBranch,Path=cfgPath}
    writefile(CFG_JSON, HttpService:JSONEncode(cfg))
    WindUI:Notify({Title="✅ Saved!",Content="Config tersimpan! Re-execute script untuk apply.",Duration=4})
end})

-- ══════════════════════════════════════════
--    START BACKGROUND TASKS
-- ══════════════════════════════════════════
task.spawn(function()
    if GH_PAT~="" then
        preloadSignals()
        registerOnline()
        task.spawn(heartbeat)
        task.spawn(pollSignals)
        WindUI:Notify({Title="✅ AdminHub Ready",Content="Terhubung ke GitHub. Signal polling aktif.",Duration=4})
    else
        WindUI:Notify({Title="⚠️ Config",Content="PAT belum diset!\nPergi ke tab Settings dan isi PAT.",Duration=6})
    end
end)
