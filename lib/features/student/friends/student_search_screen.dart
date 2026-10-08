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

class StudentSearchScreen extends ConsumerStatefulWidget {
  const StudentSearchScreen({super.key});

  @override
  ConsumerState<StudentSearchScreen> createState() => _StudentSearchScreenState();
}

class _StudentSearchScreenState extends ConsumerState<StudentSearchScreen> {
  String _query = "";
  final List<Map<String, dynamic>> _directory = [
    {
      "id": "sophia_chen",
      "name": "Sophia Chen",
      "username": "sophia_chen",
      "studentId": "CA-2026-8190",
      "college": "MIT Institute of Technology",
      "department": "AI & Data Science",
      "points": 5620,
      "solved": 490,
      "followers": "1.8k",
      "streak": 32,
      "isFollowing": true,
    },
    {
      "id": "marcus_vance",
      "name": "Marcus Vance",
      "username": "marcus_v",
      "studentId": "CA-2026-7412",
      "college": "Stanford University",
      "department": "Software Engineering",
      "points": 4310,
      "solved": 310,
      "followers": "950",
      "streak": 18,
      "isFollowing": false,
    },
    {
      "id": "elena_rostova",
      "name": "Elena Rostova",
      "username": "elena_r",
      "studentId": "CA-2026-9530",
      "college": "Cambridge University",
      "department": "Mathematics & Computing",
      "points": 3980,
      "solved": 295,
      "followers": "820",
      "streak": 24,
      "isFollowing": false,
    },
    {
      "id": "david_kim",
      "name": "David Kim",
      "username": "david_kim",
      "studentId": "CA-2026-6119",
      "college": "Seoul National University",
      "department": "Computer Science",
      "points": 3200,
      "solved": 240,
      "followers": "420",
      "streak": 12,
      "isFollowing": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    final cleanQuery = _query.trim().toLowerCase().replaceAll('@', '');
    final matches = _directory.where((s) {
      final nameMatch = (s["name"] as String).toLowerCase().contains(cleanQuery);
      final usernameMatch = (s["username"] as String).toLowerCase().contains(cleanQuery);
      final studentIdMatch = (s["studentId"] as String).toLowerCase().contains(cleanQuery);
      return nameMatch || usernameMatch || studentIdMatch;
    }).toList();

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
        vertical: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Hero Box
          AppCard(
            backgroundColor: AppColors.surfaceElevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: AppRadii.inputRadius,
                      ),
                      child: const Icon(LucideIcons.search, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.space4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Search Friends & Classmates",
                            style: AppTypography.h3(context, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Search across global students by @username, full name, or Student ID",
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space5),

                // Search Input Field
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.inputRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.search, size: 20, color: AppColors.primaryLight),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          onChanged: (v) => setState(() => _query = v),
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: "Type @username (e.g. @sophia_chen, @marcus_v) or name...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textMuted),
                          onPressed: () => setState(() => _query = ""),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          // Matching Results Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cleanQuery.isEmpty
                    ? "Recommended Classmates (${_directory.length})"
                    : "Search Results for '$_query' (${matches.length})",
                style: AppTypography.h3(context, color: AppColors.textPrimary),
              ),
              if (cleanQuery.isNotEmpty)
                Text(
                  "Found ${matches.length} matching profiles",
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),

          // Results List
          if (matches.isEmpty) ...[
            AppCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(LucideIcons.users, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text("No students found matching '$_query'", style: AppTypography.h4(context, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      const Text("Try searching by @handle or Student ID prefix like CA-2026", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matches.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                final student = matches[idx];
                final isFollowing = student["isFollowing"] as bool;

                return AppCard(
                  child: Row(
                    children: [
                      // Story-ring Avatar
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                        ),
                        child: AppAvatar(
                          name: student["name"] as String,
                          radius: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space4),

                      // Student Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  student["name"] as String,
                                  style: AppTypography.h4(context, color: AppColors.textPrimary),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  "@${student["username"]}",
                                  style: const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${student["department"]} • ${student["college"]}",
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${student["followers"]} Followers • ${student["points"]} XP • ${student["solved"]} Solved",
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                      AppBadge.streak(student["streak"] as int),
                      const SizedBox(width: 12),

                      // View Instagram-style Profile Button
                      AppButton(
                        text: "View Profile",
                        variant: AppButtonVariant.primary,
                        icon: LucideIcons.user,
                        onPressed: () {
                          context.go("/student/profile/${student["id"]}");
                        },
                      ),
                      const SizedBox(width: 8),

                      // Follow / Unfollow Button
                      AppButton(
                        text: isFollowing ? "Following" : "Follow",
                        variant: isFollowing ? AppButtonVariant.secondary : AppButtonVariant.secondary,
                        onPressed: () {
                          setState(() {
                            student["isFollowing"] = !isFollowing;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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
                  title: "Find Students & Friends",
                  subtitle: "Search username directory and connect with developers worldwide",
                  showStreak: true,
                  streakDays: 14,
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
