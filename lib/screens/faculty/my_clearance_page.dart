import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'signatories_page.dart';
import 'profile_page.dart';

class MyClearancePage extends StatefulWidget {
  const MyClearancePage({super.key});

  @override
  State<MyClearancePage> createState() => _MyClearancePageState();
}

class _MyClearancePageState extends State<MyClearancePage> {
  int selectedIndex = 1;

  String selectedYear = "2025–2026";
  String selectedSemester = "FIRST";

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
              Expanded(
              child: SafeArea(
                top: false,
                child: _buildContent(),
              ),
            ),
            ],
          ),
        );
      },
    );
  }

  // -----------------------------
  // SIDEBAR
  // -----------------------------
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
                "Faculty\nAcademic Clearance",
                style: TextStyle(fontWeight: FontWeight.bold),
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
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignatoriesPage()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
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

  // -----------------------------
  // FIXED PAGE CONTENT (NO TOP GAP)
  // -----------------------------
  Widget _buildContent() {
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Text(
              "Clearance Requests",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Track and manage clearance requests",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                _numberCard("Total Request", "3"),
                const SizedBox(width: 20),
                _numberCard("Pending", "1", color: Colors.orange),
                const SizedBox(width: 20),
                _numberCard("Approved", "1", color: Colors.green),
              ],
            ),

            const SizedBox(height: 30),

            const Text("Clearance Request",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            Row(
              children: [
                _yearDropdown(),
                const SizedBox(width: 20),
                _semesterDropdown(),
              ],
            ),

            const SizedBox(height: 20),
            _clearanceCard(),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // CARDS AND DROPDOWNS
  // -----------------------------
  Widget _numberCard(String label, String number,
      {Color color = Colors.black}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _boxStyle(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(
              number,
              style: TextStyle(
                fontSize: 24,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _boxStyle(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedYear,
          items: [
            "2023–2024",
            "2024–2025",
            "2025–2026",
          ].map((year) {
            return DropdownMenuItem(value: year, child: Text(year));
          }).toList(),
          onChanged: (value) {
            setState(() => selectedYear = value!);
          },
        ),
      ),
    );
  }

  Widget _semesterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _boxStyle(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSemester,
          items: const [
            DropdownMenuItem(value: "FIRST", child: Text("FIRST")),
            DropdownMenuItem(value: "SECOND", child: Text("SECOND")),
          ],
          onChanged: (value) {
            setState(() => selectedSemester = value!);
          },
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
          Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                "Dominican Learning Resource Center",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Chip(
                label: Text("Pending"),
                backgroundColor: Colors.orangeAccent,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text("Request ID: CLR-001"),
          const SizedBox(height: 6),

          Row(
            children: const [
              Text("Submitted:   2025-10-19"),
              SizedBox(width: 40),
              Text("Semester:   FIRST"),
            ],
          ),

          const SizedBox(height: 10),
          const Text("Required Documents",
              style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 4),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(30),
            ),
          ),

          const SizedBox(height: 10),
          const Text(
            "Note: Awaiting Dominican Learning Resource Center approval",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                    Navigator.pushNamed(context, "/view_details");
                  },
                child: const Text("View Details"),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {},
                child: const Text("Download"),
              )
            ],
          )
        ],
      ),
    );
  }

  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: const Offset(0, 2),
        )
      ],
    );
  }
}
