import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _optionsAnimationController;
  late Animation<double> _optionsAnimation;
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    _optionsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _optionsAnimation = CurvedAnimation(
      parent: _optionsAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _optionsAnimationController.dispose();
    super.dispose();
  }

  void _toggleOptions() {
    setState(() {
      _showOptions = !_showOptions;
      if (_showOptions) {
        _optionsAnimationController.forward();
      } else {
        _optionsAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(theme),

            // Chat Messages Area
            Expanded(
              child: _buildChatMessages(theme),
            ),

            // Input Section
            _buildInputSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: AppSizing.kMainPadding(context).copyWith(
        top: 16.h,
        bottom: 16.h,
      ),
      child: Row(
        children: [
          // AI Icon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 20.w,
            ),
          ),

          AppSizing.kwSpacer(12.w),

          // Title and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Talk to Your AI',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'Gemini Pro',
                      style: theme.textTheme.bodyMedium,
                    ),
                    AppSizing.kwSpacer(8.w),
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                          color: AppColors.success, shape: BoxShape.circle),
                    ),
                    AppSizing.kwSpacer(4.w),
                    Text(
                      'Offline',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Icons
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // Handle refresh
                },
                icon: Icon(
                  Icons.refresh,
                  color: AppColors.textGrey,
                  size: 20.w,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Handle settings
                },
                icon: Icon(
                  Icons.settings,
                  color: AppColors.textGrey,
                  size: 20.w,
                ),
              ),
            ],
          ),
        ],
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
            child: Text('Today, 9:41 AM', style: theme.textTheme.bodySmall),
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
              'You\'re using Gemini Pro in offline mode.',
              style: theme.textTheme.labelMedium,
            ),
          ),
        ),

        AppSizing.kh20Spacer(),

        // AI Message 1
        _buildAIMessage(
          theme,
          'Hello! I\'m Gemini Pro, running directly on your device. How can I help you today?',
          '9:41 AM',
        ),

        AppSizing.kh20Spacer(),

        // User Message 1
        _buildUserMessage(
          theme,
          'Can you explain how offline AI models work on mobile devices?',
          '9:42 AM',
        ),

        AppSizing.kh20Spacer(),

        // AI Message 2
        _buildAIMessage(
          theme,
          'Offline AI models work by downloading the entire neural network to your device. These models are optimized for mobile hardware and use techniques like quantization to reduce size while maintaining performance. Once downloaded, they can process your queries locally without sending data to the cloud, which enhances privacy and allows usage without internet connection.',
          '9:42 AM',
        ),

        AppSizing.kh20Spacer(),

        // User Message 2
        _buildUserMessage(
          theme,
          'That\'s interesting! How much storage space do these models typically require?',
          '9:43 AM',
        ),
      ],
    );
  }

  Widget _buildAIMessage(ThemeData theme, String message, String timestamp) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Avatar
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.smart_toy,
            color: Colors.white,
            size: 16.w,
          ),
        ),

        AppSizing.kwSpacer(12.w),

        // Message Bubble
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: theme.cardColor, width: 1),
                ),
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                timestamp,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessage(ThemeData theme, String message, String timestamp) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Message Bubble
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(timestamp, style: theme.textTheme.bodySmall),
            ],
          ),
        ),

        AppSizing.kwSpacer(12.w),

        // User Avatar
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: theme.primaryColorDark,
            size: 16.w,
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    return Container(
      padding: AppSizing.kMainPadding(context).copyWith(
        top: 16.h,
        bottom: 16.h,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.cardColor, width: 1)),
      ),
      child: Column(
        children: [
          // Input Field and Action Buttons
          Row(
            children: [
              // Options Button
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: _showOptions ? theme.primaryColor : AppColors.bgGray3,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _toggleOptions,
                  icon: AnimatedRotation(
                    turns: _showOptions ? 0.125 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.add,
                      color: _showOptions ? Colors.white : AppColors.textGrey,
                      size: 12.w,
                    ),
                  ),
                ),
              ),
              AppSizing.kwSpacer(12.w),

              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Message your AI...',
                    hintStyle: theme.textTheme.labelMedium,
                    fillColor: theme.cardColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                  maxLines: null,
                ),
              ),

              AppSizing.kwSpacer(12.w),

              // Send Button
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    // Handle send message
                    if (_messageController.text.trim().isNotEmpty) {
                      // Send message logic here
                      _messageController.clear();
                    }
                  },
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 12.w,
                  ),
                ),
              ),
            ],
          ),

          // Animated Input Options
          SizeTransition(
            sizeFactor: _optionsAnimation,
            child: FadeTransition(
              opacity: _optionsAnimation,
              child: Container(
                margin: EdgeInsets.only(top: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInputOption(
                      icon: Icons.mic,
                      label: 'Voice input',
                      onTap: () {
                        _toggleOptions();
                        // Handle voice input
                      },
                    ),
                    _buildInputOption(
                      icon: Icons.image,
                      label: 'Image input',
                      onTap: () {
                        _toggleOptions();
                        // Handle image input
                      },
                    ),
                    _buildInputOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        _toggleOptions();
                        // Handle camera input
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.textGrey,
            size: 20.w,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
