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

  @override
  void initState() {
    super.initState();
    loadExpenses(); // load expenses when screen opens
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

  // Delete expense
  void deleteExpense(int id) async {
    bool success = await expenseService.deleteExpense(id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense deleted!")),
      );
      loadExpenses(); // refresh list
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

  // Calculate total expenses
  double get totalExpenses {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // App Bar
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

      // Body
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

          // Expenses list
          Expanded(
            child: expenses.isEmpty
                ? const Center(
              child: Text(
                "No expenses yet!\nTap + to add one.",
                textAlign: TextAlign.center,
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
                                builder: (context) => EditExpenseScreen(
                                  expense: expense, // pass expense to edit screen
                                ),
                              ),
                            );
                            loadExpenses(); // refresh after editing
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => deleteExpense(expense.id),
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

      // Add expense button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
          loadExpenses(); // refresh after adding
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}