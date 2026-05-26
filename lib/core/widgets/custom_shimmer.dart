import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerContainer extends StatelessWidget {
  const CustomShimmerContainer({
    super.key,
    this.width,
    this.borderRadius = 0,
    this.height = 20,
    this.margin,
  });

  final double? width;
  final double borderRadius;
  final double height;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.white,
      ),
    );
  }
}

class CustomShimmer extends StatelessWidget {
  final Widget child;

  const CustomShimmer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFf0f0f0),
      highlightColor: Colors.white,
      child: child,
    );
  }
}
