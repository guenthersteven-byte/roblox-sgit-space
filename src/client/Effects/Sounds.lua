--!strict
--[[
    Sounds.lua
    Ambient sound management per planet/location.
    Uses Roblox Sound instances with crossfade transitions.

    Note: Sound IDs are placeholders - replace with actual Roblox audio asset IDs.
]]

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))

local Sounds = {}
Sounds.__index = Sounds

local player: Player = nil
local ambientSound: Sound? = nil
local sfxSounds: { [string]: Sound } = {}

-- Ambient music/sound IDs per location
-- NOTE: Since March 2022, Roblox restricts audio to creator-owned or Roblox stock.
-- These IDs are from public Roblox audio databases. If one doesn't play,
-- test in Studio Command Bar:  local s=Instance.new("Sound",workspace) s.SoundId="rbxassetid://ID" s:Play()
-- Then search Creator Hub > Audio Library for a replacement, or upload your own.
local AMBIENT_IDS = {
    station = "rbxassetid://8054429595",  -- SciFi Ambient Sound Effect
    jungle = "rbxassetid://273396693",    -- Forest/Jungle Ambience
    ice = "rbxassetid://8355232958",      -- Wind Ambient (Creator Store verified)
    mushroom = "rbxassetid://7755789977", -- Forest Ambience (ethereal/mystical)
    volcano = "rbxassetid://1847008241",  -- Volcanic Lava (a)
}

-- SFX IDs (from public Roblox audio databases)
-- Test each in Studio. Alternatives listed in comments if primary doesn't work.
local SFX_IDS = {
    gather = "rbxassetid://6787582810",      -- Coin Pickup Sound (alt: 7128958209 Bell Ding)
    craft = "rbxassetid://5670539535",       -- Crystal Sound Effect / sparkle chime
    build = "rbxassetid://399848512",        -- Construction Ambience (alt: 428545949)
    shuttle = "rbxassetid://5807235660",     -- NASA Space Shuttle Launch
    quest = "rbxassetid://2042652973",       -- Achievement fanfare (alt: 1837507072 Victory)
    alien_happy = "rbxassetid://9075431521", -- YAY Sound Effect (alt: 4602321929 Children Yay)
    button_click = "rbxassetid://6655851046",-- Button Sound Effect (alt: 4526034708 Click)
}

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------
function Sounds:Init(plr: Player)
    player = plr

    -- Create SFX sound instances
    for name, soundId in SFX_IDS do
        local sound = Instance.new("Sound")
        sound.Name = "SFX_" .. name
        sound.SoundId = soundId
        sound.Volume = 0.5
        sound.Parent = SoundService
        sfxSounds[name] = sound
    end
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------
function Sounds:Start()
    print("[Sounds] Ready (using Roblox stock audio IDs - verify in Studio)")
end

---------------------------------------------------------------------------
-- Set ambient sound for location
---------------------------------------------------------------------------
function Sounds.SetAmbient(theme: string)
    local soundId = AMBIENT_IDS[theme]
    if not soundId or soundId == "rbxassetid://0" then
        -- No valid sound, just stop current
        Sounds.StopAmbient()
        return
    end

    -- Crossfade if already playing
    if ambientSound and ambientSound.Playing then
        local oldSound = ambientSound
        TweenService:Create(oldSound, TweenInfo.new(1), { Volume = 0 }):Play()
        task.delay(1, function()
            oldSound:Stop()
            oldSound:Destroy()
        end)
    end

    -- Create new ambient sound
    ambientSound = Instance.new("Sound")
    ambientSound.Name = "Ambient_" .. theme
    ambientSound.SoundId = soundId
    ambientSound.Volume = 0
    ambientSound.Looped = true
    ambientSound.Parent = SoundService
    ambientSound:Play()

    -- Fade in
    TweenService:Create(ambientSound, TweenInfo.new(2), { Volume = 0.3 }):Play()
end

---------------------------------------------------------------------------
-- Stop ambient sound
---------------------------------------------------------------------------
function Sounds.StopAmbient()
    if ambientSound then
        TweenService:Create(ambientSound, TweenInfo.new(1), { Volume = 0 }):Play()
        local soundRef = ambientSound
        task.delay(1, function()
            soundRef:Stop()
            soundRef:Destroy()
        end)
        ambientSound = nil
    end
end

---------------------------------------------------------------------------
-- Play a sound effect
---------------------------------------------------------------------------
function Sounds.PlaySFX(name: string)
    local sound = sfxSounds[name]
    if sound then
        sound:Play()
    end
end

---------------------------------------------------------------------------
-- Play sound at a world position
---------------------------------------------------------------------------
function Sounds.PlaySFXAt(name: string, position: Vector3)
    local sound = sfxSounds[name]
    if not sound then return end

    -- Create temporary positional sound
    local tempPart = Instance.new("Part")
    tempPart.Position = position
    tempPart.Transparency = 1
    tempPart.Anchored = true
    tempPart.CanCollide = false
    tempPart.CanQuery = false
    tempPart.Size = Vector3.new(1, 1, 1)
    tempPart.Parent = workspace

    local tempSound = sound:Clone()
    tempSound.RollOffMode = Enum.RollOffMode.Linear
    tempSound.RollOffMaxDistance = 50
    tempSound.Parent = tempPart
    tempSound:Play()

    -- Cleanup after playing
    tempSound.Ended:Connect(function()
        tempPart:Destroy()
    end)

    -- Safety cleanup
    task.delay(5, function()
        if tempPart.Parent then
            tempPart:Destroy()
        end
    end)
end

return Sounds
