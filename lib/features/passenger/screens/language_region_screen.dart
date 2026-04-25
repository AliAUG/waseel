import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_settings_strings.dart';

void _pickLanguage(
  BuildContext context,
  SettingsProvider settings,
  AppLanguage lang,
  PassengerSettingsStrings s,
) {
  if (settings.language == lang) return;
  settings.setLanguage(lang);
  final auth = context.read<AuthProvider>();
  final t = auth.token;
  if (t == null || t.isEmpty || t == 'local-session') return;
  unawaited(() async {
    final ok = await settings.saveLanguageRegionToServer(t);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.couldNotSaveLanguage)),
      );
    }
  }());
}

class LanguageRegionScreen extends StatelessWidget {
  const LanguageRegionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final s = PassengerSettingsStrings(settings.language);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: Colors.grey.shade800,
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              s.languageRegionScreenTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.languageSection,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                _LanguageOption(
                  title: s.englishTitle,
                  subtitle: s.englishSub,
                  isSelected: settings.language == AppLanguage.english,
                  onTap: () => _pickLanguage(
                    context,
                    settings,
                    AppLanguage.english,
                    s,
                  ),
                ),
                const SizedBox(height: 8),
                _LanguageOption(
                  title: s.arabicTitle,
                  subtitle: s.arabicSub,
                  isSelected: settings.language == AppLanguage.arabic,
                  onTap: () => _pickLanguage(
                    context,
                    settings,
                    AppLanguage.arabic,
                    s,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  s.regionSection,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                _RegionOption(
                  country: s.lebanon,
                  flag: '🇱🇧',
                  subtitle: s.lebanonCurrencySub,
                  isSelected: true,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Text(
                    s.languageHint,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(s.languageRegionDone),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
          ],
        ),
      ),
    );
  }
}

class _RegionOption extends StatelessWidget {
  const _RegionOption({
    required this.country,
    required this.flag,
    required this.subtitle,
    required this.isSelected,
  });

  final String country;
  final String flag;
  final String subtitle;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryTeal : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
        ],
      ),
    );
  }
}
