import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'approvals_page.dart';
import 'package:smart_clearance_app/globals.dart' as G;

// --- APPROVAL SCREENS (13 departments) ---
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

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  int selectedIndex = 2; // Profile selected

    String formatDept(String t) {
      if (t.isEmpty) return "";

      return t.split(" ").map((w) {
        if (w.length <= 3) return w.toUpperCase(); // handles ICT, HR, VP etc.
        return w[0].toUpperCase() + w.substring(1).toLowerCase();
      }).join(" ");
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

  // =====================================================================
  // 🔹 SIDEBAR — copied from dashboard & approvals routing ENABLED
  // =====================================================================
  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFFF9F9F9),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Image.asset("assets/sdca_logo.png", width: 50),
          const SizedBox(height: 10),
          const Text("Admin\nAcademic Clearance",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),

          const SizedBox(height: 30),

          _menuButton(Icons.dashboard, "Dashboard", 0),
          _menuButton(Icons.fact_check, "Approvals", 1),
          _menuButton(Icons.person, "Profile", 2),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamedAndRemoveUntil(context,"/login",(r)=>false),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity,45)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(IconData icon, String text, int index) {
    bool active = index == selectedIndex;

    return InkWell(
      onTap: () {
        setState(() => selectedIndex = index);

        if (index == 0) Navigator.push(context,MaterialPageRoute(builder:(_)=>const AdminDashboardPage()));

        // 🔹 Same routing rules as dashboard
        if (index == 1) {
          final d = G.currentDepartment.toLowerCase();

          if (d == "registrar") Navigator.push(context,MaterialPageRoute(builder:(_)=>const RegistrarApprovalsPage()));
          else if (d == "accounting office") Navigator.push(context,MaterialPageRoute(builder:(_)=>const AccountingApprovalsPage()));
          else if (d == "dean office") Navigator.push(context,MaterialPageRoute(builder:(_)=>const DeanApprovalsPage()));
          else if (d == "treasury office") Navigator.push(context,MaterialPageRoute(builder:(_)=>const TreasuryApprovalsPage()));
          else if (d == "property management office") Navigator.push(context,MaterialPageRoute(builder:(_)=>const PropertyApprovalsPage()));
          else if (d == "laboratory") Navigator.push(context,MaterialPageRoute(builder:(_)=>const LaboratoryApprovalsPage()));
          else if (d == "clinic") Navigator.push(context,MaterialPageRoute(builder:(_)=>const ClinicApprovalsPage()));
          else if (d == "library") Navigator.push(context,MaterialPageRoute(builder:(_)=>const LibraryApprovalsPage()));
          else if (d == "human resource office") Navigator.push(context,MaterialPageRoute(builder:(_)=>const HRApprovalsPage()));
          else if (d == "program chair") Navigator.push(context,MaterialPageRoute(builder:(_)=>const ChairApprovalsPage()));
          else if (d == "office of the vice president as research") Navigator.push(context,MaterialPageRoute(builder:(_)=>const VPResearchApprovalsPage()));
          else if (d == "ict") Navigator.push(context,MaterialPageRoute(builder:(_)=>const ICTApprovalsPage()));
          else if (d == "community extension service office") Navigator.push(context,MaterialPageRoute(builder:(_)=>const CESOApprovalsPage()));
          else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("⚠ No approval page assigned to this admin account"))
            );
          }
        }
      },

      child: Container(
        padding: const EdgeInsets.symmetric(vertical:14,horizontal:20),
        color: active ? Colors.grey.shade200 : null,
        child: Row(children:[Icon(icon),SizedBox(width:10),Text(text)]),
      ),
    );
  }

  // =====================================================================
  // 🔹 PAGE CONTENT
  // =====================================================================
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        const Text("Profile",style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),
        const SizedBox(height:6),
        const Text("User's account information",style:TextStyle(color:Colors.black54)),

        const SizedBox(height:25),
        _banner(),

        const SizedBox(height:25),
        Row(children:[
          Expanded(child:_personalInfo()),
          const SizedBox(width:20),
          Expanded(child:_professionalInfo())
        ]),

        const SizedBox(height:25),
        _accountInfo()
      ]),
    );
  }

  // =====================================================================
  // 🔹 BANNER — now uses G.currentFullName + real Dept
  // =====================================================================
  Widget _banner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration:_box(),
      child:Row(children:[

        Expanded(
          child:Container(
            padding:const EdgeInsets.all(16),
            decoration:BoxDecoration(color:Color(0xFFB71C1C),borderRadius:BorderRadius.circular(8)),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(G.currentFullName,
                style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)),
              SizedBox(height:6),
              Text(G.currentEmail,style:TextStyle(color:Colors.white70))
            ]),
          ),
        ),

        SizedBox(width:12),
        Container(
          padding:EdgeInsets.symmetric(horizontal:12,vertical:6),
          decoration:BoxDecoration(
            color:Colors.white,borderRadius:BorderRadius.circular(20),
            border:Border.all(color:Colors.black12)),
          child:Text("${formatDept(G.currentDepartment)} Admin"),
        )
      ]),
    );
  }

  Widget _personalInfo() => _card("Personal Information",[
    _row(Icons.email,G.currentEmail),
    _row(Icons.phone,"+63 (2) 1234-5678")
  ]);

  Widget _professionalInfo() => _card("Professional Information",[
    _row(Icons.location_city,"Department"),
    Text("${formatDept(G.currentDepartment)} Office",
    style:TextStyle(fontWeight:FontWeight.w600)),
  ]);

  Widget _accountInfo(){
    return Container(
      width:double.infinity,padding:const EdgeInsets.all(22),decoration:_box(),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text("Account Information",style:TextStyle(fontWeight:FontWeight.bold)),
        SizedBox(height:12),
        Text("${formatDept(G.currentDepartment)} Administrator",
        style:TextStyle(fontWeight:FontWeight.bold,fontSize:22)),
        SizedBox(height:12),
        Text("Account Type",style:TextStyle(color:Colors.black54)),
        SizedBox(height:6),
        Text("Admin",style:TextStyle(fontWeight:FontWeight.w600)),
      ]),
    );
  }

  Widget _card(String title,List<Widget> body){
    return Container(
      padding:EdgeInsets.all(20),decoration:_box(),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(title,style:TextStyle(fontWeight:FontWeight.bold)),
        SizedBox(height:14),...body
      ]),
    );
  }

  Widget _row(IconData icon,String text)=>Row(children:[
    Icon(icon,size:16),SizedBox(width:8),Expanded(child:Text(text))
  ]);

  BoxDecoration _box()=>BoxDecoration(
    color:Colors.white,borderRadius:BorderRadius.circular(12),
    boxShadow:[BoxShadow(color:Colors.black12,blurRadius:8)]
  );
}
