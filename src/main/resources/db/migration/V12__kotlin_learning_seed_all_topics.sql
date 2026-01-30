-- =====================================================
-- SEED DATA: All Kotlin Learning Topics (2-24)
-- =====================================================

-- =====================================================
-- Topic 2: What is an Instance?
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'what-is-an-instance',
    'What is an Instance?',
    'Classes & Objects Fundamentals',
    'beginner',
    'Understand the difference between classes (blueprints) and instances (objects) in Kotlin',
    E'An **instance** (or object) is a concrete realization of a class. The class is the blueprint; the instance is the actual house built from that blueprint.\n\n## Key Concepts\n\n1. **Class** = Blueprint/Template\n2. **Instance** = Actual object created from class\n3. **Constructor** = Function that creates instances\n4. **Reference** = Variable pointing to an instance\n\n## Memory Model\n\nEach instance has its own:\n- Memory allocation\n- Property values\n- Identity (memory address)',
    E'class Car(val brand: String, var speed: Int = 0) {\n    fun accelerate() { speed += 10 }\n}\n\n// Creating instances\nval car1 = Car("Toyota")    // Instance 1\nval car2 = Car("Honda")     // Instance 2\nval car3 = car1             // Same instance as car1!\n\ncar1.accelerate()\nprintln(car1.speed)  // 10\nprintln(car2.speed)  // 0 - different instance\nprintln(car3.speed)  // 10 - same instance as car1\n\n// Identity check\nprintln(car1 === car3)  // true - same instance\nprintln(car1 === car2)  // false - different instances',
    8,
    2
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('what-is-an-instance', 'java8', 'Java 8+', E'// Java - same concept, different syntax\nCar car1 = new Car("Toyota");  // ''new'' keyword required\nCar car2 = new Car("Honda");\n\n// Reference check\nSystem.out.println(car1 == car2);  // false (identity)\nSystem.out.println(car1.equals(car2));  // depends on equals()', E'Java requires the `new` keyword to create instances.\n\nKotlin dropped `new` because:\n- Constructor calls are already distinguishable (PascalCase)\n- Less noise in code\n- Constructor is just a function that returns an object', 1),
('what-is-an-instance', 'csharp', 'C# 10+', E'// C# - similar to Java\nvar car1 = new Car("Toyota");  // ''new'' required\nCar car2 = new("Honda");       // Target-typed new (C# 9+)\n\n// Reference equality\nConsole.WriteLine(car1 == car2);           // false\nConsole.WriteLine(ReferenceEquals(car1, car2)); // false', E'C# also requires `new` but introduced target-typed `new()` in C# 9.\n\nKotlin''s approach is cleaner - no keyword needed at all.', 2);

INSERT INTO kotlin_experience (topic_id, title, content, experience_type, order_index) VALUES
('what-is-an-instance', 'Reference vs Value Confusion', E'Early in my Kotlin journey, I made this mistake:\n\n```kotlin\nval user1 = User("John")\nval user2 = user1\nuser2.name = "Jane"  // Oops - user1.name is also "Jane"!\n```\n\nRemember: variables hold REFERENCES to objects, not copies. Use `.copy()` on data classes for true copies.', 'mistake', 1),
('what-is-an-instance', '=== vs == in Kotlin', E'Kotlin has two equality operators:\n\n- `==` structural equality (calls equals())\n- `===` referential equality (same instance)\n\n```kotlin\nval a = User("John")\nval b = User("John")\na == b   // true if data class\na === b  // false - different instances\n```', 'tip', 2);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('what-is-an-instance', 'kotlin_official', 'https://kotlinlang.org/docs/classes.html#creating-instances-of-classes', 'Creating Instances - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('what-is-an-instance', 'what-is-a-class', 'prerequisite');

-- =====================================================
-- Topic 3: Constructors
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'constructors',
    'Constructors',
    'Classes & Objects Fundamentals',
    'beginner',
    'Master primary and secondary constructors in Kotlin',
    E'Kotlin has two types of constructors: **primary** (in class header) and **secondary** (in class body).\n\n## Primary Constructor\n\n- Part of class header\n- Most concise way to define properties\n- Can have default values\n\n## Secondary Constructor\n\n- Defined in class body with `constructor` keyword\n- Must delegate to primary constructor\n- Use for alternative initialization paths',
    E'// Primary constructor with properties\nclass User(val name: String, var age: Int = 0) {\n    init {\n        println("User created: $name")\n    }\n}\n\n// Secondary constructors\nclass Person {\n    val name: String\n    var age: Int\n    \n    constructor(name: String) : this(name, 0)\n    \n    constructor(name: String, age: Int) {\n        this.name = name\n        this.age = age\n    }\n}\n\n// Usage\nval user = User("John", 25)\nval person1 = Person("Jane")\nval person2 = Person("Bob", 30)',
    10,
    3
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('constructors', 'java8', 'Java 8+', E'// Java - only secondary constructors\npublic class User {\n    private final String name;\n    private int age;\n    \n    public User(String name) {\n        this(name, 0);\n    }\n    \n    public User(String name, int age) {\n        this.name = name;\n        this.age = age;\n    }\n}', E'Java only has what Kotlin calls secondary constructors.\n\nKotlin''s primary constructor:\n- Eliminates field declarations\n- Eliminates constructor body assignments\n- Supports default parameter values', 1),
('constructors', 'csharp', 'C# 12+', E'// C# 12 - Primary constructors!\npublic class User(string name, int age = 0)\n{\n    public string Name { get; } = name;\n    public int Age { get; set; } = age;\n}\n\n// Before C# 12\npublic class User\n{\n    public string Name { get; }\n    public int Age { get; set; }\n    \n    public User(string name, int age = 0)\n    {\n        Name = name;\n        Age = age;\n    }\n}', E'C# 12 added primary constructors, inspired by languages like Kotlin!\n\nThe syntax is very similar now.', 2);

INSERT INTO kotlin_experience (topic_id, title, content, experience_type, order_index) VALUES
('constructors', 'Prefer Primary Constructors', E'After years of Kotlin, I rarely use secondary constructors.\n\nInstead:\n- Use default parameter values\n- Use factory methods in companion object\n- Use builder pattern for complex objects\n\nSecondary constructors are mainly for Java interop.', 'tip', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('constructors', 'kotlin_official', 'https://kotlinlang.org/docs/classes.html#constructors', 'Constructors - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('constructors', 'what-is-an-instance', 'prerequisite');

-- =====================================================
-- Topic 4: Understanding OOP in Kotlin
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'understanding-oop-in-kotlin',
    'Understanding OOP in Kotlin',
    'Classes & Objects Fundamentals',
    'beginner',
    'Learn how Kotlin implements the four pillars of OOP',
    E'Kotlin is a **multi-paradigm language** supporting both OOP and functional programming.\n\n## Four Pillars of OOP\n\n1. **Encapsulation** - Hide internal state, expose through methods\n2. **Inheritance** - Classes are final by default (use `open`)\n3. **Polymorphism** - Same interface, different implementations\n4. **Abstraction** - Abstract classes and interfaces\n\n## Kotlin''s Philosophy\n\n- Favor composition over inheritance\n- Classes are final by default\n- Properties instead of fields + getters/setters',
    E'// Encapsulation\nclass BankAccount(private var balance: Double) {\n    fun deposit(amount: Double) {\n        require(amount > 0)\n        balance += amount\n    }\n    fun getBalance() = balance\n}\n\n// Inheritance (explicit ''open'')\nopen class Animal(val name: String) {\n    open fun makeSound() = "..."\n}\n\nclass Dog(name: String) : Animal(name) {\n    override fun makeSound() = "Woof!"\n}\n\n// Polymorphism\nfun printSound(animal: Animal) {\n    println(animal.makeSound())\n}\n\nprintSound(Dog("Rex"))  // "Woof!"',
    10,
    4
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('understanding-oop-in-kotlin', 'java8', 'Java 8+', E'// Java - classes open by default\npublic class Animal {\n    private final String name;\n    \n    public Animal(String name) {\n        this.name = name;\n    }\n    \n    public String makeSound() {\n        return "...";\n    }\n}\n\npublic class Dog extends Animal {\n    public Dog(String name) {\n        super(name);\n    }\n    \n    @Override\n    public String makeSound() {\n        return "Woof!";\n    }\n}', E'Key difference: Java classes are **open by default**, Kotlin classes are **final by default**.\n\nKotlin requires explicit `open` to allow inheritance.\nJava requires explicit `final` to prevent it.', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('understanding-oop-in-kotlin', 'kotlin_official', 'https://kotlinlang.org/docs/inheritance.html', 'Inheritance - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('understanding-oop-in-kotlin', 'constructors', 'prerequisite');

-- =====================================================
-- Topic 5: Data Classes
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'data-classes',
    'Data Classes',
    'Class Types & Data Modeling',
    'beginner',
    'Create classes that are primarily used to hold data with automatic equals, hashCode, and copy',
    E'**Data classes** automatically generate:\n\n1. `equals()` / `hashCode()` - based on constructor properties\n2. `toString()` - readable representation\n3. `copy()` - create modified copies\n4. `componentN()` - for destructuring\n\n## Requirements\n\n- Primary constructor with at least one parameter\n- All primary constructor parameters must be `val` or `var`\n- Cannot be abstract, open, sealed, or inner',
    E'data class User(\n    val id: Long,\n    val name: String,\n    val email: String\n)\n\n// Auto-generated goodies:\nval user1 = User(1, "John", "john@example.com")\nval user2 = User(1, "John", "john@example.com")\n\nprintln(user1 == user2)      // true (equals)\nprintln(user1)               // User(id=1, name=John, email=john@example.com)\n\n// copy() for immutable updates\nval user3 = user1.copy(name = "Jane")\n\n// Destructuring\nval (id, name, email) = user1',
    12,
    5
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('data-classes', 'java17', 'Java 17+ Records', E'// Java 17+ - Records (similar but immutable only)\npublic record User(long id, String name, String email) {}\n\n// Usage\nvar user1 = new User(1, "John", "john@example.com");\nvar user2 = new User(1, "John", "john@example.com");\nSystem.out.println(user1.equals(user2));  // true\n\n// No copy() - must create new instance\nvar user3 = new User(user1.id(), "Jane", user1.email());', E'Java Records are **immutable only** (all fields final).\n\nKotlin data classes support both `val` and `var`.\n\nKotlin also has `copy()` which Java Records lack.', 1),
('data-classes', 'csharp', 'C# 10+', E'// C# - Records (very similar!)\npublic record User(long Id, string Name, string Email);\n\n// Usage\nvar user1 = new User(1, "John", "john@example.com");\nvar user2 = new User(1, "John", "john@example.com");\nConsole.WriteLine(user1 == user2);  // true\n\n// with expression for copies\nvar user3 = user1 with { Name = "Jane" };', E'C# records are very similar to Kotlin data classes!\n\nC# uses `with { }` expression instead of `copy()`.\n\nC# also has `record struct` for value types.', 2);

INSERT INTO kotlin_experience (topic_id, title, content, experience_type, order_index) VALUES
('data-classes', 'DTOs Should Be Data Classes', E'Rule: If a class exists primarily to carry data (DTO, entity, request/response), make it a data class.\n\nBenefits:\n- Free equals() for testing\n- Free toString() for logging\n- Free copy() for immutable patterns', 'tip', 1),
('data-classes', 'Properties Outside Constructor', E'Only constructor properties are used in equals/hashCode:\n\n```kotlin\ndata class User(val id: Long) {\n    var loginCount: Int = 0  // NOT in equals!\n}\n\nval u1 = User(1).apply { loginCount = 5 }\nval u2 = User(1).apply { loginCount = 10 }\nu1 == u2  // true! loginCount ignored\n```', 'warning', 2);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('data-classes', 'kotlin_official', 'https://kotlinlang.org/docs/data-classes.html', 'Data Classes - Kotlin Docs', 1),
('data-classes', 'kotlinprimer', 'https://www.kotlinprimer.com/classes-what-kotlin-brings-to-the-table/data-classes/', 'Data Classes - KotlinPrimer', 2);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('data-classes', 'understanding-oop-in-kotlin', 'prerequisite');

-- =====================================================
-- Topic 6: Regular Classes
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'regular-classes',
    'Regular Classes',
    'Class Types & Data Modeling',
    'beginner',
    'When to use regular classes instead of data classes',
    E'**Regular classes** are for objects with:\n\n- Significant behavior (methods)\n- Mutable internal state with business logic\n- Identity-based equality (not data-based)\n- Need for inheritance\n\n## Regular vs Data Class\n\n| Feature | Regular Class | Data Class |\n|---------|---------------|------------|\n| Purpose | Behavior | Data holding |\n| equals() | Identity | Structural |\n| Mutable state | Encapsulated | Exposed |\n| Inheritance | Can extend | Cannot extend |',
    E'// Regular class - behavior focused\nclass ShoppingCart {\n    private val _items = mutableListOf<Item>()\n    val items: List<Item> get() = _items\n    \n    fun addItem(item: Item) {\n        _items.add(item)\n    }\n    \n    fun removeItem(item: Item) {\n        _items.remove(item)\n    }\n    \n    val total: Double\n        get() = _items.sumOf { it.price }\n}\n\n// Usage\nval cart = ShoppingCart()\ncart.addItem(Item("Book", 29.99))\nprintln(cart.total)  // 29.99',
    10,
    6
);

INSERT INTO kotlin_experience (topic_id, title, content, experience_type, order_index) VALUES
('regular-classes', 'Decision Tree', E'Use `data class` when:\n- Primary purpose is holding data\n- Need equals/hashCode based on content\n- Need copy() functionality\n\nUse `class` when:\n- Primary purpose is behavior\n- Identity matters more than content\n- Has complex mutable state', 'tip', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('regular-classes', 'kotlin_official', 'https://kotlinlang.org/docs/classes.html', 'Classes - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('regular-classes', 'data-classes', 'prerequisite');

-- =====================================================
-- Topic 7: Objects & Singletons
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'objects-singletons',
    'Objects & Singletons',
    'Class Types & Data Modeling',
    'intermediate',
    'Create singletons with object declarations and expressions',
    E'Kotlin''s `object` keyword creates singletons with guaranteed single instance.\n\n## Object Declarations\n\n- Single instance created lazily\n- Thread-safe initialization\n- Can implement interfaces\n- Can extend classes\n\n## Object Expressions\n\n- Anonymous objects (like Java''s anonymous classes)\n- Can access enclosing scope',
    E'// Singleton object\nobject DatabaseConfig {\n    val url = "jdbc:postgresql://localhost/db"\n    val maxConnections = 10\n    \n    fun connect() = println("Connecting to $url")\n}\n\n// Usage - no instantiation needed\nDatabaseConfig.connect()\nprintln(DatabaseConfig.maxConnections)\n\n// Object expression (anonymous)\nval comparator = object : Comparator<Int> {\n    override fun compare(a: Int, b: Int) = b - a\n}\n\nlistOf(1, 3, 2).sortedWith(comparator)  // [3, 2, 1]',
    10,
    7
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('objects-singletons', 'java8', 'Java Singleton', E'// Java - manual singleton pattern\npublic class DatabaseConfig {\n    private static final DatabaseConfig INSTANCE = new DatabaseConfig();\n    \n    private DatabaseConfig() {}\n    \n    public static DatabaseConfig getInstance() {\n        return INSTANCE;\n    }\n    \n    private final String url = "jdbc:postgresql://localhost/db";\n    \n    public void connect() {\n        System.out.println("Connecting to " + url);\n    }\n}\n\n// Usage\nDatabaseConfig.getInstance().connect();', E'Java requires manual singleton implementation.\n\nKotlin''s `object` keyword does this automatically with thread-safe lazy initialization.', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('objects-singletons', 'kotlin_official', 'https://kotlinlang.org/docs/object-declarations.html', 'Object Declarations - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('objects-singletons', 'regular-classes', 'prerequisite');

-- =====================================================
-- Topic 8: Companion Objects
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'companion-objects',
    'Companion Objects',
    'Class Types & Data Modeling',
    'intermediate',
    'Implement factory methods and class-level members with companion objects',
    E'**Companion objects** provide class-level members (like Java''s static) while being real objects.\n\n## Features\n\n- Accessed via class name\n- Can implement interfaces\n- Can have extension functions\n- Can be named\n\n## Common Uses\n\n- Factory methods\n- Constants\n- Shared utilities',
    E'class User private constructor(val name: String) {\n    companion object Factory {\n        fun create(name: String): User {\n            println("Creating user: $name")\n            return User(name)\n        }\n        \n        const val MAX_NAME_LENGTH = 50\n    }\n}\n\n// Usage\nval user = User.create("John")\nprintln(User.MAX_NAME_LENGTH)\n\n// Companion implementing interface\ninterface Factory<T> {\n    fun create(): T\n}\n\nclass MyClass private constructor() {\n    companion object : Factory<MyClass> {\n        override fun create() = MyClass()\n    }\n}',
    12,
    8
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('companion-objects', 'java8', 'Java Static', E'// Java - static members\npublic class User {\n    private static final int MAX_NAME_LENGTH = 50;\n    \n    public static User create(String name) {\n        return new User(name);\n    }\n    \n    // Static cannot implement interfaces!\n}', E'Java''s static members:\n- Cannot implement interfaces\n- Cannot be passed as parameters\n- Cannot have extension functions\n\nKotlin''s companion objects are actual objects!', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('companion-objects', 'kotlin_official', 'https://kotlinlang.org/docs/object-declarations.html#companion-objects', 'Companion Objects - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('companion-objects', 'objects-singletons', 'prerequisite');

-- =====================================================
-- Topic 9: Sealed Classes
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'sealed-classes',
    'Sealed Classes',
    'Class Types & Data Modeling',
    'intermediate',
    'Create restricted class hierarchies for exhaustive when expressions',
    E'**Sealed classes** restrict which classes can inherit from them.\n\n## Benefits\n\n- Compiler knows ALL possible subclasses\n- Exhaustive `when` expressions (no `else` needed)\n- Perfect for state machines, results, UI states\n\n## Rules\n\n- Subclasses must be in same package\n- Can be `data class`, `object`, or regular `class`',
    E'sealed class Result<out T> {\n    data class Success<T>(val data: T) : Result<T>()\n    data class Error(val message: String) : Result<Nothing>()\n    data object Loading : Result<Nothing>()\n}\n\n// Exhaustive when - no else needed!\nfun handleResult(result: Result<String>) = when (result) {\n    is Result.Success -> "Data: ${result.data}"\n    is Result.Error -> "Error: ${result.message}"\n    Result.Loading -> "Loading..."\n    // Compiler verifies all cases covered!\n}',
    15,
    9
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('sealed-classes', 'java17', 'Java 17+ Sealed', E'// Java 17 - Sealed classes\npublic sealed class Result<T> permits Success, Error, Loading {}\n\npublic final class Success<T> extends Result<T> {\n    private final T data;\n    public Success(T data) { this.data = data; }\n    public T getData() { return data; }\n}\n\npublic final class Error<T> extends Result<T> {\n    private final String message;\n    // ...\n}\n\npublic final class Loading<T> extends Result<T> {}', E'Java 17 added sealed classes!\n\nDifferences:\n- Java requires `permits` clause\n- Java is more verbose\n- Java 21 has exhaustive switch', 1);

INSERT INTO kotlin_experience (topic_id, title, content, experience_type, order_index) VALUES
('sealed-classes', 'Eliminating Runtime Errors', E'After migrating to sealed classes, we found all 47 places that needed updating when a new state was added. The compiler did the work!\n\nPreviously with open classes, we had `else` clauses throwing exceptions that only crashed in production.', 'story', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('sealed-classes', 'kotlin_official', 'https://kotlinlang.org/docs/sealed-classes.html', 'Sealed Classes - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('sealed-classes', 'data-classes', 'prerequisite');

-- =====================================================
-- Topic 10: Variables - val vs var
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'variables-val-vs-var',
    'Variables: val vs var',
    'Variables & Properties',
    'beginner',
    'Understand immutable (val) and mutable (var) variable declarations',
    E'Kotlin distinguishes between immutable and mutable variables at declaration.\n\n## val - Immutable\n\n- Cannot be reassigned\n- Like Java''s `final`\n- Preferred by default\n\n## var - Mutable\n\n- Can be reassigned\n- Use only when needed\n\n## Type Inference\n\nKotlin infers types, but you can be explicit.',
    E'// val - immutable (preferred)\nval name = "John"        // Type inferred: String\nval age: Int = 25        // Explicit type\n// name = "Jane"         // Error! Cannot reassign val\n\n// var - mutable\nvar counter = 0\ncounter = 1              // OK\ncounter++                // OK\n\n// val doesn''t mean deeply immutable!\nval list = mutableListOf(1, 2, 3)\nlist.add(4)              // OK - list itself unchanged\n// list = mutableListOf() // Error! Cannot reassign',
    8,
    10
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('variables-val-vs-var', 'java11', 'Java 11+', E'// Java - final keyword\nfinal String name = "John";  // Immutable reference\nint counter = 0;             // Mutable\n\n// Type inference with var (Java 10+)\nvar message = "Hello";       // Inferred String\nfinal var id = 123;          // Immutable + inferred', E'Java''s `var` is different from Kotlin!\n\nJava `var` = type inference only\nKotlin `var` = mutable variable\n\nKotlin equivalent of Java''s `var`: just `val` or `var` with type inference', 1);

INSERT INTO kotlin_experience (topic_id, title, content, experience_type, order_index) VALUES
('variables-val-vs-var', 'Default to val', E'My rule: Always start with `val`. Only change to `var` when the compiler complains.\n\nImmutability:\n- Prevents bugs\n- Enables safer concurrency\n- Makes code easier to reason about', 'tip', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('variables-val-vs-var', 'kotlin_official', 'https://kotlinlang.org/docs/basic-syntax.html#variables', 'Variables - Kotlin Docs', 1);

-- =====================================================
-- Topic 11: Properties
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'properties',
    'Properties',
    'Variables & Properties',
    'intermediate',
    'Master property syntax with custom getters, setters, and backing fields',
    E'**Properties** combine fields and accessors into a single concept.\n\n## Features\n\n- Custom getters and setters\n- Backing field (`field`)\n- Backing properties (private _property)\n- Computed properties\n- `lateinit` and `lazy`',
    E'class User {\n    // Auto-generated getter/setter\n    var name: String = ""\n    \n    // Custom setter\n    var email: String = ""\n        set(value) {\n            field = value.lowercase()\n        }\n    \n    // Computed property (no backing field)\n    val isValid: Boolean\n        get() = name.isNotBlank() && email.contains("@")\n    \n    // Private setter\n    var loginCount: Int = 0\n        private set\n    \n    fun login() { loginCount++ }\n}',
    14,
    11
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('properties', 'java8', 'Java', E'// Java - manual getters/setters\npublic class User {\n    private String name = "";\n    private String email = "";\n    private int loginCount = 0;\n    \n    public String getName() { return name; }\n    public void setName(String name) { this.name = name; }\n    \n    public String getEmail() { return email; }\n    public void setEmail(String email) {\n        this.email = email.toLowerCase();\n    }\n    \n    public boolean isValid() {\n        return !name.isBlank() && email.contains("@");\n    }\n    \n    public int getLoginCount() { return loginCount; }\n    // No setter = private\n}', E'Java requires explicit getter/setter methods.\n\nKotlin properties:\n- Less boilerplate\n- More readable\n- Same bytecode', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('properties', 'kotlin_official', 'https://kotlinlang.org/docs/properties.html', 'Properties - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('properties', 'variables-val-vs-var', 'prerequisite');

-- =====================================================
-- Topic 12: Nullability
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'nullability',
    'Nullability',
    'Variables & Properties',
    'beginner',
    'Handle null safely with Kotlin''s type system',
    E'Kotlin''s type system distinguishes nullable from non-nullable types.\n\n## Nullable Types\n\n- Add `?` to type: `String?`\n- Can be `null`\n- Requires safe handling\n\n## Safe Operators\n\n- `?.` safe call\n- `?:` Elvis operator\n- `!!` not-null assertion (avoid!)',
    E'// Non-nullable - cannot be null\nval name: String = "John"\n// name = null  // Error!\n\n// Nullable - can be null\nvar email: String? = "john@example.com"\nemail = null  // OK\n\n// Safe call\nprintln(email?.length)  // null (not NPE!)\n\n// Elvis operator\nval length = email?.length ?: 0\n\n// Smart cast\nif (email != null) {\n    println(email.length)  // Smart cast to String\n}\n\n// let for scoped null check\nemail?.let { \n    println("Email is: $it")\n}',
    15,
    12
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('nullability', 'java8', 'Java Optional', E'// Java - Optional (verbose)\nOptional<String> email = Optional.of("john@example.com");\n\n// Safe access\nint length = email.map(String::length).orElse(0);\n\n// Check and use\nemail.ifPresent(e -> System.out.println("Email: " + e));\n\n// Or null checks everywhere\nString e = getEmail();\nif (e != null) {\n    System.out.println(e.length());\n}', E'Java''s approach:\n- Optional for explicit nullable (verbose)\n- Null checks everywhere\n- NPEs at runtime\n\nKotlin: Nullability in type system, compile-time safety', 1);

INSERT INTO kotlin_experience (topic_id, title, content, experience_type, order_index) VALUES
('nullability', 'Avoid !! Operator', E'The `!!` operator defeats null safety:\n\n```kotlin\nval name: String = nullableName!!  // Throws NPE if null\n```\n\nInstead use:\n- `?.` with `?:`\n- `let`\n- Smart casts with `if`\n- `requireNotNull()` with message', 'warning', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('nullability', 'kotlin_official', 'https://kotlinlang.org/docs/null-safety.html', 'Null Safety - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('nullability', 'variables-val-vs-var', 'prerequisite');

-- =====================================================
-- Topic 13: Late Initialization
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'late-initialization',
    'Late Initialization',
    'Variables & Properties',
    'intermediate',
    'Use lateinit and lazy for deferred property initialization',
    E'For properties that can''t be initialized in constructor.\n\n## lateinit\n\n- For `var` only\n- Non-null types only\n- Not for primitives\n- Use for DI, testing\n\n## lazy\n\n- For `val` only\n- Computed on first access\n- Thread-safe by default\n- Cached after first computation',
    E'class Service {\n    // lateinit - set later\n    lateinit var repository: Repository\n    \n    // lazy - computed on first access\n    val config: Config by lazy {\n        println("Loading config...")\n        loadConfig()\n    }\n    \n    fun init(repo: Repository) {\n        repository = repo\n    }\n    \n    fun doWork() {\n        // Check if initialized\n        if (::repository.isInitialized) {\n            repository.save(data)\n        }\n    }\n}',
    10,
    13
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('late-initialization', 'java8', 'Java', E'// Java - no lateinit\nprivate Repository repository;  // null until set\n\npublic void setRepository(Repository repo) {\n    this.repository = repo;\n}\n\n// Must null-check everywhere\nif (repository != null) {\n    repository.save(data);\n}', E'Kotlin''s `lateinit` avoids null checks while ensuring initialization.\n\n`lazy` provides thread-safe lazy initialization built into the language.', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('late-initialization', 'kotlin_official', 'https://kotlinlang.org/docs/properties.html#late-initialized-properties-and-variables', 'Late-Initialized Properties - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('late-initialization', 'nullability', 'prerequisite');

-- =====================================================
-- Topic 14: Functions Basics
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'functions-basics',
    'Functions Basics',
    'Functions',
    'beginner',
    'Learn Kotlin function syntax with default and named parameters',
    E'Functions in Kotlin are declared with `fun` keyword.\n\n## Features\n\n- Default parameter values\n- Named arguments\n- Single-expression functions\n- Unit return type (like void)\n- Local functions',
    E'// Basic function\nfun greet(name: String): String {\n    return "Hello, $name!"\n}\n\n// Single-expression\nfun greet(name: String) = "Hello, $name!"\n\n// Default parameters\nfun greet(name: String, greeting: String = "Hello") = \n    "$greeting, $name!"\n\n// Named arguments\nfun createUser(\n    name: String,\n    age: Int = 0,\n    email: String = ""\n): User = User(name, age, email)\n\nval user = createUser(\n    name = "John",\n    email = "john@example.com"\n    // age uses default\n)',
    12,
    14
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('functions-basics', 'java8', 'Java', E'// Java - no default parameters\npublic String greet(String name) {\n    return greet(name, "Hello");\n}\n\npublic String greet(String name, String greeting) {\n    return greeting + ", " + name + "!";\n}\n\n// No named arguments\nUser user = createUser("John", 0, "john@example.com");\n// What does 0 mean? Age? Score?', E'Java workarounds:\n- Method overloading (multiple methods)\n- Builder pattern\n- No named arguments = unclear code', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('functions-basics', 'kotlin_official', 'https://kotlinlang.org/docs/functions.html', 'Functions - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('functions-basics', 'variables-val-vs-var', 'prerequisite');

-- =====================================================
-- Topic 15: Extension Functions
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'extension-functions',
    'Extension Functions',
    'Functions',
    'intermediate',
    'Add new functions to existing classes without inheritance',
    E'**Extension functions** let you add methods to existing classes.\n\n## Features\n\n- Add functionality to any class\n- Even final classes, even Java classes\n- Resolved statically (not runtime polymorphism)\n- Cannot access private members\n\n## Use Cases\n\n- Utility functions\n- DSLs\n- Cleaner APIs',
    E'// Extension function on String\nfun String.addExclamation() = "$this!"\n\nprintln("Hello".addExclamation())  // "Hello!"\n\n// Extension on nullable type\nfun String?.orEmpty() = this ?: ""\n\nval name: String? = null\nprintln(name.orEmpty())  // ""\n\n// Extension property\nval String.lastChar: Char\n    get() = this[length - 1]\n\nprintln("Kotlin".lastChar)  // "n"\n\n// Extension on generic type\nfun <T> List<T>.secondOrNull(): T? = \n    if (size >= 2) this[1] else null',
    12,
    15
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('extension-functions', 'java8', 'Java', E'// Java - utility classes\npublic class StringUtils {\n    public static String addExclamation(String s) {\n        return s + "!";\n    }\n}\n\n// Usage\nStringUtils.addExclamation("Hello");  // Ugly', E'Java requires utility classes with static methods.\n\nKotlin extensions:\n- Read naturally: `"Hello".addExclamation()`\n- IDE auto-completion works\n- No utility class pollution', 1),
('extension-functions', 'csharp', 'C#', E'// C# - extension methods (similar!)\npublic static class StringExtensions\n{\n    public static string AddExclamation(this string s)\n    {\n        return s + "!";\n    }\n}\n\n// Usage\n"Hello".AddExclamation();', E'C# also has extension methods!\n\nDifferences:\n- C# requires `this` in parameter\n- C# requires static class\n- Kotlin syntax is cleaner', 2);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('extension-functions', 'kotlin_official', 'https://kotlinlang.org/docs/extensions.html', 'Extensions - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('extension-functions', 'functions-basics', 'prerequisite');

-- =====================================================
-- Topic 16: Higher-Order Functions
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'higher-order-functions',
    'Higher-Order Functions',
    'Functions',
    'intermediate',
    'Functions that take functions as parameters or return functions',
    E'**Higher-order functions** take functions as parameters or return functions.\n\n## Lambda Syntax\n\n- `{ params -> body }`\n- Single parameter: use `it`\n- Trailing lambda outside parentheses\n\n## Common Operations\n\n- `map`, `filter`, `reduce`\n- `forEach`, `find`, `any/all/none`',
    E'// Function taking function parameter\nfun operate(a: Int, b: Int, op: (Int, Int) -> Int): Int {\n    return op(a, b)\n}\n\nval sum = operate(5, 3) { x, y -> x + y }  // 8\n\n// Lambda with single parameter\nval numbers = listOf(1, 2, 3, 4, 5)\nnumbers.filter { it > 2 }  // [3, 4, 5]\nnumbers.map { it * 2 }     // [2, 4, 6, 8, 10]\n\n// Function returning function\nfun multiplier(factor: Int): (Int) -> Int {\n    return { number -> number * factor }\n}\n\nval double = multiplier(2)\ndouble(5)  // 10',
    18,
    16
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('higher-order-functions', 'java8', 'Java 8+', E'// Java - functional interfaces\nList<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);\n\nList<Integer> filtered = numbers.stream()\n    .filter(n -> n > 2)\n    .collect(Collectors.toList());\n\nList<Integer> doubled = numbers.stream()\n    .map(n -> n * 2)\n    .collect(Collectors.toList());', E'Java requires:\n- `.stream()` and `.collect()`\n- Functional interfaces\n- No trailing lambda syntax\n\nKotlin is more concise.', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('higher-order-functions', 'kotlin_official', 'https://kotlinlang.org/docs/lambdas.html', 'Higher-Order Functions - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('higher-order-functions', 'functions-basics', 'prerequisite');

-- =====================================================
-- Topic 17: Scope Functions
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'scope-functions',
    'Scope Functions',
    'Functions',
    'intermediate',
    'Master let, run, with, apply, and also for cleaner code',
    E'**Scope functions** execute code blocks on objects.\n\n## Quick Reference\n\n| Function | Context | Returns | Use case |\n|----------|---------|---------|----------|\n| `let` | `it` | Lambda result | Null checks, transformations |\n| `run` | `this` | Lambda result | Object configuration + result |\n| `with` | `this` | Lambda result | Group calls on object |\n| `apply` | `this` | Object | Object configuration |\n| `also` | `it` | Object | Side effects |',
    E'val user = User("John", "john@example.com")\n\n// let - transform and null safety\nval length = user.name?.let { it.length } ?: 0\n\n// apply - configure object\nval config = Config().apply {\n    host = "localhost"\n    port = 8080\n}\n\n// also - side effects\nval result = user.also { \n    println("Processing: ${it.name}")\n}\n\n// run - compute with context\nval greeting = user.run {\n    "Hello, $name!"\n}\n\n// with - group operations\nwith(StringBuilder()) {\n    append("Hello")\n    append(" ")\n    append("World")\n    toString()\n}',
    15,
    17
);

INSERT INTO kotlin_experience (topic_id, title, content, experience_type, order_index) VALUES
('scope-functions', 'Choosing the Right One', E'My mental model:\n\n**Need result?**\n- Yes + configure: `run`\n- Yes + transform: `let`\n- No + configure: `apply`\n- No + side effect: `also`\n\n**this vs it?**\n- `this` (apply, run, with): object configuration\n- `it` (let, also): transformations, lambdas with other params', 'tip', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('scope-functions', 'kotlin_official', 'https://kotlinlang.org/docs/scope-functions.html', 'Scope Functions - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('scope-functions', 'higher-order-functions', 'prerequisite');

-- =====================================================
-- Topic 18: Collections Basics
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'collections-basics',
    'Collections Basics',
    'Collections & Sequences',
    'beginner',
    'Work with List, Set, Map and understand mutability',
    E'Kotlin distinguishes between **read-only** and **mutable** collections.\n\n## Types\n\n- `List` / `MutableList`\n- `Set` / `MutableSet`\n- `Map` / `MutableMap`\n\n## Creation\n\n- `listOf()`, `mutableListOf()`\n- `setOf()`, `mutableSetOf()`\n- `mapOf()`, `mutableMapOf()`',
    E'// Read-only collections\nval list = listOf(1, 2, 3)\nval set = setOf("a", "b", "c")\nval map = mapOf("one" to 1, "two" to 2)\n\n// Mutable collections\nval mutableList = mutableListOf(1, 2, 3)\nmutableList.add(4)\nmutableList += 5\n\n// Cannot add to read-only\n// list.add(4)  // Error!\n\n// Map access\nval value = map["one"]  // 1 (nullable)\nmap.getOrDefault("three", 0)  // 0',
    12,
    18
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('collections-basics', 'java8', 'Java', E'// Java - no compile-time immutability distinction\nList<Integer> list = List.of(1, 2, 3);  // Immutable at runtime\nlist.add(4);  // UnsupportedOperationException at RUNTIME!\n\nList<Integer> mutable = new ArrayList<>(List.of(1, 2, 3));\nmutable.add(4);  // OK', E'Java''s `List.of()` is immutable but the type is still `List`.\n\nAttempting to modify throws at runtime.\n\nKotlin catches this at compile time with separate types.', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('collections-basics', 'kotlin_official', 'https://kotlinlang.org/docs/collections-overview.html', 'Collections Overview - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('collections-basics', 'nullability', 'prerequisite');

-- =====================================================
-- Topic 19: Collection Operations
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'collection-operations',
    'Collection Operations',
    'Collections & Sequences',
    'intermediate',
    'Transform, filter, and aggregate collections with functional operations',
    E'Kotlin collections have rich functional operations.\n\n## Transformations\n\n- `map`, `flatMap`, `mapNotNull`\n- `associate`, `groupBy`\n\n## Filtering\n\n- `filter`, `filterNot`, `partition`\n- `take`, `drop`, `slice`\n\n## Aggregations\n\n- `sum`, `average`, `count`\n- `reduce`, `fold`\n- `min`, `max`, `sumOf`',
    E'val numbers = listOf(1, 2, 3, 4, 5)\n\n// Transform\nnumbers.map { it * 2 }           // [2, 4, 6, 8, 10]\nnumbers.mapNotNull { it.takeIf { it > 2 } }  // [3, 4, 5]\n\n// Filter\nnumbers.filter { it > 2 }        // [3, 4, 5]\nval (even, odd) = numbers.partition { it % 2 == 0 }\n\n// Aggregate\nnumbers.sum()                    // 15\nnumbers.sumOf { it * 2 }         // 30\nnumbers.reduce { acc, n -> acc + n }  // 15\n\n// Group\ndata class Person(val name: String, val city: String)\nval people = listOf(Person("John", "NY"), Person("Jane", "NY"))\npeople.groupBy { it.city }  // {NY=[John, Jane]}',
    15,
    19
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('collection-operations', 'java8', 'Java Streams', E'// Java - Stream API\nList<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);\n\nList<Integer> doubled = numbers.stream()\n    .map(n -> n * 2)\n    .collect(Collectors.toList());\n\nint sum = numbers.stream()\n    .reduce(0, Integer::sum);\n\nMap<String, List<Person>> byCity = people.stream()\n    .collect(Collectors.groupingBy(Person::getCity));', E'Kotlin advantages:\n- No `.stream()` / `.collect()`\n- Cleaner syntax\n- More operations built-in\n- Works on any Iterable', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('collection-operations', 'kotlin_official', 'https://kotlinlang.org/docs/collection-operations.html', 'Collection Operations - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('collection-operations', 'collections-basics', 'prerequisite'),
('collection-operations', 'higher-order-functions', 'prerequisite');

-- =====================================================
-- Topic 20: Sequences
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'sequences',
    'Sequences',
    'Collections & Sequences',
    'intermediate',
    'Use lazy sequences for efficient processing of large data sets',
    E'**Sequences** provide lazy evaluation for collection operations.\n\n## Collection vs Sequence\n\n- Collection: Eager - processes all elements at each step\n- Sequence: Lazy - processes one element through entire chain\n\n## When to Use\n\n- Large collections\n- Chained operations\n- When you don''t need all results',
    E'// Eager (List) - creates intermediate collections\nval result = listOf(1, 2, 3, 4, 5)\n    .map { println("map $it"); it * 2 }\n    .filter { println("filter $it"); it > 4 }\n    .first()\n// Processes ALL elements at each step\n\n// Lazy (Sequence) - processes one element through chain\nval result = listOf(1, 2, 3, 4, 5)\n    .asSequence()\n    .map { println("map $it"); it * 2 }\n    .filter { println("filter $it"); it > 4 }\n    .first()\n// Stops as soon as first() is satisfied!\n\n// Infinite sequences\nval naturals = generateSequence(1) { it + 1 }\nnaturals.take(10).toList()  // [1, 2, 3, ..., 10]',
    12,
    20
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('sequences', 'java8', 'Java Streams', E'// Java Streams are lazy like Kotlin Sequences\nList<Integer> result = IntStream.range(1, 1000000)\n    .filter(n -> n % 2 == 0)\n    .limit(10)\n    .boxed()\n    .collect(Collectors.toList());\n\n// Infinite stream\nStream<Integer> infinite = Stream.iterate(1, n -> n + 1);', E'Java Streams are lazy by default (like Kotlin Sequences).\n\nKotlin collections are eager (unlike Java Streams).\n\nUse `asSequence()` for lazy evaluation in Kotlin.', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('sequences', 'kotlin_official', 'https://kotlinlang.org/docs/sequences.html', 'Sequences - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('sequences', 'collection-operations', 'prerequisite');

-- =====================================================
-- Topic 21: Generics
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'generics',
    'Generics',
    'Advanced Topics',
    'advanced',
    'Write type-safe reusable code with generics and variance',
    E'**Generics** allow type-safe, reusable code.\n\n## Variance\n\n- `out T` - Covariant (producer, read-only)\n- `in T` - Contravariant (consumer, write-only)\n- Invariant - default (read and write)\n\n## Constraints\n\n- Upper bound: `T : SomeType`\n- Multiple: `where T : A, T : B`\n\n## reified\n\n- Available in inline functions\n- Allows runtime type checks',
    E'// Generic class\nclass Box<T>(val value: T)\n\n// Variance\nclass Producer<out T>(private val value: T) {\n    fun get(): T = value  // Can return T\n}\n\nclass Consumer<in T> {\n    fun accept(value: T) {}  // Can accept T\n}\n\n// Type constraints\nfun <T : Comparable<T>> sort(list: List<T>) { ... }\n\n// reified for runtime type access\ninline fun <reified T> isType(value: Any): Boolean {\n    return value is T  // Works!\n}',
    18,
    21
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('generics', 'java8', 'Java', E'// Java wildcards\nList<? extends Number> producer;  // out\nList<? super Integer> consumer;   // in\n\n// No reified - must pass Class\npublic <T> boolean isType(Object value, Class<T> clazz) {\n    return clazz.isInstance(value);\n}', E'Kotlin vs Java:\n- `out T` = `? extends T`\n- `in T` = `? super T`\n- Kotlin has reified type parameters', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('generics', 'kotlin_official', 'https://kotlinlang.org/docs/generics.html', 'Generics - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('generics', 'higher-order-functions', 'prerequisite'),
('generics', 'sealed-classes', 'prerequisite');

-- =====================================================
-- Topic 22: Delegation
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'delegation',
    'Delegation',
    'Advanced Topics',
    'advanced',
    'Implement the delegation pattern with first-class language support',
    E'Kotlin has built-in support for the delegation pattern.\n\n## Class Delegation\n\n- Implement interface by delegating to another object\n- Use `by` keyword\n\n## Property Delegation\n\n- Delegate property access to another object\n- Built-in: `lazy`, `observable`, `vetoable`',
    E'// Class delegation\ninterface Printer {\n    fun print(message: String)\n}\n\nclass ConsolePrinter : Printer {\n    override fun print(message: String) = println(message)\n}\n\n// Delegate all Printer methods to ''printer''\nclass LoggingPrinter(printer: Printer) : Printer by printer\n\n// Property delegation\nval lazyValue: String by lazy {\n    println("Computing...")\n    "Hello"\n}\n\nvar observed: String by Delegates.observable("initial") { _, old, new ->\n    println("Changed from $old to $new")\n}',
    15,
    22
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('delegation', 'java8', 'Java', E'// Java - manual delegation\npublic class LoggingPrinter implements Printer {\n    private final Printer delegate;\n    \n    public LoggingPrinter(Printer delegate) {\n        this.delegate = delegate;\n    }\n    \n    @Override\n    public void print(String message) {\n        delegate.print(message);\n    }\n    // Must delegate EVERY method manually!\n}', E'Java requires implementing every method manually.\n\nKotlin''s `by` keyword generates all delegated methods automatically.', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('delegation', 'kotlin_official', 'https://kotlinlang.org/docs/delegation.html', 'Delegation - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('delegation', 'higher-order-functions', 'prerequisite'),
('delegation', 'properties', 'prerequisite');

-- =====================================================
-- Topic 23: DSL Construction
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'dsl-construction',
    'DSL Construction',
    'Advanced Topics',
    'advanced',
    'Build domain-specific languages using Kotlin features',
    E'Kotlin is great for building **Domain-Specific Languages (DSLs)**.\n\n## Key Features\n\n- Lambda with receiver\n- Extension functions\n- Infix functions\n- Operator overloading\n\n## Common DSLs\n\n- HTML builders\n- Configuration\n- Testing (Kotest)\n- Routing (Ktor)',
    E'// Lambda with receiver - foundation of DSLs\nfun html(init: HTML.() -> Unit): HTML {\n    return HTML().apply(init)\n}\n\nclass HTML {\n    fun body(init: Body.() -> Unit) { ... }\n}\n\nclass Body {\n    fun p(text: String) { ... }\n}\n\n// Usage - looks like HTML!\nval page = html {\n    body {\n        p("Hello, World!")\n        p("This is a DSL")\n    }\n}\n\n// Infix for readable tests\ninfix fun <T> T.shouldBe(expected: T) {\n    if (this != expected) throw AssertionError()\n}\n\n5 shouldBe 5  // Reads like English!',
    18,
    23
);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('dsl-construction', 'kotlin_official', 'https://kotlinlang.org/docs/type-safe-builders.html', 'Type-Safe Builders - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('dsl-construction', 'higher-order-functions', 'prerequisite'),
('dsl-construction', 'extension-functions', 'prerequisite'),
('dsl-construction', 'scope-functions', 'prerequisite');

-- =====================================================
-- Topic 24: Coroutines Basics
-- =====================================================
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index)
VALUES (
    'coroutines-basics',
    'Coroutines Basics',
    'Advanced Topics',
    'advanced',
    'Write asynchronous code that reads like sequential code',
    E'**Coroutines** are Kotlin''s approach to async programming.\n\n## Key Concepts\n\n- `suspend` - marks suspendable functions\n- `launch` - fire and forget\n- `async` - returns a result\n- `Dispatchers` - control execution thread\n\n## Benefits\n\n- Sequential-looking async code\n- Structured concurrency\n- Lightweight (not threads)',
    E'// suspend function\nsuspend fun fetchUser(id: String): User {\n    delay(1000)  // Non-blocking delay\n    return User(id, "John")\n}\n\n// launch - fire and forget\nfun main() = runBlocking {\n    launch {\n        val user = fetchUser("1")\n        println(user)\n    }\n    println("Loading...")\n}\n\n// async - parallel execution\nsuspend fun loadAll() = coroutineScope {\n    val user = async { fetchUser("1") }\n    val orders = async { fetchOrders("1") }\n    \n    // Wait for both\n    display(user.await(), orders.await())\n}',
    20,
    24
);

INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index) VALUES
('coroutines-basics', 'java8', 'Java CompletableFuture', E'// Java - callback chains\nCompletableFuture<User> userFuture = fetchUserAsync(id);\nuserFuture\n    .thenCompose(user -> fetchOrdersAsync(user.getId()))\n    .thenAccept(orders -> display(orders))\n    .exceptionally(e -> { handleError(e); return null; });', E'Java requires chaining with `thenCompose`, `thenAccept`, etc.\n\nKotlin coroutines look like regular sequential code but execute asynchronously.', 1),
('coroutines-basics', 'csharp', 'C# async/await', E'// C# - very similar to Kotlin!\nasync Task<AllData> LoadAllAsync()\n{\n    var user = await FetchUserAsync(id);\n    var orders = await FetchOrdersAsync(user.Id);\n    return new AllData(user, orders);\n}\n\n// Parallel\nvar userTask = FetchUserAsync(id);\nvar ordersTask = FetchOrdersAsync(id);\nawait Task.WhenAll(userTask, ordersTask);', E'C# async/await is very similar to Kotlin coroutines!\n\nBoth transform sequential-looking code into async execution.', 2);

INSERT INTO kotlin_experience (topic_id, title, content, experience_type, order_index) VALUES
('coroutines-basics', 'From Callbacks to Coroutines', E'Our Android app had callback hell:\n\n```kotlin\napi.fetchUser(id, onSuccess = { user ->\n    api.fetchOrders(user.id, onSuccess = { orders ->\n        updateUI(user, orders)\n    })\n})\n```\n\nWith coroutines:\n\n```kotlin\nval user = api.fetchUser(id)\nval orders = api.fetchOrders(user.id)\nupdateUI(user, orders)\n```\n\nSame async behavior, readable code!', 'story', 1);

INSERT INTO kotlin_doc_link (topic_id, link_type, url, title, order_index) VALUES
('coroutines-basics', 'kotlin_official', 'https://kotlinlang.org/docs/coroutines-guide.html', 'Coroutines Guide - Kotlin Docs', 1);

INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type) VALUES
('coroutines-basics', 'higher-order-functions', 'prerequisite'),
('coroutines-basics', 'scope-functions', 'prerequisite');
