import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:screenshot_memory/pages/edit_options/edit_options_bloc.dart';
import 'package:screenshot_memory/views/strings.dart';
import 'package:screenshot_memory/widgets/widgetFactories.dart';

class EditOptionsPage extends StatelessWidget {
  static const routeName = "/edit";

  const EditOptionsPage(
    this.arguments, {
    Key key,
  }) : super(key: key);

  final EditOptionsArguments arguments;

  @override
  Widget build(BuildContext context) {
    final bloc = EditOptionsBloc(Provider.of(context), context, arguments);

    return Scaffold(
        appBar: defaultAppBar(context,
            actions: bloc.menuActions,
            onActionPressed: bloc.onActionPressed,
            title: FlatButton(
              child: ThemedText(
                "menuaction_done",
                textTheme: Theme.of(context).textTheme.headline6,
                capitalization: Capitalization.all_caps,
              ),
              onPressed: () {
                bloc.onDonePressed();
              },
            )),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: <Widget>[
                ScreenshotImagePreview(bloc),
                TagsWithHeader(bloc),
                StreamBuilder<String>(
                    stream: bloc.name,
                    builder: (context, snapshot) {
                      return EditTextWithHeader(
                        "screemshot_preview_title_name",
                        (newString) => bloc.onNameTyped(newString),
                        text: snapshot.data,
                      );
                    }),
                StreamBuilder<String>(
                  stream: bloc.description,
                  builder: (context, snapshot) {
                    return EditTextWithHeader(
                      "screemshot_preview_title_description",
                      (newString) => bloc.onDescriptionTyped(newString),
                      expandable: true,
                      text: snapshot.data,
                    );
                  }
                ),
              ],
            ),
          ),
        ));
  }
}

class TagsWithHeader extends StatelessWidget {
  const TagsWithHeader(
    this._bloc, {
    Key key,
  }) : super(key: key);

  final EditOptionsBloc _bloc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(bottom: 8),
            child: ThemedText(
              "screemshot_preview_title_tags",
              textTheme: Theme.of(context).textTheme.headline6,
            ),
          ),
          StreamBuilder(
            stream: _bloc.tags,
            builder: (context, AsyncSnapshot<Map<Tag, bool>> tagsSnapshot) {
              final tags = tagsSnapshot.data ?? Map<Tag, bool>();
              return Row(
                children: tags.entries.map((tag) {
                  return RawMaterialButton(
                    child: tag.value
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : null,
                    constraints: BoxConstraints.tight(Size.square(32)),
                    shape: CircleBorder(),
                    fillColor: tag.key.color,
                    onPressed: () {
                      _bloc.onTagPressed(tag.key);
                    },
                  );
                }).toList(),
              );
            },
          ),
          Divider(
            color: Colors.white,
          )
        ],
      ),
    );
  }
}

class EditTextWithHeader extends StatelessWidget {
  const EditTextWithHeader(
    this._headerKey,
    this._callback, {
    Key key,
    this.expandable = false,
    this.text,
  }) : super(key: key);

  final String _headerKey;
  final bool expandable;
  final String text;
  final Function(String) _callback;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    controller.text = text;
    controller.addListener(() {
      _callback.call(controller.value.text);
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: FlutterI18n.translate(context, _headerKey),
        ),
        maxLines: expandable ? null : 1,
        minLines: 1,
      ),
    );
  }
}

class ScreenshotImagePreview extends StatelessWidget {
  const ScreenshotImagePreview(
    this._bloc, {
    Key key,
  }) : super(key: key);

  final EditOptionsBloc _bloc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bloc.image,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.data == null) {
          return ThemedText("Loading");
        } else {
          return Container(
            padding: EdgeInsets.all(16),
            height: 350,
            alignment: Alignment.center,
            child: Image.file(
              snapshot.data,
              fit: BoxFit.contain,
            ),
          );
        }
      },
    );
  }
}
