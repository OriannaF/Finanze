import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 22),
          ),
        ),
        title: const Text('Configuración'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 22),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile
            Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfaceContainerLowest,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Valeria Torres',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'valeria.torres@ejemplo.com',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Settings groups
            _SettingsGroup(
              title: 'Cuenta',
              children: [
                _SettingsItem(
                  icon: Icons.person,
                  label: 'Información Personal',
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.credit_card,
                  label: 'Métodos de Pago',
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Preferencias',
              children: [
                _SettingsItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notificaciones',
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.dark_mode,
                  label: 'Apariencia',
                  trailing: Switch.adaptive(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeTrackColor: AppColors.primary,
                  ),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.language,
                  label: 'Idioma',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Español',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Seguridad',
              children: [
                _SettingsItem(
                  icon: Icons.lock_outline,
                  label: 'PIN de Seguridad',
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.fingerprint,
                  label: 'Biometría',
                  trailing: Switch.adaptive(
                    value: _biometricsEnabled,
                    onChanged: (v) => setState(() => _biometricsEnabled = v),
                    activeTrackColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Soporte',
              children: [
                _SettingsItem(
                  icon: Icons.help_outline,
                  label: 'Centro de Ayuda',
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                ),
                const _SettingsDivider(),
                _SettingsItem(
                  icon: Icons.description_outlined,
                  label: 'Términos y Condiciones',
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Logout
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.errorContainer.withValues(alpha: 0.5),
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.logout, size: 20),
                label: Text(
                  'Cerrar Sesión',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixedDim.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 20, color: AppColors.onTertiaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(indent: 76, endIndent: 20, height: 1);
  }
}
