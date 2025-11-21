import 'package:flutter/material.dart';
import '../../services/api_service.dart';
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

  // MUST MATCH database values exactly
  String selectedYear = "2025–2026";
  String selectedSemester = "First Semester";

  // TODO: Replace with real ID
  String facultyId = "faculty123";

  Future<Map<String, dynamic>>? clearanceFuture;

  @override
  void initState() {
    super.initState();
    clearanceFuture = ApiService.getClearanceReport(facultyId);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 800;

      return Scaffold(
        drawer: isMobile ? _buildSidebar() : null,
        body: Row(
          children: [
            if (!isMobile) _buildSidebar(),
            Expanded(
              child: SafeArea(top: false, child: _buildContent()),
            ),
          ],
        ),
      );
    });
  }

  // ----------------------------- SIDEBAR -----------------------------
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
                Navigator.pushNamedAndRemoveUntil(
                    context, "/login", (route) => false);
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
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DashboardPage()));
        } else if (index == 2) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SignatoriesPage()));
        } else if (index == 3) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ProfilePage()));
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

  // ----------------------------- CONTENT -----------------------------
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

            _buildCounters(),

            const SizedBox(height: 30),

            const Text(
              "Clearance Request",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _yearDropdown(),
                const SizedBox(width: 20),
                _semesterDropdown(),
              ],
            ),

            const SizedBox(height: 20),

            _buildClearanceReportList(),
          ],
        ),
      ),
    );
  }

  // ----------------------------- COUNTERS -----------------------------
  Widget _buildCounters() {
    return FutureBuilder<Map<String, dynamic>>(
      future: clearanceFuture,
      builder: (context, snapshot) {
        int total = 0;
        int pending = 0;
        int approved = 0;

        if (snapshot.hasData && snapshot.data!["success"] == true) {
          final List list = snapshot.data!["data"];

          total = list.length;
          pending = list.where((r) => r["status"] == "Pending").length;
          approved = list.where((r) => r["status"] == "Approved").length;
        }

        return Row(
          children: [
            _numberCard("Total Request", total.toString()),
            const SizedBox(width: 20),
            _numberCard("Pending", pending.toString(), color: Colors.orange),
            const SizedBox(width: 20),
            _numberCard("Approved", approved.toString(), color: Colors.green),
          ],
        );
      },
    );
  }

  // ----------------------------- REPORT LIST -----------------------------
  Widget _buildClearanceReportList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: clearanceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!["success"] == false) {
          return const Text(
            "Failed to load clearance reports.",
            style: TextStyle(color: Colors.red),
          );
        }

        final List allReports = snapshot.data!["data"];

        final List reports = allReports.where((r) {
          return r["academic_year"] == selectedYear &&
              r["semester"] == selectedSemester;
        }).toList();

        if (reports.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "No clearance reports found.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return Column(
          children: reports
              .map((r) => _reportCard(Map<String, dynamic>.from(r)))
              .toList(),
        );
      },
    );
  }

  // ----------------------------- REPORT CARD -----------------------------
  Widget _reportCard(Map<String, dynamic> report) {
    final department = report["department"] ?? "Unknown Department";
    final status = report["status"] ?? "Pending";
    final submitted = report["submitted_on"] ?? "N/A";
    final due = report["due_date"] ?? "N/A";
    final remarks = report["remarks"] ?? "";
    final requestId = report["request_id"] ?? "N/A";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                department,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Chip(
                label: Text(status),
                backgroundColor: (status == "Approved"
                        ? Colors.green
                        : Colors.orange)
                    .withOpacity(0.18),
                labelStyle: TextStyle(
                  color: status == "Approved"
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text("Request ID: $requestId"),
          const SizedBox(height: 6),
          Text("Submitted: $submitted"),
          const SizedBox(height: 6),
          Text("Due Date: $due"),

          if (remarks.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text("Remarks: $remarks",
                style: const TextStyle(color: Colors.black87)),
          ],

          const SizedBox(height: 14),
          Row(
            children: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/view_details",
                        arguments: report);
                  },
                  child: const Text("View Details")),
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

  // ----------------------------- NUMBER CARD (MISSING PART) -----------------------------
  Widget _numberCard(String label, String number, {Color color = Colors.black}) {
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

  // ----------------------------- DROPDOWNS -----------------------------
  Widget _yearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _boxStyle(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedYear,
          items: const [
            "2023–2024",
            "2024–2025",
            "2025–2026",
          ]
              .map((year) =>
                  DropdownMenuItem(value: year, child: Text(year)))
              .toList(),
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
            DropdownMenuItem(
                value: "First Semester", child: Text("FIRST")),
            DropdownMenuItem(
                value: "Second Semester", child: Text("SECOND")),
          ],
          onChanged: (value) {
            setState(() => selectedSemester = value!);
          },
        ),
      ),
    );
  }

  // ----------------------------- BOX STYLE -----------------------------
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
