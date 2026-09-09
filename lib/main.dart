import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/auth/logic/auth_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TabibiApp());
}

class TabibiApp extends StatelessWidget {
  const TabibiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit()..checkAuthStatus(),
      child: MaterialApp.router(
        title: 'TABIBI (طبيبي)',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('fr'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
