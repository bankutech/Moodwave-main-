# Moodwave-main-

## Overview
![MoodWave Hero](https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?auto=format&fit=crop&q=80&w=1200&h=400)

**MoodWave** is not just a music player; it's an ambient experience. Designed to bridge the gap between human emotion and digital sound, MoodWave adapts to your current state of mind, providing the perfect soundtrack for every moment of your day.

Whether you're looking for the high-octane energy of a workout, the deep focus of a late-night study session, or the tranquil peace of a rainy afternoon, MoodWave is your intelligent companion.

---

##  The MoodWave Experience

| Feature | Why You'll Love It |
| :--- | :--- |
| ** 6 Mood Ecosystem** | Curated environments for Happy, Chill, Sad, Energetic, Focus, and Night. |
| **️ Intelligent Mixer** | Blend different "vibes" to create a personal, cross-mood sonic landscape. |
| ** Living Visuals** | Real-time, high-fidelity frequency bar visualizers that dance to the rhythm. |
| ** Infinite Discovery** | Powered by Last.fm and YouTube, find any track in the world instantly. |
| ** Live Stage** | Experience the magic of live performances with our curated 24/7 stage. |
| ** DBMS Excellence** | A masterclass in database design, featuring optimized MySQL orchestration. |

---

## ️ Built for the Modern Web

MoodWave is a testament to the power of pure, high-performance web technologies. No bloated frameworks—just raw speed and elegant design.

### Frontend: The "Neon Glass" Aesthetic
- **Visual Design**: A premium glassmorphism interface with vibrant neon accents.
- **Audio Logic**: Harnessing the **Web Audio API** for precision frequency analysis.
- **Responsive Layout**: Designed to look stunning on every screen size.

### Backend: The Engine of Sound
- **Architecture**: A robust Node.js/Express ecosystem for seamless data flow.
- **Streaming**: Advanced YouTube audio extraction with low-latency proxying.
- **Database**: A highly optimized MySQL schema featuring 9 normalized tables, automated triggers, and complex analytical views.

---

##  Setting Up Your Wave

### 1. Prerequisites
- **Node.js** (v16 or higher)
- **MySQL Server** (8.0 or higher)
- **Last.fm API Key** (for track discovery)

### 2. Quick Installation
```bash
# Clone the vision
git clone https://github.com/bankutech/Moodwave-main-.git
cd Moodwave-main-

# Set up the backend
cd public/backend
npm install
```

### 3. Database Initialization
Prepare your database environment by running the provided SQL script:
```bash
mysql -u root -p < database.sql
```
*This command initializes the `mood` database, sets up all relational structures, and populates sample data.*

### 4. Configuration
Create a `.env` file in the project root:
```env
DB_HOST=localhost
DB_USER=your_user
DB_PASSWORD=your_password
DB_NAME=mood
PORT=3000
LASTFM_API_KEY=your_key
```

### 5. Launch
```bash
npm start
```
Your MoodWave experience will be waiting for you at `http://localhost:3000`.

---

##  The Palette of Sound

Every mood in MoodWave has its own identity:
-  **Happy**: Golden sunshine for your brightest days.
-  **Chill**: Sky blue serenity for moments of peace.
-  **Sad**: Lavender reflections for when the world slows down.
-  **Energetic**: Vibrant red for the drive you need.
-  **Focus**: Teal clarity for your deepest work.
-  **Night**: Indigo depth for the quiet hours.

---

##  Join the Wave
MoodWave is an open-source project born from a passion for music and technology. We welcome contributors who want to help us redefine the digital listening experience.

**License**: Distributed under the MIT License.

---
**Made with ️ and  by [bankutech](https://github.com/bankutech)**

## Getting Started
Please refer to the source files for specific installation and usage instructions. Ensure that your local environment meets the standard requirements for the associated technologies.

## Project Structure
This project is organized into standard directories. Key configuration files and primary source code are located in the root directory.
