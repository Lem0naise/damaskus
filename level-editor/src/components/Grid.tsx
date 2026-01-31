import { useState } from 'react';
import { GridCell } from './GridCell';
import type { Level, LayerMode } from '../types/level';
import { GRID_WIDTH, GRID_HEIGHT } from '../constants/tiles';

interface GridProps {
  level: Level;
  layerMode: LayerMode;
  onCellUpdate: (row: number, col: number) => void;
  onCellClear: (row: number, col: number) => void;
}

export const Grid = ({ level, layerMode, onCellUpdate, onCellClear }: GridProps) => {
  const [isMouseDown, setIsMouseDown] = useState(false);
  const [hoveredCell, setHoveredCell] = useState<{ row: number; col: number } | null>(null);

  return (
    <div className="flex flex-col items-center p-4 bg-gray-100 rounded-lg">
      <div
        className="inline-block border-4 border-gray-800 rounded"
        onMouseDown={() => setIsMouseDown(true)}
        onMouseUp={() => setIsMouseDown(false)}
        onMouseLeave={() => setIsMouseDown(false)}
      >
        {Array.from({ length: GRID_HEIGHT }).map((_, row) => (
          <div key={row} className="flex">
            {Array.from({ length: GRID_WIDTH }).map((_, col) => (
              <GridCell
                key={`${row}-${col}`}
                row={row}
                col={col}
                tileValue={level.levelLayout[row][col]}
                maskValue={level.maskLayout[row][col]}
                layerMode={layerMode}
                onCellClick={onCellUpdate}
                onCellRightClick={onCellClear}
                onCellMouseEnter={(r, c) => setHoveredCell({ row: r, col: c })}
                isMouseDown={isMouseDown}
              />
            ))}
          </div>
        ))}
      </div>

      {/* Hover info */}
      {hoveredCell && (
        <div className="mt-2 text-sm text-gray-600">
          Position: ({hoveredCell.col}, {hoveredCell.row})
        </div>
      )}
    </div>
  );
};
