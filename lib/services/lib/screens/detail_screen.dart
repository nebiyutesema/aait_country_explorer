import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_api_service.dart';
import '../services/api_exception.dart';

class DetailScreen extends StatefulWidget {
  final String countryCode;

  const DetailScreen({super.key, required this.countryCode});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Country> _countryFuture;
  final CountryApiService _apiService = CountryApiService();

  @override
  void initState() {
    super.initState();
    _countryFuture = _apiService.fetchCountryByCode(widget.countryCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Country Details")),
      body: FutureBuilder<Country>(
        future: _countryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            final error = snapshot.error;
            return Center(
              child: Text(error is ApiException ? error.message : "An error occurred"),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data found"));
          }

          final country = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    country.flagEmoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow("Name", country.name),
                _buildInfoRow("Capital", country.capital),
                _buildInfoRow("Region", country.region),
                _buildInfoRow("Population", country.population.toString()),
                _buildInfoRow("Languages", country.languages.join(", ")),
                _buildInfoRow("Currencies", country.currencies.join(", ")),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("**$label:** ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
