import 'package:flutter/material.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

class ModelListSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<dynamic> models;
  final VoidCallback? onTapSubtitle;
  final Widget Function(dynamic model) builder;
  const ModelListSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.models,
    this.onTapSubtitle,
    required this.builder,
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
            GestureDetector(
              onTap: onTapSubtitle,
              child: Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        AppSizing.kh10Spacer(),
        ...models.map(builder),
      ],
    );
  }
}
