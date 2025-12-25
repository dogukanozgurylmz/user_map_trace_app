import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';
import 'package:user_map_trace_app/app/common/constants/app_strings.dart';
import 'package:user_map_trace_app/app/common/router/app_router.dart';

@RoutePage()
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black2),
          onPressed: () => context.router.pop(),
        ),
        title: const Text(
          AppStrings.settings,
          style: TextStyle(
            color: AppColors.black2,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SettingsItem(
              icon: Icons.route,
              title: AppStrings.savedRoutes,
              onTap: () => context.router.push(const SavedRoutesRoute()),
            ),
            const SizedBox(height: 8),
            _SettingsItem(
              icon: Icons.description_outlined,
              title: AppStrings.termsOfUse,
              onTap: () => _launchUrl('https://example.com/terms'),
            ),
            const SizedBox(height: 8),
            _SettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: AppStrings.privacyPolicy,
              onTap: () => _launchUrl('https://example.com/privacy'),
            ),
            const SizedBox(height: 8),
            _SettingsItem(
              icon: Icons.star_outline,
              title: AppStrings.rateApp,
              onTap: () => _launchUrl(
                'https://play.google.com/store/apps/details?id=com.example.app',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.black2, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.black2,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey, size: 24),
          ],
        ),
      ),
    );
  }
}
