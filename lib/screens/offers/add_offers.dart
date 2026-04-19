import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({super.key});

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  final TextEditingController title = TextEditingController();
  final TextEditingController discount = TextEditingController();
  final TextEditingController start = TextEditingController();
  final TextEditingController end = TextEditingController();
  final TextEditingController description = TextEditingController();

  List hotels = [];
  String? selectedHotelId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  @override
  void dispose() {
    title.dispose();
    discount.dispose();
    start.dispose();
    end.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> fetchHotels() async {
    try {
      var res = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_hotels.php"),
      );

      var data = jsonDecode(res.body);
      if (data['status'] == true) {
        setState(() {
          hotels = data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching hotels: $e");
      hotels = [];
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initialDate = DateTime.now();

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> saveOffer() async {
    if (selectedHotelId == null ||
        title.text.isEmpty ||
        discount.text.isEmpty ||
        start.text.isEmpty ||
        end.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    int discountValue = int.tryParse(discount.text) ?? 0;

    if (discountValue < 0 || discountValue > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Discount must be between 0 and 100")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      var res = await http.post(
        Uri.parse("https://prakrutitech.xyz/jiya/insert_offers.php"),
        body: {
          "hotel_id": selectedHotelId!,
          "title": title.text.trim(),
          "description": description.text.trim(),
          "discount_percent": discount.text.trim(),
          "start_date": start.text.trim(),
          "end_date": end.text.trim(),
        },
      );

      var data = jsonDecode(res.body);

      if (data['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Offer added successfully")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'] ?? "Error")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }

    setState(() => isLoading = false);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Offer"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedHotelId,
                decoration: _inputDecoration("Select Hotel"),
                hint: const Text("Select Hotel"),
                items: hotels.map<DropdownMenuItem<String>>((hotel) {
                  return DropdownMenuItem<String>(
                    value: hotel['id'].toString(),
                    child: Text(hotel['hotel_name'] ?? ""),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedHotelId = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              TextField(
                controller: title,
                decoration: _inputDecoration("Title"),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: description,
                decoration: _inputDecoration("Description"),
                maxLines: 3,
              ),

              const SizedBox(height: 12),

              TextField(
                controller: discount,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: _inputDecoration("Discount %"),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: start,
                readOnly: true,
                decoration: _inputDecoration(
                  "Start Date",
                ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
                onTap: () => _selectDate(context, start),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: end,
                readOnly: true,
                decoration: _inputDecoration(
                  "End Date",
                ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
                onTap: () => _selectDate(context, end),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveOffer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save Offer",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
