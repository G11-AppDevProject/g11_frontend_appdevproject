import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';

import '../../screens/faculty/faculty_ocr_screen.dart';

class AdminRequestDetailsPage extends StatefulWidget {
  final String requestId;

  const AdminRequestDetailsPage({super.key, required this.requestId});

  @override
  State<AdminRequestDetailsPage> createState() => _AdminRequestDetailsPageState();
}

class _AdminRequestDetailsPageState extends State<AdminRequestDetailsPage> {
  bool loading = true;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    loadRequestDetails();
  }

  // ================= LOAD REQUEST =================
  Future<void> loadRequestDetails() async {
    final res = await ApiService.getRequestById(widget.requestId);

    if (!mounted) return;
    setState(() {
      data = res["data"];
      loading = false;
    });
  }

  // ================= UPDATE STATUS =================
  Future<void> updateStatus(String docName, String status) async {
    final res = await ApiService.updateDocumentStatus(
      requestId: widget.requestId,
      docName: docName,
      status: status,
    );

    print("🛠 UPDATED => $docName → $status");
    print("SERVER RESPONSE => $res");

    await loadRequestDetails(); // refresh UI

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$docName marked $status ✔")),
    );
  }

  // ===================== FORMAT DATE =====================
  String fmt(dynamic d) {
    if (d == null) return "-";
    try {
      return DateFormat("MMM dd, yyyy").format(DateTime.parse(d.toString()));
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // 🔙 BACK BUTTON
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    label: const Text("Back", style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(height: 10),

                  // HEADER
                  Row(
                    children: [
                      const Icon(Icons.domain_verification, size: 28, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(data?["department"] ?? "Department",
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Chip(
                        label: Text(data?["status"] ?? "Unknown"),
                        backgroundColor: Colors.orange.shade200,
                        labelStyle: const TextStyle(color: Colors.orange),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),

                Text("Request ID: ${data?["_id"]}",
                style: const TextStyle(color: Colors.black54)),

            const SizedBox(height: 25),

            // ====================== TABS ======================
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {}, // already in details
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  ),
                  child: const Text("Details", style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(width: 10),

                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FacultyOCRScreen(requestId: widget.requestId),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black87),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  ),
                  child: const Text("OCR Scanner", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),

            const SizedBox(height: 25),
                  // ================= REQUEST INFO CARD =================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: box(),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("Request Information",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      Row(children: [
                        Expanded(child: field("Faculty ID", data?["faculty_id"])),
                        Expanded(child: field("Department", data?["department"])),
                      ]),
                      const SizedBox(height: 20),

                      Row(children: [
                        Expanded(child: field("Submitted", fmt(data?["submitted_on"]))),
                        Expanded(child: field("Approved", fmt(data?["approved_on"]))),
                      ]),
                    ]),
                  ),

                  const SizedBox(height: 30),
                  // ================= REQUIRED DOCUMENTS =================
                  documentSection(),

                  const SizedBox(height: 30),

                  // ================= REMARKS (Soft White UI + Light Blue Button) =================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Remarks",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),

                          // 🔷 Light Blue Add/Edit Remarks Button
                          ElevatedButton(
                            onPressed: () => editRemarksDialog(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // light blue
                              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Add / Edit Remarks"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        data?["remarks"]?.toString().isNotEmpty == true
                            ? data!["remarks"]
                            : "No remarks yet...",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )

              ]),
            ),
          ),
        );
      }

  // =============================================================
  // DOCUMENT LIST
  // =============================================================
  Widget documentSection() {
    List docs = data?["required_documents"] ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: box(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Required Documents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            ElevatedButton(
              onPressed: showAddRequiredDocDialog,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.black),
              child: const Text("Insert for Faculty"),
            )
          ],
        ),
        const SizedBox(height: 10),
        const Text("Tap actions to approve/reject documents.",
            style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 15),

        if (docs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text("No required documents yet.",
                style: TextStyle(color: Colors.black54)),
          ),

        if (docs.isNotEmpty)
          ...docs.map((d) => adminDocRow(d)).toList(),
      ]),
    );
  }

  // =============================================================
  // 🔥 ADMIN DOCUMENT ROW (OPTION B — ACTION DROPDOWN)
  // =============================================================
  Widget adminDocRow(doc) {
    bool submitted = doc["file"] != null && doc["file"] != "";
    String status = doc["status"] ?? "Pending";
    String file = doc["file"] ?? "";
    Color color = status == "Approved"
        ? Colors.green
        : status == "Rejected"
            ? Colors.red
            : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [

          // Name
          Expanded(
            child: Text(doc["name"],
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),

          // Status Chip
          Chip(
            label: Text(status),
            backgroundColor: color.withOpacity(.2),
            labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),

          // VIEW PDF (if exists)
          if (submitted)
            OutlinedButton(
              onPressed: () {
                launchUrl(
                  Uri.parse("${ApiService.baseUrl}/uploads/$file"),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: const Text("View"),
            )
          else
            const Text("No file", style: TextStyle(color: Colors.black45)),

          const SizedBox(width: 10),

          // 🔽 ACTIONS DROPDOWN
          if (submitted)
            PopupMenuButton(
              onSelected: (value) {
                if (value == "approve") updateStatus(doc["name"], "Approved");
                if (value == "reject") updateStatus(doc["name"], "Rejected");
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: "approve", child: Text("Approve")),
                const PopupMenuItem(value: "reject", child: Text("Reject")),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Row(children: [
                  Text("Actions"),
                  Icon(Icons.arrow_drop_down),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  // =============================================================
  // INSERT REQUIRED DOCUMENT
  // =============================================================
  void showAddRequiredDocDialog() {
    final input = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Insert Required Document"),
        content: TextField(controller: input, decoration: const InputDecoration(hintText: "")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (input.text.trim().isEmpty) return;

              await ApiService.addRequiredDocument(widget.requestId, input.text.trim());
              Navigator.pop(context);

              loadRequestDetails();
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

void editRemarksDialog() {
  final input = TextEditingController(text: data?["remarks"]);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Add Remarks"),
      content: TextField(
        controller: input,
        maxLines: 4,
        decoration: const InputDecoration(hintText: "Enter remarks..."),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),

        ElevatedButton(
          onPressed: () async {
            await ApiService.updateRemarks(widget.requestId, input.text.trim());
            Navigator.pop(context);
            loadRequestDetails(); // refresh UI
          },
          child: const Text("Save"),
        )
      ],
    ),
  );
}

  // UI COMPONENTS
  Widget field(String title, value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ]);

  BoxDecoration box() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      );
}
