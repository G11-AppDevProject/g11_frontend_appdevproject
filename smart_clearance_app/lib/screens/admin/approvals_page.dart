import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';

class AdminApprovalsPage extends StatefulWidget {
  const AdminApprovalsPage({super.key});

  @override
  State<AdminApprovalsPage> createState() => _AdminApprovalsPageState();
}

class _AdminApprovalsPageState extends State<AdminApprovalsPage> {
  int selectedIndex = 1;

  // Set defaults
  String selectedYear = "2025–2026"; 
  String selectedSemester = "First Semester";

  Future<Map<String, dynamic>>? requestsFuture;

  @override
  void initState() {
    super.initState();
    // Load requests for the given year and semester
    _loadRequests();
  }

  void _loadRequests() {
    requestsFuture = ApiService.getAllClearanceRequests(year: selectedYear, semester: selectedSemester);
    setState(() {});
  }

  // Update status and refresh list
  Future<void> _updateStatus(String id, String newStatus) async {
    final resp = await ApiService.updateClearanceStatus(id, newStatus);
    if (resp["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request $newStatus")));
      _loadRequests();
    } else {
      final msg = resp["message"] ?? "Update failed";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
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
            Expanded(child: SafeArea(top: false, child: _buildContent())),
          ],
        ),
      );
    });
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFFF9F9F9),
      child: Column(children: [
        const SizedBox(height: 30),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset("assets/sdca_logo.png", width: 50),
          const SizedBox(width: 10),
          const Text("Admin\nAcademic Clearance", style: TextStyle(fontWeight: FontWeight.bold))
        ]),
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
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
          ),
        )
      ]),
    );
  }

  Widget _menuButton(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => selectedIndex = index);
        if (index == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProfilePage()));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        color: isSelected ? const Color(0xFFEEEDED) : Colors.transparent,
        child: Row(children: [Icon(icon, color: Colors.black87), const SizedBox(width: 12), Text(label, style: const TextStyle(fontSize: 16))]),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Approvals", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text("Review and manage clearance approvals", style: TextStyle(fontSize: 16, color: Colors.black54)),
        const SizedBox(height: 30),
        _buildCounters(),
        const SizedBox(height: 30),
        Row(children: [_yearDropdown(), const SizedBox(width: 20), _semesterDropdown()]),
        const SizedBox(height: 25),
        _buildRequestsList(),
      ]),
    );
  }

  Widget _buildCounters() {
    return FutureBuilder<Map<String, dynamic>>(
      future: requestsFuture,
      builder: (context, snapshot) {
        int total = 0, pending = 0, approved = 0, rejected = 0;
        if (snapshot.hasData && snapshot.data!["success"] == true) {
          final List list = snapshot.data!["data"];
          total = list.length;
          pending = list.where((r) => (r["status"] ?? "").toString().toLowerCase() == "pending").length;
          approved = list.where((r) => (r["status"] ?? "").toString().toLowerCase() == "approved").length;
          rejected = list.where((r) => (r["status"] ?? "").toString().toLowerCase() == "rejected").length;
        }
        return Row(children: [
          _statCard("Total Request", total.toString()),
          const SizedBox(width: 20),
          _statCard("Pending", pending.toString(), color: Colors.orange),
          const SizedBox(width: 20),
          _statCard("Approved", approved.toString(), color: Colors.green),
          const SizedBox(width: 20),
          _statCard("Rejected", rejected.toString(), color: Colors.red),
        ]);
      },
    );
  }

  Widget _buildRequestsList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!["success"] == false) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("Failed to load requests.", style: TextStyle(color: Colors.red)),
          );
        }

        final List all = snapshot.data!["data"] as List<dynamic>;

        // FILTER using exact strings from DB
        final List filtered = all.where((r) {
          final yr = (r["academic_year"] ?? "").toString().trim();
          final sm = (r["semester"] ?? "").toString().trim();
          return yr == selectedYear && sm == selectedSemester;
        }).toList();

        if (filtered.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("No clearance requests found.", style: TextStyle(fontSize: 16, color: Colors.black54)),
          );
        }

        return Column(children: filtered.map((r) => _approvalCardFromMap(Map<String, dynamic>.from(r))).toList());
      },
    );
  }

  Widget _approvalCardFromMap(Map<String, dynamic> r) {
    final id = r["_id"] ?? r["id"] ?? "";
    final facultyId = r["faculty_id"] ?? "Unknown";
    final requestId = r["request_id"] ?? "N/A";
    final submitted = r["submitted_on"] ?? "N/A";
    final status = r["status"] ?? "Pending";

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: _boxStyle(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.person, size: 28),
          const SizedBox(width: 10),
          Text("Faculty ID: $facultyId", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          Chip(
            label: Text(status.toString()),
            backgroundColor: _statusColor(status).withOpacity(0.18),
            labelStyle: TextStyle(color: _statusColor(status)),
          )
        ]),
        const SizedBox(height: 8),
        Text("Request ID: $requestId"),
        const SizedBox(height: 6),
        Text("Submitted: $submitted"),
        const SizedBox(height: 14),
        Row(children: [
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, "/admin_view_details", arguments: r);
            },
            child: const Text("View Details"),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              final confirm = await _confirmDialog("Approve request?");
              if (confirm == true) _updateStatus(id.toString(), "Approved");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Approve"),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              final confirm = await _confirmDialog("Reject request?");
              if (confirm == true) _updateStatus(id.toString(), "Rejected");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject"),
          )
        ])
      ]),
    );
  }

  Future<bool?> _confirmDialog(String text) {
    return showDialog<bool>(context: context, builder: (context) => AlertDialog(title: Text(text), actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
    ]));
  }

  Color _statusColor(String s) {
    final st = s.toString().toLowerCase();
    if (st.contains("approve")) return Colors.green;
    if (st.contains("pending")) return Colors.orange;
    if (st.contains("reject") || st.contains("incomplete")) return Colors.red;
    return Colors.grey;
  }

  Widget _statCard(String title, String value, {Color color = Colors.black}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _boxStyle(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ]),
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
          items: const [
            DropdownMenuItem(value: "2023–2024", child: Text("2023–2024")),
            DropdownMenuItem(value: "2024–2025", child: Text("2024–2025")),
            DropdownMenuItem(value: "2025–2026", child: Text("2025–2026")),
          ],
          onChanged: (v) {
            setState(() {
              selectedYear = v!;
              _loadRequests();
            });
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
            DropdownMenuItem(value: "First Semester", child: Text("FIRST")),
            DropdownMenuItem(value: "Second Semester", child: Text("SECOND")),
          ],
          onChanged: (v) {
            setState(() {
              selectedSemester = v!;
              _loadRequests();
            });
          },
        ),
      ),
    );
  }

  BoxDecoration _boxStyle() {
    return BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))]);
  }
}
