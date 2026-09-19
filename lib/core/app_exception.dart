// lib/core/app_exception.dart
// Sealed class untuk semua exception aplikasi.
// Layer UI hanya menangkap AppException, bukan exception mentah.

sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class AuthFailure extends AppException {
  const AuthFailure(super.message);
}

class DatabaseFailure extends AppException {
  const DatabaseFailure(super.message);
}

class ValidationFailure extends AppException {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends AppException {
  const NotFoundFailure(super.message);
}

class UnknownFailure extends AppException {
  const UnknownFailure(super.message);
}
