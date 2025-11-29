import 'package:flutter/material.dart';
import 'package:smart_clearance_app/screens/faculty/dashboard_page.dart';
import 'package:smart_clearance_app/screens/admin/dashboard_page.dart';
import 'package:smart_clearance_app/screens/admin/departments/registrar_approvals_page.dart';
import '../../services/api_service.dart'; // Import the API service
import 'package:smart_clearance_app/globals.dart' as G; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String selectedAccount = "Faculty";  // Default account type
  String email = "";
  String password = "";

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
            },
            child: const Text(
              "Test Faculty Dashboard",
              style: TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
              );
            },
            child: const Text(
              "Test Admin Dashboard",
              style: TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Image.asset('assets/sdca_logo.png', width: 120),
                const SizedBox(height: 16),
                const Text("Faculty Academic Clearance", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const Text("St. Dominic College of Asia", style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 32),

                Container(
                  width: 450,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
                  ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Color(0xFFB71C1C), borderRadius: BorderRadius.circular(12)),
                        child: const Text("Sign In\nEnter your credentials to access the system", style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 24),
                      const Text("Account Type", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => selectedAccount = "Faculty");
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedAccount == "Faculty" ? Color(0xFFB71C1C) : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Faculty",
                                    style: TextStyle(
                                      color: selectedAccount == "Faculty" ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => selectedAccount = "Admin");
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedAccount == "Admin" ? Color(0xFFB71C1C) : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Admin",
                                    style: TextStyle(
                                      color: selectedAccount == "Admin" ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "your.email@sdca.edu.ph",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFB71C1C),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                final role = selectedAccount.toLowerCase();  // faculty / admin

                final loginResp = await ApiService.login(email, password, role);

                if (loginResp["success"] == true) {
                  final user = loginResp["data"]["user"];
                  final userRole = user["role"];

                    // ================= FACULTY =================
                    if (userRole == "faculty") {

                      // 🟢 Save user details to globals
                      G.currentFullName  = user["fullName"];
                      G.currentEmail = user["email"];

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const DashboardPage()),
                      );
                      return;
                      
                    }


                  // ================= ADMIN (ANY DEPARTMENT) =================
                if (userRole.startsWith("admin-")) {

                  // 🔥 Save department + email globally
                  G.currentFullName   = user["fullName"]; 
                  G.currentDepartment = userRole.replaceFirst("admin-", "");
                  G.currentEmail = user["email"];   

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                  );
                  return;
                }


                  // Fallback
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                  );
                } 
                else {
                  ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(loginResp["message"] ?? "Login failed")));
                }
              },



                          child: const Text("Sign in", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                const Text("© 2025 St. Dominic College of Asia. All rights reserved.", style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
