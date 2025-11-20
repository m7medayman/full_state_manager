// lib/src/state/enums.dart

/// Page-level status
enum PageStatus {
  initial,
  loading,
  success,
  error,
  refreshing, // For pull-to-refresh scenarios
}

/// Widget-level status
enum WidgetStatus {
  initial,
  loading,
  success,
  error,
}

/// Dialog types for UI feedback
enum DialogType {
  success,
  error,
  warning,
  info,
  confirmation,
}