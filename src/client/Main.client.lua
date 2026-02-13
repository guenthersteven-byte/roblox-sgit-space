--!strict
--[[
    Client Bootstrap - sgit Space Station
    Single-Script Architecture: This is the only client LocalScript.
    All controllers are loaded as ModuleScripts from Controllers/.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

---------------------------------------------------------------------------
-- Wait for server to create Remotes
---------------------------------------------------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
if not Remotes then
    warn("[sgit Client] Remotes folder not found! Server may not be running.")
    return
end

print("[sgit Client] Remotes found, initializing...")

---------------------------------------------------------------------------
-- Load Controllers
---------------------------------------------------------------------------
local Controllers = script.Parent:WaitForChild("Controllers")

local controllerModules = {
    "UIController",
    "InventoryUI",
    "CraftingUI",
    -- Phase 3
    "ShuttleUI",
    "MinimapUI",
    -- Phase 4
    "QuestUI",
    "StationUI",
    -- Phase 5
    "TutorialController",
    "SettingsUI",
}

local loadedControllers = {}

for _, moduleName in controllerModules do
    local moduleInstance = Controllers:FindFirstChild(moduleName)
    if moduleInstance then
        local success, result = pcall(require, moduleInstance)
        if success then
            loadedControllers[moduleName] = result
            print("[sgit Client] Loaded: " .. moduleName)
        else
            warn("[sgit Client] Failed to load " .. moduleName .. ": " .. tostring(result))
        end
    end
end

---------------------------------------------------------------------------
-- Load Effects
---------------------------------------------------------------------------
local Effects = script.Parent:WaitForChild("Effects")

local effectModules = {
    "Particles",
    "Sounds",
    "Celebrations",
}

local loadedEffects = {}

for _, moduleName in effectModules do
    local moduleInstance = Effects:FindFirstChild(moduleName)
    if moduleInstance then
        local success, result = pcall(require, moduleInstance)
        if success then
            loadedEffects[moduleName] = result
            print("[sgit Client] Loaded effect: " .. moduleName)
        else
            warn("[sgit Client] Failed to load effect " .. moduleName .. ": " .. tostring(result))
        end
    end
end

---------------------------------------------------------------------------
-- Init Phase
---------------------------------------------------------------------------
for name, controller in loadedControllers do
    if type(controller) == "table" and type(controller.Init) == "function" then
        local success, err = pcall(controller.Init, controller, player, Remotes)
        if success then
            print("[sgit Client] Initialized: " .. name)
        else
            warn("[sgit Client] Init failed for " .. name .. ": " .. tostring(err))
        end
    end
end

for name, effect in loadedEffects do
    if type(effect) == "table" and type(effect.Init) == "function" then
        local success, err = pcall(effect.Init, effect, player)
        if success then
            print("[sgit Client] Initialized effect: " .. name)
        else
            warn("[sgit Client] Init failed for effect " .. name .. ": " .. tostring(err))
        end
    end
end

---------------------------------------------------------------------------
-- Start Phase
---------------------------------------------------------------------------
for name, controller in loadedControllers do
    if type(controller) == "table" and type(controller.Start) == "function" then
        local success, err = pcall(controller.Start, controller)
        if success then
            print("[sgit Client] Started: " .. name)
        else
            warn("[sgit Client] Start failed for " .. name .. ": " .. tostring(err))
        end
    end
end

for name, effect in loadedEffects do
    if type(effect) == "table" and type(effect.Start) == "function" then
        local success, err = pcall(effect.Start, effect)
        if success then
            print("[sgit Client] Started effect: " .. name)
        else
            warn("[sgit Client] Start failed for effect " .. name .. ": " .. tostring(err))
        end
    end
end

---------------------------------------------------------------------------
-- Setup HUD (located in StarterGui, loaded separately)
---------------------------------------------------------------------------
local playerGui = player:WaitForChild("PlayerGui")
local spaceStationUI = playerGui:WaitForChild("SpaceStationUI", 10)
if spaceStationUI then
    local HUDModule = spaceStationUI:FindFirstChild("HUD")
    if HUDModule then
        local hudSuccess, HUD = pcall(require, HUDModule)
        if hudSuccess then
            local uiController = loadedControllers["UIController"]
            if uiController and type(uiController.GetScreenGui) == "function" then
                local setupOk, setupErr = pcall(HUD.Setup, uiController:GetScreenGui(), player, Remotes)
                if setupOk then
                    print("[sgit Client] HUD setup complete")
                else
                    warn("[sgit Client] HUD setup failed: " .. tostring(setupErr))
                end
            else
                warn("[sgit Client] UIController not loaded, skipping HUD")
            end
        else
            warn("[sgit Client] Failed to load HUD: " .. tostring(HUD))
        end
    end
else
    warn("[sgit Client] SpaceStationUI not found in PlayerGui")
end

---------------------------------------------------------------------------
-- Request full state sync from server
---------------------------------------------------------------------------
local RequestFullSync = Remotes:WaitForChild("RequestFullSync") :: RemoteFunction
local success, playerData = pcall(function()
    return RequestFullSync:InvokeServer()
end)

if success and playerData then
    print("[sgit Client] Full sync received from server")
    for name, controller in loadedControllers do
        if type(controller) == "table" and type(controller.OnFullSync) == "function" then
            task.spawn(function()
                controller:OnFullSync(playerData)
            end)
        end
    end
else
    warn("[sgit Client] Full sync failed: " .. tostring(playerData))
end

---------------------------------------------------------------------------
-- Listen for celebration events
---------------------------------------------------------------------------
local TriggerCelebration = Remotes:WaitForChild("TriggerCelebration") :: RemoteEvent
TriggerCelebration.OnClientEvent:Connect(function(celebrationType: string, data: any?)
    local celebrations = loadedEffects["Celebrations"]
    if celebrations and type(celebrations.Play) == "function" then
        celebrations:Play(celebrationType, data)
    end
end)

print("[sgit Client] === sgit Space Station Client Ready ===")
print("[sgit Client] Welcome, " .. player.Name .. "!")
