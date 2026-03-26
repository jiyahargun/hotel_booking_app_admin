class RecentBookingModel {
  final String hotelName;
  final String userName;
  final String checkIn;
  final String checkOut;
  final String amount;
  final String status;

  RecentBookingModel({
    required this.hotelName,
    required this.userName,
    required this.checkIn,
    required this.checkOut,
    required this.amount,
    required this.status,
  });

  factory RecentBookingModel.fromJson(Map<String, dynamic> json) {
    return RecentBookingModel(
      hotelName: json['hotel_name'] ?? "",
      userName: json['user_name'] ?? "",
      checkIn: json['check_in'] ?? "",
      checkOut: json['check_out'] ?? "",
      amount: json['amount'] ?? "",
      status: json['status'] ?? "",
    );
  }
}
