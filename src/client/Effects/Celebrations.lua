--!strict
--[[
    Celebrations.lua
    Visual celebration effects for achievements.
    Different intensity levels for different events.
    Green-themed (sgit branding).
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))

local Celebrations = {}
Celebrations.__index = Celebrations

local player: Player = nil
local screenGui: ScreenGui? = nil

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function Celebrations:Init(plr: Player)
    player = plr
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------
function Celebrations:Start()
    -- Get reference to ScreenGui (created by UIController)
    local playerGui = player:WaitForChild("PlayerGui")
    screenGui = playerGui:FindFirstChild("SpaceStationUI") :: ScreenGui?
    print("[Celebrations] Ready")
end

---------------------------------------------------------------------------
-- Play celebration by type
---------------------------------------------------------------------------
function Celebrations:Play(celebType: string, data: any?)
    if celebType == "item_collected" then
        self:_smallSparkle()
    elseif celebType == "item_crafted" then
        self:_mediumConfetti()
        self:_showMessage("Gecraftet!")
    elseif celebType == "quest_completed" then
        self:_bigCelebration()
        self:_showMessage("Quest geschafft!")
    elseif celebType == "alien_tamed" then
        self:_heartBurst()
        self:_showMessage("Neuer Freund!")
    elseif celebType == "room_built" then
        self:_mediumConfetti()
        self:_showMessage("Raum gebaut!")
    elseif celebType == "planet_unlocked" then
        self:_bigCelebration()
        if data and data.planetName then
            self:_showMessage(data.planetName .. " entdeckt!")
        end
    elseif celebType == "shuttle_launch" then
        -- Handled by ShuttleUI loading screen
    end
end

---------------------------------------------------------------------------
-- Small sparkle (item collect)
---------------------------------------------------------------------------
function Celebrations:_smallSparkle()
    if not screenGui then return end

    for _ = 1, 5 do
        task.spawn(function()
            local sparkle = Instance.new("Frame")
            sparkle.Size = UDim2.new(0, 8, 0, 8)
            sparkle.Position = UDim2.new(
                0.5 + (math.random() - 0.5) * 0.3,
                0,
                0.5 + (math.random() - 0.5) * 0.3,
                0
            )
            sparkle.BackgroundColor3 = Constants.COLORS.GLOW
            sparkle.BorderSizePixel = 0
            sparkle.ZIndex = 50
            sparkle.Parent = screenGui

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0.5, 0)
            corner.Parent = sparkle

            -- Animate up and fade
            TweenService:Create(sparkle, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = sparkle.Position + UDim2.new(0, 0, -0.1, 0),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 2, 0, 2),
            }):Play()

            task.wait(0.8)
            sparkle:Destroy()
        end)
    end
end

---------------------------------------------------------------------------
-- Medium confetti (crafting, building)
---------------------------------------------------------------------------
function Celebrations:_mediumConfetti()
    if not screenGui then return end

    local colors = {
        Constants.COLORS.ACCENT,
        Constants.COLORS.GLOW,
        Color3.fromHex("ffffff"),
        Color3.fromHex("88ff88"),
    }

    for _ = 1, 15 do
        task.spawn(function()
            local confetti = Instance.new("Frame")
            local startX = math.random() * 1
            confetti.Size = UDim2.new(0, math.random(6, 12), 0, math.random(6, 12))
            confetti.Position = UDim2.new(startX, 0, -0.05, 0)
            confetti.BackgroundColor3 = colors[math.random(1, #colors)]
            confetti.BorderSizePixel = 0
            confetti.Rotation = math.random(0, 360)
            confetti.ZIndex = 50
            confetti.Parent = screenGui

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 3)
            corner.Parent = confetti

            -- Fall down
            local duration = 1 + math.random() * 1.5
            TweenService:Create(confetti, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(startX + (math.random() - 0.5) * 0.3, 0, 1.1, 0),
                Rotation = math.random(-360, 360),
                BackgroundTransparency = 0.5,
            }):Play()

            task.wait(duration)
            confetti:Destroy()
        end)
    end
end

---------------------------------------------------------------------------
-- Big celebration (quest complete, planet unlocked)
---------------------------------------------------------------------------
function Celebrations:_bigCelebration()
    -- Multiple rounds of confetti
    for round = 1, 3 do
        task.delay((round - 1) * 0.3, function()
            self:_mediumConfetti()
        end)
    end

    -- Screen flash
    if screenGui then
        local flash = Instance.new("Frame")
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = Constants.COLORS.GLOW
        flash.BackgroundTransparency = 0.7
        flash.ZIndex = 40
        flash.Parent = screenGui

        TweenService:Create(flash, TweenInfo.new(0.5), {
            BackgroundTransparency = 1,
        }):Play()

        task.delay(0.5, function()
            flash:Destroy()
        end)
    end
end

---------------------------------------------------------------------------
-- Heart burst (alien tamed)
---------------------------------------------------------------------------
function Celebrations:_heartBurst()
    if not screenGui then return end

    for _ = 1, 8 do
        task.spawn(function()
            local heart = Instance.new("TextLabel")
            heart.Size = UDim2.new(0, 30, 0, 30)
            heart.Position = UDim2.new(
                0.5 + (math.random() - 0.5) * 0.4,
                0,
                0.5 + (math.random() - 0.5) * 0.2,
                0
            )
            heart.BackgroundTransparency = 1
            heart.TextColor3 = Color3.fromHex("ff6688")
            heart.Font = Enum.Font.GothamBold
            heart.TextSize = math.random(20, 40)
            heart.Text = "<3"
            heart.ZIndex = 50
            heart.Parent = screenGui

            TweenService:Create(heart, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = heart.Position + UDim2.new(0, 0, -0.15, 0),
                TextTransparency = 1,
                TextSize = heart.TextSize + 10,
            }):Play()

            task.wait(1.5)
            heart:Destroy()
        end)
    end
end

---------------------------------------------------------------------------
-- Show floating message
---------------------------------------------------------------------------
function Celebrations:_showMessage(text: string)
    if not screenGui then return end

    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(0, 400, 0, 60)
    message.Position = UDim2.new(0.5, -200, 0.35, 0)
    message.BackgroundTransparency = 1
    message.TextColor3 = Constants.COLORS.GLOW
    message.TextStrokeColor3 = Constants.COLORS.DARK
    message.TextStrokeTransparency = 0.3
    message.Font = Constants.FONTS.HEADING
    message.TextSize = 36
    message.Text = text
    message.ZIndex = 55
    message.Parent = screenGui

    -- Animate: scale up, then fade out
    message.TextTransparency = 1
    TweenService:Create(message, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        TextTransparency = 0,
    }):Play()

    task.wait(1.5)

    TweenService:Create(message, TweenInfo.new(0.5), {
        TextTransparency = 1,
        Position = message.Position + UDim2.new(0, 0, -0.05, 0),
    }):Play()

    task.wait(0.5)
    message:Destroy()
end

return Celebrations
