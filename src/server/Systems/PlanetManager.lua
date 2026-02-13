--!strict
--[[
    PlanetManager.lua
    Manages planet zones, resource spawning, and resource gathering.
    Each planet is a zone in the Workspace with a landing pad and resource nodes.

    Expected Workspace structure (built in Studio):
      Workspace/
        Planets/
          Verdania/
            LandingPad (Part)
            ResourceSpawns (Folder of Parts marking spawn positions)
          Glacius/ ...
          Luminos/ ...
          Volcanus/ ...
        Station/
          LandingPad (Part - return point)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Planets = require(ReplicatedStorage:WaitForChild("Planets"))
local Items = require(ReplicatedStorage:WaitForChild("Items"))

local PlanetManager = {}
PlanetManager.__index = PlanetManager

local InventoryServer = nil
local QuestManager = nil
local Remotes = nil

-- Active resource nodes: { [Instance]: { itemId, respawnTime } }
local activeResources: { [any]: any } = {}

-- Player location tracking: { [userId]: "station" | planetId }
local playerLocations: { [number]: string } = {}

-- Rate limiting: { [userId]: lastGatherTime }
local gatherCooldowns: { [number]: number } = {}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function PlanetManager:Init()
    local Systems = ServerScriptService:WaitForChild("Systems")
    InventoryServer = require(Systems:WaitForChild("InventoryServer"))
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
-- Start: Setup resource nodes on all planets
---------------------------------------------------------------------------
function PlanetManager:Start()
    local planetsFolder = workspace:FindFirstChild("Planets")
    if not planetsFolder then
        -- Create placeholder for Studio to fill
        planetsFolder = Instance.new("Folder")
        planetsFolder.Name = "Planets"
        planetsFolder.Parent = workspace
        print("[PlanetManager] Created Planets folder in Workspace (populate in Studio)")
    end

    -- Setup each planet's resources
    for _, planetDef in Planets.getAll() do
        local planetFolder = planetsFolder:FindFirstChild(planetDef.name)
        if planetFolder then
            self:_setupPlanetResources(planetFolder, planetDef)
            print("[PlanetManager] Setup resources for: " .. planetDef.name)
        else
            -- Create placeholder folder
            local folder = Instance.new("Folder")
            folder.Name = planetDef.name
            folder.Parent = planetsFolder

            local spawns = Instance.new("Folder")
            spawns.Name = "ResourceSpawns"
            spawns.Parent = folder

            local pad = Instance.new("Part")
            pad.Name = "LandingPad"
            pad.Size = Vector3.new(20, 1, 20)
            pad.Position = Vector3.new(0, 5, 0) -- Placeholder position
            pad.Anchored = true
            pad.BrickColor = BrickColor.new("Medium stone grey")
            pad.Parent = folder

            print("[PlanetManager] Created placeholder for: " .. planetDef.name .. " (build terrain in Studio)")
        end
    end

    -- Setup station folder
    local stationFolder = workspace:FindFirstChild("Station")
    if not stationFolder then
        stationFolder = Instance.new("Folder")
        stationFolder.Name = "Station"
        stationFolder.Parent = workspace

        local stationPad = Instance.new("Part")
        stationPad.Name = "LandingPad"
        stationPad.Size = Vector3.new(20, 1, 20)
        stationPad.Position = Vector3.new(0, 5, -100) -- Behind spawn
        stationPad.Anchored = true
        stationPad.BrickColor = BrickColor.new("Dark stone grey")
        stationPad.Parent = stationFolder

        print("[PlanetManager] Created Station placeholder (build in Studio)")
    end

    print("[PlanetManager] Ready")
end

---------------------------------------------------------------------------
-- Setup resources on a planet
---------------------------------------------------------------------------
function PlanetManager:_setupPlanetResources(planetFolder: Instance, planetDef: any)
    local spawnsFolder = planetFolder:FindFirstChild("ResourceSpawns")
    if not spawnsFolder then return end

    for _, spawnPoint in spawnsFolder:GetChildren() do
        if spawnPoint:IsA("BasePart") then
            self:_createResourceNode(spawnPoint, planetDef)
        end
    end
end

---------------------------------------------------------------------------
-- Create a resource node at a spawn point
---------------------------------------------------------------------------
function PlanetManager:_createResourceNode(spawnPoint: BasePart, planetDef: any)
    -- Pick random resource from planet's resource list
    local resources = planetDef.resources
    local itemId = resources[math.random(1, #resources)]
    local itemDef = Items.get(itemId)
    if not itemDef then return end

    -- Make spawn point visible as resource
    spawnPoint.Transparency = 0
    spawnPoint.BrickColor = BrickColor.new("Bright green") -- Placeholder, replace with models
    spawnPoint.Material = Enum.Material.Neon

    -- Add ProximityPrompt for gathering
    local existingPrompt = spawnPoint:FindFirstChildOfClass("ProximityPrompt")
    if existingPrompt then
        existingPrompt:Destroy()
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.ObjectText = itemDef.name
    prompt.ActionText = "Sammeln"
    prompt.HoldDuration = 0.5 -- Short hold for kids
    prompt.MaxActivationDistance = Constants.RESOURCES.GATHER_DISTANCE
    prompt.RequiresLineOfSight = false
    prompt.Parent = spawnPoint

    -- Store resource data
    activeResources[spawnPoint] = {
        itemId = itemId,
        planetId = planetDef.id,
    }

    -- Connect gathering
    prompt.Triggered:Connect(function(playerWhoTriggered: Player)
        self:_onResourceGathered(playerWhoTriggered, spawnPoint)
    end)
end

---------------------------------------------------------------------------
-- Handle resource gathering
---------------------------------------------------------------------------
function PlanetManager:_onResourceGathered(player: Player, resourceNode: BasePart)
    local data = activeResources[resourceNode]
    if not data then return end

    -- Rate limiting (anti-exploit)
    local userId = player.UserId
    local now = tick()
    local lastGather = gatherCooldowns[userId] or 0
    if now - lastGather < Constants.RESOURCES.GATHER_COOLDOWN then
        return -- Too fast, ignore
    end
    gatherCooldowns[userId] = now

    local itemId = data.itemId
    local itemDef = Items.get(itemId)
    if not itemDef then return end

    -- Determine gather amount (1-3 for common, 1-2 for rare)
    local amount = 1
    if itemDef.rarity == 1 then
        amount = math.random(1, 3)
    elseif itemDef.rarity == 2 then
        amount = math.random(1, 2)
    end

    -- Add to inventory
    local success = InventoryServer:AddItem(player, itemId, amount)
    if not success then
        -- Inventory full - notify player
        return
    end

    -- Notify QuestManager
    if QuestManager and type(QuestManager.OnItemGathered) == "function" then
        QuestManager:OnItemGathered(player, itemId, amount)
    end

    -- Visual feedback: hide resource temporarily
    resourceNode.Transparency = 1
    local prompt = resourceNode:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt.Enabled = false
    end

    -- Respawn after delay
    local respawnTime = math.random(
        Constants.RESOURCES.RESPAWN_TIME_MIN,
        Constants.RESOURCES.RESPAWN_TIME_MAX
    )

    task.delay(respawnTime, function()
        if resourceNode and resourceNode.Parent then
            -- Pick new random resource (variety!)
            local planetDef = Planets.get(data.planetId)
            if planetDef then
                local newItemId = planetDef.resources[math.random(1, #planetDef.resources)]
                local newItemDef = Items.get(newItemId)
                if newItemDef then
                    activeResources[resourceNode] = {
                        itemId = newItemId,
                        planetId = data.planetId,
                    }
                    if prompt then
                        prompt.ObjectText = newItemDef.name
                        prompt.Enabled = true
                    end
                end
            end
            resourceNode.Transparency = 0
        end
    end)
end

---------------------------------------------------------------------------
-- Get/Set player location
---------------------------------------------------------------------------
function PlanetManager:SetPlayerLocation(player: Player, location: string)
    playerLocations[player.UserId] = location
end

function PlanetManager:GetPlayerLocation(player: Player): string
    return playerLocations[player.UserId] or "station"
end

---------------------------------------------------------------------------
-- Get landing pad position for a planet
---------------------------------------------------------------------------
function PlanetManager:GetLandingPad(planetId: string): BasePart?
    local planetDef = Planets.get(planetId)
    if not planetDef then return nil end

    local planetsFolder = workspace:FindFirstChild("Planets")
    if not planetsFolder then return nil end

    local planetFolder = planetsFolder:FindFirstChild(planetDef.name)
    if not planetFolder then return nil end

    return planetFolder:FindFirstChild("LandingPad") :: BasePart?
end

function PlanetManager:GetStationPad(): BasePart?
    local stationFolder = workspace:FindFirstChild("Station")
    if not stationFolder then return nil end
    return stationFolder:FindFirstChild("LandingPad") :: BasePart?
end

---------------------------------------------------------------------------
-- Cleanup on player leave
---------------------------------------------------------------------------
function PlanetManager:OnPlayerRemoving(player: Player)
    playerLocations[player.UserId] = nil
    gatherCooldowns[player.UserId] = nil
end

return PlanetManager
