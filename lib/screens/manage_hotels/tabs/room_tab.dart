import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/model/room_model.dart';
import 'package:hotel_booking_admin/services/api_service.dart';

class RoomsTab extends StatefulWidget {
  final String hotelId;

  const RoomsTab({super.key, required this.hotelId});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  List<RoomModel> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    print("📌 HOTEL ID RECEIVED: ${widget.hotelId}");

    try {
      final data = await ApiService.getRoomCategories(widget.hotelId);

      print(" TOTAL ROOMS FROM API: ${data.length}");

      final filteredRooms = data
          .where((room) => room.hotelId == widget.hotelId)
          .toList();

      print("FILTERED ROOMS: ${filteredRooms.length}");

      setState(() {
        rooms = filteredRooms;
        isLoading = false;
      });
    } catch (e) {
      print(" ERROR: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rooms.isEmpty) {
      return const Center(
        child: Text(
          "No Rooms Available for this Hotel 🏨",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: ListTile(
            title: Text(
              room.roomType.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "₹${room.price} | Available: ${room.availableRooms}",
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: room.roomStatus == "1" ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                room.roomStatus == "1" ? "Active" : "Inactive",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
