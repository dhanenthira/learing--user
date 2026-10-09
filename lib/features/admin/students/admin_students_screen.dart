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
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/network/api_client.dart';

class AdminStudentsScreen extends ConsumerStatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  ConsumerState<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends ConsumerState<AdminStudentsScreen> {
  String _search = "";
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get("/admin/students");
      if (res.data != null && res.data is List) {
        setState(() {
          _students = List<Map<String, dynamic>>.from((res.data as List).map((s) => {
            "id": s["id"] ?? "",
            "studentId": s["student_id"] ?? "",
            "name": s["name"] ?? "",
            "email": s["email"] ?? "",
            "college": s["college_name"] ?? "—",
            "solved": s["questions_solved"] ?? 0,
            "accuracy": "${(s["overall_accuracy"] ?? 0.0).toStringAsFixed(1)}%",
            "points": s["total_points"] ?? 0,
            "status": (s["is_active"] ?? true) ? "Active" : "Suspended",
            "avatar": s["avatar_url"] ?? "https://api.dicebear.com/7.x/avataaars/svg?seed=${s["name"]}",
          }));
          _isLoading = false;
        });
      } else {
        setState(() {
          _students = [];
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _students = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    final filtered = _students.where((s) {
      if (_search.isNotEmpty &&
          !s["name"].toString().toLowerCase().contains(_search.toLowerCase()) &&
          !s["studentId"].toString().toLowerCase().contains(_search.toLowerCase()) &&
          !s["email"].toString().toLowerCase().contains(_search.toLowerCase())) {
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
                      hintText: "Search registered students by name, ID, or email...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space4),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filtered.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    const Icon(LucideIcons.users, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      _students.isEmpty ? "No Students Registered Yet" : "No Matching Students",
                      style: AppTypography.h4(context, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _students.isEmpty
                          ? "All dummy students have been removed. When students create a profile, they will appear here directly from the database."
                          : "No students matched your search criteria.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
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
                        AppAvatar(name: s["name"] ?? "User", imageUrl: s["avatar"], radius: 22),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(s["name"], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                                  const SizedBox(width: 8),
                                  AppBadge(
                                    label: s["status"],
                                    color: s["status"] == "Active" ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                                    textColor: s["status"] == "Active" ? AppColors.success : AppColors.error,
                                    isPill: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text("${s["studentId"]} • ${s["email"]}", style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              Text(s["college"], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (!isMob) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${s["points"]} XP", style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryLight, fontSize: 13)),
                              Text("Solved: ${s["solved"]} • Acc: ${s["accuracy"]}", style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(width: 16),
                        ],
                        IconButton(
                          icon: Icon(
                            s["status"] == "Active" ? LucideIcons.userX : LucideIcons.userCheck,
                            size: 18,
                            color: s["status"] == "Active" ? AppColors.warning : AppColors.success,
                          ),
                          tooltip: s["status"] == "Active" ? "Suspend Student" : "Activate Student",
                          onPressed: () async {
                            try {
                              await ApiClient().dio.patch("/admin/students/${s["id"]}/status");
                              _fetchStudents();
                            } catch (_) {}
                          },
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
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: Row(
        children: [
          if (!isMob) const AppSidebar(isAdmin: true, currentRoute: "/admin/students"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Student Directory",
                  subtitle: "Search, inspect, and manage learners enrolled in the database",
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
