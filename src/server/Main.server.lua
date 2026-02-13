--!strict
--[[
    Server Bootstrap - sgit Space Station
    Single-Script Architecture: This is the only server Script.
    All game systems are loaded as ModuleScripts from Systems/.

    Execution order:
    1. Create RemoteEvents/RemoteFunctions
    2. Init all systems (setup, no player interaction yet)
    3. Start all systems (begin processing)
    4. Connect player events
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

---------------------------------------------------------------------------
-- Create Remotes folder for client-server communication
---------------------------------------------------------------------------
local Remotes = Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = ReplicatedStorage

-- Inventory
local InventoryChanged = Instance.new("RemoteEvent")
InventoryChanged.Name = "InventoryChanged"
InventoryChanged.Parent = Remotes

local RequestCraft = Instance.new("RemoteEvent")
RequestCraft.Name = "RequestCraft"
RequestCraft.Parent = Remotes

local CraftResult = Instance.new("RemoteEvent")
CraftResult.Name = "CraftResult"
CraftResult.Parent = Remotes

-- Shuttle / Planet
local RequestShuttle = Instance.new("RemoteEvent")
RequestShuttle.Name = "RequestShuttle"
RequestShuttle.Parent = Remotes

local ShuttleResult = Instance.new("RemoteEvent")
ShuttleResult.Name = "ShuttleResult"
ShuttleResult.Parent = Remotes

-- Station Building
local RequestBuildRoom = Instance.new("RemoteEvent")
RequestBuildRoom.Name = "RequestBuildRoom"
RequestBuildRoom.Parent = Remotes

local RoomBuilt = Instance.new("RemoteEvent")
RoomBuilt.Name = "RoomBuilt"
RoomBuilt.Parent = Remotes

-- Aliens
local RequestFeedAlien = Instance.new("RemoteEvent")
RequestFeedAlien.Name = "RequestFeedAlien"
RequestFeedAlien.Parent = Remotes

local AlienStateChanged = Instance.new("RemoteEvent")
AlienStateChanged.Name = "AlienStateChanged"
AlienStateChanged.Parent = Remotes

-- Quests
local QuestUpdated = Instance.new("RemoteEvent")
QuestUpdated.Name = "QuestUpdated"
QuestUpdated.Parent = Remotes

-- Player Stats
local StatsUpdated = Instance.new("RemoteEvent")
StatsUpdated.Name = "StatsUpdated"
StatsUpdated.Parent = Remotes

-- Sync (full state on join)
local RequestFullSync = Instance.new("RemoteFunction")
RequestFullSync.Name = "RequestFullSync"
RequestFullSync.Parent = Remotes

-- Day Cycle
local TimeUpdated = Instance.new("RemoteEvent")
TimeUpdated.Name = "TimeUpdated"
TimeUpdated.Parent = Remotes

-- Celebrations
local TriggerCelebration = Instance.new("RemoteEvent")
TriggerCelebration.Name = "TriggerCelebration"
TriggerCelebration.Parent = Remotes

-- Tutorial
local TutorialComplete = Instance.new("RemoteEvent")
TutorialComplete.Name = "TutorialComplete"
TutorialComplete.Parent = Remotes

-- Handle tutorial completion
TutorialComplete.OnServerEvent:Connect(function(completingPlayer: Player)
    local Systems = script.Parent:FindFirstChild("Systems")
    if Systems then
        local pdmModule = Systems:FindFirstChild("PlayerDataManager")
        if pdmModule then
            local PDM = require(pdmModule)
            PDM:UpdateProfile(completingPlayer, "tutorialComplete", true)
            PDM:UpdateProfile(completingPlayer, "firstJoin", false)
            print("[sgit Server] Tutorial completed for " .. completingPlayer.Name)
        end
    end
end)

print("[sgit Server] Remotes created")

---------------------------------------------------------------------------
-- Load Systems (order matters for dependencies)
---------------------------------------------------------------------------
local Systems = script.Parent:WaitForChild("Systems")

-- Phase 2 systems (loaded when files exist, graceful skip otherwise)
local systemModules = {
    "PlayerDataManager",
    "InventoryServer",
    "CraftingServer",
    "DayCycleServer",
    -- Phase 3
    "PlanetManager",
    "ShuttleSystem",
    -- Phase 4
    "AlienManager",
    "QuestManager",
    "StationBuilder",
}

local loadedSystems = {}

for _, moduleName in systemModules do
    local moduleInstance = Systems:FindFirstChild(moduleName)
    if moduleInstance then
        local success, result = pcall(require, moduleInstance)
        if success then
            loadedSystems[moduleName] = result
            print("[sgit Server] Loaded: " .. moduleName)
        else
            warn("[sgit Server] Failed to load " .. moduleName .. ": " .. tostring(result))
        end
    end
end

---------------------------------------------------------------------------
-- Init Phase: Setup systems (no player interaction)
---------------------------------------------------------------------------
for name, system in loadedSystems do
    if type(system) == "table" and type(system.Init) == "function" then
        local success, err = pcall(system.Init, system)
        if success then
            print("[sgit Server] Initialized: " .. name)
        else
            warn("[sgit Server] Init failed for " .. name .. ": " .. tostring(err))
        end
    end
end

---------------------------------------------------------------------------
-- Start Phase: Begin processing
---------------------------------------------------------------------------
for name, system in loadedSystems do
    if type(system) == "table" and type(system.Start) == "function" then
        local success, err = pcall(system.Start, system)
        if success then
            print("[sgit Server] Started: " .. name)
        else
            warn("[sgit Server] Start failed for " .. name .. ": " .. tostring(err))
        end
    end
end

---------------------------------------------------------------------------
-- Player Connections
---------------------------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
    print("[sgit Server] Player joined: " .. player.Name)

    for name, system in loadedSystems do
        if type(system) == "table" and type(system.OnPlayerAdded) == "function" then
            task.spawn(function()
                local success, err = pcall(system.OnPlayerAdded, system, player)
                if not success then
                    warn("[sgit Server] OnPlayerAdded failed in " .. name .. ": " .. tostring(err))
                end
            end)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    print("[sgit Server] Player leaving: " .. player.Name)

    for name, system in loadedSystems do
        if type(system) == "table" and type(system.OnPlayerRemoving) == "function" then
            local success, err = pcall(system.OnPlayerRemoving, system, player)
            if not success then
                warn("[sgit Server] OnPlayerRemoving failed in " .. name .. ": " .. tostring(err))
            end
        end
    end
end)

-- Handle players that joined before this script ran
for _, player in Players:GetPlayers() do
    task.spawn(function()
        for name, system in loadedSystems do
            if type(system) == "table" and type(system.OnPlayerAdded) == "function" then
                local success, err = pcall(system.OnPlayerAdded, system, player)
                if not success then
                    warn("[sgit Server] Late OnPlayerAdded failed in " .. name .. ": " .. tostring(err))
                end
            end
        end
    end)
end

print("[sgit Server] === sgit Space Station Server Ready ===")
