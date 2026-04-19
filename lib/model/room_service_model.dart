class RoomServiceModel {
  String id;
  String roomId;
  String roomType;
  String serviceId;
  String serviceName;

  RoomServiceModel({
    required this.id,
    required this.roomId,
    required this.roomType,
    required this.serviceId,
    required this.serviceName,
  });

  factory RoomServiceModel.fromJson(Map<String, dynamic> json) {
    return RoomServiceModel(
      id: json['id']?.toString() ?? "",
      roomId: json['room_id']?.toString() ?? "",
      roomType: json['room_type']?.toString() ?? "",
      serviceId: json['service_id']?.toString() ?? "",
      serviceName: json['service_name']?.toString() ?? "",
    );
  }
}