import type { Level } from '../types/level';

export const validateLevel = (level: Level): string[] => {
  const errors: string[] = [];

  // Check grid dimensions
  if (level.levelLayout.length !== 9) {
    errors.push('Level layout must have 9 rows');
  }
  if (level.levelLayout.some(row => row.length !== 15)) {
    errors.push('Level layout must have 15 columns');
  }

  if (level.maskLayout.length !== 9) {
    errors.push('Mask layout must have 9 rows');
  }
  if (level.maskLayout.some(row => row.length !== 15)) {
    errors.push('Mask layout must have 15 columns');
  }

  // Check for player spawn (-1)
  let playerSpawnCount = 0;
  level.maskLayout.forEach(row => {
    row.forEach(cell => {
      if (cell === -1) playerSpawnCount++;
    });
  });

  if (playerSpawnCount === 0) {
    errors.push('Missing player spawn (value -1)');
  } else if (playerSpawnCount > 1) {
    errors.push('Multiple player spawns detected (only one allowed)');
  }

  // Check for goal mask (3)
  let goalCount = 0;
  level.maskLayout.forEach(row => {
    row.forEach(cell => {
      if (cell === 3) goalCount++;
    });
  });

  if (goalCount === 0) {
    errors.push('Missing GOAL mask (value 3)');
  }

  return errors;
};
