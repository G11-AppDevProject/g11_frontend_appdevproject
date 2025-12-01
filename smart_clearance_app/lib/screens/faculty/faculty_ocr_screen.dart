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

  // 🔥 OCR API KEY
  final String apiKey = "K83221736988957";

  // ========================= PICK FILE =========================
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        selectedFileBytes = result.files.single.bytes;
        selectedFileName = result.files.single.name;
      });
    }
  }

  // ====================== FINANCIAL VALIDATION ======================
 Map<String, dynamic> validateFinancialClearance(String text) {
  text = text.toLowerCase();

  int score = 0;
  List<String> missing = [];

  // Title
  bool hasTitle = text.contains("financial clearance") || text.contains("clearance form");
  if (hasTitle) score += 20;
  else missing.add("Title not detected");

  // Faculty identity
  bool hasIdentity = text.contains("name") && text.contains("department");
  if (hasIdentity) score += 20;
  else missing.add("Missing Name / Department section");

  // Balance confirmation
  bool hasBalance = text.contains("no outstanding balance") ||
      text.contains("paid in full") ||
      text.contains("no remaining fees");
  if (hasBalance) score += 30;
  else missing.add("No proof of zero balance");

  // Signatory
  bool hasSignature = text.contains("approved") ||
      text.contains("signed") ||
      text.contains("finance officer");
  if (hasSignature) score += 30;
  else missing.add("Missing approval or signature");

  // 🚨 If NONE of the required elements exist → probably NOT financial clearance
  bool looksFake = !hasTitle && !hasIdentity && !hasBalance && !hasSignature;

  if (looksFake) {
    return {
      "score": 0,
      "remark": "❗ Cannot detect financial clearance elements.\nNot readable as Financial Clearance.\n(More document types coming soon)",
      "missing": ["Document doesn't match any financial clearance structure"],
    };
  }

  // Normal scoring
  String remark;
  if (score >= 70) remark = "✅ High chance of Financial Clearance — Valid Format";
  else if (score >= 40) remark = "⚠ Medium validity — Review recommended";
  else remark = "❌ Low validity — Incomplete structure";

  return {
    "score": score,
    "remark": remark,
    "missing": missing,
  };
}


  // ========================= OCR PROCESS =========================
  Future<void> processOCR() async {
    if (selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Upload a file first")),
      );
      return;
    }


    // 🔥 File size restriction (1 MB)
    if (selectedFileBytes!.lengthInBytes > 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❗ File exceeds 1MB. OCR cannot read large documents.")),
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
        http.MultipartFile.fromBytes(
          "file",
          selectedFileBytes!,
          filename: selectedFileName,
        ),
      );

      var response = await request.send();
      var result = await response.stream.bytesToString();
      var data = jsonDecode(result);

      setState(() => isLoading = false);

      String extracted = data["ParsedResults"]?[0]?["ParsedText"] ?? "No text detected.";

      // 🔥 VALIDATE OCR RESULT
      final resultCheck = validateFinancialClearance(extracted);
      String missingFields =
          resultCheck["missing"].isEmpty ? "None ✓" : resultCheck["missing"].join("\n• ");

      // ===================== SHOW RESULT =====================
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("$selectedDocType Report"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🔍 OCR Extracted Text\n", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(extracted),
                const SizedBox(height: 15),

                Text("\n📑 Validity Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
                // ================= RESULT UI WITH PROGRESS BAR =================
                Text("\n📊 Confidence Score", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: resultCheck["score"] / 100, // converts % to 0-1
                  backgroundColor: Colors.red.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    resultCheck["score"] >= 70 ? Colors.green :
                    resultCheck["score"] >= 40 ? Colors.orange :
                    Colors.red,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "${resultCheck["score"]}% Validity",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: resultCheck["score"] >= 70 ? Colors.green :
                          resultCheck["score"] >= 40 ? Colors.orange :
                          Colors.red,
                  ),
                ),
                Text("Status: ${resultCheck["remark"]}", style: TextStyle(fontSize: 16)),

                const SizedBox(height: 10),

                Text("\n❗ Missing Requirements:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("• $missingFields"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("OCR Failed → $e")));
    }
  }

  // ========================= UI (UNCHANGED) =========================
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
                onPressed: ()=> Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: Colors.black),
                label: Text("Back", style: TextStyle(color: Colors.black)),
              ),

              const SizedBox(height: 15),
              Row(
                children: const [
                  Icon(Icons.document_scanner, size: 28, color: Colors.deepPurple),
                  SizedBox(width: 10),
                  Text("OCR Document Scanner", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))
                ],
              ),

              const SizedBox(height: 30),

              Text("Select Document Type", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedDocType,
                items: ["Financial Clearance"].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v)=> setState(() => selectedDocType = v!),
              ),

              const SizedBox(height: 20),

              // Upload UI Box (same design)
              GestureDetector(
                onTap: pickFile,
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black45),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_file, size: 45, color: Colors.black54),
                        const SizedBox(height: 5),
                        Text(selectedFileName ?? "Tap to Upload PDF / Image"),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : processOCR,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Run OCR", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
