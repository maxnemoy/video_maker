import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_maker/ui/components/repaint_boundary_wrapper/repaint_boundary_wrapper_mixin.dart';

typedef OnRepaintBoundaryBuilded = void Function(Uint8List png);

class RepaintBoundaryWrapper extends StatefulWidget {
  final Widget child;
  final Widget body;
  final bool isHided;
  final OnRepaintBoundaryBuilded? onRepaintBoundaryBuilded;
  const RepaintBoundaryWrapper(
      {super.key,
      this.onRepaintBoundaryBuilded,
      required this.child,
      required this.body,
      this.isHided = false});

  @override
  State<RepaintBoundaryWrapper> createState() => _RepaintBoundaryWrapperState();
}

class _RepaintBoundaryWrapperState extends State<RepaintBoundaryWrapper>
    with RepaintBoundaryMixin {
  bool _imageBuilded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildWidgetImage();
    });
  }

  Future<void> _buildWidgetImage() async {
    Uint8List png = await getPng(pixelRatio: MediaQuery.of(context).devicePixelRatio);
    widget.onRepaintBoundaryBuilded?.call(png);
    setState(() {
      _imageBuilded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Offstage(
          offstage: widget.isHided && _imageBuilded,
          child: Transform.translate(
            offset: Offset(MediaQuery.of(context).size.width + 10, 0),
            child: RepaintBoundary(
              key: boundaryKey,
              child: widget.child,
            ),
          ),
        ),
        widget.body
      ],
    );
  }
}
