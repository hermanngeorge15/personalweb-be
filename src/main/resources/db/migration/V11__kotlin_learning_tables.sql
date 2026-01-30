-- Kotlin Learning Platform Tables

-- Topics table
CREATE TABLE IF NOT EXISTS kotlin_topic (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    module VARCHAR(100) NOT NULL,
    difficulty VARCHAR(20) NOT NULL CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'expert')),
    description TEXT,
    kotlin_explanation TEXT NOT NULL,
    kotlin_code TEXT NOT NULL,
    reading_time_minutes INT DEFAULT 10,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_kotlin_topic_module ON kotlin_topic(module);
CREATE INDEX IF NOT EXISTS idx_kotlin_topic_order ON kotlin_topic(order_index);

-- Code examples for language comparisons
CREATE TABLE IF NOT EXISTS kotlin_code_example (
    id SERIAL PRIMARY KEY,
    topic_id VARCHAR(50) NOT NULL REFERENCES kotlin_topic(id) ON DELETE CASCADE,
    language VARCHAR(20) NOT NULL CHECK (language IN ('java8', 'java11', 'java17', 'java21', 'java25', 'csharp')),
    version_label VARCHAR(100),
    code TEXT NOT NULL,
    explanation TEXT NOT NULL,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_kotlin_code_example_topic ON kotlin_code_example(topic_id);
CREATE INDEX IF NOT EXISTS idx_kotlin_code_example_language ON kotlin_code_example(language);

-- Personal experience boxes
CREATE TABLE IF NOT EXISTS kotlin_experience (
    id SERIAL PRIMARY KEY,
    topic_id VARCHAR(50) NOT NULL REFERENCES kotlin_topic(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    experience_type VARCHAR(50) NOT NULL CHECK (experience_type IN ('story', 'mistake', 'tip', 'opinion', 'warning')),
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_kotlin_experience_topic ON kotlin_experience(topic_id);

-- Documentation links
CREATE TABLE IF NOT EXISTS kotlin_doc_link (
    id SERIAL PRIMARY KEY,
    topic_id VARCHAR(50) NOT NULL REFERENCES kotlin_topic(id) ON DELETE CASCADE,
    link_type VARCHAR(50) NOT NULL CHECK (link_type IN ('kotlin_official', 'java_official', 'csharp_official', 'kotlinprimer', 'other')),
    url TEXT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_kotlin_doc_link_topic ON kotlin_doc_link(topic_id);

-- Topic dependencies for mind map
CREATE TABLE IF NOT EXISTS kotlin_topic_dependency (
    id SERIAL PRIMARY KEY,
    topic_id VARCHAR(50) NOT NULL REFERENCES kotlin_topic(id) ON DELETE CASCADE,
    depends_on_topic_id VARCHAR(50) NOT NULL REFERENCES kotlin_topic(id) ON DELETE CASCADE,
    dependency_type VARCHAR(50) NOT NULL CHECK (dependency_type IN ('prerequisite', 'related', 'next-suggested')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(topic_id, depends_on_topic_id)
);

CREATE INDEX IF NOT EXISTS idx_kotlin_topic_dependency_topic ON kotlin_topic_dependency(topic_id);

-- =====================================================
-- SEED DATA: First Topic - "What is a Class?"
-- =====================================================

INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'what-is-a-class',
    'What is a Class?',
    'OOP Fundamentals',
    'beginner',
    'Learn the fundamentals of classes in Kotlin and how they compare to Java and C#',
    E'A **class** in Kotlin is a blueprint for creating objects. It defines properties (data) and functions (behavior) that objects of that class will have.\n\nKotlin classes are concise by default - no need for explicit getters/setters, and the primary constructor is part of the class header.\n\n## Key Concepts\n\n1. **Primary Constructor** - defined in the class header\n2. **Properties** - declared with `val` (immutable) or `var` (mutable)\n3. **Functions** - define behavior\n4. **Visibility** - `public` by default (unlike Java''s package-private)\n\n## When to Use Classes\n\n- When you need to model real-world entities\n- When you need both data AND behavior together\n- When you need inheritance or polymorphism',
    E'// Kotlin class - concise and powerful\nclass Person(val name: String, var age: Int) {\n    fun greet() = "Hello, I''m $name and I''m $age years old"\n    \n    fun haveBirthday() {\n        age++\n    }\n}\n\n// Usage\nval person = Person("Jiri", 30)\nprintln(person.greet())  // Hello, I''m Jiri and I''m 30 years old\nperson.haveBirthday()\nprintln(person.age)  // 31',
    12,
    1
);

-- Java code examples
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
(
    'what-is-a-class',
    'java8',
    'Java 8-10 (2014-2018)',
    E'// Java 8 - Verbose but familiar\npublic class Person {\n    private final String name;\n    private int age;\n    \n    public Person(String name, int age) {\n        this.name = name;\n        this.age = age;\n    }\n    \n    public String getName() { return name; }\n    public int getAge() { return age; }\n    public void setAge(int age) { this.age = age; }\n    \n    public String greet() {\n        return "Hello, I''m " + name + " and I''m " + age + " years old";\n    }\n    \n    public void haveBirthday() {\n        this.age++;\n    }\n}',
    E'In Java 8, you need to write:\n- Explicit field declarations\n- Constructor with assignments\n- Getters for all fields\n- Setters for mutable fields\n\n**Lines of code:** ~25 vs Kotlin''s ~8\n\n**Pain points:**\n- Boilerplate everywhere\n- Easy to forget `this.` in constructor\n- Getters/setters are noise',
    1
),
(
    'what-is-a-class',
    'java11',
    'Java 11-16 (2018-2021)',
    E'// Java 11 - var for local variables, but classes unchanged\npublic class Person {\n    private final String name;\n    private int age;\n    \n    public Person(String name, int age) {\n        this.name = name;\n        this.age = age;\n    }\n    \n    // Same boilerplate as Java 8...\n    public String getName() { return name; }\n    public int getAge() { return age; }\n    public void setAge(int age) { this.age = age; }\n    \n    public String greet() {\n        return "Hello, I''m " + name + " and I''m " + age + " years old";\n    }\n}\n\n// Only improvement: var for local variables\nvar person = new Person("Jiri", 30);',
    E'Java 11 introduced `var` for local variable type inference, but **class definitions remained unchanged**.\n\nYou still need all the boilerplate from Java 8.\n\n**What''s new:**\n- `var` keyword (local variables only)\n- Some new String methods\n\n**Still missing:**\n- Concise class syntax\n- Properties\n- Primary constructors',
    2
),
(
    'what-is-a-class',
    'java17',
    'Java 17-20 (2021-2023)',
    E'// Java 17 - Records for data, but regular classes still verbose\n// For data-only classes, use records:\npublic record PersonRecord(String name, int age) {}\n\n// But for classes with behavior, still verbose:\npublic class Person {\n    private final String name;\n    private int age;\n    \n    public Person(String name, int age) {\n        this.name = name;\n        this.age = age;\n    }\n    \n    public String name() { return name; }  // Record-style accessor\n    public int age() { return age; }\n    public void setAge(int age) { this.age = age; }\n    \n    public String greet() {\n        return "Hello, I''m " + name + " and I''m " + age + " years old";\n    }\n}',
    E'Java 17 introduced **Records** for data classes, but regular classes with behavior still require boilerplate.\n\n**What''s new:**\n- Records (immutable data carriers)\n- Sealed classes\n- Pattern matching (instanceof)\n\n**Limitation:**\n- Records are immutable only\n- Can''t have mutable fields like `var age`\n- For behavior + mutability, still need verbose classes',
    3
),
(
    'what-is-a-class',
    'java21',
    'Java 21+ (2023+)',
    E'// Java 21 - Still no improvement for regular classes\n// Records work great for data:\npublic record PersonRecord(String name, int age) {\n    // Can add methods\n    public String greet() {\n        return "Hello, I''m " + name + " and I''m " + age + " years old";\n    }\n}\n\n// But for mutable state, still verbose:\npublic class Person {\n    private final String name;\n    private int age;\n    \n    public Person(String name, int age) {\n        this.name = name;\n        this.age = age;\n    }\n    \n    // ... same old boilerplate\n}',
    E'Java 21 added virtual threads and pattern matching improvements, but **regular class syntax remains unchanged** since Java 1.0.\n\n**Kotlin advantage:**\nKotlin classes handle both immutable (`val`) AND mutable (`var`) properties concisely in ONE syntax.\n\nJava forces you to choose:\n- Records = concise but immutable only\n- Classes = flexible but verbose',
    4
);

-- C# code example
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES (
    'what-is-a-class',
    'csharp',
    'C# 10+ (2021+)',
    E'// C# - Modern and concise (similar to Kotlin!)\npublic class Person\n{\n    public string Name { get; }\n    public int Age { get; set; }\n    \n    public Person(string name, int age)\n    {\n        Name = name;\n        Age = age;\n    }\n    \n    public string Greet() => $"Hello, I''m {Name} and I''m {Age} years old";\n    \n    public void HaveBirthday() => Age++;\n}\n\n// Or with primary constructor (C# 12):\npublic class Person(string name, int age)\n{\n    public string Name { get; } = name;\n    public int Age { get; set; } = age;\n    \n    public string Greet() => $"Hello, I''m {Name} and I''m {Age} years old";\n}',
    E'C# is **very similar** to Kotlin! Both learned from Java''s verbosity.\n\n**Similarities:**\n- Auto-implemented properties\n- String interpolation ($"...")\n- Expression-bodied members (=>)\n- Primary constructors (C# 12)\n\n**Differences:**\n- C#: `{ get; set; }` vs Kotlin: `var`\n- C#: `{ get; }` vs Kotlin: `val`\n- C#: PascalCase vs Kotlin: camelCase\n- C# properties still need explicit syntax\n\n**Coming from C#:** You''ll feel right at home with Kotlin!',
    5
);

-- Personal experiences
INSERT INTO kotlin_experience (topic_id, title, content, experience_type, order_index)
VALUES
(
    'what-is-a-class',
    'My First Kotlin Class',
    E'When I wrote my first Kotlin class after 8 years of Java, I kept looking for the "Generate Getters/Setters" menu in IntelliJ.\n\nThen I realized: there''s nothing to generate. The 3-line Kotlin class WAS the complete implementation.\n\nThat moment changed how I think about code. Less ceremony = more focus on actual logic.',
    'story',
    1
),
(
    'what-is-a-class',
    'The Public Default Gotcha',
    E'**Mistake I made:** Assumed Kotlin classes were package-private like Java.\n\nIn Java: `class Foo` is package-private\nIn Kotlin: `class Foo` is PUBLIC\n\nThis bit me when I accidentally exposed an internal class in a library API. Always use `internal` or `private` explicitly when you don''t want public access.',
    'mistake',
    2
),
(
    'what-is-a-class',
    'When to Use Class vs Data Class',
    E'**My rule of thumb:**\n\nUse `class` when:\n- Primary purpose is BEHAVIOR (methods)\n- Has mutable state with business logic\n- Needs inheritance\n\nUse `data class` when:\n- Primary purpose is holding DATA\n- Need equals/hashCode/copy\n- Mostly immutable\n\nStill unsure? Ask: "Can I describe this in one sentence without mentioning methods?" -> data class',
    'tip',
    3
);

-- Documentation links
INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, description, order_index)
VALUES
(
    'what-is-a-class',
    'kotlin_official',
    'https://kotlinlang.org/docs/classes.html',
    'Classes - Kotlin Documentation',
    'Official Kotlin documentation on classes and inheritance',
    1
),
(
    'what-is-a-class',
    'java_official',
    'https://docs.oracle.com/javase/tutorial/java/javaOO/classes.html',
    'Classes - Java Tutorials',
    'Oracle Java tutorial on defining classes',
    2
),
(
    'what-is-a-class',
    'csharp_official',
    'https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/types/classes',
    'Classes - C# Documentation',
    'Microsoft C# documentation on classes',
    3
),
(
    'what-is-a-class',
    'kotlinprimer',
    'https://www.kotlinprimer.com/classes-what-kotlin-brings-to-the-table/',
    'Classes: What Kotlin Brings to the Table',
    'KotlinPrimer deep dive on Kotlin classes',
    4
);
