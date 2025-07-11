import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;
  String message = '';

  void handleAuth() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => message = "Username and password are required.");
      return;
    }

    if (isLogin) {
      bool success = await _dbHelper.loginUser(username, password);
      setState(() {
        message = success ? "Login successful!" : "Invalid credentials.";
      });
    } else {
      int result = await _dbHelper.registerUser(username, password);
      setState(() {
        message = result != -1 ? "Registration successful!" : "Username already exists.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleAuth,
              child: Text(isLogin ? "Login" : "Register"),
            ),
            TextButton(
              onPressed: () => setState(() {
                isLogin = !isLogin;
                message = '';
              }),
              child: Text(isLogin ? "Don't have an account? Register" : "Already have an account? Login"),
            ),
            SizedBox(height: 20),
            Text(message, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
