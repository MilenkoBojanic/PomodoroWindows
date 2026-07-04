class UserVehicle {
  final String name;
  final String color;
  final String vehicleTypeId;

  const UserVehicle({
    required this.name,
    required this.color,
    required this.vehicleTypeId,
  });

  factory UserVehicle.fromJson(Map<String, dynamic> data) {
    return UserVehicle(
      name: data['name'] as String,
      color: data['color'] as String,
      vehicleTypeId: data['vehicle_type_id'] as String,
    );
  }
}
