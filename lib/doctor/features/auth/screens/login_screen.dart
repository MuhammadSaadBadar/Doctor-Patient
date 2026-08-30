// import 'package:doctor/core/constants/color_constants.dart';
// import 'package:doctor/core/themes/app_theme.dart';
// import 'package:doctor/core/widgets/material_symbol_icon.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:doctor/core/routes/app_routes.dart';
// import 'package:doctor/doctor/features/auth/controllers/auth_controller.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.light,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       body: Column(
//         children: [
//           _HeroPanel(),
//           const SizedBox(height: 10),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 400),
//                 child: Column(
//                   children: [
//                     _LoginCard(),
//                     const SizedBox(height: 20),
//                     _buildFooter(context),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFooter(BuildContext context) {
//     return TextButton(
//       onPressed: () {
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   const SnackBar(
//         //     content: Text('Contact administrator functionality coming soon'),
//         //   ),
//         // );
//       },
//       style: TextButton.styleFrom(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         minimumSize: Size.zero,
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           MaterialSymbolIcon('help', size: 16, color: AppColors.outline),
//           const SizedBox(width: 6),
//           Text(
//             'Need help? Contact Administrator',
//             style: AppTheme.bodySmall.copyWith(
//               color: AppColors.outline,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Hero panel ────────────────────────────────────────────────────────────────

// class _HeroPanel extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final topPad = MediaQuery.of(context).padding.top;
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.fromLTRB(24, topPad + 32, 24, 22),
//       decoration: AppTheme.heroPanelDecoration,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Platform badge
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//             decoration: AppTheme.badgeDecoration(
//               background: Colors.white.withOpacity(0.10),
//               border: Colors.white.withOpacity(0.15),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 6,
//                   height: 6,
//                   decoration: const BoxDecoration(
//                     color: AppColors.success,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   'Gynae Hub',
//                   style: AppTheme.labelMedium.copyWith(
//                     color: AppColors.onPrimary.withOpacity(0.85),
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 18),

//           Text(
//             'Welcome back',
//             style: AppTheme.displaySmall.copyWith(
//               color: AppColors.onPrimary,
//               fontWeight: FontWeight.w800,
//               height: 1.1,
//             ),
//           ),

//           const SizedBox(height: 8),

//           Text(
//             'Sign in to manage your patients\nand appointments.',
//             style: AppTheme.bodyMedium.copyWith(
//               color: AppColors.onPrimary.withOpacity(0.50),
//               height: 1.55,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Login card ────────────────────────────────────────────────────────────────

// class _LoginCard extends StatefulWidget {
//   @override
//   State<_LoginCard> createState() => _LoginCardState();
// }

// class _LoginCardState extends State<_LoginCard> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _emailFocusNode = FocusNode();
//   final _passwordFocusNode = FocusNode();
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _emailFocusNode.dispose();
//     _passwordFocusNode.dispose();
//     super.dispose();
//   }

//   void _togglePasswordVisibility() =>
//       setState(() => _obscurePassword = !_obscurePassword);

//   String? _validateEmail(String? value) {
//     final trimmed = value?.trim() ?? '';
//     if (trimmed.isEmpty) return 'Email address is required';
//     final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
//     if (!emailRegex.hasMatch(trimmed)) return 'Enter a valid email address';
//     return null;
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) return 'Password is required';
//     if (value.length < 6) return 'Password must be at least 6 characters';
//     return null;
//   }

//   void _handleLogin() {
//     FocusScope.of(context).unfocus();
//     if (!(_formKey.currentState?.validate() ?? false)) return;
//     Get.find<AuthController>().login(
//       _emailController.text.trim(),
//       _passwordController.text,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: AppTheme.cardDecoration(borderRadius: 24, context: context),
//       child: Form(
//         key: _formKey,
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Card header
//             Row(
//               children: [
//                 Container(
//                   width: 42,
//                   height: 42,
//                   decoration: BoxDecoration(
//                     gradient: AppColors.primaryGradient,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.medical_services_rounded,
//                     color: AppColors.onPrimary,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Sign In',
//                       style: AppTheme.titleLarge.copyWith(
//                         fontWeight: FontWeight.w800,
//                         fontSize: 18,
//                       ),
//                     ),
//                     Text(
//                       'Use your registered credentials',
//                       style: AppTheme.bodySmall.copyWith(
//                         color: AppColors.onSurfaceVariant,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),
//             _SectionRule(),
//             const SizedBox(height: 20),

//             _FormLabel('Email Address'),
//             const SizedBox(height: 8),
//             _AppTextField(
//               controller: _emailController,
//               focusNode: _emailFocusNode,
//               icon: 'mail',
//               hintText: 'you@example.com',
//               keyboardType: TextInputType.emailAddress,
//               textInputAction: TextInputAction.next,
//               validator: _validateEmail,
//               onSubmitted: (_) =>
//                   FocusScope.of(context).requestFocus(_passwordFocusNode),
//             ),

//             const SizedBox(height: 18),

//             _FormLabel('Password'),
//             const SizedBox(height: 8),
//             _AppTextField(
//               controller: _passwordController,
//               focusNode: _passwordFocusNode,
//               icon: 'lock',
//               hintText: 'Enter your password',
//               obscureText: _obscurePassword,
//               textInputAction: TextInputAction.done,
//               validator: _validatePassword,
//               onSubmitted: (_) => _handleLogin(),
//               suffixIcon: IconButton(
//                 onPressed: _togglePasswordVisibility,
//                 icon: MaterialSymbolIcon(
//                   _obscurePassword ? 'visibility_off' : 'visibility',
//                   size: 20,
//                   color: AppColors.outline,
//                 ),
//                 splashRadius: 20,
//                 tooltip: _obscurePassword ? 'Show password' : 'Hide password',
//               ),
//             ),

//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
//                 style: TextButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 4,
//                     vertical: 6,
//                   ),
//                   minimumSize: Size.zero,
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 ),
//                 child: Text(
//                   'Forgot Password?',
//                   style: AppTheme.labelMedium.copyWith(
//                     color: AppColors.secondary,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: Obx(() {
//                 final isLoading = Get.find<AuthController>().isLoading.value;
//                 return ElevatedButton(
//                   onPressed: isLoading ? null : _handleLogin,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: AppColors.onPrimary,
//                     elevation: isLoading ? 0 : 6,
//                     shadowColor: AppColors.cardShadow,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     textStyle: AppTheme.labelMedium.copyWith(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                     ),
//                     disabledBackgroundColor: AppColors.primary.withOpacity(
//                       0.55,
//                     ),
//                   ),
//                   child: AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 180),
//                     child: isLoading
//                         ? const SizedBox(
//                             key: ValueKey('loading'),
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               color: AppColors.onPrimary,
//                               strokeWidth: 2.2,
//                             ),
//                           )
//                         : Row(
//                             key: const ValueKey('label'),
//                             mainAxisSize: MainAxisSize.min,
//                             children: const [
//                               Text('Sign In'),
//                               SizedBox(width: 8),
//                               Icon(Icons.arrow_forward_rounded, size: 18),
//                             ],
//                           ),
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Supporting widgets ────────────────────────────────────────────────────────

// class _SectionRule extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(child: Container(height: 1, color: AppColors.outlineSubtle)),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: Text(
//             'CREDENTIALS',
//             style: AppTheme.labelSmall.copyWith(
//               color: AppColors.outlineVariant,
//               letterSpacing: 1.4,
//             ),
//           ),
//         ),
//         Expanded(child: Container(height: 1, color: AppColors.outlineSubtle)),
//       ],
//     );
//   }
// }

// class _FormLabel extends StatelessWidget {
//   final String text;
//   const _FormLabel(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: AppTheme.labelMedium.copyWith(
//         color: AppColors.onSurfaceVariant,
//         fontWeight: FontWeight.w600,
//         letterSpacing: 0.4,
//       ),
//     );
//   }
// }

// class _AppTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final FocusNode? focusNode;
//   final String icon;
//   final String hintText;
//   final TextInputType? keyboardType;
//   final TextInputAction? textInputAction;
//   final bool obscureText;
//   final String? Function(String?)? validator;
//   final ValueChanged<String>? onSubmitted;
//   final Widget? suffixIcon;

//   const _AppTextField({
//     required this.controller,
//     required this.icon,
//     required this.hintText,
//     this.focusNode,
//     this.keyboardType,
//     this.textInputAction,
//     this.obscureText = false,
//     this.validator,
//     this.onSubmitted,
//     this.suffixIcon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FormField<String>(
//       validator: validator,
//       builder: (field) {
//         final hasError = field.hasError;
//         final isFocused = focusNode?.hasFocus ?? false;

//         final borderColor = hasError
//             ? AppColors.error
//             : isFocused
//             ? AppColors.primary
//             : AppColors.outlineSubtle;

//         final borderWidth = (hasError || isFocused) ? 1.5 : 1.0;

//         final bgColor = hasError
//             ? AppColors.errorSubtle
//             : isFocused
//             ? AppColors.primarySubtle
//             : AppColors.surfaceContainerLowest;

//         final iconColor = hasError
//             ? AppColors.error
//             : isFocused
//             ? AppColors.primary
//             : AppColors.outlineVariant;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 150),
//               decoration: BoxDecoration(
//                 color: bgColor,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: borderColor, width: borderWidth),
//               ),
//               child: Row(
//                 children: [
//                   const SizedBox(width: 14),
//                   MaterialSymbolIcon(icon, size: 20, color: iconColor),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: TextFormField(
//                       controller: controller,
//                       focusNode: focusNode,
//                       obscureText: obscureText,
//                       keyboardType: keyboardType,
//                       textInputAction: textInputAction,
//                       onFieldSubmitted: onSubmitted,
//                       onChanged: (v) => field.didChange(v),
//                       style: AppTheme.bodyMedium.copyWith(
//                         color: AppColors.onSurface,
//                         fontSize: 14,
//                       ),
//                       decoration: InputDecoration(
//                         hintText: hintText,
//                         hintStyle: AppTheme.bodyMedium.copyWith(
//                           color: AppColors.outline,
//                           fontSize: 14,
//                         ),
//                         border: InputBorder.none,
//                         enabledBorder: InputBorder.none,
//                         focusedBorder: InputBorder.none,
//                         errorBorder: InputBorder.none,
//                         focusedErrorBorder: InputBorder.none,
//                         disabledBorder: InputBorder.none,
//                         errorStyle: const TextStyle(height: 0, fontSize: 0),
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 15,
//                           horizontal: 4,
//                         ),
//                         isDense: true,
//                       ),
//                     ),
//                   ),
//                   if (suffixIcon != null) ...[
//                     const SizedBox(width: 4),
//                     suffixIcon!,
//                     const SizedBox(width: 6),
//                   ] else
//                     const SizedBox(width: 14),
//                 ],
//               ),
//             ),
//             if (hasError) ...[
//               const SizedBox(height: 6),
//               Padding(
//                 padding: const EdgeInsets.only(left: 4),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.error_outline_rounded,
//                       size: 13,
//                       color: AppColors.error,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       field.errorText ?? '',
//                       style: AppTheme.labelSmall.copyWith(
//                         color: AppColors.error,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         );
//       },
//     );
//   }
// }
import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/constants/user_role.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/core/widgets/material_symbol_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/doctor/features/auth/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.doctor;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          _HeroPanel(role: _selectedRole),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    _LoginCard(
                      selectedRole: _selectedRole,
                      onRoleChanged: (role) =>
                          setState(() => _selectedRole = role),
                    ),
                    const SizedBox(height: 20),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MaterialSymbolIcon('help', size: 16, color: AppColors.outline),
          const SizedBox(width: 6),
          Text(
            'Need help? Contact Administrator',
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero panel ────────────────────────────────────────────────────────────────

class _HeroPanel extends StatelessWidget {
  final UserRole role;

  const _HeroPanel({required this.role});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final isDoctor = role == UserRole.doctor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPad + 32, 24, 22),
      decoration: AppTheme.heroPanelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Platform badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: AppTheme.badgeDecoration(
              background: Colors.white.withOpacity(0.10),
              border: Colors.white.withOpacity(0.15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Gynae Hub',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Welcome back',
            style: AppTheme.displaySmall.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle animates when role changes
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Align(
              key: ValueKey(role),
              alignment: Alignment.centerLeft,
              child: Text(
                isDoctor
                    ? 'Sign in to manage your patients\nand appointments.'
                    : 'Sign in to access your appointments\nand health records.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColors.onPrimary.withOpacity(0.50),
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Login card ────────────────────────────────────────────────────────────────

class _LoginCard extends StatefulWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const _LoginCard({required this.selectedRole, required this.onRoleChanged});

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() =>
      setState(() => _obscurePassword = !_obscurePassword);

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email address is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Get.find<AuthController>().login(
      _emailController.text.trim(),
      _passwordController.text,
      preferredRole: widget.selectedRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = widget.selectedRole == UserRole.doctor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(borderRadius: 24, context: context),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header — icon + title animate on role change
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      key: ValueKey(widget.selectedRole),
                      isDoctor
                          ? Icons.medical_services_rounded
                          : Icons.person_rounded,
                      color: AppColors.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign In',
                      style: AppTheme.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        key: ValueKey(widget.selectedRole),
                        isDoctor ? 'Doctor Portal' : 'Patient Portal',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Role selector ─────────────────────────────────────────────
            _RoleToggle(
              selectedRole: widget.selectedRole,
              onChanged: widget.onRoleChanged,
            ),

            const SizedBox(height: 20),
            _SectionRule(),
            const SizedBox(height: 20),

            _FormLabel('Email Address'),
            const SizedBox(height: 8),
            _AppTextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              icon: 'mail',
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_passwordFocusNode),
            ),

            const SizedBox(height: 18),

            _FormLabel('Password'),
            const SizedBox(height: 8),
            _AppTextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              icon: 'lock',
              hintText: 'Enter your password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: _validatePassword,
              onSubmitted: (_) => _handleLogin(),
              suffixIcon: IconButton(
                onPressed: _togglePasswordVisibility,
                icon: MaterialSymbolIcon(
                  _obscurePassword ? 'visibility_off' : 'visibility',
                  size: 20,
                  color: AppColors.outline,
                ),
                splashRadius: 20,
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot Password?',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(() {
                final isLoading = Get.find<AuthController>().isLoading.value;
                return ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: isLoading ? 0 : 6,
                    shadowColor: AppColors.cardShadow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: AppTheme.labelMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    disabledBackgroundColor: AppColors.primary.withOpacity(
                      0.55,
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: isLoading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.onPrimary,
                              strokeWidth: 2.2,
                            ),
                          )
                        : Row(
                            key: const ValueKey('label'),
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('Sign In'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Role toggle ───────────────────────────────────────────────────────────────

class _RoleToggle extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;

  const _RoleToggle({required this.selectedRole, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineSubtle),
      ),
      child: Row(
        children: [
          _RoleTab(
            icon: Icons.medical_services_rounded,
            label: 'Doctor',
            isSelected: selectedRole == UserRole.doctor,
            onTap: () => onChanged(UserRole.doctor),
          ),
          const SizedBox(width: 4),
          _RoleTab(
            icon: Icons.person_rounded,
            label: 'Patient',
            isSelected: selectedRole == UserRole.patient,
            onTap: () => onChanged(UserRole.patient),
          ),
        ],
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.onPrimary
                    : AppColors.primaryMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTheme.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.primaryMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting widgets (unchanged) ────────────────────────────────────────────

class _SectionRule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.outlineSubtle)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'CREDENTIALS',
            style: AppTheme.labelSmall.copyWith(
              color: AppColors.outlineVariant,
              letterSpacing: 1.4,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.outlineSubtle)),
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.labelMedium.copyWith(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String icon;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  const _AppTextField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
    this.onSubmitted,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (field) {
        final hasError = field.hasError;
        final isFocused = focusNode?.hasFocus ?? false;

        final borderColor = hasError
            ? AppColors.error
            : isFocused
            ? AppColors.primary
            : AppColors.outlineSubtle;

        final borderWidth = (hasError || isFocused) ? 1.5 : 1.0;

        final bgColor = hasError
            ? AppColors.errorSubtle
            : isFocused
            ? AppColors.primarySubtle
            : AppColors.surfaceContainerLowest;

        final iconColor = hasError
            ? AppColors.error
            : isFocused
            ? AppColors.primary
            : AppColors.outlineVariant;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  MaterialSymbolIcon(icon, size: 20, color: iconColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      obscureText: obscureText,
                      keyboardType: keyboardType,
                      textInputAction: textInputAction,
                      onFieldSubmitted: onSubmitted,
                      onChanged: (v) => field.didChange(v),
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: AppTheme.bodyMedium.copyWith(
                          color: AppColors.outline,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorStyle: const TextStyle(height: 0, fontSize: 0),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 4,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 4),
                    suffixIcon!,
                    const SizedBox(width: 6),
                  ] else
                    const SizedBox(width: 14),
                ],
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 13,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      field.errorText ?? '',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
