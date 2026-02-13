--!strict
--[[
    ProfileTemplate.lua
    Default player profile structure for new players.
    This is the template used by PlayerDataManager when a player joins for the first time.
]]

local ProfileTemplate = {
    -- Inventory: array of {itemId, quantity}
    inventory = {},

    -- Hotbar: 5 slots, nil = empty
    hotbar = { nil, nil, nil, nil, nil },

    -- Player stats
    health = 100,
    oxygen = 100,
    hunger = 100,

    -- Station rooms built by player
    stationRooms = {},

    -- Tamed aliens
    tamedAliens = {},

    -- Quest progression
    completedQuests = {},
    currentQuestId = "quest_001", -- First quest assigned on join
    questProgress = {},

    -- Unlocked content
    unlockedRecipes = {
        "scanner",
        "station_panel",
        "station_light",
        "gift_bundle",
    },
    unlockedPlanets = {
        "verdania", -- First planet available from start
    },

    -- Tutorial & meta
    tutorialComplete = false,
    firstJoin = true,
    playTime = 0,
}

return ProfileTemplate
