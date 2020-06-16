abstract class ICache {
  Future<bool> set(String key, dynamic value);

  Future<dynamic> get(String key);

  Future<bool> persist();
}