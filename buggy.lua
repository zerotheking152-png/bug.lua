local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Lighting = game:GetService("Lighting")
}

local function Make(className, properties, children)
    local inst = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then inst[prop] = value end
    end
    if properties and properties.Parent then inst.Parent = properties.Parent end
    for _, child in pairs(children or {}) do child.Parent = inst end
    return inst
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
    Window.NotifContainer = Make("Frame", {Parent = Window.ScreenGui, Size = UDim2.new(0, 300, 1, -20), Position = UDim2.new(1, -10, 0, 0), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1}, { Make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8)}) })
    
    -- ==================== [UPGRADE 1: SMOOTH OPEN/CLOSE SIZE TWEEN] ====================
    Window.MainFrame = Make("CanvasGroup", {Parent = Window.ScreenGui, BackgroundColor3 = Color3.fromRGB(255, 255, 255), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 0, 0, 0), Visible = false, GroupTransparency = 1, Active = true, Draggable = true}, {
        Make("UICorner", {CornerRadius = UDim.new(0, 10)}),
        Make("UIGradient", {Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Theme.Grad1), ColorSequenceKeypoint.new(1.00, Theme.Grad2)}, Rotation = 45})
    })

    Window.ToggleBtn = Make("ImageButton", {Parent = Window.ScreenGui, BackgroundColor3 = Color3.fromRGB(12, 12, 18), AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(0, 20, 0.5, 0), Size = UDim2.new(0, 0, 0, 0), Image = Config.ToggleIcon or "rbxassetid://131775361395370", Visible = false, Draggable = true}, { Make("UICorner", {CornerRadius = UDim.new(0, 12)}), Make("UIStroke", {Color = Theme.Accent}) })
    
    local InnerFrame = Make("Frame", {Parent = Window.MainFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ClipsDescendants = true}, { Make("UICorner", {CornerRadius = UDim.new(0, 10)}) })
    
    -- ==================== [UPGRADE 2: TITLE & SUBTITLE CENTER-ALIGNED] ====================
    Make("TextLabel", {
        Parent = InnerFrame, 
        Text = Config.Title .. " | " .. Config.Subtitle, 
        TextColor3 = Theme.Accent, 
        Font = Enum.Font.GothamBlack, 
        TextSize = 11, 
        Position = UDim2.new(0.5, 0, 0, 10), 
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(1, -60, 0, 15), 
        BackgroundTransparency = 1, 
        TextXAlignment = Enum.TextXAlignment.Center
    })

    local CloseBtn = Make("TextButton", {
        Parent = InnerFrame,
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 80, 80),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -30, 0, 5)
    }, {
        Make("UIStroke", {Color = Color3.fromRGB(255, 50, 50), Thickness = 2}),
    })

    local MinBtn = Make("TextButton", {
        Parent = InnerFrame,
        Text = "-",
        TextColor3 = Color3.fromRGB(130, 130, 150),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 26,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -55, 0, 5)
    }, {
        Make("UIStroke", {Color = Color3.fromRGB(130, 130, 150), Thickness = 2}),
    })

    local Body = Make("Frame", {Parent = InnerFrame, Size = UDim2.new(1, 0, 1, -35), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1})
    Window.Sidebar = Make("ScrollingFrame", {Parent = Body, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.5, Size = UDim2.new(0, 110, 1, 0), BorderSizePixel = 0, ScrollBarThickness = 2}, { Make("UICorner", {CornerRadius = UDim.new(0, 8)}) })
    local SideList = Make("UIListLayout", {Parent = Window.Sidebar, Padding = UDim.new(0, 2)})
    SideList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Window.Sidebar.CanvasSize = UDim2.new(0, 0, 0, SideList.AbsoluteContentSize.Y + 30) end)
    Window.Content = Make("Frame", {Parent = Body, BackgroundTransparency = 1, Position = UDim2.new(0, 115, 0, 0), Size = UDim2.new(1, -120, 1, 0)})

    -- ==================== [UPGRADE 3: SMOOTH CLOSE WITH SCALE DOWN] ====================
    CloseBtn.MouseButton1Click:Connect(function()
        Services.TweenService:Create(Window.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            GroupTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.3)
        Window.ScreenGui:Destroy()
    end)

    -- ==================== [UPGRADE 4: SMOOTH MINIMIZE WITH SCALE DOWN] ====================
    MinBtn.MouseButton1Click:Connect(function()
        Services.TweenService:Create(Window.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            GroupTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.3)
        Window.MainFrame.Visible = false
        Window.ToggleBtn.Visible = true
        -- Smooth pop-in for toggle button
        Services.TweenService:Create(Window.ToggleBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 40, 0, 40)
        }):Play()
    end)

    -- ==================== [UPGRADE 5: SMOOTH OPEN FROM TOGGLE WITH SCALE UP] ====================
    Window.ToggleBtn.MouseButton1Click:Connect(function()
        Window.ToggleBtn.Visible = false
        Window.MainFrame.Visible = true
        Services.TweenService:Create(Window.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            GroupTransparency = 0,
            Size = UDim2.new(0, 400, 0, 260)
        }):Play()
    end)

    function Window:Notify(NConfig)
        local Duration = NConfig.Duration or 3
        local NFrame = Make("Frame", {Parent = self.NotifContainer, BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY, ClipsDescendants = true, Position = UDim2.new(1, 50, 0, 0)}, {
            Make("UICorner", {CornerRadius = UDim.new(0, 6)}), Make("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}), Make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        })
        local NStroke = Make("UIStroke", {Parent = NFrame, Color = Quantum.ThemePalettes[self.CurrentTheme].Accent, Transparency = 1})
        local TopContent = Make("Frame", {Parent = NFrame, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY}, { Make("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 10)}) })
        local Logo = Make("ImageLabel", {Parent = TopContent, Size = UDim2.new(0, 28, 0, 28), BackgroundTransparency = 1, ImageTransparency = 1, Image = "rbxassetid://131775361395370"}, { Make("UICorner", {CornerRadius = UDim.new(1, 0)}) })
        local TextContainer = Make("Frame", {Parent = TopContent, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.XY}, { Make("UIListLayout", {Padding = UDim.new(0, 2)}), Make("UISizeConstraint", {MaxSize = Vector2.new(220, 9999)}) })
        local NTitle = Make("TextLabel", {Parent = TextContainer, BackgroundTransparency = 1, TextTransparency = 1, Text = NConfig.Title or "Quantum X", TextColor3 = Quantum.ThemePalettes[self.CurrentTheme].Accent, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY})
        local NText = Make("TextLabel", {Parent = TextContainer, BackgroundTransparency = 1, TextTransparency = 1, Text = NConfig.Text or "", TextColor3 = Color3.fromRGB(240, 240, 240), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY, TextWrapped = true})
        local ProgressBg = Make("Frame", {Parent = NFrame, Size = UDim2.new(1, 20, 0, 3), Position = UDim2.new(0, -10, 0, 0), BackgroundColor3 = Color3.fromRGB(30, 30, 40), BackgroundTransparency = 1, BorderSizePixel = 0})
        local ProgressFill = Make("Frame", {Parent = ProgressBg, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Quantum.ThemePalettes[self.CurrentTheme].Accent, BackgroundTransparency = 1, BorderSizePixel = 0})

        Services.TweenService:Create(NFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        Services.TweenService:Create(NFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
        Services.TweenService:Create(NStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
        Services.TweenService:Create(NTitle, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        Services.TweenService:Create(NText, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        Services.TweenService:Create(Logo, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
        Services.TweenService:Create(ProgressBg, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        Services.TweenService:Create(ProgressFill, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()

        task.spawn(function()
            Services.TweenService:Create(ProgressFill, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
            task.wait(Duration)
            Services.TweenService:Create(NFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 0, 0)}):Play()
            local fade = Services.TweenService:Create(NFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1})
            Services.TweenService:Create(NStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
            Services.TweenService:Create(NTitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            Services.TweenService:Create(NText, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            Services.TweenService:Create(Logo, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
            Services.TweenService:Create(ProgressBg, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            Services.TweenService:Create(ProgressFill, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            fade:Play()
            fade.Completed:Wait()
            NFrame:Destroy()
        end)
    end

    function Window:PlayIntro(IntroConfig)
        local IntroBlur = Make("BlurEffect", {Parent = Services.Lighting, Size = 0})
        local IntroGui = Make("ScreenGui", {Parent = Services.CoreGui})
        local CenterFrame = Make("Frame", {Parent = IntroGui, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1}, { Make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 15)}) })
        local IntroLogo = Make("ImageLabel", {Parent = CenterFrame, Image = "rbxassetid://131775361395370", Size = UDim2.new(0, 120, 0, 120), BackgroundTransparency = 1, ImageTransparency = 1, LayoutOrder = 1}, { Make("UICorner", {CornerRadius = UDim.new(1, 0)}) })
        local TextClip = Make("Frame", {Parent = CenterFrame, BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.new(0, 0, 0, 120), LayoutOrder = 2})
        local IntroText = Make("TextLabel", {Parent = TextClip, Text = "Quantum Community", Font = Enum.Font.GothamBlack, TextSize = 28, TextColor3 = Quantum.ThemePalettes[self.CurrentTheme].Accent, Size = UDim2.new(0, 320, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
        local IntroTextStroke = Make("UIStroke", {Parent = IntroText, Color = Color3.fromRGB(0, 0, 0), Thickness = 2, Transparency = 0})
        local StatusText = Make("TextLabel", {Parent = IntroGui, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0.85, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextTransparency = 1})

        if IntroConfig.IsSupported then StatusText.Text = "✅ Map Supported: " .. IntroConfig.MapName; StatusText.TextColor3 = Quantum.ThemePalettes[self.CurrentTheme].Accent
        else StatusText.Text = "❌ Map Tidak Didukung!"; StatusText.TextColor3 = Color3.fromRGB(255, 80, 80) end

        local TS = Services.TweenService
        TS:Create(IntroBlur, TweenInfo.new(1), {Size = 24}):Play()
        CenterFrame.Position = UDim2.new(0, 0, -1, 0)
        IntroLogo.ImageTransparency = 0
        TS:Create(CenterFrame, TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        TS:Create(StatusText, TweenInfo.new(1), {TextTransparency = 0}):Play()
        task.wait(1.5)
        TS:Create(TextClip, TweenInfo.new(1.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 320, 0, 120)}):Play()
        task.wait(2.5)
        TS:Create(IntroBlur, TweenInfo.new(0.8), {Size = 0}):Play()
        local fadeIntro = TS:Create(CenterFrame, TweenInfo.new(0.8), {BackgroundTransparency = 1})
        TS:Create(IntroLogo, TweenInfo.new(0.8), {ImageTransparency = 1}):Play()
        TS:Create(IntroText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
        TS:Create(IntroTextStroke, TweenInfo.new(0.8), {Transparency = 1}):Play()
        TS:Create(StatusText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
        fadeIntro:Play()
        fadeIntro.Completed:Wait()
        IntroGui:Destroy()
        IntroBlur:Destroy()

        if IntroConfig.IsSupported then
            self.MainFrame.Visible = true
            -- ==================== [UPGRADE: SMOOTH INTRO OPEN] ====================
            TS:Create(self.MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                GroupTransparency = 0,
                Size = UDim2.new(0, 400, 0, 260)
            }):Play()
        else
            self.ScreenGui:Destroy()
        end
    end

    function Window:AddTab(Name, Icon)
        local TabData = { Order = #self.Tabs + 1, Counters = 0 }
        local Btn = Make("TextButton", {Parent = self.Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35), Text = "", LayoutOrder = TabData.Order})
        local IcoL = Make("TextLabel", {Parent = Btn, Text = Icon, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextColor3 = Color3.fromRGB(130, 130, 150), BackgroundTransparency = 1, TextSize = 14})
        local TxtL = Make("TextLabel", {Parent = Btn, Text = Name, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(130, 130, 150), Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 47, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
        
        local Page = Make("ScrollingFrame", {Parent = self.Content, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2}, { Make("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 20)}) })
        local PL = Make("UIListLayout", {Parent = Page, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
        PL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, PL.AbsoluteContentSize.Y + 30) end)

        Btn.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do t.Ico.TextColor3 = Color3.fromRGB(130, 130, 150); t.Txt.TextColor3 = Color3.fromRGB(130, 130, 150); t.Page.Visible = false end
            IcoL.TextColor3 = Quantum.ThemePalettes[self.CurrentTheme].Accent; TxtL.TextColor3 = Color3.fromRGB(240, 240, 240); Page.Visible = true
        end)
        
        table.insert(self.Tabs, {Ico = IcoL, Txt = TxtL, Page = Page})
        if TabData.Order == 1 then
            IcoL.TextColor3 = Quantum.ThemePalettes[self.CurrentTheme].Accent; TxtL.TextColor3 = Color3.fromRGB(240, 240, 240); Page.Visible = true
        end

        local TabAPI = {}
        
        function TabAPI:AddLabel(LabelText)
            TabData.Counters = TabData.Counters + 1
            local Label = Make("TextLabel", {Parent = Page, Size = UDim2.new(1, -10, 0, 18), BackgroundTransparency = 1, Text = LabelText, TextColor3 = Color3.fromRGB(180, 180, 180), Font = Enum.Font.GothamBold, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = TabData.Counters})
            return Label
        end

        function TabAPI:AddVersionBox(VersionText, DateText)
            TabData.Counters = TabData.Counters + 1
            local VerWrap = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(20, 25, 35), BackgroundTransparency = 0.3, Size = UDim2.new(0.96, 0, 0, 45)}, { 
                Make("UICorner", {CornerRadius = UDim.new(0, 6)}), 
                Make("UIStroke", {Color = Quantum.ThemePalettes[Window.CurrentTheme].Accent}) 
            })
            Make("TextLabel", {Parent = VerWrap, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 5, 0, 5), BackgroundTransparency = 1, Text = VersionText, TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left})
            Make("TextLabel", {Parent = VerWrap, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 5, 0, 20), BackgroundTransparency = 1, Text = DateText, TextColor3 = Color3.fromRGB(130, 130, 150), Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left})
        end

        function TabAPI:AddProfile()
            TabData.Counters = TabData.Counters + 1
            local LP = Services.Players.LocalPlayer
            local Box = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(20, 25, 35), BackgroundTransparency = 0.3, Size = UDim2.new(0.96, 0, 0, 75)}, { Make("UICorner", {CornerRadius = UDim.new(0, 6)}) })
            Make("UIStroke", {Parent = Box, Color = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Transparency = 0.5})
            local Img = Make("ImageLabel", {Parent = Box, Size = UDim2.new(0, 55, 0, 55), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Color3.fromRGB(12, 12, 18)}, { Make("UICorner", {CornerRadius = UDim.new(1,0)}) })
            task.spawn(function() pcall(function() Img.Image = Services.Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end) end)
            Make("TextLabel", {Parent = Box, Text = LP.DisplayName, Position = UDim2.new(0, 75, 0, 18), Size = UDim2.new(0, 150, 0, 15), Font = Enum.Font.GothamBold, TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent, TextSize = 11, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            Make("TextLabel", {Parent = Box, Text = "@" .. LP.Name, Position = UDim2.new(0, 75, 0, 35), Size = UDim2.new(0, 150, 0, 15), Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(130, 130, 150), TextSize = 9, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
        end

        function TabAPI:AddDiscordLink(url)
            self:AddButton("Join Discord", function()
                if setclipboard then setclipboard(url); Window:Notify({ Title = "✅ Copied", Text = "Link Discord disalin ke clipboard!", Duration = 3 })
                else Window:Notify({ Title = "❌ Gagal", Text = "Executor tidak support setclipboard.", Duration = 3 }) end
            end, "Copy Link")
        end

        function TabAPI:AddInfoBox(LabelText)
            TabData.Counters = TabData.Counters + 1
            local Box = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(20, 25, 35), BackgroundTransparency = 0.3, Size = UDim2.new(0.96, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y}, { Make("UICorner", {CornerRadius = UDim.new(0, 6)}), Make("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}) })
            Make("UIStroke", {Parent = Box, Color = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Transparency = 0.5})
            Make("TextLabel", {Parent = Box, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Text = LabelText, TextColor3 = Color3.fromRGB(240, 240, 240), Font = Enum.Font.Gotham, TextSize = 9, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top})
        end

        function TabAPI:AddButton(LabelText, Callback, Extra)
            TabData.Counters = TabData.Counters + 1
            local Section = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.6, Size = UDim2.new(1, -10, 0, 28)}, { Make("UICorner", {CornerRadius = UDim.new(0, 4)}) })
            Make("TextLabel", {Parent = Section, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(240, 240, 240), Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            local Btn = Make("TextButton", {Parent = Section, Size = UDim2.new(0, 80, 0, 18), Position = UDim2.new(1, -90, 0.5, -9), BackgroundColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Text = Extra or "Click", TextColor3 = Color3.new(0, 0, 0), Font = Enum.Font.GothamBold, TextSize = 9}, { Make("UICorner", {CornerRadius = UDim.new(0, 4)}) })
            Btn.MouseButton1Click:Connect(Callback)
        end

        function TabAPI:AddToggle(LabelText, Callback)
            TabData.Counters = TabData.Counters + 1
            local Section = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.6, Size = UDim2.new(1, -10, 0, 28)}, { Make("UICorner", {CornerRadius = UDim.new(0, 4)}) })
            Make("TextLabel", {Parent = Section, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(240, 240, 240), Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            local On = false
            local Tog = Make("TextButton", {Parent = Section, Size = UDim2.new(0, 28, 0, 14), Position = UDim2.new(1, -35, 0.5, -7), Text = "", BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, { Make("UICorner", {CornerRadius = UDim.new(1, 0)}) })
            Tog.MouseButton1Click:Connect(function() On = not On; Tog.BackgroundColor3 = On and Quantum.ThemePalettes[Window.CurrentTheme].Accent or Color3.fromRGB(60, 60, 60); Callback(On) end)
        end

        -- ==================== [UPGRADE 6: INPUT TEXT PERSISTENT + AUTO SELECT] ====================
        function TabAPI:AddInput(LabelText, Callback, Placeholder)
            TabData.Counters = TabData.Counters + 1
            local Section = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.6, Size = UDim2.new(1, -10, 0, 28)}, { Make("UICorner", {CornerRadius = UDim.new(0, 4)}) })
            Make("TextLabel", {Parent = Section, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(240, 240, 240), Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            local Box = Make("TextBox", {Parent = Section, Size = UDim2.new(0, 70, 0, 18), Position = UDim2.new(1, -80, 0.5, -9), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Text = "", PlaceholderText = Placeholder or "Set...", TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Font = Enum.Font.Gotham, TextSize = 9}, { Make("UICorner", {CornerRadius = UDim.new(0, 4)}) })
            
            -- Simpan text history biar tetap ada pas fokus ulang
            local CurrentText = ""
            
            Box.Focused:Connect(function()
                -- Text tetap ada, nggak ilang
                Box.Text = CurrentText
                -- Auto select all text pas klik
                Box.CursorPosition = #Box.Text + 1
                Box.SelectionStart = 1
            end)
            
            Box.FocusLost:Connect(function()
                CurrentText = Box.Text
                Callback(Box.Text)
            end)
            
            -- Update history pas text berubah
            Box:GetPropertyChangedSignal("Text"):Connect(function()
                CurrentText = Box.Text
            end)
        end

        function TabAPI:AddSlider(LabelText, Callback, Opts)
            TabData.Counters = TabData.Counters + 1
            local Min, Max, Def = Opts.Min or 16, Opts.Max or 100, Opts.Def or 16
            local Wrap = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.6, Size = UDim2.new(1, -10, 0, 45)}, { Make("UICorner", {CornerRadius = UDim.new(0, 4)}) })
            Make("TextLabel", {Parent = Wrap, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(240, 240, 240), Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 10, 0, -10), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            local ValL = Make("TextLabel", {Parent = Wrap, Text = tostring(Def), Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent, Size = UDim2.new(0, 50, 0, 20), Position = UDim2.new(1, -60, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right})
            local SliderBg = Make("Frame", {Parent = Wrap, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 28), BackgroundColor3 = Color3.fromRGB(50, 50, 60)}, { Make("UICorner", {CornerRadius = UDim.new(1, 0)}) })
            local SliderFill = Make("Frame", {Parent = SliderBg, Size = UDim2.new((Def - Min) / (Max - Min), 0, 1, 0), BackgroundColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent}, { Make("UICorner", {CornerRadius = UDim.new(1, 0)}) })
            local SliderBtn = Make("TextButton", {Parent = SliderBg, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})
            local Dragging = false
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                local value = math.floor(Min + ((Max - Min) * pos))
                ValL.Text = tostring(value); Callback(value)
            end
            SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = true; UpdateSlider(input) end end)
            Services.UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)
            Services.UserInputService.InputChanged:Connect(function(input) if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSlider(input) end end)
        end

        function TabAPI:AddRadio(LabelText, Callback, Opts)
            TabData.Counters = TabData.Counters + 1
            local Section = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.6, Size = UDim2.new(1, -10, 0, 28)}, { Make("UICorner", {CornerRadius = UDim.new(0, 4)}) })
            Make("TextLabel", {Parent = Section, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(240, 240, 240), Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            
            local Options = Opts.Options or {"Opt1", "Opt2"}
            local Default = Opts.Default or Options[1]
            local RadioCont = Make("Frame", {Parent = Section, Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 110, 0, 0), BackgroundTransparency = 1}, { Make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 15)}) })
            
            local Checks = {}
            for i, optName in ipairs(Options) do
                local RBtn = Make("TextButton", {Parent = RadioCont, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = "", LayoutOrder = i})
                local Circle = Make("Frame", {Parent = RBtn, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 0, 0.5, -7), BackgroundColor3 = Color3.fromRGB(20, 20, 25)}, { Make("UICorner", {CornerRadius = UDim.new(1, 0)}), Make("UIStroke", {Color = Quantum.ThemePalettes[Window.CurrentTheme].Accent}) })
                Checks[optName] = Make("TextLabel", {Parent = Circle, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "✓", TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent, TextSize = 10, Font = Enum.Font.GothamBold, Visible = (optName == Default)})
                Make("TextLabel", {Parent = RBtn, Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 20, 0, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = optName, TextColor3 = Color3.fromRGB(240, 240, 240), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center})
                
                RBtn.MouseButton1Click:Connect(function() for key, chk in pairs(Checks) do chk.Visible = (key == optName) end; Callback(optName) end)
            end
            return Section
        end

        function TabAPI:AddChoice(LabelText, Callback, Opts)
            TabData.Counters = TabData.Counters + 1
            local Wrap = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(15, 15, 20), Size = UDim2.new(1, -10, 0, 35), ClipsDescendants = true}, { Make("UICorner", {CornerRadius = UDim.new(0, 4)}), Make("UIStroke", {Color = Color3.fromRGB(30, 30, 40), Transparency = 0}) })
            local Head = Make("TextButton", {Parent = Wrap, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Text = ""})
            Make("TextLabel", {Parent = Head, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(240, 240, 240), Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            local SelectedDisplay = Make("TextLabel", {Parent = Head, Text = "...", Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = Color3.fromRGB(130, 130, 150), Size = UDim2.new(0.5, -30, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right})
            local Arrow = Make("ImageLabel", {Parent = Head, Image = "rbxassetid://6031091004", Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -22, 0.5, -7), BackgroundTransparency = 1, ImageColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent})
            local ContentCont = Make("Frame", {Parent = Wrap, Size = UDim2.new(1, 0, 0, 110), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1})
            local Scroll = Make("ScrollingFrame", {Parent = ContentCont, Size = UDim2.new(1, -16, 1, -10), Position = UDim2.new(0, 8, 0, 5), BackgroundColor3 = Color3.fromRGB(22, 22, 28), ScrollBarThickness = 2, BorderSizePixel = 0}, { Make("UICorner", {CornerRadius = UDim.new(0, 6)}), Make("UIStroke", {Color = Color3.fromRGB(40, 40, 50), Transparency = 0.5}), Make("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)}) })
            local SL = Make("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder})
            
            local IsOpen = false
            
            local function BuildList(ItemsList)
                for _, v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                local validItems = ItemsList or {}
                if #validItems == 0 then validItems = {"[Kosong]"} end
                
                for i, opt in ipairs(validItems) do
                    local B = Make("TextButton", {Parent = Scroll, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "   " .. tostring(opt), TextColor3 = Color3.fromRGB(130, 130, 150), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i})
                    B.MouseEnter:Connect(function() Services.TweenService:Create(B, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45), BackgroundTransparency = 0}):Play() end)
                    B.MouseLeave:Connect(function() Services.TweenService:Create(B, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end)
                    B.MouseButton1Click:Connect(function() 
                        if opt ~= "[Kosong]" then
                            SelectedDisplay.Text = tostring(opt)
                            SelectedDisplay.TextColor3 = Color3.fromRGB(240, 240, 240)
                            Callback(opt) 
                        end
                        Head.MouseButton1Click:Fire() 
                    end)
                end
                Scroll.CanvasSize = UDim2.new(0,0,0,SL.AbsoluteContentSize.Y + 10)
            end

            Head.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                if IsOpen then
                    if type(Opts) == "function" then BuildList(Opts()) else BuildList(Opts) end
                end
                Services.TweenService:Create(Wrap, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = IsOpen and UDim2.new(1, -10, 0, 150) or UDim2.new(1, -10, 0, 35)}):Play()
                Services.TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen and 180 or 0}):Play()
            end)
            
            if type(Opts) ~= "function" then BuildList(Opts) end
        end

        function TabAPI:AddDropdown(LabelText, Callback, Opts)
            TabData.Counters = TabData.Counters + 1
            local Wrap = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(15, 15, 20), Size = UDim2.new(1, -10, 0, 35), ClipsDescendants = true}, { Make("UICorner", {CornerRadius = UDim.new(0, 4)}), Make("UIStroke", {Color = Color3.fromRGB(30, 30, 40), Transparency = 0}) })
            local Head = Make("TextButton", {Parent = Wrap, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Text = ""})
            Make("TextLabel", {Parent = Head, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(240, 240, 240), Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            local SelectedDisplay = Make("TextLabel", {Parent = Head, Text = "Select...", Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = Color3.fromRGB(130, 130, 150), Size = UDim2.new(0.5, -30, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right})
            local Arrow = Make("ImageLabel", {Parent = Head, Image = "rbxassetid://6031091004", Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -22, 0.5, -7), BackgroundTransparency = 1, ImageColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent})
            local ContentCont = Make("Frame", {Parent = Wrap, Size = UDim2.new(1, 0, 0, 110), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1})
            local Scroll = Make("ScrollingFrame", {Parent = ContentCont, Size = UDim2.new(1, -16, 1, -10), Position = UDim2.new(0, 8, 0, 5), BackgroundColor3 = Color3.fromRGB(22, 22, 28), ScrollBarThickness = 2, BorderSizePixel = 0}, { Make("UICorner", {CornerRadius = UDim.new(0, 6)}), Make("UIStroke", {Color = Color3.fromRGB(40, 40, 50), Transparency = 0.5}), Make("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)}) })
            local SL = Make("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder})
            
            local IsOpen = false
            local PendingBtn = nil
            local PendingItemName = nil

            local function ResetPending()
                if PendingBtn and PendingBtn.Parent then
                    PendingBtn.Text = "   " .. tostring(PendingItemName)
                    PendingBtn.TextColor3 = Color3.fromRGB(130, 130, 150)
                    Services.TweenService:Create(PendingBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 28), BackgroundTransparency = 1}):Play()
                end
                PendingBtn = nil
                PendingItemName = nil
            end

            local function BuildItems(items)
                ResetPending()
                for _, v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for i, item in ipairs(items) do
                    local B = Make("TextButton", {Parent = Scroll, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "   " .. item.Name, TextColor3 = Color3.fromRGB(130, 130, 150), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i})
                    B.MouseEnter:Connect(function() 
                        if PendingBtn ~= B then Services.TweenService:Create(B, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45), BackgroundTransparency = 0}):Play() end
                    end)
                    B.MouseLeave:Connect(function() 
                        if PendingBtn ~= B then Services.TweenService:Create(B, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end
                    end)
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
                            Services.TweenService:Create(B, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 50), BackgroundTransparency = 0}):Play()
                        end
                    end)
                end
                Scroll.CanvasSize = UDim2.new(0, 0, 0, SL.AbsoluteContentSize.Y + 10)
            end
            
            BuildItems(Opts)
            
            Head.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                if IsOpen and LabelText == "Teleport to Player" then
                    local pList = {}
                    for _, p in pairs(Services.Players:GetPlayers()) do if p ~= Services.Players.LocalPlayer then table.insert(pList, {Name = p.DisplayName .. " (@" .. p.Name .. ")", Pos = p}) end end
                    BuildItems(pList)
                end
                if not IsOpen then ResetPending() end
                Services.TweenService:Create(Wrap, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = IsOpen and UDim2.new(1, -10, 0, 150) or UDim2.new(1, -10, 0, 35)}):Play()
                Services.TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen and 180 or 0}):Play()
            end)
        end

        function TabAPI:AddMultiDropdown(LabelText, Callback, Opts)
            TabData.Counters = TabData.Counters + 1
            local Wrap = Make("Frame", {Parent = Page, LayoutOrder = TabData.Counters, BackgroundColor3 = Color3.fromRGB(15, 15, 20), Size = UDim2.new(1, -10, 0, 35), ClipsDescendants = true}, { Make("UICorner", {CornerRadius = UDim.new(0, 4)}), Make("UIStroke", {Color = Color3.fromRGB(30, 30, 40), Transparency = 0}) })
            local Head = Make("TextButton", {Parent = Wrap, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Text = ""})
            Make("TextLabel", {Parent = Head, Text = LabelText, Font = Enum.Font.GothamBold, TextSize = 9, TextColor3 = Color3.fromRGB(240, 240, 240), Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
            local SelectedDisplay = Make("TextLabel", {Parent = Head, Text = "Select...", Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = Color3.fromRGB(130, 130, 150), Size = UDim2.new(0.5, -30, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd})
            local Arrow = Make("ImageLabel", {Parent = Head, Image = "rbxassetid://6031091004", Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -22, 0.5, -7), BackgroundTransparency = 1, ImageColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent})
            local ContentCont = Make("Frame", {Parent = Wrap, Size = UDim2.new(1, 0, 0, 110), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1})
            local Scroll = Make("ScrollingFrame", {Parent = ContentCont, Size = UDim2.new(1, -16, 1, -10), Position = UDim2.new(0, 8, 0, 5), BackgroundColor3 = Color3.fromRGB(22, 22, 28), ScrollBarThickness = 2, BorderSizePixel = 0}, { Make("UICorner", {CornerRadius = UDim.new(0, 6)}), Make("UIStroke", {Color = Color3.fromRGB(40, 40, 50), Transparency = 0.5}), Make("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)}) })
            local SL = Make("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder})
            
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
                    local B = Make("TextButton", {Parent = Scroll, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = "   " .. tostring(itemStr), TextColor3 = Color3.fromRGB(130, 130, 150), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i})
                    
                    if table.find(SelectedItems, itemStr) then B.TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent end

                    B.MouseEnter:Connect(function() Services.TweenService:Create(B, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45), BackgroundTransparency = 0}):Play() end)
                    B.MouseLeave:Connect(function() Services.TweenService:Create(B, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end)
                    
                    B.MouseButton1Click:Connect(function()
                        local idx = table.find(SelectedItems, itemStr)
                        if idx then
                            table.remove(SelectedItems, idx)
                            B.TextColor3 = Color3.fromRGB(130, 130, 150)
                        else
                            table.insert(SelectedItems, itemStr)
                            B.TextColor3 = Quantum.ThemePalettes[Window.CurrentTheme].Accent
                        end
                        UpdateDisplay()
                        Callback(SelectedItems)
                    end)
                end
                Scroll.CanvasSize = UDim2.new(0, 0, 0, SL.AbsoluteContentSize.Y + 10)
            end
            
            BuildItems(Opts or {})
            
            Head.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                Services.TweenService:Create(Wrap, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = IsOpen and UDim2.new(1, -10, 0, 150) or UDim2.new(1, -10, 0, 35)}):Play()
                Services.TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = IsOpen and 180 or 0}):Play()
            end)
        end

        TabAPI.Container = Page

        return TabAPI
    end

    return Window
end

return Quantum
