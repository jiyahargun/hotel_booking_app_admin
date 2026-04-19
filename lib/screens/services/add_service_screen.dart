import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final TextEditingController serviceController = TextEditingController();

  bool isLoading = false;

  Future<void> addService() async {
    if (serviceController.text.trim().isEmpty) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/jiya/insert_service.php"),
        body: {"service_name": serviceController.text.trim()},
      );

      final data = json.decode(response.body);

      if (data['status'] == true) {
        Navigator.pop(context, true);
      } else {
        throw Exception("Failed");
      }
    } catch (e) {
      print("ERROR: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Service")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: serviceController,
              decoration: const InputDecoration(
                labelText: "Service Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : addService,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Service"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
