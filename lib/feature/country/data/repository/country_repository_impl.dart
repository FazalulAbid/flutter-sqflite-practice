import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_practice_project/core/domain/models/paginated_result.dart';
import 'package:sqflite_practice_project/core/domain/utils/app_failure.dart';
import 'package:sqflite_practice_project/core/domain/utils/result.dart';
import 'package:sqflite_practice_project/core/services/shared_prefs_storage_service.dart';
import 'package:sqflite_practice_project/core/services/storage_service.dart';
import 'package:sqflite_practice_project/core/utils/constants.dart';
import 'package:sqflite_practice_project/feature/country/data/datasource/country_remote_data_source.dart';
import 'package:sqflite_practice_project/feature/country/data/datasource/country_remote_data_source_impl.dart';
import 'package:sqflite_practice_project/feature/country/data/datasource/local/country_local_data_source.dart';
import 'package:sqflite_practice_project/feature/country/data/datasource/local/country_local_data_source_impl.dart';
import 'package:sqflite_practice_project/feature/country/data/entity/country_entity.dart';
import 'package:sqflite_practice_project/feature/country/data/mapper/country_mapper.dart';
import 'package:sqflite_practice_project/feature/country/domain/models/country_model.dart';
import 'package:sqflite_practice_project/feature/country/domain/repository/country_repository.dart';

part 'country_repository_impl.g.dart';

@riverpod
CountryRepository countryRepository(Ref ref) {
  final remoteDataSource = ref.watch(countryRemoteDataSourceProvider);
  final localDataSource = ref.watch(countryLocalDataSourceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return CountryRepositoryImpl(
    remoteDataSource,
    localDataSource,
    storageService,
  );
}

class CountryRepositoryImpl implements CountryRepository {
  final CountryRemoteDataSource _remoteDataSource;
  final CountryLocalDataSource _localDataSource;
  final StorageService _storageService;

  static const int _cacheValidityHours = 6;

  CountryRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._storageService,
  );

  @override
  Future<Result<PaginatedResult<Country>>> getCountries({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    try {
      final hasLocal = await _localDataSource.hasCountries();

      if (!hasLocal) {
        final syncResult = await _syncCountriesFromApi();
        return await syncResult.when(
          success: (_) => _getCountriesFromLocal(
            page: page,
            pageSize: pageSize,
            searchQuery: searchQuery,
          ),
          failure: (error) => Result.failure(error),
        );
      }

      final isFresh = await _isDataFresh();

      if (isFresh) {
        return _getCountriesFromLocal(
          page: page,
          pageSize: pageSize,
          searchQuery: searchQuery,
        );
      } else {
        final syncResult = await _syncCountriesFromApi();
        return await syncResult.when(
          success: (_) => _getCountriesFromLocal(
            page: page,
            pageSize: pageSize,
            searchQuery: searchQuery,
          ),
          failure: (syncError) async {
            print("Sync failed, serving stale data: $syncError");
            return _getCountriesFromLocal(
              page: page,
              pageSize: pageSize,
              searchQuery: searchQuery,
            );
          },
        );
      }
    } catch (e) {
      return Result.failure(
        AppFailure.unknown(message: 'Failed to get countries: $e'),
      );
    }
  }

  Future<Result<PaginatedResult<Country>>> _getCountriesFromLocal({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    final result = await _localDataSource.getCountries(
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
    );

    return result.when(
      success: (paginatedEntities) {
        final countries = paginatedEntities.items
            .map((entity) => entity.toDomain())
            .toList();

        final paginatedCountries = PaginatedResult<Country>(
          items: countries,
          currentPage: paginatedEntities.currentPage,
          totalPages: paginatedEntities.totalPages,
          totalItems: paginatedEntities.totalItems,
          hasNextPage: paginatedEntities.hasNextPage,
          hasPreviousPage: paginatedEntities.hasPreviousPage,
        );

        return Result.success(paginatedCountries);
      },
      failure: (error) => Result.failure(error),
    );
  }

  Future<bool> _isDataFresh() async {
    try {
      final lastFetchTime = await _getLastFetchTime();
      if (lastFetchTime == null) return false;

      final hoursDifference =
          (DateTime.now().millisecondsSinceEpoch - lastFetchTime) /
          (1000 * 60 * 60);

      return hoursDifference < _cacheValidityHours;
    } catch (e) {
      print('Failed to check data freshness: $e');
      return false;
    }
  }

  Future<int?> _getLastFetchTime() async {
    try {
      final timestampString = await _storageService.get(
        AppConstants.countriesLastFetchStorageKey,
      );
      if (timestampString == null) return null;

      return int.tryParse(timestampString.toString());
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveLastFetchTime() async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      await _storageService.set(
        AppConstants.countriesLastFetchStorageKey,
        currentTime.toString(),
      );
    } catch (e) {
      print('Failed to save last fetch time: $e');
    }
  }

  Future<Result<void>> _syncCountriesFromApi() async {
    try {
      final apiResult = await _remoteDataSource.getCountries();

      return await apiResult.when(
        success: (dtoList) async {
          final entities = dtoList.map((dto) => dto.toEntity()).toList();
          final insertResult = await _localDataSource.insertCountries(entities);

          return await insertResult.when(
            success: (_) {
              _saveLastFetchTime();
              return const Result.success(null);
            },
            failure: (error) {
              return Result.failure(error);
            },
          );
        },
        failure: (error) {
          return Result.failure(error);
        },
      );
    } catch (e) {
      return Result.failure(AppFailure.unknown(message: 'Sync failed: $e'));
    }
  }

  @override
  Future<Result<void>> syncCountriesFromApi() async {
    return await _syncCountriesFromApi();
  }
}
