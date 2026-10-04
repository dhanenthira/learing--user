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

class TestResultScreen extends StatelessWidget {
  final int score;
  final int maxScore;
  final int totalQuestions;
  final int timeTakenSeconds;

  const TestResultScreen({
    super.key,
    required this.score,
    required this.maxScore,
    required this.totalQuestions,
    required this.timeTakenSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = maxScore > 0 ? ((score / maxScore) * 100).toInt() : 0;
    final minutes = timeTakenSeconds ~/ 60;
    final seconds = timeTakenSeconds % 60;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text("Assessment Submission & Performance", style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                AppCard(
                  backgroundColor: AppColors.surfaceElevated,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.award, size: 44, color: AppColors.primaryLight),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Text("Assessment Submitted!", style: AppTypography.h1(context, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      const Text(
                        "Your responses have been validated and saved on the CodeArena database.",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 36),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCol("Your Score", "$score / $maxScore", AppColors.primaryLight),
                          _buildStatCol("Accuracy", "$accuracy%", AppColors.success),
                          _buildStatCol("Time Taken", "${minutes}m ${seconds}s", AppColors.textSecondary),
                          _buildStatCol("Estimated Rank", "#12 (Top 5%)", AppColors.streak),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppButton(
                      text: "Return to Dashboard",
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go("/student/dashboard"),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      text: "View Leaderboard",
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.go("/student/leaderboard"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: color)),
      ],
    );
  }
}
