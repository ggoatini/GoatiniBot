
-- GOATINI AUTO CLICKER V3
-- Roblox / Xeno
-- Small target with center click dot

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("GoatiniAutoClickerV3")
if oldGui then
    oldGui:Destroy()
end

local running = false
local closed = false
local circleVisible = true
local language = "PL"
local clickInterval = 0.30
local clickCount = 0
local lastClick = 0

local GOLD = Color3.fromRGB(255, 185, 35)
local ORANGE = Color3.fromRGB(255, 165, 0)
local DARK = Color3.fromRGB(19, 19, 22)
local PANEL = Color3.fromRGB(30, 30, 35)
local WHITE = Color3.fromRGB(245, 245, 245)
local MUTED = Color3.fromRGB(175, 175, 175)

local gui = Instance.new("ScreenGui")
gui.Name = "GoatiniAutoClickerV3"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.Parent = parent
    return s
end

local function makeText(parent, name, text, pos, size, fontSize, color)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Position = pos
    label.Size = size
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextSize = fontSize
    label.TextColor3 = color
    label.Parent = parent
    return label
end

local function makeButton(parent, name, text, pos, size)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = pos
    button.Size = size
    button.BackgroundColor3 = PANEL
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = WHITE
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = true
    corner(button, 8)
    button.Parent = parent
    return button
end

-- MAIN PANEL

local main = Instance.new("Frame")
main.Name = "MainPanel"
main.Size = UDim2.fromOffset(320, 315)
main.Position = UDim2.new(0.5, -160, 0.5, -157)
main.BackgroundColor3 = DARK
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
corner(main, 12)
stroke(main, GOLD, 1.5)

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 33, 20)),
    ColorSequenceKeypoint.new(1, DARK)
})
gradient.Rotation = 90
gradient.Parent = main

local title = makeText(
    main, "Title", "GOATINI AUTO CLICKER V3",
    UDim2.fromOffset(14, 12),
    UDim2.fromOffset(265, 26),
    17, GOLD
)
title.TextXAlignment = Enum.TextXAlignment.Left

local closeButton = makeButton(
    main, "Close", "X",
    UDim2.fromOffset(282, 12),
    UDim2.fromOffset(26, 26)
)
closeButton.TextColor3 = GOLD

local subtitle = makeText(
    main, "Subtitle", "ROBLOX AUTO CLICKER",
    UDim2.fromOffset(15, 42),
    UDim2.fromOffset(290, 18),
    11, MUTED
)

local startButton = makeButton(
    main, "StartStop", "START",
    UDim2.fromOffset(20, 75),
    UDim2.fromOffset(280, 43)
)
startButton.BackgroundColor3 = Color3.fromRGB(95, 70, 18)
stroke(startButton, GOLD, 1)

local speedTitle = makeText(
    main, "SpeedTitle", "SZYBKOSC KLIKANIA",
    UDim2.fromOffset(20, 131),
    UDim2.fromOffset(280, 20),
    12, GOLD
)

local minusButton = makeButton(
    main, "Faster", "-",
    UDim2.fromOffset(20, 157),
    UDim2.fromOffset(52, 37)
)

local speedLabel = makeText(
    main, "SpeedValue", "0.30 s",
    UDim2.fromOffset(78, 157),
    UDim2.fromOffset(164, 37),
    16, WHITE
)

local plusButton = makeButton(
    main, "Slower", "+",
    UDim2.fromOffset(248, 157),
    UDim2.fromOffset(52, 37)
)

local toggleCircleButton = makeButton(
    main, "ToggleCircle", "UKRYJ KOLO",
    UDim2.fromOffset(20, 209),
    UDim2.fromOffset(135, 35)
)

local languageButton = makeButton(
    main, "Language", "PL / EN",
    UDim2.fromOffset(165, 209),
    UDim2.fromOffset(135, 35)
)

local counterLabel = makeText(
    main, "Counter", "KLIKNIECIA: 0",
    UDim2.fromOffset(20, 259),
    UDim2.fromOffset(280, 22),
    13, GOLD
)

local footer = makeText(
    main, "Footer", "M = START / STOP",
    UDim2.fromOffset(20, 288),
    UDim2.fromOffset(280, 17),
    10, MUTED
)

-- SMALL TARGET CIRCLE

local target = Instance.new("Frame")
target.Name = "ClickTarget"
target.Size = UDim2.fromOffset(40, 40)
target.Position = UDim2.new(0.5, -20, 0.3, -20)
target.BackgroundTransparency = 1
target.BorderSizePixel = 0
target.Active = true
target.ZIndex = 20
target.Parent = gui
corner(target, 40)
stroke(target, ORANGE, 2)

-- Center dot: exact click location

local dot = Instance.new("Frame")
dot.Name = "ClickPoint"
dot.Size = UDim2.fromOffset(6, 6)
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.fromScale(0.5, 0.5)
dot.BackgroundColor3 = ORANGE
dot.BorderSizePixel = 0
dot.ZIndex = 21
dot.Parent = target
corner(dot, 6)

-- DRAGGING

local function makeDraggable(object, handle)
    local dragging = false
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = object.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
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

makeDraggable(main, title)
makeDraggable(target, target)

-- TRANSLATIONS

local translations = {
    PL = {
        start = "START",
        stop = "STOP",
        speed = "SZYBKOSC KLIKANIA",
        hide = "UKRYJ KOLO",
        show = "POKAZ KOLO",
        clicks = "KLIKNIECIA: ",
        footer = "M = START / STOP"
    },
    EN = {
        start = "START",
        stop = "STOP",
        speed = "CLICK SPEED",
        hide = "HIDE CIRCLE",
        show = "SHOW CIRCLE",
        clicks = "CLICKS: ",
        footer = "M = START / STOP"
    }
}

local function updateUI()
    local t = translations[language]

    startButton.Text = running and t.stop or t.start
    speedTitle.Text = t.speed
    speedLabel.Text = string.format("%.2f s", clickInterval)
    toggleCircleButton.Text = circleVisible and t.hide or t.show
    counterLabel.Text = t.clicks .. tostring(clickCount)
    footer.Text = t.footer

    startButton.BackgroundColor3 = running
        and Color3.fromRGB(130, 40, 40)
        or Color3.fromRGB(95, 70, 18)
end

local function toggleRunning()
    running = not running
    lastClick = 0
    updateUI()
end

startButton.MouseButton1Click:Connect(toggleRunning)

minusButton.MouseButton1Click:Connect(function()
    clickInterval = math.max(0.05, clickInterval - 0.05)
    clickInterval = math.floor(clickInterval * 100 + 0.5) / 100
    updateUI()
end)

plusButton.MouseButton1Click:Connect(function()
    clickInterval = math.min(2.00, clickInterval + 0.05)
    clickInterval = math.floor(clickInterval * 100 + 0.5) / 100
    updateUI()
end)

toggleCircleButton.MouseButton1Click:Connect(function()
    circleVisible = not circleVisible
    target.Visible = circleVisible
    updateUI()
end)

languageButton.MouseButton1Click:Connect(function()
    language = language == "PL" and "EN" or "PL"
    updateUI()
end)

-- EXACT CENTER DOT COORDINATES

local function getClickPosition()
    local center = dot.AbsolutePosition + dot.AbsoluteSize / 2

    return math.floor(center.X + 0.5),
           math.floor(center.Y + 0.5)
end

-- AUTO CLICKING

local clickConnection

clickConnection = RunService.Heartbeat:Connect(function()
    if closed or not running then
        return
    end

    local now = os.clock()

    if now - lastClick >= clickInterval then
        lastClick = now

        local x, y = getClickPosition()

        local success = pcall(function()
            VirtualInputManager:SendMouseButtonEvent(
                x, y, 0, true, game, 0
            )

            VirtualInputManager:SendMouseButtonEvent(
                x, y, 0, false, game, 0
            )
        end)

        if success then
            clickCount = clickCount + 1
            counterLabel.Text =
                translations[language].clicks .. tostring(clickCount)
        end
    end
end)

-- KEYBOARD HOTKEY

local inputConnection

inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if closed or processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.M then
        toggleRunning()
    end
end)

-- CLOSE

closeButton.MouseButton1Click:Connect(function()
    closed = true
    running = false

    if clickConnection then
        clickConnection:Disconnect()
    end

    if inputConnection then
        inputConnection:Disconnect()
    end

    gui:Destroy()
end)

updateUI()

print("GOATINI AUTO CLICKER V3 LOADED")
