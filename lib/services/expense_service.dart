import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/expense.dart';

class ExpenseService {
  final String baseUrl = "http://localhost:8080/api/expenses";
  final AuthService authService = AuthService();

  // get headers with the token
  Future<Map<String, String>> getHeader() async {
    String? token = await authService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // get all expense
  Future<List<Expense>> getAllExpenses() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await getHeader(),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Expense.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // add new expense
  Future<bool> addExpense(
    String title,
    double amount,
    String category,
    String date,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await getHeader(),
        body: jsonEncode({
          "title": title,
          "amount": amount,
          "category": category,
          "date": date,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // update
  Future<bool> updateExpense(
    int id,
    String title,
    double amount,
    String category,
    String date,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: await getHeader(),
        body: jsonEncode({
          "title": title,
          "amount": amount,
          "category": category,
          "date": date,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // delete
  Future<bool> deleteExpense(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: await getHeader(),
      );

      return response.statusCode == 200;
    }
    catch(e) {
      return false;
    }
  }

  // get expense by category
  Future<List<Expense>> getExpenseByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/category/$category"),
        headers: await getHeader(),
      );

      if(response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => Expense.fromJson(json))
            .toList();
      }
      return [];
    }
    catch(e) {
      return [];
    }
  }

  // Search by keyword
  Future<List<Expense>> searchExpenses(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/search?keyword=$keyword"),
        headers: await getHeader(),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => Expense.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

// Filter by date range
  Future<List<Expense>> filterExpenses(
      String startDate, String endDate, {String? category}) async {
    try {
      String url = "$baseUrl/filter?startDate=$startDate&endDate=$endDate";
      if (category != null && category.isNotEmpty && category != "All") {
        url += "&category=$category";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await getHeader(),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => Expense.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
