import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'my_clearance_page.dart';
import 'signatories_page.dart';
import 'profile_page.dart';
import 'faculty_view_details_ocr.dart'; // Import the FacultyViewDetailsOcrPage

class FacultyViewDetailsPage extends StatefulWidget {
  const FacultyViewDetailsPage({super.key});

  @override
  State<FacultyViewDetailsPage> createState() => _FacultyViewDetailsPageState();
}

class _FacultyViewDetailsPageState extends State<FacultyViewDetailsPage> {
  int selectedIndex = 1;
  bool isDetailsActive = true;  // Track active tab (Details or OCR Scanner)

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      drawer: isMobile ? _buildSidebar() : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: _buildPageContent(),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SIDEBAR
  // ─────────────────────────────────────────────
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

          _menuItem(Icons.dashboard, "Dashboard", 0),
          _menuItem(Icons.article, "My Clearance", 1),
          _menuItem(Icons.account_tree, "Signatories", 2),
          _menuItem(Icons.person, "Profile", 3),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, "/login", (_) => false),
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

  Widget _menuItem(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() => selectedIndex = index);

        if (index == 0) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DashboardPage()));
        } else if (index == 1) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MyClearancePage()));
        } else if (index == 2) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SignatoriesPage()));
        } else if (index == 3) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfilePage()));
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

  // ─────────────────────────────────────────────
  // MAIN PAGE CONTENT
  // ─────────────────────────────────────────────
  Widget _buildPageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BACK BUTTON
        TextButton.icon(
          onPressed: () =>             Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyClearancePage()),
            ),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          label: const Text("Back", style: TextStyle(color: Colors.black87)),
        ),

        const SizedBox(height: 10),

        // TITLE + STATUS
        Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.orange),
            const SizedBox(width: 8),
            const Text(
              "End of Semester Clearance",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Chip(
              label: const Text("Pending"),
              backgroundColor: Colors.orange.shade200,
              labelStyle: const TextStyle(color: Colors.orange),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text("Request ID: CLR-001",
            style: TextStyle(fontSize: 15, color: Colors.black54)),

        const SizedBox(height: 25),

        _tabs(),

        const SizedBox(height: 25),

        // REQUEST INFO
        _requestInformationBox(),

        const SizedBox(height: 25),

        // REQUIRED DOCUMENTS
        _requiredDocumentsBox(),

        const SizedBox(height: 25),

        // NOTES & COMMENTS
        _notesCommentsBox(),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // DETAILS + OCR TABS
  // ─────────────────────────────────────────────
  Widget _tabs() {
    return Row(
      children: [
        _tabButton("Details", isActive: isDetailsActive),
        const SizedBox(width: 10),
        _tabButton("OCR Scanner", isActive: !isDetailsActive),
      ],
    );
  }

  Widget _tabButton(String label, {required bool isActive}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == "Details") {
            isDetailsActive = true;
            // Navigate to Faculty View Details when Details is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FacultyViewDetailsPage()),
            );
          } else if (label == "OCR Scanner") {
            isDetailsActive = false;
            // Navigate to Faculty View Details OCR when OCR Scanner is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FacultyViewDetailsOcrPage()),
            );
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
        decoration: BoxDecoration(
          color: isActive ? Colors.black87 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // REQUEST INFORMATION BOX
  // ─────────────────────────────────────────────
  Widget _requestInformationBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Request Information",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          Row(
            children: const [
              Expanded(
                child: _infoColumn(
                  title: "Faculty Name",
                  value: "Dr. Maria Santos",
                ),
              ),
              Expanded(
                child: _infoColumn(
                  title: "Department",
                  value: "Computer Science",
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: const [
              Expanded(
                child: _infoColumn(
                  title: "Submitted Date",
                  value: "2025-10-15",
                ),
              ),
              Expanded(
                child: _infoColumn(
                  title: "Due Date",
                  value: "2025-10-25",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // REQUIRED DOCUMENTS
  // ─────────────────────────────────────────────
  Widget _requiredDocumentsBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Required Documents",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text("Status of all required documents for this clearance",
              style: TextStyle(color: Colors.black54)),

          const SizedBox(height: 15),

          _docRow("Resignation Letter", "Submitted", Colors.blue),
          const SizedBox(height: 10),
          _docRow("Financial Clearance", "Approved", Colors.green),
          const SizedBox(height: 10),
          _docRow("Library Clearance", "Pending", Colors.orange),
        ],
      ),
    );
  }

  Widget _docRow(String name, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 15))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // NOTES & COMMENTS
  // ─────────────────────────────────────────────
  Widget _notesCommentsBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Notes & Comments",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),

          const Text("Status Notes",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Awaiting Finance Department approval",
              style: TextStyle(fontSize: 13),
            ),
          ),

          const SizedBox(height: 20),

          const Text("Approver Comments",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Please ensure all financial obligations are settled before final approval.",
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BOX STYLE
  // ─────────────────────────────────────────────
  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 2),
        )
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SMALL INFO COLUMN COMPONENT
// ─────────────────────────────────────────────
class _infoColumn extends StatelessWidget {
  final String title;
  final String value;

  const _infoColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}
