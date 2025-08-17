import 'dart:async';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_ai/shared/shared.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart' as pp;
import 'package:upgrader/upgrader.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.i('onChange : ${change.nextState.runtimeType} -> ${change.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.i('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder, {required AppEnv env}) async {
  AppLogger.init(env);
  AppLogger.i('\n\n---> START NEW SESSION <---');
  // Needs to be called so that we can await for EasyLocalization.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await pp.getTemporaryDirectory()).path),
  );
  await AppConfig.instance.init(env: env);

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Initialize the service locator
  await ServiceLocators.register();

  await ScreenUtil.ensureScreenSize();

  // * Init local notifications!
  await LocalNotificationService().init();

  // Initialize download manager
  await getIt.get<DownloadManagerService>().initialize();

  runApp(
    UpgradeAlert(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('fr')],
        useOnlyLangCode: true,
        path: 'assets/languages',
        fallbackLocale: const Locale('en'),
        child: await builder(),
      ),
    ),
  );
}
