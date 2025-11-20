// lib/src/state/base_state.dart

import 'package:equatable/equatable.dart';
import '../utils/failure.dart';
import 'data_state.dart';
import 'enums.dart';
import 'widget_state.dart';

/// Unified state that manages page status, widget states, and data
class BaseState<T extends DataState> extends Equatable {
  /// Overall page status
  final PageStatus pageStatus;

  /// Page-level error
  final Failure? pageError;

  /// Individual widget states keyed by identifier
  final Map<String, MyWidgetState> widgetStates;

  /// Application data state
  final T data;

  /// Optional message for success/loading states
  final String? message;

  /// Timestamp of last state change
  final DateTime lastUpdated;

   BaseState({
    required this.pageStatus,
    required this.data,
    this.pageError,
    this.widgetStates = const {},
    this.message,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Initial state factory
  factory BaseState.initial(T initialData) {
    return BaseState<T>(
      pageStatus: PageStatus.initial,
      data: initialData,
      lastUpdated: DateTime.now(),
    );
  }

  // Page status checkers
  bool get isPageInitial => pageStatus == PageStatus.initial;
  bool get isPageLoading => pageStatus == PageStatus.loading;
  bool get isPageSuccess => pageStatus == PageStatus.success;
  bool get isPageError => pageStatus == PageStatus.error;
  bool get isPageRefreshing => pageStatus == PageStatus.refreshing;

  // Widget state helpers
  bool isWidgetLoading(String key) => widgetStates[key]?.isLoading ?? false;

  bool isWidgetSuccess(String key) => widgetStates[key]?.isSuccess ?? false;

  bool isWidgetError(String key) => widgetStates[key]?.isError ?? false;

  MyWidgetState? getWidgetState(String key) => widgetStates[key];

  D? getWidgetData<D>(String key) => widgetStates[key]?.getDataAs<D>();

  bool get hasAnyWidgetLoading =>
      widgetStates.values.any((state) => state.isLoading);

  List<String> get loadingWidgetKeys => widgetStates.entries
      .where((entry) => entry.value.isLoading)
      .map((entry) => entry.key)
      .toList();

  BaseState<T> copyWith({
    PageStatus? pageStatus,
    Failure? pageError,
    Map<String, MyWidgetState>? widgetStates,
    T? data,
    String? message,
    bool clearPageError = false,
    bool clearMessage = false,
  }) {
    return BaseState<T>(
      pageStatus: pageStatus ?? this.pageStatus,
      pageError: clearPageError ? null : (pageError ?? this.pageError),
      widgetStates: widgetStates ?? this.widgetStates,
      data: data ?? this.data,
      message: clearMessage ? null : (message ?? this.message),
      lastUpdated: DateTime.now(),
    );
  }

  /// Update a specific widget state
  BaseState<T> updateWidgetState(String key, MyWidgetState state) {
    final newWidgetStates = Map<String, MyWidgetState>.from(widgetStates);
    newWidgetStates[key] = state;
    return copyWith(widgetStates: newWidgetStates);
  }

  /// Remove a widget state
  BaseState<T> removeWidgetState(String key) {
    final newWidgetStates = Map<String, MyWidgetState>.from(widgetStates);
    newWidgetStates.remove(key);
    return copyWith(widgetStates: newWidgetStates);
  }

  /// Update multiple widget states
  BaseState<T> updateWidgetStates(Map<String, MyWidgetState> states) {
    final newWidgetStates = Map<String, MyWidgetState>.from(widgetStates);
    newWidgetStates.addAll(states);
    return copyWith(widgetStates: newWidgetStates);
  }

  /// Clear all widget states
  BaseState<T> clearWidgetStates() {
    return copyWith(widgetStates: {});
  }

  @override
  List<Object?> get props => [
    pageStatus,
    pageError,
    widgetStates,
    data,
    message,
    lastUpdated,
  ];
}
