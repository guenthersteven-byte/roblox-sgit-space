--!strict
--[[
    PlayerSafety.lua
    Prevents players from falling into the void and handles soft respawn.
    Kid-friendly: No death screen, just gentle teleport back to station.

    Features:
    - Kill zone below Y < -50 (teleport back to station)
    - Invisible barriers around station edges
    - Planet boundary enforcement
    - O2/Hunger depletion with soft respawn
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))

local PlayerSafety = {}
PlayerSafety.__index = PlayerSafety

-- Track player locations (set by ShuttleSystem)
local playerLocations: { [Player]: string } = {} -- "station" or planet id

-- Track player stats
local playerStats: { [Player]: { health: number, oxygen: number, hunger: number } } = {}

-- Planet centers for boundary checks
local PLANET_CENTERS: { [string]: Vector3 } = {
    verdania = Vector3.new(2000, 5, 0),
    glacius = Vector3.new(0, 5, 2000),
    luminos = Vector3.new(-2000, 5, 0),
    volcanus = Vector3.new(0, 5, -2000),
}

local PLANET_BOUNDARY = 280 -- Max distance from planet center before teleport back
local VOID_Y = -50 -- Below this = teleport to station
local STATION_SPAWN = Vector3.new(0, 105, 10)

-- Stat drain rates (per second)
local O2_DRAIN = Constants.PLAYER.OXYGEN_DRAIN_RATE -- 0.3/s on planets
local HUNGER_DRAIN = 0.1 -- Very slow everywhere (was 0.5, too fast for kids)
local RESPAWN_COOLDOWN = 3 -- Seconds before can respawn again

local respawnCooldowns: { [Player]: number } = {}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function PlayerSafety:Init()
    print("[PlayerSafety] Initialized")
end

---------------------------------------------------------------------------
-- Start: Begin safety checks
---------------------------------------------------------------------------
function PlayerSafety:Start()
    -- Heartbeat loop for void check + stat drain
    RunService.Heartbeat:Connect(function(dt)
        for _, player in Players:GetPlayers() do
            self:_checkPlayer(player, dt)
        end
    end)

    -- Create invisible barriers around station
    self:_createStationBarriers()

    print("[PlayerSafety] Safety systems active")
end

---------------------------------------------------------------------------
-- Set player location (called by ShuttleSystem)
---------------------------------------------------------------------------
function PlayerSafety:SetPlayerLocation(player: Player, location: string)
    playerLocations[player] = location
end

function PlayerSafety:GetPlayerLocation(player: Player): string
    return playerLocations[player] or "station"
end

---------------------------------------------------------------------------
-- Init player stats
---------------------------------------------------------------------------
function PlayerSafety:OnPlayerAdded(player: Player)
    playerStats[player] = {
        health = Constants.PLAYER.MAX_HEALTH,
        oxygen = Constants.PLAYER.MAX_OXYGEN,
        hunger = Constants.PLAYER.MAX_HUNGER,
    }
    playerLocations[player] = "station"
end

function PlayerSafety:OnPlayerRemoving(player: Player)
    playerStats[player] = nil
    playerLocations[player] = nil
    respawnCooldowns[player] = nil
end

---------------------------------------------------------------------------
-- Get player stats (for HUD sync)
---------------------------------------------------------------------------
function PlayerSafety:GetStats(player: Player): { health: number, oxygen: number, hunger: number }?
    return playerStats[player]
end

---------------------------------------------------------------------------
-- Modify stats (e.g. eating food)
---------------------------------------------------------------------------
function PlayerSafety:RestoreOxygen(player: Player, amount: number)
    local stats = playerStats[player]
    if stats then
        stats.oxygen = math.min(Constants.PLAYER.MAX_OXYGEN, stats.oxygen + amount)
        self:_syncStats(player)
    end
end

function PlayerSafety:RestoreHunger(player: Player, amount: number)
    local stats = playerStats[player]
    if stats then
        stats.hunger = math.min(Constants.PLAYER.MAX_HUNGER, stats.hunger + amount)
        self:_syncStats(player)
    end
end

function PlayerSafety:RestoreHealth(player: Player, amount: number)
    local stats = playerStats[player]
    if stats then
        stats.health = math.min(Constants.PLAYER.MAX_HEALTH, stats.health + amount)
        self:_syncStats(player)
    end
end

function PlayerSafety:RestoreAll(player: Player)
    local stats = playerStats[player]
    if stats then
        stats.health = Constants.PLAYER.MAX_HEALTH
        stats.oxygen = Constants.PLAYER.MAX_OXYGEN
        stats.hunger = Constants.PLAYER.MAX_HUNGER
        self:_syncStats(player)
    end
end

---------------------------------------------------------------------------
-- Per-frame player check
---------------------------------------------------------------------------
function PlayerSafety:_checkPlayer(player: Player, dt: number)
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not root then return end
    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
    if not humanoid or humanoid.Health <= 0 then return end

    local pos = root.Position
    local location = playerLocations[player] or "station"
    local stats = playerStats[player]
    if not stats then return end

    -- 1) Void check - below Y threshold
    if pos.Y < VOID_Y then
        self:_softRespawn(player, "Autopilot aktiviert! Zurueck zur Station...")
        return
    end

    -- 2) Planet boundary check
    if location ~= "station" then
        local center = PLANET_CENTERS[location]
        if center then
            local dist = (Vector3.new(pos.X, center.Y, pos.Z) - center).Magnitude
            if dist > PLANET_BOUNDARY then
                -- Teleport back to planet landing pad
                local landingPos = center + Vector3.new(0, 3, 0)
                root.CFrame = CFrame.new(landingPos)
                self:_showMessage(player, "Zu weit weg! Zurueck zum Landeplatz...")
            end
        end

        -- 3) O2 drain on planets
        stats.oxygen = math.max(0, stats.oxygen - O2_DRAIN * dt)
    else
        -- Station: O2 refills
        if stats.oxygen < Constants.PLAYER.MAX_OXYGEN then
            stats.oxygen = math.min(Constants.PLAYER.MAX_OXYGEN, stats.oxygen + 2 * dt)
        end
        -- Station: Health regenerates slowly
        if stats.health < Constants.PLAYER.MAX_HEALTH then
            stats.health = math.min(Constants.PLAYER.MAX_HEALTH, stats.health + 1 * dt)
        end
    end

    -- 4) Hunger drain (everywhere, very slow)
    stats.hunger = math.max(0, stats.hunger - HUNGER_DRAIN * dt)

    -- 5) Check for soft respawn conditions
    if stats.oxygen <= 0 or stats.hunger <= 0 then
        local now = tick()
        local lastRespawn = respawnCooldowns[player] or 0
        if now - lastRespawn > RESPAWN_COOLDOWN then
            local msg = stats.oxygen <= 0
                and "Sauerstoff leer! Notfall-Teleport zur Station..."
                or "Zu hungrig! Zurueck zur Station..."
            self:_softRespawn(player, msg)
        end
    end

    -- 6) Sync stats to client (throttled - every 0.5s via separate loop)
    -- This is handled by the stats sync loop below
end

---------------------------------------------------------------------------
-- Soft respawn: teleport to station, restore stats
---------------------------------------------------------------------------
function PlayerSafety:_softRespawn(player: Player, message: string)
    respawnCooldowns[player] = tick()

    -- Teleport to station spawn
    local character = player.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
        if root then
            root.CFrame = CFrame.new(STATION_SPAWN)
        end
    end

    -- Restore all stats
    self:RestoreAll(player)

    -- Update location
    playerLocations[player] = "station"

    -- Show rescue message
    self:_showMessage(player, message)

    -- Notify shuttle system to update lighting etc.
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if Remotes then
        local ShuttleResult = Remotes:FindFirstChild("ShuttleResult") :: RemoteEvent?
        if ShuttleResult then
            ShuttleResult:FireClient(player, {
                success = true,
                destination = "station",
                message = message,
            })
        end
    end

    print("[PlayerSafety] Soft respawn for " .. player.Name .. ": " .. message)
end

---------------------------------------------------------------------------
-- Show floating message to player
---------------------------------------------------------------------------
function PlayerSafety:_showMessage(player: Player, text: string)
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if Remotes then
        local TriggerCelebration = Remotes:FindFirstChild("TriggerCelebration") :: RemoteEvent?
        if TriggerCelebration then
            TriggerCelebration:FireClient(player, {
                type = "message",
                text = text,
            })
        end
    end
end

---------------------------------------------------------------------------
-- Sync stats to client
---------------------------------------------------------------------------
function PlayerSafety:_syncStats(player: Player)
    local stats = playerStats[player]
    if not stats then return end

    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if Remotes then
        local StatsUpdated = Remotes:FindFirstChild("StatsUpdated") :: RemoteEvent?
        if StatsUpdated then
            StatsUpdated:FireClient(player, {
                health = stats.health,
                oxygen = stats.oxygen,
                hunger = stats.hunger,
            })
        end
    end
end

---------------------------------------------------------------------------
-- Stats sync loop (throttled to 2x per second)
---------------------------------------------------------------------------
function PlayerSafety:_startStatsSync()
    task.spawn(function()
        while true do
            for _, player in Players:GetPlayers() do
                self:_syncStats(player)
            end
            task.wait(0.5)
        end
    end)
end

---------------------------------------------------------------------------
-- Create invisible barriers around station platform
---------------------------------------------------------------------------
function PlayerSafety:_createStationBarriers()
    local station = workspace:FindFirstChild("StationPlatform")
    if not station then
        -- Create barrier folder even without platform
        print("[PlayerSafety] No StationPlatform found, skipping barriers")
        return
    end

    local barrierFolder = Instance.new("Folder")
    barrierFolder.Name = "SafetyBarriers"
    barrierFolder.Parent = workspace

    local platformPos = station.Position
    local platformSize = station.Size

    -- Create 4 walls around the station (with gap at shuttle dock)
    local wallHeight = 25
    local wallThickness = 2

    local walls = {
        -- North wall
        {
            pos = platformPos + Vector3.new(0, wallHeight / 2, -platformSize.Z / 2),
            size = Vector3.new(platformSize.X, wallHeight, wallThickness),
        },
        -- South wall
        {
            pos = platformPos + Vector3.new(0, wallHeight / 2, platformSize.Z / 2),
            size = Vector3.new(platformSize.X, wallHeight, wallThickness),
        },
        -- East wall
        {
            pos = platformPos + Vector3.new(platformSize.X / 2, wallHeight / 2, 0),
            size = Vector3.new(wallThickness, wallHeight, platformSize.Z),
        },
        -- West wall
        {
            pos = platformPos + Vector3.new(-platformSize.X / 2, wallHeight / 2, 0),
            size = Vector3.new(wallThickness, wallHeight, platformSize.Z),
        },
    }

    for i, wallData in walls do
        local wall = Instance.new("Part")
        wall.Name = "SafetyWall_" .. i
        wall.Size = wallData.size
        wall.Position = wallData.pos
        wall.Anchored = true
        wall.CanCollide = true
        wall.Transparency = 1 -- Completely invisible
        wall.Material = Enum.Material.ForceField
        wall.Parent = barrierFolder
    end

    print("[PlayerSafety] Station barriers created")
end

return PlayerSafety
