// lib/src/utils/optional.dart

/// Wrapper class to explicitly handle null values in copyWith methods
class Optional<T> {
  final T? _value;
  final bool _isSet;

  const Optional._(this._value, this._isSet);

  /// Create an Optional with a value
  const Optional.value(T value)
      : _value = value,
        _isSet = true;

  /// Create an Optional with null (to clear a field)
  const Optional.null_()
      : _value = null,
        _isSet = true;

  /// Create an Optional that's not set (field won't be updated)
  const Optional.unset()
      : _value = null,
        _isSet = false;

  bool get isSet => _isSet;
  T? get value => _value;

  @override
  String toString() => _isSet ? 'Optional.value($_value)' : 'Optional.unset()';
}