--[[
    Colorize Aliens Script for Roblox Studio Command Bar

    Purpose: Apply colors, materials, and transparency to imported alien FBX models
    Location: ServerStorage > AlienModels > [SubFolder] > alien_[name]

    Usage: Copy entire script and paste into Roblox Studio Command Bar, then press Enter

    Author: sgit.space
    Date: 2026-02-13
]]

-- Helper function to convert hex color to Color3
local function hexToColor3(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return Color3.new(r, g, b)
end

-- Helper function to check if part name contains pattern (case-insensitive)
local function nameContains(partName, pattern)
    return partName:lower():find(pattern:lower(), 1, true) ~= nil
end

-- Alien color definitions
local alienConfigs = {
    Blobbi = {
        primaryColor = hexToColor3("#43b02a"),
        parts = {
            {pattern = "Body", color = hexToColor3("#43b02a"), material = Enum.Material.SmoothPlastic},
            {pattern = "Cheek", color = hexToColor3("#ff9999"), material = Enum.Material.SmoothPlastic},
            {pattern = "Eye_", color = hexToColor3("#ffffff"), material = Enum.Material.SmoothPlastic},
            {pattern = "Pupil", color = hexToColor3("#111111"), material = Enum.Material.SmoothPlastic},
            {pattern = "Shine", color = hexToColor3("#ffffff"), material = Enum.Material.SmoothPlastic, transparency = 0.3},
            {pattern = "Mouth", color = hexToColor3("#222222"), material = Enum.Material.SmoothPlastic},
            {pattern = "Foot", color = hexToColor3("#2a7a1a"), material = Enum.Material.SmoothPlastic},
            {pattern = "Sprout", color = hexToColor3("#33aa22"), material = Enum.Material.SmoothPlastic},
            {pattern = "Leaf", color = hexToColor3("#55cc33"), material = Enum.Material.SmoothPlastic},
        }
    },

    Pingui = {
        primaryColor = hexToColor3("#1a3a6b"),
        parts = {
            {pattern = "Body", color = hexToColor3("#1a3a6b"), material = Enum.Material.SmoothPlastic},
            {pattern = "Belly", color = hexToColor3("#e8e8f0"), material = Enum.Material.SmoothPlastic},
            {pattern = "Head", color = hexToColor3("#1a3a6b"), material = Enum.Material.SmoothPlastic},
            {pattern = "Eye_", color = hexToColor3("#ffffff"), material = Enum.Material.SmoothPlastic},
            {pattern = "Pupil", color = hexToColor3("#111111"), material = Enum.Material.SmoothPlastic},
            {pattern = "Beak", color = hexToColor3("#ff8800"), material = Enum.Material.SmoothPlastic},
            {pattern = "Flipper", color = hexToColor3("#1a3a6b"), material = Enum.Material.SmoothPlastic},
            {pattern = "Foot", color = hexToColor3("#ff8800"), material = Enum.Material.SmoothPlastic},
            {pattern = "Crown", color = hexToColor3("#88ccff"), material = Enum.Material.Glass},
        }
    },

    Glimmi = {
        primaryColor = hexToColor3("#6b1a8a"),
        parts = {
            {pattern = "Body", color = hexToColor3("#6b1a8a"), material = Enum.Material.SmoothPlastic},
            {pattern = "Head", color = hexToColor3("#7b2a9a"), material = Enum.Material.SmoothPlastic},
            {pattern = "Eye_", color = hexToColor3("#ffee00"), material = Enum.Material.Neon},
            {pattern = "Pupil", color = hexToColor3("#111111"), material = Enum.Material.SmoothPlastic},
            {pattern = "GlowBelly", color = hexToColor3("#aaff44"), material = Enum.Material.Neon},
            {pattern = "Antenna_", color = hexToColor3("#5a1a7a"), material = Enum.Material.SmoothPlastic},
            {pattern = "AntennaTip", color = hexToColor3("#ffee00"), material = Enum.Material.Neon},
            {pattern = "Wing", color = hexToColor3("#bb88dd"), material = Enum.Material.Glass, transparency = 0.4},
            {pattern = "Leg", color = hexToColor3("#4a1060"), material = Enum.Material.SmoothPlastic},
            {pattern = "Smile", color = hexToColor3("#222222"), material = Enum.Material.SmoothPlastic},
        }
    },

    Flammi = {
        primaryColor = hexToColor3("#8b1a1a"),
        parts = {
            {pattern = "Body", color = hexToColor3("#8b1a1a"), material = Enum.Material.SmoothPlastic},
            {pattern = "Belly", color = hexToColor3("#cc6633"), material = Enum.Material.SmoothPlastic},
            {pattern = "Head", color = hexToColor3("#8b1a1a"), material = Enum.Material.SmoothPlastic},
            {pattern = "Snout", color = hexToColor3("#aa2222"), material = Enum.Material.SmoothPlastic},
            {pattern = "Eye_", color = hexToColor3("#ffaa00"), material = Enum.Material.Neon},
            {pattern = "Pupil", color = hexToColor3("#111111"), material = Enum.Material.SmoothPlastic},
            {pattern = "Leg", color = hexToColor3("#7a1515"), material = Enum.Material.SmoothPlastic},
            {pattern = "Tail", color = hexToColor3("#8b1a1a"), material = Enum.Material.SmoothPlastic},
            {pattern = "GlowSpot", color = hexToColor3("#ff6600"), material = Enum.Material.Neon},
            {pattern = "Smile", color = hexToColor3("#222222"), material = Enum.Material.SmoothPlastic},
        }
    },

    GreenAlien = {
        primaryColor = hexToColor3("#33aa33"),
        parts = {
            {pattern = "Head", color = hexToColor3("#33aa33"), material = Enum.Material.SmoothPlastic},
            {pattern = "Body", color = hexToColor3("#33aa33"), material = Enum.Material.SmoothPlastic},
            {pattern = "Belly", color = hexToColor3("#225522"), material = Enum.Material.SmoothPlastic},
            {pattern = "Eye_", color = hexToColor3("#ccff00"), material = Enum.Material.Neon},
            {pattern = "Pupil", color = hexToColor3("#111111"), material = Enum.Material.SmoothPlastic},
            {pattern = "Antenna_", color = hexToColor3("#33aa33"), material = Enum.Material.SmoothPlastic},
            {pattern = "AntennaOrb", color = hexToColor3("#ffcc00"), material = Enum.Material.Neon},
            {pattern = "Arm", color = hexToColor3("#33aa33"), material = Enum.Material.SmoothPlastic},
            {pattern = "Hand", color = hexToColor3("#44bb44"), material = Enum.Material.SmoothPlastic},
            {pattern = "Leg", color = hexToColor3("#33aa33"), material = Enum.Material.SmoothPlastic},
            {pattern = "Smile", color = hexToColor3("#222222"), material = Enum.Material.SmoothPlastic},
            {pattern = "Belt", color = hexToColor3("#ffcc00"), material = Enum.Material.Metal},
            {pattern = "Buckle", color = hexToColor3("#ffdd33"), material = Enum.Material.Neon},
        }
    }
}

-- Main processing function
local function processAlienModel(alienFolder, config, alienName)
    local processedCount = 0
    local unmatchedCount = 0
    local unmatchedParts = {}

    -- Recursive function to process all descendants
    local function processPart(part)
        if not part:IsA("BasePart") then return end

        local matched = false

        -- Try to match part name with config patterns
        for _, partConfig in ipairs(config.parts) do
            if nameContains(part.Name, partConfig.pattern) then
                part.Color = partConfig.color
                part.Material = partConfig.material

                -- Apply transparency if specified
                if partConfig.transparency then
                    part.Transparency = partConfig.transparency
                else
                    part.Transparency = 0
                end

                matched = true
                processedCount = processedCount + 1
                break
            end
        end

        -- Fallback: apply primary color to unmatched parts
        if not matched then
            part.Color = config.primaryColor
            part.Material = Enum.Material.SmoothPlastic
            part.Transparency = 0
            unmatchedCount = unmatchedCount + 1
            table.insert(unmatchedParts, part.Name)
        end
    end

    -- Process all descendants
    for _, descendant in ipairs(alienFolder:GetDescendants()) do
        processPart(descendant)
    end

    -- Print summary
    print(string.format("\n[%s] Processed %d parts", alienName, processedCount))
    if unmatchedCount > 0 then
        print(string.format("  → %d unmatched parts (applied primary color):", unmatchedCount))
        for _, partName in ipairs(unmatchedParts) do
            print(string.format("    - %s", partName))
        end
    end

    return processedCount, unmatchedCount
end

-- Main execution
local function main()
    print("=== Alien Colorization Script Started ===")
    print("Searching for aliens in ServerStorage.AlienModels...\n")

    local serverStorage = game:GetService("ServerStorage")
    local alienModelsFolder = serverStorage:FindFirstChild("AlienModels")

    if not alienModelsFolder then
        warn("ERROR: ServerStorage.AlienModels folder not found!")
        return
    end

    local totalProcessed = 0
    local totalUnmatched = 0
    local aliensFound = 0

    -- Process each alien subfolder
    for alienName, config in pairs(alienConfigs) do
        -- Search for alien folder (case-insensitive)
        local alienFolder = nil

        for _, child in ipairs(alienModelsFolder:GetChildren()) do
            if child:IsA("Folder") or child:IsA("Model") then
                if child.Name:lower():find(alienName:lower(), 1, true) then
                    alienFolder = child
                    break
                end
            end
        end

        if alienFolder then
            aliensFound = aliensFound + 1
            local processed, unmatched = processAlienModel(alienFolder, config, alienName)
            totalProcessed = totalProcessed + processed
            totalUnmatched = totalUnmatched + unmatched
        else
            warn(string.format("WARNING: %s folder not found in AlienModels", alienName))
        end
    end

    -- Final summary
    print("\n=== Colorization Complete ===")
    print(string.format("Aliens found: %d/5", aliensFound))
    print(string.format("Total parts colorized: %d", totalProcessed))
    print(string.format("Total fallback parts: %d", totalUnmatched))
    print("\nAll aliens are now colorized!")
end

-- Execute the script
main()
