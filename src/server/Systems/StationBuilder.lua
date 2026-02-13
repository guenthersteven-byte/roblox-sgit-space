--!strict
--[[
    StationBuilder.lua
    Server-side station room building system.
    Players can build rooms on available slots in the station.
    Rooms cost materials from inventory and unlock new functionality.

    Expected Workspace structure (built in Studio):
      Workspace/Station/
        BuildSlots/ (Folder of Parts marking where rooms can be placed)
          Slot_1 (Part)
          Slot_2 (Part)
          ... up to MAX_ROOMS
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local StationRooms = require(ReplicatedStorage:WaitForChild("StationRooms"))

local StationBuilder = {}
StationBuilder.__index = StationBuilder

local PlayerDataManager = nil
local InventoryServer = nil
local QuestManager = nil
local Remotes = nil

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function StationBuilder:Init()
    local Systems = ServerScriptService:WaitForChild("Systems")
    PlayerDataManager = require(Systems:WaitForChild("PlayerDataManager"))
    InventoryServer = require(Systems:WaitForChild("InventoryServer"))
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
-- Start: Setup build slots + connect remote
---------------------------------------------------------------------------
function StationBuilder:Start()
    -- Ensure Station folder exists
    local stationFolder = workspace:FindFirstChild("Station")
    if not stationFolder then
        stationFolder = Instance.new("Folder")
        stationFolder.Name = "Station"
        stationFolder.Parent = workspace
    end

    -- Ensure BuildSlots folder exists
    local buildSlots = stationFolder:FindFirstChild("BuildSlots")
    if not buildSlots then
        buildSlots = Instance.new("Folder")
        buildSlots.Name = "BuildSlots"
        buildSlots.Parent = stationFolder

        -- Create placeholder build slots
        for i = 1, Constants.STATION.MAX_ROOMS do
            local slot = Instance.new("Part")
            slot.Name = "Slot_" .. i
            slot.Size = Vector3.new(15, 0.5, 15)
            -- Arrange in a grid around the station
            local row = math.ceil(i / 4)
            local col = ((i - 1) % 4) + 1
            slot.Position = Vector3.new(
                -30 + (col * 20),
                4,
                -100 - (row * 20)
            )
            slot.Anchored = true
            slot.BrickColor = BrickColor.new("Medium stone grey")
            slot.Material = Enum.Material.Metal
            slot.Transparency = 0.5
            slot.Parent = buildSlots

            -- ProximityPrompt for building
            local prompt = Instance.new("ProximityPrompt")
            prompt.ObjectText = "Bauplatz " .. i
            prompt.ActionText = "Bauen"
            prompt.HoldDuration = 0.5
            prompt.MaxActivationDistance = 12
            prompt.RequiresLineOfSight = false
            prompt.Parent = slot
        end

        print("[StationBuilder] Created " .. Constants.STATION.MAX_ROOMS .. " build slot placeholders")
    end

    -- Connect build slot prompts
    for _, slot in buildSlots:GetChildren() do
        if slot:IsA("BasePart") then
            local prompt = slot:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                prompt.Triggered:Connect(function(player: Player)
                    self:_onBuildSlotTriggered(player, slot)
                end)
            end
        end
    end

    -- Connect remote for room selection
    local RequestBuildRoom = Remotes:WaitForChild("RequestBuildRoom") :: RemoteEvent
    RequestBuildRoom.OnServerEvent:Connect(function(player: Player, roomId: string, slotIndex: number)
        self:_onBuildRequest(player, roomId, slotIndex)
    end)

    print("[StationBuilder] Ready")
end

---------------------------------------------------------------------------
-- On player join: Rebuild their rooms visually
---------------------------------------------------------------------------
function StationBuilder:OnPlayerAdded(player: Player)
    -- In a shared server, all rooms are visible to all players
    -- For personal rooms, we'd use per-player instances
    -- For simplicity: rooms are global and first-builder owns them
end

---------------------------------------------------------------------------
-- Build slot proximity prompt triggered - send available rooms to client
---------------------------------------------------------------------------
function StationBuilder:_onBuildSlotTriggered(player: Player, slotPart: BasePart)
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile then return end

    -- Check if slot is already occupied
    local slotName = slotPart.Name
    local slotIndex = tonumber(slotName:match("Slot_(%d+)"))
    if not slotIndex then return end

    for _, placed in profile.stationRooms do
        if placed.slotIndex == slotIndex then
            -- Already built here
            return
        end
    end

    -- Check total rooms limit
    if #profile.stationRooms >= Constants.STATION.MAX_ROOMS then
        return
    end

    -- Get available rooms the player can build
    local availableRooms = self:_getAvailableRooms(player, profile)

    -- Send to client to show selection UI
    local RoomBuilt = Remotes:FindFirstChild("RoomBuilt") :: RemoteEvent?
    if RoomBuilt then
        RoomBuilt:FireClient(player, "show_menu", {
            slotIndex = slotIndex,
            availableRooms = availableRooms,
        })
    end
end

---------------------------------------------------------------------------
-- Get rooms the player can build
---------------------------------------------------------------------------
function StationBuilder:_getAvailableRooms(player: Player, profile: any): { any }
    local available = {}

    for _, roomDef in StationRooms.getAll() do
        -- Check if unlocked
        local isUnlocked = true
        if roomDef.unlockQuestId then
            isUnlocked = false
            for _, completedId in profile.completedQuests do
                if completedId == roomDef.unlockQuestId then
                    isUnlocked = true
                    break
                end
            end
        end

        if not isUnlocked then continue end

        -- Check if player already has this room type (no duplicates)
        local alreadyBuilt = false
        for _, placed in profile.stationRooms do
            if placed.roomId == roomDef.id then
                alreadyBuilt = true
                break
            end
        end

        -- Check if player has materials
        local hasMaterials = true
        local costInfo = {}
        for _, cost in roomDef.cost do
            local owned = InventoryServer:GetItemCount(player, cost.itemId)
            if owned < cost.quantity then
                hasMaterials = false
            end
            table.insert(costInfo, {
                itemId = cost.itemId,
                required = cost.quantity,
                owned = owned,
            })
        end

        table.insert(available, {
            roomId = roomDef.id,
            name = roomDef.name,
            description = roomDef.description,
            cost = costInfo,
            canBuild = hasMaterials and not alreadyBuilt,
            alreadyBuilt = alreadyBuilt,
        })
    end

    return available
end

---------------------------------------------------------------------------
-- Handle build request from client
---------------------------------------------------------------------------
function StationBuilder:_onBuildRequest(player: Player, roomId: string, slotIndex: number)
    local profile = PlayerDataManager:GetProfileData(player)
    if not profile then return end

    -- Validate room exists
    local roomDef = StationRooms.get(roomId)
    if not roomDef then return end

    -- Check room limit
    if #profile.stationRooms >= Constants.STATION.MAX_ROOMS then
        return
    end

    -- Check slot not occupied
    for _, placed in profile.stationRooms do
        if placed.slotIndex == slotIndex then
            return
        end
    end

    -- Check not already built (no duplicates)
    for _, placed in profile.stationRooms do
        if placed.roomId == roomId then
            return
        end
    end

    -- Check quest unlock
    if roomDef.unlockQuestId then
        local unlocked = false
        for _, completedId in profile.completedQuests do
            if completedId == roomDef.unlockQuestId then
                unlocked = true
                break
            end
        end
        if not unlocked then return end
    end

    -- Check and consume materials
    for _, cost in roomDef.cost do
        if not InventoryServer:HasItem(player, cost.itemId, cost.quantity) then
            return -- Not enough materials
        end
    end

    -- Consume materials
    for _, cost in roomDef.cost do
        InventoryServer:RemoveItem(player, cost.itemId, cost.quantity)
    end

    -- Place the room
    table.insert(profile.stationRooms, {
        roomId = roomId,
        slotIndex = slotIndex,
    })

    -- Visual: Update the build slot in workspace
    self:_visualizeBuildSlot(slotIndex, roomDef)

    -- Disable the ProximityPrompt on that slot
    local stationFolder = workspace:FindFirstChild("Station")
    if stationFolder then
        local buildSlots = stationFolder:FindFirstChild("BuildSlots")
        if buildSlots then
            local slotPart = buildSlots:FindFirstChild("Slot_" .. slotIndex)
            if slotPart then
                local prompt = slotPart:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    prompt.Enabled = false
                end
            end
        end
    end

    -- Notify client
    local RoomBuilt = Remotes:FindFirstChild("RoomBuilt") :: RemoteEvent?
    if RoomBuilt then
        RoomBuilt:FireClient(player, "built", {
            roomId = roomId,
            roomName = roomDef.name,
            slotIndex = slotIndex,
        })
    end

    -- Celebration
    local TriggerCelebration = Remotes:FindFirstChild("TriggerCelebration") :: RemoteEvent?
    if TriggerCelebration then
        TriggerCelebration:FireClient(player, "room_built", { roomName = roomDef.name })
    end

    -- Notify QuestManager
    local totalRooms = #profile.stationRooms
    if QuestManager and type(QuestManager.OnRoomBuilt) == "function" then
        QuestManager:OnRoomBuilt(player, roomId, totalRooms)
    end

    print("[StationBuilder] " .. player.Name .. " built: " .. roomDef.name .. " in slot " .. slotIndex)
end

---------------------------------------------------------------------------
-- Visualize a built room on a slot (placeholder)
---------------------------------------------------------------------------
function StationBuilder:_visualizeBuildSlot(slotIndex: number, roomDef: any)
    local stationFolder = workspace:FindFirstChild("Station")
    if not stationFolder then return end

    local buildSlots = stationFolder:FindFirstChild("BuildSlots")
    if not buildSlots then return end

    local slotPart = buildSlots:FindFirstChild("Slot_" .. slotIndex)
    if not slotPart or not slotPart:IsA("BasePart") then return end

    -- Simple visualization: make slot opaque and colored
    slotPart.Transparency = 0
    slotPart.BrickColor = BrickColor.new("Bright green")
    slotPart.Material = Enum.Material.SmoothPlastic

    -- Add a name label
    local existingGui = slotPart:FindFirstChildOfClass("BillboardGui")
    if existingGui then existingGui:Destroy() end

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 150, 0, 40)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = slotPart

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromHex("5cd43e")
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 18
    nameLabel.Text = roomDef.name
    nameLabel.Parent = billboardGui
end

return StationBuilder
