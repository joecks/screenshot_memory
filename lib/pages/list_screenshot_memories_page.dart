import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';
import 'package:screenshot_memory/widgets/Lifecycle.dart';

class ListScreenshotMemoriesBloc {
  final DatabaseRepository databaseRepository;
  final _memories = BehaviorSubject<List<ScreenshotMemory>>();
  StreamSubscription<List<ScreenshotMemory>> _memoriesSubscription;

  get memoriesStream => _memories.stream;

  ListScreenshotMemoriesBloc(this.databaseRepository) {
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
}

class ListScreenshotMemoriesPage extends StatelessWidget {
  static String routeName = '/list';

  @override
  Widget build(BuildContext context) {
    return Consumer<ListScreenshotMemoriesBloc>(
      builder: (context, bloc, child) {
        return LifecycleWidget(
          doOnResume: bloc.onResume(),
          child: Scaffold(
            appBar: AppBar(),
            body: SafeArea(
              child: StreamBuilder<List<ScreenshotMemory>>(
                  stream: bloc.memoriesStream,
                  builder: (context, snapshot) {
                    final itemList = snapshot.data ?? [];

                    final maxItemWidth = 150.0;
                    final neededHeight = 200.0;
                    final availableWidth = MediaQuery.of(context).size.width;
                    final count = (availableWidth / maxItemWidth).ceil();
                    final ratio = max(
                        ((availableWidth / count) - 16) / neededHeight, 0.5);

                    return GridView.builder(
                        itemCount: itemList.length,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: maxItemWidth,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: ratio,
                        ),
                        itemBuilder: (context, index) {
                          final item = itemList[index];

                          return Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding:
                                      const EdgeInsets.all(8).copyWith(left: 0),
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context).textTheme.title,
                                  ),
                                ),
                                FadeInImage(
                                  image: FileImage(File(item.path)),
                                  placeholder: AssetImage("assets/gifs/image_placeholder.gif"),
                                  height: 120,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0)
                                      .copyWith(left: 0, right: 0),
                                  child: Row(
                                    children: item.tags.map((it) {
                                      return Container(
                                        margin: EdgeInsets.all(2),
                                        constraints: BoxConstraints.tight(
                                            Size.square(12)),
                                        decoration: BoxDecoration(
                                            color: it.color,
                                            shape: BoxShape.circle),
                                      );
                                    }).toList(),
                                  ),
                                )
                              ],
                            ),
                          );
                        });
                  }),
            ),
          ),
        );
      },
    );
  }
}

