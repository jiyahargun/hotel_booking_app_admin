import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddOfferImageScreen extends StatefulWidget {
  final List offers;

  const AddOfferImageScreen({Key? key, required this.offers}) : super(key: key);

  @override
  State<AddOfferImageScreen> createState() => _AddOfferImageScreenState();
}

class _AddOfferImageScreenState extends State<AddOfferImageScreen> {
  String? selectedOfferId;
  File? _image;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImage() async {
    if (selectedOfferId == null || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select offer and image")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://www.prakrutitech.xyz/jiya/insert_offer_images.php"),
      );

      request.fields['offer_id'] = selectedOfferId!;
      request.files.add(
        await http.MultipartFile.fromPath('image', _image!.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to upload image")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Offer Image")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Select Offer",
                border: OutlineInputBorder(),
              ),
              value: selectedOfferId,
              items: widget.offers.map<DropdownMenuItem<String>>((offer) {
                return DropdownMenuItem<String>(
                  value: offer['id'].toString(),
                  child: Text(offer['title']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedOfferId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image == null
                    ? const Center(child: Icon(Icons.add_a_photo, size: 50))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : uploadImage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Upload Image"),
            ),
          ],
        ),
      ),
    );
  }
}
