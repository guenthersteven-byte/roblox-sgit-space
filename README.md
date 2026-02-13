# sgit Space Station - Roblox Game

Roblox-Spiel im sgit.space Corporate Design. Kinder (5-7 Jahre) erkunden von einer Raumstation aus verschiedene Planeten, sammeln Ressourcen, craften Werkzeuge, bauen die Station aus und befreunden Aliens.

## Status: Phase 1 - Projektstruktur

## Tech Stack

| Tool | Zweck |
|------|-------|
| **Rojo v7** | Filesystem <-> Roblox Studio Sync |
| **Blender + MCP** | 3D-Modelle erstellen (Claude-gesteuert) |
| **Roblox Studio** | Visuelles Bauen, Testing, Publishing |
| **Luau** | Scripting-Sprache (strikt getypt) |
| **ProfileStore** | Spieler-Daten Persistenz |

## Setup

### 1. Rojo installieren

**Option A: VS Code Extension**
- VS Code Extension "Rojo" installieren (by evaera)

**Option B: CLI**
- Download von https://github.com/rojo-rbx/rojo/releases
- Binary in PATH legen

### 2. Roblox Studio

1. Roblox Studio oeffnen
2. Rojo Plugin installieren: https://www.roblox.com/library/13916111004
3. Neues Place erstellen (File -> New)
4. Rojo Plugin in Studio oeffnen (Plugins Tab)

### 3. Verbinden

```bash
cd services/robloxStudio
rojo serve
```

In Roblox Studio: Rojo Plugin -> "Connect" klicken (Port 34872)

### 4. Blender MCP

Blender MCP ermoeglicht Claude, direkt 3D-Modelle in Blender zu erstellen.

**Setup:**
1. Blender installiert (bereits erledigt)
2. BlenderMCP Addon installieren: https://github.com/ahujasid/blender-mcp
3. In Claude Code MCP Config eintragen
4. Blender starten, MCP Server im Addon aktivieren

**Workflow:**
- Claude erstellt Modelle in Blender via MCP
- Export als FBX (Scale 0.01)
- FBX in Roblox Studio importieren (Asset Manager)

## Projektstruktur

```
src/
  server/           -> ServerScriptService (Server-Logik)
  client/           -> StarterPlayerScripts (Client-Logik)
  shared/           -> ReplicatedStorage (gemeinsame Module)
  StarterGui/       -> StarterGui (UI)
  ServerStorage/    -> ServerStorage (Server-Daten)
blender/            -> Blender-Projekte & FBX-Exports
```

### Script-Konventionen

| Dateiendung | Wird zu | Laeuft auf |
|-------------|---------|------------|
| `.server.lua` | Script | Server |
| `.client.lua` | LocalScript | Client |
| `.lua` | ModuleScript | Require'd |
| `init.server.lua` | Script (Ordner wird Script) | Server |
| `init.client.lua` | LocalScript (Ordner wird Script) | Client |
| `init.lua` | ModuleScript (Ordner wird Modul) | Require'd |

## Spielkonzept

### Planeten

| Planet | Thema | Ressourcen |
|--------|-------|------------|
| Verdania | Dschungel | Kristalle, Pflanzen, Holz |
| Glacius | Eis | Eiskristalle, Metall |
| Luminos | Leuchtpilze | Leuchtpilze, Energie-Orbs |
| Volcanus | Vulkan (mild) | Lavasteine, Obsidian |

### sgit.space CI Farben

- Primary: `#14350d` (Dunkles Gruen)
- Accent: `#43b02a` (Helles Gruen)
- Surface: `#1a4510` (Panels)
- Dark: `#0a0f08` (Weltraum)
- Glow: `#5cd43e` (Neon-Akzente)

## Entwicklung

Phasen:
1. **Projektstruktur** (aktuell)
2. **Raumstation Hub & Core Systems** (Inventory, Crafting, HUD)
3. **Planeten & Exploration** (Shuttle, Ressourcen, Biomes)
4. **Aliens, Quests & Station-Ausbau**
5. **Polish, Feier-Effekte & Launch**
