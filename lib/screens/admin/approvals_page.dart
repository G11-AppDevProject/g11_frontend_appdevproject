import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';

class AdminApprovalsPage extends StatefulWidget {
  const AdminApprovalsPage({super.key});

  @override
  State<AdminApprovalsPage> createState() => _AdminApprovalsPageState();
}

class _AdminApprovalsPageState extends State<AdminApprovalsPage> {
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
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------
  // SIDEBAR (same structure as Faculty)
  // -------------------------------------------
  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFFF9F9F9),
      child: Column(
        children: [
          const SizedBox(height: 30),

          // LOGO + TEXT
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
          _menuButton(Icons.check_circle, "Approvals", 1),
          _menuButton(Icons.person, "Profile", 2),

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
          )
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
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
        } else if (index == 2) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminProfilePage()));
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

  // -------------------------------------------
  // MAIN PAGE CONTENT
  // -------------------------------------------
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Approvals",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Review and manage clearance approvals",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),

          const SizedBox(height: 30),

          // TOP CARDS
          Row(
            children: [
              _statCard("Total Request", "3"),
              const SizedBox(width: 20),
              _statCard("Pending", "2", color: Colors.orange),
              const SizedBox(width: 20),
              _statCard("Approved", "1", color: Colors.green),
              const SizedBox(width: 20),
              _statCard("Rejected", "1", color: Colors.red),
            ],
          ),

          const SizedBox(height: 30),

          // DROPDOWN FILTERS
          Row(
            children: [
              _yearDropdown(),
              const SizedBox(width: 20),
              _semesterDropdown(),
            ],
          ),

          const SizedBox(height: 25),

          // APPROVAL REQUESTS
          _approvalCard(
            name: "Prof. Juan Dela Cruz",
            department: "School of Communication, Multimedia, and Computer Studies",
            requestId: "APR-001",
            date: "2025-10-20",
            documents: "3 Files",
            status: "Pending",
            statusColor: Colors.orange,
            showActions: true,
          ),

          const SizedBox(height: 20),

          _approvalCard(
            name: "Dr. Anna Reyes",
            department: "School of Communication, Multimedia, and Computer Studies",
            requestId: "APR-002",
            date: "2025-10-18",
            documents: "2 Files",
            status: "Approved",
            statusColor: Colors.green,
            showActions: false,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------
  // REUSABLE COMPONENTS
  // -------------------------------------------
  Widget _statCard(String title, String value, {Color color = Colors.black}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _boxStyle(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
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
          ].map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
          onChanged: (value) => setState(() => selectedYear = value!),
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
          onChanged: (value) => setState(() => selectedSemester = value!),
        ),
      ),
    );
  }

  Widget _approvalCard({
    required String name,
    required String department,
    required String requestId,
    required String date,
    required String documents,
    required String status,
    required Color statusColor,
    required bool showActions,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            children: [
              const Icon(Icons.person, size: 28),
              const SizedBox(width: 10),
              Text(name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Chip(
                label: Text(status),
                backgroundColor: statusColor.withOpacity(0.2),
                labelStyle: TextStyle(color: statusColor),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text("End of semester clearance",
              style: const TextStyle(color: Colors.black54)),

          const SizedBox(height: 12),

          Text("Department\n$department",
              style: const TextStyle(fontSize: 13)),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Request ID\n$requestId"),
              Text("Submitted\n$date"),
              Text("Documents\n$documents"),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/admin_view_details");
                  },
                child: const Text("View Details"),
              ),
              const SizedBox(width: 10),
              if (showActions)
                ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    child: const Text("Approve")),
              if (showActions) const SizedBox(width: 10),
              if (showActions)
                ElevatedButton(
                  onPressed: () {},
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Reject"),
                ),
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
