import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_practice_project/core/data/database/database_helper.dart';
import 'package:sqflite_practice_project/core/domain/models/paginated_result.dart';
import 'package:sqflite_practice_project/core/domain/utils/app_failure.dart';
import 'package:sqflite_practice_project/core/domain/utils/result.dart';
import 'package:sqflite_practice_project/feature/country/data/datasource/local/country_local_data_source.dart';
import 'package:sqflite_practice_project/feature/country/data/entity/country_entity.dart';

part 'country_local_data_source_impl.g.dart';

@riverpod
CountryLocalDataSource countryLocalDataSource(Ref ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return CountryLocalDataSourceImpl(databaseHelper);
}

class CountryLocalDataSourceImpl implements CountryLocalDataSource {
  final DatabaseHelper _databaseHelper;

  CountryLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<Result<void>> insertCountries(List<CountryEntity> countries) async {
    try {
      final db = await _databaseHelper.database;
      final batch = db.batch();

      batch.delete('countries');

      // Insert new countries
      for (final country in countries) {
        batch.insert(
          'countries',
          country.toDatabase(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppFailure.database(message: 'Failed to insert countries: $e'),
      );
    }
  }

  @override
  Future<Result<PaginatedResult<CountryEntity>>> getCountries({
    required int page,
    required int pageSize,
    String? searchQuery,
  }) async {
    try {
      final db = await _databaseHelper.database;

      String whereClause = '';
      List<Object?> whereArgs = [];

      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause = 'WHERE common_name LIKE ? OR official_name LIKE ?';
        final searchPattern = '%$searchQuery%';
        whereArgs = [searchPattern, searchPattern];
      }

      // Get total count
      final countResult = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM countries 
        $whereClause
      ''', whereArgs);

      final totalItems = countResult.first['count'] as int;
      final totalPages = (totalItems / pageSize).ceil();

      // Get paginated data
      final offset = (page - 1) * pageSize;
      final results = await db.rawQuery(
        '''
        SELECT * FROM countries 
        $whereClause
        ORDER BY common_name ASC 
        LIMIT ? OFFSET ?
      ''',
        [...whereArgs, pageSize, offset],
      );

      final countries = results
          .map((map) => CountryEntityExtension.fromDatabase(map))
          .toList();

      final paginatedResult = PaginatedResult<CountryEntity>(
        items: countries,
        currentPage: page,
        totalPages: totalPages,
        totalItems: totalItems,
        hasNextPage: page < totalPages,
        hasPreviousPage: page > 1,
      );

      return Result.success(paginatedResult);
    } catch (e) {
      return Result.failure(
        AppFailure.database(message: 'Failed to get countries: $e'),
      );
    }
  }

  @override
  Future<Result<int>> getCountriesCount({String? searchQuery}) async {
    try {
      final db = await _databaseHelper.database;

      String whereClause = '';
      List<Object?> whereArgs = [];

      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause = 'WHERE common_name LIKE ? OR official_name LIKE ?';
        final searchPattern = '%$searchQuery%';
        whereArgs = [searchPattern, searchPattern];
      }

      final result = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM countries 
        $whereClause
      ''', whereArgs);

      final count = result.first['count'] as int;
      return Result.success(count);
    } catch (e) {
      return Result.failure(
        AppFailure.database(message: 'Failed to get countries count: $e'),
      );
    }
  }

  @override
  Future<Result<void>> clearCountries() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete('countries');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppFailure.database(message: 'Failed to clear countries: $e'),
      );
    }
  }

  @override
  Future<bool> hasCountries() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM countries',
      );
      final count = result.first['count'] as int;
      return count > 0;
    } catch (e) {
      print('Failed to check if has countries: $e');
      return false;
    }
  }
}
