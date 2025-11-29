import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'my_clearance_page.dart';
import 'signatories_page.dart';
import 'package:smart_clearance_app/globals.dart' as G;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedIndex = 3;

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

  // -------------------------------------------------
  // SIDEBAR
  // -------------------------------------------------
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
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
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

        if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
        if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const MyClearancePage()));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const SignatoriesPage()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        color: isSelected ? const Color(0xFFEEEDED) : Colors.transparent,
        child: Row(children: [Icon(icon), const SizedBox(width: 12), Text(label)]),
      ),
    );
  }

  // -------------------------------------------------
  // 🔥 CONTENT (Name + Email from DB)
  // -------------------------------------------------
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Profile", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("User’s account information", style: TextStyle(fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 20),

          // ========= 🔥 NAME + EMAIL =========
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(color: const Color(0xFFB71C1C), borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(G.currentFullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(G.currentEmail, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Text("Faculty", style: TextStyle(fontSize: 12)),
                )
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ========= TWO CARDS SAME UI =========
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _infoCard("Personal Information", [
                  iconLine(Icons.email, "Email: ${G.currentEmail}"),
                  iconLine(Icons.phone, "+63 (2) 1234-5678"),
                ]),
              ),

              Expanded(
                child: _infoCard("Professional Information", [
                  iconLine(Icons.location_city, "Department"),
                  const Text("School of Communication, Multimedia, and Computer Studies",
                      style: TextStyle(fontWeight: FontWeight.w600))
                ]),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ========= 🔥 FULL WIDTH LIKE ORIGINAL =========
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Account Information",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 12),
                Text("Full-time Faculty",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text("Account Type", style: TextStyle(color: Colors.black54)),
                SizedBox(height: 6),
                Text("Faculty", style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Reusable UI ----
  Widget _infoCard(String title, List<Widget> content) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...content,
      ]),
    );
  }

  Widget iconLine(IconData i, String text) => Row(
    children: [Icon(i, size: 16), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)))],
  );
}
