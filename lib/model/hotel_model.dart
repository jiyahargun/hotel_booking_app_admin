class HotelModel {
  final String id;
  final String name;
  final String cityId;
  final String address;
  final String rating;

  HotelModel({
    required this.id,
    required this.name,
    required this.cityId,
    required this.address,
    required this.rating,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id']?.toString() ?? "",
      name: json['hotel_name'] ?? "",
      cityId: json['city_id']?.toString() ?? "",
      address: json['address'] ?? "",
      rating: json['rating'] ?? "",
    );
  }
}
