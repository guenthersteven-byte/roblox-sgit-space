--!strict
--[[
    StationUI.lua
    Client-side station building interface.
    Shows available rooms when player interacts with a build slot.
    Toggle with B key for overview.
]]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Items = require(ReplicatedStorage:WaitForChild("Items"))
local StationRooms = require(ReplicatedStorage:WaitForChild("StationRooms"))

local StationUI = {}
StationUI.__index = StationUI

local player: Player = nil
local Remotes = nil
local UIController = nil

local buildPanel: Frame = nil
local roomList: ScrollingFrame = nil
local currentSlotIndex: number? = nil
local builtRooms: { any } = {}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function StationUI:Init(plr: Player, remotes: any)
    player = plr
    Remotes = remotes

    local Controllers = script.Parent
    UIController = require(Controllers:WaitForChild("UIController"))
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------
function StationUI:Start()
    local screenGui = UIController:GetScreenGui()
    self:_buildUI(screenGui)
    self:_connectEvents()
    print("[StationUI] Ready")
end

---------------------------------------------------------------------------
-- Full sync
---------------------------------------------------------------------------
function StationUI:OnFullSync(data: any)
    if data then
        builtRooms = data.stationRooms or {}
    end
end

---------------------------------------------------------------------------
-- Build UI
---------------------------------------------------------------------------
function StationUI:_buildUI(screenGui: ScreenGui)
    buildPanel = UIController.CreateFrame(
        screenGui,
        "StationBuildPanel",
        UDim2.new(0, 450, 0, 520),
        UDim2.new(0.5, -225, 0.5, -260)
    )
    buildPanel.Visible = false

    -- Title
    local title = UIController.CreateLabel(
        buildPanel,
        "Title",
        "Station bauen",
        UDim2.new(1, -20, 0, 40),
        UDim2.new(0, 10, 0, 5)
    )
    title.Font = Constants.FONTS.HEADING
    title.TextSize = Constants.UI.TEXT_SIZE_LARGE
    title.TextXAlignment = Enum.TextXAlignment.Center

    -- Slot info label
    local slotLabel = UIController.CreateLabel(
        buildPanel,
        "SlotInfo",
        "",
        UDim2.new(1, -20, 0, 25),
        UDim2.new(0, 10, 0, 40)
    )
    slotLabel.TextSize = Constants.UI.TEXT_SIZE_SMALL
    slotLabel.TextXAlignment = Enum.TextXAlignment.Center
    slotLabel.TextColor3 = Constants.COLORS.DISABLED

    -- Close button
    local closeBtn = UIController.CreateButton(
        buildPanel,
        "CloseBtn",
        "X",
        UDim2.new(0, 40, 0, 40),
        UDim2.new(1, -45, 0, 5)
    )
    closeBtn.BackgroundColor3 = Constants.COLORS.PRIMARY
    closeBtn.MouseButton1Click:Connect(function()
        buildPanel.Visible = false
        currentSlotIndex = nil
    end)

    -- Scrollable room list
    roomList = Instance.new("ScrollingFrame")
    roomList.Name = "RoomList"
    roomList.Size = UDim2.new(1, -20, 1, -80)
    roomList.Position = UDim2.new(0, 10, 0, 70)
    roomList.BackgroundTransparency = 1
    roomList.ScrollBarThickness = 8
    roomList.ScrollBarImageColor3 = Constants.COLORS.ACCENT
    roomList.CanvasSize = UDim2.new(0, 0, 0, 0)
    roomList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    roomList.Parent = buildPanel

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = roomList

    UIController:RegisterPanel("station", buildPanel)
end

---------------------------------------------------------------------------
-- Show build menu for a specific slot
---------------------------------------------------------------------------
function StationUI:_showBuildMenu(slotIndex: number, availableRooms: { any })
    currentSlotIndex = slotIndex
    buildPanel.Visible = true

    -- Update slot info
    local slotLabel = buildPanel:FindFirstChild("SlotInfo") :: TextLabel?
    if slotLabel then
        slotLabel.Text = "Bauplatz " .. slotIndex
    end

    -- Close other panels
    UIController:CloseAllPanels()
    buildPanel.Visible = true

    -- Build room cards
    self:_refreshRoomCards(availableRooms)
end

---------------------------------------------------------------------------
-- Refresh room cards
---------------------------------------------------------------------------
function StationUI:_refreshRoomCards(rooms: { any })
    -- Clear old cards
    for _, child in roomList:GetChildren() do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for idx, roomInfo in rooms do
        self:_createRoomCard(roomList, roomInfo, idx)
    end
end

---------------------------------------------------------------------------
-- Create a room card
---------------------------------------------------------------------------
function StationUI:_createRoomCard(parent: ScrollingFrame, roomInfo: any, layoutOrder: number): Frame
    local canBuild = roomInfo.canBuild
    local alreadyBuilt = roomInfo.alreadyBuilt

    local card = Instance.new("Frame")
    card.Name = "Room_" .. roomInfo.roomId
    card.Size = UDim2.new(1, -10, 0, 130)
    card.BackgroundColor3 = alreadyBuilt and Constants.COLORS.DARK or (canBuild and Constants.COLORS.PRIMARY or Constants.COLORS.DARK)
    card.BorderSizePixel = 0
    card.LayoutOrder = layoutOrder
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    if alreadyBuilt then
        local builtStroke = Instance.new("UIStroke")
        builtStroke.Color = Constants.COLORS.GLOW
        builtStroke.Thickness = 2
        builtStroke.Parent = card
    end

    -- Room name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(0.6, 0, 0, 30)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = alreadyBuilt and Constants.COLORS.GLOW or Constants.COLORS.WHITE
    nameLabel.Font = Constants.FONTS.HEADING
    nameLabel.TextSize = Constants.UI.TEXT_SIZE_MEDIUM
    nameLabel.Text = roomInfo.name .. (alreadyBuilt and " (gebaut)" or "")
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card

    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.6, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 32)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = Constants.COLORS.DISABLED
    descLabel.Font = Constants.FONTS.BODY
    descLabel.TextSize = 14
    descLabel.Text = roomInfo.description
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextTruncate = Enum.TextTruncate.AtEnd
    descLabel.Parent = card

    -- Materials list
    if roomInfo.cost then
        local matY = 55
        for _, costItem in roomInfo.cost do
            local itemDef = Items.get(costItem.itemId)
            local matName = itemDef and itemDef.name or costItem.itemId
            local hasEnough = costItem.owned >= costItem.required

            local matLabel = Instance.new("TextLabel")
            matLabel.Size = UDim2.new(0.6, 0, 0, 18)
            matLabel.Position = UDim2.new(0, 15, 0, matY)
            matLabel.BackgroundTransparency = 1
            matLabel.TextColor3 = alreadyBuilt and Constants.COLORS.DISABLED or (hasEnough and Constants.COLORS.GLOW or Constants.COLORS.WARNING)
            matLabel.Font = Constants.FONTS.BODY
            matLabel.TextSize = Constants.UI.TEXT_SIZE_SMALL
            matLabel.Text = matName .. ": " .. costItem.owned .. "/" .. costItem.required
            matLabel.TextXAlignment = Enum.TextXAlignment.Left
            matLabel.Parent = card

            matY += 18
        end
    end

    -- Build button
    if not alreadyBuilt then
        local buildBtn = UIController.CreateButton(
            card,
            "BuildBtn",
            canBuild and "Bauen!" or "---",
            UDim2.new(0, 100, 0, 45),
            UDim2.new(1, -115, 0.5, -22)
        )
        buildBtn.BackgroundColor3 = canBuild and Constants.COLORS.ACCENT or Constants.COLORS.DISABLED

        if canBuild and currentSlotIndex then
            local slot = currentSlotIndex
            buildBtn.MouseButton1Click:Connect(function()
                -- Send build request to server
                local RequestBuildRoom = Remotes:FindFirstChild("RequestBuildRoom") :: RemoteEvent?
                if RequestBuildRoom then
                    RequestBuildRoom:FireServer(roomInfo.roomId, slot)
                    buildBtn.Text = "..."
                    buildBtn.BackgroundColor3 = Constants.COLORS.DISABLED

                    -- Panel will be updated by RoomBuilt event
                end
            end)
        end
    end

    return card
end

---------------------------------------------------------------------------
-- Connect events
---------------------------------------------------------------------------
function StationUI:_connectEvents()
    -- B key toggles station build overview
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.B then
            UIController:TogglePanel("station")
        end
    end)

    -- Listen for room built / show menu events from server
    local RoomBuilt = Remotes:WaitForChild("RoomBuilt") :: RemoteEvent
    RoomBuilt.OnClientEvent:Connect(function(eventType: string, data: any)
        if eventType == "show_menu" then
            -- Server sends available rooms for a build slot
            self:_showBuildMenu(data.slotIndex, data.availableRooms)
        elseif eventType == "built" then
            -- Room was successfully built
            table.insert(builtRooms, {
                roomId = data.roomId,
                slotIndex = data.slotIndex,
            })

            -- Close panel
            buildPanel.Visible = false
            currentSlotIndex = nil
        end
    end)
end

return StationUI
