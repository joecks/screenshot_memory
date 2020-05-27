import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:screenshot_memory/pages/list/list_screenshot_memories_page.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';

enum MenuAction { alarm, edit, crop, close }

class EditOptionsArguments {
  final String imagePath;
  final int id;

  EditOptionsArguments.newScreenShot(this.imagePath) : id = null;
  EditOptionsArguments.editExisting(this.id) : imagePath = null;
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