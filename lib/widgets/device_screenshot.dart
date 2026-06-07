import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScreenCapture extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const ScreenCapture({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<ScreenCapture> createState() => _ScreenCaptureState();
}

class _ScreenCaptureState extends State<ScreenCapture> {
  final GlobalKey _boundaryKey = GlobalKey();

  Future<void> _capture() async {
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      final String basePath;
      if (Platform.isWindows) {
        final home = Platform.environment['USERPROFILE'] ?? '';
        basePath = '$home\\Pictures';
      } else {
        basePath = '/tmp';
      }

      final capturasDir = Directory('$basePath\\capturas zoe');
      if (!await capturasDir.exists()) {
        await capturasDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${capturasDir.path}\\screenshot_$timestamp.png';

      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          RepaintBoundary(
            key: _boundaryKey,
            child: widget.child,
          ),
          Positioned(
            right: 16,
            bottom: 100,
            child: GestureDetector(
              onTap: _capture,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xB3000000),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.screenshot_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
