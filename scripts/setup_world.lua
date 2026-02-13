--[[
    setup_world.lua
    Run this in Roblox Studio Command Bar to set up the world structure.
    Creates folders, zones, platforms, and lighting.

    Usage: Copy+paste into View > Command Bar, then press Enter
]]

-- ============================================================
-- 1. FOLDER STRUCTURE in ServerStorage
-- ============================================================
local SS = game:GetService("ServerStorage")

local function createFolder(parent, name)
    local f = parent:FindFirstChild(name) or Instance.new("Folder")
    f.Name = name
    f.Parent = parent
    return f
end

-- AlienModels
local aliens = createFolder(SS, "AlienModels")
createFolder(aliens, "Blobbi")
createFolder(aliens, "Pingui")
createFolder(aliens, "Glimmi")
createFolder(aliens, "Flammi")
createFolder(aliens, "GreenAlien")

-- PropModels
local props = createFolder(SS, "PropModels")

local verdania = createFolder(props, "Verdania")
createFolder(verdania, "Crystal")
createFolder(verdania, "Tree")
createFolder(verdania, "Plant")
createFolder(verdania, "Berry")

local glacius = createFolder(props, "Glacius")
createFolder(glacius, "IceCrystal")
createFolder(glacius, "FrozenMetal")
createFolder(glacius, "Snowflake")
createFolder(glacius, "FrostFish")
createFolder(glacius, "Icicle")

local luminos = createFolder(props, "Luminos")
createFolder(luminos, "Mushroom")
createFolder(luminos, "EnergyOrb")
createFolder(luminos, "Spore")
createFolder(luminos, "Carrot")
createFolder(luminos, "GiantMushroom")

local volcanus = createFolder(props, "Volcanus")
createFolder(volcanus, "LavaStone")
createFolder(volcanus, "Obsidian")
createFolder(volcanus, "FireCrystal")
createFolder(volcanus, "EmberFruit")
createFolder(volcanus, "VolcanicRock")
createFolder(volcanus, "LavaPool")

local universal = createFolder(props, "Universal")
createFolder(universal, "ScrapMetal")

print("[Setup] ServerStorage folders created!")

-- ============================================================
-- 2. WORKSPACE STRUCTURE
-- ============================================================
local WS = game:GetService("Workspace")

-- Station platform (invisible, holds the station)
local stationFolder = createFolder(WS, "SpaceStation")

local platform = WS:FindFirstChild("StationPlatform") or Instance.new("Part")
platform.Name = "StationPlatform"
platform.Size = Vector3.new(200, 1, 200)
platform.Position = Vector3.new(0, 99, 0)
platform.Anchored = true
platform.Transparency = 1
platform.CanCollide = true
platform.Parent = WS

-- Shuttle spawn point
local shuttleSpawn = WS:FindFirstChild("ShuttleSpawn") or Instance.new("Part")
shuttleSpawn.Name = "ShuttleSpawn"
shuttleSpawn.Size = Vector3.new(6, 1, 6)
shuttleSpawn.Position = Vector3.new(0, 102, 0)
shuttleSpawn.Anchored = true
shuttleSpawn.Transparency = 0.5
shuttleSpawn.BrickColor = BrickColor.new("Bright green")
shuttleSpawn.CanCollide = false
shuttleSpawn.Parent = WS

createFolder(WS, "Shuttle")

print("[Setup] Workspace structure created!")

-- ============================================================
-- 3. PLANET ZONES (teleport targets + detection zones)
-- ============================================================

local PLANETS = {
    {
        name = "verdania",
        position = Vector3.new(2000, 50, 0),
        size = Vector3.new(500, 200, 500),
        color = Color3.fromHex("2a6b1a"),
    },
    {
        name = "glacius",
        position = Vector3.new(0, 50, 2000),
        size = Vector3.new(500, 200, 500),
        color = Color3.fromHex("1a4a6b"),
    },
    {
        name = "luminos",
        position = Vector3.new(-2000, 50, 0),
        size = Vector3.new(400, 200, 400),
        color = Color3.fromHex("4a1a6b"),
    },
    {
        name = "volcanus",
        position = Vector3.new(0, 50, -2000),
        size = Vector3.new(400, 200, 400),
        color = Color3.fromHex("6b2a1a"),
    },
}

local zonesFolder = createFolder(WS, "PlanetZones")

for _, planet in ipairs(PLANETS) do
    -- Zone detection part (invisible)
    local zone = zonesFolder:FindFirstChild("Zone_" .. planet.name) or Instance.new("Part")
    zone.Name = "Zone_" .. planet.name
    zone.Size = planet.size
    zone.Position = planet.position
    zone.Anchored = true
    zone.Transparency = 1
    zone.CanCollide = false
    zone.CanQuery = false
    zone.Parent = zonesFolder

    -- Spawn point (where players land)
    local spawn = zonesFolder:FindFirstChild("Spawn_" .. planet.name) or Instance.new("SpawnLocation")
    spawn.Name = "Spawn_" .. planet.name
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.Position = planet.position + Vector3.new(0, -45, 0) -- Ground level
    spawn.Anchored = true
    spawn.Transparency = 0.8
    spawn.CanCollide = true
    spawn.Neutral = true
    spawn.Enabled = false -- Disable default respawn, we handle teleport
    spawn.Parent = zonesFolder

    -- Planet prop folder in workspace
    local propFolder = createFolder(WS, "Props_" .. planet.name)

    -- Visual marker (colored pillar, remove later)
    local marker = zonesFolder:FindFirstChild("Marker_" .. planet.name) or Instance.new("Part")
    marker.Name = "Marker_" .. planet.name
    marker.Size = Vector3.new(4, 100, 4)
    marker.Position = planet.position
    marker.Anchored = true
    marker.Transparency = 0.5
    marker.Color = planet.color
    marker.CanCollide = false
    marker.Material = Enum.Material.Neon
    marker.Parent = zonesFolder

    print("[Setup] Planet zone created: " .. planet.name .. " at " .. tostring(planet.position))
end

-- ============================================================
-- 4. LIGHTING (Space Skybox)
-- ============================================================
local Lighting = game:GetService("Lighting")

-- Space atmosphere
Lighting.Ambient = Color3.fromHex("0a0f08")
Lighting.OutdoorAmbient = Color3.fromHex("1a2a40")
Lighting.Brightness = 1
Lighting.ClockTime = 14 -- Afternoon
Lighting.FogEnd = 10000

-- Sky
local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky")
sky.Name = "SpaceSky"
sky.CelestialBodiesShown = true
sky.StarCount = 5000
sky.Parent = Lighting

-- Atmosphere
local atmo = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmo.Name = "SpaceAtmosphere"
atmo.Density = 0.1
atmo.Offset = 0
atmo.Color = Color3.fromHex("1a2a40")
atmo.Decay = Color3.fromHex("0a0f08")
atmo.Glare = 0
atmo.Haze = 0
atmo.Parent = Lighting

-- Bloom (for glow effects)
local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
bloom.Name = "SpaceBloom"
bloom.Intensity = 0.5
bloom.Size = 24
bloom.Threshold = 0.8
bloom.Parent = Lighting

print("[Setup] Lighting configured for space!")

-- ============================================================
-- 5. SPAWN LOCATION (Station)
-- ============================================================
local stationSpawn = WS:FindFirstChild("StationSpawn") or Instance.new("SpawnLocation")
stationSpawn.Name = "StationSpawn"
stationSpawn.Size = Vector3.new(10, 1, 10)
stationSpawn.Position = Vector3.new(0, 101, 10) -- On station platform
stationSpawn.Anchored = true
stationSpawn.Transparency = 1
stationSpawn.CanCollide = true
stationSpawn.Neutral = true
stationSpawn.Parent = WS

-- Fallen parts height
WS.FallenPartsDestroyHeight = -500

print("")
print("========================================")
print("  sgit Space Station - Setup Complete!")
print("========================================")
print("")
print("Created:")
print("  - ServerStorage folders (AlienModels, PropModels)")
print("  - Workspace structure (SpaceStation, Shuttle)")
print("  - 4 Planet Zones with spawn points")
print("  - Space lighting + skybox + bloom")
print("  - Station platform + spawn")
print("")
print("Next: Import FBX files via File > Import 3D")
print("Then: Generate terrain per planet (Terrain Editor)")
print("")
