class ParseException implements Exception {
  const ParseException(this.message, this.line, this.column, [this.token]);
  final String message;
  final int line, column;
  final String? token;
  @override
  String toString() =>
      '解析失败：第 $line 行，第 $column 列\n$message${token == null ? '' : '\n附近 Token：$token'}';
}
