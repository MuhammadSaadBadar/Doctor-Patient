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

book_apt = [
    ("'Book Appointment'", 'TranslationKeys.bookingBookAppointment.tr'),
    ("'Booking Help'", 'TranslationKeys.bookingHelp.tr'),
    ("'Fill in all required fields to book an appointment.'", 'TranslationKeys.bookingHelpDesc.tr'),
    ("'Consultation Type'", 'TranslationKeys.bookingType.tr'),
    ("'In-Person Visit'", 'TranslationKeys.bookingInPerson.tr'),
    ("'Video Consultation'", 'TranslationKeys.bookingVideo.tr'),
    ("'Select Date'", 'TranslationKeys.bookingSelectDate.tr'),
    ("'Select Time'", 'TranslationKeys.bookingSelectTime.tr'),
    ("'Reason for Visit (Optional)'", 'TranslationKeys.bookingReason.tr'),
    ("'Briefly describe your symptoms or reason for visit'", 'TranslationKeys.bookingReasonHint.tr'),
    ("'Payment Information'", 'TranslationKeys.bookingPaymentInfo.tr'),
    ("'Your appointment will be confirmed immediately. Payment will be collected at the clinic.'", 'TranslationKeys.bookingConfirmDesc.tr'),
    ("'Book Appointment Now'", 'TranslationKeys.bookingBookNow.tr'),
    ("'Please select an appointment time'", 'TranslationKeys.bookingSelectTimeWarning.tr'),
]
replace_in_file(r'c:\Users\HP\Desktop\Flutter\doctor\lib\patient\features\appointments\screens\book_appointment_screen.dart', book_apt)

apt_detail = [
    ("'Appointment Details'", 'TranslationKeys.bookingDetails.tr'),
    ("'Consultation Type'", 'TranslationKeys.bookingType.tr'),
    ("'In-Person Visit'", 'TranslationKeys.bookingInPerson.tr'),
    ("'Video Consultation'", 'TranslationKeys.bookingVideo.tr'),
    ("const Text('Cancel Appointment')", 'Text(TranslationKeys.bookingCancel.tr)'),
    ("const Text('Reschedule')", 'Text(TranslationKeys.bookingReschedule.tr)'),
    ("const Text('Join Video Call')", 'Text(TranslationKeys.bookingJoinCall.tr)'),
]
replace_in_file(r'c:\Users\HP\Desktop\Flutter\doctor\lib\patient\features\appointments\screens\appointment_detail_screen.dart', apt_detail)

reschedule_apt = [
    ("'Reschedule Appointment'", 'TranslationKeys.bookingReschedule.tr'),
    ("'Confirm Reschedule'", 'TranslationKeys.bookingConfirmReschedule.tr'),
]
replace_in_file(r'c:\Users\HP\Desktop\Flutter\doctor\lib\patient\features\appointments\screens\reschedule_appointment_screen.dart', reschedule_apt)

find_docs = [
    ("'Find Doctors'", 'TranslationKeys.doctorsFindDoctors.tr'),
    ("'Search doctors by name or specialty...'", 'TranslationKeys.doctorsSearchHint.tr'),
    ("'Specialties'", 'TranslationKeys.doctorsSpecialties.tr'),
    ("'All'", 'TranslationKeys.doctorsAll.tr'),
    ("'No doctors found matching your criteria.'", 'TranslationKeys.doctorsNoFound.tr'),
]
replace_in_file(r'c:\Users\HP\Desktop\Flutter\doctor\lib\patient\features\doctors\screens\find_doctors_screen.dart', find_docs)

doc_detail = [
    ("'Experience'", 'TranslationKeys.doctorsExperience.tr'),
    ("'Patients'", 'TranslationKeys.doctorsPatients.tr'),
    ("'Reviews'", 'TranslationKeys.doctorsReviews.tr'),
    ("'About Doctor'", 'TranslationKeys.doctorsAbout.tr'),
    ("'Working Hours'", 'TranslationKeys.doctorsWorkingHours.tr'),
]
replace_in_file(r'c:\Users\HP\Desktop\Flutter\doctor\lib\patient\features\doctors\screens\doctor_detail_screen.dart', doc_detail)

profile = [
    ("'Edit Profile'", 'TranslationKeys.profileEdit.tr'),
    ("'Full Name'", 'TranslationKeys.profileName.tr'),
    ("'Email Address'", 'TranslationKeys.profileEmail.tr'),
    ("'Phone Number'", 'TranslationKeys.profilePhone.tr'),
    ("const Text('Update Profile')", 'Text(TranslationKeys.profileUpdate.tr)'),
]
replace_in_file(r'c:\Users\HP\Desktop\Flutter\doctor\lib\patient\features\settings\screens\patient_edit_profile_screen.dart', profile)

sos = [
    ("'Emergency SOS'", 'TranslationKeys.sosTitle.tr'),
    ("'Emergency Contacts'", 'TranslationKeys.sosEmergency.tr'),
    ("'Call Ambulance'", 'TranslationKeys.sosCallAmbulance.tr'),
    ("'Alert Family'", 'TranslationKeys.sosAlertContacts.tr'),
    ("'Contact Doctor'", 'TranslationKeys.sosContactDoctor.tr'),
]
replace_in_file(r'c:\Users\HP\Desktop\Flutter\doctor\lib\patient\features\emergency\screens\emergency_screen.dart', sos)

