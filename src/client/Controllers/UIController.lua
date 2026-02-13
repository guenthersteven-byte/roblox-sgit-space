--!strict
--[[
    UIController.lua
    Central UI management. Creates the main ScreenGui and provides
    helper functions for creating sgit-themed UI elements.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage:WaitForChild("Constants"))

local UIController = {}
UIController.__index = UIController

local player: Player = nil
local screenGui: ScreenGui = nil
local panels: { [string]: Frame } = {}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function UIController:Init(plr: Player, _remotes: any)
    player = plr

    -- Create main ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpaceStationUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = player:WaitForChild("PlayerGui")

    print("[UIController] ScreenGui created")
end

function UIController:Start()
    -- Nothing to start yet
end

---------------------------------------------------------------------------
-- Get the main ScreenGui
---------------------------------------------------------------------------
function UIController:GetScreenGui(): ScreenGui
    return screenGui
end

---------------------------------------------------------------------------
-- Register a panel (for toggle management)
---------------------------------------------------------------------------
function UIController:RegisterPanel(name: string, frame: Frame)
    panels[name] = frame
end

---------------------------------------------------------------------------
-- Toggle a panel visibility (close others)
---------------------------------------------------------------------------
function UIController:TogglePanel(name: string)
    for panelName, frame in panels do
        if panelName == name then
            frame.Visible = not frame.Visible
        else
            frame.Visible = false
        end
    end
end

---------------------------------------------------------------------------
-- Close all panels
---------------------------------------------------------------------------
function UIController:CloseAllPanels()
    for _, frame in panels do
        frame.Visible = false
    end
end

---------------------------------------------------------------------------
-- UI Factory: Create themed frame
---------------------------------------------------------------------------
function UIController.CreateFrame(parent: Instance, name: string, size: UDim2, position: UDim2): Frame
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Constants.COLORS.SURFACE
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Constants.UI.CORNER_RADIUS
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Constants.COLORS.ACCENT
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = frame

    return frame
end

---------------------------------------------------------------------------
-- UI Factory: Create themed button
---------------------------------------------------------------------------
function UIController.CreateButton(parent: Instance, name: string, text: string, size: UDim2, position: UDim2): TextButton
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Constants.COLORS.ACCENT
    button.TextColor3 = Constants.COLORS.WHITE
    button.Font = Constants.FONTS.BUTTON
    button.TextSize = Constants.UI.TEXT_SIZE_MEDIUM
    button.Text = text
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Constants.UI.CORNER_RADIUS
    corner.Parent = button

    -- Hover/click animations
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            Size = UDim2.new(size.X.Scale * 1.05, size.X.Offset, size.Y.Scale * 1.05, size.Y.Offset),
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            Size = size,
        }):Play()
    end)

    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(size.X.Scale * 0.95, size.X.Offset, size.Y.Scale * 0.95, size.Y.Offset),
        }):Play()
    end)

    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = size,
        }):Play()
    end)

    return button
end

---------------------------------------------------------------------------
-- UI Factory: Create themed label
---------------------------------------------------------------------------
function UIController.CreateLabel(parent: Instance, name: string, text: string, size: UDim2, position: UDim2): TextLabel
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.TextColor3 = Constants.COLORS.WHITE
    label.Font = Constants.FONTS.BODY
    label.TextSize = Constants.UI.TEXT_SIZE_MEDIUM
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    return label
end

---------------------------------------------------------------------------
-- UI Factory: Create progress bar
---------------------------------------------------------------------------
function UIController.CreateProgressBar(parent: Instance, name: string, size: UDim2, position: UDim2, color: Color3?): Frame
    local bg = Instance.new("Frame")
    bg.Name = name
    bg.Size = size
    bg.Position = position
    bg.BackgroundColor3 = Constants.COLORS.DARK
    bg.BorderSizePixel = 0
    bg.Parent = parent

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 6)
    bgCorner.Parent = bg

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = color or Constants.COLORS.ACCENT
    fill.BorderSizePixel = 0
    fill.Parent = bg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fill

    return bg
end

---------------------------------------------------------------------------
-- Animate progress bar fill
---------------------------------------------------------------------------
function UIController.SetProgressBar(bar: Frame, percentage: number)
    local fill = bar:FindFirstChild("Fill") :: Frame?
    if fill then
        TweenService:Create(fill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(math.clamp(percentage, 0, 1), 0, 1, 0),
        }):Play()
    end
end

return UIController
