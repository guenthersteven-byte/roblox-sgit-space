--[[
	Colorize Models Script for Roblox Studio Command Bar

	Purpose: Apply CI colors and materials to imported FBX models (Space Station & Shuttle)
	Usage: Select all in Command Bar and press Enter

	Author: sgit.space
	Date: 2026-02-13
]]

-- CI Color Palette
local COLORS = {
	PRIMARY = Color3.fromHex("14350d"),
	ACCENT = Color3.fromHex("43b02a"),
	GLOW = Color3.fromHex("5cd43e"),
	SURFACE = Color3.fromHex("1a4510"),
	DARK = Color3.fromHex("0a0f08"),
	WINDOW = Color3.fromHex("1a2a40"),
	METAL = Color3.fromHex("2a2a2a"),
	LIGHT_GRAY = Color3.fromHex("8a9a8a"),
	DARK_GRAY = Color3.fromHex("3a3a3a"),
	BLACK_METAL = Color3.fromHex("1a1a1a"),
	ORANGE = Color3.fromHex("ff6600"),
	RED = Color3.fromHex("ff0000"),
	GREEN = Color3.fromHex("00ff00"),
}

-- Pattern matching rules for Space Station
local STATION_RULES = {
	-- Hub Components
	{pattern = "Hub_Torus", color = COLORS.PRIMARY, material = Enum.Material.Metal},
	{pattern = "Hub_Dome_Top", color = COLORS.PRIMARY, material = Enum.Material.Metal},
	{pattern = "Hub_Dome_Bottom", color = COLORS.PRIMARY, material = Enum.Material.Metal},
	{pattern = "Hub_ObsDome", color = COLORS.WINDOW, material = Enum.Material.Glass, transparency = 0.3},
	{pattern = "Hub_GlowRing_", color = COLORS.GLOW, material = Enum.Material.Neon},

	-- Arm/Corridor Components
	{pattern = "Arm_Corridor_", color = COLORS.METAL, material = Enum.Material.Metal},
	{pattern = "ArmRing_", color = COLORS.GLOW, material = Enum.Material.Neon},

	-- Docking Bay
	{pattern = "DockLight_", color = COLORS.ACCENT, material = Enum.Material.Neon},
	{pattern = "Dock_", color = COLORS.DARK, material = Enum.Material.Metal},

	-- Landing Pad
	{pattern = "LandingPad", color = COLORS.SURFACE, material = Enum.Material.Metal},
	{pattern = "LandingH", color = COLORS.ACCENT, material = Enum.Material.Neon},
	{pattern = "LandingLight_", color = COLORS.GLOW, material = Enum.Material.Neon},
	{pattern = "LandingStrut_", color = COLORS.METAL, material = Enum.Material.Metal},

	-- Solar Panels
	{pattern = "Solar_Panel_", color = COLORS.WINDOW, material = Enum.Material.Glass},
	{pattern = "Solar_Arm_", color = COLORS.METAL, material = Enum.Material.Metal},

	-- Antenna
	{pattern = "Antenna_Tip", color = COLORS.GLOW, material = Enum.Material.Neon},
	{pattern = "Antenna_Mast", color = COLORS.METAL, material = Enum.Material.Metal},
	{pattern = "Antenna_Dish", color = COLORS.METAL, material = Enum.Material.Metal},

	-- Thrusters
	{pattern = "ThrusterGlow_", color = COLORS.ORANGE, material = Enum.Material.Neon},
	{pattern = "Thruster_", color = COLORS.DARK, material = Enum.Material.Metal},

	-- Windows
	{pattern = "Window_Glass_", color = COLORS.WINDOW, material = Enum.Material.Glass, transparency = 0.3},
	{pattern = "Window_Frame_", color = COLORS.METAL, material = Enum.Material.Metal},

	-- Airlock
	{pattern = "Airlock_Frame", color = COLORS.GLOW, material = Enum.Material.Neon},
	{pattern = "Airlock_Door", color = COLORS.SURFACE, material = Enum.Material.Metal},
}

-- Pattern matching rules for Shuttle
local SHUTTLE_RULES = {
	-- Main Body
	{pattern = "Shuttle_Body", color = COLORS.LIGHT_GRAY, material = Enum.Material.Metal},
	{pattern = "Shuttle_Nose", color = COLORS.LIGHT_GRAY, material = Enum.Material.Metal},
	{pattern = "Shuttle_Belly", color = COLORS.LIGHT_GRAY, material = Enum.Material.Metal},
	{pattern = "Shuttle_Ridge", color = COLORS.LIGHT_GRAY, material = Enum.Material.Metal},

	-- Cockpit
	{pattern = "Shuttle_Cockpit", color = COLORS.WINDOW, material = Enum.Material.Glass, transparency = 0.3},

	-- Accent Stripes
	{pattern = "Shuttle_AccentStripe_", color = COLORS.ACCENT, material = Enum.Material.Neon},

	-- Wings & Tail
	{pattern = "Shuttle_WingTip_", color = COLORS.ACCENT, material = Enum.Material.Neon},
	{pattern = "Shuttle_Wing_", color = COLORS.DARK_GRAY, material = Enum.Material.Metal},
	{pattern = "Shuttle_Tail", color = COLORS.DARK_GRAY, material = Enum.Material.Metal},

	-- Glow Effects
	{pattern = "Shuttle_GlowStrip_", color = COLORS.GLOW, material = Enum.Material.Neon},

	-- Navigation Lights (special handling needed)
	{pattern = "Shuttle_NavLight_L", color = COLORS.RED, material = Enum.Material.Neon},
	{pattern = "Shuttle_NavLight_R", color = COLORS.GREEN, material = Enum.Material.Neon},

	-- Engines
	{pattern = "Shuttle_ThrusterGlow_", color = COLORS.ORANGE, material = Enum.Material.Neon},
	{pattern = "Shuttle_Engine_", color = COLORS.BLACK_METAL, material = Enum.Material.Metal},
	{pattern = "Shuttle_Nozzle_", color = COLORS.DARK_GRAY, material = Enum.Material.Metal},

	-- Landing Gear
	{pattern = "Shuttle_LandingPad_", color = COLORS.BLACK_METAL, material = Enum.Material.Metal},
	{pattern = "Shuttle_LandingLeg_", color = COLORS.DARK_GRAY, material = Enum.Material.Metal},

	-- Windows
	{pattern = "Shuttle_Window_Glass_", color = COLORS.WINDOW, material = Enum.Material.Glass, transparency = 0.3},
	{pattern = "Shuttle_Window_Frame_", color = COLORS.DARK_GRAY, material = Enum.Material.Metal},

	-- Door
	{pattern = "Shuttle_DoorFrame", color = COLORS.GLOW, material = Enum.Material.Neon},
	{pattern = "Shuttle_Door", color = COLORS.SURFACE, material = Enum.Material.Metal},

	-- Antenna
	{pattern = "Shuttle_Antenna", color = COLORS.DARK_GRAY, material = Enum.Material.Metal},
}

-- Fallback for unmatched parts
local FALLBACK_COLOR = COLORS.METAL
local FALLBACK_MATERIAL = Enum.Material.Metal

-- Statistics tracking
local stats = {
	station_colored = 0,
	station_fallback = 0,
	shuttle_colored = 0,
	shuttle_fallback = 0,
	total = 0
}

--[[
	Apply color rule to a BasePart
]]
local function applyRule(part, rule)
	if part:IsA("BasePart") then
		part.Color = rule.color
		part.Material = rule.material
		if rule.transparency then
			part.Transparency = rule.transparency
		end
		return true
	end
	return false
end

--[[
	Find matching rule for a part name
]]
local function findMatchingRule(partName, rules)
	for _, rule in ipairs(rules) do
		if string.find(partName, rule.pattern) then
			return rule
		end
	end
	return nil
end

--[[
	Recursively colorize all parts in a model
]]
local function colorizeModel(model, rules, statsKey, fallbackKey)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local rule = findMatchingRule(descendant.Name, rules)

			if rule then
				if applyRule(descendant, rule) then
					stats[statsKey] = stats[statsKey] + 1
				end
			else
				-- Apply fallback
				if applyRule(descendant, {
					color = FALLBACK_COLOR,
					material = FALLBACK_MATERIAL
				}) then
					stats[fallbackKey] = stats[fallbackKey] + 1
					print("  [Fallback] " .. descendant.Name)
				end
			end

			stats.total = stats.total + 1
		end
	end
end

--[[
	Main execution
]]
local function main()
	print("=== Colorize Models Script ===")
	print("Started: " .. os.date("%Y-%m-%d %H:%M:%S"))
	print("")

	local workspace = game:GetService("Workspace")

	-- Colorize Space Station
	local stationModel = workspace:FindFirstChild("SpaceStation")
	if stationModel then
		local station = stationModel:FindFirstChild("space_station")
		if station then
			print("[Space Station] Colorizing...")
			colorizeModel(station, STATION_RULES, "station_colored", "station_fallback")
			print("[Space Station] Complete")
		else
			warn("[Space Station] Model 'space_station' not found inside SpaceStation")
		end
	else
		warn("[Space Station] SpaceStation not found in Workspace")
	end

	print("")

	-- Colorize Shuttle
	local shuttleModel = workspace:FindFirstChild("Shuttle")
	if shuttleModel then
		local shuttle = shuttleModel:FindFirstChild("shuttle")
		if shuttle then
			print("[Shuttle] Colorizing...")
			colorizeModel(shuttle, SHUTTLE_RULES, "shuttle_colored", "shuttle_fallback")
			print("[Shuttle] Complete")
		else
			warn("[Shuttle] Model 'shuttle' not found inside Shuttle")
		end
	else
		warn("[Shuttle] Shuttle not found in Workspace")
	end

	-- Print summary
	print("")
	print("=== Summary ===")
	print("Space Station:")
	print("  - Colored with rules: " .. stats.station_colored)
	print("  - Fallback (gray metal): " .. stats.station_fallback)
	print("Shuttle:")
	print("  - Colored with rules: " .. stats.shuttle_colored)
	print("  - Fallback (gray metal): " .. stats.shuttle_fallback)
	print("Total parts processed: " .. stats.total)
	print("")
	print("=== Colorization Complete ===")
end

-- Execute
main()
