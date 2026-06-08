import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SegmentedProgressBar extends StatelessWidget {
  final double progress;
  final int segments;
  final Color? color;

  const SegmentedProgressBar({
    super.key,
    required this.progress,
    this.segments = 5,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = color ?? AppColors.primary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        final filledSegments = (animatedProgress * segments).round();

        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: List.generate(segments, (i) {
              final isFilled = i < filledSegments;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: i > 0 ? 2 : 0,
                    right: i < segments - 1 ? 2 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isFilled ? fillColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class SimpleProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;
  final double height;

  const SimpleProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, child) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: animatedProgress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        );
      },
    );
  }
}
