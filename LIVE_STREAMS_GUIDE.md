# 🎤 The Creator's Stage: Live Stream Management

Welcome to the **MoodWave Live Stage** management guide. This document is designed for curators and artists who want to bring the magic of live performance to our global audience.

The Live Stage is a dynamic space where live music sessions, concerts, and 24/7 streams come to life. This guide will show you how to orchestrate these events within the MoodWave ecosystem.

---

## 🏛️ The Live Stage Database

At the heart of the Live Stage is the `live_streams` table. Think of this as your digital stage manifest.

| Column | What it Represents |
| :--- | :--- |
| `artist_name` | The star of the show. |
| `stream_title` | The name of the performance (e.g., "Midnight Acoustic Session"). |
| `youtube_video_id` | The unique ID or full URL of the YouTube stream. |
| `description` | A brief story or setlist for the audience. |
| `is_live` | A toggle to signal if the artist is currently performing. |
| `category` | The type of event (Concert, Session, Live, etc.). |

---

## 🎭 Taking the Stage: Adding a New Stream

When a new artist or performance is ready to go live, you can add them using one of the following methods.

### Option 1: Direct Database Entry (SQL)
Perfect for bulk updates or initial setup.

```sql
USE mood;

INSERT INTO live_streams (artist_name, stream_title, youtube_video_id, description, is_live, category)
VALUES (
    'Taylor Swift', 
    'The Eras Tour: Live Experience', 
    'VIDEO_ID_HERE', 
    'Join Taylor for an immersive journey through her musical eras.', 
    TRUE, 
    'Concert'
);
```

### Option 2: Curated API Request
The preferred method for automated systems and dashboards.

```bash
POST http://localhost:3000/api/live-streams
{
  "artist_name": "Justin Bieber",
  "stream_title": "Justice World Tour Live",
  "youtube_video_id": "VIDEO_ID_HERE",
  "is_live": true,
  "category": "Performance"
}
```

---

## 🔄 Managing the Show: Updates

Performances are fluid. Use these commands to keep the stage updated in real-time.

### When an Artist Goes Live
Simply update their status and provide the new Video ID:

```sql
UPDATE live_streams 
SET 
    youtube_video_id = 'NEW_VIDEO_ID',
    is_live = TRUE,
    stream_title = 'Live Now: [Artist Name]',
    updated_at = CURRENT_TIMESTAMP
WHERE artist_name = 'Taylor Swift';
```

### When the Performance Ends
Keep the record, but turn off the "Live" signal:

```sql
UPDATE live_streams SET is_live = FALSE WHERE artist_name = 'Taylor Swift';
```

---

## 🎯 Pro Tips for Curators

1. **YouTube IDs Made Easy**: You don't need to hunt for just the ID. You can paste the full URL (e.g., `https://www.youtube.com/watch?v=dQw4w9WgXcQ`), and MoodWave's engine will extract the ID automatically.
2. **Category Clarity**:
   - `Concert`: Full-scale professional productions.
   - `Session`: Intimate, unplugged, or home performances.
   - `Live`: 24/7 radio stations or ongoing ambient streams.
3. **Automated Badges**: The "LIVE" badge in the UI is tied directly to the `is_live` boolean. Toggle it to capture your audience's attention instantly.

---

## 🗑️ Clearing the Stage
To remove a performance from the archive:

```sql
DELETE FROM live_streams WHERE artist_name = 'Artist Name';
```

---

## 🌐 Curator API Reference

Stay connected with our backend endpoints:
- `GET /api/live-streams`: View the entire lineup.
- `GET /api/live-streams?is_live=true`: See who's on stage right now.
- `PUT /api/live-streams/artist/:name`: Fast-track updates for a specific artist.

---
*Elevate the music. Empower the artists. Welcome to the Wave.* 🎵

