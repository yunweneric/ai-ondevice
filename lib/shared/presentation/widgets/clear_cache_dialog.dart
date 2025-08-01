import 'package:flutter/material.dart';
import 'package:offline_ai/shared/shared.dart';

class ClearCacheDialog extends StatelessWidget {
  final String cacheSize;
  final VoidCallback? onClearCache;

  const ClearCacheDialog({
    super.key,
    required this.cacheSize,
    this.onClearCache,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LangUtil.trans("dialogs.clear_cache")),
      content: Text(LangUtil.trans("dialogs.clear_cache_desc", args: {"cacheSize": cacheSize})),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(LangUtil.trans("common.cancel")),
        ),
        AppButton(
          title: LangUtil.trans("dialogs.clear_cache_button"),
          onPressed: () {
            Navigator.pop(context);
            onClearCache?.call();
          },
          type: AppButtonType.danger,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
} 