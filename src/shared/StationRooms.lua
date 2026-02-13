--!strict
--[[
    StationRooms.lua
    Station room definitions that players can build.
    Rooms are attached to the station using materials from inventory.
]]

local Types = require(script.Parent.Types)

type RoomDefinition = Types.RoomDefinition

local StationRooms: { [string]: RoomDefinition } = {}

---------------------------------------------------------------------------
-- Storage Room: Extra inventory capacity (flavor)
---------------------------------------------------------------------------
StationRooms.storage = {
    id = "storage",
    name = "Lagerraum",
    description = "Mehr Platz! (+5 Inventar-Slots)",
    cost = {
        { itemId = "station_panel", quantity = 4 },
        { itemId = "station_light", quantity = 1 },
    },
    functionality = "storage", -- +5 inventory slots
    bonusSlots = 5,
    unlockQuestId = nil, -- Available from start
}

---------------------------------------------------------------------------
-- Garden: Grow food
---------------------------------------------------------------------------
StationRooms.garden = {
    id = "garden",
    name = "Gewaechshaus",
    description = "Langsame Hunger-Regeneration auf der Station!",
    cost = {
        { itemId = "station_panel", quantity = 4 },
        { itemId = "station_window", quantity = 2 },
        { itemId = "jungle_plant", quantity = 3 },
    },
    functionality = "garden",
    unlockQuestId = nil,
}

---------------------------------------------------------------------------
-- Bedroom: Cozy room
---------------------------------------------------------------------------
StationRooms.bedroom = {
    id = "bedroom",
    name = "Schlafkabine",
    description = "Ein gemuetliches Zimmer zum Ausruhen!",
    cost = {
        { itemId = "station_panel", quantity = 3 },
        { itemId = "station_light", quantity = 2 },
        { itemId = "alien_wood", quantity = 4 },
    },
    functionality = "bedroom",
    unlockQuestId = nil,
}

---------------------------------------------------------------------------
-- Lab: Research & advanced crafting
---------------------------------------------------------------------------
StationRooms.lab = {
    id = "lab",
    name = "Forschungslabor",
    description = "Schaltet neue Rezepte frei: Maschinen & Geraete!",
    cost = {
        { itemId = "station_panel", quantity = 6 },
        { itemId = "station_light", quantity = 3 },
        { itemId = "energy_cell", quantity = 2 },
        { itemId = "crystal_green", quantity = 5 },
    },
    functionality = "lab",
    unlockQuestId = "quest_006",
}

---------------------------------------------------------------------------
-- Observatory: View planets
---------------------------------------------------------------------------
StationRooms.observatory = {
    id = "observatory",
    name = "Sternwarte",
    description = "Zeigt welche Ressourcen auf welchem Planet zu finden sind!",
    cost = {
        { itemId = "station_panel", quantity = 4 },
        { itemId = "station_window", quantity = 4 },
        { itemId = "energy_cell", quantity = 1 },
    },
    functionality = "crafting",
    unlockQuestId = "quest_007",
}

---------------------------------------------------------------------------
-- Med Bay: Health recovery
---------------------------------------------------------------------------
StationRooms.med_bay = {
    id = "med_bay",
    name = "Krankenstation",
    description = "Schnelle Gesundheits-Regeneration auf der Station!",
    cost = {
        { itemId = "station_panel", quantity = 5 },
        { itemId = "station_light", quantity = 3 },
        { itemId = "glow_mushroom", quantity = 4 },
        { itemId = "energy_cell", quantity = 2 },
    },
    functionality = "med_bay", -- Fast health regen on station
    unlockQuestId = "quest_009",
}

---------------------------------------------------------------------------
-- Alien Room: Home for tamed aliens
---------------------------------------------------------------------------
StationRooms.alien_room = {
    id = "alien_room",
    name = "Alien-Zimmer",
    description = "Gezaehmte Aliens wohnen hier und sind auf der Station sichtbar!",
    cost = {
        { itemId = "station_panel", quantity = 5 },
        { itemId = "station_window", quantity = 2 },
        { itemId = "jungle_plant", quantity = 5 },
        { itemId = "space_berry", quantity = 5 },
    },
    functionality = "alien_home", -- Tamed aliens visible on station
    unlockQuestId = "quest_004",
}

---------------------------------------------------------------------------
-- Engine Room: Power the station
---------------------------------------------------------------------------
StationRooms.engine_room = {
    id = "engine_room",
    name = "Maschinenraum",
    description = "Das Herz der Station - Shuttle-Reise wird schneller!",
    cost = {
        { itemId = "station_panel", quantity = 8 },
        { itemId = "energy_cell", quantity = 4 },
        { itemId = "fire_crystal", quantity = 3 },
        { itemId = "frozen_metal", quantity = 5 },
    },
    functionality = "engine", -- Faster shuttle travel
    unlockQuestId = "quest_011",
}

---------------------------------------------------------------------------
-- Helper: Get room by ID
---------------------------------------------------------------------------
function StationRooms.get(roomId: string): RoomDefinition?
    return StationRooms[roomId]
end

---------------------------------------------------------------------------
-- Helper: Get all rooms
---------------------------------------------------------------------------
function StationRooms.getAll(): { RoomDefinition }
    local result = {}
    for _, room in StationRooms do
        if type(room) == "table" and room.id then
            table.insert(result, room)
        end
    end
    table.sort(result, function(a, b)
        return a.id < b.id
    end)
    return result
end

return StationRooms
