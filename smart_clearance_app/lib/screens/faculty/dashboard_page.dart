import 'package:flutter/material.dart';
import 'my_clearance_page.dart';
import 'profile_page.dart';
import 'signatories_page.dart';
import 'package:smart_clearance_app/globals.dart' as G;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

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
              Expanded(child: _buildDashboardContent()),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // SIDEBAR — similar to Admin Dashboard
  // --------------------------------------------------
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
              const Text("Faculty\nAcademic Clearance",
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
            ],
          ),

          const SizedBox(height: 30),
          _menuButton(Icons.dashboard, "Dashboard", 0),
          _menuButton(Icons.article, "My Clearance", 1),
          _menuButton(Icons.account_tree, "Signatories", 2),
          _menuButton(Icons.person, "Profile", 3),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
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

        if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClearancePage()));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const SignatoriesPage()));
        if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
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

  // --------------------------------------------------
  // MAIN UI CONTENT — Name + Email pulled from globals.dart
  // --------------------------------------------------
  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text("Dashboard",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
          ),

          const SizedBox(height: 5),
          Text("Welcome, ${G.currentFullName} 👋",
            style: const TextStyle(fontSize: 16, color: Colors.black54)
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              _infoCard("Name", G.currentFullName, "Faculty"),
              const SizedBox(width: 20),
              _infoCard("Email", G.currentEmail, ""),
              const SizedBox(width: 20),
              _statusCard(),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(child: _clearanceCard()),
              const SizedBox(width: 20),
              Expanded(child: _profileCard()),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // CARDS
  // --------------------------------------------------
  Widget _infoCard(String title, String main, String tag) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _boxStyle(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Text(main, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (tag.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20)),
                child: Text(tag),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _boxStyle(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Status", style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.green.shade200, borderRadius: BorderRadius.circular(20)),
              child: const Text("Active", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clearanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("My Clearance", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("View status and requirements of your clearance."),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClearancePage()));
            },
            child: const Text("Go to My Clearance →"),
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("View and manage your personal information."),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
            child: const Text("Go to Profile →"),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxStyle() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow:[const BoxShadow(color: Colors.black12, blurRadius: 8)],
  );
}
