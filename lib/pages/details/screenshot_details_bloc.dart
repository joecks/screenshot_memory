import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';

class ScreenshotsDetailsParameters {
  final int screenshotId;
  ScreenshotsDetailsParameters(this.screenshotId);
}

class ScreenshotDetailsBloc {
  Stream<ScreenshotMemory> get memories => _screenshotsMemoryStream.stream;
  final _screenshotsMemoryStream = BehaviorSubject<ScreenshotMemory>();

  ScreenshotDetailsBloc(DatabaseRepository databaseRepository,
      ScreenshotsDetailsParameters parameters) {
    databaseRepository.screenshotMemory(parameters.screenshotId).then((it) {
      _screenshotsMemoryStream.add(it);
    });
  }
}
