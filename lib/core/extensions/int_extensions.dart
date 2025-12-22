extension IntIsBetween on int {
  /// Checks if the integer is between [min] and [max] (inclusive).
  bool isBetween(int min, int max) {
    return this >= min && this <= max;
  }
}

extension IntToPercentage on int {
  /// Converts the integer to a percentage string based on [total],
  /// with [decimalPlaces] specifying the number of decimal places to include.
  String toPercentage({int total = 100, int decimalPlaces = 0}) {
    final double percentage = (this / total) * 100;
    return '${percentage.toStringAsFixed(decimalPlaces)}%';
  }
}

extension IntToHoursMinutes on int {
  /// Converts the integer (representing minutes) to a string formatted as hours and minutes.
  /// For example, 125 minutes would become "2.5" (2 hours and 5 minutes).
  String get minutesToHoursAndMinutes {
    final hours = this ~/ 60;
    final minutes = this % 60;
    return '$hours.$minutes';
  }
}

extension IntSignCheck on int {
  /// Returns `true` if the integer is positive (greater than 0).
  bool get isPositive => this > 0;

  /// Returns `true` if the integer is negative (less than 0).
  bool get isNegative => this < 0;
}

extension IntIsIn on int {
  /// Checks if the integer exists within the provided list [list].
  bool isIn(List<int> list) => list.contains(this);
}

extension IntToDateTime on int {
  /// Converts the integer (representing a Unix timestamp in seconds) to a [DateTime] object.
  DateTime get toDateTimeFromUnix =>
      DateTime.fromMillisecondsSinceEpoch(this * 1000);
}

extension IntFormatWithCommas on int {
  /// Formats the integer with commas as thousand separators.
  /// For example, 1000000 becomes "1,000,000".
  String get formatWithCommas {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

extension IntToOrdinal on int {
  /// Converts the integer to its ordinal form.
  /// For example, 1 becomes "1st", 2 becomes "2nd", 3 becomes "3rd", etc.
  String get toOrdinal {
    if (this % 100 >= 11 && this % 100 <= 13) {
      return '${this}th';
    }
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }
}

extension IntToRomanNumeral on int {
  /// Converts the integer to its Roman numeral representation.
  /// For example, 4 becomes "IV", 9 becomes "IX", 13 becomes "XIII", etc.
  String get toRomanNumeral {
    if (this <= 0) return '';
    final Map<int, String> romanNumerals = {
      1000: 'M',
      900: 'CM',
      500: 'D',
      400: 'CD',
      100: 'C',
      90: 'XC',
      50: 'L',
      40: 'XL',
      10: 'X',
      9: 'IX',
      5: 'V',
      4: 'IV',
      1: 'I',
    };

    int num = this;
    final StringBuffer result = StringBuffer();
    romanNumerals.forEach((value, numeral) {
      while (num >= value) {
        result.write(numeral);
        num -= value;
      }
    });
    return result.toString();
  }
}

extension IntAsTimeAgo on int {
  /// Converts the integer (representing a Unix timestamp in milliseconds) to a human-readable
  /// time ago format. It returns "Yesterday," "Today," "Last week," or "Last year" when applicable.
  String asTimeAgo() {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(this);
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays > 1 ? "s" : ""} ago';
    } else if (diff.inDays < 14) {
      return 'Last week';
    } else if (now.year == date.year) {
      return '${(diff.inDays / 7).round()} week${(diff.inDays / 7).round() > 1 ? "s" : ""} ago';
    } else if (diff.inDays < 365) {
      return 'Last year';
    } else {
      return '${diff.inDays ~/ 365} year${(diff.inDays ~/ 365) > 1 ? "s" : ""} ago';
    }
  }
}
