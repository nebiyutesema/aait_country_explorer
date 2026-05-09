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
  bool _isFromCache = false;

  // Pagination
  List<Country> _allCountries = [];
  List<Country> _displayedCountries = [];
  static const int _pageSize = 20;
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  void _loadCountries() {
    _countriesFuture = _apiService.fetchAllCountries().then((countries) {
      if (mounted) {
        setState(() {
          _isFromCache = _apiService.isFromCache;
          _allCountries = countries
            ..sort((a, b) => a.commonName.compareTo(b.commonName));
          _currentPage = 1;
          _displayedCountries =
              _allCountries.take(_pageSize).toList();
        });
      }
      return countries;
    });
  }

  void _retry() {
    setState(() {
      _isFromCache = false;
      _allCountries = [];
      _displayedCountries = [];
      _currentPage = 1;
      _loadCountries();
    });
  }

  void _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate a small delay for smooth UX
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _currentPage++;
        final nextItems = _allCountries
            .skip(_currentPage * _pageSize - _pageSize)
            .take(_pageSize)
            .toList();
        _displayedCountries.addAll(nextItems);
        _isLoadingMore = false;
      });
    }
  }

  bool get _hasMore => _displayedCountries.length < _allCountries.length;

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
          // Cached badge
          if (_isFromCache)
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.storage, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Cached',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
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

          // State 4: Data with pagination
          return Column(
            children: [
              // Country count info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                color: Colors.blue.shade50,
                child: Text(
                  'Showing ${_displayedCountries.length} of ${_allCountries.length} countries',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Countries list
              Expanded(
                child: ListView.builder(
                  itemCount: _displayedCountries.length + 1,
                  itemBuilder: (context, index) {
                    // Load More button at the bottom
                    if (index == _displayedCountries.length) {
                      if (!_hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              '✅ All countries loaded',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _isLoadingMore
                            ? const Center(
                                child: CircularProgressIndicator())
                            : ElevatedButton.icon(
                                onPressed: _loadMore,
                                icon: const Icon(Icons.expand_more),
                                label: Text(
                                  'Load More (${_allCountries.length - _displayedCountries.length} remaining)',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  minimumSize:
                                      const Size(double.infinity, 48),
                                ),
                              ),
                      );
                    }

                    final country = _displayedCountries[index];
                    return ListTile(
                      leading: Text(
                        country.flagEmoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(
                        country.commonName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(country.region),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                                alpha3Code: country.alpha3Code),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}