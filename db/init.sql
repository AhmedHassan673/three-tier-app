CREATE TABLE IF NOT EXISTS tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    is_done BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO tasks (title, is_done) VALUES
    ('Set up EC2 instance', TRUE),
    ('Install Docker & Docker Compose', TRUE),
    ('Deploy 3-tier app', FALSE);
