import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'my_clearance_page.dart';
import 'signatories_page.dart';
import 'profile_page.dart';
import 'faculty_view_details.dart'; // Import the FacultyViewDetailsPage

class FacultyViewDetailsOcrPage extends StatefulWidget {
  const FacultyViewDetailsOcrPage({super.key});

  @override
  State<FacultyViewDetailsOcrPage> createState() =>
      _FacultyViewDetailsOcrPageState();
}

class _FacultyViewDetailsOcrPageState extends State<FacultyViewDetailsOcrPage> {
  int selectedIndex = 1;
  bool isDetailsActive = false; // Track active tab

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

  // SIDEBAR
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

  // MAIN PAGE CONTENT
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
          children: const [
            Icon(Icons.error_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              "Document Scanner (OCR)",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Spacer(),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          "Upload documents to scan and extract text using Optical Character Recognition (OCR)",
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 25),
        _tabs(),
        const SizedBox(height: 25),
        // OCR FILE UPLOAD
        _ocrFileUploadBox(),
        const SizedBox(height: 25),
      ],
    );
  }

  // TABS
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
          } else {
            isDetailsActive = false;
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

  // OCR FILE UPLOAD BOX
  Widget _ocrFileUploadBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Upload Document",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          // Upload UI
          GestureDetector(
            onTap: () {
              // Trigger file upload here
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Icon(Icons.upload_file, size: 40, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Drag and drop your document here\nor Browse Files",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Scan & Extract Text Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB71C1C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Perform OCR extraction here
              },
              child: const Text(
                "Scan & Extract Text",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BOX STYLE
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
