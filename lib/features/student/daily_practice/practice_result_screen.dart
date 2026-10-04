import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_badge.dart';

class PracticeResultScreen extends StatelessWidget {
  final int totalQuestions;
  final int correctCount;
  final int timeSpentSeconds;
  final List<Map<String, dynamic>> reviews;

  const PracticeResultScreen({
    super.key,
    required this.totalQuestions,
    required this.correctCount,
    required this.timeSpentSeconds,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = totalQuestions > 0 ? ((correctCount / totalQuestions) * 100).toInt() : 0;
    final minutes = timeSpentSeconds ~/ 60;
    final seconds = timeSpentSeconds % 60;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text("Practice Results & Analysis", style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go("/student/practice"),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score Banner
            AppCard(
              backgroundColor: AppColors.surfaceElevated,
              child: Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: accuracy >= 75 ? AppColors.success.withOpacity(0.15) : AppColors.warning.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accuracy >= 75 ? AppColors.success : AppColors.warning,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "$accuracy%",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: accuracy >= 75 ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          accuracy >= 75 ? "Excellent Performance!" : "Good Effort!",
                          style: AppTypography.h2(context, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "You answered $correctCount out of $totalQuestions questions correctly in ${minutes}m ${seconds}s.",
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        AppBadge(
                          label: "+${correctCount * 10} XP EARNED",
                          color: AppColors.primary.withOpacity(0.15),
                          textColor: AppColors.primaryLight,
                          isPill: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space6),

            // Question-by-Question Review
            Text("Detailed Question Review & Explanations", style: AppTypography.h3(context, color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.space4),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 16),
              itemBuilder: (context, idx) {
                final r = reviews[idx];
                final isCorrect = r["isCorrect"] as bool;

                return AppCard(
                  borderColor: isCorrect ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Question ${idx + 1}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                          AppBadge(
                            label: isCorrect ? "CORRECT (+10 XP)" : "INCORRECT",
                            color: isCorrect ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                            textColor: isCorrect ? AppColors.success : AppColors.error,
                            isPill: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      Text(r["question"], style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.4)),
                      const SizedBox(height: AppSpacing.space3),
                      Text("Your Answer: ${r["selected"] ?? 'Not Answered'}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isCorrect ? AppColors.success : AppColors.error,
                          )),
                      Text("Correct Answer: ${r["correct"]}",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                      const SizedBox(height: AppSpacing.space3),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.space3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: AppRadii.cardSmallRadius,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(LucideIcons.info, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Explanation: ${r["explanation"]}",
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.space6),

            // Footer Actions
            Row(
              children: [
                AppButton(
                  text: "Return to Dashboard",
                  variant: AppButtonVariant.primary,
                  onPressed: () => context.go("/student/dashboard"),
                ),
                const SizedBox(width: 12),
                AppButton(
                  text: "Practice Another Category",
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.go("/student/practice"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
