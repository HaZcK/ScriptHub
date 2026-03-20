-- ╔══════════════════════════════════════════╗
-- ║           AdminHub Loader                ║
-- ║         Author: Khafidz (KHAFIDZKTP)    ║
-- ╚══════════════════════════════════════════╝
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/AdminHub/Loader.lua"))()

local Players      = game:GetService("Players")
local HttpService  = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local player       = Players.LocalPlayer

local httpRequest = (syn and syn.request) or (http and http.request)
    or (http_request) or (request)
    or function(o) return {Body=game:HttpGet(o.Url),StatusCode=200} end

-- ══════════════════════════════════════════
--    JSONBIN CONFIG (Global, no PAT needed)
-- ══════════════════════════════════════════
-- Buat bin di jsonbin.io, ambil BIN_ID dan X_ACCESS_KEY
local BIN_ID       = "YOUR_BIN_ID_HERE"
local ACCESS_KEY   = "YOUR_ACCESS_KEY_HERE"
local JSONBIN_URL  = "https://api.jsonbin.io/v3/b/"..BIN_ID

local function jbGet()
    local ok,data = pcall(function()
        local res = httpRequest({
            Url     = JSONBIN_URL.."/latest",
            Method  = "GET",
            Headers = { ["X-Access-Key"]=ACCESS_KEY, ["X-Bin-Meta"]="false" }
        })
        if res and res.Body then return HttpService:JSONDecode(res.Body) end
        return nil
    end)
    return ok and data or {signals={},online={}}
end

local function jbSet(data)
    pcall(function()
        httpRequest({
            Url     = JSONBIN_URL,
            Method  = "PUT",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-Access-Key"] = ACCESS_KEY
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- ══════════════════════════════════════════
--    SCRIPT DATABASE
--    Tambah game & script di sini
-- ══════════════════════════════════════════
local SCRIPT_DB = {
    {
        game = "Grow A Garden",
        icon = "🌱",
        scripts = {
            {
                name = "Black Luck",
                desc = "Make luck get bigger bamboo or 9999X",
                url  = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/GrowAGarden/BlackLuck.lua"
            },
            {
                name = "Auto Farm",
                desc = "Automatically farm plants 24/7",
                url  = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/GrowAGarden/AutoFarm.lua"
            },
        }
    },
    {
        game = "Blox Fruits",
        icon = "🍎",
        scripts = {
            {
                name = "Auto Raid",
                desc = "Auto complete raids for max rewards",
                url  = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/BloxFruits/AutoRaid.lua"
            },
        }
    },
    {
        game = "Valley Prison",
        icon = "🏛️",
        scripts = {
            {
                name = "God Mode",
                desc = "Become invincible in prison",
                url  = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/Script/ValleyPrison/GodMode.lua"
            },
        }
    },
}

-- ══════════════════════════════════════════
--    COLORS
-- ══════════════════════════════════════════
local D1  = Color3.fromRGB(8,10,20)
local D2  = Color3.fromRGB(13,15,28)
local D3  = Color3.fromRGB(18,21,40)
local D4  = Color3.fromRGB(24,28,52)
local AC  = Color3.fromHex("#87CEEB")
local AC2 = Color3.fromHex("#00BFFF")
local TX  = Color3.fromRGB(220,230,255)
local ST  = Color3.fromRGB(110,130,180)
local RED = Color3.fromRGB(224,85,85)
local GRN = Color3.fromRGB(85,224,154)

-- ══════════════════════════════════════════
--    SCREEN GUI
-- ══════════════════════════════════════════
local Gui = Instance.new("ScreenGui")
Gui.Name           = "AdminHubLoader"
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
Gui.Parent         = player.PlayerGui

-- ── Watermark kiri bawah ──
local WM = Instance.new("TextLabel", Gui)
WM.Size               = UDim2.new(0, 180, 0, 22)
WM.Position           = UDim2.new(0, 14, 1, -32)
WM.BackgroundTransparency = 1
WM.Text               = "Script By <b>AdminHub</b>"
WM.RichText           = true
WM.TextColor3         = Color3.fromRGB(255,255,255)
WM.TextTransparency   = 0.7
WM.Font               = Enum.Font.GothamMedium
WM.TextSize           = 11
WM.TextXAlignment     = Enum.TextXAlignment.Left
WM.ZIndex             = 5
WM.Visible            = false

-- ── Overlay ──
local OV = Instance.new("TextButton", Gui)
OV.Size                   = UDim2.fromScale(1,1)
OV.BackgroundColor3       = Color3.fromRGB(0,0,0)
OV.BackgroundTransparency = 0.55
OV.BorderSizePixel        = 0
OV.Text                   = ""
OV.AutoButtonColor        = false
OV.ZIndex                 = 8
OV.Visible                = false

-- ══════════════════════════════════════════
--    HELPER FUNCTIONS
-- ══════════════════════════════════════════
local function mkC(p,r) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r or 10) end
local function mkS(p,c,t)
    for _,ch in ipairs(p:GetChildren()) do if ch:IsA("UIStroke") then ch:Destroy() end end
    local s=Instance.new("UIStroke",p) s.Color=c or Color3.fromRGB(40,60,120) s.Thickness=t or 1
end
local function mkP(p,l,r,t,b)
    local x=Instance.new("UIPadding",p)
    x.PaddingLeft=UDim.new(0,l or 0) x.PaddingRight=UDim.new(0,r or 0)
    x.PaddingTop=UDim.new(0,t or 0)  x.PaddingBottom=UDim.new(0,b or 0)
end
local function mkDrag(frame,handle)
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

local function makeFrame(w,h)
    local f=Instance.new("Frame",Gui)
    f.Size=UDim2.new(0,w,0,h)
    f.Position=UDim2.new(0.5,-w/2,0.5,-h/2)
    f.BackgroundColor3=D1
    f.BorderSizePixel=0
    f.Visible=false
    f.ZIndex=9
    mkC(f,16)
    mkS(f,Color3.fromRGB(35,55,110),1.5)
    -- top glow bar
    local g=Instance.new("Frame",f) g.Size=UDim2.new(1,0,0,2) g.BackgroundColor3=AC g.BorderSizePixel=0 g.ZIndex=10 mkC(g,2)
    return f
end

local function makeHeader(parent, title, sub)
    local h=Instance.new("Frame",parent)
    h.Size=UDim2.new(1,0,0,58) h.BackgroundColor3=D3 h.BorderSizePixel=0 h.ZIndex=10 mkC(h,16)
    do local f=Instance.new("Frame",h) f.Size=UDim2.new(1,0,0.5,0) f.Position=UDim2.new(0,0,0.5,0) f.BackgroundColor3=D3 f.BorderSizePixel=0 f.ZIndex=10 end
    local t=Instance.new("TextLabel",h) t.Size=UDim2.new(1,-24,0,22) t.Position=UDim2.new(0,18,0,10)
    t.BackgroundTransparency=1 t.Text=title t.TextColor3=TX t.Font=Enum.Font.GothamBold t.TextSize=15 t.TextXAlignment=Enum.TextXAlignment.Left t.ZIndex=11
    local s=Instance.new("TextLabel",h) s.Size=UDim2.new(1,-24,0,14) s.Position=UDim2.new(0,18,0,34)
    s.BackgroundTransparency=1 s.Text=sub s.TextColor3=ST s.Font=Enum.Font.Gotham s.TextSize=11 s.TextXAlignment=Enum.TextXAlignment.Left s.ZIndex=11
    return h
end

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quart), props):Play()
end

local function showFrame(f)
    f.Position = UDim2.new(0.5,-f.Size.X.Offset/2,0.6,-f.Size.Y.Offset/2)
    f.Visible  = true
    OV.Visible = true
    tween(f, {Position=UDim2.new(0.5,-f.Size.X.Offset/2,0.5,-f.Size.Y.Offset/2), BackgroundTransparency=0}, 0.3)
end

local function hideFrame(f, cb)
    tween(f, {Position=UDim2.new(0.5,-f.Size.X.Offset/2,0.4,-f.Size.Y.Offset/2), BackgroundTransparency=1}, 0.25)
    task.wait(0.27)
    f.Visible=false OV.Visible=false
    if cb then cb() end
end

-- ══════════════════════════════════════════
--    FRAME 1: SELECT GAME
-- ══════════════════════════════════════════
local F1 = makeFrame(460, 480)
makeHeader(F1, "🗺  The map you want to select?", "AdminHub Script Loader  •  "..player.Name)
mkDrag(F1, F1:FindFirstChildOfClass("Frame"))

local F1Scroll = Instance.new("ScrollingFrame", F1)
F1Scroll.Size=UDim2.new(1,-24,1,-80) F1Scroll.Position=UDim2.new(0,12,0,68)
F1Scroll.BackgroundTransparency=1 F1Scroll.BorderSizePixel=0
F1Scroll.ScrollBarThickness=3 F1Scroll.ScrollBarImageColor3=AC
F1Scroll.CanvasSize=UDim2.new(0,0,0,0) F1Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y F1Scroll.ZIndex=10
do local l=Instance.new("UIListLayout",F1Scroll) l.SortOrder=Enum.SortOrder.LayoutOrder l.Padding=UDim.new(0,8) end
mkP(F1Scroll,0,4,4,4)

-- ══════════════════════════════════════════
--    FRAME 2: SELECT SCRIPT
-- ══════════════════════════════════════════
local F2 = makeFrame(460, 480)
local F2Header = makeHeader(F2, "📜  What script do you want to use?", "")
mkDrag(F2, F2:FindFirstChildOfClass("Frame"))

local F2Scroll = Instance.new("ScrollingFrame", F2)
F2Scroll.Size=UDim2.new(1,-24,1,-80) F2Scroll.Position=UDim2.new(0,12,0,68)
F2Scroll.BackgroundTransparency=1 F2Scroll.BorderSizePixel=0
F2Scroll.ScrollBarThickness=3 F2Scroll.ScrollBarImageColor3=AC
F2Scroll.CanvasSize=UDim2.new(0,0,0,0) F2Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y F2Scroll.ZIndex=10
do local l=Instance.new("UIListLayout",F2Scroll) l.SortOrder=Enum.SortOrder.LayoutOrder l.Padding=UDim.new(0,8) end
mkP(F2Scroll,0,4,4,4)

-- F2 back button
local F2Back=Instance.new("TextButton",F2Header) F2Back.Size=UDim2.new(0,28,0,28) F2Back.Position=UDim2.new(1,-40,0.5,-14)
F2Back.BackgroundColor3=D4 F2Back.TextColor3=ST F2Back.Font=Enum.Font.GothamBold F2Back.TextSize=14 F2Back.Text="←" F2Back.BorderSizePixel=0 F2Back.ZIndex=12 mkC(F2Back,6)

-- ══════════════════════════════════════════
--    FRAME 3: CONFIRM / WARNING
-- ══════════════════════════════════════════
local F3 = makeFrame(400, 280)
makeHeader(F3, "⚠️  Warning", "This action cannot be cancelled")
mkDrag(F3, F3:FindFirstChildOfClass("Frame"))

local F3ScriptName=Instance.new("TextLabel",F3) F3ScriptName.Size=UDim2.new(1,-24,0,28) F3ScriptName.Position=UDim2.new(0,12,0,72)
F3ScriptName.BackgroundColor3=D3 F3ScriptName.BorderSizePixel=0 F3ScriptName.Text="" F3ScriptName.TextColor3=AC
F3ScriptName.Font=Enum.Font.GothamBold F3ScriptName.TextSize=15 F3ScriptName.ZIndex=10 mkC(F3ScriptName,8)

local F3Desc=Instance.new("TextLabel",F3) F3Desc.Size=UDim2.new(1,-24,0,60) F3Desc.Position=UDim2.new(0,12,0,108)
F3Desc.BackgroundTransparency=1 F3Desc.Text="" F3Desc.TextColor3=ST F3Desc.Font=Enum.Font.Gotham
F3Desc.TextSize=13 F3Desc.TextWrapped=true F3Desc.TextXAlignment=Enum.TextXAlignment.Left F3Desc.ZIndex=10

local F3Warn=Instance.new("TextLabel",F3) F3Warn.Size=UDim2.new(1,-24,0,28) F3Warn.Position=UDim2.new(0,12,0,172)
F3Warn.BackgroundColor3=Color3.fromRGB(60,20,20) F3Warn.BorderSizePixel=0
F3Warn.Text="⚠️  Once you click Run, this cannot be stopped!" F3Warn.TextColor3=RED
F3Warn.Font=Enum.Font.GothamMedium F3Warn.TextSize=12 F3Warn.ZIndex=10 mkC(F3Warn,8)

-- Buttons
local F3Cancel=Instance.new("TextButton",F3) F3Cancel.Size=UDim2.new(0,140,0,38) F3Cancel.Position=UDim2.new(0,12,1,-52)
F3Cancel.BackgroundColor3=D4 F3Cancel.TextColor3=ST F3Cancel.Font=Enum.Font.GothamBold F3Cancel.TextSize=13 F3Cancel.Text="Cancel" F3Cancel.BorderSizePixel=0 F3Cancel.ZIndex=10 mkC(F3Cancel,9)

local F3Run=Instance.new("TextButton",F3) F3Run.Size=UDim2.new(0,140,0,38) F3Run.Position=UDim2.new(1,-152,1,-52)
F3Run.BackgroundColor3=AC F3Run.TextColor3=Color3.fromRGB(8,10,20) F3Run.Font=Enum.Font.GothamBold F3Run.TextSize=14 F3Run.Text="▶  Run" F3Run.BorderSizePixel=0 F3Run.ZIndex=10 mkC(F3Run,9)

-- ══════════════════════════════════════════
--    BUILD GAME LIST (Frame 1)
-- ══════════════════════════════════════════
local selectedGame   = nil
local selectedScript = nil

local function buildScriptList(gameEntry)
    -- Clear existing
    for _, ch in ipairs(F2Scroll:GetChildren()) do
        if not ch:IsA("UIListLayout") then ch:Destroy() end
    end
    -- Update header sub
    local headers = F2:GetChildren()
    for _, h in ipairs(headers) do
        if h:IsA("Frame") and h.Size.Y.Offset == 58 then
            for _, lbl in ipairs(h:GetChildren()) do
                if lbl:IsA("TextLabel") and lbl.TextSize == 11 then
                    lbl.Text = gameEntry.icon.."  "..gameEntry.game
                end
            end
        end
    end

    for i, sc in ipairs(gameEntry.scripts) do
        local card=Instance.new("Frame",F2Scroll) card.Size=UDim2.new(1,0,0,76) card.BackgroundColor3=D2 card.BorderSizePixel=0 card.LayoutOrder=i card.ZIndex=11 mkC(card,10) mkS(card,Color3.fromRGB(30,45,90),1)

        local nameL=Instance.new("TextLabel",card) nameL.Size=UDim2.new(1,-120,0,22) nameL.Position=UDim2.new(0,14,0,12) nameL.BackgroundTransparency=1 nameL.Text=sc.name nameL.TextColor3=TX nameL.Font=Enum.Font.GothamBold nameL.TextSize=14 nameL.TextXAlignment=Enum.TextXAlignment.Left nameL.ZIndex=12
        local descL=Instance.new("TextLabel",card) descL.Size=UDim2.new(1,-120,0,32) descL.Position=UDim2.new(0,14,0,36) descL.BackgroundTransparency=1 descL.Text=sc.desc descL.TextColor3=ST descL.Font=Enum.Font.Gotham descL.TextSize=11 descL.TextWrapped=true descL.TextXAlignment=Enum.TextXAlignment.Left descL.ZIndex=12

        local selBtn=Instance.new("TextButton",card) selBtn.Size=UDim2.new(0,90,0,32) selBtn.Position=UDim2.new(1,-104,0.5,-16) selBtn.BackgroundColor3=D4 selBtn.TextColor3=AC selBtn.Font=Enum.Font.GothamBold selBtn.TextSize=12 selBtn.Text="Select →" selBtn.BorderSizePixel=0 selBtn.ZIndex=12 mkC(selBtn,7) mkS(selBtn,AC,1)

        selBtn.MouseButton1Click:Connect(function()
            selectedScript = sc
            F3ScriptName.Text = "  "..sc.name
            F3Desc.Text = sc.desc
            hideFrame(F2, function()
                showFrame(F3)
            end)
        end)

        -- Hover effect
        card.MouseEnter:Connect(function()
            tween(card, {BackgroundColor3=D4}, 0.15)
        end)
        card.MouseLeave:Connect(function()
            tween(card, {BackgroundColor3=D2}, 0.15)
        end)
    end
end

for i, gameEntry in ipairs(SCRIPT_DB) do
    local card=Instance.new("Frame",F1Scroll) card.Size=UDim2.new(1,0,0,68) card.BackgroundColor3=D2 card.BorderSizePixel=0 card.LayoutOrder=i card.ZIndex=11 mkC(card,10) mkS(card,Color3.fromRGB(30,45,90),1)

    local ico=Instance.new("TextLabel",card) ico.Size=UDim2.new(0,44,0,44) ico.Position=UDim2.new(0,12,0.5,-22) ico.BackgroundColor3=D4 ico.BorderSizePixel=0 ico.Text=gameEntry.icon ico.TextColor3=TX ico.Font=Enum.Font.GothamBold ico.TextSize=22 ico.ZIndex=12 mkC(ico,10)
    local nameL=Instance.new("TextLabel",card) nameL.Size=UDim2.new(1,-130,0,22) nameL.Position=UDim2.new(0,66,0,12) nameL.BackgroundTransparency=1 nameL.Text=gameEntry.game nameL.TextColor3=TX nameL.Font=Enum.Font.GothamBold nameL.TextSize=14 nameL.TextXAlignment=Enum.TextXAlignment.Left nameL.ZIndex=12
    local countL=Instance.new("TextLabel",card) countL.Size=UDim2.new(1,-130,0,16) countL.Position=UDim2.new(0,66,0,36) countL.BackgroundTransparency=1 countL.Text=#gameEntry.scripts.." script"..( #gameEntry.scripts>1 and "s" or "") .." available" countL.TextColor3=ST countL.Font=Enum.Font.Gotham countL.TextSize=11 countL.TextXAlignment=Enum.TextXAlignment.Left countL.ZIndex=12

    local selBtn=Instance.new("TextButton",card) selBtn.Size=UDim2.new(0,80,0,30) selBtn.Position=UDim2.new(1,-94,0.5,-15) selBtn.BackgroundColor3=D4 selBtn.TextColor3=AC selBtn.Font=Enum.Font.GothamBold selBtn.TextSize=12 selBtn.Text="Open →" selBtn.BorderSizePixel=0 selBtn.ZIndex=12 mkC(selBtn,7) mkS(selBtn,AC,1)

    selBtn.MouseButton1Click:Connect(function()
        selectedGame = gameEntry
        buildScriptList(gameEntry)
        hideFrame(F1, function()
            showFrame(F2)
        end)
    end)

    card.MouseEnter:Connect(function() tween(card,{BackgroundColor3=D4},0.15) end)
    card.MouseLeave:Connect(function() tween(card,{BackgroundColor3=D2},0.15) end)
end

-- ══════════════════════════════════════════
--    FRAME NAVIGATION
-- ══════════════════════════════════════════
F2Back.MouseButton1Click:Connect(function()
    hideFrame(F2, function() showFrame(F1) end)
end)

F3Cancel.MouseButton1Click:Connect(function()
    hideFrame(F3, function() showFrame(F2) end)
end)

F3Run.MouseButton1Click:Connect(function()
    if not selectedScript then return end
    hideFrame(F3)
    -- Tampilkan watermark
    WM.Visible = true
    WM.TextTransparency = 1
    tween(WM, {TextTransparency=0.7}, 0.5)

    -- Notify
    task.spawn(function()
        task.wait(0.5)
        -- Load WindUI untuk notify saja
        local ok, WindUI = pcall(function()
            return loadstring(game:HttpGet(
                "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
            ))()
        end)
        if ok and WindUI then
            WindUI:Notify({
                Title   = "By: AdminHub",
                Content = "Running: "..selectedScript.name,
                Duration = 4,
            })
        end
    end)

    -- Jalankan script
    task.spawn(function()
        task.wait(0.3)
        local ok, err = pcall(function()
            local code = game:HttpGet(selectedScript.url)
            local fn, lerr = loadstring(code)
            if not fn then error(lerr) end
            fn()
        end)
        if not ok then
            warn("[AdminHub Loader] Error running "..selectedScript.name..": "..tostring(err))
        end
    end)
end)

-- ══════════════════════════════════════════
--    RECEIVER (silent background)
-- ══════════════════════════════════════════
local processedSignals = {}
local signalsReady     = false

local function processSignal(sig)
    if processedSignals[sig.id] then return end
    processedSignals[sig.id] = true
    local t  = sig.type
    local by = sig.by or "System"

    -- Load WindUI for notify
    local wok, WUI = pcall(function()
        return loadstring(game:HttpGet(
            "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
        ))()
    end)

    if t=="kick" then
        if wok and WUI then
            WUI:Notify({Title='You Been Kicked By "'..by..'"', Content="Disconnecting...", Duration=3})
        end
        task.wait(2)
        player:Kick('You have been kicked by "'..by..'"')

    elseif t=="ban" then
        local d=sig.data or {}
        if wok and WUI then
            WUI:Notify({
                Title   = 'You Been Ban Time By "'..by..'"',
                Content = string.format("Day %d | Hour %d | Min %d | Sec %d",
                    d.day or 0,d.hour or 0,d.min or 0,d.sec or 0),
                Duration = 4
            })
        end
        task.wait(3)
        player:Kick(string.format(
            'You been Ban Time Day %d hours %d Minute %d Second %d By "%s"',
            d.day or 0,d.hour or 0,d.min or 0,d.sec or 0,by))

    elseif t=="reset" then
        if wok and WUI then
            WUI:Notify({Title='You Been Reset By "'..by..'"', Content="Character resetting...", Duration=3})
        end
        task.wait(1.5)
        pcall(function() player:LoadCharacter() end)

    elseif t=="message" then
        if wok and WUI then
            WUI:Notify({
                Title   = 'You have received a message By "'..by..'"',
                Content = (sig.data and sig.data.text) or "",
                Duration = 8
            })
        end
    end
end

local function preloadSignals()
    pcall(function()
        local data = jbGet()
        local sigs = data.signals or {}
        for _,s in ipairs(sigs) do processedSignals[s.id]=true end
    end)
    signalsReady=true
end

local function pollSignals()
    while not signalsReady do task.wait(0.5) end
    while true do
        task.wait(4)
        pcall(function()
            local data    = jbGet()
            local sigs    = data.signals or {}
            local online  = data.online  or {}
            local updated = false
            for _,sig in ipairs(sigs) do
                if not processedSignals[sig.id] and sig.target==player.Name then
                    processSignal(sig)
                    sig.processed = true
                    updated = true
                end
            end
            if updated then
                data.signals = sigs
                jbSet(data)
            end
        end)
    end
end

local function registerOnline()
    pcall(function()
        local data   = jbGet()
        local online = data.online or {}
        -- Remove old entry
        for i=#online,1,-1 do
            if online[i].Username==player.Name then table.remove(online,i) end
        end
        table.insert(online, {
            Username = player.Name,
            Display  = player.DisplayName,
            LastSeen = os.time()
        })
        data.online = online
        jbSet(data)
    end)
end

local function heartbeat()
    while true do
        task.wait(25)
        pcall(function()
            local data   = jbGet()
            local online = data.online or {}
            for _,e in ipairs(online) do
                if e.Username==player.Name then e.LastSeen=os.time() break end
            end
            data.online = online
            jbSet(data)
        end)
    end
end

player.AncestryChanged:Connect(function()
    if not player.Parent then
        pcall(function()
            local data   = jbGet()
            local online = data.online or {}
            for i=#online,1,-1 do
                if online[i].Username==player.Name then table.remove(online,i) end
            end
            data.online=online
            jbSet(data)
        end)
    end
end)

-- ══════════════════════════════════════════
--    START
-- ══════════════════════════════════════════
-- Receiver jalan silent di background
task.spawn(function()
    preloadSignals()
    registerOnline()
    task.spawn(heartbeat)
    task.spawn(pollSignals)
end)

-- Tampilkan frame pilih game
task.wait(0.5)
showFrame(F1)
