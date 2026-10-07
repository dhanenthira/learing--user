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
import '../../../core/network/api_client.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends ConsumerState<StudentDashboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoadingLeaderboard = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final res = await ApiClient().dio.get("/leaderboard");
      if (res.data is List && mounted) {
        setState(() {
          _leaderboard = (res.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoadingLeaderboard = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingLeaderboard = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final user = authState.user;

    final isMob = ResponsiveLayout.isMobile(context);
    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final mutedTextColor = isDark ? AppColors.textMuted : AppColors.lightTextMuted;

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
        vertical: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Section (Real User Profile Data)
          AppCard(
            isElevated: true,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              "Welcome back, ${user != null && user.name.isNotEmpty ? user.name : 'Learner'}!",
                              style: AppTypography.h2(context, color: primaryTextColor),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.space3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.1),
                              borderRadius: AppRadii.badgeRadius,
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Text(
                              user?.studentId ?? "CA-2026",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        (user != null && user.streakDays > 0)
                            ? "You're on a ${user.streakDays}-day learning streak! Keep practicing to climb the leaderboard."
                            : "Welcome to CodeArena! Start practicing questions to build your streak and earn points.",
                        style: TextStyle(color: secondaryTextColor, fontSize: 14),
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
                      color: AppColors.primary.withOpacity(isDark ? 0.08 : 0.06),
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
                    value: "${user?.questionsSolved ?? 0}",
                    icon: LucideIcons.checkCircle2,
                    iconColor: AppColors.success,
                    subtitle: "Recorded in DB",
                    progress: (user != null && user.questionsSolved > 0) ? 0.5 : 0.0,
                  ),
                  StatCard(
                    label: "Overall Accuracy",
                    value: "${user?.overallAccuracy != null ? user!.overallAccuracy.toStringAsFixed(1) : "0.0"}%",
                    icon: LucideIcons.target,
                    iconColor: AppColors.primary,
                    subtitle: "Accuracy score",
                    progress: (user != null && user.overallAccuracy > 0) ? (user.overallAccuracy / 100.0) : 0.0,
                  ),
                  StatCard(
                    label: "Coding Solved",
                    value: "${user?.codingProblemsSolved ?? 0}",
                    icon: LucideIcons.code2,
                    iconColor: AppColors.secondary,
                    subtitle: "Problems solved",
                    progress: (user != null && user.codingProblemsSolved > 0) ? 0.4 : 0.0,
                  ),
                  StatCard(
                    label: "Battles Won",
                    value: "${user?.battlesWon ?? 0}",
                    icon: LucideIcons.swords,
                    iconColor: AppColors.streak,
                    subtitle: "Arena battles",
                    progress: (user != null && user.battlesWon > 0) ? 0.5 : 0.0,
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
                          child: Text("Today's Practice Sets", style: AppTypography.h3(context, color: primaryTextColor)),
                        ),
                        TextButton(
                          onPressed: () => context.go("/student/practice"),
                          child: Text("View All →", style: TextStyle(color: isDark ? AppColors.primary : AppColors.primaryDark)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space3),

                    AppCard(
                      child: Column(
                        children: [
                          _buildPracticeRow(
                            context,
                            isDark: isDark,
                            title: "Quantitative & Logical Aptitude",
                            topic: "Speed Math • Percentages • Logical Reasoning",
                            duration: "15 mins",
                            difficulty: "Aptitude",
                            isCompleted: (user != null && user.questionsSolved > 0),
                            onTap: () => context.go("/student/practice/session/aptitude"),
                          ),
                          const Divider(height: 24),
                          _buildPracticeRow(
                            context,
                            isDark: isDark,
                            title: "Technical & Core CS Track",
                            topic: "Data Structures, Algorithms & Computer Networks",
                            duration: "15 mins",
                            difficulty: "Technical",
                            isCompleted: false,
                            onTap: () => context.go("/student/practice/session/technical"),
                          ),
                          const Divider(height: 24),
                          _buildPracticeRow(
                            context,
                            isDark: isDark,
                            title: "Mixed Placement Challenge",
                            topic: "Balanced Placement Assessment (Aptitude + CS)",
                            duration: "20 mins",
                            difficulty: "Mixed",
                            isCompleted: false,
                            onTap: () => context.go("/student/practice/session/mixed"),
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
                          child: Text("Recommended Coding Problem", style: AppTypography.h3(context, color: primaryTextColor)),
                        ),
                        TextButton(
                          onPressed: () => context.go("/student/coding"),
                          child: Text("Open Arena →", style: TextStyle(color: isDark ? AppColors.primary : AppColors.primaryDark)),
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
                              color: AppColors.primary.withOpacity(isDark ? 0.12 : 0.1),
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
                                      style: AppTypography.h4(context, color: primaryTextColor),
                                    ),
                                    const SizedBox(width: 8),
                                    AppBadge.difficulty("easy"),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Arrays & Hash Table • Live Problem in Database",
                                  style: TextStyle(color: mutedTextColor, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Icon(LucideIcons.chevronRight, color: mutedTextColor),
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
                            child: Text("Leaderboard", style: AppTypography.h3(context, color: primaryTextColor)),
                          ),
                          TextButton(
                            onPressed: () => context.go("/student/leaderboard"),
                            child: Text("Full Rankings →", style: TextStyle(color: isDark ? AppColors.primary : AppColors.primaryDark)),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space3),

                      AppCard(
                        child: _isLoadingLeaderboard
                            ? const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : (_leaderboard.isEmpty
                                ? (user != null
                                    ? _buildLeaderboardRow("1", user.name, "${user.totalPoints} XP", user.avatarUrl ?? "", isGold: true, isYou: true, isDark: isDark)
                                    : Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Text("No rankings recorded yet.", style: TextStyle(color: mutedTextColor, fontSize: 13)),
                                        ),
                                      ))
                                : Column(
                                    children: [
                                      for (int i = 0; i < _leaderboard.take(4).length; i++) ...[
                                        if (i > 0) const Divider(height: 18),
                                        _buildLeaderboardRow(
                                          "${_leaderboard[i]['rank'] ?? (i + 1)}",
                                          _leaderboard[i]['name'] ?? "Student",
                                          "${_leaderboard[i]['coding_points'] ?? _leaderboard[i]['points'] ?? 0} XP",
                                          _leaderboard[i]['avatar_url'] ?? _leaderboard[i]['avatar'] ?? "",
                                          isGold: i == 0,
                                          isYou: _leaderboard[i]['user_id'] == user?.id || _leaderboard[i]['student_id'] == user?.studentId,
                                          isDark: isDark,
                                        ),
                                      ],
                                    ],
                                  )),
                      ),
                      const SizedBox(height: AppSpacing.space6),

                      // Battle Room Call to Action
                      AppCard(
                        backgroundColor: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFF3E8FF), // Indigo / Soft Purple
                        borderColor: AppColors.secondary.withOpacity(isDark ? 0.5 : 0.3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(LucideIcons.swords, color: AppColors.purple, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  "1v1 Live Battle",
                                  style: AppTypography.h4(context, color: primaryTextColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Challenge friends or join an active match to win XP & trophy badges.",
                              style: TextStyle(color: secondaryTextColor, fontSize: 13),
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
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
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
                  streakDays: user?.streakDays ?? 0,
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
    required bool isDark,
    required String title,
    required String topic,
    required String duration,
    required String difficulty,
    required bool isCompleted,
    bool isComingSoon = false,
    required VoidCallback onTap,
  }) {
    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final mutedTextColor = isDark ? AppColors.textMuted : AppColors.lightTextMuted;

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
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: primaryTextColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    topic,
                    style: TextStyle(color: mutedTextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isComingSoon)
              const AppBadge(label: "SOON", isPill: true, color: Color(0x228B5CF6), textColor: AppColors.secondary)
            else ...[
              AppBadge.difficulty(difficulty),
              const SizedBox(width: 8),
              Text(duration, style: TextStyle(color: mutedTextColor, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(
    String rank,
    String name,
    String points,
    String avatar, {
    bool isGold = false,
    bool isYou = false,
    required bool isDark,
  }) {
    final primaryTextColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final mutedTextColor = isDark ? AppColors.textMuted : AppColors.lightTextMuted;

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
              color: isGold
                  ? const Color(0xFFFBBF24)
                  : (isYou ? (isDark ? AppColors.primaryLight : AppColors.primaryDark) : mutedTextColor),
            ),
          ),
        ),
        const SizedBox(width: 8),
        AppAvatar(name: name, imageUrl: avatar.isNotEmpty ? avatar : null, radius: 14),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name + (isYou ? " (You)" : ""),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isYou ? FontWeight.w700 : FontWeight.w500,
              color: isYou ? (isDark ? AppColors.primaryLight : AppColors.primaryDark) : primaryTextColor,
            ),
          ),
        ),
        Text(
          points,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondaryTextColor),
        ),
      ],
    );
  }
}
