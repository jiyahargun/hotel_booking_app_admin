import 'package:flutter/material.dart';
import 'package:hotel_booking_admin/city_manage/hotel_city.dart';
import 'package:hotel_booking_admin/dashboard/dashboard.dart';
import 'package:hotel_booking_admin/screens/booking/booking_histroy.dart';
import 'package:hotel_booking_admin/screens/manage_hotels/manage_hotels.dart';
import 'package:hotel_booking_admin/login/admin_login.dart';
import 'package:hotel_booking_admin/screens/offers/offers_screen.dart';
import 'package:hotel_booking_admin/screens/payment/view_payment.dart';
import 'package:hotel_booking_admin/screens/review/review_control.dart';
import 'package:hotel_booking_admin/screens/room_categories/room_screen.dart';
import 'package:hotel_booking_admin/screens/services/services_screen.dart';

class AppDrawer extends StatelessWidget {
  final String email;
  final String username;

  const AppDrawer({super.key, required this.email, required this.username});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFF7F7F7),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _sectionTitle("MAIN"),

                  drawerItem(Icons.dashboard, "Dashboard", () {
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

                  drawerItem(Icons.room_service, "Services", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ServicesScreen()),
                    );
                  }),

                  drawerItem(Icons.bed, "Room Categories", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RoomScreen()),
                    );
                  }),

                  drawerItem(Icons.local_offer, "Offers & Discounts", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OfferListScreen(),
                      ),
                    );
                  }),

                  drawerItem(Icons.payment, "Payment Settings", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentScreen(),
                      ),
                    );
                  }),
                  drawerItem(Icons.star, "Reviews Control", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReviewListScreen(),
                      ),
                    );
                  }),

                  drawerItem(Icons.history, "Booking History", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BookingHistoryScreen()),
                    );
                  }),

                  const SizedBox(height: 16),
                  _sectionTitle("MANAGEMENT"),

                  drawerItem(Icons.location_city, "Add City", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddCityScreen()),
                    );
                  }),

                  const SizedBox(height: 20),
                  const Divider(thickness: 1, color: Colors.grey),

                  drawerItem(Icons.logout, "Log Out", () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Signinscreen()),
                      (route) => false,
                    );
                  }, isLogout: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4E54C8), Color(0xFF8F94FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF4E54C8), size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ================= UPDATED (NO CARD) =================
  Widget drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.redAccent : Colors.blue.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.redAccent : Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
