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
        <div className={`border-2 rounded-xl p-4 shadow-sand ${isLevel
                ? 'bg-gradient-to-r from-terracotta-500/5 to-sand-100 border-terracotta-500/20'
                : 'bg-gradient-to-r from-damascus-500/5 to-sand-100 border-damascus-500/20'
            }`}>
            <div className="flex items-center gap-3">
                <div
                    className="w-16 h-16 rounded-xl border-2 border-sand-400 flex items-center justify-center text-3xl shadow-sm flex-shrink-0 overflow-hidden"
                    style={{ backgroundColor: item.color }}
                >
                    {'icon' in item && item.icon}
                    {'spriteUrl' in item && item.spriteUrl && (
                        <img src={item.spriteUrl} alt={item.name} className="w-full h-full object-cover" />
                    )}
                </div>
                <div className="flex-1">
                    <h4 className="font-bold text-lg text-sand-800 mb-1">
                        {item.name}
                    </h4>
                    <p className="text-sm text-sand-600 leading-relaxed">
                        {item.description}
                    </p>
                </div>
            </div>
        </div>
    );
};
