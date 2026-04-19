class RoomImageModel {
  final String id;
  final String roomCategoryId;
  final String image;

  RoomImageModel({
    required this.id,
    required this.roomCategoryId,
    required this.image,
  });

  factory RoomImageModel.fromJson(Map<String, dynamic> json) {
    return RoomImageModel(
      id: json['id']?.toString() ?? "",
      roomCategoryId: json['room_category_id']?.toString() ?? "",
      image: json['image']?.toString() ?? "",
    );
  }
}