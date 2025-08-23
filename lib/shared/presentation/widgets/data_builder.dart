import 'package:flutter/material.dart';
import 'package:offline_ai/shared/shared.dart';

class DataBuilder extends StatelessWidget {
  final bool isLoading;
  final bool isError;
  final bool isEmpty;
  final VoidCallback onReload;
  final Widget? errorWidget;
  final Widget child;
  final Widget noDataWidget;
  final double? errorHeight;
  final double? loadingHeight;
  final Color? loaderColor;
  final Widget? loadingWidget;

  const DataBuilder({
    super.key,
    required this.isLoading,
    required this.isError,
    required this.isEmpty,
    required this.onReload,
    required this.child,
    required this.noDataWidget,
    this.errorWidget,
    this.loadingHeight,
    this.errorHeight,
    this.loaderColor,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (isError) {
      return _buildErrorState(context);
    }

    if (isEmpty) {
      return _buildEmptyState();
    }

    return _buildSuccessState();
  }

  Widget _buildLoadingState(BuildContext context) {
    return loadingWidget ??
        SizedBox(
          height: AppSizing.kHPercentage(context, loadingHeight ?? 10),
          child: Center(
            child: AppLoader(color: loaderColor),
          ),
        );
  }

  Widget _buildErrorState(BuildContext context) {
    return errorWidget ??
        SizedBox(
          height: AppSizing.kHPercentage(context, errorHeight ?? 10),
          child: Center(
            child: _buildReloadButton(),
          ),
        );
  }

  Widget _buildReloadButton() {
    return GestureDetector(
      onTap: onReload,
      child: const CircleAvatar(
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEmptyState() {
    return noDataWidget;
  }

  Widget _buildSuccessState() {
    return child;
  }
}
