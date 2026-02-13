--!strict
--[[
    Planets.lua
    Planet definitions for sgit Space Station.
    Each planet is a biome with unique resources, aliens, and atmosphere.
]]

local Types = require(script.Parent.Types)

type PlanetDefinition = Types.PlanetDefinition

local Planets: { [string]: PlanetDefinition } = {}

---------------------------------------------------------------------------
-- Verdania: Jungle starter planet
---------------------------------------------------------------------------
Planets.verdania = {
    id = "verdania",
    name = "Verdania",
    description = "Ein gruener Dschungelplanet voller Kristalle und Pflanzen",
    theme = "jungle",
    ambientColor = Color3.fromHex("2a6b1a"),
    fogColor = Color3.fromHex("a8d8a0"),
    fogEnd = 800,
    resources = { "crystal_green", "alien_wood", "jungle_plant", "space_berry", "scrap_metal" },
    alienSpecies = "blob",
    unlockQuestId = nil, -- Available from start
}

---------------------------------------------------------------------------
-- Glacius: Ice planet (unlocked via quest)
---------------------------------------------------------------------------
Planets.glacius = {
    id = "glacius",
    name = "Glacius",
    description = "Ein funkelnder Eisplanet mit gefrorenen Kristallen",
    theme = "ice",
    ambientColor = Color3.fromHex("1a4a6b"),
    fogColor = Color3.fromHex("c8e8ff"),
    fogEnd = 600,
    resources = { "ice_crystal", "frozen_metal", "snowflake_essence", "frost_fish", "scrap_metal" },
    alienSpecies = "penguin",
    unlockQuestId = "quest_005",
}

---------------------------------------------------------------------------
-- Luminos: Glowing mushroom planet
---------------------------------------------------------------------------
Planets.luminos = {
    id = "luminos",
    name = "Luminos",
    description = "Ein magischer Planet mit riesigen Leuchtpilzen",
    theme = "mushroom",
    ambientColor = Color3.fromHex("4a1a6b"),
    fogColor = Color3.fromHex("d8a8ff"),
    fogEnd = 500,
    resources = { "glow_mushroom", "energy_orb", "spore_dust", "luminous_carrot", "energy_cell" },
    alienSpecies = "firefly",
    unlockQuestId = "quest_008",
}

---------------------------------------------------------------------------
-- Volcanus: Mild volcano planet
---------------------------------------------------------------------------
Planets.volcanus = {
    id = "volcanus",
    name = "Volcanus",
    description = "Ein warmer Vulkanplanet mit feurigen Kristallen",
    theme = "volcano",
    ambientColor = Color3.fromHex("6b2a1a"),
    fogColor = Color3.fromHex("ffd8a8"),
    fogEnd = 500,
    resources = { "lava_stone", "obsidian", "fire_crystal", "ember_fruit", "scrap_metal" },
    alienSpecies = "salamander",
    unlockQuestId = "quest_012",
}

---------------------------------------------------------------------------
-- Helper: Get planet by ID
---------------------------------------------------------------------------
function Planets.get(planetId: string): PlanetDefinition?
    return Planets[planetId]
end

---------------------------------------------------------------------------
-- Helper: Get all planets as array
---------------------------------------------------------------------------
function Planets.getAll(): { PlanetDefinition }
    local result = {}
    for _, planet in Planets do
        if type(planet) == "table" and planet.id then
            table.insert(result, planet)
        end
    end
    -- Sort by unlock order (nil unlockQuestId = first)
    table.sort(result, function(a, b)
        if a.unlockQuestId == nil then return true end
        if b.unlockQuestId == nil then return false end
        return a.unlockQuestId < b.unlockQuestId
    end)
    return result
end

return Planets
