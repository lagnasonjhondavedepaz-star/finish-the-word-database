local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local userInput = game:GetService("UserInputService")

if coreGui:FindFirstChild("DeltaScannerConsole") then
    coreGui.DeltaScannerConsole:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaScannerConsole"
screenGui.Parent = coreGui

-- GLOBAL RUN STATE
local isRunning = true
local usedWords = {}
local currentAction = "Waiting..."

-- Instantly stops old loops if the script is re-executed and the UI is replaced/destroyed
screenGui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        isRunning = false
    end
end)

-- FLOATING TOGGLE BUTTON
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 100, 0, 28)
toggleBtn.AnchorPoint = Vector2.new(0.5, 0) -- Keeps it perfectly centered when it expands
toggleBtn.Position = UDim2.new(0.5, 0, 0, 12)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 11
toggleBtn.Text = "◉ CONSOLE"
toggleBtn.AutomaticSize = Enum.AutomaticSize.X -- Allows it to stretch based on text length
toggleBtn.Parent = screenGui

local togglePadding = Instance.new("UIPadding")
togglePadding.PaddingLeft = UDim.new(0, 10)
togglePadding.PaddingRight = UDim.new(0, 10)
togglePadding.Parent = toggleBtn

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleBtn

-- MINI AUTO TOGGLE (Visible only when UI is hidden)
local miniAutoToggleBtn = Instance.new("TextButton")
miniAutoToggleBtn.Size = UDim2.new(0, 100, 0, 28)
miniAutoToggleBtn.AnchorPoint = Vector2.new(0.5, 0)
miniAutoToggleBtn.Position = UDim2.new(0.5, 0, 0, 45) -- Placed just below the main toggle
miniAutoToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
miniAutoToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
miniAutoToggleBtn.Font = Enum.Font.GothamBold
miniAutoToggleBtn.TextSize = 11
miniAutoToggleBtn.Text = "🤖 AUTO: ON"
miniAutoToggleBtn.AutomaticSize = Enum.AutomaticSize.X
miniAutoToggleBtn.Visible = false -- Hidden by default
miniAutoToggleBtn.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 6)
miniCorner.Parent = miniAutoToggleBtn

local miniPadding = Instance.new("UIPadding")
miniPadding.PaddingLeft = UDim.new(0, 10)
miniPadding.PaddingRight = UDim.new(0, 10)
miniPadding.Parent = miniAutoToggleBtn

-- MAKE BUTTONS DRAGGABLE
local function makeDraggable(button)
    local isDragging = false
    local dragStart, startPos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    userInput.InputChanged:Connect(function(input)
        if isDragging and dragStart and startPos then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

makeDraggable(toggleBtn)
makeDraggable(miniAutoToggleBtn)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.55, 0, 0.75, 0)
mainFrame.Position = UDim2.new(0.2, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true -- Stops clicks from passing through the UI to the game
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local function updateToggleButton()
    local count = 0
    for _ in pairs(usedWords) do count = count + 1 end
    
    local statePrefix = mainFrame.Visible and "◉ CONSOLE" or "○ HIDDEN"
    toggleBtn.Text = statePrefix .. " | Used: " .. count .. " | " .. currentAction
    
    if mainFrame.Visible then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
        miniAutoToggleBtn.Visible = false -- Hide mini toggle when console is open
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        miniAutoToggleBtn.Visible = true  -- Show mini toggle when console is closed
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    updateToggleButton()
end)

-- HEADER SECTION
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 30)
headerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainFrame

local headerLayout = Instance.new("UIListLayout")
headerLayout.Parent = headerFrame
headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
headerLayout.FillDirection = Enum.FillDirection.Horizontal
headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
headerLayout.Padding = UDim.new(0, 8)

-- STATUS INDICATOR
local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.new(0, 12, 0, 12)
statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
statusIndicator.BorderSizePixel = 0
statusIndicator.Parent = headerFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusIndicator

-- STATUS INDICATOR UPDATE FUNCTION
local function updateStatusIndicator()
    if isRunning then
        statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    else
        statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- TITLE LABEL
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = " FINISH THE WORD [BETA]"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Active = false
titleLabel.Parent = headerFrame

-- HEADER DIVIDER
local headerDivider = Instance.new("Frame")
headerDivider.Size = UDim2.new(1, 0, 0, 2)
headerDivider.Position = UDim2.new(0, 0, 0, 30)
headerDivider.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
headerDivider.BorderSizePixel = 0
headerDivider.Parent = mainFrame

-- WINDOW DRAGGING
local dragging = false
local dragStart = nil
local startPos = nil

headerFrame.Active = true

local function beginHeaderDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end

headerFrame.InputBegan:Connect(beginHeaderDrag)
titleLabel.InputBegan:Connect(beginHeaderDrag)

userInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

userInput.InputChanged:Connect(function(input)
    if dragging and dragStart and startPos then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- NAVIGATION BAR
local navBar = Instance.new("Frame")
navBar.Size = UDim2.new(1, 0, 0, 35)
navBar.Position = UDim2.new(0, 0, 0, 32)
navBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
navBar.BorderSizePixel = 0
navBar.Parent = mainFrame

local navLayout = Instance.new("UIListLayout")
navLayout.Parent = navBar
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.Padding = UDim.new(0, 6)
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
navLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function createNavTab(text)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0, 110, 0, 28)
    tab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tab.TextColor3 = Color3.fromRGB(150, 150, 150)
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 10
    tab.Text = text
    tab.AutoButtonColor = false
    tab.Parent = navBar
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 5)
    tabCorner.Parent = tab
    return tab
end

local settingsTab = createNavTab("⚙ SETTINGS")
local consoleTab = createNavTab("📋 CONSOLE")

-- CONTENT PANELS
local settingsPanel = Instance.new("Frame")
settingsPanel.Size = UDim2.new(1, 0, 1, -82)
settingsPanel.Position = UDim2.new(0, 0, 0, 67)
settingsPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
settingsPanel.BorderSizePixel = 0
settingsPanel.ClipsDescendants = true
settingsPanel.Visible = false
settingsPanel.Parent = mainFrame

local consolePanel = Instance.new("Frame")
consolePanel.Size = UDim2.new(1, 0, 1, -82)
consolePanel.Position = UDim2.new(0, 0, 0, 67)
consolePanel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
consolePanel.BorderSizePixel = 0
consolePanel.ClipsDescendants = true
consolePanel.Visible = true
consolePanel.Parent = mainFrame

-- TAB SWITCHING
local currentTab = "console"

local function switchTab(tabName)
    currentTab = tabName
    settingsPanel.Visible = (tabName == "settings")
    consolePanel.Visible = (tabName == "console")
    
    -- Update tab colors
    if tabName == "settings" then
        settingsTab.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        settingsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        consoleTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        consoleTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    else
        settingsTab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        settingsTab.TextColor3 = Color3.fromRGB(150, 150, 150)
        consoleTab.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        consoleTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

settingsTab.MouseButton1Click:Connect(function()
    switchTab("settings")
end)

consoleTab.MouseButton1Click:Connect(function()
    switchTab("console")
end)

-- SETTINGS PANEL CONTENT
local settingsScroll = Instance.new("ScrollingFrame")
settingsScroll.Size = UDim2.new(1, 0, 1, 0)
settingsScroll.BackgroundTransparency = 1
settingsScroll.BorderSizePixel = 0
settingsScroll.ScrollBarThickness = 4
settingsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
settingsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
settingsScroll.Parent = settingsPanel

local settingsPadding = Instance.new("UIPadding")
settingsPadding.PaddingLeft = UDim.new(0, 12)
settingsPadding.PaddingRight = UDim.new(0, 12)
settingsPadding.PaddingTop = UDim.new(0, 12)
settingsPadding.Parent = settingsScroll

local settingsLayout = Instance.new("UIListLayout")
settingsLayout.Parent = settingsScroll
settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
settingsLayout.Padding = UDim.new(0, 10)

-- Auto Answer Toggle
local autoAnswerContainer = Instance.new("Frame")
autoAnswerContainer.Size = UDim2.new(1, 0, 0, 34)
autoAnswerContainer.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
autoAnswerContainer.BorderSizePixel = 0
autoAnswerContainer.Parent = settingsScroll

local autoAnswerLabel = Instance.new("TextLabel")
autoAnswerLabel.Size = UDim2.new(1, -110, 1, 0)
autoAnswerLabel.BackgroundTransparency = 1
autoAnswerLabel.Text = "🤖 AUTO-TYPE ANSWERS"
autoAnswerLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
autoAnswerLabel.Font = Enum.Font.GothamBold
autoAnswerLabel.TextSize = 11
autoAnswerLabel.TextXAlignment = Enum.TextXAlignment.Left
autoAnswerLabel.Parent = autoAnswerContainer

local labelPadding = Instance.new("UIPadding")
labelPadding.PaddingLeft = UDim.new(0, 10)
labelPadding.Parent = autoAnswerLabel

local autoAnswerToggle = Instance.new("TextButton")
autoAnswerToggle.Size = UDim2.new(0, 100, 0, 26)
autoAnswerToggle.Position = UDim2.new(1, -106, 0.5, -13)
autoAnswerToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
autoAnswerToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoAnswerToggle.Font = Enum.Font.GothamBold
autoAnswerToggle.TextSize = 11
autoAnswerToggle.Text = "✓ ENABLED"
autoAnswerToggle.Parent = autoAnswerContainer

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = autoAnswerToggle

local autoAnswerEnabled = true
local forceReplayThisTurn = false -- Added to track when to retry

local function toggleAutoAnswerState()
    autoAnswerEnabled = not autoAnswerEnabled
    if autoAnswerEnabled then
        -- Update main UI toggle
        autoAnswerToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        autoAnswerToggle.Text = "✓ ENABLED"
        -- Update mini UI toggle
        miniAutoToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        miniAutoToggleBtn.Text = "🤖 AUTO: ON"
        
        forceReplayThisTurn = true -- Triggers the script to instantly play the pending word
        logMessage("Auto Answer: ENABLED", Color3.fromRGB(0, 255, 0))
    else
        -- Update main UI toggle
        autoAnswerToggle.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        autoAnswerToggle.Text = "✗ DISABLED"
        -- Update mini UI toggle
        miniAutoToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        miniAutoToggleBtn.Text = "🤖 AUTO: OFF"
        
        logMessage("Auto Answer: DISABLED", Color3.fromRGB(255, 150, 0))
    end
end

-- Connect both buttons to the identical function
autoAnswerToggle.MouseButton1Click:Connect(toggleAutoAnswerState)
miniAutoToggleBtn.MouseButton1Click:Connect(toggleAutoAnswerState)

local usedWordsLabel = Instance.new("TextLabel")
usedWordsLabel.Size = UDim2.new(1, 0, 0, 18)
usedWordsLabel.BackgroundTransparency = 1
usedWordsLabel.Text = "📊 WORDS ALREADY USED: 0"
usedWordsLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
usedWordsLabel.Font = Enum.Font.Code
usedWordsLabel.TextSize = 10
usedWordsLabel.TextXAlignment = Enum.TextXAlignment.Left
usedWordsLabel.Parent = settingsScroll

-- Update used words counter every second
task.spawn(function()
    while isRunning do
        local count = 0
        for _ in pairs(usedWords) do count = count + 1 end
        usedWordsLabel.Text = "📊 WORDS ALREADY USED: " .. count
        updateToggleButton() -- ADD THIS LINE
        task.wait(1)
    end
end)

-- SUFFIX SETTINGS
local suffixOptions = {"UM", "LY", "X", "Y", "IA", "AK", "KY", "PT"}
local selectedSuffixes = {}
local suffixPriority = {}
for _, suffix in ipairs(suffixOptions) do
    selectedSuffixes[suffix] = true
    table.insert(suffixPriority, suffix)
end
local suffixLengthStrict = false
local refreshSuffixOrderList

local suffixLabel = Instance.new("TextLabel")
suffixLabel.Size = UDim2.new(1, 0, 0, 22)
suffixLabel.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
suffixLabel.BorderSizePixel = 0
suffixLabel.Text = "🎯 PREFERRED WORD ENDINGS (SUFFIXES)"
suffixLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
suffixLabel.Font = Enum.Font.GothamBold
suffixLabel.TextSize = 11
suffixLabel.TextXAlignment = Enum.TextXAlignment.Left
suffixLabel.Parent = settingsScroll

local suffixPadding = Instance.new("UIPadding")
suffixPadding.PaddingLeft = UDim.new(0, 10)
suffixPadding.Parent = suffixLabel

local suffixFrame = Instance.new("Frame")
suffixFrame.Size = UDim2.new(1, 0, 0, 0)
suffixFrame.AutomaticSize = Enum.AutomaticSize.Y
suffixFrame.BackgroundTransparency = 1
suffixFrame.Parent = settingsScroll

local suffixGrid = Instance.new("UIGridLayout")
suffixGrid.Parent = suffixFrame
suffixGrid.SortOrder = Enum.SortOrder.LayoutOrder
-- Changed width from 0.5 (50%) to 0.25 (25%) to accommodate 4 columns
suffixGrid.CellSize = UDim2.new(0.25, -6, 0, 24)
suffixGrid.CellPadding = UDim2.new(0, 6, 0, 6)
-- Changed from 2 to 4 cells per row, creating exactly 2 rows for the 8 suffixes
suffixGrid.FillDirectionMaxCells = 4

local suffixButtons = {}

local function refreshSuffixButtons()
    for _, btn in ipairs(suffixButtons) do
        local suffixText = btn.Text:match("%S+%s*$")
        local suffixName = suffixText and suffixText:gsub("%s*$", "") or ""
        if selectedSuffixes[suffixName] then
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
            btn.Text = "☑ " .. suffixName
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = "☐ " .. suffixName
        end
    end
end

local function createSuffixButton(suffixName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Text = "☑ " .. suffixName
    btn.AutoButtonColor = false
    btn.Parent = suffixFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if selectedSuffixes[suffixName] then
            selectedSuffixes[suffixName] = false
            for i, name in ipairs(suffixPriority) do
                if name == suffixName then
                    table.remove(suffixPriority, i)
                    break
                end
            end
        else
            selectedSuffixes[suffixName] = true
            table.insert(suffixPriority, suffixName)
        end
        refreshSuffixButtons()
        if refreshSuffixOrderList then
            refreshSuffixOrderList()
        end
    end)

    table.insert(suffixButtons, btn)
    return btn
end

for _, suffixName in ipairs(suffixOptions) do
    createSuffixButton(suffixName)
end

local suffixOrderLabel = Instance.new("TextLabel")
suffixOrderLabel.Size = UDim2.new(1, 0, 0, 22)
suffixOrderLabel.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
suffixOrderLabel.BorderSizePixel = 0
suffixOrderLabel.Text = "📋 ENDING PRIORITY (TOP IS CHECKED FIRST)"
suffixOrderLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
suffixOrderLabel.Font = Enum.Font.GothamBold
suffixOrderLabel.TextSize = 11
suffixOrderLabel.TextXAlignment = Enum.TextXAlignment.Left
suffixOrderLabel.Parent = settingsScroll

local suffixOrderPadding = Instance.new("UIPadding")
suffixOrderPadding.PaddingLeft = UDim.new(0, 10)
suffixOrderPadding.Parent = suffixOrderLabel

local suffixOrderFrame = Instance.new("Frame")
suffixOrderFrame.Size = UDim2.new(1, 0, 0, 0)
suffixOrderFrame.AutomaticSize = Enum.AutomaticSize.Y
suffixOrderFrame.BackgroundTransparency = 1
suffixOrderFrame.Parent = settingsScroll

local suffixOrderLayout = Instance.new("UIListLayout")
suffixOrderLayout.Parent = suffixOrderFrame
suffixOrderLayout.SortOrder = Enum.SortOrder.LayoutOrder
suffixOrderLayout.Padding = UDim.new(0, 4)

local suffixOrderRows = {}

local function moveSuffixPriority(index, direction)
    local newIndex = index + direction
    if newIndex < 1 or newIndex > #suffixPriority then
        return
    end
    suffixPriority[index], suffixPriority[newIndex] = suffixPriority[newIndex], suffixPriority[index]
    refreshSuffixOrderList()
end

refreshSuffixOrderList = function()
    for _, row in ipairs(suffixOrderRows) do
        row:Destroy()
    end
    suffixOrderRows = {}

    if #suffixPriority == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, 0, 0, 22)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "No suffixes selected"
        emptyLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = 10
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
        emptyLabel.Parent = suffixOrderFrame
        table.insert(suffixOrderRows, emptyLabel)
        return
    end

    for i, suffixName in ipairs(suffixPriority) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 24)
        row.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        row.BorderSizePixel = 0
        row.Parent = suffixOrderFrame

        local rowCorner = Instance.new("UICorner")
        rowCorner.CornerRadius = UDim.new(0, 4)
        rowCorner.Parent = row

        local upBtn = Instance.new("TextButton")
        upBtn.Size = UDim2.new(0, 24, 1, 0)
        upBtn.Position = UDim2.new(0, 0, 0, 0)
        upBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        upBtn.Font = Enum.Font.GothamBold
        upBtn.TextSize = 10
        upBtn.Text = "▲"
        upBtn.AutoButtonColor = false
        upBtn.Parent = row

        local downBtn = Instance.new("TextButton")
        downBtn.Size = UDim2.new(0, 24, 1, 0)
        downBtn.Position = UDim2.new(0, 26, 0, 0)
        downBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        downBtn.Font = Enum.Font.GothamBold
        downBtn.TextSize = 10
        downBtn.Text = "▼"
        downBtn.AutoButtonColor = false
        downBtn.Parent = row

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -56, 1, 0)
        nameLabel.Position = UDim2.new(0, 54, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = i .. ". " .. suffixName
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 10
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = row

        upBtn.MouseButton1Click:Connect(function()
            moveSuffixPriority(i, -1)
        end)
        downBtn.MouseButton1Click:Connect(function()
            moveSuffixPriority(i, 1)
        end)

        table.insert(suffixOrderRows, row)
    end
end

local suffixLengthButton = Instance.new("TextButton")
suffixLengthButton.Size = UDim2.new(1, 0, 0, 28)
suffixLengthButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
suffixLengthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
suffixLengthButton.Font = Enum.Font.GothamBold
suffixLengthButton.TextSize = 10
suffixLengthButton.Text = "⚙️ PRIORITY: PREFERRED ENDING OVER LENGTH"
suffixLengthButton.AutoButtonColor = false
suffixLengthButton.Parent = settingsScroll

local suffixLengthCorner = Instance.new("UICorner")
suffixLengthCorner.CornerRadius = UDim.new(0, 5)
suffixLengthCorner.Parent = suffixLengthButton

local lengthOrderMode = 1 -- 1 = Shortest, 2 = Longest, 3 = Random

local lengthOrderButton = Instance.new("TextButton")
lengthOrderButton.Size = UDim2.new(1, 0, 0, 28)
lengthOrderButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
lengthOrderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
lengthOrderButton.Font = Enum.Font.GothamBold
lengthOrderButton.TextSize = 10
lengthOrderButton.Text = "📏 SORT BY: SHORTEST WORD FIRST"
lengthOrderButton.AutoButtonColor = false
lengthOrderButton.Parent = settingsScroll

local lengthOrderCorner = Instance.new("UICorner")
lengthOrderCorner.CornerRadius = UDim.new(0, 5)
lengthOrderCorner.Parent = lengthOrderButton

local function refreshSuffixLengthButton()
    if suffixLengthStrict then
        suffixLengthButton.BackgroundColor3 = Color3.fromRGB(0, 160, 120)
        suffixLengthButton.Text = "⚙️ PRIORITY: LENGTH OVER PREFERRED ENDING"
    else
        suffixLengthButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        suffixLengthButton.Text = "⚙️ PRIORITY: PREFERRED ENDING OVER LENGTH"
    end
end

local function refreshLengthOrderButton()
    if lengthOrderMode == 1 then
        lengthOrderButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        lengthOrderButton.Text = "📏 SORT BY: SHORTEST WORD FIRST"
    elseif lengthOrderMode == 2 then
        lengthOrderButton.BackgroundColor3 = Color3.fromRGB(0, 160, 120)
        lengthOrderButton.Text = "📏 SORT BY: LONGEST WORD FIRST"
    else
        lengthOrderButton.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
        lengthOrderButton.Text = "📏 SORT BY: RANDOM WORD"
    end
end

suffixLengthButton.MouseButton1Click:Connect(function()
    suffixLengthStrict = not suffixLengthStrict
    refreshSuffixLengthButton()
end)

lengthOrderButton.MouseButton1Click:Connect(function()
    lengthOrderMode = lengthOrderMode + 1
    if lengthOrderMode > 3 then
        lengthOrderMode = 1
    end
    refreshLengthOrderButton()
end)

refreshSuffixButtons()
refreshSuffixOrderList()
refreshSuffixLengthButton()
refreshLengthOrderButton()

-- Update settings canvas size when layout changes
settingsLayout.Changed:Connect(function()
    settingsScroll.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y)
end)

-- CONTROLS SECTION (moved to settings)
local controlsSection = Instance.new("Frame")
controlsSection.Size = UDim2.new(1, 0, 0, 0)
controlsSection.AutomaticSize = Enum.AutomaticSize.Y
controlsSection.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
controlsSection.BorderSizePixel = 0
controlsSection.Parent = settingsScroll

-- BUTTON CONTAINER
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, 0, 0, 0)
buttonContainer.AutomaticSize = Enum.AutomaticSize.Y
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = controlsSection

local buttonLayout = Instance.new("UIListLayout")
buttonLayout.Parent = buttonContainer
buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
buttonLayout.Padding = UDim.new(0, 5)

local function createButton(text, bgColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = bgColor
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Text = text
    btn.Parent = buttonContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    return btn
end

local modeButton = createButton(" 🎯 TARGET LENGTH: SHORT (1-9 LETTERS)", Color3.fromRGB(40, 100, 200))
local exitButton = createButton(" EXIT SCRIPT", Color3.fromRGB(120, 30, 30))

-- CONSOLE FILTER BUTTON
local showOnlyMissing = false

local filterBtn = Instance.new("TextButton")
filterBtn.Size = UDim2.new(1, -20, 0, 24)
filterBtn.Position = UDim2.new(0, 10, 0, 5)
filterBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
filterBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
filterBtn.Font = Enum.Font.GothamBold
filterBtn.TextSize = 10
filterBtn.Text = "🔍 SHOW ALL LOGS (CLICK TO FILTER MISSING PREFIXES)"
filterBtn.AutoButtonColor = false
filterBtn.Parent = consolePanel

local filterCorner = Instance.new("UICorner")
filterCorner.CornerRadius = UDim.new(0, 4)
filterCorner.Parent = filterBtn

-- ADJUSTED SCROLL FRAME
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -34) -- Shrunk slightly to fit button
scrollFrame.Position = UDim2.new(0, 0, 0, 34) -- Pushed down to fit button
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
scrollFrame.ElasticBehavior = Enum.ElasticBehavior.Never
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = consolePanel

-- CONSOLE PADDING
local consolePadding = Instance.new("UIPadding")
consolePadding.PaddingLeft = UDim.new(0, 10)
consolePadding.PaddingRight = UDim.new(0, 10)
consolePadding.PaddingTop = UDim.new(0, 5)
consolePadding.PaddingBottom = UDim.new(0, 5)
consolePadding.Parent = scrollFrame

local uiLayout = Instance.new("UIListLayout")
uiLayout.Parent = scrollFrame
uiLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiLayout.Padding = UDim.new(0, 2)

local function updateConsoleScroll()
    local paddingY = consolePadding.PaddingTop.Offset + consolePadding.PaddingBottom.Offset
    local contentHeight = uiLayout.AbsoluteContentSize.Y + paddingY
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
    local viewHeight = scrollFrame.AbsoluteWindowSize.Y
    if viewHeight <= 0 then
        viewHeight = scrollFrame.AbsoluteSize.Y
    end
    if contentHeight > viewHeight then
        scrollFrame.CanvasPosition = Vector2.new(0, contentHeight - viewHeight)
    else
        scrollFrame.CanvasPosition = Vector2.new(0, 0)
    end
end

uiLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateConsoleScroll)

local function applyLogFilter()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") and child:GetAttribute("IsMissingPrefix") ~= nil then
            if showOnlyMissing then
                child.Visible = child:GetAttribute("IsMissingPrefix")
            else
                child.Visible = true
            end
        end
    end
    task.defer(updateConsoleScroll)
end

filterBtn.MouseButton1Click:Connect(function()
    showOnlyMissing = not showOnlyMissing
    if showOnlyMissing then
        filterBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        filterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        filterBtn.Text = "🔍 SHOWING ONLY: MISSING PREFIXES"
    else
        filterBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        filterBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        filterBtn.Text = "🔍 SHOW ALL LOGS (CLICK TO FILTER MISSING PREFIXES)"
    end
    applyLogFilter()
end)

local function getStatusIndicator(color)
    if color == Color3.fromRGB(0, 255, 0) then
        return "✓", Color3.fromRGB(0, 255, 100)
    elseif color == Color3.fromRGB(255, 50, 50) or color == Color3.fromRGB(255, 100, 100) then
        return "✗", Color3.fromRGB(255, 100, 100)
    elseif color == Color3.fromRGB(255, 255, 0) then
        return "!", Color3.fromRGB(255, 200, 0)
    elseif color == Color3.fromRGB(255, 150, 0) then
        return "⚠", Color3.fromRGB(255, 150, 100)
    elseif color == Color3.fromRGB(0, 255, 255) or color == Color3.fromRGB(0, 255, 150) then
        return "►", Color3.fromRGB(0, 200, 255)
    else
        return "•", color
    end
end

local function getTimestamp()
    local now = os.date("*t")
    return string.format("[%02d:%02d:%02d]", now.hour, now.min, now.sec)
end

local function logMessage(text, color)
    if not isRunning then return end
    
    local msgContainer = Instance.new("Frame")
    msgContainer.Size = UDim2.new(1, 0, 0, 0)
    msgContainer.AutomaticSize = Enum.AutomaticSize.Y
    msgContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    msgContainer.BorderSizePixel = 0
    
    -- Tag log if it contains missing prefix warnings
    local isMissing = (string.find(text, "MISSING PREFIX") ~= nil) or (string.find(text, "Wala ng words") ~= nil)
    msgContainer:SetAttribute("IsMissingPrefix", isMissing)
    
    -- Hide it instantly if the filter is active and it's not a missing prefix
    if showOnlyMissing and not isMissing then
        msgContainer.Visible = false
    end
    
    msgContainer.Parent = scrollFrame
    
    local msgContainerCorner = Instance.new("UICorner")
    msgContainerCorner.CornerRadius = UDim.new(0, 4)
    msgContainerCorner.Parent = msgContainer
    
    local msgPadding = Instance.new("UIPadding")
    msgPadding.PaddingLeft = UDim.new(0, 8)
    msgPadding.PaddingRight = UDim.new(0, 8)
    msgPadding.PaddingTop = UDim.new(0, 6)
    msgPadding.PaddingBottom = UDim.new(0, 6)
    msgPadding.Parent = msgContainer
    
    local msgLayout = Instance.new("UIListLayout")
    msgLayout.Parent = msgContainer
    msgLayout.SortOrder = Enum.SortOrder.LayoutOrder
    msgLayout.FillDirection = Enum.FillDirection.Horizontal
    msgLayout.Padding = UDim.new(0, 6)
    msgLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    
    -- STATUS INDICATOR
    local statusIndicator = Instance.new("TextLabel")
    statusIndicator.Size = UDim2.new(0, 20, 0, 20)
    statusIndicator.BackgroundTransparency = 1
    statusIndicator.Text = getStatusIndicator(color)
    statusIndicator.TextColor3 = getStatusIndicator(color) and color or Color3.fromRGB(100, 100, 100)
    statusIndicator.TextSize = 16
    statusIndicator.Font = Enum.Font.GothamBold
    statusIndicator.Parent = msgContainer
    
    -- MESSAGE CONTENT FRAME
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -26, 0, 0)
    contentFrame.AutomaticSize = Enum.AutomaticSize.Y
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = msgContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = contentFrame
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 2)
    
    -- TIMESTAMP
    local timestamp = Instance.new("TextLabel")
    timestamp.Size = UDim2.new(1, 0, 0, 0)
    timestamp.AutomaticSize = Enum.AutomaticSize.Y
    timestamp.BackgroundTransparency = 1
    timestamp.Text = getTimestamp()
    timestamp.TextColor3 = Color3.fromRGB(100, 100, 100)
    timestamp.TextSize = 10
    timestamp.Font = Enum.Font.Code
    timestamp.TextXAlignment = Enum.TextXAlignment.Left
    timestamp.Parent = contentFrame
    
    -- MESSAGE TEXT
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, 0, 0, 0)
    msg.AutomaticSize = Enum.AutomaticSize.Y
    msg.TextWrapped = true
    msg.BackgroundTransparency = 1
    msg.TextColor3 = color or Color3.fromRGB(0, 255, 150)
    msg.TextSize = 12
    msg.Font = Enum.Font.Code
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Text = text
    msg.Parent = contentFrame

    task.defer(updateConsoleScroll)
end

logMessage("System Initialized! Ready to dominate. [TEST VERSION]", Color3.fromRGB(0, 255, 0))
updateStatusIndicator()

-- STATES & TOGGLES
local lengthMode = 1 
local lengthLabels = {
    " 🎯 TARGET LENGTH: SHORT (1-9 LETTERS)",
    " 🎯 TARGET LENGTH: LONG (10+ LETTERS)"
}
modeButton.MouseButton1Click:Connect(function()
    lengthMode = lengthMode == 1 and 2 or 1
    modeButton.Text = lengthLabels[lengthMode]
    logMessage("Switched to " .. lengthLabels[lengthMode], Color3.fromRGB(255, 255, 0))
end)

local suffixModeEnabled = true

local function getSelectedSuffixes()
    return suffixPriority
end

local function matchesLengthMode(word)
    if lengthMode == 1 then
        return #word <= 9
    elseif lengthMode == 2 then
        return #word >= 10
    end
    return true
end

local function pickByLengthOrder(pool)
    if #pool == 0 then
        return nil
    end

    local ranked = {}
    for _, word in ipairs(pool) do
        if matchesLengthMode(word) then
            table.insert(ranked, word)
        end
    end
    if #ranked == 0 then
        ranked = pool
    end

    -- If Random mode is selected, just pick any word from the valid length pool
    if lengthOrderMode == 3 then
        return ranked[math.random(1, #ranked)]
    end

    local bestLen = #ranked[1]
    for _, word in ipairs(ranked) do
        if lengthOrderMode == 2 then -- Longest
            if #word > bestLen then
                bestLen = #word
            end
        else -- Shortest (lengthOrderMode == 1)
            if #word < bestLen then
                bestLen = #word
            end
        end
    end

    local best = {}
    for _, word in ipairs(ranked) do
        if #word == bestLen then
            table.insert(best, word)
        end
    end

    return best[math.random(1, #best)]
end

-- WORD DB FROM GITHUB
local wordsTable = {}
local validWordsDict = {} 
local missingPrefixes = {} 

local wordUrl = "https://raw.githubusercontent.com/lagnasonjhondavedepaz-star/finish-the-word-database/refs/heads/main/word-notes.txt"
local success, fileData = pcall(function()
    return game:HttpGet(wordUrl)
end)

if success and fileData then
    for word in string.gmatch(fileData, "[^\r\n]+") do
        local cleanWord = word:match("^[%a]+$")
        if cleanWord then 
            local upperWord = cleanWord:upper()
            table.insert(wordsTable, upperWord)
            validWordsDict[upperWord] = true
        end
    end
    logMessage("Loaded " .. #wordsTable .. " words from GitHub!", Color3.fromRGB(0, 255, 255))
else
    logMessage("ERROR: Failed to fetch words from GitHub!", Color3.fromRGB(255, 50, 50))
    return
end

local function clearBlacklist()
    usedWords = {}
    missingPrefixes = {}
    currentAction = "Waiting..." -- Resets the status text
    updateToggleButton()         -- Refreshes the UI button instantly
    logMessage("--- BLACKLIST CLEARED ---", Color3.fromRGB(255, 255, 0))
end

local inGameConnection = localPlayer:GetAttributeChangedSignal("InGame"):Connect(function()
    if localPlayer:GetAttribute("InGame") ~= 2 then
        clearBlacklist()
    end
end)

-- EXIT LOGIC
exitButton.MouseButton1Click:Connect(function()
    isRunning = false
    updateStatusIndicator()
    logMessage("Script stopped by user.", Color3.fromRGB(255, 100, 100))
    if inGameConnection then inGameConnection:Disconnect() end
    task.wait(1)
    if screenGui then screenGui:Destroy() end
end)

local function readInputBox()
    local pGui = localPlayer:FindFirstChild("PlayerGui")
    local sg = pGui and pGui:FindFirstChild("ScreenGui")
    local answerInput = sg and sg:FindFirstChild("TopBar") and sg.TopBar:FindFirstChild("AnswerInput")
    
    if not answerInput then return "" end

    local letters = {}
    for _, obj in ipairs(answerInput:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible and obj.Text ~= "" then
            local txt = obj.Text:match("^[%a]+$")
            if txt then table.insert(letters, {label = obj, text = txt:upper()}) end
        end
    end
    
    table.sort(letters, function(a, b) return a.label.AbsolutePosition.X < b.label.AbsolutePosition.X end)
    
    local fullText = ""
    for _, item in ipairs(letters) do fullText = fullText .. item.text end
    return fullText
end

-- Added a 3rd parameter: isPlayingUsedWord
local function typeRemainingLetters(fullWord, prefixLength, isPlayingUsedWord)
    local suffix = string.sub(fullWord, prefixLength + 1)
    
    local willStartDelay = false
    if #fullWord >= 10 then
        willStartDelay = (math.random(1, 100) <= 75)
    else
        willStartDelay = (math.random(1, 100) <= 50)
    end
    
    if willStartDelay then
        task.wait(2)
    else
        if prefixLength >= 2 then
            task.wait(math.random(1500, 3000) / 1000)
        else
            task.wait(math.random(500, 1500) / 1000)
        end
    end
    
    if not isRunning then return end
    
    local typoRate = 25
    if #fullWord >= 15 then
        typoRate = 45
    end
    
    -- Disabled typos if isPlayingUsedWord is true
    local willMakeTypo = (not isPlayingUsedWord) and (math.random(1, 100) <= typoRate)
    local typoIndex = -1
    local typoType = 1
    local willAddEndTypo = (not isPlayingUsedWord) and (math.random(1, 100) <= 10) 
    
    if willMakeTypo and #suffix > 2 then
        typoIndex = math.random(1, #suffix - 1)
        -- 50% chance for Double-Press Correct Letter, 50% chance for Random Wrong Letter
        if math.random(1, 100) <= 50 then
            typoType = 1
        else
            typoType = 2
        end
    end
    
    local doubleCheckCount = 0
    local maxDoubleChecks = (#fullWord >= 15) and 2 or 1
    local charsBeforePause = math.random(1, 3) 
    local currentStreak = 0
    
    for i = 1, #suffix do
        if not isRunning then break end
        
        local correctChar = string.sub(suffix, i, i)
        local keycode = Enum.KeyCode[correctChar]
        local skipNormalTyping = false
        
        if i == typoIndex then
            if typoType == 1 then
                -- TYPE 1: Double press the correct character (Types 2 total, backspaces 1)
                for t = 1, 2 do
                    if not isRunning then break end
                    local wrongKeycode = Enum.KeyCode[correctChar]
                    if wrongKeycode then
                        VIM:SendKeyEvent(true, wrongKeycode, false, game)
                        task.wait(math.random(20, 50) / 1000) 
                        VIM:SendKeyEvent(false, wrongKeycode, false, game)
                        task.wait(math.random(60, 150) / 1000)
                    end
                end
                
                task.wait(math.random(250, 500) / 1000)
                
                if isRunning then
                    VIM:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
                    task.wait(math.random(20, 40) / 1000)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
                    task.wait(math.random(80, 150) / 1000)
                end
                
                task.wait(math.random(150, 250) / 1000)
                currentStreak = 0 
                skipNormalTyping = true 
                
            elseif typoType == 2 then
                -- TYPE 2: Random incorrect character (Types 1 wrong, backspaces 1)
                local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                local wrongChar = correctChar
                while wrongChar == correctChar do
                    local rIndex = math.random(1, 26)
                    wrongChar = string.sub(alphabet, rIndex, rIndex)
                end
                
                local wrongKeycode = Enum.KeyCode[wrongChar]
                if wrongKeycode and isRunning then
                    VIM:SendKeyEvent(true, wrongKeycode, false, game)
                    task.wait(math.random(20, 50) / 1000) 
                    VIM:SendKeyEvent(false, wrongKeycode, false, game)
                    task.wait(math.random(60, 150) / 1000)
                end
                
                task.wait(math.random(250, 500) / 1000)
                
                if isRunning then
                    VIM:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
                    task.wait(math.random(20, 40) / 1000)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
                    task.wait(math.random(80, 150) / 1000)
                end
                
                task.wait(math.random(150, 250) / 1000)
                currentStreak = 0 
                skipNormalTyping = false 
            end
        end
        
        if not skipNormalTyping and keycode and isRunning then
            VIM:SendKeyEvent(true, keycode, false, game)
            task.wait(math.random(20, 50) / 1000) 
            VIM:SendKeyEvent(false, keycode, false, game)
            
            currentStreak = currentStreak + 1
            
            if currentStreak >= charsBeforePause then
                if #fullWord >= 15 then
                    task.wait(math.random(200, 450) / 1000)
                elseif #fullWord > 8 then
                    task.wait(math.random(150, 300) / 1000)
                else
                    task.wait(math.random(100, 250) / 1000)
                end
                currentStreak = 0
                charsBeforePause = math.random(1, 3)
            else
                task.wait(math.random(40, 95) / 1000)
            end
            
            if #fullWord >= 15 and doubleCheckCount < maxDoubleChecks and math.random(1, 100) <= 15 then
                doubleCheckCount = doubleCheckCount + 1
                task.wait(math.random(500, 1000) / 1000) 
            elseif #fullWord > 8 and doubleCheckCount < maxDoubleChecks and math.random(1, 100) <= 8 then
                doubleCheckCount = doubleCheckCount + 1
                task.wait(math.random(400, 800) / 1000) 
            end
        end
    end
    
    if not isRunning then return end
    
if willAddEndTypo then
        task.wait(math.random(50, 150) / 1000)
        -- Uses "BackSlash" for the \ key (repeated to maintain the existing random logic)
        local endTypoChars = {"BackSlash", "BackSlash"}
        local chosenEndTypo = endTypoChars[math.random(1, 2)]
        local endTypoKey = Enum.KeyCode[chosenEndTypo]
        
        VIM:SendKeyEvent(true, endTypoKey, false, game)
        task.wait(math.random(20, 50) / 1000)
        VIM:SendKeyEvent(false, endTypoKey, false, game)
        
        -- 50% chance to wait 100-250ms, otherwise no delay before hitting Return
        if math.random(1, 100) <= 50 then
            task.wait(math.random(100, 250) / 1000)
        end
        
        VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        
        task.wait(math.random(500, 1000) / 1000)
        
        VIM:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
        task.wait(math.random(20, 50) / 1000)
        VIM:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
        
        task.wait(math.random(200, 500) / 1000)
    end
    
    if not isRunning then return end
    
if #fullWord >= 15 then
        logMessage("15+ letters! Waiting 2 seconds before enter...", Color3.fromRGB(255, 255, 0))
        task.wait(2)
    elseif (not willAddEndTypo) and math.random(1, 100) <= 5 then
        logMessage("Distracted! Waiting 3 seconds...", Color3.fromRGB(255, 150, 0))
        task.wait(3)
    else
        task.wait(math.random(400, 800) / 1000)
    end
    
    if isRunning then
        VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end
end

task.spawn(function()
    local lastSeenText = ""
    local hasPlayedThisTurn = false
    local wasMyTurn = false
    local pendingManualWord = nil -- Memory for the manual word
    local hasTriedUsedWordThisTurn = false -- Prevents multiple used word attempts per turn
    
    while isRunning and task.wait(0.1) do
        -- Reset the turn state if the user just enabled auto-type
        if forceReplayThisTurn then
            hasPlayedThisTurn = false
            forceReplayThisTurn = false
        end
        
        local currentText = readInputBox()
        local isMyTurn = localPlayer:GetAttribute("IsTurn") == true
        
        if isMyTurn ~= wasMyTurn then
            if lastSeenText ~= "" and validWordsDict[lastSeenText] and not usedWords[lastSeenText] then
                usedWords[lastSeenText] = true
                logMessage("[BLACKLIST] " .. lastSeenText, Color3.fromRGB(255, 150, 0))
            end
            wasMyTurn = isMyTurn
            if isMyTurn then
                hasTriedUsedWordThisTurn = false -- Reset for the new turn
            end
        end
        
        if currentText ~= lastSeenText then
            local isTyping = false
            if currentText ~= "" and lastSeenText ~= "" then
                if #currentText < #lastSeenText and string.sub(lastSeenText, 1, #currentText) == currentText then
                    isTyping = true
                elseif #currentText > #lastSeenText and string.sub(currentText, 1, #lastSeenText) == lastSeenText then
                    isTyping = true
                end
            elseif currentText ~= "" and lastSeenText == "" then
                isTyping = true
            end
            
            if not isTyping and lastSeenText ~= "" then
                if validWordsDict[lastSeenText] and not usedWords[lastSeenText] then
                    usedWords[lastSeenText] = true
                    logMessage("[BLACKLIST] " .. lastSeenText, Color3.fromRGB(255, 150, 0))
                end
            end
            lastSeenText = currentText
        end
        
        if isMyTurn then
            if not hasPlayedThisTurn and currentText ~= "" then
                hasPlayedThisTurn = true 
                
                task.spawn(function()
                    task.wait(0.3) 
                    if not isRunning then return end
                    
                    local settledPrefix = readInputBox()
                    
                    if settledPrefix ~= "" then
                        logMessage("MY TURN! Prefix: [" .. settledPrefix .. "]", Color3.fromRGB(0, 255, 0))
                        
                        local exactLengthMatches = {}
                        local fallbackMatches = {}
                        
                        local usedCount = 0
                        for _ in pairs(usedWords) do usedCount = usedCount + 1 end
                        
                        local usedChance = 0
                        if usedCount > 100 then
                            usedChance = 20
                        elseif usedCount > 75 then
                            usedChance = 15
                        elseif usedCount > 50 then
                            usedChance = 10
                        elseif usedCount > 25 then
                            usedChance = 5
                        end
                        
                        -- Only attempt a used word if it's short, and we haven't already tried one this turn
                        local tryUsedWord = (lengthMode == 1) and (not hasTriedUsedWordThisTurn) and (usedChance > 0) and (math.random(1, 100) <= usedChance)
                        local usedFallback = {}
                        local usedExact = {}
                        
                        for _, word in ipairs(wordsTable) do
                            if string.sub(word, 1, #settledPrefix) == settledPrefix then
                                local matchesLength = false
                                if lengthMode == 1 and #word <= 9 then matchesLength = true end
                                if lengthMode == 2 and #word >= 10 then matchesLength = true end
                                
                                if usedWords[word] then
                                    table.insert(usedFallback, word)
                                    if matchesLength then
                                        table.insert(usedExact, word)
                                    end
                                else
                                    table.insert(fallbackMatches, word)
                                    if matchesLength then
                                        table.insert(exactLengthMatches, word)
                                    end
                                end
                            end
                        end
                        
                        local isPlayingUsedWord = false
                        if tryUsedWord and #usedFallback > 0 then
                            logMessage("Intentionally trying a used word to seem human...", Color3.fromRGB(255, 100, 255))
                            fallbackMatches = usedFallback
                            exactLengthMatches = usedExact
                            isPlayingUsedWord = true
                            hasTriedUsedWordThisTurn = true -- Mark that we tried a used word this turn
                        end
                        
                        local finalPool = {}
                        local foundSuffix = false
                        
                        local activeSuffixes = getSelectedSuffixes()
                        suffixModeEnabled = (#activeSuffixes > 0)
                        
                        if suffixModeEnabled then
                            for _, targetSuffix in ipairs(activeSuffixes) do
                                local exactSuffixMatches = {}
                                local fallbackSuffixMatches = {}
                                
                                for _, word in ipairs(fallbackMatches) do
                                    if string.sub(word, -#targetSuffix) == targetSuffix then
                                        table.insert(fallbackSuffixMatches, word)
                                        if matchesLengthMode(word) then
                                            table.insert(exactSuffixMatches, word)
                                        end
                                    end
                                end
                                
                                if suffixLengthStrict then
                                    if #exactSuffixMatches > 0 then
                                        finalPool = exactSuffixMatches
                                        foundSuffix = true
                                        logMessage("Matched suffix ["..targetSuffix.."] (Length Matched)", Color3.fromRGB(0, 255, 0))
                                        break
                                    end
                                else
                                    if #fallbackSuffixMatches > 0 then
                                        finalPool = fallbackSuffixMatches
                                        foundSuffix = true
                                        logMessage("Matched suffix ["..targetSuffix.."] (Length Ignored)", Color3.fromRGB(200, 200, 0))
                                        break
                                    end
                                end
                            end
                        end
                        
                        if not foundSuffix then
                            if suffixModeEnabled then
                                logMessage("No suffix match. Back to normal.", Color3.fromRGB(255, 150, 0))
                            end
                            finalPool = #exactLengthMatches > 0 and exactLengthMatches or fallbackMatches
                        end
                        
if #finalPool > 0 then
                            local chosenWord = pickByLengthOrder(finalPool)
                            
                            -- Prevent the word from changing if we already found one in manual mode
                            if pendingManualWord and string.sub(pendingManualWord, 1, #settledPrefix) == settledPrefix then
                                for _, w in ipairs(finalPool) do
                                    if w == pendingManualWord then
                                        chosenWord = pendingManualWord
                                        break
                                    end
                                end
                            end
                            
                            if autoAnswerEnabled then
                                pendingManualWord = nil -- Clear it once we decide to play it
                                currentAction = "Playing: " .. chosenWord
                                updateToggleButton()
                                logMessage(">> PLAYING: " .. chosenWord, Color3.fromRGB(0, 255, 255))
                                typeRemainingLetters(chosenWord, #settledPrefix, isPlayingUsedWord)
                                
                                -- If we purposefully played a used word, wait 1s for the game to reject it, 
                                -- backspace the letters we added, then reset hasPlayedThisTurn.
                                if isPlayingUsedWord then
                                    task.wait(1)
                                    logMessage("Removing used word to try a valid one...", Color3.fromRGB(255, 100, 255))
                                    
                                    local charsToRemove = #chosenWord - #settledPrefix
                                    for b = 1, charsToRemove do
                                        if not isRunning then break end
                                        VIM:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
                                        task.wait(math.random(30, 60) / 1000) -- Slightly varied hold time
                                        VIM:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
                                        task.wait(math.random(100, 250) / 1000) -- Slower, human-like delay between presses
                                    end
                                    
                                    task.wait(0.5) -- Wait for the game GUI to process the backspaces
                                    hasPlayedThisTurn = false
                                end
                            else
                                pendingManualWord = chosenWord -- Store the word so it doesn't change when toggling ON
                                currentAction = "Found: " .. chosenWord
                                updateToggleButton()
                                logMessage(">> FOUND: " .. chosenWord .. " (Manual Mode - Not Auto-Typing)", Color3.fromRGB(255, 200, 0))
                            end
                        else
                            pendingManualWord = nil -- Clear it if no words are found
                            currentAction = "Missing Prefix: " .. settledPrefix
                            updateToggleButton()
                            logMessage(">> ERROR: Wala ng words para sa [" .. settledPrefix .. "]", Color3.fromRGB(255, 50, 50))
                            if not missingPrefixes[settledPrefix] then
                                missingPrefixes[settledPrefix] = true
                                logMessage(" NOTED MISSING PREFIX: [" .. settledPrefix .. "]", Color3.fromRGB(255, 100, 100))
                            end
                        end
                    else
                        hasPlayedThisTurn = false 
                    end
                end)
            end
        else
            hasPlayedThisTurn = false
        end
    end
end)