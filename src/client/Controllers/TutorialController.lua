--!strict
--[[
    TutorialController.lua
    Interactive step-by-step tutorial for new players.
    Shows big, picture-based instruction panels.
    Auto-advances on player actions or manual "Weiter!" button.
    Only runs once per player (tutorialComplete flag in profile).
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Tutorial = require(ReplicatedStorage:WaitForChild("Tutorial"))

local TutorialController = {}
TutorialController.__index = TutorialController

local player: Player = nil
local Remotes = nil
local UIController = nil

local tutorialFrame: Frame = nil
local titleLabel: TextLabel = nil
local descLabel: TextLabel = nil
local keyHighlight: TextLabel = nil
local nextButton: TextButton = nil
local stepCounter: TextLabel = nil
local skipButton: TextButton = nil

local currentStep = 1
local isActive = false
local tutorialComplete = false
local currentVoice: Sound? = nil

-- Event tracking
local hasMoved = false
local hasOpenedInventory = false
local hasUsedShuttle = false
local hasGathered = false
local hasCrafted = false
local hasOpenedQuest = false

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function TutorialController:Init(plr: Player, remotes: any)
    player = plr
    Remotes = remotes

    local Controllers = script.Parent
    UIController = require(Controllers:WaitForChild("UIController"))
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------
function TutorialController:Start()
    local screenGui = UIController:GetScreenGui()
    self:_buildUI(screenGui)
    self:_connectTracking()
    print("[TutorialController] Ready")
end

---------------------------------------------------------------------------
-- Full sync: Check if tutorial already completed
---------------------------------------------------------------------------
function TutorialController:OnFullSync(data: any)
    if data then
        tutorialComplete = data.tutorialComplete or false
        if not tutorialComplete and data.firstJoin then
            -- Start tutorial for new players
            task.delay(2, function()
                self:_startTutorial()
            end)
        end
    end
end

---------------------------------------------------------------------------
-- Build tutorial UI
---------------------------------------------------------------------------
function TutorialController:_buildUI(screenGui: ScreenGui)
    -- Dark overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "TutorialOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Constants.COLORS.DARK
    overlay.BackgroundTransparency = 0.5
    overlay.ZIndex = 90
    overlay.Visible = false
    overlay.Parent = screenGui

    -- Main tutorial panel
    tutorialFrame = Instance.new("Frame")
    tutorialFrame.Name = "TutorialPanel"
    tutorialFrame.Size = UDim2.new(0, 500, 0, 320)
    tutorialFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
    tutorialFrame.BackgroundColor3 = Constants.COLORS.SURFACE
    tutorialFrame.BorderSizePixel = 0
    tutorialFrame.ZIndex = 95
    tutorialFrame.Visible = false
    tutorialFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = tutorialFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Constants.COLORS.GLOW
    stroke.Thickness = 3
    stroke.Parent = tutorialFrame

    -- sgit logo area (green bar at top)
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 8)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundColor3 = Constants.COLORS.ACCENT
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 96
    topBar.Parent = tutorialFrame

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 16)
    topCorner.Parent = topBar

    -- Title
    titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -30, 0, 45)
    titleLabel.Position = UDim2.new(0, 15, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Constants.COLORS.GLOW
    titleLabel.Font = Constants.FONTS.HEADING
    titleLabel.TextSize = 32
    titleLabel.Text = ""
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.ZIndex = 96
    titleLabel.Parent = tutorialFrame

    -- Description
    descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -40, 0, 100)
    descLabel.Position = UDim2.new(0, 20, 0, 75)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = Constants.COLORS.WHITE
    descLabel.Font = Constants.FONTS.BODY
    descLabel.TextSize = 24
    descLabel.TextWrapped = true
    descLabel.Text = ""
    descLabel.TextXAlignment = Enum.TextXAlignment.Center
    descLabel.ZIndex = 96
    descLabel.Parent = tutorialFrame

    -- Key highlight (big key indicator)
    keyHighlight = Instance.new("TextLabel")
    keyHighlight.Name = "KeyHighlight"
    keyHighlight.Size = UDim2.new(0, 70, 0, 70)
    keyHighlight.Position = UDim2.new(0.5, -35, 0, 180)
    keyHighlight.BackgroundColor3 = Constants.COLORS.PRIMARY
    keyHighlight.TextColor3 = Constants.COLORS.GLOW
    keyHighlight.Font = Constants.FONTS.HEADING
    keyHighlight.TextSize = 36
    keyHighlight.Text = ""
    keyHighlight.Visible = false
    keyHighlight.ZIndex = 96
    keyHighlight.Parent = tutorialFrame

    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 12)
    keyCorner.Parent = keyHighlight

    local keyStroke = Instance.new("UIStroke")
    keyStroke.Color = Constants.COLORS.GLOW
    keyStroke.Thickness = 3
    keyStroke.Parent = keyHighlight

    -- Step counter
    stepCounter = Instance.new("TextLabel")
    stepCounter.Name = "StepCounter"
    stepCounter.Size = UDim2.new(0, 100, 0, 25)
    stepCounter.Position = UDim2.new(0, 15, 1, -35)
    stepCounter.BackgroundTransparency = 1
    stepCounter.TextColor3 = Constants.COLORS.DISABLED
    stepCounter.Font = Constants.FONTS.MONO
    stepCounter.TextSize = 14
    stepCounter.TextXAlignment = Enum.TextXAlignment.Left
    stepCounter.Text = ""
    stepCounter.ZIndex = 96
    stepCounter.Parent = tutorialFrame

    -- "Weiter!" button
    nextButton = Instance.new("TextButton")
    nextButton.Name = "NextBtn"
    nextButton.Size = UDim2.new(0, 160, 0, 55)
    nextButton.Position = UDim2.new(1, -180, 1, -70)
    nextButton.BackgroundColor3 = Constants.COLORS.ACCENT
    nextButton.TextColor3 = Constants.COLORS.WHITE
    nextButton.Font = Constants.FONTS.HEADING
    nextButton.TextSize = 26
    nextButton.Text = "Weiter!"
    nextButton.BorderSizePixel = 0
    nextButton.AutoButtonColor = false
    nextButton.ZIndex = 96
    nextButton.Parent = tutorialFrame

    local nextCorner = Instance.new("UICorner")
    nextCorner.CornerRadius = UDim.new(0, 12)
    nextCorner.Parent = nextButton

    -- Button hover animation
    nextButton.MouseEnter:Connect(function()
        TweenService:Create(nextButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Constants.COLORS.GLOW,
        }):Play()
    end)
    nextButton.MouseLeave:Connect(function()
        TweenService:Create(nextButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Constants.COLORS.ACCENT,
        }):Play()
    end)

    nextButton.MouseButton1Click:Connect(function()
        self:_advanceStep()
    end)

    -- "Ueberspringen" skip button
    skipButton = Instance.new("TextButton")
    skipButton.Name = "SkipBtn"
    skipButton.Size = UDim2.new(0, 120, 0, 30)
    skipButton.Position = UDim2.new(0, 15, 1, -65)
    skipButton.BackgroundTransparency = 1
    skipButton.TextColor3 = Constants.COLORS.DISABLED
    skipButton.Font = Constants.FONTS.BODY
    skipButton.TextSize = 16
    skipButton.Text = "Ueberspringen"
    skipButton.ZIndex = 96
    skipButton.Parent = tutorialFrame

    skipButton.MouseButton1Click:Connect(function()
        self:_completeTutorial()
    end)

    -- Store overlay reference
    tutorialFrame:SetAttribute("OverlayRef", true)
    overlay:SetAttribute("TutorialOverlay", true)
end

---------------------------------------------------------------------------
-- Start the tutorial
---------------------------------------------------------------------------
function TutorialController:_startTutorial()
    if tutorialComplete or isActive then return end
    isActive = true
    currentStep = 1

    -- Show UI
    local screenGui = UIController:GetScreenGui()
    local overlay = screenGui:FindFirstChild("TutorialOverlay")
    if overlay then overlay.Visible = true end
    tutorialFrame.Visible = true

    -- Close all panels
    UIController:CloseAllPanels()

    self:_showStep(currentStep)
end

---------------------------------------------------------------------------
-- Show a tutorial step
---------------------------------------------------------------------------
function TutorialController:_showStep(stepId: number)
    local step = Tutorial.getStep(stepId)
    if not step then
        self:_completeTutorial()
        return
    end

    -- Update text
    titleLabel.Text = step.title
    descLabel.Text = step.description
    stepCounter.Text = stepId .. " / " .. Tutorial.getStepCount()

    -- Key highlight
    if step.highlightKey then
        keyHighlight.Text = step.highlightKey
        keyHighlight.Visible = true

        -- Pulse animation
        task.spawn(function()
            while keyHighlight.Visible and currentStep == stepId do
                TweenService:Create(keyHighlight, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 80, 0, 80),
                    Position = UDim2.new(0.5, -40, 0, 175),
                }):Play()
                task.wait(0.5)
                TweenService:Create(keyHighlight, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 70, 0, 70),
                    Position = UDim2.new(0.5, -35, 0, 180),
                }):Play()
                task.wait(0.5)
            end
        end)
    else
        keyHighlight.Visible = false
    end

    -- Button text
    if stepId == Tutorial.getStepCount() then
        nextButton.Text = "Los geht's!"
    elseif step.waitForEvent then
        nextButton.Text = "Weiter!"
    else
        nextButton.Text = "Weiter!"
    end

    -- Panel position
    if step.position == "bottom" then
        tutorialFrame.Position = UDim2.new(0.5, -250, 1, -340)
    elseif step.position == "top" then
        tutorialFrame.Position = UDim2.new(0.5, -250, 0, 20)
    else
        tutorialFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
    end

    -- Animate in
    tutorialFrame.BackgroundTransparency = 1
    TweenService:Create(tutorialFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
    }):Play()

    -- Play voice narration
    self:_playVoice(step)
end

---------------------------------------------------------------------------
-- Play voice narration for a step
---------------------------------------------------------------------------
function TutorialController:_playVoice(step: any)
    -- Stop any current narration
    self:_stopVoice()

    -- Check if voice is enabled (via SettingsUI)
    local Controllers = script.Parent
    local settingsModule = Controllers:FindFirstChild("SettingsUI")
    if settingsModule then
        local ok, SettingsUI = pcall(require, settingsModule)
        if ok and SettingsUI.GetSetting then
            local voiceEnabled = SettingsUI.GetSetting("voiceEnabled")
            if voiceEnabled == false then
                return
            end
        end
    end

    -- Check if voice ID is valid (not placeholder)
    if not step.voiceId or step.voiceId == "rbxassetid://0" then
        return
    end

    -- Create and play voice sound
    currentVoice = Instance.new("Sound")
    currentVoice.Name = "TutorialVoice"
    currentVoice.SoundId = step.voiceId
    currentVoice.Volume = 0.8
    currentVoice.Parent = SoundService
    currentVoice:Play()

    -- Cleanup when done
    currentVoice.Ended:Connect(function()
        if currentVoice then
            currentVoice:Destroy()
            currentVoice = nil
        end
    end)
end

---------------------------------------------------------------------------
-- Stop current voice narration
---------------------------------------------------------------------------
function TutorialController:_stopVoice()
    if currentVoice then
        currentVoice:Stop()
        currentVoice:Destroy()
        currentVoice = nil
    end
end

---------------------------------------------------------------------------
-- Advance to next step
---------------------------------------------------------------------------
function TutorialController:_advanceStep()
    currentStep += 1
    if currentStep > Tutorial.getStepCount() then
        self:_completeTutorial()
    else
        self:_showStep(currentStep)
    end
end

---------------------------------------------------------------------------
-- Auto-advance when event matches current step
---------------------------------------------------------------------------
function TutorialController:_checkAutoAdvance(eventName: string)
    if not isActive then return end

    local step = Tutorial.getStep(currentStep)
    if step and step.waitForEvent == eventName then
        task.delay(0.5, function()
            self:_advanceStep()
        end)
    end
end

---------------------------------------------------------------------------
-- Complete tutorial
---------------------------------------------------------------------------
function TutorialController:_completeTutorial()
    isActive = false
    tutorialComplete = true

    -- Stop voice narration
    self:_stopVoice()

    -- Hide UI
    local screenGui = UIController:GetScreenGui()
    local overlay = screenGui:FindFirstChild("TutorialOverlay")

    TweenService:Create(tutorialFrame, TweenInfo.new(0.3), {
        BackgroundTransparency = 1,
    }):Play()

    if overlay then
        TweenService:Create(overlay, TweenInfo.new(0.3), {
            BackgroundTransparency = 1,
        }):Play()
    end

    task.delay(0.3, function()
        tutorialFrame.Visible = false
        if overlay then overlay.Visible = false end
    end)

    -- Notify server
    local TutorialDone = Remotes:FindFirstChild("TutorialComplete") :: RemoteEvent?
    if TutorialDone then
        TutorialDone:FireServer()
    end

    print("[TutorialController] Tutorial completed!")
end

---------------------------------------------------------------------------
-- Connect event tracking for auto-advance
---------------------------------------------------------------------------
function TutorialController:_connectTracking()
    -- Track player movement
    task.spawn(function()
        task.wait(3)
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid?
        if humanoid then
            humanoid.Running:Connect(function(speed: number)
                if speed > 0 and not hasMoved then
                    hasMoved = true
                    self:_checkAutoAdvance("move")
                end
            end)
        end
    end)

    -- Track key presses for UI events
    UserInputService.InputBegan:Connect(function(input, processed)
        if not isActive then return end

        if input.KeyCode == Enum.KeyCode.Tab and not hasOpenedInventory then
            hasOpenedInventory = true
            self:_checkAutoAdvance("open_inventory")
        elseif input.KeyCode == Enum.KeyCode.C and not hasCrafted then
            hasCrafted = true
            self:_checkAutoAdvance("craft")
        elseif input.KeyCode == Enum.KeyCode.Q and not hasOpenedQuest then
            hasOpenedQuest = true
            self:_checkAutoAdvance("quest")
        end
    end)

    -- Track shuttle usage
    local ShuttleResult = Remotes:WaitForChild("ShuttleResult") :: RemoteEvent
    ShuttleResult.OnClientEvent:Connect(function(data: any)
        if not hasUsedShuttle then
            hasUsedShuttle = true
            self:_checkAutoAdvance("shuttle")
        end
    end)

    -- Track gathering (via inventory change after first planet visit)
    local InventoryChanged = Remotes:WaitForChild("InventoryChanged") :: RemoteEvent
    InventoryChanged.OnClientEvent:Connect(function()
        if hasUsedShuttle and not hasGathered then
            hasGathered = true
            self:_checkAutoAdvance("gather")
        end
    end)
end

return TutorialController
