import 'package:flutter/material.dart';
import 'package:finance/models/model_transaction.dart';
import 'package:finance/river_states/currency_provider.dart';
import 'package:finance/river_states/local_sum_provider.dart';
import 'package:finance/services/privacy_service.dart';
import 'package:finance/services/settings_service.dart';
import 'package:finance/services/theme_service.dart';
import 'package:finance/session/app_session_cubit.dart';
import 'package:finance/go_router.dart';
import 'package:finance/enter_cubit/enter_auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  try {
    bool darkTheme = await SettingsService.loadDarkTheme();
    bool screenshots = await SettingsService.loadScreenshotProtection();
    ThemeService.setTheme(darkTheme);
    await PrivacyService.setScreenshotProtection(screenshots);
  } catch (e) {
    debugPrint('Startup settings error: $e');
  }
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(ModelTransactionAdapter());
    try {
      await Hive.openBox<Model_Transaction>('transactions');
      await Hive.openBox<Model_Transaction>('history');
    } catch (e) {
      debugPrint("Hive boxes corrupted, wiping: $e");
      try { await Hive.deleteBoxFromDisk('transactions'); } catch (_) {}
      try { await Hive.deleteBoxFromDisk('history'); } catch (_) {}
      await Hive.openBox<Model_Transaction>('transactions');
      await Hive.openBox<Model_Transaction>('history');
    }
    final appSessionCubit = AppSessionCubit();
    final enterAuthCubit = EnterAuthCubit();
    final routerConfig = AppRouter(appSessionCubit).router;
    runApp(
        MultiBlocProvider( providers: [
          BlocProvider.value(value: enterAuthCubit),
          BlocProvider.value(value: appSessionCubit),
        ],
            child: MultiProvider( providers: [
              ChangeNotifierProvider(create: (_) => LocalSumProvider()),
              ChangeNotifierProvider(create: (_) => CurrencyProvider()),
            ],
              child: MainApp(router: routerConfig,),))
    );
  } catch (e) {
    runApp( MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text("Error loading: $e"),
          ),
        )
    ));
  }
}

class MainApp extends StatelessWidget {
  final GoRouter router;

  const MainApp({super.key, required this.router});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, ThemeMode mode, child) {
        return MaterialApp.router(
          themeMode: mode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}
