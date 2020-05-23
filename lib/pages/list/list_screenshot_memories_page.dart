import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot_memory/pages/list/list_screenshot_bloc.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';
import 'package:screenshot_memory/widgets/Lifecycle.dart';
import 'package:screenshot_memory/widgets/widgetFactories.dart';

class ListScreenshotMemoriesPage extends StatelessWidget {
  static String routeName = '/list';

  @override
  Widget build(BuildContext context) {
    final bloc = ListScreenshotMemoriesBloc(Provider.of(context), context);
    return LifecycleWidget(
      doOnResume: bloc.onResume(),
      child: Scaffold(
        appBar: defaultAppBar(),
        body: SafeArea(
          child: StreamBuilder<List<ScreenshotMemory>>(
              stream: bloc.memoriesStream,
              builder: (context, snapshot) {
                final itemList = snapshot.data ?? [];

                final maxItemWidth = 150.0;
                final neededHeight = 200.0;
                final availableWidth = MediaQuery.of(context).size.width;
                final count = (availableWidth / maxItemWidth).ceil();
                final ratio =
                    max(((availableWidth / count) - 16) / neededHeight, 0.5);

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
                      return ScreenshotListItem(
                        item: item,
                        onClickOnItem: (id) => bloc.onItemClicked(id),
                      );
                    });
              }),
        ),
      ),
    );
  }
}

class ScreenshotListItem extends StatelessWidget {
  const ScreenshotListItem({
    Key key,
    @required this.item,
    @required this.onClickOnItem,
  }) : super(key: key);

  final ScreenshotMemory item;
  final Function(int) onClickOnItem;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      onTap: () {
        onClickOnItem(item.id);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8).copyWith(left: 0),
              alignment: Alignment.topLeft,
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            buildFadeInImage(item, 120, 150),
            Padding(
              padding: const EdgeInsets.all(8.0).copyWith(left: 0, right: 0),
              child: Row(
                children: item.tags.map((it) {
                  return Container(
                    margin: EdgeInsets.all(2),
                    constraints: BoxConstraints.tight(Size.square(12)),
                    decoration:
                        BoxDecoration(color: it.color, shape: BoxShape.circle),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
