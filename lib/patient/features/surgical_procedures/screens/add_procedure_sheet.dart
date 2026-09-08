// lib/patient/features/surgical_procedures/screens/add_procedure_sheet.dart

import 'package:doctor/patient/features/surgical_procedures/controllers/add_procedure_controller.dart';
import 'package:doctor/patient/features/surgical_procedures/widgets/procedure_form_field.dart';
import 'package:doctor/patient/features/surgical_procedures/widgets/procedure_notes_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProcedureSheet extends GetView<AddProcedureController> {
  const AddProcedureSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _buildHeader(context),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Obx(
                    () => ProcedureFormField(
                      label: 'Procedure Name',
                      hint: 'e.g., C-Section, Appendectomy',
                      icon: Icons.local_hospital_rounded,
                      controller: controller.procedureNameController,
                      required: true,
                      errorText: controller.procedureNameError.value,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => ProcedureFormField(
                      label: 'Procedure Date',
                      hint: 'Select date',
                      icon: Icons.calendar_month_rounded,
                      controller: TextEditingController(
                        text: controller.selectedDate.value != null
                            ? _formatDate(controller.selectedDate.value!)
                            : '',
                      ),
                      required: true,
                      readOnly: true,
                      errorText: controller.dateError.value,
                      onTap: () => controller.pickDate(context),
                      suffix: Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProcedureFormField(
                    label: 'Hospital Name',
                    hint: 'e.g., City Maternity Hospital',
                    icon: Icons.hotel_rounded,
                    controller: controller.hospitalNameController,
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => ProcedureNotesField(
                      controller: controller.notesController,
                      maxLength: controller.notesMaxLength,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActions(context),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            controller.getTitle(),
            style: TextStyle(
              fontSize: textScale.scale(18).clamp(16.0, 24.0),
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: controller.cancel,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);

    return Obx(
      () => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : controller.cancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
                side: BorderSide(color: colorScheme.outlineVariant),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: textScale.scale(14).clamp(12.0, 18.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : controller.submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                disabledBackgroundColor: colorScheme.onSurface.withValues(
                  alpha: 0.12,
                ),
              ),
              child: controller.isSubmitting.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      controller.getSubmitLabel(),
                      style: TextStyle(
                        fontSize: textScale.scale(14).clamp(12.0, 18.0),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
