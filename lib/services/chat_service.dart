import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/chat_message.dart';
import '../constants.dart';

class ChatService {
  Future<String> sendMessage({
    required String message,
    required WeatherModel weather,
    required List<ChatMessage> history,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/api/chat');

    final body = jsonEncode({
      'message': message,
      'city': weather.city,
      'temperature': weather.temperature,
      'feelsLike': weather.feelsLike,
      'condition': weather.condition,
      'humidity': weather.humidity,
      'windSpeed': weather.windSpeed,
      'goOutside': weather.goOutside,
      'outfit': weather.outfit,
      'history': history.map((m) => m.toHistoryMap()).toList(),
    });

    final response = await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: body)
        .timeout(const Duration(seconds: 20));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) return data['reply'] as String;
    throw Exception(data['error'] ?? 'Chat failed.');
  }
}
