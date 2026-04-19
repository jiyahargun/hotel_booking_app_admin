import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddRoomImageScreen extends StatefulWidget {
  final String hotelId;

  const AddRoomImageScreen({super.key, required this.hotelId});

  @override
  State<AddRoomImageScreen> createState() => _AddRoomImageScreenState();
}

class _AddRoomImageScreenState extends State<AddRoomImageScreen> {
  File? image;

  List roomCategories = [];
  String? selectedRoomId;

  bool isLoading = false;
  bool isDataLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRoomCategories();
  }

  Future<void> fetchRoomCategories() async {
    try {
      final response = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_room_categories.php"),
      );

      final data = json.decode(response.body);

      if (data["status"] == true) {
        List all = data["data"];

        roomCategories = all.where((room) {
          return room["hotel_id"].toString() == widget.hotelId.toString();
        }).toList();
      }

      setState(() {
        isDataLoading = false;
      });
    } catch (e) {
      setState(() => isDataLoading = false);
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  Future<void> uploadImage() async {
    if (image == null || selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select category & image")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://prakrutitech.xyz/jiya/insert_rooms_images.php"),
      );

      request.fields["room_category_id"] = selectedRoomId!;

      request.files.add(
        await http.MultipartFile.fromPath("image", image!.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        throw Exception("Upload failed");
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: const Text("Add Room Image"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Room Category",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRoomId,
                        hint: const Text("Select category"),
                        isExpanded: true,
                        items: roomCategories.map((room) {
                          return DropdownMenuItem<String>(
                            value: room["id"].toString(),
                            child: Text(room["room_type"]),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedRoomId = value);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Room Image",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: image == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 45,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Tap to upload image",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                image!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F80ED),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : uploadImage,
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Upload Image",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
