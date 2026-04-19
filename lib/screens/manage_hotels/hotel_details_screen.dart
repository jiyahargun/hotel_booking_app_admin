import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/tabs/fullscreen_gallary.dart';
import 'package:http/http.dart' as http;
import 'package:hotel_booking_admin/model/hotel_model.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/tabs/image_tab.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/tabs/room_tab.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/tabs/service_tab.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/tabs/offers_tab.dart';

class HotelDetailsScreen extends StatefulWidget {
  final HotelModel hotel;
  final String imageUrl;
  final List<String> imageList;

  const HotelDetailsScreen({
    super.key,
    required this.hotel,
    required this.imageUrl,
    required this.imageList,
  });

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  late HotelModel hotel;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    hotel = widget.hotel;
  }

  Future<void> toggleStatus() async {
    setState(() => isLoading = true);

    final newStatus = hotel.status == "1" ? "0" : "1";

    final url = Uri.parse(
      "https://prakrutitech.xyz/jiya/toggle_hotels_status.php?hotel_id=${hotel.id}&status=$newStatus",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          hotel = hotel.copyWith(status: newStatus);
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == "1" ? "Hotel Activated" : "Hotel Deactivated",
            ),
          ),
        );
      } else {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("API Error")));
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String hotelId = hotel.id;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(title: Text(hotel.name), centerTitle: true),

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: widget.imageList.isEmpty
                  ? Container(
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.hotel, size: 60),
                    )
                  : PageView.builder(
                      itemCount: widget.imageList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenGallery(
                                  images: widget.imageList,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            widget.imageList[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hotel.address,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      Text(
                        hotel.status == "1" ? "Active" : "Off",
                        style: TextStyle(
                          color: hotel.status == "1"
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Switch(
                        value: hotel.status == "1",
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.orange,
                        onChanged: (value) {
                          toggleStatus();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: "Rooms"),
                Tab(text: "Services"),
                Tab(text: "Offers"),
                Tab(text: "Images"),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  RoomsTab(hotelId: hotelId),
                  HotelServiceScreen(hotelName: hotel.name),
                  OffersTab(hotelName: hotel.name),
                  ImagesTab(hotelId: hotelId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
