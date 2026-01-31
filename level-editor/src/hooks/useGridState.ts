import { useState } from 'react';
import type { Level, LayerMode, TileType, MaskType } from '../types/level';
import { createEmptyLevel } from '../constants/tiles';

export const useGridState = () => {
  const [levels, setLevels] = useState<Level[]>([createEmptyLevel('Level 1')]);
  const [currentLevelIndex, setCurrentLevelIndex] = useState(0);
  const [layerMode, setLayerMode] = useState<LayerMode>('level');
  const [selectedTile, setSelectedTile] = useState<TileType>(1); // Default: Wall
  const [selectedMask, setSelectedMask] = useState<MaskType>(1); // Default: WATER

  const currentLevel = levels[currentLevelIndex];

  const updateCell = (row: number, col: number) => {
    setLevels((prev) => {
      const newLevels = [...prev];
      const level = { ...newLevels[currentLevelIndex] };

      if (layerMode === 'level') {
        const newLayout = level.levelLayout.map((r) => [...r]);
        newLayout[row][col] = selectedTile;
        level.levelLayout = newLayout;
      } else {
        const newLayout = level.maskLayout.map((r) => [...r]);
        newLayout[row][col] = selectedMask;
        level.maskLayout = newLayout;
      }

      newLevels[currentLevelIndex] = level;
      return newLevels;
    });
  };

  const clearCell = (row: number, col: number) => {
    setLevels((prev) => {
      const newLevels = [...prev];
      const level = { ...newLevels[currentLevelIndex] };

      if (layerMode === 'level') {
        const newLayout = level.levelLayout.map((r) => [...r]);
        newLayout[row][col] = 0;
        level.levelLayout = newLayout;
      } else {
        const newLayout = level.maskLayout.map((r) => [...r]);
        newLayout[row][col] = 0;
        level.maskLayout = newLayout;
      }

      newLevels[currentLevelIndex] = level;
      return newLevels;
    });
  };

  const addLevel = () => {
    const newLevel = createEmptyLevel(`Level ${levels.length + 1}`);
    setLevels([...levels, newLevel]);
    setCurrentLevelIndex(levels.length);
  };

  const removeLevel = (index: number) => {
    if (levels.length === 1) return; // Keep at least one level
    const newLevels = levels.filter((_, i) => i !== index);
    setLevels(newLevels);
    if (currentLevelIndex >= newLevels.length) {
      setCurrentLevelIndex(newLevels.length - 1);
    }
  };

  const duplicateLevel = (index: number) => {
    const levelToDuplicate = levels[index];
    const newLevel: Level = {
      id: crypto.randomUUID(),
      name: `${levelToDuplicate.name} (Copy)`,
      levelLayout: levelToDuplicate.levelLayout.map((row) => [...row]),
      maskLayout: levelToDuplicate.maskLayout.map((row) => [...row]),
    };
    setLevels([...levels, newLevel]);
  };

  return {
    levels,
    currentLevel,
    currentLevelIndex,
    layerMode,
    selectedTile,
    selectedMask,
    setLayerMode,
    setSelectedTile,
    setSelectedMask,
    updateCell,
    clearCell,
    addLevel,
    removeLevel,
    duplicateLevel,
    setCurrentLevelIndex,
  };
};
