import type { TileType, MaskType, LayerMode } from '../types/level';
import { TILES, MASKS } from '../constants/tiles';
import clsx from 'clsx';

interface ToolbarProps {
  layerMode: LayerMode;
  selectedTile: TileType;
  selectedMask: MaskType;
  onTileSelect: (tile: TileType) => void;
  onMaskSelect: (mask: MaskType) => void;
}

export const Toolbar = ({
  layerMode,
  selectedTile,
  selectedMask,
  onTileSelect,
  onMaskSelect,
}: ToolbarProps) => {
  const isLevel = layerMode === 'level';

  return (
    <div className="w-64 bg-white rounded-lg shadow-lg p-4">
      <h2 className="text-xl font-bold mb-4">
        {isLevel ? 'Level Tiles' : 'Masks'}
      </h2>

      <div className="space-y-2">
        {isLevel ? (
          TILES.map((tile) => (
            <button
              key={tile.value}
              className={clsx(
                'w-full p-3 rounded-lg flex items-center gap-3 transition-all',
                'hover:scale-105 border-2',
                selectedTile === tile.value
                  ? 'border-blue-500 shadow-lg'
                  : 'border-gray-200'
              )}
              onClick={() => onTileSelect(tile.value)}
            >
              <div
                className="w-12 h-12 rounded border border-gray-400"
                style={{ backgroundColor: tile.color }}
              />
              <div className="text-left flex-1">
                <div className="font-semibold">{tile.name}</div>
                <div className="text-xs text-gray-500">{tile.description}</div>
              </div>
            </button>
          ))
        ) : (
          MASKS.map((mask) => (
            <button
              key={mask.value}
              className={clsx(
                'w-full p-3 rounded-lg flex items-center gap-3 transition-all',
                'hover:scale-105 border-2',
                selectedMask === mask.value
                  ? 'border-blue-500 shadow-lg'
                  : 'border-gray-200'
              )}
              onClick={() => onMaskSelect(mask.value)}
            >
              <div
                className="w-12 h-12 rounded border border-gray-400 flex items-center justify-center text-2xl"
                style={{ backgroundColor: mask.color }}
              >
                {mask.icon}
              </div>
              <div className="text-left flex-1">
                <div className="font-semibold">{mask.name}</div>
                <div className="text-xs text-gray-500">{mask.description}</div>
              </div>
            </button>
          ))
        )}
      </div>
    </div>
  );
};
