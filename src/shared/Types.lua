--!strict
--[[
    Types.lua
    Luau type definitions for all game data structures
]]

local Types = {}

---------------------------------------------------------------------------
-- Items
---------------------------------------------------------------------------
export type ItemCategory = "resource" | "tool" | "food" | "gift" | "station_part" | "cosmetic"

export type ItemDefinition = {
    id: string,
    name: string,
    description: string,
    category: ItemCategory,
    icon: string,               -- Roblox asset ID for ImageLabel
    maxStack: number,
    rarity: number,             -- 1 = common, 2 = uncommon, 3 = rare
}

export type InventorySlot = {
    itemId: string,
    quantity: number,
}

export type Inventory = {
    slots: { InventorySlot },
}

---------------------------------------------------------------------------
-- Crafting
---------------------------------------------------------------------------
export type RecipeIngredient = {
    itemId: string,
    quantity: number,
}

export type Recipe = {
    id: string,
    name: string,
    ingredients: { RecipeIngredient },
    result: RecipeIngredient,
    craftTime: number,
    unlockQuestId: string?,     -- nil = unlocked from start
}

---------------------------------------------------------------------------
-- Planets
---------------------------------------------------------------------------
export type PlanetId = "verdania" | "glacius" | "luminos" | "volcanus"

export type PlanetDefinition = {
    id: PlanetId,
    name: string,
    description: string,
    theme: string,
    ambientColor: Color3,
    fogColor: Color3,
    fogEnd: number,
    resources: { string },      -- Item IDs that spawn here
    alienSpecies: string,       -- Alien type on this planet
    unlockQuestId: string?,     -- nil = available from start
}

---------------------------------------------------------------------------
-- Aliens
---------------------------------------------------------------------------
export type AlienState = "idle" | "wander" | "follow" | "happy" | "hungry"

export type AlienDefinition = {
    id: string,
    name: string,
    species: string,
    planet: PlanetId,
    favoriteFood: string,       -- Item ID
    feedsToTame: number,
    followSpeed: number,
    wanderSpeed: number,
}

export type TamedAlien = {
    alienId: string,
    nickname: string?,
    fedCount: number,
}

---------------------------------------------------------------------------
-- Station Rooms
---------------------------------------------------------------------------
export type RoomDefinition = {
    id: string,
    name: string,
    description: string,
    cost: { RecipeIngredient },
    functionality: string,      -- "crafting" | "storage" | "garden" | "bedroom" | "lab"
    unlockQuestId: string?,
}

export type PlacedRoom = {
    roomId: string,
    slotIndex: number,
}

---------------------------------------------------------------------------
-- Quests
---------------------------------------------------------------------------
export type QuestObjectiveType = "gather" | "craft" | "build_room" | "tame_alien" | "visit_planet" | "talk_npc"

export type QuestObjective = {
    type: QuestObjectiveType,
    targetId: string,
    targetCount: number,
    icon: string,               -- Roblox asset ID for picture-based display
}

export type QuestDefinition = {
    id: string,
    name: string,
    description: string,
    icon: string,
    objectives: { QuestObjective },
    rewards: { RecipeIngredient },
    unlockRecipes: { string }?, -- Recipe IDs unlocked on completion
    unlockPlanet: PlanetId?,    -- Planet unlocked on completion
    nextQuestId: string?,       -- Chain to next quest
}

export type QuestProgress = {
    questId: string,
    objectiveProgress: { number },  -- Progress count per objective
    completed: boolean,
}

---------------------------------------------------------------------------
-- Player Profile (saved to DataStore)
---------------------------------------------------------------------------
export type PlayerProfile = {
    inventory: { InventorySlot },
    hotbar: { string? },            -- Item IDs in hotbar slots (nil = empty)
    health: number,
    oxygen: number,
    hunger: number,
    stationRooms: { PlacedRoom },
    tamedAliens: { TamedAlien },
    completedQuests: { string },    -- Quest IDs
    currentQuestId: string?,
    questProgress: { QuestProgress },
    unlockedRecipes: { string },    -- Recipe IDs
    unlockedPlanets: { string },    -- Planet IDs
    tutorialComplete: boolean,
    firstJoin: boolean,
    playTime: number,               -- Total seconds played
}

return Types
