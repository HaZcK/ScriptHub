-- 🌙 SkyMoon ScriptHub | Mainscript.lua v3 (WindUI)
-- by KHAFIDZKTP | github.com/HaZcK/ScriptHub

local RAW_PLACELIST = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/PlaceList.json"
local RAW_UNIVERSAL = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/Universal.json"
local ALL_TOOLS_URL = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/All_tools.lua"
local RealBuilder_URL = "https://raw.githubusercontent.com/HaZcK/ScriptHub/refs/heads/main/SkyMoon/Real_Builder.lua"

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local HttpService   = game:GetService("HttpService")
local UIS           = game:GetService("UserInputService")
local LP            = Players.LocalPlayer

----------------------------------------------------
-- LOADING SCREEN (before WindUI)
----------------------------------------------------
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

-- Grid lines
for i=0,20 do
    local l=Instance.new("Frame",loadBg) l.Size=UDim2.new(1,0,0,1)
    l.Position=UDim2.new(0,0,0,i*40) l.BackgroundColor3=Color3.fromRGB(18,12,40)
    l.BackgroundTransparency=0.7 l.BorderSizePixel=0
end
for i=0,30 do
    local l=Instance.new("Frame",loadBg) l.Size=UDim2.new(0,1,1,0)
    l.Position=UDim2.new(0,i*50,0,0) l.BackgroundColor3=Color3.fromRGB(18,12,40)
    l.BackgroundTransparency=0.7 l.BorderSizePixel=0
end

local center=Instance.new("Frame",loadBg)
center.Size=UDim2.new(0,280,0,210) center.Position=UDim2.new(0.5,-140,0.5,-105)
center.BackgroundTransparency=1 center.BorderSizePixel=0

-- Rings
local ro=Instance.new("ImageLabel",center)
ro.Size=UDim2.new(0,90,0,90) ro.Position=UDim2.new(0.5,-45,0,0)
ro.BackgroundTransparency=1 ro.Image="rbxassetid://6031094678"
ro.ImageColor3=Color3.fromRGB(110,70,255) ro.ImageTransparency=0.2

local ri=Instance.new("ImageLabel",center)
ri.Size=UDim2.new(0,60,0,60) ri.Position=UDim2.new(0.5,-30,0,15)
ri.BackgroundTransparency=1 ri.Image="rbxassetid://6031094678"
ri.ImageColor3=Color3.fromRGB(0,200,170) ri.ImageTransparency=0.4

local moonLbl=Instance.new("TextLabel",center)
moonLbl.Size=UDim2.new(0,90,0,90) moonLbl.Position=UDim2.new(0.5,-45,0,0)
moonLbl.BackgroundTransparency=1 moonLbl.Text="🌙"
moonLbl.Font=Enum.Font.GothamBold moonLbl.TextSize=34

local titleL=Instance.new("TextLabel",center)
titleL.Size=UDim2.new(1,0,0,30) titleL.Position=UDim2.new(0,0,0,96)
titleL.BackgroundTransparency=1 titleL.Text="SKYMOON"
titleL.Font=Enum.Font.GothamBold titleL.TextSize=22
titleL.TextColor3=Color3.fromRGB(160,130,255)

local subL=Instance.new("TextLabel",center)
subL.Size=UDim2.new(1,0,0,16) subL.Position=UDim2.new(0,0,0,126)
subL.BackgroundTransparency=1 subL.Text="SCRIPT HUB  ·  BY KHAFIDZKTP"
subL.Font=Enum.Font.GothamBold subL.TextSize=9
subL.TextColor3=Color3.fromRGB(60,50,100)

local barBg=Instance.new("Frame",center)
barBg.Size=UDim2.new(1,0,0,4) barBg.Position=UDim2.new(0,0,0,152)
barBg.BackgroundColor3=Color3.fromRGB(20,15,40) barBg.BorderSizePixel=0
Instance.new("UICorner",barBg).CornerRadius=UDim.new(0,2)

local barFill=Instance.new("Frame",barBg)
barFill.Size=UDim2.new(0,0,1,0) barFill.BackgroundColor3=Color3.fromRGB(110,70,255)
barFill.BorderSizePixel=0 Instance.new("UICorner",barFill).CornerRadius=UDim.new(0,2)
local bg2=Instance.new("UIGradient",barFill)
bg2.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(100,60,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,200,180))})

local statusL=Instance.new("TextLabel",center)
statusL.Size=UDim2.new(1,0,0,14) statusL.Position=UDim2.new(0,0,0,160)
statusL.BackgroundTransparency=1 statusL.Text="Initializing..."
statusL.Font=Enum.Font.Code statusL.TextSize=10
statusL.TextColor3=Color3.fromRGB(70,60,110)

-- Spin animation
local spinConn=RunService.RenderStepped:Connect(function(dt)
    ro.Rotation=ro.Rotation+80*dt
    ri.Rotation=ri.Rotation-120*dt
end)

local STEPS={
    {0.15,"Loading WindUI library..."},
    {0.32,"Connecting to ScriptHub..."},
    {0.50,"Fetching game database..."},
    {0.68,"Scanning game services..."},
    {0.85,"Preparing admin panel..."},
    {1.00,"Ready!"},
}

local function runLoadingSequence(onComplete)
    local stepTime=2.6/#STEPS
    for _,step in ipairs(STEPS) do
        statusL.Text=step[2]
        TweenService:Create(barFill,TweenInfo.new(stepTime*0.9,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
            Size=UDim2.new(step[1],0,1,0)
        }):Play()
        task.wait(stepTime)
    end
    task.wait(0.2)
    TweenService:Create(loadBg,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play()
    TweenService:Create(center,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.In),{
        Position=UDim2.new(0.5,-140,0.4,-105)
    }):Play()
    task.wait(0.55)
    spinConn:Disconnect()
    loadSg:Destroy()
    onComplete()
end

----------------------------------------------------
-- HELPERS
----------------------------------------------------
local function notify(title, msg, dur)
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = msg,
            Duration = dur or 4,
        })
    end)
end

local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    return ok and res or nil
end

local function fetchPlaceList()
    local raw = httpGet(RAW_PLACELIST)
    if not raw then return nil end
    local ok, db = pcall(function() return HttpService:JSONDecode(raw) end)
    return ok and db or nil
end

local function fetchUniversal()
    local raw = httpGet(RAW_UNIVERSAL)
    if not raw then return nil end
    local ok, db = pcall(function() return HttpService:JSONDecode(raw) end)
    return ok and db or nil
end

local function escapeRich(s)
    return tostring(s):gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;")
end

local function runScript(url)
    local raw = httpGet(url)
    if not raw then notify("❌ Error","Failed to load script!") return end
    local fn, err = loadstring(raw)
    if not fn then notify("❌ Parse Error", tostring(err):sub(1,60)) return end
    pcall(fn)
end

----------------------------------------------------
-- SCAN SYSTEM (CMD overlay — kept as custom GUI)
----------------------------------------------------
local function openScanOverlay()
    local scanSg = Instance.new("ScreenGui")
    scanSg.Name = "SkyMoon_Scan"
    scanSg.ResetOnSpawn = false
    scanSg.IgnoreGuiInset = true
    pcall(function() scanSg.Parent = game:GetService("CoreGui") end)
    if not scanSg.Parent then scanSg.Parent = LP.PlayerGui end

    local bg = Instance.new("Frame", scanSg)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 0.05
    bg.BorderSizePixel = 0

    -- Ubuntu-style header
    local header = Instance.new("Frame", bg)
    header.Size = UDim2.new(1,0,0,54)
    header.BackgroundColor3 = Color3.fromRGB(10,10,18)
    header.BorderSizePixel = 0

    local ubuntuImg = Instance.new("ImageLabel", header)
    ubuntuImg.Size = UDim2.new(0,40,0,40)
    ubuntuImg.Position = UDim2.new(0.5,-20,0,7)
    ubuntuImg.BackgroundTransparency = 1
    ubuntuImg.Image = "https://tkj.smkdarmasiswasidoarjo.sch.id/wp-content/uploads/2024/08/61ef634e-0b5f-4d27-9fb6-c64d526c595c.png"

    local output = Instance.new("TextLabel", bg)
    output.Size = UDim2.new(1,-32,1,-60)
    output.Position = UDim2.new(0,16,0,58)
    output.BackgroundTransparency = 1
    output.Font = Enum.Font.Code
    output.TextSize = 13
    output.TextColor3 = Color3.fromRGB(0,255,80)
    output.TextXAlignment = Enum.TextXAlignment.Left
    output.TextYAlignment = Enum.TextYAlignment.Top
    output.TextWrapped = true
    output.RichText = true
    output.Text = ""

    local function appendLine(text, color)
        output.Text = output.Text .. string.format('<font color="#%s">%s</font>\n', color or "00ff44", escapeRich(text))
    end

    local function typeText(text, color, delay)
        for i = 1, #text do
            output.Text = output.Text .. string.format('<font color="#%s">%s</font>', color or "00ff44", escapeRich(text:sub(i,i)))
            task.wait(delay or 0.04)
        end
        output.Text = output.Text .. "\n"
    end

    task.spawn(function()
        -- Boot sequence
        appendLine("SkyMoon Terminal v2.0", "aaaaff")
        appendLine("by KHAFIDZKTP | github.com/HaZcK/ScriptHub", "666688")
        task.wait(0.3)
        typeText("Scanning game environment...", "00ff88", 0.05)
        task.wait(0.2)

        -- Hacker mode — random IPs
        local countries = {"US","JP","DE","BR","SG","KR","FR","AU","CA","NL"}
        for i = 1, 6 do
            local ip = string.format("%d.%d.%d.%d", math.random(1,255), math.random(0,255), math.random(0,255), math.random(1,254))
            local cc = countries[math.random(1,#countries)]
            appendLine(string.format("[%s] %-16s CONNECTED", cc, ip), "00aa55")
            task.wait(0.08)
        end

        output.Text = ""
        typeText("Check_This_Game:;", "00ff88", 0.06)
        task.wait(0.2)

        -- Workspace scan
        local SERVICES = {
            {game:GetService("Workspace"),"Workspace"},
            {game:GetService("ReplicatedStorage"),"ReplicatedStorage"},
            {game:GetService("Lighting"),"Lighting"},
            {LP,"LocalPlayer"},
        }

        local allItems = {}
        local function collect(parent, depth, label)
            if depth > 2 then return end
            for _, child in ipairs(parent:GetChildren()) do
                table.insert(allItems, {name=child.Name, class=child.ClassName, depth=depth, label=label})
                if not child:IsA("Model") then collect(child, depth+1, label) end
            end
        end
        for _, s in ipairs(SERVICES) do
            pcall(function() collect(s[1], 0, s[2]) end)
        end

        local total = math.max(#allItems, 1)
        local lineCount = 0
        local lineBuffer = {}

        local ROBLOX_DEFAULT = {RobloxGui=true,TopBarApp=true,ChatApp=true,ControlGui=true,BubbleChatScreenGui=true}

        for i, item in ipairs(allItems) do
            if item.class == "ScreenGui" and ROBLOX_DEFAULT[item.name] then goto continue end
            local pct = math.floor((i/total)*100)
            local line = string.format("[KHAFIDZKTP, %s] %s (%d%%)", item.label, item.name, pct)

            -- 4 items per line for same-parent objects
            table.insert(lineBuffer, item.name)
            if #lineBuffer >= 4 then
                appendLine(string.format("[%s] %s", item.label, table.concat(lineBuffer, "  |  ")), "00ff44")
                lineBuffer = {}
                lineCount = lineCount + 1
            end

            if lineCount >= 22 then output.Text = "" lineCount = 0 end
            if i % 8 == 0 then task.wait() end
            ::continue::
        end
        if #lineBuffer > 0 then
            appendLine(string.format("[%s] %s", (allItems[#allItems] or {label=""}).label, table.concat(lineBuffer, "  |  ")), "00ff44")
        end

        output.Text = ""
        appendLine("Check_This_Game... 100%", "00ffaa")
        task.wait(0.4)

        -- PlaceList check
        typeText("Checking game support...", "00ff88", 0.05)
        local db = fetchPlaceList()
        local placeId = tostring(game.PlaceId)
        local entry = db and db[placeId]

        -- GameId fallback for sub-place / VoiceChat teleport
        if not entry and db then
            for pid, data in pairs(db) do
                local ok, info = pcall(function()
                    return game:GetService("MarketplaceService"):GetProductInfo(tonumber(pid))
                end)
                local ok2, myInfo = pcall(function()
                    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
                end)
                if ok and ok2 and info and myInfo then
                    if info.Creator and myInfo.Creator and info.Creator.Id == myInfo.Creator.Id then
                        entry = data
                        appendLine("✓ Sub-place detected — same game verified", "ffaa00")
                        break
                    end
                end
            end
        end

        task.wait(0.3)
        if entry then
            appendLine("✓ Game supported! Running script...", "00ffaa")
            task.wait(0.5)
            scanSg:Destroy()
            runScript(entry.script)
        else
            appendLine("✗ Game not supported.", "ff4444")
            task.wait(0.3)
            typeText("Loading Universal Scripts...", "ffaa00", 0.05)
            task.wait(0.3)

            local udb = fetchUniversal()
            if udb then
                output.Text = ""
                appendLine("=== Universal Script List ===", "aaaaff")
                for k, v in pairs(udb) do
                    appendLine(string.format("[%s] %s", k, v.name), "88ffbb")
                end
                task.wait(3)
            end
            scanSg:Destroy()
        end
    end)

    -- Close on click
    bg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton2 then
            scanSg:Destroy()
        end
    end)
end

----------------------------------------------------
-- MINI CMD (chat command /Open_Cmd)
----------------------------------------------------
local function openMiniCmd()
    local cSg = Instance.new("ScreenGui")
    cSg.Name = "SkyMoon_Cmd"
    cSg.ResetOnSpawn = false
    pcall(function() cSg.Parent = game:GetService("CoreGui") end)
    if not cSg.Parent then cSg.Parent = LP.PlayerGui end

    local win = Instance.new("Frame", cSg)
    win.Size = UDim2.new(0, 420, 0, 240)
    win.Position = UDim2.new(0.5,-210,0.5,-120)
    win.BackgroundColor3 = Color3.fromRGB(8,8,16)
    win.BorderSizePixel = 0
    win.Active = true win.Draggable = true
    Instance.new("UICorner",win).CornerRadius=UDim.new(0,10)
    local ws=Instance.new("UIStroke",win) ws.Color=Color3.fromRGB(60,50,160) ws.Thickness=1.5

    local titleBar=Instance.new("Frame",win)
    titleBar.Size=UDim2.new(1,0,0,28) titleBar.BackgroundColor3=Color3.fromRGB(6,6,14)
    titleBar.BorderSizePixel=0
    Instance.new("UICorner",titleBar).CornerRadius=UDim.new(0,10)
    local tf=Instance.new("Frame",titleBar) tf.Size=UDim2.new(1,0,0.5,0)
    tf.Position=UDim2.new(0,0,0.5,0) tf.BackgroundColor3=Color3.fromRGB(6,6,14) tf.BorderSizePixel=0

    local tl=Instance.new("TextLabel",titleBar) tl.Size=UDim2.new(1,-60,1,0)
    tl.Position=UDim2.new(0,10,0,0) tl.BackgroundTransparency=1
    tl.Text="🌙 SkyMoon Terminal" tl.Font=Enum.Font.GothamBold tl.TextSize=11
    tl.TextColor3=Color3.fromRGB(150,130,255) tl.TextXAlignment=Enum.TextXAlignment.Left

    local closeB=Instance.new("TextButton",titleBar) closeB.Size=UDim2.new(0,22,0,20)
    closeB.Position=UDim2.new(1,-26,0,4) closeB.BackgroundColor3=Color3.fromRGB(160,30,50)
    closeB.Text="✕" closeB.TextColor3=Color3.new(1,1,1) closeB.Font=Enum.Font.GothamBold
    closeB.TextSize=10 closeB.BorderSizePixel=0
    Instance.new("UICorner",closeB).CornerRadius=UDim.new(0,4)
    closeB.MouseButton1Click:Connect(function() cSg:Destroy() end)

    local outFrame=Instance.new("ScrollingFrame",win)
    outFrame.Size=UDim2.new(1,-12,1,-60) outFrame.Position=UDim2.new(0,6,0,30)
    outFrame.BackgroundTransparency=1 outFrame.BorderSizePixel=0
    outFrame.ScrollBarThickness=2 outFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y
    outFrame.CanvasSize=UDim2.new(0,0,0,0)

    local outLbl=Instance.new("TextLabel",outFrame)
    outLbl.Size=UDim2.new(1,-4,0,0) outLbl.AutomaticSize=Enum.AutomaticSize.Y
    outLbl.BackgroundTransparency=1 outLbl.Text='<font color="#555577">-- SkyMoon CMD ready --\n/Open_Cmd opened. Type commands below.\n</font>'
    outLbl.Font=Enum.Font.Code outLbl.TextSize=11 outLbl.TextColor3=Color3.fromRGB(200,210,255)
    outLbl.TextXAlignment=Enum.TextXAlignment.Left outLbl.TextYAlignment=Enum.TextYAlignment.Top
    outLbl.TextWrapped=true outLbl.RichText=true

    local function appendOut(text, color)
        outLbl.Text = outLbl.Text .. string.format('<font color="#%s">%s\n</font>', color, escapeRich(text))
        task.defer(function() outFrame.CanvasPosition=Vector2.new(0,outFrame.AbsoluteCanvasSize.Y) end)
    end

    local inputBar=Instance.new("Frame",win)
    inputBar.Size=UDim2.new(1,-12,0,26) inputBar.Position=UDim2.new(0,6,1,-30)
    inputBar.BackgroundColor3=Color3.fromRGB(16,14,32) inputBar.BorderSizePixel=0
    Instance.new("UICorner",inputBar).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",inputBar).Color=Color3.fromRGB(60,50,160)

    local prompt=Instance.new("TextLabel",inputBar)
    prompt.Size=UDim2.new(0,22,1,0) prompt.BackgroundTransparency=1
    prompt.Text="$" prompt.Font=Enum.Font.Code prompt.TextSize=12
    prompt.TextColor3=Color3.fromRGB(100,80,200)

    local inputBox=Instance.new("TextBox",inputBar)
    inputBox.Size=UDim2.new(1,-26,1,0) inputBox.Position=UDim2.new(0,24,0,0)
    inputBox.BackgroundTransparency=1 inputBox.Text=""
    inputBox.PlaceholderText="Check In [Workspace, Folder, Name]  |  RunConsole"
    inputBox.PlaceholderColor3=Color3.fromRGB(50,45,80)
    inputBox.TextColor3=Color3.fromRGB(200,210,255) inputBox.Font=Enum.Font.Code
    inputBox.TextSize=11 inputBox.ClearTextOnFocus=false

    local function processCmd(cmd)
        appendOut("> " .. cmd, "cccccc")
        local lower = cmd:lower():match("^%s*(.-)%s*$")
        if lower == "runconsole" then
            appendOut("Opening console...", "aaaaff")
        elseif lower:match("^check in") then
            local inner = cmd:match("[Cc]heck [Ii]n %[(.-)%]")
            if not inner then
                appendOut("Usage: Check In [Service, Folder, Name]", "888888")
                return
            end
            local parts = {}
            for p in inner:gmatch("[^,]+") do
                table.insert(parts, p:match("^%s*(.-)%s*$"))
            end
            local services = {
                Workspace=workspace, ReplicatedStorage=game:GetService("ReplicatedStorage"),
                LocalPlayer=LP, Lighting=game:GetService("Lighting"),
                StarterGui=game:GetService("StarterGui"),
            }
            local current = services[parts[1]] or (parts[1]=="workspace" and workspace)
            if not current then appendOut("Unknown service: "..parts[1], "ff6644") return end
            for i=2,#parts do
                local found = current:FindFirstChild(parts[i])
                if not found then appendOut("Not found: "..parts[i], "ff6644") return end
                current = found
            end
            appendOut("Found: " .. current:GetFullName() .. " [" .. current.ClassName .. "]", "00ffaa")
        else
            appendOut("Unknown command. Try: Check In [...] or RunConsole", "ff4444")
        end
    end

    inputBox.FocusLost:Connect(function(enter)
        if not enter or inputBox.Text == "" then return end
        processCmd(inputBox.Text)
        inputBox.Text = ""
    end)
end

----------------------------------------------------
-- CONSOLE (/console command)
----------------------------------------------------
local function openConsole()
    local cSg=Instance.new("ScreenGui") cSg.Name="SkyMoon_Console" cSg.ResetOnSpawn=false
    pcall(function() cSg.Parent=game:GetService("CoreGui") end)
    if not cSg.Parent then cSg.Parent=LP.PlayerGui end

    local win=Instance.new("Frame",cSg) win.Size=UDim2.new(0,500,0,300)
    win.Position=UDim2.new(0.5,-250,0.5,-150) win.BackgroundColor3=Color3.fromRGB(8,8,16)
    win.BorderSizePixel=0 win.Active=true win.Draggable=true
    Instance.new("UICorner",win).CornerRadius=UDim.new(0,10)
    local ws=Instance.new("UIStroke",win) ws.Color=Color3.fromRGB(60,50,160) ws.Thickness=1.5

    local tbar=Instance.new("Frame",win) tbar.Size=UDim2.new(1,0,0,28)
    tbar.BackgroundColor3=Color3.fromRGB(6,6,14) tbar.BorderSizePixel=0
    Instance.new("UICorner",tbar).CornerRadius=UDim.new(0,10)
    local tf=Instance.new("Frame",tbar) tf.Size=UDim2.new(1,0,0.5,0)
    tf.Position=UDim2.new(0,0,0.5,0) tf.BackgroundColor3=Color3.fromRGB(6,6,14) tf.BorderSizePixel=0
    local tl=Instance.new("TextLabel",tbar) tl.Size=UDim2.new(1,-50,1,0)
    tl.Position=UDim2.new(0,10,0,0) tl.BackgroundTransparency=1
    tl.Text="🌙 Live Console" tl.Font=Enum.Font.GothamBold tl.TextSize=11
    tl.TextColor3=Color3.fromRGB(150,130,255) tl.TextXAlignment=Enum.TextXAlignment.Left
    local cb=Instance.new("TextButton",tbar) cb.Size=UDim2.new(0,22,0,20)
    cb.Position=UDim2.new(1,-26,0,4) cb.BackgroundColor3=Color3.fromRGB(160,30,50)
    cb.Text="✕" cb.TextColor3=Color3.new(1,1,1) cb.Font=Enum.Font.GothamBold
    cb.TextSize=10 cb.BorderSizePixel=0 Instance.new("UICorner",cb).CornerRadius=UDim.new(0,4)
    cb.MouseButton1Click:Connect(function() cSg:Destroy() end)

    local scroll=Instance.new("ScrollingFrame",win) scroll.Size=UDim2.new(1,-12,1,-36)
    scroll.Position=UDim2.new(0,6,0,32) scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0
    scroll.ScrollBarThickness=2 scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.CanvasSize=UDim2.new(0,0,0,0)

    local outL=Instance.new("TextLabel",scroll) outL.Size=UDim2.new(1,-4,0,0)
    outL.AutomaticSize=Enum.AutomaticSize.Y outL.BackgroundTransparency=1 outL.Text=""
    outL.Font=Enum.Font.Code outL.TextSize=11 outL.TextColor3=Color3.fromRGB(200,210,255)
    outL.TextXAlignment=Enum.TextXAlignment.Left outL.TextYAlignment=Enum.TextYAlignment.Top
    outL.TextWrapped=true outL.RichText=true

    local logConn = game:GetService("LogService").MessageOut:Connect(function(msg, msgType)
        local color = "aaffaa"
        if msgType==Enum.MessageType.MessageWarning then color="ffcc44"
        elseif msgType==Enum.MessageType.MessageError then color="ff5555" end
        outL.Text = outL.Text .. string.format('<font color="#%s">%s\n</font>', color, escapeRich(msg:sub(1,120)))
        task.defer(function() scroll.CanvasPosition=Vector2.new(0,scroll.AbsoluteCanvasSize.Y) end)
    end)
    cSg.AncestryChanged:Connect(function() pcall(function() logConn:Disconnect() end) end)
end

----------------------------------------------------
-- CHAT COMMANDS
----------------------------------------------------
LP.Chatted:Connect(function(msg)
    local lower = msg:lower():match("^%s*(.-)%s*$")
    if lower == "/open_cmd" then
        openMiniCmd()
    elseif lower == "/open_admin" then
        if WindUI and Window then Window:Toggle() end
    elseif lower == "/console" then
        openConsole()
    elseif lower == "/reset_skymoon" then
        pcall(function()
            if isfolder("SkyMoon") then
                if isfile("SkyMoon/memory.json") then
                    writefile("SkyMoon/memory.json",'{"log":[],"executeCount":0}')
                end
            end
        end)
        notify("✅ Reset", "SkyMoon data reset successfully!")
    end
end)

----------------------------------------------------
-- MAIN — WindUI HUB
----------------------------------------------------
local function startWindUI()
    -- Load WindUI
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if not ok then
        notify("❌ WindUI Error", tostring(lib):sub(1,60))
        return
    end

    WindUI = lib
    WindUI:SetFont(Enum.Font.Gotham)

    Window = WindUI:CreateWindow({
        Title       = "SkyMoon",
        Icon        = "moon",
        Author      = "by KHAFIDZKTP",
        Folder      = "SkyMoon",
        Size        = UDim2.fromOffset(600, 480),
        MinSize     = Vector2.new(540, 380),
        Transparent = true,
        Theme       = "Dark",
        Resizable   = true,
        SideBarWidth = 200,
    })

    ----------------------------------------------------
    -- TAB: HOME
    ----------------------------------------------------
    local HomeTab = Window:Tab({ Title="Home", Icon="house" })

    HomeTab:Paragraph({
        Title   = "🌙 SkyMoon Script Hub",
        Content = "Welcome! Use ⟳ Scan Game to detect and run the script for the current game.\n\nChat Commands: /Open_Cmd  /console  /reset_skymoon",
    })

    HomeTab:Divider()

    HomeTab:Button({
        Title    = "⟳ Scan Game",
        Desc     = "Detect current game and execute the matching script",
        Callback = function()
            Window:Close()
            task.wait(0.2)
            openScanOverlay()
        end
    })

    HomeTab:Button({
        Title    = "📋 Universal Scripts",
        Desc     = "Browse scripts that work on any game",
        Callback = function()
            local udb = fetchUniversal()
            if not udb then notify("❌ Error","Failed to load universal list!") return end
            -- Show as dialog
            WindUI:Notify({
                Title   = "Universal Scripts",
                Content = "Loaded "..tostring(#(function() local c=0 for _ in pairs(udb) do c=c+1 end return c end)()).." scripts. Check console.",
                Duration = 3,
            })
            for k, v in pairs(udb) do
                print(string.format("[%s] %s — %s", k, v.name, v.script))
            end
        end
    })

    HomeTab:Button({
        Title    = "🔥 Real Builder",
        Desc     = "Open in-game Studio builder",
        Callback = function()
            notify("⏳ Loading","Loading Real Builder...")
            task.spawn(function() runScript(RealBuilder_URL) end)
        end
    })

    HomeTab:Button({
        Title    = "💻 Open Terminal",
        Desc     = "Mini CMD — Check In commands",
        Callback = function() openMiniCmd() end
    })

    HomeTab:Button({
        Title    = "📟 Open Console",
        Desc     = "Live output console",
        Callback = function() openConsole() end
    })

    HomeTab:Divider()

    HomeTab:Paragraph({
        Title   = "Info",
        Content = "Game: " .. tostring(game:GetService("MarketplaceService"):GetProductInfo and (pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end) and game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown") or "Unknown") .. "\nPlaceId: " .. game.PlaceId .. "\nPlayer: " .. LP.Name,
    })

    ----------------------------------------------------
    -- TAB: PLAYERS
    ----------------------------------------------------
    local PlayersTab = Window:Tab({ Title="Players", Icon="users" })
    local char = LP.Character or LP.CharacterAdded:Wait()

    PlayersTab:Section({ Title="Character" })

    PlayersTab:Toggle({
        Title="God Mode", Desc="Max health & no damage",
        Value=false,
        Callback=function(state)
            pcall(function()
                local h=LP.Character.Humanoid
                if state then h.MaxHealth=math.huge h.Health=math.huge
                else h.MaxHealth=100 h.Health=100 end
            end)
        end
    })

    PlayersTab:Toggle({
        Title="NoClip", Desc="Walk through walls",
        Value=false,
        Callback=function(state)
            if state then
                _G.SkyNoClip=RunService.Stepped:Connect(function()
                    pcall(function()
                        for _,p in ipairs(LP.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide=false end
                        end
                    end)
                end)
            else
                if _G.SkyNoClip then _G.SkyNoClip:Disconnect() _G.SkyNoClip=nil end
            end
        end
    })

    PlayersTab:Toggle({
        Title="Infinite Jump", Desc="Jump anytime",
        Value=false,
        Callback=function(state)
            if state then
                _G.SkyInfJump=UIS.JumpRequest:Connect(function()
                    pcall(function() LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
                end)
            else
                if _G.SkyInfJump then _G.SkyInfJump:Disconnect() _G.SkyInfJump=nil end
            end
        end
    })

    PlayersTab:Toggle({
        Title="Anti-AFK", Desc="Prevent auto-kick",
        Value=false,
        Callback=function(state)
            if state then
                _G.SkyAFK=RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local VU=game:GetService("VirtualUser")
                        VU:CaptureController() VU:ClickButton2(Vector2.new())
                    end)
                end)
            else
                if _G.SkyAFK then _G.SkyAFK:Disconnect() _G.SkyAFK=nil end
            end
        end
    })

    PlayersTab:Toggle({
        Title="Invisible (local)", Desc="Others can't see your character",
        Value=false,
        Callback=function(state)
            pcall(function()
                for _,p in ipairs(LP.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.LocalTransparencyModifier=state and 1 or 0 end
                end
            end)
        end
    })

    PlayersTab:Toggle({
        Title="Spin", Desc="Continuously rotate character",
        Value=false,
        Callback=function(state)
            if state then
                _G.SkySpin=RunService.Heartbeat:Connect(function()
                    pcall(function()
                        LP.Character.HumanoidRootPart.CFrame=
                            LP.Character.HumanoidRootPart.CFrame*CFrame.Angles(0,math.rad(5),0)
                    end)
                end)
            else
                if _G.SkySpin then _G.SkySpin:Disconnect() _G.SkySpin=nil end
            end
        end
    })

    PlayersTab:Section({ Title="Stats" })

    PlayersTab:Slider({
        Title="Walk Speed", Desc="Default: 16",
        Step=1, Value={Min=0,Max=500,Default=16},
        Callback=function(v) pcall(function() LP.Character.Humanoid.WalkSpeed=v end) end
    })

    PlayersTab:Slider({
        Title="Jump Power", Desc="Default: 50",
        Step=1, Value={Min=0,Max=500,Default=50},
        Callback=function(v) pcall(function() LP.Character.Humanoid.JumpPower=v end) end
    })

    PlayersTab:Section({ Title="Actions" })

    PlayersTab:Button({
        Title="Save Position", Desc="Save current location",
        Callback=function()
            _G.SkyPos=LP.Character.HumanoidRootPart.CFrame
            notify("📍 Saved","Position saved!")
        end
    })

    PlayersTab:Button({
        Title="Load Position", Desc="Teleport to saved location",
        Callback=function()
            if _G.SkyPos then
                pcall(function() LP.Character.HumanoidRootPart.CFrame=_G.SkyPos end)
            else notify("⚠️ No saved position","Save a position first!") end
        end
    })

    PlayersTab:Button({
        Title="Respawn", Desc="Instantly respawn character",
        Callback=function() pcall(function() LP:LoadCharacter() end) end
    })

    PlayersTab:Input({
        Title="Set Nametag", Placeholder="Display name...",
        Callback=function(text)
            if text=="" then return end
            pcall(function()
                local h=LP.Character:FindFirstChild("Head")
                if not h then return end
                local bg=h:FindFirstChildOfClass("BillboardGui") or Instance.new("BillboardGui",h)
                bg.Size=UDim2.new(0,120,0,30) bg.StudsOffset=Vector3.new(0,2.5,0)
                local lbl=bg:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel",bg)
                lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1
                lbl.Text=text lbl.TextColor3=Color3.new(1,1,1)
                lbl.Font=Enum.Font.GothamBold lbl.TextSize=14
            end)
        end
    })

    ----------------------------------------------------
    -- TAB: MOVEMENT
    ----------------------------------------------------
    local MoveTab = Window:Tab({ Title="Move", Icon="wind" })

    MoveTab:Toggle({
        Title="Fly", Desc="Fly around the map",
        Value=false,
        Callback=function(state)
            if state then
                local bp=Instance.new("BodyPosition") bp.MaxForce=Vector3.new(1e5,1e5,1e5) bp.P=1e4
                local bg=Instance.new("BodyGyro") bg.MaxTorque=Vector3.new(1e5,1e5,1e5) bg.P=1e4
                local hrp=LP.Character.HumanoidRootPart
                bp.Position=hrp.Position bg.CFrame=hrp.CFrame
                bp.Parent=hrp bg.Parent=hrp
                _G.SkyFlyBP=bp _G.SkyFlyBG=bg
                _G.SkyFly=RunService.Heartbeat:Connect(function()
                    pcall(function()
                        local cam=workspace.CurrentCamera
                        local vel=Vector3.new(0,0,0)
                        if UIS:IsKeyDown(Enum.KeyCode.W) then vel=vel+cam.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.S) then vel=vel-cam.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.A) then vel=vel-cam.CFrame.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.D) then vel=vel+cam.CFrame.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.E) then vel=vel+Vector3.new(0,1,0) end
                        if UIS:IsKeyDown(Enum.KeyCode.Q) then vel=vel-Vector3.new(0,1,0) end
                        local spd=UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 80 or 40
                        _G.SkyFlyBP.Position=hrp.Position+vel*spd*0.016
                        _G.SkyFlyBG.CFrame=cam.CFrame
                    end)
                end)
            else
                if _G.SkyFly then _G.SkyFly:Disconnect() _G.SkyFly=nil end
                pcall(function() _G.SkyFlyBP:Destroy() _G.SkyFlyBG:Destroy() end)
            end
        end
    })

    MoveTab:Slider({
        Title="Gravity", Desc="Default: 196",
        Step=1, Value={Min=0,Max=600,Default=196},
        Callback=function(v) workspace.Gravity=v end
    })

    MoveTab:Button({ Title="Reset Speed & Gravity", Callback=function()
        pcall(function()
            LP.Character.Humanoid.WalkSpeed=16
            LP.Character.Humanoid.JumpPower=50
        end)
        workspace.Gravity=196
        notify("✅ Reset","Speed and gravity reset!")
    end})

    MoveTab:Button({ Title="🚀 Launch Upward", Callback=function()
        pcall(function()
            local bv=Instance.new("BodyVelocity",LP.Character.HumanoidRootPart)
            bv.Velocity=Vector3.new(0,120,0) bv.MaxForce=Vector3.new(0,1e6,0)
            game:GetService("Debris"):AddItem(bv,0.3)
        end)
    end})

    MoveTab:Button({ Title="💨 Dash Forward", Callback=function()
        pcall(function()
            local hrp=LP.Character.HumanoidRootPart
            local bv=Instance.new("BodyVelocity",hrp)
            bv.Velocity=hrp.CFrame.LookVector*120 bv.MaxForce=Vector3.new(1e6,0,1e6)
            game:GetService("Debris"):AddItem(bv,0.25)
        end)
    end})

    ----------------------------------------------------
    -- TAB: BUILD
    ----------------------------------------------------
    local BuildTab = Window:Tab({ Title="Build", Icon="hammer" })

    BuildTab:Button({
        Title="⟳ Spawn Part", Desc="Spawn a BasePart near camera",
        Callback=function()
            pcall(function()
                local p=Instance.new("Part")
                local cam=workspace.CurrentCamera
                p.CFrame=cam.CFrame*CFrame.new(0,0,-8)
                p.Size=Vector3.new(4,4,4) p.Anchored=true
                p.BrickColor=BrickColor.new("Bright blue")
                p.Parent=workspace
                notify("📦 Spawned","Part spawned!")
            end)
        end
    })

    BuildTab:Button({
        Title="🔥 Real Builder", Desc="Full in-game Studio mode",
        Callback=function()
            notify("⏳ Loading","Loading Real Builder...")
            task.spawn(function() runScript(RealBuilder_URL) end)
        end
    })

    BuildTab:Toggle({
        Title="Freeze All Parts", Desc="Anchor every BasePart in workspace",
        Value=false,
        Callback=function(state)
            pcall(function()
                for _,obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then obj.Anchored=state end
                end
            end)
            notify(state and "🔒 Frozen" or "🔓 Unfrozen","All parts "..(state and "anchored" or "unanchored").."!")
        end
    })

    BuildTab:Button({ Title="💥 Explode at Camera", Callback=function()
        pcall(function()
            local e=Instance.new("Explosion")
            e.Position=workspace.CurrentCamera.CFrame.Position+workspace.CurrentCamera.CFrame.LookVector*15
            e.BlastRadius=12 e.Parent=workspace
        end)
    end})

    ----------------------------------------------------
    -- TAB: TELEPORT
    ----------------------------------------------------
    local TPTab = Window:Tab({ Title="TP", Icon="map-pin" })

    TPTab:Input({
        Title="Teleport XYZ", Placeholder="X,Y,Z  e.g. 0,50,0",
        Callback=function(text)
            local coords={}
            for n in text:gmatch("[%-]?%d+%.?%d*") do table.insert(coords,tonumber(n)) end
            if #coords>=3 then
                pcall(function() LP.Character.HumanoidRootPart.CFrame=CFrame.new(coords[1],coords[2],coords[3]) end)
                notify("📍 TP","Teleported to "..coords[1]..","..coords[2]..","..coords[3])
            else notify("⚠️ Input","Enter valid X,Y,Z coordinates") end
        end
    })

    TPTab:Button({ Title="Save Position", Callback=function()
        _G.SkyPos=LP.Character.HumanoidRootPart.CFrame
        notify("📍 Saved","Position saved!")
    end})

    TPTab:Button({ Title="Load Position", Callback=function()
        if _G.SkyPos then pcall(function() LP.Character.HumanoidRootPart.CFrame=_G.SkyPos end)
        else notify("⚠️","No saved position!") end
    end})

    TPTab:Button({ Title="🌍 Map Center (0,50,0)", Callback=function()
        pcall(function() LP.Character.HumanoidRootPart.CFrame=CFrame.new(0,50,0) end)
    end})

    TPTab:Button({ Title="🗺️ Random Location", Callback=function()
        pcall(function()
            local x,z=math.random(-500,500),math.random(-500,500)
            LP.Character.HumanoidRootPart.CFrame=CFrame.new(x,50,z)
            notify("🗺️ TP",string.format("Teleported to %.0f, 50, %.0f",x,z))
        end)
    end})

    TPTab:Dropdown({
        Title="Teleport to Player",
        Values=function()
            local names={}
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP then table.insert(names,p.Name) end
            end
            return names
        end,
        Callback=function(name)
            local target=Players:FindFirstChild(name)
            if target and target.Character then
                pcall(function()
                    LP.Character.HumanoidRootPart.CFrame=
                        target.Character.HumanoidRootPart.CFrame+Vector3.new(3,0,0)
                end)
                notify("📍 TP","Teleported to "..name)
            end
        end
    })

    ----------------------------------------------------
    -- TAB: GUI
    ----------------------------------------------------
    local GuiTab = Window:Tab({ Title="GUI", Icon="layout-dashboard" })

    GuiTab:Toggle({
        Title="Hide All GUIs", Desc="Toggle all PlayerGui ScreenGuis",
        Value=false,
        Callback=function(state)
            pcall(function()
                for _,g in ipairs(LP.PlayerGui:GetChildren()) do
                    if g:IsA("ScreenGui") and g.Name~="SkyMoon_Hub" then
                        g.Enabled=not state
                    end
                end
            end)
        end
    })

    GuiTab:Button({ Title="📋 List GUIs", Desc="Print GUI names to console", Callback=function()
        local names={}
        pcall(function()
            for _,g in ipairs(LP.PlayerGui:GetChildren()) do
                table.insert(names,g.Name.." ["..g.ClassName.."]")
            end
        end)
        notify("GUIs ("..(#names)..")", table.concat(names,", "):sub(1,120))
    end})

    GuiTab:Button({ Title="🗑️ Delete All GUIs", Desc="Removes all ScreenGuis (not SkyMoon)", Callback=function()
        pcall(function()
            for _,g in ipairs(LP.PlayerGui:GetChildren()) do
                if g:IsA("ScreenGui") and not g.Name:find("SkyMoon") then g:Destroy() end
            end
        end)
        notify("🗑️ Deleted","All non-SkyMoon GUIs removed!")
    end})

    ----------------------------------------------------
    -- TAB: SOUND
    ----------------------------------------------------
    local SoundTab = Window:Tab({ Title="Sound", Icon="music" })
    local customSoundObj = nil

    SoundTab:Toggle({
        Title="Mute All Sounds", Desc="Silences all sounds (local only)",
        Value=false,
        Callback=function(state)
            pcall(function()
                for _,s in ipairs(workspace:GetDescendants()) do
                    if s:IsA("Sound") then s.Volume=state and 0 or 1 end
                end
            end)
            notify(state and "🔇 Muted" or "🔊 Unmuted","All game sounds "..(state and "muted" or "restored").." (local only)")
        end
    })

    SoundTab:Slider({
        Title="Master Volume", Desc="Set volume for all workspace sounds",
        Step=0.05, Value={Min=0,Max=1,Default=1},
        Callback=function(v)
            pcall(function()
                for _,s in ipairs(workspace:GetDescendants()) do
                    if s:IsA("Sound") then s.Volume=v end
                end
            end)
        end
    })

    SoundTab:Divider()
    SoundTab:Section({ Title="Custom Song" })

    local songIdInput = SoundTab:Input({
        Title="Sound ID", Placeholder="Enter Sound ID (numbers only)...",
        Callback=function(_) end
    })

    SoundTab:Dropdown({
        Title="Play Location",
        Values={"Workspace","Camera","LocalPlayer"},
        Callback=function(choice)
            _G.SkySoundTarget=choice
        end
    })

    SoundTab:Button({
        Title="▶ Play Custom Song",
        Desc="Press after entering Sound ID and selecting location",
        Callback=function()
            local id=tostring(_G.SkySongId or "")
            if id=="" then notify("⚠️ No ID","Enter a Sound ID first!") return end
            if customSoundObj then
                pcall(function() customSoundObj:Stop() customSoundObj:Destroy() end)
                customSoundObj=nil
            end
            pcall(function()
                local s=Instance.new("Sound")
                s.SoundId="rbxassetid://"..id
                s.Volume=_G.SkySoundVol or 0.8
                s.Looped=true
                local target=workspace
                if _G.SkySoundTarget=="Camera" then target=workspace.CurrentCamera
                elseif _G.SkySoundTarget=="LocalPlayer" then target=LP end
                s.Parent=target
                s:Play()
                customSoundObj=s
                notify("🎵 Playing","Sound ID: "..id.." → "..(target.Name or "?"))
            end)
        end
    })

    -- We need the input to actually capture the ID via separate input:
    SoundTab:Input({
        Title="Set Song ID", Placeholder="Paste Sound ID here, press Enter",
        Callback=function(text)
            local id=text:match("%d+")
            if id then _G.SkySongId=id notify("🎵 ID Set","Sound ID: "..id) end
        end
    })

    SoundTab:Slider({
        Title="Song Volume", Step=0.05, Value={Min=0,Max=1,Default=0.8},
        Callback=function(v) _G.SkySoundVol=v
            if customSoundObj then pcall(function() customSoundObj.Volume=v end) end
        end
    })

    SoundTab:Button({ Title="⏸ Pause", Callback=function()
        if customSoundObj then pcall(function() customSoundObj:Pause() end)
        else notify("⚠️","No song playing!") end
    end})

    SoundTab:Button({ Title="▶ Resume", Callback=function()
        if customSoundObj then pcall(function() customSoundObj:Resume() end)
        else notify("⚠️","No song playing!") end
    end})

    SoundTab:Button({ Title="⏹ Stop", Callback=function()
        if customSoundObj then
            pcall(function() customSoundObj:Stop() customSoundObj:Destroy() end)
            customSoundObj=nil
            notify("⏹ Stopped","Custom song stopped.")
        else notify("⚠️","No song playing!") end
    end})

    SoundTab:Toggle({
        Title="Loop Song", Value=true,
        Callback=function(state)
            if customSoundObj then pcall(function() customSoundObj.Looped=state end) end
        end
    })

    SoundTab:Button({ Title="🎵 Play Ambient BG", Desc="SkyMoon ambient background sound", Callback=function()
        pcall(function()
            local s=Instance.new("Sound")
            s.SoundId="rbxassetid://139132289200391"
            s.Volume=0.4 s.Looped=true s.Parent=workspace s:Play()
            customSoundObj=s
            notify("🎵 Ambient","Background sound playing!")
        end)
    end})

    ----------------------------------------------------
    -- TAB: SETTINGS
    ----------------------------------------------------
    local SettingsTab = Window:Tab({ Title="Settings", Icon="settings" })

    SettingsTab:Paragraph({
        Title   = "About SkyMoon",
        Content = "Version: 3.0 (WindUI)\nAuthor: KHAFIDZKTP\nGitHub: github.com/HaZcK/ScriptHub\n\nSkyMoon Script Hub — all-in-one game executor with admin panel, Real Builder, and more.",
    })

    SettingsTab:Divider()

    SettingsTab:Toggle({
        Title="Show Notifications",
        Value=true,
        Callback=function(state) _G.SkyNotifs=state end
    })

    SettingsTab:Button({
        Title="🔄 Reset Memory",
        Desc="Clear SkyMoon local data",
        Callback=function()
            pcall(function()
                if isfolder("SkyMoon") and isfile("SkyMoon/memory.json") then
                    writefile("SkyMoon/memory.json",'{"log":[],"executeCount":0}')
                end
            end)
            notify("✅ Reset","SkyMoon memory cleared!")
        end
    })

    SettingsTab:Button({
        Title="📋 Copy PlaceId",
        Desc="Copy current game PlaceId",
        Callback=function()
            pcall(function() setclipboard(tostring(game.PlaceId)) end)
            notify("📋 Copied","PlaceId: "..game.PlaceId)
        end
    })

    -- Load tools in background
    task.spawn(function()
        local ok2, res = pcall(function() return game:HttpGet(ALL_TOOLS_URL) end)
        if ok2 and res and res~="" then
            local fn, _ = loadstring(res)
            if fn then pcall(fn) end
        end
    end)

    notify("🌙 SkyMoon","Script Hub loaded! Click ⟳ Scan Game to start.")
end

----------------------------------------------------
-- STARTUP
----------------------------------------------------
WindUI = nil
Window = nil

task.spawn(function()
    runLoadingSequence(function()
        task.wait(0.1)
        startWindUI()
    end)
end)
