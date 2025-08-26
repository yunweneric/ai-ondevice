import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/pigeon.g.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
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
  final _gemma = FlutterGemmaPlugin.instance;

  ChatService? chatService;

  Future<void> initializeModel() async {
    try {
      final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
      final selectedModel = modelDownloaderBloc.state.selectedModel;

      if (selectedModel == null) {
        AppLogger.i('No model selected. Please select a model first.');
        return;
      }

      // Check if the selected model is actually downloaded
      if (!modelDownloaderBloc.isModelDownloaded(selectedModel.model)) {
        AppLogger.i('Selected model ${selectedModel.model.name} is not downloaded yet.');
        return;
      }

      AppLogger.i('Selected model: ${selectedModel.model.toMap()}');

      if (!await _gemma.modelManager.isModelInstalled) {
        final path = selectedModel.model.path;
        AppLogger.i('Setting model path: $path');
        await _gemma.modelManager.setModelPath(path);
      }

      final model = await _gemma.createModel(
        modelType: ModelType.gemmaIt,
        preferredBackend: PreferredBackend.cpu,
        maxTokens: 1024,
        supportImage: false, // Pass image support
      );

      final chat = await model.createChat(
        temperature: 0.7,
        randomSeed: 1,
        topK: 40,
        topP: 0.95,
        tokenBuffer: 256,
        supportImage: false, // Image support in chat
        supportsFunctionCalls: false, // Function calls support from model
        tools: [], // Pass the tools to the chat
        isThinking: false, // Pass isThinking from model
        modelType: ModelType.gemmaIt, // Pass modelType from model
      );

      chatService = ChatService(chat: chat);
      AppLogger.i('Model initialized successfully');

      // Trigger a rebuild to show the chat interface
      setState(() {});
    } catch (e) {
      AppLogger.e('Error initializing model: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize model: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAndSelectModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if a model was selected when returning from model selection screen
    _checkAndSelectModel();
  }

  Future<void> _checkAndSelectModel() async {
    final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();

    // Check if there's already a selected model
    if (modelDownloaderBloc.state.selectedModel != null) {
      await initializeModel();
      return;
    }

    // Check if there are any downloaded models and auto-select the first one
    final downloadedModels = modelDownloaderBloc.state.downloads.values
        .where((d) => d.status == DownloadStatus.complete)
        .toList();

    if (downloadedModels.isNotEmpty) {
      final firstDownloadedModel = downloadedModels.first;
      AppLogger.i('Auto-selecting downloaded model: ${firstDownloadedModel.model.name}');
      modelDownloaderBloc.selectModel(firstDownloadedModel.model);
      await initializeModel();
    } else {
      AppLogger.i('No downloaded models found. User needs to download a model first.');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _gemma.modelManager.deleteModel();
    super.dispose();
  }

  void _handleSendMessage(String message) {
    if (chatService == null) {
      AppLogger.i('Chat service not available. Please wait for model initialization.');
      // Show user-friendly message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please wait for the AI model to initialize before sending messages.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Handle send message logic here
    // You can add your message sending logic
    chatService?.addQuery(Message(text: message));
  }

  void _handleModelSelection(AiModel model) {
    final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
    modelDownloaderBloc.selectModel(model);
    AppLogger.i('Model ${model.name} selected for use');
  }

  void _handleRetryModelInitialization() {
    AppLogger.i('Retrying model initialization...');
    initializeModel();
  }

  void _handleClearChat() {
    setState(() {
      chatService = null;
    });
    AppLogger.i('Chat cleared. Model will need to be reinitialized.');
  }

  void _handleChangeModel() {
    final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
    // Clear the current chat service
    setState(() {
      chatService = null;
    });
    // Navigate to model selection
    Navigator.of(context).pushNamed(AppRouteNames.onboardModel);
    AppLogger.i('Navigating to model selection to change model.');
  }

  void _handleShowModelDetails() {
    final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
    final selectedModel = modelDownloaderBloc.state.selectedModel;

    if (selectedModel != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Model Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${selectedModel.model.name}'),
              Text('Type: ${selectedModel.model.modelType}'),
              Text('Version: ${selectedModel.model.modelVersion}'),
              Text('Size: ${selectedModel.model.size}'),
              Text('Author: ${selectedModel.model.modelAuthor}'),
              Text('Path: ${selectedModel.model.path}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _handleShowDownloadStatus() {
    final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
    final downloads = modelDownloaderBloc.state.downloads.values.toList();

    if (downloads.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Download Status'),
          content: Text('No models have been downloaded yet.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: downloads.map((download) {
            final status = download.status.name;
            final progress = download.progress;
            final isSelected =
                modelDownloaderBloc.state.selectedModel?.model.id == download.model.id;

            return ListTile(
              title: Text(download.model.name),
              subtitle: Text('Status: $status • Progress: ${(progress * 100).toInt()}%'),
              trailing: isSelected ? Icon(Icons.check_circle, color: Colors.green) : null,
              onTap: () {
                Navigator.of(context).pop();
                if (download.status == DownloadStatus.complete) {
                  _handleModelSelection(download.model);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleShowModelPerformance() {
    final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
    final selectedModel = modelDownloaderBloc.state.selectedModel;

    if (selectedModel == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Model Performance'),
          content: Text('No model is currently selected.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Model Performance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model: ${selectedModel.model.name}'),
            Text('Status: ${selectedModel.status.name}'),
            Text('Download Progress: ${(selectedModel.progress * 100).toInt()}%'),
            if (selectedModel.completedTime != null)
              Text('Downloaded: ${selectedModel.completedTime!.toString().split('.')[0]}'),
            if (chatService != null) ...[
              SizedBox(height: 16),
              Text('Chat Service: Active', style: TextStyle(color: Colors.green)),
              Text('Model Initialized: Yes'),
            ] else ...[
              SizedBox(height: 16),
              Text('Chat Service: Inactive', style: TextStyle(color: Colors.orange)),
              Text('Model Initialized: No'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleShowModelConfiguration() {
    final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
    final selectedModel = modelDownloaderBloc.state.selectedModel;

    if (selectedModel == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Model Configuration'),
          content: Text('No model is currently selected.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Model Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model: ${selectedModel.model.name}'),
            Text('Type: ${selectedModel.model.modelType}'),
            Text('Version: ${selectedModel.model.modelVersion}'),
            Text('Size: ${selectedModel.model.size}'),
            Text('Author: ${selectedModel.model.modelAuthor}'),
            Text('Description: ${selectedModel.model.description}'),
            SizedBox(height: 16),
            Text('Flutter Gemma Settings:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Model Type: GemmaIt'),
            Text('• Backend: CPU'),
            Text('• Max Tokens: 1024'),
            Text('• Temperature: 0.7'),
            Text('• Top K: 40'),
            Text('• Top P: 0.95'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleShowModelLogs() {
    final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
    final selectedModel = modelDownloaderBloc.state.selectedModel;

    if (selectedModel == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Model Logs'),
          content: Text('No model is currently selected.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Model Logs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model: ${selectedModel.model.name}'),
            SizedBox(height: 16),
            Text('Download Logs:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Start Time: ${selectedModel.startTime.toString().split('.')[0]}'),
            Text('• Last Update: ${selectedModel.lastUpdateTime.toString().split('.')[0]}'),
            if (selectedModel.completedTime != null)
              Text('• Completed: ${selectedModel.completedTime!.toString().split('.')[0]}'),
            Text('• Progress: ${(selectedModel.progress * 100).toInt()}%'),
            Text('• Status: ${selectedModel.status.name}'),
            if (selectedModel.errorMessage != null) ...[
              SizedBox(height: 16),
              Text('Error:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              Text(selectedModel.errorMessage!, style: TextStyle(color: Colors.red)),
            ],
            SizedBox(height: 16),
            Text('Chat Service Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(chatService != null ? 'Active' : 'Inactive'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleShowModelHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Model Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How to use AI models:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('1. Download a model from the model selection screen'),
            Text('2. Wait for the download to complete'),
            Text('3. Select the downloaded model to use'),
            Text('4. Wait for the model to initialize'),
            Text('5. Start chatting with the AI'),
            SizedBox(height: 16),
            Text('Troubleshooting:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• If the model fails to initialize, try refreshing'),
            Text('• If you want to use a different model, use the change model button'),
            Text('• Check the model logs for any error messages'),
            Text('• Ensure you have enough storage space'),
            SizedBox(height: 16),
            Text('Model Information:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Use the refresh button to retry model initialization'),
            Text('• Use the change model button to select a different model'),
            Text('• Check the model status for download progress'),
            Text('• View model logs for detailed information'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleShowModelAbout() {
    final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
    final selectedModel = modelDownloaderBloc.state.selectedModel;

    if (selectedModel == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('About AI Models'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Models in Offline AI:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                  'This app uses Flutter Gemma, a local AI model framework that allows you to run AI models on your device without sending data to the cloud.'),
              SizedBox(height: 16),
              Text('Benefits:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Privacy: Your data stays on your device'),
              Text('• Offline: Works without internet connection'),
              Text('• Fast: No network latency'),
              Text('• Secure: No data transmission to external servers'),
              SizedBox(height: 16),
              Text('Technology:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Flutter Gemma: Local AI model framework'),
              Text('• Model Type: GemmaIt (Instruction Tuned)'),
              Text('• Backend: CPU optimized'),
              Text('• Quantization: Q8 for efficiency'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About ${selectedModel.model.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model Information:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Name: ${selectedModel.model.name}'),
            Text('Description: ${selectedModel.model.description}'),
            Text('Author: ${selectedModel.model.modelAuthor}'),
            Text('Version: ${selectedModel.model.modelVersion}'),
            Text('Type: ${selectedModel.model.modelType}'),
            Text('Size: ${selectedModel.model.size}'),
            SizedBox(height: 16),
            if (selectedModel.model.modelAuthorDescription.isNotEmpty) ...[
              Text('Author Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(selectedModel.model.modelAuthorDescription),
              SizedBox(height: 16),
            ],
            if (selectedModel.model.modelAuthorWebsite.isNotEmpty) ...[
              Text('Author Website:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(selectedModel.model.modelAuthorWebsite),
            ],
            SizedBox(height: 16),
            Text('Technical Details:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Framework: Flutter Gemma'),
            Text('• Model Type: GemmaIt'),
            Text('• Backend: CPU'),
            Text('• Quantization: Q8'),
            Text('• Max Tokens: 1024'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleShowModelSettings() {
    final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
    final selectedModel = modelDownloaderBloc.state.selectedModel;

    if (selectedModel == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Model Settings'),
          content: Text('No model is currently selected.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Model Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Model: ${selectedModel.model.name}'),
            SizedBox(height: 16),
            Text('Flutter Gemma Settings:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Model Type: GemmaIt'),
            Text('• Backend: CPU'),
            Text('• Max Tokens: 1024'),
            Text('• Temperature: 0.7'),
            Text('• Top K: 40'),
            Text('• Top P: 0.95'),
            Text('• Token Buffer: 256'),
            Text('• Random Seed: 1'),
            SizedBox(height: 16),
            Text(
                'Note: These settings are optimized for the selected model and may not be configurable at runtime.'),
            SizedBox(height: 16),
            Text('Model-Specific Settings:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Support Image: No'),
            Text('• Function Calls: No'),
            Text('• Tools: None'),
            Text('• Thinking Mode: No'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleShowModelStatus() {
    final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
    final selectedModel = modelDownloaderBloc.state.selectedModel;

    if (selectedModel == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Model Status'),
          content: Text('No model is currently selected.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Model Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model: ${selectedModel.model.name}'),
            SizedBox(height: 16),
            Text('Download Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Status: ${selectedModel.status.name}'),
            Text('• Progress: ${(selectedModel.progress * 100).toInt()}%'),
            Text(
                '• Downloaded: ${selectedModel.receivedBytes} / ${selectedModel.totalBytes} bytes'),
            Text('• Start Time: ${selectedModel.startTime.toString().split('.')[0]}'),
            Text('• Last Update: ${selectedModel.lastUpdateTime.toString().split('.')[0]}'),
            if (selectedModel.completedTime != null)
              Text('• Completed: ${selectedModel.completedTime!.toString().split('.')[0]}'),
            if (selectedModel.errorMessage != null) ...[
              SizedBox(height: 16),
              Text('Error:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              Text(selectedModel.errorMessage!, style: TextStyle(color: Colors.red)),
            ],
            SizedBox(height: 16),
            Text('Chat Service Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(chatService != null ? 'Active' : 'Inactive'),
            if (chatService != null) ...[
              Text('• Model Initialized: Yes'),
              Text('• Ready for Chat: Yes'),
              Text('• Flutter Gemma: Ready'),
            ] else ...[
              Text('• Model Initialized: No'),
              Text('• Ready for Chat: No'),
              Text('• Flutter Gemma: Not Ready'),
            ],
            SizedBox(height: 16),
            Text('Storage Information:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Model Path: ${selectedModel.model.path}'),
            Text('• File Name: ${selectedModel.model.fileName}'),
            Text('• Model Size: ${selectedModel.model.size}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleShowModelInfo() {
    final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
    final selectedModel = modelDownloaderBloc.state.selectedModel;

    if (selectedModel == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Model Info'),
          content: Text('No model is currently selected.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Model Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic Information:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Name: ${selectedModel.model.name}'),
            Text('ID: ${selectedModel.model.id}'),
            Text('Type: ${selectedModel.model.modelType}'),
            Text('Version: ${selectedModel.model.modelVersion}'),
            Text('Size: ${selectedModel.model.size}'),
            Text('File Name: ${selectedModel.model.fileName}'),
            SizedBox(height: 16),
            Text('Author Information:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Author: ${selectedModel.model.modelAuthor}'),
            if (selectedModel.model.modelAuthorDescription.isNotEmpty)
              Text('Description: ${selectedModel.model.modelAuthorDescription}'),
            if (selectedModel.model.modelAuthorWebsite.isNotEmpty)
              Text('Website: ${selectedModel.model.modelAuthorWebsite}'),
            SizedBox(height: 16),
            Text('Model Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(selectedModel.model.description),
            SizedBox(height: 16),
            Text('Download Information:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('URL: ${selectedModel.model.url}'),
            Text('Local Path: ${selectedModel.model.path}'),
            Text('Download Status: ${selectedModel.status.name}'),
            Text('Progress: ${(selectedModel.progress * 100).toInt()}%'),
            SizedBox(height: 16),
            Text('Flutter Gemma Integration:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Model Type: GemmaIt'),
            Text('• Backend: CPU'),
            Text('• Status: ${chatService != null ? 'Ready' : 'Not Ready'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ModelDownloaderBloc, ModelDownloaderState>(
      listener: (context, state) {
        // Auto-initialize model when a model is selected
        if (state.selectedModel != null &&
            state.selectedModel!.status == DownloadStatus.complete &&
            chatService == null) {
          AppLogger.i('Model selected, initializing...');
          initializeModel();
        }
      },
      child: BlocBuilder<ModelDownloaderBloc, ModelDownloaderState>(
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // Header Section
                  BlocBuilder<ModelDownloaderBloc, ModelDownloaderState>(
                    builder: (context, state) {
                      return ChatHeader(
                        selectedModel: state.selectedModel,
                        onRefresh:
                            state.selectedModel != null ? _handleRetryModelInitialization : null,
                        onChangeModel: state.selectedModel != null ? _handleChangeModel : null,
                      );
                    },
                  ),

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
        },
      ),
    );
  }

  Widget _buildChatMessages(ThemeData theme) {
    return BlocBuilder<ModelDownloaderBloc, ModelDownloaderState>(
      builder: (context, state) {
        final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
        final selectedModel = state.selectedModel;

        // Check if no model is selected or if the selected model is not downloaded
        if (selectedModel == null || !modelDownloaderBloc.isModelDownloaded(selectedModel.model)) {
          return _buildNoModelSelectedView(theme, modelDownloaderBloc);
        }

        // Check if model is initializing
        if (chatService == null) {
          return _buildModelInitializingView(theme);
        }

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
                child: Text('${LangUtil.trans("chat.today")}, 9:41 AM',
                    style: theme.textTheme.bodySmall),
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
              message:
                  'That\'s interesting! How much storage space do these models typically require?',
              timestamp: '9:43 AM',
              isFromUser: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildModelInitializingView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading indicator
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),

          AppSizing.kh20Spacer(),

          Text(
            'Initializing AI Model...',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          AppSizing.kh10Spacer(),

          Text(
            'This may take a few moments',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoModelSelectedView(ThemeData theme, ModelDownloaderBloc modelDownloaderBloc) {
    return BlocBuilder<ModelDownloaderBloc, ModelDownloaderState>(
      builder: (context, state) {
        return Center(
          child: Padding(
            padding: AppSizing.kMainPadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology,
                    size: 40.w,
                    color: theme.primaryColor,
                  ),
                ),

                AppSizing.kh20Spacer(),

                // Title
                Text(
                  'No AI Model Selected',
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),

                AppSizing.kh10Spacer(),

                // Description
                Text(
                  'You need to select and download an AI model before you can start chatting.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                AppSizing.kh20Spacer(),

                // Action Button
                AppButton(
                  onPressed: () async {
                    // Navigate to model selection screen
                    final result =
                        await Navigator.of(context).pushNamed(AppRouteNames.onboardModel);
                    // Check if a model was selected when returning
                    if (result != null) {
                      _checkAndSelectModel();
                    }
                  },
                  title: 'Select Model',
                  type: AppButtonType.primary,
                  width: double.infinity,
                  height: 56.h,
                ),

                AppSizing.kh20Spacer(),

                // Check if there are any downloaded models
                if (state.downloads.values.any((d) => d.status == DownloadStatus.complete)) ...[
                  Text(
                    'Or select from your downloaded models:',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  AppSizing.kh20Spacer(),
                  ...state.downloads.values
                      .where((d) => d.status == DownloadStatus.complete)
                      .map((downloadInfo) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: ListTile(
                              leading: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24.w,
                              ),
                              title: Text(downloadInfo.model.name),
                              subtitle: Text('${downloadInfo.model.size} • Ready to use'),
                              trailing: AppButton(
                                onPressed: () {
                                  _handleModelSelection(downloadInfo.model);
                                },
                                title: 'Select',
                                type: AppButtonType.secondary,
                                height: 36.h,
                              ),
                            ),
                          )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
