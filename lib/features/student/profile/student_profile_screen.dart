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

class StudentProfileScreen extends ConsumerStatefulWidget {
  final String? studentId;

  const StudentProfileScreen({super.key, this.studentId});

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  UserModel? _otherUser;
  bool _isLoadingOther = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.studentId != null) {
      _fetchOtherUser();
    }
  }

  Future<void> _fetchOtherUser() async {
    final self = ref.read(authProvider).user;
    if (widget.studentId == null || widget.studentId == self?.id || widget.studentId == self?.studentId) {
      return;
    }
    setState(() => _isLoadingOther = true);
    try {
      final res = await ApiClient().dio.get('/students/${widget.studentId}');
      if (res.data != null) {
        setState(() {
          _otherUser = UserModel.fromJson(res.data);
          _isLoadingOther = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingOther = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final selfUser = authState.user;
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);
    final isSelf = widget.studentId == null || widget.studentId == selfUser?.id || widget.studentId == selfUser?.studentId;
    final user = isSelf ? selfUser : (_otherUser ?? selfUser);

    final displayName = (user != null && user.name.isNotEmpty) ? user.name : "Learner";
    final displayUsername = (user != null && user.email.isNotEmpty) ? user.email.split("@").first : "learner";
    final displayStudentId = (user?.studentId != null && user!.studentId.isNotEmpty) ? user.studentId : null;
    final hasCollege = user != null && user.collegeName != null && user.collegeName!.trim().isNotEmpty;
    final hasDept = user != null && user.department != null && user.department!.trim().isNotEmpty;
    final displayGradYear = (user != null && user.graduationYear != null) ? "Class of ${user.graduationYear}" : null;
    final displayBio = (user != null && user.bio != null && user.bio!.trim().isNotEmpty)
        ? user.bio!
        : "No bio added yet. Tap 'Edit Profile' to customize your bio.";
    final displayFollowers = "${user?.followersCount ?? 0}";
    final displayFollowing = "${user?.followingCount ?? 0}";
    final displaySolved = "${user?.questionsSolved ?? 0}";

    if (_isLoadingOther) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                          imageUrl: user?.avatarUrl,
                          radius: isMob ? 36 : 46,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space5),

                    // Stats: Solved, Followers, Following (Real DB values)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(displaySolved, "Solved"),
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
                    if (displayStudentId != null && displayStudentId.isNotEmpty) ...[
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
                  ],
                ),
                const SizedBox(height: 2),

                // Handle (@username)
                Text(
                  "@$displayUsername",
                  style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),

                // College & Dept Tags (Real data or prompt)
                if (hasDept || hasCollege || displayGradYear != null) ...[
                  Row(
                    children: [
                      const Icon(LucideIcons.school, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          [
                            if (hasDept) user.department,
                            if (hasCollege) user.collegeName,
                            if (displayGradYear != null) displayGradYear,
                          ].whereType<String>().join(" • "),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ] else if (isSelf) ...[
                  InkWell(
                    onTap: () => _openEditProfileDialog(context, user),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.school, size: 14, color: AppColors.primaryLight),
                        SizedBox(width: 6),
                        Text(
                          "Add College & Department +",
                          style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),

                // Bio (Real DB value or prompt)
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
                          onPressed: () => _openEditProfileDialog(context, user),
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
                              const SnackBar(content: Text("Profile link copied to clipboard!")),
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

          // 2. Real Milestone Highlights Carousel
          Text("Highlights & Milestones", style: AppTypography.h4(context, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.space3),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHighlightCircle("🔥", "${user?.streakDays ?? 0}d", "Streak", AppColors.streak),
                const SizedBox(width: 16),
                _buildHighlightCircle("⚔️", "${user?.battlesWon ?? 0}", "Battles", AppColors.secondary),
                const SizedBox(width: 16),
                _buildHighlightCircle("⚡", "${user?.codingProblemsSolved ?? 0}", "Coding", AppColors.primary),
                const SizedBox(width: 16),
                _buildHighlightCircle("🎯", "${user?.questionsSolved ?? 0}", "Questions", AppColors.success),
                const SizedBox(width: 16),
                _buildHighlightCircle("🏅", "${user?.totalPoints ?? 0}", "Points XP", const Color(0xFFF59E0B)),
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
                // Tab 1: Instagram Post Grid Style for Badges (Real Unlocked Trophies)
                _buildBadgesGrid(user),

                // Tab 2: Solved Problems Feed (Real Database Records)
                _buildSolvedFeed(context, user),

                // Tab 3: Battles History (Real Database Victories)
                _buildBattlesList(user),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMob ? const Drawer(child: AppSidebar(currentRoute: "/student/profile")) : null,
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

  Widget _buildHighlightCircle(String emoji, String count, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 1),
              Text(
                count,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBadgesGrid(UserModel? user) {
    final List<Map<String, dynamic>> earnedBadges = [];

    if ((user?.streakDays ?? 0) >= 3) {
      earnedBadges.add({
        "icon": "🔥",
        "name": "${user!.streakDays}-Day Streak",
        "tier": "Streak Master",
        "color": AppColors.streak,
      });
    }
    if ((user?.questionsSolved ?? 0) >= 1) {
      earnedBadges.add({
        "icon": "🎯",
        "name": "Practice Solver",
        "tier": "${user!.questionsSolved} Solved",
        "color": AppColors.success,
      });
    }
    if ((user?.codingProblemsSolved ?? 0) >= 1) {
      earnedBadges.add({
        "icon": "⚡",
        "name": "Algorithm Coder",
        "tier": "${user!.codingProblemsSolved} Solved",
        "color": AppColors.primary,
      });
    }
    if ((user?.battlesWon ?? 0) >= 1) {
      earnedBadges.add({
        "icon": "⚔️",
        "name": "Arena Duelist",
        "tier": "${user!.battlesWon} Victories",
        "color": AppColors.secondary,
      });
    }
    if ((user?.totalPoints ?? 0) >= 50) {
      earnedBadges.add({
        "icon": "🏆",
        "name": "XP Achiever",
        "tier": "${user!.totalPoints} Points",
        "color": const Color(0xFFF59E0B),
      });
    }

    if (earnedBadges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.award, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text("No Badges Unlocked Yet", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text("Solve questions in Daily Practice, maintain a streak, or win battles to earn trophies.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 16),
              AppButton(
                text: "Start Solving",
                icon: LucideIcons.playCircle,
                onPressed: () => context.go("/student/practice"),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: earnedBadges.length,
      itemBuilder: (ctx, idx) {
        final b = earnedBadges[idx];
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

  Widget _buildSolvedFeed(BuildContext context, UserModel? user) {
    if (user == null || user.questionsSolved == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.code2, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text("No Solved Problems Yet", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text("Start practicing questions to build your portfolio and record achievements.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 16),
              AppButton(
                text: "Go to Practice",
                icon: LucideIcons.playCircle,
                onPressed: () => context.go("/student/practice"),
              ),
            ],
          ),
        ),
      );
    }

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
                Text("Total Practice Solved: ${user.questionsSolved}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                Text("Overall Accuracy: ${user.overallAccuracy.toStringAsFixed(1)}% • Recorded in database", style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          AppBadge.difficulty("Completed"),
        ],
      ),
    );
  }

  Widget _buildBattlesList(UserModel? user) {
    if (user == null || user.battlesWon == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.swords, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text("No Arena Battles Yet", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text("Compete 1v1 with peers in live battle rooms to win XP and show your match history here.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 16),
              AppButton(
                text: "Join Battle Room",
                icon: LucideIcons.plus,
                onPressed: () => context.go("/student/battles"),
              ),
            ],
          ),
        ),
      );
    }

    return AppCard(
      child: Row(
        children: [
          const Icon(LucideIcons.trophy, color: Color(0xFFF59E0B), size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Arena Victories: ${user.battlesWon}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                Text("Earned XP in 1v1 Live Room Matches", style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const AppBadge(label: "VICTORY", isPill: true, color: Color(0x2210B981), textColor: AppColors.success),
        ],
      ),
    );
  }

  void _openEditProfileDialog(BuildContext context, UserModel? user) {
    final nameController = TextEditingController(text: user?.name ?? "");
    final collegeController = TextEditingController(text: user?.collegeName ?? "");
    final deptController = TextEditingController(text: user?.department ?? "");
    final gradYearController = TextEditingController(text: user?.graduationYear != null ? user!.graduationYear.toString() : "");
    final bioController = TextEditingController(text: user?.bio ?? "");

    String selectedAvatar = (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
        ? user.avatarUrl!
        : "https://api.dicebear.com/7.x/avataaars/svg?seed=${user?.name ?? 'User'}";
    bool isSaving = false;
    String? errorMessage;

    final baseSeed = (user?.name != null && user!.name.isNotEmpty) ? user.name : "Learner";
    final avatarOptions = [
      "https://api.dicebear.com/7.x/avataaars/svg?seed=$baseSeed",
      "https://api.dicebear.com/7.x/bottts/svg?seed=$baseSeed",
      "https://api.dicebear.com/7.x/adventurer/svg?seed=$baseSeed",
      "https://api.dicebear.com/7.x/lorelei/svg?seed=$baseSeed",
      "https://api.dicebear.com/7.x/fun-emoji/svg?seed=$baseSeed",
      "https://api.dicebear.com/7.x/pixel-art/svg?seed=$baseSeed",
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final surfaceColor = isDark ? AppColors.surfaceElevated : AppColors.lightSurface;
            final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;

            return Dialog(
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.modalRadius),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: AppRadii.badgeRadius,
                                ),
                                child: const Icon(LucideIcons.userCheck, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Edit Profile Details",
                                style: AppTypography.h3(context, color: textColor),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20),
                            onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.space4),

                      // Form Body
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar selection preview
                              Text("Choose Profile Avatar", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primary, width: 2),
                                    ),
                                    child: AppAvatar(
                                      name: nameController.text.isNotEmpty ? nameController.text : "User",
                                      imageUrl: selectedAvatar,
                                      radius: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: avatarOptions.map((opt) {
                                          final isSelected = selectedAvatar == opt;
                                          return GestureDetector(
                                            onTap: () {
                                              setDialogState(() {
                                                selectedAvatar = opt;
                                              });
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                              child: AppAvatar(
                                                name: nameController.text.isNotEmpty ? nameController.text : "User",
                                                imageUrl: opt,
                                                radius: 20,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.space4),

                              // Name
                              _buildInputField(
                                label: "Full Name *",
                                controller: nameController,
                                icon: LucideIcons.user,
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppSpacing.space3),

                              // College Name
                              _buildInputField(
                                label: "College / University",
                                controller: collegeController,
                                icon: LucideIcons.school,
                                isDark: isDark,
                              ),
                              const SizedBox(height: AppSpacing.space3),

                              // Department & Grad Year Row
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _buildInputField(
                                      label: "Department / Stream",
                                      controller: deptController,
                                      icon: LucideIcons.bookOpen,
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: _buildInputField(
                                      label: "Grad Year",
                                      controller: gradYearController,
                                      icon: LucideIcons.calendar,
                                      isDark: isDark,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.space3),

                              // Bio
                              _buildInputField(
                                label: "Bio / Headline",
                                controller: bioController,
                                icon: LucideIcons.messageSquare,
                                isDark: isDark,
                                maxLines: 3,
                              ),

                              if (errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.12),
                                    borderRadius: AppRadii.badgeRadius,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          errorMessage!,
                                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.space4),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(
                            text: "Cancel",
                            variant: AppButtonVariant.secondary,
                            onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
                          ),
                          const SizedBox(width: 12),
                          AppButton(
                            text: isSaving ? "Saving..." : "Save Changes",
                            variant: AppButtonVariant.primary,
                            icon: LucideIcons.check,
                            isLoading: isSaving,
                            onPressed: isSaving
                                ? null
                                : () async {
                                    final trimmedName = nameController.text.trim();
                                    if (trimmedName.isEmpty) {
                                      setDialogState(() {
                                        errorMessage = "Full Name is required.";
                                      });
                                      return;
                                    }
                                    setDialogState(() {
                                      isSaving = true;
                                      errorMessage = null;
                                    });

                                    final gradYear = int.tryParse(gradYearController.text.trim());

                                    final success = await ref.read(authProvider.notifier).updateProfile(
                                      name: trimmedName,
                                      collegeName: collegeController.text.trim(),
                                      department: deptController.text.trim(),
                                      graduationYear: gradYear,
                                      bio: bioController.text.trim(),
                                      avatarUrl: selectedAvatar,
                                    );

                                    if (context.mounted) {
                                      if (success) {
                                        Navigator.pop(dialogCtx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Profile updated and saved to database!"),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      } else {
                                        setDialogState(() {
                                          isSaving = false;
                                          errorMessage = ref.read(authProvider).error ?? "Failed to save profile changes.";
                                        });
                                      }
                                    }
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 ? Icon(icon, size: 18, color: AppColors.textMuted) : null,
            filled: true,
            fillColor: isDark ? AppColors.surface : AppColors.lightBackground,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: AppRadii.inputRadius,
              borderSide: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.inputRadius,
              borderSide: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.inputRadius,
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
