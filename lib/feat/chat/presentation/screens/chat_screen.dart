import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_message.dart';
import '../widgets/chat_input_section.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    // Handle send message logic here
    // You can add your message sending logic
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            const ChatHeader(),

            // Chat Messages Area
            Expanded(
              child: _buildChatMessages(theme),
            ),

            // Input Section
            ChatInputSection(
              messageController: _messageController,
              onSendMessage: _handleSendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages(ThemeData theme) {
    return ListView(
      controller: _scrollController,
      padding: AppSizing.kMainPadding(context),
      children: [
        // Date/Time Separator
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text('${LangUtil.trans("chat.today")}, 9:41 AM', style: theme.textTheme.bodySmall),
          ),
        ),

        AppSizing.kh20Spacer(),

        // System Message
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              LangUtil.trans("chat.offline_mode"),
              style: theme.textTheme.labelMedium,
            ),
          ),
        ),

        AppSizing.kh20Spacer(),

        // AI Message 1
        ChatMessage(
          message: LangUtil.trans("chat.ai_greeting"),
          timestamp: '9:41 AM',
          isFromUser: false,
        ),

        AppSizing.kh20Spacer(),

        // User Message 1
        const ChatMessage(
          message: 'Can you explain how offline AI models work on mobile devices?',
          timestamp: '9:42 AM',
          isFromUser: true,
        ),

        AppSizing.kh20Spacer(),

        // AI Message 2
        const ChatMessage(
          message:
              'Offline AI models work by downloading the entire neural network to your device. These models are optimized for mobile hardware and use techniques like quantization to reduce size while maintaining performance. Once downloaded, they can process your queries locally without sending data to the cloud, which enhances privacy and allows usage without internet connection.',
          timestamp: '9:42 AM',
          isFromUser: false,
        ),

        AppSizing.kh20Spacer(),

        // User Message 2
        const ChatMessage(
          message: 'That\'s interesting! How much storage space do these models typically require?',
          timestamp: '9:43 AM',
          isFromUser: true,
        ),
      ],
    );
  }
}
