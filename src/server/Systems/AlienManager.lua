--!strict
--[[
    AlienManager.lua
    Server-side alien AI with simple FSM (Finite State Machine).
    Aliens spawn on planets, wander, and can be befriended by feeding.

    States: idle -> wander -> (player nearby) -> idle
            idle -> (player feeds) -> happy -> follow (tamed)

    Expected Workspace structure (built in Studio):
      Workspace/Planets/{PlanetName}/Aliens/ (Folder of alien Model instances)
      Each alien Model needs a HumanoidRootPart and Humanoid.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Aliens = require(ReplicatedStorage:WaitForChild("Aliens"))
local Planets = require(ReplicatedStorage:WaitForChild("Planets"))
local Items = require(ReplicatedStorage:WaitForChild("Items"))

local AlienManager = {}
AlienManager.__index = AlienManager

local InventoryServer = nil
local PlayerDataManager = nil
local QuestManager = nil
local Remotes = nil

-- Active alien instances: { [Model]: alienData }
local activeAliens: { [any]: any } = {}

-- Per-player feed progress for wild aliens: { [userId]: { [alienModel]: feedCount } }
local feedProgress: { [number]: { [any]: number } } = {}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function AlienManager:Init()
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
-- Start: Setup aliens on planets + connect feeding remote
---------------------------------------------------------------------------
function AlienManager:Start()
    -- Setup aliens for each planet
    local planetsFolder = workspace:FindFirstChild("Planets")
    if planetsFolder then
        for _, planetDef in Planets.getAll() do
            local planetFolder = planetsFolder:FindFirstChild(planetDef.name)
            if planetFolder then
                self:_setupPlanetAliens(planetFolder, planetDef)
            end
        end
    end

    -- Connect feeding remote
    local RequestFeedAlien = Remotes:WaitForChild("RequestFeedAlien") :: RemoteEvent
    RequestFeedAlien.OnServerEvent:Connect(function(player: Player, alienModelName: string)
        self:_onFeedRequest(player, alienModelName)
    end)

    print("[AlienManager] Ready")
end

---------------------------------------------------------------------------
-- Setup aliens on a planet
---------------------------------------------------------------------------
function AlienManager:_setupPlanetAliens(planetFolder: Instance, planetDef: any)
    local aliensFolder = planetFolder:FindFirstChild("Aliens")
    if not aliensFolder then
        -- Create placeholder folder
        aliensFolder = Instance.new("Folder")
        aliensFolder.Name = "Aliens"
        aliensFolder.Parent = planetFolder
        print("[AlienManager] Created Aliens folder for " .. planetDef.name .. " (add alien models in Studio)")

        -- Create placeholder aliens as simple parts
        local alienDef = Aliens.getBySpecies(planetDef.alienSpecies)
        if alienDef then
            for i = 1, 3 do
                self:_createPlaceholderAlien(aliensFolder, alienDef, i)
            end
        end
        return
    end

    -- Setup existing alien models
    for _, alienModel in aliensFolder:GetChildren() do
        if alienModel:IsA("Model") then
            local alienDef = Aliens.getBySpecies(planetDef.alienSpecies)
            if alienDef then
                self:_initAlien(alienModel, alienDef)
            end
        end
    end
end

---------------------------------------------------------------------------
-- Create a placeholder alien (simple Part with ProximityPrompt)
---------------------------------------------------------------------------
function AlienManager:_createPlaceholderAlien(parent: Instance, alienDef: any, index: number)
    local model = Instance.new("Model")
    model.Name = alienDef.species .. "_" .. index

    local body = Instance.new("Part")
    body.Name = "HumanoidRootPart"
    body.Size = Vector3.new(3, 3, 3)
    body.Position = Vector3.new(
        math.random(-40, 40),
        5,
        math.random(-40, 40)
    )
    body.Shape = Enum.PartType.Ball
    body.Anchored = true
    body.CanCollide = false
    body.BrickColor = BrickColor.new("Bright green")
    body.Material = Enum.Material.SmoothPlastic
    body.Parent = model

    -- Name label
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 100, 0, 40)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = body

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromHex("5cd43e")
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.Text = alienDef.name
    nameLabel.Parent = billboardGui

    model.PrimaryPart = body
    model.Parent = parent

    self:_initAlien(model, alienDef)
end

---------------------------------------------------------------------------
-- Initialize an alien model with AI behavior
---------------------------------------------------------------------------
function AlienManager:_initAlien(alienModel: Model, alienDef: any)
    local rootPart = alienModel:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not rootPart then return end

    -- Store alien data
    local alienData = {
        model = alienModel,
        definition = alienDef,
        state = "idle" :: string,
        spawnPosition = rootPart.Position,
        tamedBy = nil :: Player?,
        stateTimer = 0,
    }
    activeAliens[alienModel] = alienData

    -- Add ProximityPrompt for feeding
    local prompt = Instance.new("ProximityPrompt")
    prompt.ObjectText = alienDef.name
    prompt.ActionText = "Fuettern"
    prompt.HoldDuration = 0.3
    prompt.MaxActivationDistance = 8
    prompt.RequiresLineOfSight = false
    prompt.Parent = rootPart

    prompt.Triggered:Connect(function(playerWhoTriggered: Player)
        self:_onFeedRequest(playerWhoTriggered, alienModel.Name)
    end)

    -- Start AI loop
    task.spawn(function()
        self:_alienAILoop(alienData)
    end)
end

---------------------------------------------------------------------------
-- Alien AI Loop (simple FSM)
---------------------------------------------------------------------------
function AlienManager:_alienAILoop(alienData: any)
    while alienData.model and alienData.model.Parent do
        local rootPart = alienData.model:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not rootPart then break end

        if alienData.state == "idle" then
            -- Check if player is nearby - show curious speech bubble
            alienData.stateTimer += 1

            local nearestPlayer, nearestDist = self:_findNearestPlayer(rootPart.Position)
            if nearestPlayer and nearestDist < 20 and alienData.stateTimer % 6 == 0 then
                -- Show speech bubble
                self:_showSpeechBubble(alienData, nearestPlayer)
            end

            if alienData.stateTimer > math.random(3, 6) then
                alienData.state = "wander"
                alienData.stateTimer = 0
            end

        elseif alienData.state == "wander" then
            -- Move to random position near spawn
            local wanderRadius = Constants.ALIENS.WANDER_RADIUS
            local targetPos = alienData.spawnPosition + Vector3.new(
                (math.random() - 0.5) * wanderRadius * 2,
                0,
                (math.random() - 0.5) * wanderRadius * 2
            )
            targetPos = Vector3.new(targetPos.X, alienData.spawnPosition.Y, targetPos.Z)

            -- Simple lerp movement (placeholder for Humanoid:MoveTo)
            local startPos = rootPart.Position
            local speed = alienData.definition.wanderSpeed
            local distance = (targetPos - startPos).Magnitude
            local steps = math.max(1, math.floor(distance / speed))

            for step = 1, steps do
                if alienData.state ~= "wander" then break end
                local alpha = step / steps
                local newPos = startPos:Lerp(targetPos, alpha)
                rootPart.CFrame = CFrame.new(newPos)
                task.wait(0.3)
            end

            alienData.state = "idle"
            alienData.stateTimer = 0

        elseif alienData.state == "happy" then
            -- Bounce/spin animation (placeholder)
            for _ = 1, 5 do
                rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 1, 0)
                task.wait(0.15)
                rootPart.CFrame = rootPart.CFrame - Vector3.new(0, 1, 0)
                task.wait(0.15)
            end
            alienData.state = "idle"
            alienData.stateTimer = 0

        elseif alienData.state == "follow" then
            -- Follow tamed player
            if alienData.tamedBy and alienData.tamedBy.Character then
                local playerRoot = alienData.tamedBy.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
                if playerRoot then
                    local diff = playerRoot.Position - rootPart.Position
                    local dist = diff.Magnitude
                    if dist > Constants.ALIENS.FOLLOW_DISTANCE then
                        local dir = diff.Unit
                        local speed = alienData.definition.followSpeed
                        local newPos = rootPart.Position + dir * math.min(speed * 0.3, dist - Constants.ALIENS.FOLLOW_DISTANCE)
                        rootPart.CFrame = CFrame.new(newPos.X, rootPart.Position.Y, newPos.Z)
                    end
                end
            else
                -- Player left or disconnected, return to wander
                alienData.state = "idle"
                alienData.tamedBy = nil
            end
        end

        task.wait(0.5)
    end
end

---------------------------------------------------------------------------
-- Handle feed request from player
---------------------------------------------------------------------------
function AlienManager:_onFeedRequest(player: Player, alienModelName: string)
    -- Find the alien model
    local alienData = nil
    for model, data in activeAliens do
        if model.Name == alienModelName then
            alienData = data
            break
        end
    end

    if not alienData then return end
    if alienData.state == "follow" then return end -- Already tamed

    local alienDef = alienData.definition
    local favoriteFood = alienDef.favoriteFood

    -- Check if player has the favorite food
    if not InventoryServer:HasItem(player, favoriteFood, 1) then
        -- Try gift_bundle as alternative
        if not InventoryServer:HasItem(player, "gift_bundle", 1) then
            return
        end
        -- Use gift bundle instead
        InventoryServer:RemoveItem(player, "gift_bundle", 1)
    else
        InventoryServer:RemoveItem(player, favoriteFood, 1)
    end

    -- Track feed progress
    local userId = player.UserId
    if not feedProgress[userId] then
        feedProgress[userId] = {}
    end
    local currentFeeds = (feedProgress[userId][alienData.model] or 0) + 1
    feedProgress[userId][alienData.model] = currentFeeds

    -- Make alien happy
    alienData.state = "happy"

    -- Notify client
    local AlienStateChanged = Remotes:FindFirstChild("AlienStateChanged") :: RemoteEvent?
    if AlienStateChanged then
        AlienStateChanged:FireClient(player, alienDef.id, "happy", currentFeeds, alienDef.feedsToTame)
    end

    -- Check if tamed (requires taming_device!)
    if currentFeeds >= alienDef.feedsToTame then
        local hasTamingDevice = InventoryServer:HasItem(player, "taming_device", 1)
        if hasTamingDevice then
            task.delay(1.5, function()
                self:_tameAlien(player, alienData)
            end)
        else
            -- Notify player they need taming device
            local TriggerCelebration = Remotes:FindFirstChild("TriggerCelebration") :: RemoteEvent?
            if TriggerCelebration then
                TriggerCelebration:FireClient(player, {
                    type = "message",
                    text = "Du brauchst ein Freundschafts-Geraet zum Zaehmen! (Crafting: C)",
                })
            end
        end
    end

    -- Notify QuestManager of feeding
    if QuestManager and type(QuestManager.OnAlienFed) == "function" then
        QuestManager:OnAlienFed(player, alienDef.id)
    end
end

---------------------------------------------------------------------------
-- Tame an alien
---------------------------------------------------------------------------
function AlienManager:_tameAlien(player: Player, alienData: any)
    local alienDef = alienData.definition
    alienData.state = "follow"
    alienData.tamedBy = player

    -- Save to player profile
    local profile = PlayerDataManager:GetProfileData(player)
    if profile then
        table.insert(profile.tamedAliens, {
            alienId = alienDef.id,
            nickname = nil,
            fedCount = alienDef.feedsToTame,
        })
    end

    -- Notify client
    local AlienStateChanged = Remotes:FindFirstChild("AlienStateChanged") :: RemoteEvent?
    if AlienStateChanged then
        AlienStateChanged:FireClient(player, alienDef.id, "tamed", alienDef.feedsToTame, alienDef.feedsToTame)
    end

    -- Celebration
    local TriggerCelebration = Remotes:FindFirstChild("TriggerCelebration") :: RemoteEvent?
    if TriggerCelebration then
        TriggerCelebration:FireClient(player, "alien_tamed", { alienName = alienDef.name })
    end

    -- Notify QuestManager
    if QuestManager and type(QuestManager.OnAlienTamed) == "function" then
        QuestManager:OnAlienTamed(player, alienDef.id)
    end

    -- Give taming reward items
    local TAMING_REWARDS = {
        blob = { { "space_berry", 5 } },
        penguin = { { "frost_fish", 5 }, { "ice_crystal", 3 } },
        firefly = { { "glow_mushroom", 5 }, { "energy_orb", 3 } },
        salamander = { { "ember_fruit", 5 }, { "fire_crystal", 3 } },
    }
    local rewards = TAMING_REWARDS[alienDef.species]
    if rewards then
        for _, reward in rewards do
            InventoryServer:AddItem(player, reward[1], reward[2])
        end
    end

    -- Clear feed progress
    if feedProgress[player.UserId] then
        feedProgress[player.UserId][alienData.model] = nil
    end

    print("[AlienManager] " .. player.Name .. " tamed " .. alienDef.name .. "!")
end

---------------------------------------------------------------------------
-- Find nearest player to a position
---------------------------------------------------------------------------
function AlienManager:_findNearestPlayer(pos: Vector3): (Player?, number)
    local nearest: Player? = nil
    local nearestDist = math.huge

    for _, player in Players:GetPlayers() do
        local character = player.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
            if root then
                local dist = (root.Position - pos).Magnitude
                if dist < nearestDist then
                    nearest = player
                    nearestDist = dist
                end
            end
        end
    end

    return nearest, nearestDist
end

---------------------------------------------------------------------------
-- Show speech bubble above alien
---------------------------------------------------------------------------
function AlienManager:_showSpeechBubble(alienData: any, player: Player)
    local rootPart = alienData.model:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not rootPart then return end

    local alienDef = alienData.definition
    local favoriteFood = Items.get(alienDef.favoriteFood)

    local messages = {
        "Hallo! Ich hab Hunger...",
        "Hast du " .. (favoriteFood and favoriteFood.name or "Essen") .. " fuer mich?",
        "Magst du mein Freund sein?",
        "Ich bin " .. alienDef.name .. "!",
    }

    local text = messages[math.random(1, #messages)]

    -- Create speech bubble
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 180, 0, 50)
    bb.StudsOffset = Vector3.new(0, 5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 30
    bb.Parent = rootPart

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromHex("14350d")
    bg.BackgroundTransparency = 0.2
    bg.Parent = bb

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = bg

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, -6)
    label.Position = UDim2.new(0, 5, 0, 3)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromHex("5cd43e")
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextWrapped = true
    label.Parent = bg

    -- Auto-remove after 4 seconds
    task.delay(4, function()
        if bb and bb.Parent then
            bb:Destroy()
        end
    end)
end

---------------------------------------------------------------------------
-- Cleanup on player leave
---------------------------------------------------------------------------
function AlienManager:OnPlayerRemoving(player: Player)
    -- Release any aliens this player tamed (they return to wander)
    for _, alienData in activeAliens do
        if alienData.tamedBy == player then
            alienData.tamedBy = nil
            alienData.state = "idle"
        end
    end

    feedProgress[player.UserId] = nil
end

return AlienManager
