class Expense {
  final int id;
  final String title;
  final double amount;
  final String category;
  final String date;

  // constructor
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  // json => Expense Object

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(id: json['id'], title: json['title'], amount: json['amount'].toDouble(), category: json['category'], date: json['date'],);
  }

  // Expense Object to Json
  Map<String,dynamic> toJson() {
    return {
      "title": title,
      "amount": amount,
      "category": category,
      "date": date,
    };
  }

}
