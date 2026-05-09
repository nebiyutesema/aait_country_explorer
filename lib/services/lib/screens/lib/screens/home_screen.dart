import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_api_service.dart';
import '../services/api_exception.dart';
import 'search_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CountryApiService _apiService = CountryApiService();
  late Future<List<Country>> _countriesFuture;

  @override
  void initState() {
    super.initState();
    _countriesFuture = _apiService.fetchAllCountries();
  }

  void _retry() {
    setState(() {
      _countriesFuture = _apiService.fetchAllCountries();
    });
  }

  String _getErrorMessage(Object error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is ApiException) {
      return 'Server error ${error.statusCode}: ${error.message}';
    } else if (error is FormatException) {
      return 'Unexpected data format received.';
    } else {
      return 'An unexpected error occurred: ${error.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 Country Explorer'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Country>>(
        future: _countriesFuture,
        builder: (context, snapshot) {
          // State 1: Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading countries...'),
                ],
              ),
            );
          }

          // State 2: Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _getErrorMessage(snapshot.error!),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // State 3: No data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No countries found.'),
            );
          }

          // State 4: Data
          final countries = snapshot.data!;
          countries.sort((a, b) => a.commonName.compareTo(b.commonName));

          return ListView.builder(
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final country = countries[index];
              return ListTile(
                leading: Text(
                  country.flagEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
                title: Text(
                  country.commonName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(country.region),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailScreen(alpha3Code: country.alpha3Code),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}