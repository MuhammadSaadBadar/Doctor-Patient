// lib/features/appointments/widgets/appointment_card.dart

import 'package:doctor/core/constants/color_constants.dart';
import 'package:doctor/core/routes/app_routes.dart';
import 'package:doctor/core/themes/app_theme.dart';
import 'package:doctor/doctor/features/appointments/models/doc_appointment_schedule.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentSchedule appointment;
  final VoidCallback onReschedule;
  final VoidCallback onViewRecords;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onReschedule,
    required this.onViewRecords,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(
            AppRoutes.docappointmentDetail,
            arguments: appointment.id.toString(),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration:
                AppTheme.cardDecoration(
                  context: context,
                  hasBorder: true,
                  hasShadow: true,
                ).copyWith(
                  border: Border.all(
                    color: appointment.hasWarning
                        ? AppColors.error.withOpacity(0.25)
                        : AppColors.outlineVariant.withOpacity(0.5),
                    width: appointment.hasWarning ? 1.5 : 1,
                  ),
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER ROW ===
                Row(
                  children: [
                    // Avatar - FIXED: Use colors list directly
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF4E5E81), // primary tint
                            Color(0xFF031635), // primary
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          appointment.patientInitials,
                          style: AppTheme.titleMedium.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 13 : 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name & Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.patientName,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontSize: isMobile ? 14 : 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.event_rounded,
                                size: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${_formatDate(appointment.date)} • ${appointment.time}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: isMobile ? 11 : 12,
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
                    // More button
                    // Material(
                    //   color: Colors.transparent,
                    //   shape: const CircleBorder(),
                    //   child: InkWell(
                    //     customBorder: const CircleBorder(),
                    //     onTap: () => _showMenu(context),
                    //     child: const Padding(
                    //       padding: EdgeInsets.all(4),
                    //       child: Icon(
                    //         Icons.more_vert_rounded,
                    //         size: 20,
                    //         color: AppColors.onSurfaceVariant,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),

                const SizedBox(height: 10),

                // === DIVIDER ===
                Container(
                  height: 1,
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                ),

                const SizedBox(height: 10),

                // === STATUS CHIPS ===
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildStatusChip(
                      label: appointment.statusDisplay,
                      color: appointment.statusColor,
                      icon: _getStatusIcon(appointment.status),
                    ),
                    _buildStatusChip(
                      label: appointment.typeDisplay,
                      color: appointment.typeTextColor,
                      icon: appointment.type == AppointmentType.inPerson
                          ? Icons.person_rounded
                          : Icons.videocam_rounded,
                    ),
                    if (appointment.payment != null)
                      _buildStatusChip(
                        label: appointment.payment!.statusDisplay,
                        color: appointment.payment!.statusColor,
                        icon:
                            appointment.payment!.status ==
                                AppointmentPaymentStatus.confirmed
                            ? Icons.payments_rounded
                            : Icons.pending_rounded,
                      ),
                  ],
                ),

                // === REASON (if present) ===
                if (appointment.reason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: AppColors.onSurfaceVariant.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          appointment.reason,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: isMobile ? 11 : 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // === PAYMENT STATUS (if present) ===
                if (appointment.payment != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: appointment.payment!.statusColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: appointment.payment!.statusColor.withOpacity(
                          0.15,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          appointment.payment!.status ==
                                  AppointmentPaymentStatus.confirmed
                              ? Icons.check_circle_rounded
                              : Icons.pending_rounded,
                          size: 14,
                          color: appointment.payment!.statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Payment: ${appointment.payment!.statusDisplay}',
                          style: AppTheme.bodySmall.copyWith(
                            color: appointment.payment!.statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: isMobile ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // === VIEW DETAILS BUTTON ===
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(
                      AppRoutes.docappointmentDetail,
                      arguments: appointment.id.toString(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: AppTheme.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 11 : 12,
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Icons.hourglass_empty_rounded;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_rounded;
      case AppointmentStatus.completed:
        return Icons.check_circle_outline_rounded;
      case AppointmentStatus.cancelled:
        return Icons.cancel_rounded;
      case AppointmentStatus.noShow:
        return Icons.person_off_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) return 'Today';
    if (date.isAtSameMomentAs(tomorrow)) return 'Tomorrow';

    final diff = date.difference(today).inDays;
    if (diff < 7) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  // void _showMenu(BuildContext context) {
  //   Get.bottomSheet(
  //     Container(
  //       padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
  //       decoration: const BoxDecoration(
  //         color: AppColors.surface,
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             width: 40,
  //             height: 4,
  //             margin: const EdgeInsets.only(bottom: 16),
  //             decoration: BoxDecoration(
  //               color: AppColors.outlineVariant,
  //               borderRadius: BorderRadius.circular(4),
  //             ),
  //           ),
  //           ListTile(
  //             leading: const Icon(
  //               Icons.info_outline_rounded,
  //               color: AppColors.primary,
  //               size: 22,
  //             ),
  //             title: const Text(
  //               'View Details',
  //               style: TextStyle(
  //                 fontFamily: 'PlusJakartaSans',
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             onTap: () {
  //               Get.back();
  //               Get.toNamed(
  //                 AppRoutes.appointmentDetail,
  //                 arguments: appointment.id.toString(),
  //               );
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(
  //               Icons.edit_calendar_rounded,
  //               color: AppColors.primary,
  //               size: 22,
  //             ),
  //             title: const Text(
  //               'Reschedule',
  //               style: TextStyle(
  //                 fontFamily: 'PlusJakartaSans',
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             onTap: () {
  //               Get.back();
  //               onReschedule();
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(
  //               Icons.folder_open_rounded,
  //               color: AppColors.primary,
  //               size: 22,
  //             ),
  //             title: const Text(
  //               'View Records',
  //               style: TextStyle(
  //                 fontFamily: 'PlusJakartaSans',
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             onTap: () {
  //               Get.back();
  //               onViewRecords();
  //             },
  //           ),
  //           if (appointment.status == AppointmentStatus.pending ||
  //               appointment.status == AppointmentStatus.confirmed)
  //             ListTile(
  //               leading: const Icon(
  //                 Icons.cancel_rounded,
  //                 color: AppColors.error,
  //                 size: 22,
  //               ),
  //               title: const Text(
  //                 'Cancel',
  //                 style: TextStyle(
  //                   fontFamily: 'PlusJakartaSans',
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.w500,
  //                   color: AppColors.error,
  //                 ),
  //               ),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               onTap: () {
  //                 Get.back();
  //                 _showCancelConfirmation();
  //               },
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _showCancelConfirmation() {
  //   Get.dialog(
  //     AlertDialog(
  //       backgroundColor: AppColors.surfaceContainerLowest,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       title: Text(
  //         'Cancel Appointment',
  //         style: AppTheme.headlineSmall.copyWith(
  //           color: AppColors.primary,
  //           fontWeight: FontWeight.w700,
  //         ),
  //       ),
  //       content: Text(
  //         'Are you sure you want to cancel this appointment with ${appointment.patientName}?',
  //         style: AppTheme.bodyMedium.copyWith(
  //           color: AppColors.onSurfaceVariant,
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: Text(
  //             'Keep',
  //             style: AppTheme.labelLarge.copyWith(
  //               color: AppColors.primary,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Get.back();
  //             Get.snackbar(
  //               'Info',
  //               'Cancel functionality coming soon',
  //               snackPosition: SnackPosition.TOP,
  //               backgroundColor: AppColors.primary,
  //               colorText: AppColors.onPrimary,
  //             );
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: AppColors.error,
  //             foregroundColor: AppColors.onError,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //           ),
  //           child: const Text('Cancel'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
