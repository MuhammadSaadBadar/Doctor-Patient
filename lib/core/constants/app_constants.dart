// ============================================================================
// app_constants.dart — App-wide constants for dropdowns, enums, etc.
// ============================================================================

class AppConstants {
  AppConstants._();

  // Doctor Specializations
  static const List<String> doctorSpecializations = [
    'Cardiology',
    'Neurology',
    'Pediatrics',
    'General Practice',
    'OB-GYN',
    'Orthopedics',
    'Dermatology',
    'Psychiatry',
    'Radiology',
    'Anesthesiology',
    'Emergency Medicine',
    'Family Medicine',
    'Internal Medicine',
    'Ophthalmology',
    'Otolaryngology',
    'Pathology',
    'Physical Medicine & Rehabilitation',
    'Plastic Surgery',
    'Preventive Medicine',
    'Urology',
  ];

  // Cities (matching backend fixed dropdown values - lowercase as per API)
  static const List<String> cities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Hyderabad',
    'Peshawar',
    'Quetta',
    'Gujranwala',
    'Sialkot',
    'Bahawalpur',
    'Sargodha',
    'Sukkur',
    'Other',
  ];

  // City values as expected by API (lowercase)
  static const Map<String, String> cityApiValues = {
    'Karachi': 'karachi',
    'Lahore': 'lahore',
    'Islamabad': 'islamabad',
    'Rawalpindi': 'rawalpindi',
    'Faisalabad': 'faisalabad',
    'Multan': 'multan',
    'Hyderabad': 'hyderabad',
    'Peshawar': 'peshawar',
    'Quetta': 'quetta',
    'Gujranwala': 'gujranwala',
    'Sialkot': 'sialkot',
    'Bahawalpur': 'bahawalpur',
    'Sargodha': 'sargodha',
    'Sukkur': 'sukkur',
    'Other': 'other',
  };

  // Get API value for city
  static String getCityApiValue(String displayName) {
    return cityApiValues[displayName]?.toLowerCase() ?? displayName.toLowerCase();
  }

  // Default specialization
  static const String defaultSpecialization = 'General Practice';

  // Default city
  static const String defaultCity = 'Islamabad';
}