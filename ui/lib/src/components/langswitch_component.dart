import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';

class DashboardLanguageSwitchComponent extends StatelessWidget {
  const DashboardLanguageSwitchComponent({
    super.key,
    this.selectedLocale,
    this.onSwitchLanguage,
  });

  final Locale? selectedLocale;
  final Function(Locale)? onSwitchLanguage;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      tooltip: "User",
      offset: const Offset(0, 55),
      onSelected: onSwitchLanguage,
      itemBuilder: (BuildContext context) {
        return SettingsController.supportedLocales.map((locale) {
          return PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CountryFlag.fromCountryCode(
                  locale.countryCode ?? "",
                  height: 14,
                  width: 24,
                ),
                const SizedBox(width: 7),
                Text(LocaleNames.of(context)!.nameOf(locale.languageCode) ??
                    locale.toLanguageTag()),
              ],
            ),
          );
        }).toList();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CountryFlag.fromCountryCode(
            selectedLocale?.countryCode ?? "en",
            height: 14,
            width: 24,
          ),
          const SizedBox(width: 7),
          Text(LocaleNames.of(context)!
                  .nameOf(selectedLocale?.languageCode ?? "en") ??
              selectedLocale?.toLanguageTag() ??
              "EN"),
        ],
      ),
    );
  }
}
