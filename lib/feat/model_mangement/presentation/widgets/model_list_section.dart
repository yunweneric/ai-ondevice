import 'package:flutter/material.dart';
import 'package:offline_ai/shared/shared.dart';
import 'downloaded_model_card.dart';
import 'available_model_card.dart';

class ModelListSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<dynamic> models;

  const ModelListSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.models,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
        AppSizing.kh10Spacer(),
        ...models.map((model) {
          if (model is DownloadedModel) {
            return DownloadedModelCard(model: model);
          } else if (model is AvailableModel) {
            return AvailableModelCard(model: model);
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
