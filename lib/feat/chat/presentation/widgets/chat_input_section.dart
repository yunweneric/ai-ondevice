import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';
import 'input_option.dart';

class ChatInputSection extends StatefulWidget {
  final TextEditingController messageController;
  final Function(String)? onSendMessage;

  const ChatInputSection({
    super.key,
    required this.messageController,
    this.onSendMessage,
  });

  @override
  State<ChatInputSection> createState() => _ChatInputSectionState();
}

class _ChatInputSectionState extends State<ChatInputSection> with TickerProviderStateMixin {
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
                  controller: widget.messageController,
                  decoration: InputDecoration(
                    hintText: LangUtil.trans("chat.type_message"),
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
                    if (widget.messageController.text.trim().isNotEmpty) {
                      widget.onSendMessage?.call(widget.messageController.text);
                      widget.messageController.clear();
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
                    InputOption(
                      icon: Icons.mic,
                      label: LangUtil.trans("chat.voice_input"),
                      onTap: () {
                        _toggleOptions();
                        // Handle voice input
                      },
                    ),
                    InputOption(
                      icon: Icons.image,
                      label: LangUtil.trans("chat.image_input"),
                      onTap: () {
                        _toggleOptions();
                        // Handle image input
                      },
                    ),
                    InputOption(
                      icon: Icons.camera_alt,
                      label: LangUtil.trans("chat.camera"),
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
}
