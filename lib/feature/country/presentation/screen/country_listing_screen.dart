import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_practice_project/feature/country/domain/models/country_model.dart';
import 'package:sqflite_practice_project/feature/country/presentation/notifier/country_listing_notifier.dart';
import 'package:sqflite_practice_project/feature/country/presentation/state/country_list_state.dart';

class CountryListingScreen extends ConsumerWidget {
  const CountryListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(countryListingNotifierProvider);
    final notifier = ref.read(countryListingNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries'),
        actions: [
          IconButton(onPressed: () => notifier.refreshCountries(), icon: const Icon(Icons.refresh)),
        ],
      ),
      body: state.when(
        initial: () => const Center(child: Text('Initializing...')),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (countries) {
          if (countries.isEmpty) {
            return const Center(child: Text('No countries found'));
          }

          return RefreshIndicator(
            onRefresh: () => notifier.refreshCountries(),
            child: ListView.builder(
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                return ListTile(
                  title: Text(country.commonName),
                  subtitle: Text(country.officialName),
                  leading: CircleAvatar(
                    child: Text(
                      country.commonName.isNotEmpty ? country.commonName[0].toUpperCase() : '?',
                    ),
                  ),
                  onTap: () {
                    _showCountryDetails(context, country);
                  },
                );
              },
            ),
          );
        },
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $message',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => notifier.loadCountries(), child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryDetails(BuildContext context, Country country) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(country.commonName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Official Name: ${country.officialName}')],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }
}
