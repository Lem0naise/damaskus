import type { TileDefinition, MaskDefinition, Level } from '../types/level';

export const GRID_WIDTH = 15;
export const GRID_HEIGHT = 9;
export const CELL_SIZE = 48; // pixels in web editor

export const TILES: TileDefinition[] = [
  { value: 0, name: 'Empty', color: '#f0f0f0', description: 'Walkable space' },
  { value: 1, name: 'Wall', color: '#784f3c', description: 'Solid obstacle' },
  { value: 2, name: 'Water', color: '#3498db', description: 'Water tiles' },
  { value: 3, name: 'Crumbled Wall', color: '#e67e22', description: 'Destructible wall' },
  { value: 4, name: 'Rock', color: '#7f8c8d', description: 'Pushable object' },
  { value: 5, name: 'Red Wall', color: '#cc3333', description: 'Phase wall (red mode)' },
  { value: 6, name: 'Blue Wall', color: '#3333cc', description: 'Phase wall (blue mode)' },
  { value: 7, name: 'Quicksand', color: '#e59866', description: 'Sinks objects' },
];

export const MASKS: MaskDefinition[] = [
  { value: -2, name: 'NPC Spawn', color: '#5dade2', icon: '👻', description: 'NPC/Critter spawn point' },
  { value: -1, name: 'Player Spawn', color: '#48c9b0', icon: '🧍', description: 'Player spawn point' },
  { value: 0, name: 'None', color: 'transparent', icon: '', description: 'No mask' },
  { value: 1, name: 'WATER', color: '#1abc9c', icon: '💧', description: 'Walk on water' },
  { value: 2, name: 'DIMENSION', color: '#9b59b6', icon: '🔮', description: 'Toggle phase' },
  { value: 3, name: 'WINNER', color: '#f1c40f', icon: '👑', description: 'Win condition' },
  { value: 4, name: 'BATTERING_RAM', color: '#e74c3c', icon: '🔨', description: 'Break walls' },
  { value: 5, name: 'GOLEM', color: '#95a5a6', icon: '🗿', description: 'Push rocks' },
];

export const createEmptyLevel = (name: string = 'New Level'): Level => ({
  id: crypto.randomUUID(),
  name,
  levelLayout: Array(GRID_HEIGHT).fill(null).map(() => Array(GRID_WIDTH).fill(0)),
  maskLayout: Array(GRID_HEIGHT).fill(null).map(() => Array(GRID_WIDTH).fill(0)),
});
