--!strict
--[[
    HUD.lua
    Heads-Up Display: Health bar, Oxygen bar, Hunger bar, Hotbar.
    Always visible during gameplay. sgit.space themed.

    Note: This is a ModuleScript parented under StarterGui/SpaceStationUI.
    It is required by the client bootstrap to set up the HUD.
    The actual ScreenGui is created by UIController.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))

local HUD = {}
HUD.__index = HUD

local player: Player = nil
local Remotes = nil

-- UI references
local hudFrame: Frame = nil
local healthBar: Frame = nil
local oxygenBar: Frame = nil
local hungerBar: Frame = nil
local hotbarFrame: Frame = nil
local hotbarSlots: { Frame } = {}

---------------------------------------------------------------------------
-- Init (called manually from client bootstrap after UIController)
---------------------------------------------------------------------------
function HUD.Setup(screenGui: ScreenGui, plr: Player, remotes: any)
    player = plr
    Remotes = remotes
    HUD:_buildHUD(screenGui)
    HUD:_connectEvents()
    print("[HUD] Ready")
end

---------------------------------------------------------------------------
-- Build HUD layout
---------------------------------------------------------------------------
function HUD:_buildHUD(screenGui: ScreenGui)
    -- Top-left: Status bars
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusBars"
    statusFrame.Size = UDim2.new(0, 220, 0, 110)
    statusFrame.Position = UDim2.new(0, 15, 0, 15)
    statusFrame.BackgroundColor3 = Constants.COLORS.SURFACE
    statusFrame.BackgroundTransparency = 0.3
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = screenGui

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = Constants.UI.CORNER_RADIUS
    statusCorner.Parent = statusFrame

    local statusStroke = Instance.new("UIStroke")
    statusStroke.Color = Constants.COLORS.ACCENT
    statusStroke.Thickness = 1
    statusStroke.Transparency = 0.5
    statusStroke.Parent = statusFrame

    -- Health bar
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthLabel"
    healthLabel.Size = UDim2.new(0, 30, 0, 20)
    healthLabel.Position = UDim2.new(0, 10, 0, 10)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Constants.COLORS.GLOW
    healthLabel.Font = Constants.FONTS.BUTTON
    healthLabel.TextSize = 18
    healthLabel.Text = "HP"
    healthLabel.Parent = statusFrame

    healthBar = HUD._createBar(statusFrame, "HealthBar",
        UDim2.new(0, 160, 0, 18),
        UDim2.new(0, 45, 0, 11),
        Constants.COLORS.ACCENT
    )

    -- Oxygen bar
    local o2Label = Instance.new("TextLabel")
    o2Label.Name = "O2Label"
    o2Label.Size = UDim2.new(0, 30, 0, 20)
    o2Label.Position = UDim2.new(0, 10, 0, 42)
    o2Label.BackgroundTransparency = 1
    o2Label.TextColor3 = Color3.fromHex("4da6ff")
    o2Label.Font = Constants.FONTS.BUTTON
    o2Label.TextSize = 18
    o2Label.Text = "O2"
    o2Label.Parent = statusFrame

    oxygenBar = HUD._createBar(statusFrame, "OxygenBar",
        UDim2.new(0, 160, 0, 18),
        UDim2.new(0, 45, 0, 43),
        Color3.fromHex("4da6ff")
    )

    -- Hunger bar
    local hungerLabel = Instance.new("TextLabel")
    hungerLabel.Name = "HungerLabel"
    hungerLabel.Size = UDim2.new(0, 30, 0, 20)
    hungerLabel.Position = UDim2.new(0, 10, 0, 74)
    hungerLabel.BackgroundTransparency = 1
    hungerLabel.TextColor3 = Constants.COLORS.WARNING
    hungerLabel.Font = Constants.FONTS.BUTTON
    hungerLabel.TextSize = 18
    hungerLabel.Text = "FD"
    hungerLabel.Parent = statusFrame

    hungerBar = HUD._createBar(statusFrame, "HungerBar",
        UDim2.new(0, 160, 0, 18),
        UDim2.new(0, 45, 0, 75),
        Constants.COLORS.WARNING
    )

    -- Bottom center: Hotbar
    hotbarFrame = Instance.new("Frame")
    hotbarFrame.Name = "Hotbar"
    hotbarFrame.Size = UDim2.new(0, 400, 0, 72)
    hotbarFrame.Position = UDim2.new(0.5, -200, 1, -85)
    hotbarFrame.BackgroundColor3 = Constants.COLORS.SURFACE
    hotbarFrame.BackgroundTransparency = 0.3
    hotbarFrame.BorderSizePixel = 0
    hotbarFrame.Parent = screenGui

    local hotbarCorner = Instance.new("UICorner")
    hotbarCorner.CornerRadius = Constants.UI.CORNER_RADIUS
    hotbarCorner.Parent = hotbarFrame

    local hotbarStroke = Instance.new("UIStroke")
    hotbarStroke.Color = Constants.COLORS.ACCENT
    hotbarStroke.Thickness = 1
    hotbarStroke.Transparency = 0.5
    hotbarStroke.Parent = hotbarFrame

    local hotbarLayout = Instance.new("UIListLayout")
    hotbarLayout.FillDirection = Enum.FillDirection.Horizontal
    hotbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    hotbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    hotbarLayout.Padding = UDim.new(0, 8)
    hotbarLayout.Parent = hotbarFrame

    -- Create 5 hotbar slots
    for i = 1, Constants.INVENTORY.HOTBAR_SLOTS do
        local slot = Instance.new("Frame")
        slot.Name = "HotbarSlot_" .. i
        slot.Size = UDim2.new(0, 60, 0, 60)
        slot.BackgroundColor3 = Constants.COLORS.DARK
        slot.BorderSizePixel = 0
        slot.LayoutOrder = i
        slot.Parent = hotbarFrame

        local slotCorner = Instance.new("UICorner")
        slotCorner.CornerRadius = UDim.new(0, 8)
        slotCorner.Parent = slot

        local slotStroke = Instance.new("UIStroke")
        slotStroke.Color = Constants.COLORS.PRIMARY
        slotStroke.Thickness = 2
        slotStroke.Parent = slot

        -- Slot number
        local numLabel = Instance.new("TextLabel")
        numLabel.Name = "Number"
        numLabel.Size = UDim2.new(0, 18, 0, 18)
        numLabel.Position = UDim2.new(0, 2, 0, 2)
        numLabel.BackgroundTransparency = 1
        numLabel.TextColor3 = Constants.COLORS.DISABLED
        numLabel.Font = Constants.FONTS.MONO
        numLabel.TextSize = 12
        numLabel.Text = tostring(i)
        numLabel.Parent = slot

        -- Item icon
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0.7, 0, 0.7, 0)
        icon.Position = UDim2.new(0.15, 0, 0.1, 0)
        icon.BackgroundTransparency = 1
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Image = ""
        icon.Parent = slot

        table.insert(hotbarSlots, slot)
    end

    hudFrame = statusFrame
end

---------------------------------------------------------------------------
-- Create a status bar
---------------------------------------------------------------------------
function HUD._createBar(parent: Frame, name: string, size: UDim2, position: UDim2, color: Color3): Frame
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
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.Parent = bg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fill

    return bg
end

---------------------------------------------------------------------------
-- Update a bar's fill
---------------------------------------------------------------------------
function HUD._setBar(bar: Frame, current: number, max: number)
    local fill = bar:FindFirstChild("Fill") :: Frame?
    if fill then
        local pct = math.clamp(current / max, 0, 1)
        TweenService:Create(fill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(pct, 0, 1, 0),
        }):Play()

        -- Change color to warning when low
        if pct < 0.25 then
            TweenService:Create(fill, TweenInfo.new(0.3), {
                BackgroundColor3 = Constants.COLORS.WARNING,
            }):Play()
        end
    end
end

---------------------------------------------------------------------------
-- Connect events
---------------------------------------------------------------------------
function HUD:_connectEvents()
    -- Stats updates from server
    local StatsUpdated = Remotes:WaitForChild("StatsUpdated") :: RemoteEvent
    StatsUpdated.OnClientEvent:Connect(function(stats: any)
        if stats.health then
            HUD._setBar(healthBar, stats.health, Constants.PLAYER.MAX_HEALTH)
        end
        if stats.oxygen then
            HUD._setBar(oxygenBar, stats.oxygen, Constants.PLAYER.MAX_OXYGEN)
        end
        if stats.hunger then
            HUD._setBar(hungerBar, stats.hunger, Constants.PLAYER.MAX_HUNGER)
        end
    end)
end

return HUD
