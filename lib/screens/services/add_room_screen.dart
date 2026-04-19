import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  List hotels = [];
  List categories = [];

  String? selectedHotelId;
  String? selectedCategoryId;

  TextEditingController roomNumberController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchHotels();
    fetchCategories();
  }

  Future<void> fetchHotels() async {
    try {
      final res = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_hotels.php"),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          hotels = (data != null && data['data'] != null) ? data['data'] : [];
        });
      }
    } catch (e) {
      print(" Hotel API Error: $e");
    }
  }

  Future<void> fetchCategories() async {
    try {
      final res = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_room_categories.php"),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          categories = (data != null && data['data'] != null)
              ? data['data']
              : [];
        });
      }
    } catch (e) {
      print("Category API Error: $e");
    }
  }

  Future<void> insertRoom() async {
    if (selectedHotelId == null ||
        selectedCategoryId == null ||
        roomNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields required")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/jiya/insert_rooms.php"),
        body: {
          "hotel_id": selectedHotelId ?? "",
          "room_category_id": selectedCategoryId ?? "",
          "room_number": roomNumberController.text.trim(),
        },
      );

      final data = json.decode(response.body);
      setState(() => isLoading = false);

      if (data != null && data['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Room Added Successfully")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to add room")));
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Insert Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  String getHotelName(dynamic hotel) {
    return hotel['name'] ?? hotel['hotel_name'] ?? hotel['title'] ?? "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Room")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedHotelId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Select Hotel",
                border: OutlineInputBorder(),
              ),
              items: hotels.map<DropdownMenuItem<String>>((hotel) {
                return DropdownMenuItem(
                  value: hotel['id']?.toString(),
                  child: Text(getHotelName(hotel)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedHotelId = value;
                });
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedCategoryId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Select Room Category",
                border: OutlineInputBorder(),
              ),
              items: categories.map<DropdownMenuItem<String>>((cat) {
                return DropdownMenuItem(
                  value: cat['id']?.toString(),
                  child: Text(cat['room_type'] ?? "Unknown"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: roomNumberController,
              decoration: const InputDecoration(
                labelText: "Room Number",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : insertRoom,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Add Room"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
