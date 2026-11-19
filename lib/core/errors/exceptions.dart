/// Typed Exceptions for Network and API layer
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

/// Thrown when there is no active internet connection
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network and try again.',
  });
}

/// Thrown when a network request times out
class RequestTimeoutException extends AppException {
  const RequestTimeoutException({
    super.message = 'Connection timed out. The server took too long to respond.',
  });
}

/// Thrown when the server returns a 5xx response
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error occurred. Please try again later.',
    super.statusCode,
  });
}

/// Thrown when the server returns a 4xx response
class ClientException extends AppException {
  const ClientException({
    super.message = 'Invalid request. Please try again.',
    super.statusCode,
  });
}

/// Thrown when data parsing fails
class ParseException extends AppException {
  const ParseException({
    super.message = 'Failed to parse response data.',
  });
}

/// Thrown when a request was explicitly cancelled
class RequestCancelledException extends AppException {
  const RequestCancelledException({
    super.message = 'The request was cancelled.',
  });
}

/// Thrown for any unexpected exception
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}
