import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For web + PC testing (localhost)
  static const String baseUrl = "http://localhost:5000";

      // Login API
      static Future<Map<String, dynamic>> login(String email, String password, String role) async {
        final url = Uri.parse("$baseUrl/api/auth/login");

        final resp = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": email,
            "password": password,
            "role": role,
          }),
        );

        if (resp.statusCode == 200) {
          return {
            "success": true,
            "data": jsonDecode(resp.body),
          };
        } else {
          return {
            "success": false,
            "status": resp.statusCode,
            "message": resp.body,
          };
        }
      }

  // ==========================================================
  // GET -- Clearance Requests (from clearance_request collection)
  // /api/clearance/request/:facultyId
  // ==========================================================
  static Future<Map<String, dynamic>> getClearanceRequests(String facultyId) async {
    final url = Uri.parse("$baseUrl/api/clearance/request/$facultyId");

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      return {
        "success": true,
        "data": jsonDecode(resp.body),
      };
    } else {
      return {
        "success": false,
        "status": resp.statusCode,
        "message": resp.body,
      };
    }
  }

  // ==========================================================
  // FACULTY:
  // /api/reports/:facultyId  → returns ONE report (Map)
  // ==========================================================
  static Future<Map<String, dynamic>> getClearanceReport(String facultyId) async {
    final url = Uri.parse("$baseUrl/api/reports/$facultyId");

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      return {
        "success": true,
        "data": jsonDecode(resp.body),
      };
    } else {
      return {
        "success": false,
        "status": resp.statusCode,
        "message": resp.body,
      };
    }
  }

  //==========================================================
  // FACULTY:
  // /api/reports/:facultyId  → returns LIST of departments
  // ==========================================================
  static Future<List<dynamic>> getClearanceReports(String facultyId) async {
    final url = Uri.parse("$baseUrl/api/reports/$facultyId");

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body); // return List<dynamic>
    } else {
      throw Exception(
          "Failed to fetch clearance reports: ${resp.statusCode}");
    }
  }







// ==========================================================
// ADMIN: Get ALL clearance requests
// /api/clearance/requests?year=2025–2026&semester=First%20Semester
static Future<Map<String, dynamic>> getAllClearanceRequests({
  String? year,
  String? semester,
}) async {
  final uri = Uri.parse("$baseUrl/api/clearance/requests")
      .replace(queryParameters: {
    if (year != null) "year": year,
    if (semester != null) "semester": semester,
  });

  try {
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      
      // If no data is returned, we consider it a "no results" condition
      if (data.isEmpty) {
        return {
          "success": false,
          "message": "No requests found",
          "data": [],
        };
      }

      return {
        "success": true,
        "data": data,
      };
    } else {
      return {
        "success": false,
        "status": resp.statusCode,
        "message": resp.body,
      };
    }
  } catch (e) {
    // Handle any exceptions that occur during the API call
    return {
      "success": false,
      "message": "Failed to load data: $e",
    };
  }
}


// ==========================================================
// ADMIN: Update request status (Approve / Reject)
// /api/clearance/request/:id
// ==========================================================
static Future<Map<String, dynamic>> updateClearanceStatus(
    String id, String status) async {
  final url = Uri.parse("$baseUrl/api/clearance/request/$id");

  final resp = await http.patch(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"status": status}),
  );

  if (resp.statusCode == 200) {
    return {
      "success": true,
      "data": jsonDecode(resp.body),
    };
  } else {
    return {
      "success": false,
      "status": resp.statusCode,
      "message": resp.body,
    };
  }
}

}
