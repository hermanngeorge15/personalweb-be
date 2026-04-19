-- V18: Seed Tiered Content for All 65 Topics
-- 4 tiers: TL;DR (1), Beginner (2), Intermediate (3), Deep Dive (4)

-- =====================================================
-- PART 1: KOTLIN FUNDAMENTALS
-- =====================================================

-- Topic: variables-val-var
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('variables-val-var', 1, 'TL;DR', 'Val vs Var in 30 Seconds',
 E'**val** = immutable (read-only), **var** = mutable.\n\n```kotlin\nval name = "Kotlin"  // Cannot reassign\nvar count = 0        // Can reassign\ncount++              // OK\n// name = "Java"     // Compile error!\n```\n\n**Rule:** Prefer `val` unless you need to reassign.',
 2),
('variables-val-var', 2, 'Beginner', 'Understanding Val and Var',
 E'## The Two Ways to Declare Variables\n\nKotlin has two keywords for variables:\n\n| Keyword | Meaning | Java Equivalent |\n|---------|---------|----------------|\n| `val` | Value (immutable) | `final` variable |\n| `var` | Variable (mutable) | Regular variable |\n\n## Examples\n\n```kotlin\nval pi = 3.14159       // Cannot change\nvar temperature = 20   // Can change\n\ntemperature = 25       // OK\n// pi = 3.14           // Error: Val cannot be reassigned\n```\n\n## Why Prefer val?\n\n1. **Thread safety** - Immutable values can''t cause race conditions\n2. **Easier reasoning** - Value won''t change unexpectedly\n3. **Functional style** - Encourages immutable data patterns\n\n## Important: val ≠ Immutable Object\n\n```kotlin\nval list = mutableListOf(1, 2, 3)\nlist.add(4)  // OK! The reference is immutable, not the object\n// list = mutableListOf()  // Error: can''t reassign\n```',
 5),
('variables-val-var', 3, 'Intermediate', 'Advanced Variable Patterns',
 E'## Type Inference\n\nKotlin infers types, but you can be explicit:\n\n```kotlin\nval name = "Kotlin"           // Inferred as String\nval name: String = "Kotlin"   // Explicit type\nval number: Number = 42       // Supertype declaration\n```\n\n## Lateinit for Deferred Initialization\n\n```kotlin\nclass MyTest {\n    lateinit var service: UserService  // Must be var\n    \n    @BeforeEach\n    fun setup() {\n        service = UserService()\n    }\n}\n```\n\n**Restrictions:**\n- Only for `var` (not `val`)\n- Only for non-nullable types\n- Only for non-primitive types\n\n## Const Val for Compile-Time Constants\n\n```kotlin\nconst val MAX_SIZE = 100  // Compile-time constant\nval runtime = System.currentTimeMillis()  // Runtime value\n```\n\n`const val` requirements:\n- Top-level or in object/companion object\n- Primitive or String type\n- No custom getter\n\n## Destructuring with Val/Var\n\n```kotlin\nval (name, age) = Person("John", 30)\nvar (x, y) = Point(0, 0)\n```',
 8),
('variables-val-var', 4, 'Deep Dive', 'Val/Var Under the Hood',
 E'## Bytecode Analysis\n\nLet''s see what the compiler generates:\n\n```kotlin\nval name = "Kotlin"\nvar count = 0\n```\n\nDecompiled to Java:\n```java\n@NotNull\nprivate static final String name = "Kotlin";\nprivate static int count = 0;\n\n@NotNull\npublic static final String getName() { return name; }\npublic static final int getCount() { return count; }\npublic static final void setCount(int value) { count = value; }\n```\n\n## Memory Implications\n\n- `val` primitives: Single memory location, no overhead\n- `val` objects: Reference is final, object may be mutable\n- `var` primitives: Same memory, allows reassignment\n\n## JVM Field Modifiers\n\n| Kotlin | JVM Modifier |\n|--------|-------------|\n| `val` | `final` field |\n| `var` | Non-final field |\n| `const val` | `static final` + inlined |\n\n## const val Inlining\n\n```kotlin\nconst val MAX = 100\nfun check(n: Int) = n < MAX\n```\n\nBytecode uses literal `100`, not field access. This means:\n- Faster (no field lookup)\n- Changes require recompilation of all users\n\n## Property Delegation Impact\n\n```kotlin\nval lazyValue by lazy { expensiveComputation() }\n```\n\nCreates a `Lazy<T>` wrapper object. Consider memory tradeoffs for frequently accessed values.',
 12)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: basic-types
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('basic-types', 1, 'TL;DR', 'Basic Types Quick Reference',
 E'```kotlin\nval int: Int = 42\nval long: Long = 42L\nval double: Double = 3.14\nval float: Float = 3.14f\nval boolean: Boolean = true\nval char: Char = ''A''\nval string: String = "Hello"\n```\n\nNumbers are objects but compile to primitives. No implicit widening conversions.',
 2),
('basic-types', 2, 'Beginner', 'Kotlin Basic Types Explained',
 E'## Number Types\n\n| Type | Size | Range |\n|------|------|-------|\n| Byte | 8 bit | -128 to 127 |\n| Short | 16 bit | -32768 to 32767 |\n| Int | 32 bit | -2³¹ to 2³¹-1 |\n| Long | 64 bit | -2⁶³ to 2⁶³-1 |\n| Float | 32 bit | ~6 decimal digits |\n| Double | 64 bit | ~15 decimal digits |\n\n## Literals\n\n```kotlin\nval decimal = 123\nval long = 123L\nval hex = 0x0F\nval binary = 0b00001011\nval double = 3.14\nval float = 3.14f\nval withUnderscores = 1_000_000\n```\n\n## No Implicit Conversions!\n\n```kotlin\nval i: Int = 42\n// val l: Long = i  // Error!\nval l: Long = i.toLong()  // OK\n```\n\n## Strings\n\n```kotlin\nval str = "Hello"\nval multiline = """\n    Line 1\n    Line 2\n""".trimIndent()\nval template = "Value: $i or ${i * 2}"\n```',
 6),
('basic-types', 3, 'Intermediate', 'Advanced Type Operations',
 E'## Unsigned Types (Kotlin 1.5+)\n\n```kotlin\nval uByte: UByte = 255u\nval uInt: UInt = 4_294_967_295u\nval uLong: ULong = 18_446_744_073_709_551_615uL\n```\n\n## Number Conversions\n\nEvery number type has conversion functions:\n```kotlin\nval i = 42\ni.toByte()\ni.toShort()\ni.toLong()\ni.toFloat()\ni.toDouble()\ni.toChar()\n```\n\n## Bitwise Operations (Int/Long only)\n\n```kotlin\nval x = 0b1010\nval y = 0b1100\n\nx and y   // 0b1000 (AND)\nx or y    // 0b1110 (OR)\nx xor y   // 0b0110 (XOR)\nx.inv()   // Invert bits\nx shl 2   // Shift left\nx shr 2   // Shift right\nx ushr 2  // Unsigned shift right\n```\n\n## String Operations\n\n```kotlin\n"hello".uppercase()           // HELLO\n"  hello  ".trim()            // hello\n"hello".reversed()            // olleh\n"hello".take(3)               // hel\n"a,b,c".split(",")           // [a, b, c]\nlistOf("a","b").joinToString() // a, b\n```',
 10),
('basic-types', 4, 'Deep Dive', 'Types at the JVM Level',
 E'## Primitive vs Boxed\n\nKotlin compiles to primitives when possible:\n\n```kotlin\nval i: Int = 42       // int in bytecode\nval n: Int? = 42      // Integer (boxed)\nval list: List<Int>   // List<Integer> (boxed)\n```\n\n## Identity vs Equality\n\n```kotlin\nval a: Int = 1000\nval b: Int = 1000\nprintln(a == b)   // true (structural)\nprintln(a === b)  // true (same primitive)\n\nval c: Int? = 1000\nval d: Int? = 1000\nprintln(c == d)   // true\nprintln(c === d)  // false! Different Integer objects\n```\n\n**Note:** JVM caches Integer objects for -128 to 127.\n\n## String Interning\n\n```kotlin\nval s1 = "hello"\nval s2 = "hello"\nprintln(s1 === s2)  // true - string pool\n\nval s3 = buildString { append("hel"); append("lo") }\nprintln(s1 === s3)  // false - new object\nprintln(s1 == s3)   // true - same content\n```\n\n## @JvmInline Value Classes\n\n```kotlin\n@JvmInline\nvalue class UserId(val id: Long)\n\nfun getUser(id: UserId) { ... }\n```\n\nCompiles to primitive `long` parameter - zero overhead type safety!\n\n## Array Specialization\n\n```kotlin\nval intArray: IntArray = intArrayOf(1, 2, 3)  // int[]\nval boxedArray: Array<Int> = arrayOf(1, 2, 3) // Integer[]\n```\n\nUse `IntArray`, `LongArray`, etc. for performance-critical code.',
 15)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: string-templates
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('string-templates', 1, 'TL;DR', 'String Templates Cheat Sheet',
 E'```kotlin\nval name = "World"\nprintln("Hello, $name!")           // Variable\nprintln("Sum: ${1 + 2}")           // Expression\nprintln("Length: ${name.length}")  // Property access\n```\n\nUse `$variable` for simple refs, `${expression}` for complex ones.',
 1),
('string-templates', 2, 'Beginner', 'String Templates Guide',
 E'## Why String Templates?\n\nCompare Java vs Kotlin:\n\n```java\n// Java\nString msg = "Hello, " + name + "! You are " + age + " years old.";\n```\n\n```kotlin\n// Kotlin\nval msg = "Hello, $name! You are $age years old."\n```\n\n## Syntax Rules\n\n| Syntax | Use Case |\n|--------|----------|\n| `$name` | Simple variable |\n| `${expr}` | Expressions, method calls |\n| `${"$"}` | Literal dollar sign |\n\n## Examples\n\n```kotlin\nval user = User("Alice", 30)\n\n"Name: $user"                    // Calls toString()\n"Upper: ${user.name.uppercase()}" // Method chain\n"Adult: ${user.age >= 18}"       // Boolean expression\n"Price: ${"$"}99.99"             // Literal $\n```',
 4)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: control-flow-if-when
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('control-flow-if-when', 1, 'TL;DR', 'If & When as Expressions',
 E'```kotlin\n// If as expression\nval max = if (a > b) a else b\n\n// When as expression\nval result = when (x) {\n    1 -> "one"\n    2, 3 -> "two or three"\n    in 4..10 -> "between 4-10"\n    else -> "other"\n}\n```\n\nBoth return values - no ternary operator needed!',
 2),
('control-flow-if-when', 2, 'Beginner', 'Control Flow Fundamentals',
 E'## If Expression\n\nUnlike Java, `if` returns a value:\n\n```kotlin\n// As expression (replaces ternary)\nval max = if (a > b) a else b\n\n// Multi-line - last expression is returned\nval result = if (condition) {\n    doSomething()\n    "success"  // returned\n} else {\n    "failure"  // returned\n}\n```\n\n## When Expression\n\nPowerful replacement for switch:\n\n```kotlin\nwhen (x) {\n    1 -> println("one")\n    2 -> println("two")\n    else -> println("other")\n}\n```\n\n## When Features\n\n```kotlin\nval result = when {\n    x < 0 -> "negative"\n    x == 0 -> "zero"\n    else -> "positive"\n}\n\nwhen (obj) {\n    is String -> println(obj.length)  // Smart cast!\n    is Int -> println(obj * 2)\n    !is Number -> println("not a number")\n}\n```',
 6),
('control-flow-if-when', 3, 'Intermediate', 'Advanced When Patterns',
 E'## When with Multiple Conditions\n\n```kotlin\nwhen (x) {\n    0, 1 -> "zero or one"\n    in 2..10 -> "between 2 and 10"\n    in validNumbers -> "in valid set"\n    !in blockedNumbers -> "not blocked"\n    else -> "other"\n}\n```\n\n## When as Statement vs Expression\n\n```kotlin\n// Statement - else not required\nwhen (x) {\n    1 -> doSomething()\n}\n\n// Expression - else required (unless exhaustive)\nval y = when (x) {\n    1 -> "one"\n    else -> "other"  // Required!\n}\n```\n\n## Exhaustive When with Sealed Classes\n\n```kotlin\nsealed class Result\ndata class Success(val data: String) : Result()\ndata class Error(val msg: String) : Result()\n\nfun handle(result: Result) = when (result) {\n    is Success -> result.data  // No else needed!\n    is Error -> result.msg\n}\n```\n\n## Capturing When Subject\n\n```kotlin\nwhen (val response = fetchData()) {\n    is Success -> process(response.data)\n    is Error -> log(response.message)\n}\n```',
 10),
('control-flow-if-when', 4, 'Deep Dive', 'When Implementation Details',
 E'## Bytecode: When vs Switch\n\nSimple when compiles to tableswitch/lookupswitch:\n\n```kotlin\nwhen (x) {\n    1 -> "a"\n    2 -> "b"\n}\n```\n\nComplex conditions use if-else chain:\n\n```kotlin\nwhen {\n    x > 0 -> "positive"\n    x < 0 -> "negative"\n}\n```\n\n## Performance Considerations\n\n| Pattern | Bytecode | Performance |\n|---------|----------|-------------|\n| Int literals | tableswitch | O(1) |\n| Sparse ints | lookupswitch | O(log n) |\n| Ranges | if-else | O(n) |\n| Type checks | instanceof | O(n) |\n\n## Enum Optimization\n\n```kotlin\nenum class Color { RED, GREEN, BLUE }\n\nwhen (color) {\n    Color.RED -> ...\n    Color.GREEN -> ...\n    Color.BLUE -> ...\n}\n```\n\nCompiles to efficient ordinal-based switch.\n\n## Subject Evaluation\n\nThe when subject is evaluated exactly once:\n\n```kotlin\nwhen (expensiveCall()) {  // Called once\n    1 -> use(it)  // Error: no ''it''\n}\n\n// Capture it:\nwhen (val result = expensiveCall()) {\n    1 -> use(result)\n}\n```',
 12)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: loops-ranges
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('loops-ranges', 1, 'TL;DR', 'Loops & Ranges Quick Reference',
 E'```kotlin\nfor (i in 1..5) print(i)      // 1 2 3 4 5\nfor (i in 5 downTo 1) print(i) // 5 4 3 2 1\nfor (i in 1 until 5) print(i)  // 1 2 3 4\nfor (i in 1..10 step 2) print(i) // 1 3 5 7 9\n\nwhile (condition) { }\ndo { } while (condition)\n```',
 2),
('loops-ranges', 2, 'Beginner', 'Loops and Ranges Explained',
 E'## For Loops\n\n```kotlin\n// Over range\nfor (i in 1..5) println(i)\n\n// Over collection\nfor (item in list) println(item)\n\n// With index\nfor ((index, value) in list.withIndex()) {\n    println("$index: $value")\n}\n```\n\n## Range Operators\n\n| Operator | Meaning | Example |\n|----------|---------|--------|\n| `..` | Inclusive | 1..5 = 1,2,3,4,5 |\n| `until` | Exclusive end | 1 until 5 = 1,2,3,4 |\n| `downTo` | Descending | 5 downTo 1 = 5,4,3,2,1 |\n| `step` | Skip values | 1..10 step 2 = 1,3,5,7,9 |\n\n## While Loops\n\n```kotlin\nwhile (queue.isNotEmpty()) {\n    process(queue.poll())\n}\n\ndo {\n    val input = readLine()\n} while (input != "quit")\n```',
 5)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: exceptions
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('exceptions', 1, 'TL;DR', 'Exceptions Essentials',
 E'```kotlin\n// Try as expression\nval number = try {\n    input.toInt()\n} catch (e: NumberFormatException) {\n    0  // Default value\n}\n\n// Throw is an expression too\nval value = x ?: throw IllegalArgumentException("x required")\n```\n\nNo checked exceptions in Kotlin!',
 2),
('exceptions', 2, 'Beginner', 'Exception Handling Basics',
 E'## No Checked Exceptions\n\nKotlin doesn''t have checked exceptions. You don''t need to declare or catch them:\n\n```kotlin\nfun readFile(path: String): String {\n    return File(path).readText()  // No throws declaration\n}\n```\n\n## Try-Catch-Finally\n\n```kotlin\ntry {\n    riskyOperation()\n} catch (e: IOException) {\n    handleIO(e)\n} catch (e: Exception) {\n    handleOther(e)\n} finally {\n    cleanup()\n}\n```\n\n## Try as Expression\n\n```kotlin\nval result = try {\n    parseInt(input)\n} catch (e: NumberFormatException) {\n    null\n}\n```\n\n## Throwing Exceptions\n\n```kotlin\nthrow IllegalArgumentException("Invalid input")\n\n// Throw as expression\nval name = person.name ?: throw IllegalStateException("Name required")\n```',
 6),
('exceptions', 3, 'Intermediate', 'Advanced Exception Patterns',
 E'## Nothing Type\n\n`throw` returns `Nothing` - a type with no values:\n\n```kotlin\nfun fail(message: String): Nothing {\n    throw IllegalArgumentException(message)\n}\n\nval name = person.name ?: fail("Name required")\n// Compiler knows code after fail() is unreachable\n```\n\n## Use for Resource Management\n\n```kotlin\nFile("data.txt").bufferedReader().use { reader ->\n    reader.readLines().forEach(::println)\n}  // Automatically closed, even on exception\n```\n\n## runCatching for Functional Style\n\n```kotlin\nval result = runCatching {\n    riskyOperation()\n}\n\nresult.getOrNull()     // Value or null\nresult.getOrDefault(0) // Value or default\nresult.getOrElse { e -> handleError(e) }\nresult.onSuccess { value -> process(value) }\nresult.onFailure { e -> log(e) }\n```\n\n## Custom Exceptions\n\n```kotlin\nclass ValidationException(\n    message: String,\n    val field: String\n) : RuntimeException(message)\n```',
 10)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: functions-basics
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('functions-basics', 1, 'TL;DR', 'Functions Quick Reference',
 E'```kotlin\n// Standard function\nfun greet(name: String): String {\n    return "Hello, $name!"\n}\n\n// Single-expression function\nfun double(x: Int) = x * 2\n\n// Default parameters\nfun greet(name: String = "World") = "Hello, $name!"\n```',
 2),
('functions-basics', 2, 'Beginner', 'Functions Fundamentals',
 E'## Function Syntax\n\n```kotlin\nfun functionName(param1: Type1, param2: Type2): ReturnType {\n    // body\n    return result\n}\n```\n\n## Single-Expression Functions\n\n```kotlin\nfun add(a: Int, b: Int): Int = a + b\nfun add(a: Int, b: Int) = a + b  // Type inferred\n```\n\n## Unit Return Type\n\n```kotlin\nfun printHello(): Unit {\n    println("Hello")\n}\n\n// Unit can be omitted\nfun printHello() {\n    println("Hello")\n}\n```\n\n## Default Parameters\n\n```kotlin\nfun greet(name: String = "World", punctuation: String = "!") =\n    "Hello, $name$punctuation"\n\ngreet()                    // Hello, World!\ngreet("Kotlin")            // Hello, Kotlin!\ngreet(punctuation = "?")   // Hello, World?\n```',
 6),
('functions-basics', 3, 'Intermediate', 'Advanced Function Features',
 E'## Named Arguments\n\n```kotlin\nfun createUser(\n    name: String,\n    age: Int = 0,\n    email: String = "",\n    active: Boolean = true\n)\n\n// Mix positional and named\ncreateUser("John", email = "john@example.com")\n```\n\n## Vararg Parameters\n\n```kotlin\nfun sum(vararg numbers: Int): Int = numbers.sum()\n\nsum(1, 2, 3)           // 6\nsum(*intArrayOf(1,2,3)) // Spread operator\n```\n\n## Generic Functions\n\n```kotlin\nfun <T> singletonList(item: T): List<T> = listOf(item)\n\nval list = singletonList("hello")  // List<String>\n```\n\n## Tail Recursive Functions\n\n```kotlin\ntailrec fun factorial(n: Int, acc: Int = 1): Int =\n    if (n <= 1) acc else factorial(n - 1, n * acc)\n```\n\n`tailrec` optimizes to a loop, preventing stack overflow.',
 10)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: default-named-args
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('default-named-args', 1, 'TL;DR', 'Default & Named Args',
 E'```kotlin\nfun greet(name: String = "World", loud: Boolean = false) =\n    if (loud) "HELLO, ${name.uppercase()}!" else "Hello, $name"\n\ngreet()                  // Hello, World\ngreet("Kotlin")          // Hello, Kotlin\ngreet(loud = true)       // HELLO, WORLD!\ngreet("Kotlin", true)    // HELLO, KOTLIN!\n```',
 2),
('default-named-args', 2, 'Beginner', 'Eliminating Method Overloads',
 E'## The Java Problem\n\n```java\n// Java needs multiple overloads\npublic void greet() { greet("World"); }\npublic void greet(String name) { greet(name, false); }\npublic void greet(String name, boolean loud) { ... }\n```\n\n## Kotlin Solution\n\n```kotlin\n// One function with defaults\nfun greet(name: String = "World", loud: Boolean = false) { ... }\n```\n\n## Named Arguments Benefits\n\n```kotlin\n// Unclear what true means\ncreateUser("John", true, false, true)\n\n// Self-documenting\ncreateUser(\n    name = "John",\n    isAdmin = true,\n    isActive = false,\n    sendWelcomeEmail = true\n)\n```\n\n## Rules\n\n- Named args can be in any order\n- Once you use a named arg, all following must be named\n- Can mix positional and named (positional first)',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: extension-functions
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('extension-functions', 1, 'TL;DR', 'Extension Functions',
 E'```kotlin\n// Add method to String\nfun String.addExclamation() = this + "!"\n\n"Hello".addExclamation()  // Hello!\n\n// Extension property\nval String.lastChar: Char\n    get() = this[length - 1]\n\n"Kotlin".lastChar  // n\n```',
 2),
('extension-functions', 2, 'Beginner', 'Extending Existing Classes',
 E'## What Are Extension Functions?\n\nAdd methods to existing classes without inheritance:\n\n```kotlin\nfun String.removeSpaces() = this.replace(" ", "")\n\n"Hello World".removeSpaces()  // HelloWorld\n```\n\n## How It Works\n\nThe receiver (`this`) is the object the function is called on:\n\n```kotlin\nfun String.wordCount(): Int {\n    return this.split(" ").size  // ''this'' is the String\n}\n\n"one two three".wordCount()  // 3\n```\n\n## Extension Properties\n\n```kotlin\nval String.firstChar: Char\n    get() = this[0]\n\nval <T> List<T>.secondOrNull: T?\n    get() = if (size >= 2) this[1] else null\n```\n\n**Note:** Extensions can''t have backing fields - only computed properties.',
 6),
('extension-functions', 3, 'Intermediate', 'Extension Function Patterns',
 E'## Nullable Receiver\n\n```kotlin\nfun String?.orEmpty(): String = this ?: ""\n\nval name: String? = null\nname.orEmpty()  // "" - safe to call on null!\n```\n\n## Generic Extensions\n\n```kotlin\nfun <T> T.also(block: (T) -> Unit): T {\n    block(this)\n    return this\n}\n\nfun <T, R> T.let(block: (T) -> R): R = block(this)\n```\n\n## Extensions on Collections\n\n```kotlin\nfun <T> List<T>.second(): T = this[1]\nfun <T> MutableList<T>.swap(i: Int, j: Int) {\n    val tmp = this[i]\n    this[i] = this[j]\n    this[j] = tmp\n}\n```\n\n## Scope and Import\n\n```kotlin\n// Define in package\npackage com.example.utils\nfun String.toSlug() = ...\n\n// Import to use\nimport com.example.utils.toSlug\n"Hello World".toSlug()\n```',
 10),
('extension-functions', 4, 'Deep Dive', 'Extensions Under the Hood',
 E'## Compiled Form\n\n```kotlin\nfun String.addBang() = this + "!"\n```\n\nCompiles to:\n```java\npublic static String addBang(String $this$addBang) {\n    return $this$addBang + "!";\n}\n```\n\n**Key insight:** Extensions are static methods!\n\n## No Virtual Dispatch\n\n```kotlin\nopen class Shape\nclass Circle : Shape()\n\nfun Shape.getName() = "Shape"\nfun Circle.getName() = "Circle"\n\nfun printName(s: Shape) {\n    println(s.getName())  // Always "Shape"!\n}\n\nprintName(Circle())  // "Shape" - resolved statically\n```\n\n## Member vs Extension\n\nMembers always win:\n\n```kotlin\nclass Example {\n    fun foo() = "member"\n}\n\nfun Example.foo() = "extension"  // Never called!\n\nExample().foo()  // "member"\n```\n\n## Extensions and Java Interop\n\n```kotlin\n// Kotlin\nfun String.hello() = "Hello, $this"\n\n// Java\nStringKt.hello("World");  // Static method call\n```\n\nUse `@JvmName` to customize the generated class name.',
 15)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: infix-functions
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('infix-functions', 1, 'TL;DR', 'Infix Functions',
 E'```kotlin\ninfix fun Int.times(s: String) = s.repeat(this)\n\n3 times "Hi "  // "Hi Hi Hi "\n3.times("Hi ") // Same thing\n\n// Built-in examples\n1 to "one"     // Pair(1, "one")\n1 until 10    // IntRange\nmap["key"] = "value"\n```',
 2),
('infix-functions', 2, 'Beginner', 'Creating DSL-Like Syntax',
 E'## What Makes a Function Infix?\n\n```kotlin\ninfix fun Int.times(str: String) = str.repeat(this)\n```\n\nRequirements:\n- Must be member or extension function\n- Must have exactly one parameter\n- Parameter must not be vararg or have default value\n\n## Calling Infix Functions\n\n```kotlin\n// Infix notation\n3 times "Kotlin "\n\n// Regular notation (always works)\n3.times("Kotlin ")\n```\n\n## Built-in Infix Functions\n\n```kotlin\nval pair = "key" to "value"   // Pair\nval range = 1 until 10        // IntRange exclusive\nval isType = obj is String    // Type check\nval notType = obj !is String  // Negated type check\nval inRange = 5 in 1..10      // Contains check\n```',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: local-functions
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('local-functions', 1, 'TL;DR', 'Local Functions',
 E'```kotlin\nfun process(users: List<User>) {\n    fun validate(user: User) {  // Local function\n        require(user.name.isNotBlank()) { "Name required for ${user.id}" }\n    }\n    \n    users.forEach { validate(it) }\n}\n```\n\nLocal functions can access outer function''s variables.',
 2),
('local-functions', 2, 'Beginner', 'Functions Inside Functions',
 E'## Why Local Functions?\n\n1. **Encapsulation** - Hide helper logic\n2. **Closure** - Access outer variables\n3. **Organization** - Group related code\n\n## Basic Example\n\n```kotlin\nfun saveUser(user: User) {\n    // Local validation function\n    fun validate() {\n        if (user.name.isBlank()) {\n            throw IllegalArgumentException("Name required")\n        }\n    }\n    \n    validate()  // Call local function\n    database.save(user)\n}\n```\n\n## Closure - Accessing Outer Variables\n\n```kotlin\nfun countMatches(list: List<String>, prefix: String): Int {\n    var count = 0\n    \n    fun check(item: String) {\n        if (item.startsWith(prefix)) {  // Access prefix\n            count++                      // Modify count\n        }\n    }\n    \n    list.forEach { check(it) }\n    return count\n}\n```',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: collections-overview
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('collections-overview', 1, 'TL;DR', 'Collections Overview',
 E'```kotlin\n// Immutable (read-only)\nval list = listOf(1, 2, 3)\nval set = setOf(1, 2, 3)\nval map = mapOf("a" to 1, "b" to 2)\n\n// Mutable\nval mutableList = mutableListOf(1, 2, 3)\nval mutableSet = mutableSetOf(1, 2, 3)\nval mutableMap = mutableMapOf("a" to 1)\n\nmutableList.add(4)\nmutableMap["c"] = 3\n```',
 2),
('collections-overview', 2, 'Beginner', 'Kotlin Collections Guide',
 E'## Collection Types\n\n| Type | Immutable | Mutable |\n|------|-----------|--------|\n| List | `listOf()` | `mutableListOf()` |\n| Set | `setOf()` | `mutableSetOf()` |\n| Map | `mapOf()` | `mutableMapOf()` |\n\n## Creating Collections\n\n```kotlin\n// Lists\nval numbers = listOf(1, 2, 3)\nval empty = emptyList<String>()\nval fromArray = listOf(*array)\n\n// Sets (no duplicates)\nval uniqueNumbers = setOf(1, 1, 2)  // Contains 1, 2\n\n// Maps\nval ages = mapOf("Alice" to 30, "Bob" to 25)\n```\n\n## Accessing Elements\n\n```kotlin\nlist[0]           // First element\nlist.first()      // First element\nlist.last()       // Last element\nlist.getOrNull(10) // Null if out of bounds\n\nmap["key"]        // Value or null\nmap.getValue("key") // Value or throws\n```',
 6),
('collections-overview', 3, 'Intermediate', 'Collection Implementation Details',
 E'## Read-Only vs Immutable\n\n```kotlin\nval list: List<Int> = mutableListOf(1, 2, 3)\n// list.add(4)  // Compile error - List has no add()\n\n// But the underlying list is still mutable!\nval mutable = list as MutableList<Int>\nmutable.add(4)  // Works! list now has 4 elements\n```\n\n**Best practice:** Use truly immutable collections when needed:\n```kotlin\nval immutable = listOf(1, 2, 3).toImmutableList() // kotlinx.collections.immutable\n```\n\n## ArrayList vs LinkedList\n\n```kotlin\nval arrayList = ArrayList<Int>()   // Backed by array\nval linkedList = LinkedList<Int>() // Doubly linked\n\n// mutableListOf() returns ArrayList by default\n```\n\n## Map Implementations\n\n```kotlin\nval hashMap = hashMapOf("a" to 1)      // HashMap\nval linkedMap = linkedMapOf("a" to 1)   // Preserves order\nval sortedMap = sortedMapOf("a" to 1)   // TreeMap, sorted keys\n```',
 10)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: collection-operations
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('collection-operations', 1, 'TL;DR', 'Collection Operations Cheat Sheet',
 E'```kotlin\nval list = listOf(1, 2, 3, 4, 5)\n\nlist.filter { it > 2 }      // [3, 4, 5]\nlist.map { it * 2 }         // [2, 4, 6, 8, 10]\nlist.find { it > 2 }        // 3 (first match)\nlist.any { it > 4 }         // true\nlist.all { it > 0 }         // true\nlist.sumOf { it }           // 15\nlist.groupBy { it % 2 }     // {1=[1,3,5], 0=[2,4]}\n```',
 2),
('collection-operations', 2, 'Beginner', 'Essential Collection Operations',
 E'## Filtering\n\n```kotlin\nval numbers = listOf(1, 2, 3, 4, 5)\n\nnumbers.filter { it > 2 }        // [3, 4, 5]\nnumbers.filterNot { it > 2 }     // [1, 2]\nnumbers.filterNotNull()          // Remove nulls\nnumbers.take(3)                  // [1, 2, 3]\nnumbers.drop(2)                  // [3, 4, 5]\n```\n\n## Transforming\n\n```kotlin\nnumbers.map { it * 2 }           // [2, 4, 6, 8, 10]\nnumbers.mapNotNull { it.takeIf { it > 2 } }  // [3, 4, 5]\nnumbers.flatMap { listOf(it, it) } // [1,1,2,2,3,3,4,4,5,5]\n```\n\n## Finding\n\n```kotlin\nnumbers.find { it > 2 }          // 3 (first or null)\nnumbers.first { it > 2 }         // 3 (first or throws)\nnumbers.firstOrNull { it > 10 }  // null\nnumbers.last { it < 4 }          // 3\n```\n\n## Aggregating\n\n```kotlin\nnumbers.sum()                    // 15\nnumbers.average()                // 3.0\nnumbers.count { it > 2 }         // 3\nnumbers.maxOrNull()              // 5\nnumbers.minOrNull()              // 1\n```',
 8),
('collection-operations', 3, 'Intermediate', 'Advanced Collection Operations',
 E'## Grouping and Associating\n\n```kotlin\nval words = listOf("apple", "banana", "apricot", "berry")\n\nwords.groupBy { it.first() }\n// {a=[apple, apricot], b=[banana, berry]}\n\nwords.associateBy { it.first() }\n// {a=apricot, b=berry}  // Last wins\n\nwords.associateWith { it.length }\n// {apple=5, banana=6, apricot=7, berry=5}\n```\n\n## Folding and Reducing\n\n```kotlin\nval numbers = listOf(1, 2, 3, 4)\n\nnumbers.reduce { acc, n -> acc + n }  // 10\nnumbers.fold(10) { acc, n -> acc + n } // 20 (starts at 10)\nnumbers.runningFold(0) { acc, n -> acc + n } // [0, 1, 3, 6, 10]\n```\n\n## Chaining Operations\n\n```kotlin\ndata class Person(val name: String, val age: Int, val city: String)\n\npeople\n    .filter { it.age >= 18 }\n    .groupBy { it.city }\n    .mapValues { (_, persons) -> persons.map { it.name } }\n// {NYC=[Alice, Bob], LA=[Charlie]}\n```\n\n## Sorting\n\n```kotlin\nlist.sorted()                    // Natural order\nlist.sortedDescending()          // Reverse order\nlist.sortedBy { it.name }        // By property\nlist.sortedWith(compareBy({ it.age }, { it.name })) // Multiple\n```',
 12)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: sequences
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('sequences', 1, 'TL;DR', 'Sequences for Lazy Processing',
 E'```kotlin\n// Collection: processes all elements at each step\nlistOf(1, 2, 3, 4, 5)\n    .map { it * 2 }     // Creates new list\n    .filter { it > 4 }  // Creates another list\n\n// Sequence: processes one element through all steps\nlistOf(1, 2, 3, 4, 5).asSequence()\n    .map { it * 2 }     // Lazy\n    .filter { it > 4 }  // Lazy\n    .toList()           // Terminal - triggers processing\n```',
 2),
('sequences', 2, 'Beginner', 'Understanding Sequences',
 E'## When to Use Sequences\n\n- Large collections (10,000+ elements)\n- Chained operations (3+ transformations)\n- Early termination needed (first, take)\n\n## Collection vs Sequence\n\n```kotlin\n// Collection - eager, creates intermediate lists\nlistOf(1, 2, 3, 4, 5)\n    .map { println("map $it"); it * 2 }\n    .filter { println("filter $it"); it > 4 }\n// Prints: map 1, map 2, map 3, map 4, map 5, filter 2, filter 4...\n\n// Sequence - lazy, processes element by element\nlistOf(1, 2, 3, 4, 5).asSequence()\n    .map { println("map $it"); it * 2 }\n    .filter { println("filter $it"); it > 4 }\n    .toList()\n// Prints: map 1, filter 2, map 2, filter 4, map 3, filter 6...\n```\n\n## Creating Sequences\n\n```kotlin\nlist.asSequence()                    // From collection\nsequenceOf(1, 2, 3)                  // Direct creation\ngenerateSequence(1) { it + 1 }       // Infinite!\ngenerateSequence(1) { if (it < 10) it + 1 else null } // Finite\n```',
 8),
('sequences', 3, 'Intermediate', 'Sequence Operations Deep Dive',
 E'## Intermediate vs Terminal Operations\n\n**Intermediate** (lazy, return Sequence):\n- map, filter, take, drop, distinct, sorted\n\n**Terminal** (trigger processing):\n- toList, toSet, first, count, sum, forEach\n\n```kotlin\nval seq = sequenceOf(1, 2, 3)\n    .map { it * 2 }   // Nothing happens yet\n    .filter { it > 2 } // Still nothing\n\n// Processing starts here:\nseq.toList()  // [4, 6]\n```\n\n## Short-Circuiting\n\n```kotlin\n// Finds first even number > 100 without processing entire list\n(1..1_000_000).asSequence()\n    .map { it * 2 }\n    .filter { it > 100 }\n    .first()  // 102 - stops immediately\n```\n\n## Infinite Sequences\n\n```kotlin\nval fibonacci = generateSequence(Pair(0, 1)) { \n    Pair(it.second, it.first + it.second) \n}.map { it.first }\n\nfibonacci.take(10).toList()  // [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]\n```',
 12),
('sequences', 4, 'Deep Dive', 'Sequence Internals',
 E'## How Sequences Work\n\nSequences use iterators internally:\n\n```kotlin\ninterface Sequence<out T> {\n    operator fun iterator(): Iterator<T>\n}\n```\n\nEach operation wraps the previous iterator:\n\n```kotlin\nsequenceOf(1, 2, 3)\n    .map { it * 2 }    // MapSequence wraps original\n    .filter { it > 2 } // FilterSequence wraps MapSequence\n```\n\n## Memory Characteristics\n\n| Approach | Memory | CPU |\n|----------|--------|-----|\n| Collection chain | O(n) per step | Batch processing |\n| Sequence | O(1) intermediate | Per-element overhead |\n\n## When NOT to Use Sequences\n\n1. Small collections (< 1000 elements)\n2. Single operation (no chaining)\n3. Need to iterate multiple times (sequences are single-use)\n4. Operations that need all elements (sorted, reversed)\n\n## Sequence vs Java Streams\n\n```kotlin\n// Kotlin Sequence\nlist.asSequence().filter { ... }.map { ... }.toList()\n\n// Java Stream\nlist.stream().filter { ... }.map { ... }.collect(Collectors.toList())\n```\n\nSequences are simpler (no parallel) but sufficient for most cases.',
 15)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- =====================================================
-- CLASSES & OBJECTS
-- =====================================================

-- Topic: constructors
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('constructors', 1, 'TL;DR', 'Constructors Quick Guide',
 E'```kotlin\n// Primary constructor (in header)\nclass User(val name: String, var age: Int = 0)\n\n// With init block\nclass User(val name: String) {\n    init { require(name.isNotBlank()) }\n}\n\n// Secondary constructor\nclass User {\n    constructor(name: String) : this(name, 0)\n    constructor(name: String, age: Int) { ... }\n}\n```',
 2),
('constructors', 2, 'Beginner', 'Understanding Constructors',
 E'## Primary Constructor\n\nThe most concise way to define a class:\n\n```kotlin\nclass Person(val name: String, var age: Int)\n```\n\nThis creates:\n- Constructor with two parameters\n- `name` property (immutable)\n- `age` property (mutable)\n\n## Init Blocks\n\nFor initialization logic:\n\n```kotlin\nclass Person(val name: String) {\n    val upperName: String\n    \n    init {\n        require(name.isNotBlank()) { "Name required" }\n        upperName = name.uppercase()\n    }\n}\n```\n\n## Default Values\n\n```kotlin\nclass User(\n    val name: String,\n    val email: String = "",\n    val active: Boolean = true\n)\n\nUser("John")                    // Uses defaults\nUser("John", "john@test.com")   // Override email\n```',
 6),
('constructors', 3, 'Intermediate', 'Advanced Constructor Patterns',
 E'## Secondary Constructors\n\n```kotlin\nclass Person {\n    val name: String\n    val age: Int\n    \n    constructor(name: String) : this(name, 0)\n    \n    constructor(name: String, age: Int) {\n        this.name = name\n        this.age = age\n    }\n}\n```\n\n## Delegation to Primary\n\n```kotlin\nclass User(val name: String, val age: Int) {\n    constructor(name: String) : this(name, 0) {\n        println("Secondary called")\n    }\n}\n```\n\n## Private Constructor\n\n```kotlin\nclass Singleton private constructor() {\n    companion object {\n        val instance = Singleton()\n    }\n}\n```\n\n## Multiple Init Blocks\n\n```kotlin\nclass Example(val x: Int) {\n    init { println("First init: $x") }\n    val y = x * 2\n    init { println("Second init: $y") }\n}\n// Order: primary params → init/property interleaved → secondary body\n```',
 10)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: properties
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('properties', 1, 'TL;DR', 'Properties Essentials',
 E'```kotlin\nclass User(val name: String, var age: Int)  // Constructor properties\n\nclass Rectangle(val width: Int, val height: Int) {\n    val area: Int get() = width * height  // Computed property\n    \n    var counter: Int = 0\n        private set  // Public get, private set\n}\n```',
 2),
('properties', 2, 'Beginner', 'Properties vs Fields',
 E'## Java Fields vs Kotlin Properties\n\n```java\n// Java - fields + getters/setters\npublic class User {\n    private String name;\n    public String getName() { return name; }\n    public void setName(String name) { this.name = name; }\n}\n```\n\n```kotlin\n// Kotlin - properties\nclass User(var name: String)\n```\n\n## Custom Accessors\n\n```kotlin\nclass Rectangle(val width: Int, val height: Int) {\n    // Computed property - calculated each time\n    val area: Int\n        get() = width * height\n    \n    // Custom setter\n    var text: String = ""\n        set(value) {\n            field = value.trim()  // ''field'' = backing field\n        }\n}\n```\n\n## Visibility Modifiers\n\n```kotlin\nvar counter: Int = 0\n    private set  // Setter is private\n\nval computed: Int\n    internal get() = calculateValue()  // Getter is internal\n```',
 6),
('properties', 3, 'Intermediate', 'Advanced Property Patterns',
 E'## Backing Fields\n\nUse `field` identifier in custom accessors:\n\n```kotlin\nvar name: String = ""\n    set(value) {\n        println("Setting name to $value")\n        field = value  // Access backing field\n    }\n```\n\n**No backing field generated if:**\n- val with custom getter (no default)\n- var with custom getter AND setter (no default/field usage)\n\n## Backing Properties\n\n```kotlin\nclass StringList {\n    private val _items = mutableListOf<String>()\n    val items: List<String> get() = _items  // Read-only view\n    \n    fun add(item: String) { _items.add(item) }\n}\n```\n\n## Late Initialization\n\n```kotlin\nclass MyTest {\n    lateinit var service: Service\n    \n    fun setup() {\n        service = Service()\n    }\n    \n    fun test() {\n        if (::service.isInitialized) {\n            service.doSomething()\n        }\n    }\n}\n```',
 10)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: data-classes
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('data-classes', 1, 'TL;DR', 'Data Classes Summary',
 E'```kotlin\ndata class User(val name: String, val age: Int)\n\nval user = User("John", 30)\nuser.toString()     // User(name=John, age=30)\nuser.copy(age = 31) // New instance with age=31\nuser == User("John", 30)  // true (structural equality)\nval (name, age) = user    // Destructuring\n```',
 2),
('data-classes', 2, 'Beginner', 'Data Classes Explained',
 E'## Auto-Generated Methods\n\nThe `data` keyword generates:\n\n| Method | Purpose |\n|--------|--------|\n| `equals()` | Structural equality based on constructor props |\n| `hashCode()` | Consistent with equals |\n| `toString()` | "ClassName(prop1=val1, prop2=val2)" |\n| `copy()` | Create modified copies |\n| `componentN()` | For destructuring |\n\n## Example\n\n```kotlin\ndata class User(val name: String, val email: String)\n\nval user1 = User("Alice", "alice@example.com")\nval user2 = User("Alice", "alice@example.com")\n\nprintln(user1 == user2)  // true - same data\nprintln(user1)           // User(name=Alice, email=alice@example.com)\n\nval user3 = user1.copy(email = "new@example.com")\nval (name, email) = user1  // Destructuring\n```\n\n## Requirements\n\n- Primary constructor must have at least one parameter\n- All parameters must be `val` or `var`\n- Cannot be abstract, open, sealed, or inner',
 6),
('data-classes', 3, 'Intermediate', 'Data Class Patterns',
 E'## Properties in Body\n\nOnly constructor properties are used in generated methods:\n\n```kotlin\ndata class User(val id: Long, val name: String) {\n    var loginCount: Int = 0  // NOT in equals/hashCode!\n}\n\nval u1 = User(1, "John").apply { loginCount = 5 }\nval u2 = User(1, "John").apply { loginCount = 10 }\nu1 == u2  // true - loginCount ignored\n```\n\n## Copy with Complex Objects\n\n```kotlin\ndata class Person(val name: String, val address: Address)\ndata class Address(var city: String)\n\nval p1 = Person("John", Address("NYC"))\nval p2 = p1.copy()  // Shallow copy!\np2.address.city = "LA"\nprintln(p1.address.city)  // "LA" - same Address object!\n```\n\n## Data Classes with Inheritance\n\n```kotlin\n// Can implement interfaces\ndata class User(val name: String) : Serializable\n\n// Cannot extend other classes (all data classes are final)\n// But can be extended using sealed class hierarchy\nsealed class Result\ndata class Success(val data: String) : Result()\ndata class Error(val message: String) : Result()\n```',
 10)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: enum-classes
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('enum-classes', 1, 'TL;DR', 'Enum Classes',
 E'```kotlin\nenum class Direction { NORTH, SOUTH, EAST, WEST }\n\nenum class Color(val rgb: Int) {\n    RED(0xFF0000),\n    GREEN(0x00FF00),\n    BLUE(0x0000FF);\n    \n    fun isDark() = rgb < 0x808080\n}\n\nColor.RED.rgb        // 16711680\nColor.valueOf("RED") // Color.RED\nColor.values()       // Array of all values\n```',
 2),
('enum-classes', 2, 'Beginner', 'Working with Enums',
 E'## Basic Enum\n\n```kotlin\nenum class Direction {\n    NORTH, SOUTH, EAST, WEST\n}\n\nval dir = Direction.NORTH\nprintln(dir.name)    // "NORTH"\nprintln(dir.ordinal) // 0\n```\n\n## Enum with Properties\n\n```kotlin\nenum class Planet(val mass: Double, val radius: Double) {\n    EARTH(5.97e24, 6.37e6),\n    MARS(6.42e23, 3.39e6);\n    \n    val surfaceGravity = mass / (radius * radius)\n}\n```\n\n## Enum with Methods\n\n```kotlin\nenum class Operation {\n    ADD {\n        override fun apply(a: Int, b: Int) = a + b\n    },\n    SUBTRACT {\n        override fun apply(a: Int, b: Int) = a - b\n    };\n    \n    abstract fun apply(a: Int, b: Int): Int\n}\n\nOperation.ADD.apply(5, 3)  // 8\n```',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: sealed-classes
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('sealed-classes', 1, 'TL;DR', 'Sealed Classes',
 E'```kotlin\nsealed class Result<out T>\ndata class Success<T>(val data: T) : Result<T>()\ndata class Error(val message: String) : Result<Nothing>()\nobject Loading : Result<Nothing>()\n\nfun handle(result: Result<String>) = when (result) {\n    is Success -> result.data\n    is Error -> result.message\n    Loading -> "Loading..."\n    // No else needed - compiler knows all subclasses!\n}\n```',
 2),
('sealed-classes', 2, 'Beginner', 'Understanding Sealed Classes',
 E'## What Are Sealed Classes?\n\nSealed classes restrict inheritance to a known set of subclasses. All subclasses must be defined in the same package.\n\n## Why Use Them?\n\n1. **Exhaustive when** - Compiler ensures all cases handled\n2. **Type safety** - Known hierarchy at compile time\n3. **Pattern matching** - Clean, safe branching\n\n## Example: API Result\n\n```kotlin\nsealed class ApiResult\ndata class Success(val data: String) : ApiResult()\ndata class HttpError(val code: Int) : ApiResult()\ndata class NetworkError(val exception: Exception) : ApiResult()\n\nfun handle(result: ApiResult): String = when (result) {\n    is Success -> "Data: ${result.data}"\n    is HttpError -> "HTTP ${result.code}"\n    is NetworkError -> "Network: ${result.exception.message}"\n}\n```\n\nIf you add a new subclass, the compiler forces you to handle it!',
 6),
('sealed-classes', 3, 'Intermediate', 'Advanced Sealed Patterns',
 E'## Sealed Interfaces (Kotlin 1.5+)\n\n```kotlin\nsealed interface Error\nclass IOError(val file: String) : Error\nclass DBError(val query: String) : Error\n\n// Can implement multiple sealed interfaces\nclass CriticalError : Error, Loggable\n```\n\n## Nested Sealed Hierarchies\n\n```kotlin\nsealed class UiState {\n    object Loading : UiState()\n    \n    sealed class Content : UiState() {\n        data class Data(val items: List<Item>) : Content()\n        object Empty : Content()\n    }\n    \n    data class Error(val message: String) : UiState()\n}\n```\n\n## Sealed vs Enum\n\n| Feature | Enum | Sealed |\n|---------|------|--------|\n| Instances | Single per value | Multiple |\n| State | Shared | Per instance |\n| Subclassing | No | Yes (data class, object) |\n| Use case | Fixed values | Different types/states |\n\n## Generic Sealed Classes\n\n```kotlin\nsealed class Either<out L, out R>\ndata class Left<L>(val value: L) : Either<L, Nothing>()\ndata class Right<R>(val value: R) : Either<Nothing, R>()\n```',
 10),
('sealed-classes', 4, 'Deep Dive', 'Sealed Classes Internals',
 E'## Bytecode Analysis\n\n```kotlin\nsealed class Result\n```\n\nCompiles to:\n```java\npublic abstract class Result {\n    private Result() {} // Private constructor\n    // Synthetic constructor for subclasses in same package\n}\n```\n\n## Module-Level Sealing\n\nSince Kotlin 1.5, subclasses can be in different files (same package):\n\n```kotlin\n// Result.kt\nsealed class Result\n\n// Success.kt (same package)\ndata class Success(val data: String) : Result()\n\n// Error.kt (same package)\ndata class Error(val msg: String) : Result()\n```\n\n## Performance: When with Sealed\n\n```kotlin\nwhen (result) {\n    is Success -> ...\n    is Error -> ...\n}\n```\n\nCompiles to efficient `instanceof` checks. JIT can further optimize known hierarchies.\n\n## Exhaustive When at Compile Time\n\nThe compiler uses a `@WhenMappings` annotation internally to track all subclasses and verify exhaustiveness.\n\n```kotlin\n// This fails to compile if you add a new subclass\nfun process(r: Result) = when (r) {\n    is Success -> "ok"\n    is Error -> "error"\n    // Compiler error if Loading added to sealed class\n}\n```',
 15)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: object-declarations
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('object-declarations', 1, 'TL;DR', 'Object Declarations',
 E'```kotlin\n// Singleton\nobject Logger {\n    fun log(msg: String) = println("[LOG] $msg")\n}\nLogger.log("Hello")  // No instantiation needed\n\n// Companion object (class-level members)\nclass User private constructor(val name: String) {\n    companion object {\n        fun create(name: String) = User(name)\n    }\n}\nUser.create("John")\n```',
 2),
('object-declarations', 2, 'Beginner', 'Objects and Companions',
 E'## Object Declaration (Singleton)\n\n```kotlin\nobject DatabaseConfig {\n    val url = "jdbc:postgresql://localhost/db"\n    val maxConnections = 10\n    \n    fun connect() { ... }\n}\n\n// Usage - single instance, thread-safe\nDatabaseConfig.connect()\n```\n\n## Companion Object\n\n```kotlin\nclass User(val name: String) {\n    companion object {\n        const val MAX_NAME_LENGTH = 50\n        \n        fun create(name: String): User {\n            require(name.length <= MAX_NAME_LENGTH)\n            return User(name)\n        }\n    }\n}\n\nUser.MAX_NAME_LENGTH  // Access like static\nUser.create("John")   // Factory method\n```\n\n## Object Expression (Anonymous)\n\n```kotlin\nval comparator = object : Comparator<Int> {\n    override fun compare(a: Int, b: Int) = b - a\n}\n```',
 6),
('object-declarations', 3, 'Intermediate', 'Advanced Object Patterns',
 E'## Named Companion Objects\n\n```kotlin\nclass User {\n    companion object Factory {\n        fun create() = User()\n    }\n}\n\nUser.Factory.create()  // Explicit name\nUser.create()          // Also works\n```\n\n## Companion Object Implementing Interface\n\n```kotlin\ninterface Factory<T> {\n    fun create(): T\n}\n\nclass User private constructor() {\n    companion object : Factory<User> {\n        override fun create() = User()\n    }\n}\n\nfun <T> createInstance(factory: Factory<T>): T = factory.create()\ncreateInstance(User)  // Pass companion object\n```\n\n## Extension on Companion\n\n```kotlin\nclass User { companion object }\n\nfun User.Companion.fromJson(json: String): User { ... }\n\nUser.fromJson("{}")  // Looks like static method\n```\n\n## Object vs Class\n\n| Feature | object | class |\n|---------|--------|-------|\n| Instances | Single (singleton) | Multiple |\n| Constructor | No | Yes |\n| Inheritance | Can extend/implement | Can extend/implement |\n| When to use | Stateless utilities, config | Stateful entities |',
 10)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- =====================================================
-- LAMBDAS & FUNCTIONAL
-- =====================================================

-- Topic: lambdas-basics
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('lambdas-basics', 1, 'TL;DR', 'Lambda Syntax',
 E'```kotlin\n// Full syntax\nval sum: (Int, Int) -> Int = { a, b -> a + b }\n\n// Single parameter: use ''it''\nval double: (Int) -> Int = { it * 2 }\n\n// Trailing lambda\nlistOf(1, 2, 3).filter { it > 1 }\n\n// Lambda with receiver\nval greet: String.() -> String = { "Hello, $this!" }\n"World".greet()  // "Hello, World!"\n```',
 2),
('lambdas-basics', 2, 'Beginner', 'Understanding Lambdas',
 E'## What is a Lambda?\n\nA lambda is an anonymous function that can be passed around:\n\n```kotlin\nval sum = { a: Int, b: Int -> a + b }\nprintln(sum(3, 4))  // 7\n```\n\n## Lambda Syntax\n\n```kotlin\n{ parameters -> body }\n\n// No parameters\nval sayHi = { println("Hi") }\n\n// One parameter (use ''it'')\nval double = { x: Int -> x * 2 }\nval double2: (Int) -> Int = { it * 2 }  // ''it'' = implicit single param\n\n// Multiple parameters\nval sum = { a: Int, b: Int -> a + b }\n```\n\n## Trailing Lambda\n\nIf the last parameter is a lambda, move it outside parentheses:\n\n```kotlin\nlist.filter({ it > 0 })   // Inside\nlist.filter() { it > 0 }  // Outside\nlist.filter { it > 0 }    // Parentheses removed\n```',
 6),
('lambdas-basics', 3, 'Intermediate', 'Lambda Advanced Features',
 E'## Destructuring in Lambdas\n\n```kotlin\nval map = mapOf("a" to 1, "b" to 2)\nmap.forEach { (key, value) ->\n    println("$key = $value")\n}\n```\n\n## Unused Parameters\n\n```kotlin\nmap.forEach { _, value ->  // _ ignores key\n    println(value)\n}\n```\n\n## Returning from Lambdas\n\n```kotlin\n// Return from lambda (non-local return from inline function)\nlistOf(1, 2, 3).forEach {\n    if (it == 2) return  // Returns from enclosing function!\n    println(it)\n}\n\n// Return from lambda only (labeled return)\nlistOf(1, 2, 3).forEach {\n    if (it == 2) return@forEach  // Continue to next iteration\n    println(it)\n}\n```\n\n## Closures\n\n```kotlin\nvar sum = 0\nlistOf(1, 2, 3).forEach { sum += it }  // Captures and modifies sum\nprintln(sum)  // 6\n```',
 10)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: higher-order-functions
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('higher-order-functions', 1, 'TL;DR', 'Higher-Order Functions',
 E'```kotlin\n// Takes function as parameter\nfun operate(a: Int, b: Int, op: (Int, Int) -> Int): Int = op(a, b)\noperate(5, 3, { a, b -> a + b })  // 8\noperate(5, 3) { a, b -> a * b }   // 15\n\n// Returns function\nfun multiplier(factor: Int): (Int) -> Int = { it * factor }\nval triple = multiplier(3)\ntriple(5)  // 15\n```',
 2),
('higher-order-functions', 2, 'Beginner', 'Functions as Parameters',
 E'## What is a Higher-Order Function?\n\nA function that takes functions as parameters or returns a function.\n\n## Taking a Function Parameter\n\n```kotlin\nfun process(items: List<Int>, action: (Int) -> Unit) {\n    for (item in items) {\n        action(item)\n    }\n}\n\nprocess(listOf(1, 2, 3)) { println(it) }\n```\n\n## Function Type Syntax\n\n```kotlin\n(ParamTypes) -> ReturnType\n\n(Int) -> String           // Takes Int, returns String\n(Int, Int) -> Int         // Takes two Ints, returns Int\n() -> Unit                // No params, no return\n(String) -> (Int) -> Int  // Returns a function\n```\n\n## Common Higher-Order Functions\n\n```kotlin\nlist.filter { it > 0 }    // Predicate: (T) -> Boolean\nlist.map { it * 2 }       // Transform: (T) -> R\nlist.forEach { print(it) } // Action: (T) -> Unit\nlist.reduce { a, b -> a + b } // Combine: (T, T) -> T\n```',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: scope-functions
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('scope-functions', 1, 'TL;DR', 'Scope Functions',
 E'```kotlin\nval user = User().apply { name = "John"; age = 30 }  // Configure, return object\nuser.let { sendEmail(it) }                            // Transform, return result\nuser.also { log(it) }                                 // Side effect, return object\nuser.run { "$name is $age" }                          // Run block, return result\nwith(user) { "$name is $age" }                        // Same as run, different syntax\n```\n\n| Function | Object ref | Return value |\n|----------|------------|-------------|\n| let | it | Lambda result |\n| run | this | Lambda result |\n| with | this | Lambda result |\n| apply | this | Context object |\n| also | it | Context object |',
 3),
('scope-functions', 2, 'Beginner', 'Understanding Scope Functions',
 E'## let - Transform with it\n\n```kotlin\nval length = "Hello".let { it.length }  // 5\n\n// Great for null checks\nuser?.let { \n    sendEmail(it.email)\n}\n```\n\n## apply - Configure with this\n\n```kotlin\nval user = User().apply {\n    name = "John"   // this.name\n    age = 30        // this.age\n}\n```\n\n## also - Side effects with it\n\n```kotlin\nval numbers = mutableListOf(1, 2, 3)\n    .also { println("Before: $it") }\n    .apply { add(4) }\n    .also { println("After: $it") }\n```\n\n## run - Execute with this\n\n```kotlin\nval greeting = "Hello".run {\n    "$this World!"  // this is "Hello"\n}\n```\n\n## with - Non-extension run\n\n```kotlin\nval result = with(StringBuilder()) {\n    append("Hello")\n    append(" World")\n    toString()\n}\n```',
 8),
('scope-functions', 3, 'Intermediate', 'Choosing the Right Scope Function',
 E'## Decision Matrix\n\n| Need | Use | Why |\n|------|-----|-----|\n| Configure new object | apply | Returns object, uses this |\n| Null-safe transform | let | Works with ?., returns result |\n| Execute side effect | also | Returns object, uses it |\n| Compute from object | run/with | Uses this, returns result |\n\n## Chaining Pattern\n\n```kotlin\nfun createUser(name: String) = User()\n    .apply { this.name = name }\n    .also { logger.info("Created user: $it") }\n    .let { repository.save(it) }\n```\n\n## Null Handling Patterns\n\n```kotlin\n// Execute only if non-null\nuser?.let { process(it) }\n\n// Execute if non-null, with logging\nuser?.also { log("Processing $it") }?.let { process(it) }\n\n// Execute block if non-null\nuser?.run { process(this) }\n```\n\n## Anti-patterns\n\n```kotlin\n// Don''t: nested scope functions\nuser.let { u ->\n    u.address.let { a ->\n        // Hard to read\n    }\n}\n\n// Do: chain or use regular code\nval address = user.address\nprocess(address)\n```',
 12)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: inline-functions
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('inline-functions', 1, 'TL;DR', 'Inline Functions',
 E'```kotlin\ninline fun measure(block: () -> Unit) {\n    val start = System.currentTimeMillis()\n    block()  // Inlined at call site\n    println("Took ${System.currentTimeMillis() - start}ms")\n}\n\n// No lambda object created!\nmeasure { Thread.sleep(100) }\n```\n\n`inline` copies function body to call site, avoiding lambda overhead.',
 2),
('inline-functions', 2, 'Beginner', 'Why Inline Functions?',
 E'## Lambda Overhead\n\nEach lambda creates an object:\n\n```kotlin\nfun repeat(times: Int, action: () -> Unit) {\n    for (i in 0 until times) action()  // action is an object\n}\n```\n\n## Inline Eliminates Overhead\n\n```kotlin\ninline fun repeat(times: Int, action: () -> Unit) {\n    for (i in 0 until times) action()\n}\n\n// Call site\nrepeat(3) { println("Hi") }\n\n// Becomes (conceptually)\nfor (i in 0 until 3) { println("Hi") }\n```\n\n## Benefits\n\n1. No lambda object allocation\n2. No virtual call overhead\n3. Enables non-local returns\n4. Enables reified type parameters',
 6),
('inline-functions', 3, 'Intermediate', 'Advanced Inline Features',
 E'## noinline Parameter\n\n```kotlin\ninline fun foo(inlined: () -> Unit, noinline notInlined: () -> Unit) {\n    inlined()      // Will be inlined\n    store(notInlined)  // Can be stored (not inlined)\n}\n```\n\n## crossinline Parameter\n\n```kotlin\ninline fun createRunnable(crossinline action: () -> Unit): Runnable {\n    return Runnable { action() }  // action in non-local context\n}\n```\n\n`crossinline` prevents non-local returns (since action runs in different context).\n\n## Non-Local Returns\n\n```kotlin\ninline fun forEach(items: List<Int>, action: (Int) -> Unit) {\n    for (item in items) action(item)\n}\n\nfun findFirst(): Int? {\n    forEach(listOf(1, 2, 3)) {\n        if (it == 2) return it  // Returns from findFirst!\n    }\n    return null\n}\n```\n\n## Reified Type Parameters\n\n```kotlin\ninline fun <reified T> isInstance(value: Any): Boolean {\n    return value is T  // Works because T is reified\n}\n\nisInstance<String>("hello")  // true\n```',
 12),
('inline-functions', 4, 'Deep Dive', 'Inline Implementation Details',
 E'## Bytecode Impact\n\n```kotlin\ninline fun twice(action: () -> Unit) {\n    action()\n    action()\n}\n\nfun main() {\n    twice { println("Hi") }\n}\n```\n\nCompiles to:\n```java\npublic static void main(String[] args) {\n    System.out.println("Hi");\n    System.out.println("Hi");\n}\n```\n\nNo `Function` object, no `invoke()` call!\n\n## When NOT to Inline\n\n1. Large function bodies (code bloat)\n2. No lambda parameters (no benefit)\n3. Recursion (impossible)\n4. Need to store/pass the lambda\n\n## Code Size Considerations\n\n```kotlin\n// Bad: Large inline function called many times\ninline fun processLarge(action: () -> Unit) {\n    // 100 lines of code...\n    action()\n}\n\n// Good: Small inline, large extracted\ninline fun process(action: () -> Unit) {\n    setupInternal()  // Not inlined\n    action()         // Inlined\n}\n\nfun setupInternal() { /* 100 lines */ }\n```\n\n## Reified Internals\n\n```kotlin\ninline fun <reified T> typeOf(): String = T::class.java.name\n```\n\nCompiler substitutes actual type at call site:\n```java\n// typeOf<String>() becomes:\nString.class.getName()\n```',
 15)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- =====================================================
-- COROUTINES
-- =====================================================

-- Topic: coroutines-basics
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('coroutines-basics', 1, 'TL;DR', 'Coroutines Essentials',
 E'```kotlin\n// Launch coroutine (fire and forget)\nscope.launch {\n    delay(1000)  // Suspends, doesn''t block thread\n    println("Hello")\n}\n\n// Async coroutine (returns result)\nval result = scope.async {\n    fetchData()\n}.await()\n\n// Suspend function\nsuspend fun fetchData(): String {\n    delay(1000)\n    return "Data"\n}\n```',
 2),
('coroutines-basics', 2, 'Beginner', 'Understanding Coroutines',
 E'## What Are Coroutines?\n\nLightweight threads that can suspend without blocking:\n\n```kotlin\n// Blocking (bad for many concurrent ops)\nThread.sleep(1000)\n\n// Suspending (good - thread is free for other work)\ndelay(1000)\n```\n\n## Key Concepts\n\n| Concept | Description |\n|---------|-------------|\n| suspend | Function that can pause and resume |\n| CoroutineScope | Lifecycle boundary for coroutines |\n| launch | Start coroutine, don''t wait for result |\n| async | Start coroutine, get Deferred result |\n\n## Basic Example\n\n```kotlin\nimport kotlinx.coroutines.*\n\nfun main() = runBlocking {\n    launch {\n        delay(1000)\n        println("World!")\n    }\n    println("Hello,")\n}\n// Output: Hello, World!\n```\n\n## Why Not Threads?\n\n```kotlin\n// 100,000 threads = crash\nrepeat(100_000) {\n    thread { Thread.sleep(1000) }\n}\n\n// 100,000 coroutines = fine\nrunBlocking {\n    repeat(100_000) {\n        launch { delay(1000) }\n    }\n}\n```',
 8),
('coroutines-basics', 3, 'Intermediate', 'Coroutine Builders and Scope',
 E'## Coroutine Builders\n\n```kotlin\n// launch - fire and forget, returns Job\nval job = scope.launch {\n    doWork()\n}\njob.cancel()  // Can cancel\n\n// async - returns Deferred with result\nval deferred = scope.async {\n    computeValue()\n}\nval result = deferred.await()  // Get result\n\n// runBlocking - bridges blocking and suspending\nfun main() = runBlocking {\n    // Now we''re in a coroutine\n}\n```\n\n## Structured Concurrency\n\n```kotlin\ncoroutineScope {\n    launch { task1() }\n    launch { task2() }\n}  // Waits for both to complete\n\n// If one fails, all are cancelled\ncoroutineScope {\n    launch { throw Exception() }  // Fails\n    launch { /* Also cancelled */ }\n}\n```\n\n## Parallel Decomposition\n\n```kotlin\nsuspend fun loadData() = coroutineScope {\n    val user = async { fetchUser() }\n    val posts = async { fetchPosts() }\n    \n    UserWithPosts(user.await(), posts.await())\n}\n```',
 12),
('coroutines-basics', 4, 'Deep Dive', 'Coroutines Under the Hood',
 E'## State Machine Transformation\n\n```kotlin\nsuspend fun example() {\n    println("A")\n    delay(1000)  // Suspension point 1\n    println("B")\n    delay(1000)  // Suspension point 2\n    println("C")\n}\n```\n\nCompiler transforms to state machine:\n```java\nclass ExampleContinuation : Continuation {\n    int label = 0;\n    \n    void resumeWith(Object result) {\n        switch (label) {\n            case 0:\n                println("A");\n                label = 1;\n                delay(1000, this);  // Pass continuation\n                return;\n            case 1:\n                println("B");\n                label = 2;\n                delay(1000, this);\n                return;\n            case 2:\n                println("C");\n        }\n    }\n}\n```\n\n## Continuation Passing Style\n\nSuspend functions get extra parameter:\n```kotlin\nsuspend fun fetchUser(): User\n// Becomes:\nfun fetchUser(continuation: Continuation<User>): Any?\n```\n\nReturns `COROUTINE_SUSPENDED` if suspending, or result if ready.\n\n## Memory Model\n\n- Coroutines use heap-allocated state machines\n- Each coroutine: ~100-200 bytes\n- Threads: ~1MB stack each\n- 10,000 coroutines: ~2MB\n- 10,000 threads: ~10GB\n\n## Dispatcher Thread Pools\n\n| Dispatcher | Thread Pool | Use Case |\n|------------|-------------|----------|\n| Default | CPU cores | CPU-intensive |\n| IO | 64 threads | Blocking I/O |\n| Main | Single (UI) | UI updates |\n| Unconfined | Caller thread | Testing |',
 18)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: suspend-functions
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('suspend-functions', 1, 'TL;DR', 'Suspend Functions',
 E'```kotlin\nsuspend fun fetchUser(id: Long): User {\n    delay(1000)  // Suspend point - doesn''t block thread\n    return api.getUser(id)  // Another suspend point\n}\n\n// Can only call from coroutine or another suspend fun\nscope.launch {\n    val user = fetchUser(123)\n}\n```',
 2),
('suspend-functions', 2, 'Beginner', 'Understanding Suspend',
 E'## What Does suspend Mean?\n\n`suspend` marks functions that can pause without blocking:\n\n```kotlin\nsuspend fun loadData(): String {\n    delay(1000)  // Pauses here, releases thread\n    return "Data"  // Resumes and returns\n}\n```\n\n## Calling Suspend Functions\n\n```kotlin\n// From another suspend function\nsuspend fun process() {\n    val data = loadData()  // OK\n}\n\n// From coroutine builder\nscope.launch {\n    val data = loadData()  // OK\n}\n\n// From regular function\nfun regular() {\n    // loadData()  // Error! Cannot call suspend from non-suspend\n}\n```\n\n## Suspend vs Blocking\n\n```kotlin\n// Blocking - thread is stuck\nfun blockingLoad(): String {\n    Thread.sleep(1000)  // Thread blocked!\n    return httpClient.get(url)  // Blocks again\n}\n\n// Suspending - thread is free\nsuspend fun suspendingLoad(): String {\n    delay(1000)  // Thread free for other work\n    return httpClient.getAsync(url).await()\n}\n```',
 6),
('suspend-functions', 3, 'Intermediate', 'Suspend Function Patterns',
 E'## Sequential vs Concurrent\n\n```kotlin\n// Sequential (one after another)\nsuspend fun loadBoth(): Pair<User, Posts> {\n    val user = loadUser()   // Wait for this\n    val posts = loadPosts() // Then this\n    return user to posts    // ~2 seconds total\n}\n\n// Concurrent (in parallel)\nsuspend fun loadBoth(): Pair<User, Posts> = coroutineScope {\n    val user = async { loadUser() }\n    val posts = async { loadPosts() }\n    user.await() to posts.await()  // ~1 second total\n}\n```\n\n## withContext for Switching Dispatchers\n\n```kotlin\nsuspend fun loadFromDisk(): Data {\n    return withContext(Dispatchers.IO) {\n        // This block runs on IO dispatcher\n        File("data.json").readText()\n    }\n}\n```\n\n## Cancellation\n\n```kotlin\nsuspend fun processItems(items: List<Item>) {\n    for (item in items) {\n        ensureActive()  // Check if cancelled\n        // or use yield()\n        process(item)\n    }\n}\n```',
 10)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: flow-basics
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('flow-basics', 1, 'TL;DR', 'Flow Basics',
 E'```kotlin\n// Create a flow\nfun numbers(): Flow<Int> = flow {\n    for (i in 1..3) {\n        delay(100)\n        emit(i)  // Emit values\n    }\n}\n\n// Collect (terminal operation)\nnumbers().collect { value ->\n    println(value)  // 1, 2, 3\n}\n\n// Transform\nnumbers()\n    .map { it * 2 }\n    .filter { it > 2 }\n    .collect { println(it) }  // 4, 6\n```',
 2),
('flow-basics', 2, 'Beginner', 'Understanding Kotlin Flow',
 E'## What is Flow?\n\nFlow is a cold asynchronous stream that emits values sequentially:\n\n```kotlin\nval flow = flow {\n    emit(1)\n    delay(100)\n    emit(2)\n    emit(3)\n}\n```\n\n## Cold vs Hot\n\n- **Cold** (Flow): Produces values when collected\n- **Hot** (SharedFlow): Produces values regardless of collectors\n\n## Creating Flows\n\n```kotlin\n// flow builder\nflow { emit(1); emit(2) }\n\n// From collections\nlistOf(1, 2, 3).asFlow()\n\n// flowOf\nflowOf(1, 2, 3)\n\n// From callback\ncallbackFlow {\n    api.addListener { trySend(it) }\n    awaitClose { api.removeListener() }\n}\n```\n\n## Terminal Operators\n\n```kotlin\nflow.collect { }       // Process each value\nflow.toList()          // Collect to list\nflow.first()           // Get first value\nflow.reduce { a, b -> a + b }  // Combine all\n```',
 8),
('flow-basics', 3, 'Intermediate', 'Flow Operators and Patterns',
 E'## Intermediate Operators\n\n```kotlin\nflowOf(1, 2, 3, 4, 5)\n    .map { it * 2 }           // Transform: 2,4,6,8,10\n    .filter { it > 4 }        // Filter: 6,8,10\n    .take(2)                  // Limit: 6,8\n    .onEach { log(it) }       // Side effect\n    .collect { }\n```\n\n## Error Handling\n\n```kotlin\nflow\n    .catch { e -> emit(defaultValue) }  // Handle upstream errors\n    .onCompletion { e -> log("Done") }  // Finally block\n    .collect { }\n```\n\n## Buffer and Conflate\n\n```kotlin\n// Buffer - producer and collector run concurrently\nflow.buffer().collect { }\n\n// Conflate - skip intermediate values if slow\nflow.conflate().collect { }\n\n// collectLatest - cancel previous if new arrives\nflow.collectLatest { process(it) }\n```\n\n## Combining Flows\n\n```kotlin\n// zip - pairs elements\nflow1.zip(flow2) { a, b -> a to b }\n\n// combine - latest from each\nflow1.combine(flow2) { a, b -> a to b }\n\n// flatMapConcat - sequential\nflow1.flatMapConcat { fetchDetails(it) }\n```',
 12),
('flow-basics', 4, 'Deep Dive', 'Flow Internals',
 E'## Flow is Just an Interface\n\n```kotlin\ninterface Flow<out T> {\n    suspend fun collect(collector: FlowCollector<T>)\n}\n\ninterface FlowCollector<in T> {\n    suspend fun emit(value: T)\n}\n```\n\n## Cold Stream Mechanics\n\n```kotlin\nval flow = flow {\n    println("Flow started")\n    emit(1)\n}\n\nprintln("Flow created")  // Prints first\nflow.collect { }         // "Flow started" prints here\nflow.collect { }         // Prints again! Each collect restarts\n```\n\n## Context Preservation\n\nFlow preserves context - can''t emit from different dispatcher:\n\n```kotlin\nflow {\n    withContext(Dispatchers.IO) {\n        emit(1)  // Error! Context violation\n    }\n}\n\n// Correct: use flowOn\nflow { emit(1) }\n    .flowOn(Dispatchers.IO)  // Changes upstream context\n```\n\n## StateFlow vs SharedFlow\n\n| Feature | StateFlow | SharedFlow |\n|---------|-----------|------------|\n| Initial value | Required | None |\n| Replay | 1 (always latest) | Configurable |\n| Equality | Conflates equal values | Emits all |\n| Use case | UI state | Events |\n\n```kotlin\nval state = MutableStateFlow(0)\nval events = MutableSharedFlow<Event>()\n```',
 15)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- =====================================================
-- GENERICS
-- =====================================================

-- Topic: generics-basics
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('generics-basics', 1, 'TL;DR', 'Generics Basics',
 E'```kotlin\n// Generic class\nclass Box<T>(val value: T)\nval box = Box("Hello")  // Box<String>\n\n// Generic function\nfun <T> singleton(item: T): List<T> = listOf(item)\nval list = singleton(42)  // List<Int>\n\n// Constraints\nfun <T : Comparable<T>> sort(list: List<T>) { }\n```',
 2),
('generics-basics', 2, 'Beginner', 'Understanding Generics',
 E'## What Are Generics?\n\nGenerics allow writing code that works with multiple types:\n\n```kotlin\n// Without generics - need separate classes\nclass IntBox(val value: Int)\nclass StringBox(val value: String)\n\n// With generics - one class for all\nclass Box<T>(val value: T)\nval intBox = Box(42)\nval stringBox = Box("Hello")\n```\n\n## Generic Classes\n\n```kotlin\nclass Container<T>(private var value: T) {\n    fun get(): T = value\n    fun set(newValue: T) { value = newValue }\n}\n```\n\n## Generic Functions\n\n```kotlin\nfun <T> listOfOne(item: T): List<T> = listOf(item)\n\nval ints = listOfOne(1)        // List<Int>\nval strings = listOfOne("hi")  // List<String>\n```\n\n## Type Constraints\n\n```kotlin\nfun <T : Number> double(value: T): Double = value.toDouble() * 2\n\ndouble(5)    // OK\ndouble(3.14) // OK\n// double("hi") // Error: String is not Number\n```',
 6),
('generics-basics', 3, 'Intermediate', 'Generic Constraints and Patterns',
 E'## Multiple Constraints\n\n```kotlin\nfun <T> copyWhenGreater(list: List<T>, threshold: T): List<T>\n    where T : Comparable<T>,\n          T : Cloneable {\n    return list.filter { it > threshold }\n}\n```\n\n## Generic Extension Functions\n\n```kotlin\nfun <T> List<T>.secondOrNull(): T? =\n    if (size >= 2) this[1] else null\n\nfun <K, V> Map<K, V>.getOrDefault(key: K, default: V): V =\n    this[key] ?: default\n```\n\n## Type Projections\n\n```kotlin\n// Read-only projection\nfun copy(from: Array<out Any>, to: Array<Any>) {\n    for (i in from.indices) {\n        to[i] = from[i]\n    }\n}\n\n// Write-only projection\nfun fill(dest: Array<in String>, value: String) {\n    for (i in dest.indices) {\n        dest[i] = value\n    }\n}\n```',
 10)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: generics-variance
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('generics-variance', 1, 'TL;DR', 'Variance: in, out, and invariant',
 E'```kotlin\n// Covariant (out) - can only produce T\ninterface Source<out T> {\n    fun next(): T\n}\n\n// Contravariant (in) - can only consume T\ninterface Consumer<in T> {\n    fun accept(item: T)\n}\n\n// Invariant (default) - can produce and consume\nclass Box<T>(var value: T)\n```\n\n`out` = covariant (subtype preserved)\n`in` = contravariant (subtype reversed)',
 2),
('generics-variance', 2, 'Beginner', 'Understanding Variance',
 E'## The Problem\n\n```kotlin\nopen class Animal\nclass Dog : Animal()\n\n// Is List<Dog> a subtype of List<Animal>?\nval dogs: List<Dog> = listOf(Dog())\nval animals: List<Animal> = dogs  // OK in Kotlin!\n```\n\n## Covariance (out)\n\nIf `Dog` is subtype of `Animal`, then `Source<Dog>` is subtype of `Source<Animal>`:\n\n```kotlin\ninterface Source<out T> {\n    fun next(): T  // Only returns T\n}\n\nval dogSource: Source<Dog> = ...\nval animalSource: Source<Animal> = dogSource  // OK!\n```\n\n## Contravariance (in)\n\nIf `Dog` is subtype of `Animal`, then `Consumer<Animal>` is subtype of `Consumer<Dog>`:\n\n```kotlin\ninterface Consumer<in T> {\n    fun accept(item: T)  // Only accepts T\n}\n\nval animalConsumer: Consumer<Animal> = ...\nval dogConsumer: Consumer<Dog> = animalConsumer  // OK!\n```',
 8),
('generics-variance', 3, 'Intermediate', 'Declaration-Site vs Use-Site Variance',
 E'## Declaration-Site (Kotlin)\n\n```kotlin\ninterface List<out E> {  // Always covariant\n    fun get(index: Int): E\n}\n\ninterface Comparable<in T> {  // Always contravariant\n    fun compareTo(other: T): Int\n}\n```\n\n## Use-Site (Java-style projections)\n\n```kotlin\nfun copy(from: Array<out Any>, to: Array<Any>) {\n    // from is projected - can only read\n}\n\nfun fill(dest: Array<in String>, value: String) {\n    // dest is projected - can only write\n}\n```\n\n## Star Projection\n\n```kotlin\nfun printAll(list: List<*>) {  // Unknown type\n    for (item in list) {\n        println(item)  // item is Any?\n    }\n}\n```\n\n| Declaration | Star Projection |\n|-------------|----------------|\n| `Foo<out T>` | `Foo<*>` = `Foo<out Any?>` |\n| `Foo<in T>` | `Foo<*>` = `Foo<in Nothing>` |\n| `Foo<T>` | `Foo<*>` = `Foo<out Any?>` for reads |',
 12),
('generics-variance', 4, 'Deep Dive', 'Variance and Type Safety',
 E'## Why Arrays Are Invariant\n\n```kotlin\nval dogs: Array<Dog> = arrayOf(Dog())\n// val animals: Array<Animal> = dogs  // Error!\n\n// If allowed:\n// animals[0] = Cat()  // Runtime error! Array contains Dog\n```\n\n## Why Lists Are Covariant\n\n```kotlin\nval dogs: List<Dog> = listOf(Dog())\nval animals: List<Animal> = dogs  // OK!\n\n// Can''t add to List (immutable)\n// animals.add(Cat())  // No such method!\n```\n\n## MutableList Is Invariant\n\n```kotlin\nval dogs: MutableList<Dog> = mutableListOf(Dog())\n// val animals: MutableList<Animal> = dogs  // Error!\n```\n\n## Bytecode: Type Erasure\n\n```kotlin\nclass Box<T>(val value: T)\n```\n\nAt runtime, `Box<String>` and `Box<Int>` are both just `Box`.\n\n```kotlin\n// This doesn''t work:\nif (obj is Box<String>)  // Error: Cannot check for erased type\n\n// This works:\nif (obj is Box<*>)  // OK: Check only outer type\n```\n\n## Reified to the Rescue\n\n```kotlin\ninline fun <reified T> isType(value: Any): Boolean {\n    return value is T  // Works because reified\n}\n```',
 15)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: reified-types
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('reified-types', 1, 'TL;DR', 'Reified Type Parameters',
 E'```kotlin\n// Without reified - type erased\nfun <T> isType(value: Any): Boolean {\n    // return value is T  // Error! T is erased\n}\n\n// With reified - type preserved\ninline fun <reified T> isType(value: Any): Boolean {\n    return value is T  // OK!\n}\n\nisType<String>("hello")  // true\nisType<Int>("hello")     // false\n```',
 2),
('reified-types', 2, 'Beginner', 'Understanding Reified',
 E'## The Type Erasure Problem\n\nGenerics are erased at runtime:\n\n```kotlin\nfun <T> printType() {\n    // println(T::class)  // Error! T unknown at runtime\n}\n```\n\n## Solution: Reified + Inline\n\n```kotlin\ninline fun <reified T> printType() {\n    println(T::class)  // OK! Type substituted at call site\n}\n\nprintType<String>()  // class kotlin.String\n```\n\n## Common Use Cases\n\n```kotlin\n// Type checking\ninline fun <reified T> isInstance(value: Any) = value is T\n\n// Creating instances (with no-arg constructor)\ninline fun <reified T : Any> create(): T = T::class.java.newInstance()\n\n// Parsing JSON\ninline fun <reified T> parseJson(json: String): T =\n    gson.fromJson(json, T::class.java)\n```',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- =====================================================
-- REMAINING TOPICS (Brief tiers)
-- =====================================================

-- Topic: delegation
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('delegation', 1, 'TL;DR', 'Delegation Pattern',
 E'```kotlin\n// Class delegation\ninterface Printer { fun print() }\nclass RealPrinter : Printer { override fun print() = println("Real") }\nclass DelegatingPrinter(p: Printer) : Printer by p\n\n// Property delegation\nval lazyValue by lazy { expensiveComputation() }\nvar observed by Delegates.observable(0) { _, old, new -> println("$old -> $new") }\n```',
 2),
('delegation', 2, 'Beginner', 'Understanding Delegation',
 E'## Class Delegation\n\nDelegate interface implementation to another object:\n\n```kotlin\ninterface Base {\n    fun print()\n    fun printMessage()\n}\n\nclass BaseImpl(val x: Int) : Base {\n    override fun print() { println(x) }\n    override fun printMessage() { println("BaseImpl: $x") }\n}\n\nclass Derived(b: Base) : Base by b {\n    // Can override selectively\n    override fun printMessage() { println("Derived") }\n}\n```\n\n## Why Use Delegation?\n\n1. Composition over inheritance\n2. Avoid deep class hierarchies\n3. Combine multiple behaviors\n\n## Delegated Properties\n\n```kotlin\nclass User {\n    val name: String by lazy { fetchName() }  // Computed once\n    var email: String by Delegates.observable("") { _, old, new ->\n        println("Email changed: $old -> $new")\n    }\n}\n```',
 8)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: testing-basics
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('testing-basics', 1, 'TL;DR', 'Kotlin Testing Basics',
 E'```kotlin\nimport kotlin.test.*\n\nclass CalculatorTest {\n    @Test\n    fun `addition works correctly`() {\n        assertEquals(4, 2 + 2)\n    }\n    \n    @Test\n    fun `division by zero throws`() {\n        assertFailsWith<ArithmeticException> {\n            1 / 0\n        }\n    }\n}\n```',
 2),
('testing-basics', 2, 'Beginner', 'Testing in Kotlin',
 E'## JUnit 5 Setup\n\n```kotlin\n// build.gradle.kts\ndependencies {\n    testImplementation(kotlin("test"))\n    testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")\n}\n\ntasks.test { useJUnitPlatform() }\n```\n\n## Test Structure\n\n```kotlin\nclass UserServiceTest {\n    private lateinit var service: UserService\n    \n    @BeforeEach\n    fun setup() {\n        service = UserService()\n    }\n    \n    @Test\n    fun `creates user with valid data`() {\n        val user = service.create("John", 25)\n        \n        assertNotNull(user)\n        assertEquals("John", user.name)\n    }\n    \n    @Test\n    fun `rejects invalid age`() {\n        assertFailsWith<IllegalArgumentException> {\n            service.create("John", -1)\n        }\n    }\n}\n```\n\n## Backtick Method Names\n\nKotlin allows spaces in test names:\n```kotlin\n@Test\nfun `user registration with valid email succeeds`()\n```',
 8)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: mockk
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('mockk', 1, 'TL;DR', 'MockK Essentials',
 E'```kotlin\n// Create mock\nval userRepo = mockk<UserRepository>()\n\n// Stub behavior\nevery { userRepo.findById(1) } returns User("John")\nevery { userRepo.save(any()) } just Runs\n\n// Verify calls\nverify { userRepo.findById(1) }\nverify(exactly = 1) { userRepo.save(any()) }\n```',
 2),
('mockk', 2, 'Beginner', 'Mocking with MockK',
 E'## Setup\n\n```kotlin\ntestImplementation("io.mockk:mockk:1.13.8")\n```\n\n## Creating Mocks\n\n```kotlin\n// Mock (all methods stubbed)\nval mock = mockk<UserService>()\n\n// Relaxed mock (returns defaults)\nval relaxed = mockk<UserService>(relaxed = true)\n\n// Spy (real implementation, can override)\nval spy = spyk(RealUserService())\n```\n\n## Stubbing\n\n```kotlin\nevery { mock.getUser(1) } returns User("John")\nevery { mock.getUser(any()) } returns User("Default")\nevery { mock.saveUser(any()) } just Runs\nevery { mock.delete(any()) } throws NotFoundException()\n```\n\n## Verification\n\n```kotlin\nverify { mock.getUser(1) }           // Was called\nverify(exactly = 2) { mock.getUser(any()) }  // Called twice\nverify(atLeast = 1) { mock.saveUser(any()) } // At least once\nconfirmVerified(mock)                // No other calls\n```',
 8)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- =====================================================
-- INHERITANCE & INTERFACES
-- =====================================================

-- Topic: inheritance
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('inheritance', 1, 'TL;DR', 'Inheritance Basics',
 E'```kotlin\n// Classes are final by default - use open\nopen class Animal(val name: String) {\n    open fun sound() = "..."\n}\n\nclass Dog(name: String) : Animal(name) {\n    override fun sound() = "Woof!"\n}\n\nval dog = Dog("Rex")\ndog.sound()  // "Woof!"\n```',
 2),
('inheritance', 2, 'Beginner', 'Understanding Inheritance',
 E'## Classes Are Final by Default\n\nKotlin classes cannot be inherited unless marked `open`:\n\n```kotlin\nclass Final           // Cannot extend\nopen class Open       // Can extend\nabstract class Base   // Must extend\n```\n\n## Syntax\n\n```kotlin\nopen class Parent(val name: String) {\n    open fun greet() = "Hello"\n}\n\nclass Child(name: String, val age: Int) : Parent(name) {\n    override fun greet() = "Hi, I''m $name"\n}\n```\n\n## Calling Super\n\n```kotlin\nclass Child : Parent() {\n    override fun greet(): String {\n        return super.greet() + ", from child"\n    }\n}\n```\n\n## Why Final by Default?\n\n1. Prevents fragile base class problem\n2. Encourages composition over inheritance\n3. Follows "Effective Java" recommendation',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: interfaces
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('interfaces', 1, 'TL;DR', 'Interfaces',
 E'```kotlin\ninterface Clickable {\n    fun click()  // Abstract\n    fun showOff() = println("Clickable!")  // Default impl\n}\n\nclass Button : Clickable {\n    override fun click() = println("Clicked")\n}\n```\n\nNo `open` needed - interface methods are open by default.',
 2),
('interfaces', 2, 'Beginner', 'Working with Interfaces',
 E'## Interface Features\n\n```kotlin\ninterface Drawable {\n    val color: String  // Abstract property\n    fun draw()         // Abstract method\n    fun clear() = println("Cleared")  // Default implementation\n}\n```\n\n## Multiple Interfaces\n\n```kotlin\ninterface A { fun foo() = println("A") }\ninterface B { fun foo() = println("B") }\n\nclass C : A, B {\n    override fun foo() {\n        super<A>.foo()  // Call A''s implementation\n        super<B>.foo()  // Call B''s implementation\n    }\n}\n```\n\n## Interface vs Abstract Class\n\n| Feature | Interface | Abstract Class |\n|---------|-----------|---------------|\n| State | No backing fields | Can have state |\n| Constructor | No | Yes |\n| Multiple | Yes | No |\n| Default methods | Yes | Yes |',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: abstract-classes
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('abstract-classes', 1, 'TL;DR', 'Abstract Classes',
 E'```kotlin\nabstract class Shape {\n    abstract val area: Double  // Must implement\n    abstract fun draw()        // Must implement\n    \n    fun describe() = "Area: $area"  // Concrete method\n}\n\nclass Circle(val radius: Double) : Shape() {\n    override val area = Math.PI * radius * radius\n    override fun draw() = println("Drawing circle")\n}\n```',
 2),
('abstract-classes', 2, 'Beginner', 'Using Abstract Classes',
 E'## When to Use\n\n- Need to share state between subclasses\n- Need constructors with parameters\n- Define a common base with some implementation\n\n## Example\n\n```kotlin\nabstract class Animal(val name: String) {\n    abstract fun makeSound(): String\n    \n    fun introduce() = "I''m $name and I say ${makeSound()}"\n}\n\nclass Cat(name: String) : Animal(name) {\n    override fun makeSound() = "Meow"\n}\n\nclass Dog(name: String) : Animal(name) {\n    override fun makeSound() = "Woof"\n}\n```\n\n## Abstract vs Interface\n\nUse **abstract class** when:\n- Subclasses share state\n- Need constructor logic\n- Only one base class needed\n\nUse **interface** when:\n- Multiple inheritance needed\n- No shared state\n- Defining a capability/contract',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: visibility-modifiers
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('visibility-modifiers', 1, 'TL;DR', 'Visibility Modifiers',
 E'```kotlin\npublic val a = 1     // Everywhere (default)\nprivate val b = 2    // This file/class only\nprotected val c = 3  // This class + subclasses\ninternal val d = 4   // Same module only\n```\n\n**Kotlin default is public** (Java default is package-private).',
 2),
('visibility-modifiers', 2, 'Beginner', 'Understanding Visibility',
 E'## Four Modifiers\n\n| Modifier | Class Member | Top-Level |\n|----------|--------------|----------|\n| public | Everywhere | Everywhere |\n| private | Same class | Same file |\n| protected | Same class + subclasses | N/A |\n| internal | Same module | Same module |\n\n## Examples\n\n```kotlin\nclass Example {\n    public val public = 1     // Anywhere\n    private val private = 2   // Only in Example\n    protected val protected = 3  // Example + subclasses\n    internal val internal = 4 // Same module\n}\n\n// Top-level\nprivate fun helper() { }  // Only in this file\ninternal class Util { }   // Only in this module\n```\n\n## Module = Compilation Unit\n\n- Gradle/Maven module\n- IntelliJ module\n- Set of files compiled together',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- =====================================================
-- MORE ADVANCED TOPICS
-- =====================================================

-- Topic: delegated-properties
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('delegated-properties', 1, 'TL;DR', 'Delegated Properties',
 E'```kotlin\n// lazy - computed once on first access\nval expensive by lazy { computeExpensiveValue() }\n\n// observable - callback on change\nvar name by Delegates.observable("") { _, old, new ->\n    println("$old -> $new")\n}\n\n// map-backed properties\nclass User(map: Map<String, Any>) {\n    val name: String by map\n    val age: Int by map\n}\n```',
 2),
('delegated-properties', 2, 'Beginner', 'Property Delegation Explained',
 E'## Built-in Delegates\n\n**lazy** - Initialize on first access:\n```kotlin\nval data: String by lazy {\n    println("Computing...")\n    loadData()  // Called once\n}\n```\n\n**observable** - React to changes:\n```kotlin\nvar count by Delegates.observable(0) { prop, old, new ->\n    println("Count changed: $old -> $new")\n}\n```\n\n**vetoable** - Validate before change:\n```kotlin\nvar age by Delegates.vetoable(0) { _, _, new ->\n    new >= 0  // Reject negative values\n}\n```\n\n## Map Delegation\n\n```kotlin\nclass User(val map: Map<String, Any?>) {\n    val name: String by map\n    val age: Int by map\n}\n\nval user = User(mapOf("name" to "John", "age" to 30))\nprintln(user.name)  // "John"\n```',
 8)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: lambda-with-receivers
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('lambda-with-receivers', 1, 'TL;DR', 'Lambdas with Receivers',
 E'```kotlin\n// Lambda with receiver - this refers to receiver\nval greet: String.() -> String = { "Hello, $this!" }\n"World".greet()  // "Hello, World!"\n\n// Used in builders\nfun buildString(action: StringBuilder.() -> Unit): String {\n    return StringBuilder().apply(action).toString()\n}\n\nbuildString {\n    append("Hello")  // this is StringBuilder\n    append(" World")\n}\n```',
 2),
('lambda-with-receivers', 2, 'Beginner', 'Understanding Lambda with Receiver',
 E'## Regular Lambda vs Lambda with Receiver\n\n```kotlin\n// Regular lambda\nval regular: (String) -> String = { s -> s.uppercase() }\n\n// Lambda with receiver - String is the receiver\nval withReceiver: String.() -> String = { this.uppercase() }\n\n// Call them\nregular("hello")      // HELLO\n"hello".withReceiver() // HELLO\n```\n\n## This in Receiver Lambda\n\n```kotlin\nval format: Int.() -> String = {\n    "Number: $this"  // this is the Int\n}\n\n42.format()  // "Number: 42"\n```\n\n## DSL Building\n\n```kotlin\nclass HTML {\n    fun body(init: Body.() -> Unit) { ... }\n}\n\nclass Body {\n    fun p(text: String) { ... }\n}\n\nhtml {\n    body {      // this is Body\n        p("Hello")  // calls Body.p()\n    }\n}\n```',
 8)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: function-types
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('function-types', 1, 'TL;DR', 'Function Types',
 E'```kotlin\n// Function types\nval sum: (Int, Int) -> Int = { a, b -> a + b }\nval print: (String) -> Unit = { println(it) }\nval noArgs: () -> String = { "Hello" }\n\n// Nullable function type\nval maybeCallback: ((Int) -> Unit)? = null\n\n// Function type with receiver\nval greet: String.() -> String = { "Hi, $this" }\n```',
 2),
('function-types', 2, 'Beginner', 'Function Type Syntax',
 E'## Basic Syntax\n\n```kotlin\n(ParamType1, ParamType2) -> ReturnType\n```\n\n## Examples\n\n```kotlin\n// No params, returns Int\nval getNumber: () -> Int = { 42 }\n\n// One param, returns Unit (void)\nval printIt: (String) -> Unit = { println(it) }\n\n// Two params, returns their sum\nval add: (Int, Int) -> Int = { a, b -> a + b }\n\n// Returns a function\nval multiplier: (Int) -> (Int) -> Int = { factor ->\n    { number -> number * factor }\n}\nval triple = multiplier(3)\ntriple(5)  // 15\n```\n\n## Nullable Function Types\n\n```kotlin\n// The function itself is nullable\nval callback: ((String) -> Unit)? = null\ncallback?.invoke("test")  // Safe call\n\n// The return type is nullable\nval find: (Int) -> String? = { if (it > 0) "positive" else null }\n```',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: operator-overloading
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('operator-overloading', 1, 'TL;DR', 'Operator Overloading',
 E'```kotlin\ndata class Point(val x: Int, val y: Int) {\n    operator fun plus(other: Point) = Point(x + other.x, y + other.y)\n    operator fun times(scale: Int) = Point(x * scale, y * scale)\n}\n\nval p1 = Point(1, 2)\nval p2 = Point(3, 4)\np1 + p2   // Point(4, 6)\np1 * 3    // Point(3, 6)\n```',
 2),
('operator-overloading', 2, 'Beginner', 'Overloading Operators',
 E'## Common Operators\n\n| Expression | Function |\n|------------|----------|\n| `a + b` | `a.plus(b)` |\n| `a - b` | `a.minus(b)` |\n| `a * b` | `a.times(b)` |\n| `a / b` | `a.div(b)` |\n| `a[i]` | `a.get(i)` |\n| `a[i] = v` | `a.set(i, v)` |\n| `a in b` | `b.contains(a)` |\n| `a()` | `a.invoke()` |\n\n## Example\n\n```kotlin\ndata class Money(val amount: Int, val currency: String) {\n    operator fun plus(other: Money): Money {\n        require(currency == other.currency)\n        return Money(amount + other.amount, currency)\n    }\n    \n    operator fun compareTo(other: Money): Int {\n        require(currency == other.currency)\n        return amount.compareTo(other.amount)\n    }\n}\n\nval m1 = Money(100, "USD")\nval m2 = Money(50, "USD")\nm1 + m2  // Money(150, "USD")\nm1 > m2  // true\n```',
 8)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: destructuring
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('destructuring', 1, 'TL;DR', 'Destructuring Declarations',
 E'```kotlin\n// Data class\ndata class User(val name: String, val age: Int)\nval (name, age) = User("John", 30)\n\n// Pair/Triple\nval (key, value) = "a" to 1\n\n// In loops\nfor ((k, v) in map) { println("$k = $v") }\n\n// In lambdas\nmap.forEach { (k, v) -> println("$k = $v") }\n```',
 2),
('destructuring', 2, 'Beginner', 'Destructuring Explained',
 E'## How It Works\n\nDestructuring calls `componentN()` functions:\n\n```kotlin\nval user = User("John", 30)\nval (name, age) = user\n\n// Equivalent to:\nval name = user.component1()\nval age = user.component2()\n```\n\n## Data Classes Auto-Generate\n\n```kotlin\ndata class Point(val x: Int, val y: Int)\n// Generates: component1() = x, component2() = y\n```\n\n## Skip Values with _\n\n```kotlin\nval (_, age) = user  // Only need age\n```\n\n## Custom componentN\n\n```kotlin\nclass Person(val name: String, val age: Int) {\n    operator fun component1() = name\n    operator fun component2() = age\n}\n```\n\n## In Function Returns\n\n```kotlin\nfun getUser(): Pair<String, Int> = "John" to 30\n\nval (name, age) = getUser()\n```',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: annotations
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('annotations', 1, 'TL;DR', 'Annotations',
 E'```kotlin\n// Using annotations\n@Deprecated("Use newMethod instead")\nfun oldMethod() { }\n\n@JvmStatic\nfun staticMethod() { }\n\n// Defining annotations\nannotation class JsonName(val name: String)\n\ndata class User(\n    @JsonName("user_name") val name: String\n)\n```',
 2),
('annotations', 2, 'Beginner', 'Working with Annotations',
 E'## Common Annotations\n\n```kotlin\n@Deprecated("Use X", ReplaceWith("X"))\n@Suppress("UNCHECKED_CAST")\n@JvmOverloads  // Generate overloads for default params\n@JvmStatic     // Generate static method\n@JvmField      // Expose field directly\n@Throws(IOException::class)  // For Java interop\n```\n\n## Annotation Targets\n\n```kotlin\n@file:JvmName("Utils")\n\nclass Example(\n    @field:JsonName("n") val name: String,  // On field\n    @get:JsonName("n") val name2: String,   // On getter\n    @param:NotNull val name3: String        // On constructor param\n)\n```\n\n## Defining Annotations\n\n```kotlin\n@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)\n@Retention(AnnotationRetention.RUNTIME)\nannotation class Api(val version: Int = 1)\n\n@Api(version = 2)\nclass MyService { }\n```',
 8)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: coroutine-context
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('coroutine-context', 1, 'TL;DR', 'Coroutine Context & Dispatchers',
 E'```kotlin\n// Dispatchers\nDispatchers.Main      // UI thread (Android)\nDispatchers.IO        // I/O operations (64 threads)\nDispatchers.Default   // CPU-intensive (core count)\nDispatchers.Unconfined // No specific thread\n\n// Switch context\nwithContext(Dispatchers.IO) {\n    // Runs on IO dispatcher\n    readFile()\n}\n```',
 2),
('coroutine-context', 2, 'Beginner', 'Understanding Context',
 E'## What is Coroutine Context?\n\nA set of elements that define coroutine behavior:\n- **Dispatcher** - which thread(s) to use\n- **Job** - lifecycle and cancellation\n- **Name** - for debugging\n- **Exception handler** - error handling\n\n## Dispatchers Explained\n\n| Dispatcher | Threads | Use For |\n|------------|---------|--------|\n| Main | 1 (UI) | UI updates |\n| IO | 64 | Network, disk |\n| Default | CPU cores | Computation |\n| Unconfined | Caller | Testing |\n\n## Switching Context\n\n```kotlin\nsuspend fun loadData(): Data {\n    return withContext(Dispatchers.IO) {\n        // This runs on IO thread pool\n        api.fetchData()\n    }\n}\n```\n\n## Combining Context Elements\n\n```kotlin\nlaunch(Dispatchers.IO + CoroutineName("loader")) {\n    // Named coroutine on IO\n}\n```',
 8)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: channels
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('channels', 1, 'TL;DR', 'Channels',
 E'```kotlin\nval channel = Channel<Int>()\n\n// Producer\nlaunch {\n    for (i in 1..5) channel.send(i)\n    channel.close()\n}\n\n// Consumer\nlaunch {\n    for (value in channel) {\n        println(value)  // 1, 2, 3, 4, 5\n    }\n}\n```\n\nChannels = concurrent queues for coroutines.',
 2),
('channels', 2, 'Beginner', 'Channel Basics',
 E'## What Are Channels?\n\nChannels are like BlockingQueue but for coroutines:\n- `send()` suspends if buffer full\n- `receive()` suspends if empty\n- No blocking, just suspending\n\n## Channel Types\n\n```kotlin\nChannel<Int>()                    // Rendezvous (0 buffer)\nChannel<Int>(Channel.UNLIMITED)   // Unlimited buffer\nChannel<Int>(Channel.CONFLATED)   // Keep only latest\nChannel<Int>(10)                  // Fixed buffer size\n```\n\n## Producer Pattern\n\n```kotlin\nfun CoroutineScope.produceNumbers() = produce<Int> {\n    for (i in 1..5) send(i)\n}\n\nval numbers = produceNumbers()\nfor (n in numbers) println(n)\n```\n\n## Fan-Out / Fan-In\n\n```kotlin\n// Multiple consumers from one channel\nrepeat(3) { workerId ->\n    launch { \n        for (task in channel) process(workerId, task)\n    }\n}\n```',
 8)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: value-classes
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('value-classes', 1, 'TL;DR', 'Value Classes',
 E'```kotlin\n@JvmInline\nvalue class UserId(val id: Long)\n\n@JvmInline\nvalue class Email(val value: String) {\n    init { require(value.contains("@")) }\n}\n\nfun findUser(id: UserId): User  // Type-safe!\n// Can''t pass Email where UserId expected\n```\n\nZero overhead type safety - compiles to primitive.',
 2),
('value-classes', 2, 'Beginner', 'Type-Safe Wrappers',
 E'## Why Value Classes?\n\nPrevent mixing up similar types:\n\n```kotlin\n// Without value classes - easy to mix up!\nfun transfer(from: Long, to: Long, amount: Long)\ntransfer(accountId, recipientId, 100)  // Which is which?\n\n// With value classes - compiler catches errors\n@JvmInline value class AccountId(val id: Long)\n@JvmInline value class Amount(val cents: Long)\n\nfun transfer(from: AccountId, to: AccountId, amount: Amount)\n// transfer(amount, from, to)  // Compile error!\n```\n\n## Rules\n\n1. Single property in constructor\n2. Can have methods and properties\n3. Cannot have init blocks with side effects\n4. Cannot be extended\n\n## Example\n\n```kotlin\n@JvmInline\nvalue class Password(private val value: String) {\n    val length: Int get() = value.length\n    fun isStrong() = length >= 8\n}\n```\n\nAt runtime, `Password` is just a `String` - no object allocation!',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: nested-inner-classes
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('nested-inner-classes', 1, 'TL;DR', 'Nested & Inner Classes',
 E'```kotlin\nclass Outer {\n    val x = 1\n    \n    class Nested {  // No access to Outer\n        fun foo() = "Nested"\n    }\n    \n    inner class Inner {  // Has access to Outer\n        fun foo() = "Inner sees $x"\n    }\n}\n\nOuter.Nested().foo()      // Static-like\nOuter().Inner().foo()     // Needs outer instance\n```',
 2),
('nested-inner-classes', 2, 'Beginner', 'Nested vs Inner Classes',
 E'## Nested Class (default)\n\nNo reference to outer class:\n\n```kotlin\nclass Outer {\n    private val secret = 42\n    \n    class Nested {\n        // Cannot access secret\n        fun foo() = "Just nested"\n    }\n}\n\nval nested = Outer.Nested()  // No Outer instance needed\n```\n\n## Inner Class\n\nHolds reference to outer:\n\n```kotlin\nclass Outer {\n    private val secret = 42\n    \n    inner class Inner {\n        fun reveal() = "Secret is $secret"  // Can access!\n        fun getOuter() = this@Outer         // Reference to outer\n    }\n}\n\nval inner = Outer().Inner()  // Needs Outer instance\n```\n\n## Java Comparison\n\n| Kotlin | Java |\n|--------|------|\n| `class Nested` | `static class Nested` |\n| `inner class Inner` | `class Inner` |\n\nKotlin''s default is opposite of Java!',
 6)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: type-aliases
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('type-aliases', 1, 'TL;DR', 'Type Aliases',
 E'```kotlin\n// Simplify complex types\ntypealias UserCache = MutableMap<UserId, User>\ntypealias Predicate<T> = (T) -> Boolean\ntypealias Handler = (Request) -> Response\n\n// Usage\nval cache: UserCache = mutableMapOf()\nval isAdult: Predicate<User> = { it.age >= 18 }\n```\n\nAliases are interchangeable with original types.',
 2)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: kotest
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('kotest', 1, 'TL;DR', 'Kotest Testing',
 E'```kotlin\nclass MyTest : StringSpec({\n    "string length should be correct" {\n        "hello".length shouldBe 5\n    }\n    \n    "list should contain element" {\n        listOf(1, 2, 3) shouldContain 2\n    }\n})\n```\n\nKotest = Kotlin-first testing with powerful assertions.',
 2),
('kotest', 2, 'Beginner', 'Testing with Kotest',
 E'## Setup\n\n```kotlin\ntestImplementation("io.kotest:kotest-runner-junit5:5.8.0")\ntestImplementation("io.kotest:kotest-assertions-core:5.8.0")\n```\n\n## Test Styles\n\n```kotlin\n// StringSpec - simple\nclass MyTest : StringSpec({\n    "test name" { /* test body */ }\n})\n\n// FunSpec - like JUnit\nclass MyTest : FunSpec({\n    test("test name") { /* body */ }\n})\n\n// BehaviorSpec - BDD style\nclass MyTest : BehaviorSpec({\n    given("a user") {\n        `when`("logged in") {\n            then("should see dashboard") { }\n        }\n    }\n})\n```\n\n## Assertions\n\n```kotlin\nvalue shouldBe expected\nlist shouldContain element\nstring shouldStartWith "prefix"\nresult.shouldBeInstanceOf<Success>()\nexception shouldThrow IllegalArgumentException::class\n```',
 8)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: gradle-kotlin-dsl
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('gradle-kotlin-dsl', 1, 'TL;DR', 'Gradle Kotlin DSL',
 E'```kotlin\n// build.gradle.kts\nplugins {\n    kotlin("jvm") version "1.9.21"\n    application\n}\n\nrepositories {\n    mavenCentral()\n}\n\ndependencies {\n    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")\n    testImplementation(kotlin("test"))\n}\n```',
 2),
('gradle-kotlin-dsl', 2, 'Beginner', 'Gradle with Kotlin',
 E'## Why Kotlin DSL?\n\n- IDE autocompletion\n- Type safety\n- Refactoring support\n- Same language as code\n\n## File Names\n\n| Groovy | Kotlin |\n|--------|--------|\n| build.gradle | build.gradle.kts |\n| settings.gradle | settings.gradle.kts |\n\n## Common Patterns\n\n```kotlin\nplugins {\n    kotlin("jvm") version "1.9.21"\n    kotlin("plugin.spring") version "1.9.21"\n    id("org.springframework.boot") version "3.2.0"\n}\n\ndependencies {\n    implementation(project(":core"))\n    implementation("group:artifact:version")\n    testImplementation(kotlin("test"))\n    \n    // Platform/BOM\n    implementation(platform("org.springframework.boot:spring-boot-dependencies:3.2.0"))\n}\n\ntasks.test {\n    useJUnitPlatform()\n}\n```',
 8)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Topic: best-practices
INSERT INTO kotlin_content_tier (topic_id, tier_level, tier_name, title, explanation, reading_time_minutes)
VALUES
('best-practices', 1, 'TL;DR', 'Kotlin Best Practices',
 E'```kotlin\n// 1. Prefer val over var\nval immutable = "safer"\n\n// 2. Use data classes for DTOs\ndata class User(val name: String, val age: Int)\n\n// 3. Use sealed classes for states\nsealed class Result<T>\n\n// 4. Use extension functions wisely\nfun String.isEmail() = contains("@")\n\n// 5. Prefer expression bodies\nfun double(x: Int) = x * 2\n```',
 2),
('best-practices', 2, 'Beginner', 'Kotlin Idioms',
 E'## Immutability First\n\n```kotlin\n// Prefer val\nval list = listOf(1, 2, 3)\n\n// Use copy for modifications\nval updated = user.copy(age = user.age + 1)\n```\n\n## Null Safety\n\n```kotlin\n// Avoid !!\nval length = str?.length ?: 0  // Good\nval length = str!!.length       // Avoid\n\n// Use require/check\nfun process(data: String?) {\n    requireNotNull(data) { "Data required" }\n    // data is now non-null\n}\n```\n\n## Concise Code\n\n```kotlin\n// Single expression functions\nfun isEven(n: Int) = n % 2 == 0\n\n// Scope functions\nval user = User().apply {\n    name = "John"\n    age = 30\n}\n\n// Destructuring\nfor ((key, value) in map) { }\n```\n\n## Naming\n\n- `is`/`has` prefix for Boolean properties\n- `to` prefix for conversion functions\n- Avoid Hungarian notation',
 8)
ON CONFLICT (topic_id, tier_level) DO UPDATE SET
    tier_name = EXCLUDED.tier_name, title = EXCLUDED.title,
    explanation = EXCLUDED.explanation, reading_time_minutes = EXCLUDED.reading_time_minutes;

-- Update all topics to have tiered content structure
UPDATE kotlin_topic SET content_structure = 'tiered', max_tier_level = 2 WHERE max_tier_level IS NULL OR max_tier_level < 2;
UPDATE kotlin_topic SET max_tier_level = 4 WHERE id IN ('coroutines-basics', 'suspend-functions', 'flow-basics', 'sealed-classes', 'extension-functions', 'inline-functions', 'generics-variance', 'sequences', 'variables-val-var', 'basic-types', 'control-flow-if-when');
UPDATE kotlin_topic SET max_tier_level = 3 WHERE id IN ('exceptions', 'functions-basics', 'scope-functions', 'collections-overview', 'collection-operations', 'constructors', 'properties', 'data-classes', 'object-declarations', 'lambdas-basics', 'generics-basics', 'inheritance', 'interfaces', 'delegated-properties', 'lambda-with-receivers', 'operator-overloading', 'annotations', 'coroutine-context', 'channels');
