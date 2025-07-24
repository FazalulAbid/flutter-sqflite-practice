import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sqflite_practice_project/feature/country/domain/models/country_model.dart';

part 'country_list_state.freezed.dart';

@freezed
class CountryListingState with _$CountryListingState {
  const factory CountryListingState.initial() = _Initial;

  const factory CountryListingState.loading() = _Loading;

  const factory CountryListingState.loaded({required List<Country> countries}) = _Loaded;

  const factory CountryListingState.error({required String message}) = _Error;
}
