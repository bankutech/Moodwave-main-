// db.js
const mysql = require('mysql2');

// Create connection to MySQL
const db = mysql.createConnection({
    host: 'localhost',      // usually localhost
    user: 'root',           // your MySQL username
    password: 'Sm@13022006',           // your MySQL password
    database: 'mood'    // database name
});

// Connect and check
db.connect((err) => {
    if (err) {
        console.error('Database connection failed: ' + err.stack);
        return;
    }
    console.log('Connected to MySQL database.');
});

module.exports = db;
