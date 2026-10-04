class Validators {
  static bool isValidEmail(String email) {
    return RegExp(
            r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&\()*+/,:;<=>?@[\]^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$')
        .hasMatch(email.trim());
  }

  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10;
  }

  static bool isValidPostalCode(String code) {
    if (code.isEmpty) return false;
    final cleaned = code.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 3;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    if (!isValidPhone(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    return null;
  }

  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }
    if (!isValidPostalCode(value)) {
      return 'Please enter a valid postal code';
    }
    return null;
  }
}
