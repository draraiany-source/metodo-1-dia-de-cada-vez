import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_legal.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_page.dart';

enum LegalDocumentKind { privacy, terms }

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.kind});

  final LegalDocumentKind kind;

  bool get _isPrivacy => kind == LegalDocumentKind.privacy;

  String get _title =>
      _isPrivacy ? 'Política de privacidade' : 'Termos de uso';

  String get _body =>
      _isPrivacy ? AppLegal.inAppPrivacySummary : AppLegal.inAppTermsSummary;

  String? get _url =>
      _isPrivacy
          ? (AppLegal.hasPrivacyUrl ? AppLegal.privacyPolicyUrl : null)
          : (AppLegal.hasTermsUrl ? AppLegal.termsUrl : null);

  Future<void> _openExternal() async {
    final url = _url;
    if (url == null) return;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(title: _title),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _body,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            if (_url != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openExternal,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(_isPrivacy
                      ? 'Abrir política oficial'
                      : 'Abrir termos oficiais'),
                ),
              )
            else
              const Text(
                'URL oficial ainda não configurada (PRIVACY_POLICY_URL / TERMS_URL).',
                style: TextStyle(color: AppColors.warning, fontSize: 12.5),
              ),
            if (AppLegal.hasSupportEmail) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => launchUrl(
                  Uri(
                    scheme: 'mailto',
                    path: AppLegal.supportEmail,
                  ),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.mail_outline),
                label: Text('Falar com o suporte (${AppLegal.supportEmail})'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
