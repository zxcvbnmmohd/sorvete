import 'package:serverpod_client/serverpod_client.dart';

/// Typed error envelope all Sorvete apps consume.
///
/// Maps every error a `<svc>_client` call can surface into one of seven cases
/// so UI layers can pattern-match rather than catching strings.
sealed class AppError implements Exception {
  const AppError(this.message, [this.cause]);
  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class UnauthenticatedError extends AppError {
  const UnauthenticatedError([super.message = 'Not signed in', super.cause]);
}

final class ForbiddenError extends AppError {
  const ForbiddenError([super.message = 'Not allowed', super.cause]);
}

final class ConflictError extends AppError {
  const ConflictError([super.message = 'Conflicting write', super.cause]);
}

final class NotFoundError extends AppError {
  const NotFoundError([super.message = 'Not found', super.cause]);
}

final class RateLimitedError extends AppError {
  const RateLimitedError([super.message = 'Rate limited', super.cause]);
}

final class ServerError extends AppError {
  const ServerError([super.message = 'Server error', super.cause]);
}

final class NetworkError extends AppError {
  const NetworkError([super.message = 'Network error', super.cause]);
}

/// Translates whatever a Serverpod client throws into a typed [AppError].
///
/// Unrecognised errors fall through to [ServerError] so callers can still
/// log them without crashing the UI.
AppError mapServerpodError(Object error) {
  if (error is AppError) return error;

  if (error is ServerpodClientException) {
    return switch (error.statusCode) {
      401 => UnauthenticatedError(error.message, error),
      403 => ForbiddenError(error.message, error),
      404 => NotFoundError(error.message, error),
      409 => ConflictError(error.message, error),
      429 => RateLimitedError(error.message, error),
      >= 500 => ServerError(error.message, error),
      _ => ServerError(error.message, error),
    };
  }

  return NetworkError(error.toString(), error);
}
