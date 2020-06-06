import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor/image_editor.dart';
import 'package:path/path.dart';

class ImageData {
  final String path;
  final List<int> rawImageData;
  final Rect cropRect;

  ImageData(this.path, this.rawImageData, this.cropRect);
}

Future cropAndSaveImage(ImageData config) async {
  final cropRect = config.cropRect;
  Uint8List result;
  if (Platform.isIOS || Platform.isAndroid) {
    ImageEditorOption option = ImageEditorOption();
    option.addOption(ClipOption.fromRect(cropRect));
    result = await ImageEditor.editFileImage(
      file: File(config.path),
      imageEditorOption: option,
    );
  } else {
    assert(config.rawImageData != null);
    final img.Image original =
        findDecoder(config.rawImageData, config.path).call(config.rawImageData);
    print("Will start cropping $original");
    final copy = img.copyCrop(original, cropRect.left.toInt(),
        cropRect.top.toInt(), cropRect.width.toInt(), cropRect.height.toInt());
    // final copy = await lb.run<img.Image, img.Image>();
    final encoder = findEncoder(config.path);
    print("Will use new crop copy ${copy.width}x${copy.height} with $encoder");
    result = encoder.call(copy);
    print("Will write image back");
  }
  File(config.path).writeAsBytesSync(result);
  print("Will return after writing");
}

List<int> Function(img.Image) findEncoder(String imagePath) {
  switch (extension(imagePath).toLowerCase()) {
    case '.png':
      return img.encodePng;
    case '.gif':
      return img.encodeGif;
    case '.jpeg':
    case '.jpg':
    default:
      return img.encodeJpg;
  }
}

img.Image Function(List<int>) findDecoder(List<int> data, String imagePath) {
  try {
    var decoder = img.findDecoderForData(data);
    switch (decoder.runtimeType) {
      case img.JpegDecoder:
        return img.decodeJpg;
      case img.PngDecoder:
        return img.decodePng;
      case img.GifDecoder:
        return img.decodeGif;
      case img.WebPDecoder:
        return img.decodeWebP;
    }
  } catch (_) {}

  switch (extension(imagePath).toLowerCase()) {
    case '.png':
      return img.decodePng;
    case '.gif':
      return img.decodeGif;
    case '.jpeg':
    case '.jpg':
      return img.decodeJpg;
    default:
      return null;
  }
}

img.Image decodeImage(List<int> data) {
  var decoder = img.findDecoderForData(data);
  if (decoder == null) {
    return null;
  }
  return decoder.decodeImage(data);
}
