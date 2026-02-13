-- Fix Scale: Station + Shuttle + Aliens auf richtige Groesse bringen
local ws = game:GetService("Workspace")
local ss = game:GetService("ServerStorage")

-- Helper: Model auf Zielgroesse skalieren (laengste Seite = targetSize studs)
local function scaleModelTo(model, targetSize)
    local _, size = model:GetBoundingBox()
    local maxDim = math.max(size.X, size.Y, size.Z)
    if maxDim > 0 then
        local currentScale = model:GetScale()
        local newScale = currentScale * (targetSize / maxDim)
        model:ScaleTo(newScale)
        return true
    end
    return false
end

-- Station: ~150 studs breit (passt auf 200x200 Platform)
local stationFolder = ws:FindFirstChild("SpaceStation")
if stationFolder then
    local model = stationFolder:FindFirstChildWhichIsA("Model")
    if model then
        local _, size = model:GetBoundingBox()
        print("[Scale] Station current size: " .. tostring(size))
        scaleModelTo(model, 150)
        model:PivotTo(CFrame.new(0, 110, 0))
        local _, newSize = model:GetBoundingBox()
        print("[Scale] Station new size: " .. tostring(newSize))
        print("[Scale] Station at 0, 110, 0")
    end
end

-- Shuttle: ~15 studs lang
local shuttleFolder = ws:FindFirstChild("Shuttle")
if shuttleFolder then
    local model = shuttleFolder:FindFirstChildWhichIsA("Model")
    if model then
        local _, size = model:GetBoundingBox()
        print("[Scale] Shuttle current size: " .. tostring(size))
        scaleModelTo(model, 15)
        model:PivotTo(CFrame.new(40, 103, 0))
        local _, newSize = model:GetBoundingBox()
        print("[Scale] Shuttle new size: " .. tostring(newSize))
    end
end

-- Aliens: ~4 studs hoch (kinderfreundlich, nicht zu gross)
local alienModels = ss:FindFirstChild("AlienModels")
if alienModels then
    for _, folder in alienModels:GetChildren() do
        for _, model in folder:GetChildren() do
            if model:IsA("Model") then
                local _, size = model:GetBoundingBox()
                print("[Scale] Alien " .. model.Name .. " current: " .. tostring(size))
                scaleModelTo(model, 4)
                local _, newSize = model:GetBoundingBox()
                print("[Scale] Alien " .. model.Name .. " new: " .. tostring(newSize))

                -- PrimaryPart setzen
                if not model.PrimaryPart then
                    local biggest = nil
                    local biggestSize = 0
                    for _, part in model:GetDescendants() do
                        if part:IsA("BasePart") then
                            local s = part.Size.Magnitude
                            if s > biggestSize then
                                biggestSize = s
                                biggest = part
                            end
                        end
                    end
                    if biggest then
                        model.PrimaryPart = biggest
                        print("[Scale] PrimaryPart: " .. model.Name .. " -> " .. biggest.Name)
                    end
                end
            end
        end
    end
end

print("")
print("=== Scale Fix Complete ===")
print("Station: 150 studs, Shuttle: 15 studs, Aliens: 4 studs")
print("Play to test!")
