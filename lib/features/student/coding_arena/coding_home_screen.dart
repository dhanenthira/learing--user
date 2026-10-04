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
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/theme_service.dart';

class CodingHomeScreen extends ConsumerStatefulWidget {
  const CodingHomeScreen({super.key});

  @override
  ConsumerState<CodingHomeScreen> createState() => _CodingHomeScreenState();
}

class _CodingHomeScreenState extends ConsumerState<CodingHomeScreen> {
  String _selectedDifficulty = "All";
  String _searchQuery = "";

  final List<Map<String, dynamic>> _problems = [
    {
      "id": "cp_two_sum",
      "title": "Two Sum Target Indices",
      "difficulty": "Easy",
      "topic": "Arrays & Hash Table",
      "acceptance": "82.4%",
      "submissions": "450",
      "isSolved": true,
      "tags": ["Array", "Hash Table", "Top Interview"]
    },
    {
      "id": "cp_valid_paren",
      "title": "Valid Parentheses Syntax",
      "difficulty": "Easy",
      "topic": "Stack & Strings",
      "acceptance": "78.9%",
      "submissions": "390",
      "isSolved": true,
      "tags": ["Stack", "String"]
    },
    {
      "id": "cp_merge_intervals",
      "title": "Merge Overlapping Intervals",
      "difficulty": "Medium",
      "topic": "Sorting & Arrays",
      "acceptance": "64.1%",
      "submissions": "280",
      "isSolved": false,
      "tags": ["Sorting", "Intervals"]
    },
    {
      "id": "cp_lru_cache",
      "title": "LRU Cache Architecture",
      "difficulty": "Medium",
      "topic": "Hash Map & Doubly Linked List",
      "acceptance": "58.3%",
      "submissions": "210",
      "isSolved": false,
      "tags": ["Design", "Linked List"]
    },
    {
      "id": "cp_median_streams",
      "title": "Find Median from Data Stream",
      "difficulty": "Hard",
      "topic": "Heaps & Priority Queues",
      "acceptance": "44.7%",
      "submissions": "140",
      "isSolved": false,
      "tags": ["Heap", "Stream", "Hard"]
    }
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    final filtered = _problems.where((p) {
      if (_selectedDifficulty != "All" && p["difficulty"] != _selectedDifficulty) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !p["title"].toString().toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !p["topic"].toString().toLowerCase().contains(_searchQuery.toLowerCase())) {
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
          // Banner
          AppCard(
            backgroundColor: const Color(0xFF0F172A),
            borderColor: AppColors.primary.withOpacity(0.3),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppBadge(
                        label: "LEETCODE & HACKERRANK STYLE ENGINE",
                        color: Color(0x223B82F6),
                        textColor: AppColors.primaryLight,
                        isPill: true,
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      Text(
                        "CodeArena Competitive Workspace",
                        style: AppTypography.h2(context, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      const Text(
                        "Solve real-world algorithm problems in Python, C++, Java, or JavaScript with sandboxed test case evaluations.",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          // Filters & Search Bar
          Row(
            children: [
              // Search Input
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.inputRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.search, size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: "Search problems by title, topic, or tag...",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Difficulty Chips
              ...["All", "Easy", "Medium", "Hard"].map((d) {
                final isSelected = _selectedDifficulty == d;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text(d, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : AppColors.textSecondary)),
                    selected: isSelected,
                    onSelected: (v) => setState(() => _selectedDifficulty = d),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceElevated,
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),

          // Problem List Cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) {
              final p = filtered[idx];
              final isSolved = p["isSolved"] as bool;

              return AppCard(
                onTap: () => context.go("/student/coding/workspace/${p["id"]}"),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSolved ? AppColors.success.withOpacity(0.15) : AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSolved ? LucideIcons.check : LucideIcons.code2,
                        size: 16,
                        color: isSolved ? AppColors.success : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                p["title"],
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 10),
                              AppBadge.difficulty(p["difficulty"]),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${p["topic"]} • ${p["acceptance"]} Acceptance • ${p["submissions"]} Submissions",
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    AppButton(
                      text: isSolved ? "Solve Again" : "Solve Challenge",
                      variant: isSolved ? AppButtonVariant.secondary : AppButtonVariant.primary,
                      onPressed: () => context.go("/student/coding/workspace/${p["id"]}"),
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
      body: Row(
        children: [
          if (!isMob) const AppSidebar(currentRoute: "/student/coding"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Coding Arena",
                  subtitle: "Algorithms & Data Structures Challenge Suite",
                  isDarkMode: isDark,
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMob ? const AppBottomNav(currentRoute: "/student/coding") : null,
    );
  }
}
