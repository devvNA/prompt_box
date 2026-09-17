import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class BrutalCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final Widget? labelWidget;

  const BrutalCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.labelWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = onChanged != null;

    return Semantics(
      label: label ?? 'Checkbox',
      checked: value,
      child: GestureDetector(
        onTap: isInteractive ? () => onChanged!(!value) : null,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeInOut,
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: value ? const Color(0xFFFDE153) : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  border: Border.all(color: AppColors.ink, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.ink,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: value
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.ink,
                        weight: 800,
                      )
                    : null,
              ),
              if (label != null || labelWidget != null) ...[
                const SizedBox(width: 8),
                if (labelWidget != null)
                  labelWidget!
                else
                  Text(
                    label!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF262626),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
