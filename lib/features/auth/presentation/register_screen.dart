import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/services/auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _collegeCtrl = TextEditingController(text: "National Institute of Technology");
  final _deptCtrl = TextEditingController(text: "Computer Science & Engineering");
  bool _agreeTerms = true;
  String? _error;

  void _handleRegister() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = "Please fill in all required fields.");
      return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      setState(() => _error = "Passwords do not match.");
      return;
    }
    if (!_agreeTerms) {
      setState(() => _error = "You must agree to the terms.");
      return;
    }

    setState(() => _error = null);
    final success = await ref.read(authProvider.notifier).register(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text.trim(),
          _collegeCtrl.text.trim(),
          _deptCtrl.text.trim(),
        );

    if (success && mounted) {
      context.go("/student/dashboard");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space6),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(AppSpacing.space8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.cardLargeRadius,
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    "Join CodeArena",
                    style: AppTypography.h1(context, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Center(
                  child: Text(
                    "Create your student profile and start competing",
                    style: AppTypography.bodySmall(context, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: AppSpacing.space5),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      borderRadius: AppRadii.inputRadius,
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                ],

                AppTextField(
                  label: "Full Name *",
                  hint: "e.g. John Doe",
                  controller: _nameCtrl,
                  prefixIcon: LucideIcons.user,
                ),
                const SizedBox(height: AppSpacing.space3),

                AppTextField(
                  label: "Email Address *",
                  hint: "john@example.com",
                  controller: _emailCtrl,
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.space3),

                AppTextField(
                  label: "College / University",
                  hint: "e.g. Stanford University",
                  controller: _collegeCtrl,
                  prefixIcon: LucideIcons.school,
                ),
                const SizedBox(height: AppSpacing.space3),

                AppTextField(
                  label: "Department",
                  hint: "e.g. Computer Science",
                  controller: _deptCtrl,
                  prefixIcon: LucideIcons.bookOpen,
                ),
                const SizedBox(height: AppSpacing.space3),

                AppTextField(
                  label: "Password *",
                  hint: "••••••••",
                  controller: _passCtrl,
                  isPassword: true,
                  prefixIcon: LucideIcons.lock,
                ),
                const SizedBox(height: AppSpacing.space3),

                AppTextField(
                  label: "Confirm Password *",
                  hint: "••••••••",
                  controller: _confirmPassCtrl,
                  isPassword: true,
                  prefixIcon: LucideIcons.lock,
                ),
                const SizedBox(height: AppSpacing.space4),

                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeTerms,
                        onChanged: (v) => setState(() => _agreeTerms = v ?? true),
                        activeColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "I agree to the CodeArena Terms of Service and Honor Code",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space5),

                AppButton(
                  text: "Create Account",
                  variant: AppButtonVariant.primary,
                  width: double.infinity,
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: AppSpacing.space4),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      GestureDetector(
                        onTap: () => context.go("/auth/login"),
                        child: const Text("Sign In", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
