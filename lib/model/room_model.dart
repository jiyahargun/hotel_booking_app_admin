class RoomModel {
  final String id;
  final String hotelId;
  final String roomType;
  final String price;
  final String totalRooms;
  final String availableRooms;
  final String description;
  final String roomStatus;

  RoomModel({
    required this.id,
    required this.hotelId,
    required this.roomType,
    required this.price,
    required this.totalRooms,
    required this.availableRooms,
    required this.description,
    required this.roomStatus,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      hotelId: json['hotel_id'],
      roomType: json['room_type'],
      price: json['price'],
      totalRooms: json['total_rooms'],
      availableRooms: json['available_rooms'],
      description: json['description'],
      roomStatus: json['room_status'],
    );
  }
}