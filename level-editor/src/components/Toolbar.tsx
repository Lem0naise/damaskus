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

  // Helper function to render tile visual with sprites or fallback patterns
  const renderTileVisual = (tile: typeof TILES[0]) => {
    const baseStyle = { backgroundColor: tile.color };

    return (
      <div
        className="w-10 h-10 sm:w-12 sm:h-12 lg:w-14 lg:h-14 rounded-lg border-2 border-sand-400 flex-shrink-0 relative overflow-hidden shadow-sm"
        style={baseStyle}
      >
        {tile.spriteUrl ? (
          <img
            src={tile.spriteUrl}
            alt={tile.name}
            className="w-full h-full object-cover"
          />
        ) : (
          <>
            {/* Fallback CSS patterns for tiles without sprites */}
            {tile.value === 0 && ( // Empty - no pattern
              <div className="w-full h-full"></div>
            )}
          </>
        )}
      </div>
    );
  };

  return (
    <div className="w-full lg:w-80 bg-sand-50 rounded-2xl shadow-sand border border-sand-200 p-3 md:p-4 max-h-[50vh] lg:max-h-[calc(100vh-200px)] flex flex-col">
      <h2 className="text-lg md:text-xl font-bold mb-3 md:mb-4 text-sand-800">
        {isLevel ? 'Level Tiles' : 'Masks'}
      </h2>

      <div className="grid grid-cols-3 sm:grid-cols-4 lg:grid-cols-2 gap-2 overflow-y-auto pr-2">
        {isLevel ? (
          TILES.map((tile) => (
            <button
              key={tile.value}
              className={clsx(
                'p-2 rounded-xl flex flex-col items-center gap-2 transition-all text-center',
                'hover:scale-105 border-2',
                selectedTile === tile.value
                  ? 'border-terracotta-500 shadow-sand bg-terracotta-500/10'
                  : 'border-sand-200 hover:border-sand-400 bg-sand-100/50'
              )}
              onClick={() => onTileSelect(tile.value)}
            >
              {renderTileVisual(tile)}
              <div className="text-xs font-semibold leading-tight text-sand-700">{tile.name}</div>
            </button>
          ))
        ) : (
          MASKS.map((mask) => (
            <button
              key={mask.value}
              className={clsx(
                'p-2 rounded-xl flex flex-col items-center gap-2 transition-all text-center',
                'hover:scale-105 border-2',
                selectedMask === mask.value
                  ? 'border-damascus-500 shadow-sand bg-damascus-500/10'
                  : 'border-sand-200 hover:border-sand-400 bg-sand-100/50'
              )}
              onClick={() => onMaskSelect(mask.value)}
            >
              <div
                className="w-10 h-10 sm:w-12 sm:h-12 lg:w-14 lg:h-14 rounded-lg border-2 border-sand-400 flex items-center justify-center text-xl sm:text-2xl lg:text-3xl flex-shrink-0 shadow-sm overflow-hidden"
                style={{ backgroundColor: mask.color }}
              >
                {mask.spriteUrl ? (
                  <img
                    src={mask.spriteUrl}
                    alt={mask.name}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  mask.icon
                )}
              </div>
              <div className="text-xs font-semibold leading-tight text-sand-700">{mask.name}</div>
            </button>
          ))
        )}
      </div>
    </div>
  );
};
