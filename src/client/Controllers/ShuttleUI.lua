--!strict
--[[
    ShuttleUI.lua
    Planet selection interface when interacting with shuttle console.
    Shows planet cards with name, theme, lock status.
    Big colorful buttons for kids.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Planets = require(ReplicatedStorage:WaitForChild("Planets"))

local ShuttleUI = {}
ShuttleUI.__index = ShuttleUI

local player: Player = nil
local Remotes = nil
local UIController = nil

local shuttleFrame: Frame = nil
local planetCards: { Frame } = {}
local unlockedPlanets: { string } = { "verdania" }
local loadingOverlay: Frame = nil

-- Planet theme colors for cards
local THEME_COLORS = {
    jungle = Color3.fromHex("2a6b1a"),
    ice = Color3.fromHex("1a4a6b"),
    mushroom = Color3.fromHex("4a1a6b"),
    volcano = Color3.fromHex("6b2a1a"),
}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function ShuttleUI:Init(plr: Player, remotes: any)
    player = plr
    Remotes = remotes
    local Controllers = script.Parent
    UIController = require(Controllers:WaitForChild("UIController"))
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------
function ShuttleUI:Start()
    local screenGui = UIController:GetScreenGui()
    self:_buildUI(screenGui)
    self:_buildLoadingOverlay(screenGui)
    self:_connectEvents()
    print("[ShuttleUI] Ready")
end

---------------------------------------------------------------------------
-- Full sync
---------------------------------------------------------------------------
function ShuttleUI:OnFullSync(data: any)
    if data and data.unlockedPlanets then
        unlockedPlanets = data.unlockedPlanets
    end
end

---------------------------------------------------------------------------
-- Build planet selection UI
---------------------------------------------------------------------------
function ShuttleUI:_buildUI(screenGui: ScreenGui)
    shuttleFrame = UIController.CreateFrame(
        screenGui,
        "ShuttlePanel",
        UDim2.new(0, 500, 0, 420),
        UDim2.new(0.5, -250, 0.5, -210)
    )
    shuttleFrame.Visible = false

    -- Title
    local title = UIController.CreateLabel(
        shuttleFrame,
        "Title",
        "Shuttle - Planetenauswahl",
        UDim2.new(1, -20, 0, 40),
        UDim2.new(0, 10, 0, 5)
    )
    title.Font = Constants.FONTS.HEADING
    title.TextSize = Constants.UI.TEXT_SIZE_LARGE
    title.TextXAlignment = Enum.TextXAlignment.Center

    -- Close button
    local closeBtn = UIController.CreateButton(
        shuttleFrame,
        "CloseBtn",
        "X",
        UDim2.new(0, 40, 0, 40),
        UDim2.new(1, -45, 0, 5)
    )
    closeBtn.BackgroundColor3 = Constants.COLORS.PRIMARY
    closeBtn.MouseButton1Click:Connect(function()
        shuttleFrame.Visible = false
    end)

    -- Planet list container
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Name = "PlanetList"
    listFrame.Size = UDim2.new(1, -20, 1, -60)
    listFrame.Position = UDim2.new(0, 10, 0, 50)
    listFrame.BackgroundTransparency = 1
    listFrame.ScrollBarThickness = 6
    listFrame.ScrollBarImageColor3 = Constants.COLORS.ACCENT
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFrame.Parent = shuttleFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = listFrame

    -- Return to station button
    local returnCard = self:_createStationCard(listFrame)
    returnCard.LayoutOrder = 0

    -- Create planet cards
    for i, planetDef in Planets.getAll() do
        local card = self:_createPlanetCard(listFrame, planetDef)
        card.LayoutOrder = i
        table.insert(planetCards, card)
    end

    UIController:RegisterPanel("shuttle", shuttleFrame)
end

---------------------------------------------------------------------------
-- Create station return card
---------------------------------------------------------------------------
function ShuttleUI:_createStationCard(parent: Instance): Frame
    local card = Instance.new("Frame")
    card.Name = "StationCard"
    card.Size = UDim2.new(1, -10, 0, 70)
    card.BackgroundColor3 = Constants.COLORS.PRIMARY
    card.BorderSizePixel = 0
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card

    -- Station name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.6, 0, 0, 30)
    nameLabel.Position = UDim2.new(0, 15, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Constants.COLORS.GLOW
    nameLabel.Font = Constants.FONTS.HEADING
    nameLabel.TextSize = Constants.UI.TEXT_SIZE_MEDIUM
    nameLabel.Text = "sgit Station Alpha"
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.6, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 15, 0, 40)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = Constants.COLORS.WHITE
    descLabel.Font = Constants.FONTS.BODY
    descLabel.TextSize = Constants.UI.TEXT_SIZE_SMALL
    descLabel.Text = "Zurueck zur Raumstation"
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = card

    -- Travel button
    local travelBtn = UIController.CreateButton(
        card, "TravelBtn", "Fliegen!",
        UDim2.new(0, 100, 0, 40),
        UDim2.new(1, -115, 0.5, -20)
    )

    travelBtn.MouseButton1Click:Connect(function()
        shuttleFrame.Visible = false
        local RequestShuttle = Remotes:FindFirstChild("RequestShuttle") :: RemoteEvent?
        if RequestShuttle then
            RequestShuttle:FireServer("station")
        end
    end)

    return card
end

---------------------------------------------------------------------------
-- Create planet card
---------------------------------------------------------------------------
function ShuttleUI:_createPlanetCard(parent: Instance, planetDef: any): Frame
    local isUnlocked = self:_isPlanetUnlocked(planetDef.id)
    local themeColor = THEME_COLORS[planetDef.theme] or Constants.COLORS.PRIMARY

    local card = Instance.new("Frame")
    card.Name = "Planet_" .. planetDef.id
    card.Size = UDim2.new(1, -10, 0, 80)
    card.BackgroundColor3 = isUnlocked and themeColor or Constants.COLORS.DARK
    card.BorderSizePixel = 0
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card

    -- Planet name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.6, 0, 0, 30)
    nameLabel.Position = UDim2.new(0, 15, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = isUnlocked and Constants.COLORS.WHITE or Constants.COLORS.DISABLED
    nameLabel.Font = Constants.FONTS.HEADING
    nameLabel.TextSize = Constants.UI.TEXT_SIZE_MEDIUM
    nameLabel.Text = isUnlocked and planetDef.name or "??? (Gesperrt)"
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card

    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.6, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 15, 0, 40)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = isUnlocked and Constants.COLORS.WHITE or Constants.COLORS.DISABLED
    descLabel.Font = Constants.FONTS.BODY
    descLabel.TextSize = Constants.UI.TEXT_SIZE_SMALL
    descLabel.Text = isUnlocked and planetDef.description or "Schliesse Quests ab um freizuschalten"
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextTruncate = Enum.TextTruncate.AtEnd
    descLabel.Parent = card

    -- Travel button (only if unlocked)
    if isUnlocked then
        local travelBtn = UIController.CreateButton(
            card, "TravelBtn", "Fliegen!",
            UDim2.new(0, 100, 0, 40),
            UDim2.new(1, -115, 0.5, -20)
        )

        travelBtn.MouseButton1Click:Connect(function()
            shuttleFrame.Visible = false
            local RequestShuttle = Remotes:FindFirstChild("RequestShuttle") :: RemoteEvent?
            if RequestShuttle then
                RequestShuttle:FireServer(planetDef.id)
            end
        end)
    else
        -- Lock icon
        local lockLabel = Instance.new("TextLabel")
        lockLabel.Size = UDim2.new(0, 50, 0, 50)
        lockLabel.Position = UDim2.new(1, -65, 0.5, -25)
        lockLabel.BackgroundTransparency = 1
        lockLabel.TextColor3 = Constants.COLORS.DISABLED
        lockLabel.Font = Constants.FONTS.HEADING
        lockLabel.TextSize = 36
        lockLabel.Text = "?"
        lockLabel.Parent = card
    end

    return card
end

---------------------------------------------------------------------------
-- Build loading overlay (shuttle flight animation)
---------------------------------------------------------------------------
function ShuttleUI:_buildLoadingOverlay(screenGui: ScreenGui)
    loadingOverlay = Instance.new("Frame")
    loadingOverlay.Name = "ShuttleLoading"
    loadingOverlay.Size = UDim2.new(1, 0, 1, 0)
    loadingOverlay.Position = UDim2.new(0, 0, 0, 0)
    loadingOverlay.BackgroundColor3 = Constants.COLORS.DARK
    loadingOverlay.BackgroundTransparency = 1
    loadingOverlay.ZIndex = 100
    loadingOverlay.Visible = false
    loadingOverlay.Parent = screenGui

    local loadingText = Instance.new("TextLabel")
    loadingText.Name = "LoadingText"
    loadingText.Size = UDim2.new(1, 0, 0, 60)
    loadingText.Position = UDim2.new(0, 0, 0.5, -30)
    loadingText.BackgroundTransparency = 1
    loadingText.TextColor3 = Constants.COLORS.GLOW
    loadingText.Font = Constants.FONTS.HEADING
    loadingText.TextSize = 36
    loadingText.Text = "Shuttle startet..."
    loadingText.ZIndex = 101
    loadingText.Parent = loadingOverlay
end

---------------------------------------------------------------------------
-- Show/hide loading overlay
---------------------------------------------------------------------------
function ShuttleUI:_showLoading(destination: string)
    if not loadingOverlay then return end

    local text = loadingOverlay:FindFirstChild("LoadingText") :: TextLabel?
    local arrivalText = loadingOverlay:FindFirstChild("ArrivalText") :: TextLabel?

    -- Create arrival text if it doesn't exist
    if not arrivalText then
        arrivalText = Instance.new("TextLabel")
        arrivalText.Name = "ArrivalText"
        arrivalText.Size = UDim2.new(1, 0, 0, 80)
        arrivalText.Position = UDim2.new(0, 0, 0.35, 0)
        arrivalText.BackgroundTransparency = 1
        arrivalText.TextColor3 = Constants.COLORS.WHITE
        arrivalText.Font = Constants.FONTS.HEADING
        arrivalText.TextSize = 48
        arrivalText.Text = ""
        arrivalText.TextTransparency = 1
        arrivalText.ZIndex = 101
        arrivalText.Parent = loadingOverlay
    end

    -- Set flight text
    local planetName = ""
    if text then
        if destination == "station" then
            text.Text = "Flug zur Station..."
            planetName = "sgit Station Alpha"
        else
            local planetDef = Planets.get(destination)
            planetName = planetDef and planetDef.name or destination
            text.Text = "Flug zu " .. planetName .. "..."
        end
    end

    loadingOverlay.Visible = true
    TweenService:Create(loadingOverlay, TweenInfo.new(0.5), {
        BackgroundTransparency = 0,
    }):Play()

    -- Show arrival name after 3 seconds
    task.delay(3, function()
        if arrivalText and loadingOverlay.Visible then
            arrivalText.Text = planetName
            arrivalText.TextTransparency = 1
            TweenService:Create(arrivalText, TweenInfo.new(0.5), {
                TextTransparency = 0,
            }):Play()

            if text then
                text.Text = "Ankunft!"
            end
        end
    end)

    -- Auto-hide after travel time
    task.delay(5, function()
        if loadingOverlay then
            TweenService:Create(loadingOverlay, TweenInfo.new(1), {
                BackgroundTransparency = 1,
            }):Play()
            if arrivalText then
                TweenService:Create(arrivalText, TweenInfo.new(0.8), {
                    TextTransparency = 1,
                }):Play()
            end
            task.wait(1)
            loadingOverlay.Visible = false
        end
    end)
end

---------------------------------------------------------------------------
-- Check unlock status
---------------------------------------------------------------------------
function ShuttleUI:_isPlanetUnlocked(planetId: string): boolean
    for _, id in unlockedPlanets do
        if id == planetId then
            return true
        end
    end
    return false
end

---------------------------------------------------------------------------
-- Connect events
---------------------------------------------------------------------------
function ShuttleUI:_connectEvents()
    local ShuttleResult = Remotes:WaitForChild("ShuttleResult") :: RemoteEvent

    ShuttleResult.OnClientEvent:Connect(function(result: any)
        if result.message == "show_planet_select" then
            -- Server sent planet unlock data
            if result.unlockedPlanets then
                unlockedPlanets = result.unlockedPlanets
            end
            shuttleFrame.Visible = true
        elseif result.destination then
            -- Travel initiated
            self:_showLoading(result.destination)
        end
    end)

    -- Listen for shuttle launch celebration
    local TriggerCelebration = Remotes:WaitForChild("TriggerCelebration") :: RemoteEvent
    TriggerCelebration.OnClientEvent:Connect(function(celebType: string, data: any?)
        if celebType == "shuttle_launch" and data and data.destination then
            self:_showLoading(data.destination)
        end
    end)
end

return ShuttleUI
