class ResponseException implements Exception {
  final String message;

  ResponseException([this.message]);

  @override
  String toString() => '请求出错: ${message ?? ''}';

}