local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")

if coreGui:FindFirstChild("DeltaScannerConsole") then
    coreGui.DeltaScannerConsole:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaScannerConsole"
screenGui.Parent = coreGui

-- GLOBAL RUN STATE
local isRunning = true

-- FLOATING TOGGLE BUTTON
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 100, 0, 28)
toggleBtn.Position = UDim2.new(0.5, -50, 0, 12)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 11
toggleBtn.Text = "◉ CONSOLE"
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleBtn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.55, 0, 0.55, 0)
mainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local function updateToggleButton()
    if mainFrame.Visible then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
        toggleBtn.Text = "◉ CONSOLE"
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        toggleBtn.Text = "○ HIDDEN"
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
titleLabel.Text = " FINISH THE WORD (V30) [TEST]"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
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
local dragOffset = nil

headerFrame.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        dragOffset = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset - mousePos.X, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset - mousePos.Y)
    end
end)

headerFrame.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
    if dragging and dragOffset then
        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        mainFrame.Position = UDim2.new(dragOffset.X.Scale, mousePos.X + dragOffset.X.Offset, dragOffset.Y.Scale, mousePos.Y + dragOffset.Y.Offset)
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
local autoAnswerLabel = Instance.new("TextLabel")
autoAnswerLabel.Size = UDim2.new(1, 0, 0, 22)
autoAnswerLabel.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
autoAnswerLabel.BorderSizePixel = 0
autoAnswerLabel.Text = "🤖 AUTO ANSWER"
autoAnswerLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
autoAnswerLabel.Font = Enum.Font.GothamBold
autoAnswerLabel.TextSize = 11
autoAnswerLabel.TextXAlignment = Enum.TextXAlignment.Left
autoAnswerLabel.Parent = settingsScroll

local labelPadding = Instance.new("UIPadding")
labelPadding.PaddingLeft = UDim.new(0, 10)
labelPadding.Parent = autoAnswerLabel

local autoAnswerToggle = Instance.new("TextButton")
autoAnswerToggle.Size = UDim2.new(1, 0, 0, 34)
autoAnswerToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
autoAnswerToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoAnswerToggle.Font = Enum.Font.GothamBold
autoAnswerToggle.TextSize = 11
autoAnswerToggle.Text = "✓ ENABLED"
autoAnswerToggle.Parent = settingsScroll

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = autoAnswerToggle

local autoAnswerEnabled = true

autoAnswerToggle.MouseButton1Click:Connect(function()
    autoAnswerEnabled = not autoAnswerEnabled
    if autoAnswerEnabled then
        autoAnswerToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        autoAnswerToggle.Text = "✓ ENABLED"
        logMessage("Auto Answer: ENABLED", Color3.fromRGB(0, 255, 0))
    else
        autoAnswerToggle.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        autoAnswerToggle.Text = "✗ DISABLED"
        logMessage("Auto Answer: DISABLED", Color3.fromRGB(255, 150, 0))
    end
end)

local usedWordsLabel = Instance.new("TextLabel")
usedWordsLabel.Size = UDim2.new(1, 0, 0, 18)
usedWordsLabel.BackgroundTransparency = 1
usedWordsLabel.Text = "📊 Words Used (Auto & Manual): 0"
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
        usedWordsLabel.Text = "📊 Words Used (Auto & Manual): " .. count
        task.wait(1)
    end
end)

-- SUFFIX SETTINGS
local suffixOptions = {"UM", "LY", "X", "Y", "IA", "AK", "KY"}
local selectedSuffixes = {}
for _, suffix in ipairs(suffixOptions) do
    selectedSuffixes[suffix] = true
end
local suffixLengthStrict = false

local suffixLabel = Instance.new("TextLabel")
suffixLabel.Size = UDim2.new(1, 0, 0, 22)
suffixLabel.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
suffixLabel.BorderSizePixel = 0
suffixLabel.Text = "🎯 TARGET SUFFIX"
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
suffixGrid.CellSize = UDim2.new(0, 60, 0, 24)
suffixGrid.CellPadding = UDim2.new(0, 6, 0, 6)
suffixGrid.FillDirectionMaxCells = 3

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
        selectedSuffixes[suffixName] = not selectedSuffixes[suffixName]
        refreshSuffixButtons()
    end)

    table.insert(suffixButtons, btn)
    return btn
end

for _, suffixName in ipairs(suffixOptions) do
    createSuffixButton(suffixName)
end

local suffixOrderButton = Instance.new("TextButton")
suffixOrderButton.Size = UDim2.new(1, 0, 0, 28)
suffixOrderButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
suffixOrderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
suffixOrderButton.Font = Enum.Font.GothamBold
suffixOrderButton.TextSize = 10
suffixOrderButton.Text = "SUFFIX ORDER: LONGEST TO SHORTEST"
suffixOrderButton.AutoButtonColor = false
suffixOrderButton.Parent = settingsScroll

local suffixOrderCorner = Instance.new("UICorner")
suffixOrderCorner.CornerRadius = UDim.new(0, 5)
suffixOrderCorner.Parent = suffixOrderButton

local suffixLengthButton = Instance.new("TextButton")
suffixLengthButton.Size = UDim2.new(1, 0, 0, 28)
suffixLengthButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
suffixLengthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
suffixLengthButton.Font = Enum.Font.GothamBold
suffixLengthButton.TextSize = 10
suffixLengthButton.Text = "LENGTH: USE SUFFIX EVEN IF NOT MATCHED"
suffixLengthButton.AutoButtonColor = false
suffixLengthButton.Parent = settingsScroll

local suffixLengthCorner = Instance.new("UICorner")
suffixLengthCorner.CornerRadius = UDim.new(0, 5)
suffixLengthCorner.Parent = suffixLengthButton

local suffixOrder = true

local function refreshSuffixOrderButton()
    if suffixOrder then
        suffixOrderButton.BackgroundColor3 = Color3.fromRGB(0, 160, 120)
        suffixOrderButton.Text = "SUFFIX ORDER: LONGEST TO SHORTEST"
    else
        suffixOrderButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        suffixOrderButton.Text = "SUFFIX ORDER: SHORTEST TO LONGEST"
    end
end

local function refreshSuffixLengthButton()
    if suffixLengthStrict then
        suffixLengthButton.BackgroundColor3 = Color3.fromRGB(0, 160, 120)
        suffixLengthButton.Text = "LENGTH: IGNORE SUFFIX IF NOT MATCHED"
    else
        suffixLengthButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        suffixLengthButton.Text = "LENGTH: USE SUFFIX EVEN IF NOT MATCHED"
    end
end

suffixOrderButton.MouseButton1Click:Connect(function()
    suffixOrder = not suffixOrder
    refreshSuffixOrderButton()
end)

suffixLengthButton.MouseButton1Click:Connect(function()
    suffixLengthStrict = not suffixLengthStrict
    refreshSuffixLengthButton()
end)

refreshSuffixButtons()
refreshSuffixOrderButton()
refreshSuffixLengthButton()

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

local modeButton = createButton(" LENGTH: SHORT (9 or less)", Color3.fromRGB(40, 100, 200))
local resetButton = createButton(" RESET BLACKLIST", Color3.fromRGB(200, 60, 60))
local exitButton = createButton(" EXIT SCRIPT", Color3.fromRGB(120, 30, 30))

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.Position = UDim2.new(0, 0, 0, 0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 40, 0)
scrollFrame.Parent = consolePanel

-- CONSOLE PADDING
local consolePadding = Instance.new("UIPadding")
consolePadding.PaddingLeft = UDim.new(0, 10)
consolePadding.PaddingRight = UDim.new(0, 10)
consolePadding.PaddingTop = UDim.new(0, 5)
consolePadding.Parent = scrollFrame

local uiLayout = Instance.new("UIListLayout")
uiLayout.Parent = scrollFrame
uiLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiLayout.Padding = UDim.new(0, 2)

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
end

logMessage("System Initialized! Ready to dominate. [TEST VERSION]", Color3.fromRGB(0, 255, 0))
updateStatusIndicator()

-- STATES & TOGGLES
local lengthMode = 1 
local lengthLabels = {
    " LENGTH: SHORT (9 or less)",
    " LENGTH: LONG (10 or more)"
}
modeButton.MouseButton1Click:Connect(function()
    lengthMode = lengthMode == 1 and 2 or 1
    modeButton.Text = lengthLabels[lengthMode]
    logMessage("Switched to " .. lengthLabels[lengthMode], Color3.fromRGB(255, 255, 0))
end)

local suffixModeEnabled = true

local function getSelectedSuffixes()
    local suffixList = {}
    for _, suffixName in ipairs(suffixOptions) do
        if selectedSuffixes[suffixName] then
            table.insert(suffixList, suffixName)
        end
    end

    if suffixOrder then
        table.sort(suffixList, function(a, b)
            return #a > #b
        end)
    else
        table.sort(suffixList, function(a, b)
            return #a < #b
        end)
    end

    return suffixList
end

local function matchesLengthMode(word)
    if lengthMode == 1 then
        return #word <= 9
    elseif lengthMode == 2 then
        return #word >= 10
    end
    return true
end

-- WORD DB FROM GITHUB
local wordsTable = {}
local validWordsDict = {} 
local usedWords = {} 
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
    logMessage("--- BLACKLIST CLEARED ---", Color3.fromRGB(255, 255, 0))
end
resetButton.MouseButton1Click:Connect(clearBlacklist)

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

local function typeRemainingLetters(fullWord, prefixLength)
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
    
    local willMakeTypo = (math.random(1, 100) <= typoRate)
    local typoIndex = -1
    local typosToMake = 1
    local willAddEndTypo = (math.random(1, 100) <= 10) 
    
    if willMakeTypo and #suffix > 2 then
        typoIndex = math.random(1, #suffix - 1)
        local severity = math.random(1, 10)
        if severity <= 5 then
            typosToMake = 1
        elseif severity <= 8 then
            typosToMake = 2
        else
            typosToMake = 3
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
        
        if i == typoIndex then
            local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            for t = 1, typosToMake do
                if not isRunning then break end
                local wrongChar = correctChar
                while wrongChar == correctChar do
                    local rIndex = math.random(1, 26)
                    wrongChar = string.sub(alphabet, rIndex, rIndex)
                end
                
                local wrongKeycode = Enum.KeyCode[wrongChar]
                if wrongKeycode then
                    VIM:SendKeyEvent(true, wrongKeycode, false, game)
                    task.wait(math.random(20, 50) / 1000) 
                    VIM:SendKeyEvent(false, wrongKeycode, false, game)
                    task.wait(math.random(60, 150) / 1000)
                end
            end
            
            task.wait(math.random(250, 500) / 1000)
            
            for t = 1, typosToMake do
                if not isRunning then break end
                VIM:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
                task.wait(math.random(20, 40) / 1000)
                VIM:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
                task.wait(math.random(80, 150) / 1000)
            end
            
            task.wait(math.random(150, 250) / 1000)
            currentStreak = 0 
        end
        
        if keycode and isRunning then
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
        local endTypoChars = {"Z", "X"}
        local chosenEndTypo = endTypoChars[math.random(1, 2)]
        local endTypoKey = Enum.KeyCode[chosenEndTypo]
        
        VIM:SendKeyEvent(true, endTypoKey, false, game)
        task.wait(math.random(20, 50) / 1000)
        VIM:SendKeyEvent(false, endTypoKey, false, game)
        
        task.wait(math.random(100, 250) / 1000)
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
        logMessage("15+ letters! Waiting 3 seconds before enter...", Color3.fromRGB(255, 255, 0))
        task.wait(3)
    elseif math.random(1, 100) <= 5 then
        logMessage("Distracted! Waiting 4 seconds...", Color3.fromRGB(255, 150, 0))
        task.wait(4)
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
    
    while isRunning and task.wait(0.1) do
        local currentText = readInputBox()
        local isMyTurn = localPlayer:GetAttribute("IsTurn") == true
        
        if isMyTurn ~= wasMyTurn then
            if lastSeenText ~= "" and validWordsDict[lastSeenText] and not usedWords[lastSeenText] then
                usedWords[lastSeenText] = true
                logMessage("[BLACKLIST] " .. lastSeenText, Color3.fromRGB(255, 150, 0))
            end
            wasMyTurn = isMyTurn
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
                        
                        for _, word in ipairs(wordsTable) do
                            if string.sub(word, 1, #settledPrefix) == settledPrefix and not usedWords[word] then
                                table.insert(fallbackMatches, word)
                                
                                local matchesLength = false
                                if lengthMode == 1 and #word <= 9 then matchesLength = true end
                                if lengthMode == 2 and #word >= 10 then matchesLength = true end
                                
                                if matchesLength then
                                    table.insert(exactLengthMatches, word)
                                end
                            end
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
                            local chosenWord = finalPool[math.random(1, #finalPool)]
                            usedWords[chosenWord] = true 
                            if autoAnswerEnabled then
                                logMessage(">> PLAYING: " .. chosenWord, Color3.fromRGB(0, 255, 255))
                                typeRemainingLetters(chosenWord, #settledPrefix)
                            else
                                logMessage(">> FOUND: " .. chosenWord .. " (Manual Mode - Not Auto-Typing)", Color3.fromRGB(255, 200, 0))
                            end
                        else
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