// import 'package:equatable/equatable.dart';
// import 'package:hydrated_bloc/hydrated_bloc.dart';
// import 'package:offline_ai/feat/model_mangement/model_management.dart';
// import 'package:offline_ai/shared/shared.dart';

// part 'model_management_event.dart';
// part 'model_management_state.dart';

// class ModelManagementBloc extends HydratedBloc<ModelManagementEvent, ModelManagementState> {
//   ModelManagementBloc()
//       : super(const ModelManagementInitial(
//           downloadedModels: [],
//           selectedModel: null,
//         )) {
//     on<AddDownloadedModelEvent>(_onAddDownloadedModel);
//     on<SelectModelEvent>(_onSelectModel);
//     on<RemoveDownloadedModelEvent>(_onRemoveDownloadedModel);
//     on<ClearDownloadedModelsEvent>(_onClearDownloadedModels);
//   }

//   Future<void> _onAddDownloadedModel(
//       AddDownloadedModelEvent event, Emitter<ModelManagementState> emit) async {
//     emit(
//       ModelManagementInitial(
//         downloadedModels: [...state.downloadedModels, event.downloadInfo],
//         selectedModel: state.selectedModel,
//       ),
//     );
//   }

//   Future<void> _onSelectModel(SelectModelEvent event, Emitter<ModelManagementState> emit) async {
//     emit(ModelManagementInitial(
//       downloadedModels: state.downloadedModels,
//       selectedModel: event.downloadInfo,
//     ));
//   }

//   Future<void> _onRemoveDownloadedModel(
//       RemoveDownloadedModelEvent event, Emitter<ModelManagementState> emit) async {
//     final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
//     modelDownloaderBloc.add(DeleteDownloadEvent(event.downloadInfo.model.id));
//     emit(
//       ModelManagementInitial(
//         downloadedModels:
//             state.downloadedModels.where((e) => e.model.id != event.downloadInfo.model.id).toList(),
//         selectedModel: state.selectedModel,
//       ),
//     );
//   }

//   Future<void> _onClearDownloadedModels(
//       ClearDownloadedModelsEvent event, Emitter<ModelManagementState> emit) async {
//     final modelDownloaderBloc = getIt.get<ModelDownloaderBloc>();
//     modelDownloaderBloc.add(ClearDownloadsEvent());
//     emit(const ModelManagementInitial(downloadedModels: [], selectedModel: null));
//   }

//   @override
//   ModelManagementState? fromJson(Map<String, dynamic> json) {
//     try {
//       return ModelManagementInitial(
//         downloadedModels: (json['downloadedModels'] as List<dynamic>)
//             .map((e) => DownloadInfo.fromJson(e as Map<String, dynamic>))
//             .toList(),
//         selectedModel: DownloadInfo.fromJson(json['selectedModel'] as Map<String, dynamic>),
//       );
//     } catch (e) {
//       AppLogger.e('Error deserializing ModelManagementState: $e');
//       return const ModelManagementInitial(
//         downloadedModels: [],
//         selectedModel: null,
//       );
//     }
//   }

//   @override
//   Map<String, dynamic>? toJson(ModelManagementState state) {
//     try {
//       return {
//         'downloadedModels': state.downloadedModels.map((e) => e.toJson()).toList(),
//         'selectedModel': state.selectedModel?.toJson(),
//       };
//     } catch (e) {
//       AppLogger.e('Error serializing ModelManagementState: $e');
//       return null;
//     }
//   }
// }
