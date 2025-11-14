/// API Client for connecting to Python backend
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:final_year_project/core/config/api_config.dart';

class ApiClient {
  
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(endpoint)),
        headers: {'Content-Type': 'application/json'},
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    }
  }
  
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(endpoint)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    }
  }
  
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(endpoint)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    }
  }
  
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl(endpoint)),
        headers: {'Content-Type': 'application/json'},
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    }
  }
  
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }
}

