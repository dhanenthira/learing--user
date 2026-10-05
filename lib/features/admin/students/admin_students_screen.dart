import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/theme_service.dart';

class AdminStudentsScreen extends ConsumerStatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  ConsumerState<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends ConsumerState<AdminStudentsScreen> {
  String _search = "";

  final List<Map<String, dynamic>> _students = [
    {
      "id": "u1",
      "studentId": "CA-2026-9042",
      "name": "Alex Mercer",
      "email": "student@codearena.com",
      "college": "National Institute of Tech",
      "solved": 380,
      "accuracy": "88.2%",
      "points": 4850,
      "status": "Active",
      "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Alex"
    },
    {
      "id": "u2",
      "studentId": "CA-2026-8190",
      "name": "Sophia Chen",
      "email": "sophia@codearena.com",
      "college": "Tech University",
      "solved": 450,
      "accuracy": "91.0%",
      "points": 5620,
      "status": "Active",
      "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia"
    },
    {
      "id": "u3",
      "studentId": "CA-2026-7241",
      "name": "Marcus Vance",
      "email": "marcus@codearena.com",
      "college": "State Engineering College",
      "solved": 310,
      "accuracy": "85.4%",
      "points": 4310,
      "status": "Active",
      "avatar": "https://api.dicebear.com/7.x/avataaars/svg?seed=Marcus"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    final filtered = _students.where((s) {
      if (_search.isNotEmpty &&
          !s["name"].toString().toLowerCase().contains(_search.toLowerCase()) &&
          !s["studentId"].toString().toLowerCase().contains(_search.toLowerCase())) {
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
          // Search & Filter
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
                      hintText: "Filter students by name, email, or Student ID...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          Text("Registered Students (${filtered.length})", style: AppTypography.h3(context, color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.space4),

          AppCard(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final s = filtered[idx];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AppAvatar(name: s["name"] ?? "Student", radius: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(s["name"], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: AppRadii.badgeRadius),
                                  child: Text(s["studentId"], style: const TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("${s["email"]} • ${s["college"]}", style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (!isMob) ...[
                        Text("Accuracy: ${s["accuracy"]}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(width: 20),
                        Text("Points: ${s["points"]} XP", style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryLight, fontSize: 13)),
                        const SizedBox(width: 20),
                      ],
                      const AppBadge(label: "ACTIVE", isPill: true, color: Color(0x2222C55E), textColor: AppColors.success),
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
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: Row(
        children: [
          if (!isMob) const AppSidebar(isAdmin: true, currentRoute: "/admin/students"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Student Management",
                  subtitle: "Directory, activity monitoring and student role controls",
                  showStreak: false,
                  isDarkMode: isDark,
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
