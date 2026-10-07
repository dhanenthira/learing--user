import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../services/auth_service.dart';
import 'app_badge.dart';
import 'app_button.dart';
import 'app_avatar.dart';

class AppHeader extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final bool showStreak;
  final int? streakDays;
  final String? userName;
  final String? avatarUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onThemeToggle;
  final bool isDarkMode;
  final Widget? trailing;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showStreak = true,
    this.streakDays,
    this.userName,
    this.avatarUrl,
    this.onNotificationTap,
    this.onThemeToggle,
    this.isDarkMode = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final displayName = (userName != null && userName!.trim().isNotEmpty)
        ? userName!
        : ((user != null && user.name.trim().isNotEmpty) ? user.name : "Student");
    final displayAvatar = avatarUrl ?? user?.avatarUrl;
    final effectiveStreak = streakDays ?? user?.streakDays ?? 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.divider : AppColors.lightBorder;
    final titleColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.textMuted : AppColors.lightTextMuted;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space5,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.h3(context, color: titleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Streak Badge
          if (showStreak) ...[
            AppBadge.streak(effectiveStreak),
            const SizedBox(width: AppSpacing.space3),
          ],

          // Theme Toggle
          AppIconButton(
            icon: isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: "Toggle Theme",
            onPressed: onThemeToggle ?? () {},
          ),
          const SizedBox(width: AppSpacing.space2),

          // Search Button
          AppIconButton(
            icon: LucideIcons.search,
            tooltip: "Search Students (@username)",
            onPressed: () => context.go("/student/search"),
          ),
          const SizedBox(width: AppSpacing.space2),

          // Notifications Bell
          AppIconButton(
            icon: LucideIcons.bell,
            tooltip: "Notifications",
            onPressed: onNotificationTap ?? () {},
          ),
          const SizedBox(width: AppSpacing.space3),

          // User Profile Avatar (Dynamically loaded from auth user)
          AppAvatar(
            name: displayName,
            imageUrl: displayAvatar,
            radius: 18,
            onTap: () => context.go("/student/profile"),
          ),

          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.space3),
            trailing!,
          ],
        ],
      ),
    );
  }
}

