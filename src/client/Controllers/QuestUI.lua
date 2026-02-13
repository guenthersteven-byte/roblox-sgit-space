--!strict
--[[
    QuestUI.lua
    Client-side quest tracker panel.
    Shows current quest with picture-based objectives (large icons for kids).
    Always visible as a small tracker, expandable with Q key.
]]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Items = require(ReplicatedStorage:WaitForChild("Items"))

local QuestUI = {}
QuestUI.__index = QuestUI

local player: Player = nil
local Remotes = nil
local UIController = nil

local trackerFrame: Frame = nil   -- Small always-visible tracker
local questPanel: Frame = nil     -- Full expanded quest panel
local currentQuestData: any = nil
local currentProgress: any = nil

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function QuestUI:Init(plr: Player, remotes: any)
    player = plr
    Remotes = remotes

    local Controllers = script.Parent
    UIController = require(Controllers:WaitForChild("UIController"))
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------
function QuestUI:Start()
    local screenGui = UIController:GetScreenGui()
    self:_buildTracker(screenGui)
    self:_buildPanel(screenGui)
    self:_connectEvents()
    print("[QuestUI] Ready")
end

---------------------------------------------------------------------------
-- Full sync
---------------------------------------------------------------------------
function QuestUI:OnFullSync(data: any)
    if data then
        self:_updateQuestDisplay({
            currentQuestId = data.currentQuestId,
            currentQuest = nil, -- Will be populated by QuestUpdated event
            progress = nil,
            completedQuests = data.completedQuests or {},
            unlockedRecipes = data.unlockedRecipes or {},
            unlockedPlanets = data.unlockedPlanets or {},
        })
    end
end

---------------------------------------------------------------------------
-- Build mini tracker (top-left below HUD)
---------------------------------------------------------------------------
function QuestUI:_buildTracker(screenGui: ScreenGui)
    trackerFrame = Instance.new("Frame")
    trackerFrame.Name = "QuestTracker"
    trackerFrame.Size = UDim2.new(0, 240, 0, 80)
    trackerFrame.Position = UDim2.new(0, 15, 0, 140) -- Below status bars
    trackerFrame.BackgroundColor3 = Constants.COLORS.SURFACE
    trackerFrame.BackgroundTransparency = 0.3
    trackerFrame.BorderSizePixel = 0
    trackerFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = Constants.UI.CORNER_RADIUS
    corner.Parent = trackerFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromHex("f5a623") -- Gold for quests
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = trackerFrame

    -- Quest icon
    local questIcon = Instance.new("TextLabel")
    questIcon.Name = "QuestIcon"
    questIcon.Size = UDim2.new(0, 30, 0, 30)
    questIcon.Position = UDim2.new(0, 8, 0, 8)
    questIcon.BackgroundTransparency = 1
    questIcon.TextColor3 = Color3.fromHex("f5a623")
    questIcon.Font = Constants.FONTS.HEADING
    questIcon.TextSize = 24
    questIcon.Text = "!"
    questIcon.Parent = trackerFrame

    -- Quest name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "QuestName"
    nameLabel.Size = UDim2.new(1, -50, 0, 25)
    nameLabel.Position = UDim2.new(0, 42, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Constants.COLORS.WHITE
    nameLabel.Font = Constants.FONTS.HEADING
    nameLabel.TextSize = 16
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Text = "Lade Quest..."
    nameLabel.Parent = trackerFrame

    -- Progress text
    local progressLabel = Instance.new("TextLabel")
    progressLabel.Name = "ProgressText"
    progressLabel.Size = UDim2.new(1, -50, 0, 20)
    progressLabel.Position = UDim2.new(0, 42, 0, 30)
    progressLabel.BackgroundTransparency = 1
    progressLabel.TextColor3 = Constants.COLORS.GLOW
    progressLabel.Font = Constants.FONTS.BODY
    progressLabel.TextSize = 14
    progressLabel.TextXAlignment = Enum.TextXAlignment.Left
    progressLabel.Text = ""
    progressLabel.Parent = trackerFrame

    -- Progress bar
    local progressBar = UIController.CreateProgressBar(
        trackerFrame,
        "ProgressBar",
        UDim2.new(1, -20, 0, 8),
        UDim2.new(0, 10, 1, -18),
        Color3.fromHex("f5a623")
    )

    -- Click to expand
    local clickBtn = Instance.new("TextButton")
    clickBtn.Name = "ExpandBtn"
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = trackerFrame
    clickBtn.MouseButton1Click:Connect(function()
        UIController:TogglePanel("quest")
    end)
end

---------------------------------------------------------------------------
-- Build full quest panel (expandable)
---------------------------------------------------------------------------
function QuestUI:_buildPanel(screenGui: ScreenGui)
    questPanel = UIController.CreateFrame(
        screenGui,
        "QuestPanel",
        UDim2.new(0, 400, 0, 450),
        UDim2.new(0.5, -200, 0.5, -225)
    )
    questPanel.Visible = false

    -- Title
    local title = UIController.CreateLabel(
        questPanel,
        "Title",
        "Quest",
        UDim2.new(1, -20, 0, 40),
        UDim2.new(0, 10, 0, 5)
    )
    title.Font = Constants.FONTS.HEADING
    title.TextSize = Constants.UI.TEXT_SIZE_LARGE
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.TextColor3 = Color3.fromHex("f5a623")

    -- Close button
    local closeBtn = UIController.CreateButton(
        questPanel,
        "CloseBtn",
        "X",
        UDim2.new(0, 40, 0, 40),
        UDim2.new(1, -45, 0, 5)
    )
    closeBtn.BackgroundColor3 = Constants.COLORS.PRIMARY
    closeBtn.MouseButton1Click:Connect(function()
        questPanel.Visible = false
    end)

    -- Quest content area (scrollable)
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 50)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 6
    content.ScrollBarImageColor3 = Color3.fromHex("f5a623")
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = questPanel

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = content

    UIController:RegisterPanel("quest", questPanel)
end

---------------------------------------------------------------------------
-- Update quest display
---------------------------------------------------------------------------
function QuestUI:_updateQuestDisplay(data: any)
    currentQuestData = data

    local nameLabel = trackerFrame:FindFirstChild("QuestName") :: TextLabel?
    local progressLabel = trackerFrame:FindFirstChild("ProgressText") :: TextLabel?
    local progressBar = trackerFrame:FindFirstChild("ProgressBar") :: Frame?

    if not data or not data.currentQuest then
        if nameLabel then
            if data and not data.currentQuestId then
                nameLabel.Text = "Alle Quests geschafft!"
            else
                nameLabel.Text = "Lade Quest..."
            end
        end
        if progressLabel then progressLabel.Text = "" end
        if progressBar then UIController.SetProgressBar(progressBar, 1) end
        return
    end

    local quest = data.currentQuest
    local progress = data.progress

    -- Update tracker
    if nameLabel then
        nameLabel.Text = quest.name
    end

    if progress and progressLabel then
        local totalDone = 0
        local totalNeeded = 0
        for i, obj in quest.objectives do
            totalNeeded += obj.targetCount
            totalDone += math.min(progress.objectiveProgress[i] or 0, obj.targetCount)
        end
        progressLabel.Text = totalDone .. " / " .. totalNeeded
        if progressBar then
            UIController.SetProgressBar(progressBar, totalNeeded > 0 and totalDone / totalNeeded or 0)
        end
    end

    -- Update full panel
    self:_refreshPanel(quest, progress)
end

---------------------------------------------------------------------------
-- Refresh the full quest panel
---------------------------------------------------------------------------
function QuestUI:_refreshPanel(quest: any, progress: any)
    local content = questPanel:FindFirstChild("Content") :: ScrollingFrame?
    if not content then return end

    -- Clear old content
    for _, child in content:GetChildren() do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    -- Quest description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, 0, 0, 50)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = Constants.COLORS.WHITE
    descLabel.Font = Constants.FONTS.BODY
    descLabel.TextSize = Constants.UI.TEXT_SIZE_MEDIUM
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Text = quest.description
    descLabel.LayoutOrder = 1
    descLabel.Parent = content

    -- Objectives
    for i, objective in quest.objectives do
        local objFrame = Instance.new("Frame")
        objFrame.Name = "Objective_" .. i
        objFrame.Size = UDim2.new(1, 0, 0, 60)
        objFrame.BackgroundColor3 = Constants.COLORS.DARK
        objFrame.BorderSizePixel = 0
        objFrame.LayoutOrder = i + 1
        objFrame.Parent = content

        local objCorner = Instance.new("UICorner")
        objCorner.CornerRadius = UDim.new(0, 8)
        objCorner.Parent = objFrame

        local done = progress and (progress.objectiveProgress[i] or 0) or 0
        local needed = objective.targetCount
        local isComplete = done >= needed

        -- Checkmark or progress
        local checkLabel = Instance.new("TextLabel")
        checkLabel.Size = UDim2.new(0, 40, 0, 40)
        checkLabel.Position = UDim2.new(0, 5, 0.5, -20)
        checkLabel.BackgroundTransparency = 1
        checkLabel.TextColor3 = isComplete and Constants.COLORS.GLOW or Constants.COLORS.DISABLED
        checkLabel.Font = Constants.FONTS.HEADING
        checkLabel.TextSize = 28
        checkLabel.Text = isComplete and "OK" or (done .. "/" .. needed)
        checkLabel.Parent = objFrame

        -- Objective description
        local objText = self:_getObjectiveText(objective)
        local objLabel = Instance.new("TextLabel")
        objLabel.Size = UDim2.new(1, -55, 0, 40)
        objLabel.Position = UDim2.new(0, 50, 0.5, -20)
        objLabel.BackgroundTransparency = 1
        objLabel.TextColor3 = isComplete and Constants.COLORS.GLOW or Constants.COLORS.WHITE
        objLabel.Font = Constants.FONTS.BODY
        objLabel.TextSize = 18
        objLabel.TextXAlignment = Enum.TextXAlignment.Left
        objLabel.TextWrapped = true
        objLabel.Text = objText
        objLabel.Parent = objFrame

        -- Progress bar for this objective
        local objBar = UIController.CreateProgressBar(
            objFrame,
            "ObjBar",
            UDim2.new(1, -60, 0, 6),
            UDim2.new(0, 50, 1, -12),
            isComplete and Constants.COLORS.GLOW or Color3.fromHex("f5a623")
        )
        UIController.SetProgressBar(objBar, needed > 0 and done / needed or 0)
    end

    -- Rewards section
    if quest.rewards and #quest.rewards > 0 then
        local rewardTitle = Instance.new("TextLabel")
        rewardTitle.Name = "RewardTitle"
        rewardTitle.Size = UDim2.new(1, 0, 0, 30)
        rewardTitle.BackgroundTransparency = 1
        rewardTitle.TextColor3 = Color3.fromHex("f5a623")
        rewardTitle.Font = Constants.FONTS.HEADING
        rewardTitle.TextSize = 20
        rewardTitle.TextXAlignment = Enum.TextXAlignment.Left
        rewardTitle.Text = "Belohnung:"
        rewardTitle.LayoutOrder = 100
        rewardTitle.Parent = content

        for ri, reward in quest.rewards do
            local itemDef = Items.get(reward.itemId)
            local rewardLabel = Instance.new("TextLabel")
            rewardLabel.Size = UDim2.new(1, 0, 0, 25)
            rewardLabel.BackgroundTransparency = 1
            rewardLabel.TextColor3 = Constants.COLORS.GLOW
            rewardLabel.Font = Constants.FONTS.BODY
            rewardLabel.TextSize = 16
            rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
            rewardLabel.Text = "  " .. (itemDef and itemDef.name or reward.itemId) .. " x" .. reward.quantity
            rewardLabel.LayoutOrder = 100 + ri
            rewardLabel.Parent = content
        end
    end
end

---------------------------------------------------------------------------
-- Get human-readable objective text
---------------------------------------------------------------------------
function QuestUI:_getObjectiveText(objective: any): string
    local targetName = objective.targetId

    if objective.type == "gather" then
        local itemDef = Items.get(objective.targetId)
        if itemDef then targetName = itemDef.name end
        return "Sammle " .. objective.targetCount .. "x " .. targetName
    elseif objective.type == "craft" then
        local itemDef = Items.get(objective.targetId)
        if itemDef then targetName = itemDef.name end
        return "Baue " .. objective.targetCount .. "x " .. targetName
    elseif objective.type == "build_room" then
        if objective.targetId == "any" then
            return "Baue " .. objective.targetCount .. " Raum/Raeume"
        end
        return "Baue: " .. targetName
    elseif objective.type == "tame_alien" then
        return "Zaehme: " .. targetName
    elseif objective.type == "visit_planet" then
        return "Besuche: " .. targetName
    elseif objective.type == "talk_npc" then
        return "Sprich mit: " .. targetName
    end

    return objective.type .. ": " .. targetName
end

---------------------------------------------------------------------------
-- Connect events
---------------------------------------------------------------------------
function QuestUI:_connectEvents()
    -- Q key toggles quest panel
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Q then
            UIController:TogglePanel("quest")
        end
    end)

    -- Listen for quest updates from server
    local QuestUpdated = Remotes:WaitForChild("QuestUpdated") :: RemoteEvent
    QuestUpdated.OnClientEvent:Connect(function(data: any)
        self:_updateQuestDisplay(data)
    end)
end

return QuestUI
