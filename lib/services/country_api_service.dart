import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import 'api_exception.dart';

class CountryApiService {
  static const String _baseUrl = 'restcountries.com';
  final http.Client _client;

  CountryApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches all countries for the Home Screen
  Future<List<Country>> fetchAllCountries() async {
    final url = Uri.https(_baseUrl, '/v3.1/all');
    return _performRequest(url);
  }

  /// Fetches a specific country by its alpha code for the Detail Screen
  Future<Country> fetchCountryByCode(String code) async {
    final url = Uri.https(_baseUrl, '/v3.1/alpha/$code');
    final countries = await _performRequest(url);
    if (countries.isEmpty) {
      throw ApiException("Country not found");
    }
    return countries.first;
  }

  /// Core request logic with 10-second timeout
  Future<List<Country>> _performRequest(Uri url) async {
    try {
      final response = await _client.get(url).timeout(
        const Duration(seconds: 10),
      );

      final decodedData = _checkResponse(response);
      
      return (decodedData as List)
          .map((json) => Country.fromJson(json))
          .toList();
          
    } on SocketException {
      throw ApiException("No Internet Connection");
    } on TimeoutException {
      throw ApiException("Request timed out. Please try again.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("An unexpected error occurred: $e");
    }
  }

  /// Private method to validate HTTP status codes
  dynamic _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        "Failed to load data", 
        response.statusCode
      );
    }
  }
}
