--!strict
--[[
    CraftingUI.lua
    Client-side crafting interface.
    Shows available recipes, required materials, and craft button.
    Toggle with C key.
]]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Items = require(ReplicatedStorage:WaitForChild("Items"))
local Recipes = require(ReplicatedStorage:WaitForChild("Recipes"))

local CraftingUI = {}
CraftingUI.__index = CraftingUI

local player: Player = nil
local Remotes = nil
local UIController = nil

local craftingFrame: Frame = nil
local recipeList: ScrollingFrame = nil
local currentInventory: { any } = {}
local unlockedRecipes: { string } = {}
local isCrafting = false

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function CraftingUI:Init(plr: Player, remotes: any)
    player = plr
    Remotes = remotes

    local Controllers = script.Parent
    UIController = require(Controllers:WaitForChild("UIController"))
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------
function CraftingUI:Start()
    local screenGui = UIController:GetScreenGui()
    self:_buildUI(screenGui)
    self:_connectEvents()
    print("[CraftingUI] Ready")
end

---------------------------------------------------------------------------
-- Full sync
---------------------------------------------------------------------------
function CraftingUI:OnFullSync(data: any)
    if data then
        currentInventory = data.inventory or {}
        unlockedRecipes = data.unlockedRecipes or {}
        self:_refreshRecipes()
    end
end

---------------------------------------------------------------------------
-- Build UI
---------------------------------------------------------------------------
function CraftingUI:_buildUI(screenGui: ScreenGui)
    craftingFrame = UIController.CreateFrame(
        screenGui,
        "CraftingPanel",
        UDim2.new(0, 450, 0, 520),
        UDim2.new(0.5, -225, 0.5, -260)
    )
    craftingFrame.Visible = false

    -- Title
    local title = UIController.CreateLabel(
        craftingFrame,
        "Title",
        "Crafting",
        UDim2.new(1, -20, 0, 40),
        UDim2.new(0, 10, 0, 5)
    )
    title.Font = Constants.FONTS.HEADING
    title.TextSize = Constants.UI.TEXT_SIZE_LARGE
    title.TextXAlignment = Enum.TextXAlignment.Center

    -- Close button
    local closeBtn = UIController.CreateButton(
        craftingFrame,
        "CloseBtn",
        "X",
        UDim2.new(0, 40, 0, 40),
        UDim2.new(1, -45, 0, 5)
    )
    closeBtn.BackgroundColor3 = Constants.COLORS.PRIMARY
    closeBtn.MouseButton1Click:Connect(function()
        craftingFrame.Visible = false
    end)

    -- Scrollable recipe list
    recipeList = Instance.new("ScrollingFrame")
    recipeList.Name = "RecipeList"
    recipeList.Size = UDim2.new(1, -20, 1, -60)
    recipeList.Position = UDim2.new(0, 10, 0, 50)
    recipeList.BackgroundTransparency = 1
    recipeList.ScrollBarThickness = 8
    recipeList.ScrollBarImageColor3 = Constants.COLORS.ACCENT
    recipeList.CanvasSize = UDim2.new(0, 0, 0, 0)
    recipeList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    recipeList.Parent = craftingFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = recipeList

    UIController:RegisterPanel("crafting", craftingFrame)
end

---------------------------------------------------------------------------
-- Create a recipe card
---------------------------------------------------------------------------
function CraftingUI:_createRecipeCard(parent: ScrollingFrame, recipe: any, canCraft: boolean): Frame
    local card = Instance.new("Frame")
    card.Name = "Recipe_" .. recipe.id
    card.Size = UDim2.new(1, -10, 0, 100)
    card.BackgroundColor3 = canCraft and Constants.COLORS.PRIMARY or Constants.COLORS.DARK
    card.BorderSizePixel = 0
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    -- Result item name
    local resultItem = Items.get(recipe.result.itemId)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(0.6, 0, 0, 30)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Constants.COLORS.WHITE
    nameLabel.Font = Constants.FONTS.HEADING
    nameLabel.TextSize = Constants.UI.TEXT_SIZE_MEDIUM
    nameLabel.Text = resultItem and resultItem.name or recipe.name
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card

    -- Ingredients list
    local ingredientY = 35
    for _, ingredient in recipe.ingredients do
        local ingItem = Items.get(ingredient.itemId)
        local ingName = ingItem and ingItem.name or ingredient.itemId
        local owned = self:_getItemCount(ingredient.itemId)
        local hasEnough = owned >= ingredient.quantity

        local ingLabel = Instance.new("TextLabel")
        ingLabel.Size = UDim2.new(0.6, 0, 0, 20)
        ingLabel.Position = UDim2.new(0, 15, 0, ingredientY)
        ingLabel.BackgroundTransparency = 1
        ingLabel.TextColor3 = hasEnough and Constants.COLORS.GLOW or Constants.COLORS.WARNING
        ingLabel.Font = Constants.FONTS.BODY
        ingLabel.TextSize = Constants.UI.TEXT_SIZE_SMALL
        ingLabel.Text = ingName .. ": " .. owned .. "/" .. ingredient.quantity
        ingLabel.TextXAlignment = Enum.TextXAlignment.Left
        ingLabel.Parent = card

        ingredientY += 20
    end

    -- Craft button
    local craftBtn = UIController.CreateButton(
        card,
        "CraftBtn",
        canCraft and "Bauen!" or "---",
        UDim2.new(0, 100, 0, 40),
        UDim2.new(1, -115, 0.5, -20)
    )
    craftBtn.BackgroundColor3 = canCraft and Constants.COLORS.ACCENT or Constants.COLORS.DISABLED

    if canCraft then
        craftBtn.MouseButton1Click:Connect(function()
            if isCrafting then return end
            isCrafting = true
            craftBtn.Text = "..."

            local RequestCraft = Remotes:FindFirstChild("RequestCraft") :: RemoteEvent?
            if RequestCraft then
                RequestCraft:FireServer(recipe.id)
            end

            -- Reset after timeout (server will respond via CraftResult)
            task.delay(10, function()
                isCrafting = false
                if craftBtn and craftBtn.Parent then
                    craftBtn.Text = "Bauen!"
                end
            end)
        end)
    end

    return card
end

---------------------------------------------------------------------------
-- Refresh recipe list
---------------------------------------------------------------------------
function CraftingUI:_refreshRecipes()
    -- Clear existing cards
    for _, child in recipeList:GetChildren() do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- Build recipe cards for unlocked recipes
    local allRecipes = Recipes.getAll()
    for _, recipe in allRecipes do
        -- Check if unlocked
        local isUnlocked = false
        for _, id in unlockedRecipes do
            if id == recipe.id then
                isUnlocked = true
                break
            end
        end

        if isUnlocked then
            local canCraft = self:_canCraftLocally(recipe)
            self:_createRecipeCard(recipeList, recipe, canCraft)
        end
    end
end

---------------------------------------------------------------------------
-- Local check if player has materials (for UI display only)
---------------------------------------------------------------------------
function CraftingUI:_canCraftLocally(recipe: any): boolean
    for _, ingredient in recipe.ingredients do
        if self:_getItemCount(ingredient.itemId) < ingredient.quantity then
            return false
        end
    end
    return true
end

---------------------------------------------------------------------------
-- Get item count from local inventory cache
---------------------------------------------------------------------------
function CraftingUI:_getItemCount(itemId: string): number
    local total = 0
    for _, slot in currentInventory do
        if slot.itemId == itemId then
            total += slot.quantity
        end
    end
    return total
end

---------------------------------------------------------------------------
-- Connect events
---------------------------------------------------------------------------
function CraftingUI:_connectEvents()
    -- C key toggles crafting
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.C then
            UIController:TogglePanel("crafting")
        end
    end)

    -- Listen for inventory changes to refresh craft availability
    local InventoryChanged = Remotes:WaitForChild("InventoryChanged") :: RemoteEvent
    InventoryChanged.OnClientEvent:Connect(function(inventory: any, _hotbar: any)
        currentInventory = inventory or {}
        if craftingFrame.Visible then
            self:_refreshRecipes()
        end
    end)

    -- Listen for craft results
    local CraftResult = Remotes:WaitForChild("CraftResult") :: RemoteEvent
    CraftResult.OnClientEvent:Connect(function(result: any)
        isCrafting = false
        if craftingFrame.Visible then
            self:_refreshRecipes()
        end
    end)
end

return CraftingUI
