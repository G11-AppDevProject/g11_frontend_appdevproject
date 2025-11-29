import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5000";

  // =============================== LOGIN =================================
  static Future<Map<String, dynamic>> login(
      String email, String password, String role) async {
    final url = Uri.parse("$baseUrl/api/auth/login");

    final resp = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password, "role": role}));

    return resp.statusCode == 200
        ? {"success": true, "data": jsonDecode(resp.body)}
        : {"success": false, "message": resp.body};
  }

  // =============================== FACULTY ===============================

  /// GET requests of this faculty
              static Future<Map<String, dynamic>> getClearanceRequests(
          String facultyId, {
          String? year,
          String? semester,
        }) async {
          final uri = Uri.parse("$baseUrl/api/clearance/request/$facultyId").replace(
            queryParameters: {
              if (year != null) "academic_year": year,
              if (semester != null) "semester": semester,
            },
          );

          final resp = await http.get(uri);
          final data = jsonDecode(resp.body);

          if (data["success"] != true || data["data"] == null) return data;

          // keep only latest request per department
          Map<String, dynamic> latest = {};
            for (var req in data["data"]) {
              String dept = req["department"] ?? "";

              // 🔥 FILTER HERE (THIS WAS MISSING)
              if (year != null && req["academic_year"] != year) continue;
              if (semester != null && req["semester"] != semester) continue;

              if (!latest.containsKey(dept) ||
                  (req["submitted_on"] != null &&
                  DateTime.parse(req["submitted_on"]).isAfter(
                    DateTime.parse(latest[dept]["submitted_on"] ?? "2000-01-01")))) {
                latest[dept] = req;
              }
            }


          return {
            "success": true,
            "data": latest.values.toList(),
          };
        }


  /// SEND request to specific dept
  static Future<Map<String, dynamic>> sendDepartmentRequest({
    required String facultyId,
    required String department,
    required String year,
    required String semester,
  }) async {
    final resp = await http.post(
      Uri.parse("$baseUrl/api/clearance/request/send"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "faculty_id": facultyId,
        "department": department,
        "academic_year": year,
        "semester": semester
      }),
    );
    return jsonDecode(resp.body);
  }

  /// RESUBMIT request after rejected
  static Future<Map<String, dynamic>> resubmitClearanceRequest(String id) async {
    final resp = await http.patch(Uri.parse("$baseUrl/api/clearance/request/resubmit/$id"));
    return jsonDecode(resp.body);
  }

  // ====================== DEPARTMENT/REGISTRAR ===========================

  /// LOAD requests only for selected department
  static Future<Map<String, dynamic>> getDepartmentRequests(String department) async {
    final resp = await http.get(Uri.parse("$baseUrl/api/clearance/requests/department/$department"));
    return jsonDecode(resp.body);
  }

  /// UPDATE → Pend / Approve / Reject
  static Future<Map<String, dynamic>> updateClearanceStatus(String id, String status) async {
    final resp = await http.patch(
      Uri.parse("$baseUrl/api/clearance/request/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": status}),
    );
    return jsonDecode(resp.body);
  }

  // =============================== ADMIN ===============================

  /// Load ALL clearance requests with optional filters
  static Future<Map<String, dynamic>> getAllClearanceRequests({
    String? year,
    String? semester,
  }) async {
    final uri = Uri.parse("$baseUrl/api/clearance/requests").replace(
      queryParameters: {
        if (year != null) "year": year,
        if (semester != null) "semester": semester,
      },
    );

    try {
      final resp = await http.get(uri);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return {
          "success": true,
          "data": data is List ? data : [], // ensure list output
        };
      }

      return {
        "success": false,
        "status": resp.statusCode,
        "message": resp.body,
        "data": [],
      };
    } catch (e) {
      return {"success": false, "message": "Failed: $e", "data": []};
    }
  }
  
// ============================================
// GET ONE CLEARANCE REQUEST BY ID  (View Details UI)
// ============================================

static Future<Map<String, dynamic>> getRequestById(String id) async {
  final url = Uri.parse("$baseUrl/api/clearance/request/by-id/$id"); // <-- correct backend route
  final resp = await http.get(url);

  return resp.statusCode == 200
      ? jsonDecode(resp.body)    // returns {success:true,data:{...}}
      : {"success": false, "message": resp.body};
}

// ===============================================
// FACULTY: Upload required document file
// PUT /api/clearance/upload/:id
// ===============================================
static Future<Map<String, dynamic>> uploadDocument({
  required String id,
  required String docName,
  required PlatformFile file,
}) async {
  try {
    final uri = Uri.parse("$baseUrl/api/clearance/upload/$id");
    final request = http.MultipartRequest("PUT", uri);

    request.fields["name"] = docName;            // <--- MUST MATCH DB EXACTLY

    // ===== WEB UPLOAD =====
    if (kIsWeb && file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          file.bytes!,
          filename: file.name,
          contentType: MediaType("application", "pdf"),   // <--- IMPORTANT
        ),
      );
    }

    // ===== MOBILE / DESKTOP =====
    else if (file.path != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          file.path!,
          contentType: MediaType("application", "pdf"),   // <--- IMPORTANT
        ),
      );
    } else {
      return {"success": false, "message": "No file data provided"};
    }

    final response = await request.send();
    final result = await http.Response.fromStream(response);

    return jsonDecode(result.body);

  } catch (e) {
    return {"success": false, "message": "UPLOAD ERROR — $e"};
  }
}

// =========================================
// ADMIN — Add Required Document to request
// POST /api/clearance/add-doc/:id
// =========================================
static Future<Map<String, dynamic>> addRequiredDocument(
  String requestId,
  String docName,
) async {
  final url = Uri.parse("$baseUrl/api/clearance/add-doc/$requestId");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"name": docName}),
  );

  try {
    return jsonDecode(response.body);
  } catch (_) {
    return {"success": false, "message": "Invalid server response"};
  }
}

// =========================================
// ADMIN — Update status of a single document 🔥
// =========================================
static Future<Map<String, dynamic>> updateDocumentStatus({
  required String requestId,
  required String docName,
  required String status,   // "Approved" or "Rejected"
}) async {
  final url = Uri.parse("$baseUrl/api/clearance/document-status/$requestId");

  final resp = await http.patch(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "docName": docName,
      "status": status,
    }),
  );

  return jsonDecode(resp.body);
}


}
