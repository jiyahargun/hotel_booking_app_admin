import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/drawer/manage_hotel.dart';
import '../services/api_services.dart';
import '../model/dashboard_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ApiService apiService = ApiService();

  int selectedIndex = 0;

  bool isCityEnabled = false;
  bool isHotelEnabled = false;

  late Future<DashboardModel> dashboardFuture;
  late Future<List<RecentBooking>> recentBookingsFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = apiService.fetchDashboard();
    recentBookingsFuture = apiService.fetchRecentBookings();
  }

  // 🔹 Drawer Item (🔥 NAVIGATION FIXED)
  Widget drawerItem(IconData icon, String title, int index) {
    bool isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(context);

          if (index == 1) {
            // 🔥 Manage Hotels Screen OPEN
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManageHotelDetailsScreen(),
              ),
            );
          } else {
            setState(() {
              selectedIndex = index;
            });
          }
        },
      ),
    );
  }

  // 🔹 Switch Item
  Widget switchItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Switch(
        value: title == "Add City" ? isCityEnabled : isHotelEnabled,
        onChanged: (value) {
          setState(() {
            if (title == "Add City") {
              isCityEnabled = value;
            } else {
              isHotelEnabled = value;
            }
          });
        },
      ),
    );
  }

  // 🔹 Dashboard Card
  Widget buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // 🔹 Hotel List
  Widget buildHotelList() {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          hotelCard(
            image: "https://images.unsplash.com/photo-1566073771259-6a8506099945",
            name: "Hotel Green Land",
            rooms: "25 Rooms",
            payment: "Enabled",
          ),
          hotelCard(
            image: "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa",
            name: "Grand Palace",
            rooms: "40 Rooms",
            payment: "First Booking Done",
          ),
        ],
      ),
    );
  }

  Widget hotelCard({
    required String image,
    required String name,
    required String rooms,
    required String payment,
  }) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(image, height: 100, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("$rooms | Online Payments:"),
                  Text(payment, style: const TextStyle(color: Colors.green)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 🔥 Recent Booking UI
  Widget recentBookingCard({
    required String name,
    required String room,
    required String checkIn,
    required String status,
  }) {
    Color color = status.toLowerCase() == "confirmed" ? Colors.green : Colors.red;

    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text("Room: $room\nCheck-In: $checkIn"),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
          child: Text(status, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget buildRecentBookings() {
    return FutureBuilder<List<RecentBooking>>(
      future: recentBookingsFuture,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Text("No bookings");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recent Bookings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ...snapshot.data!.map((e) => recentBookingCard(
              name: e.name,
              room: e.roomType,
              checkIn: e.checkIn,
              status: e.status,
            ))
          ],
        );
      },
    );
  }

  // 🔥 Dashboard
  Widget buildDashboard() {
    return FutureBuilder<DashboardModel>(
      future: dashboardFuture,
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildCard("Hotels", data.totalHotels.toString(), Icons.hotel, Colors.blue),
                  buildCard("Rooms", data.totalRooms.toString(), Icons.bed, Colors.indigo),
                  buildCard("Bookings", data.newBookings.toString(), Icons.book, Colors.orange),
                  buildCard("Earnings", "₹${data.earnings}", Icons.currency_rupee, Colors.green),
                ],
              ),

              const SizedBox(height: 20),
              buildHotelList(),
              const SizedBox(height: 20),
              buildRecentBookings(),
            ],
          ),
        );
      },
    );
  }

  // 🔥 Body
  Widget buildBody() {
    return buildDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),

      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
            ),
          ),
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.only(top: 50, left: 16, bottom: 20),
                child: Row(
                  children: const [
                    CircleAvatar(radius: 28),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Admin Panel", style: TextStyle(color: Colors.white)),
                        Text("admin@example.com", style: TextStyle(color: Colors.white70)),
                      ],
                    )
                  ],
                ),
              ),

              const Divider(color: Colors.white30),

              Expanded(
                child: ListView(
                  children: [
                    drawerItem(Icons.dashboard, "Dashboard", 0),
                    drawerItem(Icons.hotel, "Manage Hotels", 1),

                    const Divider(color: Colors.white30),

                    switchItem(Icons.add, "Add City"),
                    switchItem(Icons.add_business, "Add Hotel"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),

      body: buildBody(),
    );
  }
}