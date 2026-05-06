-- QuantumX UI Library | Xeno Executor Fix
-- Changes: CoreGui → gethui(), setclipboard fallback, Draggable fallback + manual drag

-- ============================================================
-- [XENO FIX #1] Safe GUI Parent
-- Xeno blokir parent langsung ke CoreGui, pake gethui() dulu
-- ============================================================
local function GetGuiParent()
    if gethui then
        return gethui()
    end
    -- fallback buat executor lain (Synapse, Fluxus, dll)
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok then return cg end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- ============================================================
-- [XENO FIX #2] Safe Clipboard
-- Xeno pake toclipboard, executor lain pake setclipboard
-- ============================================================
local function SafeClipboard(text)
    if toclipboard then
        toclipboard(text)
        return true
    elseif setclipboard then
        setclipboard(text)
        return true
    end
    return false
end

-- ============================================================
-- [XENO FIX #3] Safe Draggable
-- Xeno kadang ga support property Draggable di GuiObject
-- Diganti manual drag pake UIS
-- ============================================================
local function MakeDraggable(frame)
    -- Coba set Draggable dulu (buat executor yang support)
    pcall(function() frame.Draggable = true end)

    -- Manual drag fallback (works di semua executor termasuk Xeno)
    local UIS = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
-- Kode asli dengan patch yang diterapkan
-- (Hanya bagian yang diubah ditandai [XENO PATCH])
-- ============================================================

local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    -- [XENO PATCH] CoreGui diganti pake GetGuiParent()
    CoreGui = GetGuiParent(),
    Lighting = game:GetService("Lighting")
}

local TS = Services.TweenService

local function Make(className, properties, children)
    local inst = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            -- [XENO PATCH] Skip Draggable property, dihandle manual
            if prop ~= "Draggable" then
                pcall(function() inst[prop] = value end)
            end
        end
    end
    if properties and properties.Parent then inst.Parent = properties.Parent end
    for _, child in pairs(children or {}) do child.Parent = inst end
    return inst
end

local function Tween(obj, info, props)
    return TS:Create(obj, info or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end

local Quantum = {}
Quantum.ThemePalettes = {
    ["Default Hitam"] = {
        Accent = Color3.fromRGB(255, 255, 255),
        Grad1 = Color3.fromRGB(0, 0, 0),
        Grad2 = Color3.fromRGB(255, 255, 255)
    },
    ["Sunset Orange"] = {
        Accent = Color3.fromRGB(255, 120, 0),
        Grad1 = Color3.fromRGB(30, 10, 0),
        Grad2 = Color3.fromRGB(120, 40, 0)
    },
    ["Matrix Green"] = {
        Accent = Color3.fromRGB(0, 255, 100),
        Grad1 = Color3.fromRGB(0, 15, 5),
        Grad2 = Color3.fromRGB(0, 70, 20)
    },
    ["Blood Red"] = {
        Accent = Color3.fromRGB(255, 50, 50),
        Grad1 = Color3.fromRGB(20, 5, 5),
        Grad2 = Color3.fromRGB(90, 0, 0)
    },
    ["Neon Green"] = {
        Accent = Color3.fromRGB(57, 255, 20),
        Grad1 = Color3.fromRGB(0, 25, 0),
        Grad2 = Color3.fromRGB(0, 100, 0)
    }
}

function Quantum.Build(Config)
    local Window = { Tabs = {}, CurrentTheme = Config.Theme or "Neon Green" }
    local Theme = Quantum.ThemePalettes[Window.CurrentTheme]

    local OldGui = Services.CoreGui:FindFirstChild("QuantumXOpenSource")
    if OldGui then OldGui:Destroy() end

    Window.ScreenGui = Make("ScreenGui", {Name = "QuantumXOpenSource", Parent = Services.CoreGui, ResetOnSpawn = false})
    Window.NotifContainer = Make("Frame", {Parent = Window.ScreenGui, Size = UDim2.new(0, 300, 1, -20), Position = UDim2.new(1, -10, 0, 0), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1}, {
        Make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8)})
    })

    -- [XENO PATCH] Hapus Draggable = true dari Make(), dihandle MakeDraggable()
    Window.MainFrame = Make("CanvasGroup", {Parent = Window.ScreenGui, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 0, 0, 0), Visible = false, GroupTransparency = 1, Active = true}, {
        Make("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Make("UIGradient", {Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Theme.Grad1), ColorSequenceKeypoint.new(1.00, Theme.Grad2)}, Rotation = 45})
    })
    MakeDraggable(Window.MainFrame) -- [XENO PATCH] Manual drag

    Window.ToggleBtn = Make("ImageButton", {Parent = Window.ScreenGui, BackgroundColor3 = Color3.fromRGB(12, 12, 18), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 20, 0.5, 0), Size = UDim2.new(0, 0, 0, 0), Image = Config.ToggleIcon or "rbxassetid://131775361395370", Visible = false}, {
        Make("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Make("UIStroke", {Color = Theme.Accent, Thickness = 1})
    })
    MakeDraggable(Window.ToggleBtn) -- [XENO PATCH] Manual drag

    local InnerFrame = Make("Frame", {Parent = Window.MainFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ClipsDescendants = true})

    Make("TextLabel", {
        Parent = InnerFrame,
        Text = Config.Title .. " | " .. Config.Subtitle,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBlack,
        TextSize = 12,
        Position = UDim2.new(0.5, 0, 0, 10),
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(1, -70, 0, 16),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    local CloseBtn = Make("TextButton", {
        Parent = InnerFrame, Text = "X", TextColor3 = Color3.fromRGB(255, 80, 80),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 18,
        Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -30, 0, 6), AutoButtonColor = false
    })

    local MinBtn = Make("TextButton", {
        Parent = InnerFrame, Text = "-", TextColor3 = Color3.fromRGB(180, 180, 200),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 22,
        Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -58, 0, 6), AutoButtonColor = false
    })

    local ResizeBtn = Make("TextButton", {
        Parent = InnerFrame, Text = "□", TextColor3 = Color3.fromRGB(180, 180, 200),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14,
        Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -86, 0, 6), AutoButtonColor = false
    })

    local IsExpanded = false
    local NormalSize = UDim2.new(0, 400, 0, 260)
    local ExpandedSize = UDim2.new(0, 520, 0, 340)

    -- [XENO PATCH] ConfirmGui juga pake GetGuiParent()
    local ConfirmGui = Make("ScreenGui", {Parent = GetGuiParent(), ResetOnSpawn = false, Name = "QuantumConfirm", Enabled = false})
    local ConfirmBlur = Make("BlurEffect", {Parent = Services.Lighting, Size = 0, Enabled = false})

    local ConfirmFrame = Make("Frame", {Parent = ConfirmGui, Size = UDim2.new(0, 300, 0, 140), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(20, 20, 25), BackgroundTransparency = 0.1}, {
        Make("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Make("UIStroke", {Color = Theme.Accent, Thickness = 1})
    })

    Make("TextLabel", {Parent = ConfirmFrame, Text = "⚠️ Confirmation", Position = UDim2.new(0, 0, 0, 12), Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 16, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Center})
    Make("TextLabel", {Parent = ConfirmFrame, Text = "Are you sure want to close Quantum HUB?", Position = UDim2.new(0, 0, 0, 42), Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true})

    local YesBtn = Make("TextButton", {Parent = ConfirmFrame, Text = "YES", Size = UDim2.new(0, 120, 0, 34), Position = UDim2.new(0, 20, 1, -48), BackgroundColor3 = Color3.fromRGB(255, 60, 60), TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false}, {Make("UICorner", {CornerRadius = UDim.new(0, 6)})})
    local NoBtn = Make("TextButton", {Parent = ConfirmFrame, Text = "NO", Size = UDim2.new(0, 120, 0, 34), Position = UDim2.new(1, -140, 1, -48), BackgroundColor3 = Color3.fromRGB(60, 180, 60), TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false}, {Make("UICorner", {CornerRadius = UDim.new(0, 6)})})

    local function ShowConfirm(callback)
        ConfirmGui.Enabled = true
        ConfirmBlur.Enabled = true
        ConfirmFrame.Size = UDim2.new(0, 260, 0, 120)
        Tween(ConfirmBlur, nil, {Size = 20}):Play()
        Tween(ConfirmFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 140)}):Play()

        local connection1, connection2
        connection1 = YesBtn.MouseButton1Click:Connect(function()
            Tween(ConfirmBlur, nil, {Size = 0}):Play()
            Tween(ConfirmFrame, nil, {BackgroundTransparency = 1}):Play()
            task.wait(0.2)
            ConfirmGui.Enabled = false
            ConfirmBlur.Enabled = false
            connection1:Disconnect()
            if connection2 then connection2:Disconnect() end
            callback(true)
        end)

        connection2 = NoBtn.MouseButton1Click:Connect(function()
            Tween(ConfirmBlur, nil, {Size = 0}):Play()
            Tween(ConfirmFrame, nil, {BackgroundTransparency = 1}):Play()
            task.wait(0.2)
            ConfirmGui.Enabled = false
            ConfirmBlur.Enabled = false
            connection1:Disconnect()
            connection2:Disconnect()
            callback(false)
        end)
    end

    local Body = Make("Frame", {Parent = InnerFrame, Size = UDim2.new(1, 0, 1, -36), Position = UDim2.new(0, 0, 0, 32), BackgroundTransparency = 1})

    Window.Sidebar = Make("ScrollingFrame", {Parent = Body, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.3, Size = UDim2.new(0, 108, 1, 0), BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent})
    local SideList = Make("UIListLayout", {Parent = Window.Sidebar, Padding = UDim.new(0, 3), HorizontalAlignment = Enum.HorizontalAlignment.Center})
    SideList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Window.Sidebar.CanvasSize = UDim2.new(0, 0, 0, SideList.AbsoluteContentSize.Y + 16) end)

    Window.Content = Make("Frame", {Parent = Body, BackgroundTransparency = 1, Position = UDim2.new(0, 114, 0, 0), Size = UDim2.new(1, -120, 1, 0)})

    CloseBtn.MouseButton1Click:Connect(function()
        ShowConfirm(function(confirmed)
            if confirmed then
                Tween(Window.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
                task.wait(0.3)
                Window.ScreenGui:Destroy()
                ConfirmGui:Destroy()
                ConfirmBlur:Destroy()
            end
        end)
    end)

    MinBtn.MouseButton1Click:Connect(function()
        Tween(Window.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.3)
        Window.MainFrame.Visible = false
        Window.ToggleBtn.Visible = true
        Tween(Window.ToggleBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 42, 0, 42)}):Play()
    end)

    ResizeBtn.MouseButton1Click:Connect(function()
        IsExpanded = not IsExpanded
        local TargetSize = IsExpanded and ExpandedSize or NormalSize
        Tween(Window.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = TargetSize}):Play()
        ResizeBtn.Text = IsExpanded and "▣" or "□"
    end)

    ResizeBtn.MouseEnter:Connect(function()
        Tween(ResizeBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 30, 0, 30), TextSize = 16}):Play()
        ResizeBtn.TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent
    end)
    ResizeBtn.MouseLeave:Connect(function()
        Tween(ResizeBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 26, 0, 26), TextSize = 14}):Play()
        ResizeBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
    end)

    Window.ToggleBtn.MouseButton1Click:Connect(function()
        Window.ToggleBtn.Visible = false
        Window.MainFrame.Visible = true
        Tween(Window.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {GroupTransparency = 0, Size = UDim2.new(0, 400, 0, 260)}):Play()
    end)

    function Window:Notify(NConfig)
        local Duration = NConfig.Duration or 3
        local NFrame = Make("Frame", {Parent = self.NotifContainer, BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY, ClipsDescendants = true, Position = UDim2.new(1, 50, 0, 0)}, {
            Make("UICorner", {CornerRadius = UDim.new(0, 6)}),
            Make("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}),
            Make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
        })
        local NStroke = Make("UIStroke", {Parent = NFrame, Color = Quantum.ThemePalettes[self.CurrentTheme].Accent, Transparency = 1, Thickness = 1})
        local TopContent = Make("Frame", {Parent = NFrame, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY}, {
            Make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8)})
        })
        local Logo = Make("ImageLabel", {Parent = TopContent, Size = UDim2.new(0, 26, 0, 26), BackgroundTransparency = 1, ImageTransparency = 1, Image = "rbxassetid://131775361395370"}, {
            Make("UICorner", {CornerRadius = UDim.new(1, 0)})
        })
        local TextContainer = Make("Frame", {Parent = TopContent, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY}, {
            Make("UIListLayout", {Padding = UDim.new(0, 2)}),
            Make("UISizeConstraint", {MaxSize = Vector2.new(220, 9999)})
        })
        local NTitle = Make("TextLabel", {Parent = TextContainer, BackgroundTransparency = 1, TextTransparency = 1, Text = NConfig.Title or "Quantum X", TextColor3 = Quantum.ThemePalettes[self.CurrentTheme].Accent, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY})
        local NText = Make("TextLabel", {Parent = TextContainer, BackgroundTransparency = 1, TextTransparency = 1, Text = NConfig.Text or "", TextColor3 = Color3.fromRGB(220, 220, 220), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY, TextWrapped = true})
        local ProgressBg = Make("Frame", {Parent = NFrame, Size = UDim2.new(1, 20, 0, 2), Position = UDim2.new(0, -10, 0, 0), BackgroundColor3 = Color3.fromRGB(30, 30, 40), BackgroundTransparency = 1, BorderSizePixel = 0})
        local ProgressFill = Make("Frame", {Parent = ProgressBg, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Quantum.ThemePalettes[self.CurrentTheme].Accent, BackgroundTransparency = 1, BorderSizePixel = 0})

        TS:Create(NFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        TS:Create(NFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
        TS:Create(NStroke, TweenInfo.new(0.3), {Transparency = 0.3}):Play()
        TS:Create(NTitle, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TS:Create(NText, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TS:Create(Logo, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
        TS:Create(ProgressBg, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
        TS:Create(ProgressFill, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()

        task.spawn(function()
            TS:Create(ProgressFill, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
            task.wait(Duration)
            TS:Create(NFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 0, 0)}):Play()
            local fade = TS:Create(NFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1})
            TS:Create(NStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
            TS:Create(NTitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            TS:Create(NText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            TS:Create(Logo, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
            TS:Create(ProgressBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            TS:Create(ProgressFill, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            fade:Play()
            fade.Completed:Wait()
            NFrame:Destroy()
        end)
    end

    function Window:PlayIntro(IntroConfig)
        local IntroBlur = Make("BlurEffect", {Parent = Services.Lighting, Size = 0})
        local IntroGui = Make("ScreenGui", {Parent = GetGuiParent()}) -- [XENO PATCH]
        local CenterFrame = Make("Frame", {Parent = IntroGui, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1}, {
            Make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)})
        })
        local IntroLogo = Make("ImageLabel", {Parent = CenterFrame, Image = "rbxassetid://131775361395370", Size = UDim2.new(0, 100, 0, 100), BackgroundTransparency = 1, ImageTransparency = 1, LayoutOrder = 1}, {
            Make("UICorner", {CornerRadius = UDim.new(1, 0)})
        })
        local TextClip = Make("Frame", {Parent = CenterFrame, BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(0, 0, 0, 100), LayoutOrder = 2})
        local IntroText = Make("TextLabel", {Parent = TextClip, Text = "Quantum Community", Font = Enum.Font.GothamBlack, TextSize = 24, TextColor3 = Quantum.ThemePalettes[self.CurrentTheme].Accent, Size = UDim2.new(0, 280, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
        local StatusText = Make("TextLabel", {Parent = IntroGui, Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0.85, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextTransparency = 1})

        if IntroConfig.IsSupported then
            StatusText.Text = "✅ Map Supported: " .. IntroConfig.MapName
            StatusText.TextColor3 = Quantum.ThemePalettes[self.CurrentTheme].Accent
        else
            StatusText.Text = "❌ Map Tidak Didukung!"
            StatusText.TextColor3 = Color3.fromRGB(255, 80, 80)
        end

        TS:Create(IntroBlur, TweenInfo.new(1), {Size = 20}):Play()
        CenterFrame.Position = UDim2.new(0, 0, -1, 0)
        IntroLogo.ImageTransparency = 0
        TS:Create(CenterFrame, TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        TS:Create(StatusText, TweenInfo.new(1), {TextTransparency = 0}):Play()
        task.wait(1.5)
        TS:Create(TextClip, TweenInfo.new(1.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 280, 0, 100)}):Play()
        task.wait(2.5)
        TS:Create(IntroBlur, TweenInfo.new(0.8), {Size = 0}):Play()
        local fadeIntro = TS:Create(CenterFrame, TweenInfo.new(0.8), {BackgroundTransparency = 1})
        TS:Create(IntroLogo, TweenInfo.new(0.8), {ImageTransparency = 1}):Play()
        TS:Create(IntroText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
        TS:Create(StatusText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
        fadeIntro:Play()
        fadeIntro.Completed:Wait()
        IntroGui:Destroy()
        IntroBlur:Destroy()

        if IntroConfig.IsSupported then
            self.MainFrame.Visible = true
            TS:Create(self.MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {GroupTransparency = 0, Size = UDim2.new(0, 400, 0, 260)}):Play()
        else
            self.ScreenGui:Destroy()
        end
    end

    function Window:AddTab(Name, Icon)
        local TabData = { Order = #self.Tabs + 1, Counters = 0 }

        local Btn = Make("TextButton", {Parent = self.Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, -6, 0, 34), Text = "", LayoutOrder = TabData.Order, AutoButtonColor = false})
        local Indicator = Make("Frame", {Parent = Btn, Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 4, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, BorderSizePixel = 0}, {
            Make("UICorner", {CornerRadius = UDim.new(0, 2)})
        })
        local IcoL = Make("TextLabel", {Parent = Btn, Text = Icon, Size = UDim2.new(0, 28, 1, 0), Position = UDim2.new(0, 12, 0, 0), TextColor3 = Color3.fromRGB(130, 130, 150), BackgroundTransparency = 1, TextSize = 13})
        local TxtL = Make("TextLabel", {Parent = Btn, Text = Name, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(130, 130, 150), Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 42, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})

        local Page = Make("ScrollingFrame", {Parent = self.Content, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, BorderSizePixel = 0}, {
            Make("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 16), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)})
        })
        local PL = Make("UIListLayout", {Parent = Page, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
        PL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, PL.AbsoluteContentSize.Y + 20) end)

        Btn.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do
                t.Ico.TextColor3 = Color3.fromRGB(130, 130, 150)
                t.Txt.TextColor3 = Color3.fromRGB(130, 130, 150)
                t.Page.Visible = false
                t.Ind.Size = UDim2.new(0, 3, 0, 0)
                t.Ind.BackgroundTransparency = 1
                t.Btn.BackgroundTransparency = 1
            end
            IcoL.TextColor3 = Quantum.ThemePalettes[self.CurrentTheme].Accent
            TxtL.TextColor3 = Color3.fromRGB(240, 240, 240)
            Page.Visible = true
            Indicator.Size = UDim2.new(0, 3, 0, 16)
            Indicator.BackgroundTransparency = 0
            Btn.BackgroundTransparency = 0.9
            Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end)

        table.insert(self.Tabs, {Ico = IcoL, Txt = TxtL, Page = Page, Ind = Indicator, Btn = Btn})
        if TabData.Order == 1 then
            IcoL.TextColor3 = Quantum.ThemePalettes[self.CurrentTheme].Accent
            TxtL.TextColor3 = Color3.fromRGB(240, 240, 240)
            Page.Visible = true
            Indicator.Size = UDim2.new(0, 3, 0, 16)
            Indicator.BackgroundTransparency = 0
            Btn.BackgroundTransparency = 0.9
            Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end

        local TabAPI = {}

        function TabAPI:AddLabel(LabelText)
            TabData.Counters = TabData.Counters + 1
            local Label = Make("TextLabel", {Parent = Page, Size = UDim2.new(1, -10, 0, 16), BackgroundTransparency = 1, Text = LabelText, TextColor3 = Color3.fromRGB(160, 160, 170), Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = TabData.Counters})
            return Label
        end

        function TabAPI:AddVersionBox(VersionText, DateText)
            TabData.Counters = TabData.Counters + 1
            local VerWrap = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(20, 25, 35), BackgroundTransparency = 0.2, Size = UDim2.new(0.96, 0, 0, 44)}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Make("UIStroke", {Color = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Thickness = 1, Transparency = 0.5})
            })
            Make("TextLabel", {Parent = VerWrap, Size = UDim2.new(1, -12, 0, 20), Position = UDim2.new(0, 8, 0, 5), BackgroundTransparency = 1, Text = VersionText, TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left})
            Make("TextLabel", {Parent = VerWrap, Size = UDim2.new(1, -12, 0, 18), Position = UDim2.new(0, 8, 0, 22), BackgroundTransparency = 1, Text = DateText, TextColor3 = Color3.fromRGB(130, 130, 150), Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left})
        end

        function TabAPI:AddProfile()
            TabData.Counters = TabData.Counters + 1
            local LP = Services.Players.LocalPlayer
            local Box = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(20, 25, 35), BackgroundTransparency = 0.2, Size = UDim2.new(0.96, 0, 0, 72)}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 8)}),
                Make("UIStroke", {Color = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Thickness = 1, Transparency = 0.5})
            })
            local Img = Make("ImageLabel", {Parent = Box, Size = UDim2.new(0, 52, 0, 52), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Color3.fromRGB(12, 12, 18)}, {
                Make("UICorner", {CornerRadius = UDim.new(1, 0)})
            })
            task.spawn(function() pcall(function() Img.Image = Services.Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end) end)
            Make("TextLabel", {Parent = Box, Text = LP.DisplayName, Position = UDim2.new(0, 72, 0, 16), Size = UDim2.new(0, 150, 0, 15), Font = Enum.Font.GothamBold, TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent, TextSize = 11, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            Make("TextLabel", {Parent = Box, Text = "@" .. LP.Name, Position = UDim2.new(0, 72, 0, 34), Size = UDim2.new(0, 150, 0, 14), Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(130, 130, 150), TextSize = 9, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
        end

        function TabAPI:AddDiscordLink(url)
            self:AddButton("Join Discord", function()
                -- [XENO PATCH] Pake SafeClipboard() biar support toclipboard & setclipboard
                if SafeClipboard(url) then
                    Window:Notify({ Title = "✅ Copied", Text = "Link Discord disalin ke clipboard!", Duration = 3 })
                else
                    Window:Notify({ Title = "❌ Gagal", Text = "Executor tidak support clipboard.", Duration = 3 })
                end
            end, "Copy Link")
        end

        function TabAPI:AddInfoBox(LabelText)
            TabData.Counters = TabData.Counters + 1
            local Box = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(20, 25, 35), BackgroundTransparency = 0.2, Size = UDim2.new(0.96, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Make("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}),
                Make("UIStroke", {Color = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Thickness = 1, Transparency = 0.5})
            })
            Make("TextLabel", {Parent = Box, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Text = LabelText, TextColor3 = Color3.fromRGB(220, 220, 220), Font = Enum.Font.Gotham, TextSize = 9, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top})
        end

        function TabAPI:AddButton(LabelText, Callback, Extra)
            TabData.Counters = TabData.Counters + 1
            local Section = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 0.3, Size = UDim2.new(1, -10, 0, 30)}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)})
            })
            Make("TextLabel", {Parent = Section, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(230, 230, 230), Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})

            local Btn = Make("TextButton", {Parent = Section, Size = UDim2.new(0, 76, 0, 20), Position = UDim2.new(1, -88, 0.5, -10), BackgroundColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Text = Extra or "Click", TextColor3 = Color3.new(0, 0, 0), Font = Enum.Font.GothamBold, TextSize = 9, AutoButtonColor = false}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)})
            })

            Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) end)
            Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent end)
            Btn.MouseButton1Click:Connect(Callback)
        end

        function TabAPI:AddToggle(LabelText, Callback)
            TabData.Counters = TabData.Counters + 1
            local Section = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 0.3, Size = UDim2.new(1, -10, 0, 30)}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)})
            })
            Make("TextLabel", {Parent = Section, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(230, 230, 230), Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})

            local On = false
            local Track = Make("Frame", {Parent = Section, Size = UDim2.new(0, 34, 0, 16), Position = UDim2.new(1, -42, 0.5, -8), BackgroundColor3 = Color3.fromRGB(45, 45, 55)}, {
                Make("UICorner", {CornerRadius = UDim.new(1, 0)})
            })
            local Knob = Make("Frame", {Parent = Track, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(180, 180, 190)}, {
                Make("UICorner", {CornerRadius = UDim.new(1, 0)})
            })

            local ClickArea = Make("TextButton", {Parent = Track, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false})
            ClickArea.MouseButton1Click:Connect(function()
                On = not On
                Track.BackgroundColor3 = On and Quantum.ThemePalettes[Window.CurrentTheme].Accent or Color3.fromRGB(45, 45, 55)
                Knob.BackgroundColor3 = On and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
                Knob.Position = On and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                Callback(On)
            end)
        end

        function TabAPI:AddInput(LabelText, Callback, Placeholder)
            TabData.Counters = TabData.Counters + 1
            local Section = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 0.3, Size = UDim2.new(1, -10, 0, 30)}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)})
            })
            Make("TextLabel", {Parent = Section, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(230, 230, 230), Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})

            local Box = Make("TextBox", {
                Parent = Section,
                Size = UDim2.new(0, 80, 0, 20),
                Position = UDim2.new(1, -92, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                BackgroundTransparency = 0.2,
                Text = "",
                PlaceholderText = Placeholder or "Type...",
                TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 9,
                ClearTextOnFocus = false
            }, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)}),
                Make("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)})
            })

            Box.Focused:Connect(function()
                Box.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                Box.SelectionStart = 1
                Box.CursorPosition = #Box.Text + 1
            end)
            Box.FocusLost:Connect(function()
                Box.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                Callback(Box.Text)
            end)
        end

        function TabAPI:AddSlider(LabelText, Callback, Opts)
            TabData.Counters = TabData.Counters + 1
            local Min, Max, Def = Opts.Min or 16, Opts.Max or 100, Opts.Def or 16

            local Wrap = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 0.3, Size = UDim2.new(1, -10, 0, 46)}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)})
            })
            Make("TextLabel", {Parent = Wrap, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(230, 230, 230), Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 10, 0, -10), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})

            local ValL = Make("TextLabel", {Parent = Wrap, Text = tostring(Def), Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Size = UDim2.new(0, 50, 0, 18), Position = UDim2.new(1, -56, 0, 2), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right})

            local SliderBg = Make("Frame", {Parent = Wrap, Size = UDim2.new(1, -20, 0, 5), Position = UDim2.new(0, 10, 0, 28), BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, {
                Make("UICorner", {CornerRadius = UDim.new(1, 0)})
            })
            local SliderFill = Make("Frame", {Parent = SliderBg, Size = UDim2.new((Def - Min) / (Max - Min), 0, 1, 0), BackgroundColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent}, {
                Make("UICorner", {CornerRadius = UDim.new(1, 0)})
            })

            local SliderBtn = Make("TextButton", {Parent = SliderBg, Size = UDim2.new(1, 0, 3, 0), Position = UDim2.new(0, 0, -1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false})
            local Dragging = false

            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                local value = math.floor(Min + ((Max - Min) * pos))
                ValL.Text = tostring(value)
                Callback(value)
            end

            SliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    UpdateSlider(input)
                end
            end)
            Services.UserInputService.InputEnded:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    Dragging = false
                end
            end)
            Services.UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
        end

        function TabAPI:AddRadio(LabelText, Callback, Opts)
            TabData.Counters = TabData.Counters + 1
            local Section = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 0.3, Size = UDim2.new(1, -10, 0, 30)}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)})
            })
            Make("TextLabel", {Parent = Section, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(230, 230, 230), Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})

            local Options = Opts.Options or {"Opt1", "Opt2"}
            local Default = Opts.Default or Options[1]
            local RadioCont = Make("Frame", {Parent = Section, Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 110, 0, 0), BackgroundTransparency = 1}, {
                Make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 12)})
            })

            local Checks = {}
            for i, optName in ipairs(Options) do
                local RBtn = Make("TextButton", {Parent = RadioCont, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = "", LayoutOrder = i, AutoButtonColor = false})
                local Circle = Make("Frame", {Parent = RBtn, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 0, 0.5, -7), BackgroundColor3 = Color3.fromRGB(25, 25, 30)}, {
                    Make("UICorner", {CornerRadius = UDim.new(1, 0)}),
                    Make("UIStroke", {Color = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Thickness = 1.5, Transparency = 0.5})
                })
                local Fill = Make("Frame", {Parent = Circle, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent, BorderSizePixel = 0}, {
                    Make("UICorner", {CornerRadius = UDim.new(1, 0)})
                })
                Checks[optName] = Fill
                Make("TextLabel", {Parent = RBtn, Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 18, 0, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = optName, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center})

                if optName == Default then Fill.Size = UDim2.new(0, 8, 0, 8) end

                RBtn.MouseButton1Click:Connect(function()
                    for key, f in pairs(Checks) do
                        f.Size = (key == optName) and UDim2.new(0, 8, 0, 8) or UDim2.new(0, 0, 0, 0)
                    end
                    Callback(optName)
                end)
            end
            return Section
        end

        function TabAPI:AddChoice(LabelText, Callback, Opts)
            TabData.Counters = TabData.Counters + 1
            local Wrap = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 0.25, Size = UDim2.new(1, -10, 0, 34), ClipsDescendants = true}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)}),
                Make("UIStroke", {Color = Color3.fromRGB(40, 40, 50), Transparency = 0.5, Thickness = 1})
            })
            local Head = Make("TextButton", {Parent = Wrap, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "", AutoButtonColor = false})
            Make("TextLabel", {Parent = Head, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(230, 230, 230), Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            local SelectedDisplay = Make("TextLabel", {Parent = Head, Text = "...", Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = Color3.fromRGB(130, 130, 150), Size = UDim2.new(0.5, -30, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right})
            local Arrow = Make("ImageLabel", {Parent = Head, Image = "rbxassetid://6031091004", Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -22, 0.5, -6), BackgroundTransparency = 1, ImageColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent})
            local ContentCont = Make("Frame", {Parent = Wrap, Size = UDim2.new(1, 0, 0, 110), Position = UDim2.new(0, 0, 0, 34), BackgroundTransparency = 1})
            local Scroll = Make("ScrollingFrame", {Parent = ContentCont, Size = UDim2.new(1, -14, 1, -8), Position = UDim2.new(0, 7, 0, 4), BackgroundColor3 = Color3.fromRGB(22, 22, 28), BackgroundTransparency = 0.3, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, BorderSizePixel = 0}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)}),
                Make("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)})
            })
            local SL = Make("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})

            local IsOpen = false

            local function BuildList(ItemsList)
                for _, v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                local validItems = ItemsList or {}
                if #validItems == 0 then validItems = {"[Kosong]"} end
                for i, opt in ipairs(validItems) do
                    local B = Make("TextButton", {Parent = Scroll, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "   " .. tostring(opt), TextColor3 = Color3.fromRGB(150, 150, 160), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i, AutoButtonColor = false})
                    B.MouseEnter:Connect(function() B.BackgroundColor3 = Color3.fromRGB(45, 45, 55); B.BackgroundTransparency = 0.3 end)
                    B.MouseLeave:Connect(function() B.BackgroundTransparency = 1 end)
                    B.MouseButton1Click:Connect(function()
                        if opt ~= "[Kosong]" then
                            SelectedDisplay.Text = tostring(opt)
                            SelectedDisplay.TextColor3 = Color3.fromRGB(240, 240, 240)
                            Callback(opt)
                        end
                        Head.MouseButton1Click:Fire()
                    end)
                end
                Scroll.CanvasSize = UDim2.new(0, 0, 0, SL.AbsoluteContentSize.Y + 8)
            end

            Head.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                if IsOpen then
                    if type(Opts) == "function" then BuildList(Opts()) else BuildList(Opts) end
                end
                Wrap.Size = IsOpen and UDim2.new(1, -10, 0, 148) or UDim2.new(1, -10, 0, 34)
                Arrow.Rotation = IsOpen and 180 or 0
            end)

            if type(Opts) ~= "function" then BuildList(Opts) end
        end

        function TabAPI:AddDropdown(LabelText, Callback, Opts)
            TabData.Counters = TabData.Counters + 1
            local Wrap = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 0.25, Size = UDim2.new(1, -10, 0, 34), ClipsDescendants = true}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)}),
                Make("UIStroke", {Color = Color3.fromRGB(40, 40, 50), Transparency = 0.5, Thickness = 1})
            })
            local Head = Make("TextButton", {Parent = Wrap, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "", AutoButtonColor = false})
            Make("TextLabel", {Parent = Head, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(230, 230, 230), Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            local SelectedDisplay = Make("TextLabel", {Parent = Head, Text = "Select...", Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = Color3.fromRGB(130, 130, 150), Size = UDim2.new(0.5, -30, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right})
            local Arrow = Make("ImageLabel", {Parent = Head, Image = "rbxassetid://6031091004", Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -22, 0.5, -6), BackgroundTransparency = 1, ImageColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent})
            local ContentCont = Make("Frame", {Parent = Wrap, Size = UDim2.new(1, 0, 0, 110), Position = UDim2.new(0, 0, 0, 34), BackgroundTransparency = 1})
            local Scroll = Make("ScrollingFrame", {Parent = ContentCont, Size = UDim2.new(1, -14, 1, -8), Position = UDim2.new(0, 7, 0, 4), BackgroundColor3 = Color3.fromRGB(22, 22, 28), BackgroundTransparency = 0.3, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, BorderSizePixel = 0}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)}),
                Make("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)})
            })
            local SL = Make("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})

            local IsOpen = false
            local PendingBtn, PendingItemName = nil, nil

            local function ResetPending()
                if PendingBtn and PendingBtn.Parent then
                    PendingBtn.Text = "   " .. tostring(PendingItemName)
                    PendingBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
                    PendingBtn.BackgroundTransparency = 1
                end
                PendingBtn, PendingItemName = nil, nil
            end

            local function BuildItems(items)
                ResetPending()
                for _, v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for i, item in ipairs(items) do
                    local B = Make("TextButton", {Parent = Scroll, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "   " .. item.Name, TextColor3 = Color3.fromRGB(150, 150, 160), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i, AutoButtonColor = false})
                    B.MouseEnter:Connect(function() if PendingBtn ~= B then B.BackgroundColor3 = Color3.fromRGB(45, 45, 55); B.BackgroundTransparency = 0.3 end end)
                    B.MouseLeave:Connect(function() if PendingBtn ~= B then B.BackgroundTransparency = 1 end end)
                    B.MouseButton1Click:Connect(function()
                        if PendingBtn == B then
                            SelectedDisplay.Text = item.Name
                            SelectedDisplay.TextColor3 = Color3.fromRGB(240, 240, 240)
                            ResetPending()
                            Callback(item.Pos)
                            Head.MouseButton1Click:Fire()
                        else
                            ResetPending()
                            PendingBtn = B
                            PendingItemName = item.Name
                            B.Text = "   [ Tap again to teleport ]"
                            B.TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent
                            B.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                            B.BackgroundTransparency = 0.2
                        end
                    end)
                end
                Scroll.CanvasSize = UDim2.new(0, 0, 0, SL.AbsoluteContentSize.Y + 8)
            end

            BuildItems(Opts)

            Head.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                if IsOpen and LabelText == "Teleport to Player" then
                    local pList = {}
                    for _, p in pairs(Services.Players:GetPlayers()) do
                        if p ~= Services.Players.LocalPlayer then
                            table.insert(pList, {Name = p.DisplayName .. " (@" .. p.Name .. ")", Pos = p})
                        end
                    end
                    BuildItems(pList)
                end
                if not IsOpen then ResetPending() end
                Wrap.Size = IsOpen and UDim2.new(1, -10, 0, 148) or UDim2.new(1, -10, 0, 34)
                Arrow.Rotation = IsOpen and 180 or 0
            end)
        end

        function TabAPI:AddMultiDropdown(LabelText, Callback, Opts)
            TabData.Counters = TabData.Counters + 1
            local Wrap = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 0.25, Size = UDim2.new(1, -10, 0, 34), ClipsDescendants = true}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)}),
                Make("UIStroke", {Color = Color3.fromRGB(40, 40, 50), Transparency = 0.5, Thickness = 1})
            })
            local Head = Make("TextButton", {Parent = Wrap, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "", AutoButtonColor = false})
            Make("TextLabel", {Parent = Head, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(230, 230, 230), Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            local SelectedDisplay = Make("TextLabel", {Parent = Head, Text = "Select...", Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = Color3.fromRGB(130, 130, 150), Size = UDim2.new(0.5, -30, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd})
            local Arrow = Make("ImageLabel", {Parent = Head, Image = "rbxassetid://6031091004", Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -22, 0.5, -6), BackgroundTransparency = 1, ImageColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent})
            local ContentCont = Make("Frame", {Parent = Wrap, Size = UDim2.new(1, 0, 0, 110), Position = UDim2.new(0, 0, 0, 34), BackgroundTransparency = 1})
            local Scroll = Make("ScrollingFrame", {Parent = ContentCont, Size = UDim2.new(1, -14, 1, -8), Position = UDim2.new(0, 7, 0, 4), BackgroundColor3 = Color3.fromRGB(22, 22, 28), BackgroundTransparency = 0.3, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent, BorderSizePixel = 0}, {
                Make("UICorner", {CornerRadius = UDim.new(0, 5)}),
                Make("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)})
            })
            local SL = Make("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})

            local IsOpen = false
            local SelectedItems = {}

            local function UpdateDisplay()
                if #SelectedItems == 0 then
                    SelectedDisplay.Text = "Select..."
                    SelectedDisplay.TextColor3 = Color3.fromRGB(130, 130, 150)
                else
                    SelectedDisplay.Text = table.concat(SelectedItems, ", ")
                    SelectedDisplay.TextColor3 = Color3.fromRGB(240, 240, 240)
                end
            end

            local function BuildItems(items)
                for _, v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for i, itemStr in ipairs(items) do
                    local B = Make("TextButton", {Parent = Scroll, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "   " .. tostring(itemStr), TextColor3 = Color3.fromRGB(150, 150, 160), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i, AutoButtonColor = false})
                    if table.find(SelectedItems, itemStr) then B.TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent end
                    B.MouseEnter:Connect(function() B.BackgroundColor3 = Color3.fromRGB(45, 45, 55); B.BackgroundTransparency = 0.3 end)
                    B.MouseLeave:Connect(function() B.BackgroundTransparency = 1 end)
                    B.MouseButton1Click:Connect(function()
                        local idx = table.find(SelectedItems, itemStr)
                        if idx then
                            table.remove(SelectedItems, idx)
                            B.TextColor3 = Color3.fromRGB(150, 150, 160)
                        else
                            table.insert(SelectedItems, itemStr)
                            B.TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent
                        end
                        UpdateDisplay()
                        Callback(SelectedItems)
                    end)
                end
                Scroll.CanvasSize = UDim2.new(0, 0, 0, SL.AbsoluteContentSize.Y + 8)
            end

            BuildItems(Opts or {})

            Head.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                Wrap.Size = IsOpen and UDim2.new(1, -10, 0, 148) or UDim2.new(1, -10, 0, 34)
                Arrow.Rotation = IsOpen and 180 or 0
            end)
        end

        TabAPI.Container = Page
        return TabAPI
    end

    return Window
end

return Quantum
