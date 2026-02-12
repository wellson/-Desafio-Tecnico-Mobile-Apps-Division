import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_fast_tracker/core/theme/app_theme.dart';
import 'package:mamba_fast_tracker/core/theme/theme_cubit.dart';
import 'package:mamba_fast_tracker/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mamba_fast_tracker/core/utils/strings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Aparência ──
              Text(
                AppStrings.appearanceSection,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _ThemeOptionTile(
                      icon: Icons.dark_mode,
                      title: AppStrings.darkMode,
                      subtitle: AppStrings.darkModeSubtitle,
                      isSelected: themeState.isDark,
                      onTap: () => context
                          .read<ThemeCubit>()
                          .setThemeMode(ThemeMode.dark),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.dividerColor.withValues(alpha: 0.3),
                    ),
                    _ThemeOptionTile(
                      icon: Icons.light_mode,
                      title: AppStrings.lightMode,
                      subtitle: AppStrings.lightModeSubtitle,
                      isSelected: !themeState.isDark,
                      onTap: () => context
                          .read<ThemeCubit>()
                          .setThemeMode(ThemeMode.light),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Conta ──
              Text(
                AppStrings.accountSection,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: Icon(Icons.logout, color: AppTheme.accentRed),
                  title: Text(
                    AppStrings.logoutButton,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.accentRed,
                    ),
                  ),
                  subtitle: Text(
                    AppStrings.logoutSubtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                  onTap: () => _showLogoutDialog(context),
                ),
              ),

              const SizedBox(height: 32),

              // ── Sobre ──
              Text(
                AppStrings.aboutSection,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/icon/logo.png',
                        height: 80,
                        width: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.appName,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.appVersion,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.appDescription,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.logoutDialogTitle),
        content: const Text(AppStrings.logoutDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
            },
            child: Text(
              AppStrings.logoutButton,
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : theme.iconTheme.color,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isSelected ? AppTheme.primaryColor : null,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
          : Icon(Icons.circle_outlined, color: theme.iconTheme.color),
      onTap: onTap,
    );
  }
}
