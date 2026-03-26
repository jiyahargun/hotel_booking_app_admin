import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/dashboard/dashboard.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/manage_hotels.dart';

class AppDrawer extends StatelessWidget {
  final String email;
  final String username;

  const AppDrawer({super.key, required this.email, required this.username});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              accountName: Text(username),
              accountEmail: Text(email),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 30, color: Colors.black),
              ),
            ),

            drawerItem(Icons.dashboard_customize_outlined, "Dashboard", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DashboardScreen(email: email, username: username),
                ),
              );
            }),
            drawerItem(Icons.hotel, "Manage Hotels", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ManageHotelsScreen()),
              );
            }),
            drawerItem(Icons.bed, "Room Categories", () {}),
            drawerItem(Icons.local_offer, "Offers & Discounts", () {}),
            drawerItem(Icons.payment, "Payment Settings", () {}),
            drawerItem(Icons.star, "Reviews Control", () {}),
            drawerItem(Icons.history, "Booking History", () {}),

            const Divider(color: Colors.white30),

            drawerItem(Icons.location_city, "Add City", () {}),
            drawerItem(Icons.add_business, "Add Hotel", () {}),

            const Spacer(),

            drawerItem(Icons.logout, "Log Out", () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      hoverColor: Colors.white10,
    );
  }
}
