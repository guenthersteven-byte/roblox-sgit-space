--!strict
--[[
    Tutorial.lua
    Tutorial step definitions for new players.
    Picture-based with large arrows and highlights (kids 5-7).
    Steps are shown one at a time with big "Weiter!" buttons.
]]

local Tutorial = {}

export type TutorialStep = {
    id: number,
    title: string,
    description: string,
    icon: string,                   -- Placeholder asset ID
    voiceId: string,                -- Roblox Sound ID for narration (placeholder)
    highlightKey: string?,          -- Key to highlight (e.g. "Tab", "C", "Q")
    waitForEvent: string?,          -- Event to auto-advance: "move", "open_inventory", "gather", "craft", "quest", "shuttle"
    arrowTarget: string?,           -- UI element name to point arrow at
    position: string?,              -- "center", "bottom", "top"
}

---------------------------------------------------------------------------
-- Tutorial Steps
---------------------------------------------------------------------------
--[[
    Voice narration: voiceId fields are placeholders (rbxassetid://0).
    Replace with actual recorded audio files uploaded to Roblox.
    Record each step as a separate .ogg/.mp3 and upload via Creator Hub.
    Recommended: Friendly, slow German narration for kids 5-7.
]]
Tutorial.steps = {
    {
        id = 1,
        title = "Willkommen!",
        description = "Willkommen auf der sgit Space Station!\nDu bist ein Weltraum-Forscher!",
        icon = "rbxassetid://0",
        voiceId = "rbxassetid://0", -- "Willkommen auf der sgit Space Station! Du bist ein Weltraum-Forscher!"
        highlightKey = nil,
        waitForEvent = nil,
        arrowTarget = nil,
        position = "center",
    },
    {
        id = 2,
        title = "Bewegen",
        description = "Benutze W A S D zum Laufen\nund die Maus zum Umschauen!",
        icon = "rbxassetid://0",
        voiceId = "rbxassetid://0", -- "Benutze W A S D zum Laufen und die Maus zum Umschauen!"
        highlightKey = nil,
        waitForEvent = "move",
        arrowTarget = nil,
        position = "center",
    },
    {
        id = 3,
        title = "Dein Rucksack",
        description = "Druecke TAB um deinen\nRucksack zu oeffnen!",
        icon = "rbxassetid://0",
        voiceId = "rbxassetid://0", -- "Druecke die Tab-Taste um deinen Rucksack zu oeffnen!"
        highlightKey = "Tab",
        waitForEvent = "open_inventory",
        arrowTarget = nil,
        position = "center",
    },
    {
        id = 4,
        title = "Shuttle-Konsole",
        description = "Gehe zur Shuttle-Konsole\nund druecke E zum Benutzen!",
        icon = "rbxassetid://0",
        voiceId = "rbxassetid://0", -- "Gehe zur Shuttle-Konsole und druecke E zum Benutzen!"
        highlightKey = "E",
        waitForEvent = "shuttle",
        arrowTarget = nil,
        position = "bottom",
    },
    {
        id = 5,
        title = "Ressourcen sammeln",
        description = "Auf dem Planeten:\nGehe zu leuchtenden Sachen\nund druecke E zum Sammeln!",
        icon = "rbxassetid://0",
        voiceId = "rbxassetid://0", -- "Auf dem Planeten: Gehe zu den leuchtenden Sachen und druecke E zum Sammeln!"
        highlightKey = "E",
        waitForEvent = "gather",
        arrowTarget = nil,
        position = "bottom",
    },
    {
        id = 6,
        title = "Crafting",
        description = "Zurueck auf der Station:\nDruecke C zum Bauen!",
        icon = "rbxassetid://0",
        voiceId = "rbxassetid://0", -- "Zurueck auf der Station: Druecke C zum Bauen!"
        highlightKey = "C",
        waitForEvent = "craft",
        arrowTarget = nil,
        position = "center",
    },
    {
        id = 7,
        title = "Quests",
        description = "Druecke Q fuer deine Aufgaben!\nErfuelle sie fuer tolle Belohnungen!",
        icon = "rbxassetid://0",
        voiceId = "rbxassetid://0", -- "Druecke Q fuer deine Aufgaben! Erfuelle sie fuer tolle Belohnungen!"
        highlightKey = "Q",
        waitForEvent = "quest",
        arrowTarget = "QuestTracker",
        position = "center",
    },
    {
        id = 8,
        title = "Bereit!",
        description = "Super! Du bist jetzt\nein echter Weltraum-Forscher!\n\nViel Spass beim Erkunden!",
        icon = "rbxassetid://0",
        voiceId = "rbxassetid://0", -- "Super! Du bist jetzt ein echter Weltraum-Forscher! Viel Spass beim Erkunden!"
        highlightKey = nil,
        waitForEvent = nil,
        arrowTarget = nil,
        position = "center",
    },
}

---------------------------------------------------------------------------
-- Helper: Get step by ID
---------------------------------------------------------------------------
function Tutorial.getStep(stepId: number): TutorialStep?
    for _, step in Tutorial.steps do
        if step.id == stepId then
            return step
        end
    end
    return nil
end

---------------------------------------------------------------------------
-- Helper: Get total step count
---------------------------------------------------------------------------
function Tutorial.getStepCount(): number
    return #Tutorial.steps
end

return Tutorial
