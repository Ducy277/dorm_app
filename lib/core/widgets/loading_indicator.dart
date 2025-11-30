import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final bool centered;

  const LoadingIndicator({
    super.key,
    this.size = 32,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(strokeWidth: 3),
    );
    if (!centered) return indicator;
    return Center(child: indicator);
  }
}
