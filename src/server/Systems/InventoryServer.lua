--!strict
--[[
    InventoryServer.lua
    Server-authoritative inventory system.
    All inventory changes go through this module. Clients receive updates via RemoteEvents.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Items = require(ReplicatedStorage:WaitForChild("Items"))

local InventoryServer = {}
InventoryServer.__index = InventoryServer

local PlayerDataManager = nil -- Set during Init
local Remotes = nil

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function InventoryServer:Init()
    -- Get reference to PlayerDataManager
    local Systems = ServerScriptService:WaitForChild("Systems")
    PlayerDataManager = require(Systems:WaitForChild("PlayerDataManager"))
    Remotes = ReplicatedStorage:WaitForChild("Remotes")
end

---------------------------------------------------------------------------
-- Start: Connect RemoteEvents
---------------------------------------------------------------------------
function InventoryServer:Start()
    -- No direct client requests for inventory (crafting/gathering handle it)
    print("[InventoryServer] Ready")
end

---------------------------------------------------------------------------
-- Add item to player inventory
-- Returns true if successful, false if inventory full
---------------------------------------------------------------------------
function InventoryServer:AddItem(player: Player, itemId: string, quantity: number): boolean
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile then
        return false
    end

    local itemDef = Items.get(itemId)
    if not itemDef then
        warn("[InventoryServer] Unknown item: " .. itemId)
        return false
    end

    local inventory = profile.inventory
    local maxStack = itemDef.maxStack or Constants.INVENTORY.MAX_STACK
    local remaining = quantity

    -- Try to stack with existing slots
    for _, slot in inventory do
        if slot.itemId == itemId and slot.quantity < maxStack then
            local canAdd = math.min(remaining, maxStack - slot.quantity)
            slot.quantity += canAdd
            remaining -= canAdd
            if remaining <= 0 then
                break
            end
        end
    end

    -- Add new slots for remaining items
    while remaining > 0 do
        if #inventory >= Constants.INVENTORY.MAX_SLOTS then
            warn("[InventoryServer] Inventory full for " .. player.Name)
            -- Still added partial amount, notify client
            if remaining < quantity then
                self:_notifyClient(player, profile)
            end
            return false
        end

        local addAmount = math.min(remaining, maxStack)
        table.insert(inventory, {
            itemId = itemId,
            quantity = addAmount,
        })
        remaining -= addAmount
    end

    self:_notifyClient(player, profile)

    -- Fire celebration for item pickup
    local TriggerCelebration = Remotes:FindFirstChild("TriggerCelebration") :: RemoteEvent?
    if TriggerCelebration then
        TriggerCelebration:FireClient(player, "item_collected", {
            itemId = itemId,
            quantity = quantity,
        })
    end

    return true
end

---------------------------------------------------------------------------
-- Remove item from player inventory
-- Returns true if player had enough items
---------------------------------------------------------------------------
function InventoryServer:RemoveItem(player: Player, itemId: string, quantity: number): boolean
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile then
        return false
    end

    -- Check if player has enough
    if not self:HasItem(player, itemId, quantity) then
        return false
    end

    local inventory = profile.inventory
    local remaining = quantity

    -- Remove from slots (last to first to clean up easily)
    for i = #inventory, 1, -1 do
        local slot = inventory[i]
        if slot.itemId == itemId then
            local removeAmount = math.min(remaining, slot.quantity)
            slot.quantity -= removeAmount
            remaining -= removeAmount

            -- Remove empty slots
            if slot.quantity <= 0 then
                table.remove(inventory, i)
            end

            if remaining <= 0 then
                break
            end
        end
    end

    self:_notifyClient(player, profile)
    return true
end

---------------------------------------------------------------------------
-- Check if player has at least `quantity` of an item
---------------------------------------------------------------------------
function InventoryServer:HasItem(player: Player, itemId: string, quantity: number): boolean
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile then
        return false
    end

    local total = 0
    for _, slot in profile.inventory do
        if slot.itemId == itemId then
            total += slot.quantity
            if total >= quantity then
                return true
            end
        end
    end

    return false
end

---------------------------------------------------------------------------
-- Get total count of an item in inventory
---------------------------------------------------------------------------
function InventoryServer:GetItemCount(player: Player, itemId: string): number
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile then
        return 0
    end

    local total = 0
    for _, slot in profile.inventory do
        if slot.itemId == itemId then
            total += slot.quantity
        end
    end

    return total
end

---------------------------------------------------------------------------
-- Get full inventory (for UI sync)
---------------------------------------------------------------------------
function InventoryServer:GetInventory(player: Player): { any }?
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile then
        return nil
    end
    return profile.inventory
end

---------------------------------------------------------------------------
-- Notify client of inventory change
---------------------------------------------------------------------------
function InventoryServer:_notifyClient(player: Player, profile: any)
    local InventoryChanged = Remotes:FindFirstChild("InventoryChanged") :: RemoteEvent?
    if InventoryChanged then
        InventoryChanged:FireClient(player, profile.inventory, profile.hotbar)
    end
end

return InventoryServer
