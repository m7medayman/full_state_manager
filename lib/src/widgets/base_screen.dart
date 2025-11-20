// lib/src/widgets/base_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/base_cubit.dart';
import '../state/base_state.dart';
import '../state/data_state.dart';
import '../state/enums.dart';
import '../utils/failure.dart';

/// Abstract base screen that handles common UI patterns
abstract class BaseScreen<C extends BaseCubit<D>, D extends DataState>
    extends StatelessWidget {
  const BaseScreen({super.key});

  // ========== MUST IMPLEMENT ==========

  /// Build the main content of the screen
  Widget buildContent(BuildContext context, D data);

  // ========== OPTIONAL OVERRIDES ==========

  /// Build loading state (page-level)
  Widget buildPageLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            loadingMessage,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// Build error state (page-level)
  Widget buildPageError(BuildContext context, Failure failure) {
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
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            if (showRetryButton)
              ElevatedButton.icon(
                onPressed: () => onRetry(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }

  /// Build initial state
  Widget buildInitial(BuildContext context) {
    return const SizedBox.shrink();
  }

  /// Build refreshing indicator (shown during pull-to-refresh)
  Widget buildRefreshingIndicator(BuildContext context) {
    return const SizedBox.shrink(); // Return empty, RefreshIndicator handles it
  }

  // ========== CONFIGURATION ==========

  /// App bar for the screen
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  /// Floating action button
  Widget? buildFloatingActionButton(BuildContext context) => null;

  /// Bottom navigation bar
  Widget? buildBottomNavigationBar(BuildContext context) => null;

  /// Drawer
  Widget? buildDrawer(BuildContext context) => null;

  /// Background color
  Color? get backgroundColor => null;

  /// Enable safe area
  bool get useSafeArea => true;

  /// Show loading overlay instead of replacing content
  bool get useLoadingOverlay => false;

  /// Show error as dialog instead of replacing content
  bool get showErrorAsDialog => false;

  /// Show error as snackbar
  bool get showErrorAsSnackBar => false;

  /// Enable pull to refresh
  bool get enablePullToRefresh => false;

  /// Loading message
  String get loadingMessage => 'Loading...';

  /// Show retry button on error
  bool get showRetryButton => true;

  /// Resizes to avoid bottom inset (keyboard)
  bool get resizeToAvoidBottomInset => true;

  // ========== LIFECYCLE HOOKS ==========

  /// Called when page reaches success state
  void onPageSuccess(BuildContext context, D data) {}

  /// Called when page reaches error state
  void onPageError(BuildContext context, Failure failure) {}

  /// Called when page starts loading
  void onPageLoading(BuildContext context) {}

  /// Called when retry button is pressed
  void onRetry(BuildContext context) {
    // Override to implement retry logic
  }

  /// Called on pull to refresh
  Future<void> onRefresh(BuildContext context) async {
    // Override to implement refresh logic
  }

  // ========== BUILD METHOD ==========

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<C, BaseState<D>>(
      listener: (context, state) {
        _handleStateChanges(context, state);
      },
      builder: (context, state) {
        return Scaffold(
          appBar: buildAppBar(context),
          body: _buildBody(context, state),
          floatingActionButton: buildFloatingActionButton(context),
          bottomNavigationBar: buildBottomNavigationBar(context),
          drawer: buildDrawer(context),
          backgroundColor: backgroundColor,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BaseState<D> state) {
    Widget body;

    // Determine which widget to show based on page status
    if (useLoadingOverlay) {
      body = _buildContentWithOverlay(context, state);
    } else {
      body = _buildContentBasedOnStatus(context, state);
    }

    // Wrap with SafeArea if needed
    if (useSafeArea) {
      body = SafeArea(child: body);
    }

    // Wrap with RefreshIndicator if enabled
    if (enablePullToRefresh && !state.isPageLoading) {
      body = RefreshIndicator(
        onRefresh: () => onRefresh(context),
        child: body,
      );
    }

    return body;
  }

  Widget _buildContentBasedOnStatus(BuildContext context, BaseState<D> state) {
    switch (state.pageStatus) {
      case PageStatus.initial:
        return buildInitial(context);
      case PageStatus.loading:
        onPageLoading(context);
        return buildPageLoading(context);
      case PageStatus.error:
        if (state.pageError != null && !showErrorAsDialog && !showErrorAsSnackBar) {
          onPageError(context, state.pageError!);
          return buildPageError(context, state.pageError!);
        }
        return buildContent(context, state.data);
      case PageStatus.success:
      case PageStatus.refreshing:
        onPageSuccess(context, state.data);
        return buildContent(context, state.data);
    }
  }

  Widget _buildContentWithOverlay(BuildContext context, BaseState<D> state) {
    return Stack(
      children: [
        buildContent(context, state.data),
        if (state.isPageLoading)
          Container(
            color: Colors.black54,
            child: buildPageLoading(context),
          ),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, BaseState<D> state) {
    // Handle error as dialog
    if (showErrorAsDialog && state.isPageError && state.pageError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, state.pageError!);
      });
    }

    // Handle error as snackbar
    if (showErrorAsSnackBar && state.isPageError && state.pageError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(context, state.pageError!);
      });
    }

    // Handle success message
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
          if (showRetryButton)
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onRetry(context);
              },
              child: const Text('Retry'),
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
        action: showRetryButton
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => onRetry(context),
              )
            : null,
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