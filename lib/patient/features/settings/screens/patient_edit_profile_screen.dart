import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:doctor/core/widgets/patient_top_app_bar.dart';
import 'package:doctor/patient/features/settings/controllers/patient_settings_controller.dart';
import 'package:doctor/patient/features/settings/models/patient_profile_model.dart';
import 'package:doctor/core/localization/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientEditProfileScreen extends GetView<PatientSettingsController> {
  const PatientEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PatientEditProfileView();
  }
}

class _PatientEditProfileView extends StatefulWidget {
  @override
  State<_PatientEditProfileView> createState() =>
      _PatientEditProfileViewState();
}

class _PatientEditProfileViewState extends State<_PatientEditProfileView> {
  final _formKey = GlobalKey<FormState>();

  // Personal info controllers
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;

  // Patient profile controllers
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _lmpDateController;
  late final TextEditingController _eddDateController;
  late final TextEditingController _emergencyContactNameController;
  late final TextEditingController _emergencyContactPhoneController;
  late final TextEditingController _addressController;

  String? _selectedBloodGroup;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedLmpDate;
  DateTime? _selectedEddDate;

  PatientSettingsController get _controller =>
      Get.find<PatientSettingsController>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    ever(_controller.profileData, _onProfileDataChanged);
  }

  void _initializeControllers() {
    final profile = _controller.profileData.value;
    if (profile != null) {
      _firstNameController = TextEditingController(
        text: profile.user.firstName,
      );
      _lastNameController = TextEditingController(text: profile.user.lastName);
      _phoneController = TextEditingController(
        text: profile.user.phoneNumber ?? '',
      );

      final patientProfile = profile.patientProfile;
      _dateOfBirthController = TextEditingController(
        text: patientProfile?.dateOfBirth != null
            ? '${patientProfile!.dateOfBirth!.day}/${patientProfile.dateOfBirth!.month}/${patientProfile.dateOfBirth!.year}'
            : '',
      );
      _lmpDateController = TextEditingController(
        text: patientProfile?.lmpDate != null
            ? '${patientProfile!.lmpDate!.day}/${patientProfile.lmpDate!.month}/${patientProfile.lmpDate!.year}'
            : '',
      );
      _eddDateController = TextEditingController(
        text: patientProfile?.eddDate != null
            ? '${patientProfile!.eddDate!.day}/${patientProfile.eddDate!.month}/${patientProfile.eddDate!.year}'
            : '',
      );
      _emergencyContactNameController = TextEditingController(
        text: patientProfile?.emergencyContactName ?? '',
      );
      _emergencyContactPhoneController = TextEditingController(
        text: patientProfile?.emergencyContactPhone ?? '',
      );
      _addressController = TextEditingController(
        text: patientProfile?.address ?? '',
      );
      _selectedBloodGroup = patientProfile?.bloodGroup;
      _selectedDateOfBirth = patientProfile?.dateOfBirth;
      _selectedLmpDate = patientProfile?.lmpDate;
      _selectedEddDate = patientProfile?.eddDate;
    } else {
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _phoneController = TextEditingController();
      _dateOfBirthController = TextEditingController();
      _lmpDateController = TextEditingController();
      _eddDateController = TextEditingController();
      _emergencyContactNameController = TextEditingController();
      _emergencyContactPhoneController = TextEditingController();
      _addressController = TextEditingController();
    }
  }

  void _onProfileDataChanged(PatientProfileData? profile) {
    if (profile == null) return;
    if (!mounted) return;

    _firstNameController.text = profile.user.firstName;
    _lastNameController.text = profile.user.lastName;
    _phoneController.text = profile.user.phoneNumber ?? '';

    final patientProfile = profile.patientProfile;
    _dateOfBirthController.text = patientProfile?.dateOfBirth != null
        ? '${patientProfile!.dateOfBirth!.day}/${patientProfile.dateOfBirth!.month}/${patientProfile.dateOfBirth!.year}'
        : '';
    _lmpDateController.text = patientProfile?.lmpDate != null
        ? '${patientProfile!.lmpDate!.day}/${patientProfile.lmpDate!.month}/${patientProfile.lmpDate!.year}'
        : '';
    _eddDateController.text = patientProfile?.eddDate != null
        ? '${patientProfile!.eddDate!.day}/${patientProfile.eddDate!.month}/${patientProfile.eddDate!.year}'
        : '';
    _emergencyContactNameController.text =
        patientProfile?.emergencyContactName ?? '';
    _emergencyContactPhoneController.text =
        patientProfile?.emergencyContactPhone ?? '';
    _addressController.text = patientProfile?.address ?? '';
    _selectedBloodGroup = patientProfile?.bloodGroup;
    _selectedDateOfBirth = patientProfile?.dateOfBirth;
    _selectedLmpDate = patientProfile?.lmpDate;
    _selectedEddDate = patientProfile?.eddDate;

    setState(() {});
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _lmpDateController.dispose();
    _eddDateController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Obx(() {
        final profile = _controller.profileData.value;
        if (profile == null) return _buildLoadingState();

        return Column(
          children: [
            PatientTopAppBar(
              title: TranslationKeys.profileEdit.tr,
              showBackButton: true,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(profile),
                      const SizedBox(height: 24),
                      _buildPersonalInfoSection(),
                      const SizedBox(height: 24),
                      _buildPatientProfileSection(),
                      const SizedBox(height: 32),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildProfileHeader(PatientProfileData profile) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryContainer,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child:
                profile.user.profilePictureUrl != null &&
                    profile.user.profilePictureUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      profile.user.profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildInitials(profile.user),
                    ),
                  )
                : _buildInitials(profile.user),
          ),
          const SizedBox(height: 12),
          Text(
            profile.user.fullName,
            style: AppTheme.headlineMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.user.email,
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(UserProfile user) {
    return Center(
      child: Text(
        user.initials,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      children: [
        _buildTextField(
          label: 'First Name',
          controller: _firstNameController,
          icon: 'person',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'First name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Last Name',
          controller: _lastNameController,
          icon: 'person',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Last name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Email',
          controller: TextEditingController(
            text: _controller.profileData.value?.user.email ?? '',
          ),
          icon: 'mail',
          readOnly: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: TranslationKeys.profilePhone.tr,
          controller: _phoneController,
          icon: 'phone',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildPatientProfileSection() {
    return _buildSection(
      title: 'Patient Profile',
      children: [
        _buildTextField(
          label: 'Date of Birth',
          controller: _dateOfBirthController,
          icon: 'calendar_today',
          readOnly: true,
          onTap: _selectDateOfBirth,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'LMP Date (Last Menstrual Period)',
          controller: _lmpDateController,
          icon: 'calendar_today',
          readOnly: true,
          onTap: _selectLmpDate,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'EDD Date (Expected Due Date)',
          controller: _eddDateController,
          icon: 'calendar_today',
          readOnly: true,
          onTap: _selectEddDate,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Blood Group',
          value: _selectedBloodGroup,
          items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
          icon: 'bloodtype',
          onChanged: (value) {
            setState(() => _selectedBloodGroup = value);
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Emergency Contact Name',
          controller: _emergencyContactNameController,
          icon: 'person',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Emergency Contact Phone',
          controller: _emergencyContactPhoneController,
          icon: 'phone',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Address',
          controller: _addressController,
          icon: 'location_on',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: MaterialSymbolIcon(icon, size: 22),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: MaterialSymbolIcon(icon, size: 22),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSaveButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _controller.isLoading.value ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dateOfBirthController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectLmpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedLmpDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 300)),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedLmpDate = picked;
        _lmpDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectEddDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedEddDate ?? DateTime.now().add(const Duration(days: 280)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 300)),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedEddDate = picked;
        _eddDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    if (success && mounted) {
      // Also update patient profile fields
      await _controller.updatePatientProfile(
        dateOfBirth: _selectedDateOfBirth,
        lmpDate: _selectedLmpDate,
        eddDate: _selectedEddDate,
        bloodGroup: _selectedBloodGroup,
        emergencyContactName:
            _emergencyContactNameController.text.trim().isEmpty
            ? null
            : _emergencyContactNameController.text.trim(),
        emergencyContactPhone:
            _emergencyContactPhoneController.text.trim().isEmpty
            ? null
            : _emergencyContactPhoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );

      if (mounted) {
        Get.back(result: true);
      }
    }
  }
}
