# Damaskus Level Editor

React-based visual editor for creating levels for the Damaskus puzzle game. Export directly to GDScript arrays for use in Godot.

## Quick Start

```bash
npm install
npm run dev
```

Open browser to `http://localhost:5173`

## Features

- Visual grid editor (15x9 tiles, 128px in-game)
- Dual-layer editing (Level tiles + Masks)
- **Drag-to-reorder levels** with grip handle
- **Rename levels** with edit button
- Import/Export GDScript arrays
- Save/Load JSON files

## Tile Types (Level Layer)

| Value | Name | Color | Description |
|-------|------|-------|-------------|
| 0 | Empty | Light gray | Walkable space |
| 1 | Wall | Brown | Solid obstacle |
| 2 | Water | Blue | Water terrain (deadly without H2O mask) |
| 3 | Crumbled Wall | Orange | Destructible with RAM mask |
| 4 | Rock | Gray | Pushable object |
| 5 | Red Wall | Bright red | Phase column - DOWN in red mode, UP in blue mode |
| 6 | Blue Wall | Bright blue | Phase column - DOWN in blue mode, UP in red mode |
| 7 | Quicksand | Sandy orange | Deadly terrain |

## Mask Types (Mask Layer)

| Value | Name | Icon | Description |
|-------|------|------|-------------|
| -2 | NPC Spawn | 👻 | Spawn point for NPCs/Critters |
| -1 | Player Spawn | 🧍 | Player spawn point |
| 0 | None | - | No mask |
| 1 | **H2O** | 💧 | Walk on water tiles |
| 2 | **GOLEM** | 🗿 | Control phase columns with Space key |
| 3 | **GOAL** | 👑 | Win condition (equip to complete level) |
| 4 | **RAM** | 🔨 | Smash through crumbled walls and push rocks |

**Note**: GOLEM is the dimension-shifting mask (uses golem sprite). Each level must have exactly one Player Spawn (-1) and at least one GOAL mask (3).

### Phase Wall Mechanics

**Red Walls** and **Blue Walls** are phase columns that can be UP (blocking) or DOWN (passable):

- **Without GOLEM mask**: All phase columns stay UP and block movement
- **With GOLEM mask**:
  - **Red Mode** (default): Red walls DOWN (passable), Blue walls UP (blocking)
  - **Blue Mode**: Blue walls DOWN (passable), Red walls UP (blocking)
  - Press **Space** to toggle between red/blue modes

## Usage

### Creating Levels

1. Select layer mode (Level or Mask)
2. Choose a tile/mask from the toolbar
3. Click and drag on the grid to paint
4. Right-click to erase
5. Use level management buttons

### Level Management

- **Add Level**: Creates a new empty level
- **Duplicate**: Copies an existing level
- **Delete**: Removes a level (minimum 1 required)
- **Reorder**: Drag levels by the grip handle (≡) to reorder
- **Rename**: Click purple edit icon to rename levels

### Exporting to GDScript

1. Click "Copy" button in Export panel
2. Paste into `scripts/core/LevelGenerator.gd`
3. Replace `var level_layouts = [...]` and `var level_masks = [...]`

### Saving/Loading

- **Download JSON**: Saves all levels to .json file
- **Import JSON**: Load previously saved levels
- **Import GDScript**: Paste GDScript arrays to load levels

## Keyboard Shortcuts

- **L**: Toggle layer mode
- **Ctrl/Cmd + Arrow Keys**: Navigate between levels

## Technical Details

- **Grid**: 15 width × 9 height (1920×1080 / 128px tiles)
- **Tile Size**: 128 pixels in-game, 48 pixels in editor
- **Dependencies**: React 19, TypeScript, Vite, @dnd-kit, Tailwind CSS

## Game Integration

Synchronized with:
- `scripts/core/GridManager.gd` - TileType enum and grid constants
- `scripts/core/LevelGenerator.gd` - tile_definitions and mask_definitions
- `scripts/objects/Mask.gd` - Mask display names

**DO NOT** add tile/mask values not defined in game code.
