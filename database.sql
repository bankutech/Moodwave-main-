CREATE DATABASE IF NOT EXISTS mood;
USE mood;
CREATE TABLE IF NOT EXISTS songs (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    title        VARCHAR(150)  NOT NULL,
    artist       VARCHAR(150),
    mood         VARCHAR(50)   NOT NULL,
    audio_url    VARCHAR(255)  NOT NULL,
    duration     INT           DEFAULT 0,
    genre        VARCHAR(50),
    release_year YEAR,
    play_count   INT           DEFAULT 0,
    total_rating DECIMAL(3,2)  DEFAULT 0.00,
    created_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_mood       (mood),
    INDEX idx_artist     (artist),
    INDEX idx_play_count (play_count)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  UNIQUE NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    last_login    TIMESTAMP    NULL,
    favorite_mood VARCHAR(50),
    INDEX idx_username (username),
    INDEX idx_email    (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS play_history (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT,
    song_id       INT NOT NULL,
    played_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    play_duration INT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
    INDEX idx_user_id   (user_id),
    INDEX idx_song_id   (song_id),
    INDEX idx_played_at (played_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS favorites (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    user_id  INT NOT NULL,
    song_id  INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
    UNIQUE KEY  unique_user_favorite (user_id, song_id),
    INDEX idx_user_id (user_id),
    INDEX idx_song_id (song_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS mood_statistics (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    mood             VARCHAR(50) NOT NULL,
    total_plays      INT DEFAULT 0,
    unique_listeners INT DEFAULT 0,
    average_rating   DECIMAL(3,2) DEFAULT 0.00,
    last_updated     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_mood (mood),
    INDEX idx_mood (mood)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ratings (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT,
    song_id    INT NOT NULL,
    rating     INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review     TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_song_rating (user_id, song_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS live_streams (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    artist_name      VARCHAR(100) NOT NULL,
    stream_title     VARCHAR(200) NOT NULL,
    youtube_video_id VARCHAR(50)  NOT NULL,
    description      TEXT,
    is_live          BOOLEAN      DEFAULT FALSE,
    category         VARCHAR(50)  DEFAULT 'Concert',
    thumbnail_url    VARCHAR(255),
    view_count       INT          DEFAULT 0,
    created_at       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_artist   (artist_name),
    INDEX idx_is_live  (is_live),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT IGNORE INTO songs (title, artist, mood, audio_url) VALUES 
('Navjaxx - Embrace', 'Navjaxx', 'Chill', 'backend/music/Navjaxx - Embrace (4K Official Music Video) - Navjaxx.mp3'),
('Navjaxx, VXLLAIN - Distant Memories', 'Navjaxx & VXLLAIN', 'Chill', 'backend/music/Navjaxx, VXLLAIN - Distant Memories (4K Official Music Video) - Navjaxx.mp3'),
('Mr.Kitty - After Dark', 'Ava Rinzler', 'Night', 'backend/music/Mr.Kitty - After Dark (Slowed to Perfection + Rain Effect) - Ava Rinzler.mp3'),
('VØJ, Narvent - Memory Reboot', 'VØJ & Narvent', 'Chill', 'backend/music/VOJ, Narvent - Memory Reboot (4K Music Video) - Narvent.mp3'),
('20 Minutes of Calm and Inspiring Funk Best Aura Phonk Music Brazilian Phonk Remix', 'MironN', 'Night', 'backend/music/20 Minutes of Calm and Inspiring Fonk  Best Aura  Phonk music  Brazilian Phonk remix - MironN.mp3'),
('Activate Your Brain Potential 30 minutes deep focus BrainSync', 'BrainSync', 'Focus', 'backend/music/Activate Your Brain Potential  30 minutes deep focus  Improve Memory & Intelligence - BrainSync Focus Music.mp3'),
('AIRTEL PHONK', 'Mashuq Haque', 'Night', 'backend/music/AIRTEL PHONK - Mashuq Haque.mp3'),
('Nonstop Arijit Singh Mashup Lofi Boy', 'Lofi Boy', 'Chill', 'backend/music/Nonstop Arjit Singh Mashup  Remix  Saturday Special  Lofi Boy - Lofi boy (1).mp3'),
('Late Night - SAD CHILL Lofi Piano Beat', 'Rude Boy', 'Focus', 'backend/music/Late Night - (EA7) SAD CHILL Lofi Piano Beat - Rude Boy.mp3'),
('1 Hour Of Night Hindi Lofi Songs To Study Chill Relax Refreshing', 'indianmusicalvideos', 'Focus', 'backend/music/1 Hour Of Night Hindi Lofi Songs To Study _Chill _Relax _Refreshing - indianmusicalvideos.mp3'),
('Stellar Fission Oppenheimer X Interstellar Music Mix', 'SuperImpose', 'Chill', 'backend/music/Stellar Fission  Oppenheimer X Interstellar Music Mix - SuperImpose.mp3'),
('Happy Nation Phonk', 'x3L', 'Night', 'backend/music/Happy Nation Phonk - x3L.mp3'),
('Distant Echoes', 'VXLLAIN', 'Night', 'backend/music/Distant Echoes (Slowed + Reverb) - VXLLAIN.mp3'),
('ButtaBomma Allu Arjun Thaman S Armaan Malik', 'AlaVaikunthapurramuloo', 'Chill', 'backend/music/#AlaVaikunthapurramuloo - ButtaBomma Full Video Song (4K)  Allu Arjun  Thaman S  Armaan Malik.mp3'),
('2 Phut Hon', 'Various Artists', 'Chill', 'backend/music/2 Phut Hon(AVOIZE Remix).mp3'),
('24kGoldn Mood ft Iann Dior', 'MoodWave Artist', 'Chill', 'backend/music/9convert.com - 24kGoldn  Mood Lyrics ft Iann Dior_1080p.mp3'),
('Diet Pepsi', 'Addison Rae', 'Chill', 'backend/music/Addison Rae - Diet Pepsi (Lyrics).mp3'),
('Unforgettable NEIMY & NSH', 'Aerreo', 'Chill', 'backend/music/Aerreo - Unforgettable (Lyrics) feat. NEIMY & NSH.mp3'),
('Dil Bechara', 'Afreeda', 'Sad', 'backend/music/Afreeda - Dil Bechara.mp3'),
('On My Way', 'Alan Walker, Sabrina Carpenter & Farruko', 'Chill', 'backend/music/Alan Walker, Sabrina Carpenter & Farruko - On My Way (Lyrics).mp3'),
('Let Me Down Slowly', 'Alec Benjamin', 'Sad', 'backend/music/Alec Benjamin - Let Me Down Slowly (Lyrics).mp3'),
('Free Fire World Series 2021 Singapore', 'All In', 'Energetic', 'backend/music/All In - Lyric Video Free Fire World Series 2021 Singapore.mp3'),
('Theme Extended', 'Ant-Man', 'Chill', 'backend/music/Ant-Man - Theme Extended.mp3'),
('Avengers', 'London Music Works', 'Chill', 'backend/music/avengers-theme-song-download.mp3'),
('Waiting For Love', 'Avicii', 'Chill', 'backend/music/Avicii - Waiting For Love.mp3'),
('Your eyes teri nazron ne X your eyes got my heart falling for you', 'Barney Sku', 'Chill', 'backend/music/Barney Sku - Your eyes (Lyrics) teri nazron ne X your eyes got my heart falling for you.mp3'),
('Ta Ta Ta', 'Bayanni', 'Chill', 'backend/music/Bayanni - Ta Ta Ta (Official Lyric Audio).mp3'),
('Otilia@OtiliaBilioneraOfficial songlove', 'Bilionera', 'Chill', 'backend/music/Bilionera - Otilia ( Lyrics )@OtiliaBilioneraOfficial #song#lyrics#love.mp3'),
('Lovely Bleedingxhe', 'Billie Eilish', 'Sad', 'backend/music/Billie_Eilish_-_Lovely_Bleedingxhe_(getmp3.pro).mp3'),
('WHISTLE - Karaoke Easy', 'BLACKPINK', 'Chill', 'backend/music/BLACKPINK_-_WHISTLE_-_Karaoke_Easy_(getmp3.pro).mp3'),
('Oh No', 'Capone', 'Chill', 'backend/music/Capone - Oh No (Lyrics).mp3'),
('Hymn For The Weekend', 'Coldplay', 'Chill', 'backend/music/Coldplay - Hymn For The Weekend (Official Video).mp3'),
('Barbaadiyan Shiddat Sunny KRadhika M Sachet TNikhita G Madhubanti BSachin -Jigar', 'Various Artists', 'Chill', 'backend/music/Convert_Barbaadiyan (Full Video) Shiddat Sunny KRadhika M Sachet TNikhita G Madhubanti BSachin -Jigar.mp3'),
('Hours 002', 'Convert Josh Makazo', 'Chill', 'backend/music/Convert_Josh Makazo - Hours (Official Music Video)_002.mp3'),
('Kar Gayi Chull', 'Badshah, Amaal Mallik, Fazilpuria, Sukriti Kakar & Neha Kakkar', 'Energetic', 'backend/music/Convert_Kar Gayi Chull - Kapoor & Sons _ Sidharth Malhotra _ Alia Bhatt _ Badshah _ Amaal Mallik _Fazilpuria.mp3'),
('KATSEYE', 'Various Artists', 'Chill', 'backend/music/Convert_KATSEYE (캣츠아이)  Touch  Official MV (1).mp3'),
('Cheri Cheri Lady', 'Modern Talking', 'Chill', 'backend/music/Convert_Modern Talking - Cheri Cheri Lady (Lyrics).mp3'),
('I''m on Fire', 'Garena Free Fire & Trap', 'Energetic', 'backend/music/Convert_Official Music Video_ _I''m on Fire_ - T.R.A.P. (ft BJRNCK Awich Krawk Faruz Feet ).mp3'),
('Oonchi Oonchi Deewarein MeezaanAnaswara Arijit Singh Manan RadhikaVinay Bhushan K', 'Various Artists', 'Chill', 'backend/music/Convert_Oonchi Oonchi Deewarein (Full Video)_ MeezaanAnaswara _Arijit Singh Manan _RadhikaVinay_Bhushan K.mp3'),
('Clear Mothica Shawn Wasabi tiktok remix Musicallynewocl noordabashh catboiheaven', 'Convert Pusher', 'Chill', 'backend/music/Convert_Pusher - Clear ft. Mothica Shawn Wasabi tiktok remix _ Musicallynewocl _ noordabashh _ catboiheaven.mp3'),
('Aasa Kooda Thejo Bharathwaj Preity Mukundhan Sai Smriti', 'Convert Sai Abhyankkar', 'Chill', 'backend/music/Convert_Sai Abhyankkar - Aasa Kooda (Music Video) _ Thejo Bharathwaj _ Preity Mukundhan _ Sai Smriti.mp3'),
('The Machine', 'Reed Wonder & Aurora Olivas', 'Chill', 'backend/music/Convert_The Machine (Sped Up).mp3'),
('Speechless', 'Dan + Shay', 'Chill', 'backend/music/Dan + Shay - Speechless (Icon Video).mp3'),
('Run Free Official Ly', 'Deep Chills', 'Chill', 'backend/music/Deep_Chills_-_Run_Free_Official_Ly_(getmp3.pro).mp3'),
('Cool for the Summer', 'Demi Lovato', 'Chill', 'backend/music/Demi Lovato - Cool for the Summer (Official Video).mp3'),
('Sugar & Brownies', 'DHARIA', 'Happy', 'backend/music/DHARIA - Sugar & Brownies (by Monoir) [Official Video].mp3'),
('lady gaga, bruno mars', 'die with a smile', 'Happy', 'backend/music/die with a smile (tiktok versionbest part!) - lady gaga, bruno mars [edit audio].mp3'),
('Title Song', 'Dil Bechara', 'Sad', 'backend/music/Dil Bechara - Title Song.mp3'),
('Vacation', 'Dirty Heads', 'Happy', 'backend/music/Dirty Heads - Vacation (Lyric Video).mp3'),
('You''ve Got a Friend In Me', 'Randy Newman', 'Chill', 'backend/music/Disney s Toy Story-You ve Got a Friend in Me with.mp3'),
('One More Round Garena Free Fire', 'DJ KSHMR, Jeremy Oceans', 'Energetic', 'backend/music/DJ KSHMR, Jeremy Oceans - One More Round (Free Fire Booyah Day Theme Song) Garena Free Fire.mp3'),
('Dress', 'Taylor Swift', 'Chill', 'backend/music/DRESS!.mp3'),
('Rise Up 2', 'Egzod', 'Energetic', 'backend/music/Egzod - Rise Up (ft. Veronica Bravo & M.I.M.E) [NCS Release]_2.mp3'),
('No Rival', 'Egzod Maestro Chives & Alaina Cross', 'Chill', 'backend/music/Egzod Maestro Chives & Alaina Cross - No Rival [Official Lyric Video].mp3'),
('Middle of the Night', 'Elley Duhé', 'Night', 'backend/music/Elley Duhé - Middle of the Night (Nitti Gritti Remix).mp3'),
('dress Ultra slowed +) Reverb', 'eternxlkz', 'Night', 'backend/music/eternxlkz - dress Ultra slowed +) Reverb.mp3'),
('FORCE!', 'Eternxlkz', 'Chill', 'backend/music/Eternxlkz - FORCE! (Official Audio).mp3'),
('Feeling the Fire', 'Garena Free Fire', 'Energetic', 'backend/music/Feeling the Fire (Free Fire 7th Anniversary) (320).mp3'),
('For the First Time in Forever', 'Kristen Bell & Idina Menzel', 'Chill', 'backend/music/For the First Time in Forever (Disney s Frozen).mp3'),
('Ghungroo', 'Vishal & Shekhar, Arijit Singh & Shilpa Rao', 'Energetic', 'backend/music/Free Fire Holi Music Video ft. Hrithik Roshan Song DNA Mein Dance By Vishal & Shekhar.mp3'),
('Free Fire World Series Theme', 'Garena Free Fire', 'Energetic', 'backend/music/Free Fire World Series Theme (2022 Bangkok).mp3'),
('Free Fire x Alok Vale Vale Music Video', 'Various Artists', 'Energetic', 'backend/music/Free Fire x Alok Vale Vale Music Video.mp3'),
('Reunion', 'Alok, Dimitri Vegas & Like Mike & KSHMR', 'Energetic', 'backend/music/Freefire Anniversary.mp3'),
('Dil Bechara', 'Friendzone', 'Sad', 'backend/music/Friendzone - Dil Bechara.mp3'),
('Street Dancer 3D - Varun D - Siddharth B, Jubin N,Sachin-Jigar', 'Bezubaan Kab Se', 'Chill', 'backend/music/Full Song - Bezubaan Kab Se - Street Dancer 3D - Varun D - Siddharth B, Jubin N,Sachin-Jigar.mp3'),
('Moana', 'G-Eazy, Jack Harlow', 'Chill', 'backend/music/G-Eazy, Jack Harlow - Moana (Official Video).mp3'),
('Garena Free Fire One Man Panch New Update', 'Various Artists', 'Energetic', 'backend/music/Garena Free Fire One Man Panch New Update (Theme Song ).mp3'),
('February OB26 Update 2021', 'New Theme Song', 'Energetic', 'backend/music/Garena Free Fire OST - New Theme Song - February OB26 Update 2021 (MUST WATCH).mp3'),
('Celebration Call', 'Garena Free Fire', 'Energetic', 'backend/music/Garena Free Fire _ 6th Anniversary New Update ( Theme Song ).mp3'),
('Attack on Titan', 'Garena Free Fire', 'Energetic', 'backend/music/Garena Free Fire _ Ob27 New Update ( Theme Song ).mp3'),
('Mclaren', 'Garena Free Fire', 'Energetic', 'backend/music/Garena Free Fire _ The Mclaren New Update ( Theme Song ).mp3'),
('Gurinder Seagal 190', 'Gf Bf', 'Chill', 'backend/music/Gf Bf - Gurinder Seagal 190Kbps.mp3'),
('Heat Waves', 'Glass Animals', 'Chill', 'backend/music/Glass Animals - Heat Waves (Neovaii Remix).mp3'),
('Gryffin-Mega-Mashup-By-Karmaxis-After-Yo 3', 'Various Artists', 'Chill', 'backend/music/Gryffin-Mega-Mashup-By-Karmaxis-After-Yo_3.mp3'),
('Hawayein', 'Various Artists', 'Chill', 'backend/music/Hawayein (SongsMp3.Com).mp3'),
('Arjun X Arijit Singh • Vixauds', 'I ll be waiting X Kabhi Jo Badal Barse', 'Chill', 'backend/music/I ll be waiting X Kabhi Jo Badal Barse - Arjun X Arijit Singh (Audio edit) • Vixauds.mp3'),
('Let It Go', 'Idina Menzel', 'Chill', 'backend/music/Idina Menzel - Let It Go (from Frozen) (Official Video).mp3'),
('iglite incoming call new', 'Various Artists', 'Chill', 'backend/music/iglite_incoming_call_new.ogg'),
('Alan Walker, K-391 Play, Alone, Pt. II, Unity, ...', 'Ignite', 'Chill', 'backend/music/Ignite - Alan Walker, K-391 (Lyrics) _ Play, Alone, Pt. II, Unity, ....mp3'),
('Believer', 'Imagine Dragons', 'Energetic', 'backend/music/Imagine Dragons - Believer (Lyrics).mp3'),
('INDUSTRY BABY', 'Lil Nas X & Jack Harlow', 'Energetic', 'backend/music/Industry Baby X E.T. [Lyrics] _ Lil Nas X & Katy Perry.mp3'),
('Jawan Not Ramaiya Vastavaiya Extended Version Shah Rukh Khan Atlee Anirudh Nayanthara', 'Various Artists', 'Chill', 'backend/music/Jawan_ Not Ramaiya Vastavaiya Extended Version (Hindi)_ Shah Rukh Khan Atlee Anirudh Nayanthara.mp3'),
('Infinity ''cause i love you for infinity''', 'Jaymes Young', 'Chill', 'backend/music/Jaymes Young - Infinity (Lyrics) ''cause i love you for infinity''.mp3'),
('KEHLANI REMIX', 'Jordan Adetunji', 'Chill', 'backend/music/Jordan Adetunji - KEHLANI REMIX (feat. Kehlani) [Official Video].mp3'),
('MORE Male Cover', 'K-DA', 'Chill', 'backend/music/K-DA - MORE Male Cover.mp3'),
('Kabira', 'Pritam, Tochi Raina & Rekha Bhardwaj', 'Chill', 'backend/music/Kabira Full Song Yeh Jawaani Hai Deewani  Pritam  Ranbir Kapoor, Deepika Padukone.mp3'),
('I m So Sorry', 'Kai', 'Chill', 'backend/music/Kai - I m So Sorry (Kung Fu Panda 3 vs Imagine Dragons).mp3'),
('Kabir Singh 320', 'Kaise Hua', 'Chill', 'backend/music/Kaise Hua - Kabir Singh 320 Kbps.mp3'),
('khada hu aaj bhi wahi The Local Train Uali s', 'Various Artists', 'Chill', 'backend/music/khada hu aaj bhi wahi lyrics _ The Local Train _ Uali s Lyrics.mp3'),
('Dil Bechara', 'Khulke Jeene Ka', 'Sad', 'backend/music/Khulke Jeene Ka - Dil Bechara.mp3'),
('Kai''s Theme', 'Samuel Kim', 'Chill', 'backend/music/Kung Fu Panda 3 Soundtrack- Kai s theme.mp3'),
('Kung Fu Panda', 'Sarah Lula', 'Chill', 'backend/music/Kung Fu Panda Music Video.mp3'),
('Diet Mountain Dew', 'Lana Del Rey', 'Chill', 'backend/music/Lana Del Rey - Diet Mountain Dew (Lyrics).mp3'),
('Summertime Sadness', 'Lana Del Rey', 'Sad', 'backend/music/Lana Del Rey - Summertime Sadness (Lyrics).mp3'),
('Legends Never Die', 'League of Legends Music & Against The Current', 'Energetic', 'backend/music/LEGENDS_NEVER_DIE_LEAGUE_OF_LEGENDS_(1).mp3'),
('Ordinary Person Lyric Thalapathy Vijay, Anirudh Ravichander, Lokesh Kanagaraj, NikhitaGandhi', 'LEO', 'Chill', 'backend/music/LEO - Ordinary Person Lyric  Thalapathy Vijay, Anirudh Ravichander, Lokesh Kanagaraj, NikhitaGandhi.mp3'),
('People ''did you check on me''', 'Libianca', 'Chill', 'backend/music/Libianca - People (Lyrics) ''did you check on me''.mp3'),
('People', 'Libianca', 'Chill', 'backend/music/Libianca - People (Sped Up Lyrics).mp3'),
('Life force x Lost in the madness', 'Various Artists', 'Chill', 'backend/music/Life force x Lost in the madness (unreleased).mp3'),
('Tanhaji', 'Maay Bhavani', 'Chill', 'backend/music/Maay Bhavani - Tanhaji.mp3'),
('Madhukaitava Vidhwangsi', 'Tushar Dutta, Trishit & Supratik Das', 'Chill', 'backend/music/Madhukaitava Vidhwangsi.mp3'),
('Dil Bechara', 'Main Tumhara', 'Sad', 'backend/music/Main Tumhara - Dil Bechara.mp3'),
('Panipat', 'Mard Maratha', 'Chill', 'backend/music/Mard Maratha - Panipat.mp3'),
('Girls Like You Cardi B', 'Maroon 5', 'Happy', 'backend/music/Maroon 5 - Girls Like You ft. Cardi B.mp3'),
('Guitar Cover by CallumMcGaw', 'Marvels Ant-Man Main Theme', 'Chill', 'backend/music/Marvels Ant-Man Main Theme (Christophe Beck) - Guitar Cover by CallumMcGaw.mp3'),
('Dil Bechara', 'Maskhari', 'Sad', 'backend/music/Maskhari - Dil Bechara.mp3'),
('kali uchis', 'moonlight', 'Night', 'backend/music/moonlight - kali uchis [edit audio].mp3'),
('Shree Siddhivinayak Mantra And Aarti', 'Amitabh Bachchan', 'Chill', 'backend/music/Myntra.mp3'),
('Great Big Storm', 'Nate Ruess', 'Chill', 'backend/music/Nate Ruess Great Big Storm [OFFICIAL VIDEO].mp3'),
('Darkside', 'NEONI', 'Night', 'backend/music/NEONI - Darkside (Lyrics).mp3'),
('Haunted House', 'Neoni', 'Energetic', 'backend/music/Neoni - Haunted House [NCS Release].mp3'),
('Perfect Super Slowed', 'NEXT', 'Night', 'backend/music/NEXT - Perfect Super Slowed.mp3'),
('ncts', 'next!', 'Night', 'backend/music/next! - ncts (slowed) [edit audio].mp3'),
('Feel this moment', 'Nightcore', 'Chill', 'backend/music/Nightcore - Feel this moment (male version remix).mp3'),
('Life Goes On 4', 'Oliver Tree', 'Chill', 'backend/music/Oliver Tree - Life Goes On (Lyrics) (1)_4.mp3'),
('My Once Upon a Time', 'Dove Cameron', 'Chill', 'backend/music/Once Upon a Time.mp3'),

('Over the Horizon', 'Atmospheric Lights', 'Focus', 'backend/music/Over_the_Horizon.m4a'),
('Pathaan’s Theme', 'Sanchit Balhara, Ankit Balhara & Magdalena Supel', 'Chill', 'backend/music/Pathaan''s Theme _ Shah Rukh Khan _ Sanchit, Ankit _ Kit Bee _ Magdalena Supel _ YRF Spy Universe.mp3'),
('Feel This Moment Christina Aguilera', 'Pitbull', 'Chill', 'backend/music/Pitbull - Feel This Moment ft. Christina Aguilera.mp3'),
('Sture Zutterberg', 'REVIVE', 'Chill', 'backend/music/REVIVE (Hallman Remix) - Sture Zutterberg (LYRICS).mp3'),
('Revive', 'Revive by Sture Zetterberg', 'Chill', 'backend/music/Revive [Hallman Remix] by Sture Zetterberg - [House Music].mp3'),
('Lemonade', 'Internet Money, Don Toliver, Roddy Ricch & Robin S.', 'Sad', 'backend/music/Roses x The Box x No Idea x Lovely (Imanbek x Don Toliver x Roddy Rich x Billie Eillish )[Mix].mp3'),
('Espresso', 'Sabrina Carpenter', 'Happy', 'backend/music/Sabrina Carpenter - Espresso (Espressooooo Version) [Official Audio].mp3'),
('Sample Audio', 'Rans Musiq', 'Chill', 'backend/music/Sample audio.mp3'),
('Safari', 'Serena', 'Chill', 'backend/music/Serena - Safari (Official Video) (320 kbps).mp3'),
('dead to me', 'sex whales & fraxo', 'Night', 'backend/music/sex whales & fraxo - dead to me  ( slow + reverb ).mp3'),
('Tanhaji', 'Shankara Re Shankara', 'Chill', 'backend/music/Shankara Re Shankara - Tanhaji.mp3'),
('Señorita', 'Shawn Mendes & Camila Cabello', 'Happy', 'backend/music/Shawn Mendes, Camila Cabello – Señorita.mp3'),
('shubaarambh', 'Various Artists', 'Chill', 'backend/music/shubaarambh [edit audio].mp3'),
('Sona Kitna Sona Hai', 'Udit Narayan & Poornima', 'Chill', 'backend/music/Sona Kitna Sona Hai.mp3'),
('Soni Soni Is Vishk Rebound Rohit Saraf, Pashmina @DarshanRavalDZ@jonitamusic, Rochak,Gurpreet', 'Various Artists', 'Chill', 'backend/music/Soni Soni  Ishq Vishk Rebound  Rohit Saraf, Pashmina @DarshanRavalDZ@jonitamusic, Rochak,Gurpreet.mp3'),
('Cradles', 'Sub Urban', 'Energetic', 'backend/music/Sub Urban - Cradles [Official Music Video].mp3'),
('The Man', 'Taylor Swift', 'Happy', 'backend/music/Taylor Swift - The Man.mp3'),
('Lofi Arijit Singh Girl I Need You', 'Teri Dhadkan Se Meri Dhadkan Ab Judne Lagi', 'Night', 'backend/music/Teri Dhadkan Se Meri Dhadkan Ab Judne Lagi - [Slowed  Reverb] Lofi  Arijit Singh  Girl I Need You.mp3'),
('SOTYAlia Bhatt,Sidharth Malhotra,Varun DhawanSunidhi Chauhan', 'The Disco Song', 'Chill', 'backend/music/The Disco Song Full Song - SOTYAlia Bhatt,Sidharth Malhotra,Varun DhawanSunidhi Chauhan.mp3'),
('Dil Bechara', 'The Horizon of Saudade', 'Sad', 'backend/music/The Horizon of Saudade - Dil Bechara.mp3'),
('The Machine', 'Reed Wonder & Aurora Olivas', 'Chill', 'backend/music/The Machine.mp3'),
('Rise Up', 'TheFatRat', 'Energetic', 'backend/music/TheFatRat - Rise Up (Lyrics).mp3'),
('Fly Away', 'TheFatRat', 'Energetic', 'backend/music/TheFatRat-Fly-Away-feat-Anjulie_1.mp3'),
('Theme from Ant-Man', 'Christophe Beck', 'Chill', 'backend/music/Theme from Ant-Man.mp3'),
('Tanhaji', 'Tinak Tinak', 'Chill', 'backend/music/Tinak Tinak - Tanhaji.mp3'),
('Tokyo Drift', 'Teriyaki Boyz', 'Energetic', 'backend/music/Tokyo Drift & Sean Paul Temperature [REMIX] _ Fast And Furious 8 (Final Battle).mp3'),
('Top 100 Songs 2020 - Most Popular English Songs 2020', 'Top Songs April 2020', 'Chill', 'backend/music/Top Songs April 2020 - Top 100 Songs 2020 - Most Popular English Songs 2020.mp3'),
('Music Video Chithha Siddharth Santhosh Narayanan Deeraj Vaidy Etaki', 'Unakku Thaan', 'Chill', 'backend/music/Unakku Thaan - Music Video _ Chithha _ Siddharth _ Santhosh Narayanan _ Deeraj Vaidy _ Etaki.mp3'),
('Mortals Slowed + Reverb Bass Boosted', 'Warriyo', 'Night', 'backend/music/Warriyo - Mortals __ Slowed + Reverb __ Bass Boosted.mp3'),
('We Win', 'Garena Free Fire', 'Energetic', 'backend/music/WE WIN (Free Fire 6th Anniversary).mp3'),
('When I''m Sixty Four', 'Cleveland Francis', 'Chill', 'backend/music/Willow Tree__[ringtones pro.mp3'),
('See You Again Charlie Puth', 'Wiz Khalifa', 'Chill', 'backend/music/Wiz Khalifa - See You Again (Lyrics) ft. Charlie Puth.mp3'),
('Garena Free Fire 6th Anniversary New Update Theme Song Garena Free Fire AssassinFF', 'MoodWave Artist', 'Energetic', 'backend/music/X2Download.app - Garena Free Fire_ 6th Anniversary(OB40 PATCH) New Update_Theme Song_Garena Free Fire_ AssassinFF (320 kbps).mp3'),
('DDU-DU DDU-DU English Cover by JANNY', 'BLACKPINK', 'Chill', 'backend/music/X2Download.com -  BLACKPINK - DDU-DU DDU-DU _ English Cover by JANNY (128 kbps).mp3'),
('Free Fire -Instrumental', 'REUNION', 'Energetic', 'backend/music/X2Download.com - REUNION - Free Fire -Instrumental (320 kbps).mp3'),
('-Dimitri Vegas', 'Various Artists', 'Chill', 'backend/music/X2Download.com-Dimitri Vegas .mp3'),
('1 Sad Songs Playlist I''m sorry, don''t leave me...', 'MoodWave Artist', 'Chill', 'backend/music/Y2Mate.is - #1 Sad Songs Playlist (Lyrics Video) I''m sorry, don''t leave me...-vOvvAgq-2XU-160k-1644322555461.mp3'),
('Faded', 'Alan Walker', 'Chill', 'backend/music/Y2Mate.is - Alan Walker - Faded (Lyrics)-qdpXxGPqW-Y-160k-1642431005445.mp3'),
('YAD', 'Various Artists', 'Chill', 'backend/music/YAD (Яд) ENGLISH VERSION (lyric video).mp3'),
('Avicii The Nights', 'MoodWave Artist', 'Energetic', 'backend/music/yt1s.com - Avicii  The Nights.mp3'),
('Desiigner Panda', 'MoodWave Artist', 'Chill', 'backend/music/yt1s.com - Desiigner  Panda Official Music Video.mp3'),
('GENTRAMMEL Out of My Mind', 'MoodWave Artist', 'Chill', 'backend/music/yt1s.com - GENTRAMMEL  Out of My Mind Lyrics.mp3'),
('Imagine Dragons Believer Romy Wave Cover NSG Remix', 'MoodWave Artist', 'Energetic', 'backend/music/yt1s.com - Imagine Dragons  Believer Romy Wave Cover NSG Remix.mp3'),
('Janji Heroes Tonight feat Johnning', 'MoodWave Artist', 'Energetic', 'backend/music/yt1s.com - Janji  Heroes Tonight feat Johnning NCS Release.mp3'),
('Justin Bieber Baby ft Ludacris', 'MoodWave Artist', 'Happy', 'backend/music/yt1s.com - Justin Bieber  Baby Official Music Video ft Ludacris.mp3'),
('Lost Sky Fearless pt II feat Chris Linton Music Video Edit', 'MoodWave Artist', 'Chill', 'backend/music/yt1s.com - Lost Sky  Fearless pt II feat Chris Linton Music Video Edit.mp3'),
('NEFFEX Grateful', 'MoodWave Artist', 'Energetic', 'backend/music/yt1s.com - NEFFEX  Grateful Lyrics.mp3'),
('NEFFEX Failure', 'MoodWave Artist', 'Energetic', 'backend/music/yt1s.com - NEFFEX Failure  Copyright Free.mp3'),
('Dusk Till Dawn', 'ZAYN & Sia', 'Sad', 'backend/music/ZAYN & Sia - Dusk Till Dawn (Lyrics).mp3'),
('Ajay-Atul -T-Series', 'Shah Rukh Khan, Anushka Sharma, Katrina Kaif', 'Chill', 'backend/music/ZERO- Mere Naam Tu Full Song - Shah Rukh Khan, Anushka Sharma, Katrina Kaif - Ajay-Atul -T-Series.mp3'),
('Bhool Bhulaiyaa 2 Kartik A, Kiara A, Tabu Tanishk, Pritam, Neeraj, Anees B, Bhushan K', 'Various Artists', 'Chill', 'backend/music/[BTCLOD.COM] Bhool Bhulaiyaa 2 (Title Track) Kartik A, Kiara A, Tabu _Tanishk, Pritam, Neeraj, Anees B, Bhushan K-320k.mp3'),
('Often', 'The Weeknd', 'Chill', 'backend/music/[BTCLOD.COM] The Weeknd - Often (NSFW) (Official Video)-320k.mp3');
INSERT IGNORE INTO users (username, email, password_hash) VALUES
('demo_user', 'demo@moodwave.com', '$2b$10$placeholder_hash_replace_me');
INSERT IGNORE INTO mood_statistics (mood, total_plays, unique_listeners, average_rating) VALUES
('Happy',     0, 0, 0.00),
('Chill',     0, 0, 0.00),
('Sad',       0, 0, 0.00),
('Energetic', 0, 0, 0.00),
('Focus',     0, 0, 0.00),
('Night',     0, 0, 0.00);
INSERT IGNORE INTO live_streams (artist_name, stream_title, youtube_video_id, description, is_live, category) VALUES
('Taylor Swift',     'Taylor Swift - Live Concert',      'jfKfPfJRdy4',   'Taylor Swift live performance and concert streams',       TRUE,  'Concert'),
('The Good Life Radio','24/7 Chill & House Live',        '36YnV9STBqc', '24/7 relaxing house and chill music livestream', TRUE, 'Music'),
('Justin Bieber',    'Justin Bieber - Live Session',     '5qap5aO4i9A',   'Justin Bieber live music sessions and performances',      FALSE, 'Performance'),
('Ed Sheeran',       'Ed Sheeran - Acoustic Live',       '4R8n6h0m5qk',   'Ed Sheeran intimate acoustic live sessions',              FALSE, 'Session'),
('Billie Eilish',    'Billie Eilish - Live Performance',  '7NOSDKb0HlU',  'Billie Eilish live performances and concerts',             FALSE, 'Performance'),
('The Weeknd',       'The Weeknd - Live Concert',        '1ZYbU82GVz4',   'The Weeknd live concert streams',                          FALSE, 'Concert'),
('Ariana Grande',    'Ariana Grande - Live Stage',       '4xDzrJKXOOY',   'Ariana Grande live stage performances',                    FALSE, 'Concert'),
('Drake',            'Drake - Live Performance',          'rUxyKA_-grg',   'Drake live music performances',                            FALSE, 'Performance'),
('Dua Lipa',         'Dua Lipa - Live Concert',          'MYxAiK6VnXw',   'Dua Lipa live concert streams',                            FALSE, 'Concert');
CREATE OR REPLACE VIEW vw_mood_analytics AS
SELECT
    s.mood,
    COUNT(DISTINCT s.id)       AS total_songs,
    COUNT(ph.id)               AS total_plays,
    COUNT(DISTINCT ph.user_id) AS unique_listeners,
    COUNT(DISTINCT f.user_id)  AS total_favorites
FROM songs s
LEFT JOIN play_history ph ON s.id = ph.song_id
LEFT JOIN favorites    f  ON s.id = f.song_id
GROUP BY s.mood
ORDER BY total_plays DESC;
CREATE OR REPLACE VIEW vw_user_activity AS
SELECT
    u.id,
    u.username,
    u.email,
    u.favorite_mood,
    COUNT(ph.id)              AS total_plays,
    COUNT(DISTINCT f.song_id) AS favorite_count,
    COUNT(DISTINCT ph.song_id) AS songs_played,
    MAX(ph.played_at)         AS last_played
FROM users u
LEFT JOIN favorites    f  ON u.id = f.user_id
LEFT JOIN play_history ph ON u.id = ph.user_id
GROUP BY u.id, u.username, u.email, u.favorite_mood;
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS sp_record_play(
    IN p_user_id       INT,
    IN p_song_id       INT,
    IN p_play_duration INT
)
BEGIN
    INSERT IGNORE INTO play_history (user_id, song_id, play_duration)
    VALUES (p_user_id, p_song_id, p_play_duration);
END //
DELIMITER ;
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS sp_get_recommendations(
    IN p_user_id INT,
    IN p_limit   INT
)
BEGIN
    SELECT DISTINCT s.*
    FROM songs s
    WHERE s.mood = (SELECT favorite_mood FROM users WHERE id = p_user_id)
      AND s.id NOT IN (SELECT song_id FROM play_history WHERE user_id = p_user_id)
    ORDER BY s.id DESC
    LIMIT p_limit;
END //
DELIMITER ;
DELIMITER //
CREATE TRIGGER IF NOT EXISTS trg_update_favorite_mood
AFTER INSERT ON play_history
FOR EACH ROW
BEGIN
    IF NEW.user_id IS NOT NULL THEN
        UPDATE users u
        SET favorite_mood = (
            SELECT mood
            FROM songs s
            JOIN play_history ph ON s.id = ph.song_id
            WHERE ph.user_id = NEW.user_id
            GROUP BY s.mood
            ORDER BY COUNT(*) DESC
            LIMIT 1
        )
        WHERE u.id = NEW.user_id;
    END IF;
END //
DELIMITER ;
CREATE INDEX idx_play_history_user_song   ON play_history(user_id, song_id, played_at);