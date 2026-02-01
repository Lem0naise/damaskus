import type { TileType, MaskType, LayerMode } from '../types/level';
import { TILES, MASKS } from '../constants/tiles';

interface SelectedItemTooltipProps {
    layerMode: LayerMode;
    selectedTile: TileType;
    selectedMask: MaskType;
}

export const SelectedItemTooltip = ({
    layerMode,
    selectedTile,
    selectedMask,
}: SelectedItemTooltipProps) => {
    const isLevel = layerMode === 'level';
    const item = isLevel
        ? TILES.find((t) => t.value === selectedTile)
        : MASKS.find((m) => m.value === selectedMask);

    if (!item) return null;

    return (
        <div className="bg-gradient-to-r from-blue-50 to-purple-50 border-2 border-blue-200 rounded-lg p-4 shadow-md">
            <div className="flex items-center gap-3">
                <div
                    className="w-16 h-16 rounded-lg border-2 border-gray-300 flex items-center justify-center text-3xl shadow-sm flex-shrink-0"
                    style={{ backgroundColor: item.color }}
                >
                    {'icon' in item && item.icon}
                </div>
                <div className="flex-1">
                    <h4 className="font-bold text-lg text-gray-800 mb-1">
                        {item.name}
                    </h4>
                    <p className="text-sm text-gray-700 leading-relaxed">
                        {item.description}
                    </p>
                </div>
            </div>
        </div>
    );
};
