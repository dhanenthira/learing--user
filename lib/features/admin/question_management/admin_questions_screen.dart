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
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/services/theme_service.dart';

class AdminQuestionsScreen extends ConsumerStatefulWidget {
  const AdminQuestionsScreen({super.key});

  @override
  ConsumerState<AdminQuestionsScreen> createState() => _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends ConsumerState<AdminQuestionsScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      "id": "q1",
      "title": "Train Speed & Distance",
      "category": "Aptitude",
      "topic": "Time & Distance",
      "difficulty": "Easy",
      "answer": "150 metres"
    },
    {
      "id": "q2",
      "title": "Profit and Loss Calculation",
      "category": "Aptitude",
      "topic": "Profit & Loss",
      "difficulty": "Easy",
      "answer": "\$200"
    },
    {
      "id": "q3",
      "title": "Binary Search Worst Case",
      "category": "Technical",
      "topic": "Data Structures",
      "difficulty": "Easy",
      "answer": "O(log n)"
    },
    {
      "id": "q4",
      "title": "HTTP Status Codes",
      "category": "Technical",
      "topic": "Computer Networks",
      "difficulty": "Easy",
      "answer": "401 Unauthorized"
    },
  ];

  void _showAddQuestionDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final opt1Ctrl = TextEditingController();
    final opt2Ctrl = TextEditingController();
    final opt3Ctrl = TextEditingController();
    final opt4Ctrl = TextEditingController();
    final ansCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    String category = "Aptitude";
    String difficulty = "Easy";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.modalRadius, side: const BorderSide(color: AppColors.border)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Add New Question", style: AppTypography.h3(context, color: AppColors.textPrimary)),
                      IconButton(icon: const Icon(LucideIcons.x, size: 20), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const Divider(height: 24),
                  AppTextField(label: "Question Title", hint: "e.g. Work and Time Rates", controller: titleCtrl),
                  const SizedBox(height: AppSpacing.space3),
                  AppTextField(label: "Question Statement", hint: "Enter full problem statement...", controller: contentCtrl, maxLines: 3),
                  const SizedBox(height: AppSpacing.space3),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Category", style: AppTypography.labelLarge(context, color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            DropdownButton<String>(
                              value: category,
                              dropdownColor: AppColors.surfaceElevated,
                              items: ["Aptitude", "Technical"].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (v) => setModalState(() => category = v!),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Difficulty", style: AppTypography.labelLarge(context, color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            DropdownButton<String>(
                              value: difficulty,
                              dropdownColor: AppColors.surfaceElevated,
                              items: ["Easy", "Medium", "Hard"].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                              onChanged: (v) => setModalState(() => difficulty = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space3),

                  AppTextField(label: "Option A", hint: "Option A", controller: opt1Ctrl),
                  const SizedBox(height: AppSpacing.space2),
                  AppTextField(label: "Option B", hint: "Option B", controller: opt2Ctrl),
                  const SizedBox(height: AppSpacing.space2),
                  AppTextField(label: "Option C", hint: "Option C", controller: opt3Ctrl),
                  const SizedBox(height: AppSpacing.space2),
                  AppTextField(label: "Option D", hint: "Option D", controller: opt4Ctrl),
                  const SizedBox(height: AppSpacing.space3),

                  AppTextField(label: "Correct Answer (Exact Match)", hint: "e.g. Option A", controller: ansCtrl),
                  const SizedBox(height: AppSpacing.space3),
                  AppTextField(label: "Detailed Explanation", hint: "Explain step-by-step resolution...", controller: expCtrl, maxLines: 2),
                  const SizedBox(height: AppSpacing.space5),

                  AppButton(
                    text: "Publish Question to Bank",
                    variant: AppButtonVariant.primary,
                    width: double.infinity,
                    onPressed: () {
                      if (titleCtrl.text.isNotEmpty) {
                        setState(() {
                          _questions.add({
                            "id": "q_${DateTime.now().millisecondsSinceEpoch}",
                            "title": titleCtrl.text,
                            "category": category,
                            "topic": "General",
                            "difficulty": difficulty,
                            "answer": ansCtrl.text,
                          });
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Question Bank (${_questions.length})", style: AppTypography.h3(context, color: AppColors.textPrimary)),
              AppButton(
                text: "Add Question",
                variant: AppButtonVariant.primary,
                icon: LucideIcons.plus,
                onPressed: _showAddQuestionDialog,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),

          AppCard(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final q = _questions[idx];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: AppRadii.badgeRadius),
                        child: const Icon(LucideIcons.helpCircle, color: AppColors.primaryLight, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(q["title"], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                                const SizedBox(width: 8),
                                AppBadge.difficulty(q["difficulty"]),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text("${q["category"]} • Topic: ${q["topic"]} • Answer: ${q["answer"]}", style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                        onPressed: () => setState(() => _questions.removeAt(idx)),
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
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (!isMob) const AppSidebar(isAdmin: true, currentRoute: "/admin/questions"),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: "Question Bank & Management",
                  subtitle: "Create, edit, and organize aptitude and technical question assets",
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
