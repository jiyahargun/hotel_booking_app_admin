class PaymentModel {
  final String paymentId;
  final String amount;
  final String paymentMethod;
  final String paymentStatusText;
  final String transactionId;
  final String createdAt;
  final String userName;
  final String hotelName;
  final String bookingId;

  PaymentModel({
    required this.paymentId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatusText,
    required this.transactionId,
    required this.createdAt,
    required this.userName,
    required this.hotelName,
    required this.bookingId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['payment_id'].toString(),
      amount: json['amount'].toString(),
      paymentMethod: json['payment_method'],
      paymentStatusText: json['payment_status_text'],
      transactionId: json['transaction_id'],
      createdAt: json['created_at'],
      userName: json['user_name'],
      hotelName: json['hotel_name'],
      bookingId: json['booking_id'].toString(),
    );
  }
}