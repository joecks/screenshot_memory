import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screenshot_memory/pages/edit_options_page.dart';
import 'package:screenshot_memory/pages/ftu_page.dart';
import 'package:screenshot_memory/pages/list_screenshot_memories_page.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';

const platform = const MethodChannel('newIntent');

// DEBUG INFO /storage/emulated/0/Pictures/Screenshots/Screenshot_20200512-162924.png

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      Provider<FtuBloc>(
        create: (_) => FtuBloc(),
        dispose: (_, bloc) => bloc.dispose(),
      ),
      Provider<DatabaseRepository>(
        create: (_) => SqLiteDatabaseRepository(),
        dispose: (_, repo) => repo.dispose(),
      ),
      ProxyProvider<DatabaseRepository, ListScreenshotMemoriesBloc>(
        dispose: (_, bloc) => bloc.dispose(),
        update: (_, DatabaseRepository databaseRepository, __) =>
            ListScreenshotMemoriesBloc(databaseRepository),
      ),
      ProxyProvider<DatabaseRepository, EditOptionsBloc>(
        dispose: (_, bloc) => bloc.dispose(),
        update: (_, DatabaseRepository databaseRepository, __) =>
            EditOptionsBloc(databaseRepository),
      )
    ],
    child: ScreenshotMemoryApp(),
  ));
}

class ScreenshotMemoryApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [
          FlutterI18nDelegate(
              translationLoader:
                  FileTranslationLoader(basePath: "assets/i18n")),
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
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.black,
          accentColor: Colors.white,
          iconTheme: IconTheme.of(context).copyWith(color: Colors.white),
          textTheme: Theme.of(context)
              .textTheme
              .apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
        //TODO need concept to decide who routes where
        initialRoute: ListScreenshotMemoriesPage.routeName,
        routes: {
          EditOptionsPage.routeName: (context) =>
              EditOptionsPage(ModalRoute.of(context).settings.arguments),
          FtuPage.routeName: (context) =>
              ListenToExternalSignalsWidget(FtuPage()),
          ListScreenshotMemoriesPage.routeName: (context) =>
              ListenToExternalSignalsWidget(ListScreenshotMemoriesPage())
        });
  }
}

class ListenToExternalSignalsWidget extends StatelessWidget {
  Future<String> screenshotPath() async {
    return await platform.invokeMethod("getScreenshotPath");
    //return "/storage/emulated/0/Pictures/Screenshots/Screenshot_20200512-162924.png";
  }

  ListenToExternalSignalsWidget(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    screenshotPath().then((path) {
      Navigator.popAndPushNamed(context, EditOptionsPage.routeName,
          arguments: EditOptionsArguments(path));
    });

    return child;
  }
}
