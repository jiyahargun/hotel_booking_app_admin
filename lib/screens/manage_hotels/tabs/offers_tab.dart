import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hotel_booking_admin/services/api_service.dart';

class OffersTab extends StatefulWidget {
  final String hotelName;

  const OffersTab({super.key, required this.hotelName});

  @override
  State<OffersTab> createState() => _OffersTabState();
}

class _OffersTabState extends State<OffersTab> {
  List<Map<String, dynamic>> offers = [];
  Map<String, String> offerImages = {};
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

      final filtered = data.where((offer) {
        final apiName = normalize((offer["hotel_name"] ?? "").toString());
        final uiName = normalize(widget.hotelName);
        return apiName == uiName;
      }).toList();

      setState(() {
        offers = List<Map<String, dynamic>>.from(filtered);
      });

      await fetchOfferImages();
    } catch (e) {
      debugPrint("ERROR: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchOfferImages() async {
    try {
      final response = await http.get(
        Uri.parse("https://www.prakrutitech.xyz/jiya/view_offers_images.php"),
      );

      final data = json.decode(response.body);

      if (data['status'] == true) {
        Map<String, String> tempImages = {};

        for (var img in data['data']) {
          String offerId = img['offer_id'].toString();

          // Clean URL if necessary
          String imageUrl = img['image'].toString().replaceAll('\\', '');

          // Only store the first image for each offer
          tempImages.putIfAbsent(offerId, () => imageUrl);
        }

        setState(() {
          offerImages = tempImages;
        });
      }
    } catch (e) {
      debugPrint("Image Fetch Error: $e");
    }
  }

  Future<void> toggleOfferStatus(String offerId, bool value, int index) async {
    setState(() {
      offers[index]["status"] = value ? "1" : "0";
    });

    try {
      final response = await http.post(
        Uri.parse("https://www.prakrutitech.xyz/jiya/toggle_offer_status.php"),
        body: {"id": offerId, "status": value ? "1" : "0"},
      );

      final data = json.decode(response.body);

      if (data["code"] != 200) {
        throw Exception("API failed");
      }
    } catch (e) {
      debugPrint("Toggle Error: $e");

      // Revert status if API fails
      setState(() {
        offers[index]["status"] = value ? "0" : "1";
      });
    }
  }

  /// 🔹 Build Offer Image Widget
  Widget buildOfferImage(String offerId) {
    final imageUrl = offerImages[offerId];

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 90,
            height: 90,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image),
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: 90,
            height: 90,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (offers.isEmpty) {
      return const Center(
        child: Text("No Offers Available", style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchOffers,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];

          String offerId = offer["id"].toString();
          String title = (offer["title"] ?? offer["offer_title"] ?? "Offer")
              .toString();

          String discount =
              (offer["discount_percent"] ?? offer["discount"] ?? "").toString();

          String start = (offer["start_date"] ?? "").toString();
          String end = (offer["end_date"] ?? "").toString();

          bool isActive = (offer["status"] ?? "1") == "1";

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  buildOfferImage(offerId),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "📅 $start → $end",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isActive ? "Active" : "Inactive",
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "$discount%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          value: isActive,
                          activeColor: Colors.green,
                          activeTrackColor: Colors.green.shade200,
                          inactiveThumbColor: Colors.orange,
                          inactiveTrackColor: Colors.orange.shade200,
                          onChanged: (value) {
                            toggleOfferStatus(offerId, value, index);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
