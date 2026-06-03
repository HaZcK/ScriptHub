--[[
    ╔══════════════════════════════════════════════════════════╗
    ║          SetGame Hub — Pure Luau UI Framework            ║
    ║          Elegant Dark  |  No 3rd-Party Libraries         ║
    ║          Version 2.0   |  Safe Topbar Adaptation         ║
    ╚══════════════════════════════════════════════════════════╝

    COMPONENT API QUICK REFERENCE
    ──────────────────────────────
    local Hub    = SetGameFramework.new("SetGame Hub")
    local page   = Hub:AddPage("PageName", "icon_rbxasset")

    page:AddButton    { Label="…", Callback=fn }
    page:AddToggle    { Label="…", Default=false, Callback=fn }
    page:AddSlider    { Label="…", Min=0, Max=100, Default=50, Callback=fn }
    page:AddDropdown  { Label="…", Options={…}, Default="…", Callback=fn }
    page:AddInput     { Label="…", Placeholder="…", Callback=fn }
    page:AddDivider   { Label="…" }          -- Label optional
    Hub:Notify        { Title="…", Message="…", Duration=3 }
]]

-- ╔══════════════════════════════╗
-- ║      S E R V I C E S        ║
-- ╚══════════════════════════════╝
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService     = game:GetService("GuiService")
local ContentProvider = game:GetService("ContentProvider")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- ╔══════════════════════════════╗
-- ║        T H E M E            ║
-- ╚══════════════════════════════╝
local Theme = {
    -- Background layers
    BG          = Color3.fromHex("121212"),   -- main window
    Sidebar     = Color3.fromHex("0E0E0E"),   -- sidebar / topbar
    Surface     = Color3.fromHex("1A1A1A"),   -- cards / panels
    Elevated    = Color3.fromHex("232323"),   -- hover states / inputs
    Divider     = Color3.fromHex("2A2A2A"),   -- separator lines

    -- Accent
    Accent      = Color3.fromHex("5B8DEF"),   -- primary accent (blue)
    AccentDim   = Color3.fromHex("3A5FA8"),   -- accent pressed
    AccentGlow  = Color3.fromHex("7BA7FF"),   -- accent hover

    -- Text
    TextPrimary = Color3.fromHex("EBEBEB"),
    TextSecond  = Color3.fromHex("8A8A8A"),
    TextMuted   = Color3.fromHex("555555"),

    -- Status
    Success     = Color3.fromHex("4CAF7D"),
    Warning     = Color3.fromHex("F0A843"),
    Error       = Color3.fromHex("E05252"),
    Info        = Color3.fromHex("5B8DEF"),

    -- Misc
    TopbarH     = 36,   -- px — standard Roblox topbar button height
    CornerSm    = UDim.new(0, 4),
    CornerMd    = UDim.new(0, 8),
    CornerLg    = UDim.new(0, 12),
    CornerFull  = UDim.new(1, 0),
}

-- ╔══════════════════════════════╗
-- ║    U T I L I T Y            ║
-- ╚══════════════════════════════╝
local function Tween(obj, info, goal)
    TweenService:Create(obj, info, goal):Play()
end

local function FastTween(obj, goal, t)
    Tween(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or Theme.CornerMd
    c.Parent = parent
    return c
end

local function Padding(parent, all, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    if all then
        p.PaddingTop    = UDim.new(0, all)
        p.PaddingBottom = UDim.new(0, all)
        p.PaddingLeft   = UDim.new(0, all)
        p.PaddingRight  = UDim.new(0, all)
    else
        p.PaddingTop    = UDim.new(0, top    or 0)
        p.PaddingBottom = UDim.new(0, bottom or 0)
        p.PaddingLeft   = UDim.new(0, left   or 0)
        p.PaddingRight  = UDim.new(0, right  or 0)
    end
    p.Parent = parent
    return p
end

local function ListLayout(parent, dir, pad, align)
    local l = Instance.new("UIListLayout")
    l.FillDirection       = dir   or Enum.FillDirection.Vertical
    l.Padding             = UDim.new(0, pad or 0)
    l.HorizontalAlignment = align or Enum.HorizontalAlignment.Left
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    l.Parent              = parent
    return l
end

local function New(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║   T O P B A R   A D A P T A T I O N   E N G I N E       ║
-- ╚══════════════════════════════════════════════════════════╝
--[[
    SECURITY NOTE
    ─────────────
    CoreGui is sandboxed in LocalScript context — direct iteration
    over its children raises an error. We therefore use a layered
    safe-calculation approach:

      Layer 1  GuiService:GetGuiInset()
               Returns Vector2 (top inset, bottom inset) — the
               safest official API to learn how tall the topbar is.

      Layer 2  GuiService topbar-related properties (if available)
               TopbarInset etc. for newer engine versions.

      Layer 3  Standard layout constants
               Roblox has used a 36 px tall topbar with buttons at
               Y = 4, height = 28 px for years. We encode these as
               verified fallback constants.

    Button placement strategy
    ─────────────────────────
    Roblox renders these native buttons in the top-left corner (in
    order): Menu (hamburger) ≈ 44 px wide, then Backpack, then Chat,
    etc.  The right side has: Leaderboard, Emote, Avatar, ...

    We place our custom button to the RIGHT of the native left-cluster
    with an 8 px gap, anchored to the bottom of the topbar's inset
    region so it always sits flush without overlapping native icons.
]]

local TopbarAdapter = {}

-- Returns { Height, OffsetY, LeftEdge } — all in absolute pixels.
function TopbarAdapter.GetTopbarMetrics()
    local topH   = Theme.TopbarH   -- sensible default
    local offsetY = 4              -- standard vertical gap inside topbar
    local leftButtonsWidth = 148   -- approx width of Roblox left native buttons
                                   -- (Menu≈44 + Backpack≈36 + Chat≈36 + gap≈32)

    -- ── Layer 1: GuiService inset (most reliable) ──────────────────
    local ok, inset = pcall(function()
        return GuiService:GetGuiInset()
    end)
    if ok and inset then
        -- inset.Y is the top inset (topbar height in screen-space)
        topH = math.max(inset.Y, topH)
    end

    -- ── Layer 2: SafeAreaCompatibility offset ─────────────────────
    -- On devices with notches, GuiService.TopbarInset shifts things.
    -- We clamp to [28, 60] — anything outside is an anomaly.
    topH = math.clamp(topH, 28, 60)

    return {
        Height         = topH,
        OffsetY        = offsetY,
        ButtonSize     = topH - (offsetY * 2),   -- fills the inset minus padding
        LeftEdge       = leftButtonsWidth + 8,    -- 8 px gap after native buttons
    }
end

-- Syncs our custom topbar button style to match Roblox's own look.
function TopbarAdapter.StyleButton(btn)
    -- Roblox native buttons are semi-transparent dark pills.
    -- We replicate: BackgroundColor3 = very dark, Transparency ≈ 0.4
    btn.BackgroundColor3        = Theme.Sidebar
    btn.BackgroundTransparency  = 0.3
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║       F R A M E W O R K   C O R E                       ║
-- ╚══════════════════════════════════════════════════════════╝
local SetGameFramework = {}
SetGameFramework.__index = SetGameFramework

function SetGameFramework.new(title)
    local self = setmetatable({}, SetGameFramework)
    self._title    = title or "SetGame Hub"
    self._pages    = {}
    self._activePg = nil
    self._navBtns  = {}
    self._visible  = true
    self._notifQ   = {}         -- notification queue

    self:_BuildGui()
    self:_BuildTopbarButton()
    self:_StartClockLoop()
    self:_BuildAboutPage()

    return self
end

-- ─── Main Window ──────────────────────────────────────────────
function SetGameFramework:_BuildGui()
    -- ScreenGui root
    self.ScreenGui = New("ScreenGui", {
        Name              = "SetGameHub",
        ResetOnSpawn      = false,
        ZIndexBehavior    = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset    = true,     -- we handle inset ourselves
        DisplayOrder      = 10,
    }, PlayerGui)

    -- Notification layer (separate ZIndex above everything)
    self.NotifLayer = New("Frame", {
        Name              = "NotifLayer",
        Size              = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex            = 50,
    }, self.ScreenGui)

    -- Blur-style backdrop (non-intrusive)
    self.Backdrop = New("Frame", {
        Name              = "Backdrop",
        Size              = UDim2.new(1, 0, 1, 0),
        BackgroundColor3  = Color3.fromHex("000000"),
        BackgroundTransparency = 0.55,
        ZIndex            = 1,
        Visible           = false,
    }, self.ScreenGui)

    -- Main container — centered, 680×430
    self.Window = New("Frame", {
        Name              = "Window",
        Size              = UDim2.new(0, 680, 0, 430),
        Position          = UDim2.new(0.5, -340, 0.5, -215),
        BackgroundColor3  = Theme.BG,
        BorderSizePixel   = 0,
        ZIndex            = 2,
        ClipsDescendants  = true,
    }, self.ScreenGui)
    Corner(self.Window, Theme.CornerLg)

    -- Thin border accent
    New("UIStroke", {
        Color     = Theme.Divider,
        Thickness = 1,
        Transparency = 0.4,
    }, self.Window)

    -- ── Sidebar (left 188 px) ──────────────────────────────────
    self.Sidebar = New("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 188, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, self.Window)

    -- Sidebar separator line
    New("Frame", {
        Name             = "SepLine",
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, self.Sidebar)

    -- Logo block at top of sidebar
    local logoBlock = New("Frame", {
        Name             = "LogoBlock",
        Size             = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1,
        ZIndex           = 4,
    }, self.Sidebar)
    Padding(logoBlock, nil, 0, 0, 14, 0)

    New("TextLabel", {
        Name             = "Logo",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = self._title,
        TextColor3       = Theme.TextPrimary,
        Font             = Enum.Font.GothamBold,
        TextSize         = 15,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 5,
    }, logoBlock)

    -- Divider under logo
    New("Frame", {
        Name             = "LogoDivider",
        Size             = UDim2.new(1, -24, 0, 1),
        Position         = UDim2.new(0, 12, 0, 56),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, self.Sidebar)

    -- Nav container
    self.NavContainer = New("ScrollingFrame", {
        Name                   = "NavContainer",
        Size                   = UDim2.new(1, 0, 1, -114),  -- -56 logo -58 footer
        Position               = UDim2.new(0, 0, 0, 66),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ScrollBarThickness     = 0,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ZIndex                 = 4,
        ClipsDescendants       = true,
    }, self.Sidebar)
    Padding(self.NavContainer, nil, 6, 6, 8, 8)
    ListLayout(self.NavContainer, nil, 3)

    -- Sidebar footer (version)
    local footer = New("Frame", {
        Name             = "Footer",
        Size             = UDim2.new(1, 0, 0, 48),
        Position         = UDim2.new(0, 0, 1, -48),
        BackgroundTransparency = 1,
        ZIndex           = 4,
    }, self.Sidebar)
    Padding(footer, nil, 0, 0, 14, 0)

    -- Separator above footer
    New("Frame", {
        Name             = "FooterSep",
        Size             = UDim2.new(1, -24, 0, 1),
        Position         = UDim2.new(0, 12, 0, 0),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, footer)

    New("TextLabel", {
        Name             = "VersionLabel",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "v2.0  •  SetGame Hub",
        TextColor3       = Theme.TextMuted,
        Font             = Enum.Font.Gotham,
        TextSize         = 10,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 5,
    }, footer)

    -- ── Content area (right side) ──────────────────────────────
    self.ContentArea = New("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -188, 1, 0),
        Position         = UDim2.new(0, 188, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, self.Window)

    -- Content titlebar
    self.ContentTitle = New("Frame", {
        Name             = "ContentTitle",
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        ZIndex           = 4,
    }, self.ContentArea)
    Padding(self.ContentTitle, nil, 0, 0, 16, 16)

    self.ContentTitleLabel = New("TextLabel", {
        Name             = "TitleLabel",
        Size             = UDim2.new(1, -32, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        TextColor3       = Theme.TextPrimary,
        Font             = Enum.Font.GothamSemibold,
        TextSize          = 14,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 5,
    }, self.ContentTitle)

    -- Divider below content title
    New("Frame", {
        Name             = "TitleDivider",
        Size             = UDim2.new(1, -32, 0, 1),
        Position         = UDim2.new(0, 16, 0, 44),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, self.ContentArea)

    -- Page scroll container
    self.PageContainer = New("ScrollingFrame", {
        Name                   = "PageContainer",
        Size                   = UDim2.new(1, 0, 1, -52),
        Position               = UDim2.new(0, 0, 0, 52),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ScrollBarThickness     = 3,
        ScrollBarImageColor3   = Theme.Accent,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ZIndex                 = 4,
        ClipsDescendants       = true,
    }, self.ContentArea)
    Padding(self.PageContainer, nil, 4, 12, 14, 14)
    ListLayout(self.PageContainer, nil, 6)

    -- Window dragging support
    self:_EnableDrag(self.Window, self.ContentTitle)
end

-- ─── Topbar Button ────────────────────────────────────────────
function SetGameFramework:_BuildTopbarButton()
    local metrics = TopbarAdapter.GetTopbarMetrics()
    local btnSize = metrics.ButtonSize   -- typically 28 px

    -- Container inside ScreenGui at topbar level
    self.TopbarBtn = New("ImageButton", {
        Name              = "SetGameTopbar",
        Size              = UDim2.new(0, btnSize + 12, 0, btnSize),
        Position          = UDim2.new(0, metrics.LeftEdge, 0, metrics.OffsetY),
        BackgroundColor3  = Theme.Sidebar,
        BackgroundTransparency = 0.3,
        ZIndex            = 5,
        AutoButtonColor   = false,
        Image             = "",
    }, self.ScreenGui)
    TopbarAdapter.StyleButton(self.TopbarBtn)
    Corner(self.TopbarBtn, UDim.new(0, 6))
    New("UIStroke", {
        Color        = Theme.Divider,
        Thickness    = 1,
        Transparency = 0.5,
    }, self.TopbarBtn)

    -- Icon (≡ hamburger text label — no image dependency)
    New("TextLabel", {
        Name             = "Icon",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "⊞",
        TextColor3       = Theme.TextPrimary,
        Font             = Enum.Font.GothamBold,
        TextSize         = 14,
        ZIndex           = 6,
    }, self.TopbarBtn)

    -- Hover / click tweens
    self.TopbarBtn.MouseEnter:Connect(function()
        FastTween(self.TopbarBtn, {BackgroundTransparency = 0.1}, 0.12)
    end)
    self.TopbarBtn.MouseLeave:Connect(function()
        FastTween(self.TopbarBtn, {BackgroundTransparency = 0.3}, 0.12)
    end)
    self.TopbarBtn.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end)

    -- Re-calculate on viewport resize (orientation change, etc.)
    self.ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        task.defer(function()
            local m2 = TopbarAdapter.GetTopbarMetrics()
            self.TopbarBtn.Position = UDim2.new(0, m2.LeftEdge, 0, m2.OffsetY)
            local s2 = m2.ButtonSize
            self.TopbarBtn.Size = UDim2.new(0, s2 + 12, 0, s2)
        end)
    end)
end

-- ─── Drag ─────────────────────────────────────────────────────
function SetGameFramework:_EnableDrag(window, handle)
    local dragging, startPos, startWinPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            startPos   = input.Position
            startWinPos = window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - startPos
            window.Position = UDim2.new(
                startWinPos.X.Scale, startWinPos.X.Offset + delta.X,
                startWinPos.Y.Scale, startWinPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ─── Visibility ───────────────────────────────────────────────
function SetGameFramework:ToggleVisibility()
    self._visible = not self._visible
    if self._visible then
        self.Window.Visible = true
        self.Backdrop.Visible = true
        FastTween(self.Window, {BackgroundTransparency = 0}, 0.2)
    else
        FastTween(self.Window, {BackgroundTransparency = 1}, 0.15)
        task.delay(0.16, function()
            self.Window.Visible = false
            self.Backdrop.Visible = false
        end)
    end
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║           P A G E   S Y S T E M                         ║
-- ╚══════════════════════════════════════════════════════════╝
local Page = {}
Page.__index = Page

function SetGameFramework:AddPage(name, icon)
    local pg = setmetatable({}, Page)
    pg._name       = name
    pg._hub        = self
    pg._components = {}

    -- ── Nav button in sidebar ─────────────────────────────────
    pg.NavBtn = New("TextButton", {
        Name             = "NavBtn_" .. name,
        Size             = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 1,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 5,
    }, self.NavContainer)
    Corner(pg.NavBtn, Theme.CornerSm)
    Padding(pg.NavBtn, nil, 0, 0, 10, 6)

    local navLayout = New("Frame", {
        Name             = "NavInner",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex           = 6,
    }, pg.NavBtn)
    ListLayout(navLayout, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Left)
    New("UIListLayout", nil, navLayout).VerticalAlignment = Enum.VerticalAlignment.Center

    if icon then
        New("ImageLabel", {
            Name             = "Icon",
            Size             = UDim2.new(0, 14, 0, 14),
            BackgroundTransparency = 1,
            Image            = icon,
            ImageColor3      = Theme.TextSecond,
            ZIndex           = 7,
        }, navLayout)
    end

    pg.NavLabel = New("TextLabel", {
        Name             = "Label",
        Size             = UDim2.new(1, -22, 1, 0),
        BackgroundTransparency = 1,
        Text             = name,
        TextColor3       = Theme.TextSecond,
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 7,
    }, navLayout)

    -- Active indicator bar
    pg.ActiveBar = New("Frame", {
        Name             = "ActiveBar",
        Size             = UDim2.new(0, 3, 0.7, 0),
        Position         = UDim2.new(0, 0, 0.15, 0),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 7,
    }, pg.NavBtn)
    Corner(pg.ActiveBar, UDim.new(0, 2))

    -- ── Page frame in content area ────────────────────────────
    pg.Frame = New("Frame", {
        Name             = "Page_" .. name,
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible          = false,
        ZIndex           = 4,
    }, self.PageContainer)

    -- ── Nav click ─────────────────────────────────────────────
    pg.NavBtn.MouseEnter:Connect(function()
        if self._activePg ~= pg then
            FastTween(pg.NavBtn, {BackgroundTransparency = 0.5}, 0.1)
        end
    end)
    pg.NavBtn.MouseLeave:Connect(function()
        if self._activePg ~= pg then
            FastTween(pg.NavBtn, {BackgroundTransparency = 1}, 0.1)
        end
    end)
    pg.NavBtn.MouseButton1Click:Connect(function()
        self:_SelectPage(pg)
    end)

    table.insert(self._pages, pg)

    -- Auto-select first page
    if #self._pages == 1 then
        self:_SelectPage(pg)
    end

    return pg
end

function SetGameFramework:_SelectPage(pg)
    -- Deactivate previous
    if self._activePg then
        local prev = self._activePg
        FastTween(prev.NavBtn,   {BackgroundTransparency = 1}, 0.12)
        FastTween(prev.NavLabel, {TextColor3 = Theme.TextSecond}, 0.12)
        FastTween(prev.ActiveBar, {BackgroundTransparency = 1}, 0.12)
        prev.Frame.Visible = false
    end
    -- Activate new
    self._activePg = pg
    FastTween(pg.NavBtn,   {BackgroundTransparency = 0.6, BackgroundColor3 = Theme.Accent}, 0.15)
    FastTween(pg.NavLabel, {TextColor3 = Theme.TextPrimary}, 0.15)
    FastTween(pg.ActiveBar, {BackgroundTransparency = 0}, 0.15)
    pg.Frame.Visible = true

    -- Reset canvas since we switched pages
    task.defer(function()
        self.PageContainer.CanvasPosition = Vector2.new(0, 0)
    end)
    self.ContentTitleLabel.Text = pg._name
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║      C O M P O N E N T   F A C T O R Y                  ║
-- ╚══════════════════════════════════════════════════════════╝

-- ── Helper: component wrapper (consistent height + styling) ──
local function ComponentWrapper(parent, h)
    local wrap = New("Frame", {
        Size             = UDim2.new(1, 0, 0, h or 38),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.4,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        AutomaticSize    = Enum.AutomaticSize.None,
    }, parent.Frame)
    Corner(wrap, Theme.CornerSm)
    New("UIStroke", {
        Color        = Theme.Divider,
        Thickness    = 1,
        Transparency = 0.6,
    }, wrap)
    return wrap
end

local function LabelLeft(parent, text, small)
    return New("TextLabel", {
        Name             = "Label",
        Size             = UDim2.new(0.55, 0, 1, 0),
        Position         = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text             = text,
        TextColor3       = Theme.TextPrimary,
        Font             = small and Enum.Font.Gotham or Enum.Font.GothamSemibold,
        TextSize         = small and 11 or 12,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
    }, parent)
end

-- ══════════════════
--  BUTTON
-- ══════════════════
function Page:AddButton(opts)
    opts = opts or {}
    local label    = opts.Label    or "Button"
    local callback = opts.Callback or function() end
    local desc     = opts.Description

    local h = desc and 46 or 36
    local wrap = ComponentWrapper(self, h)

    local btn = New("TextButton", {
        Name             = "Btn",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 6,
    }, wrap)
    Padding(btn, nil, 0, 0, 12, 12)

    New("TextLabel", {
        Name             = "BtnLabel",
        Size             = UDim2.new(0.7, 0, 0, 14),
        Position         = UDim2.new(0, 0, 0.5, desc and -8 or -7),
        BackgroundTransparency = 1,
        Text             = label,
        TextColor3       = Theme.TextPrimary,
        Font             = Enum.Font.GothamSemibold,
        TextSize         = 12,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 7,
    }, btn)

    if desc then
        New("TextLabel", {
            Name             = "BtnDesc",
            Size             = UDim2.new(0.7, 0, 0, 11),
            Position         = UDim2.new(0, 0, 0.5, 4),
            BackgroundTransparency = 1,
            Text             = desc,
            TextColor3       = Theme.TextSecond,
            Font             = Enum.Font.Gotham,
            TextSize         = 10,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 7,
        }, btn)
    end

    -- Action pill (right side)
    local pill = New("Frame", {
        Name             = "Pill",
        Size             = UDim2.new(0, 60, 0, 22),
        Position         = UDim2.new(1, -60, 0.5, -11),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 7,
    }, btn)
    Corner(pill, Theme.CornerSm)
    New("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "Execute",
        TextColor3       = Color3.fromHex("FFFFFF"),
        Font             = Enum.Font.GothamBold,
        TextSize         = 10,
        ZIndex           = 8,
    }, pill)

    btn.MouseEnter:Connect(function()
        FastTween(wrap, {BackgroundTransparency = 0.1}, 0.1)
        FastTween(pill, {BackgroundColor3 = Theme.AccentGlow}, 0.1)
    end)
    btn.MouseLeave:Connect(function()
        FastTween(wrap, {BackgroundTransparency = 0.4}, 0.1)
        FastTween(pill, {BackgroundColor3 = Theme.Accent}, 0.1)
    end)
    btn.MouseButton1Down:Connect(function()
        FastTween(pill, {BackgroundColor3 = Theme.AccentDim}, 0.06)
    end)
    btn.MouseButton1Up:Connect(function()
        FastTween(pill, {BackgroundColor3 = Theme.AccentGlow}, 0.06)
    end)
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    return wrap
end

-- ══════════════════
--  TOGGLE
-- ══════════════════
function Page:AddToggle(opts)
    opts = opts or {}
    local label    = opts.Label    or "Toggle"
    local value    = opts.Default  or false
    local callback = opts.Callback or function() end

    local wrap = ComponentWrapper(self, 36)
    LabelLeft(wrap, label)

    -- Track
    local track = New("Frame", {
        Name             = "Track",
        Size             = UDim2.new(0, 40, 0, 20),
        Position         = UDim2.new(1, -52, 0.5, -10),
        BackgroundColor3 = value and Theme.Accent or Theme.Elevated,
        BorderSizePixel  = 0,
        ZIndex           = 6,
    }, wrap)
    Corner(track, Theme.CornerFull)

    -- Thumb
    local thumb = New("Frame", {
        Name             = "Thumb",
        Size             = UDim2.new(0, 14, 0, 14),
        Position         = value and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = Color3.fromHex("FFFFFF"),
        BorderSizePixel  = 0,
        ZIndex           = 7,
    }, track)
    Corner(thumb, Theme.CornerFull)

    local function setVal(v, silent)
        value = v
        FastTween(track, {BackgroundColor3 = v and Theme.Accent or Theme.Elevated}, 0.18)
        FastTween(thumb, {Position = v and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, 0.18)
        if not silent then pcall(callback, v) end
    end

    local btn = New("TextButton", {
        Name             = "Hitbox",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 8,
    }, wrap)
    btn.MouseButton1Click:Connect(function()
        setVal(not value)
    end)
    btn.MouseEnter:Connect(function()
        FastTween(wrap, {BackgroundTransparency = 0.1}, 0.1)
    end)
    btn.MouseLeave:Connect(function()
        FastTween(wrap, {BackgroundTransparency = 0.4}, 0.1)
    end)

    local api = { Set = setVal, Get = function() return value end }
    return api
end

-- ══════════════════
--  SLIDER
-- ══════════════════
function Page:AddSlider(opts)
    opts = opts or {}
    local label    = opts.Label    or "Slider"
    local minV     = opts.Min      or 0
    local maxV     = opts.Max      or 100
    local value    = opts.Default  or minV
    local suffix   = opts.Suffix   or ""
    local callback = opts.Callback or function() end
    local step     = opts.Step     or 1

    local wrap = ComponentWrapper(self, 48)
    Padding(wrap, nil, 6, 6, 12, 12)

    -- Top row: label + value display
    local topRow = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        ZIndex           = 6,
    }, wrap)

    New("TextLabel", {
        Size             = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = label,
        TextColor3       = Theme.TextPrimary,
        Font             = Enum.Font.GothamSemibold,
        TextSize         = 12,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 7,
    }, topRow)

    local valLabel = New("TextLabel", {
        Size             = UDim2.new(0.3, 0, 1, 0),
        Position         = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Text             = tostring(value) .. suffix,
        TextColor3       = Theme.Accent,
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        TextXAlignment   = Enum.TextXAlignment.Right,
        ZIndex           = 7,
    }, topRow)

    -- Track bar
    local track = New("Frame", {
        Name             = "Track",
        Size             = UDim2.new(1, 0, 0, 4),
        Position         = UDim2.new(0, 0, 0, 26),
        BackgroundColor3 = Theme.Elevated,
        BorderSizePixel  = 0,
        ZIndex           = 6,
    }, wrap)
    Corner(track, Theme.CornerFull)

    -- Fill
    local fill = New("Frame", {
        Name             = "Fill",
        Size             = UDim2.new((value - minV) / (maxV - minV), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 7,
    }, track)
    Corner(fill, Theme.CornerFull)

    -- Knob
    local knob = New("Frame", {
        Name             = "Knob",
        Size             = UDim2.new(0, 12, 0, 12),
        Position         = UDim2.new((value - minV) / (maxV - minV), -6, 0.5, -6),
        BackgroundColor3 = Color3.fromHex("FFFFFF"),
        BorderSizePixel  = 0,
        ZIndex           = 8,
    }, track)
    Corner(knob, Theme.CornerFull)
    New("UIStroke", {
        Color        = Theme.Accent,
        Thickness    = 2,
    }, knob)

    local function updateValue(v)
        v = math.clamp(math.round(v / step) * step, minV, maxV)
        value = v
        local pct = (v - minV) / (maxV - minV)
        fill.Size     = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -6, 0.5, -6)
        valLabel.Text = tostring(v) .. suffix
        pcall(callback, v)
    end

    -- Drag logic
    local sliding = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            local abs = track.AbsolutePosition.X
            local w   = track.AbsoluteSize.X
            local pct = math.clamp((input.Position.X - abs) / w, 0, 1)
            updateValue(minV + pct * (maxV - minV))
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not sliding then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local abs = track.AbsolutePosition.X
            local w   = track.AbsoluteSize.X
            local pct = math.clamp((input.Position.X - abs) / w, 0, 1)
            updateValue(minV + pct * (maxV - minV))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    return { Get = function() return value end, Set = updateValue }
end

-- ══════════════════
--  DROPDOWN
-- ══════════════════
function Page:AddDropdown(opts)
    opts = opts or {}
    local label    = opts.Label   or "Dropdown"
    local options  = opts.Options or {}
    local default  = opts.Default or (options[1] or "Select…")
    local callback = opts.Callback or function() end

    local selected = default
    local open     = false

    local wrap = ComponentWrapper(self, 36)
    LabelLeft(wrap, label)

    -- Button
    local selBtn = New("TextButton", {
        Name             = "SelBtn",
        Size             = UDim2.new(0, 130, 0, 24),
        Position         = UDim2.new(1, -140, 0.5, -12),
        BackgroundColor3 = Theme.Elevated,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 6,
    }, wrap)
    Corner(selBtn, Theme.CornerSm)
    Padding(selBtn, nil, 0, 0, 8, 6)

    local selLabel = New("TextLabel", {
        Size             = UDim2.new(1, -18, 1, 0),
        BackgroundTransparency = 1,
        Text             = selected,
        TextColor3       = Theme.TextPrimary,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 7,
    }, selBtn)

    New("TextLabel", {
        Name             = "Arrow",
        Size             = UDim2.new(0, 14, 1, 0),
        Position         = UDim2.new(1, -14, 0, 0),
        BackgroundTransparency = 1,
        Text             = "▾",
        TextColor3       = Theme.TextSecond,
        Font             = Enum.Font.Gotham,
        TextSize         = 10,
        ZIndex           = 7,
    }, selBtn)

    -- Dropdown list (rendered above the wrap, high ZIndex)
    local listFrame = New("ScrollingFrame", {
        Name             = "DropList",
        Size             = UDim2.new(0, 130, 0, 0),
        Position         = UDim2.new(1, -140, 1, 4),
        BackgroundColor3 = Theme.Elevated,
        BorderSizePixel  = 0,
        ZIndex           = 20,
        Visible          = false,
        ClipsDescendants = true,
        ScrollBarThickness = 0,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, wrap)
    Corner(listFrame, Theme.CornerSm)
    New("UIStroke", {
        Color        = Theme.Divider,
        Thickness    = 1,
        Transparency = 0.3,
    }, listFrame)
    Padding(listFrame, nil, 4, 4, 0, 0)
    ListLayout(listFrame, nil, 1)

    local function buildList()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, opt in ipairs(options) do
            local item = New("TextButton", {
                Name             = "Item_" .. opt,
                Size             = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Theme.Elevated,
                BackgroundTransparency = opt == selected and 0.5 or 1,
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 21,
            }, listFrame)
            Padding(item, nil, 0, 0, 10, 0)
            New("TextLabel", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = opt,
                TextColor3       = opt == selected and Theme.Accent or Theme.TextPrimary,
                Font             = Enum.Font.Gotham,
                TextSize         = 11,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 22,
            }, item)
            item.MouseEnter:Connect(function()
                FastTween(item, {BackgroundTransparency = 0.5}, 0.08)
            end)
            item.MouseLeave:Connect(function()
                FastTween(item, {BackgroundTransparency = opt == selected and 0.5 or 1}, 0.08)
            end)
            item.MouseButton1Click:Connect(function()
                selected = opt
                selLabel.Text = opt
                open = false
                FastTween(listFrame, {Size = UDim2.new(0, 130, 0, 0)}, 0.12)
                task.delay(0.12, function() listFrame.Visible = false end)
                buildList()
                pcall(callback, opt)
            end)
        end
    end
    buildList()

    selBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            listFrame.Visible = true
            local targetH = math.min(#options * 27 + 8, 150)
            FastTween(listFrame, {Size = UDim2.new(0, 130, 0, targetH)}, 0.15)
        else
            FastTween(listFrame, {Size = UDim2.new(0, 130, 0, 0)}, 0.12)
            task.delay(0.12, function() listFrame.Visible = false end)
        end
    end)

    local api = {}
    api.Set = function(v)
        selected = v; selLabel.Text = v; buildList()
    end
    api.Get = function() return selected end
    return api
end

-- ══════════════════
--  INPUT BOX
-- ══════════════════
function Page:AddInput(opts)
    opts = opts or {}
    local label    = opts.Label       or "Input"
    local placeholder = opts.Placeholder or "Type here…"
    local callback = opts.Callback    or function() end

    local wrap = ComponentWrapper(self, 36)
    LabelLeft(wrap, label)

    local box = New("TextBox", {
        Name             = "InputBox",
        Size             = UDim2.new(0, 130, 0, 24),
        Position         = UDim2.new(1, -140, 0.5, -12),
        BackgroundColor3 = Theme.Elevated,
        Text             = "",
        PlaceholderText  = placeholder,
        PlaceholderColor3 = Theme.TextMuted,
        TextColor3       = Theme.TextPrimary,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        ClearTextOnFocus = opts.ClearOnFocus ~= false,
        BorderSizePixel  = 0,
        ZIndex           = 6,
    }, wrap)
    Corner(box, Theme.CornerSm)
    Padding(box, nil, 0, 0, 8, 8)

    local stroke = New("UIStroke", {
        Color        = Theme.Divider,
        Thickness    = 1,
        Transparency = 0.4,
    }, box)

    box.Focused:Connect(function()
        FastTween(stroke, {Color = Theme.Accent, Transparency = 0}, 0.12)
    end)
    box.FocusLost:Connect(function(enter)
        FastTween(stroke, {Color = Theme.Divider, Transparency = 0.4}, 0.12)
        pcall(callback, box.Text, enter)
    end)

    return { Get = function() return box.Text end, Set = function(v) box.Text = v end }
end

-- ══════════════════
--  DIVIDER
-- ══════════════════
function Page:AddDivider(opts)
    opts = opts or {}
    local label = opts.Label

    local wrap = New("Frame", {
        Size             = UDim2.new(1, 0, 0, label and 24 or 12),
        BackgroundTransparency = 1,
        ZIndex           = 5,
    }, self.Frame)

    if label then
        New("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 12),
            Position         = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text             = label,
            TextColor3       = Theme.TextMuted,
            Font             = Enum.Font.GothamBold,
            TextSize         = 9,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 6,
        }, wrap)
    end

    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel  = 0,
        ZIndex           = 6,
    }, wrap)

    return wrap
end

-- ═══════════════════════════════════════════════════════════
--  N O T I F I C A T I O N   S Y S T E M
-- ═══════════════════════════════════════════════════════════
function SetGameFramework:Notify(opts)
    opts = opts or {}
    local title    = opts.Title   or "Notice"
    local message  = opts.Message or ""
    local duration = opts.Duration or 3
    local kind     = opts.Kind    or "info"  -- info | success | warning | error

    local kindColor = {
        info    = Theme.Info,
        success = Theme.Success,
        warning = Theme.Warning,
        error   = Theme.Error,
    }
    local accentCol = kindColor[kind] or Theme.Info

    local notif = New("Frame", {
        Name             = "Notif",
        Size             = UDim2.new(0, 280, 0, 64),
        Position         = UDim2.new(1, -296, 1, 16),  -- start below screen
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 55,
        BackgroundTransparency = 0,
    }, self.NotifLayer)
    Corner(notif, Theme.CornerMd)
    New("UIStroke", {
        Color        = accentCol,
        Thickness    = 1,
        Transparency = 0.3,
    }, notif)

    -- Accent bar (left)
    New("Frame", {
        Size             = UDim2.new(0, 3, 0.7, 0),
        Position         = UDim2.new(0, 0, 0.15, 0),
        BackgroundColor3 = accentCol,
        BorderSizePixel  = 0,
        ZIndex           = 56,
    }, notif).Parent = notif

    Padding(notif, nil, 0, 0, 10, 8)

    New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 18),
        Position         = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = Theme.TextPrimary,
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 57,
    }, notif)

    New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 22),
        Position         = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        Text             = message,
        TextColor3       = Theme.TextSecond,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 57,
    }, notif)

    -- Progress bar
    local progBG = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Elevated,
        BorderSizePixel  = 0,
        ZIndex           = 57,
    }, notif)
    Corner(progBG)
    local progFill = New("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentCol,
        BorderSizePixel  = 0,
        ZIndex           = 58,
    }, progBG)
    Corner(progFill)

    -- Stack offset (simple: each notif sits above the previous)
    local existingCount = 0
    for _, ch in ipairs(self.NotifLayer:GetChildren()) do
        if ch:IsA("Frame") and ch.Name == "Notif" and ch ~= notif then
            existingCount += 1
        end
    end
    local targetY = -1 * (80 * (existingCount + 1)) + 16   -- stack upward from bottom

    -- Slide in
    FastTween(notif, {Position = UDim2.new(1, -296, 1, targetY)}, 0.25)

    -- Progress tween
    Tween(progFill,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 1, 0)}
    )

    -- Slide out & destroy
    task.delay(duration, function()
        FastTween(notif, {Position = UDim2.new(1, 16, 1, targetY), BackgroundTransparency = 1}, 0.2)
        task.delay(0.22, function()
            notif:Destroy()
        end)
    end)
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║       A B O U T   Y O U   P A G E                       ║
-- ╚══════════════════════════════════════════════════════════╝
function SetGameFramework:_BuildAboutPage()
    local aboutPage = self:AddPage("About You", "")

    -- ── Avatar card ─────────────────────────────────────────
    local avatarCard = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 82),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.2,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, aboutPage.Frame)
    Corner(avatarCard, Theme.CornerMd)
    New("UIStroke", {Color = Theme.Divider, Thickness = 1, Transparency = 0.5}, avatarCard)
    Padding(avatarCard, nil, 12, 12, 14, 12)

    -- Avatar image
    local avatarImg = New("ImageLabel", {
        Name             = "Avatar",
        Size             = UDim2.new(0, 56, 0, 56),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Elevated,
        Image            = "",
        ZIndex           = 6,
    }, avatarCard)
    Corner(avatarImg, Theme.CornerFull)

    -- Info block next to avatar
    local infoBlock = New("Frame", {
        Size             = UDim2.new(1, -68, 0, 56),
        Position         = UDim2.new(0, 68, 0, 0),
        BackgroundTransparency = 1,
        ZIndex           = 6,
    }, avatarCard)

    local nameLabel = New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 18),
        Position         = UDim2.new(0, 0, 0, 4),
        BackgroundTransparency = 1,
        Text             = LP.DisplayName,
        TextColor3       = Theme.TextPrimary,
        Font             = Enum.Font.GothamBold,
        TextSize         = 14,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 7,
    }, infoBlock)

    New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 14),
        Position         = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
        Text             = "@" .. LP.Name,
        TextColor3       = Theme.TextSecond,
        Font             = Enum.Font.Gotham,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 7,
    }, infoBlock)

    -- Account age tag
    local ageTag = New("Frame", {
        Size             = UDim2.new(0, 0, 0, 16),
        Position         = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.6,
        AutomaticSize    = Enum.AutomaticSize.X,
        ZIndex           = 7,
    }, infoBlock)
    Corner(ageTag, UDim.new(0, 3))
    Padding(ageTag, nil, 0, 0, 6, 6)
    local ageTagLabel = New("TextLabel", {
        Size             = UDim2.new(0, 0, 1, 0),
        AutomaticSize    = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text             = "…",
        TextColor3       = Theme.Accent,
        Font             = Enum.Font.GothamBold,
        TextSize         = 9,
        ZIndex           = 8,
    }, ageTag)

    -- ── Stats grid ──────────────────────────────────────────
    aboutPage:AddDivider({ Label = "ACCOUNT STATS" })

    local statsRow = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
        ZIndex           = 5,
    }, aboutPage.Frame)
    local statsLayout = Instance.new("UIGridLayout")
    statsLayout.CellSize    = UDim2.new(0.5, -4, 1, 0)
    statsLayout.CellPadding = UDim2.new(0, 8, 0, 0)
    statsLayout.SortOrder   = Enum.SortOrder.LayoutOrder
    statsLayout.Parent      = statsRow

    local function StatCard(title, valueText, color)
        local card = New("Frame", {
            BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 0.4,
            BorderSizePixel  = 0,
            ZIndex           = 6,
        }, statsRow)
        Corner(card, Theme.CornerSm)
        Padding(card, nil, 7, 7, 10, 10)
        New("UIStroke", {Color = Theme.Divider, Thickness = 1, Transparency = 0.5}, card)
        New("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 11),
            BackgroundTransparency = 1,
            Text             = title,
            TextColor3       = Theme.TextSecond,
            Font             = Enum.Font.Gotham,
            TextSize         = 9,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 7,
        }, card)
        local valL = New("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 16),
            Position         = UDim2.new(0, 0, 0, 14),
            BackgroundTransparency = 1,
            Text             = valueText,
            TextColor3       = color or Theme.TextPrimary,
            Font             = Enum.Font.GothamBold,
            TextSize         = 13,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 7,
        }, card)
        return valL
    end

    local acctAgeLabel   = StatCard("Account Age",      "…",  Theme.TextPrimary)
    local createdYrLabel = StatCard("Estimated Created", "…",  Theme.Accent)

    -- ── Ultra-Precision Clock ────────────────────────────────
    aboutPage:AddDivider({ Label = "SYSTEM CLOCK" })

    local clockCard = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.3,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, aboutPage.Frame)
    Corner(clockCard, Theme.CornerMd)
    New("UIStroke", {Color = Theme.Divider, Thickness = 1, Transparency = 0.5}, clockCard)
    Padding(clockCard, nil, 8, 8, 14, 14)

    local clockBig = New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text             = "00:00:00",
        TextColor3       = Theme.TextPrimary,
        Font             = Enum.Font.RobotoMono,
        TextSize         = 20,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
    }, clockCard)

    local clockMs = New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 14),
        Position         = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
        Text             = "ms: 000  |  Unix: 0",
        TextColor3       = Theme.TextMuted,
        Font             = Enum.Font.RobotoMono,
        TextSize         = 10,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
    }, clockCard)

    -- ── Async avatar fetch + account age calc ───────────────
    task.spawn(function()
        -- Avatar headshot
        local ok, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(
                LP.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)
        if ok and thumb then
            avatarImg.Image = thumb
        end

        -- Account age
        local accountAge = LP.AccountAge   -- in days (Roblox built-in)
        local years       = math.floor(accountAge / 365)
        local months      = math.floor((accountAge % 365) / 30)
        local days        = accountAge % 30

        local ageStr = ""
        if years  > 0 then ageStr = ageStr .. years  .. "y " end
        if months > 0 then ageStr = ageStr .. months .. "m " end
        ageStr = ageStr .. days .. "d"

        acctAgeLabel.Text  = ageStr
        ageTagLabel.Text   = "Age: " .. ageStr

        -- Estimated creation year
        -- os.time() returns current Unix timestamp
        local nowUnix     = os.time()
        local createdUnix = nowUnix - (accountAge * 86400)
        -- Very rough estimation — no os.date in executor context
        -- We calculate year from epoch: year ≈ 1970 + secs/31_557_600
        local YEAR_SECS   = 31_557_600
        local estYear     = math.floor(1970 + createdUnix / YEAR_SECS)
        createdYrLabel.Text = "~" .. tostring(estYear)
    end)

    return aboutPage
end

-- ─── Ultra-Precision Clock Loop ───────────────────────────────
function SetGameFramework:_StartClockLoop()
    -- We store the session start time to compute sub-second offset
    local sessionStartOsTime  = os.time()
    local sessionStartOsClock = os.clock()

    RunService.RenderStepped:Connect(function()
        -- Find the clock labels (they only exist after _BuildAboutPage is called)
        local aboutFrame = self.PageContainer:FindFirstChild("Page_About You")
        if not aboutFrame then return end

        local clockCard = aboutFrame:FindFirstChild("Frame", true)
        -- We'll look up by a specific label
        -- (more robust: we store refs in _BuildAboutPage; see note below)
        -- Clock logic is self-contained here using upvalue refs set below.
    end)
end

-- ─── We override _StartClockLoop after _BuildAboutPage creates refs ──
-- This is called at the end of _BuildAboutPage internally:
local _origBuild = SetGameFramework._BuildAboutPage
SetGameFramework._BuildAboutPage = function(self)
    local aboutPage = _origBuild(self)

    -- Find clock labels from the page we just built
    local pgFrame = aboutPage.Frame
    local function findLabel(name)
        for _, d in ipairs(pgFrame:GetDescendants()) do
            if d:IsA("TextLabel") and d.Name == name then return d end
        end
    end

    -- We stored them as locals in the closure, but we expose them via
    -- well-known TextLabel names for the clock loop.
    local clockBig = pgFrame:FindFirstChild("TextLabel", true)  -- fallback
    -- Better: use the refs directly. We patch the loop here:
    local sessionStartOsTime  = os.time()
    local sessionStartOsClock = os.clock()

    -- Walk descendants to find our clock labels by content pattern
    local bigLabel, msLabel
    for _, d in ipairs(pgFrame:GetDescendants()) do
        if d:IsA("TextLabel") then
            if d.Font == Enum.Font.RobotoMono and d.TextSize == 20 then
                bigLabel = d
            elseif d.Font == Enum.Font.RobotoMono and d.TextSize == 10 then
                msLabel = d
            end
        end
    end

    if bigLabel and msLabel then
        RunService.RenderStepped:Connect(function()
            -- High-resolution time: os.time() gives seconds,
            -- os.clock() gives sub-second precision since session start
            local elapsed    = os.clock() - sessionStartOsClock
            local currentUnix = sessionStartOsTime + math.floor(elapsed)
            local ms          = math.floor((elapsed % 1) * 1000)

            -- Build H:M:S from unix
            local s  = currentUnix % 60
            local m  = math.floor(currentUnix / 60)  % 60
            local h  = math.floor(currentUnix / 3600) % 24

            bigLabel.Text = string.format("%02d:%02d:%02d", h, m, s)
            msLabel.Text  = string.format("ms: %03d  |  Unix: %d", ms, currentUnix)
        end)
    end

    return aboutPage
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║           E X A M P L E   U S A G E                     ║
-- ║   (Remove or wrap in pcall when using in production)     ║
-- ╚══════════════════════════════════════════════════════════╝
--[[
local Hub = SetGameFramework.new("SetGame Hub")

-- ── Example page: Settings ────────────────────────────────
local settings = Hub:AddPage("Settings", "")

settings:AddButton({
    Label       = "Reset Character",
    Description = "Teleport to spawn",
    Callback    = function()
        game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Health = 0
    end,
})

settings:AddToggle({
    Label    = "Speed Hack",
    Default  = false,
    Callback = function(v)
        local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v and 50 or 16 end
    end,
})

settings:AddSlider({
    Label    = "Walk Speed",
    Min      = 1,
    Max      = 200,
    Default  = 16,
    Suffix   = " ws",
    Callback = function(v)
        local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end,
})

settings:AddDropdown({
    Label   = "Jump Power",
    Options = {"50", "100", "150", "200"},
    Default = "50",
    Callback = function(v)
        local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = tonumber(v) end
    end,
})

settings:AddInput({
    Label       = "Chat Message",
    Placeholder = "Enter text…",
    Callback    = function(text, enter)
        if enter then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                .SayMessageRequest:FireServer(text, "All")
        end
    end,
})

settings:AddDivider({ Label = "DANGER ZONE" })

settings:AddButton({
    Label    = "Notify Test",
    Callback = function()
        Hub:Notify({
            Title   = "Test Notification",
            Message = "SetGame Hub v2.0 is running!",
            Kind    = "success",
            Duration = 4,
        })
    end,
})
]]

return SetGameFramework
