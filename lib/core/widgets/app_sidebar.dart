import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'coming_soon_modal.dart';

class SidebarItem {
  final String title;
  final IconData icon;
  final String route;
  final bool isComingSoon;

  const SidebarItem({
    required this.title,
    required this.icon,
    required this.route,
    this.isComingSoon = false,
  });
}

class AppSidebar extends StatelessWidget {
  final bool isAdmin;
  final String currentRoute;

  const AppSidebar({
    super.key,
    this.isAdmin = false,
    required this.currentRoute,
  });

  List<SidebarItem> get studentItems => const [
        SidebarItem(title: "Dashboard", icon: LucideIcons.home, route: "/student/dashboard"),
        SidebarItem(title: "Learning", icon: LucideIcons.bookOpen, route: "/student/learning"),
        SidebarItem(title: "Daily Practice", icon: LucideIcons.brain, route: "/student/practice"),
        SidebarItem(title: "Coding Arena", icon: LucideIcons.code2, route: "/student/coding"),
        SidebarItem(title: "Communication", icon: LucideIcons.messageSquare, route: "#", isComingSoon: true),
        SidebarItem(title: "Assessment Tests", icon: LucideIcons.clipboardCheck, route: "/student/tests"),
        SidebarItem(title: "Battle Rooms", icon: LucideIcons.swords, route: "/student/battles"),
        SidebarItem(title: "Friends", icon: LucideIcons.users, route: "/student/friends"),
        SidebarItem(title: "Leaderboard", icon: LucideIcons.trophy, route: "/student/leaderboard"),
        SidebarItem(title: "Reports & Analytics", icon: LucideIcons.barChart2, route: "/student/reports"),
        SidebarItem(title: "Profile & Settings", icon: LucideIcons.user, route: "/student/profile"),
      ];

  List<SidebarItem> get adminItems => const [
        SidebarItem(title: "Admin Dashboard", icon: LucideIcons.layoutDashboard, route: "/admin/dashboard"),
        SidebarItem(title: "Students", icon: LucideIcons.users, route: "/admin/students"),
        SidebarItem(title: "Question Bank", icon: LucideIcons.helpCircle, route: "/admin/questions"),
        SidebarItem(title: "Learning Content", icon: LucideIcons.bookOpen, route: "/admin/learning"),
        SidebarItem(title: "Daily Challenges", icon: LucideIcons.calendar, route: "/admin/daily-challenges"),
        SidebarItem(title: "Coding Problems", icon: LucideIcons.code2, route: "/admin/coding"),
        SidebarItem(title: "Test Management", icon: LucideIcons.clipboardCheck, route: "/admin/tests"),
        SidebarItem(title: "Battle Rooms", icon: LucideIcons.swords, route: "/admin/battles"),
        SidebarItem(title: "Platform Analytics", icon: LucideIcons.pieChart, route: "/admin/analytics"),
        SidebarItem(title: "Notifications", icon: LucideIcons.bell, route: "/admin/notifications"),
        SidebarItem(title: "Settings", icon: LucideIcons.settings, route: "/admin/settings"),
      ];

  @override
  Widget build(BuildContext context) {
    final items = isAdmin ? adminItems : studentItems;

    return Container(
      width: 250,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // Logo & Branding
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space5, vertical: AppSpacing.space5),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadii.cardSmallRadius,
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.code2, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "CODE",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            TextSpan(
                              text: "ARENA",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        isAdmin ? "Admin Console" : "Learn • Practice • Compete",
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4, horizontal: AppSpacing.space3),
              itemCount: items.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = items[index];
                final isActive = currentRoute.startsWith(item.route) && item.route != "#";

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (item.isComingSoon) {
                        ComingSoonModal.show(context);
                      } else {
                        context.go(item.route);
                      }
                    },
                    borderRadius: AppRadii.inputRadius,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                        borderRadius: AppRadii.inputRadius,
                        border: Border.all(
                          color: isActive ? AppColors.primary.withOpacity(0.4) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 18,
                            color: isActive ? AppColors.primary : AppColors.textMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (item.isComingSoon)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "SOON",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer Role Switch & Logout
          Container(
            padding: const EdgeInsets.all(AppSpacing.space4),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: isAdmin ? AppColors.primary.withOpacity(0.12) : AppColors.error.withOpacity(0.12),
                  borderRadius: AppRadii.inputRadius,
                  child: InkWell(
                    onTap: () {
                      if (isAdmin) {
                        context.go("/student/dashboard");
                      } else {
                        context.go("/admin/dashboard");
                      }
                    },
                    borderRadius: AppRadii.inputRadius,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            isAdmin ? LucideIcons.userRound : LucideIcons.shieldAlert,
                            size: 18,
                            color: isAdmin ? AppColors.primaryLight : AppColors.error,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isAdmin ? "Switch to Student View" : "Admin Console",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isAdmin ? AppColors.primaryLight : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.go(isAdmin ? "/admin/login" : "/auth/login");
                    },
                    borderRadius: AppRadii.inputRadius,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.logOut, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 10),
                          Text(
                            "Sign Out",
                            style: AppTypography.button(context, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
