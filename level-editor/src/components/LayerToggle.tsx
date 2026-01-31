import type { LayerMode } from '../types/level';
import clsx from 'clsx';

interface LayerToggleProps {
  layerMode: LayerMode;
  onToggle: (mode: LayerMode) => void;
}

export const LayerToggle = ({ layerMode, onToggle }: LayerToggleProps) => {
  return (
    <div className="flex gap-2 bg-white rounded-lg shadow p-2">
      <button
        className={clsx(
          'px-6 py-2 rounded-lg font-semibold transition-all',
          layerMode === 'level'
            ? 'bg-blue-500 text-white shadow-lg'
            : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
        )}
        onClick={() => onToggle('level')}
      >
        🧱 Level Layer
      </button>
      <button
        className={clsx(
          'px-6 py-2 rounded-lg font-semibold transition-all',
          layerMode === 'mask'
            ? 'bg-purple-500 text-white shadow-lg'
            : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
        )}
        onClick={() => onToggle('mask')}
      >
        🎭 Mask Layer
      </button>
    </div>
  );
};
