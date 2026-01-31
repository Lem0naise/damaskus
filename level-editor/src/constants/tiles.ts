import type { TileDefinition, MaskDefinition, Level } from '../types/level';

// Grid configuration (matches GridManager.gd)
export const GRID_WIDTH = 15; // 1920 / 128
export const GRID_HEIGHT = 9; // 1080 / 128
export const CELL_SIZE = 48; // pixels in web editor (128px in-game)

// Tile definitions (matches GridManager.TileType enum)
// Values: 0=EMPTY, 1=WALL, 2=WATER, 3=CRUMBLED_WALL, 4=ROCK,
//         5=RED_WALL, 6=BLUE_WALL, 7=QUICKSAND
export const TILES: TileDefinition[] = [
  { value: 0, name: 'Empty', color: '#f0f0f0', description: 'Walkable space' },
  { value: 1, name: 'Wall', color: '#784f3c', description: 'Solid obstacle' },
  { value: 2, name: 'Water', color: '#3498db', description: 'Water tiles' },
  { value: 3, name: 'Crumbled Wall', color: '#e67e22', description: 'Destructible wall' },
  { value: 4, name: 'Rock', color: '#7f8c8d', description: 'Pushable object' },
  { value: 5, name: 'Red Wall', color: '#cc3333', description: 'Phase column - DOWN (passable) in red mode, UP (blocks) in blue mode' },
  { value: 6, name: 'Blue Wall', color: '#3333cc', description: 'Phase column - DOWN (passable) in blue mode, UP (blocks) in red mode' },
  { value: 7, name: 'Quicksand', color: '#e59866', description: 'Sinks objects' },
];

// Mask definitions (matches in-game UI)
// Values: -2=NPC_SPAWN, -1=PLAYER_SPAWN, 0=NONE,
//         1=H2O, 2=GOLEM, 3=GOAL, 4=RAM
// NOTE: GOLEM (value 2) is the dimension-shifting mask (uses golem sprite)
export const MASKS: MaskDefinition[] = [
  { value: -2, name: 'NPC Spawn', color: '#5dade2', icon: '👻', description: 'NPC/Critter spawn point' },
  { value: -1, name: 'Player Spawn', color: '#48c9b0', icon: '🧍', description: 'Player spawn point' },
  { value: 0, name: 'None', color: 'transparent', icon: '', description: 'No mask' },
  { value: 1, name: 'H2O', color: '#1abc9c', icon: '💧', description: 'Walk on water' },
  { value: 2, name: 'GOLEM', color: '#9b59b6', icon: '🗿', description: 'Control phase columns - Red mode: red DOWN/blue UP. Press Space to toggle. Without this, all phase columns stay UP' },
  { value: 3, name: 'GOAL', color: '#f1c40f', icon: '👑', description: 'Equip to win the level!' },
  { value: 4, name: 'RAM', color: '#e74c3c', icon: '🔨', description: 'Smash through crumbled walls and push rocks!' },
];

export const createEmptyLevel = (name: string = 'New Level'): Level => ({
  id: crypto.randomUUID(),
  name,
  levelLayout: Array(GRID_HEIGHT).fill(null).map(() => Array(GRID_WIDTH).fill(0)),
  maskLayout: Array(GRID_HEIGHT).fill(null).map(() => Array(GRID_WIDTH).fill(0)),
});
