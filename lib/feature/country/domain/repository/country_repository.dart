import 'package:sqflite_practice_project/core/domain/utils/result.dart';
import 'package:sqflite_practice_project/feature/country/domain/models/country_model.dart';

abstract class CountryRepository {
  Future<Result<List<Country>>> getCountries();
}
