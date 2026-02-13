--!strict
--[[
    CraftingServer.lua
    Server-side crafting system.
    Validates recipes, checks materials, consumes ingredients, grants results.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Recipes = require(ReplicatedStorage:WaitForChild("Recipes"))

local CraftingServer = {}
CraftingServer.__index = CraftingServer

local InventoryServer = nil
local PlayerDataManager = nil
local QuestManager = nil
local Remotes = nil

-- Track active crafts to prevent spam
local activeCrafts: { [number]: boolean } = {}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function CraftingServer:Init()
    local Systems = ServerScriptService:WaitForChild("Systems")
    InventoryServer = require(Systems:WaitForChild("InventoryServer"))
    PlayerDataManager = require(Systems:WaitForChild("PlayerDataManager"))
    Remotes = ReplicatedStorage:WaitForChild("Remotes")

    -- QuestManager may not be loaded yet, defer
    task.defer(function()
        local qm = Systems:FindFirstChild("QuestManager")
        if qm then
            QuestManager = require(qm)
        end
    end)
end

---------------------------------------------------------------------------
-- Start: Listen for craft requests
---------------------------------------------------------------------------
function CraftingServer:Start()
    local RequestCraft = Remotes:WaitForChild("RequestCraft") :: RemoteEvent
    local CraftResult = Remotes:WaitForChild("CraftResult") :: RemoteEvent

    RequestCraft.OnServerEvent:Connect(function(player: Player, recipeId: string)
        local success, message = self:TryCraft(player, recipeId)

        CraftResult:FireClient(player, {
            success = success,
            message = message,
            recipeId = recipeId,
        })

        if success then
            -- Fire celebration
            local TriggerCelebration = Remotes:FindFirstChild("TriggerCelebration") :: RemoteEvent?
            if TriggerCelebration then
                TriggerCelebration:FireClient(player, "item_crafted", { recipeId = recipeId })
            end

            -- Notify QuestManager
            if QuestManager and type(QuestManager.OnItemCrafted) == "function" then
                QuestManager:OnItemCrafted(player, recipeId)
            end
        end
    end)

    print("[CraftingServer] Ready")
end

---------------------------------------------------------------------------
-- Try to craft an item
---------------------------------------------------------------------------
function CraftingServer:TryCraft(player: Player, recipeId: string): (boolean, string)
    local userId = player.UserId

    -- Prevent double-crafting
    if activeCrafts[userId] then
        return false, "Bereits am Craften!"
    end

    -- Validate recipe exists
    local recipe = Recipes.get(recipeId)
    if not recipe then
        return false, "Unbekanntes Rezept"
    end

    -- Check if recipe is unlocked
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile then
        return false, "Keine Spielerdaten"
    end

    local isUnlocked = false
    for _, unlockedId in profile.unlockedRecipes do
        if unlockedId == recipeId then
            isUnlocked = true
            break
        end
    end

    if not isUnlocked then
        return false, "Rezept noch nicht freigeschaltet"
    end

    -- Check materials
    for _, ingredient in recipe.ingredients do
        if not InventoryServer:HasItem(player, ingredient.itemId, ingredient.quantity) then
            return false, "Nicht genug Material"
        end
    end

    -- Lock crafting
    activeCrafts[userId] = true

    -- Wait for craft time (short for kids)
    local craftTime = recipe.craftTime or Constants.CRAFTING.DEFAULT_CRAFT_TIME
    task.wait(craftTime)

    -- Double-check materials (might have changed during wait)
    for _, ingredient in recipe.ingredients do
        if not InventoryServer:HasItem(player, ingredient.itemId, ingredient.quantity) then
            activeCrafts[userId] = nil
            return false, "Material waehrend Crafting verloren"
        end
    end

    -- Consume ingredients
    for _, ingredient in recipe.ingredients do
        InventoryServer:RemoveItem(player, ingredient.itemId, ingredient.quantity)
    end

    -- Grant result
    local added = InventoryServer:AddItem(player, recipe.result.itemId, recipe.result.quantity)

    activeCrafts[userId] = nil

    if added then
        print("[CraftingServer] " .. player.Name .. " crafted: " .. recipeId)
        return true, "Erfolgreich gecraftet!"
    else
        -- Inventory full - refund materials
        for _, ingredient in recipe.ingredients do
            InventoryServer:AddItem(player, ingredient.itemId, ingredient.quantity)
        end
        return false, "Inventar voll!"
    end
end

---------------------------------------------------------------------------
-- Check if player can craft a recipe (for UI display)
---------------------------------------------------------------------------
function CraftingServer:CanCraft(player: Player, recipeId: string): boolean
    local recipe = Recipes.get(recipeId)
    if not recipe then
        return false
    end

    -- Check unlocked
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile then
        return false
    end

    local isUnlocked = false
    for _, unlockedId in profile.unlockedRecipes do
        if unlockedId == recipeId then
            isUnlocked = true
            break
        end
    end
    if not isUnlocked then
        return false
    end

    -- Check materials
    for _, ingredient in recipe.ingredients do
        if not InventoryServer:HasItem(player, ingredient.itemId, ingredient.quantity) then
            return false
        end
    end

    return true
end

return CraftingServer
