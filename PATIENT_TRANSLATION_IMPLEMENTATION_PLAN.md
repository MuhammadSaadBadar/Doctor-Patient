# Patient Translation Implementation Plan

## Findings

- Localization is centralized in `lib/core/localization/translation_keys.dart` and `app_translations.dart` using GetX keys.
- Several patient screens already use keys, but adjacent screens still contain English literals.
- Appointment booking/detail/reschedule is the highest-impact gap: labels, empty/loading states, payment text, action buttons, and controller messages bypass localization.
- Urdu entries exist for the current key set, but newly discovered literals have no key or Urdu value.
- Some model/controller display getters also return English directly, so screen-only replacement is not sufficient for status and payment labels.

## Implementation Phases

1. **Appointment workflow**: add shared keys and Urdu/English values; migrate appointment list, booking, detail, reschedule, filter labels, and appointment display getters.
2. **Doctor discovery and booking entry**: migrate doctor search/detail screens and reusable doctor widgets; add parameterized keys for counts and doctor names.
3. **Health tracking modules**: migrate water intake, kick counter, vitals, symptoms, surgical history, and exercise screens/widgets.
4. **Medication, emergency, and profile modules**: migrate medicine reminders, SOS/emergency, and remaining settings/profile surfaces.
5. **Parity validation**: add a key-parity check so every `TranslationKeys` constant has both English and Urdu values, then run analyzer and widget tests in English and Urdu locales.

## Current Slice

Phase 1 is being implemented first because it is a complete user journey and has existing key conventions to extend. The appointment and doctor discovery/detail screens are now migrated, including model status/payment labels, filters, dialogs, loading/error/empty states, and dynamic placeholders. Each phase should preserve API/domain strings, use placeholders for dynamic values, and keep English and Urdu maps synchronized.

## Validation

- Run `flutter analyze` after each module slice.
- Add or update widget tests for locale-sensitive labels where practical.
- Manually verify RTL layout and dynamic placeholder replacement in Urdu.
