import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';
import 'faculty_ocr_screen.dart';

class FacultyRequestDetailsPage extends StatefulWidget {
  final String requestId;

  const FacultyRequestDetailsPage({super.key, required this.requestId});

  @override
  State<FacultyRequestDetailsPage> createState() =>
      _FacultyRequestDetailsPageState();
}

class _FacultyRequestDetailsPageState extends State<FacultyRequestDetailsPage> {
  bool loading = true;
  bool uploading = false;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  // ===============================
  // LOAD REQUEST FROM BACKEND
  // ===============================
  Future<void> _loadRequest() async {
    setState(() => loading = true);
    print("📥 Loading request details for id: ${widget.requestId}");

    try {
      final res = await ApiService.getRequestById(widget.requestId);
      print("📥 getRequestById response: $res");

      if (!mounted) return;

      if (res["success"] == true) {
        setState(() {
          data = res["data"] as Map<String, dynamic>;
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res["message"]?.toString() ?? "Failed to load details",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading details: $e")),
      );
    }
  }

  // ===============================
  // PICK + UPLOAD PDF
  // ===============================
  Future<void> _pickAndUpload(Map<String, dynamic> doc) async {
    final String docName = (doc["name"] ?? "Document").toString().trim();
    print("🟦 Upload button pressed for document: '$docName'");

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      print("⚪ File picking cancelled");
      return;
    }

    final file = result.files.single;
    print("📄 Picked file: ${file.name}, bytes: ${file.bytes?.length ?? 0}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Uploading...")),
    );

    setState(() => uploading = true);

    final res = await ApiService.uploadDocument(
      id: widget.requestId,
      docName: docName, // MUST match backend "name" exactly
      file: file,
    );

    print("📤 uploadDocument response: $res");

    if (!mounted) return;
    setState(() => uploading = false);

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploaded ✔")),
      );

      // reload request from DB so 'file' and 'status' refresh
      await _loadRequest();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["message"]?.toString() ?? "Upload failed ❌"),
        ),
      );
    }
  }

  // ===============================
  // VIEW PDF
  // ===============================
  Future<void> _viewFile(String filename) async {
    final url = "${ApiService.baseUrl}/uploads/$filename";
    print("👁 Opening file: $url");

    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot open file ❌")),
      );
    }
  }

  // ===============================
  // DATE FORMATTER
  // ===============================
  String _fmt(dynamic d) {
    if (d == null) return "-";
    try {
      return DateFormat("MMM dd, yyyy").format(DateTime.parse(d.toString()));
    } catch (_) {
      return "-";
    }
  }

  // ===============================
  // DOCUMENT ROW (Upload / View)
  // ===============================
 Widget _docRow(Map<String, dynamic> doc) {
  final String name = doc["name"] ?? "Document";
  final String status = doc["status"] ?? "Pending";
  final String file = doc["file"] ?? "";
  final bool hasFile = file.isNotEmpty;

  final bool allowResubmit = status == "Pending" || status == "Rejected";  
  final bool isApproved = status == "Approved";

  Color chipColor;
  switch (status) {
    case "Approved": chipColor = Colors.green; break;
    case "Rejected": chipColor = Colors.red; break;
    case "Submitted": chipColor = Colors.blue; break;
    default: chipColor = Colors.orange;
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ),

        // ==============================
        //   IF NO FILE → Upload
        // ==============================
        if (!hasFile)
          ElevatedButton(
            onPressed: uploading ? null : () => _pickAndUpload(doc),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: uploading
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2,color: Colors.white))
                : const Text("Upload"),
          )

        // ==============================
        // FILE EXISTS → View + Status
        // ==============================
        else Row(
          children: [
            OutlinedButton(
              onPressed: () => _viewFile(file),
              child: const Text("View"),
            ),
            const SizedBox(width: 10),

            // 🔥 Re-submit allowed only if not approved
            if (allowResubmit)
              ElevatedButton(
                onPressed: () => _pickAndUpload(doc),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Re-submit"),
              ),

            // 🔥 Approved → show only Approved chip
            if (isApproved)
              Chip(
                label: const Text("Approved"),
                backgroundColor: Colors.green.withOpacity(.15),
                labelStyle: const TextStyle(color: Colors.green,fontWeight: FontWeight.bold),
              ),

            // Show status chip always (except approved handled above)
            if (!isApproved)
              Chip(
                label: Text(status),
                backgroundColor: chipColor.withOpacity(.15),
                labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ],
    ),
  );
}



  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FF),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BACK
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      label: const Text(
                        "Back",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // HEADER
                    Row(
                      children: [
                        const Icon(Icons.description,
                            color: Colors.blue, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          data?["department"] ?? "Department",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Chip(
                          label: Text(data?["status"] ?? "Unknown"),
                          backgroundColor: Colors.orange.shade200,
                          labelStyle:
                              const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Request ID: ${data?["_id"] ?? widget.requestId}",
                      style: const TextStyle(
                          fontSize: 15, color: Colors.black54),
                    ),

                    const SizedBox(height: 25),

                    // TABS
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                          ),
                          child: const Text("Details",
                              style: TextStyle(color: Colors.white)),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                          ),
                          child: const Text("OCR Scanner",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // REQUEST INFO CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _box(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Request Information",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _infoColumn(
                                  title: "Faculty ID",
                                  value: data?["faculty_id"],
                                ),
                              ),
                              Expanded(
                                child: _infoColumn(
                                  title: "Department",
                                  value: data?["department"],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _infoColumn(
                                  title: "Submitted",
                                  value: _fmt(data?["submitted_on"]),
                                ),
                              ),
                              Expanded(
                                child: _infoColumn(
                                  title: "Approved",
                                  value: _fmt(data?["approved_on"]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // REQUIRED DOCUMENTS CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _box(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Required Documents",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (data?["required_documents"] == null ||
                              (data?["required_documents"] as List).isEmpty)
                            const Text(
                              "No required documents yet.",
                              style: TextStyle(color: Colors.black54),
                            ),

                          if (data?["required_documents"] is List)
                            ...List<Widget>.from(
                              (data!["required_documents"] as List)
                                  .map<Widget>((doc) {
                                final m = Map<String, dynamic>.from(doc);
                                return _docRow(m);
                              }),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      );
}

class _infoColumn extends StatelessWidget {
  final String title;
  final String? value;
  const _infoColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          value ?? "-",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
