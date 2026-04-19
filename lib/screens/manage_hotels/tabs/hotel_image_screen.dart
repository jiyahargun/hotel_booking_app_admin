import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class HotelImagesScreen extends StatefulWidget {
  final String hotelId;

  const HotelImagesScreen({super.key, required this.hotelId});

  @override
  State<HotelImagesScreen> createState() => _HotelImagesScreenState();
}

class _HotelImagesScreenState extends State<HotelImagesScreen> {
  List images = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("https://www.prakrutitech.xyz/jiya/view_hotel_images.php"),
      );

      final data = json.decode(response.body);

      List<dynamic> allImages = [];

      if (data is Map<String, dynamic> && data.containsKey("images")) {
        allImages = data["images"];
      } else if (data is List) {
        allImages = data;
      } else {
        allImages = [];
      }

      setState(() {
        images = allImages
            .where(
              (item) =>
                  item["hotel_id"].toString() == widget.hotelId.toString(),
            )
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print(" Fetch Images Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    File file = File(picked.path);

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("https://www.prakrutitech.xyz/jiya/insert_hotel_images.php"),
    );

    request.fields["hotel_id"] = widget.hotelId;
    request.files.add(await http.MultipartFile.fromPath("image", file.path));

    setState(() => isLoading = true);

    try {
      var response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Image Uploaded")));
        fetchImages();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Upload failed: $body")));
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Upload Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotel Images"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: pickAndUploadImage,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : images.isEmpty
          ? const Center(child: Text("No Images"))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                String imgUrl = images[index]["image"].toString().replaceAll(
                  r'\/',
                  '/',
                );

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
