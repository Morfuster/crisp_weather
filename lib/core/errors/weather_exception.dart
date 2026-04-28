class WeatherException implements Exception {
  const WeatherException({
    required this.message,
    required this.statusCode,
    required this.responseBody,
  });

  final String message;
  final int statusCode;
  final String responseBody;

  @override
  String toString() =>
      'WeatherException($statusCode): $message — $responseBody';
}

class GeocodingException implements Exception {
  const GeocodingException({
    required this.message,
    required this.statusCode,
    required this.responseBody,
  });

  final String message;
  final int statusCode;
  final String responseBody;

  @override
  String toString() =>
      'GeocodingException($statusCode): $message — $responseBody';
}
