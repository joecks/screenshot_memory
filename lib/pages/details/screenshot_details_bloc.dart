import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:screenshot_memory/pages/edit_options/edit_options_bloc.dart';
import 'package:screenshot_memory/pages/edit_options/edit_options_page.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';

class ScreenshotsDetailsParameters {
  final int screenshotId;
  ScreenshotsDetailsParameters(this.screenshotId);
}

class ScreenshotDetailsBloc {
  final DatabaseRepository _databaseRepository;
  Stream<ScreenshotMemory> get memories => _screenshotsMemoryStream.stream;
  final _screenshotsMemoryStream = BehaviorSubject<ScreenshotMemory>();
  final ScreenshotsDetailsParameters _parameters;
  final BuildContext _context;

  ScreenshotDetailsBloc(
      this._databaseRepository, this._parameters, this._context) {
    updateScreenshotMemory();
  }

  void updateScreenshotMemory() {
    _databaseRepository.screenshotMemory(_parameters.screenshotId).then((it) {
      _screenshotsMemoryStream.add(it);
    });
  }

  onActionPressed(MenuAction action) {
    if (action == MenuAction.edit) {
      Navigator.of(_context)
          .pushNamed(EditOptionsPage.routeName,
              arguments:
                  EditOptionsArguments.editExisting(_parameters.screenshotId))
          .then((value) {
        if (value == true) {
          updateScreenshotMemory();
        }
      });
    }
  }
}
