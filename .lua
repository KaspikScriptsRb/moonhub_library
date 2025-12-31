--[[ 
    MoonHub UI Library Remastered
    Optimized, Beautified, and Indented by AI
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

--// Theme Configuration
local theme = {
    Background    = Color3.fromRGB(20, 22, 28),
    Header        = Color3.fromRGB(25, 28, 35),
    Primary       = Color3.fromRGB(32, 35, 45),
    PrimaryHover  = Color3.fromRGB(42, 45, 58),
    Accent        = Color3.fromRGB(114, 137, 218), -- Blurple-like accent
    AccentHover   = Color3.fromRGB(140, 160, 235),
    Text          = Color3.fromRGB(245, 245, 250),
    SubText       = Color3.fromRGB(150, 155, 170),
    Stroke        = Color3.fromRGB(50, 55, 70),
    StrokeHover   = Color3.fromRGB(80, 85, 105),
    NeonStroke    = Color3.fromRGB(114, 137, 218),
    Shadow        = Color3.fromRGB(0, 0, 0)
}

--// Utility Functions
local function tween(object, properties, time, style, direction)
    local info = TweenInfo.new(
        time or 0.25, 
        style or Enum.EasingStyle.Exponential, 
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(object, info, properties)
    t:Play()
    return t
end

local function safeParent(gui)
    local success, _ = pcall(function()
        gui.Parent = CoreGui
    end)
    if not success then
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

local function makeDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject
    local dragging, dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X, 
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            -- Smooth drag using TweenService
            TweenService:Create(guiObject, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        end
    end)
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 6)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color or theme.Stroke
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function createShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.ZIndex = 0
    shadow.Image = "rbxassetid://6015897843" -- Soft glow texture
    shadow.ImageColor3 = theme.Shadow
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
end

local function normalizeKey(key)
    if not key then return nil end
    if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
        return key
    end
    if type(key) == "string" then
        local success, result = pcall(function() return Enum.KeyCode[key] end)
        if success then return result end
    end
    return nil
end

local function safeDisconnect(connection)
    if connection then connection:Disconnect() end
end

--// Library Class
local Library = {}
Library.__index = Library

function Library:Destroy()
    if self._gui then self._gui:Destroy() end
end

function Library:CreateWindow(options)
    options = options or {}
    
    local window = setmetatable({}, Library)
    
    local gui = Instance.new("ScreenGui")
    gui.Name = options.Name or "MoonHubUI"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    safeParent(gui)
    
    -- Main Container
    local container = Instance.new("Frame")
    container.Name = "Main"
    container.Size = options.Size or UDim2.new(0, 700, 0, 450)
    container.Position = options.Position or UDim2.new(0.5, -350, 0.5, -225)
    container.BackgroundColor3 = theme.Background
    container.BorderSizePixel = 0
    container.Parent = gui
    
    createCorner(container, UDim.new(0, 8))
    createStroke(container, theme.Stroke, 1.5)
    createShadow(container)
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = theme.Header
    header.BorderSizePixel = 0
    header.Parent = container
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    -- Fix header bottom corners being round (we want them flat)
    local headerCover = Instance.new("Frame")
    headerCover.Name = "Cover"
    headerCover.BackgroundColor3 = theme.Header
    headerCover.BorderSizePixel = 0
    headerCover.Size = UDim2.new(1, 0, 0, 10)
    headerCover.Position = UDim2.new(0, 0, 1, -10)
    headerCover.Parent = header
    
    makeDraggable(container, header)
    
    -- Header Elements
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.BackgroundTransparency = 1
    icon.Image = options.Icon or "rbxassetid://13161991129"
    icon.ImageColor3 = theme.Accent
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 12, 0.5, -10)
    icon.Parent = header
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = options.Title or "Moon Hub"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(1, -120, 0, 20)
    titleLabel.Position = UDim2.new(0, 40, 0.5, -10)
    titleLabel.Parent = header
    
    -- Close/Minimize Buttons
    local function createHeaderBtn(text, offset)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 28, 0, 28)
        btn.Position = UDim2.new(1, offset, 0.5, -14)
        btn.BackgroundColor3 = theme.Primary
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = header
        
        createCorner(btn, UDim.new(0, 6))
        createStroke(btn, theme.Stroke, 1)
        
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.Text = text
        label.TextColor3 = theme.SubText
        label.TextSize = 14
        label.Parent = btn
        
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = theme.PrimaryHover})
            tween(label, {TextColor3 = theme.Text})
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = theme.Primary})
            tween(label, {TextColor3 = theme.SubText})
        end)
        
        return btn, label
    end
    
    local closeBtn = createHeaderBtn("✕", -38)
    local minBtn = createHeaderBtn("−", -72)
    
    closeBtn.MouseButton1Click:Connect(function() window:Destroy() end)
    
    local minimized = false
    local openSize = container.Size
    local minSize = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, 45)
    
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(container, {Size = minSize})
            -- Hide body elements
            container.Body.Visible = false
        else
            container.Body.Visible = true
            tween(container, {Size = openSize})
        end
    end)
    
    -- Body Area
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 1, -45)
    body.Position = UDim2.new(0, 0, 0, 45)
    body.BackgroundTransparency = 1
    body.ClipsDescendants = true
    body.Parent = container
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 180, 1, -24)
    sidebar.Position = UDim2.new(0, 12, 0, 12)
    sidebar.BackgroundColor3 = theme.Header
    sidebar.BorderSizePixel = 0
    sidebar.Parent = body
    
    createCorner(sidebar, UDim.new(0, 8))
    createStroke(sidebar, theme.Stroke, 1)
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.FillDirection = Enum.FillDirection.Vertical
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.Parent = sidebar
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    sidebarPadding.PaddingBottom = UDim.new(0, 10)
    sidebarPadding.Parent = sidebar
    
    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "Content"
    contentArea.Size = UDim2.new(1, -216, 1, -24)
    contentArea.Position = UDim2.new(0, 204, 0, 12)
    contentArea.BackgroundColor3 = theme.Header -- Darker background for content
    contentArea.BackgroundTransparency = 1 -- Actually, let's keep it transparent to show Main bg, or give it a bg
    contentArea.BorderSizePixel = 0
    contentArea.ClipsDescendants = true
    contentArea.Parent = body
    
    -- Keybind System Variables
    window._binds = {}
    window._tabs = {}
    window._activeTab = nil
    
    -- Keybind Listener
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or UserInputService:GetFocusedTextBox() then return end
        local key = input.KeyCode
        if window._binds[key] then
            for _, callback in ipairs(window._binds[key]) do
                task.spawn(callback)
            end
        end
    end)
    
    function window:_bind(key, callback)
        key = normalizeKey(key)
        if not key then return end
        if not self._binds[key] then self._binds[key] = {} end
        table.insert(self._binds[key], callback)
        return {Key = key, Callback = callback}
    end
    
    function window:_unbind(bindObj)
        if not bindObj or not bindObj.Key then return end
        local list = self._binds[bindObj.Key]
        if list then
            for i, fn in ipairs(list) do
                if fn == bindObj.Callback then
                    table.remove(list, i)
                    break
                end
            end
        end
    end
    
    -- Tab System
    function window:AddTab(name)
        local tab = {}
        
        -- Tab Button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = name .. "Tab"
        tabBtn.Size = UDim2.new(1, 0, 0, 34)
        tabBtn.BackgroundColor3 = theme.Primary
        tabBtn.BackgroundTransparency = 1 -- Start transparent
        tabBtn.Text = ""
        tabBtn.AutoButtonColor = false
        tabBtn.Parent = sidebar
        
        local tabCorner = createCorner(tabBtn, UDim.new(0, 6))
        
        local tabLabel = Instance.new("TextLabel")
        tabLabel.BackgroundTransparency = 1
        tabLabel.Size = UDim2.new(1, -20, 1, 0)
        tabLabel.Position = UDim2.new(0, 10, 0, 0)
        tabLabel.Font = Enum.Font.GothamSemibold
        tabLabel.Text = name
        tabLabel.TextColor3 = theme.SubText
        tabLabel.TextSize = 14
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabBtn
        
        -- Page Container
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = theme.Accent
        page.Visible = false
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.None
        page.Parent = contentArea
        
        local pageLayout = Instance.new("Frame") -- Column holder
        pageLayout.Size = UDim2.new(1, 0, 1, 0)
        pageLayout.BackgroundTransparency = 1
        pageLayout.Parent = page
        
        local leftCol = Instance.new("Frame")
        leftCol.Name = "LeftCol"
        leftCol.Size = UDim2.new(0.5, -6, 1, 0) -- Subtract half padding
        leftCol.Position = UDim2.new(0, 0, 0, 0)
        leftCol.BackgroundTransparency = 1
        leftCol.Parent = pageLayout
        
        local rightCol = Instance.new("Frame")
        rightCol.Name = "RightCol"
        rightCol.Size = UDim2.new(0.5, -6, 1, 0)
        rightCol.Position = UDim2.new(0.5, 6, 0, 0)
        rightCol.BackgroundTransparency = 1
        rightCol.Parent = pageLayout
        
        local leftList = Instance.new("UIListLayout")
        leftList.SortOrder = Enum.SortOrder.LayoutOrder
        leftList.Padding = UDim.new(0, 12)
        leftList.Parent = leftCol
        
        local rightList = Instance.new("UIListLayout")
        rightList.SortOrder = Enum.SortOrder.LayoutOrder
        rightList.Padding = UDim.new(0, 12)
        rightList.Parent = rightCol
        
        -- Auto resize canvas
        local function updateCanvas()
            local lh = leftList.AbsoluteContentSize.Y
            local rh = rightList.AbsoluteContentSize.Y
            local maxH = math.max(lh, rh)
            page.CanvasSize = UDim2.new(0, 0, 0, maxH + 20)
        end
        
        leftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        rightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        
        -- Tab Activation Logic
        local function activate()
            if window._activeTab then
                local old = window._activeTab
                tween(old.Btn, {BackgroundTransparency = 1})
                tween(old.Label, {TextColor3 = theme.SubText})
                old.Page.Visible = false
            end
            
            window._activeTab = tab
            tab.Page.Visible = true
            tween(tabBtn, {BackgroundTransparency = 0, BackgroundColor3 = theme.PrimaryHover})
            tween(tabLabel, {TextColor3 = theme.Accent})
        end
        
        tabBtn.MouseButton1Click:Connect(activate)
        
        tabBtn.MouseEnter:Connect(function()
            if window._activeTab ~= tab then
                tween(tabLabel, {TextColor3 = theme.Text})
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if window._activeTab ~= tab then
                tween(tabLabel, {TextColor3 = theme.SubText})
            end
        end)
        
        tab.Btn = tabBtn
        tab.Label = tabLabel
        tab.Page = page
        table.insert(window._tabs, tab)
        
        if #window._tabs == 1 then activate() end
        
        -- Section System
        function tab:AddSection(secName)
            local section = {}
            
            -- Determine column
            local parentCol = leftCol
            if rightList.AbsoluteContentSize.Y < leftList.AbsoluteContentSize.Y then
                parentCol = rightCol
            end
            
            local container = Instance.new("Frame")
            container.Name = secName or "Section"
            container.BackgroundColor3 = theme.Header
            container.Size = UDim2.new(1, 0, 0, 100) -- Auto sized later
            container.AutomaticSize = Enum.AutomaticSize.Y
            container.Parent = parentCol
            
            createCorner(container, UDim.new(0, 8))
            createStroke(container, theme.Stroke, 1)
            
            local secPad = Instance.new("UIPadding")
            secPad.PaddingTop = UDim.new(0, 12)
            secPad.PaddingBottom = UDim.new(0, 12)
            secPad.PaddingLeft = UDim.new(0, 12)
            secPad.PaddingRight = UDim.new(0, 12)
            secPad.Parent = container
            
            local secTitle = Instance.new("TextLabel")
            secTitle.Text = secName
            secTitle.Font = Enum.Font.GothamBold
            secTitle.TextSize = 13
            secTitle.TextColor3 = theme.Text
            secTitle.Size = UDim2.new(1, 0, 0, 16)
            secTitle.BackgroundTransparency = 1
            secTitle.TextXAlignment = Enum.TextXAlignment.Left
            secTitle.Parent = container
            
            local items = Instance.new("Frame")
            items.Name = "Items"
            items.Size = UDim2.new(1, 0, 0, 0)
            items.Position = UDim2.new(0, 0, 0, 24)
            items.AutomaticSize = Enum.AutomaticSize.Y
            items.BackgroundTransparency = 1
            items.Parent = container
            
            local itemList = Instance.new("UIListLayout")
            itemList.SortOrder = Enum.SortOrder.LayoutOrder
            itemList.Padding = UDim.new(0, 8)
            itemList.Parent = items
            
            -- UI Elements
            
            function section:AddButton(text, callback)
                callback = callback or function() end
                
                local btnFrame = Instance.new("TextButton")
                btnFrame.Size = UDim2.new(1, 0, 0, 32)
                btnFrame.BackgroundColor3 = theme.Primary
                btnFrame.Text = ""
                btnFrame.AutoButtonColor = false
                btnFrame.Parent = items
                
                createCorner(btnFrame, UDim.new(0, 6))
                local s = createStroke(btnFrame, theme.Stroke, 1)
                
                local lbl = Instance.new("TextLabel")
                lbl.Text = text
                lbl.Font = Enum.Font.GothamSemibold
                lbl.TextSize = 13
                lbl.TextColor3 = theme.Text
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.Parent = btnFrame
                
                btnFrame.MouseEnter:Connect(function()
                    tween(btnFrame, {BackgroundColor3 = theme.PrimaryHover})
                    tween(s, {Color = theme.StrokeHover})
                end)
                btnFrame.MouseLeave:Connect(function()
                    tween(btnFrame, {BackgroundColor3 = theme.Primary})
                    tween(s, {Color = theme.Stroke})
                end)
                
                btnFrame.MouseButton1Click:Connect(function()
                    -- Click effect
                    tween(btnFrame, {BackgroundColor3 = theme.Accent}, 0.1)
                    task.delay(0.1, function()
                        tween(btnFrame, {BackgroundColor3 = theme.PrimaryHover})
                    end)
                    task.spawn(callback)
                end)
            end
            
            function section:AddToggle(text, default, callback)
                local state = default or false
                callback = callback or function() end
                
                local frame = Instance.new("TextButton")
                frame.Size = UDim2.new(1, 0, 0, 32)
                frame.BackgroundColor3 = theme.Background
                frame.BackgroundTransparency = 1
                frame.Text = ""
                frame.AutoButtonColor = false
                frame.Parent = items
                
                local lbl = Instance.new("TextLabel")
                lbl.Text = text
                lbl.Font = Enum.Font.GothamSemibold
                lbl.TextSize = 13
                lbl.TextColor3 = theme.Text
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1, -50, 1, 0)
                lbl.Parent = frame
                
                local toggler = Instance.new("Frame")
                toggler.Size = UDim2.new(0, 40, 0, 20)
                toggler.Position = UDim2.new(1, -40, 0.5, -10)
                toggler.BackgroundColor3 = state and theme.Accent or theme.Primary
                toggler.Parent = frame
                
                createCorner(toggler, UDim.new(1, 0))
                local ts = createStroke(toggler, state and theme.NeonStroke or theme.Stroke, 1)
                
                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 16, 0, 16)
                knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                knob.BackgroundColor3 = theme.Text
                knob.Parent = toggler
                createCorner(knob, UDim.new(1, 0))
                
                local function update()
                    tween(toggler, {BackgroundColor3 = state and theme.Accent or theme.Primary})
                    tween(ts, {Color = state and theme.NeonStroke or theme.Stroke})
                    tween(knob, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                end
                
                frame.MouseButton1Click:Connect(function()
                    state = not state
                    update()
                    task.spawn(function() callback(state) end)
                end)
                
                return {
                    Set = function(v) state = v; update(); callback(state) end,
                    Get = function() return state end
                }
            end
            
            function section:AddSlider(text, options, callback)
                options = options or {}
                local min = options.Min or 0
                local max = options.Max or 100
                local def = options.Default or min
                local val = def
                
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, 50)
                frame.BackgroundTransparency = 1
                frame.Parent = items
                
                local lbl = Instance.new("TextLabel")
                lbl.Text = text
                lbl.Font = Enum.Font.GothamSemibold
                lbl.TextSize = 13
                lbl.TextColor3 = theme.Text
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Size = UDim2.new(1, -40, 0, 20)
                lbl.BackgroundTransparency = 1
                lbl.Parent = frame
                
                local valLbl = Instance.new("TextLabel")
                valLbl.Text = tostring(val)
                valLbl.Font = Enum.Font.Gotham
                valLbl.TextSize = 12
                valLbl.TextColor3 = theme.SubText
                valLbl.TextXAlignment = Enum.TextXAlignment.Right
                valLbl.Size = UDim2.new(0, 40, 0, 20)
                valLbl.Position = UDim2.new(1, -40, 0, 0)
                valLbl.BackgroundTransparency = 1
                valLbl.Parent = frame
                
                local slideBg = Instance.new("TextButton") -- Using TextButton for input
                slideBg.Text = ""
                slideBg.AutoButtonColor = false
                slideBg.Size = UDim2.new(1, 0, 0, 10)
                slideBg.Position = UDim2.new(0, 0, 0, 30)
                slideBg.BackgroundColor3 = theme.Primary
                slideBg.Parent = frame
                createCorner(slideBg, UDim.new(1, 0))
                local ss = createStroke(slideBg, theme.Stroke, 1)
                
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                fill.BackgroundColor3 = theme.Accent
                fill.Parent = slideBg
                createCorner(fill, UDim.new(1, 0))
                
                local dragging = false
                
                local function update(input)
                    local sizeX = slideBg.AbsoluteSize.X
                    local posX = slideBg.AbsolutePosition.X
                    local rawP = (input.Position.X - posX) / sizeX
                    local p = math.clamp(rawP, 0, 1)
                    
                    val = math.floor(min + ((max - min) * p))
                    valLbl.Text = tostring(val)
                    tween(fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.05)
                    task.spawn(function() callback(val) end)
                end
                
                slideBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        tween(ss, {Color = theme.Accent})
                        update(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        tween(ss, {Color = theme.Stroke})
                    end
                end)
            end
            
            function section:AddDropdown(text, options, callback)
                local list = options.Options or {}
                local default = options.Default or list[1]
                local isMulti = options.Multi or false
                
                local isOpen = false
                
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, 46) -- Base height
                frame.BackgroundTransparency = 1
                frame.ClipsDescendants = true
                frame.Parent = items
                
                local lbl = Instance.new("TextLabel")
                lbl.Text = text
                lbl.Font = Enum.Font.GothamSemibold
                lbl.TextSize = 13
                lbl.TextColor3 = theme.Text
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Size = UDim2.new(1, 0, 0, 16)
                lbl.BackgroundTransparency = 1
                lbl.Parent = frame
                
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, 0, 0, 26)
                button.Position = UDim2.new(0, 0, 0, 20)
                button.BackgroundColor3 = theme.Primary
                button.Text = ""
                button.AutoButtonColor = false
                button.Parent = frame
                createCorner(button, UDim.new(0, 6))
                local bs = createStroke(button, theme.Stroke, 1)
                
                local dispLbl = Instance.new("TextLabel")
                dispLbl.Text = tostring(default)
                dispLbl.Font = Enum.Font.Gotham
                dispLbl.TextSize = 13
                dispLbl.TextColor3 = theme.SubText
                dispLbl.Size = UDim2.new(1, -24, 1, 0)
                dispLbl.Position = UDim2.new(0, 8, 0, 0)
                dispLbl.TextXAlignment = Enum.TextXAlignment.Left
                dispLbl.BackgroundTransparency = 1
                dispLbl.TextTruncate = Enum.TextTruncate.AtEnd
                dispLbl.Parent = button
                
                local icon = Instance.new("TextLabel")
                icon.Text = "▼"
                icon.TextSize = 10
                icon.TextColor3 = theme.SubText
                icon.Size = UDim2.new(0, 20, 1, 0)
                icon.Position = UDim2.new(1, -20, 0, 0)
                icon.BackgroundTransparency = 1
                icon.Parent = button
                
                local container = Instance.new("ScrollingFrame")
                container.Size = UDim2.new(1, 0, 0, 0)
                container.Position = UDim2.new(0, 0, 0, 50)
                container.BackgroundColor3 = theme.PrimaryHover
                container.BorderSizePixel = 0
                container.ScrollBarThickness = 2
                container.CanvasSize = UDim2.new(0, 0, 0, 0)
                container.Parent = frame
                createCorner(container, UDim.new(0, 6))
                
                local cLayout = Instance.new("UIListLayout")
                cLayout.SortOrder = Enum.SortOrder.LayoutOrder
                cLayout.Padding = UDim.new(0, 4)
                cLayout.Parent = container
                
                local cPad = Instance.new("UIPadding")
                cPad.PaddingLeft = UDim.new(0, 4)
                cPad.PaddingTop = UDim.new(0, 4)
                cPad.Parent = container
                
                local function refreshList()
                    for _, c in pairs(container:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    
                    for _, opt in ipairs(list) do
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, -8, 0, 24)
                        btn.BackgroundColor3 = theme.Primary
                        btn.BackgroundTransparency = 1
                        btn.Text = tostring(opt)
                        btn.TextColor3 = theme.SubText
                        btn.Font = Enum.Font.Gotham
                        btn.TextSize = 13
                        btn.Parent = container
                        createCorner(btn, UDim.new(0, 4))
                        
                        btn.MouseEnter:Connect(function()
                            tween(btn, {BackgroundTransparency = 0})
                            tween(btn, {TextColor3 = theme.Text})
                        end)
                        btn.MouseLeave:Connect(function()
                            tween(btn, {BackgroundTransparency = 1})
                            tween(btn, {TextColor3 = theme.SubText})
                        end)
                        
                        btn.MouseButton1Click:Connect(function()
                            isOpen = false
                            dispLbl.Text = tostring(opt)
                            dispLbl.TextColor3 = theme.Text
                            icon.Text = "▼"
                            tween(frame, {Size = UDim2.new(1, 0, 0, 46)})
                            tween(container, {Size = UDim2.new(1, 0, 0, 0)})
                            tween(bs, {Color = theme.Stroke})
                            task.spawn(function() callback(opt) end)
                        end)
                    end
                    
                    container.CanvasSize = UDim2.new(0, 0, 0, #list * 28 + 5)
                end
                
                refreshList()
                
                button.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        icon.Text = "▲"
                        local totalH = math.min(#list * 28 + 10, 140)
                        tween(frame, {Size = UDim2.new(1, 0, 0, 46 + totalH + 5)})
                        tween(container, {Size = UDim2.new(1, 0, 0, totalH)})
                        tween(bs, {Color = theme.Accent})
                    else
                        icon.Text = "▼"
                        tween(frame, {Size = UDim2.new(1, 0, 0, 46)})
                        tween(container, {Size = UDim2.new(1, 0, 0, 0)})
                        tween(bs, {Color = theme.Stroke})
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
