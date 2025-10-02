CREATE DATABASE labdb;
CREATE USER 'labuser'@'%' IDENTIFIED BY 'labpass';
GRANT ALL PRIVILEGES ON labdb.* TO 'labuser'@'%';
FLUSH PRIVILEGES;

USE labdb;
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    content VARCHAR(255) NOT NULL
);
INSERT INTO messages (content) VALUES ('Hello from Lab DB!');

