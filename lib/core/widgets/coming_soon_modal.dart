import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';
import 'app_badge.dart';

class ComingSoonModal extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const ComingSoonModal({
    super.key,
    this.title = "Coming Soon!",
    this.description = "We're working on something exciting. Communication practice will be available in a future update.",
    this.icon = Icons.chat_bubble_outline_rounded,
  });

  static Future<void> show(BuildContext context, {String? title, String? description, IconData? icon}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => ComingSoonModal(
        title: title ?? "Coming Soon!",
        description: description ?? "We're working on something exciting. Communication practice will be available in a future update.",
        icon: icon ?? Icons.chat_bubble_outline_rounded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.modalRadius,
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Badge
            const AppBadge(
              label: "UNDER DEVELOPMENT",
              color: Color(0x228B5CF6),
              textColor: AppColors.secondary,
              isPill: true,
            ),
            const SizedBox(height: AppSpacing.space5),
            
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
              ),
              child: Icon(icon, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.space4),

            // Heading
            Text(
              title,
              style: AppTypography.h2(context, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space2),

            // Description
            Text(
              description,
              style: AppTypography.bodyMedium(context, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space6),

            // Close Button
            AppButton(
              text: "Close",
              variant: AppButtonVariant.primary,
              width: double.infinity,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
