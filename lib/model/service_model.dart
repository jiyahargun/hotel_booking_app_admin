class ServiceModel {
  final String id;
  final String serviceName;

  ServiceModel({
    required this.id,
    required this.serviceName,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'].toString(),
      serviceName: json['service_name'],
    );
  }
}