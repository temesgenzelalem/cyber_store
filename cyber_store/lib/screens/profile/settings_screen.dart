import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final localeProv = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr(context, 'Settings')),
      ),
      body: ListView(
        children: [
          _sectionTitle(context, 'Appearance'),
          SwitchListTile(
            title: const Text('Follow System Settings'),
            subtitle: const Text('Match the Light/Dark mode of your phone'),
            value: themeProv.useSystemTheme,
            onChanged: (val) => themeProv.setUseSystemTheme(val),
            activeColor: AppTheme.black,
          ),
          if (!themeProv.useSystemTheme) ...[
            _themeTile(context, themeProv, 'Light', 'light'),
            _themeTile(context, themeProv, 'Dark', 'dark'),
            _themeTile(context, themeProv, 'Midnight', 'midnight'),
            _themeTile(context, themeProv, 'Forest', 'forest'),
            _themeTile(context, themeProv, 'Sunset', 'sunset'),
          ],
          const Divider(),
          _sectionTitle(context, 'Language'),
          _langTile(context, localeProv, 'English', 'en'),
          _langTile(context, localeProv, 'Amharic', 'am'),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.grey600)),
  );

  Widget _themeTile(BuildContext context, ThemeProvider prov, String label, String value) =>
      RadioListTile<String>(
        title: Text(label),
        value: value,
        groupValue: prov.themeName,
        onChanged: (val) => prov.setTheme(val!),
        activeColor: AppTheme.black,
      );

  Widget _langTile(BuildContext context, LocaleProvider prov, String label, String code) =>
      RadioListTile<String>(
        title: Text(label),
        value: code,
        groupValue: prov.locale.languageCode,
        onChanged: (val) => prov.setLocale(Locale(val!)),
        activeColor: AppTheme.black,
      );
}
