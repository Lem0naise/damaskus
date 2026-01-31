import type { Level } from '../types/level';
import { Plus, Trash2, Copy } from 'lucide-react';
import clsx from 'clsx';

interface LevelSelectorProps {
  levels: Level[];
  currentIndex: number;
  onSelect: (index: number) => void;
  onAdd: () => void;
  onRemove: (index: number) => void;
  onDuplicate: (index: number) => void;
}

export const LevelSelector = ({
  levels,
  currentIndex,
  onSelect,
  onAdd,
  onRemove,
  onDuplicate,
}: LevelSelectorProps) => {
  return (
    <div className="bg-white rounded-lg shadow-lg p-4">
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-xl font-bold">Levels</h2>
        <button
          onClick={onAdd}
          className="flex items-center gap-2 px-3 py-1 bg-green-500 text-white rounded hover:bg-green-600 transition"
        >
          <Plus size={16} />
          Add Level
        </button>
      </div>

      <div className="flex flex-wrap gap-2">
        {levels.map((level, index) => (
          <div
            key={level.id}
            className={clsx(
              'relative p-3 rounded-lg border-2 transition-all cursor-pointer group',
              currentIndex === index
                ? 'border-blue-500 bg-blue-50'
                : 'border-gray-200 hover:border-gray-400'
            )}
            onClick={() => onSelect(index)}
          >
            <div className="font-semibold">{level.name}</div>
            <div className="text-xs text-gray-500">Level {index + 1}</div>

            {/* Action buttons (show on hover) */}
            <div className="absolute top-1 right-1 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  onDuplicate(index);
                }}
                className="p-1 bg-blue-500 text-white rounded hover:bg-blue-600"
                title="Duplicate"
              >
                <Copy size={12} />
              </button>
              {levels.length > 1 && (
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    onRemove(index);
                  }}
                  className="p-1 bg-red-500 text-white rounded hover:bg-red-600"
                  title="Delete"
                >
                  <Trash2 size={12} />
                </button>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
