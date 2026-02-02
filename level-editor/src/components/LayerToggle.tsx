import type { LayerMode } from '../types/level';
import clsx from 'clsx';

interface LayerToggleProps {
  layerMode: LayerMode;
  onToggle: (mode: LayerMode) => void;
}

export const LayerToggle = ({ layerMode, onToggle }: LayerToggleProps) => {
  return (
    <div className="flex gap-1 bg-sand-200 rounded-xl shadow-sand p-1.5 border border-sand-300">
      <button
        className={clsx(
          'px-4 sm:px-5 md:px-7 py-2 md:py-2.5 rounded-lg text-sm md:text-base font-semibold transition-all duration-200',
          layerMode === 'level'
            ? 'bg-terracotta-500 text-white shadow-lg'
            : 'text-sand-600 hover:bg-sand-300/50'
        )}
        onClick={() => onToggle('level')}
      >
        🧱 Level Layer
      </button>
      <button
        className={clsx(
          'px-4 sm:px-5 md:px-7 py-2 md:py-2.5 rounded-lg text-sm md:text-base font-semibold transition-all duration-200',
          layerMode === 'mask'
            ? 'bg-damascus-500 text-white shadow-lg'
            : 'text-sand-600 hover:bg-sand-300/50'
        )}
        onClick={() => onToggle('mask')}
      >
        🎭 Mask Layer
      </button>
    </div>
  );
};
