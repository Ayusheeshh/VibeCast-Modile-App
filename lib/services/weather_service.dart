import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../constants.dart';

class WeatherService {

  // ── Current weather by city ──────────────────────────────────────────────
  Future<WeatherModel> fetchWeather(String city) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}/api/weather?city=${Uri.encodeComponent(city)}',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) return WeatherModel.fromJson(data);
    throw Exception(data['error'] ?? 'Something went wrong.');
  }

  // ── Current weather by GPS ───────────────────────────────────────────────
  Future<WeatherModel> fetchWeatherByCoords(double lat, double lon) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}/api/weather/coordinates?lat=$lat&lon=$lon',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) return WeatherModel.fromJson(data);
    throw Exception(data['error'] ?? 'Something went wrong.');
  }

  // ── Forecast by city ─────────────────────────────────────────────────────
  Future<ForecastModel> fetchForecast(String city) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}/api/forecast?city=${Uri.encodeComponent(city)}',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) return ForecastModel.fromJson(data);
    throw Exception(data['error'] ?? 'Forecast unavailable.');
  }

  // ── Forecast by GPS ──────────────────────────────────────────────────────
  Future<ForecastModel> fetchForecastByCoords(double lat, double lon) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}/api/forecast/coordinates?lat=$lat&lon=$lon',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) return ForecastModel.fromJson(data);
    throw Exception(data['error'] ?? 'Forecast unavailable.');
  }

  // ── Get device GPS position ──────────────────────────────────────────────
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Enable it in settings.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }
}
