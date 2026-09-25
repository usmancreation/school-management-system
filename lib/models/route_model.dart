class TransportRouteModel {
  final String id;
  final String routeName;
  final String startPoint;
  final String endPoint;
  final double monthlyFee;

  TransportRouteModel({
    required this.id,
    required this.routeName,
    required this.startPoint,
    required this.endPoint,
    required this.monthlyFee,
  });

  factory TransportRouteModel.fromJson(Map<String, dynamic> json) {
    return TransportRouteModel(
      id: json['id'] ?? '',
      routeName: json['route_name'] ?? '',
      startPoint: json['start_point'] ?? '',
      endPoint: json['end_point'] ?? '',
      monthlyFee: (json['monthly_fee'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
