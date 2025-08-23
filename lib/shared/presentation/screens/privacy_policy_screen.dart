import 'package:flutter/material.dart';
import 'package:offline_ai/shared/shared.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //Todo: Create a webview widget for the privacy policy
    return WebViewWidget(
      url: 'https://google.com',
      title: LangUtil.trans("privacy_policy.title"),
    );
  }
}
