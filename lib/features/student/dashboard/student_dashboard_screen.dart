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
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/widgets/coming_soon_modal.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final user = authState.user;

    final isMob = ResponsiveLayout.isMobile(context);

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
        vertical: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Section
          AppCard(
            backgroundColor: AppColors.surfaceElevated,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Welcome back, ${user?.name ?? 'Alex'}!",
                            style: AppTypography.h2(context, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: AppSpacing.space3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: AppRadii.badgeRadius,
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Text(
                              user?.studentId ?? "CA-2026-9042",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      const Text(
                        "You're on a 14-day learning streak! Solve today's technical practice and climb the leaderboard.",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          AppButton(
                            text: "Continue Learning",
                            icon: LucideIcons.playCircle,
                            onPressed: () => context.go("/student/learning"),
                          ),
                          AppButton(
                            text: "Daily Practice",
                            variant: AppButtonVariant.secondary,
                            icon: LucideIcons.brain,
                            onPressed: () => context.go("/student/practice"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isMob) ...[
                  const SizedBox(width: AppSpacing.space6),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.flame, size: 54, color: AppColors.streak),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          // 2. Statistics Grid
          LayoutBuilder(
            builder: (ctx, constraints) {
              int crossAxisCount = constraints.maxWidth < 600 ? 1 : (constraints.maxWidth < 1100 ? 2 : 4);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.45,
                children: [
                  StatCard(
                    label: "Questions Solved",
                    value: "${user?.questionsSolved ?? 380}",
                    icon: LucideIcons.checkCircle2,
                    iconColor: AppColors.success,
                    subtitle: "+18 this week",
                    progress: 0.72,
                  ),
                  StatCard(
                    label: "Overall Accuracy",
                    value: "${user?.overallAccuracy ?? 88.2}%",
                    icon: LucideIcons.target,
                    iconColor: AppColors.primary,
                    subtitle: "Top 5% Tier",
                    progress: 0.88,
                  ),
                  StatCard(
                    label: "Coding Solved",
                    value: "${user?.codingProblemsSolved ?? 56}",
                    icon: LucideIcons.code2,
                    iconColor: AppColors.secondary,
                    subtitle: "LeetCode & Arenas",
                    progress: 0.65,
                  ),
                  StatCard(
                    label: "Battles Won",
                    value: "${user?.battlesWon ?? 19}",
                    icon: LucideIcons.swords,
                    iconColor: AppColors.streak,
                    subtitle: "Win Rate 76%",
                    progress: 0.76,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.space8),

          // 3. Main Dashboard Sections
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column (Daily Practice & Learning)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Practice Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text("Today's Practice Sets", style: AppTypography.h3(context, color: AppColors.textPrimary)),
                        ),
                        TextButton(
                          onPressed: () => context.go("/student/practice"),
                          child: const Text("View All →", style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space3),

                    AppCard(
                      child: Column(
                        children: [
                          _buildPracticeRow(
                            context,
                            title: "Daily Aptitude Challenge #42",
                            topic: "Time & Distance • Profit & Loss",
                            duration: "10 mins",
                            difficulty: "Easy",
                            isCompleted: false,
                            onTap: () => context.go("/student/practice"),
                          ),
                          const Divider(height: 24),
                          _buildPracticeRow(
                            context,
                            title: "Daily Technical Challenge #42",
                            topic: "DSA Complexity • Computer Networks",
                            duration: "8 mins",
                            difficulty: "Medium",
                            isCompleted: true,
                            onTap: () => context.go("/student/practice"),
                          ),
                          const Divider(height: 24),
                          _buildPracticeRow(
                            context,
                            title: "Communication Practice",
                            topic: "Corporate Etiquette & Verbal Reasoning",
                            duration: "15 mins",
                            difficulty: "Easy",
                            isCompleted: false,
                            isComingSoon: true,
                            onTap: () => ComingSoonModal.show(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space6),

                    // Coding Arena Highlight
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text("Recommended Coding Problem", style: AppTypography.h3(context, color: AppColors.textPrimary)),
                        ),
                        TextButton(
                          onPressed: () => context.go("/student/coding"),
                          child: const Text("Open Arena →", style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space3),

                    AppCard(
                      onTap: () => context.go("/student/coding/workspace/cp_two_sum"),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: AppRadii.inputRadius,
                            ),
                            child: const Icon(LucideIcons.code2, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: AppSpacing.space4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Two Sum Target Indices",
                                      style: AppTypography.h4(context, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(width: 8),
                                    AppBadge.difficulty("easy"),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Arrays & Hash Table • 82.4% Acceptance • 450 Submissions",
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(LucideIcons.chevronRight, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (!isMob) ...[
                const SizedBox(width: AppSpacing.space6),
                // Right Column (Leaderboard & Quick Actions)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text("Leaderboard", style: AppTypography.h3(context, color: AppColors.textPrimary)),
                          ),
                          TextButton(
                            onPressed: () => context.go("/student/leaderboard"),
                            child: const Text("Full Rankings →", style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space3),

                      AppCard(
                        child: Column(
                          children: [
                            _buildLeaderboardRow("1", "Sophia Chen", "5,620 XP", "https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia", isGold: true),
                            const Divider(height: 18),
                            _buildLeaderboardRow("2", user?.name ?? "Alex Mercer", "4,850 XP", "https://api.dicebear.com/7.x/avataaars/svg?seed=Alex", isYou: true),
                            const Divider(height: 18),
                            _buildLeaderboardRow("3", "Marcus Vance", "4,310 XP", "https://api.dicebear.com/7.x/avataaars/svg?seed=Marcus"),
                            const Divider(height: 18),
                            _buildLeaderboardRow("4", "Elena Rostova", "3,980 XP", "https://api.dicebear.com/7.x/avataaars/svg?seed=Elena"),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space6),

                      // Battle Room Call to Action
                      AppCard(
                        backgroundColor: const Color(0xFF1E1B4B), // Deep indigo
                        borderColor: AppColors.secondary.withOpacity(0.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.swords, color: AppColors.purple, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  "1v1 Live Battle",
                                  style: AppTypography.h4(context, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Challenge friends or join an active match to win XP & trophy badges.",
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            AppButton(
                              text: "Create Battle Room",
                              variant: AppButtonVariant.primary,
                              icon: LucideIcons.plus,
                              width: double.infinity,
                              onPressed: () => context.go("/student/battles"),
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
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (!isMob)
            const AppSidebar(currentRoute: "/student/dashboard"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Student Dashboard",
                  subtitle: "CodeArena Learning & Competition Suite",
                  streakDays: user?.streakDays ?? 14,
                  isDarkMode: isDark,
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMob ? const AppBottomNav(currentRoute: "/student/dashboard") : null,
    );
  }

  Widget _buildPracticeRow(
    BuildContext context, {
    required String title,
    required String topic,
    required String duration,
    required String difficulty,
    required bool isCompleted,
    bool isComingSoon = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.inputRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success.withOpacity(0.15)
                    : (isComingSoon ? AppColors.secondary.withOpacity(0.15) : AppColors.primary.withOpacity(0.15)),
                borderRadius: AppRadii.badgeRadius,
              ),
              child: Icon(
                isCompleted ? LucideIcons.check : (isComingSoon ? LucideIcons.sparkles : LucideIcons.play),
                size: 18,
                color: isCompleted ? AppColors.success : (isComingSoon ? AppColors.secondary : AppColors.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    topic,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isComingSoon)
              const AppBadge(label: "SOON", isPill: true, color: Color(0x228B5CF6), textColor: AppColors.secondary)
            else ...[
              AppBadge.difficulty(difficulty),
              const SizedBox(width: 8),
              Text(duration, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(String rank, String name, String points, String avatar, {bool isGold = false, bool isYou = false}) {
    return Row(
      children: [
        Container(
          width: 24,
          alignment: Alignment.center,
          child: Text(
            rank,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isGold ? const Color(0xFFFBBF24) : (isYou ? AppColors.primary : AppColors.textMuted),
            ),
          ),
        ),
        const SizedBox(width: 8),
        AppAvatar(name: name, radius: 14),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name + (isYou ? " (You)" : ""),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isYou ? FontWeight.w700 : FontWeight.w500,
              color: isYou ? AppColors.primaryLight : AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          points,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
