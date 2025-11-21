import 'package:flutter/material.dart';
import 'screens/auth/login_page.dart';
import 'screens/faculty/dashboard_page.dart';
import 'screens/faculty/my_clearance_page.dart';
import 'screens/faculty/signatories_page.dart';
import 'screens/faculty/profile_page.dart';
import 'screens/faculty/faculty_view_details.dart';
import 'screens/faculty/faculty_view_details_ocr.dart';

import 'screens/admin/dashboard_page.dart';
import 'screens/admin/approvals_page.dart';
import 'screens/admin/profile_page.dart';
import 'screens/admin/admin_view_details.dart';


import 'screens/test_requests_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/login",

      
      routes: {
        "/login": (context) => const LoginPage(),
        "/dashboard": (context) => const DashboardPage(),
        "/my_clearance": (context) => const MyClearancePage(),
        "/view_details": (context) => const FacultyViewDetailsPage(),
        "/signatories": (context) => const SignatoriesPage(),
        "/profile": (context) => const ProfilePage(),

        "/admin_dashboard": (context) => const AdminDashboardPage(),
        "/admin_approvals": (context) => const AdminApprovalsPage(),
        "/admin_view_details": (context) => const AdminViewDetailsPage(),
        '/ocr': (context) => FacultyViewDetailsOcrPage(),
        "/admin_profile": (context) => const AdminProfilePage(),

        "/test": (context) => const TestRequestsScreen(),


      },
    );
  }
}
