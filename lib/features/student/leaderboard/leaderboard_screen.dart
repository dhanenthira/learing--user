import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/network/api_client.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _period = "All Time";
  String _category = "All";
  List<Map<String, dynamic>> _rankings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final res = await ApiClient().dio.get("/leaderboard");
      if (res.data is List && mounted) {
        final list = (res.data as List).map((e) {
          final m = Map<String, dynamic>.from(e);
          return {
            "rank": m["rank"] ?? 1,
            "name": m["name"] ?? "Student",
            "studentId": m["student_id"] ?? "CA-2026",
            "solved": m["questions_solved"] ?? 0,
            "accuracy": "${(m["accuracy"] ?? 0.0).toStringAsFixed(1)}%",
            "points": m["coding_points"] ?? 0,
            "battleWins": m["battle_wins"] ?? 0,
            "streak": m["streak_days"] ?? 0,
            "avatar": m["avatar_url"] ?? "",
            "userId": m["user_id"] ?? "",
          };
        }).toList();

        setState(() {
          _rankings = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

          // Top Podium (if at least 3 exist)
          if (!isMob && _rankings.length >= 3)
            Row(
              children: [
                _buildPodiumCard(_rankings[1], 2, const Color(0xFF94A3B8)),
                const SizedBox(width: 16),
                _buildPodiumCard(_rankings[0], 1, const Color(0xFFFBBF24)),
                const SizedBox(width: 16),
                _buildPodiumCard(_rankings[2], 3, const Color(0xFFB45309)),
              ],
            )
          else if (!isMob && _rankings.isNotEmpty)
            Row(
              children: [
                for (int i = 0; i < _rankings.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  _buildPodiumCard(
                    _rankings[i],
                    i + 1,
                    i == 0 ? const Color(0xFFFBBF24) : const Color(0xFF94A3B8),
                  ),
                ],
              ],
            ),
          const SizedBox(height: AppSpacing.space6),

          // Leaderboard Table
          AppCard(
            padding: EdgeInsets.zero,
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : (_rankings.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "No rankings recorded yet in database. Start practicing to climb the leaderboard!",
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _rankings.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (ctx, idx) {
                          final r = _rankings[idx];
                          final currentUser = ref.watch(authProvider).user;
                          final isYou = r["userId"] == currentUser?.id || r["studentId"] == currentUser?.studentId;

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
                                AppAvatar(
                                  name: r["name"] ?? "User",
                                  imageUrl: (r["avatar"] as String?)?.isNotEmpty == true ? r["avatar"] : null,
                                  radius: 18,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r["name"] + (isYou ? " (You)" : ""),
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
                      )),
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
            AppAvatar(
              name: r["name"] ?? "User",
              imageUrl: (r["avatar"] as String?)?.isNotEmpty == true ? r["avatar"] : null,
              radius: 28,
            ),
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
