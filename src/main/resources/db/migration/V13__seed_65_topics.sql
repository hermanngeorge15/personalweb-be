-- V13: Seed 65 Kotlin Learning Topics
-- Based on "Kotlin in Action" book structure

-- Update existing topic with part info
UPDATE kotlin_topic SET part_number = 1, part_name = 'Kotlin Fundamentals', max_tier_level = 4 WHERE id = 'what-is-a-class';

-- =====================================================
-- PART 1: KOTLIN FUNDAMENTALS (Topics 2-20)
-- =====================================================

-- Chapter 1: Kotlin Basics
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index, part_number, part_name, max_tier_level)
VALUES
('variables-val-var', 'Variables: val vs var', 'Kotlin Basics', 'beginner',
 'Understand immutability with val and mutability with var',
 'Kotlin has two ways to declare variables: `val` for immutable (read-only) and `var` for mutable. Prefer `val` whenever possible.',
 E'val name = "Kotlin"  // Immutable\nvar count = 0         // Mutable\ncount++               // OK\n// name = "Java"      // Error!',
 8, 2, 1, 'Kotlin Fundamentals', 3),

('basic-types', 'Basic Types', 'Kotlin Basics', 'beginner',
 'Numbers, strings, booleans, and type inference',
 'Kotlin has rich basic types with smart inference. Numbers are objects but optimized to primitives.',
 E'val int: Int = 42\nval long = 42L\nval double = 3.14\nval string = "Hello"\nval bool = true',
 10, 3, 1, 'Kotlin Fundamentals', 3),

('string-templates', 'String Templates', 'Kotlin Basics', 'beginner',
 'Embed expressions in strings with $ syntax',
 'String templates let you embed variables and expressions directly in strings.',
 E'val name = "World"\nprintln("Hello, $name!")\nprintln("2 + 2 = ${2 + 2}")',
 6, 4, 1, 'Kotlin Fundamentals', 2),

('null-safety', 'Null Safety', 'Kotlin Basics', 'beginner',
 'Eliminate NullPointerExceptions with nullable types',
 'Kotlin''s type system distinguishes nullable (T?) from non-nullable (T) types, preventing NPEs at compile time.',
 E'val nonNull: String = "hello"\nval nullable: String? = null\n\n// Safe call\nprintln(nullable?.length)\n\n// Elvis operator\nval len = nullable?.length ?: 0',
 15, 5, 1, 'Kotlin Fundamentals', 4),

('control-flow-if-when', 'Control Flow: if & when', 'Kotlin Basics', 'beginner',
 'Expressions that return values, not just statements',
 'In Kotlin, `if` and `when` are expressions that return values, making code more concise.',
 E'val max = if (a > b) a else b\n\nval result = when (x) {\n    1 -> "one"\n    2 -> "two"\n    else -> "many"\n}',
 10, 6, 1, 'Kotlin Fundamentals', 3),

('loops-ranges', 'Loops and Ranges', 'Kotlin Basics', 'beginner',
 'For loops, while loops, and range expressions',
 'Kotlin provides concise loop syntax with ranges and progressions.',
 E'for (i in 1..5) println(i)\nfor (i in 5 downTo 1 step 2) println(i)\n(1..10).forEach { println(it) }',
 8, 7, 1, 'Kotlin Fundamentals', 2),

('exceptions', 'Exceptions', 'Kotlin Basics', 'intermediate',
 'Try-catch as expressions, no checked exceptions',
 'Kotlin doesn''t have checked exceptions. try-catch is an expression that returns a value.',
 E'val result = try {\n    parseInt(input)\n} catch (e: NumberFormatException) {\n    0\n}',
 10, 8, 1, 'Kotlin Fundamentals', 3);

-- Chapter 2: Functions
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index, part_number, part_name, max_tier_level)
VALUES
('functions-basics', 'Functions Basics', 'Functions', 'beginner',
 'Declaring and calling functions in Kotlin',
 'Functions are declared with `fun` keyword. They can have default parameters and named arguments.',
 E'fun greet(name: String = "World"): String {\n    return "Hello, $name!"\n}\n\n// Single expression\nfun double(x: Int) = x * 2',
 10, 9, 1, 'Kotlin Fundamentals', 3),

('default-named-args', 'Default & Named Arguments', 'Functions', 'beginner',
 'Reduce overloads with default values and improve readability',
 'Default arguments eliminate the need for multiple overloads. Named arguments improve readability.',
 E'fun createUser(\n    name: String,\n    age: Int = 0,\n    email: String = ""\n) { }\n\ncreateUser("John", email = "john@example.com")',
 8, 10, 1, 'Kotlin Fundamentals', 3),

('extension-functions', 'Extension Functions', 'Functions', 'intermediate',
 'Add methods to existing classes without inheritance',
 'Extension functions let you add new functions to existing types without modifying them.',
 E'fun String.addExclamation() = this + "!"\n\nprintln("Hello".addExclamation())  // Hello!',
 12, 11, 1, 'Kotlin Fundamentals', 4),

('infix-functions', 'Infix Functions', 'Functions', 'intermediate',
 'Create DSL-like syntax with infix notation',
 'Infix functions can be called without dot and parentheses for cleaner syntax.',
 E'infix fun Int.times(str: String) = str.repeat(this)\n\nprintln(3 times "Hi ")  // Hi Hi Hi',
 8, 12, 1, 'Kotlin Fundamentals', 3),

('local-functions', 'Local Functions', 'Functions', 'intermediate',
 'Define functions inside functions for encapsulation',
 'Local functions can access variables from the enclosing function.',
 E'fun process(data: List<Int>) {\n    fun validate(item: Int) = item > 0\n    data.filter(::validate).forEach { println(it) }\n}',
 8, 13, 1, 'Kotlin Fundamentals', 2);

-- Chapter 3: Collections
INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index, part_number, part_name, max_tier_level)
VALUES
('collections-overview', 'Collections Overview', 'Collections', 'beginner',
 'Lists, Sets, Maps - mutable and immutable',
 'Kotlin distinguishes between read-only and mutable collections at the type level.',
 E'val list = listOf(1, 2, 3)           // Immutable\nval mutableList = mutableListOf(1, 2, 3)  // Mutable\n\nval map = mapOf("a" to 1, "b" to 2)',
 10, 14, 1, 'Kotlin Fundamentals', 3),

('collection-operations', 'Collection Operations', 'Collections', 'intermediate',
 'Filter, map, reduce, and more functional operations',
 'Kotlin collections have rich functional operations built-in.',
 E'val numbers = listOf(1, 2, 3, 4, 5)\n\nval doubled = numbers.map { it * 2 }\nval even = numbers.filter { it % 2 == 0 }\nval sum = numbers.reduce { acc, n -> acc + n }',
 15, 15, 1, 'Kotlin Fundamentals', 4),

('sequences', 'Sequences', 'Collections', 'advanced',
 'Lazy evaluation for large collections',
 'Sequences process elements lazily, one at a time, avoiding intermediate collections.',
 E'val result = (1..1_000_000)\n    .asSequence()\n    .filter { it % 2 == 0 }\n    .map { it * 2 }\n    .take(10)\n    .toList()',
 12, 16, 1, 'Kotlin Fundamentals', 4);

-- =====================================================
-- PART 2: OBJECT-ORIENTED KOTLIN (Topics 17-35)
-- =====================================================

INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index, part_number, part_name, max_tier_level)
VALUES
('constructors', 'Constructors', 'Classes & Objects', 'beginner',
 'Primary and secondary constructors',
 'Kotlin has a concise primary constructor in the class header and optional secondary constructors.',
 E'class Person(val name: String) {  // Primary\n    var nickname: String = ""\n    \n    constructor(name: String, nick: String) : this(name) {\n        nickname = nick\n    }\n}',
 10, 17, 2, 'Object-Oriented Kotlin', 3),

('properties', 'Properties', 'Classes & Objects', 'beginner',
 'Getters, setters, and backing fields',
 'Properties replace Java''s field + getter + setter pattern with concise syntax.',
 E'class Rectangle(val width: Int, val height: Int) {\n    val area: Int\n        get() = width * height\n    \n    var counter = 0\n        set(value) {\n            if (value >= 0) field = value\n        }\n}',
 12, 18, 2, 'Object-Oriented Kotlin', 4),

('data-classes', 'Data Classes', 'Class Types', 'beginner',
 'Auto-generated equals, hashCode, toString, copy',
 'Data classes automatically implement common methods for data-holding classes.',
 E'data class User(val name: String, val age: Int)\n\nval user1 = User("John", 30)\nval user2 = user1.copy(age = 31)\nprintln(user1 == User("John", 30))  // true',
 10, 19, 2, 'Object-Oriented Kotlin', 3),

('enum-classes', 'Enum Classes', 'Class Types', 'beginner',
 'Type-safe enumerations with properties and methods',
 'Enum classes can have properties, methods, and implement interfaces.',
 E'enum class Color(val rgb: Int) {\n    RED(0xFF0000),\n    GREEN(0x00FF00),\n    BLUE(0x0000FF);\n    \n    fun hex() = "#${rgb.toString(16)}"\n}',
 8, 20, 2, 'Object-Oriented Kotlin', 3),

('sealed-classes', 'Sealed Classes', 'Class Types', 'intermediate',
 'Restricted class hierarchies for exhaustive when',
 'Sealed classes restrict which classes can inherit from them, enabling exhaustive when expressions.',
 E'sealed class Result<out T> {\n    data class Success<T>(val data: T) : Result<T>()\n    data class Error(val message: String) : Result<Nothing>()\n    object Loading : Result<Nothing>()\n}\n\nwhen (result) {\n    is Result.Success -> println(result.data)\n    is Result.Error -> println(result.message)\n    Result.Loading -> println("Loading...")\n}',
 15, 21, 2, 'Object-Oriented Kotlin', 4),

('object-declarations', 'Object Declarations', 'Class Types', 'intermediate',
 'Singletons and companion objects',
 'Object declarations create singletons. Companion objects provide static-like members.',
 E'object DatabaseConfig {\n    val url = "jdbc:..."\n    fun connect() { }\n}\n\nclass MyClass {\n    companion object {\n        fun create() = MyClass()\n    }\n}',
 12, 22, 2, 'Object-Oriented Kotlin', 4),

('inheritance', 'Inheritance', 'Inheritance & Interfaces', 'intermediate',
 'Open classes, overriding, and calling super',
 'Classes are final by default. Use open to allow inheritance.',
 E'open class Animal(val name: String) {\n    open fun sound() = "..."\n}\n\nclass Dog(name: String) : Animal(name) {\n    override fun sound() = "Woof!"\n}',
 12, 23, 2, 'Object-Oriented Kotlin', 3),

('interfaces', 'Interfaces', 'Inheritance & Interfaces', 'beginner',
 'Defining contracts with default implementations',
 'Interfaces can have abstract and default method implementations.',
 E'interface Clickable {\n    fun click()\n    fun showOff() = println("Clickable!")\n}\n\nclass Button : Clickable {\n    override fun click() = println("Clicked")\n}',
 10, 24, 2, 'Object-Oriented Kotlin', 3),

('abstract-classes', 'Abstract Classes', 'Inheritance & Interfaces', 'intermediate',
 'Partial implementations with abstract members',
 'Abstract classes can have state and abstract members that subclasses must implement.',
 E'abstract class Shape {\n    abstract val area: Double\n    fun describe() = "Area: $area"\n}\n\nclass Circle(val radius: Double) : Shape() {\n    override val area = Math.PI * radius * radius\n}',
 10, 25, 2, 'Object-Oriented Kotlin', 3),

('visibility-modifiers', 'Visibility Modifiers', 'Inheritance & Interfaces', 'intermediate',
 'public, private, protected, internal',
 'Kotlin has public (default), private, protected, and internal (module-level) visibility.',
 E'class Example {\n    public val a = 1        // Visible everywhere\n    private val b = 2       // Visible in class only\n    protected val c = 3     // Visible in subclasses\n    internal val d = 4      // Visible in same module\n}',
 8, 26, 2, 'Object-Oriented Kotlin', 3),

('nested-inner-classes', 'Nested & Inner Classes', 'Classes & Objects', 'intermediate',
 'Static nested vs inner classes with outer reference',
 'Nested classes don''t hold outer reference by default. Use inner keyword when needed.',
 E'class Outer {\n    val x = 1\n    \n    class Nested {  // No outer reference\n        fun foo() = 2\n    }\n    \n    inner class Inner {  // Has outer reference\n        fun foo() = x\n    }\n}',
 10, 27, 2, 'Object-Oriented Kotlin', 3),

('type-aliases', 'Type Aliases', 'Classes & Objects', 'intermediate',
 'Give alternative names to existing types',
 'Type aliases provide alternative names for types, useful for complex generic types.',
 E'typealias UserMap = Map<String, List<User>>\ntypealias Predicate<T> = (T) -> Boolean\n\nval users: UserMap = mapOf()\nval isEven: Predicate<Int> = { it % 2 == 0 }',
 6, 28, 2, 'Object-Oriented Kotlin', 2),

('delegation', 'Delegation', 'Advanced OOP', 'advanced',
 'Implement interfaces by delegating to another object',
 'Class delegation allows implementing interfaces by forwarding calls to a delegate object.',
 E'interface Printer {\n    fun print()\n}\n\nclass ConsolePrinter : Printer {\n    override fun print() = println("Console")\n}\n\nclass Document(printer: Printer) : Printer by printer',
 12, 29, 2, 'Object-Oriented Kotlin', 4),

('delegated-properties', 'Delegated Properties', 'Advanced OOP', 'advanced',
 'lazy, observable, and custom property delegates',
 'Delegated properties let you define reusable property behaviors.',
 E'val lazyValue: String by lazy {\n    println("Computed!")\n    "Hello"\n}\n\nvar observed: String by Delegates.observable("initial") { _, old, new ->\n    println("$old -> $new")\n}',
 15, 30, 2, 'Object-Oriented Kotlin', 4);

-- =====================================================
-- PART 3: FUNCTIONAL PROGRAMMING (Topics 31-45)
-- =====================================================

INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index, part_number, part_name, max_tier_level)
VALUES
('lambdas-basics', 'Lambdas Basics', 'Lambdas', 'beginner',
 'Anonymous functions with concise syntax',
 'Lambdas are anonymous functions that can be passed as values.',
 E'val sum = { a: Int, b: Int -> a + b }\nprintln(sum(1, 2))  // 3\n\nlistOf(1, 2, 3).filter { it > 1 }',
 10, 31, 3, 'Functional Programming', 3),

('lambda-with-receivers', 'Lambdas with Receivers', 'Lambdas', 'advanced',
 'DSL building blocks - this inside lambdas',
 'Lambdas with receivers allow calling methods on an implicit this inside the lambda.',
 E'fun buildString(action: StringBuilder.() -> Unit): String {\n    val sb = StringBuilder()\n    sb.action()\n    return sb.toString()\n}\n\nval str = buildString {\n    append("Hello, ")\n    append("World!")\n}',
 15, 32, 3, 'Functional Programming', 4),

('higher-order-functions', 'Higher-Order Functions', 'Lambdas', 'intermediate',
 'Functions that take or return functions',
 'Higher-order functions accept functions as parameters or return them.',
 E'fun <T> List<T>.customFilter(predicate: (T) -> Boolean): List<T> {\n    val result = mutableListOf<T>()\n    for (item in this) {\n        if (predicate(item)) result.add(item)\n    }\n    return result\n}',
 12, 33, 3, 'Functional Programming', 4),

('inline-functions', 'Inline Functions', 'Lambdas', 'advanced',
 'Eliminate lambda overhead with inlining',
 'Inline functions copy the function body to the call site, avoiding lambda object creation.',
 E'inline fun <T> measureTime(block: () -> T): T {\n    val start = System.currentTimeMillis()\n    val result = block()\n    println("Took ${System.currentTimeMillis() - start}ms")\n    return result\n}',
 12, 34, 3, 'Functional Programming', 4),

('function-types', 'Function Types', 'Lambdas', 'intermediate',
 'Understanding (A) -> B and Function interfaces',
 'Function types describe the signature of functions that can be stored and passed.',
 E'val onClick: () -> Unit = { println("Clicked") }\nval transform: (String) -> Int = { it.length }\nval combine: (Int, Int) -> Int = Int::plus',
 10, 35, 3, 'Functional Programming', 3),

('scope-functions', 'Scope Functions', 'Standard Library', 'intermediate',
 'let, run, with, apply, also - when to use each',
 'Scope functions execute a block of code in the context of an object.',
 E'// let - null check, transform\nval length = str?.let { it.length }\n\n// apply - configure object\nval person = Person().apply {\n    name = "John"\n    age = 30\n}\n\n// also - side effects\nreturn value.also { println("Returning $it") }',
 15, 36, 3, 'Functional Programming', 4),

('operator-overloading', 'Operator Overloading', 'Standard Library', 'intermediate',
 'Define +, -, *, [], and other operators',
 'Kotlin allows overloading operators by defining functions with special names.',
 E'data class Point(val x: Int, val y: Int) {\n    operator fun plus(other: Point) = Point(x + other.x, y + other.y)\n    operator fun times(scale: Int) = Point(x * scale, y * scale)\n}\n\nval p = Point(1, 2) + Point(3, 4)  // Point(4, 6)',
 12, 37, 3, 'Functional Programming', 4),

('destructuring', 'Destructuring Declarations', 'Standard Library', 'beginner',
 'Unpack objects into multiple variables',
 'Destructuring lets you extract multiple values from objects at once.',
 E'val (name, age) = Person("John", 30)\n\nfor ((key, value) in map) {\n    println("$key = $value")\n}\n\nval (first, second, _) = Triple(1, 2, 3)',
 8, 38, 3, 'Functional Programming', 3),

('invoke-convention', 'Invoke Convention', 'Standard Library', 'advanced',
 'Make objects callable like functions',
 'The invoke operator lets you call objects as if they were functions.',
 E'class Greeter(val greeting: String) {\n    operator fun invoke(name: String) = "$greeting, $name!"\n}\n\nval greet = Greeter("Hello")\nprintln(greet("World"))  // Hello, World!',
 8, 39, 3, 'Functional Programming', 3);

-- =====================================================
-- PART 4: ADVANCED FEATURES (Topics 40-65)
-- =====================================================

INSERT INTO kotlin_topic (id, title, module, difficulty, description, kotlin_explanation, kotlin_code, reading_time_minutes, order_index, part_number, part_name, max_tier_level)
VALUES
('generics-basics', 'Generics Basics', 'Generics', 'intermediate',
 'Type parameters for reusable code',
 'Generics let you write code that works with any type while maintaining type safety.',
 E'class Box<T>(val value: T)\n\nfun <T> singletonList(item: T): List<T> = listOf(item)\n\nval box = Box("Hello")\nval list = singletonList(42)',
 12, 40, 4, 'Advanced Features', 3),

('generics-variance', 'Generics Variance', 'Generics', 'advanced',
 'in, out - covariance and contravariance',
 'Variance annotations (in/out) define how generic types relate to their subtypes.',
 E'interface Producer<out T> {  // Covariant\n    fun produce(): T\n}\n\ninterface Consumer<in T> {  // Contravariant\n    fun consume(item: T)\n}\n\n// Producer<Dog> is subtype of Producer<Animal>\n// Consumer<Animal> is subtype of Consumer<Dog>',
 15, 41, 4, 'Advanced Features', 4),

('reified-types', 'Reified Type Parameters', 'Generics', 'advanced',
 'Access type info at runtime with inline reified',
 'Reified type parameters preserve type information at runtime in inline functions.',
 E'inline fun <reified T> isInstance(value: Any): Boolean = value is T\n\ninline fun <reified T> Gson.fromJson(json: String): T =\n    fromJson(json, T::class.java)',
 12, 42, 4, 'Advanced Features', 4),

('star-projection', 'Star Projection', 'Generics', 'advanced',
 'Use * when you don''t care about the type argument',
 'Star projection is like Java''s wildcard <?>, used when the exact type doesn''t matter.',
 E'fun printAll(list: List<*>) {\n    for (item in list) println(item)\n}\n\nval mixed: MutableList<*> = mutableListOf(1, "two", 3.0)',
 8, 43, 4, 'Advanced Features', 3),

('annotations', 'Annotations', 'Metaprogramming', 'intermediate',
 'Add metadata to code elements',
 'Annotations add metadata that can be processed at compile time or runtime.',
 E'@Target(AnnotationTarget.CLASS)\n@Retention(AnnotationRetention.RUNTIME)\nannotation class JsonSerializable(val name: String = "")\n\n@JsonSerializable("user")\nclass User(val name: String)',
 12, 44, 4, 'Advanced Features', 3),

('reflection', 'Reflection', 'Metaprogramming', 'advanced',
 'Inspect and manipulate code at runtime',
 'Reflection allows examining and modifying program structure at runtime.',
 E'val kClass = MyClass::class\nprintln(kClass.simpleName)\n\nval prop = MyClass::myProperty\nprintln(prop.get(instance))\n\nval func = MyClass::myFunction\nfunc.call(instance, arg)',
 15, 45, 4, 'Advanced Features', 4),

('coroutines-basics', 'Coroutines Basics', 'Coroutines', 'intermediate',
 'Asynchronous programming made simple',
 'Coroutines are lightweight threads for asynchronous, non-blocking code.',
 E'suspend fun fetchUser(): User {\n    delay(1000)  // Non-blocking delay\n    return User("John")\n}\n\nrunBlocking {\n    val user = fetchUser()\n    println(user)\n}',
 15, 46, 4, 'Advanced Features', 4),

('suspend-functions', 'Suspend Functions', 'Coroutines', 'intermediate',
 'Functions that can pause and resume',
 'Suspend functions can pause execution without blocking threads.',
 E'suspend fun loadData(): Data {\n    val a = async { fetchA() }\n    val b = async { fetchB() }\n    return combine(a.await(), b.await())\n}',
 12, 47, 4, 'Advanced Features', 4),

('coroutine-context', 'Coroutine Context & Dispatchers', 'Coroutines', 'advanced',
 'Control which thread coroutines run on',
 'Dispatchers determine which threads coroutines use for execution.',
 E'launch(Dispatchers.IO) {\n    // For I/O operations\n}\n\nlaunch(Dispatchers.Default) {\n    // For CPU-intensive work\n}\n\nwithContext(Dispatchers.Main) {\n    // Update UI\n}',
 12, 48, 4, 'Advanced Features', 4),

('flow-basics', 'Flow Basics', 'Coroutines', 'advanced',
 'Asynchronous streams of data',
 'Flow is Kotlin''s reactive streams implementation for asynchronous data.',
 E'fun numbers(): Flow<Int> = flow {\n    for (i in 1..3) {\n        delay(100)\n        emit(i)\n    }\n}\n\nnumbers().collect { println(it) }',
 15, 49, 4, 'Advanced Features', 4),

('channels', 'Channels', 'Coroutines', 'advanced',
 'Communication between coroutines',
 'Channels allow coroutines to communicate by sending and receiving values.',
 E'val channel = Channel<Int>()\n\nlaunch {\n    for (x in 1..5) channel.send(x)\n    channel.close()\n}\n\nfor (y in channel) println(y)',
 12, 50, 4, 'Advanced Features', 4),

('dsl-basics', 'DSL Building Basics', 'DSL', 'advanced',
 'Create domain-specific languages in Kotlin',
 'Kotlin''s features enable creating expressive DSLs.',
 E'html {\n    head {\n        title("My Page")\n    }\n    body {\n        h1("Welcome")\n        p("This is a DSL example")\n    }\n}',
 15, 51, 4, 'Advanced Features', 4),

('type-safe-builders', 'Type-Safe Builders', 'DSL', 'advanced',
 'Build complex structures with compile-time safety',
 'Type-safe builders use lambdas with receivers for compile-time checked structures.',
 E'fun buildPerson(block: PersonBuilder.() -> Unit): Person {\n    val builder = PersonBuilder()\n    builder.block()\n    return builder.build()\n}\n\nval person = buildPerson {\n    name = "John"\n    age = 30\n    address {\n        city = "NYC"\n    }\n}',
 15, 52, 4, 'Advanced Features', 4),

('contracts', 'Contracts', 'Advanced', 'expert',
 'Help the compiler understand your code',
 'Contracts provide additional information to the compiler about function behavior.',
 E'@OptIn(ExperimentalContracts::class)\nfun requireNotEmpty(str: String?) {\n    contract {\n        returns() implies (str != null)\n    }\n    require(!str.isNullOrEmpty())\n}\n\n// After call, compiler knows str is not null',
 12, 53, 4, 'Advanced Features', 4),

('value-classes', 'Value Classes', 'Advanced', 'intermediate',
 'Inline classes for type safety without overhead',
 'Value classes wrap primitive types with zero runtime overhead.',
 E'@JvmInline\nvalue class UserId(val id: Long)\n\n@JvmInline\nvalue class Email(val value: String) {\n    init {\n        require(value.contains("@"))\n    }\n}\n\nfun sendEmail(email: Email) { }',
 10, 54, 4, 'Advanced Features', 3),

('context-receivers', 'Context Receivers', 'Advanced', 'expert',
 'Implicit parameters for cleaner APIs',
 'Context receivers allow functions to require certain contexts without explicit parameters.',
 E'context(LoggerContext, TransactionContext)\nfun performOperation() {\n    log("Starting")  // From LoggerContext\n    commit()         // From TransactionContext\n}',
 12, 55, 4, 'Advanced Features', 4),

('multiplatform-basics', 'Multiplatform Basics', 'Multiplatform', 'intermediate',
 'Share code between JVM, JS, Native, and more',
 'Kotlin Multiplatform allows sharing business logic across platforms.',
 E'// commonMain\nexpect fun platformName(): String\n\nfun greeting() = "Hello from ${platformName()}"\n\n// jvmMain\nactual fun platformName() = "JVM"\n\n// jsMain\nactual fun platformName() = "JavaScript"',
 15, 56, 4, 'Advanced Features', 4),

('expect-actual', 'Expect/Actual Declarations', 'Multiplatform', 'advanced',
 'Platform-specific implementations',
 'Expect/actual mechanism provides platform-specific implementations for common code.',
 E'// Common\nexpect class UUID {\n    fun toString(): String\n}\n\nexpect fun randomUUID(): UUID\n\n// JVM\nactual typealias UUID = java.util.UUID\nactual fun randomUUID() = java.util.UUID.randomUUID()',
 12, 57, 4, 'Advanced Features', 4),

('java-interop', 'Java Interoperability', 'Interop', 'intermediate',
 'Call Java from Kotlin and vice versa',
 'Kotlin has seamless Java interoperability for gradual migration.',
 E'// Call Java from Kotlin\nval list = ArrayList<String>()\nlist.add("Kotlin")\n\n// Java sees Kotlin code\n// @JvmStatic, @JvmField, @JvmOverloads',
 12, 58, 4, 'Advanced Features', 3),

('nullability-annotations', 'Nullability Annotations', 'Interop', 'intermediate',
 'Platform types and nullability in Java interop',
 'Kotlin uses nullability annotations from Java code to determine types.',
 E'// Java with annotations\n@NotNull String getName()      // -> String\n@Nullable String getNickname() // -> String?\n\n// Without annotations: platform type\nString getOther()              // -> String!',
 10, 59, 4, 'Advanced Features', 3),

('sam-conversions', 'SAM Conversions', 'Interop', 'intermediate',
 'Convert lambdas to Java functional interfaces',
 'Single Abstract Method interfaces can be implemented with lambdas.',
 E'// Java interface\ninterface Runnable { void run(); }\n\n// Kotlin SAM conversion\nval runnable = Runnable { println("Running") }\n\nThread(runnable).start()',
 8, 60, 4, 'Advanced Features', 3),

('testing-basics', 'Testing Basics', 'Testing', 'beginner',
 'Unit testing with JUnit and assertions',
 'Kotlin works well with JUnit for testing, with more expressive assertions.',
 E'class CalculatorTest {\n    @Test\n    fun `addition works correctly`() {\n        val calculator = Calculator()\n        assertEquals(4, calculator.add(2, 2))\n    }\n}',
 10, 61, 4, 'Advanced Features', 3),

('mockk', 'Mocking with MockK', 'Testing', 'intermediate',
 'Kotlin-first mocking library',
 'MockK is a mocking library designed specifically for Kotlin.',
 E'@Test\nfun `test with mock`() {\n    val userService = mockk<UserService>()\n    every { userService.getUser(any()) } returns User("Test")\n    \n    val result = userService.getUser(1)\n    assertEquals("Test", result.name)\n    \n    verify { userService.getUser(1) }\n}',
 12, 62, 4, 'Advanced Features', 4),

('kotest', 'Testing with Kotest', 'Testing', 'intermediate',
 'Kotlin-native testing framework',
 'Kotest provides Kotlin-native testing styles and powerful assertions.',
 E'class MySpec : StringSpec({\n    "string length should be correct" {\n        "hello".length shouldBe 5\n    }\n    \n    "collections should contain element" {\n        listOf(1, 2, 3) shouldContain 2\n    }\n})',
 12, 63, 4, 'Advanced Features', 4),

('gradle-kotlin-dsl', 'Gradle Kotlin DSL', 'Build Tools', 'intermediate',
 'Type-safe build scripts in Kotlin',
 'Write Gradle build scripts in Kotlin for type safety and IDE support.',
 E'plugins {\n    kotlin("jvm") version "1.9.0"\n    application\n}\n\ndependencies {\n    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.0")\n    testImplementation(kotlin("test"))\n}',
 10, 64, 4, 'Advanced Features', 3),

('best-practices', 'Kotlin Best Practices', 'Best Practices', 'intermediate',
 'Idiomatic Kotlin patterns and conventions',
 'Follow Kotlin conventions for clean, maintainable code.',
 E'// Prefer val over var\n// Use data classes for DTOs\n// Use sealed classes for restricted hierarchies\n// Prefer expressions over statements\n// Use scope functions appropriately\n// Avoid !! - use safe calls or elvis',
 15, 65, 4, 'Advanced Features', 4);
