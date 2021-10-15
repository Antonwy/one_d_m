import "package:charcode/charcode.dart";

class Currency {
  final num _number;

  Currency._(this._number);

  /// Create [Currency] class.
  ///
  /// The Factory create a [Currency] class instance.
  ///
  /// [Currency] is num [Type].
  ///
  /// return [Currency] instance.
  factory Currency(num amount) {
    // assert(
    // Currency is num, 'The data to be processed must be passed in a [num].');

    return Currency._(amount);
  }

  /// Get a [number] for double value.
  ///
  /// Get the [_number] to [double] Type value.
  double get number => _number.toDouble();

  /// Format [number] to beautiful [String].
  ///
  /// E.g:
  /// ```dart
  /// Numeral(1000).value(); // -> 1K
  /// ```
  ///
  /// return a [String] type.
  String value() {
    // Formated value.
    var value = number;
    var absolute = number.abs();

    // String suffix.
    var abbr = '';

    // If number > 1 trillion.
    if (absolute >= 100) {
      value = number / 100;
      abbr = ' ${String.fromCharCode($euro)}';

      // If number > 1 billion.
    } else if (absolute < 100) {
      value = number;
      abbr = ' Cent';
    }

    return _removeEndsZore(value.toStringAsFixed(1)) + abbr;
  }

  /// Remove value ends with zore.
  ///
  /// Remove formated value ends with zore,
  /// replace to zore string.
  ///
  /// [value] type is [String].
  ///
  /// return a [String] type.
  String _removeEndsZore(String value) {
    if (value.length == 1) {
      return value;
    } else if (value.endsWith('.')) {
      return value.substring(0, value.length - 1);
    } else if (value.endsWith('0')) {
      return _removeEndsZore(value.substring(0, value.length - 1));
    }

    return value;
  }

  /// Get formated value.
  ///
  /// Get the [value] function value.
  ///
  /// return a [String] type.
  @override
  String toString() => value();
}
