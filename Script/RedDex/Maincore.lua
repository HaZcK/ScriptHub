-- ╔══════════════════════════════════════════╗
-- ║         UniverseHub - Maincore           ║
-- ║         Author: Khafidz (KHAFIDZKTP)    ║
-- ╚══════════════════════════════════════════╝
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/RedDex/Maincore.lua"))()

local Players      = game:GetService("Players")
local HttpService  = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local TS           = game:GetService("TeleportService")
local player       = Players.LocalPlayer

-- ══════════════════════════════════════════
--    EXECUTOR FOLDER DETECTION
-- ══════════════════════════════════════════
local POSSIBLE_ROOTS = { "", "DeltaWorkspace/", "workspace/", "scripts/", "autoexec/", "Synapse/", "KRNL/", "Delta/", "Fluxus/", "Arceus/", "Hydrogen/" }
local ROOT = ""
for _, r in ipairs(POSSIBLE_ROOTS) do
    pcall(function() if r ~= "" and isfolder(r.."GlobalHub") then ROOT = r end end)
    if ROOT ~= "" then break end
end

local FOLDER      = ROOT.."GlobalHub"
local ASSETS_PATH = ROOT.."GlobalHub/assets"
local SCRIPTS_JSON= ASSETS_PATH.."/ScriptUser.json"
local ALGO_JSON   = ASSETS_PATH.."/Algorithm.json"
local CFG_JSON    = ASSETS_PATH.."/config.json"

for _, f in ipairs({FOLDER, ASSETS_PATH}) do
    if not isfolder(f) then pcall(makefolder, f) end
end

-- ══════════════════════════════════════════
--    CONFIG (PAT dari lokal)
-- ══════════════════════════════════════════
local GH_PAT = ""
local GH_RAW = "https://raw.githubusercontent.com/HaZcK/ScriptHub/main/Script/RedDex/"
local GH_API = "https://api.github.com/repos/HaZcK/ScriptHub/contents/Script/RedDex/"

local function loadConfig()
    if isfile(CFG_JSON) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CFG_JSON)) end)
        if ok and type(data) == "table" then GH_PAT = data.PAT or "" end
    end
end
loadConfig()

-- ══════════════════════════════════════════
--    BASE64 (untuk GitHub API write)
-- ══════════════════════════════════════════
local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function base64Encode(data)
    return ((data:gsub(".", function(x)
        local r, b = "", x:byte()
        for i = 8, 1, -1 do r = r..(b % 2^i - b % 2^(i-1) > 0 and "1" or "0") end
        return r
    end).."0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
        if #x < 6 then return "" end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i,i) == "1" and 2^(6-i) or 0) end
        return b64:sub(c+1, c+1)
    end)..({ "", "==", "=" })[#data % 3 + 1])
end

-- ══════════════════════════════════════════
--    GITHUB READ / WRITE
-- ══════════════════════════════════════════
local function ghGet(file)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(GH_RAW..file.."?t="..os.time()))
    end)
    return ok and data or nil
end

local function ghWrite(file, tbl)
    if GH_PAT == "" then return false end
    local content = HttpService:JSONEncode(tbl)
    -- Get SHA
    local sha = nil
    pcall(function()
        local meta = HttpService:JSONDecode(game:HttpGet(GH_API..file))
        sha = meta.sha
    end)
    local body = HttpService:JSONEncode({
        message = "Update "..file,
        content = base64Encode(content),
        sha     = sha,
        branch  = "main"
    })
    local ok = pcall(function()
        request({
            Url     = GH_API..file,
            Method  = "PUT",
            Headers = {
                ["Authorization"] = "token "..GH_PAT,
                ["Content-Type"]  = "application/json",
                ["User-Agent"]    = "UniverseHub"
            },
            Body = body
        })
    end)
    return ok
end

-- ══════════════════════════════════════════
--    LOCAL SAVE/LOAD
-- ══════════════════════════════════════════
local scriptList = {}
local function loadScripts()
    if isfile(SCRIPTS_JSON) then
        local ok, d = pcall(function() return HttpService:JSONDecode(readfile(SCRIPTS_JSON)) end)
        if ok and type(d) == "table" then scriptList = d end
    end
end
local function saveScripts()
    pcall(writefile, SCRIPTS_JSON, HttpService:JSONEncode(scriptList))
end
loadScripts()

local algo = { searches={}, viewed={}, tags={} }
local function loadAlgo()
    if isfile(ALGO_JSON) then
        local ok, d = pcall(function() return HttpService:JSONDecode(readfile(ALGO_JSON)) end)
        if ok and type(d) == "table" then algo = d end
    end
    algo.searches = algo.searches or {}
    algo.viewed   = algo.viewed   or {}
    algo.tags     = algo.tags     or {}
end
local function saveAlgo() pcall(writefile, ALGO_JSON, HttpService:JSONEncode(algo)) end
loadAlgo()

local function recordSearch(kw)
    table.insert(algo.searches, 1, kw)
    if #algo.searches > 30 then algo.searches[31] = nil end
    saveAlgo()
end
local function recordView(title, game_)
    table.insert(algo.viewed, 1, {title=title, game=game_ or ""})
    if #algo.viewed > 50 then algo.viewed[51] = nil end
    if game_ and game_ ~= "" then algo.tags[game_] = (algo.tags[game_] or 0) + 1 end
    saveAlgo()
end
local function recommendScore(e)
    local s = 0
    if e.Game and e.NameGame then s = s + (algo.tags[e.NameGame] or 0) * 3 end
    for _, kw in ipairs(algo.searches) do if e.Title:lower():find(kw:lower(),1,true) then s = s + 2 end end
    for _, v in ipairs(algo.viewed) do if v.title == e.Title then s = s + 1 end end
    return s
end

-- ══════════════════════════════════════════
--    VALIDATION
-- ══════════════════════════════════════════
local function validateDate(s)
    if not s or s=="" then return false,"Tanggal wajib diisi!" end
    local d,m,y = s:match("^(%d+)/(%d+)/(%d+)$")
    if not d then return false,"Format salah! Contoh: 1/7/2025" end
    d,m,y=tonumber(d),tonumber(m),tonumber(y)
    if d<1 or d>31 then return false,"Hari tidak valid!" end
    if m<1 or m>12 then return false,"Bulan tidak valid!" end
    if y<2000 or y>2100 then return false,"Tahun tidak valid!" end
    return true
end
local function validateCode(code)
    if not code or code=="" then return false,"Script wajib diisi!" end
    if #code < 5 then return false,"Script terlalu pendek!" end
    local fn,err = loadstring(code)
    if not fn then return false,"Syntax Error: "..(tostring(err):match("%[.-%]:(.+)") or tostring(err)) end
    return true
end
local function validateGame(name)
    if not name or name=="" then return false,"Nama game wajib diisi!" end
    local ok,result = pcall(function()
        local raw = game:HttpGet("https://games.roblox.com/v1/games/search?keyword="..HttpService:UrlEncode(name).."&limit=25")
        local data = HttpService:JSONDecode(raw)
        if data and data.data then for _,g in ipairs(data.data) do if g.name==name then return true end end end
        return false
    end)
    if not ok then return false,"Gagal cek Roblox API!" end
    if not result then return false,"Game Not Found!" end
    return true
end

-- ══════════════════════════════════════════
--    BLACKLIST & BAN CHECK
-- ══════════════════════════════════════════
local myDev = nil -- entry developer.json milik player ini
local ROLE_LEVEL = {Visitor=0,Admin=1,Developer=2,Moderate=3,["Co-Owner"]=4,Owner=5}

local function checkDeveloperJson()
    local devs = ghGet("developer.json")
    if not devs or type(devs) ~= "table" then return end
    for _, entry in ipairs(devs) do
        if tostring(entry.Id) == tostring(player.UserId) or entry.Username == player.Name then
            myDev = entry
            break
        end
    end
    -- Check blacklist
    if myDev and myDev.Blacklist == true then
        player:Kick("You have been blacklisted From Moderate!")
        return
    end
    -- Check ban time
    if myDev and myDev.BanExpiry then
        local now = os.time()
        if myDev.BanExpiry > now then
            local remaining = myDev.BanExpiry - now
            local d = math.floor(remaining / 86400)
            local h = math.floor((remaining % 86400) / 3600)
            local m = math.floor((remaining % 3600) / 60)
            local s = remaining % 60
            player:Kick(string.format("You been Ban Time Day %d hours %d Minute %d Second %d", d, h, m, s))
            return
        end
    end
    -- Register player in developer.json if not exists
    if not myDev then
        myDev = {
            Id        = tostring(player.UserId),
            Username  = player.Name,
            Role      = "Visitor",
            Blacklist = false
        }
        local updated = devs
        table.insert(updated, myDev)
        ghWrite("developer.json", updated)
    end
end

-- ══════════════════════════════════════════
--    ONLINE REGISTRATION & HEARTBEAT
-- ══════════════════════════════════════════
local function registerOnline()
    local online = ghGet("online.json") or {}
    -- Remove old entry if exists
    for i = #online, 1, -1 do
        if tostring(online[i].Id) == tostring(player.UserId) then
            table.remove(online, i)
        end
    end
    table.insert(online, {
        Id       = tostring(player.UserId),
        Username = player.Name,
        LastSeen = os.time()
    })
    ghWrite("online.json", online)
end

local function heartbeat()
    while true do
        task.wait(30)
        pcall(function()
            local online = ghGet("online.json") or {}
            for _, entry in ipairs(online) do
                if tostring(entry.Id) == tostring(player.UserId) then
                    entry.LastSeen = os.time()
                    break
                end
            end
            ghWrite("online.json", online)
        end)
    end
end

-- Remove self from online on disconnect (executor safe)
-- Remove self from online when leaving
player.AncestryChanged:Connect(function()
    if not player.Parent then
        pcall(function()
            local online = ghGet("online.json") or {}
            for i = #online, 1, -1 do
                if tostring(online[i].Id) == tostring(player.UserId) then
                    table.remove(online, i)
                end
            end
            ghWrite("online.json", online)
        end)
    end
end)

-- ══════════════════════════════════════════
--    SIGNAL POLLING
-- ══════════════════════════════════════════
local processedSignals = {}

local function processSignal(sig)
    if processedSignals[sig.id] then return end
    processedSignals[sig.id] = true

    local t = sig.type
    local by = sig.by or "System"

    if t == "kick" then
        player:Kick('You have been kicked by "'..by..'"')

    elseif t == "ban" then
        local d = sig.data or {}
        player:Kick(string.format('You been Ban Time Day %d hours %d Minute %d Second %d By "%s"',
            d.day or 0, d.hour or 0, d.min or 0, d.sec or 0, by))

    elseif t == "reset" then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end

    elseif t == "message" then
        local msg = (sig.data and sig.data.text) or "Message from Admin"
        -- Will be shown via WindUI notify after WindUI loads
        task.spawn(function()
            task.wait(2)
            if WindUI then
                WindUI:Notify({ Title="📨 Message from "..by, Content=msg, Duration=8 })
            end
        end)

    elseif t == "blacklist" then
        player:Kick("You have been blacklisted From Moderate!")
    end
end

local function pollSignals()
    while true do
        task.wait(3)
        pcall(function()
            local sigs = ghGet("signals.json")
            if not sigs or type(sigs) ~= "table" then return end
            local updated = false
            for _, sig in ipairs(sigs) do
                if not sig.processed and sig.target == player.Name then
                    processSignal(sig)
                    sig.processed = true
                    updated = true
                end
            end
            if updated then ghWrite("signals.json", sigs) end
        end)
    end
end

-- ══════════════════════════════════════════
--    AUTO TELEPORT TO PLAYER'S GAME
-- ══════════════════════════════════════════
local function teleportToPlayer(targetUsername)
    -- Cari UserId dari username
    local ok, userId = pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet(
            "https://users.roblox.com/v1/users/search?keyword="..HttpService:UrlEncode(targetUsername).."&limit=5"
        ))
        if data and data.data then
            for _, u in ipairs(data.data) do
                if u.name == targetUsername then return u.id end
            end
        end
        return nil
    end)
    if not ok or not userId then return false, "User not found" end

    -- Cari game yang sedang dimainkan
    local ok2, presence = pcall(function()
        local raw = HttpService:JSONDecode(game:HttpGet(
            "https://presence.roblox.com/v1/presence/users",
            false, -- tidak pakai cache
            {["Content-Type"]="application/json"},
            HttpService:JSONEncode({userIds={userId}})
        ))
        return raw
    end)
    if not ok2 or not presence then return false, "Gagal cek presence" end
    local userPresence = presence.userPresences and presence.userPresences[1]
    if not userPresence or not userPresence.placeId or userPresence.placeId == 0 then
        return false, "Player tidak sedang bermain game apapun"
    end
    TS:Teleport(userPresence.placeId, player)
    return true
end

-- ══════════════════════════════════════════
--    WINDUI SETUP
-- ══════════════════════════════════════════
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

-- Sekarang bisa kirim message yang pending
local _WindUI = WindUI

local Window = WindUI:CreateWindow({
    Title  = "UniverseHub",
    Icon   = "aperture",
    Author = "Khafidz",
    Folder = FOLDER,
    User   = {
        Enabled   = true,
        Anonymous = false,
        Callback  = function()
            print("Display Name : "..player.DisplayName)
            print("Username     : "..player.Name)
            print("ID           : "..tostring(player.UserId))
            WindUI:Notify({Title="Info Player", Content="Logged in: "..player.DisplayName, Duration=4})
        end,
    },
})

Window:Tag({Title="1.0", Icon="file-text", Color=Color3.fromHex("#87CEEB"), Radius=0.5})

local TabScripts = Window:Tab({Title="Scripts",     Icon="library"     })
local TabRec     = Window:Tab({Title="Recommended", Icon="star"        })
local TabLog     = Window:Tab({Title="Update Log",  Icon="scroll-text" })

-- Role-based tabs
local myRole  = myDev and myDev.Role or "Visitor"
local myLevel = ROLE_LEVEL[myRole] or 0

local TabAdmin = myLevel >= 1 and Window:Tab({Title="Role Admin",  Icon="shield"   }) or nil
local TabDev   = myLevel >= 2 and Window:Tab({Title="Role Dev",    Icon="wrench"   }) or nil
local TabMod   = myLevel >= 3 and Window:Tab({Title="Moderate",    Icon="eye"      }) or nil
local TabCO    = myLevel >= 4 and Window:Tab({Title="Co-Owner",    Icon="crown"    }) or nil

TabLog:Paragraph({Title="Update Log", Desc="WHERE IS THERE AN UPDATE THAT IS STILL RELEASED", Color="Blue"})

-- ══════════════════════════════════════════
--    GUI HELPERS
-- ══════════════════════════════════════════
local D1=Color3.fromRGB(10,12,22) local D2=Color3.fromRGB(16,18,32) local D3=Color3.fromRGB(22,26,46)
local AC=Color3.fromHex("#87CEEB") local TX=Color3.fromRGB(220,230,255) local ST=Color3.fromRGB(120,140,180)

local function mkCorner(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 10) c.Parent=p end
local function mkStroke(p,col,th)
    for _,ch in ipairs(p:GetChildren()) do if ch:IsA("UIStroke") then ch:Destroy() end end
    local s=Instance.new("UIStroke") s.Color=col or Color3.fromRGB(60,80,120) s.Thickness=th or 1 s.Parent=p return s
end
local function mkPad(p,l,r,t,b)
    local x=Instance.new("UIPadding")
    x.PaddingLeft=UDim.new(0,l or 0) x.PaddingRight=UDim.new(0,r or 0)
    x.PaddingTop=UDim.new(0,t or 0)  x.PaddingBottom=UDim.new(0,b or 0) x.Parent=p
end

local Gui=Instance.new("ScreenGui")
Gui.Name="UniverseHubGui" Gui.ResetOnSpawn=false
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling Gui.IgnoreGuiInset=true Gui.Parent=player.PlayerGui

local function mkDrag(frame, handle)
    local drag,ds,sp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true ds=i.Position sp=frame.Position end end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
end

-- ══════════════════════════════════════════
--    ADD SCRIPT FRAME
-- ══════════════════════════════════════════
local Overlay=Instance.new("Frame",Gui)
Overlay.Size=UDim2.fromScale(1,1) Overlay.BackgroundColor3=Color3.fromRGB(0,0,0)
Overlay.BackgroundTransparency=0.6 Overlay.BorderSizePixel=0 Overlay.Visible=false Overlay.ZIndex=8

local AF=Instance.new("Frame",Gui)
AF.Size=UDim2.new(0,480,0,560) AF.Position=UDim2.new(0.5,-240,0.5,-280)
AF.BackgroundColor3=D1 AF.BorderSizePixel=0 AF.Visible=false AF.ZIndex=9
mkCorner(AF,14) mkStroke(AF,Color3.fromRGB(40,70,130),1.5)

local GB=Instance.new("Frame",AF) GB.Size=UDim2.new(1,0,0,2) GB.BackgroundColor3=AC GB.BorderSizePixel=0 GB.ZIndex=10 mkCorner(GB,2)
local AH=Instance.new("Frame",AF) AH.Size=UDim2.new(1,0,0,52) AH.BackgroundColor3=D3 AH.BorderSizePixel=0 AH.ZIndex=10 mkCorner(AH,14)
do local fix=Instance.new("Frame",AH) fix.Size=UDim2.new(1,0,0.5,0) fix.Position=UDim2.new(0,0,0.5,0) fix.BackgroundColor3=D3 fix.BorderSizePixel=0 fix.ZIndex=10 end
local AHI=Instance.new("TextLabel",AH) AHI.Size=UDim2.new(0,36,0,36) AHI.Position=UDim2.new(0,14,0.5,-18) AHI.BackgroundColor3=Color3.fromRGB(30,40,80) AHI.BorderSizePixel=0 AHI.Text="✦" AHI.TextColor3=AC AHI.Font=Enum.Font.GothamBold AHI.TextSize=18 AHI.ZIndex=11 mkCorner(AHI,8)
local AHT=Instance.new("TextLabel",AH) AHT.Size=UDim2.new(1,-120,0,22) AHT.Position=UDim2.new(0,58,0,8) AHT.BackgroundTransparency=1 AHT.Text="Add Script" AHT.TextColor3=TX AHT.Font=Enum.Font.GothamBold AHT.TextSize=15 AHT.TextXAlignment=Enum.TextXAlignment.Left AHT.ZIndex=11
local AHS=Instance.new("TextLabel",AH) AHS.Size=UDim2.new(1,-120,0,14) AHS.Position=UDim2.new(0,58,0,31) AHS.BackgroundTransparency=1 AHS.Text="UniverseHub  •  "..player.Name AHS.TextColor3=ST AHS.Font=Enum.Font.Gotham AHS.TextSize=11 AHS.TextXAlignment=Enum.TextXAlignment.Left AHS.ZIndex=11
local XBtn=Instance.new("TextButton",AH) XBtn.Size=UDim2.new(0,30,0,30) XBtn.Position=UDim2.new(1,-42,0.5,-15) XBtn.BackgroundColor3=Color3.fromRGB(180,50,50) XBtn.TextColor3=Color3.fromRGB(255,255,255) XBtn.Font=Enum.Font.GothamBold XBtn.TextSize=14 XBtn.Text="✕" XBtn.BorderSizePixel=0 XBtn.ZIndex=12 mkCorner(XBtn,6)
mkDrag(AF,AH)

local SC=Instance.new("ScrollingFrame",AF)
SC.Size=UDim2.new(1,-24,1,-122) SC.Position=UDim2.new(0,12,0,60)
SC.BackgroundTransparency=1 SC.BorderSizePixel=0 SC.ScrollBarThickness=3
SC.ScrollBarImageColor3=AC SC.CanvasSize=UDim2.new(0,0,0,0) SC.AutomaticCanvasSize=Enum.AutomaticSize.Y SC.ZIndex=10
local SL=Instance.new("UIListLayout",SC) SL.SortOrder=Enum.SortOrder.LayoutOrder SL.Padding=UDim.new(0,8) mkPad(SC,0,4,4,4)

local function mkLbl(p,txt,ord) local l=Instance.new("TextLabel",p) l.Size=UDim2.new(1,0,0,16) l.BackgroundTransparency=1 l.Text=txt l.TextColor3=ST l.Font=Enum.Font.GothamMedium l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left l.LayoutOrder=ord or 0 l.ZIndex=11 end
local function mkField(p,ph,ml,ord)
    local w=Instance.new("Frame",p) w.Size=UDim2.new(1,0,0,ml and 80 or 38) w.BackgroundColor3=D2 w.BorderSizePixel=0 w.LayoutOrder=ord or 0 w.ZIndex=11 mkCorner(w,8) mkStroke(w,Color3.fromRGB(35,50,90),1)
    local tb=Instance.new("TextBox",w) tb.Size=UDim2.new(1,0,1,0) tb.BackgroundTransparency=1 tb.PlaceholderText=ph tb.PlaceholderColor3=ST tb.TextColor3=TX tb.Font=Enum.Font.Gotham tb.TextSize=13 tb.Text="" tb.MultiLine=ml or false tb.ClearTextOnFocus=false tb.TextXAlignment=Enum.TextXAlignment.Left tb.TextYAlignment=ml and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center tb.ZIndex=12 mkPad(tb,10,10,ml and 8 or 0,0)
    tb.Focused:Connect(function() TweenService:Create(w,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(20,25,50)}):Play() mkStroke(w,AC,1.2) end)
    tb.FocusLost:Connect(function() TweenService:Create(w,TweenInfo.new(0.2),{BackgroundColor3=D2}):Play() mkStroke(w,Color3.fromRGB(35,50,90),1) end)
    return tb
end
local function mkToggle(p,lbl,ord)
    local row=Instance.new("Frame",p) row.Size=UDim2.new(1,0,0,40) row.BackgroundColor3=D2 row.BorderSizePixel=0 row.LayoutOrder=ord or 0 row.ZIndex=11 mkCorner(row,8) mkStroke(row,Color3.fromRGB(35,50,90),1)
    local L=Instance.new("TextLabel",row) L.Size=UDim2.new(1,-70,1,0) L.Position=UDim2.new(0,12,0,0) L.BackgroundTransparency=1 L.Text=lbl L.TextColor3=TX L.Font=Enum.Font.Gotham L.TextSize=13 L.TextXAlignment=Enum.TextXAlignment.Left L.ZIndex=12
    local st=false
    local pill=Instance.new("TextButton",row) pill.Size=UDim2.new(0,46,0,24) pill.Position=UDim2.new(1,-58,0.5,-12) pill.BackgroundColor3=Color3.fromRGB(40,40,60) pill.Text="" pill.BorderSizePixel=0 pill.ZIndex=12 mkCorner(pill,12)
    local dot=Instance.new("Frame",pill) dot.Size=UDim2.new(0,18,0,18) dot.Position=UDim2.new(0,3,0.5,-9) dot.BackgroundColor3=Color3.fromRGB(100,100,130) dot.BorderSizePixel=0 dot.ZIndex=13 mkCorner(dot,9)
    local function setV(v)
        st=v
        TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=v and Color3.fromRGB(30,80,160) or Color3.fromRGB(40,40,60)}):Play()
        TweenService:Create(dot,TweenInfo.new(0.2),{Position=v and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),BackgroundColor3=v and AC or Color3.fromRGB(100,100,130)}):Play()
    end
    pill.MouseButton1Click:Connect(function() setV(not st) end)
    return function() return st end, setV
end
local function mkDiv(p,ord) local d=Instance.new("Frame",p) d.Size=UDim2.new(1,0,0,1) d.BackgroundColor3=Color3.fromRGB(35,50,90) d.BorderSizePixel=0 d.LayoutOrder=ord or 0 d.ZIndex=11 end
local function mkSecLbl(p,txt,ord) local l=Instance.new("TextLabel",p) l.Size=UDim2.new(1,0,0,20) l.BackgroundTransparency=1 l.Text="— "..txt l.TextColor3=AC l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left l.LayoutOrder=ord or 0 l.ZIndex=11 end

mkSecLbl(SC,"SCRIPT INFO",1)
mkLbl(SC,"Title",2) local TBox=mkField(SC,"Nama script kamu...",false,3)
mkLbl(SC,"Description",4) local DBox=mkField(SC,"Jelaskan tujuan script ini...",false,5)
mkLbl(SC,"Release Date  (D/M/YYYY)",6) local RBox=mkField(SC,"Contoh: 1/7/2025",false,7)
mkDiv(SC,8) mkSecLbl(SC,"GAME INFO",9)
local getFG,setFG=mkToggle(SC,"For Specific Game",10)
mkLbl(SC,"Game Name (Case Sensitive!)",11) local GBox=mkField(SC,"Nama game PERSIS...",false,12)
mkDiv(SC,13) mkSecLbl(SC,"PERMISSION",14)
local getRX,setRX=mkToggle(SC,"Allow Remix",15)
mkDiv(SC,16) mkSecLbl(SC,"CODE",17)

local CBW=Instance.new("Frame",SC) CBW.Size=UDim2.new(1,0,0,42) CBW.BackgroundTransparency=1 CBW.LayoutOrder=18 CBW.ZIndex=11
local CBO=Instance.new("TextButton",CBW) CBO.Size=UDim2.new(1,0,1,0) CBO.BackgroundColor3=Color3.fromRGB(20,30,65) CBO.TextColor3=AC CBO.Font=Enum.Font.GothamBold CBO.TextSize=13 CBO.Text="⌨  Open CoderBox" CBO.BorderSizePixel=0 CBO.ZIndex=12 mkCorner(CBO,8) mkStroke(CBO,AC,1)

local CPrev=Instance.new("TextLabel",SC) CPrev.Size=UDim2.new(1,0,0,0) CPrev.AutomaticSize=Enum.AutomaticSize.Y CPrev.BackgroundColor3=D2 CPrev.BorderSizePixel=0 CPrev.Text="" CPrev.TextColor3=Color3.fromHex("#87CEEB") CPrev.Font=Enum.Font.Code CPrev.TextSize=11 CPrev.TextXAlignment=Enum.TextXAlignment.Left CPrev.TextYAlignment=Enum.TextYAlignment.Top CPrev.TextWrapped=true CPrev.Visible=false CPrev.LayoutOrder=19 CPrev.ZIndex=11 mkCorner(CPrev,6) mkPad(CPrev,8,8,6,6)

local BB=Instance.new("Frame",AF) BB.Size=UDim2.new(1,0,0,58) BB.Position=UDim2.new(0,0,1,-58) BB.BackgroundColor3=D3 BB.BorderSizePixel=0 BB.ZIndex=10 mkCorner(BB,14)
do local fix=Instance.new("Frame",BB) fix.Size=UDim2.new(1,0,0.5,0) fix.BackgroundColor3=D3 fix.BorderSizePixel=0 fix.ZIndex=10 end
local ABt=Instance.new("TextButton",BB) ABt.Size=UDim2.new(1,-24,0,38) ABt.Position=UDim2.new(0,12,0.5,-19) ABt.BackgroundColor3=AC ABt.TextColor3=Color3.fromRGB(8,10,20) ABt.Font=Enum.Font.GothamBold ABt.TextSize=14 ABt.Text="✚  Add Script" ABt.BorderSizePixel=0 ABt.ZIndex=11 mkCorner(ABt,9)

-- CODERBOX
local CBF=Instance.new("Frame",Gui) CBF.Size=UDim2.new(0,520,0,400) CBF.Position=UDim2.new(0.5,-260,0.5,-200) CBF.BackgroundColor3=D1 CBF.BorderSizePixel=0 CBF.Visible=false CBF.ZIndex=14 mkCorner(CBF,14) mkStroke(CBF,Color3.fromRGB(40,80,160),1.5)
do local g=Instance.new("Frame",CBF) g.Size=UDim2.new(1,0,0,2) g.BackgroundColor3=Color3.fromHex("#00CFFF") g.BorderSizePixel=0 g.ZIndex=15 mkCorner(g,2) end
local CBH=Instance.new("Frame",CBF) CBH.Size=UDim2.new(1,0,0,48) CBH.BackgroundColor3=Color3.fromRGB(18,22,44) CBH.BorderSizePixel=0 CBH.ZIndex=15 mkCorner(CBH,14)
do local fix=Instance.new("Frame",CBH) fix.Size=UDim2.new(1,0,0.5,0) fix.Position=UDim2.new(0,0,0.5,0) fix.BackgroundColor3=Color3.fromRGB(18,22,44) fix.BorderSizePixel=0 fix.ZIndex=15 end
local CBT=Instance.new("TextLabel",CBH) CBT.Size=UDim2.new(1,-60,1,0) CBT.Position=UDim2.new(0,16,0,0) CBT.BackgroundTransparency=1 CBT.Text="⌨  CoderBox" CBT.TextColor3=TX CBT.Font=Enum.Font.GothamBold CBT.TextSize=15 CBT.TextXAlignment=Enum.TextXAlignment.Left CBT.ZIndex=16
local CBX=Instance.new("TextButton",CBH) CBX.Size=UDim2.new(0,30,0,30) CBX.Position=UDim2.new(1,-42,0.5,-15) CBX.BackgroundColor3=Color3.fromRGB(180,50,50) CBX.TextColor3=Color3.fromRGB(255,255,255) CBX.Font=Enum.Font.GothamBold CBX.TextSize=14 CBX.Text="✕" CBX.BorderSizePixel=0 CBX.ZIndex=16 mkCorner(CBX,6)
mkDrag(CBF,CBH)
local CdBox=Instance.new("TextBox",CBF) CdBox.Size=UDim2.new(1,-24,1,-110) CdBox.Position=UDim2.new(0,12,0,56) CdBox.BackgroundColor3=Color3.fromRGB(8,9,18) CdBox.TextColor3=Color3.fromHex("#87CEEB") CdBox.Font=Enum.Font.Code CdBox.TextSize=13 CdBox.Text="" CdBox.PlaceholderText="-- Write your script here..." CdBox.PlaceholderColor3=ST CdBox.MultiLine=true CdBox.ClearTextOnFocus=false CdBox.TextXAlignment=Enum.TextXAlignment.Left CdBox.TextYAlignment=Enum.TextYAlignment.Top CdBox.BorderSizePixel=0 CdBox.ZIndex=15 mkCorner(CdBox,8) mkStroke(CdBox,Color3.fromRGB(30,45,90),1) mkPad(CdBox,10,10,8,8)
local CBDn=Instance.new("TextButton",CBF) CBDn.Size=UDim2.new(0,160,0,38) CBDn.Position=UDim2.new(0.5,-80,1,-48) CBDn.BackgroundColor3=AC CBDn.TextColor3=Color3.fromRGB(8,10,20) CBDn.Font=Enum.Font.GothamBold CBDn.TextSize=14 CBDn.Text="✓  Done" CBDn.BorderSizePixel=0 CBDn.ZIndex=15 mkCorner(CBDn,8)

-- ══════════════════════════════════════════
--    RENDER SCRIPT CARD
-- ══════════════════════════════════════════
local savedCode = ""

local function renderCard(tabRef, entry)
    local gt=entry.Game and ("🎮 "..(entry.NameGame or "?")) or "🌐 General"
    local rt=entry.CanRemix and "✅ Remix" or "🔒 No Remix"
    local btn=tabRef:Button({Title=entry.Title, Desc="👤 "..entry.Username.."  •  "..gt.."  •  "..rt.."  •  📅 "..entry.Release, Icon="code-2",
        Callback=function() recordView(entry.Title,entry.NameGame or "") WindUI:Notify({Title=entry.Title,Content=entry.Description,Duration=5}) end})
    if btn and btn.Frame then
        local holding=false
        btn.Frame.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
                holding=true task.delay(0.65,function()
                    if not holding then return end
                    if not entry.CanRemix then WindUI:Notify({Title="🔒 Remix Ditolak",Content="Creator does not allow to be remixed!",Duration=4})
                    else WindUI:Notify({Title="⏳ Wait...",Content="Mengambil script dari "..entry.Username.."...",Duration=2}) task.wait(1.5) WindUI:Notify({Title="📋 "..entry.Title,Content=entry.Code,Duration=10}) end
                end) end end)
        btn.Frame.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then holding=false end end)
    end
end

-- ══════════════════════════════════════════
--    SCRIPTS TAB
-- ══════════════════════════════════════════
local searchKW=""
TabScripts:Input({Title="🔍  Search Script",Placeholder="Ketik nama script...",Callback=function(v) searchKW=v end})
TabScripts:Button({Title="Search",Icon="search",Callback=function()
    local kw=searchKW:lower():gsub("^%s*(.-)%s*$","%1")
    if kw=="" then WindUI:Notify({Title="⚠️",Content="Ketik keyword dulu!",Duration=3}) return end
    WindUI:Notify({Title="🔍 Mencari...",Content='Tunggu sebentar, mencari "'..kw..'"...',Duration=2}) recordSearch(kw) task.wait(1)
    local results={} for _,e in ipairs(scriptList) do if e.Title:lower():find(kw,1,true) or (e.Description and e.Description:lower():find(kw,1,true)) or (e.NameGame and e.NameGame:lower():find(kw,1,true)) then table.insert(results,e) end end
    if #results==0 then WindUI:Notify({Title="😕 Tidak Ditemukan",Content='Tidak ada script dengan "'..kw..'"',Duration=4}) return end
    local names={} for i,r in ipairs(results) do if i<=5 then table.insert(names,"• "..r.Title) end end
    if #results>5 then table.insert(names,"...dan "..( #results-5).." lainnya") end
    WindUI:Notify({Title="✅ Done!  "..#results.." hasil",Content=table.concat(names,"\n"),Duration=6})
end})
TabScripts:Button({Title="＋  Add Script",Desc="Tambahkan script baru ke hub",Icon="plus-circle",Callback=function()
    TBox.Text="" DBox.Text="" RBox.Text="" GBox.Text="" savedCode="" CdBox.Text="" CPrev.Text="" CPrev.Visible=false setFG(false) setRX(false)
    Overlay.Visible=true AF.Visible=true AF:TweenPosition(UDim2.new(0.5,-240,0.5,-280),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.35,true)
end})
for _,e in ipairs(scriptList) do renderCard(TabScripts,e) end

-- ══════════════════════════════════════════
--    RECOMMENDED TAB
-- ══════════════════════════════════════════
local function buildRec()
    local scored={}
    for _,e in ipairs(scriptList) do table.insert(scored,{e=e,s=recommendScore(e)}) end
    table.sort(scored,function(a,b) return a.s>b.s end)
    if #scored==0 then TabRec:Paragraph({Title="Belum Ada Rekomendasi",Desc="Mulai cari dan klik script.",Color="Blue"}) return end
    TabRec:Paragraph({Title="⭐ Rekomendasi",Desc="Berdasarkan kebiasaan & riwayat pencarian.",Color="Blue"})
    local shown=0
    for _,item in ipairs(scored) do if shown>=10 then break end renderCard(TabRec,item.e) shown=shown+1 end
    if shown==0 then TabRec:Paragraph({Title="Belum Ada Rekomendasi",Desc="Mulai cari dan klik script.",Color="Blue"}) end
end
buildRec()

-- ══════════════════════════════════════════
--    ROLE TABS
-- ══════════════════════════════════════════
-- ADMIN TAB
if TabAdmin then
    TabAdmin:Paragraph({Title="👢 Kick Player",Desc="Pilih player dan kick. Player harus online menggunakan script ini.",Color="Blue"})
    local kickTarget=""
    TabAdmin:Input({Title="Target Username",Placeholder="Username player...",Callback=function(v) kickTarget=v end})
    TabAdmin:Button({Title="Kick Player",Icon="user-x",Callback=function()
        if kickTarget=="" then WindUI:Notify({Title="❌",Content="Username kosong!",Duration=3}) return end
        WindUI:Notify({Title="⏳ Wait...",Content="Mengirim sinyal kick...",Duration=2})
        local ok=ghWrite("signals.json",function()
            local sigs=ghGet("signals.json") or {}
            table.insert(sigs,{id=tostring(os.time()),type="kick",target=kickTarget,by=player.Name,data={},processed=false,timestamp=os.time()})
            return sigs
        end)
        task.wait(0.5)
        WindUI:Notify({Title="✅",Content='Kick signal dikirim ke "'..kickTarget..'"',Duration=4})
    end})
    -- Auto Teleport
    TabAdmin:Paragraph({Title="🚀 Auto Teleport",Desc="Teleport ke game yang sedang dimainkan player.",Color="Blue"})
    local tpTarget=""
    TabAdmin:Input({Title="Target Username",Placeholder="Username player...",Callback=function(v) tpTarget=v end})
    TabAdmin:Button({Title="Teleport To Player",Icon="navigation",Callback=function()
        if tpTarget=="" then WindUI:Notify({Title="❌",Content="Username kosong!",Duration=3}) return end
        WindUI:Notify({Title="⏳ Wait...",Content="Mencari game player...",Duration=2})
        local ok,err=teleportToPlayer(tpTarget)
        if not ok then WindUI:Notify({Title="❌",Content=tostring(err),Duration=4}) end
    end})
end

-- DEV TAB
if TabDev then
    TabDev:Paragraph({Title="🛠️ Developer Tools",Desc="Ban Time, Reset Karakter.",Color="Blue"})
    -- BAN TIME
    local banTarget="" local banD,banH,banM,banS=0,0,0,0
    TabDev:Input({Title="Target Username",Placeholder="Username player...",Callback=function(v) banTarget=v end})
    TabDev:Input({Title="Day (max 3)",Placeholder="0",Callback=function(v) banD=tonumber(v) or 0 end})
    TabDev:Input({Title="Hour (max 24)",Placeholder="0",Callback=function(v) banH=tonumber(v) or 0 end})
    TabDev:Input({Title="Minute (max 60)",Placeholder="0",Callback=function(v) banM=tonumber(v) or 0 end})
    TabDev:Input({Title="Second (max 60)",Placeholder="0",Callback=function(v) banS=tonumber(v) or 0 end})
    TabDev:Button({Title="Apply Ban Time",Icon="clock",Callback=function()
        if banTarget=="" then WindUI:Notify({Title="❌",Content="Username kosong!",Duration=3}) return end
        if (banD or 0)>3 or (banH or 0)>24 or (banM or 0)>60 or (banS or 0)>60 then WindUI:Notify({Title="❌",Content="Melebihi batas maksimum!",Duration=3}) return end
        if banD==0 and banH==0 and banM==0 and banS==0 then WindUI:Notify({Title="❌",Content="Durasi tidak boleh 0!",Duration=3}) return end
        local expiry=os.time()+(banD or 0)*86400+(banH or 0)*3600+(banM or 0)*60+(banS or 0)
        WindUI:Notify({Title="⏳ Wait...",Content="Menerapkan ban time...",Duration=2})
        -- Update developer.json
        local devs=ghGet("developer.json") or {}
        local found=nil for _,d in ipairs(devs) do if d.Username==banTarget then found=d break end end
        if not found then found={Id="",Username=banTarget,Role="Visitor",Blacklist=false} table.insert(devs,found) end
        found.BanExpiry=expiry
        ghWrite("developer.json",devs)
        -- Send signal
        local sigs=ghGet("signals.json") or {}
        table.insert(sigs,{id=tostring(os.time()),type="ban",target=banTarget,by=player.Name,data={day=banD,hour=banH,min=banM,sec=banS,expiry=expiry},processed=false,timestamp=os.time()})
        ghWrite("signals.json",sigs)
        WindUI:Notify({Title="✅",Content='Ban time diterapkan ke "'..banTarget..'"',Duration=4})
    end})
    -- RESET
    local resetTarget=""
    TabDev:Input({Title="Reset — Target Username",Placeholder="Username player...",Callback=function(v) resetTarget=v end})
    TabDev:Button({Title="Reset Character",Icon="rotate-cw",Callback=function()
        if resetTarget=="" then WindUI:Notify({Title="❌",Content="Username kosong!",Duration=3}) return end
        WindUI:Notify({Title="⏳ Wait...",Content="Mengirim sinyal reset...",Duration=2})
        local sigs=ghGet("signals.json") or {}
        table.insert(sigs,{id=tostring(os.time()),type="reset",target=resetTarget,by=player.Name,data={},processed=false,timestamp=os.time()})
        ghWrite("signals.json",sigs)
        WindUI:Notify({Title="✅",Content='Reset signal dikirim ke "'..resetTarget..'"',Duration=4})
    end})
end

-- MODERATE TAB
if TabMod then
    TabMod:Paragraph({Title="🛡️ Moderate Tools",Desc="Blacklist, Whitelist, Give Message.",Color="Blue"})
    -- MESSAGE
    local msgTarget,msgText="",""
    TabMod:Input({Title="Target Username",Placeholder="Username player...",Callback=function(v) msgTarget=v end})
    TabMod:Input({Title="Message",Placeholder="Pesan untuk player...",Callback=function(v) msgText=v end})
    TabMod:Button({Title="Give Message",Icon="message-square",Callback=function()
        if msgTarget=="" or msgText=="" then WindUI:Notify({Title="❌",Content="Username dan pesan wajib diisi!",Duration=3}) return end
        local sigs=ghGet("signals.json") or {}
        table.insert(sigs,{id=tostring(os.time()),type="message",target=msgTarget,by=player.Name,data={text=msgText},processed=false,timestamp=os.time()})
        ghWrite("signals.json",sigs)
        WindUI:Notify({Title="✅",Content='Pesan terkirim ke "'..msgTarget..'"',Duration=4})
    end})
    -- BLACKLIST
    local blTarget=""
    TabMod:Input({Title="Blacklist — Target Username",Placeholder="Username player...",Callback=function(v) blTarget=v end})
    TabMod:Button({Title="Blacklist Player",Icon="ban",Callback=function()
        if blTarget=="" then WindUI:Notify({Title="❌",Content="Username kosong!",Duration=3}) return end
        if blTarget=="KHAFIDZKTP" then WindUI:Notify({Title="❌",Content="Tidak bisa blacklist owner!",Duration=4}) return end
        WindUI:Notify({Title="⏳ Wait...",Content="Memproses blacklist...",Duration=2})
        local devs=ghGet("developer.json") or {}
        local found=nil for _,d in ipairs(devs) do if d.Username==blTarget then found=d break end end
        if not found then found={Id="",Username=blTarget,Role="Visitor",Blacklist=false} table.insert(devs,found) end
        found.Blacklist=true
        ghWrite("developer.json",devs)
        local sigs=ghGet("signals.json") or {}
        table.insert(sigs,{id=tostring(os.time()),type="blacklist",target=blTarget,by=player.Name,data={},processed=false,timestamp=os.time()})
        ghWrite("signals.json",sigs)
        WindUI:Notify({Title="✅",Content='"'..blTarget..'" berhasil di-blacklist!',Duration=4})
    end})
    -- WHITELIST (show blacklisted)
    TabMod:Button({Title="Show Blacklisted / Whitelist",Icon="list",Callback=function()
        WindUI:Notify({Title="⏳ Wait...",Content="Memuat daftar blacklist...",Duration=2})
        task.wait(1)
        local devs=ghGet("developer.json") or {}
        local bls={} for _,d in ipairs(devs) do if d.Blacklist==true then table.insert(bls,d.Username) end end
        if #bls==0 then WindUI:Notify({Title="📋 Whitelist",Content="Tidak ada player yang di-blacklist.",Duration=5}) return end
        WindUI:Notify({Title="⛔ Blacklisted ("..#bls..")",Content=table.concat(bls,"\n"),Duration=8})
    end})
    local wlTarget=""
    TabMod:Input({Title="Whitelist — Target Username",Placeholder="Username player...",Callback=function(v) wlTarget=v end})
    TabMod:Button({Title="Whitelist Player",Icon="check-circle",Callback=function()
        if wlTarget=="" then WindUI:Notify({Title="❌",Content="Username kosong!",Duration=3}) return end
        local devs=ghGet("developer.json") or {}
        local found=nil for _,d in ipairs(devs) do if d.Username==wlTarget then found=d break end end
        if not found then WindUI:Notify({Title="❌",Content="Player tidak ditemukan di database!",Duration=4}) return end
        found.Blacklist=false
        ghWrite("developer.json",devs)
        WindUI:Notify({Title="✅",Content='"'..wlTarget..'" berhasil di-whitelist!',Duration=4})
    end})
end

-- CO-OWNER TAB
if TabCO then
    TabCO:Paragraph({Title="👑 Co-Owner Tools",Desc="Change role player. Tidak bisa set Co-Owner atau ubah KHAFIDZKTP.",Color="Blue"})
    local roleTarget,roleVal="","Visitor"
    TabCO:Input({Title="Target Username",Placeholder="Username player...",Callback=function(v) roleTarget=v end})
    local ROLES={"Visitor","Admin","Developer","Moderate"}
    for _,r in ipairs(ROLES) do
        TabCO:Button({Title="Set Role → "..r,Icon="user-check",Callback=function()
            if roleTarget=="" then WindUI:Notify({Title="❌",Content="Username kosong!",Duration=3}) return end
            if roleTarget=="KHAFIDZKTP" or roleTarget=="OwnerDex" then
                -- Punish
                WindUI:Notify({Title="❌ WARNING",Content="Tidak bisa mengubah role Owner! Ban 5 hari...",Duration=4})
                local devs=ghGet("developer.json") or {}
                local me=nil for _,d in ipairs(devs) do if d.Username==player.Name then me=d break end end
                if not me then me={Id=tostring(player.UserId),Username=player.Name,Role=myRole,Blacklist=false} table.insert(devs,me) end
                me.BanExpiry=os.time()+5*86400
                ghWrite("developer.json",devs)
                task.wait(1)
                player:Kick("You have been Ban Time Day 5 hours 0 Minute 0 Second 0 By System (attempted to change owner role)")
                return
            end
            WindUI:Notify({Title="⏳ Wait...",Content="Mengubah role...",Duration=2})
            local devs=ghGet("developer.json") or {}
            local found=nil for _,d in ipairs(devs) do if d.Username==roleTarget then found=d break end end
            if not found then found={Id="",Username=roleTarget,Role="Visitor",Blacklist=false} table.insert(devs,found) end
            found.Role=r
            ghWrite("developer.json",devs)
            WindUI:Notify({Title="✅",Content='Role "'..roleTarget..'" diset ke '..r,Duration=4})
        end})
    end
end

-- ══════════════════════════════════════════
--    FRAME LOGIC
-- ══════════════════════════════════════════
local function closeAF() AF.Visible=false Overlay.Visible=false end
XBtn.MouseButton1Click:Connect(closeAF)
Overlay.MouseButton1Click:Connect(closeAF)
CBO.MouseButton1Click:Connect(function() CdBox.Text=savedCode CBF.Visible=true end)
CBX.MouseButton1Click:Connect(function() CBF.Visible=false end)
CBDn.MouseButton1Click:Connect(function()
    local code=CdBox.Text local ok,err=validateCode(code)
    if not ok then WindUI:Notify({Title="❌ Code Error",Content=err.."\n\nFix code lalu Done lagi.",Duration=5}) return end
    savedCode=code CBF.Visible=false
    CPrev.Text=#code>60 and code:sub(1,60).."..." or code CPrev.Visible=true
    WindUI:Notify({Title="✅ CoderBox",Content="Script tersimpan! Klik Add Script.",Duration=3})
end)
ABt.MouseButton1Click:Connect(function()
    local title=TBox.Text local desc=DBox.Text local date=RBox.Text local gname=GBox.Text local fg=getFG() local rx=getRX()
    if title=="" then WindUI:Notify({Title="❌",Content="Title wajib diisi!",Duration=4}) return end
    if desc==""  then WindUI:Notify({Title="❌",Content="Description wajib diisi!",Duration=4}) return end
    local dok,derr=validateDate(date) if not dok then WindUI:Notify({Title="❌ Date Error",Content=derr,Duration=4}) return end
    local cok,cerr=validateCode(savedCode) if not cok then WindUI:Notify({Title="❌ Code Error",Content=cerr.."\n\nBuka CoderBox.",Duration=5}) return end
    if fg then
        if gname=="" then WindUI:Notify({Title="❌",Content="Nama game wajib diisi!",Duration=4}) return end
        WindUI:Notify({Title="🔍 Checking...",Content="Memvalidasi game...",Duration=3})
        local gok,gerr=validateGame(gname) if not gok then WindUI:Notify({Title="❌ Game Error",Content=gerr,Duration=5}) return end
    end
    local entry={Username=player.Name,Title=title,Code=savedCode,CanRemix=rx,Release=date,Description=desc,Game=fg,NameGame=fg and gname or nil}
    table.insert(scriptList,entry) saveScripts() renderCard(TabScripts,entry) closeAF()
    WindUI:Notify({Title="✅ Berhasil!",Content='"'..title..'" ditambahkan!',Duration=4})
end)

-- ══════════════════════════════════════════
--    START BACKGROUND TASKS
-- ══════════════════════════════════════════
task.spawn(function()
    -- Cek developer.json & blacklist
    checkDeveloperJson()
    -- Register online
    if GH_PAT ~= "" then
        registerOnline()
        task.spawn(heartbeat)
        task.spawn(pollSignals)
    else
        WindUI:Notify({Title="⚠️ Config",Content="PAT tidak ditemukan di config.json.\nSignal & online tracking nonaktif.",Duration=6})
    end
end)
