import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/model/hotel_model.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/tabs/room_tab.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/tabs/service_tab.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/tabs/offers_tab.dart';

class HotelDetailsScreen extends StatelessWidget {
  final HotelModel hotel;
  final String imageUrl;

  const HotelDetailsScreen({
    super.key,
    required this.hotel,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final String hotelId = hotel.id;

    print(" HOTEL ID: $hotelId");

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(title: Text(hotel.name)),

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isEmpty
                ? Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.hotel, size: 60),
                  )
                : Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
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

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Active",
                      style: TextStyle(color: Colors.white),
                    ),
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
                Tab(text: "Booking INFO"),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  RoomsTab(hotelId: hotelId),

                  const ServicesTab(),

                  OffersTab(hotelName: hotel.name),
                  const Center(child: Text("Images Data")),
                  const Center(child: Text("Booking INFO")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
