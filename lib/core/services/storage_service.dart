abstract class StorageService {
  void init();

  bool get hasInitialized;

  Future<bool> remove(String key);

  Future<Object?> get(String key);

  Future<bool> set(String key, String value);

  Future<void> clear();

  Future<bool> has(String key);
}
