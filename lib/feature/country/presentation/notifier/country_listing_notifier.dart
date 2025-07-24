import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_practice_project/core/domain/utils/result.dart';
import 'package:sqflite_practice_project/core/presentation/states/loader_state.dart';
import 'package:sqflite_practice_project/feature/country/data/repository/country_repository_impl.dart';
import 'package:sqflite_practice_project/feature/country/domain/models/country_model.dart';
import 'package:sqflite_practice_project/feature/country/presentation/state/country_list_state.dart';

part 'country_listing_notifier.g.dart';

@riverpod
class CountryListingNotifier extends _$CountryListingNotifier {
  @override
  CountryListState build() {
    return CountryListState.initial();
  }

  Future<void> searchCountries(BuildContext context, {String? query}) async {
    state = state.copyWith(
      isSearching: true,
      currentPage: 1,
      hasMoreData: true,
      countries: [],
    );

    await _fetchCountries(query: query, page: 1);
  }

  Future<void> loadMoreCountries() async {
    if (state.isLoadingMore || !state.hasMoreData) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    await _fetchCountries(
      query: state.currentQuery,
      page: nextPage,
      isLoadMore: true,
    );
  }

  Future<void> _fetchCountries({
    String? query,
    int page = 1,
    bool isLoadMore = false,
  }) async {
    try {
      final repository = ref.read(countryRepositoryProvider);
      final result = await repository.getCountries(
        page: page,
        pageSize: 20,
        searchQuery: query?.isEmpty == true ? null : query,
      );

      result.when(
        success: (paginatedResult) {
          final List<Country> newCountries = paginatedResult.items;

          if (isLoadMore) {
            final updatedCountries = [...state.countries, ...newCountries];
            state = state.copyWith(
              isLoadingMore: false,
              countries: updatedCountries,
              currentPage: page,
              hasMoreData: paginatedResult.hasNextPage,
              loaderState: const LoaderState.success(),
            );
          } else {
            state = state.copyWith(
              isSearching: false,
              countries: newCountries,
              currentPage: page,
              currentQuery: query,
              hasMoreData: paginatedResult.hasNextPage,
              loaderState: const LoaderState.success(),
            );
          }
        },
        failure: (error) {
          if (isLoadMore) {
            state = state.copyWith(
              isLoadingMore: false,
              loaderState: LoaderState.error(error.toString()),
            );
          } else {
            state = state.copyWith(
              isSearching: false,
              loaderState: LoaderState.error(error.toString()),
            );
          }
        },
      );
    } catch (e) {
      if (isLoadMore) {
        state = state.copyWith(
          isLoadingMore: false,
          loaderState: LoaderState.error(e.toString()),
        );
      } else {
        state = state.copyWith(
          isSearching: false,
          loaderState: LoaderState.error(e.toString()),
        );
      }
    }
  }

  Future<void> refreshCountries() async {
    try {
      state = state.copyWith(isSearching: true);

      final repository = ref.read(countryRepositoryProvider);
      final syncResult = await repository.syncCountriesFromApi();

      await syncResult.when(
        success: (_) async {
          await _fetchCountries(page: 1);
        },
        failure: (error) {
          state = state.copyWith(
            isSearching: false,
            loaderState: LoaderState.error(error.toString()),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        loaderState: LoaderState.error(e.toString()),
      );
    }
  }
}
