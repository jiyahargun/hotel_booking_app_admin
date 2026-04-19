import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  String? selectedHotelId;

  List hotelList = [];
  List roomList = [];

  bool isLoadingHotels = false;
  bool isLoadingRooms = false;

  @override
  void initState() {
    super.initState();
    fetchHotels();
    fetchRooms();
  }

  Future fetchHotels() async {
    setState(() => isLoadingHotels = true);
    try {
      var res = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_hotels.php"),
      );
      var data = jsonDecode(res.body);
      hotelList = data['data'] ?? [];
    } catch (e) {
      hotelList = [];
    }
    setState(() => isLoadingHotels = false);
  }

  Future fetchRooms() async {
    setState(() => isLoadingRooms = true);
    try {
      var res = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_room_categories.php"),
      );
      var data = jsonDecode(res.body);
      roomList = data['data'] ?? [];
    } catch (e) {
      roomList = [];
    }
    setState(() => isLoadingRooms = false);
  }

  String getHotelName(String hotelId) {
    try {
      return hotelList
          .firstWhere(
            (hotel) => hotel['id'].toString() == hotelId.toString(),
          )['hotel_name']
          .toString();
    } catch (e) {
      return "Unknown Hotel";
    }
  }

  Future addRoom(Map body) async {
    await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/insert_room_categories.php"),
      body: body,
    );
  }

  Future updateRoom(Map body) async {
    await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/update_room_categories.php"),
      body: body,
    );
  }

  Future deleteRoom(String id) async {
    await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/delete_room_categories.php"),
      body: {"id": id},
    );
    await fetchRooms();
  }

  Future<bool> confirmDeleteDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Delete Room"),
            content: const Text("Are you sure you want to delete this room?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void showRoomDialog({Map? room}) {
    TextEditingController type = TextEditingController(
      text: room?['room_type'] ?? "",
    );
    TextEditingController price = TextEditingController(
      text: room?['price'] ?? "",
    );
    TextEditingController total = TextEditingController(
      text: room?['total_rooms'] ?? "",
    );
    TextEditingController available = TextEditingController(
      text: room?['available_rooms'] ?? "",
    );
    TextEditingController desc = TextEditingController(
      text: room?['description'] ?? "",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(room == null ? "Add Room" : "Edit Room"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: type,
                decoration: const InputDecoration(labelText: "Room Type"),
              ),
              TextField(
                controller: price,
                decoration: const InputDecoration(labelText: "Price"),
              ),
              TextField(
                controller: total,
                decoration: const InputDecoration(labelText: "Total Rooms"),
              ),
              TextField(
                controller: available,
                decoration: const InputDecoration(labelText: "Available Rooms"),
              ),
              TextField(
                controller: desc,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (room == null && selectedHotelId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Select hotel first")),
                );
                return;
              }

              if (room == null) {
                await addRoom({
                  "hotel_id": selectedHotelId,
                  "room_type": type.text,
                  "price": price.text,
                  "total_rooms": total.text,
                  "available_rooms": available.text,
                  "description": desc.text,
                  "room_status": "1",
                });
              } else {
                await updateRoom({
                  "id": room['id'],
                  "hotel_id": room['hotel_id'],
                  "room_type": type.text,
                  "price": price.text,
                  "total_rooms": total.text,
                  "available_rooms": available.text,
                  "description": desc.text,
                  "room_status": "1",
                });
              }

              await fetchRooms();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Rooms"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showRoomDialog(),
        child: const Icon(Icons.add),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await fetchHotels();
          await fetchRooms();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    value: selectedHotelId,
                    hint: const Text("Select Hotel"),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: hotelList.map<DropdownMenuItem<String>>((hotel) {
                      return DropdownMenuItem(
                        value: hotel['id']?.toString(),
                        child: Text(hotel['hotel_name'] ?? ""),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedHotelId = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: isLoadingRooms
                    ? const Center(child: CircularProgressIndicator())
                    : roomList.isEmpty
                    ? const Center(child: Text("No Rooms Found"))
                    : ListView.builder(
                        itemCount: roomList.length,
                        itemBuilder: (context, index) {
                          var room = roomList[index];

                          return Dismissible(
                            key: Key(room['id'].toString()),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await confirmDeleteDialog();
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) async {
                              await deleteRoom(room['id'].toString());
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Room deleted")),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFDFBFB),
                                    Color(0xFFEBEDEE),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(14),
                                title: Text(
                                  room['room_type'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text(
                                      getHotelName(room['hotel_id']),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "₹${room['price']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.edit_note,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => showRoomDialog(room: room),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
