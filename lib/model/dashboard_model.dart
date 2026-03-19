class DashboardModel {
  final int totalHotels;
  final int totalRooms;
  final int newBookings;
  final int earnings;

  DashboardModel({
    required this.totalHotels,
    required this.totalRooms,
    required this.newBookings,
    required this.earnings,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalHotels: int.tryParse(json['total_hotels'].toString()) ?? 0,
      totalRooms: int.tryParse(json['total_rooms'].toString()) ?? 0,
      newBookings: int.tryParse(json['new_bookings'].toString()) ?? 0,
      earnings: int.tryParse(json['earnings'].toString()) ?? 0,
    );
  }
}


// 🔥 RECENT BOOKING MODEL (SAFE)
class RecentBooking {
  final String name;
  final String roomType;
  final String checkIn;
  final String status;

  RecentBooking({
    required this.name,
    required this.roomType,
    required this.checkIn,
    required this.status,
  });

  factory RecentBooking.fromJson(Map<String, dynamic> json) {
    return RecentBooking(
      name: json['name'] ?? "",
      roomType: json['room_type'] ?? "",
      checkIn: json['check_in'] ?? "",
      status: json['status'] ?? "",
    );
  }
}


// 🔥 HOTEL MODEL (SIMPLE + SAFE)
class HotelModel {
  final String name;

  HotelModel({required this.name});

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      name: json['hotel_name'] ?? "",
    );
  }
}