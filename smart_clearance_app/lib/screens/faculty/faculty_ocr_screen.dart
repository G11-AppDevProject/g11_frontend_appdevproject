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

// ====================== LIBRARY CLEARANCE VALIDATION ======================
Map<String, dynamic> validateLibraryClearance(String text) {
  text = text.toLowerCase();

  int score = 0;
  List<String> missing = [];

  // Title
  bool hasTitle = text.contains("library clearance") || text.contains("clearance form");
  if (hasTitle) score += 20; else missing.add("Missing Library Clearance title");

  // Borrowed items section
  bool hasBorrow = text.contains("borrowed") || text.contains("returned") || text.contains("books");
  if (hasBorrow) score += 30; else missing.add("Missing borrowed/returned books section");

  // Faculty identity
  bool hasIdentity = text.contains("name") || text.contains("faculty");
  if (hasIdentity) score += 20; else missing.add("Missing faculty name");

  // Approval/signature
  bool hasSignature = text.contains("librarian") || text.contains("approved") || text.contains("signature");
  if (hasSignature) score += 30; else missing.add("Missing librarian approval/signature");

  if (score == 0) {
    return {
      "score": 0,
      "remark": "❗ Not readable as Library Clearance, \n(More document types coming soon",
      "missing": missing,
    };
  }

  String remark;
  if (score >= 70) remark = "✅ Valid Library Clearance Format";
  else if (score >= 40) remark = "⚠ Partially Valid — Needs Review";
  else remark = "❌ Weak — Incomplete Structure";

  return {"score": score, "remark": remark, "missing": missing};
}

// ====================== BORROWED BOOKS RETURN SLIP VALIDATION ======================
Map<String, dynamic> validateBorrowedBooksSlip(String text) {
  text = text.toLowerCase();
  int score = 0;
  List<String> missing = [];

  // ========================= TITLE CHECK =========================
  bool hasTitle =
      text.contains("borrowed books return slip") ||
      text.contains("return slip") ||
      text.contains("dlrc — borrowed books");

  if (hasTitle) score += 30;
  else missing.add("Missing official 'Borrowed Books Return Slip' title");


  // ========================= BOOK LIST CHECK =========================
  // Require ACTUAL book-like entries (title/author/isbn)
  bool hasBookList = RegExp(
    r"(isbn|call number|author|title:|book title|module|copy no\.|#\d+)"
  ).hasMatch(text);

  if (hasBookList) score += 30;
  else missing.add("Missing list of returned items (ISBN, title, author, or call number)");


  // ========================= DATE CHECK =========================
  // Detect real date formats (e.g. September 1, 2025 or 09/01/25)
  bool hasDate = RegExp(
    r"(date\s*[:\-]\s*\w+|\b\d{1,2}\/\d{1,2}\/\d{2,4}\b|\b\d{4}\b)"
  ).hasMatch(text);

  if (hasDate) score += 20;
  else missing.add("Missing official return date");


  // ========================= SIGNATURE / APPROVAL =========================
  bool hasSignature = RegExp(
    r"(librarian|library staff|verified by|checked by|approved by|signature)"
  ).hasMatch(text);

  if (hasSignature) score += 20;
  else missing.add("Missing librarian approval or signature");


  // ========================= ZERO SCORE CASE =========================
  if (score == 0) {
    return {
      "score": 0,
      "remark": "❗ Not readable as Borrowed Books Return Slip.",
      "missing": missing,
    };
  }

  // ========================= FINAL REMARK =========================
  String remark;
  if (score >= 70) remark = "✅ Valid Borrowed Books Return Slip";
  else if (score >= 40) remark = "⚠ Needs Review";
  else remark = "❌ Incomplete Format";

  return {"score": score, "remark": remark, "missing": missing};
}

// ====================== PMO EQUIPMENT RETURN VALIDATION ======================
Map<String, dynamic> validateEquipmentReturn(String text) {
  text = text.toLowerCase();

  int score = 0;
  List<String> missing = [];

  // ===== TITLE CHECK =====
  bool hasTitle =
      text.contains("equipment return") ||
      text.contains("asset accountability") ||
      text.contains("property office") ||
      text.contains("pmo clearance");

  if (hasTitle) score += 25;
  else missing.add("Missing Equipment/Asset Return title");

  // ===== ITEM LIST CHECK =====
  bool hasItems = RegExp(
    r"(item|equipment|serial|unit|model|property|description)"
  ).hasMatch(text);

  if (hasItems) score += 25;
  else missing.add("Missing item/equipment details");

  // ===== IDENTITY CHECK =====
  bool hasIdentity = RegExp(r"(name|faculty|employee)").hasMatch(text);
  if (hasIdentity) score += 20;
  else missing.add("Missing faculty/employee name");

  // ===== APPROVAL/SIGNATURE CHECK =====
  bool hasSignature = RegExp(r"(approved|checked by|property custodian|signature)").hasMatch(text);
  if (hasSignature) score += 30;
  else missing.add("Missing PMO approval or signature");

  // ===== ZERO SCORE CASE =====
  if (score == 0) {
    return {
      "score": 0,
      "remark": "❗ Not readable as PMO Equipment/Asset Clearance.",
      "missing": missing,
    };
  }

  // ===== FINAL REMARK =====
  String remark;
  if (score >= 70) remark = "✅ Valid PMO Equipment Return Clearance";
  else if (score >= 40) remark = "⚠ Partially Valid — Needs Review";
  else remark = "❌ Incomplete Format";

  return {"score": score, "remark": remark, "missing": missing};
}

// ====================== LABORATORY TOOLS RETURN VALIDATION ======================
Map<String, dynamic> validateLabReturn(String text) {
  text = text.toLowerCase();

  int score = 0;
  List<String> missing = [];

  // ===== TITLE CHECK =====
  bool hasTitle =
      text.contains("laboratory") &&
      (text.contains("tools") || text.contains("equipment")) &&
      (text.contains("return") || text.contains("checklist"));

  if (hasTitle) score += 25;
  else missing.add("Missing Laboratory Tools Return title");

  // ===== ITEM LIST CHECK =====
  bool hasItems = RegExp(
    r"(test tube|microscope|beaker|pipette|flask|experiment|lab|chemicals)"
  ).hasMatch(text);

  if (hasItems) score += 25;
  else missing.add("Missing list of returned laboratory materials");

  // ===== IDENTITY CHECK =====
  bool hasIdentity = RegExp(r"(name|student|faculty|section)").hasMatch(text);
  if (hasIdentity) score += 20;
  else missing.add("Missing name/section/faculty identifier");

  // ===== APPROVAL / VERIFIED CHECK =====
  bool hasVerification = RegExp(
    r"(checked by|verified by|laboratory custodian|lab technician|signature)"
  ).hasMatch(text);

  if (hasVerification) score += 30;
  else missing.add("Missing laboratory staff verification");

  // ===== ZERO SCORE CASE =====
  if (score == 0) {
    return {
      "score": 0,
      "remark": "❗ Not readable as Laboratory Tools Return Checklist.",
      "missing": missing,
    };
  }

  // ===== FINAL REMARK =====
  String remark;
  if (score >= 70) remark = "✅ Valid Laboratory Return Checklist";
  else if (score >= 40) remark = "⚠ Partially Valid — Needs Review";
  else remark = "❌ Incomplete Format";

  return {"score": score, "remark": remark, "missing": missing};
}

// ====================== ICT DEVICE RETURN VALIDATION ======================
Map<String, dynamic> validateICTReturn(String text) {
  text = text.toLowerCase();

  int score = 0;
  List<String> missing = [];

  // ===== TITLE CHECK =====
  bool hasTitle =
      text.contains("device return") ||
      text.contains("laptop return") ||
      text.contains("ict equipment") ||
      text.contains("ict clearance");

  if (hasTitle) score += 25;
  else missing.add("Missing ICT Device/Laptop Return title");

  // ===== DEVICE DETAILS CHECK (model, asset tag, serial, etc.) =====
  bool hasDeviceDetails = RegExp(
    r"(serial|asset|model|device|laptop|tablet|computer)"
  ).hasMatch(text);

  if (hasDeviceDetails) score += 25;
  else missing.add("Missing device/equipment details");

  // ===== FACULTY IDENTITY CHECK =====
  bool hasIdentity = RegExp(r"(name|faculty|instructor|department)").hasMatch(text);
  if (hasIdentity) score += 20;
  else missing.add("Missing faculty name/department");

    // ===== APPROVAL/VERIFIED CHECK =====
    // Must show approver name (not just role like "ICT Staff")
    bool hasVerification = RegExp(
      r"(received by[: ]+[a-z])|(checked by[: ]+[a-z])|(verified by[: ]+[a-z])|(ict staff[: ]+[a-z])"
    ).hasMatch(text);

    if (hasVerification) score += 30;
    else missing.add("Missing ICT approval with staff signature/name");

  // ===== ZERO SCORE CASE =====
  if (score == 0) {
    return {
      "score": 0,
      "remark": "❗ Not readable as ICT Device Return Clearance.",
      "missing": missing,
    };
  }

  // ===== FINAL REMARK =====
  String remark;
  if (score >= 70) remark = "✅ Valid ICT Equipment Return";
  else if (score >= 40) remark = "⚠ Partially Valid — Needs Review";
  else remark = "❌ Incomplete Format";

  return {"score": score, "remark": remark, "missing": missing};
}

// ====================== CESO PARTICIPATION VALIDATION ======================
Map<String, dynamic> validateCESOCompletion(String text) {
  text = text.toLowerCase();

  int score = 0;
  List<String> missing = [];

  // ===== TITLE CHECK =====
  bool hasTitle =
      (text.contains("community extension") || text.contains("ceso")) &&
      (text.contains("form") || text.contains("completion") || text.contains("participation"));

  if (hasTitle) score += 30;
  else missing.add("Missing CESO Form/Completion title");

  // ===== FACULTY NAME CHECK =====
  bool hasName = text.contains("name") || RegExp(r"(prof|mr\.|ms\.|dr\.)").hasMatch(text);
  if (hasName) score += 15;
  else missing.add("Missing faculty name section");

  // ===== ACTIVITY / PROGRAM CHECK =====
  bool hasActivity = RegExp(r"(activity|program|outreach|seminar|event)").hasMatch(text);
  if (hasActivity) score += 25;
  else missing.add("No community activity stated");

  // ===== DATE CHECK =====
  bool hasDate = RegExp(r"(date|issued|20[0-9]{2})").hasMatch(text);
  if (hasDate) score += 15;
  else missing.add("Missing issue/participation date");

  // ===== APPROVAL CHECK =====
    bool hasSignature = RegExp(r"(coordinator[: ]+[a-z])|(approved by[: ]+[a-z])").hasMatch(text);
    if (hasSignature) score += 25;
    else {
      missing.add("Missing CESO approval / coordinator signature");
      score -= 20; // ❗ Strong penalty
    }

  // ===== ZERO SCORE CASE =====
  if (score == 0) {
    return {
      "score": 0,
      "remark": "❗ Not readable as CESO Completion Form.",
      "missing": missing,
    };
  }

  // ===== FINAL REMARK =====
  String remark;
  if (score >= 70) remark = "✅ Valid CESO Completion Form";
  else if (score >= 40) remark = "⚠ Partially Valid — Needs Review";
  else remark = "❌ Incomplete Structure";

  return {"score": score, "remark": remark, "missing": missing};
}

// ====================== PROGRAM CHAIR CLEARANCE VALIDATION ======================
Map<String, dynamic> validateProgramChairClearance(String text) {
  text = text.toLowerCase();

  int score = 0;
  List<String> missing = [];

  // ===== NAME FILLED =====
  bool nameFilled = RegExp(r"(name[: ]+[a-z])").hasMatch(text);
  if (nameFilled) score += 25;
  else missing.add("Name field seems incomplete");

  // ===== DEPARTMENT FILLED =====
  bool departmentFilled = RegExp(r"(department[: ]+[a-z])").hasMatch(text);
  if (departmentFilled) score += 25;
  else missing.add("Department field not properly filled");

  // ===== LOAD / COMPLIANCE CHECK =====
  // must detect a list with at least 3 subjects
  List<String> detectedSubjects = RegExp(
    r"(english|math|science|research|filipino|values|arts|pe|tourism|business|history)"
  ).allMatches(text).map((m) => m.group(0)!).toList();

  bool hasCompliance = detectedSubjects.length >= 3;

  if (hasCompliance) score += 45; 
  else missing.add("Teaching Load / Compliance details unclear or incomplete");

  // ===== OPTIONAL APPROVAL (bonus only, not required) =====
  bool hasApproval = RegExp(
    r"(approved by|program chair|assistant principal|signature)"
  ).hasMatch(text);

  if (hasApproval) score += 5; 
  // NO deduction if missing

  // ===== REMARK =====
  String remark;
  if (score >= 70) remark = "✔ Likely acceptable — Complete Faculty Clearance";
  else if (score >= 40) remark = "⚠ Needs review — Some missing details";
  else remark = "❌ Low validity — Many fields incomplete";

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
      Map<String, dynamic> resultCheck;

      if (selectedDocType == "Financial Clearance") {
        resultCheck = validateFinancialClearance(extracted);
      } else if (selectedDocType == "Library Clearance Form") {
        resultCheck = validateLibraryClearance(extracted);
      } else if (selectedDocType == "Borrowed Books Return Slip") {
        resultCheck = validateBorrowedBooksSlip(extracted);
      } 
        else if (selectedDocType == "PMO Equipment Return") {
        resultCheck = validateEquipmentReturn(extracted);
      } 
        else if (selectedDocType == "Laboratory Tools Return Checklist") {
        resultCheck = validateLabReturn(extracted);
      }
        else if (selectedDocType == "ICT Device Return Slip") {
        resultCheck = validateICTReturn(extracted);
      }
        else if (selectedDocType == "CESO Completion Form") {
        resultCheck = validateCESOCompletion(extracted);
      }
        else if (selectedDocType == "Program Chair Clearance Form") {
        resultCheck = validateProgramChairClearance(extracted);
      }

      else {
        resultCheck = {
          "score": 0,
          "remark": "❗ No validation rules for this document yet.",
          "missing": ["Document type not supported"],
        };
      }

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
                items: ["Financial Clearance",
                        "Library Clearance Form",
                        "Borrowed Books Return Slip",
                        "PMO Equipment Return",
                        "Laboratory Tools Return Checklist",
                        "ICT Device Return Slip",
                        "CESO Completion Form",
                        "Program Chair Clearance Form",
                         ]
                        .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
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
