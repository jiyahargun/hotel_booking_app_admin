import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/screens/services/add_room_screen.dart';
import 'package:http/http.dart' as http;
import 'add_service_screen.dart';
import 'edit_service_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      setState(() => isLoading = true);

      final response = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_service.php"),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        setState(() {
          services = decoded['data'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteService(String id) async {
    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/jiya/delete_service.php"),
        body: {"id": id},
      );

      final data = json.decode(response.body);

      if (data['status'] == true) {
        fetchServices();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Service Deleted")));
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  Future<void> goToAddService() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddServiceScreen()),
    );
    if (result == true) fetchServices();
  }

  Future<void> goToEditService(service) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditServiceScreen(
          id: service['id'].toString(),
          name: service['service_name'],
        ),
      ),
    );
    if (result == true) fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Services",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),

        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 20, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddRoomScreen()),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToAddService,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text("Add"),
      ),

      body: RefreshIndicator(
        onRefresh: fetchServices,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : services.isEmpty
            ? const Center(child: Text("No Services Found"))
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];

                  return Dismissible(
                    key: Key(service['id'].toString()),
                    direction: DismissDirection.endToStart,

                    background: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Service"),
                          content: const Text("Are you sure?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },

                    onDismissed: (direction) {
                      deleteService(service['id'].toString());
                    },

                    child: GestureDetector(
                      onTap: () => goToEditService(service),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.miscellaneous_services,
                                color: Colors.blue,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                service['service_name'] ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
