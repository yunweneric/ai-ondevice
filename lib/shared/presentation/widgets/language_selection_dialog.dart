import 'package:flutter/material.dart';
import 'package:offline_ai/shared/shared.dart';

class LanguageSelectionDialog extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String>? onLanguageChanged;

  const LanguageSelectionDialog({
    super.key,
    required this.selectedLanguage,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LangUtil.trans("dialogs.select_language")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(context, 'English', LangUtil.trans("profile.english")),
          _buildLanguageOption(context, 'Spanish', LangUtil.trans("profile.spanish")),
          _buildLanguageOption(context, 'French', LangUtil.trans("profile.french")),
          _buildLanguageOption(context, 'German', LangUtil.trans("profile.german")),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(LangUtil.trans("common.cancel")),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(BuildContext context, String value, String label) {
    final isSelected = selectedLanguage == value;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        onLanguageChanged?.call(value);
        Navigator.pop(context);
      },
    );
  }
}
