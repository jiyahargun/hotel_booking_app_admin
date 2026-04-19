import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/model/room_service_model.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/tabs/add_room_services.dart';
import 'package:hotel_booking_admin/services/api_service.dart';

class RoomServiceScreen extends StatefulWidget {
  final String roomId;
  final String roomType;

  const RoomServiceScreen({
    super.key,
    required this.roomId,
    required this.roomType,
  });

  @override
  State<RoomServiceScreen> createState() => _RoomServiceScreenState();
}

class _RoomServiceScreenState extends State<RoomServiceScreen> {
  List<RoomServiceModel> roomServices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    setState(() => isLoading = true);

    final data = await ApiService.getRoomServices(
      widget.roomId,
      widget.roomType,
    );

    setState(() {
      roomServices = data;
      isLoading = false;
    });
  }

  Future<void> goToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddRoomServiceScreen(
          roomId: widget.roomId,
          roomType: widget.roomType,
        ),
      ),
    );

    if (result == true) {
      fetchServices();
    }
  }

  Future<void> deleteService(String id) async {
    await ApiService.deleteRoomService(id);

    fetchServices();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Service Deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Services (${widget.roomType})"),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: goToAdd)],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : roomServices.isEmpty
          ? const Center(child: Text("No Services Found"))
          : ListView.builder(
              itemCount: roomServices.length,
              itemBuilder: (context, index) {
                final s = roomServices[index];

                return Dismissible(
                  key: Key(s.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    deleteService(s.id.toString());
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.room_service),
                      title: Text(s.serviceName),
                      subtitle: Text(s.roomType),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
