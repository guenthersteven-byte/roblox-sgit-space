# sgit Space Station - Projekt Status

**Service:** Roblox Game - sgit Space Station
**CT:** - (lokale Entwicklung, kein Container)
**Typ:** Roblox Studio + Rojo + Blender MCP
**Zielgruppe:** Kinder 5-7 Jahre

---

## Aktueller Status: Bereit fuer Roblox Studio Integration

| Phase | Status | Beschreibung |
|-------|--------|--------------|
| Phase 1: Projekt-Setup | ERLEDIGT | Rojo, Projektstruktur, Shared Modules, Bootstrap |
| Phase 2: Station Hub & Core | ERLEDIGT | Inventory, Crafting, HUD, PlayerData, Recipes, UI |
| Phase 3: Planeten & Exploration | ERLEDIGT | Shuttle, Ressourcen, Planeten, Tag/Nacht, Minimap, Effekte |
| Phase 4: Aliens & Quests | ERLEDIGT | Alien AI, Quests, Station-Ausbau, Quest-Integration |
| Phase 5: Polish & Launch | ERLEDIGT | Tutorial mit Vorlese-Support, Settings/Accessibility, Rate-Limiting |
| Phase 6: 3D-Assets | ERLEDIGT | Station, Shuttle, 5 Aliens, 21 Planeten-Props (4 Planeten + Scrap Metal) |

---

## Toolchain Status

| Tool | Version | Status |
|------|---------|--------|
| Rojo CLI | 7.7.0-rc.1 | Installiert (via Aftman) |
| Rojo VS Code Extension | 2.1.2 (evaera) | Installiert |
| Rojo Studio Plugin | 7.7.0-rc.1 | Installiert, Sync funktioniert |
| Roblox Studio | Aktuell | Installiert |
| Blender | 5.0 | Installiert (C:\Program Files\Blender Foundation\Blender 5.0) |
| Blender MCP | addon v1.2 + blender-mcp v1.5.5 | Addon installiert, Server laeuft (Port 9876), MCP-Config erstellt, Verbindung verifiziert |
| uv/uvx | 0.10.2 | Installiert (C:\Users\SG\.local\bin\uvx.exe), blender-mcp vorinstalliert |

---

## Erstellte Dateien

### Konfiguration
- [x] `default.project.json` - Rojo v7 Projekt-Mapping
- [x] `.gitignore` - Roblox/Blender Excludes
- [x] `.luaurc` - Luau strict typing + Globals
- [x] `README.md` - Projekt-Dokumentation

### Shared Modules (src/shared/ -> ReplicatedStorage)
- [x] `Constants.lua` - sgit CI Farben, Game-Balance, UI-Config
- [x] `Types.lua` - 15+ Luau Type Definitions (Items, Crafting, Aliens, Quests, Profile)
- [x] `Items.lua` - 24 Items (4 Planeten-Ressourcen, Tools, Food, Gifts, Station Parts)
- [x] `Utility/TableUtil.lua` - deepCopy, merge, find, filter, map

### Server (src/server/ -> ServerScriptService)
- [x] `Main.server.lua` - Server Bootstrap, RemoteEvents, System-Loader

### Client (src/client/ -> StarterPlayerScripts)
- [x] `Main.client.lua` - Client Bootstrap, Controller/Effects-Loader, HUD-Integration

### Phase 2: Server Systems
- [x] `src/server/Systems/PlayerDataManager.lua` - DataStore Persistence, Auto-Save, Profile Load/Save
- [x] `src/server/Systems/InventoryServer.lua` - AddItem, RemoveItem, HasItem, Stacking
- [x] `src/server/Systems/CraftingServer.lua` - Recipe Validation, Material Check, Craft Execution, Quest-Callback
- [x] `src/ServerStorage/ProfileTemplate.lua` - Default Player Profile

### Phase 2: Client Controllers
- [x] `src/client/Controllers/UIController.lua` - ScreenGui, Panel Management, UI Factory
- [x] `src/client/Controllers/InventoryUI.lua` - Grid Layout, 20 Slots, Tab-Toggle, Live Updates
- [x] `src/client/Controllers/CraftingUI.lua` - Recipe Cards, Material Check, Craft Button, C-Toggle

### Phase 2: Shared Data
- [x] `src/shared/Recipes.lua` - 8 Crafting Recipes (4 Starter + 4 Quest-unlocked)

### Phase 2: UI
- [x] `src/StarterGui/SpaceStationUI/HUD.lua` - Health/O2/Hunger Bars + 5-Slot Hotbar

### Phase 3: Server Systems
- [x] `src/server/Systems/DayCycleServer.lua` - Tag/Nacht Zyklus, Station/Planet Lighting
- [x] `src/server/Systems/PlanetManager.lua` - Planet-Zonen, Ressourcen-Spawning, Quest-Callback
- [x] `src/server/Systems/ShuttleSystem.lua` - Station<->Planet Teleport, Quest-Callback

### Phase 3: Client Controllers
- [x] `src/client/Controllers/ShuttleUI.lua` - Planet-Auswahl Cards, Lock-Status, Loading-Overlay
- [x] `src/client/Controllers/MinimapUI.lua` - Runder Minimap, Ressourcen/Spieler/Pads als Dots

### Phase 3: Effects
- [x] `src/client/Effects/Particles.lua` - Biom-Partikel (Dschungel/Schnee/Pilzsporen/Funken)
- [x] `src/client/Effects/Sounds.lua` - Ambient Sound Crossfade, SFX System (Placeholder IDs)
- [x] `src/client/Effects/Celebrations.lua` - Sparkles, Konfetti, Herzen, Screen-Flash, Floating Messages

### Phase 3: Shared Data
- [x] `src/shared/Planets.lua` - 4 Planeten (Verdania, Glacius, Luminos, Volcanus)

### Phase 4: Server Systems
- [x] `src/server/Systems/AlienManager.lua` - Alien AI (FSM: idle/wander/happy/follow), Feeding, Taming, ProximityPrompt
- [x] `src/server/Systems/QuestManager.lua` - Quest Tracking, Objective Progress, Rewards, Unlock-Chains
- [x] `src/server/Systems/StationBuilder.lua` - Room Building, Material Check, Build Slots, Visual Feedback

### Phase 4: Client Controllers
- [x] `src/client/Controllers/QuestUI.lua` - Mini-Tracker (immer sichtbar) + Voller Quest-Panel (Q-Toggle)
- [x] `src/client/Controllers/StationUI.lua` - Raum-Auswahl Cards, Material-Anzeige, Build-Button (B-Toggle)

### Phase 4: Shared Data
- [x] `src/shared/Aliens.lua` - 4 Alien-Spezies (Blob, Pinguin, Gluehwuermchen, Salamander)
- [x] `src/shared/Quests.lua` - 12 Quests (Sammeln, Craften, Bauen, Zaehmen, Erkunden)
- [x] `src/shared/StationRooms.lua` - 8 Raeume (Lager, Garten, Schlafkabine, Labor, Sternwarte, Krankenstation, Alien-Zimmer, Maschinenraum)

### Phase 4: System-Integrationen
- [x] CraftingServer -> QuestManager.OnItemCrafted()
- [x] PlanetManager -> QuestManager.OnItemGathered()
- [x] ShuttleSystem -> QuestManager.OnPlanetVisited()
- [x] AlienManager -> QuestManager.OnAlienFed() / OnAlienTamed()
- [x] StationBuilder -> QuestManager.OnRoomBuilt()

### Phase 5: Client Controllers
- [x] `src/client/Controllers/TutorialController.lua` - 8-Schritt Tutorial, Vorlese-Support, Auto-Advance, Key-Highlights
- [x] `src/client/Controllers/SettingsUI.lua` - Sound/Musik/Vorlesen Toggle, UI-Groesse (Normal/GROSS), P-Toggle

### Phase 5: Shared Data
- [x] `src/shared/Tutorial.lua` - 8 Tutorial-Schritte mit voiceId fuer Narration

### Phase 5: Server-Optimierungen
- [x] `Main.server.lua` - TutorialComplete RemoteEvent + Handler
- [x] `PlanetManager.lua` - Rate-Limiting fuer Gathering (Anti-Exploit)

---

## Quest-Kette

| Quest | Name | Typ | Belohnung |
|-------|------|-----|-----------|
| 001 | Erste Kristalle | 5x Gruene Kristalle sammeln | Scrap Metal |
| 002 | Erste Erfindung | Energiezelle craften | Unlock: energy_cell Rezept |
| 003 | Dschungel-Forscher | Holz + Pflanzen sammeln | Unlock: laser_cutter Rezept |
| 004 | Erster Kontakt | 2x Geschenkpaket craften | Unlock: taming_device Rezept |
| 005 | Beste Freunde | Blob zaehmen | Unlock: Glacius + station_window Rezept |
| 006 | Eis-Forscher | Eiskristalle sammeln + Glacius besuchen | Frost-Ressourcen |
| 007 | Stations-Baumeister | Ersten Raum bauen | Station-Materialien |
| 008 | Forschungslabor | Labor bauen | Unlock: Luminos |
| 009 | Pilz-Jaeger | Leuchtpilze sammeln | Luminos-Ressourcen |
| 010 | Eis-Freund | Pinguin zaehmen | Eis-Ressourcen |
| 011 | Grosser Baumeister | 3 Raeume bauen | Energy Cells + Fenster |
| 012 | Galaxie-Forscher | Alle Planeten besuchen | Unlock: Volcanus |

---

## Verzeichnisstruktur

```
services/robloxStudio/
├── src/
│   ├── server/
│   │   ├── Main.server.lua              [FERTIG]
│   │   └── Systems/
│   │       ├── PlayerDataManager.lua    [FERTIG]
│   │       ├── InventoryServer.lua      [FERTIG]
│   │       ├── CraftingServer.lua       [FERTIG + Quest-Integration]
│   │       ├── DayCycleServer.lua       [FERTIG]
│   │       ├── PlanetManager.lua        [FERTIG + Quest + Rate-Limiting]
│   │       ├── ShuttleSystem.lua        [FERTIG + Quest-Integration]
│   │       ├── AlienManager.lua         [FERTIG - Phase 4]
│   │       ├── QuestManager.lua         [FERTIG - Phase 4]
│   │       └── StationBuilder.lua       [FERTIG - Phase 4]
│   ├── client/
│   │   ├── Main.client.lua              [FERTIG]
│   │   ├── Controllers/
│   │   │   ├── UIController.lua         [FERTIG]
│   │   │   ├── InventoryUI.lua          [FERTIG]
│   │   │   ├── CraftingUI.lua           [FERTIG]
│   │   │   ├── ShuttleUI.lua            [FERTIG]
│   │   │   ├── MinimapUI.lua            [FERTIG]
│   │   │   ├── QuestUI.lua              [FERTIG - Phase 4]
│   │   │   ├── StationUI.lua            [FERTIG - Phase 4]
│   │   │   ├── TutorialController.lua   [FERTIG - Phase 5]
│   │   │   └── SettingsUI.lua           [FERTIG - Phase 5]
│   │   └── Effects/
│   │       ├── Particles.lua            [FERTIG]
│   │       ├── Sounds.lua               [FERTIG]
│   │       └── Celebrations.lua         [FERTIG]
│   ├── shared/
│   │   ├── Constants.lua                [FERTIG]
│   │   ├── Types.lua                    [FERTIG]
│   │   ├── Items.lua                    [FERTIG]
│   │   ├── Recipes.lua                  [FERTIG]
│   │   ├── Planets.lua                  [FERTIG]
│   │   ├── Aliens.lua                   [FERTIG - Phase 4]
│   │   ├── Quests.lua                   [FERTIG - Phase 4]
│   │   ├── StationRooms.lua             [FERTIG - Phase 4]
│   │   ├── Tutorial.lua                 [FERTIG - Phase 5]
│   │   └── Utility/
│   │       └── TableUtil.lua            [FERTIG]
│   ├── StarterGui/
│   │   └── SpaceStationUI/
│   │       └── HUD.lua                  [FERTIG]
│   └── ServerStorage/
│       └── ProfileTemplate.lua          [FERTIG]
├── blender/
│   ├── blender_mcp_addon.py             [INSTALLIERT - v1.2]
│   ├── station/
│   │   └── space_station.blend           [FERTIG - 100 Objekte, 9 Collections]
│   ├── planets/
│   │   └── planet_props_all.blend        [FERTIG - 4 Planeten: Verdania, Glacius, Luminos, Volcanus + Scrap]
│   ├── aliens/
│   │   └── aliens_all.blend              [FERTIG - 5 Aliens: Blobbi, Pingui, Glimmi, Flammi, GreenAlien]
│   ├── shuttle/
│   │   └── shuttle.blend                 [FERTIG - Chunky Kid-Friendly Shuttle]
│   └── export/
│       ├── space_station.fbx             [FERTIG - Scale 0.01]
│       ├── shuttle.fbx                   [FERTIG - Scale 0.01]
│       ├── alien_blobbi.fbx              [FERTIG - 14 Objekte]
│       ├── alien_pingui.fbx              [FERTIG - 15 Objekte]
│       ├── alien_glimmi.fbx              [FERTIG - 22 Objekte]
│       ├── alien_flammi.fbx              [FERTIG - 28 Objekte]
│       ├── alien_green_alien.fbx         [FERTIG - 24 Objekte]
│       ├── prop_verdania_crystal.fbx    [FERTIG]
│       ├── prop_verdania_tree.fbx       [FERTIG]
│       ├── prop_verdania_plant.fbx      [FERTIG]
│       ├── prop_verdania_berry.fbx      [FERTIG]
│       ├── prop_glacius_ice_crystal.fbx [FERTIG]
│       ├── prop_glacius_frozen_metal.fbx[FERTIG]
│       ├── prop_glacius_snowflake.fbx   [FERTIG]
│       ├── prop_glacius_frost_fish.fbx  [FERTIG]
│       ├── prop_glacius_icicle.fbx      [FERTIG]
│       ├── prop_luminos_mushroom.fbx    [FERTIG]
│       ├── prop_luminos_energy_orb.fbx  [FERTIG]
│       ├── prop_luminos_spore.fbx       [FERTIG]
│       ├── prop_luminos_carrot.fbx      [FERTIG]
│       ├── prop_luminos_giant_mush.fbx  [FERTIG]
│       ├── prop_volcanus_lava_stone.fbx [FERTIG]
│       ├── prop_volcanus_obsidian.fbx   [FERTIG]
│       ├── prop_volcanus_fire_crystal.fbx[FERTIG]
│       ├── prop_volcanus_ember_fruit.fbx[FERTIG]
│       ├── prop_volcanus_volcanic_rock.fbx[FERTIG]
│       ├── prop_volcanus_lava_pool.fbx  [FERTIG]
│       └── prop_scrap_metal.fbx         [FERTIG]
├── default.project.json                 [FERTIG]
├── .gitignore                           [FERTIG]
├── .luaurc                              [FERTIG]
├── README.md                            [FERTIG]
└── STATUS.md                            [DIESE DATEI]
```

---

## Bekannte Issues

- Rojo Binary nicht in PATH (muss ueber `C:\Users\SG\.aftman\tool-storage\rojo-rbx\rojo\7.7.0-rc.1\rojo.exe` aufgerufen werden)
- ~~Blender MCP Setup steht noch aus~~ **ERLEDIGT** (Addon + MCP-Config)
- ~~HUD.lua wurde nicht von Main.client.lua aufgerufen~~ **GEFIXT**
- ~~.mcp.json hatte falsches Format (mcpServers-Wrapper fehlte)~~ **GEFIXT**
- ~~blender-mcp musste jedes Mal 70 Packages bauen → Timeout bei Claude Code~~ **GEFIXT** (uv tool install blender-mcp, jetzt vorinstalliert)
- ~~Sound-IDs sind alle Placeholder (`rbxassetid://0`)~~ **ERLEDIGT** (Roblox Stock IDs eingetragen, in Studio verifizieren)
- ~~Alien-Modelle sind Placeholder-Parts (Kugeln) - muessen durch echte 3D-Modelle ersetzt werden~~ **ERLEDIGT** (5 Alien-FBX exportiert)

---

## Naechste Schritte

1. ~~**Blender MCP** einrichten~~ **ERLEDIGT**
2. ~~**Phase 5** starten~~ **ERLEDIGT**
3. ~~**Blender Addon in Blender installieren**~~ **ERLEDIGT** (Server laeuft Port 9876)
4. ~~**Claude Code MCP-Config fixen**~~ **ERLEDIGT** (.mcp.json hatte falsches Format, mcpServers-Wrapper fehlte)
5. ~~**blender-mcp vorinstallieren**~~ **ERLEDIGT** (`uv tool install blender-mcp` v1.5.5, 70 Packages)
6. ~~**Verbindung verifiziert**~~ **ERLEDIGT** (MCP Handshake OK, BlenderMCP v1.26.0, Blender Port 9876 offen)
7. **Claude Code Session neu starten** damit Blender MCP Tools geladen werden
   - Blender muss offen sein + MCP Server gestartet (N-Taste > BlenderMCP Tab > Start Server)
   - Dann direkt mit 3D-Assets loslegen
6. ~~**3D-Assets in Blender erstellen**~~ **ERLEDIGT** (Station, Shuttle, 5 Aliens)
7. ~~**Planeten-Props in Blender erstellen**~~ **ERLEDIGT** (21 Props: 4 Planeten + Scrap Metal)
8. **FBX-Modelle in Roblox Studio importieren** (28 FBX-Dateien im export/ Ordner)
   - Setup-Script: `scripts/setup_world.lua` (Command Bar ausfuehren)
   - Terrain-Script: `scripts/generate_terrain.lua` (Command Bar ausfuehren)
9. ~~Sound-Assets~~ **ERLEDIGT** (Roblox Stock Audio IDs in Sounds.lua eingetragen)
10. Voice-Recordings fuer Tutorial (8 deutsche Narrations-Clips)
11. Rojo Sync testen + Playtesting

---

## Blender MCP Setup-Anleitung

### Schritt 1: Addon in Blender installieren
1. Blender oeffnen (`C:\Program Files\Blender Foundation\Blender 5.0\blender.exe`)
2. Edit > Preferences > Add-ons > Install from Disk
3. Datei waehlen: `services/robloxStudio/blender/blender_mcp_addon.py`
4. Addon "Blender MCP" aktivieren (Haekchen setzen)

### Schritt 2: Verbindung starten
1. In Blender: 3D Viewport Seitenleiste oeffnen (N-Taste)
2. Tab "BlenderMCP" waehlen
3. "Start Server" klicken (Port 9876)

### Schritt 3: Claude Code neu starten
1. Diese Claude Code Session beenden
2. Neu starten - MCP-Config wird automatisch geladen
3. Blender-MCP Tools erscheinen als neue Tools

### Export-Workflow fuer Roblox
- Blender erstellt Modelle per Claude-Befehle
- Export als FBX: `blender/export/` Ordner
- Scale 0.01 fuer korrekte Roblox-Groessen
- FBX in Roblox Studio importieren (File > Import 3D)

---

## Tastenbelegung

| Taste | Funktion |
|-------|----------|
| Tab | Inventar oeffnen/schliessen |
| C | Crafting oeffnen/schliessen |
| Q | Quest-Panel oeffnen/schliessen |
| B | Station-Bau oeffnen/schliessen |
| P | Einstellungen oeffnen/schliessen |
| E | ProximityPrompt (Sammeln, Fuettern, Shuttle) |

---

*Zuletzt aktualisiert: 2026-02-13*
