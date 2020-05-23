import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot_memory/pages/details/screenshot_details_bloc.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';
import 'package:screenshot_memory/widgets/widgetFactories.dart';

class ScreenshotDetailsPage extends StatelessWidget {
  static final routeName = "/details";

  final ScreenshotsDetailsParameters _parameters;

  ScreenshotDetailsPage(this._parameters);

  @override
  Widget build(BuildContext context) {
    final bloc = ScreenshotDetailsBloc(
        Provider.of<DatabaseRepository>(context), _parameters);

    return Scaffold(
        appBar: defaultAppBar(),
        body: StreamBuilder<ScreenshotMemory>(
            stream: bloc.memories,
            builder: (context, snapshot) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    if (snapshot.data != null)
                      buildFadeInImage(snapshot.data, null,
                          MediaQuery.of(context).size.width)
                  ],
                ),
              );
            }));
  }
}
