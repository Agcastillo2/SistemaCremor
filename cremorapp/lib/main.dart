import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'views/login_view.dart';
import 'views/jefe_nata_view.dart';
import 'views/jefe_helados_view.dart';
import 'views/trabajador_nata_view.dart';
import 'views/trabajador_helados_view.dart';
import 'views/supervisor_view.dart';
import 'views/profile_view.dart';
import 'views/register_view.dart';
import 'views/procesos_screen.dart';

import 'utils/theme_provider.dart';
import 'utils/locale_provider.dart';
import 'utils/app_theme.dart';
import 'l10n/l10n_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const CremorApp(),
    ),
  );
}

class CremorApp extends StatelessWidget {
  const CremorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cremor Sistema',

      // Configuración de temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // Configuración de localización
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10nConfig.supportedLocales,

      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/jefe-nata': (context) => const JefeNataView(),
        '/jefe-helados': (context) => const JefeHeladosView(),
        '/trabajador-nata': (context) => const TrabajadorNataView(),
        '/trabajador-helados': (context) => const TrabajadorHeladosView(),
        '/supervisor': (context) => const SupervisorView(),
        '/profile': (context) => const ProfileView(),
        '/register': (context) => const RegisterView(),
        '/procesos': (context) => const ProcesosScreen(),
      },
    );
  }
}
