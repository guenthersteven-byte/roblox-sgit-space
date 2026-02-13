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

    -- QuestManager may not be loaded yet, defer
    task.defer(function()
        local qm = Systems:FindFirstChild("QuestManager")
        if qm then
            QuestManager = require(qm)
        end
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

    -- ProximityPrompt for shuttle console
    local prompt = console:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.ObjectText = "Shuttle-Konsole"
        prompt.ActionText = "Planeten anzeigen"
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 10
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
                    returnPrompt.ObjectText = "Shuttle"
                    returnPrompt.ActionText = "Zurueck zur Station"
                    returnPrompt.HoldDuration = 0.5
                    returnPrompt.MaxActivationDistance = 15
                    returnPrompt.Parent = landingPad
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

    -- Update location
    PlanetManager:SetPlayerLocation(player, destination)

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
