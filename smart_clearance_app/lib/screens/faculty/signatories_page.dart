import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import 'dashboard_page.dart';
import 'my_clearance_page.dart';
import 'profile_page.dart';

class SignatoriesPage extends StatefulWidget {
  const SignatoriesPage({super.key});

  @override
  State<SignatoriesPage> createState() => _SignatoriesPageState();
}

class _SignatoriesPageState extends State<SignatoriesPage> {
  int selectedIndex = 2;

  // same facultyId as MyClearancePage for now
  String facultyId = "faculty123";

  String selectedYear = "2025–2026";
  String selectedSemester = "First Semester";

  String searchQuery = "";

  Future<Map<String, dynamic>>? clearanceFuture;

  // Same department list as MyClearancePage
  final List<String> departments = const [
    "Registrar",
    "Accounting",
    "Dean",
    "Treasury",
    "Property Management Office",
    "Laboratory",
    "Clinic",
    "Library",
    "Human Resource Office",
    "Program Chair",
    "Office of the Vice President as Research",
    "ICT",
    "Community Extension Service Office",
  ];

  // Directory: department => office name + email (from your users collection)
  final Map<String, Map<String, String>> departmentDirectory = const {
    "Registrar": {
      "name": "Registrar Office",
      "email": "registrar@sdca.edu.ph",
    },
    "Accounting": {
      "name": "Accounting Office",
      "email": "accounting@sdca.edu.ph",
    },
    "Dean": {
      "name": "Dean Office",
      "email": "dean@sdca.edu.ph",
    },
    "Treasury": {
      "name": "Treasury Office",
      "email": "treasury@sdca.edu.ph",
    },
    "Property Management Office": {
      "name": "Property Management Office",
      "email": "property@sdca.edu.ph",
    },
    "Laboratory": {
      "name": "Laboratory Office",
      "email": "laboratory@sdca.edu.ph",
    },
    "Clinic": {
      "name": "Clinic Office",
      "email": "clinic@sdca.edu.ph",
    },
    "Library": {
      "name": "Library Office",
      "email": "library@sdca.edu.ph",
    },
    "Human Resource Office": {
      "name": "Human Resource Office",
      "email": "hr@sdca.edu.ph",
    },
    "Program Chair": {
      "name": "Program Chair",
      "email": "chair@sdca.edu.ph",
    },
    "Office of the Vice President as Research": {
      "name": "VP Research Office",
      "email": "vp-research@sdca.edu.ph",
    },
    "ICT": {
      "name": "ICT Office",
      "email": "ict@sdca.edu.ph",
    },
    "Community Extension Service Office": {
      "name": "CESO Office",
      "email": "ceso@sdca.edu.ph",
    },
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    clearanceFuture = ApiService.getClearanceRequests(facultyId);
    setState(() {});
  }

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

  // -------------------------------------------------------
  // SIDEBAR (same style as dashboard)
  // -------------------------------------------------------
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
            padding: const EdgeInsets.all(12),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyClearancePage()),
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

  // -------------------------------------------------------
  // CONTENT
  // -------------------------------------------------------
  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Clearance Sign Status by Department",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Track which departments have signed off on your clearance",
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            FutureBuilder<Map<String, dynamic>>(
              future: clearanceFuture,
              builder: (context, snapshot) {
                // Map dept -> latest request object
                final Map<String, dynamic> reqByDept = {};
                if (snapshot.hasData && snapshot.data?["success"] == true) {
                  for (var r in snapshot.data!["data"]) {
                    final dept = (r["department"] ?? "").toString();
                    reqByDept[dept] = r;
                  }
                }

                // --- compute summary stats over departments ---
                int totalSignatories = departments.length;
                int signedDepts = 0;
                int pendingDepts = 0;

                for (final dept in departments) {
                  final req = reqByDept[dept];
                  final docs = (req?["required_documents"] ?? []) as List;

                  if (docs.isEmpty) continue;

                  final approved = docs
                      .where((d) =>
                          (d["status"] ?? "").toString().toLowerCase() ==
                          "approved")
                      .length;
                  final totalDocs = docs.length;

                  if (totalDocs > 0 && approved == totalDocs) {
                    signedDepts++;
                  } else {
                    pendingDepts++;
                  }
                }

                final double completion = totalSignatories == 0
                    ? 0
                    : signedDepts / totalSignatories;

                return Column(
                  children: [
                    // Top stats row
                    Row(
                      children: [
                        _buildStatCard(
                            "Total Signatories", "$totalSignatories"),
                        const SizedBox(width: 20),
                        _buildStatCard("Pending", "$pendingDepts",
                            color: Colors.orange),
                        const SizedBox(width: 20),
                        _buildStatCard("Signed", "$signedDepts",
                            color: Colors.green),
                        const SizedBox(width: 20),
                        _buildStatCard(
                          "Completion",
                          "${(completion * 100).round()}%",
                          bold: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (v) =>
                            setState(() => searchQuery = v.trim()),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search, color: Colors.black54),
                          hintText: "Search by Department or signatory name",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Department cards
                    Column(
                      children: _filteredDepartments()
                          .map((dept) =>
                              _buildDepartmentCard(dept, reqByDept[dept]))
                          .toList(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // FILTERED DEPARTMENT LIST (search)
  // -------------------------------------------------------
  List<String> _filteredDepartments() {
    if (searchQuery.isEmpty) return departments;

    final q = searchQuery.toLowerCase();
    return departments.where((dept) {
      final meta = departmentDirectory[dept];
      final officeName = (meta?["name"] ?? "").toLowerCase();
      final email = (meta?["email"] ?? "").toLowerCase();

      return dept.toLowerCase().contains(q) ||
          officeName.contains(q) ||
          email.contains(q);
    }).toList();
  }



  Widget _semesterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _box(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSemester,
          items: const [
            DropdownMenuItem(
              value: "First Semester",
              child: Text("First Semester"),
            ),
            DropdownMenuItem(
              value: "Second Semester",
              child: Text("Second Semester"),
            ),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => selectedSemester = v);
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // SMALL STAT CARD
  // -------------------------------------------------------
  Widget _buildStatCard(String title, String value,
      {Color color = Colors.black87, bool bold = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _box(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                color: color,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // DEPARTMENT CARD (with progress + signatory)
  // -------------------------------------------------------
  Widget _buildDepartmentCard(String dept, Map<String, dynamic>? request) {
    final meta = departmentDirectory[dept] ?? {};
    final officeName = meta["name"] ?? dept;
    final officeEmail = meta["email"] ?? "-";

    final docs = (request?["required_documents"] ?? []) as List;
    final int totalDocs = docs.length;
    final int approvedDocs = docs
        .where((d) =>
            (d["status"] ?? "").toString().toLowerCase() == "approved")
        .length;

    final bool hasDocs = totalDocs > 0;
    final bool isSigned = hasDocs && approvedDocs == totalDocs;
    final double progress = hasDocs ? approvedDocs / totalDocs : 0.0;

    final String progressLabel = hasDocs
        ? "$approvedDocs of $totalDocs signed"
        : "No documents submitted";

    final String percentLabel = hasDocs
        ? "${(progress * 100).round()} %"
        : "0 %";

    // date: prefer approved_on -> submitted_on
    String dateLabel = "-";
    final dynamic approvedOn = request?["approved_on"];
    final dynamic submittedOn = request?["submitted_on"];

    DateTime? dt;
    try {
      if (approvedOn != null) {
        dt = DateTime.parse(approvedOn.toString());
      } else if (submittedOn != null) {
        dt = DateTime.parse(submittedOn.toString());
      }
    } catch (_) {}
    if (dt != null) {
      dateLabel = DateFormat("dd/MM/yyyy").format(dt);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department title
          Text(
            officeName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            dept,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),

          // Progress line
          Row(
            children: [
              Text(progressLabel, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 10),
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  color: const Color(0xFFB71C1C),
                  backgroundColor: const Color(0xFFF1F1F1),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                percentLabel,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB71C1C)),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          // Signatory row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: name + role + email
                Row(
                  children: [
                    Icon(
                      isSigned ? Icons.check_circle : Icons.hourglass_top,
                      color: isSigned ? Colors.green : Colors.orange,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          officeName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "$dept Administrator",
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54),
                        ),
                        Text(
                          officeEmail,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),

                // Right side: status + date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSigned
                            ? const Color(0xFFD6F5D6)
                            : const Color(0xFFFFF0CC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSigned
                            ? "Signed"
                            : hasDocs
                                ? "In Progress"
                                : "Not Started",
                        style: TextStyle(
                          color: isSigned ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // SHARED STYLES
  // -------------------------------------------------------
  BoxDecoration _box() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      );
}
