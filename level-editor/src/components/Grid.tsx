import { useState, useMemo } from 'react';
import { GridCell } from './GridCell';
import type { Level, LayerMode, TileType } from '../types/level';
import { GRID_WIDTH, GRID_HEIGHT, CELL_SIZE } from '../constants/tiles';

interface GridProps {
  level: Level;
  layerMode: LayerMode;
  onCellUpdate: (row: number, col: number) => void;
  onCellClear: (row: number, col: number) => void;
}

// Tiles that permanently block lasers: Wall only
const HARD_BLOCKING_TILES: TileType[] = [1];

// Column tiles (can be toggled with GOLEM mask, so "potential" laser)
const COLUMN_TILES: TileType[] = [5, 6];

// Crumbled wall (can be destroyed with RAM mask, so "potential" laser)
const CRUMBLED_WALL_TILE: TileType = 3;

// Log (can be pushed with RAM mask, so "potential" laser)
const LOG_TILE: TileType = 4;

interface LaserLine {
  from: { row: number; col: number };
  to: { row: number; col: number };
  direction: 'horizontal' | 'vertical';
  type: 'solid' | 'potential'; // solid = clear path, potential = only columns in the way
}

// Find all laser emitters and calculate lines of sight
const calculateLaserLines = (levelLayout: TileType[][]): LaserLine[] => {
  const emitters: { row: number; col: number }[] = [];

  // Find all laser emitters (tile value 8)
  for (let row = 0; row < GRID_HEIGHT; row++) {
    for (let col = 0; col < GRID_WIDTH; col++) {
      if (levelLayout[row][col] === 8) {
        emitters.push({ row, col });
      }
    }
  }

  const lines: LaserLine[] = [];
  const usedPairs = new Set<string>();

  // Check each emitter for line of sight to other emitters
  for (const emitter of emitters) {
    // Check horizontal (same row)
    const sameRowEmitters = emitters.filter(e => e.row === emitter.row && e.col !== emitter.col);
    for (const other of sameRowEmitters) {
      const pairKey = `${Math.min(emitter.col, other.col)},${emitter.row}-${Math.max(emitter.col, other.col)},${other.row}`;
      if (usedPairs.has(pairKey)) continue;

      // Check what's in the path
      const minCol = Math.min(emitter.col, other.col);
      const maxCol = Math.max(emitter.col, other.col);
      let hardBlocked = false;
      let hasSoftBlocker = false;
      let columnType: TileType | null = null;

      for (let col = minCol + 1; col < maxCol; col++) {
        const tile = levelLayout[emitter.row][col];
        if (HARD_BLOCKING_TILES.includes(tile)) {
          hardBlocked = true;
          break;
        }
        if (tile === CRUMBLED_WALL_TILE || tile === LOG_TILE) {
          hasSoftBlocker = true;
        }
        if (COLUMN_TILES.includes(tile)) {
          if (columnType === null) {
            columnType = tile;
            hasSoftBlocker = true;
          } else if (columnType !== tile) {
            // Mixed column types = fully blocked (one will always be up)
            hardBlocked = true;
            break;
          }
        }
      }

      if (!hardBlocked) {
        lines.push({
          from: emitter.col < other.col ? emitter : other,
          to: emitter.col < other.col ? other : emitter,
          direction: 'horizontal',
          type: hasSoftBlocker ? 'potential' : 'solid'
        });
        usedPairs.add(pairKey);
      }
    }

    // Check vertical (same column)
    const sameColEmitters = emitters.filter(e => e.col === emitter.col && e.row !== emitter.row);
    for (const other of sameColEmitters) {
      const pairKey = `${emitter.col},${Math.min(emitter.row, other.row)}-${other.col},${Math.max(emitter.row, other.row)}`;
      if (usedPairs.has(pairKey)) continue;

      // Check what's in the path
      const minRow = Math.min(emitter.row, other.row);
      const maxRow = Math.max(emitter.row, other.row);
      let hardBlocked = false;
      let hasSoftBlocker = false;
      let columnType: TileType | null = null;

      for (let row = minRow + 1; row < maxRow; row++) {
        const tile = levelLayout[row][emitter.col];
        if (HARD_BLOCKING_TILES.includes(tile)) {
          hardBlocked = true;
          break;
        }
        if (tile === CRUMBLED_WALL_TILE || tile === LOG_TILE) {
          hasSoftBlocker = true;
        }
        if (COLUMN_TILES.includes(tile)) {
          if (columnType === null) {
            columnType = tile;
            hasSoftBlocker = true;
          } else if (columnType !== tile) {
            // Mixed column types = fully blocked
            hardBlocked = true;
            break;
          }
        }
      }

      if (!hardBlocked) {
        lines.push({
          from: emitter.row < other.row ? emitter : other,
          to: emitter.row < other.row ? other : emitter,
          direction: 'vertical',
          type: hasSoftBlocker ? 'potential' : 'solid'
        });
        usedPairs.add(pairKey);
      }
    }
  }

  return lines;
};

export const Grid = ({ level, layerMode, onCellUpdate, onCellClear }: GridProps) => {
  const [isMouseDown, setIsMouseDown] = useState(false);
  const [hoveredCell, setHoveredCell] = useState<{ row: number; col: number } | null>(null);

  // Calculate laser lines whenever level changes
  const laserLines = useMemo(() => calculateLaserLines(level.levelLayout), [level.levelLayout]);

  return (
    <div className="flex flex-col items-center p-3 md:p-5 bg-sand-100 rounded-2xl overflow-x-auto border border-sand-200 shadow-sand">
      <div
        className="inline-block border-4 border-sand-700 rounded-lg overflow-hidden shadow-lg relative"
        onMouseDown={() => setIsMouseDown(true)}
        onMouseUp={() => setIsMouseDown(false)}
        onMouseLeave={() => setIsMouseDown(false)}
      >
        {/* Grid cells */}
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

        {/* Laser lines overlay */}
        <svg
          className="absolute inset-0 pointer-events-none"
          style={{ width: GRID_WIDTH * CELL_SIZE, height: GRID_HEIGHT * CELL_SIZE }}
        >
          <defs>
            <filter id="glow">
              <feGaussianBlur stdDeviation="2" result="coloredBlur" />
              <feMerge>
                <feMergeNode in="coloredBlur" />
                <feMergeNode in="SourceGraphic" />
              </feMerge>
            </filter>
            <filter id="glow-soft">
              <feGaussianBlur stdDeviation="1" result="coloredBlur" />
              <feMerge>
                <feMergeNode in="coloredBlur" />
                <feMergeNode in="SourceGraphic" />
              </feMerge>
            </filter>
          </defs>
          {laserLines.map((line, index) => {
            // Calculate pixel positions (center of cells)
            const x1 = line.from.col * CELL_SIZE + CELL_SIZE / 2;
            const y1 = line.from.row * CELL_SIZE + CELL_SIZE / 2;
            const x2 = line.to.col * CELL_SIZE + CELL_SIZE / 2;
            const y2 = line.to.row * CELL_SIZE + CELL_SIZE / 2;

            if (line.type === 'potential') {
              // Dashed line for potential lasers (columns can be toggled)
              return (
                <g key={index}>
                  {/* Outer dashed glow */}
                  <line
                    x1={x1}
                    y1={y1}
                    x2={x2}
                    y2={y2}
                    stroke="rgba(255, 100, 100, 0.2)"
                    strokeWidth="6"
                    strokeLinecap="round"
                    strokeDasharray="8 12"
                  />
                  {/* Main dashed laser line */}
                  <line
                    x1={x1}
                    y1={y1}
                    x2={x2}
                    y2={y2}
                    stroke="#ff6666"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeDasharray="8 12"
                    filter="url(#glow-soft)"
                  />
                </g>
              );
            }

            // Solid line for active lasers
            return (
              <g key={index}>
                {/* Outer glow */}
                <line
                  x1={x1}
                  y1={y1}
                  x2={x2}
                  y2={y2}
                  stroke="rgba(255, 0, 0, 0.3)"
                  strokeWidth="8"
                  strokeLinecap="round"
                />
                {/* Main laser line */}
                <line
                  x1={x1}
                  y1={y1}
                  x2={x2}
                  y2={y2}
                  stroke="#ff0000"
                  strokeWidth="3"
                  strokeLinecap="round"
                  filter="url(#glow)"
                />
                {/* Bright core */}
                <line
                  x1={x1}
                  y1={y1}
                  x2={x2}
                  y2={y2}
                  stroke="#ff6666"
                  strokeWidth="1"
                  strokeLinecap="round"
                />
              </g>
            );
          })}
        </svg>
      </div>

      {/* Hover info */}
      {hoveredCell && (
        <div className="mt-3 text-sm text-sand-600 font-medium">
          Position: ({hoveredCell.col}, {hoveredCell.row})
        </div>
      )}
    </div>
  );
};
