import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/model/image_model.dart';
import 'package:hotel_booking_admin/model/room_model.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/tabs/fullscreen_gallary.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/tabs/room_services_screen.dart';
import 'package:hotel_booking_admin/services/api_service.dart';

class RoomsTab extends StatefulWidget {
  final String hotelId;

  const RoomsTab({super.key, required this.hotelId});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  List<RoomModel> rooms = [];
  List<RoomImageModel> images = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    final roomData = await ApiService.getRoomCategories(widget.hotelId);
    final imageData = await ApiService.getRoomImages();

    final filteredRooms = roomData
        .where((r) => r.hotelId.toString() == widget.hotelId.toString())
        .toList();

    setState(() {
      rooms = filteredRooms;
      images = imageData;
      isLoading = false;
    });
  }

  List<String> getImages(String roomId) {
    return images
        .where((e) => e.roomCategoryId.toString() == roomId.toString())
        .map((e) => e.image)
        .toList();
  }

  Future<String?> getRealRoomId(String categoryId) async {
    final allRooms = await ApiService.getRooms();

    final filtered = allRooms
        .where(
          (r) =>
              r['room_category_id'].toString().trim() ==
              categoryId.toString().trim(),
        )
        .toList();

    if (filtered.isNotEmpty) {
      return filtered.first['id'].toString();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rooms")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rooms.isEmpty
          ? const Center(child: Text("No Rooms Found"))
          : ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                final imageList = getImages(room.id);

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: imageList.isEmpty
                            ? const Center(child: Icon(Icons.image))
                            : PageView.builder(
                                itemCount: imageList.length,
                                itemBuilder: (context, i) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FullScreenGallery(
                                            images: imageList,
                                            initialIndex: i,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Image.network(
                                      imageList[i],
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                      ),
                      ListTile(
                        title: Text(room.roomType),
                        subtitle: Text("₹${room.price}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.miscellaneous_services),
                          onPressed: () async {
                            final realRoomId = await getRealRoomId(room.id);

                            if (realRoomId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("No actual rooms found"),
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RoomServiceScreen(
                                  roomId: realRoomId,
                                  roomType: room.roomType,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
