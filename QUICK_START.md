# Community Levels - Quick Start Guide

## What's Been Implemented

The Damaskus game now has a complete community levels system! Here's what's ready:

### ✅ React Editor (Phases 2-3)
- **PublishPanel component** - Beautiful UI to publish levels
- **Validation system** - Checks for player spawn and goal mask
- **API integration** - Calls n8n backend to save levels
- Added to main App.tsx next to Export Panel

### ✅ Godot Game (Phases 4-6)
- **CommunityLevelAPI singleton** - Handles all HTTP requests
- **Refactored LevelGenerator** - Now supports both campaign and community levels
- **Community Browser UI** - Scene with level cards, sorting, and loading states
- **Level Card component** - Shows level info with star button
- **Main Menu integration** - Added "Community Levels" button

### ⏳ n8n Backend (Phase 1)
- **Database schema** ready (see COMMUNITY_INTEGRATION_SETUP.md)
- **5 workflow configs** provided (publish, list, get, star, user-stars)
- **You need to set this up!**

---

## Next Steps (10 Minutes to Get Running)

### 1. Set Up Supabase (3 min)

1. Go to https://supabase.com and create free account
2. Click "New Project"
3. Fill in project details and create
4. Wait ~2 minutes for project to initialize
5. Go to **SQL Editor** → **New query**
6. Paste and run the SQL from COMMUNITY_INTEGRATION_SETUP.md (creates 2 tables)
7. Go to **Project Settings** → **API** → Copy your project URL and service role key

### 2. Set Up n8n (5 min)

**Option A: n8n Cloud (Recommended)**
1. Go to https://n8n.io and create free account
2. Create new workflow
3. Add Supabase credential (use URL and service role key from Supabase)
4. Copy workflow configs from COMMUNITY_INTEGRATION_SETUP.md
5. Note your webhook URL (e.g., `https://yourname.app.n8n.cloud/webhook`)

**Option B: Local n8n (For Testing)**
```bash
npx n8n
# Opens at http://localhost:5678
```
Then add Supabase credentials and create workflows

### 3. Configure Godot (1 min)

1. Open Godot project
2. Go to Project → Project Settings → Autoload
3. Add autoload:
   - Name: `CommunityAPI`
   - Path: `res://scripts/core/CommunityLevelAPI.gd`
   - Enable: ✓
4. Save and close

### 4. Update API URLs (1 min)

**In Godot** (`scripts/core/CommunityLevelAPI.gd` line 3):
```gdscript
const API_BASE_URL = "http://localhost:5678/webhook"
# Or your n8n cloud URL
```

**In React** (`.env` file):
```
VITE_API_URL=http://localhost:5678/webhook
# Or your n8n cloud URL
```

### 5. Test It! (1 min)

**React:**
```bash
cd level-editor
npm run dev
```
1. Create a level with player spawn (-1) and goal (3)
2. Fill in publish form
3. Click "Publish Level"
4. Should see success toast!

**Godot:**
1. Run project (F5)
2. Click "Community Levels"
3. Should see browser load
4. Should show your published level!

---

## Common Issues

### "Failed to connect to server"
- Make sure n8n is running and accessible
- Check API_BASE_URL matches your n8n URL
- Try testing webhook URL in browser first
- For local: http://localhost:5678/webhook

### "Validation failed: Missing player spawn"
- Make sure you have exactly ONE cell with value -1 in mask layer
- Make sure you have at least ONE cell with value 3 in mask layer

### "CORS error" in browser
- Add CORS headers in n8n webhook responses:
```json
{
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type"
}
```

---

## The Magic Workflow

Here's how it all works:

```
1. Creator designs level in React editor
          ↓
2. Clicks "Publish" → React validates level
          ↓
3. React sends POST to n8n API
          ↓
4. n8n validates & saves to Supabase (PostgreSQL)
          ↓
5. Player opens Godot game
          ↓
6. Clicks "Community Levels" button
          ↓
7. Godot fetches levels from n8n API
          ↓
8. Player clicks "Play" on a level
          ↓
9. Godot fetches full level data
          ↓
10. LevelGenerator loads community level
          ↓
11. Player enjoys custom level!
          ↓
12. Player clicks star ⭐
          ↓
13. n8n updates star count
```

---

## What You Can Do Now

### As a Level Creator:
1. Open React editor
2. Design your level
3. Click "Publish to Community"
4. Fill in name, description, difficulty
5. Hit publish!
6. Your level is now live!

### As a Player:
1. Open Godot game
2. Click "Community Levels"
3. Browse published levels
4. Click "Play" to try one
5. Click ⭐ to favorite levels
6. Complete the level!

---

## File Structure Overview

```
damaskus/
├── level-editor/           # React level editor
│   ├── src/
│   │   ├── components/
│   │   │   └── PublishPanel.tsx    ← New publish UI
│   │   ├── utils/
│   │   │   ├── api.ts              ← New API calls
│   │   │   └── validator.ts        ← New validation
│   │   └── App.tsx                 ← Updated
│   └── .env                        ← New config
│
├── scripts/
│   ├── core/
│   │   ├── CommunityLevelAPI.gd    ← New API singleton
│   │   └── LevelGenerator.gd       ← Refactored
│   ├── ui/
│   │   ├── level_card.gd           ← New card component
│   │   └── community_levels_browser.gd  ← New browser
│   └── mainnmenu.gd                ← Updated
│
├── scenes/
│   └── ui/
│       ├── level_card.tscn         ← New scene
│       └── community_levels_browser.tscn  ← New scene
│
└── main_menu.tscn                  ← Updated (new button)
```

---

## Next Features to Add

Once basic system is working, you can enhance:

1. **Search & Filter** - Search levels by name, filter by difficulty
2. **Level Screenshots** - Capture thumbnail when publishing
3. **Comments** - Let players leave feedback
4. **Ratings** - 5-star rating system
5. **Daily Challenges** - Featured level each day
6. **Level Editor In-Game** - Build levels directly in Godot
7. **Multiplayer** - Co-op community levels

---

## Need Help?

1. Check COMMUNITY_INTEGRATION_SETUP.md for detailed configs
2. Test API endpoints with curl/Postman first
3. Check n8n execution logs for errors
4. Check Godot console output
5. Check browser developer console

Happy level creating! 🎮✨
