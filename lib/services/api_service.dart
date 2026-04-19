import 'dart:convert';
import 'package:hotel_booking_admin/model/hotel_service_model.dart';
import 'package:hotel_booking_admin/model/image_model.dart';
import 'package:hotel_booking_admin/model/payment_model.dart';
import 'package:hotel_booking_admin/model/room_service_model.dart';
import 'package:hotel_booking_admin/model/service_model.dart';
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
  static Future<List<ServiceModel>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_service.php"),
      );

      final jsonData = jsonDecode(response.body);

      if (jsonData["status"] == true) {
        List data = jsonData["data"];

        return data.map((e) => ServiceModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print("SERVICES ERROR: $e");
      return [];
    }
  }

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

  static Future<List<RoomImageModel>> getRoomImages() async {
    try {
      final response = await http.get(
        Uri.parse("https://prakrutitech.xyz/jiya/view_rooms_images.php"),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        List data = jsonData is List ? jsonData : jsonData['data'];

        return data.map((e) => RoomImageModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("ROOM IMAGE ERROR: $e");
    }

    return [];
  }

  static Future<List<RoomServiceModel>> getRoomServices(
    String roomId,
    String roomType,
  ) async {
    final response = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_room_service.php"),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == true) {
      List list = data['data'];

      List<RoomServiceModel> all = list
          .map((e) => RoomServiceModel.fromJson(e))
          .toList();

      List<RoomServiceModel> filtered = all
          .where((e) => e.roomId == roomId)
          .toList();

      if (filtered.isEmpty) {
        filtered = all
            .where(
              (e) =>
                  e.roomType.toLowerCase().trim() ==
                  roomType.toLowerCase().trim(),
            )
            .toList();
      }

      return filtered;
    }

    return [];
  }

  static Future<bool> addRoomService({
    required String roomId,
    required String serviceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("https://prakrutitech.xyz/jiya/insert_room_service.php"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"room_id": roomId.trim(), "service_id": serviceId.trim()},
      );

      print("ROOM_ID: $roomId");
      print("SERVICE_ID: $serviceId");
      print("RAW RESPONSE: ${response.body}");

      if (response.body.isEmpty) {
        print("EMPTY RESPONSE FROM SERVER");
        return false;
      }

      final data = jsonDecode(response.body);

      if (data['status'] == true) return true;

      /// duplicate bhi success treat
      if (data['message'].toString().toLowerCase().contains("already")) {
        return true;
      }

      return false;
    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }

  Future<String?> getHotelIdFromName(String name) async {
    var response = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_hotels.php"),
    );

    var data = jsonDecode(response.body);

    if (data['status'] == true) {
      for (var hotel in data['data']) {
        if (hotel['hotel_name'].toString().toLowerCase().trim() ==
            name.toLowerCase().trim()) {
          return hotel['id'].toString();
        }
      }
    }

    return null;
  }

  Future<void> updateService({
    required String id,
    required String hotelId,
    required String serviceId,
  }) async {
    var res = await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/update_hotel_service.php"),
      body: {"id": id, "hotel_id": hotelId, "service_id": serviceId},
    );

    var data = jsonDecode(res.body);

    print(data);
  }

  // Future<List<RoomCategoryModel>> getRoomCategoryList() async {
  //   try {
  //     final response = await http.get(Uri.parse(
  //         "https://www.prakrutitech.xyz/jiya/view_room_categories.php"));
  //
  //     print("ROOM CATEGORY API: ${response.body}");
  //
  //     final jsonData = jsonDecode(response.body);
  //
  //     if (jsonData['status'] == true) {
  //       List data = jsonData['data'];
  //       return data
  //           .map((e) => RoomCategoryModel.fromJson(e))
  //           .toList();
  //     }
  //   } catch (e) {
  //     print("ROOM CATEGORY ERROR: $e");
  //   }
  //
  //   return [];
  // }
  static Future<List<dynamic>> getRooms() async {
    final response = await http.get(
      Uri.parse("https://prakrutitech.xyz/jiya/view_rooms.php"),
    );

    if (response.body.isEmpty) return [];

    final data = jsonDecode(response.body);

    if (data['status'] == true) {
      return data['data'];
    }

    return [];
  }

  static Future<List<PaymentModel>> fetchPayments() async {
    final url = Uri.parse(
      "https://prakrutitech.xyz/jiya/admin_view_payments.php",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == true) {
        List list = data['data'];

        return list.map((e) => PaymentModel.fromJson(e)).toList();
      }
    }

    return [];
  }

  static Future<void> deleteRoomService(String id) async {
    final res = await http.post(
      Uri.parse("https://prakrutitech.xyz/jiya/delete_room_service.php"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"id": id},
    );

    print("DELETE RESPONSE: ${res.body}");
  }
}
