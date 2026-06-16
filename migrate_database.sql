USE mood;
ALTER TABLE songs
ADD COLUMN duration INT DEFAULT 0;
ALTER TABLE songs
ADD COLUMN genre VARCHAR(50);
ALTER TABLE songs
ADD COLUMN release_year YEAR;
ALTER TABLE songs
ADD COLUMN play_count INT DEFAULT 0;
ALTER TABLE songs
ADD COLUMN total_rating DECIMAL(3, 2) DEFAULT 0.00;
ALTER TABLE songs
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE songs
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
CREATE INDEX idx_mood ON songs(mood);
CREATE INDEX idx_artist ON songs(artist);
CREATE INDEX idx_play_count ON songs(play_count);
CREATE INDEX idx_rating ON songs(total_rating);
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    total_plays INT DEFAULT 0,
    favorite_mood VARCHAR(50),
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE TABLE IF NOT EXISTS playlists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_public (is_public)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE TABLE IF NOT EXISTS playlist_songs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    playlist_id INT NOT NULL,
    song_id INT NOT NULL,
    position INT DEFAULT 0,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
    UNIQUE KEY unique_playlist_song (playlist_id, song_id),
    INDEX idx_playlist_id (playlist_id),
    INDEX idx_song_id (song_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE TABLE IF NOT EXISTS play_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    song_id INT NOT NULL,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    play_duration INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE
    SET NULL,
        FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
        INDEX idx_user_id (user_id),
        INDEX idx_song_id (song_id),
        INDEX idx_played_at (played_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE TABLE IF NOT EXISTS favorites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    song_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_favorite (user_id, song_id),
    INDEX idx_user_id (user_id),
    INDEX idx_song_id (song_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE TABLE IF NOT EXISTS ratings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    song_id INT NOT NULL,
    rating INT NOT NULL CHECK (
        rating >= 1
        AND rating <= 5
    ),
    review TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE
    SET NULL,
        FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
        UNIQUE KEY unique_user_song_rating (user_id, song_id),
        INDEX idx_song_id (song_id),
        INDEX idx_rating (rating)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE TABLE IF NOT EXISTS mood_statistics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mood VARCHAR(50) NOT NULL,
    total_plays INT DEFAULT 0,
    unique_listeners INT DEFAULT 0,
    average_rating DECIMAL(3, 2) DEFAULT 0.00,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_mood (mood),
    INDEX idx_mood (mood)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
INSERT IGNORE INTO mood_statistics (
        mood,
        total_plays,
        unique_listeners,
        average_rating
    )
VALUES ('Happy', 0, 0, 0.00),
    ('Chill', 0, 0, 0.00),
    ('Sad', 0, 0, 0.00),
    ('Energetic', 0, 0, 0.00),
    ('Focus', 0, 0, 0.00),
    ('Night', 0, 0, 0.00);
CREATE TABLE IF NOT EXISTS live_streams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(100) NOT NULL,
    stream_title VARCHAR(200) NOT NULL,
    youtube_video_id VARCHAR(50) NOT NULL,
    description TEXT,
    is_live BOOLEAN DEFAULT FALSE,
    category VARCHAR(50) DEFAULT 'Concert',
    thumbnail_url VARCHAR(255),
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_artist (artist_name),
    INDEX idx_is_live (is_live),
    INDEX idx_category (category)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
INSERT IGNORE INTO live_streams (
        artist_name,
        stream_title,
        youtube_video_id,
        description,
        is_live,
        category
    )
VALUES (
        'Taylor Swift',
        'Taylor Swift - Live Concert',
        'jfKfPfJRdy4',
        'Taylor Swift live performance and concert streams',
        TRUE,
        'Concert'
    ),
    (
        'Justin Bieber',
        'Justin Bieber - Live Session',
        '5qap5aO4i9A',
        'Justin Bieber live music sessions and performances',
        FALSE,
        'Performance'
    ),
    (
        'Ed Sheeran',
        'Ed Sheeran - Acoustic Live',
        '4R8n6h0m5qk',
        'Ed Sheeran intimate acoustic live sessions',
        FALSE,
        'Session'
    ),
    (
        'Billie Eilish',
        'Billie Eilish - Live Performance',
        '7NOSDKb0HlU',
        'Billie Eilish live performances and concerts',
        FALSE,
        'Performance'
    ),
    (
        'The Weeknd',
        'The Weeknd - Live Concert',
        '1ZYbU82GVz4',
        'The Weeknd live concert streams',
        FALSE,
        'Concert'
    ),
    (
        'Ariana Grande',
        'Ariana Grande - Live Stage',
        '4xDzrJKXOOY',
        'Ariana Grande live stage performances',
        FALSE,
        'Concert'
    ),
    (
        'Drake',
        'Drake - Live Performance',
        'rUxyKA_-grg',
        'Drake live music performances',
        FALSE,
        'Performance'
    ),
    (
        'Dua Lipa',
        'Dua Lipa - Live Concert',
        'MYxAiK6VnXw',
        'Dua Lipa live concert streams',
        FALSE,
        'Concert'
    );
SELECT '✅ Basic migration completed! Tables and columns added.' AS status;
SELECT '⚠️  For Views, Procedures, and Triggers, see database.sql' AS next_step;