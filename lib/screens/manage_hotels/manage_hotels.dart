import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/add_image_screen.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/edit_hotels.dart';
import '../../services/api_service.dart';
import '../../model/hotel_model.dart';
import 'hotel_details_screen.dart';
import 'add_hotel_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ManageHotelsScreen extends StatefulWidget {
  const ManageHotelsScreen({super.key});

  @override
  State<ManageHotelsScreen> createState() => _ManageHotelsScreenState();
}

class _ManageHotelsScreenState extends State<ManageHotelsScreen> {
  List<HotelModel> hotels = [];
  Map<String, String> hotelImageMap = {};

  Map<String, List<String>> hotelImagesMap = {};

  Map<String, String> cityMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() => isLoading = true);

      final hotelData = await ApiService.getHotels();
      final imageData = await ApiService.getHotelImages();

      await loadCities();

      hotelImageMap.clear();
      hotelImagesMap.clear();

      for (var img in imageData) {
        if (img.hotelId.isNotEmpty && img.hotelId != "0") {
          if (!hotelImageMap.containsKey(img.hotelId)) {
            hotelImageMap[img.hotelId] = img.image;
          }

          if (!hotelImagesMap.containsKey(img.hotelId)) {
            hotelImagesMap[img.hotelId] = [];
          }
          hotelImagesMap[img.hotelId]!.add(img.image);
        }
      }

      setState(() {
        hotels = hotelData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadCities() async {
    final response = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_city.php"),
    );

    var data = jsonDecode(response.body);

    cityMap.clear();
    for (var city in data) {
      cityMap[city['id'].toString()] = city['city_name'];
    }
  }

  Future<void> deleteHotel(String id) async {
    final response = await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/delete_hotels.php"),
      body: {"id": id},
    );

    if (response.statusCode == 200) {
      loadData();
    }
  }

  Widget buildStars(String ratingStr) {
    double rating = double.tryParse(ratingStr) ?? 0;

    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating.floor() ? Icons.star : Icons.star_border,
              color: Colors.orange,
              size: 14,
            );
          }),
        ),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Hotels"),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddHotelImageScreen()),
              );
              if (result == true) loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddHotelScreen()),
              );
              if (result == true) loadData();
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hotels.isEmpty
          ? const Center(child: Text("No Hotels Found"))
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView.builder(
                itemCount: hotels.length,
                itemBuilder: (context, index) {
                  final hotel = hotels[index];

                  String imageUrl =
                      hotelImageMap[hotel.id] ??
                      "https://via.placeholder.com/300x200.png?text=No+Image";

                  List<String> imageList = hotelImagesMap[hotel.id] ?? [];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HotelDetailsScreen(
                            hotel: hotel,
                            imageUrl: imageUrl,
                            imageList: imageList,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hotel.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                buildStars(hotel.rating),
                                const SizedBox(height: 4),
                                Text(
                                  hotel.address,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          cityMap[hotel.cityId] ??
                                              "Unknown City",
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2F6FED),
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(
                                                  0.4,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            onTap: () async {
                                              final result =
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          EditHotelScreen(
                                                            hotel: hotel,
                                                          ),
                                                    ),
                                                  );
                                              if (result == true) loadData();
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    "Edit",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE53935),
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red.withOpacity(
                                                  0.4,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text(
                                                    "Delete Hotel",
                                                  ),
                                                  content: const Text(
                                                    "Are you sure you want to delete this hotel?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        deleteHotel(hotel.id);
                                                      },
                                                      child: const Text(
                                                        "Delete",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
