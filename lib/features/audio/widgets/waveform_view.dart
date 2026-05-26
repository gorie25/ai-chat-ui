import 'package:flutter/material.dart';
import '../../../core/theme/custom_colors.dart';

class WaveformView extends StatelessWidget {
  final List<double> soundLevels;
  final int duration;
  final bool isListening;

  const WaveformView({
    super.key,
    required this.soundLevels,
    required this.duration,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const barWidth = 2.0;
        const spacing = 1.5;
        const itemWidth = barWidth + spacing;

        final itemCount = (constraints.maxWidth / itemWidth).floor().clamp(20, 120);

        final centerIndex = itemCount ~/ 2;

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(itemCount * 2 - 1, (i) {
            if (i.isOdd) return const SizedBox(width: spacing);

            final index = i ~/ 2;

            double level = 0;

            final historyIndex = soundLevels.length - (itemCount - index);

            if (historyIndex >= 0 && historyIndex < soundLevels.length) {
              level = soundLevels[historyIndex];
            } else if (soundLevels.isNotEmpty) {
              level = soundLevels.last;
            }

            double height = level == 0 ? 4 : 6 + level * 28;

            final distance = (index - centerIndex).abs();
            final factor = (1 - (distance / centerIndex)).clamp(0.0, 1.0);

            height *= (0.6 + factor * 0.4);

            final opacity = 0.3 + factor * 0.7;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              width: barWidth,
              height: height.clamp(4, 34),
              decoration: BoxDecoration(
                color: CustomColors.color28247C.withOpacity(opacity),
                borderRadius: BorderRadius.circular(100),
              ),
            );
          }),
        );
      },
    );
  }
}
