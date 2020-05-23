import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screenshot_memory/repositories/DatabaseRepository.dart';

AppBar defaultAppBar() {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
  );
}

FadeInImage buildFadeInImage(ScreenshotMemory item, double height, double width) {
    return FadeInImage(
            image: FileImage(File(item.path)),
            placeholder: AssetImage("assets/gifs/image_placeholder.gif"),
            height: height,
            width: width,
            fit: BoxFit.cover,
          );
  }