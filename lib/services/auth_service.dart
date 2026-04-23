import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://localhost:8080/api/auth";

  // register
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type" : "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );
      return response.statusCode == 200;
    }
    catch(e) {
      return false;
    }
  }

  // login
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type" : "application/json"},
        body: jsonEncode({
          "email":email,
          "password":password,
        })
      );

      if(response.statusCode == 200) {
        // save token to device
        String token = response.body;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        return true;
      }
      return false;
    }
    catch(e) {
      return false;
    }
  }

  // get stored token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // logout
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
  }

  // check if user is logged in
  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }
}
