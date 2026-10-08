import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/theme_service.dart';

class TestsListScreen extends ConsumerWidget {
  const TestsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    final tests = [
      {
        "id": "test_nationwide_01",
        "title": "All-India Coding & Aptitude Grand Assessment",
        "category": "Grand Challenge Mix",
        "duration": "30 Mins",
        "marks": "40 Marks",
        "questions": "4 Questions",
        "status": "Active Now",
        "isAttempted": false,
        "difficulty": "Medium",
        "deadline": "Open until Oct 10, 2026"
      },
      {
        "id": "test_dsa_02",
        "title": "Data Structures & Big-O Speed Benchmark",
        "category": "Technical Assessment",
        "duration": "45 Mins",
        "marks": "60 Marks",
        "questions": "20 Questions",
        "status": "Upcoming",
        "isAttempted": false,
        "difficulty": "Hard",
        "deadline": "Starts Tomorrow at 6:00 PM"
      },
      {
        "id": "test_apt_prev",
        "title": "Placement Quantitative Reasoning Screening",
        "category": "Aptitude Screening",
        "duration": "25 Mins",
        "marks": "30 Marks",
        "questions": "15 Questions",
        "status": "Completed",
        "isAttempted": true,
        "score": "28 / 30",
        "difficulty": "Easy",
        "deadline": "Submitted on Oct 1, 2026"
      }
    ];

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
        vertical: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            backgroundColor: const Color(0xFF1E1B4B),
            borderColor: AppColors.secondary.withOpacity(0.3),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppBadge(
                        label: "PROCTORED FORMAL ASSESSMENTS",
                        color: Color(0x228B5CF6),
                        textColor: AppColors.secondary,
                        isPill: true,
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      Text("Formal Tests & Certifications", style: AppTypography.h2(context, color: AppColors.textPrimary)),
                      const SizedBox(height: AppSpacing.space2),
                      const Text(
                        "Timed recruitment assessments with strict server-side evaluation and percentile ranking.",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          Text("Available Assessments", style: AppTypography.h3(context, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.space4),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tests.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (ctx, idx) {
              final t = tests[idx];
              final isActive = t["status"] == "Active Now";
              final isAttempted = t["isAttempted"] as bool;

              return AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary.withOpacity(0.12) : AppColors.surfaceElevated,
                        borderRadius: AppRadii.inputRadius,
                      ),
                      child: Icon(
                        isActive ? LucideIcons.clipboardCheck : (isAttempted ? LucideIcons.checkCheck : LucideIcons.calendar),
                        color: isActive ? AppColors.primary : AppColors.textMuted,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(t["title"] as String, style: AppTypography.h4(context, color: AppColors.textPrimary)),
                              const SizedBox(width: 8),
                              AppBadge.difficulty(t["difficulty"] as String),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${t["category"]} • ${t["duration"]} • ${t["marks"]} • ${t["questions"]}",
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t["deadline"] as String,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (isAttempted)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Score: ${t["score"]}", style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success, fontSize: 14)),
                          const SizedBox(height: 4),
                          const AppBadge(label: "ATTEMPTED", isPill: true, color: Color(0x2222C55E), textColor: AppColors.success),
                        ],
                      )
                    else
                      AppButton(
                        text: isActive ? "Start Test" : "View Rules",
                        variant: isActive ? AppButtonVariant.primary : AppButtonVariant.secondary,
                        onPressed: () {
                          if (isActive) {
                            context.go("/student/tests/active/${t["id"]}");
                          }
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMob ? const Drawer(child: AppSidebar(currentRoute: "/student/tests")) : null,
      body: Row(
        children: [
          if (!isMob) const AppSidebar(currentRoute: "/student/tests"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Assessment Tests",
                  subtitle: "Scheduled competitive & recruitment exams",
                  isDarkMode: isDark,
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMob ? const AppBottomNav(currentRoute: "/student/tests") : null,
    );
  }
}
