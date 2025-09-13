class EnergyReading {
  final String meterId;
  final double consumption;
  final double carbon;
  final DateTime timestamp;

  EnergyReading({
    required this.meterId,
    required this.consumption,
    required this.carbon,
    required this.timestamp,
  });

  factory EnergyReading.fromJson(Map<String, dynamic> json) {
    return EnergyReading(
      meterId: json['meter_id'] as String,
      consumption: (json['consumption'] as num).toDouble(),
      carbon: (json['carbon'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}