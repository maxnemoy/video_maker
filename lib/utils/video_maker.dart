import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

class VideoMaker {
  /// Background video path from assets
  final String backgroundVideoPath;

  /// Raw overlay image data (.png)
  final Uint8List imageData;

  /// Directory from tmp files
  late String? workDirectory;

  VideoMaker(
      {this.workDirectory,
      required this.backgroundVideoPath,
      required this.imageData});

  Future<String> _createInputVideo(String directory) async {
    ByteData data = await rootBundle.load(backgroundVideoPath);

    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    String inputFile = "$directory/input.mp4";

    await File(inputFile).writeAsBytes(bytes, flush: true);
    return inputFile;
  }

  Future<String> _createImageOverlay(String directory) async {
    String inputImage = "$directory/image.png";

    File img = await File(inputImage).writeAsBytes(imageData, flush: true);
    return img.path;
  }

  Future<String?> buildVideo() async {
    workDirectory ??= (await getExternalStorageDirectory())!.path;
    await clearTmpFiles();
    String inputFilePath = await _createInputVideo(workDirectory!);
    String imageOverlayPath = await _createImageOverlay(workDirectory!);

    String outputFile = "$workDirectory/output.mp4";
    String command =
        "-i $inputFilePath -i $imageOverlayPath -filter_complex \"[0:v][1:v] overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2:enable='between(t,0,5)'\" -pix_fmt yuv420p -c:a copy $outputFile";

    FFmpegSession session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputFile;
    } else if (ReturnCode.isCancel(returnCode)) {
      debugPrint("cancel");
    } else {
      debugPrint("Build video filed. ReturnCode $returnCode");
    }
    return null;
  }

  Future clearTmpFiles() async {
    if (workDirectory != null) {
      Directory dir = Directory(workDirectory!);
      dir
          .listSync(recursive: true)
          .whereType<File>()
          .forEach((element) async {
        switch (element.path.split("/").last) {
          case "image.png":
            await element.delete();
            break;
          case "input.mp4":
            await element.delete();
            break;
          case "output.mp4":
            await element.delete();
            break;
        }
      });
    }
  }
}
