import 'package:flutter/material.dart';
import 'package:foodie/services/theme.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    Widget? trailing, // 尾部的 Widget 可以是圖標、Switch 或其他
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title, style: theme.textTheme.titleMedium),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child:
            trailing ??
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurfaceVariant),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final themeService = context.watch<ThemeService>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  children: [
                    Icon(Icons.account_circle, size: 80, color: colorScheme.inverseSurface),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Login google account
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Log in with Google',
                          style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildSettingsTile(
                context,
                title: 'Browse Record',
                onTap: () {
                  // TODO: Jump to Browse Record
                },
              ),
              // 3. 元件優化：使用標準的 Divider Widget
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                title: 'My Review',
                onTap: () {
                  // TODO: Jump to My Review
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                context,
                title: 'Dark Theme',
                onTap: () {
                  themeService.toggleTheme();
                },
                trailing: Switch(
                  value: themeService.isDarkMode,
                  onChanged: (value) {
                    themeService.toggleTheme();
                  },
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}
