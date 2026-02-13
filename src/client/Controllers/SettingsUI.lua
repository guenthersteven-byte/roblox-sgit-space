--!strict
--[[
    SettingsUI.lua
    Accessibility settings panel.
    Simple options for kids: Sound, Music, UI Size.
    Toggle with P key.
]]

local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))

local SettingsUI = {}
SettingsUI.__index = SettingsUI

local player: Player = nil
local Remotes = nil
local UIController = nil

local settingsFrame: Frame = nil

-- Current settings (defaults)
local settings = {
    soundEnabled = true,
    musicEnabled = true,
    voiceEnabled = true,
    uiScale = 1.0,    -- 1.0 = normal, 1.3 = gross
}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function SettingsUI:Init(plr: Player, remotes: any)
    player = plr
    Remotes = remotes

    local Controllers = script.Parent
    UIController = require(Controllers:WaitForChild("UIController"))
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------
function SettingsUI:Start()
    local screenGui = UIController:GetScreenGui()
    self:_buildUI(screenGui)
    self:_connectEvents()
    print("[SettingsUI] Ready")
end

---------------------------------------------------------------------------
-- Get setting value (used by other controllers)
---------------------------------------------------------------------------
function SettingsUI.GetSetting(key: string): any
    return settings[key]
end

---------------------------------------------------------------------------
-- Build UI
---------------------------------------------------------------------------
function SettingsUI:_buildUI(screenGui: ScreenGui)
    settingsFrame = UIController.CreateFrame(
        screenGui,
        "SettingsPanel",
        UDim2.new(0, 380, 0, 400),
        UDim2.new(0.5, -190, 0.5, -200)
    )
    settingsFrame.Visible = false

    -- Title
    local title = UIController.CreateLabel(
        settingsFrame,
        "Title",
        "Einstellungen",
        UDim2.new(1, -20, 0, 40),
        UDim2.new(0, 10, 0, 5)
    )
    title.Font = Constants.FONTS.HEADING
    title.TextSize = Constants.UI.TEXT_SIZE_LARGE
    title.TextXAlignment = Enum.TextXAlignment.Center

    -- Close button
    local closeBtn = UIController.CreateButton(
        settingsFrame,
        "CloseBtn",
        "X",
        UDim2.new(0, 40, 0, 40),
        UDim2.new(1, -45, 0, 5)
    )
    closeBtn.BackgroundColor3 = Constants.COLORS.PRIMARY
    closeBtn.MouseButton1Click:Connect(function()
        settingsFrame.Visible = false
    end)

    -- Settings list
    local yPos = 60

    -- Sound toggle
    yPos = self:_createToggle(settingsFrame, "Geraeusche", "soundEnabled", yPos)

    -- Music toggle
    yPos = self:_createToggle(settingsFrame, "Musik", "musicEnabled", yPos)

    -- Voice narration toggle
    yPos = self:_createToggle(settingsFrame, "Vorlesen", "voiceEnabled", yPos)

    -- UI Scale section
    yPos += 15
    local scaleTitle = UIController.CreateLabel(
        settingsFrame,
        "ScaleTitle",
        "Schriftgroesse",
        UDim2.new(1, -30, 0, 30),
        UDim2.new(0, 15, 0, yPos)
    )
    scaleTitle.Font = Constants.FONTS.HEADING
    scaleTitle.TextSize = 20
    yPos += 35

    -- Normal button
    local normalBtn = UIController.CreateButton(
        settingsFrame,
        "ScaleNormal",
        "Normal",
        UDim2.new(0, 140, 0, 50),
        UDim2.new(0, 20, 0, yPos)
    )
    normalBtn.BackgroundColor3 = settings.uiScale == 1.0 and Constants.COLORS.ACCENT or Constants.COLORS.PRIMARY

    -- Gross button
    local grossBtn = UIController.CreateButton(
        settingsFrame,
        "ScaleGross",
        "GROSS",
        UDim2.new(0, 140, 0, 50),
        UDim2.new(0, 180, 0, yPos)
    )
    grossBtn.TextSize = 28
    grossBtn.BackgroundColor3 = settings.uiScale == 1.3 and Constants.COLORS.ACCENT or Constants.COLORS.PRIMARY

    normalBtn.MouseButton1Click:Connect(function()
        settings.uiScale = 1.0
        normalBtn.BackgroundColor3 = Constants.COLORS.ACCENT
        grossBtn.BackgroundColor3 = Constants.COLORS.PRIMARY
        self:_applyUIScale()
    end)

    grossBtn.MouseButton1Click:Connect(function()
        settings.uiScale = 1.3
        grossBtn.BackgroundColor3 = Constants.COLORS.ACCENT
        normalBtn.BackgroundColor3 = Constants.COLORS.PRIMARY
        self:_applyUIScale()
    end)

    UIController:RegisterPanel("settings", settingsFrame)
end

---------------------------------------------------------------------------
-- Create a toggle row
---------------------------------------------------------------------------
function SettingsUI:_createToggle(parent: Frame, label: string, settingKey: string, yPos: number): number
    local row = Instance.new("Frame")
    row.Name = "Toggle_" .. settingKey
    row.Size = UDim2.new(1, -30, 0, 50)
    row.Position = UDim2.new(0, 15, 0, yPos)
    row.BackgroundColor3 = Constants.COLORS.DARK
    row.BorderSizePixel = 0
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    -- Label
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.6, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 15, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Constants.COLORS.WHITE
    textLabel.Font = Constants.FONTS.BODY
    textLabel.TextSize = 22
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Text = label
    textLabel.Parent = row

    -- Toggle button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 80, 0, 36)
    toggleBtn.Position = UDim2.new(1, -95, 0.5, -18)
    toggleBtn.BackgroundColor3 = settings[settingKey] and Constants.COLORS.ACCENT or Constants.COLORS.DISABLED
    toggleBtn.TextColor3 = Constants.COLORS.WHITE
    toggleBtn.Font = Constants.FONTS.BUTTON
    toggleBtn.TextSize = 18
    toggleBtn.Text = settings[settingKey] and "AN" or "AUS"
    toggleBtn.BorderSizePixel = 0
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = row

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn

    toggleBtn.MouseButton1Click:Connect(function()
        settings[settingKey] = not settings[settingKey]
        toggleBtn.Text = settings[settingKey] and "AN" or "AUS"

        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = settings[settingKey] and Constants.COLORS.ACCENT or Constants.COLORS.DISABLED,
        }):Play()

        self:_applySetting(settingKey)
    end)

    return yPos + 58
end

---------------------------------------------------------------------------
-- Apply a setting change
---------------------------------------------------------------------------
function SettingsUI:_applySetting(key: string)
    if key == "soundEnabled" then
        -- Mute/unmute SFX
        for _, sound in SoundService:GetChildren() do
            if sound:IsA("Sound") and sound.Name:match("^SFX_") then
                sound.Volume = settings.soundEnabled and 0.5 or 0
            end
        end
    elseif key == "musicEnabled" then
        -- Mute/unmute ambient music
        for _, sound in SoundService:GetChildren() do
            if sound:IsA("Sound") and sound.Name:match("^Ambient_") then
                sound.Volume = settings.musicEnabled and 0.3 or 0
            end
        end
    elseif key == "voiceEnabled" then
        -- Voice narration toggle (TutorialController reads this)
        -- No immediate action needed
    end
end

---------------------------------------------------------------------------
-- Apply UI scale
---------------------------------------------------------------------------
function SettingsUI:_applyUIScale()
    local screenGui = UIController:GetScreenGui()
    if not screenGui then return end

    -- Scale all text elements
    for _, descendant in screenGui:GetDescendants() do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
            local baseSize = descendant:GetAttribute("BaseTextSize")
            if not baseSize then
                descendant:SetAttribute("BaseTextSize", descendant.TextSize)
                baseSize = descendant.TextSize
            end
            descendant.TextSize = math.floor(baseSize * settings.uiScale)
        end
    end
end

---------------------------------------------------------------------------
-- Connect events
---------------------------------------------------------------------------
function SettingsUI:_connectEvents()
    -- ESC key or P key toggles settings
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.P then
            UIController:TogglePanel("settings")
        end
    end)
end

return SettingsUI
