export type TileType = 0 | 1 | 2 | 3 | 4 | 5 | 6;
export type MaskType = -2 | -1 | 0 | 1 | 2 | 3 | 4 | 5;

export interface TileDefinition {
  value: TileType;
  name: string;
  color: string;
  description: string;
}

export interface MaskDefinition {
  value: MaskType;
  name: string;
  color: string;
  icon: string;
  description: string;
}

export type LevelLayout = TileType[][];
export type MaskLayout = MaskType[][];

export interface Level {
  id: string;
  name: string;
  levelLayout: LevelLayout;
  maskLayout: MaskLayout;
}

export type LayerMode = 'level' | 'mask';
