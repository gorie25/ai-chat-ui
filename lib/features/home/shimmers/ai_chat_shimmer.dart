import 'package:flutter/material.dart';
import '../../../core/widgets/custom_shimmer.dart';

class AiChatShimmer extends StatelessWidget {
  const AiChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return const CustomShimmerContainer(
            height: 40,
            borderRadius: 16,
            width: double.infinity,
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 16);
        },
        itemCount: 8,
      ),
    );
  }
}
