-- ============================================
-- MoodWave FULL ER Model Schema
-- Strong + Weak Entities + All ER Concepts
-- ============================================

USE mood;

-- ============================================
-- 1️⃣ SUPER ENTITY (Generalization)
-- ============================================

CREATE TABLE IF NOT EXISTS content (
    content_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 2️⃣ STRONG ENTITIES
-- ============================================

-- USER (Composite attribute: first_name + last_name)
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE NOT NULL,
    date_of_birth DATE,
    favorite_mood VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ARTIST
CREATE TABLE IF NOT EXISTS artists (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(100) NOT NULL,
    country VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- SONG (Specialization of CONTENT)
CREATE TABLE IF NOT EXISTS songs (
    song_id INT PRIMARY KEY,
    duration INT,
    release_year YEAR,
    mood VARCHAR(50),
    play_count INT DEFAULT 0,
    artist_id INT,
    FOREIGN KEY (song_id) REFERENCES content(content_id) ON DELETE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- LIVE_STREAM (Specialization of CONTENT)
CREATE TABLE IF NOT EXISTS live_streams (
    stream_id INT PRIMARY KEY,
    stream_date DATE,
    youtube_link VARCHAR(255),
    is_live BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (stream_id) REFERENCES content(content_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- PLAYLIST
CREATE TABLE IF NOT EXISTS playlists (
    playlist_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 3️⃣ MULTI-VALUED ATTRIBUTE
-- ============================================

-- A song can have multiple genres
CREATE TABLE IF NOT EXISTS song_genres (
    song_id INT,
    genre VARCHAR(50),
    PRIMARY KEY (song_id, genre),
    FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 4️⃣ WEAK ENTITIES (Composite PK)
-- ============================================

-- PLAYLIST_SONG (Weak entity)
CREATE TABLE IF NOT EXISTS playlist_songs (
    playlist_id INT,
    song_id INT,
    position INT,
    PRIMARY KEY (playlist_id, song_id),
    FOREIGN KEY (playlist_id) REFERENCES playlists(playlist_id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- RATING (Weak entity)
CREATE TABLE IF NOT EXISTS ratings (
    user_id INT,
    song_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review TEXT,
    PRIMARY KEY (user_id, song_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- FAVORITES (Weak entity)
CREATE TABLE IF NOT EXISTS favorites (
    user_id INT,
    song_id INT,
    PRIMARY KEY (user_id, song_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(song_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 5️⃣ OPTIONAL DERIVED ATTRIBUTE (Not Stored)
-- ============================================
-- average_rating is derived from ratings table
-- Not stored physically (calculated using AVG)

SELECT '✅ FULL ER MODEL SCHEMA CREATED SUCCESSFULLY' AS status;

