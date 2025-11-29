import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';


class FacultyOCRScreen extends StatefulWidget {
  final String requestId;
  const FacultyOCRScreen({super.key, required this.requestId});

  @override
  State<FacultyOCRScreen> createState() => _FacultyOCRScreenState();
}

class _FacultyOCRScreenState extends State<FacultyOCRScreen> {
  Uint8List? selectedFileBytes;
  String? selectedFileName;
  bool isLoading = false;

  // =========================
  // PICK FILE (PDF / IMAGE)
  // =========================
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;

      if (file.size > 10 * 1024 * 1024) { // 10MB LIMIT
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File too large. Max 10MB")),
        );
        return;
      }

      setState(() {
        selectedFileBytes = file.bytes;
        selectedFileName = file.name;
      });
    }
  }

  // =========================
  // NEXT — Connect OCR Later
  // =========================
  Future<void> processOCR() async {
    if (selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload a file first.")),
      );
      return;
    }

    setState(() => isLoading = true);

    // 🔥 OCR WILL BE ADDED HERE IN NEXT STEP
    await Future.delayed(const Duration(seconds: 1));

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OCR Ready — Next Phase to Integrate")),
    );
  }

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

              // BACK TO DETAILS
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                label: const Text("Back", style: TextStyle(color: Colors.black87)),
              ),

              const SizedBox(height: 10),

              // HEADER
              Row(
                children: const [
                  Icon(Icons.text_snippet, color: Colors.deepPurple, size: 28),
                  SizedBox(width: 10),
                  Text("OCR Scanner",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // UPLOAD BOX
              GestureDetector(
                onTap: pickFile,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black45),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_file, size: 45, color: Colors.black87),
                        const SizedBox(height: 10),
                        Text(
                          selectedFileName ?? "Drag or Click to Upload PDF/Image",
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // PROCESS BUTTON
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
                      : const Text("Run OCR", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
