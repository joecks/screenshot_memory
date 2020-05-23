import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screenshot_memory/pages/list/list_screenshot_memories_page.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';
import 'package:screenshot_memory/views/strings.dart';

enum MenuAction { alarm, edit, crop, close }

class EditOptionsArguments {
  final String imagePath;

  EditOptionsArguments(this.imagePath);
}

class Tag {
  Tag(this.color, this.selected);

  final Color color;
  final bool selected;

  String toDbString() {
    return "#COLOR(${color.value})";
  }

  static final _COLOR_REGEXP = RegExp("#COLOR\\((\\d+)\\)");

  static Tag parse(String tagString) {
    final matches = _COLOR_REGEXP.firstMatch(tagString);
    final match = matches != null ? int.tryParse(matches.group(1)) : null;
    return match != null ? Tag(Color(match), true) : null;
  }
}

class EditOptionsBloc {
  final _imageController = BehaviorSubject<File>();
  final _tagsController = BehaviorSubject<List<Tag>>();
  final DatabaseRepository _databaseRepository;
  final BuildContext _context;
  final EditOptionsArguments _arguments;
  String _name;
  String _description = "";

  Iterable<Tag> _tags = <Tag>[
    Tag(Color(0xffff3b30), false),
    Tag(Color(0xffff9500), false),
    Tag(Color(0xffffcc00), false),
    Tag(Color(0xff4CD964), false),
    Tag(Color(0xff5AC8FA), false),
    Tag(Color(0xff007AFF), false),
    Tag(Color(0xff5856D6), false)
  ];

  final List<MenuAction> menuActions = <MenuAction>[
    MenuAction.alarm,
    MenuAction.edit,
    MenuAction.crop,
    MenuAction.close
  ];

  Stream<File> get image => _imageController.stream;

  Stream<Iterable<Tag>> get tags => _tagsController.stream;

  EditOptionsBloc(this._databaseRepository, this._context, this._arguments) {
    _tagsController.add(_tags);
    _imageController.add(File(_arguments.imagePath));
  }

  void onActionPressed(MenuAction action) {
    // TODO
  }

  void onDonePressed() {
    if (_arguments != null) {
      _databaseRepository
          .insertScreenshotMemory(ScreenshotMemory(
              _name ?? _arguments.imagePath
                ..split('/').last,
              _arguments.imagePath,
              _description,
              _tags.where((it) => it.selected).toSet()))
          .then((id) {
        print('CREATED $id');
      });
    }
    Navigator.popAndPushNamed(_context, ListScreenshotMemoriesPage.routeName);
  }

  void dispose() {
    _imageController.close();
    _tagsController.close();
  }

  onTagPressed(Tag selectedTag) {
    _tags = _tags.map((tag) {
      return tag.color == selectedTag.color
          ? Tag(tag.color, !tag.selected)
          : tag;
    }).toList();
    _tagsController.add(_tags);
  }

  onNameTyped(String newString) {
    _name = newString;
  }

  onDescriptionTyped(String newString) {
    _description = newString;
  }
}

extension MenuActionExtension on MenuAction {
  IconData get iconData {
    switch (this) {
      case MenuAction.alarm:
        return Icons.alarm;
      case MenuAction.edit:
        return Icons.edit;
      case MenuAction.crop:
        return Icons.crop;
      case MenuAction.close:
        return Icons.close;
    }
    throw ("${this} is not implemented yet");
  }
}

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
        appBar: AppBar(
          actions: bloc.menuActions
              .map((menuAction) => IconButton(
                    onPressed: () {
                      bloc.onActionPressed(menuAction);
                    },
                    icon: Icon(menuAction.iconData),
                  ))
              .toList(),
          title: FlatButton(
            child: ThemedText(
              "menuaction_done",
              textTheme: Theme.of(context).textTheme.headline6,
              capitalization: Capitalization.all_caps,
            ),
            onPressed: () {
              bloc.onDonePressed();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: <Widget>[
                ScreenshotImagePreview(bloc),
                TagsWithHeader(bloc),
                EditTextWithHeader(
                  "screemshot_preview_title_name",
                  (newString) => bloc.onNameTyped(newString),
                ),
                EditTextWithHeader(
                  "screemshot_preview_title_description",
                  (newString) => bloc.onDescriptionTyped(newString),
                  expandable: true,
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
              textTheme: Theme.of(context).textTheme.title,
            ),
          ),
          StreamBuilder(
            stream: _bloc.tags,
            builder: (context, AsyncSnapshot<Iterable<Tag>> tagsSnapshot) {
              final tags = tagsSnapshot.data ?? <Tag>[];

              return Row(
                children: tags.map((tag) {
                  return RawMaterialButton(
                    child: tag.selected
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : null,
                    constraints: BoxConstraints.tight(Size.square(32)),
                    shape: CircleBorder(),
                    fillColor: tag.color,
                    onPressed: () {
                      _bloc.onTagPressed(tag);
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
    this.callback, {
    Key key,
    this.expandable = false,
  }) : super(key: key);

  final String _headerKey;
  final bool expandable;
  final Function(String) callback;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    controller.addListener(() {
      callback.call(controller.value.text);
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
