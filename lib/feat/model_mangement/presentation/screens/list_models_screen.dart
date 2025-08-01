import 'package:flutter/material.dart';
import 'package:offline_ai/shared/shared.dart';
import '../widgets/storage_overview.dart';
import '../widgets/model_list_section.dart';
import '../widgets/downloaded_model_card.dart';
import '../widgets/available_model_card.dart';

class ListModelsScreen extends StatefulWidget {
  const ListModelsScreen({super.key});

  @override
  State<ListModelsScreen> createState() => _ListModelsScreenState();
}

class _ListModelsScreenState extends State<ListModelsScreen> {
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

    return ListView(
      padding: AppSizing.kMainPadding(context),
      children: [
        // Storage Overview Section
        const StorageOverview(),

        AppSizing.kh20Spacer(),

        // Downloaded Models Section
        ModelListSection(
          title: LangUtil.trans("models.downloaded_models"),
          subtitle: LangUtil.trans("models.models_count"),
          models: [
            DownloadedModel(
              name: LangUtil.trans("models.gemini_pro"),
              description: LangUtil.trans("models.general_purpose"),
              details: '1.5 GB • v1.0.2',
              icon: Icons.smart_toy,
              iconColor: theme.primaryColor,
              isActive: true,
              isSelected: true,
            ),
            DownloadedModel(
              name: LangUtil.trans("models.ux_pilot"),
              description: LangUtil.trans("models.conversational_ai"),
              details: '2.3 GB • v3.5.0',
              icon: Icons.chat_bubble_outline,
              iconColor: theme.primaryColor,
              isActive: false,
              isSelected: false,
            ),
            DownloadedModel(
              name: LangUtil.trans("models.stable_diffusion"),
              description: LangUtil.trans("models.image_generation"),
              details: '3.7 GB • v1.2.1',
              icon: Icons.brush,
              iconColor: theme.primaryColor,
              isActive: false,
              isSelected: false,
            ),
          ],
        ),

        AppSizing.kh20Spacer(),

        // Available to Download Section
        ModelListSection(
          title: LangUtil.trans("models.available_models"),
          subtitle: LangUtil.trans("common.view_all"),
          models: [
            AvailableModel(
              name: LangUtil.trans("models.llama_2"),
              description: LangUtil.trans("models.open_source_language"),
              details: '4.2 GB • v2.0.0',
              icon: Icons.psychology,
              iconColor: theme.primaryColor,
            ),
            AvailableModel(
              name: LangUtil.trans("models.whisper_small"),
              description: LangUtil.trans("models.speech_recognition"),
              details: '0.9 GB • v1.1.0',
              icon: Icons.mic,
              iconColor: theme.primaryColor,
            ),
          ],
        ),
      ],
    );
  }
}
