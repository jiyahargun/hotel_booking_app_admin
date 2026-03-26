import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddHotelImageScreen extends StatefulWidget {
  const AddHotelImageScreen({super.key});

  @override
  State<AddHotelImageScreen> createState() => _AddHotelImageScreenState();
}

class _AddHotelImageScreenState extends State<AddHotelImageScreen> {
  List hotels = [];
  String? selectedHotelId;
  File? imageFile;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadHotels();
  }

  Future<void> loadHotels() async {
    try {
      final res = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_hotels.php"),
      );

      var decoded = jsonDecode(res.body);

      List data = decoded is List ? decoded : decoded['data'];

      setState(() {
        hotels = data;
      });
    } catch (e) {
      print("HOTEL LOAD ERROR: $e");
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> pickFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> uploadImage() async {
    if (selectedHotelId == null || imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select hotel & image")));
      return;
    }

    try {
      setState(() => isLoading = true);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://prakrutitech.xyz/jiya/insert_hotel_images.php"),
      );

      request.fields['hotel_id'] = selectedHotelId!;

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile!.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Image Uploaded")));

        Navigator.pop(context, true);
      } else {
        throw Exception("Upload failed");
      }
    } catch (e) {
      print("UPLOAD ERROR: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload Error")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Hotel Image")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              hint: const Text("Select Hotel"),
              value: selectedHotelId,
              items: hotels.map<DropdownMenuItem<String>>((hotel) {
                return DropdownMenuItem(
                  value: hotel['id'].toString(),
                  child: Text(hotel['hotel_name']),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedHotelId = val;
                });
              },
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text("Gallery"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  imageFile!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : uploadImage,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Upload Image"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
