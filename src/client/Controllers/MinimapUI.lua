--!strict
--[[
    MinimapUI.lua
    Simple minimap in top-right corner showing player position
    and nearby points of interest (resources, landing pad).
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))

local MinimapUI = {}
MinimapUI.__index = MinimapUI

local player: Player = nil
local UIController = nil

local minimapFrame: Frame = nil
local playerDot: Frame = nil
local mapRadius = 80 -- Pixels
local worldRadius = 200 -- Studs visible on minimap

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function MinimapUI:Init(plr: Player, _remotes: any)
    player = plr
    local Controllers = script.Parent
    UIController = require(Controllers:WaitForChild("UIController"))
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------
function MinimapUI:Start()
    local screenGui = UIController:GetScreenGui()
    self:_buildUI(screenGui)
    self:_startUpdateLoop()
    print("[MinimapUI] Ready")
end

---------------------------------------------------------------------------
-- Build minimap
---------------------------------------------------------------------------
function MinimapUI:_buildUI(screenGui: ScreenGui)
    -- Circular minimap background
    minimapFrame = Instance.new("Frame")
    minimapFrame.Name = "Minimap"
    minimapFrame.Size = UDim2.new(0, mapRadius * 2, 0, mapRadius * 2)
    minimapFrame.Position = UDim2.new(1, -(mapRadius * 2) - 15, 0, 15)
    minimapFrame.BackgroundColor3 = Constants.COLORS.DARK
    minimapFrame.BackgroundTransparency = 0.3
    minimapFrame.BorderSizePixel = 0
    minimapFrame.ClipsDescendants = true
    minimapFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0) -- Full circle
    corner.Parent = minimapFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Constants.COLORS.ACCENT
    stroke.Thickness = 2
    stroke.Parent = minimapFrame

    -- Player dot (always center)
    playerDot = Instance.new("Frame")
    playerDot.Name = "PlayerDot"
    playerDot.Size = UDim2.new(0, 10, 0, 10)
    playerDot.Position = UDim2.new(0.5, -5, 0.5, -5)
    playerDot.BackgroundColor3 = Constants.COLORS.GLOW
    playerDot.BorderSizePixel = 0
    playerDot.ZIndex = 10
    playerDot.Parent = minimapFrame

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0.5, 0)
    dotCorner.Parent = playerDot

    -- Direction indicator (small triangle above player dot)
    local dirIndicator = Instance.new("Frame")
    dirIndicator.Name = "Direction"
    dirIndicator.Size = UDim2.new(0, 4, 0, 8)
    dirIndicator.Position = UDim2.new(0.5, -2, 0.5, -12)
    dirIndicator.BackgroundColor3 = Constants.COLORS.WHITE
    dirIndicator.BorderSizePixel = 0
    dirIndicator.ZIndex = 10
    dirIndicator.Parent = minimapFrame

    -- Compass labels
    local compassData = {
        { text = "N", pos = UDim2.new(0.5, -6, 0, 5) },
        { text = "S", pos = UDim2.new(0.5, -5, 1, -20) },
        { text = "W", pos = UDim2.new(0, 5, 0.5, -8) },
        { text = "O", pos = UDim2.new(1, -18, 0.5, -8) },
    }

    for _, compass in compassData do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 15, 0, 15)
        label.Position = compass.pos
        label.BackgroundTransparency = 1
        label.TextColor3 = Constants.COLORS.DISABLED
        label.Font = Constants.FONTS.MONO
        label.TextSize = 12
        label.Text = compass.text
        label.ZIndex = 5
        label.Parent = minimapFrame
    end
end

---------------------------------------------------------------------------
-- Update loop: Show nearby objects on minimap
---------------------------------------------------------------------------
function MinimapUI:_startUpdateLoop()
    RunService.Heartbeat:Connect(function()
        local character = player.Character
        if not character then return end

        local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not root then return end

        local playerPos = root.Position
        local playerLook = root.CFrame.LookVector

        -- Clear old dots (except player dot, direction, compass)
        for _, child in minimapFrame:GetChildren() do
            if child:IsA("Frame") and child.Name ~= "PlayerDot" and child.Name ~= "Direction" then
                if child:GetAttribute("MapDot") then
                    child:Destroy()
                end
            end
        end

        -- Show nearby resource nodes
        local planetsFolder = workspace:FindFirstChild("Planets")
        if planetsFolder then
            for _, planetFolder in planetsFolder:GetChildren() do
                local spawns = planetFolder:FindFirstChild("ResourceSpawns")
                if spawns then
                    for _, spawn in spawns:GetChildren() do
                        if spawn:IsA("BasePart") and spawn.Transparency < 1 then
                            self:_addDotForObject(spawn, playerPos, Color3.fromHex("ffdd44"), 6)
                        end
                    end
                end

                -- Show landing pad
                local pad = planetFolder:FindFirstChild("LandingPad")
                if pad and pad:IsA("BasePart") then
                    self:_addDotForObject(pad, playerPos, Constants.COLORS.ACCENT, 8)
                end
            end
        end

        -- Show station pad
        local stationFolder = workspace:FindFirstChild("Station")
        if stationFolder then
            local stationPad = stationFolder:FindFirstChild("LandingPad")
            if stationPad and stationPad:IsA("BasePart") then
                self:_addDotForObject(stationPad, playerPos, Constants.COLORS.GLOW, 8)
            end
        end

        -- Show other players
        for _, otherPlayer in Players:GetPlayers() do
            if otherPlayer ~= player then
                local otherChar = otherPlayer.Character
                if otherChar then
                    local otherRoot = otherChar:FindFirstChild("HumanoidRootPart") :: BasePart?
                    if otherRoot then
                        self:_addDotForObject(otherRoot, playerPos, Color3.fromHex("44aaff"), 7)
                    end
                end
            end
        end
    end)
end

---------------------------------------------------------------------------
-- Add a dot on the minimap for a world object
---------------------------------------------------------------------------
function MinimapUI:_addDotForObject(obj: BasePart, playerPos: Vector3, color: Color3, size: number)
    local objPos = obj.Position
    local offset = objPos - playerPos
    local dist2D = Vector2.new(offset.X, offset.Z).Magnitude

    if dist2D > worldRadius then return end

    -- Convert world offset to minimap pixel offset
    local pixelX = (offset.X / worldRadius) * mapRadius
    local pixelY = (offset.Z / worldRadius) * mapRadius

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, size, 0, size)
    dot.Position = UDim2.new(0.5, pixelX - size / 2, 0.5, pixelY - size / 2)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.ZIndex = 3
    dot:SetAttribute("MapDot", true)
    dot.Parent = minimapFrame

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0.5, 0)
    dotCorner.Parent = dot
end

return MinimapUI
