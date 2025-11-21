import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TestRequestsScreen extends StatefulWidget {
  const TestRequestsScreen({super.key});

  @override
  State<TestRequestsScreen> createState() => _TestRequestsScreenState();
}

class _TestRequestsScreenState extends State<TestRequestsScreen> {
  bool loading = false;
  dynamic response;

  Future<void> loadRequests() async {
    setState(() => loading = true);

    final res = await ApiService.getClearanceRequests("faculty123");

    setState(() {
      loading = false;
      response = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test GET Requests")),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: loadRequests,
                    child: const Text("Load Clearance Request"),
                  ),
                  const SizedBox(height: 20),
                  if (response != null)
                    Text(
                      response.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                ],
              ),
      ),
    );
  }
}
