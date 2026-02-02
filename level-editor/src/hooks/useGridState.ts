import { useState, useEffect } from 'react';
import type { Level, LayerMode, TileType, MaskType } from '../types/level';
import { createEmptyLevel } from '../constants/tiles';

const STORAGE_KEY = 'damaskus-level-editor-state';

interface StoredState {
  levels: Level[];
  currentLevelIndex: number;
}

const loadFromStorage = (): StoredState | null => {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      const parsed = JSON.parse(stored);
      // Validate that it has the expected structure
      if (parsed.levels && Array.isArray(parsed.levels) && parsed.levels.length > 0) {
        return parsed;
      }
    }
  } catch (e) {
    console.warn('Failed to load saved state:', e);
  }
  return null;
};

const saveToStorage = (state: StoredState) => {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch (e) {
    console.warn('Failed to save state:', e);
  }
};

export const useGridState = () => {
  // Initialize from localStorage or create default
  const [levels, setLevels] = useState<Level[]>(() => {
    const stored = loadFromStorage();
    return stored?.levels ?? [createEmptyLevel('Level 1')];
  });

  const [currentLevelIndex, setCurrentLevelIndex] = useState(() => {
    const stored = loadFromStorage();
    return stored?.currentLevelIndex ?? 0;
  });

  const [layerMode, setLayerMode] = useState<LayerMode>('level');
  const [selectedTile, setSelectedTile] = useState<TileType>(1); // Default: Wall
  const [selectedMask, setSelectedMask] = useState<MaskType>(1); // Default: WATER

  // Save to localStorage whenever levels or currentLevelIndex changes
  useEffect(() => {
    saveToStorage({ levels, currentLevelIndex });
  }, [levels, currentLevelIndex]);

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

  const clearCurrentLevel = () => {
    setLevels((prev) => {
      const newLevels = [...prev];
      const currentName = newLevels[currentLevelIndex].name;
      const emptyLevel = createEmptyLevel(currentName);
      // Preserve the ID
      emptyLevel.id = newLevels[currentLevelIndex].id;
      newLevels[currentLevelIndex] = emptyLevel;
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

  const reorderLevels = (startIndex: number, endIndex: number) => {
    setLevels((prev) => {
      const result = Array.from(prev);
      const [removed] = result.splice(startIndex, 1);
      result.splice(endIndex, 0, removed);
      return result;
    });

    // Adjust current level index if the active level was moved
    if (currentLevelIndex === startIndex) {
      setCurrentLevelIndex(endIndex);
    } else if (startIndex < currentLevelIndex && endIndex >= currentLevelIndex) {
      setCurrentLevelIndex(currentLevelIndex - 1);
    } else if (startIndex > currentLevelIndex && endIndex <= currentLevelIndex) {
      setCurrentLevelIndex(currentLevelIndex + 1);
    }
  };

  const renameLevel = (index: number, newName: string) => {
    setLevels((prev) => {
      const newLevels = [...prev];
      newLevels[index] = {
        ...newLevels[index],
        name: newName,
      };
      return newLevels;
    });
  };

  const loadLevels = (newLevels: Level[]) => {
    setLevels(newLevels);
    setCurrentLevelIndex(0);
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
    clearCurrentLevel,
    addLevel,
    removeLevel,
    duplicateLevel,
    reorderLevels,
    renameLevel,
    setCurrentLevelIndex,
    loadLevels,
  };
};
