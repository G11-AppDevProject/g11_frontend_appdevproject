// ==========================================================
// ADMIN APPROVALS PAGE (FULL + FIXED + DATE FORMAT + REJECT WITH REMARKS)
// ==========================================================

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

  // USE NORMAL HYPHEN FORMAT (NEEDED FOR FILTERING)
  String selectedYear = "2025-2026";
  String selectedSemester = "First Semester";

  Future<Map<String, dynamic>>? requestsFuture;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

void _loadRequests() {
  requestsFuture = ApiService.getAllClearanceRequests(
    year: selectedYear,
    semester: selectedSemester,
  );
  setState(() {});
}



  Future<void> _updateStatus(String id, String newStatus) async {
    final resp = await ApiService.updateClearanceStatus(id, newStatus);
    if (resp["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request $newStatus Successfully")));
      _loadRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp["message"] ?? "Failed")));
    }
  }

  // ===========================
  // 📌 Date Formatter UI Output
  // ===========================
  String formatDate(dynamic raw) {
    try {
      DateTime d = DateTime.parse(raw);
      List months = [
        "January","February","March","April","May","June",
        "July","August","September","October","November","December"
      ];
      return "${months[d.month - 1]} ${d.day}, ${d.year}";
    } catch (_) {
      return raw.toString();
    }
  }

  // ===========================
  // 📌 Popup Input — Reject w/ Reason
  // ===========================
  Future<void> _rejectWithRemarks(String id) async {
    TextEditingController remarks = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reason for Rejection"),
        content: TextField(
          controller: remarks,
          decoration: const InputDecoration(hintText: "Enter remarks..."),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _updateStatus(id,"Rejected");  // backend remarks later
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }

  // ==========================================================
  // MAIN LAYOUT
  // ==========================================================
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

  // ==========================================================
  // SIDEBAR
  // ==========================================================
  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFFF9F9F9),
      child: Column(children: [
        const SizedBox(height: 30),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset("assets/sdca_logo.png", width: 50),
          const SizedBox(width: 10),
          const Text("Admin\nAcademic Clearance",
              style: TextStyle(fontWeight: FontWeight.bold))
        ]),

        const SizedBox(height: 30),
        _menuButton(Icons.dashboard, "Dashboard", 0),
        _menuButton(Icons.check_circle, "Approvals", 1),
        _menuButton(Icons.person, "Profile", 2),

        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, "/login", (route) => false),
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
          ),
        )
      ]),
    );
  }

  Widget _menuButton(IconData icon, String label, int index) {
    bool active = selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => selectedIndex = index);
        if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProfilePage()));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        color: active ? const Color(0xFFEEEDED) : Colors.transparent,
        child: Row(children: [Icon(icon), const SizedBox(width: 12), Text(label)]),
      ),
    );
  }

  // ==========================================================
  // CONTENT SECTION
  // ==========================================================
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        const Text("Approvals", style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold)),
        const Text("Review and manage clearance approvals",
            style: TextStyle(fontSize: 16, color: Colors.black54)),
        const SizedBox(height: 30),

        _buildCounters(),
        const SizedBox(height: 30),
        Row(children: [_yearDropdown(), const SizedBox(width: 20), _semesterDropdown()]),
        const SizedBox(height: 25),
        _buildRequestsList(),

      ]),
    );
  }

  // ==========================================================
  // COUNTERS
  // ==========================================================
  Widget _buildCounters() {
    return FutureBuilder<Map<String, dynamic>>(
      future: requestsFuture,
      builder: (context, snapshot) {
        int total = 0, pending = 0, approved = 0, rejected = 0;
        if (snapshot.hasData && snapshot.data!["success"] == true) {
          final List list = snapshot.data!["data"];
          total = list.length;
          pending = list.where((r) => (r["status"] ?? "").toLowerCase()=="pending").length;
          approved = list.where((r)=>(r["status"]??"").toLowerCase()=="approved").length;
          rejected = list.where((r)=>(r["status"]??"").toLowerCase()=="rejected").length;
        }

        return Row(children: [
          _statCard("Total Request", "$total"),
          const SizedBox(width: 20),
          _statCard("Pending", "$pending", color: Colors.orange),
          const SizedBox(width: 20),
          _statCard("Approved", "$approved", color: Colors.green),
          const SizedBox(width: 20),
          _statCard("Rejected", "$rejected", color: Colors.red),
        ]);
      },
    );
  }

  // ==========================================================
  // REQUEST LIST UI
  // ==========================================================
  Widget _buildRequestsList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: requestsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text("Loading...");

        final List requests = snapshot.data!["data"];

        final filtered = requests.where((r) =>
          r["academic_year"]==selectedYear &&
          r["semester"]==selectedSemester
        ).toList();

        if (filtered.isEmpty) {
          return const Text("No requests found.", style: TextStyle(fontSize:16,color:Colors.black54));
        }

        return Column(
          children:
            filtered.map((r)=>_requestCard(Map<String,dynamic>.from(r))).toList()
        );
      },
    );
  }

  // ==========================================================
  // APPROVAL CARD (UI with formatted date + buttons)
  // ==========================================================
  Widget _requestCard(Map<String, dynamic> r) {
    String id = r["_id"] ?? "";
    String faculty = r["faculty_id"] ?? "";
    String submitted = formatDate(r["submitted_on"]);
    String status = r["status"] ?? "Pending";

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      decoration: _boxStyle(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: [
          const Icon(Icons.person, size: 28),
          const SizedBox(width: 10),
          Text("Faculty ID: $faculty", style: TextStyle(fontWeight: FontWeight.bold)),
          Spacer(),
          Chip(
            label: Text(status),
            backgroundColor: _statusColor(status).withOpacity(0.18),
            labelStyle: TextStyle(color: _statusColor(status)),
          )
        ]),

        const SizedBox(height: 8),
        Text("Year: ${r["academic_year"]}"),
        Text("Semester: ${r["semester"]}"),
        Text("Submitted on: $submitted"),

        const SizedBox(height: 12),
        Row(children: [
          OutlinedButton(
            onPressed: ()=> Navigator.pushNamed(context,"/admin_view_details",arguments:r),
            child: const Text("View Details"),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: ()=> _updateStatus(id,"Approved"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Approve"),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: ()=> _rejectWithRemarks(id),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject"),
          ),
        ])
      ]),
    );
  }

  // ==========================================================
  // UTIL UI FUNCTIONS
  // ==========================================================
  Widget _statCard(String t,String v,{Color color=Colors.black}) {
    return Expanded(child: Container(
      padding: EdgeInsets.all(20),
      decoration: _boxStyle(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text(t,style:TextStyle(color:Colors.black54)),
        SizedBox(height:6),
        Text(v,style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:color))
      ]),
    ));
  }

  Widget _yearDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal:16),
      decoration: _boxStyle(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value:selectedYear,
          items:[
            DropdownMenuItem(value:"2023-2024",child:Text("2023–2024")),
            DropdownMenuItem(value:"2024-2025",child:Text("2024–2025")),
            DropdownMenuItem(value:"2025-2026",child:Text("2025–2026")),
          ],
          onChanged:(v){
            setState(()=>selectedYear=v!);
            _loadRequests();
          },
        ),
      ),
    );
  }

  Widget _semesterDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal:16),
      decoration:_boxStyle(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value:selectedSemester,
          items:[
            DropdownMenuItem(value:"First Semester",child:Text("FIRST")),
            DropdownMenuItem(value:"Second Semester",child:Text("SECOND")),
          ],
          onChanged:(v){
            setState(()=>selectedSemester=v!);
            _loadRequests();
          },
        ),
      ),
    );
  }

  Color _statusColor(s){
    s=s.toLowerCase();
    if(s=="approved") return Colors.green;
    if(s=="rejected") return Colors.red;
    return Colors.orange;
  }

  BoxDecoration _boxStyle()=>BoxDecoration(
    color:Colors.white,
    borderRadius:BorderRadius.circular(12),
    boxShadow:[BoxShadow(color:Colors.black12,blurRadius:8,offset:Offset(0,2))]
  );
}
