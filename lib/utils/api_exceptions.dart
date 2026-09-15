abstract class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class NoInternetException extends ApiException {
  NoInternetException() : super('No internet connection.');
}

class AppTimeoutException extends ApiException {
  AppTimeoutException() : super('The server is taking too long to respond.');
}

class ServerException extends ApiException {
  final int statusCode;

  ServerException(this.statusCode)
      : super('Server error ($statusCode).');
}

class NotFoundException extends ApiException {
  NotFoundException() : super('Resource not found (404).');
}

class InvalidJsonException extends ApiException {
  InvalidJsonException() : super('Invalid server response.');
}

class UnknownApiException extends ApiException {
  UnknownApiException() : super('An unknown error occurred.');
}
