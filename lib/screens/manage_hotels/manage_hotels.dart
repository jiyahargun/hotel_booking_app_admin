import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/screens/add_image_screen.dart';
import '../../services/api_service.dart';
import '../../model/hotel_model.dart';
import '../../model/hotel_image_model.dart';
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
      for (var img in imageData) {
        if (img.hotelId.isNotEmpty && img.hotelId != "0") {
          hotelImageMap[img.hotelId] = img.image;
        }
      }

      setState(() {
        hotels = hotelData;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
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

  Widget buildStars(String ratingStr) {
    double rating = double.tryParse(ratingStr) ?? 0;

    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating.floor() ? Icons.star : Icons.star_border,
              color: Colors.orange,
              size: 16,
            );
          }),
        ),
        const SizedBox(width: 5),
        Text("($ratingStr)", style: const TextStyle(fontSize: 12)),
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

              if (result == true) {
                loadData();
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddHotelScreen()),
              );

              if (result == true) {
                loadData();
              }
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

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HotelDetailsScreen(
                            hotel: hotel,
                            imageUrl: imageUrl,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
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
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.broken_image),
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
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                buildStars(hotel.rating),

                                const SizedBox(height: 6),

                                Text(
                                  hotel.address,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  cityMap[hotel.cityId] ?? "Unknown City",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
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
