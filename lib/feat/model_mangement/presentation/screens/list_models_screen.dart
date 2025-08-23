import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';

class ListModelsScreen extends StatefulWidget {
  const ListModelsScreen({super.key});

  @override
  State<ListModelsScreen> createState() => _ListModelsScreenState();
}

class _ListModelsScreenState extends State<ListModelsScreen> {
  final bloc = getIt.get<ModelDownloaderBloc>();

  @override
  void initState() {
    super.initState();
    bloc.add(const LoadDownloadsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LangUtil.trans("models.model_management")),
        centerTitle: true,
      ),
      body: const Column(
        children: [
          // Main Content
          Expanded(
            child: ModelManagementContent(),
          ),
        ],
      ),
    );
  }
}

class ModelManagementContent extends StatelessWidget {
  const ModelManagementContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Storage Overview Section
          Padding(
            padding: AppSizing.kMainPadding(context),
            child: const StorageOverview(),
          ),
          AppSizing.kh20Spacer(),
          BlocBuilder<ModelDownloaderBloc, ModelDownloaderState>(
            builder: (context, state) {
              final selectedModel = state.selectedModel;
              final downloadedModels = state.downloads.values
                  .where((download) => download.status == DownloadStatus.complete)
                  .toList();

              final downloadingModels = state.downloads.values
                  .where((download) => download.status == DownloadStatus.downloading)
                  .toList();

              final availableModels = AllAiModels.models
                  .where((model) => !downloadedModels
                      .any((downloadedModel) => downloadedModel.model.id == model.id))
                  .where((model) => !downloadingModels
                      .any((downloadingModel) => downloadingModel.model.id == model.id))
                  .toList();

              return ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: AppSizing.kMainPadding(context),
                children: [
                  AppSizing.kh20Spacer(),
                  // Available to Download Section
                  if (downloadingModels.isNotEmpty)
                    ModelListSection(
                      title: LangUtil.trans("models.in_progress"),
                      subtitle: LangUtil.trans("common.view_all"),
                      models: downloadingModels,
                      builder: (model) => ModelDownloadingCard(downloadInfo: model),
                    ),
                  AppSizing.kh20Spacer(),
                  // Downloaded Models Section
                  if (downloadedModels.isNotEmpty)
                    ModelListSection(
                      title: LangUtil.trans("models.downloaded_models"),
                      subtitle: LangUtil.trans("models.clear_all"),
                      onTapSubtitle: () {
                        final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
                        modelDownloaderBloc.add(const ClearDownloadsEvent());
                      },
                      models: downloadedModels,
                      builder: (model) => DownloadedModelCard(
                        model: model,
                        isActive: selectedModel?.model.id == model.model.id,
                      ),
                    ),

                  AppSizing.kh20Spacer(),

                  // Available to Download Section

                  ModelListSection(
                    title: LangUtil.trans("models.available_models"),
                    subtitle: LangUtil.trans("common.view_all"),
                    models: availableModels,
                    builder: (model) => AvailableModelCard(model: model),
                  ),

                  AppSizing.khSpacer(AppSizing.kHPercentage(context, 10)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
