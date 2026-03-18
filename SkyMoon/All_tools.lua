-- 🌙 SkyMoon All_tools.lua
-- by KHAFIDZKTP | github.com/HaZcK/ScriptHub
-- Provides: Help Tool + Custom Backpack UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

----------------------------------------------------
-- LANGUAGE SYSTEM (English / Indonesian)
----------------------------------------------------
local lang = "EN" -- default English

local STRINGS = {
    EN = {
        help_title      = "🌙 SkyMoon Help",
        help_subtitle   = "Commands & Features Guide",
        tab_commands    = "Commands",
        tab_admin       = "Admin Panel",
        tab_builder     = "Real Builder",
        tab_tips        = "Tips",
        close           = "✕ Close",
        lang_toggle     = "🇮🇩 Bahasa",
        backpack_title  = "🎒 Backpack",
        backpack_empty  = "Backpack is empty.",
        equip           = "Equip",
        drop            = "Drop",
        holding         = "Holding: ",
        none            = "None",
        -- Commands list
        cmd_open_cmd    = "/Open_Cmd  —  Open mini terminal",
        cmd_open_admin  = "/Open_Admin  —  Open admin panel (key required)",
        cmd_console     = "/console  —  Open live output console",
        cmd_reset       = "/Reset_Skymoon  —  Reset local memory/data",
        cmd_checkin     = "Check In [Service, Folder, Name]  —  Deep path scan",
        cmd_runconsole  = "RunConsole  —  Open console (in mini CMD)",
        -- Admin panel
        admin_players   = "Players Tab  —  NoClip, InfJump, God Mode, Save/Load pos, Nametag, Skins...",
        admin_move      = "Move Tab  —  WalkSpeed, JumpPower, Fly, Dash, Gravity, Ice physics...",
        admin_build     = "Build Tab  —  Spawn parts, Weld, Resize, Rotate, Real Builder...",
        admin_tp        = "TP Tab  —  Teleport XYZ, to player, random, grid snap, orbit...",
        admin_gui       = "GUI Tab  —  List/Show/Hide/Delete GUIs, rainbow bg, lock...",
        admin_sound     = "Sound Tab  —  Mute/Unmute, Custom Song ID, Volume, Play/Pause/Stop...",
        -- Builder
        builder_cam     = "Camera  —  Hold RMB + drag to look | WASD/QE to move | Shift = fast",
        builder_select  = "Select  —  Click any part in viewport to select it",
        builder_move    = "Move  —  Grab red/green/blue arrow handles to move part",
        builder_scale   = "Scale  —  Grab colored sphere handles to resize",
        builder_rotate  = "Rotate  —  Drag on part OR Numpad 1/3",
        builder_insert  = "Insert  —  Click ⊕ Insert button | Long-press folder in Explorer",
        builder_rename  = "Rename  —  Double-click any object in Explorer",
        builder_coder   = "CoderScript  —  Select a Script/LocalScript → Properties → 📝 Insert Inside",
        builder_cut     = "Cut/Paste  —  Click ✂ Cut then select target → 📋 Paste",
        builder_play    = "Play/Stop  —  ▶ Play enables physics | ■ Stop freezes all parts",
        -- Tips
        tip1 = "💡 Key resets every day at 00:00 UTC.",
        tip2 = "💡 Use /Open_Cmd to run deep workspace scan commands.",
        tip3 = "💡 Real Builder freezes all parts — click ▶ Play for physics.",
        tip4 = "💡 Custom Song: paste Sound ID in Sound tab → choose where to play.",
        tip5 = "💡 Long-press a folder in Explorer to insert objects inside it.",
        tip6 = "💡 Double-click any Explorer item to rename it.",
    },
    ID = {
        help_title      = "🌙 Bantuan SkyMoon",
        help_subtitle   = "Panduan Perintah & Fitur",
        tab_commands    = "Perintah",
        tab_admin       = "Admin Panel",
        tab_builder     = "Real Builder",
        tab_tips        = "Tips",
        close           = "✕ Tutup",
        lang_toggle     = "🇬🇧 English",
        backpack_title  = "🎒 Ransel",
        backpack_empty  = "Ransel kosong.",
        equip           = "Pakai",
        drop            = "Lempar",
        holding         = "Dipegang: ",
        none            = "Kosong",
        cmd_open_cmd    = "/Open_Cmd  —  Buka terminal mini",
        cmd_open_admin  = "/Open_Admin  —  Buka panel admin (butuh key)",
        cmd_console     = "/console  —  Buka konsol output langsung",
        cmd_reset       = "/Reset_Skymoon  —  Reset memori/data lokal",
        cmd_checkin     = "Check In [Service, Folder, Nama]  —  Scan jalur mendalam",
        cmd_runconsole  = "RunConsole  —  Buka konsol (di mini CMD)",
        admin_players   = "Tab Players  —  NoClip, InfJump, God Mode, Simpan/Muat posisi, Nametag, Skin...",
        admin_move      = "Tab Move  —  WalkSpeed, JumpPower, Terbang, Dash, Gravitasi, Fisika es...",
        admin_build     = "Tab Build  —  Spawn part, Weld, Resize, Putar, Real Builder...",
        admin_tp        = "Tab TP  —  Teleport XYZ, ke pemain, acak, snap grid, orbit...",
        admin_gui       = "Tab GUI  —  Daftar/Tampil/Sembunyikan/Hapus GUI, pelangi, kunci...",
        admin_sound     = "Tab Sound  —  Bisu/Nyalakan, Lagu Kustom ID, Volume, Putar/Jeda/Berhenti...",
        builder_cam     = "Kamera  —  Tahan RMB + geser untuk melihat | WASD/QE bergerak | Shift = cepat",
        builder_select  = "Pilih  —  Klik part mana saja di viewport untuk memilihnya",
        builder_move    = "Pindah  —  Pegang gagang panah merah/hijau/biru untuk memindah part",
        builder_scale   = "Skala  —  Pegang gagang bola berwarna untuk mengubah ukuran",
        builder_rotate  = "Putar  —  Seret di part ATAU Numpad 1/3",
        builder_insert  = "Masukkan  —  Klik tombol ⊕ Insert | Tahan folder di Explorer",
        builder_rename  = "Ganti Nama  —  Klik dua kali objek di Explorer",
        builder_coder   = "CoderScript  —  Pilih Script/LocalScript → Properties → 📝 Insert Inside",
        builder_cut     = "Potong/Tempel  —  Klik ✂ Potong lalu pilih target → 📋 Tempel",
        builder_play    = "Main/Berhenti  —  ▶ Play aktifkan fisika | ■ Stop bekukan semua part",
        tip1 = "💡 Key diperbarui setiap hari pukul 00:00 UTC.",
        tip2 = "💡 Gunakan /Open_Cmd untuk menjalankan perintah scan workspace mendalam.",
        tip3 = "💡 Real Builder membekukan semua part — klik ▶ Play untuk fisika.",
        tip4 = "💡 Lagu Kustom: tempelkan Sound ID di tab Sound → pilih tempat memutar.",
        tip5 = "💡 Tahan folder di Explorer untuk memasukkan objek ke dalamnya.",
        tip6 = "💡 Klik dua kali item Explorer untuk mengganti namanya.",
    }
}

local function S(key)
    return STRINGS[lang][key] or STRINGS["EN"][key] or key
end

----------------------------------------------------
-- HELPERS
----------------------------------------------------
local function mkCorner(r, p)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r)
end
local function mkStroke(col, t, p)
    local s = Instance.new("UIStroke", p)
    s.Color = col s.Thickness = t
end
local function mkLabel(parent, text, size, pos, fs, col, xa)
    local l = Instance.new("TextLabel", parent)
    l.Size = size l.Position = pos or UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1 l.Text = text
    l.Font = Enum.Font.Gotham l.TextSize = fs or 11
    l.TextColor3 = col or Color3.fromRGB(220,220,220)
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.TextWrapped = true
    return l
end
local function mkBtn(parent, text, size, pos, bg, tc)
    local b = Instance.new("TextButton", parent)
    b.Size = size b.Position = pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = bg or Color3.fromRGB(30,30,40)
    b.Text = text b.TextColor3 = tc or Color3.fromRGB(220,220,220)
    b.Font = Enum.Font.GothamBold b.TextSize = 11
    b.BorderSizePixel = 0 b.AutoButtonColor = false
    mkCorner(6, b)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60,60,100)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = bg or Color3.fromRGB(30,30,40)}):Play()
    end)
    return b
end

----------------------------------------------------
-- HELP GUI
----------------------------------------------------
local helpOpen = false
local helpSg = nil

local function openHelpGui()
    if helpOpen then return end
    helpOpen = true

    helpSg = Instance.new("ScreenGui")
    helpSg.Name = "SkyMoon_Help"
    helpSg.ResetOnSpawn = false
    helpSg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    helpSg.DisplayOrder = 200
    pcall(function() helpSg.Parent = game:GetService("CoreGui") end)
    if not helpSg.Parent then helpSg.Parent = LP.PlayerGui end

    -- Main window
    local win = Instance.new("Frame", helpSg)
    win.Size = UDim2.new(0, 480, 0, 440)
    win.Position = UDim2.new(0.5, -240, 0.5, -220)
    win.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    mkCorner(14, win)
    mkStroke(Color3.fromRGB(80, 60, 200), 1.5, win)

    local grad = Instance.new("UIGradient", win)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,  Color3.fromRGB(20, 16, 38)),
        ColorSequenceKeypoint.new(1,  Color3.fromRGB(8,  10, 22)),
    })
    grad.Rotation = 140

    -- Accent top line
    local topLine = Instance.new("Frame", win)
    topLine.Size = UDim2.new(0.65, 0, 0, 2)
    topLine.Position = UDim2.new(0.175, 0, 0, 0)
    topLine.BackgroundColor3 = Color3.fromRGB(100, 70, 255)
    topLine.BorderSizePixel = 0
    local tg = Instance.new("UIGradient", topLine)
    tg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,  Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(120,80,255)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(0,200,180)),
        ColorSequenceKeypoint.new(1,  Color3.fromRGB(0,0,0)),
    })

    -- Header
    local header = Instance.new("Frame", win)
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size = UDim2.new(1, -130, 1, 0)
    titleLbl.Position = UDim2.new(0, 16, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 16
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    local tg2 = Instance.new("UIGradient", titleLbl)
    tg2.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80,  220, 200)),
    })

    local subtitleLbl = Instance.new("TextLabel", header)
    subtitleLbl.Size = UDim2.new(1, -130, 0, 16)
    subtitleLbl.Position = UDim2.new(0, 16, 0, 28)
    subtitleLbl.BackgroundTransparency = 1
    subtitleLbl.Font = Enum.Font.Code
    subtitleLbl.TextSize = 9
    subtitleLbl.TextColor3 = Color3.fromRGB(60, 50, 100)
    subtitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Lang toggle button
    local langBtn = mkBtn(header, "", UDim2.new(0, 72, 0, 24),
        UDim2.new(1, -138, 0, 12),
        Color3.fromRGB(30, 24, 60), Color3.fromRGB(180, 160, 255))
    langBtn.TextSize = 10

    -- Close button
    local closeBtn = mkBtn(header, "✕", UDim2.new(0, 28, 0, 28),
        UDim2.new(1, -36, 0, 10),
        Color3.fromRGB(160, 30, 50), Color3.new(1,1,1))

    closeBtn.MouseButton1Click:Connect(function()
        helpOpen = false
        helpSg:Destroy()
    end)

    -- Divider
    local div = Instance.new("Frame", win)
    div.Size = UDim2.new(1, -32, 0, 1)
    div.Position = UDim2.new(0, 16, 0, 50)
    div.BackgroundColor3 = Color3.fromRGB(50, 40, 100)
    div.BorderSizePixel = 0

    -- Tab bar
    local tabBar = Instance.new("Frame", win)
    tabBar.Size = UDim2.new(1, -32, 0, 32)
    tabBar.Position = UDim2.new(0, 16, 0, 54)
    tabBar.BackgroundTransparency = 1
    tabBar.BorderSizePixel = 0
    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 6)

    -- Content scroll
    local contentScroll = Instance.new("ScrollingFrame", win)
    contentScroll.Size = UDim2.new(1, -32, 1, -98)
    contentScroll.Position = UDim2.new(0, 16, 0, 90)
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel = 0
    contentScroll.ScrollBarThickness = 3
    contentScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 60, 200)
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UIListLayout", contentScroll).Padding = UDim.new(0, 4)

    -- Content data per tab
    local TABS = {
        {key = "tab_commands", items = {
            {type="section", text="Chat Commands"},
            {type="item",    key="cmd_open_cmd"},
            {type="item",    key="cmd_open_admin"},
            {type="item",    key="cmd_console"},
            {type="item",    key="cmd_reset"},
            {type="section", text="Mini CMD Terminal"},
            {type="item",    key="cmd_checkin"},
            {type="item",    key="cmd_runconsole"},
        }},
        {key = "tab_admin", items = {
            {type="section", text="Admin Panel Tabs"},
            {type="item",    key="admin_players"},
            {type="item",    key="admin_move"},
            {type="item",    key="admin_build"},
            {type="item",    key="admin_tp"},
            {type="item",    key="admin_gui"},
            {type="item",    key="admin_sound"},
        }},
        {key = "tab_builder", items = {
            {type="section", text="Camera & Navigation"},
            {type="item",    key="builder_cam"},
            {type="section", text="Tools"},
            {type="item",    key="builder_select"},
            {type="item",    key="builder_move"},
            {type="item",    key="builder_scale"},
            {type="item",    key="builder_rotate"},
            {type="section", text="Workflow"},
            {type="item",    key="builder_insert"},
            {type="item",    key="builder_rename"},
            {type="item",    key="builder_coder"},
            {type="item",    key="builder_cut"},
            {type="item",    key="builder_play"},
        }},
        {key = "tab_tips", items = {
            {type="section", text="Tips & Tricks"},
            {type="item",    key="tip1"},
            {type="item",    key="tip2"},
            {type="item",    key="tip3"},
            {type="item",    key="tip4"},
            {type="item",    key="tip5"},
            {type="item",    key="tip6"},
        }},
    }

    local activeTabIdx = 1
    local tabBtns = {}

    local function buildContent(tabIdx)
        for _, c in ipairs(contentScroll:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
        end
        contentScroll.CanvasPosition = Vector2.new(0, 0)
        local tab = TABS[tabIdx]
        for _, item in ipairs(tab.items) do
            if item.type == "section" then
                local row = Instance.new("Frame", contentScroll)
                row.Size = UDim2.new(1, 0, 0, 22)
                row.BackgroundColor3 = Color3.fromRGB(20, 16, 40)
                row.BorderSizePixel = 0
                mkCorner(4, row)
                mkLabel(row, "  " .. item.text, UDim2.new(1, 0, 1, 0), nil, 10,
                    Color3.fromRGB(120, 100, 220))
            elseif item.type == "item" then
                local row = Instance.new("Frame", contentScroll)
                row.Size = UDim2.new(1, 0, 0, 36)
                row.BackgroundColor3 = Color3.fromRGB(12, 10, 24)
                row.BorderSizePixel = 0
                mkCorner(6, row)

                -- Left accent bar
                local bar = Instance.new("Frame", row)
                bar.Size = UDim2.new(0, 2, 0.6, 0)
                bar.Position = UDim2.new(0, 0, 0.2, 0)
                bar.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
                bar.BorderSizePixel = 0

                mkLabel(row, S(item.key), UDim2.new(1, -12, 1, 0),
                    UDim2.new(0, 10, 0, 0), 11,
                    Color3.fromRGB(180, 170, 220))
            end
        end
    end

    local function setTab(idx)
        activeTabIdx = idx
        for i, tb in ipairs(tabBtns) do
            if i == idx then
                tb.BackgroundColor3 = Color3.fromRGB(60, 40, 140)
                tb.TextColor3 = Color3.fromRGB(220, 200, 255)
            else
                tb.BackgroundColor3 = Color3.fromRGB(20, 16, 40)
                tb.TextColor3 = Color3.fromRGB(80, 70, 120)
            end
        end
        buildContent(idx)
    end

    local function rebuildAll()
        -- Rebuild tab labels
        for _, tb in ipairs(tabBtns) do tb.Text = S(TABS[tabBtns[table.find(tabBtns, tb) or 1].tag or "tab_commands"]) end
        -- Rebuild title
        titleLbl.Text    = S("help_title")
        subtitleLbl.Text = S("help_subtitle")
        closeBtn.Text    = "✕"
        langBtn.Text     = S("lang_toggle")
        buildContent(activeTabIdx)
    end

    -- Build tab buttons
    for i, tab in ipairs(TABS) do
        local tb = mkBtn(tabBar, S(tab.key), UDim2.new(0, 100, 1, 0), nil,
            Color3.fromRGB(20, 16, 40),
            Color3.fromRGB(80, 70, 120))
        tb.TextSize = 10
        tb.tag = tab.key
        tb.MouseButton1Click:Connect(function() setTab(i) end)
        table.insert(tabBtns, tb)
    end

    titleLbl.Text    = S("help_title")
    subtitleLbl.Text = S("help_subtitle")
    langBtn.Text     = S("lang_toggle")

    langBtn.MouseButton1Click:Connect(function()
        lang = (lang == "EN") and "ID" or "EN"
        titleLbl.Text    = S("help_title")
        subtitleLbl.Text = S("help_subtitle")
        langBtn.Text     = S("lang_toggle")
        for i, tb in ipairs(tabBtns) do
            tb.Text = S(TABS[i].key)
        end
        buildContent(activeTabIdx)
    end)

    setTab(1)
end

----------------------------------------------------
-- CUSTOM BACKPACK GUI
----------------------------------------------------
local backpackOpen = false
local backpackSg   = nil

local function openBackpackGui()
    if backpackOpen then return end
    backpackOpen = true

    backpackSg = Instance.new("ScreenGui")
    backpackSg.Name = "SkyMoon_Backpack"
    backpackSg.ResetOnSpawn = false
    backpackSg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    backpackSg.DisplayOrder = 150
    pcall(function() backpackSg.Parent = game:GetService("CoreGui") end)
    if not backpackSg.Parent then backpackSg.Parent = LP.PlayerGui end

    local win = Instance.new("Frame", backpackSg)
    win.Size = UDim2.new(0, 360, 0, 180)
    win.Position = UDim2.new(0.5, -180, 1, -196)
    win.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
    win.BorderSizePixel = 0
    win.Active = true
    win.Draggable = true
    mkCorner(12, win)
    mkStroke(Color3.fromRGB(60, 50, 150), 1.5, win)

    local winGrad = Instance.new("UIGradient", win)
    winGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 14, 36)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 18)),
    })
    winGrad.Rotation = 135

    -- Title bar
    local tbar = Instance.new("Frame", win)
    tbar.Size = UDim2.new(1, 0, 0, 32)
    tbar.BackgroundTransparency = 1
    tbar.BorderSizePixel = 0

    local titleL = mkLabel(tbar, S("backpack_title"),
        UDim2.new(1, -50, 1, 0), UDim2.new(0, 12, 0, 0),
        13, Color3.fromRGB(180, 160, 255))
    titleL.Font = Enum.Font.GothamBold

    local holdL = mkLabel(tbar, S("holding") .. S("none"),
        UDim2.new(0, 160, 1, 0), UDim2.new(0.5, -80, 0, 0),
        10, Color3.fromRGB(80, 70, 120), Enum.TextXAlignment.Center)

    local closeB = mkBtn(tbar, "✕", UDim2.new(0, 26, 0, 26),
        UDim2.new(1, -30, 0, 3),
        Color3.fromRGB(140, 25, 45), Color3.new(1,1,1))
    closeB.MouseButton1Click:Connect(function()
        backpackOpen = false
        backpackSg:Destroy()
    end)

    -- Divider
    local dv = Instance.new("Frame", win)
    dv.Size = UDim2.new(1, -24, 0, 1)
    dv.Position = UDim2.new(0, 12, 0, 34)
    dv.BackgroundColor3 = Color3.fromRGB(40, 30, 90)
    dv.BorderSizePixel = 0

    -- Tool slots container
    local slotsFrame = Instance.new("ScrollingFrame", win)
    slotsFrame.Size = UDim2.new(1, -24, 1, -44)
    slotsFrame.Position = UDim2.new(0, 12, 0, 40)
    slotsFrame.BackgroundTransparency = 1
    slotsFrame.BorderSizePixel = 0
    slotsFrame.ScrollBarThickness = 3
    slotsFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 60, 200)
    slotsFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
    slotsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    slotsFrame.ScrollingDirection = Enum.ScrollingDirection.X

    local slotLayout = Instance.new("UIListLayout", slotsFrame)
    slotLayout.FillDirection = Enum.FillDirection.Horizontal
    slotLayout.Padding = UDim.new(0, 6)
    slotLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local emptyL = mkLabel(slotsFrame, S("backpack_empty"),
        UDim2.new(0, 300, 1, 0), nil,
        11, Color3.fromRGB(60, 50, 100), Enum.TextXAlignment.Left)

    -- Refresh slots
    local function refreshSlots()
        for _, c in ipairs(slotsFrame:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
        end

        local backpack = LP:FindFirstChild("Backpack")
        local char = LP.Character
        local tools = {}

        if backpack then
            for _, t in ipairs(backpack:GetChildren()) do
                if t:IsA("Tool") then table.insert(tools, {tool=t, equipped=false}) end
            end
        end
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then table.insert(tools, {tool=t, equipped=true}) end
            end
        end

        if #tools == 0 then
            mkLabel(slotsFrame, S("backpack_empty"),
                UDim2.new(0, 300, 1, 0), nil,
                11, Color3.fromRGB(60, 50, 100), Enum.TextXAlignment.Left)
            holdL.Text = S("holding") .. S("none")
            return
        end

        -- Update holding label
        local holding = S("none")
        for _, entry in ipairs(tools) do
            if entry.equipped then holding = entry.tool.Name end
        end
        holdL.Text = S("holding") .. holding

        for _, entry in ipairs(tools) do
            local t = entry.tool
            local slot = Instance.new("Frame", slotsFrame)
            slot.Size = UDim2.new(0, 100, 0, 120)
            slot.BackgroundColor3 = entry.equipped
                and Color3.fromRGB(30, 20, 70)
                or  Color3.fromRGB(14, 12, 28)
            slot.BorderSizePixel = 0
            mkCorner(8, slot)
            if entry.equipped then
                mkStroke(Color3.fromRGB(100, 80, 255), 1.5, slot)
            else
                mkStroke(Color3.fromRGB(40, 35, 80), 1, slot)
            end

            -- Tool icon (text emoji fallback)
            local iconFrame = Instance.new("Frame", slot)
            iconFrame.Size = UDim2.new(1, -16, 0, 56)
            iconFrame.Position = UDim2.new(0, 8, 0, 8)
            iconFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 44)
            iconFrame.BorderSizePixel = 0
            mkCorner(6, iconFrame)

            local iconLbl = Instance.new("TextLabel", iconFrame)
            iconLbl.Size = UDim2.new(1, 0, 1, 0)
            iconLbl.BackgroundTransparency = 1
            iconLbl.Text = "🔧"
            iconLbl.Font = Enum.Font.GothamBold
            iconLbl.TextSize = 26
            -- Try to get tool texture
            pcall(function()
                local handle = t:FindFirstChildWhichIsA("BasePart", true)
                if handle then iconLbl.Text = "🗡️" end
                local mesh = t:FindFirstChildWhichIsA("SpecialMesh", true)
                if mesh then iconLbl.Text = "⚙️" end
            end)

            if entry.equipped then
                local eqDot = Instance.new("Frame", iconFrame)
                eqDot.Size = UDim2.new(0, 8, 0, 8)
                eqDot.Position = UDim2.new(1, -10, 0, 2)
                eqDot.BackgroundColor3 = Color3.fromRGB(0, 220, 120)
                eqDot.BorderSizePixel = 0
                mkCorner(4, eqDot)
            end

            -- Tool name
            mkLabel(slot, t.Name,
                UDim2.new(1, -8, 0, 24), UDim2.new(0, 4, 0, 68),
                10, Color3.fromRGB(180, 170, 220), Enum.TextXAlignment.Center)

            -- Equip/Drop button
            local actionBtn = mkBtn(slot,
                entry.equipped and S("drop") or S("equip"),
                UDim2.new(1, -8, 0, 20), UDim2.new(0, 4, 1, -24),
                entry.equipped
                    and Color3.fromRGB(140, 30, 50)
                    or  Color3.fromRGB(40, 60, 140),
                Color3.new(1, 1, 1))
            actionBtn.TextSize = 10

            actionBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    if entry.equipped then
                        -- Unequip → move to backpack
                        local bp = LP:FindFirstChild("Backpack")
                        if bp then t.Parent = bp end
                    else
                        -- Equip → move to character
                        local char2 = LP.Character
                        if char2 then t.Parent = char2 end
                    end
                end)
                task.wait(0.1)
                refreshSlots()
            end)
        end
    end

    refreshSlots()

    -- Auto-refresh every 1.5s
    task.spawn(function()
        while backpackSg and backpackSg.Parent do
            task.wait(1.5)
            pcall(refreshSlots)
        end
    end)
end

----------------------------------------------------
-- HELP TOOL MODEL CREATION
----------------------------------------------------
local function createHelpTool()
    local tool = Instance.new("Tool")
    tool.Name = "Help"
    tool.ToolTip = "SkyMoon Help & Commands Guide"
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    -- Handle (small glowing cube)
    local handle = Instance.new("Part", tool)
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.8, 0.8, 0.8)
    handle.BrickColor = BrickColor.new("Bright violet")
    handle.Material = Enum.Material.Neon
    handle.CanCollide = false
    handle.CastShadow = false

    -- Question mark billboard
    local billboard = Instance.new("BillboardGui", handle)
    billboard.Size = UDim2.new(0, 40, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 1, 0)
    billboard.AlwaysOnTop = true

    local qLabel = Instance.new("TextLabel", billboard)
    qLabel.Size = UDim2.new(1, 0, 1, 0)
    qLabel.BackgroundTransparency = 1
    qLabel.Text = "?"
    qLabel.Font = Enum.Font.GothamBold
    qLabel.TextSize = 28
    qLabel.TextColor3 = Color3.fromRGB(180, 150, 255)

    -- Activate = open help
    tool.Activated:Connect(function()
        openHelpGui()
    end)

    return tool
end

----------------------------------------------------
-- CUSTOM BACKPACK TOOL MODEL CREATION
----------------------------------------------------
local function createBackpackTool()
    local tool = Instance.new("Tool")
    tool.Name = "Backpack"
    tool.ToolTip = "Open SkyMoon Custom Backpack"
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local handle = Instance.new("Part", tool)
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1.2, 0.6)
    handle.BrickColor = BrickColor.new("Dark orange")
    handle.Material = Enum.Material.SmoothPlastic
    handle.CanCollide = false

    local billboard = Instance.new("BillboardGui", handle)
    billboard.Size = UDim2.new(0, 40, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 1.2, 0)
    billboard.AlwaysOnTop = true

    local bLabel = Instance.new("TextLabel", billboard)
    bLabel.Size = UDim2.new(1, 0, 1, 0)
    bLabel.BackgroundTransparency = 1
    bLabel.Text = "🎒"
    bLabel.Font = Enum.Font.GothamBold
    bLabel.TextSize = 22

    tool.Activated:Connect(function()
        openBackpackGui()
    end)

    return tool
end

----------------------------------------------------
-- DEPLOY TOOLS TO PLAYER
----------------------------------------------------
local function deployTools()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local backpack = LP:WaitForChild("Backpack", 5)

    -- Always give Help tool
    local helpTool = createHelpTool()
    helpTool.Parent = backpack or char

    -- Check if default backpack is accessible
    local hasBackpackAccess = false
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        if pg then
            -- Check if Roblox BackpackGui exists
            local bg = pg:FindFirstChild("BackpackGui")
            if bg and bg:IsA("ScreenGui") then
                hasBackpackAccess = true
            end
        end
    end)

    -- Give custom backpack tool if no backpack GUI
    if not hasBackpackAccess then
        local bpTool = createBackpackTool()
        bpTool.Parent = backpack or char
    end
end

----------------------------------------------------
-- INIT
----------------------------------------------------
-- Deploy on load
task.spawn(function()
    task.wait(1)
    deployTools()
end)

-- Re-deploy on character respawn
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    deployTools()
end)

-- Keyboard shortcut: F1 = Help, F2 = Backpack
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.F1 then
        openHelpGui()
    elseif inp.KeyCode == Enum.KeyCode.F2 then
        openBackpackGui()
    end
end)

print("[SkyMoon] All_tools.lua loaded — Help tool (F1) + Backpack (F2)")
