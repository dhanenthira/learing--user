import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/theme_service.dart';

class StudentReportsScreen extends ConsumerWidget {
  const StudentReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    final categories = [
      {"name": "Quantitative Aptitude", "accuracy": 0.90, "percent": "90.0%", "attempted": "180 Questions", "color": AppColors.primary},
      {"name": "Computer Science Core", "accuracy": 0.875, "percent": "87.5%", "attempted": "120 Questions", "color": AppColors.secondary},
      {"name": "Data Structures & Algos", "accuracy": 0.85, "percent": "85.0%", "attempted": "80 Questions", "color": AppColors.accent},
      {"name": "System Design & Web", "accuracy": 0.78, "percent": "78.0%", "attempted": "45 Questions", "color": AppColors.warning},
    ];

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
        vertical: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Stats
          LayoutBuilder(
            builder: (ctx, constraints) {
              int crossAxisCount = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 950 ? 2 : 3);
              double aspectRatio;
              if (crossAxisCount == 1) {
                aspectRatio = constraints.maxWidth < 400 ? 2.2 : 2.5;
              } else if (crossAxisCount == 2) {
                aspectRatio = 1.5;
              } else {
                aspectRatio = 1.4;
              }
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: aspectRatio,
                children: const [
                  StatCard(
                    label: "Overall Solved",
                    value: "380 / 425",
                    icon: LucideIcons.checkCircle2,
                    iconColor: AppColors.success,
                    subtitle: "89.4% Accuracy",
                  ),
                  StatCard(
                    label: "Weekly Study Time",
                    value: "8.5 Hours",
                    icon: LucideIcons.clock,
                    iconColor: AppColors.primary,
                    subtitle: "+2.1 hrs vs last week",
                  ),
                  StatCard(
                    label: "Current Streak",
                    value: "14 Days",
                    icon: LucideIcons.flame,
                    iconColor: AppColors.streak,
                    subtitle: "Personal Record 🔥",
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.space6),

          // Category Performance Breakdown
          Text("Category-wise Mastery", style: AppTypography.h3(context, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.space4),

          AppCard(
            child: Column(
              children: categories.map((cat) {
                final color = cat["color"] as Color;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat["name"] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                          Text("${cat["percent"]} (${cat["attempted"]})", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: cat["accuracy"] as double,
                          minHeight: 8,
                          backgroundColor: AppColors.surfaceElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          // Strengths & Improvement Areas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppCard(
                  backgroundColor: AppColors.surfaceElevated,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(LucideIcons.sparkles, color: AppColors.success, size: 20),
                          SizedBox(width: 8),
                          Text("Strongest Topics", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text("• Arrays, Hash Maps & Two Pointers", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text("• Time & Distance / Relative Speed", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text("• Binary Search & Logarithmic Space", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppCard(
                  backgroundColor: AppColors.surfaceElevated,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(LucideIcons.target, color: AppColors.warning, size: 20),
                          SizedBox(width: 8),
                          Text("Recommended Focus Areas", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text("• Dynamic Programming (Knapsack & Subsequences)", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text("• Combinatorics & Probability Calculations", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text("• Graph Traversal (Dijkstra / Bellman-Ford)", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (!isMob) const AppSidebar(currentRoute: "/student/reports"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Student Analytics & Reports",
                  subtitle: "Visual breakdown of performance, study habits, and competencies",
                  isDarkMode: isDark,
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMob ? const AppBottomNav(currentRoute: "/student/reports") : null,
    );
  }
}
