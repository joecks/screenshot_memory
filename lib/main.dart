import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screenshot_memory/pages/details/screenshot_details.dart';
import 'package:screenshot_memory/pages/edit_options/edit_options_bloc.dart';
import 'package:screenshot_memory/pages/edit_options/edit_options_page.dart';
import 'package:screenshot_memory/pages/ftu_page.dart';
import 'package:screenshot_memory/pages/list/list_screenshot_memories_page.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';

const platform = const MethodChannel('newIntent');

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
    ],
    child: ScreenshotMemoryApp(),
  ));
}

class TrackNavigation extends NavigatorObserver {
  var isPopping = false;
  var isPushing = false;

  @override
  void didPop(Route route, Route previousRoute) {
    isPushing = false;
    isPopping = true;
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route previousRoute) {
    isPushing = true;
    isPopping = false;
    super.didPush(route, previousRoute);
  }
}

class ScreenshotMemoryApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final observer = TrackNavigation();

    return MaterialApp(
      navigatorObservers: [observer],
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
      theme: ThemeData(primarySwatch: Colors.amber
//          scaffoldBackgroundColor: Colors.black,
//          primaryColor: Colors.black,
//          accentColor: Colors.white,
//          iconTheme: IconTheme.of(context).copyWith(color: Colors.white),
//          textTheme: Theme.of(context)
//              .textTheme
//              .apply(bodyColor: Colors.white, displayColor: Colors.white),
          ),
      initialRoute: ListScreenshotMemoriesPage.routeName,
      onGenerateRoute: (settings) {
        return settings.name == '/' ? null : _createRoute(settings, observer);
      },
    );
  }
}

class ListenToExternalSignalsWidget extends StatelessWidget {
  Future<String> screenshotPath() async {
    return await platform.invokeMethod("getScreenshotPath");
  }

  ListenToExternalSignalsWidget(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final callback = (call) {
      print("method called: $call");
      if (call.method == "onScreenshotPathReceived") {
        Navigator.popAndPushNamed(context, EditOptionsPage.routeName,
            arguments: EditOptionsArguments.newScreenShot(call.arguments));
      }

      return null;
    };

    platform.setMethodCallHandler(callback);
    screenshotPath().then((path) {
      Navigator.popAndPushNamed(context, EditOptionsPage.routeName,
          arguments: EditOptionsArguments.newScreenShot(path));
    });

    return child;
  }
}

final _routes = {
  "/": (context) => null,
  EditOptionsPage.routeName: (context, arguments) => EditOptionsPage(arguments),
  FtuPage.routeName: (context, _) => ListenToExternalSignalsWidget(FtuPage()),
  ListScreenshotMemoriesPage.routeName: (context, _) =>
      ListenToExternalSignalsWidget(ListScreenshotMemoriesPage()),
  ScreenshotDetailsPage.routeName: (context, arguments) =>
      ScreenshotDetailsPage(arguments),
};

Route _createRoute(RouteSettings settings, TrackNavigation observer) {
  final name = settings.name;
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return _routes[settings.name].call(context, settings.arguments);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      if (observer.isPopping &&
              (name == ScreenshotDetailsPage.routeName ||
                  name == EditOptionsPage.routeName) ||
          (observer.isPushing && name == EditOptionsPage.routeName)) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      }

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
