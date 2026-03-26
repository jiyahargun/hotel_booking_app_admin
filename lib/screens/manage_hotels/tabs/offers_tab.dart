import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/services/api_service.dart';

class OffersTab extends StatefulWidget {
  final String hotelName;

  const OffersTab({super.key, required this.hotelName});

  @override
  State<OffersTab> createState() => _OffersTabState();
}

class _OffersTabState extends State<OffersTab> {
  List<Map<String, dynamic>> offers = [];
  bool isLoading = true;

  String normalize(String text) {
    return text.toLowerCase().replaceAll("_", "").replaceAll(" ", "").trim();
  }

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    try {
      final data = await ApiService.getOffers();

      print("📌 HOTEL NAME: ${widget.hotelName}");

      final filtered = data.where((offer) {
        final apiName = normalize(offer["hotel_name"].toString());
        final uiName = normalize(widget.hotelName);

        return apiName == uiName;
      }).toList();

      print("FILTERED OFFERS: ${filtered.length}");

      setState(() {
        offers = filtered;
        isLoading = false;
      });
    } catch (e) {
      print(" ERROR: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (offers.isEmpty) {
      return const Center(child: Text("No Offers Available ❌"));
    }

    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];

        String title = offer["title"] ?? "";
        String discount = offer["discount_percent"] ?? "";
        String start = offer["start_date"] ?? "";
        String end = offer["end_date"] ?? "";

        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            title: Text(title.toUpperCase()),
            subtitle: Text("Discount: $discount\n$start → $end"),
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                discount,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
