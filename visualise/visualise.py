import sys

# --- CONFIGURATION: COLORS & SYMBOLS ---
class Colors:
    RESET = "\033[0m"
    WALL = "\033[90m"      # Dark Gray
    WATER = "\033[94m"     # Light Blue
    CRUMBLED = "\033[33m"  # Yellow/Brown
    MASK_WATER = "\033[96m" # Cyan
    MASK_DIM = "\033[95m"   # Purple
    MASK_WIN = "\033[93m"   # Gold/Yellow
    MASK_RAM = "\033[91m"   # Red
    BOLD = "\033[1m"

# Symbols (Using 2 chars for a roughly square aspect ratio)
SYMBOLS = {
    'empty': '  ',
    'wall': '██',
    'water': '~~',
    'crumbled': '▒▒',
}

# --- DATA: PASTE YOUR ARRAYS HERE ---
level_layouts = [
		[ # LEVEL 1
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 0, 0, 0, 0, 0, 1, 0, 0, 2, 2, 2, 0, 0, 1],
		[1, 0, 0, 1, 1, 0, 1, 0, 0, 2, 0, 2, 0, 0, 1],
		[1, 0, 0, 1, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 1],
		[1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1],
		[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	],
		[ # LEVEL 2
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 1, 0, 1, 1, 0, 1, 1, 1, 3, 1, 1, 1, 1], # 3 = Crumbled Wall blocking exit
	[1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 3, 0, 0, 3, 1],
	[1, 0, 1, 0, 1, 1, 1, 3, 1, 1, 3, 1, 1, 3, 1], # 3 = Crumbled Wall blocking exit
	[1, 0, 1, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 3, 0, 3, 0, 1, 1, 1, 1, 3, 1, 1, 1, 1], # 3 = Weak walls everywhere
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
],
[ # LEVEL 3
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
	[1, 0, 1, 1, 3, 3, 1, 0, 1, 2, 2, 2, 2, 0, 1], # 3 = Wall blocking Water Mask
	[1, 0, 1, 0, 0, 0, 1, 0, 1, 2, 0, 0, 2, 0, 1], # 2 = The Moat
	[1, 0, 1, 0, 0, 0, 1, 0, 1, 2, 0, 0, 2, 0, 1],
	[1, 0, 1, 1, 1, 1, 1, 0, 1, 2, 2, 2, 2, 0, 1],
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
],
[ # LEVEL 4 - Rock Bridge Puzzle
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 4, 2, 0, 0, 1, 1, 1, 1, 0, 0, 1], # 4 = Rock, 2 = Water river
	[1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1], # Player starts left side
	[1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 0, 0, 0, 4, 2, 0, 0, 1, 1, 1, 1, 0, 0, 1], # 3 rocks to push into water
	[1, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
]
]

level_masks = [
		[ # LEVEL 1
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	],
	[ # LEVEL 2
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0], # 4 = RAM, 3 = WINNER
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
],
[ # LEVEL 3
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0], # 4 = RAM (Easy access)
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0], # 1 = WATER (Trapped), 3 = WINNER (Across moat)
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
],
[ # LEVEL 4 - Rock Bridge Puzzle Masks
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0], # 5 = GOLEM mask, 3 = WINNER mask
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]
]

# --- 2. RENDERER ---
def print_level(idx, layout, mask_grid):
    rows = len(layout)
    cols = len(layout[0])
    
    print(f"\n{Colors.BOLD}=== LEVEL {idx + 1} ==={Colors.RESET}")
    
    for r in range(rows):
        line = ""
        for c in range(cols):
            # Check mask layer first (Overlay)
            mask_val = mask_grid[r][c]
            terrain_val = layout[r][c]
            
            symbol = SYMBOLS['empty']
            color = Colors.RESET
            
            # --- MASK LOGIC ---
            if mask_val > 0:
                if mask_val == 1:   # Water Mask
                    symbol = "WA"
                    color = Colors.MASK_WATER
                elif mask_val == 2: # Dimension Mask
                    symbol = "DM"
                    color = Colors.MASK_DIM
                elif mask_val == 3: # Winner
                    symbol = "★ "
                    color = Colors.MASK_WIN
                elif mask_val == 4: # Ram
                    symbol = "RM"
                    color = Colors.MASK_RAM
                elif mask_val == 5: # GOLEM
                    symbol = "GM"
                    color = Colors.MASK_RAM
            
            # --- TERRAIN LOGIC (If no mask) ---
            else:
                if terrain_val == 1:
                    symbol = SYMBOLS['wall']
                    color = Colors.WALL
                elif terrain_val == 2:
                    symbol = SYMBOLS['water']
                    color = Colors.WATER
                elif terrain_val == 3:
                    symbol = SYMBOLS['crumbled']
                    color = Colors.CRUMBLED
                elif terrain_val == 0:
                    symbol = SYMBOLS['empty']
            
            # Add to line
            line += f"{color}{symbol}{Colors.RESET}"
            
        print(line)

# --- 3. MAIN LOOP ---
for i, (layout, masks) in enumerate(zip(level_layouts, level_masks)):
    print_level(i, layout, masks)