import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';
import 'package:screenshot_memory/views/strings.dart';

class ListScreenshotMemoriesBloc {
  final _memories = BehaviorSubject<List<ScreenshotMemory>>();

  get memoriesStream => _memories.stream;

  ListScreenshotMemoriesBloc(DatabaseRepository databaseRepository) {
    databaseRepository.screenshotMemories().then((memories) {
      _memories.add(memories);
    });
  }

  void dispose() {
    _memories.close();
  }
}

class ListScreenshotMemoriesPage extends StatelessWidget {
  static String routeName = '/list';

  @override
  Widget build(BuildContext context) {
    return Consumer<ListScreenshotMemoriesBloc>(
        builder: (context, bloc, child) {
      return Scaffold(
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
                final ratio = ((availableWidth/ count) - 16) / neededHeight ;

                return GridView.builder(
                    itemCount: itemList.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: maxItemWidth,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio:  ratio,
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
                            Image.file(
                              File(item.path),
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
                                    constraints:
                                        BoxConstraints.tight(Size.square(12)),
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
      );
    });
  }
}
