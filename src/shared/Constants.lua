--!strict
--[[
    Constants.lua
    Central game configuration and sgit.space Corporate Identity
]]

local Constants = {}

---------------------------------------------------------------------------
-- sgit.space Corporate Identity
---------------------------------------------------------------------------
Constants.COLORS = {
    PRIMARY     = Color3.fromHex("14350d"),  -- Dark green (station walls, backgrounds)
    ACCENT      = Color3.fromHex("43b02a"),  -- Bright green (buttons, glow, HUD accents)
    SURFACE     = Color3.fromHex("1a4510"),  -- UI panels, cards
    DARK        = Color3.fromHex("0a0f08"),  -- Deep space background
    WHITE       = Color3.fromHex("ffffff"),  -- Text on dark surfaces
    GLOW        = Color3.fromHex("5cd43e"),  -- Neon accents, particle glow
    WARNING     = Color3.fromHex("f5a623"),  -- Hunger/O2 low (friendly orange, not red)
    DISABLED    = Color3.fromHex("6b7280"),  -- Muted/inactive elements
}

Constants.FONTS = {
    HEADING  = Enum.Font.GothamBold,    -- Closest to Space Grotesk
    BODY     = Enum.Font.Gotham,        -- Clean body text
    BUTTON   = Enum.Font.GothamBold,    -- Strong button labels
    MONO     = Enum.Font.RobotoMono,    -- Terminal/code elements
}

Constants.UI = {
    BUTTON_MIN_SIZE   = UDim2.new(0, 120, 0, 60),  -- Large for kids
    ICON_SIZE         = UDim2.new(0, 64, 0, 64),
    CORNER_RADIUS     = UDim.new(0, 12),
    TEXT_SIZE_LARGE   = 28,
    TEXT_SIZE_MEDIUM   = 22,
    TEXT_SIZE_SMALL    = 16,
    PADDING           = UDim.new(0, 8),
}

---------------------------------------------------------------------------
-- Game Balance
---------------------------------------------------------------------------
Constants.PLAYER = {
    MAX_HEALTH        = 100,
    MAX_OXYGEN        = 100,
    MAX_HUNGER        = 100,
    HUNGER_DRAIN_RATE = 0.5,    -- Per second on planets
    OXYGEN_DRAIN_RATE = 0.3,    -- Per second on planets (station has infinite O2)
    RESPAWN_DELAY     = 3,      -- Seconds before teleport back to station
}

Constants.INVENTORY = {
    MAX_SLOTS     = 20,         -- Total inventory slots
    HOTBAR_SLOTS  = 5,          -- Quick-access slots
    MAX_STACK     = 99,         -- Default max stack size
}

Constants.CRAFTING = {
    DEFAULT_CRAFT_TIME = 2,     -- Seconds (short for kids)
}

Constants.RESOURCES = {
    RESPAWN_TIME_MIN = 30,      -- Seconds before resource respawns
    RESPAWN_TIME_MAX = 60,
    GATHER_COOLDOWN  = 1,       -- Seconds between gathers
    GATHER_DISTANCE  = 10,      -- Max studs for ProximityPrompt
}

Constants.STATION = {
    MAX_ROOMS = 12,             -- Max rooms player can build
}

Constants.ALIENS = {
    WANDER_RADIUS   = 30,       -- Studs from spawn point
    FOLLOW_DISTANCE = 5,        -- Studs behind player when tamed
    FEED_COUNT      = 3,        -- Times to feed before tamed
}

Constants.DAY_CYCLE = {
    FULL_CYCLE_SECONDS = 720,   -- 12 minutes real-time = 1 game day
    DAWN_HOUR          = 6,
    DUSK_HOUR          = 18,
    NIGHT_AMBIENT      = Color3.fromHex("1a2a40"),  -- Soft blue, not scary
}

---------------------------------------------------------------------------
-- Data Persistence
---------------------------------------------------------------------------
Constants.DATA = {
    PROFILE_STORE_NAME = "sgitSpaceStation_PlayerData_v1",
    AUTO_SAVE_INTERVAL = 300,   -- 5 minutes
}

return Constants
