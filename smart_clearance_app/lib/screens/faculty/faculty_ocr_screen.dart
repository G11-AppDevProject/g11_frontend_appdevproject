import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class FacultyOCRScreen extends StatefulWidget {
  final String requestId;
  const FacultyOCRScreen({super.key, required this.requestId});

  @override
  State<FacultyOCRScreen> createState() => _FacultyOCRScreenState();
}

class _FacultyOCRScreenState extends State<FacultyOCRScreen> {
  Uint8List? selectedFileBytes;
  String? selectedFileName;
  String selectedDocType = "Financial Clearance";
  bool isLoading = false;

  // 🔥 YOUR API KEY
  final String apiKey = "K83221736988957";

  // ========================= PICK FILE =========================
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        selectedFileBytes = result.files.single.bytes;
        selectedFileName = result.files.single.name;
      });
    }
  }

  // ========================= OCR PROCESS =========================
  Future<void> processOCR() async {
    if (selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Upload a file first")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://api.ocr.space/parse/image"),
      );

      request.headers.addAll({"apikey": apiKey});
      request.files.add(
        http.MultipartFile.fromBytes("file", selectedFileBytes!,
            filename: selectedFileName),
      );

      var response = await request.send();
      var result = await response.stream.bytesToString();
      var data = jsonDecode(result);

      setState(() => isLoading = false);

      String extracted =
          data["ParsedResults"]?[0]?["ParsedText"] ?? "No text detected.";

      // ===================== SHOW RESULT =====================
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("$selectedDocType OCR Result"),
          content: SingleChildScrollView(child: Text(extracted)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            )
          ],
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OCR Failed → $e")),
      );
    }
  }

  // ========================= UI + DRAG UI =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                label: const Text("Back",
                    style: TextStyle(color: Colors.black87)),
              ),
              const SizedBox(height: 15),

              const Row(children: [
                Icon(Icons.document_scanner,
                    size: 28, color: Colors.deepPurple),
                SizedBox(width: 10),
                Text(
                  "OCR Document Scanner",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ]),

              const SizedBox(height: 25),

              const Text("Select Document Type",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedDocType,
                items: ["Financial Clearance"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => selectedDocType = v!),
              ),

              const SizedBox(height: 20),

              // ================= DRAG + CLICK BOX =================
              DragTarget<Uint8List>(
                onAccept: (fileBytes) {
                  setState(() {
                    selectedFileBytes = fileBytes;
                    selectedFileName = "Dragged_File.pdf";
                  });
                },
                builder: (context, candidate, rejected) {
                  return GestureDetector(
                    onTap: pickFile,
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: candidate.isNotEmpty
                            ? Colors.green.shade100
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black45),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file,
                                size: 45,
                                color: candidate.isNotEmpty
                                    ? Colors.green
                                    : Colors.black54),
                            const SizedBox(height: 5),
                            Text(
                              selectedFileName ??
                                  "Click OR Drag & Drop PDF/Image Here",
                              style: const TextStyle(color: Colors.black87),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : processOCR,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Run OCR",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
