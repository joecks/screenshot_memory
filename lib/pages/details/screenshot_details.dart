import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot_memory/pages/details/screenshot_details_bloc.dart';
import 'package:screenshot_memory/pages/edit_options/edit_options_bloc.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';
import 'package:screenshot_memory/widgets/widgetFactories.dart';

class ScreenshotDetailsPage extends StatelessWidget {
  static final routeName = "/details";

  final ScreenshotsDetailsParameters _parameters;

  ScreenshotDetailsPage(this._parameters);

  @override
  Widget build(BuildContext context) {
    final bloc = ScreenshotDetailsBloc(
        Provider.of<DatabaseRepository>(context), _parameters, context);

    return Scaffold(
        appBar: defaultAppBar(context,
            actions: [MenuAction.edit], onActionPressed: bloc.onActionPressed),
        body: StreamBuilder<ScreenshotMemory>(
            stream: bloc.memory,
            builder: (context, snapshot) {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenWidthCap = screenWidth > 500.0 ? 800.0 : 400.0;
              final screenshotMemory = snapshot.data;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    if (screenshotMemory != null)
                      Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.all(16),
                          child: Text(
                            snapshot.data.name,
                            style: Theme.of(context).textTheme.headline6,
                          )),
                    if (screenshotMemory != null)
                      buildFadeInImage(
                          snapshot.data, null, min(screenWidth, screenWidthCap)),
                    if (screenshotMemory != null &&
                        screenshotMemory.tags != null &&
                        screenshotMemory.tags.isNotEmpty)
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.all(16),
                        child: buildTagsRow(screenshotMemory.tags),
                      ),
                    if (screenshotMemory != null &&
                        screenshotMemory.description.isNotEmpty)
                      Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.all(16),
                          child: Text(
                            snapshot.data.description,
                            style: Theme.of(context).textTheme.bodyText1,
                          )),
                  ],
                ),
              );
            }));
  }
}
