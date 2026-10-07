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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _rememberMe = true;
  String? _error;

  void _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = "Please fill in all fields.");
      return;
    }

    setState(() => _error = null);
    final success = await ref.read(authProvider.notifier).login(email, pass);
    if (success && mounted) {
      context.go("/student/dashboard");
    } else if (mounted) {
      final authError = ref.read(authProvider).error;
      setState(() => _error = authError ?? "Invalid email or password.");
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
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(AppSpacing.space8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.cardLargeRadius,
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo & Header
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadii.cardStandardRadius,
                    ),
                    child: const Icon(LucideIcons.code2, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Center(
                  child: Text(
                    "Welcome Back",
                    style: AppTypography.h1(context, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Center(
                  child: Text(
                    "Sign in to your CodeArena student account",
                    style: AppTypography.bodySmall(context, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: AppSpacing.space6),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      borderRadius: AppRadii.inputRadius,
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertCircle, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                ],

                // Form Fields
                AppTextField(
                  label: "Email Address",
                  hint: "student@codearena.com",
                  controller: _emailCtrl,
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.space4),

                AppTextField(
                  label: "Password",
                  hint: "••••••••",
                  controller: _passCtrl,
                  isPassword: true,
                  prefixIcon: LucideIcons.lock,
                ),
                const SizedBox(height: AppSpacing.space3),

                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (v) => setState(() => _rememberMe = v ?? true),
                            activeColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text("Remember me", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Forgot password?", style: TextStyle(color: AppColors.primary, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space5),

                // Sign In Button
                AppButton(
                  text: "Sign In",
                  variant: AppButtonVariant.primary,
                  width: double.infinity,
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: AppSpacing.space5),

                // Switch to Register
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => context.go("/auth/register"),
                        child: const Text(
                          "Create one",
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),

                // Admin Login Link
                Center(
                  child: GestureDetector(
                    onTap: () => context.go("/admin/login"),
                    child: const Text(
                      "Sign in as Administrator →",
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
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
