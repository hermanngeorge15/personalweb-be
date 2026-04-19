-- V12: Tiered Content Schema
-- Adds support for multi-level content (TL;DR, Beginner, Intermediate, Deep Dive)

-- Add new columns to kotlin_topic
ALTER TABLE kotlin_topic ADD COLUMN IF NOT EXISTS part_number INT;
ALTER TABLE kotlin_topic ADD COLUMN IF NOT EXISTS part_name VARCHAR(100);
ALTER TABLE kotlin_topic ADD COLUMN IF NOT EXISTS content_structure VARCHAR(50) DEFAULT 'tiered';
ALTER TABLE kotlin_topic ADD COLUMN IF NOT EXISTS max_tier_level INT DEFAULT 2;

-- Content tiers table (multi-level explanations)
CREATE TABLE IF NOT EXISTS kotlin_content_tier (
    id SERIAL PRIMARY KEY,
    topic_id VARCHAR(50) NOT NULL REFERENCES kotlin_topic(id) ON DELETE CASCADE,
    tier_level INT NOT NULL CHECK (tier_level BETWEEN 1 AND 4),
    tier_name VARCHAR(50) NOT NULL,
    title VARCHAR(255),
    explanation TEXT NOT NULL,
    code_examples TEXT, -- JSON array of code snippets
    reading_time_minutes INT DEFAULT 5,
    learning_objectives TEXT, -- JSON array
    prerequisites TEXT, -- JSON array of topic IDs
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(topic_id, tier_level)
);

CREATE INDEX IF NOT EXISTS idx_kotlin_content_tier_topic ON kotlin_content_tier(topic_id);
CREATE INDEX IF NOT EXISTS idx_kotlin_content_tier_level ON kotlin_content_tier(tier_level);

-- Runnable examples table (for Kotlin Playground)
CREATE TABLE IF NOT EXISTS kotlin_runnable_example (
    id SERIAL PRIMARY KEY,
    topic_id VARCHAR(50) NOT NULL REFERENCES kotlin_topic(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    code TEXT NOT NULL,
    expected_output TEXT,
    tier_level INT NOT NULL DEFAULT 2,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_kotlin_runnable_example_topic ON kotlin_runnable_example(topic_id);

-- Expense Tracker chapters table
CREATE TABLE IF NOT EXISTS kotlin_expense_tracker_chapter (
    id SERIAL PRIMARY KEY,
    chapter_number INT NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    introduction TEXT,
    implementation_steps TEXT, -- JSON array
    code_snippets TEXT, -- JSON object
    summary TEXT,
    difficulty VARCHAR(20) DEFAULT 'beginner',
    estimated_time_minutes INT DEFAULT 30,
    previous_chapter INT,
    next_chapter INT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Link table for topics used in expense tracker chapters
CREATE TABLE IF NOT EXISTS kotlin_topic_chapter_link (
    id SERIAL PRIMARY KEY,
    topic_id VARCHAR(50) NOT NULL REFERENCES kotlin_topic(id) ON DELETE CASCADE,
    chapter_id INT NOT NULL REFERENCES kotlin_expense_tracker_chapter(id) ON DELETE CASCADE,
    usage_type VARCHAR(50) NOT NULL CHECK (usage_type IN ('primary', 'supporting', 'reference')),
    context_description TEXT,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(topic_id, chapter_id)
);

CREATE INDEX IF NOT EXISTS idx_kotlin_topic_chapter_link_topic ON kotlin_topic_chapter_link(topic_id);
CREATE INDEX IF NOT EXISTS idx_kotlin_topic_chapter_link_chapter ON kotlin_topic_chapter_link(chapter_id);
