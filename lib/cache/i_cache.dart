import 'package:musicfox/cache/file_cache.dart';

abstract class ICache {
  
  bool set(String key, dynamic value);

  dynamic get(String key);

  bool persist();

  bool clear();

  bool del(String key);
}

class CacheFactory {
  static ICache _cache;

  static ICache produce() {
    _cache ??= FileCache();
    return _cache;
  }
}