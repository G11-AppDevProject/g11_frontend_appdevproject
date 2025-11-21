import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'approvals_page.dart';
import 'profile_page.dart';

class AdminViewDetailsPage extends StatefulWidget {
  const AdminViewDetailsPage({super.key});

  @override
  State<AdminViewDetailsPage> createState() => _AdminViewDetailsPageState();
}

class _AdminViewDetailsPageState extends State<AdminViewDetailsPage> {
  int selectedIndex = 1;

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
  // SIDEBAR (Admin Version)
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
                "Admin\nAcademic Clearance",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),

          const SizedBox(height: 30),

          _menuItem(Icons.dashboard, "Dashboard", 0),
          _menuItem(Icons.check_circle, "Approvals", 1),
          _menuItem(Icons.person, "Profile", 2),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                (_) => false,
              ),
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
              MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
        } else if (index == 1) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminApprovalsPage()));
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

  // ─────────────────────────────────────────────
  // MAIN CONTENT
  // ─────────────────────────────────────────────
  Widget _buildPageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BACK BUTTON
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
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
        const Text("Request ID: APR-001",
            style: TextStyle(fontSize: 15, color: Colors.black54)),

        const SizedBox(height: 25),

        _tabs(),

        const SizedBox(height: 25),

        // REQUEST INFO
        _requestInformation(),

        const SizedBox(height: 25),

        // REQUIRED DOCUMENTS
        _documentsBox(),

        const SizedBox(height: 25),

        // NOTES & COMMENTS + ACTION BUTTONS FOR ADMIN
        _notesAndActions(),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // DETAILS + OCR TABS
  // ─────────────────────────────────────────────
  Widget _tabs() {
    return Row(
      children: [
        _tabButton("Details", isActive: true),
        const SizedBox(width: 10),
        _tabButton("OCR Scanner", isActive: false),
      ],
    );
  }

  Widget _tabButton(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
      decoration: BoxDecoration(
        color: isActive ? Colors.black87 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          )),
    );
  }

  // ─────────────────────────────────────────────
  // INFORMATION BOX
  // ─────────────────────────────────────────────
  Widget _requestInformation() {
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
  // DOCUMENTS BOX
  // ─────────────────────────────────────────────
  Widget _documentsBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Required Documents",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text("Status of all required documents",
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
                  fontWeight: FontWeight.bold, color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // NOTES + ACTION BUTTONS (Admin)
  // ─────────────────────────────────────────────
  Widget _notesAndActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Notes & Comments",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              "Please ensure department obligations are cleared before approving.",
              style: TextStyle(fontSize: 13),
            ),
          ),

          const SizedBox(height: 25),

          // ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Approve",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Reject",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
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

// Small Info Column Widget
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
