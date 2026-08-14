import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/providers.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'Home': 'Home',
      'Products': 'Products',
      'Cart': 'Cart',
      'Account': 'Account',
      'Settings': 'Settings',
      'Buy Now': 'Buy Now',
      'Search': 'Search',
      'Categories': 'Categories',
    },
    'am': {
      'Home': 'ቤት',
      'Products': 'ምርቶች',
      'Cart': 'ቅርጫት',
      'Account': 'መገለጫ',
      'Settings': 'ቅንብሮች',
      'Buy Now': 'አሁኑኑ ይግዙ',
      'Search': 'ፈልግ',
      'Categories': 'ምድቦች',
    },
  };

  static String tr(BuildContext context, String key) {
    final locale = Provider.of<LocaleProvider>(context).locale;
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ?? key;
  }
}
