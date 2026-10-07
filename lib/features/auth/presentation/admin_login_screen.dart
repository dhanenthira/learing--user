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
import '../../../core/widgets/app_badge.dart';
import '../../../core/services/auth_service.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;

  void _handleAdminLogin() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = "Please enter admin credentials.");
      return;
    }

    setState(() => _error = null);
    final success = await ref.read(authProvider.notifier).adminLogin(email, pass);
    if (success && mounted) {
      context.go("/admin/dashboard");
    } else if (mounted) {
      final authError = ref.read(authProvider).error;
      setState(() => _error = authError ?? "Unauthorized. Admin privileges required.");
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: AppBadge(
                    label: "SECURE ADMIN PORTAL",
                    color: Color(0x22EF4444),
                    textColor: AppColors.error,
                    isPill: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.error.withOpacity(0.5), width: 1.5),
                    ),
                    child: const Icon(LucideIcons.shieldAlert, color: AppColors.error, size: 26),
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                Center(
                  child: Text(
                    "Admin Authentication",
                    style: AppTypography.h2(context, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Center(
                  child: Text(
                    "Sign in with authorized administrator credentials",
                    style: AppTypography.bodySmall(context, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
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
                  label: "Admin Email",
                  hint: "admin@codearena.com",
                  controller: _emailCtrl,
                  prefixIcon: LucideIcons.mail,
                ),
                const SizedBox(height: AppSpacing.space4),

                AppTextField(
                  label: "Admin Password",
                  hint: "••••••••",
                  controller: _passCtrl,
                  isPassword: true,
                  prefixIcon: LucideIcons.lock,
                ),
                const SizedBox(height: AppSpacing.space3),

                // Quick Demo Credentials Fill
                InkWell(
                  onTap: () {
                    _emailCtrl.text = "admin@codearena.com";
                    _passCtrl.text = "admin123";
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHover,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.keyRound, size: 14, color: AppColors.textMuted),
                        SizedBox(width: 6),
                        Text(
                          "Fill Demo Credentials (admin@codearena.com / admin123)",
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space5),

                AppButton(
                  text: "Enter Admin Console",
                  variant: AppButtonVariant.destructive,
                  width: double.infinity,
                  isLoading: authState.isLoading,
                  onPressed: _handleAdminLogin,
                ),
                const SizedBox(height: AppSpacing.space4),

                Center(
                  child: GestureDetector(
                    onTap: () => context.go("/auth/login"),
                    child: const Text(
                      "← Return to Student Login",
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
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
