import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

enum Capitalization { all_caps, normal, small_caps }

class ThemedText extends StatelessWidget {
  const ThemedText(this.stringKey,
      {Key key,
      this.textTheme,
      this.fallbackKey,
      this.translationParams,
      this.capitalization = Capitalization.normal})
      : super(key: key);

  final String stringKey;
  final TextStyle textTheme;
  final String fallbackKey;
  final Capitalization capitalization;

  final Map<String, String> translationParams;

  @override
  Widget build(BuildContext context) {
    final TextStyle textTheme = (this.textTheme == null)
        ? Theme.of(context).textTheme.body1
        : this.textTheme;
    return Text(
      _changeCaps(FlutterI18n.translate(context, stringKey,
          fallbackKey: fallbackKey, translationParams: translationParams)),
      style: textTheme,
    );
  }

  String _changeCaps(String string) {
    switch (capitalization) {
      case Capitalization.all_caps:
        return string.toUpperCase();
      case Capitalization.normal:
        return string;
      case Capitalization.small_caps:
        return string.toLowerCase();
    }
    throw ("Not implemented $capitalization");
  }
}
