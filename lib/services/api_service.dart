import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:hotel_booking_admin/model/RecentBookingModel.dart';
import '../model/dashboard_model.dart';
import '../model/hotel_model.dart';
import '../model/hotel_image_model.dart';
import '../model/room_model.dart';

class ApiService {

  // ================= DASHBOARD =================
  static Future<DashboardModel?> getDashboardDataWithNoCache() async {
    final response = await http.get(
      Uri.parse(
        "https://prakrutitech.xyz/jiya/view_dashboard_status.php?time=${DateTime.now().millisecondsSinceEpoch}",
      ),
    );

    print("DASHBOARD API: ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return DashboardModel.fromJson(data['data']);
    }
    return null;
  }

  // ================= HOTELS =================
  static Future<List<HotelModel>> getHotels() async {
    final response = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_hotels.php"),
    );

    print("HOTELS API: ${response.body}");

    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body);

      List data = decoded is List ? decoded : decoded['data'];

      return data.map((e) => HotelModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load hotels");
    }
  }

  // ================= HOTEL IMAGES =================
  static Future<List<HotelImageModel>> getHotelImages() async {
    final response = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_hotel_images.php"),
    );

    print("IMAGES API: ${response.body}");

    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body);

      List data = decoded is List ? decoded : decoded['data'];

      return data.map((e) => HotelImageModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load images");
    }
  }

  // ================= RECENT BOOKINGS =================
  static Future<List<RecentBookingModel>> getRecentBookings() async {
    try {
      final response = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_recent_booking.php"),
      );

      print("RECENT BOOKINGS API: ${response.body}");

      if (response.statusCode == 200) {
        var decoded = jsonDecode(response.body);

        List data = decoded is List ? decoded : decoded['data'];

        return data.map((e) => RecentBookingModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("RECENT BOOKING ERROR: $e");
      return [];
    }
  }

  // ================= ROOM CATEGORIES =================
  static Future<List<RoomModel>> getRoomCategories(String hotelId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://prakrutitech.xyz/jiya/view_room_categories.php?hotel_id=$hotelId",
        ),
      );

      print("📡 STATUS: ${response.statusCode}");
      print("📡 RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData["status"] == true) {
          List data = jsonData["data"];
          return data.map((e) => RoomModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      print("❌ API ERROR: $e");
      return [];
    }
  }

  // ================= SERVICES =================
  static Future<List<String>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_service.php"),
      );

      print("📡 SERVICES API: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData["status"] == true) {
          List data = jsonData["data"];

          return data
              .map<String>((e) => e["service_name"].toString())
              .toList();
        }
      }

      return [];
    } catch (e) {
      print("❌ SERVICES ERROR: $e");
      return [];
    }
  }

  // ================= OFFERS =================
  static Future<List<Map<String, dynamic>>> getOffers() async {
    try {
      final response = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_offers.php"),
      );

      print("📡 OFFERS API: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData["code"] == 200) {
          List data = jsonData["data"];
          return List<Map<String, dynamic>>.from(data);
        }
      }

      return [];
    } catch (e) {
      print("❌ OFFERS ERROR: $e");
      return [];
    }
  }
}