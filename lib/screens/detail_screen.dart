import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_api_service.dart';
import '../services/api_exception.dart';

class DetailScreen extends StatefulWidget {
  final String alpha3Code;

  const DetailScreen({super.key, required this.alpha3Code});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CountryApiService _apiService = CountryApiService();
  late Future<Country> _countryFuture;

  @override
  void initState() {
    super.initState();
    _countryFuture = _apiService.fetchByCode(widget.alpha3Code);
  }

  void _retry() {
    setState(() {
      _countryFuture = _apiService.fetchByCode(widget.alpha3Code);
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
        title: const Text('Country Details'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Country>(
        future: _countryFuture,
        builder: (context, snapshot) {
          // State 1: Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading country details...'),
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
          if (!snapshot.hasData) {
            return const Center(child: Text('No details found.'));
          }

          // State 4: Data
          final country = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flag and name
                Center(
                  child: Column(
                    children: [
                      Text(
                        country.flagEmoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        country.commonName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        country.officialName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                // Details
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: 'Region',
                  value: country.region,
                ),
                _buildDetailRow(
                  icon: Icons.map,
                  label: 'Subregion',
                  value: country.subregion.isEmpty
                      ? 'N/A'
                      : country.subregion,
                ),
                _buildDetailRow(
                  icon: Icons.location_city,
                  label: 'Capital',
                  value: country.capital.isEmpty
                      ? 'N/A'
                      : country.capital.join(', '),
                ),
                _buildDetailRow(
                  icon: Icons.people,
                  label: 'Population',
                  value: country.population.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (m) => '${m[1]},',
                      ),
                ),
                _buildDetailRow(
                  icon: Icons.square_foot,
                  label: 'Area',
                  value: '${country.area.toStringAsFixed(0)} km²',
                ),
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: 'Timezones',
                  value: country.timezones.join(', '),
                ),
                _buildDetailRow(
                  icon: Icons.attach_money,
                  label: 'Currencies',
                  value: country.currencies.isEmpty
                      ? 'N/A'
                      : country.currencies.entries
                          .map((e) => '${e.value} (${e.key})')
                          .join(', '),
                ),
                _buildDetailRow(
                  icon: Icons.language,
                  label: 'Languages',
                  value: country.languages.isEmpty
                      ? 'N/A'
                      : country.languages.values.join(', '),
                ),
                _buildDetailRow(
                  icon: Icons.flag,
                  label: 'ISO Code',
                  value: country.alpha3Code,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}