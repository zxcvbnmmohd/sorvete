import 'package:serverpod_client/serverpod_client.dart';
import 'package:sorvete_core/sorvete_core.dart';

/// Translates whatever a Serverpod client throws into a typed [AppError]
/// (defined in `packages/core`).
///
/// Unrecognised errors fall through to [ServerError] / [NetworkError] so
/// callers can still log them without crashing the UI.
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
