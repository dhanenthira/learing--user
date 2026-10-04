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

class StudentProfileScreen extends ConsumerStatefulWidget {
  final String? studentId;

  const StudentProfileScreen({super.key, this.studentId});

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;

  // Mock directory of other students if viewing someone else
  final Map<String, Map<String, dynamic>> _mockProfiles = {
    "sophia_chen": {
      "name": "Sophia Chen",
      "username": "sophia_chen",
      "studentId": "CA-2026-8190",
      "college": "MIT Institute of Technology",
      "department": "AI & Data Science",
      "bio": "AI Researcher & Competitive Coder 🤖 | 1st in Global Rankings | Python & C++ Lead",
      "followers": "1.8k",
      "following": "240",
      "solved": 490,
      "xp": "5,620 XP",
      "streak": 32,
      "rank": "#1",
    },
    "marcus_vance": {
      "name": "Marcus Vance",
      "username": "marcus_v",
      "studentId": "CA-2026-7412",
      "college": "Stanford University",
      "department": "Software Engineering",
      "bio": "Building distributed systems ⚡ | LeetCode Knight ⚔️ | Algorithms Enthusiast",
      "followers": "950",
      "following": "310",
      "solved": 310,
      "xp": "4,310 XP",
      "streak": 18,
      "rank": "#3",
    },
    "elena_rostova": {
      "name": "Elena Rostova",
      "username": "elena_r",
      "studentId": "CA-2026-9530",
      "college": "Cambridge University",
      "department": "Mathematics & Computing",
      "bio": "Graph Theory & Discrete Math 📊 | Fast Solver | Top 5% Accuracy",
      "followers": "820",
      "following": "190",
      "solved": 295,
      "xp": "3,980 XP",
      "streak": 24,
      "rank": "#4",
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    // Determine whether this is viewing self or another student
    final isSelf = widget.studentId == null || widget.studentId == authState.user?.studentId || widget.studentId == "me";
    final profileData = !isSelf && widget.studentId != null && _mockProfiles.containsKey(widget.studentId)
        ? _mockProfiles[widget.studentId]!
        : null;

    final displayName = isSelf ? (authState.user?.name ?? "Alex Mercer") : (profileData?["name"] ?? "Student");
    final displayUsername = isSelf ? "alex_mercer" : (profileData?["username"] ?? "student_user");
    final displayStudentId = isSelf ? (authState.user?.studentId ?? "CA-2026-9042") : (profileData?["studentId"] ?? "CA-2026-8888");
    final displayCollege = isSelf ? (authState.user?.collegeName ?? "National Institute of Tech") : (profileData?["college"] ?? "Engineering University");
    final displayDept = isSelf ? (authState.user?.department ?? "Computer Science & Engineering") : (profileData?["department"] ?? "Computer Science");
    final displayBio = isSelf ? "Passionate competitive programmer, algorithm enthusiast, and full-stack developer 🚀 | Level 12 Coder | 14-Day Active Streak 🔥" : (profileData?["bio"] ?? "Student coder on CodeArena");
    final displayFollowers = isSelf ? "1.2k" : (profileData?["followers"] ?? "640");
    final displayFollowing = isSelf ? "340" : (profileData?["following"] ?? "180");
    final displaySolved = isSelf ? (authState.user?.questionsSolved ?? 380) : (profileData?["solved"] ?? 280);

    Widget content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
        vertical: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Instagram-Style Profile Header Card
          AppCard(
            backgroundColor: AppColors.surfaceElevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Stats Counters
                Row(
                  children: [
                    // Profile Avatar with Gradient Story Ring
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceElevated,
                        ),
                        child: AppAvatar(
                          name: displayName,
                          radius: isMob ? 36 : 46,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space5),

                    // Stats: Solved, Followers, Following
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn("$displaySolved", "Solved"),
                          _buildStatColumn(displayFollowers, "Followers"),
                          _buildStatColumn(displayFollowing, "Following"),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),

                // Name & Verified Badge
                Row(
                  children: [
                    Text(
                      displayName,
                      style: AppTypography.h3(context, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: AppRadii.badgeRadius,
                      ),
                      child: Text(
                        displayStudentId,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Handle (@username)
                Text(
                  "@$displayUsername",
                  style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),

                // College & Dept Tags
                Row(
                  children: [
                    const Icon(LucideIcons.school, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "$displayDept • $displayCollege",
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Bio
                Text(
                  displayBio,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: AppSpacing.space4),

                // Action Buttons (Edit Profile / Follow & Message)
                Row(
                  children: [
                    if (isSelf) ...[
                      Expanded(
                        child: AppButton(
                          text: "Edit Profile",
                          variant: AppButtonVariant.secondary,
                          icon: LucideIcons.settings,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Profile settings & customization opened")),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          text: "Share Profile",
                          variant: AppButtonVariant.secondary,
                          icon: LucideIcons.copy,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Profile URL copied to clipboard!")),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: AppButton(
                          text: _isFollowing ? "Following" : "Follow",
                          variant: _isFollowing ? AppButtonVariant.secondary : AppButtonVariant.primary,
                          icon: _isFollowing ? LucideIcons.check : LucideIcons.plus,
                          onPressed: () {
                            setState(() {
                              _isFollowing = !_isFollowing;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          text: "1v1 Challenge",
                          variant: AppButtonVariant.secondary,
                          icon: LucideIcons.swords,
                          onPressed: () => context.go("/student/battles"),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space5),

          // 2. Instagram Story Highlights Carousel (Achievement Circles)
          Text("Highlights & Story Milestones", style: AppTypography.h4(context, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.space3),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHighlightCircle("🔥 14-Day", "Streak", AppColors.streak),
                const SizedBox(width: 16),
                _buildHighlightCircle("⚔️ Master", "Battles", AppColors.secondary),
                const SizedBox(width: 16),
                _buildHighlightCircle("⚡ Ace", "Python", AppColors.primary),
                const SizedBox(width: 16),
                _buildHighlightCircle("🎯 Top 5%", "DSA Rank", AppColors.success),
                const SizedBox(width: 16),
                _buildHighlightCircle("🏅 Gold", "Hackathon", const Color(0xFFF59E0B)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          // 3. Instagram-Style Tab Bar
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primaryLight,
              unselectedLabelColor: AppColors.textMuted,
              tabs: const [
                Tab(icon: Icon(LucideIcons.award), text: "BADGES & TROPHIES"),
                Tab(icon: Icon(LucideIcons.code2), text: "SOLVED FEED"),
                Tab(icon: Icon(LucideIcons.swords), text: "BATTLES"),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space4),

          // Tab Content
          SizedBox(
            height: 380,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Instagram Post Grid Style for Badges
                _buildBadgesGrid(),

                // Tab 2: Solved Problems Feed
                _buildSolvedFeed(context),

                // Tab 3: Battles History
                _buildBattlesList(),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (!isMob) const AppSidebar(currentRoute: "/student/profile"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: isSelf ? "My Profile" : "$displayName's Profile",
                  subtitle: "@$displayUsername • CodeArena Developer Portfolio",
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
      bottomNavigationBar: isMob ? const AppBottomNav(currentRoute: "/student/profile") : null,
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildHighlightCircle(String title, String subtitle, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Center(
            child: Text(
              title.split(' ')[0],
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBadgesGrid() {
    final badges = [
      {"icon": "⚡", "name": "Two Sum Fast Solver", "tier": "Gold Tier", "color": Color(0xFFF59E0B)},
      {"icon": "🦉", "name": "Night Owl Coder", "tier": "Special", "color": AppColors.secondary},
      {"icon": "🔥", "name": "14-Day Streak Keeper", "tier": "Diamond", "color": AppColors.streak},
      {"icon": "🏆", "name": "1v1 Arena Gladiator", "tier": "Master", "color": AppColors.primary},
      {"icon": "🎯", "name": "DSA Top 5% Accuracy", "tier": "Legend", "color": AppColors.success},
      {"icon": "📚", "name": "Python Track 100%", "tier": "Completed", "color": AppColors.accent},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: badges.length,
      itemBuilder: (ctx, idx) {
        final b = badges[idx];
        return AppCard(
          backgroundColor: AppColors.surface,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(b["icon"] as String, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                b["name"] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                b["tier"] as String,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: b["color"] as Color),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSolvedFeed(BuildContext context) {
    final solved = [
      {"title": "Two Sum Target Indices", "topic": "Arrays & Hash Table", "difficulty": "Easy", "time": "Yesterday", "runtime": "38ms"},
      {"title": "Longest Substring Without Repeating", "topic": "Sliding Window", "difficulty": "Medium", "time": "2 days ago", "runtime": "54ms"},
      {"title": "Merge Overlapping Intervals", "topic": "Intervals", "difficulty": "Medium", "time": "4 days ago", "runtime": "62ms"},
    ];

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: solved.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final s = solved[idx];
        return AppCard(
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), borderRadius: AppRadii.inputRadius),
                child: const Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s["title"]!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                    Text("${s["topic"]} • Runtime: ${s["runtime"]} • Solved ${s["time"]}", style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              AppBadge.difficulty(s["difficulty"]!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBattlesList() {
    final battles = [
      {"rival": "Sophia Chen", "result": "VICTORY (+50 XP)", "score": "30 vs 20", "won": true},
      {"rival": "Marcus Vance", "result": "VICTORY (+50 XP)", "score": "40 vs 10", "won": true},
      {"rival": "Elena Rostova", "result": "DEFEAT (+10 XP)", "score": "20 vs 30", "won": false},
    ];

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: battles.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final b = battles[idx];
        final won = b["won"] as bool;
        return AppCard(
          child: Row(
            children: [
              Icon(won ? LucideIcons.trophy : LucideIcons.swords, color: won ? const Color(0xFFF59E0B) : AppColors.error, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("1v1 vs ${b["rival"]}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                    Text("Final Score: ${b["score"]}", style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                b["result"] as String,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: won ? AppColors.success : AppColors.error),
              ),
            ],
          ),
        );
      },
    );
  }
}
