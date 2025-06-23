CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    favorite_insult VARCHAR(255) NOT NULL
);

INSERT INTO users (name, favorite_insult) VALUES
    ('Jean-Kevin', 'You code like a Java dev on Monday morning'),
    ('Brigitte', 'Your commit messages make Git cry'),
    ('Mustafa', 'You write CSS with inline styles… in 2025'),
    ('Lucie', 'You name variables like "data1" and "stuff"'),
    ('Bob', 'Your SQL injections are just sad now');
