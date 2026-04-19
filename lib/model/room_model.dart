class RoomModel {
  final String id;
  final String hotelId;
  final String roomType;
  final String price;
  final String totalRooms;
  final String availableRooms;
  final String description;
  final String roomStatus;

  final List<String> images;

  RoomModel({
    required this.id,
    required this.hotelId,
    required this.roomType,
    required this.price,
    required this.totalRooms,
    required this.availableRooms,
    required this.description,
    required this.roomStatus,
    required this.images,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'].toString(),
      hotelId: json['hotel_id'].toString(),
      roomType: json['room_type'] ?? '',
      price: json['price'].toString(),
      totalRooms: json['total_rooms'].toString(),
      availableRooms: json['available_rooms'].toString(),
      description: json['description'] ?? '',
      roomStatus: json['room_status'] ?? '',

      images: [],
    );
  }
}