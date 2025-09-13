import 'dart:convert';
import 'package:http/http.dart' as http;
import 'energy_reading.dart';

class ApiService {
  static Future<List<EnergyReading>> fetchEnergyData() async {
    final response = await http.get(
      Uri.parse("https://4224e1bdc986.ngrok-free.app/latest?api_key=public-demo-key-2025"),
      headers: {
        "ngrok-skip-browser-warning": "true",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData
          .map((item) => EnergyReading.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Failed to load data");
    }
  }
}


