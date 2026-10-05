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

class LearningHomeScreen extends ConsumerWidget {
  const LearningHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    final courses = [
      {
        "id": "mod_python",
        "title": "Python Programming",
        "desc": "Master Python syntax, data structures, OOP and standard libraries with hands-on practice.",
        "lessons": "4 Lessons",
        "progress": 0.50,
        "icon": LucideIcons.code2,
        "color": AppColors.primary,
        "tags": ["Beginner", "Popular", "OOP"]
      },
      {
        "id": "mod_dsa",
        "title": "Data Structures & Algorithms",
        "desc": "Master Arrays, Linked Lists, Trees, Graphs, Dynamic Programming and Big-O Analysis.",
        "lessons": "8 Lessons",
        "progress": 0.25,
        "icon": LucideIcons.layers,
        "color": AppColors.secondary,
        "tags": ["Intermediate", "Interview Prep"]
      },
      {
        "id": "mod_cpp",
        "title": "C++ for Competitive Programming",
        "desc": "Standard Template Library (STL), pointers, memory management, and ultra-fast I/O.",
        "lessons": "6 Lessons",
        "progress": 0.0,
        "icon": LucideIcons.cpu,
        "color": AppColors.accent,
        "tags": ["Fast Speed", "STL", "Memory"]
      },
      {
        "id": "mod_web",
        "title": "Full-Stack Web Development",
        "desc": "HTML5, modern CSS, JavaScript ES6+, RESTful APIs, and backend architecture.",
        "lessons": "10 Lessons",
        "progress": 0.10,
        "icon": LucideIcons.globe,
        "color": AppColors.warning,
        "tags": ["Frontend", "Backend", "APIs"]
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
          // Banner
          AppCard(
            backgroundColor: const Color(0xFF172554), // Dark Navy Blue
            borderColor: AppColors.primary.withOpacity(0.4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppBadge(
                        label: "W3SCHOOLS-STYLE LEARNING PATHS",
                        color: Color(0x223B82F6),
                        textColor: AppColors.primaryLight,
                        isPill: true,
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      Text(
                        "Structured Interactive Programming Tracks",
                        style: AppTypography.h2(context, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      const Text(
                        "Learn syntax step-by-step with interactive executable code blocks, definitions, and direct practice exercises.",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          // Track List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Available Learning Tracks", style: AppTypography.h3(context, color: AppColors.textPrimary)),
              Container(
                width: 220,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadii.inputRadius,
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: const Row(
                  children: [
                    Icon(LucideIcons.search, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: "Search topics...",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                itemCount: courses.length,
                itemBuilder: (context, idx) {
                  final c = courses[idx];
                  final color = c["color"] as Color;

                  return AppCard(
                    onTap: () => context.go("/student/learning/lesson/py_intro"),
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
                              child: Icon(c["icon"] as IconData, color: color, size: 22),
                            ),
                            const SizedBox(width: AppSpacing.space3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c["title"] as String,
                                    style: AppTypography.h4(context, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    c["lessons"] as String,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        Text(
                          c["desc"] as String,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Progress", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                      Text("${((c["progress"] as double) * 100).toInt()}%",
                                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: c["progress"] as double,
                                      minHeight: 6,
                                      backgroundColor: AppColors.border,
                                      valueColor: AlwaysStoppedAnimation<Color>(color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            AppButton(
                              text: (c["progress"] as double) > 0 ? "Resume" : "Start",
                              variant: AppButtonVariant.primary,
                              onPressed: () => context.go("/student/learning/lesson/py_intro"),
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
          if (!isMob) const AppSidebar(currentRoute: "/student/learning"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Interactive Learning",
                  subtitle: "W3Schools-style concept guides with executable examples",
                  isDarkMode: isDark,
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMob ? const AppBottomNav(currentRoute: "/student/learning") : null,
    );
  }
}
