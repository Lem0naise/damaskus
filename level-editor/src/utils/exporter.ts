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

/**
 * Parse a single GDScript array block.
 * Strategy: Clean comments -> Isolate Array -> Remove trailing commas -> Parse
 */
const parseGDScriptArray = (code: string): number[][][] => {
  // 1. Remove comments (lines starting with # or inline #)
  let cleaned = code.replace(/#[^\n]*/g, '');

  // 2. Find the start and end of the actual array structure
  const firstBracket = cleaned.indexOf('[');
  const lastBracket = cleaned.lastIndexOf(']');

  if (firstBracket === -1 || lastBracket === -1) {
    throw new Error('Invalid GDScript array format: brackets not found');
  }

  // Extract just the array part, ignoring "var x =" or trailing junk
  cleaned = cleaned.substring(firstBracket, lastBracket + 1);

  // 3. Fix Trailing Commas
  // GDScript allows [1, 2, ] but JSON does not.
  // We remove any comma that is followed immediately by a closing bracket (ignoring whitespace).
  // Regex: Match a comma, followed by optional whitespace, followed by ]
  cleaned = cleaned.replace(/,\s*]/g, ']');

  try {
    return JSON.parse(cleaned);
  } catch (error) {
    console.error('Failed to parse. Cleaned JSON snippet:', cleaned.substring(0, 200) + '...');
    throw new Error(`Failed to parse GDScript array: ${error}`);
  }
};

/**
 * Parse complete GDScript code containing both level_layouts and level_masks
 */
export const parseGDScriptLevels = (code: string): Level[] => {
  try {
    // 1. Robust Splitting
    // Instead of regex matching the whole block (which fails on nested brackets),
    // we split the file by the variable declaration of the second array.
    const splitKey = 'var level_masks';
    const parts = code.split(splitKey);

    if (parts.length < 2) {
      throw new Error(`Could not find '${splitKey}' declaration in code.`);
    }

    // Part 0 is level_layouts, Part 1 is level_masks
    const levelLayouts = parseGDScriptArray(parts[0]);
    const levelMasks = parseGDScriptArray(parts[1]);

    if (levelLayouts.length !== levelMasks.length) {
      throw new Error(`Mismatch: ${levelLayouts.length} level layouts but ${levelMasks.length} mask layouts`);
    }

    // Create Level objects
    const levels: Level[] = levelLayouts.map((layout, index) => ({
      id: crypto.randomUUID(),
      name: `Level ${index + 1}`,
      levelLayout: layout as any,
      maskLayout: levelMasks[index] as any,
    }));

    return levels;
  } catch (error) {
    throw new Error(`Failed to parse GDScript: ${error}`);
  }
};