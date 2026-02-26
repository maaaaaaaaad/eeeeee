class BusinessNumberFormatter {
  static final RegExp _withHyphens = RegExp(r'^\d{3}-\d{2}-\d{5}$');
  static final RegExp _withoutHyphens = RegExp(r'^\d{10}$');

  static bool isValid(String value) {
    return _withHyphens.hasMatch(value) || _withoutHyphens.hasMatch(value);
  }

  static String stripHyphens(String value) {
    return value.replaceAll('-', '');
  }

  static String formatWithHyphens(String value) {
    final digits = value.replaceAll('-', '');
    if (digits.length != 10) return value;
    return '${digits.substring(0, 3)}-${digits.substring(3, 5)}-${digits.substring(5)}';
  }
}

class PhoneNumberFormatter {
  static final RegExp _withHyphens = RegExp(r'^01[016789]-\d{3,4}-\d{4}$');
  static final RegExp _withoutHyphens = RegExp(r'^01[016789]\d{7,8}$');

  static bool isValid(String value) {
    return _withHyphens.hasMatch(value) || _withoutHyphens.hasMatch(value);
  }

  static String stripHyphens(String value) {
    return value.replaceAll('-', '');
  }

  static String formatWithHyphens(String value) {
    final digits = value.replaceAll('-', '');
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return value;
  }
}
