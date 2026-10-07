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
import '../../../core/widgets/coming_soon_modal.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/services/auth_service.dart';

class DailyPracticeHomeScreen extends ConsumerStatefulWidget {
  const DailyPracticeHomeScreen({super.key});

  @override
  ConsumerState<DailyPracticeHomeScreen> createState() => _DailyPracticeHomeScreenState();
}

class _DailyPracticeHomeScreenState extends ConsumerState<DailyPracticeHomeScreen> {
  bool _timerEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    final practiceCategories = [
      {
        "id": "aptitude",
        "title": "Quantitative & Logical Aptitude",
        "desc": "Time & Distance, Work & Pipes, Percentages, Profit & Loss, Syllogisms, Series.",
        "icon": LucideIcons.brain,
        "color": AppColors.primary,
        "questions": "15 Questions Daily",
        "duration": "15 mins",
        "status": "Available Today",
        "isAvailable": true,
      },
      {
        "id": "technical",
        "title": "Technical & Core CS Practice",
        "desc": "Data Structures, Algorithms, OS, DBMS, Computer Networks, OOP, System Design.",
        "icon": LucideIcons.cpu,
        "color": AppColors.secondary,
        "questions": "15 Questions Daily",
        "duration": "15 mins",
        "status": "Completed Today",
        "isAvailable": true,
      },
      {
        "id": "mixed",
        "title": "Daily Mixed Challenge",
        "desc": "A balanced mix of 10 Aptitude + 10 Technical MCQs for fast placement preparation.",
        "icon": LucideIcons.sparkles,
        "color": AppColors.accent,
        "questions": "20 Questions Daily",
        "duration": "20 mins",
        "status": "Available Today",
        "isAvailable": true,
      },
      {
        "id": "communication",
        "title": "Communication Practice",
        "desc": "Verbal reasoning, corporate emails, interview phrasing, vocabulary and grammar.",
        "icon": LucideIcons.messageSquare,
        "color": AppColors.warning,
        "questions": "Coming Soon",
        "duration": "10 mins",
        "status": "Under Development",
        "isAvailable": false,
      },
    ];

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
        vertical: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner & Timer Toggle
          AppCard(
            backgroundColor: AppColors.surfaceElevated,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBadge.streak(ref.watch(authProvider).user?.streakDays ?? 0),
                      const SizedBox(height: AppSpacing.space3),
                      Text(
                        "Daily Practice Challenges",
                        style: AppTypography.h2(context, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      const Text(
                        "Sharpen your aptitude and core computer science knowledge with server-evaluated daily sets.",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Row(
                        children: [
                          Switch(
                            value: _timerEnabled,
                            onChanged: (v) => setState(() => _timerEnabled = v),
                            activeColor: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timerEnabled ? "Timed Mode Enabled (Recommended)" : "Untimed Practice Mode",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _timerEnabled ? AppColors.primaryLight : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          Text("Select Practice Category", style: AppTypography.h3(context, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.space4),

          LayoutBuilder(
            builder: (ctx, constraints) {
              int crossCount = constraints.maxWidth < 700 ? 1 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: crossCount == 1 ? 2.0 : 1.7,
                ),
                itemCount: practiceCategories.length,
                itemBuilder: (context, idx) {
                  final cat = practiceCategories[idx];
                  final isAvailable = cat["isAvailable"] as bool;
                  final color = cat["color"] as Color;

                  return AppCard(
                    onTap: () {
                      if (!isAvailable) {
                        ComingSoonModal.show(context);
                      } else {
                        context.go("/student/practice/session/${cat["id"]}?timer=$_timerEnabled");
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: AppRadii.inputRadius,
                              ),
                              child: Icon(cat["icon"] as IconData, color: color, size: 22),
                            ),
                            const SizedBox(width: AppSpacing.space3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat["title"] as String,
                                    style: AppTypography.h4(context, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    "${cat["questions"]} • ${cat["duration"]}",
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        Text(
                          cat["desc"] as String,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppBadge(
                              label: cat["status"] as String,
                              color: isAvailable ? AppColors.primary.withOpacity(0.12) : const Color(0x228B5CF6),
                              textColor: isAvailable ? AppColors.primary : AppColors.secondary,
                              isPill: true,
                            ),
                            AppButton(
                              text: isAvailable ? "Start Practice" : "Explore",
                              variant: isAvailable ? AppButtonVariant.primary : AppButtonVariant.secondary,
                              icon: isAvailable ? LucideIcons.play : LucideIcons.lock,
                              onPressed: () {
                                if (!isAvailable) {
                                  ComingSoonModal.show(context);
                                } else {
                                  context.go("/student/practice/session/${cat["id"]}?timer=$_timerEnabled");
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: Row(
        children: [
          if (!isMob) const AppSidebar(currentRoute: "/student/practice"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Daily Practice",
                  subtitle: "Aptitude, Technical & Placement Modules",
                  isDarkMode: isDark,
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMob ? const AppBottomNav(currentRoute: "/student/practice") : null,
    );
  }
}
