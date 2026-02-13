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

-- Station lighting (always bright)
local STATION_SETTINGS = {
    ClockTime = 12,
    Brightness = 2.5,
    Ambient = Color3.fromHex("ccddcc"),
    OutdoorAmbient = Color3.fromHex("eeffee"),
    FogEnd = 10000,
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

return DayCycleServer
