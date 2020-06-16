import 'dart:io';

import 'package:musicfox/cache/i_cache.dart';

class FileCache implements ICache {

  static const String FILE_PATH = '待定';

  File _file;

  FileCache() {
    _file = File(FILE_PATH);
    if (!_file.existsSync()) {
      _file.createSync(recursive: true);
    }
  }

  @override
  Future get(String key) {
    // TODO: implement get
    return null;
  }

  @override
  Future<bool> persist() {
    // TODO: implement persist
    return null;
  }

  @override
  Future<bool> set(String key, value) {
    // TODO: implement set
    return null;
  }
  
}