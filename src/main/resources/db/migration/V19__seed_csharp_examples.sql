-- V19: Seed C# Code Examples for Language Comparison
-- Adds C# equivalents for Kotlin features across all topics

-- =====================================================
-- KOTLIN BASICS
-- =====================================================

-- variables-val-var
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('variables-val-var', 'csharp', 'C# 10+',
 E'// C# uses different keywords\nreadonly string name = "CSharp";  // Like val (field)\nconst string VERSION = "10";      // Compile-time constant\nstring mutableName = "Hello";     // Like var (can reassign)\n\n// Local variables\nvar inferred = "Type inferred";   // var = type inference, not mutability!\nstring explicit = "Explicit type";\n\n// C# 9+ readonly locals (limited)\n// No direct equivalent to Kotlin''s val for locals',
 E'C# doesn''t have a direct equivalent to Kotlin''s `val` for local variables. C#''s `var` is about type inference, not immutability. Use `readonly` for fields.', 1)
ON CONFLICT DO NOTHING;

-- basic-types
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('basic-types', 'csharp', 'C# 10+',
 E'// Value types (stack allocated)\nint number = 42;\nlong bigNumber = 42L;\ndouble floating = 3.14;\nfloat precise = 3.14f;\nbool flag = true;\nchar letter = ''A'';\n\n// Reference type\nstring text = "Hello";\n\n// Nullable value types\nint? nullable = null;\n\n// Type inference\nvar inferred = 42;  // int',
 E'C# has similar basic types. Key difference: C# has value types (struct) vs reference types (class). Kotlin compiles to JVM primitives when possible.', 1)
ON CONFLICT DO NOTHING;

-- string-templates
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('string-templates', 'csharp', 'C# 10+',
 E'var name = "World";\nvar age = 25;\n\n// String interpolation (C# 6+)\nConsole.WriteLine($"Hello, {name}!");\nConsole.WriteLine($"Age: {age}, Next year: {age + 1}");\n\n// Raw string literals (C# 11+)\nvar json = $"""\n    {{\n        "name": "{name}",\n        "age": {age}\n    }}\n    """;',
 E'C# uses `$"..."` for string interpolation (very similar to Kotlin''s `"$..."`). C# 11 added raw string literals similar to Kotlin''s triple-quoted strings.', 1)
ON CONFLICT DO NOTHING;

-- null-safety
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('null-safety', 'csharp', 'C# 10+',
 E'// Nullable reference types (C# 8+)\n#nullable enable\n\nstring nonNull = "hello";     // Cannot be null\nstring? nullable = null;      // Can be null\n\n// Null-conditional operator (same as Kotlin!)\nint? length = nullable?.Length;\n\n// Null-coalescing operator (like Elvis)\nint len = nullable?.Length ?? 0;\n\n// Null-forgiving operator (like !!)\nstring forced = nullable!;  // Trust me, it''s not null\n\n// Pattern matching with null\nif (nullable is string s)\n{\n    Console.WriteLine(s.Length);\n}',
 E'C# 8+ added nullable reference types, very similar to Kotlin. The syntax is almost identical: `?.` for safe calls, `??` for Elvis, `!` for assertion.', 1)
ON CONFLICT DO NOTHING;

-- control-flow-if-when
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('control-flow-if-when', 'csharp', 'C# 10+',
 E'// Ternary operator (no if expression in C#)\nvar max = a > b ? a : b;\n\n// Switch expression (C# 8+) - like Kotlin when\nvar result = x switch\n{\n    1 => "one",\n    2 or 3 => "two or three",\n    >= 4 and <= 10 => "between 4-10",\n    _ => "other"  // Default case (like else)\n};\n\n// Pattern matching in switch\nvar description = obj switch\n{\n    string s => $"String of length {s.Length}",\n    int i => $"Integer: {i * 2}",\n    null => "It''s null",\n    _ => "Unknown type"\n};',
 E'C# 8+ switch expressions are very similar to Kotlin''s `when`. C# uses `=>` instead of `->` and `_` instead of `else`. Pattern matching works similarly.', 1)
ON CONFLICT DO NOTHING;

-- loops-ranges
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('loops-ranges', 'csharp', 'C# 10+',
 E'// Range operator (C# 8+)\nvar range = 1..5;  // Range type, not iteration!\nvar slice = array[1..3];  // Slicing\n\n// For loop with range (traditional)\nfor (int i = 1; i <= 5; i++)\n    Console.Write(i);  // 1 2 3 4 5\n\n// LINQ alternative\nforeach (var i in Enumerable.Range(1, 5))\n    Console.Write(i);  // 1 2 3 4 5\n\n// Descending\nfor (int i = 5; i >= 1; i--)\n    Console.Write(i);  // 5 4 3 2 1',
 E'C# 8+ has ranges but they''re primarily for slicing, not iteration. Use traditional for loops or LINQ''s `Enumerable.Range()` for Kotlin-style ranges.', 1)
ON CONFLICT DO NOTHING;

-- exceptions
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('exceptions', 'csharp', 'C# 10+',
 E'// Try-catch (statement, not expression)\ntry\n{\n    RiskyOperation();\n}\ncatch (IOException ex)\n{\n    HandleIO(ex);\n}\ncatch (Exception ex)\n{\n    HandleOther(ex);\n}\nfinally\n{\n    Cleanup();\n}\n\n// No checked exceptions in C# either!\n\n// Throw expression (C# 7+)\nvar name = input ?? throw new ArgumentNullException(nameof(input));\n\n// Exception filters\ncatch (Exception ex) when (ex.Message.Contains("timeout"))\n{\n    // Only catches timeout exceptions\n}',
 E'C# doesn''t have checked exceptions (like Kotlin). Try-catch is a statement, not an expression, but throw can be used in expressions since C# 7.', 1)
ON CONFLICT DO NOTHING;

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- functions-basics
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('functions-basics', 'csharp', 'C# 10+',
 E'// Standard method\nstring Greet(string name = "World")\n{\n    return $"Hello, {name}!";\n}\n\n// Expression-bodied method (C# 6+)\nint Double(int x) => x * 2;\n\n// Local function (C# 7+)\nvoid Process()\n{\n    int LocalHelper(int x) => x * 2;\n    Console.WriteLine(LocalHelper(5));\n}\n\n// Top-level statements (C# 9+)\n// Can write code without class wrapper\nConsole.WriteLine("Hello!");',
 E'C# has similar function features. Expression-bodied members (`=>`) are like single-expression functions. Local functions were added in C# 7.', 1)
ON CONFLICT DO NOTHING;

-- default-named-args
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('default-named-args', 'csharp', 'C# 10+',
 E'// Default parameters\nvoid CreateUser(\n    string name,\n    int age = 0,\n    string email = "",\n    bool active = true)\n{\n    // ...\n}\n\n// Named arguments\nCreateUser("John", email: "john@example.com");\nCreateUser(name: "Jane", active: false, age: 25);\n\n// Caller argument expression (C# 10+)\nvoid Log([CallerArgumentExpression("value")] string? expr = null, object? value = null)\n{\n    Console.WriteLine($"{expr} = {value}");\n}',
 E'C# has had default and named parameters since C# 4.0. Syntax is nearly identical to Kotlin. Named arguments use `:` instead of `=`.', 1)
ON CONFLICT DO NOTHING;

-- extension-functions
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('extension-functions', 'csharp', 'C# 10+',
 E'// Extension method (must be in static class)\npublic static class StringExtensions\n{\n    public static string AddExclamation(this string str)\n        => str + "!";\n    \n    public static int WordCount(this string str)\n        => str.Split('' '').Length;\n}\n\n// Usage\nvar result = "Hello".AddExclamation();  // "Hello!"\nvar words = "one two three".WordCount(); // 3\n\n// Extension method on nullable\npublic static string OrEmpty(this string? str)\n    => str ?? "";',
 E'C# extension methods are very similar to Kotlin! Key difference: must be defined in a static class with `this` keyword on the first parameter.', 1)
ON CONFLICT DO NOTHING;

-- infix-functions
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('infix-functions', 'csharp', 'C# 10+',
 E'// C# doesn''t have infix notation for methods\n// Closest equivalent: operator overloading\n\npublic readonly struct Money\n{\n    public decimal Amount { get; }\n    \n    // Operator overloading\n    public static Money operator +(Money a, Money b)\n        => new Money(a.Amount + b.Amount);\n}\n\nvar total = money1 + money2;  // Uses overloaded +\n\n// For custom "operators", use regular methods\nvar pair = Tuple.Create(1, "one");  // Like Kotlin''s 1 to "one"',
 E'C# doesn''t support infix function notation. Use operator overloading for mathematical operations or regular method calls for custom operations.', 1)
ON CONFLICT DO NOTHING;

-- =====================================================
-- CLASSES & OBJECTS
-- =====================================================

-- data-classes
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('data-classes', 'csharp', 'C# 10+',
 E'// Record (C# 9+) - equivalent to data class\npublic record User(long Id, string Name, string Email);\n\n// Usage\nvar user1 = new User(1, "John", "john@example.com");\nvar user2 = new User(1, "John", "john@example.com");\n\nConsole.WriteLine(user1 == user2);  // true (value equality)\nConsole.WriteLine(user1);  // User { Id = 1, Name = John, Email = john@example.com }\n\n// with expression (like copy())\nvar user3 = user1 with { Name = "Jane" };\n\n// Deconstruction\nvar (id, name, email) = user1;',
 E'C# records (C# 9+) are nearly identical to Kotlin data classes! They provide value equality, ToString, deconstruction, and `with` expressions (like `copy()`).', 1)
ON CONFLICT DO NOTHING;

-- sealed-classes
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('sealed-classes', 'csharp', 'C# 10+',
 E'// Sealed classes + pattern matching\npublic abstract record Result;\npublic record Success(string Data) : Result;\npublic record Error(string Message) : Result;\npublic record Loading : Result;\n\n// Exhaustive switch (C# warns if incomplete)\nstring Handle(Result result) => result switch\n{\n    Success s => s.Data,\n    Error e => e.Message,\n    Loading => "Loading...",\n    _ => throw new InvalidOperationException()  // Still need default\n};\n\n// C# doesn''t enforce exhaustiveness as strictly as Kotlin',
 E'C# has sealed classes but they prevent inheritance entirely. Use abstract records with pattern matching for Kotlin-style sealed hierarchies. Exhaustiveness checking isn''t as strict.', 1)
ON CONFLICT DO NOTHING;

-- object-declarations
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('object-declarations', 'csharp', 'C# 10+',
 E'// Singleton pattern (manual)\npublic sealed class Logger\n{\n    private static readonly Lazy<Logger> _instance = \n        new(() => new Logger());\n    \n    public static Logger Instance => _instance.Value;\n    \n    private Logger() { }  // Private constructor\n    \n    public void Log(string msg) => Console.WriteLine(msg);\n}\n\n// Usage\nLogger.Instance.Log("Hello");\n\n// Static class (for utility functions)\npublic static class MathUtils\n{\n    public static int Double(int x) => x * 2;\n}',
 E'C# doesn''t have `object` declarations. Use the singleton pattern with `Lazy<T>` for thread-safe lazy initialization, or static classes for stateless utilities.', 1)
ON CONFLICT DO NOTHING;

-- constructors
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('constructors', 'csharp', 'C# 12+',
 E'// Primary constructor (C# 12+)\npublic class User(string name, int age = 0)\n{\n    public string Name { get; } = name;\n    public int Age { get; set; } = age;\n}\n\n// Traditional constructors\npublic class Person\n{\n    public string Name { get; }\n    public int Age { get; set; }\n    \n    public Person(string name) : this(name, 0) { }\n    \n    public Person(string name, int age)\n    {\n        Name = name;\n        Age = age;\n    }\n}',
 E'C# 12 added primary constructors, making the syntax very similar to Kotlin! Before C# 12, you needed traditional constructor syntax.', 1)
ON CONFLICT DO NOTHING;

-- properties
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('properties', 'csharp', 'C# 10+',
 E'public class Rectangle\n{\n    // Auto-implemented properties\n    public int Width { get; set; }\n    public int Height { get; init; }  // init-only (C# 9+)\n    \n    // Computed property\n    public int Area => Width * Height;\n    \n    // Property with backing field\n    private string _name = "";\n    public string Name\n    {\n        get => _name;\n        set => _name = value?.Trim() ?? "";\n    }\n    \n    // Private setter\n    public int Counter { get; private set; }\n}',
 E'C# properties are similar to Kotlin''s. Key differences: `{ get; set; }` syntax, `init` for init-only setters, explicit backing fields with `_name` convention.', 1)
ON CONFLICT DO NOTHING;

-- enum-classes
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('enum-classes', 'csharp', 'C# 10+',
 E'// Basic enum\npublic enum Direction { North, South, East, West }\n\n// Enum with values\npublic enum Planet\n{\n    Earth = 1,\n    Mars = 2\n}\n\n// For properties, use extension methods or records\npublic static class PlanetExtensions\n{\n    public static double GetMass(this Planet p) => p switch\n    {\n        Planet.Earth => 5.97e24,\n        Planet.Mars => 6.42e23,\n        _ => 0\n    };\n}\n\n// Or use sealed record hierarchy for rich enums\npublic abstract record PlanetRecord(double Mass);',
 E'C# enums are simpler than Kotlin''s. For properties/methods, use extension methods or switch expressions. For richer enums, consider sealed record hierarchies.', 1)
ON CONFLICT DO NOTHING;

-- =====================================================
-- LAMBDAS & FUNCTIONAL
-- =====================================================

-- lambdas-basics
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('lambdas-basics', 'csharp', 'C# 10+',
 E'// Lambda expressions\nFunc<int, int, int> sum = (a, b) => a + b;\nFunc<int, int> square = x => x * x;  // Single param, no parens\nAction<string> print = msg => Console.WriteLine(msg);\n\n// With type inference\nvar double = (int x) => x * 2;\n\n// Multi-line lambda\nFunc<int, int> complex = x =>\n{\n    var temp = x * 2;\n    return temp + 1;\n};\n\n// Method group\nvar numbers = new[] { 1, 2, 3 };\nnumbers.ToList().ForEach(Console.WriteLine);',
 E'C# lambdas use `=>` (fat arrow) instead of `->`. Types like `Func<>`, `Action<>`, `Predicate<>` define the lambda signature. Very similar to Kotlin overall.', 1)
ON CONFLICT DO NOTHING;

-- higher-order-functions
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('higher-order-functions', 'csharp', 'C# 10+',
 E'// Taking function as parameter\nint Operate(int a, int b, Func<int, int, int> op)\n    => op(a, b);\n\nvar result = Operate(5, 3, (a, b) => a + b);  // 8\n\n// Returning a function\nFunc<int, int> Multiplier(int factor)\n    => x => x * factor;\n\nvar triple = Multiplier(3);\nConsole.WriteLine(triple(5));  // 15\n\n// Common LINQ operations\nvar numbers = new[] { 1, 2, 3, 4, 5 };\nvar filtered = numbers.Where(x => x > 2);\nvar doubled = numbers.Select(x => x * 2);',
 E'C# uses `Func<>` and `Action<>` delegate types for function parameters. LINQ provides familiar operations like `Where` (filter) and `Select` (map).', 1)
ON CONFLICT DO NOTHING;

-- scope-functions
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('scope-functions', 'csharp', 'C# 10+',
 E'// C# doesn''t have built-in scope functions, but you can create them:\n\npublic static class ScopeExtensions\n{\n    // Like Kotlin''s let\n    public static TResult Let<T, TResult>(this T obj, Func<T, TResult> func)\n        => func(obj);\n    \n    // Like Kotlin''s also\n    public static T Also<T>(this T obj, Action<T> action)\n    {\n        action(obj);\n        return obj;\n    }\n}\n\n// Usage\nvar result = "hello"\n    .Let(s => s.ToUpper())\n    .Also(s => Console.WriteLine(s));  // HELLO\n\n// Object initializer (like apply)\nvar user = new User\n{\n    Name = "John",\n    Age = 30\n};',
 E'C# doesn''t have built-in scope functions like Kotlin. Object initializers provide similar functionality to `apply`. You can create extension methods for `let`/`also`.', 1)
ON CONFLICT DO NOTHING;

-- inline-functions
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('inline-functions', 'csharp', 'C# 10+',
 E'// C# has [MethodImpl(MethodImplOptions.AggressiveInlining)]\n[MethodImpl(MethodImplOptions.AggressiveInlining)]\nint Double(int x) => x * 2;\n\n// But it''s a hint, not a guarantee like Kotlin inline\n\n// For performance-critical code, consider:\n// 1. AggressiveInlining attribute\n// 2. Source generators for compile-time code generation\n// 3. Span<T> and stackalloc for avoiding allocations\n\n// No equivalent to reified type parameters\n// Use runtime reflection or source generators',
 E'C# has `AggressiveInlining` as a hint to the JIT compiler, but it''s not guaranteed like Kotlin''s `inline`. There''s no equivalent to reified type parameters.', 1)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COROUTINES
-- =====================================================

-- coroutines-basics
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('coroutines-basics', 'csharp', 'C# 10+',
 E'// async/await (built into the language)\nasync Task<string> FetchDataAsync()\n{\n    await Task.Delay(1000);  // Like delay()\n    return "Data";\n}\n\n// Fire and forget (like launch)\n_ = Task.Run(async () =>\n{\n    await Task.Delay(1000);\n    Console.WriteLine("Done");\n});\n\n// Parallel execution (like async/await in Kotlin)\nasync Task LoadBothAsync()\n{\n    var userTask = FetchUserAsync();\n    var postsTask = FetchPostsAsync();\n    \n    await Task.WhenAll(userTask, postsTask);\n    // or: var (user, posts) = await (userTask, postsTask);\n}',
 E'C# async/await is conceptually similar to Kotlin coroutines. Main differences: `async` on method, `Task` instead of `Deferred`, `Task.Delay` instead of `delay`.', 1)
ON CONFLICT DO NOTHING;

-- suspend-functions
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('suspend-functions', 'csharp', 'C# 10+',
 E'// Async methods (equivalent to suspend functions)\nasync Task<User> FetchUserAsync(long id)\n{\n    await Task.Delay(1000);\n    return await api.GetUserAsync(id);\n}\n\n// Calling async methods\nasync Task ProcessAsync()\n{\n    var user = await FetchUserAsync(123);\n    Console.WriteLine(user.Name);\n}\n\n// ConfigureAwait for context\nasync Task LibraryMethodAsync()\n{\n    await SomeOperationAsync().ConfigureAwait(false);\n    // Doesn''t need to return to original context\n}',
 E'C# `async` methods are equivalent to Kotlin `suspend` functions. Both allow non-blocking async code. C# uses `async Task<T>` return type, Kotlin uses `suspend fun`.', 1)
ON CONFLICT DO NOTHING;

-- flow-basics
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('flow-basics', 'csharp', 'C# 10+',
 E'// IAsyncEnumerable (C# 8+) - like Flow\nasync IAsyncEnumerable<int> GenerateNumbersAsync()\n{\n    for (int i = 1; i <= 5; i++)\n    {\n        await Task.Delay(100);\n        yield return i;\n    }\n}\n\n// Consuming (like collect)\nawait foreach (var number in GenerateNumbersAsync())\n{\n    Console.WriteLine(number);\n}\n\n// LINQ operations on async streams\nvar doubled = GenerateNumbersAsync()\n    .Select(x => x * 2);\n\n// System.Reactive for more operators\n// Observable.Interval(TimeSpan.FromSeconds(1))',
 E'C# `IAsyncEnumerable<T>` is similar to Kotlin `Flow`. Both are cold async streams. Use `await foreach` to consume. System.Reactive provides more operators like RxJS.', 1)
ON CONFLICT DO NOTHING;

-- =====================================================
-- GENERICS
-- =====================================================

-- generics-basics
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('generics-basics', 'csharp', 'C# 10+',
 E'// Generic class\npublic class Box<T>\n{\n    public T Value { get; set; }\n    public Box(T value) => Value = value;\n}\n\nvar box = new Box<string>("Hello");\n\n// Generic method\nT Identity<T>(T item) => item;\nvar result = Identity(42);  // Type inferred\n\n// Constraints\nvoid Sort<T>(List<T> list) where T : IComparable<T>\n{\n    list.Sort();\n}\n\n// Multiple constraints\nvoid Process<T>(T item) where T : class, IDisposable, new()\n{\n    // T must be: reference type, implement IDisposable, have parameterless constructor\n}',
 E'C# generics are similar to Kotlin''s. Constraints use `where` clause. C# supports `new()` constraint for parameterless constructors, `class`/`struct` for type category.', 1)
ON CONFLICT DO NOTHING;

-- generics-variance
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('generics-variance', 'csharp', 'C# 10+',
 E'// Covariance (out) - only produce T\npublic interface IProducer<out T>\n{\n    T Produce();\n}\n\n// Contravariance (in) - only consume T\npublic interface IConsumer<in T>\n{\n    void Consume(T item);\n}\n\n// Example\nIProducer<Dog> dogProducer = ...;\nIProducer<Animal> animalProducer = dogProducer;  // OK!\n\nIConsumer<Animal> animalConsumer = ...;\nIConsumer<Dog> dogConsumer = animalConsumer;  // OK!\n\n// Built-in examples\nIEnumerable<out T>  // Covariant\nAction<in T>        // Contravariant\nFunc<in T, out R>   // Both!',
 E'C# variance is nearly identical to Kotlin! `out` for covariance, `in` for contravariance. Same concepts, same keywords.', 1)
ON CONFLICT DO NOTHING;

-- reified-types
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('reified-types', 'csharp', 'C# 10+',
 E'// C# doesn''t have reified generics, but has runtime type info\n\n// Using typeof\nbool IsType<T>(object value) => value is T;\n// or: value.GetType() == typeof(T)\n\n// Using reflection\nT? Deserialize<T>(string json)\n{\n    return JsonSerializer.Deserialize<T>(json);\n    // Works because typeof(T) is available at runtime\n}\n\n// Generic constraints as alternative to reified\nvoid Process<T>(T item) where T : IMyInterface\n{\n    item.MyMethod();  // Constrained, so method is available\n}',
 E'C# generics are NOT erased at runtime (unlike JVM). You can use `typeof(T)` and reflection. However, there''s no `is T` check in generics without reflection.', 1)
ON CONFLICT DO NOTHING;

-- =====================================================
-- MISCELLANEOUS
-- =====================================================

-- delegation
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('delegation', 'csharp', 'C# 10+',
 E'// No built-in delegation, use composition\npublic interface IPrinter { void Print(); }\n\npublic class DelegatingPrinter : IPrinter\n{\n    private readonly IPrinter _inner;\n    \n    public DelegatingPrinter(IPrinter inner) => _inner = inner;\n    \n    public void Print() => _inner.Print();\n}\n\n// For property delegation, use custom patterns\npublic class LazyProperty<T>\n{\n    private Lazy<T> _lazy;\n    public T Value => _lazy.Value;\n    public LazyProperty(Func<T> factory) => _lazy = new(factory);\n}',
 E'C# doesn''t have built-in delegation syntax. Use composition manually or create helper classes. `Lazy<T>` provides similar functionality to Kotlin''s `lazy` delegate.', 1)
ON CONFLICT DO NOTHING;

-- testing-basics
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('testing-basics', 'csharp', 'C# 10+',
 E'using Xunit;\n\npublic class CalculatorTests\n{\n    [Fact]\n    public void Addition_Works_Correctly()\n    {\n        Assert.Equal(4, 2 + 2);\n    }\n    \n    [Theory]\n    [InlineData(2, 3, 5)]\n    [InlineData(0, 0, 0)]\n    public void Add_Returns_Sum(int a, int b, int expected)\n    {\n        Assert.Equal(expected, a + b);\n    }\n    \n    [Fact]\n    public void Division_By_Zero_Throws()\n    {\n        Assert.Throws<DivideByZeroException>(() => 1 / 0);\n    }\n}',
 E'C# typically uses xUnit, NUnit, or MSTest. xUnit''s `[Fact]` is like `@Test`, `[Theory]` for parameterized tests. Assert methods are similar to Kotlin/JUnit.', 1)
ON CONFLICT DO NOTHING;

-- mockk
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('mockk', 'csharp', 'C# 10+',
 E'using Moq;\n\npublic class UserServiceTests\n{\n    [Fact]\n    public void GetUser_Returns_User()\n    {\n        // Arrange\n        var mockRepo = new Mock<IUserRepository>();\n        mockRepo.Setup(r => r.FindById(1))\n                .Returns(new User("John"));\n        \n        var service = new UserService(mockRepo.Object);\n        \n        // Act\n        var user = service.GetUser(1);\n        \n        // Assert\n        Assert.Equal("John", user.Name);\n        mockRepo.Verify(r => r.FindById(1), Times.Once);\n    }\n}',
 E'C# uses Moq (most popular) or NSubstitute for mocking. `Setup` is like `every`, `Verify` is like `verify`. Very similar concepts to MockK.', 1)
ON CONFLICT DO NOTHING;

-- value-classes
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('value-classes', 'csharp', 'C# 10+',
 E'// Record struct (C# 10+) - value type record\npublic readonly record struct UserId(long Value);\npublic readonly record struct Email(string Value);\n\n// Usage\nvoid SendEmail(UserId userId, Email email)\n{\n    // Type-safe - can''t mix up UserId and Email\n}\n\n// Regular struct for more control\npublic readonly struct Money\n{\n    public decimal Amount { get; }\n    public string Currency { get; }\n    \n    public Money(decimal amount, string currency)\n    {\n        Amount = amount;\n        Currency = currency;\n    }\n}',
 E'C# `readonly record struct` is similar to Kotlin''s `@JvmInline value class`. Both provide type safety with minimal overhead. Structs are value types (stack allocated).', 1)
ON CONFLICT DO NOTHING;

-- java-interop
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('java-interop', 'csharp', 'C# 10+',
 E'// C# doesn''t directly interop with Java, but...\n\n// P/Invoke for native code\n[DllImport("user32.dll")]\nstatic extern int MessageBox(IntPtr hWnd, string text, string caption, uint type);\n\n// COM interop for Windows components\nvar excel = new Microsoft.Office.Interop.Excel.Application();\n\n// For JVM interop, use:\n// - IKVM.NET (Java bytecode on .NET)\n// - gRPC/REST for service communication\n// - Message queues (Kafka, RabbitMQ)',
 E'C# doesn''t interop with Java directly (different runtimes). Use P/Invoke for native code, COM for Windows, or network protocols (gRPC/REST) for cross-platform communication.', 1)
ON CONFLICT DO NOTHING;

-- dsl-basics
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('dsl-basics', 'csharp', 'C# 10+',
 E'// Builder pattern for DSL-like syntax\npublic class HtmlBuilder\n{\n    private readonly StringBuilder _sb = new();\n    \n    public HtmlBuilder Div(Action<HtmlBuilder> content)\n    {\n        _sb.Append("<div>");\n        content(this);\n        _sb.Append("</div>");\n        return this;\n    }\n    \n    public HtmlBuilder Text(string text)\n    {\n        _sb.Append(text);\n        return this;\n    }\n    \n    public override string ToString() => _sb.ToString();\n}\n\n// Usage\nvar html = new HtmlBuilder()\n    .Div(b => b\n        .Text("Hello ")\n        .Div(inner => inner.Text("World")))\n    .ToString();',
 E'C# can create DSL-like APIs using builder pattern and fluent interfaces. Not as elegant as Kotlin''s lambdas with receivers, but achieves similar results.', 1)
ON CONFLICT DO NOTHING;

-- best-practices
INSERT INTO kotlin_code_example (topic_id, language, version_label, code, explanation, order_index)
VALUES
('best-practices', 'csharp', 'C# 10+',
 E'// Modern C# best practices\n\n// 1. Use records for DTOs\npublic record UserDto(string Name, int Age);\n\n// 2. Use file-scoped namespaces (C# 10)\nnamespace MyApp.Services;\n\n// 3. Use nullable reference types\n#nullable enable\n\n// 4. Prefer expression bodies\nstring Greet(string name) => $"Hello, {name}!";\n\n// 5. Use pattern matching\nvar result = obj switch\n{\n    int i => i * 2,\n    string s => s.Length,\n    _ => 0\n};\n\n// 6. Use LINQ for collections\nvar adults = users.Where(u => u.Age >= 18).ToList();',
 E'Modern C# (10+) shares many best practices with Kotlin: prefer immutability (records), use pattern matching, leverage LINQ, enable nullable reference types.', 1)
ON CONFLICT DO NOTHING;
