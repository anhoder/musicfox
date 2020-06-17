class ResponseException implements Exception {
  final String message;

  ResponseException([this.message]);

  @override
  String toString() => '<!!! 错误: ${message ?? ''} !!!>';

}