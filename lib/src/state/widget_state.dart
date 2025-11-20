// lib/src/state/widget_state.dart

import 'package:equatable/equatable.dart';
import '../utils/failure.dart';
import 'enums.dart';

/// Represents the state of a specific widget identified by a key
class MyWidgetState extends Equatable {
  final WidgetStatus status;
  final dynamic data;
  final Failure? error;
  final DateTime? lastUpdated;

  const MyWidgetState({
    this.status = WidgetStatus.initial,
    this.data,
    this.error,
    this.lastUpdated,
  });

  const MyWidgetState.initial() : this();

  const MyWidgetState.loading()
    : status = WidgetStatus.loading,
      data = null,
      error = null,
      lastUpdated = null;

  MyWidgetState.success(dynamic data)
    : status = WidgetStatus.success,
      data = data,
      error = null,
      lastUpdated = DateTime.now();

  MyWidgetState.error(Failure error)
    : status = WidgetStatus.error,
      data = null,
      error = error,
      lastUpdated = DateTime.now();

  bool get isInitial => status == WidgetStatus.initial;
  bool get isLoading => status == WidgetStatus.loading;
  bool get isSuccess => status == WidgetStatus.success;
  bool get isError => status == WidgetStatus.error;

  T? getDataAs<T>() => data is T ? data as T : null;

  MyWidgetState copyWith({
    WidgetStatus? status,
    dynamic data,
    Failure? error,
    DateTime? lastUpdated,
  }) {
    return MyWidgetState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [status, data, error, lastUpdated];
}
