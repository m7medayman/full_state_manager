// lib/src/widgets/screen_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/base_cubit.dart';
import '../state/base_state.dart';
import '../state/data_state.dart';
import '../state/enums.dart';
import '../utils/failure.dart';

/// Wrapper widget that can be used with regular StatelessWidget/StatefulWidget
class ScreenWrapper<C extends BaseCubit<D>, D extends DataState>
    extends StatelessWidget {
  final Widget Function(BuildContext context, D data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Failure failure)? errorBuilder;
  final bool showLoadingOverlay;
  final bool showErrorAsDialog;
  final bool showErrorAsSnackBar;
  final void Function(BuildContext context, BaseState<D> state)? listener;
  final String? loadingMessage;
  final bool Function(BaseState<D> previous, BaseState<D> current)?
      buildWhen;

  const ScreenWrapper({
    super.key,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.showLoadingOverlay = true,
    this.showErrorAsDialog = false,
    this.showErrorAsSnackBar = true,
    this.listener,
    this.loadingMessage,
    this.buildWhen,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<C, BaseState<D>>(
      listener: (context, state) {
        listener?.call(context, state);
        _handleSideEffects(context, state);
      },
      buildWhen: buildWhen,
      builder: (context, state) {
        if (showLoadingOverlay) {
          return _buildWithOverlay(context, state);
        } else {
          return _buildWithoutOverlay(context, state);
        }
      },
    );
  }

  Widget _buildWithOverlay(BuildContext context, BaseState<D> state) {
    return Stack(
      children: [
        builder(context, state.data),
        if (state.isPageLoading) _buildLoadingOverlay(context, state),
      ],
    );
  }

  Widget _buildWithoutOverlay(BuildContext context, BaseState<D> state) {
    if (state.isPageLoading) {
      return loadingBuilder?.call(context) ??
          _buildDefaultLoading(context);
    }

    if (state.isPageError &&
        state.pageError != null &&
        !showErrorAsDialog &&
        !showErrorAsSnackBar) {
      return errorBuilder?.call(context, state.pageError!) ??
          _buildDefaultError(context, state.pageError!);
    }

    return builder(context, state.data);
  }

  Widget _buildLoadingOverlay(BuildContext context, BaseState<D> state) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (loadingMessage != null || state.message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    state.message ?? loadingMessage ?? 'Loading...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            loadingMessage ?? 'Loading...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultError(BuildContext context, Failure failure) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              failure.message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSideEffects(BuildContext context, BaseState<D> state) {
    if (showErrorAsDialog && state.isPageError && state.pageError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, state.pageError!);
      });
    }

    if (showErrorAsSnackBar && state.isPageError && state.pageError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(context, state.pageError!);
      });
    }

    if (state.isPageSuccess && state.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessSnackBar(context, state.message!);
      });
    }
  }

  void _showErrorDialog(BuildContext context, Failure failure) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Error'),
        content: Text(failure.message),
        icon: Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failure.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}