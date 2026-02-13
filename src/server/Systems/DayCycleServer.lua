--!strict
--[[
    DayCycleServer.lua
    Manages day/night cycle for planets.
    Station always has artificial light (no cycle).
    Night on planets is soft and non-scary (kid-friendly).
]]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))

local DayCycleServer = {}
DayCycleServer.__index = DayCycleServer

local isRunning = false
local currentHour = 10 -- Start at 10 AM (bright and friendly)
local cycleSpeed = 24 / Constants.DAY_CYCLE.FULL_CYCLE_SECONDS -- Hours per second

-- Lighting presets
local DAY_SETTINGS = {
    ClockTime = 14,
    Brightness = 2,
    Ambient = Color3.fromHex("8ca88c"),
    OutdoorAmbient = Color3.fromHex("aaccaa"),
    FogEnd = 10000,
}

local NIGHT_SETTINGS = {
    ClockTime = 22,
    Brightness = 0.5,
    Ambient = Constants.DAY_CYCLE.NIGHT_AMBIENT,
    OutdoorAmbient = Color3.fromHex("2a3a5a"),
    FogEnd = 600,
}

-- Station lighting (space-themed: dark sky with stars, soft station glow)
local STATION_SETTINGS = {
    ClockTime = 0, -- Midnight = dark sky with stars visible
    Brightness = 0.8, -- Soft brightness from station lights
    Ambient = Color3.fromHex("1a2a3a"), -- Cool blue-black ambient
    OutdoorAmbient = Color3.fromHex("0a0a1a"), -- Very dark outdoor (space!)
    FogEnd = 100000, -- No fog in space (see everything)
}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function DayCycleServer:Init()
    -- Set initial lighting to station (players start there)
    self:SetStationLighting()
    print("[DayCycleServer] Initialized")
end

---------------------------------------------------------------------------
-- Start: Begin day/night cycle loop
---------------------------------------------------------------------------
function DayCycleServer:Start()
    isRunning = true

    RunService.Heartbeat:Connect(function(dt)
        if not isRunning then return end

        currentHour = (currentHour + cycleSpeed * dt) % 24
        Lighting.ClockTime = currentHour
    end)

    -- Periodically update ambient lighting based on time
    task.spawn(function()
        while isRunning do
            self:_updateAmbient()
            task.wait(2) -- Update every 2 seconds (smooth enough)
        end
    end)

    -- Notify clients of time
    task.spawn(function()
        local Remotes = ReplicatedStorage:WaitForChild("Remotes")
        local TimeUpdated = Remotes:WaitForChild("TimeUpdated") :: RemoteEvent

        while isRunning do
            TimeUpdated:FireAllClients({
                hour = currentHour,
                isDay = self:IsDay(),
            })
            task.wait(10) -- Sync every 10 seconds
        end
    end)

    print("[DayCycleServer] Day/night cycle running")
end

---------------------------------------------------------------------------
-- Check if currently daytime
---------------------------------------------------------------------------
function DayCycleServer:IsDay(): boolean
    return currentHour >= Constants.DAY_CYCLE.DAWN_HOUR
        and currentHour < Constants.DAY_CYCLE.DUSK_HOUR
end

---------------------------------------------------------------------------
-- Get current hour
---------------------------------------------------------------------------
function DayCycleServer:GetHour(): number
    return currentHour
end

---------------------------------------------------------------------------
-- Set station lighting (no day/night cycle)
---------------------------------------------------------------------------
function DayCycleServer:SetStationLighting()
    isRunning = false
    TweenService:Create(Lighting, TweenInfo.new(1), {
        ClockTime = STATION_SETTINGS.ClockTime,
        Brightness = STATION_SETTINGS.Brightness,
        Ambient = STATION_SETTINGS.Ambient,
        OutdoorAmbient = STATION_SETTINGS.OutdoorAmbient,
        FogEnd = STATION_SETTINGS.FogEnd,
    }):Play()

    -- Setup space sky if not already created
    self:_setupSpaceSky()
end

---------------------------------------------------------------------------
-- Set planet lighting and start cycle
---------------------------------------------------------------------------
function DayCycleServer:SetPlanetLighting(planetTheme: string)
    -- Set initial time based on theme feel
    if planetTheme == "ice" then
        currentHour = 10 -- Cool morning light
    elseif planetTheme == "mushroom" then
        currentHour = 19 -- Dusk (mushrooms glow better at night)
    elseif planetTheme == "volcano" then
        currentHour = 16 -- Warm afternoon
    else
        currentHour = 12 -- Bright noon for jungle
    end

    Lighting.ClockTime = currentHour
    isRunning = true
    self:_updateAmbient()
end

---------------------------------------------------------------------------
-- Pause cycle (for shuttle transitions etc.)
---------------------------------------------------------------------------
function DayCycleServer:Pause()
    isRunning = false
end

function DayCycleServer:Resume()
    isRunning = true
end

---------------------------------------------------------------------------
-- Update ambient lighting based on current time
---------------------------------------------------------------------------
function DayCycleServer:_updateAmbient()
    local t = 0 -- 0 = full day, 1 = full night

    if currentHour >= Constants.DAY_CYCLE.DAWN_HOUR and currentHour < Constants.DAY_CYCLE.DAWN_HOUR + 2 then
        -- Dawn transition (6-8)
        t = 1 - (currentHour - Constants.DAY_CYCLE.DAWN_HOUR) / 2
    elseif currentHour >= Constants.DAY_CYCLE.DUSK_HOUR - 2 and currentHour < Constants.DAY_CYCLE.DUSK_HOUR then
        -- Dusk transition (16-18)
        t = (currentHour - (Constants.DAY_CYCLE.DUSK_HOUR - 2)) / 2
    elseif currentHour >= Constants.DAY_CYCLE.DUSK_HOUR or currentHour < Constants.DAY_CYCLE.DAWN_HOUR then
        -- Night
        t = 1
    else
        -- Day
        t = 0
    end

    -- Lerp between day and night settings
    local brightness = DAY_SETTINGS.Brightness + (NIGHT_SETTINGS.Brightness - DAY_SETTINGS.Brightness) * t
    local ambient = DAY_SETTINGS.Ambient:Lerp(NIGHT_SETTINGS.Ambient, t)
    local outdoor = DAY_SETTINGS.OutdoorAmbient:Lerp(NIGHT_SETTINGS.OutdoorAmbient, t)
    local fogEnd = DAY_SETTINGS.FogEnd + (NIGHT_SETTINGS.FogEnd - DAY_SETTINGS.FogEnd) * t

    -- Kid-friendly: Night is never too dark (min brightness 0.5)
    brightness = math.max(brightness, 0.5)

    TweenService:Create(Lighting, TweenInfo.new(1), {
        Brightness = brightness,
        Ambient = ambient,
        OutdoorAmbient = outdoor,
        FogEnd = fogEnd,
    }):Play()
end

---------------------------------------------------------------------------
-- Setup space sky with stars and nearby decorative planets
---------------------------------------------------------------------------
function DayCycleServer:_setupSpaceSky()
    -- Configure sky for space look
    local sky = Lighting:FindFirstChildWhichIsA("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end
    sky.StarCount = 5000 -- Lots of stars
    sky.SunAngularSize = 8 -- Smaller sun (distant)
    sky.MoonAngularSize = 6 -- Smaller moon
    sky.CelestialBodiesShown = true

    -- Configure atmosphere for space (very thin)
    local atmo = Lighting:FindFirstChildWhichIsA("Atmosphere")
    if not atmo then
        atmo = Instance.new("Atmosphere")
        atmo.Parent = Lighting
    end
    atmo.Density = 0.02 -- Almost no atmosphere (space!)
    atmo.Offset = 0
    atmo.Color = Color3.fromHex("050510") -- Near-black
    atmo.Decay = Color3.fromHex("050510") -- Fade to black at edges
    atmo.Glare = 0
    atmo.Haze = 0

    -- Bloom for glowing station lights
    local bloom = Lighting:FindFirstChildWhichIsA("BloomEffect")
    if not bloom then
        bloom = Instance.new("BloomEffect")
        bloom.Parent = Lighting
    end
    bloom.Intensity = 0.6
    bloom.Size = 24
    bloom.Threshold = 0.7

    -- Create decorative planets in the distance
    self:_createDecoPlanets()

    print("[DayCycleServer] Space sky configured")
end

---------------------------------------------------------------------------
-- Create decorative planet spheres visible from station
---------------------------------------------------------------------------
function DayCycleServer:_createDecoPlanets()
    local decoFolder = workspace:FindFirstChild("DecoPlanets")
    if decoFolder then return end -- Already created

    decoFolder = Instance.new("Folder")
    decoFolder.Name = "DecoPlanets"
    decoFolder.Parent = workspace

    local planets = {
        {
            name = "RedGiant",
            pos = Vector3.new(4000, 800, 3000),
            size = 600,
            color = Color3.fromHex("cc4422"),
            material = Enum.Material.Neon,
        },
        {
            name = "IceWorld",
            pos = Vector3.new(-3000, 400, 4000),
            size = 350,
            color = Color3.fromHex("88bbff"),
            material = Enum.Material.Ice,
        },
        {
            name = "GasGiant",
            pos = Vector3.new(-5000, 1200, -2000),
            size = 900,
            color = Color3.fromHex("ddaa44"),
            material = Enum.Material.SmoothPlastic,
        },
        {
            name = "SmallMoon",
            pos = Vector3.new(2000, 600, -3000),
            size = 150,
            color = Color3.fromHex("aaaaaa"),
            material = Enum.Material.Slate,
        },
        {
            name = "GreenNebula",
            pos = Vector3.new(-1500, 1500, 5000),
            size = 250,
            color = Color3.fromHex("33cc55"),
            material = Enum.Material.Neon,
        },
    }

    for _, planetData in planets do
        local planet = Instance.new("Part")
        planet.Name = planetData.name
        planet.Shape = Enum.PartType.Ball
        planet.Size = Vector3.new(planetData.size, planetData.size, planetData.size)
        planet.Position = planetData.pos
        planet.Color = planetData.color
        planet.Material = planetData.material
        planet.Anchored = true
        planet.CanCollide = false -- Decoration only
        planet.CastShadow = false
        planet.Parent = decoFolder

        -- Add subtle glow to neon planets
        if planetData.material == Enum.Material.Neon then
            local light = Instance.new("PointLight")
            light.Color = planetData.color
            light.Brightness = 0.3
            light.Range = planetData.size * 0.5
            light.Parent = planet
        end
    end

    print("[DayCycleServer] Decorative planets created (" .. #planets .. ")")
end

return DayCycleServer
