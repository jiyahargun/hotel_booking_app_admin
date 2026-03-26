class HotelImageModel {
  final String hotelId;
  final String image;

  HotelImageModel({required this.hotelId, required this.image});

  factory HotelImageModel.fromJson(Map<String, dynamic> json) {
    return HotelImageModel(
      hotelId: json['hotel_id']?.toString() ?? "",
      image: json['image'] ?? "",
    );
  }
}
