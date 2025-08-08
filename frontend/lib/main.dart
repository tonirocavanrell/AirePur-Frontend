import 'package:flutter/material.dart';
import 'package:frontend/providers/locale_translationProvider.dart';
import 'package:frontend/screens/login/login_screen.dart';
import 'package:frontend/screens/signup/signup_screen.dart';
import 'package:frontend/utils/auth_service.dart';
import 'package:frontend/utils/load_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';

void main() {
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => LoadData()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  LoadData ld = LoadData();
  

  @override
  Widget build(BuildContext context) {
    AuthService.logOutGoogle();
    var localeProvider = Provider.of<LocaleProvider>(context);
    String ip = ld.ip;
    Widget homeScreen;
    if (localeProvider.languageChangeOccurred) {
      localeProvider.resetLanguageChangeFlag();
      // Decide la pantalla basado en la última pantalla activa
      switch (localeProvider.lastScreen) {
        case 'signup':
          homeScreen = SignupScreen(ip: ip);
          break;
        case 'login':
        default:
          homeScreen = LoginScreen(ip: ip);
          break;
      }
    } else {
      homeScreen = LoginScreen(ip: ip);  // Si no ha habido un cambio de idioma, ir a login
    }
    TranslationService().loadTranslations('en');
    TranslationService().loadTranslations('es');
    TranslationService().loadTranslations('ca');
    

    return MaterialApp(
    locale: localeProvider.locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    debugShowCheckedModeBanner: false,
    home: FutureBuilder(
      future: ld.getLocationPermits(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return homeScreen;  // Usa la función para decidir la pantalla inicial
        }
      },
    ),
  );
  }
}