import 'package:flutter/material.dart';
import 'package:offline_ai/shared/shared.dart';
import '../widgets/time_section.dart';
import '../widgets/chat_entry_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LangUtil.trans("chat.chat_history")),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: const Column(
        children: [
          // Main Content
          Expanded(
            child: HistoryContent(),
          ),
        ],
      ),
    );
  }
}

class HistoryContent extends StatelessWidget {
  const HistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: AppSizing.kMainPadding(context),
      children: [
        // Today Section
        TimeSection(
          title: LangUtil.trans("chat.today"),
          entries: [
            ChatEntry(
              modelName: 'Gemini Pro',
              timestamp: '9:43 AM',
              previewText: 'Offline AI models work by downloading the entire neural network to your device...',
              messageCount: 5,
              icon: Icons.smart_toy,
              iconColor: theme.primaryColor,
            ),
            ChatEntry(
              modelName: 'Gemini Pro',
              timestamp: '8:15 AM',
              previewText: 'Here\'s a summary of the latest advancements in quantum computing...',
              messageCount: 12,
              icon: Icons.smart_toy,
              iconColor: theme.primaryColor,
            ),
          ],
        ),

        AppSizing.kh20Spacer(),

        // Yesterday Section
        TimeSection(
          title: LangUtil.trans("chat.yesterday"),
          entries: [
            ChatEntry(
              modelName: 'UX Pilot 3.5',
              timestamp: '5:22 PM',
              previewText: 'I\'ve analyzed your UI design and here are my suggestions for improvement...',
              messageCount: 8,
              icon: Icons.chat_bubble_outline,
              iconColor: theme.primaryColor,
            ),
            ChatEntry(
              modelName: 'Gemini Pro',
              timestamp: '11:34 AM',
              previewText: 'The best practices for offline-first mobile app development include...',
              messageCount: 15,
              icon: Icons.smart_toy,
              iconColor: theme.primaryColor,
            ),
          ],
        ),

        AppSizing.kh20Spacer(),

        // Last Week Section
        TimeSection(
          title: LangUtil.trans("chat.last_week"),
          entries: [
            ChatEntry(
              modelName: 'Stable Diffusion XL',
              timestamp: 'Fri, 3:12 PM',
              previewText: 'I\'ve generated the landscape image with mountains and a lake as requested...',
              messageCount: 3,
              icon: Icons.brush,
              iconColor: theme.primaryColor,
            ),
          ],
        ),
      ],
    );
  }
}
