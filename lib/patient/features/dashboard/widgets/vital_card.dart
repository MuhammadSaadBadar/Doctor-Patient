// lib/patient/features/dashboard/widgets/vital_card.dart

import 'package:doctor/patient/features/dashboard/models/blood_pressure_reading.dart';
import 'package:doctor/patient/features/dashboard/models/blood_sugar_reading.dart';
import 'package:flutter/material.dart';

class VitalCard extends StatelessWidget {
  final dynamic reading;
  final String type;

  const VitalCard.bloodPressure({
    super.key,
    required BloodPressureReading reading,
  }) : reading = reading,
       type = 'bp';

  const VitalCard.bloodSugar({super.key, required BloodSugarReading reading})
    : reading = reading,
      type = 'sugar';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return type == 'bp'
        ? _buildBPCard(reading as BloodPressureReading, cs)
        : _buildSugarCard(reading as BloodSugarReading, cs);
  }

  Widget _buildBPCard(BloodPressureReading bp, ColorScheme cs) {
    final isNormal = bp.isNormal;
    final statusColor = isNormal ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            cs.primary.withOpacity(0.10),
            cs.primaryContainer.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  size: 14,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'BP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bp.status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: statusColor.shade700,
                  ),
                ),
              ),
            ],
          ),
          // Flexible spacer absorbs any extra height given by IntrinsicHeight,
          // preventing the 1px bottom overflow.
          const Flexible(child: SizedBox(height: 6)),
          Flexible(
            child: Text(
              '${bp.systolic}/${bp.diastolic}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (bp.pulse != null)
            Flexible(
              child: Text(
                '♥ ${bp.pulse} bpm',
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSugarCard(BloodSugarReading sugar, ColorScheme cs) {
    final isNormal = sugar.isNormal;
    final statusColor = isNormal ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            cs.primary.withOpacity(0.10),
            cs.primaryContainer.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bloodtype_rounded,
                  size: 14,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Sugar',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isNormal ? 'Normal' : 'High',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: statusColor.shade700,
                  ),
                ),
              ),
            ],
          ),
          const Flexible(child: SizedBox(height: 6)),
          Flexible(
            child: Text(
              '${sugar.valueMgDl} mg/dL',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              sugar.contextLabel,
              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
