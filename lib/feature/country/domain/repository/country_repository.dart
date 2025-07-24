import 'package:sqflite_practice_project/core/domain/models/paginated_result.dart';
import 'package:sqflite_practice_project/core/domain/utils/result.dart';
import 'package:sqflite_practice_project/feature/country/domain/models/country_model.dart';

abstract class CountryRepository {
  Future<Result<void>> syncCountriesFromApi();

  Future<Result<PaginatedResult<Country>>> getCountries({
    required int page,
    required int pageSize,
    String? searchQuery,
  });
}
