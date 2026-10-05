import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/theme_service.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
        vertical: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          AppCard(
            backgroundColor: const Color(0xFF1E1B4B),
            borderColor: AppColors.secondary.withOpacity(0.4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppBadge(
                        label: "CODEARENA MASTER ADMIN CONSOLE",
                        color: Color(0x228B5CF6),
                        textColor: AppColors.secondary,
                        isPill: true,
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      Text("Platform Overview & Administration", style: AppTypography.h2(context, color: AppColors.textPrimary)),
                      const SizedBox(height: AppSpacing.space2),
                      const Text(
                        "Manage student accounts, publish new aptitude and coding questions, inspect live battle rooms, and track real-time assessment benchmarks.",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          // Top Metric Cards
          LayoutBuilder(
            builder: (ctx, constraints) {
              int crossCount = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 1100 ? 2 : 4);
              return GridView.count(
                crossAxisCount: crossCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: crossCount == 1 ? 2.5 : 1.45,
                children: const [
                  StatCard(
                    label: "Total Students",
                    value: "2,480",
                    icon: LucideIcons.users,
                    iconColor: AppColors.primary,
                    subtitle: "+124 this week",
                    progress: 0.85,
                  ),
                  StatCard(
                    label: "Active Today",
                    value: "1,820",
                    icon: LucideIcons.activity,
                    iconColor: AppColors.success,
                    subtitle: "73% Engagement",
                    progress: 0.73,
                  ),
                  StatCard(
                    label: "Published Questions",
                    value: "1,250",
                    icon: LucideIcons.helpCircle,
                    iconColor: AppColors.secondary,
                    subtitle: "Aptitude + Coding",
                    progress: 0.90,
                  ),
                  StatCard(
                    label: "Total Submissions",
                    value: "48,920",
                    icon: LucideIcons.uploadCloud,
                    iconColor: AppColors.streak,
                    subtitle: "84.6% Avg Accuracy",
                    progress: 0.84,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.space8),

          // Two Column Sections
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Recent Submissions
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Live Student Submissions", style: AppTypography.h3(context, color: AppColors.textPrimary)),
                        TextButton(onPressed: () {}, child: const Text("View All Logs →", style: TextStyle(color: AppColors.primary))),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space3),

                    AppCard(
                      child: Column(
                        children: [
                          _buildSubmissionRow("Alex Mercer", "Two Sum Target Indices", "Accepted (100%)", "2 mins ago", AppColors.success),
                          const Divider(height: 20),
                          _buildSubmissionRow("Sophia Chen", "Train Relative Velocity", "Correct (10/10)", "8 mins ago", AppColors.success),
                          const Divider(height: 20),
                          _buildSubmissionRow("Marcus Vance", "Merge Overlapping Intervals", "Wrong Answer (Case 3)", "15 mins ago", AppColors.error),
                          const Divider(height: 20),
                          _buildSubmissionRow("Elena Rostova", "Binary Search Complexity", "Correct (10/10)", "24 mins ago", AppColors.success),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (!isMob) ...[
                const SizedBox(width: AppSpacing.space6),
                // Right: Quick Admin Management Actions
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Administrative Actions", style: AppTypography.h3(context, color: AppColors.textPrimary)),
                      const SizedBox(height: AppSpacing.space3),

                      AppCard(
                        child: Column(
                          children: [
                            AppButton(
                              text: "Create New MCQ Question",
                              variant: AppButtonVariant.primary,
                              icon: LucideIcons.plusCircle,
                              width: double.infinity,
                              onPressed: () => context.go("/admin/questions"),
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              text: "Add Coding Arena Problem",
                              variant: AppButtonVariant.secondary,
                              icon: LucideIcons.code2,
                              width: double.infinity,
                              onPressed: () => context.go("/admin/coding"),
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              text: "Publish Daily Challenge Set",
                              variant: AppButtonVariant.secondary,
                              icon: LucideIcons.calendar,
                              width: double.infinity,
                              onPressed: () => context.go("/admin/daily-challenges"),
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              text: "Create Grand Assessment Test",
                              variant: AppButtonVariant.secondary,
                              icon: LucideIcons.clipboardCheck,
                              width: double.infinity,
                              onPressed: () => context.go("/admin/tests"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: Row(
        children: [
          if (!isMob) const AppSidebar(isAdmin: true, currentRoute: "/admin/dashboard"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Admin Dashboard",
                  subtitle: "CodeArena Central Operational Control",
                  showStreak: false,
                  isDarkMode: isDark,
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionRow(String student, String problem, String status, String time, Color statusColor) {
    return Row(
      children: [
        AppAvatar(name: student, radius: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
              Text(problem, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(status, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: statusColor)),
            Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
