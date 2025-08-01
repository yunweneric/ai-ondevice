import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';
import 'chat_entry_card.dart';

class TimeSection extends StatelessWidget {
  final String title;
  final List<ChatEntry> entries;

  const TimeSection({
    super.key,
    required this.title,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSizing.kh10Spacer(),
        ...entries.map((entry) => ChatEntryCard(entry: entry)),
      ],
    );
  }
}
