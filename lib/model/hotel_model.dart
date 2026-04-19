class HotelModel {
  final String id;
  final String name;
  final String cityId;
  final String address;
  final String rating;
  final String description;
  final String status;
  final String coverImage;

  HotelModel({
    required this.id,
    required this.name,
    required this.cityId,
    required this.address,
    required this.rating,
    required this.description,
    required this.status,
    required this.coverImage,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id']?.toString() ?? "",
      name: json['hotel_name'] ?? "",
      cityId: json['city_id']?.toString() ?? "",
      address: json['address'] ?? "",
      rating: json['rating'] ?? "",
      description: json['description'] ?? "",
      status: json['hotel_status']?.toString() ?? "1",

      coverImage: json['cover_image'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "hotel_name": name,
      "address": address,
      "rating": rating,
      "description": description,
      "city_id": cityId,
      "hotel_status": status,

      "cover_image": coverImage,
    };
  }

  HotelModel copyWith({
    String? id,
    String? name,
    String? cityId,
    String? address,
    String? rating,
    String? description,
    String? status,
    String? coverImage,
  }) {
    return HotelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cityId: cityId ?? this.cityId,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      status: status ?? this.status,
      coverImage: coverImage ?? this.coverImage,
    );
  }
}
