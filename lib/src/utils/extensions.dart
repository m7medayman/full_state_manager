// lib/src/utils/extensions.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/base_cubit.dart';
import '../state/data_state.dart';

/// Extension on BuildContext for easy Cubit access
extension CubitExtension on BuildContext {
  /// Get cubit without listening
  C cubit<C extends BaseCubit<D>, D extends DataState>() {
    return read<C>();
  }

  /// Get cubit and listen to changes
  C watchCubit<C extends BaseCubit<D>, D extends DataState>() {
    return watch<C>();
  }
}

/// Extension for common patterns
extension DataStateExtension<T extends DataState> on T {
  /// Check if data is empty (override in your data state)
  bool get isEmpty => false;

  /// Check if data is not empty
  bool get isNotEmpty => !isEmpty;
}