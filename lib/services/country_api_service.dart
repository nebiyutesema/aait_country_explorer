import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import 'api_exception.dart';

class CountryApiService {
  final String _baseUrl = 'restcountries.com';
  final Duration _timeout = const Duration(seconds: 10);
  final Map<String, String> _headers = const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Cache storage
  List<Country>? _cachedCountries;
  DateTime? _cacheTime;
  final Duration _cacheTTL = const Duration(minutes: 5);

  // Check if cache is still valid
  bool get _isCacheValid {
    if (_cachedCountries == null || _cacheTime == null) return false;
    return DateTime.now().difference(_cacheTime!) < _cacheTTL;
  }

  // Public getter to check if data is from cache
  bool get isFromCache => _isCacheValid && _cachedCountries != null;

  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Server error: ${response.statusCode}',
      );
    }
  }

  Future<List<Country>> fetchAllCountries() async {
    // Return cache if valid
    if (_isCacheValid) {
      return _cachedCountries!;
    }

    final uri = Uri.https(
      _baseUrl,
      '/v3.1/all',
      {'fields': 'name,flag,region,population,cca3'},
    );

    final response = await http
        .get(uri, headers: _headers)
        .timeout(_timeout);

    _checkResponse(response);

    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    final countries = data
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();

    // Save to cache
    _cachedCountries = countries;
    _cacheTime = DateTime.now();

    return countries;
  }

  Future<List<Country>> searchByName(String name) async {
    final uri = Uri.https(
      _baseUrl,
      '/v3.1/name/$name',
    );

    final response = await http
        .get(uri, headers: _headers)
        .timeout(_timeout);

    _checkResponse(response);

    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return data
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Country> fetchByCode(String code) async {
    final uri = Uri.https(
      _baseUrl,
      '/v3.1/alpha/$code',
    );

    final response = await http
        .get(uri, headers: _headers)
        .timeout(_timeout);

    _checkResponse(response);

    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return Country.fromJson(data.first as Map<String, dynamic>);
  }
}