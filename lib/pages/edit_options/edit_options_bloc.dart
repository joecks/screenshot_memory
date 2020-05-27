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
  static final defaultTags = <Tag>[
    Tag(Color(0xffff3b30)),
    Tag(Color(0xffff9500)),
    Tag(Color(0xffffcc00)),
    Tag(Color(0xff4CD964)),
    Tag(Color(0xff5AC8FA)),
    Tag(Color(0xff007AFF)),
    Tag(Color(0xff5856D6))
  ];

  Tag(this.color);

  final Color color;

  String toDbString() {
    return "#COLOR(${color.value})";
  }

  static final _COLOR_REGEXP = RegExp("#COLOR\\((\\d+)\\)");

  static Tag parse(String tagString) {
    final matches = _COLOR_REGEXP.firstMatch(tagString);
    final match = matches != null ? int.tryParse(matches.group(1)) : null;
    return match != null ? Tag(Color(match)) : null;
  }

  @override
  int get hashCode => color.hashCode;

  @override
  bool operator ==(other) =>
      other is Tag ? color == other.color : this == other;
}

class EditOptionsBloc {
  final _imageController = BehaviorSubject<File>();
  final _tagsController = BehaviorSubject<Map<Tag, bool>>();
  final _nameController = BehaviorSubject<String>();
  final _descriptionController = BehaviorSubject<String>();
  final DatabaseRepository _databaseRepository;
  final BuildContext _context;
  final EditOptionsArguments _arguments;
  String _name;
  String _description = "";
  String _path = "";
  Map<Tag, bool> _tags =
      Map.fromIterable(Tag.defaultTags, key: (it) => it, value: (_) => false);

  final List<MenuAction> menuActions = <MenuAction>[
    MenuAction.alarm,
    MenuAction.edit,
    MenuAction.crop,
    MenuAction.close
  ];

  Stream<File> get image => _imageController.stream;
  Stream<Map<Tag, bool>> get tags => _tagsController.stream;
  Stream<String> get name => _nameController.stream;
  Stream<String> get description => _descriptionController.stream;

  EditOptionsBloc(this._databaseRepository, this._context, this._arguments) {
    if (_arguments.id == null) {
      _tagsController.add(_tags);
      _path = _arguments.imagePath;
      _imageController.add(File(_path));
    } else {
      this._databaseRepository.screenshotMemory(_arguments.id).then((it) {
        it.tags.forEach((tag) {
          _tags[tag] = true;
        });
        _tagsController.add(_tags);
        _path = it.path;
        _description = it.description;
        _name = it.name;
        _nameController.add(_name);
        _descriptionController.add(_description);
        _imageController.add(File(_path));
      });
    }
  }

  void onActionPressed(MenuAction action) {
    // TODO
  }

  void onDonePressed() {
    final tags =
        _tags.entries.where((it) => it.value).map((e) => e.key).toSet();
    if (_arguments.id == null) {
      _databaseRepository
          .insertScreenshotMemory(ScreenshotMemory(
              _name ?? _arguments.imagePath
                ..split('/').last,
              _arguments.imagePath,
              _description,
              tags))
          .then((id) {
        print('CREATED $id');
        Navigator.popAndPushNamed(
            _context, ListScreenshotMemoriesPage.routeName);
      });
    } else {
      _databaseRepository
          .updateScreenshotMemory(_arguments.id,
              name: _name, description: _description, tags: tags)
          .then((value) => Navigator.pop(_context, true));
    }
  }

  void dispose() {
    _imageController.close();
    _tagsController.close();
  }

  onTagPressed(Tag selectedTag) {
    _tags[selectedTag] = !_tags[selectedTag];
    _tagsController.add(_tags);
  }

  onNameTyped(String newString) {
    _name = newString;
  }

  onDescriptionTyped(String newString) {
    _description = newString;
  }
}
