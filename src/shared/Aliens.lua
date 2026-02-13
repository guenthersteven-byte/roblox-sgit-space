--!strict
--[[
    Aliens.lua
    Alien species definitions per planet.
    Each planet has one alien type that can be befriended with food.
]]

local Types = require(script.Parent.Types)

type AlienDefinition = Types.AlienDefinition

local Aliens: { [string]: AlienDefinition } = {}

---------------------------------------------------------------------------
-- Verdania: Blob (friendly bouncing creatures)
---------------------------------------------------------------------------
Aliens.blob = {
    id = "blob",
    name = "Blobbi",
    species = "blob",
    planet = "verdania",
    favoriteFood = "space_berry",
    feedsToTame = 3,
    followSpeed = 10,
    wanderSpeed = 4,
}

---------------------------------------------------------------------------
-- Glacius: Penguin-Aliens (waddling ice creatures)
---------------------------------------------------------------------------
Aliens.penguin = {
    id = "penguin",
    name = "Pingui",
    species = "penguin",
    planet = "glacius",
    favoriteFood = "frost_fish",
    feedsToTame = 3,
    followSpeed = 8,
    wanderSpeed = 3,
}

---------------------------------------------------------------------------
-- Luminos: Firefly creatures (floating glowing beings)
---------------------------------------------------------------------------
Aliens.firefly = {
    id = "firefly",
    name = "Glimmi",
    species = "firefly",
    planet = "luminos",
    favoriteFood = "luminous_carrot",
    feedsToTame = 4,
    followSpeed = 12,
    wanderSpeed = 5,
}

---------------------------------------------------------------------------
-- Volcanus: Fire Salamanders (warm, friendly lizards)
---------------------------------------------------------------------------
Aliens.salamander = {
    id = "salamander",
    name = "Flammi",
    species = "salamander",
    planet = "volcanus",
    favoriteFood = "ember_fruit",
    feedsToTame = 4,
    followSpeed = 10,
    wanderSpeed = 4,
}

---------------------------------------------------------------------------
-- Helper: Get alien by ID
---------------------------------------------------------------------------
function Aliens.get(alienId: string): AlienDefinition?
    return Aliens[alienId]
end

---------------------------------------------------------------------------
-- Helper: Get alien by species name (same as planet.alienSpecies)
---------------------------------------------------------------------------
function Aliens.getBySpecies(species: string): AlienDefinition?
    for _, alien in Aliens do
        if type(alien) == "table" and alien.species == species then
            return alien
        end
    end
    return nil
end

---------------------------------------------------------------------------
-- Helper: Get all aliens
---------------------------------------------------------------------------
function Aliens.getAll(): { AlienDefinition }
    local result = {}
    for _, alien in Aliens do
        if type(alien) == "table" and alien.id then
            table.insert(result, alien)
        end
    end
    return result
end

return Aliens
