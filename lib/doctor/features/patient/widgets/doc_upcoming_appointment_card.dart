import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/patient/models/doc_appointment.dart';
import 'package:flutter/material.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  final List<Appointment> appointments;
  final bool isLoading;
  final VoidCallback? onViewAll;

  const UpcomingAppointmentCard({
    super.key,
    required this.appointments,
    required this.isLoading,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceContainerLow, height: 1),
          const SizedBox(height: 12),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.event_rounded,
            size: 18,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Upcoming Appointments',
            style: AppTheme.headlineSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (onViewAll != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: AppTheme.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (appointments.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        ...appointments.take(3).map((appointment) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildAppointmentRow(appointment),
          );
        }).toList(),
        if (appointments.length > 3) _buildMoreAppointmentsIndicator(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 32,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: 8),
            Text(
              'No Upcoming Appointments',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'No appointments scheduled at this time.',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentRow(Appointment appointment) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            appointment.appointmentType == 'video_consultation'
                ? Icons.videocam_rounded
                : Icons.medical_services_rounded,
            size: 18,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.reason.isNotEmpty
                    ? appointment.reason
                    : 'Medical Consultation',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      appointment.formattedDate,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.schedule_rounded,
                    size: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${appointment.durationMinutes} min',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: appointment.statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              appointment.statusDisplay,
              style: AppTheme.labelMedium.copyWith(
                color: appointment.statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreAppointmentsIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Text(
          '+ ${appointments.length - 3} more appointments',
          style: AppTheme.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}
