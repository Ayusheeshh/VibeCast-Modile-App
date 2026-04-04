class ForecastDay {
  final String day;
  final double minTemp;
  final double maxTemp;
  final String condition;

  ForecastDay({
    required this.day,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      day: json['day'] as String,
      minTemp: (json['minTemp'] as num).toDouble(),
      maxTemp: (json['maxTemp'] as num).toDouble(),
      condition: json['condition'] as String,
    );
  }
}

class ForecastModel {
  final String city;
  final List<ForecastDay> forecast;

  ForecastModel({required this.city, required this.forecast});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      city: json['city'] as String,
      forecast: (json['forecast'] as List)
          .map((d) => ForecastDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
