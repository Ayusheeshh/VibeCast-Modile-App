class WeatherModel {
  final String city;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final String summary;
  final String goOutside;
  final String outfit;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.summary,
    required this.goOutside,
    required this.outfit,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['city'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      condition: json['condition'] as String,
      humidity: json['humidity'] as int,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      summary: json['summary'] as String,
      goOutside: json['goOutside'] as String,
      outfit: json['outfit'] as String,
    );
  }
}
