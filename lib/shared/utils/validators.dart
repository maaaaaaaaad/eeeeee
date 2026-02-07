class ShopNameValidator {
  static const int minLength = 2;
  static const int maxLength = 50;

  static String? validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '샵 이름을 입력해주세요';
    if (trimmed.length < minLength) return '샵 이름은 $minLength자 이상이어야 합니다';
    if (trimmed.length > maxLength) return '샵 이름은 $maxLength자 이하여야 합니다';
    return null;
  }
}

class BusinessNumberValidator {
  static final RegExp _withHyphens = RegExp(r'^\d{3}-\d{2}-\d{5}$');
  static final RegExp _withoutHyphens = RegExp(r'^\d{10}$');

  static String? validate(String value) {
    if (value.isEmpty) return '사업자등록번호를 입력해주세요';
    if (!_withHyphens.hasMatch(value) && !_withoutHyphens.hasMatch(value)) {
      return '올바른 사업자등록번호를 입력해주세요 (10자리)';
    }
    return null;
  }
}

class PhoneNumberValidator {
  static final RegExp _withHyphens = RegExp(r'^01[016789]-\d{3,4}-\d{4}$');
  static final RegExp _withoutHyphens = RegExp(r'^01[016789]\d{7,8}$');

  static String? validate(String value) {
    if (value.isEmpty) return '전화번호를 입력해주세요';
    if (!_withHyphens.hasMatch(value) && !_withoutHyphens.hasMatch(value)) {
      return '올바른 전화번호를 입력해주세요';
    }
    return null;
  }
}

class AddressValidator {
  static String? validate(String value) {
    if (value.trim().isEmpty) return '주소를 입력해주세요';
    return null;
  }
}

class CoordinateValidator {
  static String? validateLatitude(String value) {
    if (value.isEmpty) return '위도를 입력해주세요';
    final parsed = double.tryParse(value);
    if (parsed == null) return '숫자를 입력해주세요';
    if (parsed < -90 || parsed > 90) return '위도는 -90 ~ 90 범위여야 합니다';
    return null;
  }

  static String? validateLongitude(String value) {
    if (value.isEmpty) return '경도를 입력해주세요';
    final parsed = double.tryParse(value);
    if (parsed == null) return '숫자를 입력해주세요';
    if (parsed < -180 || parsed > 180) return '경도는 -180 ~ 180 범위여야 합니다';
    return null;
  }
}

class TreatmentNameValidator {
  static const int minLength = 2;
  static const int maxLength = 50;

  static String? validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '시술명을 입력해주세요';
    if (trimmed.length < minLength) return '시술명은 $minLength자 이상이어야 합니다';
    if (trimmed.length > maxLength) return '시술명은 $maxLength자 이하여야 합니다';
    return null;
  }
}

class PriceValidator {
  static String? validate(String value) {
    if (value.isEmpty) return '가격을 입력해주세요';
    final parsed = int.tryParse(value);
    if (parsed == null) return '숫자를 입력해주세요';
    if (parsed < 0) return '가격은 0 이상이어야 합니다';
    return null;
  }
}

class DurationValidator {
  static const int minMinutes = 10;
  static const int maxMinutes = 300;

  static String? validate(String value) {
    if (value.isEmpty) return '소요시간을 입력해주세요';
    final parsed = int.tryParse(value);
    if (parsed == null) return '숫자를 입력해주세요';
    if (parsed < minMinutes) return '소요시간은 $minMinutes분 이상이어야 합니다';
    if (parsed > maxMinutes) return '소요시간은 $maxMinutes분 이하여야 합니다';
    return null;
  }
}

class DescriptionValidator {
  static const int maxLength = 500;

  static String? validate(String value) {
    if (value.isEmpty) return null;
    if (value.length > maxLength) return '설명은 $maxLength자 이하여야 합니다';
    return null;
  }
}

class ImageUrlValidator {
  static String? validate(String value) {
    if (value.isEmpty) return 'URL을 입력해주세요';
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return '올바른 URL을 입력해주세요 (http:// 또는 https://)';
    }
    return null;
  }
}
