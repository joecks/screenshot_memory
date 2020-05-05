import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        FlutterI18nDelegate(
            translationLoader: FileTranslationLoader(basePath: "assets/i18n")),
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        // Add new languages here
        const Locale("en"),
      ],
      title: 'Screenshot Memory',
      theme: ThemeData(
        primaryColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      home: I18nText("test"),
    );
  }
}
