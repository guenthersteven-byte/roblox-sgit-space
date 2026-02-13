--!strict
--[[
    Recipes.lua
    Crafting recipe database. Shared between server (validation) and client (UI display).
]]

local Types = require(script.Parent.Types)

type Recipe = Types.Recipe

local Recipes: { [string]: Recipe } = {}

---------------------------------------------------------------------------
-- Starter Recipes (unlocked from beginning)
---------------------------------------------------------------------------
Recipes.scanner = {
    id = "scanner",
    name = "Scanner",
    ingredients = {
        { itemId = "crystal_green", quantity = 3 },
        { itemId = "scrap_metal", quantity = 2 },
    },
    result = { itemId = "scanner", quantity = 1 },
    craftTime = 2,
    unlockQuestId = nil,
}

Recipes.station_panel = {
    id = "station_panel",
    name = "Stationswand",
    ingredients = {
        { itemId = "scrap_metal", quantity = 5 },
        { itemId = "alien_wood", quantity = 3 },
    },
    result = { itemId = "station_panel", quantity = 2 },
    craftTime = 3,
    unlockQuestId = nil,
}

Recipes.station_light = {
    id = "station_light",
    name = "LED-Leuchte",
    ingredients = {
        { itemId = "crystal_green", quantity = 2 },
        { itemId = "scrap_metal", quantity = 1 },
    },
    result = { itemId = "station_light", quantity = 1 },
    craftTime = 2,
    unlockQuestId = nil,
}

Recipes.gift_bundle = {
    id = "gift_bundle",
    name = "Geschenkpaket",
    ingredients = {
        { itemId = "space_berry", quantity = 3 },
        { itemId = "jungle_plant", quantity = 2 },
    },
    result = { itemId = "gift_bundle", quantity = 1 },
    craftTime = 2,
    unlockQuestId = nil,
}

---------------------------------------------------------------------------
-- Quest-unlocked Recipes
---------------------------------------------------------------------------
Recipes.laser_cutter = {
    id = "laser_cutter",
    name = "Laserschneider",
    ingredients = {
        { itemId = "crystal_green", quantity = 5 },
        { itemId = "alien_wood", quantity = 3 },
        { itemId = "scrap_metal", quantity = 3 },
    },
    result = { itemId = "laser_cutter", quantity = 1 },
    craftTime = 4,
    unlockQuestId = "quest_003",
}

Recipes.taming_device = {
    id = "taming_device",
    name = "Freundschafts-Geraet",
    ingredients = {
        { itemId = "jungle_plant", quantity = 3 },
        { itemId = "space_berry", quantity = 5 },
        { itemId = "crystal_green", quantity = 3 },
    },
    result = { itemId = "taming_device", quantity = 1 },
    craftTime = 4,
    unlockQuestId = "quest_004",
}

Recipes.station_window = {
    id = "station_window",
    name = "Fenster-Modul",
    ingredients = {
        { itemId = "ice_crystal", quantity = 4 },
        { itemId = "scrap_metal", quantity = 3 },
    },
    result = { itemId = "station_window", quantity = 1 },
    craftTime = 3,
    unlockQuestId = "quest_005",
}

Recipes.energy_cell = {
    id = "energy_cell",
    name = "Energiezelle",
    ingredients = {
        { itemId = "crystal_green", quantity = 3 },
        { itemId = "scrap_metal", quantity = 2 },
    },
    result = { itemId = "energy_cell", quantity = 1 },
    craftTime = 3,
    unlockQuestId = "quest_002",
}

---------------------------------------------------------------------------
-- Helper: Get recipe by ID
---------------------------------------------------------------------------
function Recipes.get(recipeId: string): Recipe?
    return Recipes[recipeId]
end

---------------------------------------------------------------------------
-- Helper: Get all recipes (for UI listing)
---------------------------------------------------------------------------
function Recipes.getAll(): { Recipe }
    local result = {}
    for _, recipe in Recipes do
        if type(recipe) == "table" and recipe.id then
            table.insert(result, recipe)
        end
    end
    return result
end

return Recipes
