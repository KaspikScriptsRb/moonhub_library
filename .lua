-- Modified UI Library by @qkaspq (Design: COMPKILLER Style)
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local theme = {
    Background = Color3.fromRGB(11, 12, 16),
    Sidebar = Color3.fromRGB(18, 20, 26),
    Section = Color3.fromRGB(20, 22, 28),
    Accent = Color3.fromRGB(0, 220, 255),
    AccentDark = Color3.fromRGB(0, 150, 180),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(140, 145, 160),
    Stroke = Color3.fromRGB(35, 38, 45),
    Element = Color3.fromRGB(28, 31, 38)
}

local function tween(object, properties, duration)
    TweenService:Create(object, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quint), properties):Play()
end

-- Вспомогательные функции
local function createRound(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 6)
    c.Parent = parent
    return c
end

local function createStroke(parent, color, thickness, trans)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = trans or 0
    s.Parent = parent
    return s
end

local Library = {}
Library.__index = Library

function Library:CreateWindow(options)
    options = options or {}
    local window = setmetatable({}, Library)

    local gui = Instance.new("ScreenGui")
    gui.Name = "CompkillerUI"
    gui.Parent = CoreGui

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 700, 0, 480)
    container.Position = UDim2.new(0.5, -350, 0.5, -240)
    container.BackgroundColor3 = theme.Background
    container.BorderSizePixel = 0
    container.Parent = gui
    createRound(container, UDim.new(0, 10))
    createStroke(container, theme.Stroke, 1.5)

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 180, 1, 0)
    sidebar.BackgroundColor3 = theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = container
    createRound(sidebar, UDim.new(0, 10))

    -- Logo Area
    local logoArea = Instance.new("Frame")
    logoArea.Size = UDim2.new(1, 0, 0, 60)
    logoArea.BackgroundTransparency = 1
    logoArea.Parent = sidebar

    local logoIcon = Instance.new("ImageLabel")
    logoIcon.Size = UDim2.new(0, 35, 0, 35)
    logoIcon.Position = UDim2.new(0, 15, 0.5, -17)
    logoIcon.Image = "rbxassetid://13161991129" -- Твой ID лого
    logoIcon.ImageColor3 = theme.Accent
    logoIcon.BackgroundTransparency = 1
    logoIcon.Parent = logoArea

    local logoTitle = Instance.new("TextLabel")
    logoTitle.Text = (options.Title or "COMPKILLER"):upper()
    logoTitle.Font = Enum.Font.GothamBold
    logoTitle.TextSize = 16
    logoTitle.TextColor3 = theme.Text
    logoTitle.Position = UDim2.new(0, 60, 0.5, -8)
    logoTitle.TextXAlignment = Enum.TextXAlignment.Left
    logoTitle.BackgroundTransparency = 1
    logoTitle.Parent = logoArea

    -- Tabs Container
    local tabsScroll = Instance.new("ScrollingFrame")
    tabsScroll.Size = UDim2.new(1, 0, 1, -130)
    tabsScroll.Position = UDim2.new(0, 0, 0, 70)
    tabsScroll.BackgroundTransparency = 1
    tabsScroll.ScrollBarThickness = 0
    tabsScroll.Parent = sidebar

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Padding = UDim.new(0, 5)
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabsLayout.Parent = tabsScroll

    -- Profile Section (Bottom)
    local profile = Instance.new("Frame")
    profile.Size = UDim2.new(1, -20, 0, 50)
    profile.Position = UDim2.new(0, 10, 1, -60)
    profile.BackgroundTransparency = 1
    profile.Parent = sidebar

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 35, 0, 35)
    avatar.Position = UDim2.new(0, 5, 0.5, -17)
    avatar.Image = "rbxassetid://6033727445" -- Дефолт аватар
    avatar.Parent = profile
    createRound(avatar, UDim.new(1, 0))

    local userName = Instance.new("TextLabel")
    userName.Text = "UserAccount"
    userName.Font = Enum.Font.GothamSemibold
    userName.TextSize = 13
    userName.TextColor3 = theme.Text
    userName.Position = UDim2.new(0, 48, 0.2, 0)
    userName.BackgroundTransparency = 1
    userName.TextXAlignment = Enum.TextXAlignment.Left
    userName.Parent = profile

    local userStatus = Instance.new("TextLabel")
    userStatus.Text = "PREMIUM"
    userStatus.Font = Enum.Font.Gotham
    userStatus.TextSize = 10
    userStatus.TextColor3 = theme.SubText
    userStatus.Position = UDim2.new(0, 48, 0.6, 0)
    userStatus.BackgroundTransparency = 1
    userStatus.TextXAlignment = Enum.TextXAlignment.Left
    userStatus.Parent = profile

    -- Content Area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -190, 1, -20)
    content.Position = UDim2.new(0, 185, 0, 10)
    content.BackgroundTransparency = 1
    content.Parent = container

    window.Tabs = {}
    window.ActiveTab = nil

    function window:AddTab(name, iconId)
        local tab = { Active = false }
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 160, 0, 35)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = tabsScroll

        local btnRound = createRound(btn, UDim.new(0, 6))
        
        local btnIcon = Instance.new("ImageLabel")
        btnIcon.Size = UDim2.new(0, 20, 0, 20)
        btnIcon.Position = UDim2.new(0, 10, 0.5, -10)
        btnIcon.Image = iconId or "rbxassetid://6023426915"
        btnIcon.ImageColor3 = theme.SubText
        btnIcon.BackgroundTransparency = 1
        btnIcon.Parent = btn

        local btnText = Instance.new("TextLabel")
        btnText.Text = name
        btnText.Font = Enum.Font.GothamSemibold
        btnText.TextSize = 13
        btnText.TextColor3 = theme.SubText
        btnText.Position = UDim2.new(0, 40, 0, 0)
        btnText.Size = UDim2.new(1, -40, 1, 0)
        btnText.TextXAlignment = Enum.TextXAlignment.Left
        btnText.BackgroundTransparency = 1
        btnText.Parent = btn

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 0, 18)
        indicator.Position = UDim2.new(1, -3, 0.5, -9)
        indicator.BackgroundColor3 = theme.Accent
        indicator.BorderSizePixel = 0
        indicator.Visible = false
        indicator.Parent = btn
        createRound(indicator, UDim.new(0, 2))

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 0
        page.Parent = content

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 15)
        pageLayout.FillDirection = Enum.FillDirection.Horizontal
        pageLayout.Parent = page

        local leftCol = Instance.new("Frame")
        leftCol.Size = UDim2.new(0.5, -8, 1, 0)
        leftCol.BackgroundTransparency = 1
        leftCol.Parent = page
        Instance.new("UIListLayout", leftCol).Padding = UDim.new(0, 10)

        local rightCol = Instance.new("Frame")
        rightCol.Size = UDim2.new(0.5, -8, 1, 0)
        rightCol.BackgroundTransparency = 1
        rightCol.Parent = page
        Instance.new("UIListLayout", rightCol).Padding = UDim.new(0, 10)

        local function activate()
            if window.ActiveTab then
                window.ActiveTab.btnText.TextColor3 = theme.SubText
                window.ActiveTab.btnIcon.ImageColor3 = theme.SubText
                window.ActiveTab.indicator.Visible = false
                window.ActiveTab.btn.BackgroundTransparency = 1
                window.ActiveTab.page.Visible = false
            end
            window.ActiveTab = {btnText = btnText, btnIcon = btnIcon, indicator = indicator, btn = btn, page = page}
            btnText.TextColor3 = theme.Text
            btnIcon.ImageColor3 = theme.Accent
            indicator.Visible = true
            btn.BackgroundTransparency = 0.9
            btn.BackgroundColor3 = theme.Accent
            page.Visible = true
        end

        btn.MouseButton1Click:Connect(activate)
        if not window.ActiveTab then activate() end

        function tab:AddSection(title)
            local section = {}
            local secFrame = Instance.new("Frame")
            secFrame.Size = UDim2.new(1, 0, 0, 40)
            secFrame.AutomaticSize = Enum.AutomaticSize.Y
            secFrame.BackgroundColor3 = theme.Section
            secFrame.BorderSizePixel = 0
            secFrame.Parent = (#leftCol:GetChildren() <= #rightCol:GetChildren()) and leftCol or rightCol
            createRound(secFrame)
            createStroke(secFrame, theme.Stroke, 1)

            local secTitle = Instance.new("TextLabel")
            secTitle.Text = title
            secTitle.Font = Enum.Font.GothamBold
            secTitle.TextSize = 14
            secTitle.TextColor3 = theme.SubText
            secTitle.Position = UDim2.new(0, 12, 0, 10)
            secTitle.Size = UDim2.new(1, -24, 0, 20)
            secTitle.BackgroundTransparency = 1
            secTitle.TextXAlignment = Enum.TextXAlignment.Left
            secTitle.Parent = secFrame

            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 0)
            container.Position = UDim2.new(0, 0, 0, 35)
            container.AutomaticSize = Enum.AutomaticSize.Y
            container.BackgroundTransparency = 1
            container.Parent = secFrame
            local clayout = Instance.new("UIListLayout", container)
            clayout.Padding = UDim.new(0, 5)
            Instance.new("UIPadding", container).PaddingLeft = UDim.new(0, 10)
            container.UIPadding.PaddingRight = UDim.new(0, 10)
            container.UIPadding.PaddingBottom = UDim.new(0, 10)

            function section:AddButton(text, callback)
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, 0, 0, 32)
                b.BackgroundColor3 = theme.Accent
                b.Text = text
                b.Font = Enum.Font.GothamBold
                b.TextColor3 = Color3.fromRGB(0,0,0) -- Черный текст на циан кнопке
                b.TextSize = 13
                b.AutoButtonColor = true
                b.Parent = container
                createRound(b)
                b.MouseButton1Click:Connect(callback)
            end

            function section:AddToggle(text, default, callback)
                local state = default or false
                local t = Instance.new("TextButton")
                t.Size = UDim2.new(1, 0, 0, 30)
                t.BackgroundTransparency = 1
                t.Text = text
                t.Font = Enum.Font.Gotham
                t.TextColor3 = theme.Text
                t.TextSize = 13
                t.TextXAlignment = Enum.TextXAlignment.Left
                t.Parent = container

                local box = Instance.new("Frame")
                box.Size = UDim2.new(0, 34, 0, 18)
                box.Position = UDim2.new(1, -34, 0.5, -9)
                box.BackgroundColor3 = state and theme.Accent or theme.Element
                box.Parent = t
                createRound(box, UDim.new(1, 0))

                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 14, 0, 14)
                knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
                knob.Parent = box
                createRound(knob, UDim.new(1, 0))

                t.MouseButton1Click:Connect(function()
                    state = not state
                    tween(box, {BackgroundColor3 = state and theme.Accent or theme.Element})
                    tween(knob, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                    callback(state)
                end)
            end

            function section:AddSlider(text, min, max, default, callback)
                local val = default or min
                local s = Instance.new("Frame")
                s.Size = UDim2.new(1, 0, 0, 45)
                s.BackgroundTransparency = 1
                s.Parent = container

                local stxt = Instance.new("TextLabel")
                stxt.Text = text
                stxt.Font = Enum.Font.Gotham
                stxt.TextColor3 = theme.Text
                stxt.TextSize = 13
                stxt.Size = UDim2.new(1, 0, 0, 20)
                stxt.BackgroundTransparency = 1
                stxt.TextXAlignment = Enum.TextXAlignment.Left
                stxt.Parent = s

                local vtxt = Instance.new("TextLabel")
                vtxt.Text = tostring(val)
                vtxt.Position = UDim2.new(1, -30, 0, 0)
                vtxt.Size = UDim2.new(0, 30, 0, 20)
                vtxt.TextColor3 = theme.SubText
                vtxt.BackgroundTransparency = 1
                vtxt.TextSize = 12
                vtxt.Parent = s

                local bar = Instance.new("Frame")
                bar.Size = UDim2.new(1, 0, 0, 6)
                bar.Position = UDim2.new(0, 0, 0, 28)
                bar.BackgroundColor3 = theme.Element
                bar.Parent = s
                createRound(bar)

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
                fill.BackgroundColor3 = theme.Accent
                fill.Parent = bar
                createRound(fill)

                -- Логика слайдера (упрощенно)
                local dragging = false
                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                        val = math.floor(min + (max - min) * pos)
                        vtxt.Text = tostring(val)
                        fill.Size = UDim2.new(pos, 0, 1, 0)
                        callback(val)
                    end
                end)
            end

            return section
        end
        return tab
    end

    return window
end

return Library
