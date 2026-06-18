abstract class Parse {
  static int toIntValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? -1;
    }
    return -1;
  }

  static double toDoubleValue(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }
    if (value is String) {
      return double.tryParse(value) ?? -1;
    }
    return -1;
  }

  static String toStringValue(dynamic value) {
    if (value is int) {
      return value.toString();
    }
    if (value is double) {
      return value.toString();
    }
    if (value is String) {
      return value;
    }
    return '';
  }

  static bool toBoolValue(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is int) {
      return value == BoolType.boolTypeTrue.index;
    }
    return false;
  }

  /// Check condition by int type
  /// false = 0, true = 1
  static int toBoolByInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return BoolType.boolTypeTrue.index;
  }

  static num? toNumValue(dynamic value) {
    if (value is int || value is double) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value);
    }
    return 0;
  }

  static String roundThreeDoubleValue(double value) {
    final double rounded = value * 100 * 1000;
    return (rounded.round() / 1000).toString();
  }
}

enum BoolType { boolTypeInvalid, boolTypeFalse, boolTypeTrue }
