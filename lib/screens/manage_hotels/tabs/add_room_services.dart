import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/model/service_model.dart';
import 'package:hotel_booking_admin/services/api_service.dart';

class AddRoomServiceScreen extends StatefulWidget {
  final String roomId;
  final String roomType;

  const AddRoomServiceScreen({
    super.key,
    required this.roomId,
    required this.roomType,
  });

  @override
  State<AddRoomServiceScreen> createState() => _AddRoomServiceScreenState();
}

class _AddRoomServiceScreenState extends State<AddRoomServiceScreen> {
  List<ServiceModel> services = [];
  String? selectedServiceId;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    services = await ApiService.getServices();
    setState(() {});
  }

  Future<void> addService() async {
    if (selectedServiceId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select Service")));
      return;
    }

    final success = await ApiService.addRoomService(
      roomId: widget.roomId,
      serviceId: selectedServiceId!,
    );

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to add service")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Service")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              hint: const Text("Select Service"),
              items: services.map((e) {
                return DropdownMenuItem(
                  value: e.id,
                  child: Text(e.serviceName),
                );
              }).toList(),
              onChanged: (v) => selectedServiceId = v,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addService,
              child: const Text("Add Service"),
            ),
          ],
        ),
      ),
    );
  }
}
