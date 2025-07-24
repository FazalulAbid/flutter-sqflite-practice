import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sqflite_practice_project/core/presentation/states/loader_state.dart';
import 'package:sqflite_practice_project/feature/country/domain/models/country_model.dart';

part 'country_list_state.freezed.dart';

@freezed
abstract class CountryListState with _$CountryListState {
  const factory CountryListState({
    @Default([]) List<Country> countries,
    @Default(false) bool isSearching,
    @Default(false) bool isLoadingMore,
    @Default(1) int currentPage,
    @Default(true) bool hasMoreData,
    String? currentQuery,
    Country? selectedCountry,
    @Default(LoaderState.initial()) LoaderState loaderState,
  }) = _CountryListState;

  factory CountryListState.initial() => const CountryListState();
}
