import 'package:sqflite_practice_project/core/domain/models/paginated_result.dart';
import 'package:sqflite_practice_project/core/domain/utils/result.dart';
import 'package:sqflite_practice_project/feature/country/data/entity/country_entity.dart';

abstract class CountryLocalDataSource {
  Future<Result<void>> insertCountries(List<CountryEntity> countries);

  Future<Result<PaginatedResult<CountryEntity>>> getCountries({
    required int page,
    required int pageSize,
    String? searchQuery,
  });

  Future<Result<int>> getCountriesCount({String? searchQuery});

  Future<Result<void>> clearCountries();

  Future<bool> hasCountries();
}
