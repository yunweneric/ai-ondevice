import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/core/service_locators.dart';

class ModelActions extends StatelessWidget {
  const ModelActions({super.key, required this.model, required this.downloadInfo});
  final AiModel model;
  final DownloadInfo? downloadInfo;

  @override
  Widget build(BuildContext context) {
    return _buildModelActions(context, model, downloadInfo);
  }
}

Widget _buildModelActions(BuildContext context, AiModel model, DownloadInfo? downloadInfo) {
  final bloc = getIt.get<ModelDownloaderBloc>();
  if (downloadInfo?.isDownloading == true) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              bloc.add(CancelDownloadEvent(model));
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
              bloc.add(DeleteDownloadEvent(model));
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
              bloc.add(DeleteDownloadEvent(model));
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
