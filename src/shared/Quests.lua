--!strict
--[[
    Quests.lua
    Quest definitions for sgit Space Station.
    Quests are picture-based (icons instead of text) for kids 5-7.
    Quest chain: quest_001 -> quest_002 -> ... -> quest_012

    Quest flow:
    001: Gather crystals on Verdania (learn gathering)
    002: Craft energy cell (learn crafting, unlocks energy_cell recipe)
    003: Gather wood & plants (unlocks laser_cutter recipe)
    004: Feed a blob alien (learn feeding, unlocks taming_device recipe)
    005: Tame a blob alien (unlocks Glacius planet + station_window recipe)
    006: Gather ice crystals on Glacius
    007: Build first station room (learn building)
    008: Build a lab room (unlocks Luminos planet)
    009: Gather glow mushrooms on Luminos
    010: Tame a penguin alien
    011: Build 3 station rooms total
    012: Explore all planets (unlocks Volcanus planet)
]]

local Types = require(script.Parent.Types)

type QuestDefinition = Types.QuestDefinition

local Quests: { [string]: QuestDefinition } = {}

---------------------------------------------------------------------------
-- Quest 001: First Steps - Gather crystals
---------------------------------------------------------------------------
Quests.quest_001 = {
    id = "quest_001",
    name = "Erste Kristalle",
    description = "Sammle 5 gruene Kristalle auf Verdania!",
    icon = "rbxassetid://0", -- placeholder
    objectives = {
        {
            type = "gather",
            targetId = "crystal_green",
            targetCount = 5,
            icon = "rbxassetid://0",
        },
    },
    rewards = {
        { itemId = "scrap_metal", quantity = 5 },
    },
    unlockRecipes = nil,
    unlockPlanet = nil,
    nextQuestId = "quest_002",
}

---------------------------------------------------------------------------
-- Quest 002: First Craft - Build an energy cell
---------------------------------------------------------------------------
Quests.quest_002 = {
    id = "quest_002",
    name = "Erste Erfindung",
    description = "Baue eine Energiezelle an der Werkbank!",
    icon = "rbxassetid://0",
    objectives = {
        {
            type = "craft",
            targetId = "energy_cell",
            targetCount = 1,
            icon = "rbxassetid://0",
        },
    },
    rewards = {
        { itemId = "crystal_green", quantity = 5 },
    },
    unlockRecipes = { "energy_cell" },
    unlockPlanet = nil,
    nextQuestId = "quest_003",
}

---------------------------------------------------------------------------
-- Quest 003: Explorer - Gather wood and plants
---------------------------------------------------------------------------
Quests.quest_003 = {
    id = "quest_003",
    name = "Dschungel-Forscher",
    description = "Sammle Holz und Pflanzen auf Verdania!",
    icon = "rbxassetid://0",
    objectives = {
        {
            type = "gather",
            targetId = "alien_wood",
            targetCount = 5,
            icon = "rbxassetid://0",
        },
        {
            type = "gather",
            targetId = "jungle_plant",
            targetCount = 3,
            icon = "rbxassetid://0",
        },
    },
    rewards = {
        { itemId = "scrap_metal", quantity = 5 },
        { itemId = "space_berry", quantity = 5 },
    },
    unlockRecipes = { "laser_cutter" },
    unlockPlanet = nil,
    nextQuestId = "quest_004",
}

---------------------------------------------------------------------------
-- Quest 004: First Contact - Craft gifts for aliens
---------------------------------------------------------------------------
Quests.quest_004 = {
    id = "quest_004",
    name = "Erster Kontakt",
    description = "Baue Geschenkpakete fuer die Aliens!",
    icon = "rbxassetid://0",
    objectives = {
        {
            type = "craft",
            targetId = "gift_bundle",
            targetCount = 2,
            icon = "rbxassetid://0",
        },
    },
    rewards = {
        { itemId = "space_berry", quantity = 10 },
    },
    unlockRecipes = { "taming_device" },
    unlockPlanet = nil,
    nextQuestId = "quest_005",
}

---------------------------------------------------------------------------
-- Quest 005: Best Friends - Tame a blob (unlocks Glacius)
---------------------------------------------------------------------------
Quests.quest_005 = {
    id = "quest_005",
    name = "Beste Freunde",
    description = "Zaehme ein Blob-Wesen! Fuettere es 3 mal!",
    icon = "rbxassetid://0",
    objectives = {
        {
            type = "tame_alien",
            targetId = "blob",
            targetCount = 1,
            icon = "rbxassetid://0",
        },
    },
    rewards = {
        { itemId = "energy_cell", quantity = 3 },
    },
    unlockRecipes = { "station_window" },
    unlockPlanet = "glacius",
    nextQuestId = "quest_006",
}

---------------------------------------------------------------------------
-- Quest 006: Ice Explorer - Gather on Glacius
---------------------------------------------------------------------------
Quests.quest_006 = {
    id = "quest_006",
    name = "Eis-Forscher",
    description = "Sammle Eiskristalle auf Glacius!",
    icon = "rbxassetid://0",
    objectives = {
        {
            type = "gather",
            targetId = "ice_crystal",
            targetCount = 5,
            icon = "rbxassetid://0",
        },
        {
            type = "visit_planet",
            targetId = "glacius",
            targetCount = 1,
            icon = "rbxassetid://0",
        },
    },
    rewards = {
        { itemId = "frozen_metal", quantity = 5 },
        { itemId = "frost_fish", quantity = 3 },
    },
    unlockRecipes = nil,
    unlockPlanet = nil,
    nextQuestId = "quest_007",
}

---------------------------------------------------------------------------
-- Quest 007: Station Builder - Build first room
---------------------------------------------------------------------------
Quests.quest_007 = {
    id = "quest_007",
    name = "Stations-Baumeister",
    description = "Baue deinen ersten Raum an die Station an!",
    icon = "rbxassetid://0",
    objectives = {
        {
            type = "build_room",
            targetId = "any",
            targetCount = 1,
            icon = "rbxassetid://0",
        },
    },
    rewards = {
        { itemId = "station_panel", quantity = 5 },
        { itemId = "station_light", quantity = 3 },
    },
    unlockRecipes = nil,
    unlockPlanet = nil,
    nextQuestId = "quest_008",
}

---------------------------------------------------------------------------
-- Quest 008: Science Lab - Build a lab (unlocks Luminos)
---------------------------------------------------------------------------
Quests.quest_008 = {
    id = "quest_008",
    name = "Forschungslabor",
    description = "Baue ein Labor an die Station!",
    icon = "rbxassetid://0",
    objectives = {
        {
            type = "build_room",
            targetId = "lab",
            targetCount = 1,
            icon = "rbxassetid://0",
        },
    },
    rewards = {
        { itemId = "energy_orb", quantity = 2 },
    },
    unlockRecipes = nil,
    unlockPlanet = "luminos",
    nextQuestId = "quest_009",
}

---------------------------------------------------------------------------
-- Quest 009: Mushroom Hunter - Gather on Luminos
---------------------------------------------------------------------------
Quests.quest_009 = {
    id = "quest_009",
    name = "Pilz-Jaeger",
    description = "Sammle Leuchtpilze auf Luminos!",
    icon = "rbxassetid://0",
    objectives = {
        {
            type = "gather",
            targetId = "glow_mushroom",
            targetCount = 8,
            icon = "rbxassetid://0",
        },
    },
    rewards = {
        { itemId = "spore_dust", quantity = 5 },
        { itemId = "luminous_carrot", quantity = 3 },
    },
    unlockRecipes = nil,
    unlockPlanet = nil,
    nextQuestId = "quest_010",
}

---------------------------------------------------------------------------
-- Quest 010: Ice Friend - Tame a penguin
---------------------------------------------------------------------------
Quests.quest_010 = {
    id = "quest_010",
    name = "Eis-Freund",
    description = "Zaehme einen Pinguin-Alien auf Glacius!",
    icon = "rbxassetid://0",
    objectives = {
        {
            type = "tame_alien",
            targetId = "penguin",
            targetCount = 1,
            icon = "rbxassetid://0",
        },
    },
    rewards = {
        { itemId = "ice_crystal", quantity = 5 },
        { itemId = "snowflake_essence", quantity = 3 },
    },
    unlockRecipes = nil,
    unlockPlanet = nil,
    nextQuestId = "quest_011",
}

---------------------------------------------------------------------------
-- Quest 011: Station Expander - Build 3 rooms total
---------------------------------------------------------------------------
Quests.quest_011 = {
    id = "quest_011",
    name = "Grosser Baumeister",
    description = "Baue insgesamt 3 Raeume an die Station!",
    icon = "rbxassetid://0",
    objectives = {
        {
            type = "build_room",
            targetId = "any",
            targetCount = 3,
            icon = "rbxassetid://0",
        },
    },
    rewards = {
        { itemId = "energy_cell", quantity = 5 },
        { itemId = "station_window", quantity = 3 },
    },
    unlockRecipes = nil,
    unlockPlanet = nil,
    nextQuestId = "quest_012",
}

---------------------------------------------------------------------------
-- Quest 012: Galaxy Explorer (unlocks Volcanus)
---------------------------------------------------------------------------
Quests.quest_012 = {
    id = "quest_012",
    name = "Galaxie-Forscher",
    description = "Besuche alle freigeschalteten Planeten!",
    icon = "rbxassetid://0",
    objectives = {
        {
            type = "visit_planet",
            targetId = "verdania",
            targetCount = 1,
            icon = "rbxassetid://0",
        },
        {
            type = "visit_planet",
            targetId = "glacius",
            targetCount = 1,
            icon = "rbxassetid://0",
        },
        {
            type = "visit_planet",
            targetId = "luminos",
            targetCount = 1,
            icon = "rbxassetid://0",
        },
    },
    rewards = {
        { itemId = "fire_crystal", quantity = 3 },
        { itemId = "obsidian", quantity = 3 },
    },
    unlockRecipes = nil,
    unlockPlanet = "volcanus",
    nextQuestId = nil, -- End of quest chain (for now)
}

---------------------------------------------------------------------------
-- Helper: Get quest by ID
---------------------------------------------------------------------------
function Quests.get(questId: string): QuestDefinition?
    return Quests[questId]
end

---------------------------------------------------------------------------
-- Helper: Get all quests sorted by ID
---------------------------------------------------------------------------
function Quests.getAll(): { QuestDefinition }
    local result = {}
    for _, quest in Quests do
        if type(quest) == "table" and quest.id then
            table.insert(result, quest)
        end
    end
    table.sort(result, function(a, b)
        return a.id < b.id
    end)
    return result
end

return Quests
