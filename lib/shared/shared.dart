export 'presentation/theme/theme.dart';
export 'presentation/theme/colors.dart';
export 'utils/sizing.dart';
export 'utils/exception.dart';
export 'logging/logger.dart';
export 'logging/logger_interceptor.dart';

// utils
export 'utils/util_helper.dart';
export 'utils/language_util.dart';

// assets
export 'assets/image_manager.dart';
export 'assets/svg_manager.dart';
export 'assets/icon_manager.dart';

// core
export 'core/bootstrap.dart';
export 'core/app_config.dart';
export 'core/app_env.dart';
export 'core/service_locators.dart';
export 'core/application.dart';
export 'core/service_locators.dart' show getIt;

// data
export 'data/services/local_notification_service.dart';
export 'data/services/permission_service.dart';
export 'data/services/file_management_service.dart';
export 'data/services/flutter_gemma_service.dart';
export 'data/services/chat_service.dart';
export 'data/services/local_storage_service.dart';
export 'data/repositories/file_management_repository.dart';

// presentation/routes
export 'presentation/routes/app_router.dart';
export 'presentation/routes/app_route_names.dart';

// presentation
export 'presentation/screens/app_layout.dart';
export 'presentation/screens/onboarding_screen.dart';
export 'presentation/screens/splash_screen.dart';
export 'presentation/screens/settings_screen.dart';
export 'presentation/screens/permission_screen.dart';

// logic
export 'logic/theme/theme_bloc.dart';
export 'logic/language_bloc/language_bloc.dart';
export 'logic/bottom_nav_bar/bottom_nav_bar_bloc.dart';
export 'logic/permission/permission_bloc.dart';
export 'logic/file_management/file_management_bloc.dart';

// widgets
export 'presentation/widgets/system_bar.dart';
export 'presentation/widgets/app_button.dart';
export 'presentation/widgets/app_icon.dart';
export 'presentation/widgets/app_loader.dart';
export 'presentation/widgets/data_builder.dart';

// settings widgets
export 'presentation/widgets/settings_profile_section.dart';
export 'presentation/widgets/settings_appearance_section.dart';
export 'presentation/widgets/settings_notifications_section.dart';
export 'presentation/widgets/settings_model_management_section.dart';
export 'presentation/widgets/settings_storage_section.dart';
export 'presentation/widgets/settings_about_section.dart';
export 'presentation/widgets/settings_danger_zone_section.dart';
export 'presentation/widgets/language_selection_dialog.dart';
export 'presentation/widgets/clear_cache_dialog.dart';
export 'presentation/widgets/delete_data_dialog.dart';
export 'presentation/widgets/app_checkbox.dart';
export 'presentation/widgets/bottom_sheets.dart';
export 'presentation/widgets/storage_info_widget.dart';
export 'presentation/widgets/storage_overview_shimmer.dart';
export 'presentation/widgets/webview_widget.dart';

// screens
export 'presentation/screens/privacy_policy_screen.dart';
export 'presentation/screens/terms_of_service_screen.dart';

// enums
export 'data/enums/permissions_status.dart';
