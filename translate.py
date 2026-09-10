import re

def replace_in_file(filepath, replacements):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Add imports
    if 'import \'package:doctor/core/localization/translation_keys.dart\';' not in content:
        content = content.replace('import \'package:flutter/material.dart\';', 'import \'package:doctor/core/localization/translation_keys.dart\';\nimport \'package:flutter/material.dart\';')

    for old, new in replacements:
        content = content.replace(old, new)
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

kick_replacements = [
    ("'Kick Counter'", 'TranslationKeys.kickCounterTitle.tr'),
    ("const Text('End Session')", 'Text(TranslationKeys.kickCounterEnd.tr)'),
    ("const Text(\n                'Start Session',", "Text(\n                TranslationKeys.kickCounterStart.tr,"),
    ("'Today\\'s Sessions'", 'TranslationKeys.kickCounterTodaysSessions.tr'),
    ("'No sessions recorded yet'", 'TranslationKeys.kickCounterNoSessions.tr'),
    ("\"Track your baby's movements today.\"", 'TranslationKeys.kickCounterNoSessionsDesc.tr'),
    ("const Text('History')", 'Text(TranslationKeys.kickCounterHistory.tr)'),
    ("'Loading kick data...'", 'TranslationKeys.commonLoading.tr'),
    ("'Something went wrong'", 'TranslationKeys.commonSomethingWentWrong.tr'),
    ("const Text('Try Again')", 'Text(TranslationKeys.commonTryAgain.tr)'),
]
replace_in_file(r'c:\Users\HP\Desktop\Flutter\doctor\lib\patient\features\kick_counter\screens\kick_counter_screen.dart', kick_replacements)

water_replacements = [
    ("'Water Intake'", 'TranslationKeys.waterIntakeTitle.tr'),
    ("'Hydration Tracker'", 'TranslationKeys.waterHydrationTracker.tr'),
    ("'Goal Progress'", 'TranslationKeys.waterGoalProgress.tr'),
    ("'No water logged yet'", 'TranslationKeys.waterNoLog.tr'),
    ("const Text('History')", 'Text(TranslationKeys.waterHistory.tr)'),
    ("const Text('View History')", 'Text(TranslationKeys.waterViewHistory.tr)'),
    ("const Text('Add Glass')", 'Text(TranslationKeys.waterAddGlass.tr)'),
    ("'Daily Goal'", 'TranslationKeys.waterDailyGoal.tr'),
    ("'Glasses Consumed'", 'TranslationKeys.waterGlassesConsumed.tr'),
    ("'Loading...'", 'TranslationKeys.commonLoading.tr'),
    ("'Something went wrong'", 'TranslationKeys.commonSomethingWentWrong.tr'),
    ("const Text('Try Again')", 'Text(TranslationKeys.commonTryAgain.tr)'),
]
replace_in_file(r'c:\Users\HP\Desktop\Flutter\doctor\lib\patient\features\water_intake\screens\water_intake_screen.dart', water_replacements)

symptom_replacements = [
    ("'Symptoms'", 'TranslationKeys.symptomsTitle.tr'),
    ("'Add Symptom'", 'TranslationKeys.symptomsAdd.tr'),
    ("'No logs yet'", 'TranslationKeys.symptomsNoLogs.tr'),
    ("'Log your symptoms to track your health.'", 'TranslationKeys.symptomsNoLogsDesc.tr'),
    ("'Loading...'", 'TranslationKeys.symptomsLoading.tr'),
    ("'Log Symptom'", 'TranslationKeys.symptomsLogSymptom.tr'),
    ("'Select Date'", 'TranslationKeys.symptomsSelectDate.tr'),
    ("'Notes'", 'TranslationKeys.symptomsNotes.tr'),
    ("'Add any additional notes here'", 'TranslationKeys.symptomsNotesHint.tr'),
    ("'Something went wrong'", 'TranslationKeys.commonSomethingWentWrong.tr'),
    ("const Text('Try Again')", 'Text(TranslationKeys.commonTryAgain.tr)'),
    ("const Text('Save')", 'Text(TranslationKeys.commonSave.tr)'),
    ("const Text('Cancel')", 'Text(TranslationKeys.commonCancel.tr)'),
]
replace_in_file(r'c:\Users\HP\Desktop\Flutter\doctor\lib\patient\features\symptoms\screens\symptoms_screen.dart', symptom_replacements)
