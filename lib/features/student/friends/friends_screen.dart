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
import '../../../core/services/theme_service.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  String _search = "";

  final List<Map<String, dynamic>> _friends = [
    {
      "id": "u2",
      "studentId": "CA-2026-8190",
      "name": "Sophia Chen",
      "college": "Tech University",
      "points": 5620,
      "solved": 450,
      "streak": 21,
      "isFollowing": true,
      "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia"
    },
    {
      "id": "u3",
      "studentId": "CA-2026-7241",
      "name": "Marcus Vance",
      "college": "State Engineering College",
      "points": 4310,
      "solved": 310,
      "streak": 10,
      "isFollowing": true,
      "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Marcus"
    },
    {
      "id": "u4",
      "studentId": "CA-2026-5120",
      "name": "Elena Rostova",
      "college": "Polytechnic Institute",
      "points": 3980,
      "solved": 280,
      "streak": 7,
      "isFollowing": false,
      "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Elena"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    final filtered = _friends.where((f) {
      if (_search.isNotEmpty &&
          !f["name"].toString().toLowerCase().contains(_search.toLowerCase()) &&
          !f["studentId"].toString().toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
        vertical: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Box
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.inputRadius,
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(LucideIcons.search, size: 20, color: AppColors.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Search students by Student ID (e.g. CA-2026-8190) or name...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          Text("Friends & Following (${filtered.length})", style: AppTypography.h3(context, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.space4),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) {
              final f = filtered[idx];
              final isFollowing = f["isFollowing"] as bool;

              return AppCard(
                onTap: () {
                  final usernameMap = {
                    "Sophia Chen": "sophia_chen",
                    "Marcus Vance": "marcus_vance",
                    "Elena Rostova": "elena_rostova",
                  };
                  final uid = usernameMap[f["name"]] ?? "sophia_chen";
                  context.go("/student/profile/$uid");
                },
                child: Row(
                  children: [
                    AppAvatar(name: f["name"] ?? "Student", radius: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(f["name"], style: AppTypography.h4(context, color: AppColors.textPrimary)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: AppRadii.badgeRadius,
                                ),
                                child: Text(f["studentId"], style: const TextStyle(fontSize: 10, color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("${f["college"]} • ${f["points"]} XP • ${f["solved"]} Solved", style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                    AppBadge.streak(f["streak"]),
                    const SizedBox(width: 12),
                    AppButton(
                      text: "View Profile",
                      variant: AppButtonVariant.primary,
                      icon: LucideIcons.user,
                      onPressed: () {
                        final usernameMap = {
                          "Sophia Chen": "sophia_chen",
                          "Marcus Vance": "marcus_vance",
                          "Elena Rostova": "elena_rostova",
                        };
                        final uid = usernameMap[f["name"]] ?? "sophia_chen";
                        context.go("/student/profile/$uid");
                      },
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: isFollowing ? "Following" : "Follow",
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        setState(() {
                          f["isFollowing"] = !isFollowing;
                        });
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
      drawer: isMob ? const Drawer(child: AppSidebar(currentRoute: "/student/friends")) : null,
      body: Row(
        children: [
          if (!isMob) const AppSidebar(currentRoute: "/student/friends"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Friends & Network",
                  subtitle: "Connect, follow peer progress, and challenge teammates",
                  isDarkMode: isDark,
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMob ? const AppBottomNav(currentRoute: "/student/friends") : null,
    );
  }
}
