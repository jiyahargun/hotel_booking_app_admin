import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/screens/offers/add_image_file.dart';
import 'package:http/http.dart' as http;

import 'add_offers.dart';
import 'update_offers.dart';

class OfferListScreen extends StatefulWidget {
  const OfferListScreen({Key? key}) : super(key: key);

  @override
  State<OfferListScreen> createState() => _OfferListScreenState();
}

class _OfferListScreenState extends State<OfferListScreen> {
  List<dynamic> offerList = [];
  Map<String, List<String>> offerImages = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("https://www.prakrutitech.xyz/jiya/view_offers.php"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true || data['code'] == 200) {
          offerList = data['data'] ?? [];
          await fetchOfferImages();
        } else {
          offerList = [];
        }
      }
    } catch (e) {
      debugPrint("Error fetching offers: $e");
      offerList = [];
    }

    setState(() => isLoading = false);
  }

  Future<void> fetchOfferImages() async {
    try {
      final response = await http.get(
        Uri.parse("https://www.prakrutitech.xyz/jiya/view_offers_images.php"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          Map<String, List<String>> tempImages = {};

          for (var img in data['data']) {
            String offerId = img['offer_id'].toString();

            // Clean URL if needed
            String imageUrl = img['image'].toString().replaceAll('\\', '');

            if (!tempImages.containsKey(offerId)) {
              tempImages[offerId] = [];
            }
            tempImages[offerId]!.add(imageUrl);
          }

          setState(() {
            offerImages = tempImages;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching images: $e");
      offerImages = {};
    }
  }

  Future<void> deleteOffer(String id) async {
    try {
      await http.post(
        Uri.parse("https://www.prakrutitech.xyz/jiya/delete_offers.php"),
        body: {"id": id},
      );
      fetchOffers();
    } catch (e) {
      debugPrint("Error deleting offer: $e");
    }
  }

  void _openFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageView(imageUrl: imageUrl),
      ),
    );
  }

  Widget buildOfferImages(String offerId) {
    final images = offerImages[offerId] ?? [];

    if (images.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Icon(Icons.image_not_supported, size: 40)),
      );
    }

    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = images[index];

          return GestureDetector(
            onTap: () => _openFullScreenImage(imageUrl),
            child: Hero(
              tag: imageUrl,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openAddImageScreen() async {
    if (offerList.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No offers available")));
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddOfferImageScreen(offers: offerList)),
    );

    if (result == true) {
      fetchOffers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offers"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            tooltip: "Add Offer Image",
            onPressed: _openAddImageScreen,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddOfferScreen()),
          );
          fetchOffers();
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : offerList.isEmpty
          ? const Center(child: Text("No Offers Found"))
          : RefreshIndicator(
              onRefresh: fetchOffers,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: offerList.length,
                itemBuilder: (context, index) {
                  final offer = offerList[index];
                  final offerId = offer['id'].toString();

                  return Dismissible(
                    key: Key(offerId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Confirmation"),
                          content: const Text(
                            "Are you sure you want to delete this offer?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) => deleteOffer(offerId),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildOfferImages(offerId),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    offer['title'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditOfferScreen(offer: offer),
                                      ),
                                    );
                                    fetchOffers();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text("Hotel: ${offer['hotel_name'] ?? ''}"),
                            Text("Discount: ${offer['discount_percent']}%"),
                            Text(
                              "${offer['start_date']} → ${offer['end_date']}",
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({Key? key, required this.imageUrl})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: imageUrl,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 60,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
