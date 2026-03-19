import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/dashboard_model.dart';

class ApiService {

  // 🔹 Dashboard API
  static const String dashboardUrl =
      "https://prakrutitech.xyz/jiya/view_dashboard_status.php";

  // 🔹 Recent Booking API
  static const String recentBookingUrl =
      "https://prakrutitech.xyz/jiya/view_recent_booking.php";

  // 🔹 Hotels API (👉 apni actual API lagana)
  static const String hotelsUrl =
      "https://prakrutitech.xyz/jiya/view_hotels.php";


  // 🔥 DASHBOARD API
  Future<DashboardModel> fetchDashboard() async {
    try {
      final response = await http.get(Uri.parse(dashboardUrl));

      print("DASHBOARD API RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final data = jsonData is Map && jsonData.containsKey('data')
            ? jsonData['data']
            : jsonData;

        return DashboardModel.fromJson(data);
      } else {
        throw Exception("Dashboard API Error: ${response.statusCode}");
      }

    } catch (e) {
      throw Exception("Dashboard Exception: $e");
    }
  }


  // 🔥 RECENT BOOKINGS API
  Future<List<RecentBooking>> fetchRecentBookings() async {
    try {
      final response = await http.get(Uri.parse(recentBookingUrl));

      print("RECENT BOOKING API RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final data = jsonData is Map && jsonData.containsKey('data')
            ? jsonData['data']
            : jsonData;

        if (data is List) {
          return data.map((e) {
            return RecentBooking(
              name: e['name'] ?? "",
              roomType: e['room_type'] ?? "",
              checkIn: e['check_in'] ?? "",
              status: e['status'] ?? "",
            );
          }).toList();
        } else {
          throw Exception("Invalid format: Not a list");
        }

      } else {
        throw Exception("Recent Booking API Error: ${response.statusCode}");
      }

    } catch (e) {
      throw Exception("Recent Booking Exception: $e");
    }
  }


  // 🔥 HOTELS API (FIXED)
  Future<List<HotelModel>> fetchHotels() async {
    try {
      final response = await http.get(Uri.parse(hotelsUrl));

      print("HOTELS API RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final data = jsonData is Map && jsonData.containsKey('data')
            ? jsonData['data']
            : jsonData;

        if (data is List) {
          return data.map<HotelModel>((e) {
            return HotelModel.fromJson(e);
          }).toList();
        } else {
          throw Exception("Invalid format: Not a list");
        }

      } else {
        throw Exception("Hotels API Error: ${response.statusCode}");
      }

    } catch (e) {
      throw Exception("Hotels Exception: $e");
    }
  }
}