import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite_practice_project/core/data/network/network_client.dart';
import 'package:sqflite_practice_project/core/domain/utils/result.dart';
import 'package:sqflite_practice_project/feature/country/data/datasource/country_remote_data_source.dart';
import 'package:sqflite_practice_project/feature/country/data/dto/country_dto.dart';

part 'country_remote_data_source_impl.g.dart';

@riverpod
CountryRemoteDataSource countryRemoteDataSource(Ref ref) {
  final networkClient = ref.watch(networkClientProvider);
  return CountryRemoteDataSourceImpl(networkClient);
}

class CountryRemoteDataSourceImpl implements CountryRemoteDataSource {
  final NetworkClient _networkClient;

  CountryRemoteDataSourceImpl(this._networkClient);

  @override
  Future<Result<List<CountryDto>>> getCountries() async {
    return await _networkClient.getListRequest<CountryDto>(
      '/all?fields=name',
      fromJson: (json) => CountryDto.fromJson(json),
    );
  }
}
