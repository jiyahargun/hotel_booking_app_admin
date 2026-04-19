import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../model/hotel_model.dart';

class EditHotelScreen extends StatefulWidget {
  final HotelModel hotel;

  const EditHotelScreen({super.key, required this.hotel});

  @override
  State<EditHotelScreen> createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends State<EditHotelScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController descriptionController;
  late TextEditingController ratingController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.hotel.name);
    addressController = TextEditingController(text: widget.hotel.address);
    descriptionController = TextEditingController(
      text: widget.hotel.description,
    );
    ratingController = TextEditingController(text: widget.hotel.rating);
  }

  Future<void> updateHotel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/update_hotels.php"),
      body: {
        "id": widget.hotel.id,
        "city_id": widget.hotel.cityId,
        "hotel_name": nameController.text,
        "address": addressController.text,
        "description": descriptionController.text,
        "rating": ratingController.text,
      },
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // refresh list
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Update Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Hotel")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Hotel Name"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),

              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Address"),
                validator: (v) => v!.isEmpty ? "Enter address" : null,
              ),

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),

              TextFormField(
                controller: ratingController,
                decoration: const InputDecoration(labelText: "Rating"),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateHotel,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update Hotel"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
