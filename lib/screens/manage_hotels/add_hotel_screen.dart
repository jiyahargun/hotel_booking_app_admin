import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddHotelScreen extends StatefulWidget {
  const AddHotelScreen({super.key});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List cities = [];
  String? selectedCityId;

  String hotelStatus = "1";

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCities();
  }

  Future<void> loadCities() async {
    final response = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_city.php"),
    );

    var data = jsonDecode(response.body);

    setState(() {
      cities = data;
    });
  }

  Future<void> insertHotel() async {
    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        ratingController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedCityId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    var response = await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/insert_hotels.php"),
      body: {
        "hotel_name": nameController.text,
        "address": addressController.text,
        "rating": ratingController.text,
        "description": descriptionController.text,
        "city_id": selectedCityId!,
        "hotel_status": hotelStatus,
      },
    );

    print("INSERT HOTEL RESPONSE: ${response.body}");

    setState(() => isLoading = false);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Hotel")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Hotel Name"),
            ),

            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Rating"),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField(
              hint: const Text("Select City"),
              value: selectedCityId,
              items: cities.map<DropdownMenuItem<String>>((city) {
                return DropdownMenuItem(
                  value: city['id'].toString(),
                  child: Text(city['city_name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCityId = value.toString();
                });
              },
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                const Text("Status: "),
                Radio(
                  value: "1",
                  groupValue: hotelStatus,
                  onChanged: (val) {
                    setState(() {
                      hotelStatus = val.toString();
                    });
                  },
                ),
                const Text("Active"),
                Radio(
                  value: "0",
                  groupValue: hotelStatus,
                  onChanged: (val) {
                    setState(() {
                      hotelStatus = val.toString();
                    });
                  },
                ),
                const Text("Inactive"),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : insertHotel,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Hotel"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
