class DashboardModel {
  final int totalHotels;
  final int totalRooms;
  final int newBookings;
  final String earnings;

  DashboardModel({
    required this.totalHotels,
    required this.totalRooms,
    required this.newBookings,
    required this.earnings,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    print("JSON DATA: $json");

    return DashboardModel(
      totalHotels: int.tryParse(json['total_hotels'].toString()) ?? 0,

      totalRooms: int.tryParse(json['total_rooms'].toString()) ?? 0,

      newBookings:
          int.tryParse(json['new_bookings_this_month'].toString()) ?? 0,

      earnings: json['earnings_this_month'].toString(),
    );
  }
}
