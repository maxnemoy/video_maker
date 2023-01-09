import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_maker/ui/components/repaint_boundary_wrapper/repaint_boundary_wrapper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_maker/utils/video_maker.dart';

const txt = """
What is Lorem Ipsum?
Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum
""";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? image;

  _onVideoShare() async {
    VideoMaker mv = VideoMaker(
        backgroundVideoPath: "assets/background.mp4", imageData: image!);
    String? result = await mv.buildVideo();

    if (result == null) return;
    List<XFile> files = [];
    Uint8List video = await File(result).readAsBytes();
    files.add(XFile.fromData(Uint8List.fromList(video), mimeType: "video/mp4"));
    await Share.shareXFiles(files, text: "some text", subject: "some subject");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RepaintBoundaryWrapper(
          isHided: true,
          onRepaintBoundaryBuilded: (png) async {
            setState(() {
              image = png;
            });
          },
          body: Column(children: [
            if (image != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(image!),
              ),
            const Text("^ is image ^"),
            ElevatedButton.icon(
              onPressed: image == null ? null : _onVideoShare,
              icon: const Icon(Icons.share),
              label: const Text("Share"),
            )
          ]),
          child: Container(
            width: 300,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: Colors.red),
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(txt),
            ),
          ),
        ),
      ),
    );
  }
}
