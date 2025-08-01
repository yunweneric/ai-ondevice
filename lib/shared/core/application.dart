import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_ai/feat/model_mangement/model_management.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:upgrader/upgrader.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  void updateSystemBar() {
    var brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) {
      SystemBar.setStatusBarIconColor(brightness: Brightness.light, context: context);
      SystemBar.setNavBarColor(color: AppColors.bgDark, context: context);
    } else {
      SystemBar.setStatusBarIconColor(brightness: Brightness.dark, context: context);
      SystemBar.setNavBarColor(color: AppColors.bg, context: context);
    }
  }

  @override
  void didChangeDependencies() {
    updateSystemBar();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt.get<ThemeBloc>()),
        BlocProvider(create: (_) => getIt.get<BottomNavBarBloc>()),
        BlocProvider(create: (_) => getIt.get<LanguageBloc>()),
        BlocProvider(create: (_) => getIt.get<ModelDownloadBloc>()),
        BlocProvider(create: (_) => getIt.get<PermissionBloc>()..add(const CheckPermissions())),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ScreenUtilInit(
              designSize: Size(constraints.maxWidth, constraints.maxHeight),
              enableScaleText: () => false,
              useInheritedMediaQuery: true,
              builder: (context, _) {
                return BlocBuilder<LanguageBloc, LanguageState>(
                  builder: (context, languageState) {
                    return BlocConsumer<ThemeBloc, ThemeState>(
                      listener: (context, state) {
                        updateSystemBar();
                      },
                      builder: (context, state) {
                        return MaterialApp.router(
                          routerConfig: getIt.get<GoRouter>(),
                          debugShowCheckedModeBanner: false,
                          supportedLocales: context.supportedLocales,
                          localizationsDelegates: context.localizationDelegates,
                          locale: languageState.currentLocale,
                          theme: AppTheme.light(),
                          darkTheme: AppTheme.dark(),
                          themeMode: state.themeMode,
                          builder: (ctx, child) {
                            return UpgradeAlert(
                              navigatorKey: getIt.get<GoRouter>().routerDelegate.navigatorKey,
                              child: GestureDetector(
                                onTap: () => UtilHelper.hideKeyboard(),
                                child: child,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              });
        },
      ),
    );
  }
}
