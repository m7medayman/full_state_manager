// lib/src/utils/failure.dart

import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;
  final int? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, code, originalError];

  @override
  String toString() => message;
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Validation failure
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'Validation failed',
    super.code,
    this.fieldErrors,
    super.originalError,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Authentication failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Authentication failed',
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Authorization failure
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    super.message = 'You do not have permission to perform this action',
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Timeout failure
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timeout',
    super.code,
    super.originalError,
    super.stackTrace,
  });
}