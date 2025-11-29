import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminDepartmentApprovalsPage extends StatefulWidget {
  final String department; // ← assigned dept from login later

  const AdminDepartmentApprovalsPage({super.key, required this.department});

  @override
  State<AdminDepartmentApprovalsPage> createState() => _AdminDepartmentApprovalsPageState();
}

class _AdminDepartmentApprovalsPageState extends State<AdminDepartmentApprovalsPage> {

  Future<Map<String, dynamic>>? deptRequestsFuture;

  @override
  void initState() {
    super.initState();
    _loadDeptRequests();
  }

  void _loadDeptRequests() {
    deptRequestsFuture = ApiService.getDepartmentRequests(widget.department);
    setState(() {});
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final res = await ApiService.updateClearanceStatus(id, newStatus);

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Marked as $newStatus")));
      _loadDeptRequests();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res["message"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.department} Requests"),
        backgroundColor: Colors.blue,
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: deptRequestsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final List data = snapshot.data!["data"] ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("No requests found for this department"));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: data.map((req) => _requestCard(req)).toList(),
          );
        },
      ),
    );
  }

  Widget _requestCard(Map req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)]
      ),

      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Faculty ID: ${req["faculty_id"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("Year: ${req["academic_year"]}"),
        Text("Sem: ${req["semester"]}"),
        Text("Status: ${req["status"]}", style: const TextStyle(color: Colors.blue)),

        const SizedBox(height: 12),
        Row(children: [
          ElevatedButton(
            onPressed: () => updateStatus(req["_id"], "Approved"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Approve"),
          ),
          const SizedBox(width: 10),

          ElevatedButton(
            onPressed: () => updateStatus(req["_id"], "Rejected"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject"),
          )
        ])
      ]),
    );
  }
}
