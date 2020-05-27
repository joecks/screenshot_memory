import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:screenshot_memory/pages/details/screenshot_details.dart';
import 'package:screenshot_memory/pages/details/screenshot_details_bloc.dart';
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

  void onItemClicked(id) {
    Navigator.pushNamed(_buildContext, ScreenshotDetailsPage.routeName,
        arguments: ScreenshotsDetailsParameters(id)).then((value) => databaseRepository.onResume());
  }
}
