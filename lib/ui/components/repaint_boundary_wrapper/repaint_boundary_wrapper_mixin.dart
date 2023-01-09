import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

mixin RepaintBoundaryMixin {
  final GlobalKey _boundaryKey = GlobalKey();

  GlobalKey get boundaryKey => _boundaryKey;

  Future<Uint8List> getPng({double pixelRatio = 1}) async {
    RenderRepaintBoundary? widget = boundaryKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (widget == null) throw "Widget not found in render three";

    ui.Image image = await widget.toImage(pixelRatio: pixelRatio);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  }
}