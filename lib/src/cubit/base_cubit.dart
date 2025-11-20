// lib/src/cubit/base_cubit.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/base_state.dart';
import '../state/data_state.dart';
import '../state/enums.dart';
import '../state/widget_state.dart';
import '../utils/failure.dart';

/// Base Cubit with unified state management
abstract class BaseCubit<T extends DataState> extends Cubit<BaseState<T>> {
  BaseCubit(T initialData) : super(BaseState<T>.initial(initialData));

  // ========== PAGE-LEVEL OPERATIONS ==========

  /// Emit page loading state
  void emitPageLoading({String? message}) {
    emit(state.copyWith(
      pageStatus: PageStatus.loading,
      message: message,
      clearPageError: true,
    ));
  }

  /// Emit page refreshing state (for pull-to-refresh)
  void emitPageRefreshing({String? message}) {
    emit(state.copyWith(
      pageStatus: PageStatus.refreshing,
      message: message,
      clearPageError: true,
    ));
  }

  /// Emit page success state
  void emitPageSuccess({String? message, T? data}) {
    emit(state.copyWith(
      pageStatus: PageStatus.success,
      message: message,
      data: data,
      clearPageError: true,
    ));
  }

  /// Emit page error state
  void emitPageError(Failure failure, {String? message}) {
    emit(state.copyWith(
      pageStatus: PageStatus.error,
      pageError: failure,
      message: message,
    ));
  }

  /// Reset page to initial state
  void resetPageState() {
    emit(state.copyWith(
      pageStatus: PageStatus.initial,
      clearPageError: true,
      clearMessage: true,
    ));
  }

  // ========== WIDGET-LEVEL OPERATIONS ==========

  /// Emit widget loading state
  void emitWidgetLoading(String key) {
    emit(state.updateWidgetState(key, const MyWidgetState.loading()));
  }

  /// Emit widget success state
  void emitWidgetSuccess(String key, dynamic data) {
    emit(state.updateWidgetState(key, MyWidgetState.success(data)));
  }

  /// Emit widget error state
  void emitWidgetError(String key, Failure error) {
    emit(state.updateWidgetState(key, MyWidgetState.error(error)));
  }

  /// Reset widget to initial state
  void resetWidgetState(String key) {
    emit(state.updateWidgetState(key, const MyWidgetState.initial()));
  }

  /// Remove widget state
  void removeWidgetState(String key) {
    emit(state.removeWidgetState(key));
  }

  /// Emit multiple widgets loading
  void emitMultipleWidgetsLoading(List<String> keys) {
    final Map<String, MyWidgetState> newStates = {};
    for (final key in keys) {
      newStates[key] = const MyWidgetState.loading();
    }
    emit(state.updateWidgetStates(newStates));
  }

  /// Clear all widget states
  void clearAllWidgetStates() {
    emit(state.clearWidgetStates());
  }

  // ========== DATA OPERATIONS ==========

  /// Update data using a function
  void updateData(T Function(T currentData) updater) {
    final newData = updater(state.data);
    emit(state.copyWith(data: newData));
  }

  /// Update data directly
  void setData(T data) {
    emit(state.copyWith(data: data));
  }

  /// Reset data to initial state
  void resetData(T initialData) {
    emit(state.copyWith(data: initialData));
  }

  // ========== API CALL WRAPPERS ==========

  /// Execute API call with page-level state management
  Future<Either<Failure, R>> executePageApiCall<R>({
    required Future<Either<Failure, R>> Function() apiCall,
    String? loadingMessage,
    String? successMessage,
    void Function(R data)? onSuccess,
    void Function(Failure failure)? onError,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        emitPageLoading(message: loadingMessage);
      }

      final result = await apiCall();

      return result.fold(
        (failure) {
          emitPageError(failure);
          onError?.call(failure);
          return Left(failure);
        },
        (data) {
          emitPageSuccess(message: successMessage);
          onSuccess?.call(data);
          return Right(data);
        },
      );
    } catch (e, stackTrace) {
      final failure = UnknownFailure(
        message: 'An unexpected error occurred',
        originalError: e,
        stackTrace: stackTrace,
      );
      emitPageError(failure);
      onError?.call(failure);
      return Left(failure);
    }
  }

  /// Execute API call with widget-level state management
  Future<Either<Failure, R>> executeWidgetApiCall<R>({
    required String widgetKey,
    required Future<Either<Failure, R>> Function() apiCall,
    void Function(R data)? onSuccess,
    void Function(Failure failure)? onError,
    bool saveDataToWidget = true,
  }) async {
    try {
      emitWidgetLoading(widgetKey);

      final result = await apiCall();

      return result.fold(
        (failure) {
          emitWidgetError(widgetKey, failure);
          onError?.call(failure);
          return Left(failure);
        },
        (data) {
          if (saveDataToWidget) {
            emitWidgetSuccess(widgetKey, data);
          } else {
            resetWidgetState(widgetKey);
          }
          onSuccess?.call(data);
          return Right(data);
        },
      );
    } catch (e, stackTrace) {
      final failure = UnknownFailure(
        message: 'An unexpected error occurred',
        originalError: e,
        stackTrace: stackTrace,
      );
      emitWidgetError(widgetKey, failure);
      onError?.call(failure);
      return Left(failure);
    }
  }

  /// Execute multiple widget API calls concurrently
  Future<Map<String, Either<Failure, dynamic>>> executeMultipleWidgetApiCalls(
    Map<String, Future<Either<Failure, dynamic>> Function()> apiCalls,
  ) async {
    // Set all to loading
    emitMultipleWidgetsLoading(apiCalls.keys.toList());

    final results = <String, Either<Failure, dynamic>>{};

    await Future.wait(
      apiCalls.entries.map((entry) async {
        final key = entry.key;
        final apiCall = entry.value;

        try {
          final result = await apiCall();
          results[key] = result;

          result.fold(
            (failure) => emitWidgetError(key, failure),
            (data) => emitWidgetSuccess(key, data),
          );
        } catch (e, stackTrace) {
          final failure = UnknownFailure(
            message: 'An unexpected error occurred',
            originalError: e,
            stackTrace: stackTrace,
          );
          emitWidgetError(key, failure);
          results[key] = Left(failure);
        }
      }),
    );

    return results;
  }

  // ========== LIFECYCLE ==========

  @override
  Future<void> close() {
    // Override to add cleanup logic
    return super.close();
  }
}