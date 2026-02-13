--[[
    Prop Colorization Script for sgit Space Station
    Author: sgit.space
    Purpose: Apply planet-specific colors and materials to all imported FBX prop models

    Usage: Paste into Roblox Studio Command Bar and hit Enter
]]

-- Helper function to convert hex to Color3
local function hex(hexString)
    hexString = hexString:gsub("#", "")
    local r = tonumber(hexString:sub(1, 2), 16) / 255
    local g = tonumber(hexString:sub(3, 4), 16) / 255
    local b = tonumber(hexString:sub(5, 6), 16) / 255
    return Color3.new(r, g, b)
end

-- Helper function to check if part name contains pattern (case-insensitive)
local function matchesPattern(partName, pattern)
    return partName:lower():find(pattern:lower(), 1, true) ~= nil
end

-- Apply properties to a part
local function applyProps(part, color, material, transparency)
    if part:IsA("BasePart") then
        part.Color = color
        part.Material = material or Enum.Material.SmoothPlastic
        if transparency then
            part.Transparency = transparency
        end
    end
end

-- Statistics tracking
local stats = {
    Verdania = 0,
    Glacius = 0,
    Luminos = 0,
    Volcanus = 0,
    Universal = 0,
    Unmatched = 0
}

-- VERDANIA COLORIZATION (Jungle planet)
local function colorizeVerdania(model, propType)
    for _, part in pairs(model:GetDescendants()) do
        if not part:IsA("BasePart") then continue end
        local name = part.Name

        if propType == "Crystal" then
            if matchesPattern(name, "Crystal_Base") then
                applyProps(part, hex("#5a3a1a"), Enum.Material.Rock)
            elseif matchesPattern(name, "Crystal_Shard") then
                applyProps(part, hex("#43b02a"), Enum.Material.Glass, 0.1)
            elseif matchesPattern(name, "Crystal_Glow") then
                applyProps(part, hex("#5cd43e"), Enum.Material.Neon)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#5a3a1a"), Enum.Material.Rock)
            end

        elseif propType == "Tree" then
            if matchesPattern(name, "Tree_Trunk") then
                applyProps(part, hex("#4a2a0a"), Enum.Material.Wood)
            elseif matchesPattern(name, "Tree_Branch") then
                applyProps(part, hex("#5a3a1a"), Enum.Material.Wood)
            elseif matchesPattern(name, "Tree_Canopy") then
                applyProps(part, hex("#1a6b0a"), Enum.Material.LeafyGrass)
            elseif matchesPattern(name, "Tree_Leaf") then
                applyProps(part, hex("#33aa22"), Enum.Material.Grass)
            elseif matchesPattern(name, "Tree_Vine") then
                applyProps(part, hex("#2a5a1a"), Enum.Material.Fabric)
            elseif matchesPattern(name, "Tree_Fruit") then
                applyProps(part, hex("#ffaa22"), Enum.Material.SmoothPlastic)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#4a2a0a"), Enum.Material.Wood)
            end

        elseif propType == "Plant" then
            if matchesPattern(name, "Plant_Stem") then
                applyProps(part, hex("#1a4a0a"), Enum.Material.Grass)
            elseif matchesPattern(name, "Plant_Leaf") then
                applyProps(part, hex("#33bb22"), Enum.Material.LeafyGrass)
            elseif matchesPattern(name, "Plant_Flower") then
                applyProps(part, hex("#ff66aa"), Enum.Material.SmoothPlastic)
            elseif matchesPattern(name, "Plant_Pot") or matchesPattern(name, "Plant_Base") then
                applyProps(part, hex("#5a3a1a"), Enum.Material.Rock)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#2a5a1a"), Enum.Material.Grass)
            end

        elseif propType == "Berry" then
            if matchesPattern(name, "Berry_Bush") then
                applyProps(part, hex("#2a7a1a"), Enum.Material.LeafyGrass)
            elseif matchesPattern(name, "Berry_Branch") then
                applyProps(part, hex("#4a2a0a"), Enum.Material.Wood)
            elseif matchesPattern(name, "Berry_Fruit") then
                applyProps(part, hex("#cc2255"), Enum.Material.SmoothPlastic)
            elseif matchesPattern(name, "Berry_Leaf") then
                applyProps(part, hex("#33aa22"), Enum.Material.Grass)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#2a7a1a"), Enum.Material.Grass)
            end
        end

        stats.Verdania = stats.Verdania + 1
    end
end

-- GLACIUS COLORIZATION (Ice planet)
local function colorizeGlacius(model, propType)
    for _, part in pairs(model:GetDescendants()) do
        if not part:IsA("BasePart") then continue end
        local name = part.Name

        if propType == "IceCrystal" then
            if matchesPattern(name, "IceCrystal_Base") then
                applyProps(part, hex("#c8d8e8"), Enum.Material.Ice)
            elseif matchesPattern(name, "IceCrystal_Spire") then
                applyProps(part, hex("#88bbee"), Enum.Material.Glass, 0.15)
            elseif matchesPattern(name, "IceCrystal_Tip") then
                applyProps(part, hex("#aaddff"), Enum.Material.Neon)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#c8d8e8"), Enum.Material.Ice)
            end

        elseif propType == "FrozenMetal" then
            if matchesPattern(name, "FrozenMetal_Rock") then
                applyProps(part, hex("#6a7a8a"), Enum.Material.Rock)
            elseif matchesPattern(name, "FrozenMetal_Ore") then
                applyProps(part, hex("#3a4a5a"), Enum.Material.Metal)
            elseif matchesPattern(name, "FrozenMetal_Ice") then
                applyProps(part, hex("#aaccee"), Enum.Material.Ice)
            elseif matchesPattern(name, "FrozenMetal_Frost") then
                applyProps(part, hex("#d8e8f0"), Enum.Material.Ice)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#6a7a8a"), Enum.Material.Rock)
            end

        elseif propType == "Snowflake" then
            if matchesPattern(name, "Snowflake_Center") then
                applyProps(part, hex("#88ccff"), Enum.Material.Neon)
            else
                applyProps(part, hex("#d0e0f0"), Enum.Material.Ice)
            end

        elseif propType == "FrostFish" then
            if matchesPattern(name, "FrostFish_Body") then
                applyProps(part, hex("#8899aa"), Enum.Material.SmoothPlastic)
            elseif matchesPattern(name, "FrostFish_Fin") then
                applyProps(part, hex("#5577aa"), Enum.Material.SmoothPlastic)
            elseif matchesPattern(name, "FrostFish_Eye") then
                applyProps(part, hex("#ffffff"), Enum.Material.SmoothPlastic)
            elseif matchesPattern(name, "FrostFish_Ice") or matchesPattern(name, "FrostFish_Pool") then
                applyProps(part, hex("#aaddee"), Enum.Material.Ice)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#8899aa"), Enum.Material.SmoothPlastic)
            end

        elseif propType == "Icicle" then
            if matchesPattern(name, "Icicle_Base") then
                applyProps(part, hex("#d8e8f0"), Enum.Material.Ice)
            else
                applyProps(part, hex("#99ccee"), Enum.Material.Glass, 0.1)
            end
        end

        stats.Glacius = stats.Glacius + 1
    end
end

-- LUMINOS COLORIZATION (Mushroom planet)
local function colorizeLuminos(model, propType)
    for _, part in pairs(model:GetDescendants()) do
        if not part:IsA("BasePart") then continue end
        local name = part.Name

        if propType == "Mushroom" then
            if matchesPattern(name, "Mushroom_Stem") then
                applyProps(part, hex("#8866aa"), Enum.Material.SmoothPlastic)
            elseif matchesPattern(name, "Mushroom_Cap") then
                applyProps(part, hex("#aa44cc"), Enum.Material.SmoothPlastic)
            elseif matchesPattern(name, "Mushroom_Spot") then
                applyProps(part, hex("#ffee44"), Enum.Material.Neon)
            elseif matchesPattern(name, "Mushroom_Glow") then
                applyProps(part, hex("#cc66ff"), Enum.Material.Neon)
            elseif matchesPattern(name, "Mushroom_Base") then
                applyProps(part, hex("#3a1a4a"), Enum.Material.Ground)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#8866aa"), Enum.Material.SmoothPlastic)
            end

        elseif propType == "EnergyOrb" then
            if matchesPattern(name, "EnergyOrb_Sphere") then
                applyProps(part, hex("#aaff44"), Enum.Material.Neon)
            elseif matchesPattern(name, "EnergyOrb_Ring") then
                applyProps(part, hex("#7744aa"), Enum.Material.Neon)
            elseif matchesPattern(name, "EnergyOrb_Base") then
                applyProps(part, hex("#3a1a4a"), Enum.Material.Rock)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#aaff44"), Enum.Material.Neon)
            end

        elseif propType == "Spore" then
            if matchesPattern(name, "Spore_Cloud") then
                applyProps(part, hex("#bb88dd"), Enum.Material.SmoothPlastic, 0.3)
            elseif matchesPattern(name, "Spore_Core") then
                applyProps(part, hex("#88ff44"), Enum.Material.Neon)
            elseif matchesPattern(name, "Spore_Trail") then
                applyProps(part, hex("#9966cc"), Enum.Material.Neon, 0.4)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#bb88dd"), Enum.Material.SmoothPlastic, 0.3)
            end

        elseif propType == "Carrot" then
            if matchesPattern(name, "Carrot_Body") then
                applyProps(part, hex("#ff8833"), Enum.Material.SmoothPlastic)
            elseif matchesPattern(name, "Carrot_Tip") then
                applyProps(part, hex("#cc6622"), Enum.Material.SmoothPlastic)
            elseif matchesPattern(name, "Carrot_Leaf") then
                applyProps(part, hex("#66aa55"), Enum.Material.Grass)
            elseif matchesPattern(name, "Carrot_Glow") then
                applyProps(part, hex("#ffaa33"), Enum.Material.Neon)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#ff8833"), Enum.Material.SmoothPlastic)
            end

        elseif propType == "GiantMushroom" or matchesPattern(propType, "GiantMush") then
            if matchesPattern(name, "GiantMush_Stem") then
                applyProps(part, hex("#9977bb"), Enum.Material.SmoothPlastic)
            elseif matchesPattern(name, "GiantMush_Cap") then
                applyProps(part, hex("#7733aa"), Enum.Material.SmoothPlastic)
            elseif matchesPattern(name, "GiantMush_Spots") then
                applyProps(part, hex("#44ffee"), Enum.Material.Neon)
            elseif matchesPattern(name, "GiantMush_Ring") then
                applyProps(part, hex("#8844bb"), Enum.Material.SmoothPlastic)
            elseif matchesPattern(name, "GiantMush_Glow") then
                applyProps(part, hex("#cc66ff"), Enum.Material.Neon)
            elseif matchesPattern(name, "GiantMush_Base") then
                applyProps(part, hex("#2a1030"), Enum.Material.Rock)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#9977bb"), Enum.Material.SmoothPlastic)
            end
        end

        stats.Luminos = stats.Luminos + 1
    end
end

-- VOLCANUS COLORIZATION (Volcano planet)
local function colorizeVolcanus(model, propType)
    for _, part in pairs(model:GetDescendants()) do
        if not part:IsA("BasePart") then continue end
        local name = part.Name

        if propType == "LavaStone" then
            if matchesPattern(name, "LavaStone_Rock") then
                applyProps(part, hex("#2a1a1a"), Enum.Material.Basalt)
            elseif matchesPattern(name, "LavaStone_Crack") then
                applyProps(part, hex("#ff4400"), Enum.Material.Neon)
            elseif matchesPattern(name, "LavaStone_Glow") then
                applyProps(part, hex("#ff6600"), Enum.Material.Neon)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#2a1a1a"), Enum.Material.Basalt)
            end

        elseif propType == "Obsidian" then
            if matchesPattern(name, "Obsidian_Shard") then
                applyProps(part, hex("#0a0a0a"), Enum.Material.Glass)
            elseif matchesPattern(name, "Obsidian_Base") then
                applyProps(part, hex("#1a1010"), Enum.Material.Rock)
            elseif matchesPattern(name, "Obsidian_Edge") then
                applyProps(part, hex("#2a1a3a"), Enum.Material.Glass)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#0a0a0a"), Enum.Material.Glass)
            end

        elseif propType == "FireCrystal" then
            if matchesPattern(name, "FireCrystal_Base") then
                applyProps(part, hex("#2a1a0a"), Enum.Material.Rock)
            elseif matchesPattern(name, "FireCrystal_Shard") then
                applyProps(part, hex("#cc3300"), Enum.Material.Glass)
            elseif matchesPattern(name, "FireCrystal_Flame") then
                applyProps(part, hex("#ff8800"), Enum.Material.Neon)
            elseif matchesPattern(name, "FireCrystal_Glow") then
                applyProps(part, hex("#ffaa00"), Enum.Material.Neon)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#2a1a0a"), Enum.Material.Rock)
            end

        elseif propType == "EmberFruit" then
            if matchesPattern(name, "EmberFruit_Trunk") then
                applyProps(part, hex("#1a0a0a"), Enum.Material.Wood)
            elseif matchesPattern(name, "EmberFruit_Branch") then
                applyProps(part, hex("#2a1a0a"), Enum.Material.Wood)
            elseif matchesPattern(name, "EmberFruit_Canopy") then
                applyProps(part, hex("#4a1a0a"), Enum.Material.Grass)
            elseif matchesPattern(name, "EmberFruit_Fruit") then
                applyProps(part, hex("#ff6600"), Enum.Material.Neon)
            elseif matchesPattern(name, "EmberFruit_Ember") then
                applyProps(part, hex("#ff3300"), Enum.Material.Neon)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#1a0a0a"), Enum.Material.Wood)
            end

        elseif propType == "VolcanicRock" then
            if matchesPattern(name, "VolcanicRock_Rock") then
                applyProps(part, hex("#2a1a1a"), Enum.Material.Basalt)
            elseif matchesPattern(name, "VolcanicRock_Base") then
                applyProps(part, hex("#1a1010"), Enum.Material.Rock)
            elseif matchesPattern(name, "VolcanicRock_Moss") then
                applyProps(part, hex("#3a1a0a"), Enum.Material.Grass)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#2a1a1a"), Enum.Material.Basalt)
            end

        elseif propType == "LavaPool" then
            if matchesPattern(name, "LavaPool_Pool") then
                applyProps(part, hex("#ff4400"), Enum.Material.Neon)
            elseif matchesPattern(name, "LavaPool_Rim") then
                applyProps(part, hex("#2a1a1a"), Enum.Material.Basalt)
            elseif matchesPattern(name, "LavaPool_Bubble") then
                applyProps(part, hex("#ffaa00"), Enum.Material.Neon, 0.2)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#ff4400"), Enum.Material.Neon)
            end
        end

        stats.Volcanus = stats.Volcanus + 1
    end
end

-- UNIVERSAL COLORIZATION (ScrapMetal)
local function colorizeUniversal(model, propType)
    for _, part in pairs(model:GetDescendants()) do
        if not part:IsA("BasePart") then continue end
        local name = part.Name

        if propType == "ScrapMetal" or matchesPattern(propType, "Scrap") then
            if matchesPattern(name, "Scrap_Plate") then
                applyProps(part, hex("#5a5a5a"), Enum.Material.Metal)
            elseif matchesPattern(name, "Scrap_Pipe") then
                applyProps(part, hex("#3a3a3a"), Enum.Material.Metal)
            elseif matchesPattern(name, "Scrap_Bolt") then
                applyProps(part, hex("#8a8a8a"), Enum.Material.Metal)
            else
                stats.Unmatched = stats.Unmatched + 1
                applyProps(part, hex("#5a5a5a"), Enum.Material.Metal)
            end
        end

        stats.Universal = stats.Universal + 1
    end
end

-- Main recursion function to traverse folder hierarchy
local function processFolder(folder, planetName, propType)
    -- Check if this is a model
    if folder:IsA("Model") then
        -- Determine which planet colorization to apply
        if planetName == "Verdania" then
            colorizeVerdania(folder, propType)
        elseif planetName == "Glacius" then
            colorizeGlacius(folder, propType)
        elseif planetName == "Luminos" then
            colorizeLuminos(folder, propType)
        elseif planetName == "Volcanus" then
            colorizeVolcanus(folder, propType)
        elseif planetName == "Universal" then
            colorizeUniversal(folder, propType)
        end
        return
    end

    -- Otherwise, recurse through children
    for _, child in pairs(folder:GetChildren()) do
        local newPlanetName = planetName
        local newPropType = propType

        -- Track hierarchy: PropModels > [Planet] > [Type] > [Model]
        if folder.Name == "PropModels" then
            newPlanetName = child.Name  -- Verdania, Glacius, etc.
        elseif planetName and not propType then
            newPropType = child.Name  -- Crystal, Tree, Mushroom, etc.
        end

        processFolder(child, newPlanetName, newPropType)
    end
end

-- MAIN EXECUTION
print("=== sgit Space Station Prop Colorization ===")
print("Starting colorization process...")

local serverStorage = game:GetService("ServerStorage")
local propModels = serverStorage:FindFirstChild("PropModels")

if not propModels then
    warn("ERROR: ServerStorage.PropModels not found!")
    return
end

-- Start processing from PropModels root
processFolder(propModels, nil, nil)

-- Print statistics
print("\n=== Colorization Complete ===")
print(string.format("Verdania parts: %d", stats.Verdania))
print(string.format("Glacius parts: %d", stats.Glacius))
print(string.format("Luminos parts: %d", stats.Luminos))
print(string.format("Volcanus parts: %d", stats.Volcanus))
print(string.format("Universal parts: %d", stats.Universal))
print(string.format("Unmatched parts: %d", stats.Unmatched))
print(string.format("Total parts colorized: %d",
    stats.Verdania + stats.Glacius + stats.Luminos + stats.Volcanus + stats.Universal))
print("\nAll props have been colorized successfully!")
