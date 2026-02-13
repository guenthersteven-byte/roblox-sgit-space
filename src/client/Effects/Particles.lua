--!strict
--[[
    Particles.lua
    Ambient particle effects per planet biome.
    Creates atmospheric effects like snow, spores, fireflies, embers.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))

local Particles = {}
Particles.__index = Particles

local player: Player = nil
local activeEmitter: ParticleEmitter? = nil
local emitterPart: Part? = nil

-- Particle presets per planet theme
local PRESETS = {
    jungle = {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("43b02a")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("a8d8a0")),
        }),
        Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(0.5, 0.3),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Lifetime = NumberRange.new(3, 6),
        Rate = 8,
        Speed = NumberRange.new(0.5, 2),
        SpreadAngle = Vector2.new(180, 180),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(0.5, 0.2),
            NumberSequenceKeypoint.new(1, 1),
        }),
        LightEmission = 0.5,
    },

    ice = {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("ffffff")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("c8e8ff")),
        }),
        Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.05),
            NumberSequenceKeypoint.new(0.5, 0.15),
            NumberSequenceKeypoint.new(1, 0.05),
        }),
        Lifetime = NumberRange.new(4, 8),
        Rate = 15,
        Speed = NumberRange.new(1, 3),
        SpreadAngle = Vector2.new(180, 30),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(1, 0.8),
        }),
        LightEmission = 0.3,
    },

    mushroom = {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("ff88ff")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("88ffaa")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("ffff88")),
        }),
        Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(0.5, 0.4),
            NumberSequenceKeypoint.new(1, 0.1),
        }),
        Lifetime = NumberRange.new(5, 10),
        Rate = 6,
        Speed = NumberRange.new(0.2, 1),
        SpreadAngle = Vector2.new(180, 180),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.4),
            NumberSequenceKeypoint.new(0.5, 0.1),
            NumberSequenceKeypoint.new(1, 1),
        }),
        LightEmission = 1,
    },

    volcano = {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("ff6622")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("ffaa44")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("ff4400")),
        }),
        Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.05),
            NumberSequenceKeypoint.new(0.3, 0.2),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Lifetime = NumberRange.new(2, 5),
        Rate = 10,
        Speed = NumberRange.new(1, 4),
        SpreadAngle = Vector2.new(180, 60),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 1),
        }),
        LightEmission = 1,
    },

    station = nil, -- No particles in station
}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function Particles:Init(plr: Player)
    player = plr
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------
function Particles:Start()
    print("[Particles] Ready")
end

---------------------------------------------------------------------------
-- Set biome particles (called when player changes location)
---------------------------------------------------------------------------
function Particles.SetBiome(theme: string?)
    -- Clear existing particles
    Particles.Clear()

    if not theme or not PRESETS[theme] then
        return
    end

    local preset = PRESETS[theme]

    -- Create invisible part attached to camera for ambient particles
    local camera = workspace.CurrentCamera
    if not camera then return end

    emitterPart = Instance.new("Part")
    emitterPart.Name = "AmbientParticles"
    emitterPart.Size = Vector3.new(40, 1, 40)
    emitterPart.Transparency = 1
    emitterPart.Anchored = true
    emitterPart.CanCollide = false
    emitterPart.CanQuery = false
    emitterPart.CFrame = camera.CFrame + Vector3.new(0, 15, 0)
    emitterPart.Parent = workspace

    activeEmitter = Instance.new("ParticleEmitter")
    activeEmitter.Color = preset.Color
    activeEmitter.Size = preset.Size
    activeEmitter.Lifetime = preset.Lifetime
    activeEmitter.Rate = preset.Rate
    activeEmitter.Speed = preset.Speed
    activeEmitter.SpreadAngle = preset.SpreadAngle
    activeEmitter.Transparency = preset.Transparency
    activeEmitter.LightEmission = preset.LightEmission
    activeEmitter.RotSpeed = NumberRange.new(-30, 30)
    activeEmitter.Parent = emitterPart

    -- Move emitter part to follow player
    task.spawn(function()
        while emitterPart and emitterPart.Parent do
            local character = player.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
                if root then
                    emitterPart.CFrame = root.CFrame + Vector3.new(0, 15, 0)
                end
            end
            task.wait(0.5)
        end
    end)
end

---------------------------------------------------------------------------
-- Clear all ambient particles
---------------------------------------------------------------------------
function Particles.Clear()
    if activeEmitter then
        activeEmitter:Destroy()
        activeEmitter = nil
    end
    if emitterPart then
        emitterPart:Destroy()
        emitterPart = nil
    end
end

return Particles
