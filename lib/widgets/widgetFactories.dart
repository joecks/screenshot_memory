import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screenshot_memory/pages/edit_options/edit_options_bloc.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';

extension MenuActionExtension on MenuAction {
  IconData get iconData {
    switch (this) {
      case MenuAction.alarm:
        return Icons.alarm;
      case MenuAction.edit:
        return Icons.edit;
      case MenuAction.crop:
        return Icons.crop;
      case MenuAction.close:
        return Icons.close;
      case MenuAction.add:
        return Icons.add;
    }
    throw ("${this} is not implemented yet");
  }
}

AppBar defaultAppBar(BuildContext context,
    {List<MenuAction> actions,
    Function(MenuAction) onActionPressed,
    Widget title}) {
  return AppBar(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    elevation: 1,
    actions: actions != null
        ? actions
            .map((menuAction) => IconButton(
                  onPressed: () {
                    if (onActionPressed != null) onActionPressed(menuAction);
                  },
                  icon: Icon(menuAction.iconData),
                ))
            .toList()
        : [],
    title: title,
  );
}

Widget buildFadeInImage(ScreenshotMemory item, double height, double width) {
  return Hero(
    tag: "image_${item.id}",
    child: FadeInImage(
      image: FileImage(File(item.path)),
      placeholder: AssetImage("assets/gifs/image_placeholder.gif"),
      height: height,
      width: width,
      key: ObjectKey(item.path),
      fit: BoxFit.cover,
    ),
  );
}

Row buildTagsRow(Iterable<Tag> tags) {
  return Row(
    children: tags.map((it) {
      return Container(
        margin: EdgeInsets.all(2),
        constraints: BoxConstraints.tight(Size.square(12)),
        decoration: BoxDecoration(color: it.color, shape: BoxShape.circle),
      );
    }).toList(),
  );
}
