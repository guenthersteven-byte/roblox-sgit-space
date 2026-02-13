--!strict
--[[
    ShuttleSystem.lua
    Handles player transport between station and planets.
    Players interact with a shuttle console (ProximityPrompt) to travel.
    Includes loading screen effect and planet unlock checking.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Planets = require(ReplicatedStorage:WaitForChild("Planets"))

local ShuttleSystem = {}
ShuttleSystem.__index = ShuttleSystem

local PlanetManager = nil
local DayCycleServer = nil
local PlayerDataManager = nil
local QuestManager = nil
local PlayerSafety = nil
local Remotes = nil

-- Cooldown to prevent rapid travel
local travelCooldowns: { [number]: boolean } = {}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function ShuttleSystem:Init()
    local Systems = ServerScriptService:WaitForChild("Systems")
    PlanetManager = require(Systems:WaitForChild("PlanetManager"))
    DayCycleServer = require(Systems:WaitForChild("DayCycleServer"))
    PlayerDataManager = require(Systems:WaitForChild("PlayerDataManager"))
    Remotes = ReplicatedStorage:WaitForChild("Remotes")

    -- Deferred system loading
    task.defer(function()
        local qm = Systems:FindFirstChild("QuestManager")
        if qm then QuestManager = require(qm) end
        local ps = Systems:FindFirstChild("PlayerSafety")
        if ps then PlayerSafety = require(ps) end
    end)
end

---------------------------------------------------------------------------
-- Start: Listen for shuttle requests
---------------------------------------------------------------------------
function ShuttleSystem:Start()
    local RequestShuttle = Remotes:WaitForChild("RequestShuttle") :: RemoteEvent
    local ShuttleResult = Remotes:WaitForChild("ShuttleResult") :: RemoteEvent

    RequestShuttle.OnServerEvent:Connect(function(player: Player, destination: string)
        local success, message = self:TryTravel(player, destination)
        ShuttleResult:FireClient(player, {
            success = success,
            message = message,
            destination = destination,
        })
    end)

    -- Setup shuttle console in station (ProximityPrompt)
    self:_setupShuttleConsole()

    print("[ShuttleSystem] Ready")
end

---------------------------------------------------------------------------
-- Setup shuttle console in station
---------------------------------------------------------------------------
function ShuttleSystem:_setupShuttleConsole()
    local stationFolder = workspace:FindFirstChild("Station")
    if not stationFolder then return end

    -- Look for existing console or create placeholder
    local console = stationFolder:FindFirstChild("ShuttleConsole")
    if not console then
        console = Instance.new("Part")
        console.Name = "ShuttleConsole"
        console.Size = Vector3.new(4, 3, 2)
        console.Position = Vector3.new(0, 7, -90) -- Near station pad
        console.Anchored = true
        console.BrickColor = BrickColor.new("Dark stone grey")
        console.Material = Enum.Material.SmoothPlastic
        console.Parent = stationFolder
    end

    -- Make console glow and add "SHUTTLE" sign
    local existingLight = console:FindFirstChildOfClass("PointLight")
    if not existingLight then
        local glow = Instance.new("PointLight")
        glow.Color = Color3.fromHex("43b02a")
        glow.Brightness = 2
        glow.Range = 25
        glow.Parent = console
    end

    -- Add "SHUTTLE" billboard sign
    local existingSign = console:FindFirstChildOfClass("BillboardGui")
    if not existingSign then
        local sign = Instance.new("BillboardGui")
        sign.Size = UDim2.new(0, 200, 0, 60)
        sign.StudsOffset = Vector3.new(0, 4, 0)
        sign.AlwaysOnTop = false
        sign.MaxDistance = 100
        sign.Parent = console

        local signLabel = Instance.new("TextLabel")
        signLabel.Size = UDim2.new(1, 0, 1, 0)
        signLabel.BackgroundColor3 = Color3.fromHex("14350d")
        signLabel.BackgroundTransparency = 0.3
        signLabel.Text = "SHUTTLE"
        signLabel.TextColor3 = Color3.fromHex("5cd43e")
        signLabel.TextStrokeTransparency = 0
        signLabel.TextStrokeColor3 = Color3.fromHex("14350d")
        signLabel.Font = Enum.Font.GothamBold
        signLabel.TextSize = 32
        signLabel.Parent = sign

        local signCorner = Instance.new("UICorner")
        signCorner.CornerRadius = UDim.new(0, 8)
        signCorner.Parent = signLabel
    end

    -- ProximityPrompt for shuttle console
    local prompt = console:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.ObjectText = "Shuttle-Konsole"
        prompt.ActionText = "Planeten anzeigen"
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 15
        prompt.Parent = console
    end

    prompt.Triggered:Connect(function(player: Player)
        -- Tell client to show planet selection UI
        local ShuttleResult = Remotes:FindFirstChild("ShuttleResult") :: RemoteEvent?
        if ShuttleResult then
            local profile = PlayerDataManager:GetProfileData(player)
            ShuttleResult:FireClient(player, {
                success = true,
                message = "show_planet_select",
                unlockedPlanets = profile and profile.unlockedPlanets or { "verdania" },
            })
        end
    end)

    -- Return prompts on planet landing pads
    task.defer(function()
        local planetsFolder = workspace:FindFirstChild("Planets")
        if not planetsFolder then return end

        for _, planetFolder in planetsFolder:GetChildren() do
            local landingPad = planetFolder:FindFirstChild("LandingPad")
            if landingPad and landingPad:IsA("BasePart") then
                local returnPrompt = landingPad:FindFirstChild("ReturnPrompt")
                if not returnPrompt then
                    returnPrompt = Instance.new("ProximityPrompt")
                    returnPrompt.Name = "ReturnPrompt"
                    returnPrompt.ObjectText = "Shuttle rufen"
                    returnPrompt.ActionText = "Zurueck zur Station"
                    returnPrompt.HoldDuration = 0.5
                    returnPrompt.MaxActivationDistance = 20
                    returnPrompt.Parent = landingPad
                end

                -- Add glowing sign above landing pad
                local padSign = landingPad:FindFirstChild("PadSign")
                if not padSign then
                    local sign = Instance.new("BillboardGui")
                    sign.Name = "PadSign"
                    sign.Size = UDim2.new(0, 250, 0, 50)
                    sign.StudsOffset = Vector3.new(0, 5, 0)
                    sign.AlwaysOnTop = false
                    sign.MaxDistance = 80
                    sign.Parent = landingPad

                    local signLabel = Instance.new("TextLabel")
                    signLabel.Size = UDim2.new(1, 0, 1, 0)
                    signLabel.BackgroundColor3 = Color3.fromHex("14350d")
                    signLabel.BackgroundTransparency = 0.3
                    signLabel.Text = "SHUTTLE-LANDEPLATZ"
                    signLabel.TextColor3 = Color3.fromHex("5cd43e")
                    signLabel.TextStrokeTransparency = 0
                    signLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                    signLabel.Font = Enum.Font.GothamBold
                    signLabel.TextSize = 22
                    signLabel.Parent = sign

                    local signCorner = Instance.new("UICorner")
                    signCorner.CornerRadius = UDim.new(0, 6)
                    signCorner.Parent = signLabel
                end

                -- Add glow to landing pad
                local padLight = landingPad:FindFirstChildOfClass("PointLight")
                if not padLight then
                    local glow = Instance.new("PointLight")
                    glow.Color = Color3.fromHex("43b02a")
                    glow.Brightness = 1.5
                    glow.Range = 30
                    glow.Parent = landingPad
                end

                (returnPrompt :: ProximityPrompt).Triggered:Connect(function(player: Player)
                    self:TryTravel(player, "station")
                end)
            end
        end
    end)
end

---------------------------------------------------------------------------
-- Try to travel to destination
---------------------------------------------------------------------------
function ShuttleSystem:TryTravel(player: Player, destination: string): (boolean, string)
    local userId = player.UserId

    -- Cooldown check
    if travelCooldowns[userId] then
        return false, "Shuttle wird vorbereitet..."
    end

    local currentLocation = PlanetManager:GetPlayerLocation(player)

    -- Validate destination
    if destination == "station" then
        if currentLocation == "station" then
            return false, "Du bist schon auf der Station!"
        end
    else
        -- Traveling to a planet
        local planetDef = Planets.get(destination)
        if not planetDef then
            return false, "Unbekannter Planet"
        end

        -- Check if planet is unlocked
        local profile = PlayerDataManager:GetProfileData(player)
        if profile then
            local isUnlocked = false
            for _, unlockedId in profile.unlockedPlanets do
                if unlockedId == destination then
                    isUnlocked = true
                    break
                end
            end
            if not isUnlocked then
                return false, planetDef.name .. " ist noch nicht freigeschaltet!"
            end
        end

        if currentLocation == destination then
            return false, "Du bist schon auf " .. planetDef.name .. "!"
        end
    end

    -- Set cooldown
    travelCooldowns[userId] = true

    -- Notify client of travel start (loading screen)
    local TriggerCelebration = Remotes:FindFirstChild("TriggerCelebration") :: RemoteEvent?
    if TriggerCelebration then
        TriggerCelebration:FireClient(player, "shuttle_launch", { destination = destination })
    end

    -- Travel delay (simulates shuttle flight)
    task.wait(3)

    -- Teleport player
    local character = player.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
        if root then
            local targetPad: BasePart? = nil

            if destination == "station" then
                targetPad = PlanetManager:GetStationPad()
                DayCycleServer:SetStationLighting()
            else
                targetPad = PlanetManager:GetLandingPad(destination)
                local planetDef = Planets.get(destination)
                if planetDef then
                    DayCycleServer:SetPlanetLighting(planetDef.theme)
                end
            end

            if targetPad then
                root.CFrame = targetPad.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end

    -- Update location in both systems
    PlanetManager:SetPlayerLocation(player, destination)
    if PlayerSafety then
        PlayerSafety:SetPlayerLocation(player, destination)
        if destination == "station" then
            PlayerSafety:RestoreAll(player) -- Full heal on return to station
        end
    end

    -- Notify QuestManager of planet visit
    if destination ~= "station" and QuestManager and type(QuestManager.OnPlanetVisited) == "function" then
        QuestManager:OnPlanetVisited(player, destination)
    end

    -- Clear cooldown
    task.delay(2, function()
        travelCooldowns[userId] = nil
    end)

    if destination == "station" then
        return true, "Willkommen zurueck auf der Station!"
    else
        local planetDef = Planets.get(destination)
        return true, "Willkommen auf " .. (planetDef and planetDef.name or destination) .. "!"
    end
end

---------------------------------------------------------------------------
-- Cleanup
---------------------------------------------------------------------------
function ShuttleSystem:OnPlayerRemoving(player: Player)
    travelCooldowns[player.UserId] = nil
end

return ShuttleSystem
