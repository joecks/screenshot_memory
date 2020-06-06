import 'dart:async';
import 'dart:io' show Platform;

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:rxdart/subjects.dart';
import 'package:screenshot_memory/pages/details/screenshot_details.dart';
import 'package:screenshot_memory/pages/details/screenshot_details_bloc.dart';
import 'package:screenshot_memory/pages/edit_options/edit_options_bloc.dart';
import 'package:screenshot_memory/pages/edit_options/edit_options_page.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';

class ListScreenshotMemoriesBloc {
  final DatabaseRepository databaseRepository;
  final _memories = BehaviorSubject<List<ScreenshotMemory>>();
  StreamSubscription<List<ScreenshotMemory>> _memoriesSubscription;
  final BuildContext _buildContext;

  get memoriesStream => _memories.stream;

  ListScreenshotMemoriesBloc(this.databaseRepository, this._buildContext) {
    final screenshotMemoriesStream =
        databaseRepository.screenshotMemoriesStream();
    _memoriesSubscription = screenshotMemoriesStream.listen((event) {
      _memories.add(event);
    });
  }

  void dispose() {
    _memoriesSubscription.cancel();
    _memories.close();
  }

  onResume() {
    databaseRepository.onResume();
  }

  onMenuActionClicked(MenuAction action) {
    if (action == MenuAction.add) {
      if (Platform.isAndroid || Platform.isIOS) {
        FlutterDocumentPicker.openDocument().then((value) {
          if (value != null) {
            Navigator.pushNamed(_buildContext, EditOptionsPage.routeName,
                arguments: EditOptionsArguments.newScreenShot(value));
          }
        });
      } else {
        showOpenPanel().then((value) {
          if (value != null && !value.canceled && value.paths.isNotEmpty) {
            Navigator.pushNamed(_buildContext, EditOptionsPage.routeName,
                arguments: EditOptionsArguments.newScreenShot(value.paths[0]));
          }
        });
      }
    }
  }

  void onItemClicked(id) {
    Navigator.pushNamed(_buildContext, ScreenshotDetailsPage.routeName,
            arguments: ScreenshotsDetailsParameters(id))
        .then((value) => databaseRepository.onResume());
  }
}
