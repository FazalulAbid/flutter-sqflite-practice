import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_practice_project/core/domain/utils/result.dart';
import 'package:sqflite_practice_project/feature/country/data/repository/country_repository_impl.dart';
import 'package:sqflite_practice_project/feature/country/presentation/state/country_list_state.dart';

part 'country_listing_notifier.g.dart';

@riverpod
class CountryListingNotifier extends _$CountryListingNotifier {
  @override
  CountryListingState build() {
    loadCountries();
    return const CountryListingState.initial();
  }

  Future<void> loadCountries() async {
    state = const CountryListingState.loading();

    try {
      final repository = ref.read(countryRepositoryProvider);
      final result = await repository.getCountries();

      result.when(
        success: (countries) {
          state = CountryListingState.loaded(countries: countries);
        },
        failure: (error) {
          print("Hello: ${error.message}");
          state = CountryListingState.error(message: error.toString());
        },
      );
    } catch (e) {
      state = CountryListingState.error(message: e.toString());
    }
  }

  Future<void> refreshCountries() async {
    await loadCountries();
  }
}
