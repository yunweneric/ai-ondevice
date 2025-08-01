import 'package:flutter/material.dart';
import 'package:offline_ai/shared/shared.dart';

class DeleteDataDialog extends StatelessWidget {
  final VoidCallback? onDeleteData;

  const DeleteDataDialog({
    super.key,
    this.onDeleteData,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LangUtil.trans("dialogs.delete_all_data")),
      content: Text(LangUtil.trans("dialogs.delete_all_data_desc")),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(LangUtil.trans("common.cancel")),
        ),
        AppButton(
          title: LangUtil.trans("dialogs.delete_all_data_button"),
          onPressed: () {
            Navigator.pop(context);
            onDeleteData?.call();
          },
          type: AppButtonType.danger,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
} 