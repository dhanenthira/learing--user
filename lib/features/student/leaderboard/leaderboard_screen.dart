import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/theme_service.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _period = "All Time";
  String _category = "All";

  final List<Map<String, dynamic>> _rankings = [
    {
      "rank": 1,
      "name": "Sophia Chen",
      "studentId": "CA-2026-8190",
      "solved": 450,
      "accuracy": "91.0%",
      "points": 5620,
      "battleWins": 27,
      "streak": 21,
      "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia"
    },
    {
      "rank": 2,
      "name": "Alex Mercer (You)",
      "studentId": "CA-2026-9042",
      "solved": 380,
      "accuracy": "88.2%",
      "points": 4850,
      "battleWins": 19,
      "streak": 14,
      "isYou": true,
      "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Alex"
    },
    {
      "rank": 3,
      "name": "Marcus Vance",
      "studentId": "CA-2026-7241",
      "solved": 310,
      "accuracy": "85.4%",
      "points": 4310,
      "battleWins": 15,
      "streak": 10,
      "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Marcus"
    },
    {
      "rank": 4,
      "name": "Elena Rostova",
      "studentId": "CA-2026-5120",
      "solved": 280,
      "accuracy": "84.0%",
      "points": 3980,
      "battleWins": 12,
      "streak": 7,
      "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Elena"
    },
    {
      "rank": 5,
      "name": "David Kim",
      "studentId": "CA-2026-3829",
      "solved": 240,
      "accuracy": "81.5%",
      "points": 3520,
      "battleWins": 9,
      "streak": 5,
      "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=David"
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          // Filter Tabs
          Row(
            children: [
              // Period Filter
              ...["Daily", "Weekly", "Monthly", "All Time"].map((p) {
                final isSel = _period == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500, color: isSel ? Colors.white : AppColors.textSecondary)),
                    selected: isSel,
                    onSelected: (v) => setState(() => _period = p),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),

          // Top 3 Podium
          if (!isMob)
            Row(
              children: [
                _buildPodiumCard(_rankings[1], 2, const Color(0xFF94A3B8)),
                const SizedBox(width: 16),
                _buildPodiumCard(_rankings[0], 1, const Color(0xFFFBBF24)),
                const SizedBox(width: 16),
                _buildPodiumCard(_rankings[2], 3, const Color(0xFFB45309)),
              ],
            ),
          const SizedBox(height: AppSpacing.space6),

          // Leaderboard Table
          AppCard(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _rankings.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final r = _rankings[idx];
                final isYou = r["isYou"] == true;

                return Container(
                  color: isYou ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          "#${r["rank"]}",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: r["rank"] == 1 ? const Color(0xFFFBBF24) : (r["rank"] == 2 ? const Color(0xFF94A3B8) : (r["rank"] == 3 ? const Color(0xFFB45309) : AppColors.textMuted)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AppAvatar(name: r["name"] ?? "User", radius: 18),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r["name"],
                              style: TextStyle(
                                fontWeight: isYou ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 14,
                                color: isYou ? AppColors.primaryLight : AppColors.textPrimary,
                              ),
                            ),
                            Text(r["studentId"], style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                      if (!isMob) ...[
                        Text("Accuracy: ${r["accuracy"]}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(width: 24),
                        Text("Solved: ${r["solved"]}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(width: 24),
                      ],
                      Text(
                        "${r["points"]} XP",
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryLight),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (!isMob) const AppSidebar(currentRoute: "/student/leaderboard"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Hall of Fame Leaderboard",
                  subtitle: "Global rankings computed transparently via server-verified benchmarks",
                  isDarkMode: isDark,
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMob ? const AppBottomNav(currentRoute: "/student/leaderboard") : null,
    );
  }

  Widget _buildPodiumCard(Map<String, dynamic> r, int rank, Color medalColor) {
    return Expanded(
      child: AppCard(
        backgroundColor: AppColors.surfaceElevated,
        borderColor: rank == 1 ? const Color(0xFFFBBF24).withOpacity(0.5) : AppColors.border,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: medalColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(
                rank == 1 ? "🥇 1ST PLACE" : (rank == 2 ? "🥈 2ND PLACE" : "🥉 3RD PLACE"),
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: medalColor),
              ),
            ),
            const SizedBox(height: 12),
            AppAvatar(name: r["name"] ?? "User", radius: 28),
            const SizedBox(height: 8),
            Text(r["name"], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
            Text(r["studentId"], style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(height: 8),
            Text("${r["points"]} XP", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: medalColor)),
          ],
        ),
      ),
    );
  }
}
