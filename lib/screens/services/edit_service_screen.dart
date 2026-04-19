import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditServiceScreen extends StatefulWidget {
  final String id;
  final String name;

  const EditServiceScreen({super.key, required this.id, required this.name});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  late TextEditingController controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.name);
  }

  Future<void> updateService() async {
    if (controller.text.trim().isEmpty) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/jiya/update_service.php"),
        body: {"id": widget.id, "service_name": controller.text.trim()},
      );

      final data = json.decode(response.body);

      if (data['status'] == true) {
        Navigator.pop(context, true);
      } else {
        throw Exception("Update failed");
      }
    } catch (e) {
      print(" ERROR: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Service")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
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
                onPressed: isLoading ? null : updateService,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Service"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
