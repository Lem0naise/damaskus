import type { Level } from '../types/level';

export const exportToGDScript = (levels: Level[]): string => {
  const levelLayoutsStr = formatArray(levels.map((l) => l.levelLayout), 'level_layouts');
  const maskLayoutsStr = formatArray(levels.map((l) => l.maskLayout), 'level_masks');

  return `${levelLayoutsStr}\n\n${maskLayoutsStr}`;
};

const formatArray = (data: number[][][], varName: string): string => {
  let result = `var ${varName} = [\n`;

  data.forEach((level, levelIdx) => {
    result += `\t\t[ # LEVEL ${levelIdx + 1}\n`;
    level.forEach((row) => {
      const rowStr = '\t' + JSON.stringify(row).replace(/,/g, ', ');
      result += rowStr + ',\n';
    });
    result += `],\n`;
  });

  result += ']';
  return result;
};

export const exportToJSON = (levels: Level[]): string => {
  return JSON.stringify(levels, null, 2);
};

export const parseGDScriptArray = (code: string): number[][] => {
  // Extract array content between [ and ]
  const arrayMatch = code.match(/\[[\s\S]*\]/);
  if (!arrayMatch) throw new Error('Invalid GDScript array format');

  // Remove comments and clean up
  const cleaned = arrayMatch[0]
    .replace(/#[^\n]*/g, '') // Remove comments
    .replace(/\s+/g, ' ') // Collapse whitespace
    .trim();

  // Parse as JSON
  return JSON.parse(cleaned);
};
