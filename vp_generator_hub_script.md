--[[
========================================================
VP GENERATOR HUB - VIOLENCE DISTRICT
Features: Ultra Fast Repair (Multi-Trigger) + Auto Skill Check + Custom Drag UI
========================================================
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MIN_SPEED = 1
local MAX_SPEED = 10
local GeneratorSpeed = MIN_SPEED
local MAX_REPAIR_DISTANCE = 15 -- Jarak maksimum perbaikan (Studs)
local isRunning = false

-- Cleanup GUI Lama jika ada
local oldGui = playerGui:FindFirstChild("VP_ViolenceDistrictHub")
if oldGui then
    oldGui:Destroy()
end

-- ScreenGui Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VP_ViolenceDistrictHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

-- HELPER: CUSTOM DRAGGABLE FUNCTION (SUPPORTS TOUCH & MOUSE)
local function makeDraggable(guiObject)
    local dragging = false
    local dragInput, dragStart, startPos

    guiObject.InputBegan:Connect(function(input)
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

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- 1. TOMBOL LINGKARAN "VP" (TOGGLE MENU)
local VPButton = Instance.new("TextButton")
VPButton.Name = "VPButton"
VPButton.Size = UDim2.fromOffset(50, 50)
VPButton.Position = UDim2.fromScale(0.08, 0.25)
VPButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
VPButton.Text = "VP"
VPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
VPButton.TextSize = 20
VPButton.Font = Enum.Font.SourceSansBold
VPButton.Active = true
VPButton.Parent = ScreenGui

local VPCorner = Instance.new("UICorner")
VPCorner.CornerRadius = UDim.new(1, 0)
VPCorner.Parent = VPButton

local VPStroke = Instance.new("UIStroke")
VPStroke.Color = Color3.fromRGB(255, 255, 255)
VPStroke.Thickness = 2
VPStroke.Parent = VPButton

makeDraggable(VPButton)

-- 2. MENU UTAMA (MAIN FRAME)
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.fromOffset(320, 260)
Frame.Position = UDim2.fromScale(0.5, 0.5)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Visible = false
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = Frame

makeDraggable(Frame)

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "VIOLENCE DISTRICT - VP HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 17
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

-- Speed Label
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Position = UDim2.fromOffset(20, 42)
SpeedLabel.Size = UDim2.fromOffset(280, 25)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Repair Speed: 1x"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 15
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.Parent = Frame

-- Slider Bar
local SliderBar = Instance.new("Frame")
SliderBar.Name = "SliderBar"
SliderBar.Position = UDim2.fromOffset(25, 75)
SliderBar.Size = UDim2.fromOffset(270, 10)
SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = Frame

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = SliderBar

-- Knob Slider
local Knob = Instance.new("TextButton")
Knob.Name = "Knob"
Knob.Size = UDim2.fromOffset(24, 24)
Knob.Position = UDim2.new(0, -12, 0.5, -12)
Knob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Knob.BorderSizePixel = 0
Knob.Text = ""
Knob.AutoButtonColor = false
Knob.Parent = SliderBar

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = Knob

-- Skill Check Info
local SkillCheckLabel = Instance.new("TextLabel")
SkillCheckLabel.Name = "SkillCheckLabel"
SkillCheckLabel.Position = UDim2.fromOffset(20, 105)
SkillCheckLabel.Size = UDim2.fromOffset(280, 25)
SkillCheckLabel.BackgroundTransparency = 1
SkillCheckLabel.Text = "Auto Skill Check: ACTIVE"
SkillCheckLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
SkillCheckLabel.TextSize = 14
SkillCheckLabel.Font = Enum.Font.SourceSansSemibold
SkillCheckLabel.Parent = Frame

-- Distance Info
local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Name = "DistanceLabel"
DistanceLabel.Position = UDim2.fromOffset(20, 130)
DistanceLabel.Size = UDim2.fromOffset(280, 25)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.Text = "Max Distance: 15 Studs (Safe Range)"
DistanceLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
DistanceLabel.TextSize = 14
DistanceLabel.Font = Enum.Font.SourceSansSemibold
DistanceLabel.Parent = Frame

-- Start/Stop Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Position = UDim2.fromOffset(25, 170)
ToggleBtn.Size = UDim2.fromOffset(270, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
ToggleBtn.Text = "START REPAIR & SKILL CHECK"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 15
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleBtn

-- 3. LOGIKA SLIDER & UI INTERAKSI
VPButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

local sliderDragging = false

local function updateSlider(inputX)
    local barX = SliderBar.AbsolutePosition.X
    local barWidth = SliderBar.AbsoluteSize.X

    local percent = math.clamp((inputX - barX) / barWidth, 0, 1)
    local speed = math.floor(percent * (MAX_SPEED - MIN_SPEED) + MIN_SPEED + 0.5)

    GeneratorSpeed = math.clamp(speed, MIN_SPEED, MAX_SPEED)
    Knob.Position = UDim2.new(percent, -12, 0.5, -12)
    SpeedLabel.Text = "Repair Speed: " .. GeneratorSpeed .. "x"
end

Knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleBtn.Text = "STOP REPAIR"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    else
        ToggleBtn.Text = "START REPAIR & SKILL CHECK"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    end
end)

-- 4. LOGIKA AUTO SKILL CHECK (AUTOMATIC QTE TRIGGER)
local function hitSkillCheck()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.01)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)

        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.01)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

playerGui.DescendantAdded:Connect(function(descendant)
    if not isRunning then return end

    local nameLower = string.lower(descendant.Name)
    if string.find(nameLower, "skillcheck") or string.find(nameLower, "qte") or string.find(nameLower, "needle") or string.find(nameLower, "space") then
        task.defer(function()
            task.wait(0.01)
            hitSkillCheck()
        end)
    end
end)

-- 5. LOGIKA ULTRA FAST REPAIR (MULTI-TRIGGER LOOPER)
task.spawn(function()
    while ScreenGui.Parent do
        if isRunning then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart

                for _, prompt in ipairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local parentPart = prompt.Parent
                        if parentPart and parentPart:IsA("BasePart") then
                            local distance = (hrp.Position - parentPart.Position).Magnitude

                            -- Pengecekan Batasan Jarak
                            if distance <= MAX_REPAIR_DISTANCE and distance <= prompt.MaxActivationDistance then
                                if fireproximityprompt then
                                    -- Multi-trigger loop berdasarkan Speed untuk menembus limit FPS (~5 Detik/Instan)
                                    local triggerCount = math.clamp(math.floor(GeneratorSpeed * 2.5), 1, 25)
                                    for _ = 1, triggerCount do
                                        pcall(function()
                                            fireproximityprompt(prompt, 0)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- Pengecekan Skill Check UI tambahan jika terlewat event DescendantAdded
            for _, gui in ipairs(playerGui:GetDescendants()) do
                if gui:IsA("GuiObject") and gui.Visible then
                    local gName = string.lower(gui.Name)
                    if string.find(gName, "skillcheck") or string.find(gName, "qte") or string.find(gName, "zone") then
                        hitSkillCheck()
                        break
                    end
                end
            end

            task.wait(0.02)
        else
            task.wait(0.2)
        end
    end
end)

-- Notifikasi Sukses Load
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "VP Generator Hub",
        Text = "Script Loaded Successfully!",
        Duration = 3
    })
end)