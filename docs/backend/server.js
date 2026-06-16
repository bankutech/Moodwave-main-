const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const fs = require('fs');
require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });

const app = express();
const path = require('path');
app.use(cors());
app.use(express.json());

// Serve static files (music files)
app.use('/music', express.static(path.join(__dirname, 'music')));

// Serve frontend HTML files
app.use(express.static(path.join(__dirname, '..')));

// 🔑 MySQL connection
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

let dbConnected = false;

// Connect to MySQL
db.connect(err => {
  if (err) {
    console.error('❌ MySQL connection failed:', err);
    dbConnected = false;
    return;
  }
  dbConnected = true;
  console.log('✅ MySQL connected');
});

// 🎵 API: get songs (optionally filter by mood)
app.get('/songs', (req, res) => {
  const mood = req.query.mood; // e.g., /songs?mood=Chill
  let sql = 'SELECT * FROM songs';
  const params = [];

  if (mood) {
    sql += ' WHERE mood = ?';
    params.push(mood);
  }

  const baseHost = `${req.protocol}://${req.get('host')}`;

  function normalizeAudioUrls(songList) {
    return songList.map(song => {
      if (song.audio_url && !String(song.audio_url).startsWith('http')) {
        const filename = String(song.audio_url).split(/[\\/]/).pop();
        song.audio_url = `${baseHost}/music/${encodeURIComponent(filename)}`;
      }
      return song;
    });
  }

  function loadFromJsonFallback() {
    try {
      const jsonPath = path.join(__dirname, '..', 'songs.json');
      const raw = fs.readFileSync(jsonPath, 'utf8');
      const allSongs = JSON.parse(raw);
      const filtered = mood ? allSongs.filter(s => s.mood === mood) : allSongs;
      return res.json(normalizeAudioUrls(filtered));
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
      console.error('❌ DB query failed, falling back to songs.json:', err);
      return loadFromJsonFallback();
    }

    if (!Array.isArray(results) || results.length === 0) {
      return loadFromJsonFallback();
    }

    return res.json(normalizeAudioUrls(results));
  });
});

// 🚀 Start server
app.listen(3000, () => {
  console.log('🚀 Server running at http://localhost:3000');
});
