--!strict
--[[
    PlayerDataManager.lua
    Handles player data persistence using DataStoreService.
    Loads profile on join, saves on leave and auto-saves periodically.

    Note: In production, consider using ProfileStore module for session locking.
    This implementation uses raw DataStoreService for simplicity.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local TableUtil = require(ReplicatedStorage:WaitForChild("Utility"):WaitForChild("TableUtil"))
local ProfileTemplate = require(ServerStorage:WaitForChild("ProfileTemplate"))

local PlayerDataManager = {}
PlayerDataManager.__index = PlayerDataManager

-- Player data cache: { [userId]: profileData }
local playerProfiles: { [number]: any } = {}
local dataStore = nil

-- In Studio testing, DataStore may not be available
local USE_DATASTORE = not RunService:IsStudio() or game:GetService("RunService"):IsRunMode()

---------------------------------------------------------------------------
-- Init: Setup DataStore
---------------------------------------------------------------------------
function PlayerDataManager:Init()
    if USE_DATASTORE then
        local success, store = pcall(function()
            return DataStoreService:GetDataStore(Constants.DATA.PROFILE_STORE_NAME)
        end)
        if success then
            dataStore = store
            print("[PlayerDataManager] DataStore ready: " .. Constants.DATA.PROFILE_STORE_NAME)
        else
            warn("[PlayerDataManager] DataStore unavailable, using local data only: " .. tostring(store))
        end
    else
        print("[PlayerDataManager] Studio mode - using local data only")
    end
end

---------------------------------------------------------------------------
-- Start: Begin auto-save loop
---------------------------------------------------------------------------
function PlayerDataManager:Start()
    -- Auto-save loop
    task.spawn(function()
        while true do
            task.wait(Constants.DATA.AUTO_SAVE_INTERVAL)
            self:SaveAllProfiles()
        end
    end)

    -- Bind RequestFullSync
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    local RequestFullSync = Remotes:WaitForChild("RequestFullSync") :: RemoteFunction

    RequestFullSync.OnServerInvoke = function(player: Player)
        return self:GetProfile(player)
    end

    print("[PlayerDataManager] Auto-save started (every " .. Constants.DATA.AUTO_SAVE_INTERVAL .. "s)")
end

---------------------------------------------------------------------------
-- Load profile for a player
---------------------------------------------------------------------------
function PlayerDataManager:OnPlayerAdded(player: Player)
    local userId = player.UserId
    local profile = nil

    -- Try loading from DataStore
    if dataStore then
        local success, data = pcall(function()
            return dataStore:GetAsync("player_" .. userId)
        end)

        if success and data then
            -- Merge with template to add any new fields
            profile = TableUtil.merge(TableUtil.deepCopy(ProfileTemplate), data)
            profile.firstJoin = false
            print("[PlayerDataManager] Loaded profile for " .. player.Name)
        elseif success then
            -- New player, no data found
            profile = TableUtil.deepCopy(ProfileTemplate)
            print("[PlayerDataManager] New profile for " .. player.Name)
        else
            warn("[PlayerDataManager] Failed to load data for " .. player.Name .. ": " .. tostring(data))
            profile = TableUtil.deepCopy(ProfileTemplate)
        end
    else
        -- No DataStore, use fresh template
        profile = TableUtil.deepCopy(ProfileTemplate)
        print("[PlayerDataManager] Local profile for " .. player.Name)
    end

    playerProfiles[userId] = profile

    -- Send initial data to client
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    local StatsUpdated = Remotes:WaitForChild("StatsUpdated") :: RemoteEvent
    local InventoryChanged = Remotes:WaitForChild("InventoryChanged") :: RemoteEvent

    StatsUpdated:FireClient(player, {
        health = profile.health,
        oxygen = profile.oxygen,
        hunger = profile.hunger,
    })

    InventoryChanged:FireClient(player, profile.inventory, profile.hotbar)
end

---------------------------------------------------------------------------
-- Save profile when player leaves
---------------------------------------------------------------------------
function PlayerDataManager:OnPlayerRemoving(player: Player)
    local userId = player.UserId
    self:SaveProfile(userId)
    playerProfiles[userId] = nil
end

---------------------------------------------------------------------------
-- Get profile (read-only copy for client sync)
---------------------------------------------------------------------------
function PlayerDataManager:GetProfile(player: Player): any
    local profile = playerProfiles[player.UserId]
    if profile then
        return TableUtil.deepCopy(profile)
    end
    return nil
end

---------------------------------------------------------------------------
-- Get profile data directly (for server systems to read/write)
---------------------------------------------------------------------------
function PlayerDataManager:GetProfileData(player: Player): any
    return playerProfiles[player.UserId]
end

---------------------------------------------------------------------------
-- Save a single player's profile
---------------------------------------------------------------------------
function PlayerDataManager:SaveProfile(userId: number)
    local profile = playerProfiles[userId]
    if not profile or not dataStore then
        return
    end

    local success, err = pcall(function()
        dataStore:SetAsync("player_" .. userId, profile)
    end)

    if success then
        print("[PlayerDataManager] Saved profile for userId " .. userId)
    else
        warn("[PlayerDataManager] Save failed for userId " .. userId .. ": " .. tostring(err))
    end
end

---------------------------------------------------------------------------
-- Save all active profiles
---------------------------------------------------------------------------
function PlayerDataManager:SaveAllProfiles()
    for userId, _ in playerProfiles do
        self:SaveProfile(userId)
    end
end

---------------------------------------------------------------------------
-- Update specific profile fields
---------------------------------------------------------------------------
function PlayerDataManager:UpdateProfile(player: Player, key: string, value: any)
    local profile = playerProfiles[player.UserId]
    if profile then
        profile[key] = value
    end
end

return PlayerDataManager
