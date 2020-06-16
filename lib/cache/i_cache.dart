import 'package:musicfox/cache/file_cache.dart';

abstract class ICache {
  
  Future<bool> set(String key, dynamic value);

  Future<dynamic> get(String key);

  Future<bool> persist();

  Future<bool> clear();

  Future<bool> del(String key);
}

class CacheFactory {
  static ICache _cache;

  static ICache produce() {
    _cache ??= FileCache();
    return _cache;
  }
}