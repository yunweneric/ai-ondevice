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
    getIt.get<ModelDownloadBloc>().add(const LoadModelDownloads());
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
                child: BlocBuilder<ModelDownloadBloc, ModelDownloadState>(
                  builder: (context, state) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: models.length,
                      itemBuilder: (context, index) {
                        final model = models[index];
                        final isDownloading = state.isModelDownloading(model.id);
                        final isCompleted = state.isModelDownloadCompleted(model.id);
                        final isFailed = state.isModelDownloadFailed(model.id);
                        final progress = state.getDownloadProgress(model.id);

                        return ModelCard(
                          model: model,
                          isSelected: model == selectedModel,
                          isDownloading: isDownloading,
                          isDownloaded: isCompleted,
                          isFailed: isFailed,
                          downloadProgress: progress?.progress,
                          downloadedBytes: progress?.downloadedBytes,
                          downloadSpeed: progress?.speed,
                          downloadError: state.getDownloadError(model.id),
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
              BlocBuilder<ModelDownloadBloc, ModelDownloadState>(
                builder: (context, state) {
                  final isDownloading = state.isModelDownloading(selectedModel.id);
                  final isCompleted = state.isModelDownloadCompleted(selectedModel.id);
                  final isFailed = state.isModelDownloadFailed(selectedModel.id);

                  String buttonText;
                  VoidCallback? onPressed;
                  AppButtonType buttonType = AppButtonType.primary;
                  final canResume = state.canResumeModelDownload(selectedModel.id);

                  if (isDownloading) {
                    buttonText = 'Cancel Download';
                    onPressed = () => _cancelDownload(context, selectedModel.id);
                    buttonType = AppButtonType.outline;
                  } else if (isCompleted) {
                    buttonText = 'Download Complete';
                    onPressed = () => context.go(AppRouteNames.home);
                  } else if (isFailed || canResume) {
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

  void _startDownload(BuildContext context, AiModel model) {
    getIt.get<ModelDownloadBloc>().add(StartModelDownload(model));
  }

  void _cancelDownload(BuildContext context, String modelId) {
    getIt.get<ModelDownloadBloc>().add(CancelModelDownload(modelId));
  }

  void _resumeDownload(BuildContext context, String modelId) {
    getIt.get<ModelDownloadBloc>().add(ResumeModelDownload(modelId));
  }
}
