import 'package:flutter/material.dart';
import 'package:offline_ai/shared/shared.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      url: 'https://google.com',
      title: LangUtil.trans("terms_of_service.title"),
    );
  }
}
