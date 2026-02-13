--!strict
--[[
    InventoryUI.lua
    Client-side inventory display. Grid layout with large slots for kids.
    Toggle with Tab key or inventory button.
]]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Items = require(ReplicatedStorage:WaitForChild("Items"))

local InventoryUI = {}
InventoryUI.__index = InventoryUI

local player: Player = nil
local Remotes = nil
local UIController = nil

local inventoryFrame: Frame = nil
local slotFrames: { Frame } = {}
local currentInventory: { any } = {}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function InventoryUI:Init(plr: Player, remotes: any)
    player = plr
    Remotes = remotes

    -- Get UIController reference
    local Controllers = script.Parent
    UIController = require(Controllers:WaitForChild("UIController"))
end

---------------------------------------------------------------------------
-- Start: Build UI and connect events
---------------------------------------------------------------------------
function InventoryUI:Start()
    local screenGui = UIController:GetScreenGui()
    self:_buildUI(screenGui)
    self:_connectEvents()
    print("[InventoryUI] Ready")
end

---------------------------------------------------------------------------
-- Full sync handler
---------------------------------------------------------------------------
function InventoryUI:OnFullSync(data: any)
    if data and data.inventory then
        currentInventory = data.inventory
        self:_refreshSlots()
    end
end

---------------------------------------------------------------------------
-- Build the inventory UI
---------------------------------------------------------------------------
function InventoryUI:_buildUI(screenGui: ScreenGui)
    -- Main inventory frame (center of screen)
    inventoryFrame = UIController.CreateFrame(
        screenGui,
        "InventoryPanel",
        UDim2.new(0, 420, 0, 480),
        UDim2.new(0.5, -210, 0.5, -240)
    )
    inventoryFrame.Visible = false

    -- Title
    local title = UIController.CreateLabel(
        inventoryFrame,
        "Title",
        "Inventar",
        UDim2.new(1, -20, 0, 40),
        UDim2.new(0, 10, 0, 5)
    )
    title.Font = Constants.FONTS.HEADING
    title.TextSize = Constants.UI.TEXT_SIZE_LARGE
    title.TextXAlignment = Enum.TextXAlignment.Center

    -- Close button
    local closeBtn = UIController.CreateButton(
        inventoryFrame,
        "CloseBtn",
        "X",
        UDim2.new(0, 40, 0, 40),
        UDim2.new(1, -45, 0, 5)
    )
    closeBtn.BackgroundColor3 = Constants.COLORS.PRIMARY
    closeBtn.MouseButton1Click:Connect(function()
        inventoryFrame.Visible = false
    end)

    -- Grid container
    local grid = Instance.new("Frame")
    grid.Name = "Grid"
    grid.Size = UDim2.new(1, -20, 1, -60)
    grid.Position = UDim2.new(0, 10, 0, 50)
    grid.BackgroundTransparency = 1
    grid.Parent = inventoryFrame

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 72, 0, 72)
    gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = grid

    -- Create slots
    for i = 1, Constants.INVENTORY.MAX_SLOTS do
        local slot = self:_createSlot(grid, i)
        table.insert(slotFrames, slot)
    end

    -- Register panel for toggle management
    UIController:RegisterPanel("inventory", inventoryFrame)
end

---------------------------------------------------------------------------
-- Create a single inventory slot
---------------------------------------------------------------------------
function InventoryUI:_createSlot(parent: Frame, index: number): Frame
    local slot = Instance.new("Frame")
    slot.Name = "Slot_" .. index
    slot.BackgroundColor3 = Constants.COLORS.DARK
    slot.BorderSizePixel = 0
    slot.LayoutOrder = index
    slot.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = slot

    local stroke = Instance.new("UIStroke")
    stroke.Name = "Border"
    stroke.Color = Constants.COLORS.PRIMARY
    stroke.Thickness = 2
    stroke.Parent = slot

    -- Item icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0.8, 0, 0.8, 0)
    icon.Position = UDim2.new(0.1, 0, 0.05, 0)
    icon.BackgroundTransparency = 1
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Image = ""
    icon.Parent = slot

    -- Quantity label
    local qty = Instance.new("TextLabel")
    qty.Name = "Quantity"
    qty.Size = UDim2.new(0.5, 0, 0.3, 0)
    qty.Position = UDim2.new(0.5, 0, 0.7, 0)
    qty.BackgroundTransparency = 1
    qty.TextColor3 = Constants.COLORS.WHITE
    qty.Font = Constants.FONTS.BUTTON
    qty.TextSize = 16
    qty.Text = ""
    qty.TextXAlignment = Enum.TextXAlignment.Right
    qty.Parent = slot

    return slot
end

---------------------------------------------------------------------------
-- Refresh slot display from current inventory data
---------------------------------------------------------------------------
function InventoryUI:_refreshSlots()
    for i, slot in slotFrames do
        local icon = slot:FindFirstChild("Icon") :: ImageLabel
        local qty = slot:FindFirstChild("Quantity") :: TextLabel
        local border = slot:FindFirstChild("Border") :: UIStroke

        local inventorySlot = currentInventory[i]

        if inventorySlot and inventorySlot.itemId then
            local itemDef = Items.get(inventorySlot.itemId)
            if itemDef then
                icon.Image = itemDef.icon
                qty.Text = tostring(inventorySlot.quantity)
                border.Color = Constants.COLORS.ACCENT
            end
        else
            icon.Image = ""
            qty.Text = ""
            border.Color = Constants.COLORS.PRIMARY
        end
    end
end

---------------------------------------------------------------------------
-- Connect events
---------------------------------------------------------------------------
function InventoryUI:_connectEvents()
    -- Tab key toggles inventory
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Tab then
            UIController:TogglePanel("inventory")
        end
    end)

    -- Listen for inventory updates from server
    local InventoryChanged = Remotes:WaitForChild("InventoryChanged") :: RemoteEvent
    InventoryChanged.OnClientEvent:Connect(function(inventory: any, _hotbar: any)
        currentInventory = inventory or {}
        self:_refreshSlots()
    end)
end

return InventoryUI
