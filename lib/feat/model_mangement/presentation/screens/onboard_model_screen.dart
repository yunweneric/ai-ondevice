import 'package:flutter/material.dart';
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
    AiModel(
      id: '1',
      name: 'Gemma 7b',
      description: 'A powerful general-purpose AI model for text and reasoning tasks.',
      image: 'assets/images/gemini.png',
      model: 'gemini-pro.tflite',
      url: 'https://example.com/models/gemini-pro.tflite',
      path: '/models/gemini-pro.tflite',
      modelType: 'Text',
      modelSize: '1.2GB',
      modelVersion: '1.0.0',
      modelAuthor: 'Google DeepMind',
      modelAuthorImage: 'assets/images/google.png',
      modelAuthorDescription: 'Google DeepMind is a leading AI research lab.',
      modelAuthorWebsite: 'https://deepmind.google/',
    ),
    AiModel(
      id: '2',
      name: 'Gemma 3b',
      description: 'An AI model specialized in user experience and interface suggestions.',
      image: 'assets/images/uxpilot.png',
      model: 'ux-pilot.tflite',
      url: 'https://example.com/models/ux-pilot.tflite',
      path: '/models/ux-pilot.tflite',
      modelType: 'Text',
      modelSize: '800MB',
      modelVersion: '2.1.0',
      modelAuthor: 'UXAI Labs',
      modelAuthorImage: 'assets/images/uxai.png',
      modelAuthorDescription: 'UXAI Labs focuses on AI for user experience.',
      modelAuthorWebsite: 'https://uxai.example.com/',
    ),
    AiModel(
      id: '3',
      name: 'Vision Lite',
      description: 'A lightweight vision model for image recognition and classification.',
      image: 'assets/images/visionlite.png',
      model: 'vision-lite.tflite',
      url: 'https://example.com/models/vision-lite.tflite',
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              AppSizing.kh20Spacer(),
              // Main Illustration
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_download,
                  color: theme.primaryColor,
                  size: 60.w,
                ),
              ),

              AppSizing.kh20Spacer(),

              // Main Heading
              Text(
                'Download Your First AI Model',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              AppSizing.kh10Spacer(),

              // Description
              Text(
                'Choose a model to download and start using AI offline on your device',
                style: theme.textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),

              AppSizing.kh20Spacer(),

              // Model Details
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: models.length, // Replace with your models list length when available
                  itemBuilder: (context, index) {
                    return ModelCard(
                      model: models[index],
                      isSelected: models[index] == selectedModel,
                      onTap: () {
                        setState(() => selectedModel = models[index]);
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return AppSizing.kh10Spacer();
                  },
                ),
              ),

              // Download Button
              AppButton(
                onPressed: () {},
                title: 'Download Now',
                width: double.infinity,
                height: 56.h,
              ),
              AppSizing.kh10Spacer(),
              AppButton(
                onPressed: () => context.go(AppRouteNames.home),
                title: 'Skip',
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
}
