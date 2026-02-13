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
-- Phase 8: Machine & Gadget Recipes (unlocked via Lab room or quests)
---------------------------------------------------------------------------
Recipes.oxygen_generator = {
    id = "oxygen_generator",
    name = "Sauerstoff-Generator",
    ingredients = {
        { itemId = "energy_cell", quantity = 3 },
        { itemId = "frozen_metal", quantity = 5 },
    },
    result = { itemId = "oxygen_generator", quantity = 1 },
    craftTime = 4,
    unlockQuestId = "quest_006",
}

Recipes.food_synthesizer = {
    id = "food_synthesizer",
    name = "Nahrungs-Synthesizer",
    ingredients = {
        { itemId = "jungle_plant", quantity = 3 },
        { itemId = "space_berry", quantity = 3 },
        { itemId = "scrap_metal", quantity = 2 },
    },
    result = { itemId = "food_synthesizer", quantity = 1 },
    craftTime = 3,
    unlockQuestId = "quest_006",
}

Recipes.alien_beacon = {
    id = "alien_beacon",
    name = "Alien-Leuchtfeuer",
    ingredients = {
        { itemId = "glow_mushroom", quantity = 5 },
        { itemId = "energy_orb", quantity = 3 },
    },
    result = { itemId = "alien_beacon", quantity = 1 },
    craftTime = 4,
    unlockQuestId = "quest_008",
}

Recipes.shield_module = {
    id = "shield_module",
    name = "Schutz-Modul",
    ingredients = {
        { itemId = "obsidian", quantity = 5 },
        { itemId = "ice_crystal", quantity = 3 },
        { itemId = "energy_cell", quantity = 2 },
    },
    result = { itemId = "shield_module", quantity = 1 },
    craftTime = 5,
    unlockQuestId = "quest_012",
}

Recipes.turbo_boots = {
    id = "turbo_boots",
    name = "Turbo-Stiefel",
    ingredients = {
        { itemId = "fire_crystal", quantity = 3 },
        { itemId = "scrap_metal", quantity = 5 },
        { itemId = "frozen_metal", quantity = 2 },
    },
    result = { itemId = "turbo_boots", quantity = 1 },
    craftTime = 5,
    unlockQuestId = "quest_012",
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
