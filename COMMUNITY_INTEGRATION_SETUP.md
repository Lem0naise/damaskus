# Damaskus Community Levels - Setup Guide

This document contains all the configuration needed to complete the community levels integration.

## Phase 1: n8n Backend Setup with Supabase

### Step 1: Set Up Supabase Project (2 minutes)

1. Go to https://supabase.com and sign up/login
2. Click "New Project"
3. Fill in:
   - **Name:** damaskus-community
   - **Database Password:** (save this - you'll need it)
   - **Region:** Choose closest to your users
4. Click "Create new project"
5. Wait for project to initialize (~2 minutes)

### Step 2: Create Database Tables (1 minute)

1. In Supabase dashboard, go to **SQL Editor** (left sidebar)
2. Click "New query"
3. Paste this SQL and click **RUN**:

```sql
-- Community Levels Table
CREATE TABLE community_levels (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  author_name TEXT NOT NULL,
  description TEXT,
  difficulty TEXT,
  tags TEXT,
  level_layout JSONB NOT NULL,
  mask_layout JSONB NOT NULL,
  play_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance (sorted by play count for popularity)
CREATE INDEX idx_play_count ON community_levels(play_count DESC);
CREATE INDEX idx_created ON community_levels(created_at DESC);
```

### Step 3: Get Supabase Connection Details (1 minute)

1. In Supabase dashboard, go to **Project Settings** → **Database**
2. Scroll to **Connection string** section
3. Copy the **Connection pooling** URL (starts with `postgresql://`)
4. Replace `[YOUR-PASSWORD]` with your database password
5. Save this URL - you'll use it in n8n

**Example:**
```
postgresql://postgres.xxxxxxxxxxxx:YOUR_PASSWORD@aws-0-us-east-1.pooler.supabase.com:5432/postgres
```

### Step 4: Configure n8n Supabase Credential (2 minutes)

1. In n8n, go to **Credentials** (top right)
2. Click **Add Credential**
3. Search for and select **Supabase**
4. Fill in:
   - **Host:** Your Supabase project URL (e.g., `xxxxxxxxxxxx.supabase.co`)
   - **Service Role Secret:** Get from Supabase → Project Settings → API → `service_role` key
5. Click **Save**

### n8n Workflow 1: POST /webhook/levels/publish

**Node 1: Webhook Trigger**
- Method: POST
- Path: `/levels/publish`
- Response Mode: When Last Node Finishes

**Node 2: Function - Validate Input**
```javascript
// Validate input
const level = $json.level;
const metadata = $json.metadata;

if (!level || !metadata) {
  throw new Error("Missing level or metadata");
}

// Validate grid dimensions
if (level.levelLayout.length !== 9 || level.levelLayout[0].length !== 15) {
  throw new Error("Invalid level dimensions - must be 15x9");
}

if (level.maskLayout.length !== 9 || level.maskLayout[0].length !== 15) {
  throw new Error("Invalid mask dimensions - must be 15x9");
}

// Check for player spawn
let spawnCount = 0;
level.maskLayout.forEach(row => {
  row.forEach(cell => {
    if (cell === -1) spawnCount++;
  });
});

if (spawnCount !== 1) {
  throw new Error("Must have exactly one player spawn (-1)");
}

// Check for goal
let goalCount = 0;
level.maskLayout.forEach(row => {
  row.forEach(cell => {
    if (cell === 3) goalCount++;
  });
});

if (goalCount === 0) {
  throw new Error("Must have at least one goal mask (3)");
}

// Return validated data
return {
  id: level.id,
  name: level.name,
  author_name: metadata.authorName,
  description: metadata.description || "",
  difficulty: metadata.difficulty || "Medium",
  tags: metadata.tags ? metadata.tags.join(',') : "",
  level_layout: level.levelLayout,
  mask_layout: level.maskLayout
};
```

**Node 3: Supabase - Insert Row**
- **Resource:** Insert
- **Table:** `community_levels`
- **Columns:**
  - id: `={{ $json.id }}`
  - name: `={{ $json.name }}`
  - author_name: `={{ $json.author_name }}`
  - description: `={{ $json.description }}`
  - difficulty: `={{ $json.difficulty }}`
  - tags: `={{ $json.tags }}`
  - level_layout: `={{ JSON.stringify($json.level_layout) }}`
  - mask_layout: `={{ JSON.stringify($json.mask_layout) }}`

**Node 4: Respond to Webhook**
```json
{
  "success": true,
  "levelId": "={{ $('Function').item.json.id }}"
}
```

---

### n8n Workflow 2: GET /webhook/levels

**Node 1: Webhook Trigger**
- Method: GET
- Path: `/levels`

**Node 2: Function - Parse Query Parameters**
```javascript
const sort = $input.params.sort || 'popular';
const limit = parseInt($input.params.limit) || 20;
const offset = parseInt($input.params.offset) || 0;

// Determine sort column
const orderColumn = sort === 'new' ? 'created_at' : 'star_count';

return {
  orderColumn,
  limit: Math.min(limit, 100), // Cap at 100
  offset
};
```

**Node 3: Supabase - Get Rows**
- **Resource:** Get Rows
- **Table:** `community_levels`
- **Select:** `id, name, author_name, difficulty, play_count, tags, created_at`
- **Sort:** `={{ $json.orderColumn }}:desc`
- **Range:**
  - From: `={{ $json.offset }}`
  - To: `={{ $json.offset + $json.limit - 1 }}`

**Node 4: Function - Format Response**
```javascript
const levels = $input.all();

return {
  json: {
    success: true,
    levels: levels.map(item => ({
      id: item.json.id,
      name: item.json.name,
      authorName: item.json.author_name,
      difficulty: item.json.difficulty,
      playCount: item.json.play_count,
      tags: item.json.tags ? item.json.tags.split(',') : [],
      createdAt: item.json.created_at
    }))
  }
};
```

**Node 5: Respond to Webhook**
- Use output from Function node: `={{ $json }}`

---

### n8n Workflow 3: POST /webhook/levels/specificlevel

**Node 1: Webhook Trigger**
- Method: POST
- Path: `/levels/specificlevel`
- Response Mode: When Last Node Finishes

**Node 2: Supabase - Get Rows**
- **Resource:** Get Rows
- **Table:** `community_levels`
- **Select:** `*`
- **Filter:** `id=eq.{{ $json.levelId }}`
- **Limit:** 1

**Node 3: Supabase - Update Row**
- **Resource:** Update
- **Table:** `community_levels`
- **Filter:** `id=eq.{{ $json.levelId }}`
- **Columns:**
  - play_count: `={{ $json.play_count + 1 }}`

**Node 4: Function - Format Level Data**
```javascript
const level = $('Supabase').item.json;

return {
  success: true,
  level: {
    id: level.id,
    name: level.name,
    authorName: level.author_name,
    description: level.description,
    difficulty: level.difficulty,
    levelLayout: typeof level.level_layout === 'string'
      ? JSON.parse(level.level_layout)
      : level.level_layout,
    maskLayout: typeof level.mask_layout === 'string'
      ? JSON.parse(level.mask_layout)
      : level.mask_layout,
    playCount: level.play_count
  }
};
```

**Node 5: Respond to Webhook**
- Use output from Function node: `={{ $json }}`

---

---

## Removed: Star System

The star/favorite system has been removed. Popularity is based solely on **play count**, which automatically increments when someone plays a level (see Workflow 3 above).

**Benefits:**
- Simpler implementation (fewer endpoints)
- No need to track user IDs or starred levels
- Play count is a natural measure of popularity
- Less database complexity

If you want to add stars back later, you can:
1. Add `level_stars` table back
2. Create POST `/webhook/levels/:id/star` endpoint
3. Create GET `/webhook/user-stars` endpoint
4. Update Godot UI to show star buttons

---

## ~~Removed Workflow: POST /webhook/levels/:id/star~~

**This workflow has been removed.** Popularity is now based solely on play count.

---

## ~~Removed Workflow: GET /webhook/user-stars~~

**This workflow has been removed.** No need to track user stars.

---

## Phase 2: Godot Project Configuration

### Add Autoload Singleton

1. Open Godot Project Settings (Project → Project Settings)
2. Go to the "Autoload" tab
3. Add new autoload:
   - **Name:** `CommunityAPI`
   - **Path:** `res://scripts/core/CommunityLevelAPI.gd`
   - **Enable:** ✓
4. Click "Add"
5. Close Project Settings

### Update API URL for Production

Edit `scripts/core/CommunityLevelAPI.gd` line 3:
```gdscript
const API_BASE_URL = "https://your-n8n-instance.com/webhook"
```

---

## Phase 3: React Environment Configuration

### For Development

The `.env` file has been created with:
```
VITE_API_URL=http://localhost:5678/webhook
```

### For Production

Update `.env` before building:
```
VITE_API_URL=https://your-n8n-instance.com/webhook
```

Then build:
```bash
cd level-editor
npm run build
```

---

## Testing Checklist

### Backend Testing (Use Postman or curl)

Replace `YOUR_N8N_URL` with your actual n8n webhook URL.

1. **Publish Level**
```bash
curl -X POST automation.112000000.xyz/webhook/levels/publish \
  -H "Content-Type: application/json" \
  -H "Authorization: 9JnwJyoeqJ6E8bRf" \
  -d '{
    "level": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Test Level",
      "levelLayout": [
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
      ],
      "maskLayout": [
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,3,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      ]
    },
    "metadata": {
      "authorName": "Tester",
      "description": "Test level",
      "difficulty": "Easy",
      "tags": ["test"]
    }
  }'
```

Expected response:
```json
{"success": true, "levelId": "550e8400-e29b-41d4-a716-446655440000"}
```

2. **Fetch Levels**
```bash
curl -X GET "https://automation.112000000.xyz/webhook/levels?sort=popular&limit=10" \
-H "Authorization: 9JnwJyoeqJ6E8bRf"
```

Expected response:
```json
{
  "success": true,
  "levels": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Test Level",
      "authorName": "Tester",
      "difficulty": "Easy",
      "playCount": 0,
      "tags": ["test"],
      "createdAt": "2026-01-30T12:34:56Z"
    }
  ]
}
```

3. **Fetch Single Level**
```bash
curl -X POST "https://automation.112000000.xyz/webhook/levels/specificlevel" \
  -H "Content-Type: application/json" \
  -H "Authorization: 9JnwJyoeqJ6E8bRf" \
  -d '{"levelId": "550e8400-e29b-41d4-a716-446655440000"}'
```

Expected response includes full level data with incremented play count:
```json
{
  "success": true,
  "level": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Test Level",
    "authorName": "Tester",
    "description": "Test level",
    "difficulty": "Easy",
    "levelLayout": [[1,1,1,...], ...],
    "maskLayout": [[0,-1,0,...], ...],
    "playCount": 1
  }
}
```

### React Testing

1. Start dev server:
```bash
cd level-editor
npm run dev
```

2. Create a valid level (with player spawn and goal)
3. Fill in publish form
4. Click "Publish Level"
5. Check browser console for success
6. Verify in n8n database

### Godot Testing

1. Open Godot project
2. Run the project (F5)
3. Click "Community Levels" button
4. Should see browser scene load
5. Should fetch levels from API
6. Click "Play" on a level
7. Verify level loads correctly
8. Test star functionality

---

## Deployment Checklist

### Supabase Setup
- [ ] Create Supabase project
- [ ] Run database migration (create tables)
- [ ] Get project URL and service role key
- [ ] Enable Row Level Security (RLS) policies if needed
- [ ] Test direct database access

### n8n Production
- [ ] Deploy n8n instance (n8n Cloud recommended)
- [ ] Add Supabase credentials in n8n
- [ ] Create all 5 workflows
- [ ] Test all endpoints with curl/Postman
- [ ] Note down webhook URL
- [ ] Configure CORS if needed

### React Production
- [ ] Update `.env` with production API URL
- [ ] Run `npm run build`
- [ ] Deploy `dist/` folder to hosting (Netlify, Vercel, etc.)
- [ ] Test publishing from live site

### Godot Production
- [ ] Update `CommunityLevelAPI.gd` with production URL
- [ ] Export game for target platforms
- [ ] Test community browser in exported builds
- [ ] Verify API calls work from game

---

## CORS Configuration (Important!)

If React and n8n are on different domains, add CORS headers in n8n:

In each "Respond to Webhook" node, add headers:
```json
{
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type"
}
```

Or configure CORS in your n8n instance settings.

---

## Troubleshooting

### "Failed to connect to server" in Godot
- Check API_BASE_URL in CommunityLevelAPI.gd
- Verify n8n is running and accessible
- Test webhook URL directly in browser
- Check firewall settings

### "CORS error" in React
- In n8n, add CORS headers to each "Respond to Webhook" node
- Headers tab: Add `Access-Control-Allow-Origin: *`
- Or configure CORS in n8n settings

### "Validation failed" when publishing
- Ensure level has exactly one player spawn (-1) in mask layer
- Ensure level has at least one goal mask (3) in mask layer
- Check grid dimensions are exactly 15x9
- Use validator before publishing

### Levels not appearing in browser
- Check Supabase database has data (use Supabase Table Editor)
- Verify fetch_levels endpoint returns JSON
- Check browser console for errors
- Test endpoint directly with curl

### "Supabase connection error" in n8n
- Verify credentials (Host and Service Role Secret)
- Check Supabase project is active
- Test connection in Supabase node
- Ensure database tables exist

### Star count not updating
- If using RPC method: Ensure toggle_star function exists
- Check Supabase execution logs
- Verify level_stars table has correct foreign key
- Test star/unstar with curl first

---

## Future Enhancements

After basic integration is working, consider:

1. **Search/Filter:**
   - Add search by level name
   - Filter by difficulty or tags

2. **Moderation:**
   - Add level reporting system
   - Admin panel to review/delete levels

3. **Leaderboards:**
   - Most-starred creators
   - Most-played levels

4. **Offline Support:**
   - Cache levels in Godot for offline play
   - Sync stars when back online

5. **Level Updates:**
   - Allow creators to update published levels
   - Version tracking

6. **Comments/Ratings:**
   - Add comment system
   - 5-star rating system

---

## Files Modified/Created

### React (level-editor/)
- ✅ Created: `src/utils/validator.ts`
- ✅ Created: `src/utils/api.ts`
- ✅ Created: `src/components/PublishPanel.tsx`
- ✅ Modified: `src/App.tsx`
- ✅ Created: `.env`

### Godot
- ✅ Created: `scripts/core/CommunityLevelAPI.gd`
- ✅ Created: `scripts/ui/level_card.gd`
- ✅ Created: `scripts/ui/community_levels_browser.gd`
- ✅ Created: `scenes/ui/level_card.tscn`
- ✅ Created: `scenes/ui/community_levels_browser.tscn`
- ✅ Modified: `scripts/core/LevelGenerator.gd`
- ✅ Modified: `scripts/mainnmenu.gd`
- ✅ Modified: `main_menu.tscn`

### n8n
- ⏳ To create: 5 webhook workflows (see above)
- ⏳ To create: SQLite database with 2 tables

---

## Support

If you encounter issues:

1. Check n8n workflow execution logs
2. Check Godot console output
3. Check browser developer console
4. Verify API endpoints with curl/Postman first
5. Test each component independently before integrating

Good luck with your community levels integration! 🎮
