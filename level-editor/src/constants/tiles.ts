import type { TileDefinition, MaskDefinition, Level } from '../types/level';

// Grid configuration (matches GridManager.gd)
export const GRID_WIDTH = 15; // 1920 / 128
export const GRID_HEIGHT = 9; // 1080 / 128
export const CELL_SIZE = 48; // pixels in web editor (128px in-game)

// Tile definitions (matches GridManager.TileType enum)
// Values: 0=EMPTY, 1=WALL, 2=WATER, 3=CRUMBLED_WALL, 4=ROCK,
//         5=RED_WALL, 6=BLUE_WALL, 7=QUICKSAND, 8=LASER_EMITTER
export const TILES: TileDefinition[] = [
  { value: 0, name: 'Empty', color: '#f0f0f0', description: 'Walkable space' },
  { value: 1, name: 'Wall', color: '#784f3c', description: 'Solid obstacle - blocks movement and lasers', spriteUrl: '/sprites/wall.png' },
  { value: 2, name: 'Water', color: '#3498db', description: 'Water terrain (deadly without H2O mask)', spriteUrl: '/sprites/water.png' },
  { value: 3, name: 'Crumbled Wall', color: '#e67e22', description: 'Destructible with RAM mask - blocks lasers', spriteUrl: '/sprites/crackedBlock.png' },
  { value: 4, name: 'Log', color: '#8b6f47', description: 'Pushable log - blocks lasers', spriteUrl: '/sprites/log.png' },
  { value: 5, name: 'Column (Down)', color: '#cc3333', description: 'Column - DOWN by default - blocks lasers when raised', spriteUrl: '/sprites/downpillar.png' },
  { value: 6, name: 'Column (Up)', color: '#3333cc', description: 'Column - UP by default - blocks lasers when raised', spriteUrl: '/sprites/pillar.png' },
  { value: 7, name: 'Quicksand', color: '#e59866', description: 'Deadly terrain - does not block lasers', spriteUrl: '/sprites/spikes.png' },
  { value: 8, name: 'Laser Emitter', color: '#ff0000', description: 'Emits deadly laser to paired emitter. Blocks movement. Pairs with closest aligned emitter.', spriteUrl: '/sprites/laserEmitter.png' },
];

// Mask definitions (matches in-game UI)
// Values: -2=NPC_SPAWN, -1=PLAYER_SPAWN, 0=NONE,
//         1=H2O, 2=GOLEM, 3=GOAL, 4=RAM
// NOTE: GOLEM (value 2) is the dimension-shifting mask (uses golem sprite)
export const MASKS: MaskDefinition[] = [
  { value: -2, name: 'NPC Spawn', color: '#5dade2', icon: '👻', description: 'NPC/Critter spawn point' },
  { value: -1, name: 'Player Spawn', color: '#48c9b0', icon: '🧍', description: 'Player spawn point' },
  { value: 0, name: 'None', color: 'transparent', icon: '', description: 'No mask' },
  { value: 1, name: 'H2O', color: '#1abc9c', icon: '💧', description: 'Walk on water', spriteUrl: '/sprites/maskSpirit.png' },
  { value: 2, name: 'GOLEM', color: '#9b59b6', icon: '🗿', description: 'Control phase columns - Red mode: red DOWN/blue UP. Press Space to toggle. Without this, all phase columns stay UP', spriteUrl: '/sprites/golemStill.png' },
  { value: 3, name: 'GOAL', color: '#f1c40f', icon: '👑', description: 'Equip to win the level!', spriteUrl: '/sprites/crown.png' },
  { value: 4, name: 'RAM', color: '#e74c3c', icon: '🔨', description: 'Smash through crumbled walls and push rocks!', spriteUrl: '/sprites/ram.png' },
  { value: 5, name: 'DAMASCUS STEEL', color: '#34495e', icon: '🛡️', description: 'Blocks lasers!', spriteUrl: '/sprites/damascusStill.png' },
];

export const createEmptyLevel = (name: string = 'New Level'): Level => {
  // Create grid with walls around the perimeter
  const levelLayout = Array(GRID_HEIGHT).fill(null).map((_, row) =>
    Array(GRID_WIDTH).fill(null).map((_, col) => {
      // Place walls on the edges (first/last row or first/last column)
      if (row === 0 || row === GRID_HEIGHT - 1 || col === 0 || col === GRID_WIDTH - 1) {
        return 1; // Wall
      }
      return 0; // Empty
    })
  );

  return {
    id: crypto.randomUUID(),
    name,
    levelLayout,
    maskLayout: Array(GRID_HEIGHT).fill(null).map(() => Array(GRID_WIDTH).fill(0)),
  };
};
