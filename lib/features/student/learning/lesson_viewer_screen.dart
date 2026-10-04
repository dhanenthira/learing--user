import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/theme_service.dart';

class LessonViewerScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonViewerScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends ConsumerState<LessonViewerScreen> {
  bool _isCompleted = false;
  bool _copied = false;
  int _selectedTopicIndex = 0;

  final List<Map<String, dynamic>> _topics = [
    {"id": "py_intro", "title": "1. Python Introduction", "completed": true},
    {"id": "py_syntax", "title": "2. Syntax & Variables", "completed": true},
    {"id": "py_data_types", "title": "3. Data Structures", "completed": false},
    {"id": "py_functions", "title": "4. Functions & Lambda", "completed": false},
    {"id": "py_oop", "title": "5. Classes & Objects", "completed": false},
    {"id": "py_modules", "title": "6. Modules & Pip", "completed": false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isMob = ResponsiveLayout.isMobile(context);

    // Topic Nav Drawer / Sidebar
    Widget topicNav = Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, size: 18),
                  onPressed: () => context.go("/student/learning"),
                ),
                const SizedBox(width: 4),
                const Text(
                  "Python Track",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _topics.length,
              itemBuilder: (ctx, idx) {
                final item = _topics[idx];
                final isSelected = _selectedTopicIndex == idx;
                return InkWell(
                  onTap: () => setState(() => _selectedTopicIndex = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                    child: Row(
                      children: [
                        Icon(
                          item["completed"] ? LucideIcons.checkCircle2 : LucideIcons.circle,
                          size: 16,
                          color: item["completed"] ? AppColors.success : AppColors.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item["title"],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    // Main Lesson Body
    Widget mainLesson = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingDesktop,
        vertical: AppSpacing.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go("/student/learning"),
                child: const Text("Learning", style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ),
              const Text(" / ", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const Text("Python Programming", style: TextStyle(color: AppColors.primary, fontSize: 13)),
              const Text(" / ", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const Text("Introduction", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),

          // Lesson Title & Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _topics[_selectedTopicIndex]["title"],
                  style: AppTypography.h1(context, color: AppColors.textPrimary),
                ),
              ),
              AppButton(
                text: _isCompleted ? "Completed" : "Mark as Completed",
                variant: _isCompleted ? AppButtonVariant.secondary : AppButtonVariant.primary,
                icon: _isCompleted ? LucideIcons.check : LucideIcons.checkCircle,
                onPressed: () {
                  setState(() => _isCompleted = !_isCompleted);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isCompleted ? "Marked as completed! (+15 XP)" : "Unmarked lesson"),
                      backgroundColor: AppColors.surfaceElevated,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),

          // 1. Introduction Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Introduction", style: AppTypography.h3(context, color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.space2),
                const Text(
                  "Python is a high-level, general-purpose programming language. Its design philosophy emphasizes code readability with the use of significant indentation. Python is dynamically typed and garbage-collected, supporting multiple programming paradigms including structured, object-oriented, and functional programming.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space4),

          // 2. Syntax & Definition
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Definition & Key Concepts", style: AppTypography.h3(context, color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.space2),
                const Text(
                  "Unlike languages like C++ or Java that use curly braces {} to delimit code blocks, Python uses whitespace indentation. Semicolons are optional, making the syntax very clean and English-like.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text("Syntax Example", style: AppTypography.h4(context, color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.space2),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF030712),
                    borderRadius: AppRadii.cardSmallRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    "print('Hello, CodeArena Champion!')",
                    style: TextStyle(fontFamily: 'monospace', color: AppColors.accent, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space4),

          // 3. Interactive Code Block with Output
          AppCard(
            backgroundColor: const Color(0xFF0F172A),
            borderColor: AppColors.primary.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.code2, color: AppColors.primaryLight, size: 18),
                        const SizedBox(width: 8),
                        Text("Example Code", style: AppTypography.h4(context, color: AppColors.textPrimary)),
                      ],
                    ),
                    AppIconButton(
                      icon: _copied ? LucideIcons.check : LucideIcons.copy,
                      size: 32,
                      tooltip: "Copy Code",
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(
                            text: "# Welcome script\nplayer = 'Alex'\nlevel = 5\nprint(f'Player {player} reached level {level}!')"));
                        setState(() => _copied = true);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _copied = false);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF030712),
                    borderRadius: AppRadii.cardSmallRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    "# Welcome script\nplayer = 'Alex'\nlevel = 5\nprint(f'Player {player} reached level {level}!')\n\nif level >= 5:\n    print('Unlocked Arena Master Badge!')",
                    style: TextStyle(fontFamily: 'monospace', color: Color(0xFF93C5FD), fontSize: 13, height: 1.5),
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                Text("Output:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: AppRadii.cardSmallRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    "Player Alex reached level 5!\nUnlocked Arena Master Badge!",
                    style: TextStyle(fontFamily: 'monospace', color: AppColors.success, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space4),

          // 4. Important Notes
          AppCard(
            backgroundColor: const Color(0xFF1E1B4B),
            borderColor: AppColors.purple.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.info, color: AppColors.purple, size: 20),
                    const SizedBox(width: 8),
                    Text("Important Takeaways", style: AppTypography.h4(context, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                _buildNoteBullet("Python variables do not require explicit type declaration."),
                _buildNoteBullet("Python is case-sensitive: 'Value' and 'value' represent distinct identifiers."),
                _buildNoteBullet("Consistent 4-space indentation is standard PEP 8 convention."),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space6),

          // Bottom Actions & Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton(
                text: "← Previous Topic",
                variant: AppButtonVariant.secondary,
                onPressed: _selectedTopicIndex > 0
                    ? () => setState(() => _selectedTopicIndex--)
                    : null,
              ),
              AppButton(
                text: "Practice This Topic",
                variant: AppButtonVariant.secondary,
                icon: LucideIcons.brain,
                onPressed: () => context.go("/student/practice"),
              ),
              AppButton(
                text: "Next Topic →",
                variant: AppButtonVariant.primary,
                onPressed: _selectedTopicIndex < _topics.length - 1
                    ? () => setState(() => _selectedTopicIndex++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (!isMob) const AppSidebar(currentRoute: "/student/learning"),
          if (!isMob) topicNav,
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Python Programming",
                  subtitle: _topics[_selectedTopicIndex]["title"],
                  isDarkMode: isDark,
                  onThemeToggle: () => ref.read(themeProvider.notifier).toggleTheme(),
                ),
                Expanded(child: mainLesson),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: AppColors.purple, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
