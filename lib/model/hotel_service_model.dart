class HotelServiceModel {
  final String hotelId;
  final String serviceId;
  final String serviceName;

  HotelServiceModel({
    required this.hotelId,
    required this.serviceId,
    required this.serviceName,
  });

  factory HotelServiceModel.fromJson(Map<String, dynamic> json) {
    return HotelServiceModel(
      hotelId: json['hotel_id'].toString(),
      serviceId: json['service_id'].toString(),
      serviceName: json['service_name'] ?? '',
    );
  }
}