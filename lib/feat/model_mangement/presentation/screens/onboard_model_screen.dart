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
  late AiModel selectedModel;

  @override
  void initState() {
    super.initState();
    selectedModel = AllAiModels.models[0];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModelDownloaderBloc, ModelDownloaderState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  const OnboardHeader(),

                  // Model Details
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: AllAiModels.models.length,
                      itemBuilder: (context, index) {
                        final model = AllAiModels.models[index];
                        final bloc = getIt.get<ModelDownloaderBloc>();
                        final downloadInfo = bloc.getDownloadInfo(model);
                        // AppLogger.i('downloadInfo: ${downloadInfo?.toJson()}');
                        return Column(
                          children: [
                            ModelCard(
                              model: model,
                              isSelected: model == selectedModel,
                              downloadInfo: downloadInfo,
                              onTap: () {
                                setState(() => selectedModel = model);
                              },
                              onPause: downloadInfo?.isDownloading == true
                                  ? () {
                                      final modelKey =
                                          '${model.name}_${model.modelVersion}_${model.modelType}';
                                      bloc.add(CancelDownloadEvent(modelKey));
                                    }
                                  : null,
                              onDelete: downloadInfo?.isDownloading == true
                                  ? () {
                                      final modelKey =
                                          '${model.name}_${model.modelVersion}_${model.modelType}';
                                      bloc.add(DeleteDownloadEvent(modelKey));
                                    }
                                  : null,
                            ),
                            if (model == selectedModel) ...[
                              SizedBox(height: 12.h),
                              _buildModelActions(context, model, bloc, downloadInfo),
                            ],
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return AppSizing.kh10Spacer();
                      },
                    ),
                  ),

                  // Model Selection Button
                  AppButton(
                    onPressed: () {
                      // For now, just navigate to home
                      // In the future, this could save the selected model preference
                      context.go(AppRouteNames.home);
                    },
                    title: 'Select Model',
                    type: AppButtonType.primary,
                    width: double.infinity,
                    height: 56.h,
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
      },
    );
  }

  Widget _buildModelActions(
      BuildContext context, AiModel model, ModelDownloaderBloc bloc, DownloadInfo? downloadInfo) {
    if (downloadInfo?.isDownloading == true) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                final modelKey = '${model.name}_${model.modelVersion}_${model.modelType}';
                bloc.add(CancelDownloadEvent(modelKey));
              },
              icon: const Icon(Icons.stop),
              label: const Text('Cancel Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      );
    } else if (bloc.isModelDownloaded(model)) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${model.name} is ready to use!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Model Ready'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                final modelKey = '${model.name}_${model.modelVersion}_${model.modelType}';
                bloc.add(DeleteDownloadEvent(modelKey));
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      );
    } else if (downloadInfo?.errorMessage != null) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                bloc.add(StartDownloadEvent(model));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                final modelKey = '${model.name}_${model.modelVersion}_${model.modelType}';
                bloc.add(DeleteDownloadEvent(modelKey));
              },
              icon: const Icon(Icons.delete),
              label: const Text('Clear Error'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                bloc.add(StartDownloadEvent(model));
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Model'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      );
    }
  }
}
