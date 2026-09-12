import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service.dart';

class ServiceApi {
  final String baseUrl;
  ServiceApi({required this.baseUrl});

  Future<List<Service>> fetchServices() async {
    final response = await http.get(Uri.parse('$baseUrl/services'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Service.fromJson(json)).toList();
    }

    throw Exception('Erreur HTTP ${response.statusCode}');
  }
}