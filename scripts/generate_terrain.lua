--[[
    generate_terrain.lua
    Run this in Roblox Studio Command Bar AFTER setup_world.lua.
    Generates terrain for all 4 planets.

    Usage: Copy+paste into View > Command Bar, then press Enter
    WARNING: This takes a few seconds per planet. Be patient!
]]

local WS = game:GetService("Workspace")
local terrain = WS.Terrain

print("[Terrain] Starting terrain generation...")
print("[Terrain] This may take 30-60 seconds. Please wait...")

-- ============================================================
-- VERDANIA (Jungle) - Rolling green hills
-- ============================================================
print("[Terrain] Generating Verdania (Jungle)...")

local verdaniaCenter = Vector3.new(2000, 0, 0)
local verdaniaSize = Vector3.new(500, 100, 500)

terrain:FillBlock(
    CFrame.new(verdaniaCenter + Vector3.new(0, -25, 0)),
    Vector3.new(500, 50, 500),
    Enum.Material.Grass
)

-- Add some hills (stacked blocks at various heights)
local hillPositions = {
    {offset = Vector3.new(80, 5, 60), size = Vector3.new(80, 30, 80)},
    {offset = Vector3.new(-100, 3, -80), size = Vector3.new(60, 25, 70)},
    {offset = Vector3.new(50, 4, -120), size = Vector3.new(70, 28, 60)},
    {offset = Vector3.new(-60, 6, 100), size = Vector3.new(90, 32, 80)},
    {offset = Vector3.new(150, 2, 30), size = Vector3.new(50, 20, 50)},
}

for _, hill in ipairs(hillPositions) do
    terrain:FillBall(
        verdaniaCenter + hill.offset + Vector3.new(0, hill.size.Y/2, 0),
        hill.size.X/2,
        Enum.Material.Grass
    )
    -- Top layer with leafy grass
    terrain:FillBall(
        verdaniaCenter + hill.offset + Vector3.new(0, hill.size.Y * 0.7, 0),
        hill.size.X/3,
        Enum.Material.LeafyGrass
    )
end

-- Water pond
terrain:FillCylinder(
    CFrame.new(verdaniaCenter + Vector3.new(-20, -2, 20)),
    30, -- height
    40, -- radius
    Enum.Material.Water
)

print("[Terrain] Verdania done!")

-- ============================================================
-- GLACIUS (Ice) - Snowy mountains
-- ============================================================
print("[Terrain] Generating Glacius (Ice)...")

local glaciusCenter = Vector3.new(0, 0, 2000)

-- Base snow layer
terrain:FillBlock(
    CFrame.new(glaciusCenter + Vector3.new(0, -25, 0)),
    Vector3.new(500, 50, 500),
    Enum.Material.Snow
)

-- Ice mountains
local icePeaks = {
    {offset = Vector3.new(0, 20, 0), radius = 80, mat = Enum.Material.Glacier},
    {offset = Vector3.new(120, 15, 80), radius = 60, mat = Enum.Material.Ice},
    {offset = Vector3.new(-100, 18, -60), radius = 70, mat = Enum.Material.Glacier},
    {offset = Vector3.new(60, 12, -120), radius = 50, mat = Enum.Material.Snow},
    {offset = Vector3.new(-80, 10, 100), radius = 45, mat = Enum.Material.Ice},
}

for _, peak in ipairs(icePeaks) do
    terrain:FillBall(
        glaciusCenter + peak.offset,
        peak.radius,
        peak.mat
    )
end

-- Frozen lake (flat ice)
terrain:FillBlock(
    CFrame.new(glaciusCenter + Vector3.new(50, -5, -40)),
    Vector3.new(80, 3, 60),
    Enum.Material.Ice
)

print("[Terrain] Glacius done!")

-- ============================================================
-- LUMINOS (Mushroom) - Flat with canyons
-- ============================================================
print("[Terrain] Generating Luminos (Mushroom)...")

local luminosCenter = Vector3.new(-2000, 0, 0)

-- Base ground layer (mud/ground for mushroom planet)
terrain:FillBlock(
    CFrame.new(luminosCenter + Vector3.new(0, -25, 0)),
    Vector3.new(400, 50, 400),
    Enum.Material.Mud
)

-- Top ground layer
terrain:FillBlock(
    CFrame.new(luminosCenter + Vector3.new(0, 2, 0)),
    Vector3.new(400, 4, 400),
    Enum.Material.Ground
)

-- Cave-like formations (raised areas with gaps)
local mushPlatforms = {
    {offset = Vector3.new(60, 5, 40), size = Vector3.new(80, 15, 60)},
    {offset = Vector3.new(-80, 4, -50), size = Vector3.new(60, 12, 70)},
    {offset = Vector3.new(-30, 6, 80), size = Vector3.new(70, 18, 50)},
}

for _, plat in ipairs(mushPlatforms) do
    terrain:FillBall(
        luminosCenter + plat.offset,
        plat.size.X/2,
        Enum.Material.Ground
    )
end

print("[Terrain] Luminos done!")

-- ============================================================
-- VOLCANUS (Volcano) - Rocky with crater
-- ============================================================
print("[Terrain] Generating Volcanus (Volcano)...")

local volcanusCenter = Vector3.new(0, 0, -2000)

-- Base rock layer
terrain:FillBlock(
    CFrame.new(volcanusCenter + Vector3.new(0, -25, 0)),
    Vector3.new(400, 50, 400),
    Enum.Material.Basalt
)

-- Volcano mountain (big cone shape using stacked balls)
for i = 0, 8 do
    local height = i * 12
    local radius = 80 - i * 8
    if radius > 5 then
        terrain:FillBall(
            volcanusCenter + Vector3.new(0, height, 0),
            radius,
            Enum.Material.Basalt
        )
    end
end

-- Crater top (remove center to make crater)
-- Fill with air to carve out
terrain:FillBall(
    volcanusCenter + Vector3.new(0, 85, 0),
    25,
    Enum.Material.Air
)

-- Lava in crater
terrain:FillCylinder(
    CFrame.new(volcanusCenter + Vector3.new(0, 70, 0)),
    10, -- height
    20, -- radius
    Enum.Material.CrackedLava
)

-- Rocky outcrops around the base
local rockFormations = {
    {offset = Vector3.new(120, 8, 50), radius = 30},
    {offset = Vector3.new(-100, 6, -80), radius = 25},
    {offset = Vector3.new(60, 10, -130), radius = 35},
    {offset = Vector3.new(-80, 7, 110), radius = 28},
}

for _, rock in ipairs(rockFormations) do
    terrain:FillBall(
        volcanusCenter + rock.offset,
        rock.radius,
        Enum.Material.Rock
    )
end

-- Lava streams (small lava patches)
local lavaPatches = {
    Vector3.new(40, 0, 30),
    Vector3.new(-30, 0, -40),
    Vector3.new(50, 0, -20),
}

for _, pos in ipairs(lavaPatches) do
    terrain:FillBlock(
        CFrame.new(volcanusCenter + pos),
        Vector3.new(15, 2, 30),
        Enum.Material.CrackedLava
    )
end

print("[Terrain] Volcanus done!")

-- ============================================================
-- DONE
-- ============================================================
print("")
print("========================================")
print("  Terrain Generation Complete!")
print("========================================")
print("")
print("Generated terrain for:")
print("  - Verdania (2000, 0, 0) - Jungle with hills + pond")
print("  - Glacius  (0, 0, 2000) - Snow mountains + frozen lake")
print("  - Luminos  (-2000, 0, 0) - Mushroom ground + platforms")
print("  - Volcanus (0, 0, -2000) - Volcano crater + lava")
print("")
print("Next: Place props from ServerStorage onto the terrain!")
print("")
