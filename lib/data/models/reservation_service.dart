class ReservationService {
  final String serviceId;
  final String name;
  final double price;
  final int duration;

  const ReservationService({
    required this.serviceId,
    required this.name,
    required this.price,
    required this.duration,
  });

  factory ReservationService.fromJson(Map<String, dynamic> data) {
    return ReservationService(
      serviceId: data['service_id'] as String,
      name: data['name'] as String,
      price: double.parse(data['price'].toString()),
      duration: int.parse(data['duration_in_min'].toString()),
    );
  }
}
