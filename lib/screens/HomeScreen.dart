import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';
import 'LoginScreen.dart';
import 'AddExpenseScreen.dart';
import 'EditExpenseScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ExpenseService expenseService = ExpenseService();
  final AuthService authService = AuthService();

  List<Expense> expenses = [];
  bool isLoading = false;

  // Search and filter state
  final TextEditingController searchController = TextEditingController();
  String selectedCategory = "All";
  DateTimeRange? selectedDateRange;

  final List<String> categories = [
    "All",
    "Food",
    "Transport",
    "Shopping",
    "Education",
    "Health",
    "Entertainment",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  // Load all expenses
  void loadExpenses() async {
    setState(() => isLoading = true);
    List<Expense> data = await expenseService.getAllExpenses();
    setState(() {
      expenses = data;
      isLoading = false;
    });
  }

  // Search expenses
  // Add this variable at top of state class
  DateTime? _lastSearchTime;

// Replace searchExpenses method
  void searchExpenses(String keyword) async {
    _lastSearchTime = DateTime.now();
    final searchTime = _lastSearchTime;

    // Wait 500ms before searching
    await Future.delayed(const Duration(milliseconds: 500));

    // If user typed more in the meantime, cancel this search
    if (searchTime != _lastSearchTime) return;

    if (keyword.isEmpty) {
      loadExpenses();
      return;
    }

    setState(() => isLoading = true);
    List<Expense> data = await expenseService.searchExpenses(keyword);
    setState(() {
      expenses = data;
      isLoading = false;
    });
  }

  // Filter expenses
  void filterExpenses() async {
    if (selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date range!")),
      );
      return;
    }

    setState(() => isLoading = true);

    String startDate =
        "${selectedDateRange!.start.year}-${selectedDateRange!.start.month.toString().padLeft(2, '0')}-${selectedDateRange!.start.day.toString().padLeft(2, '0')}";
    String endDate =
        "${selectedDateRange!.end.year}-${selectedDateRange!.end.month.toString().padLeft(2, '0')}-${selectedDateRange!.end.day.toString().padLeft(2, '0')}";

    List<Expense> data = await expenseService.filterExpenses(
      startDate,
      endDate,
      category: selectedCategory,
    );

    setState(() {
      expenses = data;
      isLoading = false;
    });
  }

  // Pick date range
  void pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDateRange = picked);
    }
  }

  // Clear filters
  void clearFilters() {
    setState(() {
      searchController.clear();
      selectedCategory = "All";
      selectedDateRange = null;
    });
    loadExpenses();
  }

  // Delete expense
  void deleteExpense(int id) async {
    bool success = await expenseService.deleteExpense(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense deleted!")),
      );
      loadExpenses();
    }
  }

  // Logout
  void logout() async {
    await authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Total expenses
  double get totalExpenses {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "SpendSmart 💰",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          // Total card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Expenses",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹ ${totalExpenses.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              onChanged: searchExpenses,
              decoration: InputDecoration(
                hintText: "Search expenses...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: clearFilters,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [

                // Category dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedCategory = value!);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Date range button
                ElevatedButton.icon(
                  onPressed: pickDateRange,
                  icon: const Icon(Icons.date_range, size: 16),
                  label: Text(
                    selectedDateRange == null
                        ? "Date"
                        : "${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Filter button
                ElevatedButton(
                  onPressed: filterExpenses,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Filter"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Clear filter button
          if (selectedDateRange != null || selectedCategory != "All")
            TextButton.icon(
              onPressed: clearFilters,
              icon: const Icon(Icons.clear, color: Colors.red),
              label: const Text(
                "Clear Filters",
                style: TextStyle(color: Colors.red),
              ),
            ),

          // Expenses list
          Expanded(
            child: expenses.isEmpty
                ? const Center(
              child: Text(
                "No expenses found!",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                Expense expense = expenses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple[100],
                      child: const Icon(
                        Icons.receipt,
                        color: Colors.deepPurple,
                      ),
                    ),
                    title: Text(
                      expense.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${expense.category} • ${expense.date}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "₹${expense.amount}",
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditExpenseScreen(
                                        expense: expense),
                              ),
                            );
                            loadExpenses();
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              deleteExpense(expense.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
          loadExpenses();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}