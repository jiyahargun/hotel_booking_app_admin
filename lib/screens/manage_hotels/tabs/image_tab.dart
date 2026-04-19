import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'add_room_image_screen.dart';

class ImagesTab extends StatefulWidget {
  final String hotelId;

  const ImagesTab({super.key, required this.hotelId});

  @override
  State<ImagesTab> createState() => _ImagesTabState();
}

class _ImagesTabState extends State<ImagesTab> {
  List images = [];
  bool isLoading = true;

  List roomImages = [];
  bool roomLoading = true;

  List roomCategories = [];

  @override
  void initState() {
    super.initState();
    fetchImages();
    fetchRoomCategories();
  }

  Future<void> fetchImages() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("https://www.prakrutitech.xyz/jiya/view_hotel_images.php"),
      );

      final data = json.decode(response.body);

      List allImages = data["data"] ?? [];

      setState(() {
        images = allImages.where((item) {
          return item["hotel_id"].toString() == widget.hotelId.toString();
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickAndUploadImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    File file = File(picked.path);

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("https://www.prakrutitech.xyz/jiya/insert_hotel_images.php"),
    );

    request.fields["hotel_id"] = widget.hotelId;
    request.files.add(await http.MultipartFile.fromPath("image", file.path));

    await request.send();
    fetchImages();
  }

  Future<void> deleteImage(String id) async {
    await http.post(
      Uri.parse("https://www.prakrutitech.xyz/jiya/delete_hotel_images.php"),
      body: {"id": id},
    );

    fetchImages();
  }

  Future<void> fetchRoomCategories() async {
    try {
      final response = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_room_categories.php"),
      );

      final data = json.decode(response.body);

      if (data["status"] == true) {
        List allRooms = data["data"];

        roomCategories = allRooms.where((room) {
          return room["hotel_id"].toString() == widget.hotelId.toString();
        }).toList();

        fetchRoomImages();
      }
    } catch (e) {}
  }

  Future<void> fetchRoomImages() async {
    setState(() => roomLoading = true);

    try {
      final response = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_rooms_images.php"),
      );

      final data = json.decode(response.body);

      if (data["status"] == true) {
        List allImages = data["data"];

        final roomIds = roomCategories.map((e) => e["id"].toString()).toList();

        roomImages = allImages.where((img) {
          return roomIds.contains(img["room_category_id"].toString());
        }).toList();
      }

      setState(() => roomLoading = false);
    } catch (e) {
      setState(() => roomLoading = false);
    }
  }

  Future<void> deleteRoomImage(String id) async {
    await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/delete_room_images.php"),
      body: {"id": id},
    );

    fetchRoomImages();
  }

  void confirmDelete({required String id, required bool isRoom}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Image"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isRoom) {
                deleteRoomImage(id);
              } else {
                deleteImage(id);
              }
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String getCategoryName(String id) {
    final room = roomCategories.firstWhere(
      (e) => e["id"].toString() == id,
      orElse: () => {},
    );

    return room.isNotEmpty ? room["room_type"] : "Unknown";
  }

  Map<String, List> groupImages() {
    Map<String, List> grouped = {};

    for (var img in roomImages) {
      String roomId = img["room_category_id"].toString();
      String name = getCategoryName(roomId);

      grouped.putIfAbsent(name, () => []);
      grouped[name]!.add(img);
    }

    return grouped;
  }

  String fixUrl(String url) {
    return url.replaceAll(r'\/', '/');
  }

  void openViewer(List list, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageViewer(images: list, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedImages = groupImages();

    Widget buildImage(String url) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 110,
          height: 90,
          child: Image.network(url, fit: BoxFit.cover),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Hotel Images",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          onPressed: pickAndUploadImage,
                        ),
                      ],
                    ),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (images.isEmpty)
                      const Text("No Images")
                    else
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final item = images[index];

                            String imgUrl = fixUrl(item["image"]);
                            String id = item["id"].toString();

                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => openViewer(images, index),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    child: buildImage(imgUrl),
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () =>
                                        confirmDelete(id: id, isRoom: false),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Room Images",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddRoomImageScreen(hotelId: widget.hotelId),
                              ),
                            ).then((_) => fetchRoomCategories());
                          },
                        ),
                      ],
                    ),
                    if (roomLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (roomImages.isEmpty)
                      const Text("No Room Images")
                    else
                      Column(
                        children: groupedImages.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 95,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: entry.value.length,
                                  itemBuilder: (context, index) {
                                    final item = entry.value[index];

                                    String imgUrl = fixUrl(item["image"]);
                                    String id = item["id"].toString();

                                    return Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              openViewer(entry.value, index),
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: buildImage(imgUrl),
                                          ),
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 10,
                                          child: GestureDetector(
                                            onTap: () => confirmDelete(
                                              id: id,
                                              isRoom: true,
                                            ),
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageViewer extends StatefulWidget {
  final List images;
  final int initialIndex;

  const ImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialIndex);
  }

  String fixUrl(String url) {
    return url.replaceAll(r'\/', '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: PageView.builder(
        controller: controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          String imgUrl = fixUrl(widget.images[index]["image"]);

          return Center(child: Image.network(imgUrl, fit: BoxFit.contain));
        },
      ),
    );
  }
}
