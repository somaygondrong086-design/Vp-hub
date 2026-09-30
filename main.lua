-- MY GENERATOR HUB
-- GUI + Generator Speed Slider
-- Mouse + Touch Support

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MIN_SPEED = 1
local MAX_SPEED = 10
local GeneratorSpeed = MIN_SPEED

-- Remove old GUI
local oldGui = playerGui:FindFirstChild("MyGeneratorHub")
if oldGui then
    oldGui:Destroy()
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyGeneratorHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.fromOffset(320, 170)
Frame.Position = UDim2.fromScale(0.5, 0.5)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "MY GENERATOR HUB"
Title.TextSize = 20
Title.Parent = Frame

-- Speed Label
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Position = UDim2.fromOffset(20, 50)
SpeedLabel.Size = UDim2.fromOffset(280, 30)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Generator Speed: 1x"
SpeedLabel.TextSize = 18
SpeedLabel.Parent = Frame

-- Slider
local SliderBar = Instance.new("Frame")
SliderBar.Name = "SliderBar"
SliderBar.Position = UDim2.fromOffset(25, 95)
SliderBar.Size = UDim2.fromOffset(270, 10)
SliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = Frame

-- Knob
local Knob = Instance.new("TextButton")
Knob.Name = "Knob"
Knob.Size = UDim2.fromOffset(24, 24)
Knob.Position = UDim2.new(0, -12, 0.5, -12)
Knob.Text = ""
Knob.AutoButtonColor = false
Knob.Parent = SliderBar

local dragging = false

local function updateSlider(inputX)
    local barX = SliderBar.AbsolutePosition.X
    local barWidth = SliderBar.AbsoluteSize.X

    local percent = (inputX - barX) / barWidth
    percent = math.clamp(percent, 0, 1)

    local speed = math.floor(
        percent * (MAX_SPEED - MIN_SPEED) + MIN_SPEED + 0.5
    )

    speed = math.clamp(speed, MIN_SPEED, MAX_SPEED)
    GeneratorSpeed = speed

    Knob.Position = UDim2.new(
        percent,
        -12,
        0.5,
        -12
    )

    SpeedLabel.Text = "Generator Speed: " .. GeneratorSpeed .. "x"
end

-- Mouse / Touch start
Knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

-- Mouse / Touch movement
UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        updateSlider(input.Position.X)
    end
end)

-- Mouse / Touch end
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
