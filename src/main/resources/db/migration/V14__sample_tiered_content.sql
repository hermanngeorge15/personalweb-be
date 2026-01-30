-- V14: Sample Tiered Content and Runnable Examples
-- Demonstrates the tiered content structure for a few topics

-- =====================================================
-- TIERED CONTENT FOR "what-is-a-class"
-- =====================================================

INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes, order_index)
VALUES
('what-is-a-class', 1, 'TL;DR', 'Classes in 30 Seconds',
 E'A **class** is a blueprint for objects. In Kotlin:\n\n```kotlin\nclass Person(val name: String, var age: Int)\n```\n\nThat''s it! No getters, setters, or constructor body needed.\n\n**Key differences from Java:**\n- Properties, not fields\n- Primary constructor in header\n- Public by default',
 2, 1),

('what-is-a-class', 2, 'Beginner', 'Understanding Classes',
 E'## What is a Class?\n\nA class defines the structure and behavior of objects. Think of it as a cookie cutter - you design it once, then stamp out as many cookies (objects) as you need.\n\n## Kotlin vs Java Classes\n\n| Feature | Kotlin | Java |\n|---------|--------|------|\n| Properties | Built-in | Manual getters/setters |\n| Constructor | In class header | Separate body |\n| Default visibility | Public | Package-private |\n| Boilerplate | Minimal | Significant |\n\n## Anatomy of a Kotlin Class\n\n```kotlin\nclass Person(val name: String, var age: Int) {\n    fun greet() = "Hello, I''m $name"\n}\n```\n\n- `class Person` - declares the class\n- `(val name: String, var age: Int)` - primary constructor with properties\n- `val` - immutable property (like final in Java)\n- `var` - mutable property\n- `fun greet()` - member function',
 5, 2),

('what-is-a-class', 3, 'Intermediate', 'Deep Dive into Classes',
 E'## How Kotlin Classes Work Under the Hood\n\nWhen you write:\n```kotlin\nclass Person(val name: String, var age: Int)\n```\n\nKotlin generates:\n- A private `name` field with public getter\n- A private `age` field with public getter AND setter\n- A constructor that initializes both\n\n## Custom Accessors\n\n```kotlin\nclass Rectangle(val width: Int, val height: Int) {\n    val area: Int\n        get() = width * height  // Computed on every access\n    \n    var counter: Int = 0\n        private set  // Public getter, private setter\n}\n```\n\n## Backing Fields\n\nUse `field` in custom setters:\n\n```kotlin\nvar name: String = ""\n    set(value) {\n        field = value.trim().capitalize()\n    }\n```\n\n## Init Blocks\n\n```kotlin\nclass Person(val name: String) {\n    init {\n        require(name.isNotBlank()) { "Name cannot be blank" }\n    }\n}\n```',
 10, 3),

('what-is-a-class', 4, 'Deep Dive', 'Advanced Class Patterns',
 E'## Bytecode Analysis\n\nLet''s see what the Kotlin compiler generates:\n\n```kotlin\nclass Person(val name: String)\n```\n\nDecompiled Java:\n```java\npublic final class Person {\n    @NotNull\n    private final String name;\n    \n    @NotNull\n    public final String getName() {\n        return this.name;\n    }\n    \n    public Person(@NotNull String name) {\n        Intrinsics.checkNotNullParameter(name, "name");\n        this.name = name;\n    }\n}\n```\n\n## Final by Default Philosophy\n\nKotlin classes are `final` by default (cannot be inherited). This follows "Effective Java" Item 19: "Design for inheritance or prohibit it."\n\n```kotlin\nclass Closed          // Cannot inherit\nopen class Open       // Can inherit\nabstract class Base   // Must inherit\nsealed class Sealed   // Limited inheritance\n```\n\n## Memory Considerations\n\n- Val properties: 1 field + 1 getter method\n- Var properties: 1 field + 1 getter + 1 setter method\n- Each method adds ~40 bytes to class file\n- Use `@JvmField` to expose field directly (no accessor)',
 15, 4);

-- =====================================================
-- TIERED CONTENT FOR "null-safety"
-- =====================================================

INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes, order_index)
VALUES
('null-safety', 1, 'TL;DR', 'Null Safety Essentials',
 E'Kotlin eliminates NullPointerException by distinguishing nullable (`T?`) from non-nullable (`T`) types.\n\n```kotlin\nval safe: String = "hello"     // Cannot be null\nval nullable: String? = null   // Can be null\n\n// Safe call\nnullable?.length  // Returns null if nullable is null\n\n// Elvis operator\nnullable?.length ?: 0  // Returns 0 if null\n```',
 2, 1),

('null-safety', 2, 'Beginner', 'Understanding Null Safety',
 E'## The Billion Dollar Mistake\n\nTony Hoare, inventor of null references, called them his "billion dollar mistake." NullPointerExceptions are one of the most common bugs in Java.\n\n## Kotlin''s Solution\n\nKotlin distinguishes at the **type level**:\n\n```kotlin\nvar name: String = "John"   // Non-nullable\nvar nickname: String? = null // Nullable\n\nname = null    // Compile error!\nnickname = null // OK\n```\n\n## Working with Nullable Types\n\n**Safe Call (?.):**\n```kotlin\nval length = nickname?.length  // Int? - might be null\n```\n\n**Elvis Operator (?:):**\n```kotlin\nval length = nickname?.length ?: 0  // Int - default if null\n```\n\n**Not-Null Assertion (!!):**\n```kotlin\nval length = nickname!!.length  // Throws NPE if null - avoid!\n```',
 8, 2),

('null-safety', 3, 'Intermediate', 'Advanced Null Handling',
 E'## Smart Casts\n\nKotlin automatically casts after null checks:\n\n```kotlin\nfun process(str: String?) {\n    if (str != null) {\n        // str is automatically String (not String?) here\n        println(str.length)\n    }\n}\n```\n\n## let for Null Checks\n\n```kotlin\nuser?.let { \n    // ''it'' is non-null User inside this block\n    sendEmail(it.email)\n}\n```\n\n## Platform Types\n\nJava code has "platform types" (shown as `String!`):\n\n```kotlin\n// Java: String getName() - no nullability info\nval name = javaObject.getName()  // String! - platform type\n```\n\n**Best practice:** Assign to explicitly typed variable:\n```kotlin\nval name: String = javaObject.getName()  // NPE if null\nval name: String? = javaObject.getName() // Safe\n```\n\n## Collections and Nullability\n\n```kotlin\nList<String>   // Non-null list of non-null strings\nList<String?>  // Non-null list of nullable strings\nList<String>?  // Nullable list of non-null strings\nList<String?>? // Nullable list of nullable strings\n```',
 12, 3),

('null-safety', 4, 'Deep Dive', 'Null Safety Implementation',
 E'## How Kotlin Enforces Null Safety\n\nKotlin uses `@NotNull` and `@Nullable` annotations in bytecode:\n\n```kotlin\nfun greet(name: String): String\n```\n\nGenerates:\n```java\n@NotNull\npublic String greet(@NotNull String name) {\n    Intrinsics.checkNotNullParameter(name, "name");\n    // ...\n}\n```\n\n## Runtime Checks\n\nKotlin adds null checks at function boundaries:\n\n```kotlin\nfun process(data: String) { ... }\n```\n\nIf Java code passes null, you get:\n`IllegalArgumentException: Parameter ''data'' cannot be null`\n\n## Performance Considerations\n\n- Nullable primitives (`Int?`) are boxed (Integer object)\n- Non-nullable primitives (`Int`) use primitives (int)\n\n```kotlin\nval nonNull: Int = 42    // int in bytecode\nval nullable: Int? = 42  // Integer in bytecode\n```\n\n## When !! is Acceptable\n\n1. In tests (fail fast)\n2. After external validation\n3. Framework callbacks (e.g., Android `onCreate`)\n\nAlways prefer `requireNotNull()` for better error messages:\n```kotlin\nval user = requireNotNull(findUser(id)) { "User $id not found" }\n```',
 15, 4);

-- =====================================================
-- RUNNABLE EXAMPLES
-- =====================================================

INSERT INTO kotlin_runnable_example (topic_id, title, description, code, expected_output, tier_level, order_index)
VALUES
-- what-is-a-class examples
('what-is-a-class', 'Basic Class', 'Create and use a simple class',
 E'class Person(val name: String, var age: Int) {\n    fun greet() = "Hello, I''m $name and I''m $age years old"\n}\n\nfun main() {\n    val person = Person("Kotlin", 10)\n    println(person.greet())\n    person.age = 11\n    println("After birthday: ${person.age}")\n}',
 E'Hello, I''m Kotlin and I''m 10 years old\nAfter birthday: 11',
 2, 1),

('what-is-a-class', 'Custom Accessors', 'Properties with custom getters and setters',
 E'class Temperature(celsius: Double) {\n    var celsius: Double = celsius\n        set(value) {\n            field = if (value < -273.15) -273.15 else value\n        }\n    \n    val fahrenheit: Double\n        get() = celsius * 9/5 + 32\n}\n\nfun main() {\n    val temp = Temperature(25.0)\n    println("${temp.celsius}°C = ${temp.fahrenheit}°F")\n    \n    temp.celsius = -300.0  // Below absolute zero\n    println("Clamped to: ${temp.celsius}°C")\n}',
 E'25.0°C = 77.0°F\nClamped to: -273.15°C',
 3, 2),

-- null-safety examples
('null-safety', 'Safe Calls', 'Using ?. to safely access nullable properties',
 E'fun main() {\n    val name: String? = "Kotlin"\n    val nullName: String? = null\n    \n    println("Length of name: ${name?.length}")\n    println("Length of nullName: ${nullName?.length}")\n    \n    // Chained safe calls\n    val city: String? = name?.uppercase()?.take(3)\n    println("City: $city")\n}',
 E'Length of name: 6\nLength of nullName: null\nCity: KOT',
 2, 1),

('null-safety', 'Elvis Operator', 'Providing default values with ?:',
 E'fun getLength(str: String?): Int = str?.length ?: 0\n\nfun main() {\n    println("Length of ''hello'': ${getLength("hello")}")\n    println("Length of null: ${getLength(null)}")\n    \n    // Elvis with throw\n    val name: String? = "Kotlin"\n    val length = name?.length ?: throw IllegalArgumentException("Name required")\n    println("Validated length: $length")\n}',
 E'Length of ''hello'': 5\nLength of null: 0\nValidated length: 6',
 2, 2),

('null-safety', 'Smart Casts', 'Automatic casting after null checks',
 E'fun describe(obj: Any?): String {\n    return when {\n        obj == null -> "It''s null"\n        obj is String -> "String of length ${obj.length}"\n        obj is Int -> "Integer: ${obj * 2}"\n        else -> "Unknown type"\n    }\n}\n\nfun main() {\n    println(describe(null))\n    println(describe("Hello"))\n    println(describe(21))\n    println(describe(3.14))\n}',
 E'It''s null\nString of length 5\nInteger: 42\nUnknown type',
 3, 3),

-- variables examples
('variables-val-var', 'Val vs Var', 'Understanding immutable and mutable variables',
 E'fun main() {\n    val immutable = "Cannot change"\n    var mutable = "Can change"\n    \n    // immutable = "Error"  // Would not compile\n    mutable = "Changed!"\n    \n    println(immutable)\n    println(mutable)\n    \n    // Val with mutable content\n    val list = mutableListOf(1, 2, 3)\n    list.add(4)  // OK - modifying content, not reference\n    println(list)\n}',
 E'Cannot change\nChanged!\n[1, 2, 3, 4]',
 2, 1),

-- data-classes examples
('data-classes', 'Data Class Basics', 'Auto-generated methods in data classes',
 E'data class User(val name: String, val age: Int)\n\nfun main() {\n    val user1 = User("Alice", 30)\n    val user2 = User("Alice", 30)\n    val user3 = user1.copy(age = 31)\n    \n    println("user1: $user1")\n    println("user1 == user2: ${user1 == user2}")\n    println("user3: $user3")\n    \n    // Destructuring\n    val (name, age) = user1\n    println("Name: $name, Age: $age")\n}',
 E'user1: User(name=Alice, age=30)\nuser1 == user2: true\nuser3: User(name=Alice, age=31)\nName: Alice, Age: 30',
 2, 1),

-- extension-functions examples
('extension-functions', 'String Extensions', 'Adding methods to String class',
 E'fun String.addExclamation() = this + "!"\n\nfun String.words() = this.split(" ").filter { it.isNotBlank() }\n\nfun String.isPalindrome(): Boolean {\n    val clean = this.lowercase().filter { it.isLetter() }\n    return clean == clean.reversed()\n}\n\nfun main() {\n    println("Hello".addExclamation())\n    println("Kotlin is awesome".words())\n    println("A man a plan a canal Panama".isPalindrome())\n}',
 E'Hello!\n[Kotlin, is, awesome]\ntrue',
 3, 1);

-- Add topic dependencies for mind map
INSERT INTO kotlin_topic_dependency (topic_id, depends_on_topic_id, dependency_type)
VALUES
('variables-val-var', 'what-is-a-class', 'related'),
('null-safety', 'variables-val-var', 'prerequisite'),
('data-classes', 'what-is-a-class', 'prerequisite'),
('extension-functions', 'functions-basics', 'prerequisite'),
('lambdas-basics', 'functions-basics', 'prerequisite'),
('higher-order-functions', 'lambdas-basics', 'prerequisite'),
('coroutines-basics', 'lambdas-basics', 'prerequisite'),
('sealed-classes', 'inheritance', 'prerequisite'),
('generics-variance', 'generics-basics', 'prerequisite')
ON CONFLICT DO NOTHING;
