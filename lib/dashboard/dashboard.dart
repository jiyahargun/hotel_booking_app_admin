import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  final String username;

  const HomeScreen({
    super.key,
    required this.email,
    required this.username,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAddCity = false;
  bool isAddHotel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${widget.username}"),
        backgroundColor: Colors.blueGrey.shade800,
      ),

      /// 🔥 DRAWER
      drawer: Drawer(
        child: Container(
          color: Colors.blueGrey.shade900,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              /// HEADER
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800,
                ),
                accountName: const SizedBox(),
                accountEmail: Text(
                  widget.email, // ✅ only email
                  style: const TextStyle(fontSize: 16),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40),
                ),
              ),

              drawerItem(Icons.dashboard, "Dashboard"),
              drawerItem(Icons.hotel, "Manage Hotels"),
              drawerItem(Icons.meeting_room, "Room Categories"),
              drawerItem(Icons.local_offer, "Offers & Discounts"),
              drawerItem(Icons.payment, "Payment Settings"),

              ListTile(
                leading: const Icon(Icons.star, color: Colors.white),
                title: const Text("Reviews Control",
                    style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),

              drawerItem(Icons.history, "Booking History"),

              const Divider(color: Colors.white54),

              /// SWITCHES
              SwitchListTile(
                value: isAddCity,
                activeColor: Colors.blue,
                title: const Text("Add City",
                    style: TextStyle(color: Colors.white)),
                onChanged: (val) {
                  setState(() {
                    isAddCity = val;
                  });
                },
              ),

              SwitchListTile(
                value: isAddHotel,
                activeColor: Colors.blue,
                title: const Text("Add Hotel",
                    style: TextStyle(color: Colors.white)),
                onChanged: (val) {
                  setState(() {
                    isAddHotel = val;
                  });
                },
              ),

              const Divider(color: Colors.white54),

              /// LOGOUT
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text("Log Out",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),

      /// 🔥 BODY
      body: Center(
        child: Text(
          "Welcome ${widget.username}", // ✅ username here
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  /// COMMON ITEM
  Widget drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {},
    );
  }
}