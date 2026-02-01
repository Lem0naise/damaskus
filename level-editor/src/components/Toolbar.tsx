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

  // Helper function to render tile visual with patterns
  const renderTileVisual = (tile: typeof TILES[0]) => {
    const baseStyle = { backgroundColor: tile.color };

    return (
      <div
        className="w-14 h-14 rounded border-2 border-gray-400 flex-shrink-0 relative overflow-hidden"
        style={baseStyle}
      >
        {/* Add visual patterns based on tile type */}
        {tile.value === 1 && ( // Wall - brick pattern
          <div className="absolute inset-0 opacity-30">
            <div className="h-1/3 border-b border-black"></div>
            <div className="h-1/3 border-b border-black translate-x-1/2"></div>
          </div>
        )}
        {tile.value === 2 && ( // Water - wave pattern
          <div className="absolute inset-0 flex items-center justify-center text-2xl">💧</div>
        )}
        {tile.value === 3 && ( // Crumbled wall - cracks
          <div className="absolute inset-0 opacity-40">
            <svg className="w-full h-full" viewBox="0 0 100 100">
              <path d="M 10 50 L 90 50 M 50 10 L 50 90" stroke="black" strokeWidth="3" fill="none" />
            </svg>
          </div>
        )}
        {tile.value === 4 && ( // Rock - texture
          <div className="absolute inset-0 flex items-center justify-center opacity-50">
            <div className="w-2 h-2 bg-black rounded-full"></div>
            <div className="w-2 h-2 bg-black rounded-full ml-1"></div>
          </div>
        )}
        {tile.value === 5 && ( // Red wall - vertical lines
          <div className="absolute inset-0" style={{
            background: 'repeating-linear-gradient(90deg, #cc3333 0px, #cc3333 4px, #aa2222 4px, #aa2222 8px)'
          }}></div>
        )}
        {tile.value === 6 && ( // Blue wall - vertical lines
          <div className="absolute inset-0" style={{
            background: 'repeating-linear-gradient(90deg, #3333cc 0px, #3333cc 4px, #2222aa 4px, #2222aa 8px)'
          }}></div>
        )}
        {tile.value === 7 && ( // Quicksand - dots
          <div className="absolute inset-0 opacity-40" style={{
            backgroundImage: 'radial-gradient(circle, #000 1px, transparent 1px)',
            backgroundSize: '8px 8px'
          }}></div>
        )}
        {tile.value === 8 && ( // Laser - warning stripes
          <div className="absolute inset-0" style={{
            background: 'repeating-linear-gradient(45deg, #ff0000 0px, #ff0000 6px, #ffff00 6px, #ffff00 12px)'
          }}></div>
        )}
      </div>
    );
  };

  return (
    <div className="w-80 bg-white rounded-lg shadow-lg p-4 max-h-[calc(100vh-200px)] flex flex-col">
      <h2 className="text-xl font-bold mb-4">
        {isLevel ? 'Level Tiles' : 'Masks'}
      </h2>

      <div className="grid grid-cols-2 gap-2 overflow-y-auto pr-2">
        {isLevel ? (
          TILES.map((tile) => (
            <button
              key={tile.value}
              className={clsx(
                'p-2 rounded-lg flex flex-col items-center gap-2 transition-all text-center',
                'hover:scale-105 border-2',
                selectedTile === tile.value
                  ? 'border-blue-500 shadow-lg bg-blue-50'
                  : 'border-gray-200 hover:border-gray-300'
              )}
              onClick={() => onTileSelect(tile.value)}
            >
              {renderTileVisual(tile)}
              <div className="text-xs font-semibold leading-tight">{tile.name}</div>
            </button>
          ))
        ) : (
          MASKS.map((mask) => (
            <button
              key={mask.value}
              className={clsx(
                'p-2 rounded-lg flex flex-col items-center gap-2 transition-all text-center',
                'hover:scale-105 border-2',
                selectedMask === mask.value
                  ? 'border-blue-500 shadow-lg bg-blue-50'
                  : 'border-gray-200 hover:border-gray-300'
              )}
              onClick={() => onMaskSelect(mask.value)}
            >
              <div
                className="w-14 h-14 rounded border-2 border-gray-400 flex items-center justify-center text-3xl flex-shrink-0 shadow-sm"
                style={{ backgroundColor: mask.color }}
              >
                {mask.icon}
              </div>
              <div className="text-xs font-semibold leading-tight">{mask.name}</div>
            </button>
          ))
        )}
      </div>
    </div>
  );
};
