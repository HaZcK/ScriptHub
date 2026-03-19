-- ════════════════════════════════════════════════════
-- PASTE YOUR JUNKIE CUSTOM CODE HERE (lines 1 to while loop)
-- Then this file content comes AFTER the while loop
-- ════════════════════════════════════════════════════

-- ── LOADSTRINGS (taruh di atas, sebelum while loop) ──────────────────
 local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
    Junkie.service = "Roblox script"
    Junkie.identifier = "1034169"
    Junkie.provider = "Skymoonn"
--... (Junkie setup + Window creation + KeySystem) ...
-- while not getgenv().SCRIPT_KEY do task.wait(0.1) end
-- ─────────────────────────────────────────────────────────────────────

-- URLs (diletakkan di atas sebelum while loop juga)
local RAW_PLACELIST   = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/PlaceList.json"
local RAW_UNIVERSAL   = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/Universal.json"
local ALL_TOOLS_URL   = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/All_tools.lua"
local RealBuilder_URL = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/Real_Builder.lua"

-- Load All_tools sebelum while loop
local allToolsFn = loadstring(game:HttpGet(ALL_TOOLS_URL))

-- ═══════════════════════════════════════
 while not getgenv().SCRIPT_KEY do
     task.wait(0.1)
 end
-- ═══════════════════════════════════════
-- KODE DI BAWAH INI JALAN SETELAH KEY VERIFIED

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local UIS          = game:GetService("UserInputService")
local LP           = Players.LocalPlayer

-- Helpers
local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    return ok and res or nil
end
local function fetchPlaceList()
    local raw = httpGet(RAW_PLACELIST)
    if not raw then return nil end
    local ok, db = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
    return ok and db or nil
end
local function fetchUniversal()
    local raw = httpGet(RAW_UNIVERSAL)
    if not raw then return nil end
    local ok, db = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
    return ok and db or nil
end
local function escapeRich(s)
    return tostring(s):gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;")
end
local function runScript(url)
    local raw = httpGet(url)
    if not raw then return end
    local fn = loadstring(raw)
    if fn then pcall(fn) end
end
local function notify(title, msg, dur)
    pcall(function()
        WindUI:Notify({ Title=title, Content=msg, Duration=dur or 4 })
    end)
end

----------------------------------------------------
-- LOADING SCREEN
----------------------------------------------------
local function showLoadingScreen(onComplete)
    local loadSg = Instance.new("ScreenGui")
    loadSg.Name = "SkyMoon_Loading"
    loadSg.ResetOnSpawn = false
    loadSg.IgnoreGuiInset = true
    loadSg.DisplayOrder = 9999
    pcall(function() loadSg.Parent = game:GetService("CoreGui") end)
    if not loadSg.Parent then loadSg.Parent = LP.PlayerGui end

    local loadBg = Instance.new("Frame", loadSg)
    loadBg.Size = UDim2.new(1,0,1,0)
    loadBg.BackgroundColor3 = Color3.fromRGB(4,4,10)
    loadBg.BorderSizePixel = 0

    for i = 0, 20 do
        local l = Instance.new("Frame", loadBg)
        l.Size = UDim2.new(1,0,0,1) l.Position = UDim2.new(0,0,0,i*40)
        l.BackgroundColor3 = Color3.fromRGB(18,12,40) l.BackgroundTransparency = 0.7 l.BorderSizePixel = 0
    end
    for i = 0, 30 do
        local l = Instance.new("Frame", loadBg)
        l.Size = UDim2.new(0,1,1,0) l.Position = UDim2.new(0,i*50,0,0)
        l.BackgroundColor3 = Color3.fromRGB(18,12,40) l.BackgroundTransparency = 0.7 l.BorderSizePixel = 0
    end

    local center = Instance.new("Frame", loadBg)
    center.Size = UDim2.new(0,280,0,210) center.Position = UDim2.new(0.5,-140,0.5,-105)
    center.BackgroundTransparency = 1 center.BorderSizePixel = 0

    local ro = Instance.new("ImageLabel", center)
    ro.Size = UDim2.new(0,90,0,90) ro.Position = UDim2.new(0.5,-45,0,0)
    ro.BackgroundTransparency = 1 ro.Image = "rbxassetid://6031094678"
    ro.ImageColor3 = Color3.fromRGB(110,70,255) ro.ImageTransparency = 0.2

    local ri = Instance.new("ImageLabel", center)
    ri.Size = UDim2.new(0,60,0,60) ri.Position = UDim2.new(0.5,-30,0,15)
    ri.BackgroundTransparency = 1 ri.Image = "rbxassetid://6031094678"
    ri.ImageColor3 = Color3.fromRGB(0,200,170) ri.ImageTransparency = 0.4

    local moonL = Instance.new("TextLabel", center)
    moonL.Size = UDim2.new(0,90,0,90) moonL.Position = UDim2.new(0.5,-45,0,0)
    moonL.BackgroundTransparency = 1 moonL.Text = "🌙"
    moonL.Font = Enum.Font.GothamBold moonL.TextSize = 34

    local titleL = Instance.new("TextLabel", center)
    titleL.Size = UDim2.new(1,0,0,30) titleL.Position = UDim2.new(0,0,0,96)
    titleL.BackgroundTransparency = 1 titleL.Text = "SKYMOON"
    titleL.Font = Enum.Font.GothamBold titleL.TextSize = 22
    titleL.TextColor3 = Color3.fromRGB(160,130,255)

    local subL = Instance.new("TextLabel", center)
    subL.Size = UDim2.new(1,0,0,16) subL.Position = UDim2.new(0,0,0,126)
    subL.BackgroundTransparency = 1 subL.Text = "SCRIPT HUB  ·  BY KHAFIDZKTP"
    subL.Font = Enum.Font.GothamBold subL.TextSize = 9
    subL.TextColor3 = Color3.fromRGB(60,50,100)

    local barBg = Instance.new("Frame", center)
    barBg.Size = UDim2.new(1,0,0,4) barBg.Position = UDim2.new(0,0,0,152)
    barBg.BackgroundColor3 = Color3.fromRGB(20,15,40) barBg.BorderSizePixel = 0
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(0,2)

    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new(0,0,1,0) barFill.BackgroundColor3 = Color3.fromRGB(110,70,255)
    barFill.BorderSizePixel = 0
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(0,2)
    local barGrad = Instance.new("UIGradient", barFill)
    barGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100,60,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,200,180))
    })

    local statusL = Instance.new("TextLabel", center)
    statusL.Size = UDim2.new(1,0,0,14) statusL.Position = UDim2.new(0,0,0,160)
    statusL.BackgroundTransparency = 1 statusL.Text = "Initializing..."
    statusL.Font = Enum.Font.Code statusL.TextSize = 10
    statusL.TextColor3 = Color3.fromRGB(70,60,110)

    local spinConn = nil
    local STEPS = {
        {0.15,"Loading modules..."},
        {0.32,"Connecting to ScriptHub..."},
        {0.50,"Fetching game database..."},
        {0.68,"Building hub..."},
        {0.85,"Finishing up..."},
        {1.00,"Ready!"},
    }

    spinConn = RunService.RenderStepped:Connect(function(dt)
        ro.Rotation = ro.Rotation + 80 * dt
        ri.Rotation = ri.Rotation - 120 * dt
    end)

    local stepTime = 2.2 / #STEPS
    for _, step in ipairs(STEPS) do
        statusL.Text = step[2]
        TweenService:Create(barFill,
            TweenInfo.new(stepTime*0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(step[1],0,1,0) }):Play()
        task.wait(stepTime)
    end
    task.wait(0.2)
    TweenService:Create(loadBg, TweenInfo.new(0.5), {BackgroundTransparency=1}):Play()
    TweenService:Create(center,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Position=UDim2.new(0.5,-140,0.4,-105)}):Play()
    task.wait(0.55)
    if spinConn then spinConn:Disconnect() end
    loadSg:Destroy()
    onComplete()
end

----------------------------------------------------
-- SCAN OVERLAY
----------------------------------------------------
local function openScanOverlay()
    local scanSg = Instance.new("ScreenGui")
    scanSg.Name = "SkyMoon_Scan" scanSg.ResetOnSpawn = false
    pcall(function() scanSg.Parent = game:GetService("CoreGui") end)
    if not scanSg.Parent then scanSg.Parent = LP.PlayerGui end

    local bg = Instance.new("Frame", scanSg)
    bg.Size = UDim2.new(1,0,1,0) bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 0.05 bg.BorderSizePixel = 0

    local hdr = Instance.new("Frame", bg)
    hdr.Size = UDim2.new(1,0,0,54) hdr.BackgroundColor3 = Color3.fromRGB(10,10,18) hdr.BorderSizePixel = 0
    local img = Instance.new("ImageLabel", hdr)
    img.Size = UDim2.new(0,40,0,40) img.Position = UDim2.new(0.5,-20,0,7)
    img.BackgroundTransparency = 1
    img.Image = "https://tkj.smkdarmasiswasidoarjo.sch.id/wp-content/uploads/2024/08/61ef634e-0b5f-4d27-9fb6-c64d526c595c.png"

    local output = Instance.new("TextLabel", bg)
    output.Size = UDim2.new(1,-32,1,-60) output.Position = UDim2.new(0,16,0,58)
    output.BackgroundTransparency = 1 output.Font = Enum.Font.Code output.TextSize = 13
    output.TextColor3 = Color3.fromRGB(0,255,80) output.TextXAlignment = Enum.TextXAlignment.Left
    output.TextYAlignment = Enum.TextYAlignment.Top output.TextWrapped = true
    output.RichText = true output.Text = ""

    local function ap(text, color)
        output.Text = output.Text..string.format('<font color="#%s">%s</font>\n', color or "00ff44", escapeRich(text))
    end
    local function tp(text, color, delay)
        for i=1,#text do
            output.Text = output.Text..string.format('<font color="#%s">%s</font>', color or "00ff44", escapeRich(text:sub(i,i)))
            task.wait(delay or 0.04)
        end
        output.Text = output.Text.."\n"
    end

    task.spawn(function()
        ap("SkyMoon Terminal v3.0", "aaaaff")
        ap("by KHAFIDZKTP | github.com/HaZcK/ScriptHub", "666688")
        task.wait(0.3)
        tp("Scanning game environment...", "00ff88", 0.05)
        local countries = {"US","JP","DE","BR","SG","KR","FR","AU","CA","NL"}
        for i = 1, 6 do
            ap(string.format("[%s] %d.%d.%d.%d  CONNECTED",
                countries[math.random(1,#countries)],
                math.random(1,255),math.random(0,255),math.random(0,255),math.random(1,254)), "00aa55")
            task.wait(0.08)
        end
        output.Text = ""
        tp("Check_This_Game:;", "00ff88", 0.06)
        task.wait(0.2)

        local SVCS = {
            {game:GetService("Workspace"),"Workspace"},
            {game:GetService("ReplicatedStorage"),"ReplicatedStorage"},
            {LP,"LocalPlayer"},
        }
        local allItems = {}
        local function collect(parent, depth, label)
            if depth > 2 then return end
            for _, child in ipairs(parent:GetChildren()) do
                table.insert(allItems,{name=child.Name,class=child.ClassName,depth=depth,label=label})
                if not child:IsA("Model") then collect(child,depth+1,label) end
            end
        end
        for _, s in ipairs(SVCS) do pcall(function() collect(s[1],0,s[2]) end) end

        local total = math.max(#allItems,1)
        local lineCount = 0
        local SKIP = {RobloxGui=true,TopBarApp=true,ChatApp=true,ControlGui=true,BubbleChatScreenGui=true}
        local buf = {} local lastLabel = ""
        for i, item in ipairs(allItems) do
            if item.class=="ScreenGui" and SKIP[item.name] then goto cont end
            local pct = math.floor((i/total)*100)
            table.insert(buf, item.name)
            if #buf >= 4 or item.label ~= lastLabel then
                ap(string.format("[KHAFIDZKTP, %s] %s  (%d%%)", item.label, table.concat(buf," | "), pct), "00ff44")
                buf = {} lineCount = lineCount + 1
            end
            lastLabel = item.label
            if lineCount >= 22 then output.Text="" lineCount=0 end
            if i%8==0 then task.wait() end
            ::cont::
        end
        output.Text="" ap("Check_This_Game... 100%","00ffaa") task.wait(0.4)
        tp("Checking game support...","00ff88",0.05)

        local db = fetchPlaceList()
        local entry = db and db[tostring(game.PlaceId)]
        if not entry and db then
            for pid,data in pairs(db) do
                local ok,info   = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(tonumber(pid)) end)
                local ok2,myInfo= pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
                if ok and ok2 and info and myInfo and info.Creator and myInfo.Creator then
                    if info.Creator.Id==myInfo.Creator.Id then
                        entry=data ap("✓ Sub-place verified","ffaa00") break
                    end
                end
            end
        end
        task.wait(0.3)
        if entry then
            ap("✓ Game supported! Running script...","00ffaa") task.wait(0.5)
            scanSg:Destroy() runScript(entry.script)
        else
            ap("✗ Game not supported.","ff4444") task.wait(0.3)
            tp("Loading Universal Scripts...","ffaa00",0.05) task.wait(0.3)
            local udb = fetchUniversal()
            if udb then
                output.Text="" ap("=== Universal Script List ===","aaaaff")
                for k,v in pairs(udb) do ap(string.format("[%s] %s",k,v.name),"88ffbb") end
                task.wait(3)
            end
            scanSg:Destroy()
        end
    end)
    bg.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton2 then scanSg:Destroy() end
    end)
end

----------------------------------------------------
-- MINI CMD
----------------------------------------------------
local function openMiniCmd()
    local cSg=Instance.new("ScreenGui") cSg.Name="SkyMoon_Cmd" cSg.ResetOnSpawn=false
    pcall(function() cSg.Parent=game:GetService("CoreGui") end)
    if not cSg.Parent then cSg.Parent=LP.PlayerGui end
    local win=Instance.new("Frame",cSg) win.Size=UDim2.new(0,420,0,240) win.Position=UDim2.new(0.5,-210,0.5,-120)
    win.BackgroundColor3=Color3.fromRGB(8,8,16) win.BorderSizePixel=0 win.Active=true win.Draggable=true
    Instance.new("UICorner",win).CornerRadius=UDim.new(0,10)
    local ws=Instance.new("UIStroke",win) ws.Color=Color3.fromRGB(60,50,160) ws.Thickness=1.5
    local tbar=Instance.new("Frame",win) tbar.Size=UDim2.new(1,0,0,28) tbar.BackgroundColor3=Color3.fromRGB(6,6,14) tbar.BorderSizePixel=0
    Instance.new("UICorner",tbar).CornerRadius=UDim.new(0,10)
    local tf=Instance.new("Frame",tbar) tf.Size=UDim2.new(1,0,0.5,0) tf.Position=UDim2.new(0,0,0.5,0) tf.BackgroundColor3=Color3.fromRGB(6,6,14) tf.BorderSizePixel=0
    local tl=Instance.new("TextLabel",tbar) tl.Size=UDim2.new(1,-60,1,0) tl.Position=UDim2.new(0,10,0,0) tl.BackgroundTransparency=1
    tl.Text="🌙 SkyMoon Terminal" tl.Font=Enum.Font.GothamBold tl.TextSize=11 tl.TextColor3=Color3.fromRGB(150,130,255) tl.TextXAlignment=Enum.TextXAlignment.Left
    local cb=Instance.new("TextButton",tbar) cb.Size=UDim2.new(0,22,0,20) cb.Position=UDim2.new(1,-26,0,4) cb.BackgroundColor3=Color3.fromRGB(160,30,50)
    cb.Text="✕" cb.TextColor3=Color3.new(1,1,1) cb.Font=Enum.Font.GothamBold cb.TextSize=10 cb.BorderSizePixel=0
    Instance.new("UICorner",cb).CornerRadius=UDim.new(0,4) cb.MouseButton1Click:Connect(function() cSg:Destroy() end)
    local scroll=Instance.new("ScrollingFrame",win) scroll.Size=UDim2.new(1,-12,1,-60) scroll.Position=UDim2.new(0,6,0,30)
    scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0 scroll.ScrollBarThickness=2
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y scroll.CanvasSize=UDim2.new(0,0,0,0)
    local outL=Instance.new("TextLabel",scroll) outL.Size=UDim2.new(1,-4,0,0) outL.AutomaticSize=Enum.AutomaticSize.Y
    outL.BackgroundTransparency=1 outL.Text='<font color="#555577">SkyMoon CMD ready.\n</font>'
    outL.Font=Enum.Font.Code outL.TextSize=11 outL.TextColor3=Color3.fromRGB(200,210,255)
    outL.TextXAlignment=Enum.TextXAlignment.Left outL.TextYAlignment=Enum.TextYAlignment.Top outL.TextWrapped=true outL.RichText=true
    local function appendOut(text,color)
        outL.Text=outL.Text..string.format('<font color="#%s">%s\n</font>',color,escapeRich(text))
        task.defer(function() scroll.CanvasPosition=Vector2.new(0,scroll.AbsoluteCanvasSize.Y) end)
    end
    local ibar=Instance.new("Frame",win) ibar.Size=UDim2.new(1,-12,0,26) ibar.Position=UDim2.new(0,6,1,-30)
    ibar.BackgroundColor3=Color3.fromRGB(16,14,32) ibar.BorderSizePixel=0
    Instance.new("UICorner",ibar).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",ibar).Color=Color3.fromRGB(60,50,160)
    local prompt=Instance.new("TextLabel",ibar) prompt.Size=UDim2.new(0,22,1,0) prompt.BackgroundTransparency=1
    prompt.Text="$" prompt.Font=Enum.Font.Code prompt.TextSize=12 prompt.TextColor3=Color3.fromRGB(100,80,200)
    local inputBox=Instance.new("TextBox",ibar) inputBox.Size=UDim2.new(1,-26,1,0) inputBox.Position=UDim2.new(0,24,0,0)
    inputBox.BackgroundTransparency=1 inputBox.Text="" inputBox.PlaceholderText="Check In [Service, Folder, Name]  |  RunConsole"
    inputBox.PlaceholderColor3=Color3.fromRGB(50,45,80) inputBox.TextColor3=Color3.fromRGB(200,210,255)
    inputBox.Font=Enum.Font.Code inputBox.TextSize=11 inputBox.ClearTextOnFocus=false
    inputBox.FocusLost:Connect(function(enter)
        if not enter or inputBox.Text=="" then return end
        local cmd=inputBox.Text appendOut("> "..cmd,"cccccc")
        local lower=cmd:lower():match("^%s*(.-)%s*$")
        if lower=="runconsole" then appendOut("Opening console...","aaaaff")
        elseif lower:match("^check in") then
            local inner=cmd:match("[Cc]heck [Ii]n %[(.-)%]")
            if not inner then appendOut("Usage: Check In [Service, Folder, Name]","888888") inputBox.Text="" return end
            local parts={} for p in inner:gmatch("[^,]+") do table.insert(parts,p:match("^%s*(.-)%s*$")) end
            local svcs={Workspace=workspace,ReplicatedStorage=game:GetService("ReplicatedStorage"),LocalPlayer=LP}
            local cur=svcs[parts[1]] if not cur then appendOut("Unknown: "..parts[1],"ff6644") inputBox.Text="" return end
            for i=2,#parts do cur=cur:FindFirstChild(parts[i]) if not cur then appendOut("Not found: "..parts[i],"ff6644") inputBox.Text="" return end end
            appendOut("Found: "..cur:GetFullName().." ["..cur.ClassName.."]","00ffaa")
        else appendOut("Unknown command.","ff4444") end
        inputBox.Text=""
    end)
end

----------------------------------------------------
-- CONSOLE
----------------------------------------------------
local function openConsole()
    local cSg=Instance.new("ScreenGui") cSg.Name="SkyMoon_Console" cSg.ResetOnSpawn=false
    pcall(function() cSg.Parent=game:GetService("CoreGui") end)
    if not cSg.Parent then cSg.Parent=LP.PlayerGui end
    local win=Instance.new("Frame",cSg) win.Size=UDim2.new(0,500,0,300) win.Position=UDim2.new(0.5,-250,0.5,-150)
    win.BackgroundColor3=Color3.fromRGB(8,8,16) win.BorderSizePixel=0 win.Active=true win.Draggable=true
    Instance.new("UICorner",win).CornerRadius=UDim.new(0,10) Instance.new("UIStroke",win).Color=Color3.fromRGB(60,50,160)
    local tbar=Instance.new("Frame",win) tbar.Size=UDim2.new(1,0,0,28) tbar.BackgroundColor3=Color3.fromRGB(6,6,14) tbar.BorderSizePixel=0
    Instance.new("UICorner",tbar).CornerRadius=UDim.new(0,10)
    local tf=Instance.new("Frame",tbar) tf.Size=UDim2.new(1,0,0.5,0) tf.Position=UDim2.new(0,0,0.5,0) tf.BackgroundColor3=Color3.fromRGB(6,6,14) tf.BorderSizePixel=0
    local tl=Instance.new("TextLabel",tbar) tl.Size=UDim2.new(1,-50,1,0) tl.Position=UDim2.new(0,10,0,0) tl.BackgroundTransparency=1
    tl.Text="🌙 Live Console" tl.Font=Enum.Font.GothamBold tl.TextSize=11 tl.TextColor3=Color3.fromRGB(150,130,255) tl.TextXAlignment=Enum.TextXAlignment.Left
    local cb=Instance.new("TextButton",tbar) cb.Size=UDim2.new(0,22,0,20) cb.Position=UDim2.new(1,-26,0,4) cb.BackgroundColor3=Color3.fromRGB(160,30,50)
    cb.Text="✕" cb.TextColor3=Color3.new(1,1,1) cb.Font=Enum.Font.GothamBold cb.TextSize=10 cb.BorderSizePixel=0
    Instance.new("UICorner",cb).CornerRadius=UDim.new(0,4) cb.MouseButton1Click:Connect(function() cSg:Destroy() end)
    local scroll=Instance.new("ScrollingFrame",win) scroll.Size=UDim2.new(1,-12,1,-36) scroll.Position=UDim2.new(0,6,0,32)
    scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0 scroll.ScrollBarThickness=2
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y scroll.CanvasSize=UDim2.new(0,0,0,0)
    local outL=Instance.new("TextLabel",scroll) outL.Size=UDim2.new(1,-4,0,0) outL.AutomaticSize=Enum.AutomaticSize.Y
    outL.BackgroundTransparency=1 outL.Text="" outL.Font=Enum.Font.Code outL.TextSize=11 outL.TextColor3=Color3.fromRGB(200,210,255)
    outL.TextXAlignment=Enum.TextXAlignment.Left outL.TextYAlignment=Enum.TextYAlignment.Top outL.TextWrapped=true outL.RichText=true
    local logConn=game:GetService("LogService").MessageOut:Connect(function(msg,msgType)
        local color="aaffaa"
        if msgType==Enum.MessageType.MessageWarning then color="ffcc44" elseif msgType==Enum.MessageType.MessageError then color="ff5555" end
        outL.Text=outL.Text..string.format('<font color="#%s">%s\n</font>',color,escapeRich(msg:sub(1,120)))
        task.defer(function() scroll.CanvasPosition=Vector2.new(0,scroll.AbsoluteCanvasSize.Y) end)
    end)
    cSg.AncestryChanged:Connect(function() pcall(function() logConn:Disconnect() end) end)
end

----------------------------------------------------
-- CHAT COMMANDS
----------------------------------------------------
LP.Chatted:Connect(function(msg)
    local lower=msg:lower():match("^%s*(.-)%s*$")
    if lower=="/open_cmd" then openMiniCmd()
    elseif lower=="/open_admin" then if Window then Window:Toggle() end
    elseif lower=="/console" then openConsole()
    elseif lower=="/reset_skymoon" then
        pcall(function()
            if isfolder("SkyMoon") and isfile("SkyMoon/memory.json") then
                writefile("SkyMoon/memory.json",'{"log":[],"executeCount":0}')
            end
        end)
        notify("✅ Reset","SkyMoon data reset!")
    end
end)

----------------------------------------------------
-- ADD TABS TO EXISTING Window (from Junkie code)
----------------------------------------------------
local function buildTabs()
    -- HOME
    local HT = Window:Tab({Title="Home", Icon="house"})
    HT:Paragraph({Title="🌙 SkyMoon Script Hub", Content="Welcome! Scan Game to run scripts.\n\nChat: /Open_Cmd  /console  /reset_skymoon"})
    HT:Divider()
    HT:Button({Title="⟳ Scan Game", Desc="Detect game and run matching script",
        Callback=function() Window:Close() task.wait(0.2) openScanOverlay() end})
    HT:Button({Title="📋 Universal Scripts", Callback=function()
        local udb=fetchUniversal() if not udb then notify("❌","Failed!") return end
        local n={} for k,v in pairs(udb) do table.insert(n,v.name) end
        notify("Universal",table.concat(n,", "):sub(1,100),5)
    end})
    HT:Button({Title="🔥 Real Builder", Callback=function()
        notify("⏳","Loading Real Builder...") task.spawn(function() runScript(RealBuilder_URL) end)
    end})
    HT:Button({Title="💻 Terminal", Callback=function() openMiniCmd() end})
    HT:Button({Title="📟 Console",  Callback=function() openConsole() end})
    HT:Divider()
    HT:Paragraph({Title="Game Info", Content="PlaceId: "..game.PlaceId.."\nPlayer: "..LP.Name})

    -- PLAYERS
    local PT=Window:Tab({Title="Players",Icon="users"})
    PT:Section({Title="Character"})
    PT:Toggle({Title="God Mode",Value=false,Callback=function(s) pcall(function() local h=LP.Character.Humanoid if s then h.MaxHealth=math.huge h.Health=math.huge else h.MaxHealth=100 h.Health=100 end end) end})
    PT:Toggle({Title="NoClip",Value=false,Callback=function(s)
        if s then _G.SkyNC=RunService.Stepped:Connect(function() pcall(function() for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end) end)
        else if _G.SkyNC then _G.SkyNC:Disconnect() _G.SkyNC=nil end end
    end})
    PT:Toggle({Title="Infinite Jump",Value=false,Callback=function(s)
        if s then _G.SkyIJ=UIS.JumpRequest:Connect(function() pcall(function() LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) end)
        else if _G.SkyIJ then _G.SkyIJ:Disconnect() _G.SkyIJ=nil end end
    end})
    PT:Toggle({Title="Anti-AFK",Value=false,Callback=function(s)
        if s then _G.SkyAFK=RunService.Heartbeat:Connect(function() pcall(function() local VU=game:GetService("VirtualUser") VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end)
        else if _G.SkyAFK then _G.SkyAFK:Disconnect() _G.SkyAFK=nil end end
    end})
    PT:Toggle({Title="Invisible (local)",Value=false,Callback=function(s) pcall(function() for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier=s and 1 or 0 end end end) end})
    PT:Toggle({Title="Spin",Value=false,Callback=function(s)
        if s then _G.SkySpin=RunService.Heartbeat:Connect(function() pcall(function() LP.Character.HumanoidRootPart.CFrame=LP.Character.HumanoidRootPart.CFrame*CFrame.Angles(0,math.rad(5),0) end) end)
        else if _G.SkySpin then _G.SkySpin:Disconnect() _G.SkySpin=nil end end
    end})
    PT:Section({Title="Stats"})
    PT:Slider({Title="Walk Speed",Step=1,Value={Min=0,Max=500,Default=16},Callback=function(v) pcall(function() LP.Character.Humanoid.WalkSpeed=v end) end})
    PT:Slider({Title="Jump Power",Step=1,Value={Min=0,Max=500,Default=50},Callback=function(v) pcall(function() LP.Character.Humanoid.JumpPower=v end) end})
    PT:Section({Title="Actions"})
    PT:Button({Title="Save Position",Callback=function() _G.SkyPos=LP.Character.HumanoidRootPart.CFrame notify("📍 Saved","Done!") end})
    PT:Button({Title="Load Position",Callback=function() if _G.SkyPos then pcall(function() LP.Character.HumanoidRootPart.CFrame=_G.SkyPos end) else notify("⚠️","No saved position!") end end})
    PT:Button({Title="Respawn",Callback=function() pcall(function() LP:LoadCharacter() end) end})
    PT:Input({Title="Nametag",Placeholder="Display name...",Callback=function(text)
        if text=="" then return end
        pcall(function()
            local h=LP.Character:FindFirstChild("Head") if not h then return end
            local bg=h:FindFirstChildOfClass("BillboardGui") or Instance.new("BillboardGui",h)
            bg.Size=UDim2.new(0,120,0,30) bg.StudsOffset=Vector3.new(0,2.5,0)
            local lbl=bg:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel",bg)
            lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1 lbl.Text=text
            lbl.TextColor3=Color3.new(1,1,1) lbl.Font=Enum.Font.GothamBold lbl.TextSize=14
        end)
    end})

    -- MOVE
    local MT=Window:Tab({Title="Move",Icon="wind"})
    MT:Toggle({Title="Fly",Value=false,Callback=function(s)
        if s then
            local bp=Instance.new("BodyPosition") bp.MaxForce=Vector3.new(1e5,1e5,1e5) bp.P=1e4
            local bg=Instance.new("BodyGyro") bg.MaxTorque=Vector3.new(1e5,1e5,1e5) bg.P=1e4
            local hrp=LP.Character.HumanoidRootPart bp.Position=hrp.Position bg.CFrame=hrp.CFrame bp.Parent=hrp bg.Parent=hrp
            _G.SkyFlyBP=bp _G.SkyFlyBG=bg
            _G.SkyFly=RunService.Heartbeat:Connect(function() pcall(function()
                local cam=workspace.CurrentCamera local vel=Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then vel=vel+cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then vel=vel-cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then vel=vel-cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then vel=vel+cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.E) then vel=vel+Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.Q) then vel=vel-Vector3.new(0,1,0) end
                local spd=UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 80 or 40
                _G.SkyFlyBP.Position=LP.Character.HumanoidRootPart.Position+vel*spd*0.016
                _G.SkyFlyBG.CFrame=cam.CFrame
            end) end)
        else
            if _G.SkyFly then _G.SkyFly:Disconnect() _G.SkyFly=nil end
            pcall(function() _G.SkyFlyBP:Destroy() _G.SkyFlyBG:Destroy() end)
        end
    end})
    MT:Slider({Title="Gravity",Step=1,Value={Min=0,Max=600,Default=196},Callback=function(v) workspace.Gravity=v end})
    MT:Button({Title="Reset Speed & Gravity",Callback=function()
        pcall(function() LP.Character.Humanoid.WalkSpeed=16 LP.Character.Humanoid.JumpPower=50 end)
        workspace.Gravity=196 notify("✅ Reset","Done!")
    end})
    MT:Button({Title="🚀 Launch Up",Callback=function() pcall(function() local bv=Instance.new("BodyVelocity",LP.Character.HumanoidRootPart) bv.Velocity=Vector3.new(0,120,0) bv.MaxForce=Vector3.new(0,1e6,0) game:GetService("Debris"):AddItem(bv,0.3) end) end})
    MT:Button({Title="💨 Dash Forward",Callback=function() pcall(function() local hrp=LP.Character.HumanoidRootPart local bv=Instance.new("BodyVelocity",hrp) bv.Velocity=hrp.CFrame.LookVector*120 bv.MaxForce=Vector3.new(1e6,0,1e6) game:GetService("Debris"):AddItem(bv,0.25) end) end})

    -- BUILD
    local BT=Window:Tab({Title="Build",Icon="hammer"})
    BT:Button({Title="⟳ Spawn Part",Callback=function() pcall(function() local p=Instance.new("Part") p.CFrame=workspace.CurrentCamera.CFrame*CFrame.new(0,0,-8) p.Size=Vector3.new(4,4,4) p.Anchored=true p.BrickColor=BrickColor.new("Bright blue") p.Parent=workspace end) notify("📦","Spawned!") end})
    BT:Button({Title="🔥 Real Builder",Callback=function() notify("⏳","Loading...") task.spawn(function() runScript(RealBuilder_URL) end) end})
    BT:Toggle({Title="Freeze All Parts",Value=false,Callback=function(s) pcall(function() for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") then obj.Anchored=s end end end) notify(s and "🔒 Frozen" or "🔓 Unfrozen","Done!") end})

    -- TP
    local TPT=Window:Tab({Title="TP",Icon="map-pin"})
    TPT:Input({Title="Teleport XYZ",Placeholder="X,Y,Z",Callback=function(text)
        local c={} for n in text:gmatch("[%-]?%d+%.?%d*") do table.insert(c,tonumber(n)) end
        if #c>=3 then pcall(function() LP.Character.HumanoidRootPart.CFrame=CFrame.new(c[1],c[2],c[3]) end) notify("📍 TP","Done!")
        else notify("⚠️","Enter valid X,Y,Z") end
    end})
    TPT:Button({Title="Save Position",Callback=function() _G.SkyPos=LP.Character.HumanoidRootPart.CFrame notify("📍 Saved","Done!") end})
    TPT:Button({Title="Load Position",Callback=function() if _G.SkyPos then pcall(function() LP.Character.HumanoidRootPart.CFrame=_G.SkyPos end) else notify("⚠️","No saved position!") end end})
    TPT:Button({Title="🌍 Map Center",Callback=function() pcall(function() LP.Character.HumanoidRootPart.CFrame=CFrame.new(0,50,0) end) end})
    TPT:Button({Title="🗺️ Random",Callback=function() pcall(function() local x,z=math.random(-500,500),math.random(-500,500) LP.Character.HumanoidRootPart.CFrame=CFrame.new(x,50,z) notify("🗺️ TP","X:"..x.." Z:"..z) end) end})
    TPT:Dropdown({Title="TP to Player",
        Values=function() local n={} for _,p in ipairs(Players:GetPlayers()) do if p~=LP then table.insert(n,p.Name) end end return n end,
        Callback=function(name) local t=Players:FindFirstChild(name) if t and t.Character then pcall(function() LP.Character.HumanoidRootPart.CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(3,0,0) end) notify("📍 TP","→ "..name) end end})

    -- GUI
    local GT=Window:Tab({Title="GUI",Icon="layout-dashboard"})
    GT:Toggle({Title="Hide All GUIs",Value=false,Callback=function(s) pcall(function() for _,g in ipairs(LP.PlayerGui:GetChildren()) do if g:IsA("ScreenGui") and not g.Name:find("SkyMoon") then g.Enabled=not s end end end) end})
    GT:Button({Title="📋 List GUIs",Callback=function() local n={} pcall(function() for _,g in ipairs(LP.PlayerGui:GetChildren()) do table.insert(n,g.Name) end end) notify("GUIs",table.concat(n,", "):sub(1,120),5) end})
    GT:Button({Title="🗑️ Delete GUIs",Callback=function() pcall(function() for _,g in ipairs(LP.PlayerGui:GetChildren()) do if g:IsA("ScreenGui") and not g.Name:find("SkyMoon") then g:Destroy() end end end) notify("🗑️","Done!") end})

    -- SOUND
    local SndT=Window:Tab({Title="Sound",Icon="music"})
    local csnd=nil
    SndT:Toggle({Title="Mute All",Value=false,Callback=function(s) pcall(function() for _,so in ipairs(workspace:GetDescendants()) do if so:IsA("Sound") then so.Volume=s and 0 or 1 end end end) notify(s and "🔇" or "🔊",s and "Muted!" or "Unmuted!") end})
    SndT:Slider({Title="Master Volume",Step=0.05,Value={Min=0,Max=1,Default=1},Callback=function(v) pcall(function() for _,so in ipairs(workspace:GetDescendants()) do if so:IsA("Sound") then so.Volume=v end end end) end})
    SndT:Divider()
    SndT:Section({Title="Custom Song"})
    SndT:Input({Title="Song ID",Placeholder="Sound ID...",Callback=function(text) local id=text:match("%d+") if id then _G.SkySongId=id notify("🎵","ID: "..id) end end})
    SndT:Dropdown({Title="Play Location",Values={"Workspace","Camera","LocalPlayer"},Callback=function(c) _G.SkySndTarget=c end})
    SndT:Slider({Title="Volume",Step=0.05,Value={Min=0,Max=1,Default=0.8},Callback=function(v) _G.SkySndVol=v if csnd then pcall(function() csnd.Volume=v end) end end})
    SndT:Button({Title="▶ Play",Callback=function()
        local id=tostring(_G.SkySongId or "") if id=="" then notify("⚠️","Enter Song ID!") return end
        if csnd then pcall(function() csnd:Stop() csnd:Destroy() end) csnd=nil end
        pcall(function()
            local s=Instance.new("Sound") s.SoundId="rbxassetid://"..id s.Volume=_G.SkySndVol or 0.8 s.Looped=true
            local t=workspace if _G.SkySndTarget=="Camera" then t=workspace.CurrentCamera elseif _G.SkySndTarget=="LocalPlayer" then t=LP end
            s.Parent=t s:Play() csnd=s notify("🎵 Playing","ID: "..id)
        end)
    end})
    SndT:Button({Title="⏸ Pause",Callback=function() if csnd then pcall(function() csnd:Pause() end) else notify("⚠️","No song!") end end})
    SndT:Button({Title="▶ Resume",Callback=function() if csnd then pcall(function() csnd:Resume() end) else notify("⚠️","No song!") end end})
    SndT:Button({Title="⏹ Stop",Callback=function() if csnd then pcall(function() csnd:Stop() csnd:Destroy() end) csnd=nil notify("⏹","Stopped.") else notify("⚠️","No song!") end end})
    SndT:Toggle({Title="Loop",Value=true,Callback=function(s) if csnd then pcall(function() csnd.Looped=s end) end end})
    SndT:Button({Title="🎵 Ambient BG",Callback=function() pcall(function() local s=Instance.new("Sound") s.SoundId="rbxassetid://139132289200391" s.Volume=0.4 s.Looped=true s.Parent=workspace s:Play() csnd=s end) notify("🎵","Ambient playing!") end})

    -- SETTINGS
    local SetT=Window:Tab({Title="Settings",Icon="settings"})
    SetT:Paragraph({Title="About",Content="SkyMoon v3.0 (WindUI + Junkie)\nby KHAFIDZKTP\ngithub.com/HaZcK/ScriptHub"})
    SetT:Divider()
    SetT:Button({Title="🔄 Reset Memory",Callback=function()
        pcall(function() if isfolder("SkyMoon") and isfile("SkyMoon/memory.json") then writefile("SkyMoon/memory.json",'{"log":[],"executeCount":0}') end end)
        notify("✅","Memory cleared!")
    end})
    SetT:Button({Title="📋 Copy PlaceId",Callback=function() pcall(function() setclipboard(tostring(game.PlaceId)) end) notify("📋","PlaceId: "..game.PlaceId) end})
end

----------------------------------------------------
-- STARTUP — loading screen then build tabs
----------------------------------------------------
task.spawn(function()
    showLoadingScreen(function()
        task.wait(0.1)
        buildTabs()
        -- Run All_tools
        if allToolsFn then pcall(allToolsFn) end
        notify("🌙 SkyMoon","Hub loaded! Click ⟳ Scan Game to start.")
    end)
end)
