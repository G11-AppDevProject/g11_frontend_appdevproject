import 'package:flutter/material.dart';
import 'approvals_page.dart';
import 'profile_page.dart';
import 'package:smart_clearance_app/globals.dart' as G;

// Department Approval Screens  
import 'departments/registrar_approvals_page.dart';
import 'departments/accounting_approvals_page.dart';
import 'departments/dean_approvals_page.dart';
import 'departments/treasury_approvals_page.dart';
import 'departments/property_approvals_page.dart';
import 'departments/laboratory_approvals_page.dart';
import 'departments/clinic_approvals_page.dart';
import 'departments/library_approvals_page.dart';
import 'departments/hr_approvals_page.dart';
import 'departments/chair_approvals_page.dart';
import 'departments/vp_research_approvals_page.dart';
import 'departments/ict_approvals_page.dart';
import 'departments/ceso_approvals_page.dart';


class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
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
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // 🔹 SIDEBAR — visually matches Registrar Side Navigation
  // =========================================================================
  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFFF9F9F9),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Image.asset("assets/sdca_logo.png", width: 50),
          const SizedBox(height: 10),
          const Text(
            "Admin\nAcademic Clearance",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),

          const SizedBox(height: 30),

          _menuButton(Icons.dashboard, "Dashboard", 0),
          _menuButton(Icons.fact_check, "Approvals", 1),
          _menuButton(Icons.person, "Profile", 2),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamedAndRemoveUntil(context, "/login", (r) => false),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
            ),
          )
        ],
      ),
    );
  }

  Widget _menuButton(IconData icon, String label, int index) {
    bool active = index == selectedIndex;

    return InkWell(
      onTap: () {
        setState(() => selectedIndex = index);

          // =============================== APPROVALS ROUTER ===============================
          if (index == 1) {
            final d = G.currentDepartment.toLowerCase();
            print("=== DEBUG DEPARTMENT CHECK ===");
            print("RAW: '${G.currentDepartment}'");
            print("LOWER: '${G.currentDepartment.toLowerCase()}'");
            print("TRIMMED: '${G.currentDepartment.toLowerCase().trim()}'");
            print("MATCH property office? ${G.currentDepartment.toLowerCase().trim() == "property office"}");
            print("LENGTH: ${G.currentDepartment.toLowerCase().trim().length}");
            print("EXPECTED LENGTH: ${"property office".length}");

                if (d == "registrar") Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarApprovalsPage()));
            else if (d == "accounting" || d == "accounting office") Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountingApprovalsPage()));
            else if (d == "dean" || d == "dean office") Navigator.push(context, MaterialPageRoute(builder: (_) => const DeanApprovalsPage()));
            else if (d == "treasury" || d == "treasury office") Navigator.push(context, MaterialPageRoute(builder: (_) => const TreasuryApprovalsPage()));
            else if (d == "property" || d == "property office" || d == "property management office") Navigator.push(context, MaterialPageRoute(builder: (_) => const PropertyApprovalsPage()));
            else if (d == "laboratory") Navigator.push(context, MaterialPageRoute(builder: (_) => const LaboratoryApprovalsPage()));
            else if (d == "clinic") Navigator.push(context, MaterialPageRoute(builder: (_) => const ClinicApprovalsPage()));
            else if (d == "library") Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryApprovalsPage()));
            else if (d == "hr" || d == "human resource office") Navigator.push(context, MaterialPageRoute(builder: (_) => const HRApprovalsPage()));
            else if (d == "chair" || d == "program chair") Navigator.push(context, MaterialPageRoute(builder: (_) => const ChairApprovalsPage()));
            else if (d == "vp-research" || d == "office of the vice president as research") Navigator.push(context, MaterialPageRoute(builder: (_) => const VPResearchApprovalsPage()));
            else if (d == "ict") Navigator.push(context, MaterialPageRoute(builder: (_) => const ICTApprovalsPage()));
            else if (d == "ceso" || d == "community extension service office") Navigator.push(context, MaterialPageRoute(builder: (_) => const CESOApprovalsPage()));

            else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("⚠ No approval page assigned to this admin account."))
              );
            }
          }


        else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProfilePage()));
        }
      },

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        color: active ? Colors.grey.shade200 : null,
        child: Row(children: [
          Icon(icon), const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 16)),
        ]),
      ),
    );
  }

      String formatDepartment(String text) {
        // Auto uppercase full acronyms
        if (text.toUpperCase() == text.toLowerCase()) return text.toUpperCase(); 

        // Normal capitalization
        return text.split(' ').map((w) {
          return w.length <= 3 ? w.toUpperCase() : w[0].toUpperCase() + w.substring(1);
        }).join(' ');
      }

  // =========================================================================
  // 🔹 MAIN DASHBOARD UI
  // =========================================================================
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Dashboard",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),

      Text("Welcome, ${formatDepartment(G.currentDepartment)} Office",
          style: const TextStyle(color: Colors.black54)),

      Row(children: [
        _infoCard("Office / Department",
            "${formatDepartment(G.currentDepartment)} Office", "Admin"),
        const SizedBox(width: 20),
        _infoCard("Email", G.currentEmail, ""),
        const SizedBox(width: 20),
        _statusCard(),
      ]),



          const SizedBox(height: 30),

          Row(children: [
            Expanded(child: _clearanceCard()),
            const SizedBox(width: 20),
            Expanded(child: _profileShortcut()),
          ]),
        ],
      ),
    );
  }

  // =========================================================================
  // 🔹 TOP CARDS
  // =========================================================================
  Widget _infoCard(String title, String text, String tag) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          if (tag.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20)),
              child: Text(tag),
            ),
        ]),
      ),
    );
  }

  Widget _statusCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Status", style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.green.shade200, borderRadius: BorderRadius.circular(20)),
            child: const Text("Active", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }

  // =========================================================================
  // 🔹 CLEARANCE CARD — FIXED ROUTING
  // =========================================================================
Widget _clearanceCard() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: _box(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("My Clearance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Review and monitor faculty clearance requests."),
        const SizedBox(height: 12),

        TextButton(
          onPressed: () {
            final d = G.currentDepartment.toLowerCase(); // normalized  


            if (d == "registrar") Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarApprovalsPage()));
            else if (d == "accounting" || d == "accounting office") Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountingApprovalsPage()));
            else if (d == "dean" || d == "dean office") Navigator.push(context, MaterialPageRoute(builder: (_) => const DeanApprovalsPage()));
            else if (d == "treasury" || d == "treasury office") Navigator.push(context, MaterialPageRoute(builder: (_) => const TreasuryApprovalsPage()));
            else if (d == "property" || d == "property office" || d == "property management office") Navigator.push(context, MaterialPageRoute(builder: (_) => const PropertyApprovalsPage()));
            else if (d == "laboratory") Navigator.push(context, MaterialPageRoute(builder: (_) => const LaboratoryApprovalsPage()));
            else if (d == "clinic") Navigator.push(context, MaterialPageRoute(builder: (_) => const ClinicApprovalsPage()));
            else if (d == "library") Navigator.push(context, MaterialPageRoute(builder: (_) => const LibraryApprovalsPage()));
            else if (d == "hr" || d == "human resource office") Navigator.push(context, MaterialPageRoute(builder: (_) => const HRApprovalsPage()));
            else if (d == "chair" || d == "program chair") Navigator.push(context, MaterialPageRoute(builder: (_) => const ChairApprovalsPage()));
            else if (d == "vp-research" || d == "office of the vice president as research") Navigator.push(context, MaterialPageRoute(builder: (_) => const VPResearchApprovalsPage()));
            else if (d == "ict") Navigator.push(context, MaterialPageRoute(builder: (_) => const ICTApprovalsPage()));
            else if (d == "ceso" || d == "community extension service office") Navigator.push(context, MaterialPageRoute(builder: (_) => const CESOApprovalsPage()));

            else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("⚠ No department page assigned to this admin account"))
              );
            }
          },
          child: const Text("Go to Approvals →"),
        ),
      ],
    ),
  );
}

  Widget _profileShortcut() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("View and manage your account."),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminProfilePage())),
          child: const Text("Go to Profile →"),
        ),
      ]),
    );
  }

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
  );
}
