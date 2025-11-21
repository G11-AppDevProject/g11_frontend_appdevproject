import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'approvals_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  int selectedIndex = 2; // Profile selected

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;

        return Scaffold(
          drawer: isMobile ? _buildSidebar() : null,
          body: Row(
            children: [
              if (!isMobile) _buildSidebar(),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------
  // SIDEBAR (Admin Version)
  // ------------------------------
  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFFF9F9F9),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/sdca_logo.png", width: 50),
              const SizedBox(width: 10),
              const Text(
                "Admin\nAcademic Clearance",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 30),

          _menuButton(Icons.dashboard, "Dashboard", 0),
          _menuButton(Icons.verified, "Approvals", 1),
          _menuButton(Icons.person, "Profile", 2),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
                },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() => selectedIndex = index);

        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminApprovalsPage()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        color: isSelected ? const Color(0xFFEEEDED) : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // MAIN CONTENT
  // ------------------------------
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profile",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "User’s account information",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),

          const SizedBox(height: 25),

          // NAME BANNER ----------------------
          _nameBanner(),

          const SizedBox(height: 25),

          // PERSONAL & PROFESSIONAL INFO -----
          Row(
            children: [
              Expanded(child: _personalInfoCard()),
              const SizedBox(width: 20),
              Expanded(child: _professionalInfoCard()),
            ],
          ),

          const SizedBox(height: 25),

          // ACCOUNT INFORMATION --------------
          _accountInfoCard(),
        ],
      ),
    );
  }

  // ------------------------------
  // COMPONENTS
  // ------------------------------

  Widget _nameBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFB71C1C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Juan Dela Cruz",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "juan.delacruz@sdca.edu.ph",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: const Text("Admin"),
          ),
        ],
      ),
    );
  }

  Widget _personalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Personal Information",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 14),

          Row(
            children: [
              Icon(Icons.email, size: 16),
              SizedBox(width: 8),
              Text("juan.delacruz@sdca.edu.ph"),
            ],
          ),
          SizedBox(height: 10),

          Row(
            children: [
              Icon(Icons.phone, size: 16),
              SizedBox(width: 8),
              Text("+63 (2) 1234-5678"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _professionalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Professional Information",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.apartment, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Department\nRegistrar’s Office",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _accountInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _boxStyle(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Account Information",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 12),

          Text("Administrator",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),

          Text("Account Type", style: TextStyle(color: Colors.black54)),
          SizedBox(height: 6),
          Text("Admin", style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black12),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}
