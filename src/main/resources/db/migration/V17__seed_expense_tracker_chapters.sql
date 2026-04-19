-- V17: Seed Expense Tracker Tutorial Chapters
-- Complete 8-chapter tutorial for building an expense tracker app

-- =====================================================
-- CHAPTER 1: Project Setup
-- Topics: variables-val-var, basic-types
-- =====================================================

INSERT INTO kotlin_expense_tracker_chapter (
    chapter_number, title, description, introduction,
    implementation_steps, code_snippets, summary,
    difficulty, estimated_time_minutes, previous_chapter, next_chapter
) VALUES (
    1,
    'Project Setup',
    'Initialize the expense tracker project and learn Kotlin basics',
    E'Welcome to the Expense Tracker tutorial! In this first chapter, we''ll set up our project structure and learn the fundamentals of Kotlin: variables, basic types, and your first Kotlin code.\n\nBy the end of this chapter, you''ll have a working project skeleton and understand the difference between `val` (immutable) and `var` (mutable) variables.',

    -- implementation_steps (JSON array)
    '[
        "Create a new Kotlin project using IntelliJ IDEA or Gradle",
        "Set up the main function as the entry point",
        "Declare your first variables using val and var",
        "Experiment with basic types: Int, Double, String, Boolean",
        "Run your first Kotlin program"
    ]',

    -- code_snippets (JSON object with snippets array)
    '{
        "snippets": [
            {
                "filename": "Main.kt",
                "language": "kotlin",
                "code": "fun main() {\n    // Immutable - cannot be reassigned\n    val appName = \"ExpenseTracker\"\n    val version = 1.0\n    \n    // Mutable - can be reassigned\n    var expenseCount = 0\n    \n    println(\"Welcome to $appName v$version\")\n    println(\"Current expenses: $expenseCount\")\n    \n    // This works because var is mutable\n    expenseCount = 5\n    println(\"Updated expenses: $expenseCount\")\n}",
                "explanation": "The entry point of our application. We use val for constants that won''t change and var for values that will be updated throughout the app lifecycle."
            },
            {
                "filename": "build.gradle.kts",
                "language": "kotlin",
                "code": "plugins {\n    kotlin(\"jvm\") version \"1.9.21\"\n    application\n}\n\nrepositories {\n    mavenCentral()\n}\n\napplication {\n    mainClass.set(\"MainKt\")\n}",
                "explanation": "Gradle Kotlin DSL configuration for our project. This sets up Kotlin JVM compilation and defines the main class."
            }
        ]
    }',

    E'In this chapter, you learned:\n- How to create a Kotlin project\n- The difference between `val` (immutable) and `var` (mutable)\n- Basic types like Int, Double, String, and Boolean\n- String templates for easy string formatting\n\nNext, we''ll create our data models using Kotlin''s powerful data classes.',

    'beginner', 25, NULL, 2
);

-- Link topics to Chapter 1
INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'variables-val-var', id, 'primary', 'Understanding val vs var for expense tracking state'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 1;

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'basic-types', id, 'primary', 'Using Int for amounts, String for descriptions'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 1;

-- =====================================================
-- CHAPTER 2: Data Modeling
-- Topics: data-classes, properties
-- =====================================================

INSERT INTO kotlin_expense_tracker_chapter (
    chapter_number, title, description, introduction,
    implementation_steps, code_snippets, summary,
    difficulty, estimated_time_minutes, previous_chapter, next_chapter
) VALUES (
    2,
    'Data Modeling with Data Classes',
    'Create the Expense data model using Kotlin''s powerful data classes',
    E'Now that we have our project set up, let''s create the core data models. Kotlin''s data classes are perfect for representing our expenses - they automatically generate equals(), hashCode(), toString(), and copy() methods.\n\nWe''ll also explore properties and how they differ from Java''s getters/setters.',

    '[
        "Create an Expense data class with id, amount, description, category, and date",
        "Add an ExpenseCategory enum for categorizing expenses",
        "Implement custom property getters for computed values",
        "Use copy() to create modified expense instances",
        "Test the auto-generated methods"
    ]',

    '{
        "snippets": [
            {
                "filename": "model/Expense.kt",
                "language": "kotlin",
                "code": "import java.time.LocalDate\n\ndata class Expense(\n    val id: Long,\n    val amount: Double,\n    val description: String,\n    val category: ExpenseCategory,\n    val date: LocalDate = LocalDate.now()\n) {\n    // Computed property\n    val formattedAmount: String\n        get() = \"$${String.format(\"%.2f\", amount)}\"\n    \n    val isRecent: Boolean\n        get() = date.isAfter(LocalDate.now().minusDays(7))\n}",
                "explanation": "Our Expense data class with auto-generated equals, hashCode, toString, and copy. Custom property getters compute values on demand."
            },
            {
                "filename": "model/ExpenseCategory.kt",
                "language": "kotlin",
                "code": "enum class ExpenseCategory(val displayName: String, val emoji: String) {\n    FOOD(\"Food & Dining\", \"🍔\"),\n    TRANSPORT(\"Transportation\", \"🚗\"),\n    UTILITIES(\"Utilities\", \"💡\"),\n    ENTERTAINMENT(\"Entertainment\", \"🎬\"),\n    SHOPPING(\"Shopping\", \"🛍️\"),\n    HEALTH(\"Health\", \"🏥\"),\n    OTHER(\"Other\", \"📦\");\n    \n    override fun toString() = \"$emoji $displayName\"\n}",
                "explanation": "Enum class with properties. Each category has a display name and emoji for user-friendly presentation."
            },
            {
                "filename": "Main.kt",
                "language": "kotlin",
                "code": "fun main() {\n    val expense = Expense(\n        id = 1,\n        amount = 25.99,\n        description = \"Lunch at cafe\",\n        category = ExpenseCategory.FOOD\n    )\n    \n    println(expense)  // Auto-generated toString()\n    println(\"Formatted: ${expense.formattedAmount}\")\n    \n    // Create modified copy\n    val updatedExpense = expense.copy(amount = 30.00)\n    println(\"Updated: $updatedExpense\")\n    \n    // Equality check uses all properties\n    println(\"Same? ${expense == updatedExpense}\")  // false\n}",
                "explanation": "Using the data class features: toString(), copy(), and structural equality."
            }
        ]
    }',

    E'In this chapter, you learned:\n- How data classes auto-generate useful methods\n- Custom property getters for computed values\n- Using copy() for immutable updates\n- Enum classes with properties\n\nNext, we''ll store multiple expenses using Kotlin''s powerful collections.',

    'beginner', 30, 1, 3
);

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'data-classes', id, 'primary', 'Modeling Expense entities with auto-generated methods'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 2;

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'properties', id, 'primary', 'Custom getters for formatted amounts and computed values'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 2;

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'enum-classes', id, 'secondary', 'Categorizing expenses with type-safe enums'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 2;

-- =====================================================
-- CHAPTER 3: Collections & Storage
-- Topics: collections-overview, collection-operations
-- =====================================================

INSERT INTO kotlin_expense_tracker_chapter (
    chapter_number, title, description, introduction,
    implementation_steps, code_snippets, summary,
    difficulty, estimated_time_minutes, previous_chapter, next_chapter
) VALUES (
    3,
    'Collections & In-Memory Storage',
    'Manage multiple expenses with Kotlin''s powerful collection operations',
    E'Our expense tracker needs to store and query multiple expenses. Kotlin''s collection API is incredibly powerful, offering functional operations like filter, map, groupBy, and sum that make data manipulation elegant and concise.\n\nWe''ll build an in-memory expense repository using these operations.',

    '[
        "Create an ExpenseRepository to store expenses in memory",
        "Implement add, remove, and find operations",
        "Use filter and map for querying expenses",
        "Calculate totals with sumOf and groupBy",
        "Sort expenses by date and amount"
    ]',

    '{
        "snippets": [
            {
                "filename": "repository/ExpenseRepository.kt",
                "language": "kotlin",
                "code": "class ExpenseRepository {\n    private val expenses = mutableListOf<Expense>()\n    private var nextId = 1L\n    \n    fun add(expense: Expense): Expense {\n        val newExpense = expense.copy(id = nextId++)\n        expenses.add(newExpense)\n        return newExpense\n    }\n    \n    fun remove(id: Long): Boolean = expenses.removeIf { it.id == id }\n    \n    fun findById(id: Long): Expense? = expenses.find { it.id == id }\n    \n    fun findAll(): List<Expense> = expenses.toList()\n    \n    fun findByCategory(category: ExpenseCategory): List<Expense> =\n        expenses.filter { it.category == category }\n    \n    fun findRecent(days: Int = 7): List<Expense> {\n        val cutoff = LocalDate.now().minusDays(days.toLong())\n        return expenses.filter { it.date.isAfter(cutoff) }\n    }\n}",
                "explanation": "Repository pattern using mutableListOf for storage. Collection operations like filter and find make querying simple."
            },
            {
                "filename": "service/ExpenseAnalytics.kt",
                "language": "kotlin",
                "code": "class ExpenseAnalytics(private val repository: ExpenseRepository) {\n    \n    fun totalExpenses(): Double =\n        repository.findAll().sumOf { it.amount }\n    \n    fun totalByCategory(): Map<ExpenseCategory, Double> =\n        repository.findAll()\n            .groupBy { it.category }\n            .mapValues { (_, expenses) -> expenses.sumOf { it.amount } }\n    \n    fun topExpenses(limit: Int = 5): List<Expense> =\n        repository.findAll()\n            .sortedByDescending { it.amount }\n            .take(limit)\n    \n    fun expensesByMonth(): Map<String, List<Expense>> =\n        repository.findAll()\n            .groupBy { \"${it.date.year}-${it.date.monthValue.toString().padStart(2, ''0'')}\" }\n            .toSortedMap()\n}",
                "explanation": "Analytics using collection operations: sumOf, groupBy, sortedByDescending, and take."
            },
            {
                "filename": "Main.kt",
                "language": "kotlin",
                "code": "fun main() {\n    val repo = ExpenseRepository()\n    val analytics = ExpenseAnalytics(repo)\n    \n    // Add sample expenses\n    repo.add(Expense(0, 45.99, \"Groceries\", ExpenseCategory.FOOD))\n    repo.add(Expense(0, 120.00, \"Electric bill\", ExpenseCategory.UTILITIES))\n    repo.add(Expense(0, 35.50, \"Gas\", ExpenseCategory.TRANSPORT))\n    repo.add(Expense(0, 89.99, \"Concert tickets\", ExpenseCategory.ENTERTAINMENT))\n    \n    println(\"Total: $${analytics.totalExpenses()}\")\n    println(\"\\nBy Category:\")\n    analytics.totalByCategory().forEach { (cat, total) ->\n        println(\"  $cat: $$total\")\n    }\n}",
                "explanation": "Putting it together: adding expenses and running analytics queries."
            }
        ]
    }',

    E'In this chapter, you learned:\n- Using mutableListOf for in-memory storage\n- Filtering collections with filter and find\n- Aggregating with sumOf and groupBy\n- Sorting with sortedBy and sortedByDescending\n- Transforming data with map and mapValues\n\nNext, we''ll add business logic with functions and extension functions.',

    'intermediate', 35, 2, 4
);

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'collections-overview', id, 'primary', 'Using List and MutableList for expense storage'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 3;

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'collection-operations', id, 'primary', 'Filter, map, groupBy, and sum for expense analytics'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 3;

-- =====================================================
-- CHAPTER 4: Business Logic with Functions
-- Topics: functions-basics, extension-functions
-- =====================================================

INSERT INTO kotlin_expense_tracker_chapter (
    chapter_number, title, description, introduction,
    implementation_steps, code_snippets, summary,
    difficulty, estimated_time_minutes, previous_chapter, next_chapter
) VALUES (
    4,
    'Business Logic with Functions',
    'Add business rules using Kotlin functions and extension functions',
    E'Now we need to add business logic: validating expenses, formatting output, and computing budgets. Kotlin''s functions with default parameters and extension functions make this clean and expressive.\n\nExtension functions are particularly powerful - they let us add methods to existing classes without inheritance.',

    '[
        "Create validation functions with meaningful error messages",
        "Add extension functions for formatting and display",
        "Implement budget tracking with remaining balance",
        "Use default and named parameters for flexible APIs",
        "Create helper functions for common operations"
    ]',

    '{
        "snippets": [
            {
                "filename": "validation/ExpenseValidator.kt",
                "language": "kotlin",
                "code": "object ExpenseValidator {\n    fun validate(expense: Expense): ValidationResult {\n        val errors = mutableListOf<String>()\n        \n        if (expense.amount <= 0) {\n            errors.add(\"Amount must be positive\")\n        }\n        if (expense.amount > 10_000) {\n            errors.add(\"Amount exceeds maximum limit\")\n        }\n        if (expense.description.isBlank()) {\n            errors.add(\"Description cannot be empty\")\n        }\n        if (expense.description.length > 100) {\n            errors.add(\"Description too long (max 100 chars)\")\n        }\n        \n        return if (errors.isEmpty()) {\n            ValidationResult.Success\n        } else {\n            ValidationResult.Failure(errors)\n        }\n    }\n}\n\nsealed class ValidationResult {\n    object Success : ValidationResult()\n    data class Failure(val errors: List<String>) : ValidationResult()\n}",
                "explanation": "Validator using sealed classes for type-safe results. Notice the object declaration for singleton."
            },
            {
                "filename": "extensions/ExpenseExtensions.kt",
                "language": "kotlin",
                "code": "// Extension functions add methods to Expense class\n\nfun Expense.toDisplayString(): String =\n    \"${category.emoji} ${description}: ${formattedAmount} (${date})\"\n\nfun Expense.isOverBudget(budget: Double): Boolean =\n    amount > budget\n\nfun List<Expense>.totalAmount(): Double =\n    sumOf { it.amount }\n\nfun List<Expense>.filterByAmountRange(\n    min: Double = 0.0,\n    max: Double = Double.MAX_VALUE\n): List<Expense> = filter { it.amount in min..max }\n\n// Extension property\nval List<Expense>.averageAmount: Double\n    get() = if (isEmpty()) 0.0 else totalAmount() / size",
                "explanation": "Extension functions and properties. We add new methods to Expense and List<Expense> without modifying them."
            },
            {
                "filename": "service/BudgetService.kt",
                "language": "kotlin",
                "code": "class BudgetService(\n    private val repository: ExpenseRepository,\n    private val monthlyBudget: Double = 2000.0\n) {\n    fun getRemainingBudget(month: Int = LocalDate.now().monthValue): Double {\n        val spent = repository.findAll()\n            .filter { it.date.monthValue == month }\n            .totalAmount()  // Using our extension function!\n        return monthlyBudget - spent\n    }\n    \n    fun getBudgetStatus(month: Int = LocalDate.now().monthValue): BudgetStatus {\n        val remaining = getRemainingBudget(month)\n        val percentage = (remaining / monthlyBudget) * 100\n        \n        return when {\n            percentage > 50 -> BudgetStatus.HEALTHY\n            percentage > 20 -> BudgetStatus.WARNING\n            percentage > 0 -> BudgetStatus.CRITICAL\n            else -> BudgetStatus.OVER_BUDGET\n        }\n    }\n}\n\nenum class BudgetStatus(val message: String) {\n    HEALTHY(\"Budget looking good!\"),\n    WARNING(\"Budget getting tight\"),\n    CRITICAL(\"Budget almost depleted!\"),\n    OVER_BUDGET(\"Over budget!\")\n}",
                "explanation": "Budget service using default parameters and extension functions. The when expression provides clean status logic."
            }
        ]
    }',

    E'In this chapter, you learned:\n- Functions with default and named parameters\n- Extension functions to add methods to existing classes\n- Extension properties for computed values\n- Using sealed classes for type-safe results\n- When expressions for status/state logic\n\nNext, we''ll build a user interface using control flow and string templates.',

    'intermediate', 35, 3, 5
);

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'functions-basics', id, 'primary', 'Creating validation and business logic functions'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 4;

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'extension-functions', id, 'primary', 'Adding methods to Expense and List<Expense>'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 4;

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'sealed-classes', id, 'secondary', 'Type-safe validation results'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 4;

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'default-named-args', id, 'reference', 'Flexible function APIs with default values'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 4;

-- =====================================================
-- CHAPTER 5: User Interface (CLI)
-- Topics: control-flow-if-when, string-templates
-- =====================================================

INSERT INTO kotlin_expense_tracker_chapter (
    chapter_number, title, description, introduction,
    implementation_steps, code_snippets, summary,
    difficulty, estimated_time_minutes, previous_chapter, next_chapter
) VALUES (
    5,
    'Building the CLI Interface',
    'Create an interactive command-line interface with menus and input handling',
    E'Let''s build a user-friendly command-line interface for our expense tracker. We''ll use Kotlin''s when expression (a powerful switch statement), string templates for output formatting, and control flow to handle user input.\n\nThe result will be an interactive menu-driven application.',

    '[
        "Create a main menu with numbered options",
        "Handle user input with when expressions",
        "Format output using string templates",
        "Implement input validation and error messages",
        "Add a table-like display for expense lists"
    ]',

    '{
        "snippets": [
            {
                "filename": "ui/ExpenseTrackerCLI.kt",
                "language": "kotlin",
                "code": "class ExpenseTrackerCLI(\n    private val repository: ExpenseRepository,\n    private val analytics: ExpenseAnalytics,\n    private val budgetService: BudgetService\n) {\n    fun run() {\n        println(\"\\n💰 Welcome to Expense Tracker!\\n\")\n        \n        var running = true\n        while (running) {\n            printMenu()\n            running = handleInput(readLine() ?: \"\")\n        }\n        println(\"\\nGoodbye! 👋\")\n    }\n    \n    private fun printMenu() {\n        val status = budgetService.getBudgetStatus()\n        val remaining = budgetService.getRemainingBudget()\n        \n        println(\"\"\"\n            |📊 Budget Status: ${status.message}\n            |   Remaining: $${String.format(\"%.2f\", remaining)}\n            |\n            |Choose an option:\n            |  1. Add expense\n            |  2. View all expenses\n            |  3. View by category\n            |  4. View analytics\n            |  5. Exit\n        \"\"\".trimMargin())\n        print(\"\\n> \")\n    }\n}",
                "explanation": "Main CLI class using string templates with trimMargin() for clean multi-line output."
            },
            {
                "filename": "ui/ExpenseTrackerCLI.kt (continued)",
                "language": "kotlin",
                "code": "private fun handleInput(input: String): Boolean {\n    return when (input.trim()) {\n        \"1\" -> { addExpense(); true }\n        \"2\" -> { viewAllExpenses(); true }\n        \"3\" -> { viewByCategory(); true }\n        \"4\" -> { viewAnalytics(); true }\n        \"5\" -> false\n        else -> {\n            println(\"\\n❌ Invalid option. Please try again.\")\n            true\n        }\n    }\n}\n\nprivate fun addExpense() {\n    println(\"\\n--- Add New Expense ---\")\n    \n    print(\"Amount: $\")\n    val amount = readLine()?.toDoubleOrNull() ?: run {\n        println(\"Invalid amount!\")\n        return\n    }\n    \n    print(\"Description: \")\n    val description = readLine() ?: \"\"\n    \n    println(\"Category:\")\n    ExpenseCategory.values().forEachIndexed { index, cat ->\n        println(\"  ${index + 1}. $cat\")\n    }\n    print(\"Choice: \")\n    val catIndex = (readLine()?.toIntOrNull() ?: 1) - 1\n    val category = ExpenseCategory.values().getOrElse(catIndex) { \n        ExpenseCategory.OTHER \n    }\n    \n    val expense = Expense(0, amount, description, category)\n    val result = ExpenseValidator.validate(expense)\n    \n    when (result) {\n        is ValidationResult.Success -> {\n            repository.add(expense)\n            println(\"\\n✅ Expense added successfully!\")\n        }\n        is ValidationResult.Failure -> {\n            println(\"\\n❌ Validation failed:\")\n            result.errors.forEach { println(\"   - $it\") }\n        }\n    }\n}",
                "explanation": "Input handling with when expressions. Note smart casting with ''is'' for sealed class matching."
            },
            {
                "filename": "ui/TableFormatter.kt",
                "language": "kotlin",
                "code": "object TableFormatter {\n    fun formatExpenses(expenses: List<Expense>): String {\n        if (expenses.isEmpty()) {\n            return \"No expenses found.\"\n        }\n        \n        val header = \"| ID | Category        | Description                  | Amount    | Date       |\"\n        val separator = \"|----|-----------------|-----------------------------|-----------|------------|\"\n        \n        val rows = expenses.map { e ->\n            val cat = e.category.displayName.padEnd(15)\n            val desc = e.description.take(27).padEnd(27)\n            val amt = e.formattedAmount.padStart(9)\n            \"| ${e.id.toString().padEnd(2)} | $cat | $desc | $amt | ${e.date} |\"\n        }\n        \n        return buildString {\n            appendLine(header)\n            appendLine(separator)\n            rows.forEach { appendLine(it) }\n            appendLine(separator)\n            appendLine(\"Total: $${expenses.totalAmount()}\")\n        }\n    }\n}",
                "explanation": "Table formatting using string operations, padEnd/padStart, and buildString for efficient concatenation."
            }
        ]
    }',

    E'In this chapter, you learned:\n- Using when expressions for menu handling\n- Smart casts with sealed class matching (is keyword)\n- String templates and multi-line strings with trimMargin()\n- Input validation and error handling\n- Formatting output with padEnd and padStart\n\nNext, we''ll add proper error handling and null safety.',

    'intermediate', 40, 4, 6
);

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'control-flow-if-when', id, 'primary', 'Menu handling and conditional logic'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 5;

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'string-templates', id, 'primary', 'Formatting CLI output and menus'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 5;

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'loops-ranges', id, 'secondary', 'Iterating through menu options'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 5;

-- =====================================================
-- CHAPTER 6: Error Handling & Null Safety
-- Topics: exceptions, null-safety
-- =====================================================

INSERT INTO kotlin_expense_tracker_chapter (
    chapter_number, title, description, introduction,
    implementation_steps, code_snippets, summary,
    difficulty, estimated_time_minutes, previous_chapter, next_chapter
) VALUES (
    6,
    'Error Handling & Null Safety',
    'Handle errors gracefully and leverage Kotlin''s null safety features',
    E'Real applications need robust error handling. Kotlin''s null safety system prevents NullPointerExceptions at compile time, and its try-catch expressions make error handling concise.\n\nWe''ll refactor our code to properly handle edge cases and potential failures.',

    '[
        "Use nullable types and safe calls (?.) for optional data",
        "Apply the Elvis operator (?:) for default values",
        "Create a Result type for operation outcomes",
        "Use try-catch as expressions",
        "Implement proper error messages and recovery"
    ]',

    '{
        "snippets": [
            {
                "filename": "util/Result.kt",
                "language": "kotlin",
                "code": "sealed class Result<out T> {\n    data class Success<T>(val data: T) : Result<T>()\n    data class Error(val message: String, val cause: Throwable? = null) : Result<Nothing>()\n    \n    fun getOrNull(): T? = when (this) {\n        is Success -> data\n        is Error -> null\n    }\n    \n    fun getOrThrow(): T = when (this) {\n        is Success -> data\n        is Error -> throw IllegalStateException(message, cause)\n    }\n    \n    inline fun <R> map(transform: (T) -> R): Result<R> = when (this) {\n        is Success -> Success(transform(data))\n        is Error -> this\n    }\n    \n    inline fun onSuccess(action: (T) -> Unit): Result<T> {\n        if (this is Success) action(data)\n        return this\n    }\n    \n    inline fun onError(action: (String) -> Unit): Result<T> {\n        if (this is Error) action(message)\n        return this\n    }\n}\n\ninline fun <T> runCatching(block: () -> T): Result<T> {\n    return try {\n        Result.Success(block())\n    } catch (e: Exception) {\n        Result.Error(e.message ?: \"Unknown error\", e)\n    }\n}",
                "explanation": "Custom Result type using sealed classes. This provides type-safe error handling without exceptions."
            },
            {
                "filename": "repository/ExpenseRepository.kt",
                "language": "kotlin",
                "code": "class ExpenseRepository {\n    private val expenses = mutableListOf<Expense>()\n    \n    fun findById(id: Long): Expense? =  // Nullable return\n        expenses.find { it.id == id }\n    \n    fun findByIdOrThrow(id: Long): Expense =\n        findById(id) ?: throw ExpenseNotFoundException(id)\n    \n    fun safeDelete(id: Long): Result<Unit> = runCatching {\n        val expense = findById(id)\n            ?: throw ExpenseNotFoundException(id)\n        expenses.remove(expense)\n    }\n    \n    fun updateAmount(id: Long, newAmount: Double): Result<Expense> {\n        val expense = findById(id)\n            ?: return Result.Error(\"Expense not found: $id\")\n        \n        if (newAmount <= 0) {\n            return Result.Error(\"Amount must be positive\")\n        }\n        \n        val updated = expense.copy(amount = newAmount)\n        expenses[expenses.indexOf(expense)] = updated\n        return Result.Success(updated)\n    }\n}\n\nclass ExpenseNotFoundException(id: Long) : \n    RuntimeException(\"Expense with id $id not found\")",
                "explanation": "Repository with null-safe operations and Result type for error handling."
            },
            {
                "filename": "ui/ExpenseTrackerCLI.kt",
                "language": "kotlin",
                "code": "private fun deleteExpense() {\n    print(\"Enter expense ID to delete: \")\n    val id = readLine()?.toLongOrNull() ?: run {\n        println(\"Invalid ID format!\")\n        return\n    }\n    \n    repository.safeDelete(id)\n        .onSuccess { println(\"✅ Expense deleted!\") }\n        .onError { println(\"❌ Error: $it\") }\n}\n\nprivate fun parseAmount(input: String?): Double {\n    // Elvis operator chain\n    return input\n        ?.trim()\n        ?.replace(\"$\", \"\")\n        ?.toDoubleOrNull()\n        ?: 0.0\n}\n\nprivate fun getExpenseDetails(id: Long) {\n    // Safe call chain with Elvis\n    val details = repository.findById(id)\n        ?.let { expense ->\n            \"\"\"\n            |Expense #${expense.id}\n            |Amount: ${expense.formattedAmount}\n            |Category: ${expense.category}\n            |Description: ${expense.description}\n            |Date: ${expense.date}\n            \"\"\".trimMargin()\n        }\n        ?: \"Expense not found\"\n    \n    println(details)\n}",
                "explanation": "CLI using safe calls, Elvis operator, and Result type for clean error handling."
            }
        ]
    }',

    E'In this chapter, you learned:\n- Nullable types (T?) and safe calls (?.)\n- The Elvis operator (?:) for defaults\n- Custom Result type for type-safe errors\n- Try-catch as expressions\n- Chaining safe calls with let\n\nNext, we''ll add file persistence using sequences and scope functions.',

    'intermediate', 35, 5, 7
);

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'exceptions', id, 'primary', 'Error handling with try-catch and custom exceptions'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 6;

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'null-safety', id, 'primary', 'Null-safe operations for optional expense data'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 6;

-- =====================================================
-- CHAPTER 7: File Persistence
-- Topics: sequences, scope-functions
-- =====================================================

INSERT INTO kotlin_expense_tracker_chapter (
    chapter_number, title, description, introduction,
    implementation_steps, code_snippets, summary,
    difficulty, estimated_time_minutes, previous_chapter, next_chapter
) VALUES (
    7,
    'File Persistence with Sequences',
    'Save and load expenses from files using sequences and scope functions',
    E'Our expense tracker needs to persist data between sessions. We''ll implement file-based storage using Kotlin''s sequences for efficient lazy processing and scope functions (apply, also, let, run, with) for clean object initialization.\n\nSequences are particularly useful for large datasets as they process elements lazily.',

    '[
        "Create a file-based storage implementation",
        "Use sequences for lazy file processing",
        "Apply scope functions for clean code",
        "Implement CSV import/export",
        "Handle file errors gracefully"
    ]',

    '{
        "snippets": [
            {
                "filename": "storage/FileStorage.kt",
                "language": "kotlin",
                "code": "import java.io.File\n\nclass FileStorage(private val filePath: String) {\n    private val file = File(filePath)\n    \n    fun saveExpenses(expenses: List<Expense>) {\n        file.bufferedWriter().use { writer ->\n            // Header\n            writer.write(\"id,amount,description,category,date\")\n            writer.newLine()\n            \n            // Data rows\n            expenses.forEach { expense ->\n                writer.apply {\n                    write(expense.toCsvLine())\n                    newLine()\n                }\n            }\n        }\n    }\n    \n    fun loadExpenses(): Sequence<Expense> {\n        if (!file.exists()) return emptySequence()\n        \n        return file.bufferedReader()\n            .lineSequence()      // Lazy line reading\n            .drop(1)             // Skip header\n            .mapNotNull { line ->\n                runCatching { parseCsvLine(line) }.getOrNull()\n            }\n    }\n}",
                "explanation": "File storage using sequences for lazy processing. The apply scope function chains writer operations."
            },
            {
                "filename": "storage/FileStorage.kt (parsing)",
                "language": "kotlin",
                "code": "private fun Expense.toCsvLine(): String =\n    listOf(id, amount, description.escapeCsv(), category.name, date)\n        .joinToString(\",\")\n\nprivate fun String.escapeCsv(): String = \n    if (contains(\",\") || contains(\"\\\"\")) {\n        \"\\\"${replace(\"\\\"\", \"\\\"\\\"\")}\\\"\"\n    } else this\n\nprivate fun parseCsvLine(line: String): Expense {\n    val parts = line.split(\",\")\n    return Expense(\n        id = parts[0].toLong(),\n        amount = parts[1].toDouble(),\n        description = parts[2].unescapeCsv(),\n        category = ExpenseCategory.valueOf(parts[3]),\n        date = LocalDate.parse(parts[4])\n    )\n}\n\n// With scope function for complex initialization\nfun loadAndMerge(existingExpenses: List<Expense>): List<Expense> {\n    return with(loadExpenses().toList()) {\n        val existingIds = existingExpenses.map { it.id }.toSet()\n        val newExpenses = filterNot { it.id in existingIds }\n        existingExpenses + newExpenses\n    }\n}",
                "explanation": "CSV parsing with extension functions. The with scope function provides a clean context for operations."
            },
            {
                "filename": "repository/PersistentExpenseRepository.kt",
                "language": "kotlin",
                "code": "class PersistentExpenseRepository(\n    private val storage: FileStorage\n) : ExpenseRepository() {\n    \n    init {\n        // Load expenses on startup using also for side effect\n        storage.loadExpenses()\n            .also { println(\"Loading ${it.count()} expenses...\") }\n            .forEach { super.add(it) }\n    }\n    \n    override fun add(expense: Expense): Expense {\n        return super.add(expense).also { \n            saveAll()  // Persist after each add\n        }\n    }\n    \n    override fun remove(id: Long): Boolean {\n        return super.remove(id).also { success ->\n            if (success) saveAll()\n        }\n    }\n    \n    private fun saveAll() {\n        storage.saveExpenses(findAll())\n    }\n    \n    // Using run for scoped operations\n    fun exportReport(path: String) = run {\n        val report = StringBuilder()\n        report.appendLine(\"Expense Report\")\n        report.appendLine(\"Generated: ${LocalDate.now()}\")\n        report.appendLine()\n        \n        findAll().groupBy { it.category }.forEach { (cat, expenses) ->\n            report.appendLine(\"$cat: $${expenses.totalAmount()}\")\n        }\n        \n        File(path).writeText(report.toString())\n    }\n}",
                "explanation": "Persistent repository using also for side effects and run for scoped operations."
            }
        ]
    }',

    E'In this chapter, you learned:\n- Sequences for lazy file processing\n- Scope functions: apply, also, let, run, with\n- File I/O with use for auto-closing\n- Extension functions for data formatting\n- Chaining operations with scope functions\n\nIn the final chapter, we''ll add tests using Kotlin testing frameworks.',

    'intermediate', 40, 6, 8
);

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'sequences', id, 'primary', 'Lazy file reading and processing'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 7;

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'scope-functions', id, 'primary', 'Object initialization and side effects'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 7;

-- =====================================================
-- CHAPTER 8: Testing
-- Topics: testing-basics, mockk
-- =====================================================

INSERT INTO kotlin_expense_tracker_chapter (
    chapter_number, title, description, introduction,
    implementation_steps, code_snippets, summary,
    difficulty, estimated_time_minutes, previous_chapter, next_chapter
) VALUES (
    8,
    'Testing Your Application',
    'Write comprehensive tests using Kotlin testing frameworks',
    E'A well-tested application is a reliable application. In this final chapter, we''ll write unit tests and integration tests for our expense tracker using Kotlin''s testing ecosystem.\n\nWe''ll use JUnit 5 for the test framework and MockK for mocking dependencies.',

    '[
        "Set up testing dependencies (JUnit 5, MockK)",
        "Write unit tests for the Expense data class",
        "Test the ExpenseRepository with in-memory data",
        "Mock the FileStorage for repository tests",
        "Write integration tests for the full flow"
    ]',

    '{
        "snippets": [
            {
                "filename": "build.gradle.kts",
                "language": "kotlin",
                "code": "dependencies {\n    // Testing\n    testImplementation(kotlin(\"test\"))\n    testImplementation(\"org.junit.jupiter:junit-jupiter:5.10.0\")\n    testImplementation(\"io.mockk:mockk:1.13.8\")\n    testImplementation(\"org.assertj:assertj-core:3.24.2\")\n}\n\ntasks.test {\n    useJUnitPlatform()\n}",
                "explanation": "Test dependencies: JUnit 5 for testing, MockK for mocking, and AssertJ for fluent assertions."
            },
            {
                "filename": "test/model/ExpenseTest.kt",
                "language": "kotlin",
                "code": "import org.junit.jupiter.api.Test\nimport org.junit.jupiter.api.Assertions.*\nimport java.time.LocalDate\n\nclass ExpenseTest {\n    \n    @Test\n    fun `data class equality works correctly`() {\n        val expense1 = Expense(1, 25.99, \"Lunch\", ExpenseCategory.FOOD)\n        val expense2 = Expense(1, 25.99, \"Lunch\", ExpenseCategory.FOOD)\n        \n        assertEquals(expense1, expense2)\n    }\n    \n    @Test\n    fun `copy creates modified instance`() {\n        val original = Expense(1, 25.99, \"Lunch\", ExpenseCategory.FOOD)\n        val updated = original.copy(amount = 30.00)\n        \n        assertNotEquals(original, updated)\n        assertEquals(30.00, updated.amount)\n        assertEquals(original.description, updated.description)\n    }\n    \n    @Test\n    fun `formattedAmount includes dollar sign`() {\n        val expense = Expense(1, 25.99, \"Test\", ExpenseCategory.FOOD)\n        \n        assertTrue(expense.formattedAmount.startsWith(\"$\"))\n    }\n    \n    @Test\n    fun `isRecent returns true for today`() {\n        val expense = Expense(1, 10.0, \"Today\", ExpenseCategory.OTHER)\n        \n        assertTrue(expense.isRecent)\n    }\n}",
                "explanation": "Unit tests for Expense data class using JUnit 5 with backtick-named test methods."
            },
            {
                "filename": "test/repository/ExpenseRepositoryTest.kt",
                "language": "kotlin",
                "code": "import io.mockk.*\nimport org.junit.jupiter.api.*\nimport org.junit.jupiter.api.Assertions.*\n\nclass ExpenseRepositoryTest {\n    private lateinit var repository: ExpenseRepository\n    \n    @BeforeEach\n    fun setup() {\n        repository = ExpenseRepository()\n    }\n    \n    @Test\n    fun `add assigns unique ID`() {\n        val expense1 = repository.add(Expense(0, 10.0, \"First\", ExpenseCategory.FOOD))\n        val expense2 = repository.add(Expense(0, 20.0, \"Second\", ExpenseCategory.FOOD))\n        \n        assertNotEquals(expense1.id, expense2.id)\n    }\n    \n    @Test\n    fun `findById returns null for missing ID`() {\n        assertNull(repository.findById(999))\n    }\n    \n    @Test\n    fun `findByCategory filters correctly`() {\n        repository.add(Expense(0, 10.0, \"Lunch\", ExpenseCategory.FOOD))\n        repository.add(Expense(0, 50.0, \"Gas\", ExpenseCategory.TRANSPORT))\n        repository.add(Expense(0, 15.0, \"Dinner\", ExpenseCategory.FOOD))\n        \n        val foodExpenses = repository.findByCategory(ExpenseCategory.FOOD)\n        \n        assertEquals(2, foodExpenses.size)\n        assertTrue(foodExpenses.all { it.category == ExpenseCategory.FOOD })\n    }\n}",
                "explanation": "Repository tests with @BeforeEach setup and assertions."
            },
            {
                "filename": "test/repository/PersistentRepositoryTest.kt",
                "language": "kotlin",
                "code": "import io.mockk.*\nimport org.junit.jupiter.api.*\n\nclass PersistentRepositoryTest {\n    private val mockStorage = mockk<FileStorage>()\n    private lateinit var repository: PersistentExpenseRepository\n    \n    @BeforeEach\n    fun setup() {\n        // Configure mock to return empty sequence on load\n        every { mockStorage.loadExpenses() } returns emptySequence()\n        every { mockStorage.saveExpenses(any()) } just Runs\n        \n        repository = PersistentExpenseRepository(mockStorage)\n    }\n    \n    @Test\n    fun `add saves to storage`() {\n        val expense = Expense(0, 25.0, \"Test\", ExpenseCategory.FOOD)\n        \n        repository.add(expense)\n        \n        verify { mockStorage.saveExpenses(any()) }\n    }\n    \n    @Test\n    fun `remove saves to storage on success`() {\n        val added = repository.add(Expense(0, 25.0, \"Test\", ExpenseCategory.FOOD))\n        clearMocks(mockStorage, answers = false)  // Clear previous calls\n        \n        repository.remove(added.id)\n        \n        verify(exactly = 1) { mockStorage.saveExpenses(any()) }\n    }\n    \n    @Test\n    fun `loads expenses on initialization`() {\n        val testExpenses = sequenceOf(\n            Expense(1, 10.0, \"Loaded1\", ExpenseCategory.FOOD),\n            Expense(2, 20.0, \"Loaded2\", ExpenseCategory.TRANSPORT)\n        )\n        every { mockStorage.loadExpenses() } returns testExpenses\n        \n        val newRepo = PersistentExpenseRepository(mockStorage)\n        \n        assertEquals(2, newRepo.findAll().size)\n    }\n}",
                "explanation": "Tests with MockK: mockk() creates mocks, every {} stubs behavior, verify {} checks calls."
            }
        ]
    }',

    E'Congratulations! You''ve completed the Expense Tracker tutorial!\n\nIn this chapter, you learned:\n- Setting up Kotlin testing with JUnit 5\n- Writing unit tests with meaningful names\n- Using MockK for mocking dependencies\n- Testing data classes, repositories, and services\n- Integration testing patterns\n\nYou now have a fully functional, tested expense tracker application that demonstrates many Kotlin features!',

    'intermediate', 45, 7, NULL
);

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'testing-basics', id, 'primary', 'Unit testing with JUnit 5 and Kotlin'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 8;

INSERT INTO kotlin_topic_chapter_link (topic_id, chapter_id, usage_type, context_description)
SELECT 'mockk', id, 'primary', 'Mocking dependencies with MockK'
FROM kotlin_expense_tracker_chapter WHERE chapter_number = 8;

-- Update navigation links for all chapters
UPDATE kotlin_expense_tracker_chapter SET updated_at = NOW();
