const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const fs = require('fs');
const axios = require('axios'); // For Last.fm API
const ytdl = require('@distube/ytdl-core'); // For YouTube Audio Streaming
const ytSearch = require('yt-search'); // For YouTube Audio
require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });

const app = express();
const path = require('path');
app.use(cors());
app.use(express.json());

// Serve static files (music files)
app.use('/music', express.static(path.join(__dirname, 'music')));

// Serve frontend HTML files
app.use(express.static(path.join(__dirname, '..')));

// 🔑 MySQL connection with connection pooling for better performance
const db = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  multipleStatements: true, // Allow multiple statements for stored procedures
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

let dbConnected = false;

// Test the pool connection
db.getConnection((err, connection) => {
  if (err) {
    console.error('❌ MySQL pool connection failed:', err);
    dbConnected = false;
    return;
  }
  dbConnected = true;
  connection.release(); // Important to release back to pool
  console.log('✅ MySQL connected (Pool enabled)');
  console.log('📊 Advanced DBMS features enabled: Views, Stored Procedures, Triggers, Analytics');
});

// Helper function to check database connection
function checkDBConnection(res, callback) {
  if (!dbConnected) {
    return res.status(503).json({ error: 'Database not connected. Please check MySQL server.' });
  }
  callback();
}

// Helper function to normalize audio URLs
function normalizeAudioUrls(songList, req) {
  const baseHost = `${req.protocol}://${req.get('host')}`;
  return songList.map(song => {
    if (song.audio_url && !String(song.audio_url).startsWith('http')) {
      const filename = String(song.audio_url).split(/[\\/]/).pop();
      song.audio_url = `${baseHost}/music/${encodeURIComponent(filename)}`;
    }
    return song;
  });
}

// ============================================
// BASIC CRUD OPERATIONS
// ============================================

// 🎵 API: get songs (optionally filter by mood)
app.get('/songs', (req, res) => {
  const mood = req.query.mood; // e.g., /songs?mood=Chill
  // Use safe default that works with both old and new schema
  const sort = req.query.sort || 'id'; // Default to 'id' for backward compatibility
  const order = req.query.order || 'ASC';

  // Safe sort fields that exist in both schemas
  const safeSortFields = ['id', 'title', 'artist', 'mood'];
  const sortField = safeSortFields.includes(sort) ? sort : 'id';

  let sql = 'SELECT * FROM songs';
  const params = [];

  if (mood) {
    // Use LOWER() on both sides for case-insensitive matching
    // This allows 'happy', 'Happy', or 'HAPPY' to all work correctly
    sql += ' WHERE LOWER(mood) = LOWER(?)';
    params.push(mood);
  }

  sql += ` ORDER BY ${sortField} ${order}`;

  function loadFromJsonFallback() {
    try {
      const jsonPath = path.join(__dirname, '..', 'songs.json');
      const raw = fs.readFileSync(jsonPath, 'utf8');
      const allSongs = JSON.parse(raw);
      // Case-insensitive filter in fallback too
      const filtered = mood ? allSongs.filter(s => (s.mood||'').toLowerCase() === mood.toLowerCase()) : allSongs;
      return res.json(normalizeAudioUrls(filtered, req));
    } catch (e) {
      console.error('❌ songs.json fallback failed:', e);
      return res.status(500).json({ error: 'Failed to load songs (DB and fallback unavailable).' });
    }
  }

  if (!dbConnected) {
    return loadFromJsonFallback();
  }

  db.query(sql, params, (err, results) => {
    if (err) {
      // If error is due to missing column, try with safe sort
      if (err.code === 'ER_BAD_FIELD_ERROR' && sort !== 'id') {
        console.warn(`⚠️ Column '${sort}' not found, using 'id' instead.`);
        const fallbackSql = mood
          ? `SELECT * FROM songs WHERE LOWER(mood) = LOWER(?) ORDER BY id ASC`
          : `SELECT * FROM songs ORDER BY id ASC`;
        const fallbackParams = mood ? [mood] : [];

        return db.query(fallbackSql, fallbackParams, (fallbackErr, fallbackResults) => {
          if (fallbackErr) {
            console.error('❌ DB query failed, falling back to songs.json:', fallbackErr);
            return loadFromJsonFallback();
          }
          return res.json(normalizeAudioUrls(fallbackResults, req));
        });
      }
      console.error('❌ DB query failed, falling back to songs.json:', err);
      return loadFromJsonFallback();
    }

    // Only fallback to songs.json when NO mood filter is set and DB is empty
    // If a mood filter is set and returns 0, that's valid (no songs in that mood)
    if (!mood && (!Array.isArray(results) || results.length === 0)) {
      return loadFromJsonFallback();
    }

    return res.json(normalizeAudioUrls(results, req));
  });
});

// ============================================
// ADVANCED DATABASE FEATURES
// ============================================

// 📊 ANALYTICS ENDPOINTS (Using Database Views)

// Get Mood Analytics (using vw_mood_analytics view)
app.get('/api/analytics/moods', (req, res) => {
  checkDBConnection(res, () => {
    db.query('SELECT mood, total_songs, total_plays FROM vw_mood_analytics ORDER BY total_plays DESC', (err, results) => {
      if (err) {
        console.error('❌ Analytics query failed:', err.message);
        return res.status(500).json({ error: 'Failed to fetch mood analytics', details: err.message });
      }
      res.json(results);
    });
  });
});



// Get User Activity Summary (using vw_user_activity view)
app.get('/api/analytics/users/:userId', (req, res) => {
  const userId = req.params.userId;

  checkDBConnection(res, () => {
    db.query('SELECT * FROM vw_user_activity WHERE id = ?', [userId], (err, results) => {
      if (err) {
        console.error('❌ User activity query failed:', err);
        return res.status(500).json({ error: 'Failed to fetch user activity' });
      }
      if (results.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }
      res.json(results[0]);
    });
  });
});

// ============================================
// STORED PROCEDURES ENDPOINTS
// ============================================

// Record Song Play (using sp_record_play stored procedure)
app.post('/api/play/record', (req, res) => {
  const { userId, songId, playDuration } = req.body;

  if (!songId) {
    return res.status(400).json({ error: 'songId is required' });
  }

  checkDBConnection(res, () => {
    db.query('CALL sp_record_play(?, ?, ?)', [userId || null, songId, playDuration || 0], (err, results) => {
      if (err) {
        console.error('❌ Record play failed:', err);
        return res.status(500).json({ error: 'Failed to record play' });
      }
      res.json({ success: true, message: 'Play recorded successfully' });
    });
  });
});



// Get Recommendations (using sp_get_recommendations stored procedure)
app.get('/api/recommendations/:userId', (req, res) => {
  const userId = req.params.userId;
  const limit = parseInt(req.query.limit) || 5;

  checkDBConnection(res, () => {
    db.query('CALL sp_get_recommendations(?, ?)', [userId, limit], (err, results) => {
      if (err) {
        console.error('❌ Get recommendations failed:', err);
        return res.status(500).json({ error: 'Failed to get recommendations' });
      }
      const songs = Array.isArray(results[0]) ? results[0] : results;
      res.json(normalizeAudioUrls(songs, req));
    });
  });
});


// ============================================
// EXTERNAL APIS (Last.fm)
// ============================================

app.get('/api/lastfm/trackInfo', async (req, res) => {
  const { artist, track } = req.query;
  const apiKey = process.env.LASTFM_API_KEY;

  if (!apiKey || apiKey === 'YOUR_LASTFM_API_KEY_HERE') {
    return res.status(503).json({ error: 'Last.fm API key not configured' });
  }

  if (!artist || !track) {
    return res.status(400).json({ error: 'Artist and track parameters are required' });
  }

  try {
    const url = `http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=${apiKey}&artist=${encodeURIComponent(artist)}&track=${encodeURIComponent(track)}&format=json`;
    const response = await axios.get(url);
    res.json(response.data);
  } catch (error) {
    console.error('Last.fm API error:', error.message);
    res.status(500).json({ error: 'Failed to fetch data from Last.fm' });
  }
});

app.get('/api/lastfm/search', async (req, res) => {
  const { q, limit } = req.query;
  const apiKey = process.env.LASTFM_API_KEY;

  if (!apiKey || apiKey === 'YOUR_LASTFM_API_KEY_HERE') {
    return res.status(503).json({ error: 'Last.fm API key not configured' });
  }

  if (!q) {
    return res.status(400).json({ error: 'Query parameter "q" is required' });
  }

  try {
    const searchLimit = limit || 10;
    const url = `http://ws.audioscrobbler.com/2.0/?method=track.search&track=${encodeURIComponent(q)}&api_key=${apiKey}&limit=${searchLimit}&format=json`;
    const response = await axios.get(url);
    res.json(response.data);
  } catch (error) {
    console.error('Last.fm Search API error:', error.message);
    res.status(500).json({ error: 'Failed to search Last.fm' });
  }
});

app.get('/api/audio/search', async (req, res) => {
  const { q } = req.query;

  if (!q) {
    return res.status(400).json({ error: 'Query parameter "q" is required' });
  }

  try {
    // Search YouTube
    const r = await ytSearch(q);

    if (r && r.videos && r.videos.length > 0) {
      const firstResult = r.videos[0];
      res.json({
        videoId: firstResult.videoId,
        url: firstResult.url,
        title: firstResult.title,
        timestamp: firstResult.timestamp
      });
    } else {
      res.status(404).json({ error: 'No video found' });
    }
  } catch (error) {
    console.error('Audio Search API error:', error);
    res.status(500).json({ error: 'Failed to search audio' });
  }
});

app.get('/api/audio/stream', async (req, res) => {
  const videoId = req.query.videoId;
  if (!videoId) return res.status(400).send('No videoId');

  try {
    const info = await ytdl.getInfo(`https://www.youtube.com/watch?v=${videoId}`);
    // Prioritize webm/opus (usually better for streaming) or mp4/aac
    const format = ytdl.chooseFormat(info.formats, { quality: 'highestaudio', filter: 'audioonly' });

    if (!format) {
      return res.status(404).send('No suitable format');
    }

    // Set CORS headers explicitly
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type');

    // Set appropriate Content-Type if present, or generic
    if (format.mimeType) {
      res.header('Content-Type', format.mimeType.split(';')[0]);
    } else {
      res.header('Content-Type', 'audio/mpeg');
    }

    ytdl.downloadFromInfo(info, { format: format })
      .on('error', (err) => {
        console.error('YTDL Stream Error:', err.message);
        if (!res.headersSent) res.end();
      })
      .pipe(res);

  } catch (err) {
    console.error('Stream Setup Error:', err.message);
    if (!res.headersSent) res.status(500).send(err.message);
  }
});

// ============================================
// COMPLEX QUERIES (JOINs, Aggregations, Subqueries)
// ============================================



// Get User's Favorite Songs (JOIN query)
app.get('/api/favorites/:userId', (req, res) => {
  const userId = req.params.userId;

  checkDBConnection(res, () => {
    db.query(`
      SELECT 
        s.*,
        f.added_at as favorited_at
      FROM favorites f
      JOIN songs s ON f.song_id = s.id
      WHERE f.user_id = ?
      ORDER BY f.added_at DESC
    `, [userId], (err, results) => {
      if (err) {
        console.error('❌ Favorites query failed:', err);
        return res.status(500).json({ error: 'Failed to fetch favorites' });
      }
      res.json(normalizeAudioUrls(results, req));
    });
  });
});

// Add to Favorites
app.post('/api/favorites', (req, res) => {
  const { userId, songId } = req.body;

  if (!userId || !songId) {
    return res.status(400).json({ error: 'userId and songId are required' });
  }

  checkDBConnection(res, () => {
    db.query('INSERT IGNORE INTO favorites (user_id, song_id) VALUES (?, ?)', [userId, songId], (err, results) => {
      if (err) {
        console.error('❌ Add favorite failed:', err);
        return res.status(500).json({ error: 'Failed to add favorite' });
      }
      res.json({ success: true, message: 'Song added to favorites' });
    });
  });
});

// Remove from Favorites
app.delete('/api/favorites/:userId/:songId', (req, res) => {
  const { userId, songId } = req.params;

  checkDBConnection(res, () => {
    db.query('DELETE FROM favorites WHERE user_id = ? AND song_id = ?', [userId, songId], (err, results) => {
      if (err) {
        console.error('❌ Remove favorite failed:', err);
        return res.status(500).json({ error: 'Failed to remove favorite' });
      }
      res.json({ success: true, message: 'Song removed from favorites' });
    });
  });
});





// ============================================
// LIVE STREAMS MANAGEMENT
// ============================================

// Get All Live Streams
app.get('/api/live-streams', (req, res) => {
  const artist = req.query.artist;
  const isLive = req.query.is_live;
  const category = req.query.category;

  if (!dbConnected) {
    console.log('⚠️ Database not connected, returning empty array');
    return res.json([]);
  }

  let sql = 'SELECT * FROM live_streams WHERE 1=1';
  const params = [];

  if (artist) {
    sql += ' AND artist_name LIKE ?';
    params.push(`%${artist}%`);
  }

  if (isLive !== undefined) {
    sql += ' AND is_live = ?';
    params.push(isLive === 'true' || isLive === '1' ? 1 : 0);
  }

  if (category) {
    sql += ' AND category = ?';
    params.push(category);
  }

  sql += ' ORDER BY is_live DESC, artist_name ASC';

  db.query(sql, params, (err, results) => {
    if (err) {
      // If table doesn't exist, return empty array instead of error
      if (err.code === 'ER_NO_SUCH_TABLE') {
        console.log('⚠️ live_streams table does not exist. Please run database.sql');
        return res.json([]);
      }
      console.error('❌ Get live streams failed:', err);
      return res.status(500).json({ error: 'Failed to fetch live streams', details: err.message });
    }

    // Process YouTube video IDs to create embed URLs
    const processedResults = (results || []).map(stream => {
      let videoId = stream.youtube_video_id;

      // Extract video ID from full URL if needed
      if (videoId && (videoId.includes('youtube.com') || videoId.includes('youtu.be'))) {
        // Handle different YouTube URL formats:
        // - https://www.youtube.com/watch?v=VIDEO_ID
        // - https://www.youtube.com/live/VIDEO_ID
        // - https://youtu.be/VIDEO_ID
        // - https://www.youtube.com/embed/VIDEO_ID
        let match = videoId.match(/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?|live)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/);
        if (!match) {
          // Try to extract from /live/ format specifically
          match = videoId.match(/youtube\.com\/live\/([^"&?\/\s]{11})/);
        }
        if (!match) {
          // Try to extract from query parameter
          match = videoId.match(/[?&]v=([^"&?\/\s]{11})/);
        }
        videoId = match ? match[1] : videoId;
      }

      return {
        ...stream,
        embed_url: `https://www.youtube.com/embed/${videoId}?rel=0&modestbranding=1&autoplay=0&controls=1`,
        watch_url: `https://www.youtube.com/watch?v=${videoId}`
      };
    });

    res.json(processedResults);
  });
});

// Get Live Stream by ID
app.get('/api/live-streams/:id', (req, res) => {
  const id = req.params.id;

  checkDBConnection(res, () => {
    db.query('SELECT * FROM live_streams WHERE id = ?', [id], (err, results) => {
      if (err) {
        console.error('❌ Get live stream failed:', err);
        return res.status(500).json({ error: 'Failed to fetch live stream' });
      }

      if (results.length === 0) {
        return res.status(404).json({ error: 'Live stream not found' });
      }

      const stream = results[0];
      let videoId = stream.youtube_video_id;

      // Extract video ID from full URL if needed
      if (videoId && (videoId.includes('youtube.com') || videoId.includes('youtu.be'))) {
        // Handle different YouTube URL formats including /live/
        let match = videoId.match(/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?|live)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/);
        if (!match) {
          match = videoId.match(/youtube\.com\/live\/([^"&?\/\s]{11})/);
        }
        if (!match) {
          match = videoId.match(/[?&]v=([^"&?\/\s]{11})/);
        }
        videoId = match ? match[1] : videoId;
      }

      res.json({
        ...stream,
        embed_url: `https://www.youtube.com/embed/${videoId}?rel=0&modestbranding=1&autoplay=0&controls=1`,
        watch_url: `https://www.youtube.com/watch?v=${videoId}`
      });
    });
  });
});

// Add/Update Live Stream
app.post('/api/live-streams', (req, res) => {
  const { artist_name, stream_title, youtube_video_id, description, is_live, category, thumbnail_url } = req.body;

  if (!artist_name || !stream_title || !youtube_video_id) {
    return res.status(400).json({ error: 'artist_name, stream_title, and youtube_video_id are required' });
  }

  checkDBConnection(res, () => {
    // Extract video ID if full URL provided
    let videoId = youtube_video_id;
    if (videoId && (videoId.includes('youtube.com') || videoId.includes('youtu.be'))) {
      // Handle different YouTube URL formats including /live/
      let match = videoId.match(/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?|live)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/);
      if (!match) {
        match = videoId.match(/youtube\.com\/live\/([^"&?\/\s]{11})/);
      }
      if (!match) {
        match = videoId.match(/[?&]v=([^"&?\/\s]{11})/);
      }
      videoId = match ? match[1] : videoId;
    }

    db.query(
      `INSERT INTO live_streams (artist_name, stream_title, youtube_video_id, description, is_live, category, thumbnail_url)
       VALUES (?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
       stream_title = VALUES(stream_title),
       youtube_video_id = VALUES(youtube_video_id),
       description = VALUES(description),
       is_live = VALUES(is_live),
       category = VALUES(category),
       thumbnail_url = VALUES(thumbnail_url),
       updated_at = CURRENT_TIMESTAMP`,
      [artist_name, stream_title, videoId, description || null, is_live || false, category || 'Concert', thumbnail_url || null],
      (err, results) => {
        if (err) {
          console.error('❌ Add live stream failed:', err);
          return res.status(500).json({ error: 'Failed to add/update live stream' });
        }
        res.json({ success: true, message: 'Live stream added/updated successfully', id: results.insertId });
      }
    );
  });
});

// Update Live Stream (by ID or artist name)
app.put('/api/live-streams/:id', (req, res) => {
  const id = req.params.id;
  const { artist_name, stream_title, youtube_video_id, description, is_live, category, thumbnail_url } = req.body;

  checkDBConnection(res, () => {
    const updates = [];
    const params = [];

    if (artist_name) {
      updates.push('artist_name = ?');
      params.push(artist_name);
    }
    if (stream_title) {
      updates.push('stream_title = ?');
      params.push(stream_title);
    }
    if (youtube_video_id) {
      let videoId = youtube_video_id;
      // Extract video ID if full URL provided
      if (videoId && (videoId.includes('youtube.com') || videoId.includes('youtu.be'))) {
        // Handle different YouTube URL formats including /live/
        let match = videoId.match(/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?|live)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/);
        if (!match) {
          match = videoId.match(/youtube\.com\/live\/([^"&?\/\s]{11})/);
        }
        if (!match) {
          match = videoId.match(/[?&]v=([^"&?\/\s]{11})/);
        }
        videoId = match ? match[1] : videoId;
      }
      updates.push('youtube_video_id = ?');
      params.push(videoId);
    }
    if (description !== undefined) {
      updates.push('description = ?');
      params.push(description);
    }
    if (is_live !== undefined) {
      updates.push('is_live = ?');
      params.push(is_live);
    }
    if (category) {
      updates.push('category = ?');
      params.push(category);
    }
    if (thumbnail_url !== undefined) {
      updates.push('thumbnail_url = ?');
      params.push(thumbnail_url);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');
    params.push(id);

    db.query(
      `UPDATE live_streams SET ${updates.join(', ')} WHERE id = ?`,
      params,
      (err, results) => {
        if (err) {
          console.error('❌ Update live stream failed:', err);
          return res.status(500).json({ error: 'Failed to update live stream' });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ error: 'Live stream not found' });
        }
        res.json({ success: true, message: 'Live stream updated successfully' });
      }
    );
  });
});

// Update Live Stream by Artist Name (convenience endpoint)
app.put('/api/live-streams/artist/:artistName', (req, res) => {
  const artistName = req.params.artistName;
  const { stream_title, youtube_video_id, description, is_live, category } = req.body;

  checkDBConnection(res, () => {
    const updates = [];
    const params = [];

    if (stream_title) {
      updates.push('stream_title = ?');
      params.push(stream_title);
    }
    if (youtube_video_id) {
      let videoId = youtube_video_id;
      if (videoId && (videoId.includes('youtube.com') || videoId.includes('youtu.be'))) {
        // Handle different YouTube URL formats including /live/
        let match = videoId.match(/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?|live)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/);
        if (!match) {
          match = videoId.match(/youtube\.com\/live\/([^"&?\/\s]{11})/);
        }
        if (!match) {
          match = videoId.match(/[?&]v=([^"&?\/\s]{11})/);
        }
        videoId = match ? match[1] : videoId;
      }
      updates.push('youtube_video_id = ?');
      params.push(videoId);
    }
    if (description !== undefined) {
      updates.push('description = ?');
      params.push(description);
    }
    if (is_live !== undefined) {
      updates.push('is_live = ?');
      params.push(is_live);
    }
    if (category) {
      updates.push('category = ?');
      params.push(category);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');
    params.push(artistName);

    db.query(
      `UPDATE live_streams SET ${updates.join(', ')} WHERE artist_name = ?`,
      params,
      (err, results) => {
        if (err) {
          console.error('❌ Update live stream failed:', err);
          return res.status(500).json({ error: 'Failed to update live stream' });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ error: 'Artist not found' });
        }
        res.json({ success: true, message: 'Live stream updated successfully' });
      }
    );
  });
});

// Delete Live Stream
app.delete('/api/live-streams/:id', (req, res) => {
  const id = req.params.id;

  checkDBConnection(res, () => {
    db.query('DELETE FROM live_streams WHERE id = ?', [id], (err, results) => {
      if (err) {
        console.error('❌ Delete live stream failed:', err);
        return res.status(500).json({ error: 'Failed to delete live stream' });
      }
      if (results.affectedRows === 0) {
        return res.status(404).json({ error: 'Live stream not found' });
      }
      res.json({ success: true, message: 'Live stream deleted successfully' });
    });
  });
});

// 🚀 Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running at http://${process.env.HOST || 'localhost'}:${PORT}`);
});
