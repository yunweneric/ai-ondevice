import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview_flutter;
import 'package:offline_ai/shared/shared.dart';

class WebViewWidget extends StatefulWidget {
  final String url;
  final String title;
  final bool showAppBar;

  const WebViewWidget({
    super.key,
    required this.url,
    required this.title,
    this.showAppBar = true,
  });

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  late final webview_flutter.WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = webview_flutter.WebViewController()
      ..setJavaScriptMode(webview_flutter.JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        webview_flutter.NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar based on progress
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (webview_flutter.WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = error.description;
            });
            AppLogger.e('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(widget.title),
              centerTitle: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.primaryColor,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: theme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                    });
                    _controller.reload();
                  },
                ),
              ],
            )
          : null,
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_hasError) {
      return _buildErrorWidget(theme);
    }

    return Stack(
      children: [
        webview_flutter.WebViewWidget(controller: _controller),
        if (_isLoading)
          Container(
            color: theme.scaffoldBackgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppLoader(
                    color: theme.primaryColor,
                    size: 40.w,
                  ),
                  AppSizing.kh20Spacer(),
                  Text(
                    LangUtil.trans("webview.loading"),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: AppSizing.kMainPadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.w,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
              AppSizing.kh20Spacer(),
              Text(
                LangUtil.trans("webview.error_title"),
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              AppSizing.kh10Spacer(),
              Text(
                _errorMessage.isNotEmpty ? _errorMessage : LangUtil.trans("webview.error_message"),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              AppSizing.khSpacer(30.h),
              AppButton(
                title: LangUtil.trans("webview.retry"),
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _controller.reload();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
