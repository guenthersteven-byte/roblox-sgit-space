--!strict
--[[
    QuestManager.lua
    Server-side quest tracking and progression.
    Tracks objective progress, grants rewards, unlocks content.

    Quest events are reported by other systems:
    - Gathering: PlanetManager calls OnItemGathered
    - Crafting: CraftingServer calls OnItemCrafted
    - Building: StationBuilder calls OnRoomBuilt
    - Aliens: AlienManager calls OnAlienFed / OnAlienTamed
    - Travel: ShuttleSystem calls OnPlanetVisited
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Quests = require(ReplicatedStorage:WaitForChild("Quests"))

local QuestManager = {}
QuestManager.__index = QuestManager

local PlayerDataManager = nil
local InventoryServer = nil
local Remotes = nil

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function QuestManager:Init()
    local Systems = ServerScriptService:WaitForChild("Systems")
    PlayerDataManager = require(Systems:WaitForChild("PlayerDataManager"))
    InventoryServer = require(Systems:WaitForChild("InventoryServer"))
    Remotes = ReplicatedStorage:WaitForChild("Remotes")
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------
function QuestManager:Start()
    print("[QuestManager] Ready")
end

---------------------------------------------------------------------------
-- On player join: Initialize quest state
---------------------------------------------------------------------------
function QuestManager:OnPlayerAdded(player: Player)
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile then return end

    -- Ensure quest progress exists for current quest
    if profile.currentQuestId then
        self:_ensureQuestProgress(profile, profile.currentQuestId)
    end

    -- Send quest state to client
    self:_notifyClient(player)
end

---------------------------------------------------------------------------
-- Ensure quest progress entry exists
---------------------------------------------------------------------------
function QuestManager:_ensureQuestProgress(profile: any, questId: string)
    local questDef = Quests.get(questId)
    if not questDef then return end

    -- Check if progress already exists
    for _, progress in profile.questProgress do
        if progress.questId == questId then
            return
        end
    end

    -- Create new progress entry
    local objectiveProgress = {}
    for i = 1, #questDef.objectives do
        objectiveProgress[i] = 0
    end

    table.insert(profile.questProgress, {
        questId = questId,
        objectiveProgress = objectiveProgress,
        completed = false,
    })
end

---------------------------------------------------------------------------
-- Get quest progress for a player
---------------------------------------------------------------------------
function QuestManager:_getProgress(profile: any, questId: string): any?
    for _, progress in profile.questProgress do
        if progress.questId == questId then
            return progress
        end
    end
    return nil
end

---------------------------------------------------------------------------
-- Report: Item gathered (called by PlanetManager or InventoryServer)
---------------------------------------------------------------------------
function QuestManager:OnItemGathered(player: Player, itemId: string, quantity: number)
    self:_checkObjectives(player, "gather", itemId, quantity)
end

---------------------------------------------------------------------------
-- Report: Item crafted (called by CraftingServer)
---------------------------------------------------------------------------
function QuestManager:OnItemCrafted(player: Player, recipeId: string)
    self:_checkObjectives(player, "craft", recipeId, 1)
end

---------------------------------------------------------------------------
-- Report: Room built (called by StationBuilder)
---------------------------------------------------------------------------
function QuestManager:OnRoomBuilt(player: Player, roomId: string, totalRooms: number)
    -- Check for specific room objectives
    self:_checkObjectives(player, "build_room", roomId, 1)
    -- Check for "any" room objectives (use total count)
    self:_checkObjectivesTotal(player, "build_room", "any", totalRooms)
end

---------------------------------------------------------------------------
-- Report: Alien fed (called by AlienManager)
---------------------------------------------------------------------------
function QuestManager:OnAlienFed(player: Player, alienId: string)
    -- Feeding alone doesn't complete tame objectives
end

---------------------------------------------------------------------------
-- Report: Alien tamed (called by AlienManager)
---------------------------------------------------------------------------
function QuestManager:OnAlienTamed(player: Player, alienId: string)
    self:_checkObjectives(player, "tame_alien", alienId, 1)
end

---------------------------------------------------------------------------
-- Report: Planet visited (called by ShuttleSystem)
---------------------------------------------------------------------------
function QuestManager:OnPlanetVisited(player: Player, planetId: string)
    self:_checkObjectives(player, "visit_planet", planetId, 1)
end

---------------------------------------------------------------------------
-- Check and increment matching objectives
---------------------------------------------------------------------------
function QuestManager:_checkObjectives(player: Player, objectiveType: string, targetId: string, amount: number)
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile or not profile.currentQuestId then return end

    local questDef = Quests.get(profile.currentQuestId)
    if not questDef then return end

    local progress = self:_getProgress(profile, profile.currentQuestId)
    if not progress or progress.completed then return end

    local changed = false

    for i, objective in questDef.objectives do
        if objective.type == objectiveType and (objective.targetId == targetId or objective.targetId == "any") then
            if progress.objectiveProgress[i] < objective.targetCount then
                progress.objectiveProgress[i] = math.min(
                    progress.objectiveProgress[i] + amount,
                    objective.targetCount
                )
                changed = true
            end
        end
    end

    if changed then
        self:_notifyClient(player)
        self:_checkCompletion(player, profile, questDef, progress)
    end
end

---------------------------------------------------------------------------
-- Check objectives with a total count (for "build 3 rooms total")
---------------------------------------------------------------------------
function QuestManager:_checkObjectivesTotal(player: Player, objectiveType: string, targetId: string, totalCount: number)
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile or not profile.currentQuestId then return end

    local questDef = Quests.get(profile.currentQuestId)
    if not questDef then return end

    local progress = self:_getProgress(profile, profile.currentQuestId)
    if not progress or progress.completed then return end

    local changed = false

    for i, objective in questDef.objectives do
        if objective.type == objectiveType and objective.targetId == targetId then
            if progress.objectiveProgress[i] < totalCount then
                progress.objectiveProgress[i] = math.min(totalCount, objective.targetCount)
                changed = true
            end
        end
    end

    if changed then
        self:_notifyClient(player)
        self:_checkCompletion(player, profile, questDef, progress)
    end
end

---------------------------------------------------------------------------
-- Check if all objectives are complete
---------------------------------------------------------------------------
function QuestManager:_checkCompletion(player: Player, profile: any, questDef: any, progress: any)
    for i, objective in questDef.objectives do
        if progress.objectiveProgress[i] < objective.targetCount then
            return -- Not all complete
        end
    end

    -- Quest complete!
    progress.completed = true
    table.insert(profile.completedQuests, questDef.id)

    -- Grant rewards
    for _, reward in questDef.rewards do
        InventoryServer:AddItem(player, reward.itemId, reward.quantity)
    end

    -- Unlock recipes
    if questDef.unlockRecipes then
        for _, recipeId in questDef.unlockRecipes do
            local alreadyUnlocked = false
            for _, id in profile.unlockedRecipes do
                if id == recipeId then
                    alreadyUnlocked = true
                    break
                end
            end
            if not alreadyUnlocked then
                table.insert(profile.unlockedRecipes, recipeId)
            end
        end
    end

    -- Unlock planet
    if questDef.unlockPlanet then
        local alreadyUnlocked = false
        for _, id in profile.unlockedPlanets do
            if id == questDef.unlockPlanet then
                alreadyUnlocked = true
                break
            end
        end
        if not alreadyUnlocked then
            table.insert(profile.unlockedPlanets, questDef.unlockPlanet)
        end
    end

    -- Advance to next quest
    if questDef.nextQuestId then
        profile.currentQuestId = questDef.nextQuestId
        self:_ensureQuestProgress(profile, questDef.nextQuestId)
    else
        profile.currentQuestId = nil
    end

    -- Celebration
    local TriggerCelebration = Remotes:FindFirstChild("TriggerCelebration") :: RemoteEvent?
    if TriggerCelebration then
        TriggerCelebration:FireClient(player, "quest_completed", {
            questName = questDef.name,
            unlockPlanet = questDef.unlockPlanet,
        })
    end

    -- Planet unlock celebration
    if questDef.unlockPlanet then
        local TriggerCeleb = Remotes:FindFirstChild("TriggerCelebration") :: RemoteEvent?
        if TriggerCeleb then
            TriggerCeleb:FireClient(player, "planet_unlocked", {
                planetName = questDef.unlockPlanet,
            })
        end
    end

    -- Notify client of new quest state
    self:_notifyClient(player)

    print("[QuestManager] " .. player.Name .. " completed: " .. questDef.name)
end

---------------------------------------------------------------------------
-- Notify client of current quest state
---------------------------------------------------------------------------
function QuestManager:_notifyClient(player: Player)
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile then return end

    local QuestUpdated = Remotes:FindFirstChild("QuestUpdated") :: RemoteEvent?
    if not QuestUpdated then return end

    local currentQuest = nil
    local currentProgress = nil

    if profile.currentQuestId then
        currentQuest = Quests.get(profile.currentQuestId)
        currentProgress = self:_getProgress(profile, profile.currentQuestId)
    end

    QuestUpdated:FireClient(player, {
        currentQuestId = profile.currentQuestId,
        currentQuest = currentQuest,
        progress = currentProgress,
        completedQuests = profile.completedQuests,
        unlockedRecipes = profile.unlockedRecipes,
        unlockedPlanets = profile.unlockedPlanets,
    })
end

return QuestManager
