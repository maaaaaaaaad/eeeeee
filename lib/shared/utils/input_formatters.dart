class BusinessNumberFormatter {
  static final RegExp _withHyphens = RegExp(r'^\d{3}-\d{2}-\d{5}$');
  static final RegExp _withoutHyphens = RegExp(r'^\d{10}$');

  static bool isValid(String value) {
    return _withHyphens.hasMatch(value) || _withoutHyphens.hasMatch(value);
  }

  static String stripHyphens(String value) {
    return value.replaceAll('-', '');
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
}
