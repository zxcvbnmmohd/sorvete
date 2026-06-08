/// Typed error envelope every Sorvete app and service speaks.
///
/// One sealed case per failure mode so UI and callers pattern-match rather
/// than catching strings. Pure Dart — the Serverpod-client mapping
/// (`mapServerpodError`) lives in `packages/backend`, which depends on this.
///
/// Kept as a hand-written sealed class (not freezed): each case carries a
/// default message and `implements Exception`, which a data-class generator
/// does not express cleanly. Codegen-first applies to data types (Money,
/// Currency, OutboxEvent), not this exception hierarchy.
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
