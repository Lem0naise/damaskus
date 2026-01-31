import { memo } from 'react';
import type { TileType, MaskType } from '../types/level';
import { TILES, MASKS } from '../constants/tiles';
import clsx from 'clsx';

interface GridCellProps {
  row: number;
  col: number;
  tileValue: TileType;
  maskValue: MaskType;
  layerMode: 'level' | 'mask';
  onCellClick: (row: number, col: number) => void;
  onCellRightClick: (row: number, col: number) => void;
  onCellMouseEnter: (row: number, col: number) => void;
  isMouseDown: boolean;
}

export const GridCell = memo(({
  row,
  col,
  tileValue,
  maskValue,
  layerMode,
  onCellClick,
  onCellRightClick,
  onCellMouseEnter,
  isMouseDown,
}: GridCellProps) => {
  const tile = TILES.find((t) => t.value === tileValue)!;
  const mask = MASKS.find((m) => m.value === maskValue)!;

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault();
    if (e.button === 2) {
      onCellRightClick(row, col);
    } else {
      onCellClick(row, col);
    }
  };

  const handleMouseEnter = () => {
    if (isMouseDown) {
      onCellClick(row, col);
    }
    onCellMouseEnter(row, col);
  };

  const handleContextMenu = (e: React.MouseEvent) => {
    e.preventDefault();
  };

  return (
    <div
      className={clsx(
        'relative border border-gray-300 transition-all cursor-crosshair',
        'hover:ring-2 hover:ring-blue-400'
      )}
      style={{
        width: '48px',
        height: '48px',
        backgroundColor: tile.color,
      }}
      onMouseDown={handleMouseDown}
      onMouseEnter={handleMouseEnter}
      onContextMenu={handleContextMenu}
    >
      {/* Mask overlay */}
      {maskValue !== 0 && (
        <div
          className="absolute inset-0 flex items-center justify-center text-2xl font-bold"
          style={{
            backgroundColor: layerMode === 'mask' ? mask.color : `${mask.color}99`, // Add transparency
            color: '#fff',
            textShadow: '1px 1px 2px rgba(0,0,0,0.8)',
          }}
        >
          {mask.icon}
        </div>
      )}

      {/* Coordinate label (on hover) */}
      <div className="absolute top-0 left-0 text-xs text-gray-500 opacity-0 hover:opacity-100 pointer-events-none">
        {col},{row}
      </div>
    </div>
  );
});

GridCell.displayName = 'GridCell';
