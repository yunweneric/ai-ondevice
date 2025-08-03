import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

class OnboardModelScreen extends StatefulWidget {
  const OnboardModelScreen({super.key});

  @override
  State<OnboardModelScreen> createState() => _OnboardModelScreenState();
}

class _OnboardModelScreenState extends State<OnboardModelScreen> {
  List<AiModel> models = [
    const AiModel(
      id: '1',
      name: 'Gemma 3n',
      description: 'A powerful general-purpose AI model for text and reasoning tasks.',
      image: 'assets/images/gemini.png',
      model: 'gemini-pro.tflite',
      url: 'https://ash-speed.hetzner.com/1GB.bin',
      path: '/models/gemini-pro.tflite',
      modelType: 'Text',
      modelSize: '1.2GB',
      modelVersion: '1.0.0',
      modelAuthor: 'Google DeepMind',
      modelAuthorImage: 'assets/images/google.png',
      modelAuthorDescription: 'Google DeepMind is a leading AI research lab.',
      modelAuthorWebsite: 'https://deepmind.google/',
    ),
    const AiModel(
      id: '2',
      name: 'Gemma 2n',
      description: 'An AI model specialized in user experience and interface suggestions.',
      image: 'assets/images/uxpilot.png',
      model: 'ux-pilot.tflite',
      url: 'https://ash-speed.hetzner.com/1GB.bin',
      path: '/models/ux-pilot.tflite',
      modelType: 'Text',
      modelSize: '800MB',
      modelVersion: '2.1.0',
      modelAuthor: 'UXAI Labs',
      modelAuthorImage: 'assets/images/uxai.png',
      modelAuthorDescription: 'UXAI Labs focuses on AI for user experience.',
      modelAuthorWebsite: 'https://uxai.example.com/',
    ),
    const AiModel(
      id: '3',
      name: 'Vision Lite',
      description: 'A lightweight vision model for image recognition and classification.',
      image: 'assets/images/visionlite.png',
      model: 'vision-lite.tflite',
      url: 'https://ash-speed.hetzner.com/1GB.bin',
      path: '/models/vision-lite.tflite',
      modelType: 'Vision',
      modelSize: '500MB',
      modelVersion: '0.9.5',
      modelAuthor: 'OpenVision',
      modelAuthorImage: 'assets/images/openvision.png',
      modelAuthorDescription: 'OpenVision develops open-source vision models.',
      modelAuthorWebsite: 'https://openvision.ai/',
    ),
  ];
  late AiModel selectedModel;

  @override
  void initState() {
    super.initState();
    selectedModel = models[0];
    // Load existing downloads and auto-resume interrupted ones
    getIt.get<DownloadManagerBloc>().add(const LoadDownloads());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const OnboardHeader(),

              // Model Details
              Expanded(
                child: BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
                  builder: (context, state) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: models.length,
                      itemBuilder: (context, index) {
                        final model = models[index];

                        // Check if this model has an existing download
                        final existingDownload = _getExistingDownload(state, model.id);
                        final downloadTaskId = _getDownloadTaskId(state, model.id);
                        final isDownloading = existingDownload?.isActive ?? false;
                        final isCompleted = existingDownload?.isCompleted ?? false;
                        final isFailed = existingDownload?.isFailed ?? false;

                        // Get progress information using the correct download task ID
                        final progress = downloadTaskId != null ? state.getDownloadProgress(downloadTaskId) : null;
                        final downloadTask = downloadTaskId != null ? state.getDownloadTask(downloadTaskId) : null;

                        return ModelCard(
                          model: model,
                          isSelected: model == selectedModel,
                          isDownloading: isDownloading,
                          isDownloaded: isCompleted,
                          isFailed: isFailed,
                          downloadProgress: progress?.progress ?? downloadTask?.progress ?? 0.0,
                          downloadedBytes: progress?.downloadedBytes ?? downloadTask?.downloadedBytes ?? 0,
                          downloadSpeed: progress?.speed ?? 0.0,
                          downloadError: downloadTaskId != null ? state.getDownloadError(downloadTaskId) : null,
                          onTap: () {
                            setState(() => selectedModel = model);
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return AppSizing.kh10Spacer();
                      },
                    );
                  },
                ),
              ),

              // Download Button
              BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
                builder: (context, state) {
                  final existingDownload = _getExistingDownload(state, selectedModel.id);
                  final isDownloading = existingDownload?.isActive ?? false;
                  final isCompleted = existingDownload?.isCompleted ?? false;
                  final isFailed = existingDownload?.isFailed ?? false;
                  final isPaused = existingDownload?.status == DownloadStatus.paused;

                  String buttonText;
                  VoidCallback? onPressed;
                  AppButtonType buttonType = AppButtonType.primary;

                  if (isDownloading) {
                    buttonText = 'Cancel Download';
                    onPressed = () => _cancelDownload(context, selectedModel.id);
                    buttonType = AppButtonType.outline;
                  } else if (isCompleted) {
                    buttonText = 'Download Complete';
                    onPressed = () => context.go(AppRouteNames.home);
                  } else if (isFailed || isPaused) {
                    buttonText = isFailed ? 'Retry Download' : 'Resume Download';
                    onPressed = () => _resumeDownload(context, selectedModel.id);
                  } else {
                    buttonText = LangUtil.trans("models.download_now");
                    onPressed = () => _startDownload(context, selectedModel);
                  }

                  return AppButton(
                    onPressed: onPressed,
                    title: buttonText,
                    type: buttonType,
                    width: double.infinity,
                    height: 56.h,
                  );
                },
              ),

              AppSizing.kh10Spacer(),
              AppButton(
                onPressed: () => context.go(AppRouteNames.home),
                title: LangUtil.trans("common.skip"),
                width: double.infinity,
                height: 56.h,
              ),

              AppSizing.kh20Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// Get existing download for a model
  DownloadTask? _getExistingDownload(DownloadManagerState state, String modelId) {
    // Check if there's an existing download for this model
    final downloads = state.downloads;
    for (final entry in downloads.entries) {
      final download = entry.value;
      // Check if the download is for this model (using model ID in metadata or filename)
      if (download.metadata?['modelId'] == modelId || download.fileName.contains(modelId)) {
        return download;
      }
    }
    return null;
  }

  /// Get download task ID for a model
  String? _getDownloadTaskId(DownloadManagerState state, String modelId) {
    final downloads = state.downloads;
    for (final entry in downloads.entries) {
      final download = entry.value;
      if (download.metadata?['modelId'] == modelId || download.fileName.contains(modelId)) {
        return entry.key; // Return the download task ID
      }
    }
    return null;
  }

  void _startDownload(BuildContext context, AiModel model) {
    // Start download with model metadata
    getIt.get<DownloadManagerBloc>().add(StartDownload(
          url: model.url,
          fileName: model.model,
          customId: model.id,
          metadata: {
            'modelId': model.id,
            'modelName': model.name,
            'modelType': model.modelType,
            'modelSize': model.modelSize,
          },
        ));
  }

  void _cancelDownload(BuildContext context, String modelId) {
    // Find the download task ID for this model
    final downloadTaskId = _getDownloadTaskId(getIt.get<DownloadManagerBloc>().state, modelId);
    if (downloadTaskId != null) {
      getIt.get<DownloadManagerBloc>().add(CancelDownload(downloadTaskId));
    }
  }

  void _resumeDownload(BuildContext context, String modelId) {
    // Find the download task ID for this model
    final downloadTaskId = _getDownloadTaskId(getIt.get<DownloadManagerBloc>().state, modelId);
    if (downloadTaskId != null) {
      getIt.get<DownloadManagerBloc>().add(ResumeDownload(downloadTaskId));
    }
  }
}
