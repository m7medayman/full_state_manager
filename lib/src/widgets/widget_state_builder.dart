// lib/src/widgets/widget_state_builder.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/base_cubit.dart';
import '../state/base_state.dart';
import '../state/data_state.dart';
import '../state/enums.dart';
import '../utils/failure.dart';

/// Builder widget for individual widget states
class WidgetStateBuilder<C extends BaseCubit<D>, D extends DataState, T>
    extends StatelessWidget {
  final String widgetKey;
  final Widget Function(BuildContext context, T data) onSuccess;
  final Widget Function(BuildContext context)? onLoading;
  final Widget Function(BuildContext context, Failure failure)? onError;
  final Widget Function(BuildContext context)? onInitial;
  final bool Function(BaseState<D> previous, BaseState<D> current)?
      buildWhen;

  const WidgetStateBuilder({
    super.key,
    required this.widgetKey,
    required this.onSuccess,
    this.onLoading,
    this.onError,
    this.onInitial,
    this.buildWhen,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, BaseState<D>>(
      buildWhen: buildWhen ??
          (previous, current) {
            return previous.getWidgetState(widgetKey) !=
                current.getWidgetState(widgetKey);
          },
      builder: (context, state) {
        final widgetState = state.getWidgetState(widgetKey);

        if (widgetState == null || widgetState.isInitial) {
          return onInitial?.call(context) ?? const SizedBox.shrink();
        }

        if (widgetState.isLoading) {
          return onLoading?.call(context) ?? _defaultLoadingWidget();
        }

        if (widgetState.isError) {
          return onError?.call(context, widgetState.error!) ??
              _defaultErrorWidget(context, widgetState.error!);
        }

        if (widgetState.isSuccess && widgetState.data != null) {
          final data = widgetState.data;
          if (data is T) {
            return onSuccess(context, data);
          } else {
            return _defaultErrorWidget(
              context,
              const ValidationFailure(
                message: 'Invalid data type received',
              ),
            );
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _defaultLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _defaultErrorWidget(BuildContext context, Failure failure) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}