// lib/src/state/data_state.dart

import '../utils/optional.dart';

/// Abstract base class for data state
/// Extend this class to create your own data state with specific fields
abstract class DataState {
  const DataState();

  /// Override this to implement copyWith with Optional support
  DataState copyWith();

  /// Override this to support nullable updates
  DataState copyWithOptional();

  /// Reset to initial state
  DataState reset();
}

/// Default empty data state
class EmptyDataState extends DataState {
  const EmptyDataState();

  @override
  DataState copyWith() => this;

  @override
  DataState copyWithOptional() => this;

  @override
  DataState reset() => this;
}