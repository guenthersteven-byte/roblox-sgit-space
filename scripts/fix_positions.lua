-- Fix: Station + Shuttle Position und Scale pruefen
local ws = game:GetService("Workspace")

-- Station fixen
local stationFolder = ws:FindFirstChild("SpaceStation")
if stationFolder then
    local model = stationFolder:FindFirstChildWhichIsA("Model")
    if model then
        print("[Fix] Station model found: " .. model.Name)

        -- Bounding Box checken
        local cf, size = model:GetBoundingBox()
        print("[Fix] Station current pos: " .. tostring(cf.Position))
        print("[Fix] Station size: " .. tostring(size))

        -- Wenn zu klein (unter 20 studs), hochskalieren
        if size.Magnitude < 30 then
            print("[Fix] Station zu klein! Skaliere hoch...")
            model:ScaleTo(100)
            local cf2, size2 = model:GetBoundingBox()
            print("[Fix] Station new size: " .. tostring(size2))
        end

        -- Position auf StationPlatform setzen
        model:PivotTo(CFrame.new(0, 105, 0))
        print("[Fix] Station moved to 0, 105, 0")
    else
        warn("[Fix] No model found in SpaceStation folder!")
    end
end

-- Shuttle fixen
local shuttleFolder = ws:FindFirstChild("Shuttle")
if shuttleFolder then
    local model = shuttleFolder:FindFirstChildWhichIsA("Model")
    if model then
        local cf, size = model:GetBoundingBox()
        print("[Fix] Shuttle current pos: " .. tostring(cf.Position))
        print("[Fix] Shuttle size: " .. tostring(size))

        if size.Magnitude < 10 then
            print("[Fix] Shuttle zu klein! Skaliere hoch...")
            model:ScaleTo(20)
        end

        model:PivotTo(CFrame.new(30, 103, 0))
        print("[Fix] Shuttle moved to 30, 103, 0")
    end
end

-- Alien models PrimaryPart setzen
local ss = game:GetService("ServerStorage")
local alienModels = ss:FindFirstChild("AlienModels")
if alienModels then
    for _, folder in alienModels:GetChildren() do
        for _, model in folder:GetChildren() do
            if model:IsA("Model") then
                -- Scale check
                local cf, size = model:GetBoundingBox()
                print("[Fix] Alien " .. model.Name .. " size: " .. tostring(size))

                if size.Magnitude < 3 then
                    print("[Fix] Alien " .. model.Name .. " zu klein, skaliere...")
                    model:ScaleTo(3)
                end

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
                        print("[Fix] PrimaryPart set: " .. model.Name .. " -> " .. biggest.Name)
                    end
                end
            end
        end
    end
end

print("")
print("=== Fix Complete ===")
print("Press Play to test!")
