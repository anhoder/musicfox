import 'dart:convert';
import 'dart:io';

import 'package:musicfox/cache/i_cache.dart';

class FileCache implements ICache {

  static String _filePath;

  File _file;

  Map<String, dynamic> _data;

  FileCache() {
    var env = Platform.environment;
    if (Platform.isWindows) {
      _filePath = '${env['USERPROFILE'].toString()}${Platform.pathSeparator}.musicfox.cache';
    } else {
      _filePath = '${env['HOME'].toString()}${Platform.pathSeparator}.musicfox.cache';
    }

    _file = File(_filePath);

    if (!_file.existsSync()) {
      _file.createSync(recursive: true);
      _data = {};
    } else {
      var json = _file.readAsStringSync();
      if (json == '') {
        _data = {};
      } else {
        _data = JsonDecoder().convert(json);
      }
    }
  }

  @override
  dynamic get(String key) {
    if (_data.containsKey(key)) return _data[key];
    return null;
  }

  @override
  bool persist() {
    var json = JsonEncoder().convert(_data);
    _file.writeAsString(json, flush: true);
    return true;
  }

  @override
  bool set(String key, value) {
    _data[key] = value;
    persist();
    return true;
  }

  @override
  bool clear() {
    _data = {};
    persist();
    return true;
  }

  @override
  bool del(String key) {
    if (_data.containsKey(key)) _data.remove(key);
    return true;
  }
  
}