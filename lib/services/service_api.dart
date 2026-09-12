import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/service.dart';
import '../utils/api_exceptions.dart';

class ServiceApi {
  final String baseUrl;
  ServiceApi({required this.baseUrl});

  Future<List<Service>> fetchServices() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/services'))
          .timeout(const Duration(seconds: 10));

      switch (response.statusCode) {
        case 200:
          return _parseServices(response.body);
        case 404:
          throw NotFoundException();
        case 500:
          throw ServerException(500);
        default:
          throw ServerException(response.statusCode);
      }
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw AppTimeoutException();
    } on FormatException {
      throw InvalidJsonException();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw UnknownApiException();
    }
  }

  List<Service> _parseServices(String body) {
    try {
      final List<dynamic> data = jsonDecode(body);
      return data.map((json) => Service.fromJson(json)).toList();
    } catch (_) {
      throw InvalidJsonException();
    }
  }
}