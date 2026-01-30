-- Migration: Add tiered content support for Kotlin Learning Platform
-- This enables multi-level content: TL;DR, Beginner, Intermediate, Deep Dive

-- =====================================================
-- 1. Add tier-related columns to kotlin_topic
-- =====================================================

-- Add content structure type (flat = current behavior, tiered = new multi-tier)
ALTER TABLE kotlin_topic
ADD COLUMN IF NOT EXISTS content_structure VARCHAR(20) DEFAULT 'flat'
CHECK (content_structure IN ('flat', 'tiered'));

-- Add max tier level available for this topic (1-4)
ALTER TABLE kotlin_topic
ADD COLUMN IF NOT EXISTS max_tier_level INT DEFAULT 1
CHECK (max_tier_level BETWEEN 1 AND 4);

-- Add part/section grouping (Part 1: Fundamentals, Part 2: OOP, etc.)
ALTER TABLE kotlin_topic
ADD COLUMN IF NOT EXISTS part_number INT DEFAULT 1;

ALTER TABLE kotlin_topic
ADD COLUMN IF NOT EXISTS part_name VARCHAR(100);

-- =====================================================
-- 2. Create content tier table
-- =====================================================

CREATE TABLE IF NOT EXISTS kotlin_content_tier (
    id SERIAL PRIMARY KEY,
    topic_id VARCHAR(50) NOT NULL REFERENCES kotlin_topic(id) ON DELETE CASCADE,

    -- Tier level: 1=TL;DR, 2=Beginner, 3=Intermediate, 4=Deep Dive
    tier_level INT NOT NULL CHECK (tier_level BETWEEN 1 AND 4),
    tier_name VARCHAR(50) NOT NULL, -- 'TL;DR', 'Beginner', 'Intermediate', 'Deep Dive'

    -- Content for this tier
    title VARCHAR(255), -- Optional tier-specific title
    explanation TEXT NOT NULL,
    code_examples TEXT, -- JSON array of code snippets for this tier

    -- Metadata
    reading_time_minutes INT DEFAULT 5,
    learning_objectives TEXT, -- JSON array of objectives
    prerequisites TEXT, -- JSON array of prerequisite topic IDs

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Each topic can have only one entry per tier level
    UNIQUE(topic_id, tier_level)
);

CREATE INDEX IF NOT EXISTS idx_kotlin_content_tier_topic ON kotlin_content_tier(topic_id);
CREATE INDEX IF NOT EXISTS idx_kotlin_content_tier_level ON kotlin_content_tier(tier_level);

-- =====================================================
-- 3. Create runnable examples table (for Kotlin Playground)
-- =====================================================

CREATE TABLE IF NOT EXISTS kotlin_runnable_example (
    id SERIAL PRIMARY KEY,
    topic_id VARCHAR(50) NOT NULL REFERENCES kotlin_topic(id) ON DELETE CASCADE,
    tier_level INT DEFAULT 1, -- Which tier this example belongs to

    -- Example metadata
    title VARCHAR(255) NOT NULL,
    description TEXT,

    -- Code that can be run in Kotlin Playground
    code TEXT NOT NULL,

    -- Expected output (for verification)
    expected_output TEXT,

    -- Ordering
    order_index INT NOT NULL DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_kotlin_runnable_example_topic ON kotlin_runnable_example(topic_id);
CREATE INDEX IF NOT EXISTS idx_kotlin_runnable_example_tier ON kotlin_runnable_example(tier_level);

-- =====================================================
-- 4. Create expense tracker chapter mapping table
-- =====================================================

CREATE TABLE IF NOT EXISTS kotlin_expense_tracker_chapter (
    id SERIAL PRIMARY KEY,
    chapter_number INT NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT,

    -- Which topics are covered in this chapter (JSON array of topic IDs)
    topic_ids TEXT, -- JSON array like ["variables", "basic-types"]

    -- Chapter content
    introduction TEXT,
    implementation_steps TEXT, -- JSON array of steps
    code_snippets TEXT, -- JSON array of code blocks
    summary TEXT,

    -- Navigation
    previous_chapter INT,
    next_chapter INT,

    -- Metadata
    estimated_time_minutes INT DEFAULT 30,
    difficulty VARCHAR(20) DEFAULT 'beginner',

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_expense_chapter_number ON kotlin_expense_tracker_chapter(chapter_number);

-- =====================================================
-- 5. Link topics to expense tracker chapters
-- =====================================================

CREATE TABLE IF NOT EXISTS kotlin_topic_chapter_link (
    id SERIAL PRIMARY KEY,
    topic_id VARCHAR(50) NOT NULL REFERENCES kotlin_topic(id) ON DELETE CASCADE,
    chapter_id INT NOT NULL REFERENCES kotlin_expense_tracker_chapter(id) ON DELETE CASCADE,

    -- How the topic is used in this chapter
    usage_type VARCHAR(50) DEFAULT 'primary' CHECK (usage_type IN ('primary', 'secondary', 'reference')),

    -- Brief description of how the topic applies
    context_description TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(topic_id, chapter_id)
);

CREATE INDEX IF NOT EXISTS idx_topic_chapter_topic ON kotlin_topic_chapter_link(topic_id);
CREATE INDEX IF NOT EXISTS idx_topic_chapter_chapter ON kotlin_topic_chapter_link(chapter_id);

-- =====================================================
-- 6. Update existing topic to use tiered structure
-- =====================================================

-- Migrate existing "what-is-a-class" topic to tiered structure
UPDATE kotlin_topic
SET content_structure = 'tiered',
    max_tier_level = 3,
    part_number = 1,
    part_name = 'Kotlin Fundamentals'
WHERE id = 'what-is-a-class';

-- Add tier content for the existing topic
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, explanation, reading_time_minutes)
VALUES
(
    'what-is-a-class',
    1,
    'TL;DR',
    E'A **class** is a blueprint for objects. In Kotlin, define it with one line:\n\n```kotlin\nclass Person(val name: String, var age: Int)\n```\n\nThat''s it! No getters, setters, or boilerplate needed.',
    1
),
(
    'what-is-a-class',
    2,
    'Beginner',
    E'## What is a Class?\n\nThink of a class as a **cookie cutter** - it defines the shape, and you can make many cookies (objects) from it.\n\n### Creating a Class\n\n```kotlin\nclass Dog(val name: String, var age: Int)\n```\n\nThis one line gives you:\n- A constructor that takes `name` and `age`\n- Properties you can access with `dog.name` and `dog.age`\n- `name` is read-only (`val`), `age` can change (`var`)\n\n### Using Your Class\n\n```kotlin\nval myDog = Dog("Buddy", 3)\nprintln(myDog.name)  // Buddy\nmyDog.age = 4        // Happy birthday!\n```\n\n### Adding Behavior\n\n```kotlin\nclass Dog(val name: String, var age: Int) {\n    fun bark() = println("$name says Woof!")\n    fun haveBirthday() { age++ }\n}\n```\n\n**Key takeaway:** Kotlin classes are concise. What takes 30+ lines in Java takes 3 in Kotlin.',
    5
),
(
    'what-is-a-class',
    3,
    'Intermediate',
    E'## Classes In-Depth\n\n### Primary vs Secondary Constructors\n\n**Primary constructor** - in the class header:\n```kotlin\nclass Person(val name: String, var age: Int)\n```\n\n**Secondary constructor** - for alternative initialization:\n```kotlin\nclass Person(val name: String, var age: Int) {\n    constructor(name: String) : this(name, 0)\n}\n```\n\n### Init Blocks\n\nCode that runs during construction:\n```kotlin\nclass Person(val name: String, var age: Int) {\n    init {\n        require(age >= 0) { "Age cannot be negative" }\n        println("Person created: $name")\n    }\n}\n```\n\n### Visibility Modifiers\n\n- `public` (default) - visible everywhere\n- `private` - visible only inside the class\n- `protected` - visible in class and subclasses\n- `internal` - visible within the same module\n\n### Properties with Custom Accessors\n\n```kotlin\nclass Rectangle(val width: Int, val height: Int) {\n    val area: Int\n        get() = width * height\n    \n    var scale: Double = 1.0\n        set(value) {\n            require(value > 0) { "Scale must be positive" }\n            field = value\n        }\n}\n```\n\n### Open Classes (for Inheritance)\n\nKotlin classes are `final` by default. Use `open` to allow inheritance:\n```kotlin\nopen class Animal(val name: String) {\n    open fun sound() = "..."\n}\n\nclass Dog(name: String) : Animal(name) {\n    override fun sound() = "Woof!"\n}\n```',
    10
);

-- Add runnable examples for the topic
INSERT INTO kotlin_runnable_example (topic_id, tier_level, title, description, code, expected_output, order_index)
VALUES
(
    'what-is-a-class',
    1,
    'Basic Class',
    'Create and use a simple class',
    E'class Person(val name: String, var age: Int)\n\nfun main() {\n    val person = Person("Alice", 25)\n    println("Name: ${person.name}")\n    println("Age: ${person.age}")\n    \n    person.age = 26\n    println("After birthday: ${person.age}")\n}',
    E'Name: Alice\nAge: 25\nAfter birthday: 26',
    1
),
(
    'what-is-a-class',
    2,
    'Class with Methods',
    'Add behavior to your class',
    E'class BankAccount(val owner: String, private var balance: Double = 0.0) {\n    fun deposit(amount: Double) {\n        balance += amount\n        println("Deposited $$amount. New balance: $$balance")\n    }\n    \n    fun withdraw(amount: Double): Boolean {\n        return if (amount <= balance) {\n            balance -= amount\n            println("Withdrew $$amount. New balance: $$balance")\n            true\n        } else {\n            println("Insufficient funds!")\n            false\n        }\n    }\n    \n    fun getBalance() = balance\n}\n\nfun main() {\n    val account = BankAccount("John")\n    account.deposit(100.0)\n    account.withdraw(30.0)\n    account.withdraw(100.0)\n}',
    E'Deposited $100.0. New balance: $100.0\nWithdrew $30.0. New balance: $70.0\nInsufficient funds!',
    2
),
(
    'what-is-a-class',
    3,
    'Inheritance Example',
    'Create class hierarchies',
    E'open class Shape(val name: String) {\n    open fun area(): Double = 0.0\n    open fun describe() = "I am a $name"\n}\n\nclass Circle(val radius: Double) : Shape("Circle") {\n    override fun area() = 3.14159 * radius * radius\n    override fun describe() = "${super.describe()} with radius $radius"\n}\n\nclass Rectangle(val width: Double, val height: Double) : Shape("Rectangle") {\n    override fun area() = width * height\n}\n\nfun main() {\n    val shapes = listOf(\n        Circle(5.0),\n        Rectangle(4.0, 3.0)\n    )\n    \n    for (shape in shapes) {\n        println("${shape.describe()}")\n        println("Area: ${shape.area()}")\n        println()\n    }\n}',
    E'I am a Circle with radius 5.0\nArea: 78.53975\n\nI am a Rectangle\nArea: 12.0',
    3
);

-- =====================================================
-- 7. Add comments for documentation
-- =====================================================

COMMENT ON TABLE kotlin_content_tier IS 'Multi-tier content for topics: TL;DR (1), Beginner (2), Intermediate (3), Deep Dive (4)';
COMMENT ON TABLE kotlin_runnable_example IS 'Code examples that can be run in Kotlin Playground';
COMMENT ON TABLE kotlin_expense_tracker_chapter IS 'Chapters for the Expense Tracker tutorial journey';
COMMENT ON TABLE kotlin_topic_chapter_link IS 'Links topics to expense tracker chapters';
COMMENT ON COLUMN kotlin_topic.content_structure IS 'flat = single explanation, tiered = multi-level content';
COMMENT ON COLUMN kotlin_topic.max_tier_level IS 'Highest tier level available (1-4)';
