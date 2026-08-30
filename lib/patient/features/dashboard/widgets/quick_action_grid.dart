// lib/patient/features/dashboard/widgets/quick_action_grid.dart

import 'package:flutter/material.dart';

class QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isHidden;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isHidden = false,
  });
}

class QuickActionGrid extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionGrid({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final visibleActions = actions.where((a) => !a.isHidden).toList();
    if (visibleActions.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive column count based on available width
        // Minimum tile width ~80dp for good touch targets and text
        final crossAxisCount = (constraints.maxWidth / 80).floor().clamp(2, 4);
        
        // Calculate aspect ratio to maintain reasonable tile height
        final tileWidth = constraints.maxWidth / crossAxisCount;
        final childAspectRatio = tileWidth / 88; // 88dp target tile height

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: visibleActions.map((action) {
            return _ActionTile(action: action);
          }).toList(),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  final QuickAction action;

  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(action.icon, size: 20, color: action.color),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
