--Open Source UI by @qkaspq
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local theme = {
    Background = Color3.fromRGB(24, 26, 35),
    Primary = Color3.fromRGB(35, 38, 50),
    PrimaryHover = Color3.fromRGB(50, 54, 70),
    Header = Color3.fromRGB(30, 32, 42),
    Accent = Color3.fromRGB(138, 178, 255),
    AccentHover = Color3.fromRGB(168, 208, 255),
    Text = Color3.fromRGB(240, 240, 255),
    SubText = Color3.fromRGB(160, 160, 180),
    Stroke = Color3.fromRGB(70, 74, 90),
    NeonStroke = Color3.fromRGB(138, 178, 255),
    StrokeHover = Color3.fromRGB(90, 94, 110)
}
local function tween(object, p1, p2)
    if not object then return end
    local tweenInfo, properties
    if p2 then
        tweenInfo = p1
        properties = p2
    else
        tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint)
        properties = p1
    end
    TweenService:Create(object, tweenInfo, properties):Play()
end

local function makeDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject

    local dragging = false
    local dragStart = nil
    local startPos = nil
    local lastInput = nil

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            lastInput = input
        end
    end)

    game:GetService("RunService").Heartbeat:Connect(function()
        if dragging and lastInput and dragStart and startPos then
            local delta = lastInput.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function safeParentToCoreGui(gui)
    pcall(function()
        gui.Parent = CoreGui
    end)
end

local function createRound(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius
    c.Parent = parent
    return c
end

local function createStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color
    s.Thickness = thickness
    s.Parent = parent
    return s
end

local function createLabel(parent, text, font, size, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Font = font
    l.TextSize = size
    l.TextColor3 = color
    l.Text = text
    l.Parent = parent
    return l
end

local function createIcon(parent, iconId, color)
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Image = iconId
    img.ImageColor3 = color
    img.Parent = parent
    return img
end

 local function safeDisconnect(conn)
     if conn then
         pcall(function()
             conn:Disconnect()
         end)
     end
 end

 local function normalizeKey(key)
     if key == nil then
         return nil
     end
     if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
         return key
     end
     if type(key) == "string" then
         local ok, kc = pcall(function()
             return Enum.KeyCode[key]
         end)
         if ok then
             return kc
         end
     end
     return nil
 end

local Library = {}
Library.__index = Library

function Library:Destroy()
    if self._gui and self._gui.Parent then
        self._gui:Destroy()
    end
end

function Library:CreateWindow(options)
    options = options or {}

    local window = setmetatable({}, Library)

    local gui = Instance.new("ScreenGui")
    gui.Name = options.Name or "MoonHubUI"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.ResetOnSpawn = false
    safeParentToCoreGui(gui)

    local container = Instance.new("Frame")
    container.Size = options.Size or UDim2.new(0, 720, 0, 480)
    container.Position = options.Position or UDim2.new(0.5, -360, 0.5, -240)
    container.BackgroundColor3 = theme.Header
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = gui
    createRound(container, UDim.new(0, 10))
    createStroke(container, theme.Accent, 1.5)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 52)
    header.BackgroundTransparency = 1
    header.Parent = container

    makeDraggable(container, header)

    local icon = createIcon(header, options.Icon or "rbxassetid://13161991129", theme.Accent)
    icon.Size = UDim2.new(0, 22, 0, 22)
    icon.Position = UDim2.new(0, 12, 0.5, -11)

    local title = createLabel(header, options.Title or "Moon Hub", Enum.Font.GothamBold, 18, theme.Text)
    title.Size = UDim2.new(1, -150, 0, 26)
    title.Position = UDim2.new(0, 44, 0, 2)

    local sub = createLabel(header, options.Subtitle or "UI Library", Enum.Font.Gotham, 12, theme.SubText)
    sub.Size = UDim2.new(1, -150, 0, 18)
    sub.Position = UDim2.new(0, 44, 0, 28)

    local function headerCircleButton(xOffset, labelText)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 26, 0, 26)
        b.Position = UDim2.new(1, xOffset, 0.5, -13)
        b.BackgroundColor3 = theme.Primary
        b.Text = ""
        b.AutoButtonColor = false
        b.Parent = header
        createRound(b, UDim.new(1, 0))
        local st = createStroke(b, theme.Stroke, 1.5)

        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(1, 0, 1, 0)
        t.Font = Enum.Font.GothamBold
        t.Text = labelText
        t.TextColor3 = theme.Accent
        t.TextSize = 14
        t.Parent = b

        b.MouseEnter:Connect(function()
            tween(b, { BackgroundColor3 = theme.PrimaryHover })
            tween(t, { TextColor3 = theme.AccentHover })
        end)
        b.MouseLeave:Connect(function()
            tween(b, { BackgroundColor3 = theme.Primary })
            tween(t, { TextColor3 = theme.Accent })
        end)

        return b, st, t
    end

    local collapseButton = headerCircleButton(-66, "—")
    local closeButton = headerCircleButton(-34, "X")

    local body = Instance.new("Frame")
    body.Position = UDim2.new(0, 0, 0, 52)
    body.Size = UDim2.new(1, 0, 1, -52)
    body.BackgroundTransparency = 1
    body.Parent = container

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 190, 1, 0)
    sidebar.BackgroundColor3 = theme.Primary
    sidebar.BorderSizePixel = 0
    sidebar.ClipsDescendants = true
    sidebar.Parent = body
    createRound(sidebar, UDim.new(0, 10))
    createStroke(sidebar, theme.Stroke, 1)

    local sidebarPad = Instance.new("UIPadding")
    sidebarPad.PaddingTop = UDim.new(0, 10)
    sidebarPad.PaddingLeft = UDim.new(0, 10)
    sidebarPad.PaddingRight = UDim.new(0, 10)
    sidebarPad.PaddingBottom = UDim.new(0, 10)
    sidebarPad.Parent = sidebar

    local tabsList = Instance.new("Frame")
    tabsList.Size = UDim2.new(1, 0, 1, 0)
    tabsList.BackgroundTransparency = 1
    tabsList.Parent = sidebar

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.FillDirection = Enum.FillDirection.Vertical
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 8)
    tabsLayout.Parent = tabsList

    local content = Instance.new("Frame")
    content.Position = UDim2.new(0, 202, 0, 0)
    content.Size = UDim2.new(1, -202, 1, 0)
    content.BackgroundColor3 = theme.Background
    content.BorderSizePixel = 0
    content.ClipsDescendants = true
    content.Parent = body
    createRound(content, UDim.new(0, 10))
    createStroke(content, theme.Stroke, 1)

    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingTop = UDim.new(0, 12)
    contentPad.PaddingLeft = UDim.new(0, 12)
    contentPad.PaddingRight = UDim.new(0, 12)
    contentPad.PaddingBottom = UDim.new(0, 12)
    contentPad.Parent = content

    local pages = Instance.new("Folder")
    pages.Name = "Pages"
    pages.Parent = content

     local overlay = Instance.new("Frame")
     overlay.Name = "MoonHubUI_Overlay"
     overlay.BackgroundTransparency = 1
     overlay.Size = UDim2.new(1, 0, 1, 0)
     overlay.Position = UDim2.new(0, 0, 0, 0)
     overlay.ZIndex = 200
     overlay.Visible = false
     overlay.Parent = gui

     local overlayBlocker = Instance.new("TextButton")
     overlayBlocker.Name = "Blocker"
     overlayBlocker.BackgroundTransparency = 1
     overlayBlocker.Text = ""
     overlayBlocker.AutoButtonColor = false
     overlayBlocker.Size = UDim2.new(1, 0, 1, 0)
     overlayBlocker.Position = UDim2.new(0, 0, 0, 0)
     overlayBlocker.ZIndex = 200
     overlayBlocker.Parent = overlay

     local overlayHost = Instance.new("Frame")
     overlayHost.Name = "Host"
     overlayHost.BackgroundTransparency = 1
     overlayHost.Size = UDim2.new(1, 0, 1, 0)
     overlayHost.Position = UDim2.new(0, 0, 0, 0)
     overlayHost.ZIndex = 201
     overlayHost.Parent = overlay

    window._gui = gui
    window._container = container
    window._body = body
    window._tabsList = tabsList
    window._pages = pages
    window._tabs = {}
    window._activeTab = nil

    window._binds = {}
    window._bindConn = nil

     window._overlay = overlay
     window._overlayHost = overlayHost
     window._overlayBlocker = overlayBlocker
     window._overlayCloseConn = nil
     window._overlayContent = nil

    local isCollapsed = false
    local originalSize = container.Size
    local collapsedSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, header.Size.Y.Offset)

    collapseButton.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        body.Visible = not isCollapsed
        if isCollapsed then
            collapseButton[3].Text = "+"
            tween(container, { Size = collapsedSize })
        else
            collapseButton[3].Text = "—"
            tween(container, { Size = originalSize })
        end
    end)

    closeButton.MouseButton1Click:Connect(function()
        window:Destroy()
    end)

    local function setActiveTab(tabObj)
        if window._activeTab == tabObj then return end

        if window._activeTab then
            window._activeTab.Page.Visible = false
            tween(window._activeTab.Stroke, { Color = theme.Stroke })
            tween(window._activeTab.Text, { TextColor3 = theme.Text })
        end

        window._activeTab = tabObj
        tabObj.Page.Visible = true
        tween(tabObj.Stroke, { Color = theme.NeonStroke })
        tween(tabObj.Text, { TextColor3 = theme.Accent })
    end

     function window:CloseOverlay()
         if window._overlayContent and window._overlayContent.Parent then
             window._overlayContent:Destroy()
         end
         window._overlayContent = nil
         window._overlay.Visible = false
         safeDisconnect(window._overlayCloseConn)
         window._overlayCloseConn = nil
     end

     function window:OpenOverlay(buildFn, anchorAbsPos, anchorAbsSize, onClose)
         window:CloseOverlay()
         window._overlay.Visible = true

         local contentFrame = buildFn(window._overlayHost)
         window._overlayContent = contentFrame
         contentFrame.ZIndex = 210

         local viewX = window._container.AbsolutePosition.X
         local viewY = window._container.AbsolutePosition.Y
         local viewW = window._container.AbsoluteSize.X
         local viewH = window._container.AbsoluteSize.Y

         local popupW = contentFrame.AbsoluteSize.X
         local popupH = contentFrame.AbsoluteSize.Y
         local px = anchorAbsPos.X
         local py = anchorAbsPos.Y + anchorAbsSize.Y + 6

         if popupW > 0 and popupH > 0 then
             px = math.clamp(px, viewX + 10, (viewX + viewW) - popupW - 10)
             py = math.clamp(py, viewY + 10, (viewY + viewH) - popupH - 10)
         end

         contentFrame.Position = UDim2.fromOffset(px, py)
         window._overlayCloseConn = overlayBlocker.MouseButton1Click:Connect(function()
             window:CloseOverlay()
             if onClose then
                 task.spawn(onClose)
             end
         end)
     end

     function window:_bindKey(key, fn)
         local kc = normalizeKey(key)
         if not kc or not fn then
             return nil
         end
         local list = window._binds[kc]
         if not list then
             list = {}
             window._binds[kc] = list
         end
         table.insert(list, fn)
         return { KeyCode = kc, Fn = fn }
     end

     function window:_unbindKey(token)
         if not token or not token.KeyCode or not token.Fn then
             return
         end
         local list = window._binds[token.KeyCode]
         if not list then
             return
         end
         for i = #list, 1, -1 do
             if list[i] == token.Fn then
                 table.remove(list, i)
             end
         end
     end

     if window._bindConn == nil then
         window._bindConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
             if gameProcessed then
                 return
             end
             if UserInputService:GetFocusedTextBox() then
                 return
             end
             local kc = input.KeyCode
             local list = kc and window._binds[kc]
             if not list then
                 return
             end
             for _, fn in ipairs(list) do
                 task.spawn(fn)
             end
         end)
     end

    function window:AddTab(tabName)
        tabName = tabName or "Tab"

        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, 0, 0, 36)
        tabButton.BackgroundTransparency = 1
        tabButton.BackgroundColor3 = theme.Background
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabsList
        createRound(tabButton, UDim.new(0, 8))
        local tabStroke = createStroke(tabButton, theme.Stroke, 1)

        local tabText = Instance.new("TextLabel")
        tabText.BackgroundTransparency = 1
        tabText.Size = UDim2.new(1, -12, 1, 0)
        tabText.Position = UDim2.new(0, 12, 0, 0)
        tabText.Font = Enum.Font.GothamSemibold
        tabText.Text = tabName
        tabText.TextColor3 = theme.Text
        tabText.TextSize = 14
        tabText.TextXAlignment = Enum.TextXAlignment.Left
        tabText.Parent = tabButton

        tabButton.MouseEnter:Connect(function()
            if window._activeTab and window._activeTab.Button == tabButton then return end
            tween(tabStroke, { Color = theme.StrokeHover })
            tween(tabText, { TextColor3 = theme.Accent })
        end)
        tabButton.MouseLeave:Connect(function()
            if window._activeTab and window._activeTab.Button == tabButton then return end
            tween(tabStroke, { Color = theme.Stroke })
            tween(tabText, { TextColor3 = theme.Text })
        end)

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = theme.Accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.None
        page.Visible = false
        page.Parent = pages

        local pagePad = Instance.new("UIPadding")
        pagePad.PaddingTop = UDim.new(0, 2)
        pagePad.PaddingLeft = UDim.new(0, 2)
        pagePad.PaddingRight = UDim.new(0, 2)
        pagePad.PaddingBottom = UDim.new(0, 2)
        pagePad.Parent = page

        local columns = Instance.new("Frame")
        columns.Name = "Columns"
        columns.BackgroundTransparency = 1
        columns.Size = UDim2.new(1, 0, 0, 0)
        columns.Parent = page

        local colGap = 12

        local leftCol = Instance.new("Frame")
        leftCol.Name = "Left"
        leftCol.BackgroundTransparency = 1
        leftCol.Position = UDim2.new(0, 0, 0, 0)
        leftCol.Size = UDim2.new(0.5, -(colGap / 2), 0, 0)
        leftCol.AutomaticSize = Enum.AutomaticSize.Y
        leftCol.Parent = columns

        local rightCol = Instance.new("Frame")
        rightCol.Name = "Right"
        rightCol.BackgroundTransparency = 1
        rightCol.Position = UDim2.new(0.5, (colGap / 2), 0, 0)
        rightCol.Size = UDim2.new(0.5, -(colGap / 2), 0, 0)
        rightCol.AutomaticSize = Enum.AutomaticSize.Y
        rightCol.Parent = columns

        local leftLayout = Instance.new("UIListLayout")
        leftLayout.FillDirection = Enum.FillDirection.Vertical
        leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        leftLayout.Padding = UDim.new(0, 12)
        leftLayout.Parent = leftCol

        local rightLayout = Instance.new("UIListLayout")
        rightLayout.FillDirection = Enum.FillDirection.Vertical
        rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rightLayout.Padding = UDim.new(0, 12)
        rightLayout.Parent = rightCol

        local function updateCanvas()
            local leftH = leftLayout.AbsoluteContentSize.Y
            local rightH = rightLayout.AbsoluteContentSize.Y
            local h = math.max(leftH, rightH)
            columns.Size = UDim2.new(1, 0, 0, h)
            page.CanvasSize = UDim2.new(0, 0, 0, h)
        end

        leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        updateCanvas()

        local tab = {}
        tab.Button = tabButton
        tab.Stroke = tabStroke
        tab.Text = tabText
        tab.Page = page
        tab._leftCol = leftCol
        tab._rightCol = rightCol
        tab._leftLayout = leftLayout
        tab._rightLayout = rightLayout
        tab._updateCanvas = updateCanvas

        function tab:AddSection(sectionName)
            sectionName = sectionName or "Section"

            local parentColumn = tab._leftCol
            if tab._rightLayout.AbsoluteContentSize.Y < tab._leftLayout.AbsoluteContentSize.Y then
                parentColumn = tab._rightCol
            end

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.BackgroundColor3 = theme.Header
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = parentColumn
            createRound(sectionFrame, UDim.new(0, 10))
            createStroke(sectionFrame, theme.Stroke, 1)

            local secPad = Instance.new("UIPadding")
            secPad.PaddingTop = UDim.new(0, 12)
            secPad.PaddingLeft = UDim.new(0, 12)
            secPad.PaddingRight = UDim.new(0, 12)
            secPad.PaddingBottom = UDim.new(0, 12)
            secPad.Parent = sectionFrame

            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.FillDirection = Enum.FillDirection.Vertical
            sectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 10)
            sectionLayout.Parent = sectionFrame

            local secTitle = createLabel(sectionFrame, sectionName, Enum.Font.GothamBold, 14, theme.Text)
            secTitle.Size = UDim2.new(1, 0, 0, 20)
            secTitle.LayoutOrder = 1

            local secList = Instance.new("Frame")
            secList.Size = UDim2.new(1, 0, 0, 0)
            secList.AutomaticSize = Enum.AutomaticSize.Y
            secList.BackgroundTransparency = 1
            secList.Parent = sectionFrame
            secList.LayoutOrder = 2

            local secListLayout = Instance.new("UIListLayout")
            secListLayout.FillDirection = Enum.FillDirection.Vertical
            secListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            secListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            secListLayout.Padding = UDim.new(0, 10)
            secListLayout.Parent = secList

            secListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                tab._updateCanvas()
            end)

            local section = {}

            local elementOrder = 0

            local function baseItemFrame(height)
                elementOrder += 1
                local item = Instance.new("Frame")
                item.Size = UDim2.new(1, 0, 0, height)
                item.BackgroundColor3 = theme.Background
                item.BorderSizePixel = 0
                item.Parent = secList
                item.LayoutOrder = elementOrder
                createRound(item, UDim.new(0, 8))
                local st = createStroke(item, theme.Stroke, 1)
                return item, st
            end

            function section:AddButton(text, options, callback)
                if type(options) == "function" and callback == nil then
                    callback = options
                    options = {}
                end
                options = options or {}

                local showKeybind = (options.Keybindable == true) or (options.Keybind ~= nil) or (options.Key ~= nil)

                local item, st = baseItemFrame(36)

                local btn = Instance.new("TextButton")
                btn.BackgroundTransparency = 1
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.Text = ""
                btn.AutoButtonColor = false
                btn.Parent = item

                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Size = showKeybind and UDim2.new(1, -80, 1, 0) or UDim2.new(1, -12, 1, 0)
                lbl.Position = UDim2.new(0, 12, 0, 0)
                lbl.Font = Enum.Font.GothamSemibold
                lbl.Text = text or "Button"
                lbl.TextColor3 = theme.Text
                lbl.TextSize = 14
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = item

                local keyBtn = Instance.new("TextButton")
                keyBtn.BackgroundColor3 = theme.Primary
                keyBtn.BorderSizePixel = 0
                keyBtn.Size = UDim2.new(0, 56, 0, 20)
                keyBtn.Position = UDim2.new(1, -68, 0.5, -10)
                keyBtn.AutoButtonColor = false
                keyBtn.Text = ""
                keyBtn.Parent = item
                createRound(keyBtn, UDim.new(0, 6))
                local keyStroke = createStroke(keyBtn, theme.Stroke, 1)
                keyBtn.Visible = showKeybind

                local keyText = Instance.new("TextLabel")
                keyText.BackgroundTransparency = 1
                keyText.Size = UDim2.new(1, -10, 1, 0)
                keyText.Position = UDim2.new(0, 5, 0, 0)
                keyText.Font = Enum.Font.Gotham
                keyText.TextColor3 = theme.SubText
                keyText.TextSize = 12
                keyText.TextXAlignment = Enum.TextXAlignment.Right
                keyText.TextTruncate = Enum.TextTruncate.AtEnd
                keyText.Parent = keyBtn

                local waiting = false
                local captureConn
                local bindToken
                local currentKey = normalizeKey(options.Keybind or options.Key)

                if not showKeybind then
                    currentKey = nil
                end

                local function renderKey()
                    if waiting then
                        keyText.Text = "..."
                        keyText.TextColor3 = theme.SubText
                    else
                        keyText.Text = currentKey and currentKey.Name or ""
                        keyText.TextColor3 = currentKey and theme.Text or theme.SubText
                    end
                end

                local function setKeybind(key)
                    currentKey = normalizeKey(key)
                    if bindToken then
                        window:_unbindKey(bindToken)
                        bindToken = nil
                    end
                    if currentKey then
                        bindToken = window:_bindKey(currentKey, function()
                            if callback then
                                callback()
                            end
                        end)
                    end
                    renderKey()
                end

                local function stopCapture()
                    waiting = false
                    safeDisconnect(captureConn)
                    captureConn = nil
                    tween(keyStroke, { Color = theme.Stroke })
                    renderKey()
                end

                local function startCapture()
                    if waiting then
                        return
                    end
                    waiting = true
                    tween(keyStroke, { Color = theme.NeonStroke })
                    renderKey()
                    safeDisconnect(captureConn)
                    captureConn = UserInputService.InputBegan:Connect(function(input, gp)
                        if gp then
                            return
                        end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                                setKeybind(nil)
                                stopCapture()
                                return
                            end
                            setKeybind(input.KeyCode)
                            stopCapture()
                        end
                    end)
                end

                btn.MouseEnter:Connect(function()
                    tween(item, { BackgroundColor3 = theme.Header })
                    tween(st, { Color = theme.StrokeHover })
                end)
                btn.MouseLeave:Connect(function()
                    tween(item, { BackgroundColor3 = theme.Background })
                    tween(st, { Color = theme.Stroke })
                end)

                if showKeybind then
                    keyBtn.MouseEnter:Connect(function()
                        tween(keyBtn, { BackgroundColor3 = theme.PrimaryHover })
                        if not waiting then
                            tween(keyStroke, { Color = theme.StrokeHover })
                        end
                    end)
                    keyBtn.MouseLeave:Connect(function()
                        tween(keyBtn, { BackgroundColor3 = theme.Primary })
                        tween(keyStroke, { Color = waiting and theme.NeonStroke or theme.Stroke })
                    end)

                    keyBtn.MouseButton1Click:Connect(function()
                        if waiting then
                            stopCapture()
                        else
                            startCapture()
                        end
                    end)
                end

                btn.MouseButton1Click:Connect(function()
                    if callback then
                        task.spawn(callback)
                    end
                end)

                tab._updateCanvas()
                if showKeybind then
                    if currentKey then
                        setKeybind(currentKey)
                    else
                        renderKey()
                    end
                end
                return {
                    Instance = btn,
                    SetText = function(_, v)
                        lbl.Text = tostring(v)
                        tab._updateCanvas()
                    end,
                    SetCallback = function(_, fn)
                        callback = fn
                    end,
                    GetKeybind = function()
                        return currentKey
                    end,
                    SetKeybind = function(_, key)
                        if showKeybind then
                            setKeybind(key)
                        end
                    end,
                    ClearKeybind = function()
                        if showKeybind then
                            setKeybind(nil)
                        end
                    end
                }
            end

            function section:AddToggle(text, default, callback)
                local options
                if type(default) == "table" then
                    options = default
                    default = options.Default
                    if callback == nil and type(options.Callback) == "function" then
                        callback = options.Callback
                    end
                end
                options = options or {}

                local showKeybind = (options.Keybindable == true) or (options.Keybind ~= nil) or (options.Key ~= nil)

                local item, st = baseItemFrame(36)

                local state = default and true or false

                local btn = Instance.new("TextButton")
                btn.BackgroundTransparency = 1
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.Text = ""
                btn.AutoButtonColor = false
                btn.Parent = item

                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Size = showKeybind and UDim2.new(1, -130, 1, 0) or UDim2.new(1, -60, 1, 0)
                lbl.Position = UDim2.new(0, 12, 0, 0)
                lbl.Font = Enum.Font.GothamSemibold
                lbl.Text = text or "Toggle"
                lbl.TextColor3 = theme.Text
                lbl.TextSize = 14
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = item

                local keyBtn = Instance.new("TextButton")
                keyBtn.BackgroundColor3 = theme.Primary
                keyBtn.BorderSizePixel = 0
                keyBtn.Size = UDim2.new(0, 56, 0, 20)
                keyBtn.Position = UDim2.new(1, -126, 0.5, -10)
                keyBtn.AutoButtonColor = false
                keyBtn.Text = ""
                keyBtn.Parent = item
                createRound(keyBtn, UDim.new(0, 6))
                local keyStroke = createStroke(keyBtn, theme.Stroke, 1)

                local keyText = Instance.new("TextLabel")
                keyText.BackgroundTransparency = 1
                keyText.Size = UDim2.new(1, -10, 1, 0)
                keyText.Position = UDim2.new(0, 5, 0, 0)
                keyText.Font = Enum.Font.Gotham
                keyText.TextColor3 = theme.SubText
                keyText.TextSize = 12
                keyText.TextXAlignment = Enum.TextXAlignment.Right
                keyText.TextTruncate = Enum.TextTruncate.AtEnd
                keyText.Parent = keyBtn

                local pill = Instance.new("Frame")
                pill.Size = UDim2.new(0, 42, 0, 20)
                pill.Position = UDim2.new(1, -54, 0.5, -10)
                pill.BackgroundColor3 = state and theme.Accent or theme.Primary
                pill.BorderSizePixel = 0
                pill.Parent = item
                createRound(pill, UDim.new(1, 0))
                local pillStroke = createStroke(pill, state and theme.NeonStroke or theme.Stroke, 1)

                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 16, 0, 16)
                knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                knob.BackgroundColor3 = theme.Text
                knob.BorderSizePixel = 0
                knob.Parent = pill
                createRound(knob, UDim.new(1, 0))

                local function render()
                    tween(pill, { BackgroundColor3 = state and theme.Accent or theme.Primary })
                    tween(pillStroke, { Color = state and theme.NeonStroke or theme.Stroke })
                    tween(knob, { Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) })
                end

                btn.MouseEnter:Connect(function()
                    tween(item, { BackgroundColor3 = theme.Header })
                    tween(st, { Color = theme.StrokeHover })
                end)
                btn.MouseLeave:Connect(function()
                    tween(item, { BackgroundColor3 = theme.Background })
                    tween(st, { Color = theme.Stroke })
                end)

                btn.MouseButton1Click:Connect(function()
                    state = not state
                    render()
                    if callback then
                        task.spawn(function()
                            callback(state)
                        end)
                    end
                end)

                local waiting = false
                local captureConn
                local bindToken
                local currentKey = normalizeKey(options.Keybind or options.Key)

                local function renderKey()
                    if waiting then
                        keyText.Text = "..."
                        keyText.TextColor3 = theme.SubText
                    else
                        keyText.Text = currentKey and currentKey.Name or ""
                        keyText.TextColor3 = currentKey and theme.Text or theme.SubText
                    end
                end

                local function setKeybind(key)
                    currentKey = normalizeKey(key)
                    if bindToken then
                        window:_unbindKey(bindToken)
                        bindToken = nil
                    end
                    if currentKey then
                        bindToken = window:_bindKey(currentKey, function()
                            state = not state
                            render()
                            if callback then
                                callback(state)
                            end
                        end)
                    end
                    renderKey()
                end

                local function stopCapture()
                    waiting = false
                    safeDisconnect(captureConn)
                    captureConn = nil
                    tween(keyStroke, { Color = theme.Stroke })
                    renderKey()
                end

                local function startCapture()
                    if waiting then
                        return
                    end
                    waiting = true
                    tween(keyStroke, { Color = theme.NeonStroke })
                    renderKey()
                    safeDisconnect(captureConn)
                    captureConn = UserInputService.InputBegan:Connect(function(input, gp)
                        if gp then
                            return
                        end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                                setKeybind(nil)
                                stopCapture()
                                return
                            end
                            setKeybind(input.KeyCode)
                            stopCapture()
                        end
                    end)
                end

                render()
                if showKeybind then
                    if currentKey then
                        setKeybind(currentKey)
                    else
                        renderKey()
                    end
                end
                tab._updateCanvas()
                return {
                    Get = function() return state end,
                    Set = function(_, v)
                        state = not not v
                        render()
                        tab._updateCanvas()
                    end,
                    SetText = function(_, v)
                        lbl.Text = tostring(v)
                        tab._updateCanvas()
                    end,
                    GetKeybind = function()
                        return currentKey
                    end,
                    SetKeybind = function(_, key)
                        if showKeybind then
                            setKeybind(key)
                        end
                    end,
                    ClearKeybind = function()
                        if showKeybind then
                            setKeybind(nil)
                        end
                    end
                }
            end

            function section:AddCheckbox(text, default, callback)
                local options
                if type(default) == "table" then
                    options = default
                    default = options.Default
                    if callback == nil and type(options.Callback) == "function" then
                        callback = options.Callback
                    end
                end
                options = options or {}

                local showKeybind = (options.Keybindable == true) or (options.Keybind ~= nil) or (options.Key ~= nil)

                local item, st = baseItemFrame(36)

                local state = default and true or false

                local btn = Instance.new("TextButton")
                btn.BackgroundTransparency = 1
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.Text = ""
                btn.AutoButtonColor = false
                btn.Parent = item

                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Size = showKeybind and UDim2.new(1, -112, 1, 0) or UDim2.new(1, -46, 1, 0)
                lbl.Position = UDim2.new(0, 12, 0, 0)
                lbl.Font = Enum.Font.GothamSemibold
                lbl.Text = text or "Checkbox"
                lbl.TextColor3 = theme.Text
                lbl.TextSize = 14
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = item

                local keyBtn = Instance.new("TextButton")
                keyBtn.BackgroundColor3 = theme.Primary
                keyBtn.BorderSizePixel = 0
                keyBtn.Size = UDim2.new(0, 56, 0, 20)
                keyBtn.Position = UDim2.new(1, -98, 0.5, -10)
                keyBtn.AutoButtonColor = false
                keyBtn.Text = ""
                keyBtn.Parent = item
                createRound(keyBtn, UDim.new(0, 6))
                local keyStroke = createStroke(keyBtn, theme.Stroke, 1)

                local keyText = Instance.new("TextLabel")
                keyText.BackgroundTransparency = 1
                keyText.Size = UDim2.new(1, -10, 1, 0)
                keyText.Position = UDim2.new(0, 5, 0, 0)
                keyText.Font = Enum.Font.Gotham
                keyText.TextColor3 = theme.SubText
                keyText.TextSize = 12
                keyText.TextXAlignment = Enum.TextXAlignment.Right
                keyText.TextTruncate = Enum.TextTruncate.AtEnd
                keyText.Parent = keyBtn

                local box = Instance.new("Frame")
                box.Size = UDim2.new(0, 18, 0, 18)
                box.Position = UDim2.new(1, -32, 0.5, -9)
                box.BackgroundColor3 = state and theme.Accent or theme.Primary
                box.BorderSizePixel = 0
                box.Parent = item
                createRound(box, UDim.new(0, 5))
                local boxStroke = createStroke(box, state and theme.NeonStroke or theme.Stroke, 1)

                local function render()
                    tween(box, { BackgroundColor3 = state and theme.Accent or theme.Primary })
                    tween(boxStroke, { Color = state and theme.NeonStroke or theme.Stroke })
                end

                btn.MouseEnter:Connect(function()
                    tween(item, { BackgroundColor3 = theme.Header })
                    tween(st, { Color = theme.StrokeHover })
                end)
                btn.MouseLeave:Connect(function()
                    tween(item, { BackgroundColor3 = theme.Background })
                    tween(st, { Color = theme.Stroke })
                end)

                btn.MouseButton1Click:Connect(function()
                    state = not state
                    render()
                    if callback then
                        task.spawn(function()
                            callback(state)
                        end)
                    end
                end)

                local waiting = false
                local captureConn
                local bindToken
                local currentKey = normalizeKey(options.Keybind or options.Key)

                local function renderKey()
                    if waiting then
                        keyText.Text = "..."
                        keyText.TextColor3 = theme.SubText
                    else
                        keyText.Text = currentKey and currentKey.Name or ""
                        keyText.TextColor3 = currentKey and theme.Text or theme.SubText
                    end
                end

                local function setKeybind(key)
                    currentKey = normalizeKey(key)
                    if bindToken then
                        window:_unbindKey(bindToken)
                        bindToken = nil
                    end
                    if currentKey then
                        bindToken = window:_bindKey(currentKey, function()
                            state = not state
                            render()
                            if callback then
                                callback(state)
                            end
                        end)
                    end
                    renderKey()
                end

                local function stopCapture()
                    waiting = false
                    safeDisconnect(captureConn)
                    captureConn = nil
                    tween(keyStroke, { Color = theme.Stroke })
                    renderKey()
                end

                local function startCapture()
                    if waiting then
                        return
                    end
                    waiting = true
                    tween(keyStroke, { Color = theme.NeonStroke })
                    renderKey()
                    safeDisconnect(captureConn)
                    captureConn = UserInputService.InputBegan:Connect(function(input, gp)
                        if gp then
                            return
                        end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                                setKeybind(nil)
                                stopCapture()
                                return
                            end
                            setKeybind(input.KeyCode)
                            stopCapture()
                        end
                    end)
                end

                if showKeybind then
                    keyBtn.MouseEnter:Connect(function()
                        tween(keyBtn, { BackgroundColor3 = theme.PrimaryHover })
                        if not waiting then
                            tween(keyStroke, { Color = theme.StrokeHover })
                        end
                    end)
                    keyBtn.MouseLeave:Connect(function()
                        tween(keyBtn, { BackgroundColor3 = theme.Primary })
                        tween(keyStroke, { Color = waiting and theme.NeonStroke or theme.Stroke })
                    end)

                    keyBtn.MouseButton1Click:Connect(function()
                        if waiting then
                            stopCapture()
                        else
                            startCapture()
                        end
                    end)
                end

                render()
                if showKeybind then
                    if currentKey then
                        setKeybind(currentKey)
                    else
                        renderKey()
                    end
                end
                tab._updateCanvas()
                return {
                    Get = function() return state end,
                    Set = function(_, v)
                        state = not not v
                        render()
                        tab._updateCanvas()
                    end,
                    SetText = function(_, v)
                        lbl.Text = tostring(v)
                        tab._updateCanvas()
                    end,
                    GetKeybind = function()
                        return currentKey
                    end,
                    SetKeybind = function(_, key)
                        if showKeybind then
                            setKeybind(key)
                        end
                    end,
                    ClearKeybind = function()
                        if showKeybind then
                            setKeybind(nil)
                        end
                    end
                }
            end

            function section:AddKeybind(text, options, callback)
                if type(options) == "function" and callback == nil then
                    callback = options
                    options = {}
                end
                options = options or {}

                local item, st = baseItemFrame(44)
                item.ClipsDescendants = true

                local title = Instance.new("TextLabel")
                title.BackgroundTransparency = 1
                title.Size = UDim2.new(1, -12, 0, 18)
                title.Position = UDim2.new(0, 12, 0, 4)
                title.Font = Enum.Font.GothamSemibold
                title.Text = text or "Keybind"
                title.TextColor3 = theme.Text
                title.TextSize = 13
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Parent = item

                local box = Instance.new("TextButton")
                box.BackgroundColor3 = theme.Primary
                box.BorderSizePixel = 0
                box.Size = UDim2.new(1, -24, 0, 22)
                box.Position = UDim2.new(0, 12, 0, 22)
                box.AutoButtonColor = false
                box.Text = ""
                box.Parent = item
                createRound(box, UDim.new(0, 6))
                local boxStroke = createStroke(box, theme.Stroke, 1)

                local keyLabel = Instance.new("TextLabel")
                keyLabel.BackgroundTransparency = 1
                keyLabel.Size = UDim2.new(1, -12, 1, 0)
                keyLabel.Position = UDim2.new(0, 10, 0, 0)
                keyLabel.Font = Enum.Font.Gotham
                keyLabel.TextColor3 = theme.SubText
                keyLabel.TextSize = 13
                keyLabel.TextXAlignment = Enum.TextXAlignment.Left
                keyLabel.TextTruncate = Enum.TextTruncate.AtEnd
                keyLabel.Parent = box

                local waiting = false
                local keyConn
                local bindToken
                local currentKey = normalizeKey(options.Default)

                local function renderKey()
                    if waiting then
                        keyLabel.Text = options.WaitText or "Press a key..."
                        keyLabel.TextColor3 = theme.SubText
                    else
                        keyLabel.Text = currentKey and currentKey.Name or (options.NoneText or "None")
                        keyLabel.TextColor3 = currentKey and theme.Text or theme.SubText
                    end
                end

                local function setKey(key)
                    currentKey = normalizeKey(key)
                    if bindToken then
                        window:_unbindKey(bindToken)
                        bindToken = nil
                    end
                    if currentKey then
                        bindToken = window:_bindKey(currentKey, function()
                            if callback then
                                callback(currentKey)
                            end
                        end)
                    end
                    renderKey()
                end

                local function stopCapture()
                    waiting = false
                    safeDisconnect(keyConn)
                    keyConn = nil
                    tween(boxStroke, { Color = theme.Stroke })
                    renderKey()
                end

                local function startCapture()
                    if waiting then
                        return
                    end
                    waiting = true
                    tween(boxStroke, { Color = theme.NeonStroke })
                    renderKey()
                    safeDisconnect(keyConn)
                    keyConn = UserInputService.InputBegan:Connect(function(input, gp)
                        if gp then
                            return
                        end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                                setKey(nil)
                                stopCapture()
                                return
                            end
                            setKey(input.KeyCode)
                            stopCapture()
                        end
                    end)
                end

                box.MouseEnter:Connect(function()
                    tween(box, { BackgroundColor3 = theme.PrimaryHover })
                    if not waiting then
                        tween(boxStroke, { Color = theme.StrokeHover })
                    end
                    tween(st, { Color = theme.StrokeHover })
                end)
                box.MouseLeave:Connect(function()
                    tween(box, { BackgroundColor3 = theme.Primary })
                    tween(boxStroke, { Color = waiting and theme.NeonStroke or theme.Stroke })
                    tween(st, { Color = theme.Stroke })
                end)

                box.MouseButton1Click:Connect(function()
                    if waiting then
                        stopCapture()
                    else
                        startCapture()
                    end
                end)

                renderKey()
                if currentKey then
                    setKey(currentKey)
                end
                tab._updateCanvas()
                return {
                    Get = function() return currentKey end,
                    Set = function(_, key)
                        setKey(key)
                    end,
                    Clear = function()
                        setKey(nil)
                    end,
                    SetText = function(_, v)
                        title.Text = tostring(v)
                        tab._updateCanvas()
                    end,
                    SetCallback = function(_, fn)
                        callback = fn
                    end
                }
            end

            function section:AddLabel(text, options)
                options = options or {}
                elementOrder += 1
                local item = Instance.new("Frame")
                item.Size = UDim2.new(1, 0, 0, options.Height or 30)
                item.BackgroundTransparency = 1
                item.BorderSizePixel = 0
                item.LayoutOrder = elementOrder
                item.Parent = secList

                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.Font = options.Font or Enum.Font.Gotham
                lbl.Text = text or "Label"
                lbl.TextColor3 = options.Color or theme.SubText
                lbl.TextSize = options.TextSize or 13
                lbl.TextXAlignment = options.Align or Enum.TextXAlignment.Left
                lbl.TextWrapped = options.Wrap == nil and true or not not options.Wrap
                lbl.Parent = item

                tab._updateCanvas()
                return {
                    SetText = function(_, v)
                        lbl.Text = tostring(v)
                        tab._updateCanvas()
                    end,
                    SetColor = function(_, c)
                        lbl.TextColor3 = c
                    end,
                    SetTextSize = function(_, s)
                        lbl.TextSize = s
                        tab._updateCanvas()
                    end,
                    Instance = lbl
                }
            end

            function section:AddImage(imageId, options)
                options = options or {}
                local height = options.Height or 120
                local item, _ = baseItemFrame(height)
                item.BackgroundColor3 = options.BackgroundColor3 or theme.Background
                item.ClipsDescendants = true

                local img = Instance.new("ImageLabel")
                img.BackgroundTransparency = 1
                img.Size = UDim2.new(1, -12, 1, -12)
                img.Position = UDim2.new(0, 6, 0, 6)
                img.Image = imageId or ""
                img.ImageColor3 = options.ImageColor3 or Color3.new(1, 1, 1)
                img.ScaleType = options.ScaleType or Enum.ScaleType.Fit
                img.Parent = item

                tab._updateCanvas()
                return {
                    SetImage = function(_, v)
                        img.Image = tostring(v)
                    end,
                    SetImageColor3 = function(_, c)
                        img.ImageColor3 = c
                    end,
                    Instance = img
                }
            end

            function section:AddTextbox(text, options, callback)
                if type(options) == "function" and callback == nil then
                    callback = options
                    options = {}
                end
                options = options or {}

                local item, st = baseItemFrame(44)

                local title = Instance.new("TextLabel")
                title.BackgroundTransparency = 1
                title.Size = UDim2.new(1, -12, 0, 18)
                title.Position = UDim2.new(0, 12, 0, 4)
                title.Font = Enum.Font.GothamSemibold
                title.Text = text or "Textbox"
                title.TextColor3 = theme.Text
                title.TextSize = 13
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Parent = item

                local box = Instance.new("TextBox")
                box.ClearTextOnFocus = false
                box.Size = UDim2.new(1, -24, 0, 20)
                box.Position = UDim2.new(0, 12, 0, 22)
                box.BackgroundColor3 = theme.Primary
                box.BorderSizePixel = 0
                box.ClipsDescendants = true
                box.Font = Enum.Font.Gotham
                box.Text = options.Default or ""
                box.PlaceholderText = options.Placeholder or ""
                box.TextColor3 = theme.Text
                box.PlaceholderColor3 = theme.SubText
                box.TextSize = 13
                box.TextXAlignment = Enum.TextXAlignment.Left
                box.Parent = item
                createRound(box, UDim.new(0, 6))
                local boxStroke = createStroke(box, theme.Stroke, 1)

                local boxPad = Instance.new("UIPadding")
                boxPad.PaddingLeft = UDim.new(0, 8)
                boxPad.PaddingRight = UDim.new(0, 8)
                boxPad.Parent = box

                local function fire(v)
                    if callback then
                        task.spawn(function()
                            callback(v)
                        end)
                    end
                end

                box.Focused:Connect(function()
                    tween(item, { BackgroundColor3 = theme.Header })
                    tween(st, { Color = theme.StrokeHover })
                    tween(boxStroke, { Color = theme.NeonStroke })
                end)
                box.FocusLost:Connect(function(enterPressed)
                    tween(item, { BackgroundColor3 = theme.Background })
                    tween(st, { Color = theme.Stroke })
                    tween(boxStroke, { Color = theme.Stroke })
                    if enterPressed or options.FireOnFocusLost then
                        fire(box.Text)
                    end
                end)

                tab._updateCanvas()
                return {
                    Get = function() return box.Text end,
                    Set = function(_, v)
                        box.Text = tostring(v)
                    end,
                    SetText = function(_, v)
                        title.Text = tostring(v)
                        tab._updateCanvas()
                    end,
                    SetPlaceholder = function(_, v)
                        box.PlaceholderText = tostring(v)
                    end,
                    SetCallback = function(_, fn)
                        callback = fn
                    end,
                    Instance = box
                }
            end

            function section:AddSlider(text, options, callback)
                if type(options) == "function" and callback == nil then
                    callback = options
                    options = {}
                end
                options = options or {}

                local min = options.Min or 0
                local max = options.Max or 100
                local step = options.Step or 1
                local value = options.Default
                if value == nil then value = min end

                local item, st = baseItemFrame(54)

                local title = Instance.new("TextLabel")
                title.BackgroundTransparency = 1
                title.Size = UDim2.new(1, -80, 0, 18)
                title.Position = UDim2.new(0, 12, 0, 6)
                title.Font = Enum.Font.GothamSemibold
                title.Text = text or "Slider"
                title.TextColor3 = theme.Text
                title.TextSize = 13
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Parent = item

                local valueLabel = Instance.new("TextLabel")
                valueLabel.BackgroundTransparency = 1
                valueLabel.Size = UDim2.new(0, 70, 0, 18)
                valueLabel.Position = UDim2.new(1, -82, 0, 6)
                valueLabel.Font = Enum.Font.Gotham
                valueLabel.Text = tostring(value)
                valueLabel.TextColor3 = theme.SubText
                valueLabel.TextSize = 12
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = item

                local barBg = Instance.new("Frame")
                barBg.Size = UDim2.new(1, -24, 0, 8)
                barBg.Position = UDim2.new(0, 12, 0, 34)
                barBg.BackgroundColor3 = theme.Primary
                barBg.BorderSizePixel = 0
                barBg.Parent = item
                createRound(barBg, UDim.new(1, 0))
                createStroke(barBg, theme.Stroke, 1)

                local barFill = Instance.new("Frame")
                barFill.Size = UDim2.new(0, 0, 1, 0)
                barFill.BackgroundColor3 = theme.Accent
                barFill.BorderSizePixel = 0
                barFill.Parent = barBg
                createRound(barFill, UDim.new(1, 0))

                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 14, 0, 14)
                knob.BackgroundColor3 = theme.Text
                knob.BorderSizePixel = 0
                knob.Parent = barBg
                createRound(knob, UDim.new(1, 0))

                local drag = false

                local function clamp(v)
                    return math.max(min, math.min(max, v))
                end

                local function quantize(v)
                    if step <= 0 then return v end
                    local n = math.floor((v - min) / step + 0.5)
                    return min + n * step
                end

                local function pctFromValue(v)
                    if max == min then return 0 end
                    return (v - min) / (max - min)
                end

                local function setValue(v, fire)
                    value = quantize(clamp(v))
                    local pct = pctFromValue(value)
                    local w = barBg.AbsoluteSize.X
                    local x = math.floor(w * pct)
                    barFill.Size = UDim2.new(0, x, 1, 0)
                    knob.Position = UDim2.new(0, math.clamp(x - 7, -7, w - 7), 0.5, -7)
                    valueLabel.Text = tostring(value)
                    if fire and callback then
                        task.spawn(function()
                            callback(value)
                        end)
                    end
                end

                local function setFromInput(input)
                    local x = input.Position.X - barBg.AbsolutePosition.X
                    local pct = x / math.max(1, barBg.AbsoluteSize.X)
                    local v = min + (max - min) * pct
                    setValue(v, true)
                end

                barBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        drag = true
                        tween(st, { Color = theme.StrokeHover })
                        setFromInput(input)
                    end
                end)

                barBg.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        drag = false
                        tween(st, { Color = theme.Stroke })
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        setFromInput(input)
                    end
                end)

                barBg:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    setValue(value, false)
                end)

                setValue(value, false)
                tab._updateCanvas()
                return {
                    Get = function() return value end,
                    Set = function(_, v)
                        setValue(v, false)
                    end,
                    SetText = function(_, v)
                        title.Text = tostring(v)
                        tab._updateCanvas()
                    end,
                    SetCallback = function(_, fn)
                        callback = fn
                    end
                }
            end

            function section:AddDropdown(text, options, callback)
                if type(options) == "table" and options.Options == nil and options[1] ~= nil then
                    options = { Options = options }
                end
                if type(options) == "function" and callback == nil then
                    callback = options
                    options = {}
                end
                options = options or {}

                local list = options.Options or {}
                local selected = options.Default

                local item, st = baseItemFrame(44)
                item.ClipsDescendants = true

                local title = Instance.new("TextLabel")
                title.BackgroundTransparency = 1
                title.Size = UDim2.new(1, -12, 0, 18)
                title.Position = UDim2.new(0, 12, 0, 4)
                title.Font = Enum.Font.GothamSemibold
                title.Text = text or "Dropdown"
                title.TextColor3 = theme.Text
                title.TextSize = 13
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Parent = item

                local openBtn = Instance.new("TextButton")
                openBtn.BackgroundColor3 = theme.Primary
                openBtn.BorderSizePixel = 0
                openBtn.Size = UDim2.new(1, -24, 0, 22)
                openBtn.Position = UDim2.new(0, 12, 0, 22)
                openBtn.AutoButtonColor = false
                openBtn.Text = ""
                openBtn.ClipsDescendants = true
                openBtn.Parent = item
                createRound(openBtn, UDim.new(0, 6))
                local openStroke = createStroke(openBtn, theme.Stroke, 1)

                local openPad = Instance.new("UIPadding")
                openPad.PaddingLeft = UDim.new(0, 2)
                openPad.PaddingRight = UDim.new(0, 2)
                openPad.Parent = openBtn

                local valueLabel = Instance.new("TextLabel")
                valueLabel.BackgroundTransparency = 1
                valueLabel.Size = UDim2.new(1, -28, 1, 0)
                valueLabel.Position = UDim2.new(0, 10, 0, 0)
                valueLabel.Font = Enum.Font.Gotham
                valueLabel.Text = selected and tostring(selected) or (options.Placeholder or "Select")
                valueLabel.TextColor3 = selected and theme.Text or theme.SubText
                valueLabel.TextSize = 13
                valueLabel.TextXAlignment = Enum.TextXAlignment.Left
                valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
                valueLabel.Parent = openBtn

                local arrow = Instance.new("TextLabel")
                arrow.BackgroundTransparency = 1
                arrow.Size = UDim2.new(0, 18, 1, 0)
                arrow.Position = UDim2.new(1, -20, 0, 0)
                arrow.Font = Enum.Font.GothamBold
                arrow.Text = "v"
                arrow.TextColor3 = theme.SubText
                arrow.TextSize = 12
                arrow.TextXAlignment = Enum.TextXAlignment.Center
                arrow.Parent = openBtn

                local isOpen = false

                local function closeState()
                    isOpen = false
                    arrow.Text = "v"
                end

                local listHolder = Instance.new("Frame")
                listHolder.BackgroundTransparency = 1
                listHolder.BorderSizePixel = 0
                listHolder.Size = UDim2.new(1, -24, 0, 0)
                listHolder.Position = UDim2.new(0, 12, 0, 46)
                listHolder.ClipsDescendants = true
                listHolder.Parent = item

                local listBg = Instance.new("Frame")
                listBg.BackgroundColor3 = theme.Header
                listBg.BorderSizePixel = 0
                listBg.Size = UDim2.new(1, 0, 1, 0)
                listBg.Parent = listHolder
                createRound(listBg, UDim.new(0, 10))
                createStroke(listBg, theme.Stroke, 1)

                local popPad = Instance.new("UIPadding")
                popPad.PaddingTop = UDim.new(0, 8)
                popPad.PaddingLeft = UDim.new(0, 8)
                popPad.PaddingRight = UDim.new(0, 8)
                popPad.PaddingBottom = UDim.new(0, 8)
                popPad.Parent = listBg

                local sf = Instance.new("ScrollingFrame")
                sf.BackgroundTransparency = 1
                sf.BorderSizePixel = 0
                sf.Size = UDim2.new(1, 0, 1, 0)
                sf.ScrollBarThickness = 0
                sf.CanvasSize = UDim2.new(0, 0, 0, 0)
                sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
                sf.Parent = listBg

                local layout = Instance.new("UIListLayout")
                layout.FillDirection = Enum.FillDirection.Vertical
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0, 6)
                layout.Parent = sf

                local function rebuild()
                    sf:ClearAllChildren()
                    layout.Parent = sf
                    for i, opt in ipairs(list) do
                        local b = Instance.new("TextButton")
                        b.Size = UDim2.new(1, 0, 0, 26)
                        b.BackgroundColor3 = theme.Background
                        b.BorderSizePixel = 0
                        b.Text = ""
                        b.AutoButtonColor = false
                        b.LayoutOrder = i
                        b.Parent = sf
                        createRound(b, UDim.new(0, 8))
                        local bst = createStroke(b, theme.Stroke, 1)

                        local t = Instance.new("TextLabel")
                        t.BackgroundTransparency = 1
                        t.Size = UDim2.new(1, -12, 1, 0)
                        t.Position = UDim2.new(0, 12, 0, 0)
                        t.Font = Enum.Font.Gotham
                        t.Text = tostring(opt)
                        t.TextColor3 = theme.Text
                        t.TextSize = 13
                        t.TextXAlignment = Enum.TextXAlignment.Left
                        t.TextTruncate = Enum.TextTruncate.AtEnd
                        t.Parent = b

                        b.MouseEnter:Connect(function()
                            tween(b, { BackgroundColor3 = theme.Primary })
                            tween(bst, { Color = theme.StrokeHover })
                        end)
                        b.MouseLeave:Connect(function()
                            tween(b, { BackgroundColor3 = theme.Background })
                            tween(bst, { Color = theme.Stroke })
                        end)

                        b.MouseButton1Click:Connect(function()
                            selected = opt
                            valueLabel.Text = tostring(opt)
                            valueLabel.TextColor3 = theme.Text
                            if callback then
                                task.spawn(function()
                                    callback(selected)
                                end)
                            end
                            isOpen = false
                            arrow.Text = "v"
                            tween(listHolder, { Size = UDim2.new(1, -24, 0, 0) })
                            tween(item, { Size = UDim2.new(1, 0, 0, 44) })
                            tab._updateCanvas()
                        end)
                    end
                end

                local function openInline()
                    local maxVisible = options.MaxVisible or 6
                    local rowH = 26
                    local pad = 6
                    local count = math.min(#list, maxVisible)
                    local h = count > 0 and (count * rowH + (count - 1) * pad) or 0
                    local popupH = math.max(34, h + 16)
                    rebuild()
                    tween(listHolder, { Size = UDim2.new(1, -24, 0, popupH) })
                    tween(item, { Size = UDim2.new(1, 0, 0, 44 + popupH + 6) })
                    tab._updateCanvas()
                end

                local function closeInline()
                    closeState()
                    tween(listHolder, { Size = UDim2.new(1, -24, 0, 0) })
                    tween(item, { Size = UDim2.new(1, 0, 0, 44) })
                    tab._updateCanvas()
                end

                openBtn.MouseEnter:Connect(function()
                    tween(openBtn, { BackgroundColor3 = theme.PrimaryHover })
                    tween(openStroke, { Color = theme.StrokeHover })
                    tween(st, { Color = theme.StrokeHover })
                end)
                openBtn.MouseLeave:Connect(function()
                    tween(openBtn, { BackgroundColor3 = theme.Primary })
                    tween(openStroke, { Color = theme.Stroke })
                    tween(st, { Color = theme.Stroke })
                end)

                openBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    arrow.Text = isOpen and "^" or "v"
                    if isOpen then
                        openInline()
                    else
                        closeInline()
                    end
                end)

                tab._updateCanvas()
                return {
                    Get = function() return selected end,
                    Set = function(_, v)
                        selected = v
                        valueLabel.Text = selected and tostring(selected) or (options.Placeholder or "Select")
                        valueLabel.TextColor3 = selected and theme.Text or theme.SubText
                    end,
                    SetText = function(_, v)
                        title.Text = tostring(v)
                        tab._updateCanvas()
                    end,
                    SetOptions = function(_, arr)
                        list = arr or {}
                        if isOpen then
                            openInline()
                        end
                        tab._updateCanvas()
                    end,
                    SetCallback = function(_, fn)
                        callback = fn
                    end
                }
            end

            function section:AddMultiDropdown(text, options, callback)
                if type(options) == "table" and options.Options == nil and options[1] ~= nil then
                    options = { Options = options }
                end
                if type(options) == "function" and callback == nil then
                    callback = options
                    options = {}
                end
                options = options or {}

                local list = options.Options or {}
                local selectedMap = {}
                if options.Default then
                    for _, v in ipairs(options.Default) do
                        selectedMap[v] = true
                    end
                end

                local function selectedArray()
                    local out = {}
                    for _, v in ipairs(list) do
                        if selectedMap[v] then
                            table.insert(out, v)
                        end
                    end
                    return out
                end

                local item, st = baseItemFrame(44)
                item.ClipsDescendants = true

                local title = Instance.new("TextLabel")
                title.BackgroundTransparency = 1
                title.Size = UDim2.new(1, -12, 0, 18)
                title.Position = UDim2.new(0, 12, 0, 4)
                title.Font = Enum.Font.GothamSemibold
                title.Text = text or "MultiDropdown"
                title.TextColor3 = theme.Text
                title.TextSize = 13
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Parent = item

                local openBtn = Instance.new("TextButton")
                openBtn.BackgroundColor3 = theme.Primary
                openBtn.BorderSizePixel = 0
                openBtn.Size = UDim2.new(1, -24, 0, 22)
                openBtn.Position = UDim2.new(0, 12, 0, 22)
                openBtn.AutoButtonColor = false
                openBtn.Text = ""
                openBtn.ClipsDescendants = true
                openBtn.Parent = item
                createRound(openBtn, UDim.new(0, 6))
                local openStroke = createStroke(openBtn, theme.Stroke, 1)

                local openPad = Instance.new("UIPadding")
                openPad.PaddingLeft = UDim.new(0, 2)
                openPad.PaddingRight = UDim.new(0, 2)
                openPad.Parent = openBtn

                local valueLabel = Instance.new("TextLabel")
                valueLabel.BackgroundTransparency = 1
                valueLabel.Size = UDim2.new(1, -28, 1, 0)
                valueLabel.Position = UDim2.new(0, 10, 0, 0)
                valueLabel.Font = Enum.Font.Gotham
                valueLabel.Text = options.Placeholder or "Select"
                valueLabel.TextColor3 = theme.SubText
                valueLabel.TextSize = 13
                valueLabel.TextXAlignment = Enum.TextXAlignment.Left
                valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
                valueLabel.Parent = openBtn

                local arrow = Instance.new("TextLabel")
                arrow.BackgroundTransparency = 1
                arrow.Size = UDim2.new(0, 18, 1, 0)
                arrow.Position = UDim2.new(1, -20, 0, 0)
                arrow.Font = Enum.Font.GothamBold
                arrow.Text = "v"
                arrow.TextColor3 = theme.SubText
                arrow.TextSize = 12
                arrow.TextXAlignment = Enum.TextXAlignment.Center
                arrow.Parent = openBtn

                local isOpen = false

                local function closeState()
                    isOpen = false
                    arrow.Text = "v"
                end

                local function refreshValueText()
                    local arr = selectedArray()
                    if #arr == 0 then
                        valueLabel.Text = options.Placeholder or "Select"
                        valueLabel.TextColor3 = theme.SubText
                    else
                        local out = {}
                        for i, v in ipairs(arr) do
                            out[i] = tostring(v)
                        end
                        valueLabel.Text = table.concat(out, ", ")
                        valueLabel.TextColor3 = theme.Text
                    end
                end



                local listHolder = Instance.new("Frame")
                listHolder.BackgroundTransparency = 1
                listHolder.BorderSizePixel = 0
                listHolder.Size = UDim2.new(1, -24, 0, 0)
                listHolder.Position = UDim2.new(0, 12, 0, 46)
                listHolder.ClipsDescendants = true
                listHolder.Parent = item

                local listBg = Instance.new("Frame")
                listBg.BackgroundColor3 = theme.Header
                listBg.BorderSizePixel = 0
                listBg.Size = UDim2.new(1, 0, 1, 0)
                listBg.Parent = listHolder
                createRound(listBg, UDim.new(0, 10))
                createStroke(listBg, theme.Stroke, 1)

                local popPad = Instance.new("UIPadding")
                popPad.PaddingTop = UDim.new(0, 8)
                popPad.PaddingLeft = UDim.new(0, 8)
                popPad.PaddingRight = UDim.new(0, 8)
                popPad.PaddingBottom = UDim.new(0, 8)
                popPad.Parent = listBg

                local sf = Instance.new("ScrollingFrame")
                sf.BackgroundTransparency = 1
                sf.BorderSizePixel = 0
                sf.Size = UDim2.new(1, 0, 1, 0)
                sf.ScrollBarThickness = 0
                sf.CanvasSize = UDim2.new(0, 0, 0, 0)
                sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
                sf.Parent = listBg

                local layout = Instance.new("UIListLayout")
                layout.FillDirection = Enum.FillDirection.Vertical
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0, 6)
                layout.Parent = sf

                local function rebuild()
                    sf:ClearAllChildren()
                    layout.Parent = sf
                    for i, opt in ipairs(list) do
                        local b = Instance.new("TextButton")
                        b.Size = UDim2.new(1, 0, 0, 26)
                        b.BackgroundColor3 = theme.Background
                        b.BorderSizePixel = 0
                        b.Text = ""
                        b.AutoButtonColor = false
                        b.LayoutOrder = i
                        b.Parent = sf
                        createRound(b, UDim.new(0, 8))
                        local bst = createStroke(b, theme.Stroke, 1)

                        local t = Instance.new("TextLabel")
                        t.BackgroundTransparency = 1
                        t.Size = UDim2.new(1, -36, 1, 0)
                        t.Position = UDim2.new(0, 12, 0, 0)
                        t.Font = Enum.Font.Gotham
                        t.Text = tostring(opt)
                        t.TextColor3 = theme.Text
                        t.TextSize = 13
                        t.TextXAlignment = Enum.TextXAlignment.Left
                        t.TextTruncate = Enum.TextTruncate.AtEnd
                        t.Parent = b

                        local dot = Instance.new("Frame")
                        dot.Size = UDim2.new(0, 10, 0, 10)
                        dot.Position = UDim2.new(1, -20, 0.5, -5)
                        dot.BackgroundColor3 = theme.Accent
                        dot.BorderSizePixel = 0
                        dot.BackgroundTransparency = selectedMap[opt] and 0 or 1
                        dot.Parent = b
                        createRound(dot, UDim.new(1, 0))

                        b.MouseEnter:Connect(function()
                            tween(b, { BackgroundColor3 = theme.Primary })
                            tween(bst, { Color = theme.StrokeHover })
                        end)
                        b.MouseLeave:Connect(function()
                            tween(b, { BackgroundColor3 = theme.Background })
                            tween(bst, { Color = theme.Stroke })
                        end)

                        b.MouseButton1Click:Connect(function()
                            selectedMap[opt] = not selectedMap[opt]
                            dot.BackgroundTransparency = selectedMap[opt] and 0 or 1
                            refreshValueText()
                            if callback then
                                local arr = selectedArray()
                                task.spawn(function()
                                    callback(arr)
                                end)
                            end
                        end)
                    end
                end

                local function openInline()
                    local maxVisible = options.MaxVisible or 7
                    local rowH = 26
                    local pad = 6
                    local count = math.min(#list, maxVisible)
                    local h = count > 0 and (count * rowH + (count - 1) * pad) or 0
                    local popupH = math.max(34, h + 16)
                    rebuild()
                    tween(listHolder, { Size = UDim2.new(1, -24, 0, popupH) })
                    tween(item, { Size = UDim2.new(1, 0, 0, 44 + popupH + 6) })
                    tab._updateCanvas()
                end

                local function closeInline()
                    closeState()
                    tween(listHolder, { Size = UDim2.new(1, -24, 0, 0) })
                    tween(item, { Size = UDim2.new(1, 0, 0, 44) })
                    tab._updateCanvas()
                end

                openBtn.MouseEnter:Connect(function()
                    tween(openBtn, { BackgroundColor3 = theme.PrimaryHover })
                    tween(openStroke, { Color = theme.StrokeHover })
                    tween(st, { Color = theme.StrokeHover })
                end)
                openBtn.MouseLeave:Connect(function()
                    tween(openBtn, { BackgroundColor3 = theme.Primary })
                    tween(openStroke, { Color = theme.Stroke })
                    tween(st, { Color = theme.Stroke })
                end)

                openBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    arrow.Text = isOpen and "^" or "v"
                    if isOpen then
                        openInline()
                    else
                        closeInline()
                    end
                end)

                refreshValueText()
                tab._updateCanvas()
                return {
                    Get = function() return selectedArray() end,
                    Set = function(_, arr)
                        selectedMap = {}
                        for _, v in ipairs(arr or {}) do
                            selectedMap[v] = true
                        end
                        refreshValueText()
                        if isOpen then
                            openInline()
                        end
                    end,
                    SetOptions = function(_, arr)
                        list = arr or {}
                        refreshValueText()
                        if isOpen then
                            openInline()
                        end
                        tab._updateCanvas()
                    end,
                    SetText = function(_, v)
                        title.Text = tostring(v)
                        tab._updateCanvas()
                    end,
                    SetCallback = function(_, fn)
                        callback = fn
                    end
                }
            end

            tab._updateCanvas()
            return section
        end

        tabButton.MouseButton1Click:Connect(function()
            setActiveTab(tab)
        end)

        table.insert(window._tabs, tab)
        if not window._activeTab then
            setActiveTab(tab)
        end

        return tab
    end

    return window
end

return Library
