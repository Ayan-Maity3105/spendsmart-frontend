import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'AddExpenseScreen.dart';
import 'EditExpenseScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ExpenseService expenseService = ExpenseService();
  List<Expense> expenses = [];
  bool isLoading = false;

  final TextEditingController searchController = TextEditingController();
  String selectedCategory = "All";
  DateTimeRange? selectedDateRange;
  DateTime? _lastSearchTime;

  final List<String> categories = [
    "All", "Food", "Transport", "Shopping",
    "Education", "Health", "Entertainment", "Other",
  ];

  // Category icons
  final Map<String, IconData> categoryIcons = {
    "Food": Icons.restaurant_rounded,
    "Transport": Icons.directions_car_rounded,
    "Shopping": Icons.shopping_bag_rounded,
    "Education": Icons.school_rounded,
    "Health": Icons.favorite_rounded,
    "Entertainment": Icons.movie_rounded,
    "Other": Icons.category_rounded,
  };

  // Category colors
  final Map<String, Color> categoryColors = {
    "Food": const Color(0xFFFF6B6B),
    "Transport": const Color(0xFF4ECDC4),
    "Shopping": const Color(0xFFFFE66D),
    "Education": const Color(0xFF6C63FF),
    "Health": const Color(0xFFFF8B94),
    "Entertainment": const Color(0xFFA8E6CF),
    "Other": const Color(0xFF95A5A6),
  };

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  void loadExpenses() async {
    setState(() => isLoading = true);
    List<Expense> data = await expenseService.getAllExpenses();
    setState(() {
      expenses = data;
      isLoading = false;
    });
  }

  void searchExpenses(String keyword) async {
    _lastSearchTime = DateTime.now();
    final searchTime = _lastSearchTime;
    await Future.delayed(const Duration(milliseconds: 500));
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

  void filterExpenses() async {
    setState(() => isLoading = true);
    String startDate = selectedDateRange != null
        ? "${selectedDateRange!.start.year}-${selectedDateRange!.start.month.toString().padLeft(2, '0')}-${selectedDateRange!.start.day.toString().padLeft(2, '0')}"
        : "2020-01-01";
    String endDate = selectedDateRange != null
        ? "${selectedDateRange!.end.year}-${selectedDateRange!.end.month.toString().padLeft(2, '0')}-${selectedDateRange!.end.day.toString().padLeft(2, '0')}"
        : "2030-12-31";

    List<Expense> data = await expenseService.filterExpenses(
      startDate, endDate, category: selectedCategory,
    );
    setState(() {
      expenses = data;
      isLoading = false;
    });
  }

  void pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDateRange = picked);
  }

  void clearFilters() {
    setState(() {
      searchController.clear();
      selectedCategory = "All";
      selectedDateRange = null;
    });
    loadExpenses();
  }

  void deleteExpense(int id) async {
    bool success = await expenseService.deleteExpense(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Expense deleted!"),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      loadExpenses();
    }
  }

  double get totalExpenses {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F3460),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "SpendSmart 💰",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        body: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6C63FF),
          ),
        )
            : CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    // Total card — Glassmorphism
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6C63FF).withOpacity(0.3),
                                const Color(0xFF3B82F6).withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Total Expenses",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "₹ ${totalExpenses.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${expenses.length} transactions",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search bar — Glassmorphism
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: searchExpenses,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Search expenses...",
                              hintStyle: const TextStyle(
                                color: Colors.white38,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: Colors.white38,
                              ),
                              suffixIcon: searchController.text.isNotEmpty
                                  ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: Colors.white38,
                                ),
                                onPressed: clearFilters,
                              )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter row
                    Row(
                      children: [
                        // Category dropdown
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 10, sigmaY: 10,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedCategory,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF1A1A2E),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    items: categories.map((cat) {
                                      return DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() =>
                                      selectedCategory = value!);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Date button
                        _glassButton(
                          icon: Icons.date_range_rounded,
                          label: selectedDateRange == null
                              ? "Date"
                              : "${selectedDateRange!.start.day}/${selectedDateRange!.start.month}-${selectedDateRange!.end.day}/${selectedDateRange!.end.month}",
                          onTap: pickDateRange,
                        ),
                        const SizedBox(width: 8),

                        // Filter button
                        _glassButton(
                          icon: Icons.filter_list_rounded,
                          label: "Filter",
                          onTap: filterExpenses,
                          isPrimary: true,
                        ),
                      ],
                    ),

                    // Clear filters
                    if (selectedDateRange != null ||
                        selectedCategory != "All")
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextButton.icon(
                          onPressed: clearFilters,
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                          label: const Text(
                            "Clear Filters",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Expenses header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Expenses",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${expenses.length} items",
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Expenses list
            expenses.isEmpty
                ? SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 64,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No expenses found!",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    Expense expense = expenses[index];
                    Color color = categoryColors[expense.category]
                        ?? const Color(0xFF6C63FF);
                    IconData icon = categoryIcons[expense.category]
                        ?? Icons.category_rounded;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 10, sigmaY: 10,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: color.withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(icon, color: color, size: 22),
                              ),
                              title: Text(
                                expense.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "${expense.category} • ${expense.date}",
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "₹${expense.amount}",
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white38,
                                      size: 18,
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
                                      Icons.delete_rounded,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        deleteExpense(expense.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: expenses.length,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              );
              loadExpenses();
            },
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isPrimary
                  ? const Color(0xFF6C63FF).withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPrimary
                    ? const Color(0xFF6C63FF).withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}