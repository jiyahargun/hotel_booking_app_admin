import 'package:flutter/material.dart';
import '../drawer/app_drawer.dart';
import '../services/api_service.dart';
import '../model/dashboard_model.dart';
import '../model/hotel_model.dart';
import '../model/hotel_image_model.dart';
import '../model/RecentBookingModel.dart';

class DashboardScreen extends StatefulWidget {
  final String email;
  final String username;

  const DashboardScreen({
    super.key,
    required this.email,
    required this.username,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardModel? dashboardData;
  bool isLoading = true;

  List<HotelModel> hotels = [];
  List<HotelImageModel> images = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    var dashboard = await ApiService.getDashboardDataWithNoCache();
    var hotelList = await ApiService.getHotels();
    var imageList = await ApiService.getHotelImages();

    if (!mounted) return;

    setState(() {
      dashboardData = dashboard;
      hotels = hotelList;
      images = imageList;
      isLoading = false;
    });
  }

  String getHotelImage(String hotelId) {
    try {
      return images.firstWhere((img) => img.hotelId == hotelId).image;
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,

        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadData),
        ],
      ),

      drawer: AppDrawer(email: widget.email, username: widget.username),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardData == null
          ? const Center(child: Text("No Data Found"))
          : RefreshIndicator(
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome @${widget.username}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Overview",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        dashboardCard(
                          title: "Total Hotels",
                          value: dashboardData!.totalHotels.toString(),
                          icon: Icons.hotel,
                          color: Colors.blue.shade700,
                        ),
                        dashboardCard(
                          title: "Total Rooms",
                          value: dashboardData!.totalRooms.toString(),
                          icon: Icons.bed,
                          color: Colors.deepPurple,
                        ),
                        dashboardCard(
                          title: "New Bookings",
                          value: dashboardData!.newBookings.toString(),
                          icon: Icons.calendar_month,
                          color: Colors.green.shade700,
                        ),
                        dashboardCard(
                          title: "Earnings",
                          value: "₹${dashboardData!.earnings}",
                          icon: Icons.currency_rupee,
                          color: Colors.orange.shade800,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Hotels",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 210,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hotels.length,
                        itemBuilder: (context, index) {
                          final hotel = hotels[index];
                          final imageUrl = getHotelImage(hotel.id);

                          double rating =
                              double.tryParse(hotel.rating ?? "0") ?? 0;

                          return GestureDetector(
                            onTap: () {
                              print("Tapped: ${hotel.name}");
                            },
                            child: Container(
                              width: 230,
                              margin: const EdgeInsets.only(right: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            height: 130,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            height: 130,
                                            width: double.infinity,
                                            color: Colors.grey.shade300,
                                            child: const Icon(Icons.image),
                                          ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hotel.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            ...List.generate(5, (i) {
                                              if (i < rating.floor()) {
                                                return const Icon(
                                                  Icons.star,
                                                  color: Colors.orange,
                                                  size: 16,
                                                );
                                              } else if (i < rating &&
                                                  rating % 1 != 0) {
                                                return const Icon(
                                                  Icons.star_half,
                                                  color: Colors.orange,
                                                  size: 16,
                                                );
                                              } else {
                                                return const Icon(
                                                  Icons.star_border,
                                                  color: Colors.orange,
                                                  size: 16,
                                                );
                                              }
                                            }),
                                            const SizedBox(width: 6),
                                            Text(
                                              rating.toString(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
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

                    const SizedBox(height: 20),

                    const Text(
                      "Recent Bookings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    FutureBuilder<List<RecentBookingModel>>(
                      future: ApiService.getRecentBookings(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final bookings = snapshot.data!;

                        if (bookings.isEmpty) {
                          return const Text("No Recent Bookings");
                        }

                        return ListView.builder(
                          itemCount: bookings.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final booking = bookings[index];

                            String status = booking.status.toLowerCase();

                            Color statusColor;
                            String statusText;

                            if (status == "success") {
                              statusColor = Colors.green;
                              statusText = "Success";
                            } else if (status == "cancelled") {
                              statusColor = Colors.red;
                              statusText = "Cancelled";
                            } else {
                              statusColor = Colors.orange;
                              statusText = "Pending";
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.hotelName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "User: ${booking.userName}",
                                    style: const TextStyle(fontSize: 13),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "${booking.checkIn} → ${booking.checkOut}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "₹${booking.amount}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        statusText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
