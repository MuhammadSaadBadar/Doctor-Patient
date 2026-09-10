import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/patient/models/doc_patient.dart';
import 'package:flutter/material.dart';

class PatientHeader extends StatelessWidget {
  final Patient? patient;

  const PatientHeader({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    final cardColor =
        Theme.of(context).cardTheme.color ??
        Theme.of(context).colorScheme.surface;
    final outlineVariant = Theme.of(context).colorScheme.outlineVariant;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final secondaryContainer = Theme.of(context).colorScheme.secondaryContainer;
    final onSecondaryContainer = Theme.of(
      context,
    ).colorScheme.onSecondaryContainer;

    // Handle null patient
    if (patient == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No patient data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [primary.withOpacity(0.07), primary.withOpacity(0.0)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withOpacity(0.12), width: 1),
            ),
            child: isDesktop
                ? Row(
                    children: [
                      _buildAvatarAndName(context),
                      const Spacer(),
                      _buildStatusBadges(context),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatarAndName(context),
                      const SizedBox(height: 14),
                      _buildStatusBadges(context),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 4),
            child: _buildPatientInfoGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarAndName(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              patient!.name.isNotEmpty
                  ? patient!.name
                        .trim()
                        .split(' ')
                        .where((s) => s.isNotEmpty)
                        .take(2)
                        .map((s) => s[0])
                        .join()
                        .toUpperCase()
                  : '?',
              style: AppTheme.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient!.name,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    patient!.patientId,
                    style: AppTheme.bodySmall.copyWith(
                      color: onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    'Age: ${patient!.age}',
                    style: AppTheme.bodySmall.copyWith(color: onSurfaceVariant),
                  ),
                  if (patient!.phoneNumber?.isNotEmpty == true) ...[
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(
                      Icons.phone_rounded,
                      size: 12,
                      color: onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        patient!.phoneNumber!,
                        style: AppTheme.bodySmall.copyWith(
                          color: onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadges(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final secondaryContainer = Theme.of(context).colorScheme.secondaryContainer;
    final onSecondaryContainer = Theme.of(
      context,
    ).colorScheme.onSecondaryContainer;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            patient!.status,
            style: AppTheme.labelMedium.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: secondaryContainer,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            patient!.week,
            style: AppTheme.labelMedium.copyWith(
              color: onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientInfoGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        if (isDesktop) {
          return Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  context,
                  Icons.event_rounded,
                  'EDD',
                  patient!.edd ?? 'Not set',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  context,
                  Icons.pregnant_woman_rounded,
                  'Trimester',
                  patient!.trimester ?? 'Not set',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  context,
                  Icons.bloodtype_rounded,
                  'Blood Group',
                  patient!.bloodGroup ?? 'Not set',
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    Icons.event_rounded,
                    'EDD',
                    patient!.edd ?? 'Not set',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    Icons.pregnant_woman_rounded,
                    'Trimester',
                    patient!.trimester ?? 'Not set',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    Icons.bloodtype_rounded,
                    'Blood Group',
                    patient!.bloodGroup ?? 'Not set',
                  ),
                ),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final onPrimaryContainer = Theme.of(context).colorScheme.onPrimaryContainer;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: onPrimaryContainer),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.labelMedium.copyWith(color: onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
