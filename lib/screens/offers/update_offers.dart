import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditOfferScreen extends StatefulWidget {
  final Map offer;

  const EditOfferScreen({super.key, required this.offer});

  @override
  State<EditOfferScreen> createState() => _EditOfferScreenState();
}

class _EditOfferScreenState extends State<EditOfferScreen> {
  late TextEditingController title;
  late TextEditingController discount;
  late TextEditingController start;
  late TextEditingController end;
  late TextEditingController description;

  List hotels = [];
  String? selectedHotelId;

  @override
  void initState() {
    super.initState();

    title = TextEditingController(text: widget.offer['title'] ?? "");
    discount = TextEditingController(
      text: widget.offer['discount_percent']?.toString() ?? "",
    );
    start = TextEditingController(text: widget.offer['start_date'] ?? "");
    end = TextEditingController(text: widget.offer['end_date'] ?? "");
    description = TextEditingController(
      text: widget.offer['description'] ?? "",
    );

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

  Future fetchHotels() async {
    try {
      var res = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_hotels.php"),
      );

      var data = jsonDecode(res.body);

      if (data['status'] == true) {
        setState(() {
          hotels = data['data'] ?? [];

          var match = hotels.firstWhere(
            (h) => h['hotel_name'] == widget.offer['hotel_name'],
            orElse: () => null,
          );

          if (match != null) {
            selectedHotelId = match['id'].toString();
          }
        });
      }
    } catch (e) {
      hotels = [];
    }
  }

  Future updateOffer() async {
    await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/update_offers.php"),
      body: {
        "id": widget.offer['id'].toString(),
        "hotel_id": selectedHotelId ?? "",
        "title": title.text,
        "description": description.text,
        "discount_percent": discount.text,
        "start_date": start.text,
        "end_date": end.text,
      },
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Offer")),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedHotelId,
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

              const SizedBox(height: 10),

              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: "Title"),
              ),

              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: "Description"),
              ),

              TextField(
                controller: discount,
                decoration: const InputDecoration(
                  labelText: "Discount Percent",
                ),
                keyboardType: TextInputType.number,
              ),

              TextField(
                controller: start,
                decoration: const InputDecoration(labelText: "Start Date"),
              ),

              TextField(
                controller: end,
                decoration: const InputDecoration(labelText: "End Date"),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateOffer,
                  child: const Text("Update Offer"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
