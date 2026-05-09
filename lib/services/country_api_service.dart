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

  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Server error: ${response.statusCode}',
      );
    }
  }

  Future<List<Country>> fetchAllCountries() async {
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
    return data
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();
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