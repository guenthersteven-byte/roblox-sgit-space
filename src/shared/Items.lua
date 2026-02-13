--!strict
--[[
    Items.lua
    Complete item database for sgit Space Station
    Icons use placeholder IDs - replace with actual Roblox asset IDs
]]

local Types = require(script.Parent.Types)

type ItemDefinition = Types.ItemDefinition

local Items: { [string]: ItemDefinition } = {}

---------------------------------------------------------------------------
-- Resources: Verdania (Jungle Planet)
---------------------------------------------------------------------------
Items.crystal_green = {
    id = "crystal_green",
    name = "Gruener Kristall",
    description = "Ein leuchtender Kristall von Verdania",
    category = "resource",
    icon = "rbxassetid://0", -- placeholder
    maxStack = 50,
    rarity = 1,
}

Items.alien_wood = {
    id = "alien_wood",
    name = "Alien-Holz",
    description = "Weiches, leicht leuchtendes Holz",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 50,
    rarity = 1,
}

Items.jungle_plant = {
    id = "jungle_plant",
    name = "Dschungelpflanze",
    description = "Eine bunte Pflanze aus dem Dschungel",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 30,
    rarity = 1,
}

Items.space_berry = {
    id = "space_berry",
    name = "Weltraum-Beere",
    description = "Saftige Beere - lecker und nahrhaft!",
    category = "food",
    icon = "rbxassetid://0",
    maxStack = 20,
    rarity = 1,
    hungerRestore = 20,
}

---------------------------------------------------------------------------
-- Resources: Glacius (Ice Planet)
---------------------------------------------------------------------------
Items.ice_crystal = {
    id = "ice_crystal",
    name = "Eiskristall",
    description = "Ein funkelnder Kristall aus ewigem Eis",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 50,
    rarity = 2,
}

Items.frozen_metal = {
    id = "frozen_metal",
    name = "Frost-Metall",
    description = "Extrem hartes Metall vom Eisplaneten",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 30,
    rarity = 2,
}

Items.snowflake_essence = {
    id = "snowflake_essence",
    name = "Schneeflocken-Essenz",
    description = "Magische Schneeflocken die nie schmelzen",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 20,
    rarity = 2,
}

Items.frost_fish = {
    id = "frost_fish",
    name = "Frost-Fisch",
    description = "Ein kleiner leuchtender Fisch aus dem Eis",
    category = "food",
    icon = "rbxassetid://0",
    maxStack = 15,
    rarity = 2,
    hungerRestore = 30,
}

---------------------------------------------------------------------------
-- Resources: Luminos (Mushroom Planet)
---------------------------------------------------------------------------
Items.glow_mushroom = {
    id = "glow_mushroom",
    name = "Leuchtpilz",
    description = "Ein Pilz der sanft in allen Farben leuchtet",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 40,
    rarity = 2,
}

Items.energy_orb = {
    id = "energy_orb",
    name = "Energie-Kugel",
    description = "Schwebende Energiekugel voller Kraft",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 20,
    rarity = 3,
}

Items.spore_dust = {
    id = "spore_dust",
    name = "Sporenstaub",
    description = "Glitzernder Staub der Riesenpilze",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 30,
    rarity = 2,
}

Items.luminous_carrot = {
    id = "luminous_carrot",
    name = "Leucht-Karotte",
    description = "Eine Karotte die im Dunkeln leuchtet!",
    category = "food",
    icon = "rbxassetid://0",
    maxStack = 15,
    rarity = 2,
    hungerRestore = 25,
}

---------------------------------------------------------------------------
-- Resources: Volcanus (Volcano Planet)
---------------------------------------------------------------------------
Items.lava_stone = {
    id = "lava_stone",
    name = "Lavastein",
    description = "Warmer Stein aus den Vulkanen",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 40,
    rarity = 2,
}

Items.obsidian = {
    id = "obsidian",
    name = "Obsidian",
    description = "Glaenzendes schwarzes Vulkanglas",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 30,
    rarity = 3,
}

Items.fire_crystal = {
    id = "fire_crystal",
    name = "Feuerkristall",
    description = "Ein Kristall mit innerem Feuer",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 20,
    rarity = 3,
}

Items.ember_fruit = {
    id = "ember_fruit",
    name = "Glutfrucht",
    description = "Warme Frucht - schmeckt wie heisse Schokolade!",
    category = "food",
    icon = "rbxassetid://0",
    maxStack = 15,
    rarity = 2,
    hungerRestore = 35,
}

---------------------------------------------------------------------------
-- Universal Resources
---------------------------------------------------------------------------
Items.scrap_metal = {
    id = "scrap_metal",
    name = "Altmetall",
    description = "Nuetzliches Metall von der Station",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 50,
    rarity = 1,
}

Items.energy_cell = {
    id = "energy_cell",
    name = "Energiezelle",
    description = "Aufgeladene Zelle fuer die Station",
    category = "resource",
    icon = "rbxassetid://0",
    maxStack = 20,
    rarity = 2,
}

---------------------------------------------------------------------------
-- Tools
---------------------------------------------------------------------------
Items.scanner = {
    id = "scanner",
    name = "Scanner",
    description = "Scannt Ressourcen und zeigt sie auf der Minimap",
    category = "tool",
    icon = "rbxassetid://0",
    maxStack = 1,
    rarity = 1,
}

Items.laser_cutter = {
    id = "laser_cutter",
    name = "Laserschneider",
    description = "Sammelt Ressourcen schneller!",
    category = "tool",
    icon = "rbxassetid://0",
    maxStack = 1,
    rarity = 2,
}

Items.taming_device = {
    id = "taming_device",
    name = "Freundschafts-Geraet",
    description = "Hilft beim Anfreunden mit Aliens",
    category = "tool",
    icon = "rbxassetid://0",
    maxStack = 1,
    rarity = 2,
}

---------------------------------------------------------------------------
-- Machines & Gadgets (Phase 8)
---------------------------------------------------------------------------
Items.oxygen_generator = {
    id = "oxygen_generator",
    name = "Sauerstoff-Generator",
    description = "Erzeugt frische Luft - Sofort +50 O2!",
    category = "gadget",
    icon = "rbxassetid://0",
    maxStack = 5,
    rarity = 2,
    oxygenRestore = 50,
}

Items.food_synthesizer = {
    id = "food_synthesizer",
    name = "Nahrungs-Synthesizer",
    description = "Verwandelt Pflanzen in leckeres Essen - Sofort +40 Hunger!",
    category = "gadget",
    icon = "rbxassetid://0",
    maxStack = 5,
    rarity = 2,
    hungerRestore = 40,
}

Items.alien_beacon = {
    id = "alien_beacon",
    name = "Alien-Leuchtfeuer",
    description = "Lockt Aliens in der Naehe an!",
    category = "gadget",
    icon = "rbxassetid://0",
    maxStack = 5,
    rarity = 2,
}

Items.shield_module = {
    id = "shield_module",
    name = "Schutz-Modul",
    description = "Schuetzt vor extremer Hitze und Kaelte!",
    category = "gadget",
    icon = "rbxassetid://0",
    maxStack = 1,
    rarity = 3,
}

Items.turbo_boots = {
    id = "turbo_boots",
    name = "Turbo-Stiefel",
    description = "Laufe 50% schneller auf Planeten!",
    category = "gadget",
    icon = "rbxassetid://0",
    maxStack = 1,
    rarity = 3,
}

---------------------------------------------------------------------------
-- Gifts (for befriending aliens)
---------------------------------------------------------------------------
Items.gift_bundle = {
    id = "gift_bundle",
    name = "Geschenkpaket",
    description = "Ein buntes Paket - Aliens lieben es!",
    category = "gift",
    icon = "rbxassetid://0",
    maxStack = 10,
    rarity = 2,
}

---------------------------------------------------------------------------
-- Station Parts
---------------------------------------------------------------------------
Items.station_panel = {
    id = "station_panel",
    name = "Stationswand",
    description = "Baumaterial fuer neue Raeume",
    category = "station_part",
    icon = "rbxassetid://0",
    maxStack = 30,
    rarity = 1,
}

Items.station_window = {
    id = "station_window",
    name = "Fenster-Modul",
    description = "Panoramafenster mit Blick ins All",
    category = "station_part",
    icon = "rbxassetid://0",
    maxStack = 10,
    rarity = 2,
}

Items.station_light = {
    id = "station_light",
    name = "LED-Leuchte",
    description = "Helle Beleuchtung fuer die Station",
    category = "station_part",
    icon = "rbxassetid://0",
    maxStack = 20,
    rarity = 1,
}

---------------------------------------------------------------------------
-- Helper: Get item by ID
---------------------------------------------------------------------------
function Items.get(itemId: string): ItemDefinition?
    return Items[itemId]
end

---------------------------------------------------------------------------
-- Helper: Get all items of a category
---------------------------------------------------------------------------
function Items.getByCategory(category: string): { ItemDefinition }
    local result = {}
    for _, item in Items do
        if type(item) == "table" and item.category == category then
            table.insert(result, item)
        end
    end
    return result
end

return Items
