import 'dart:async';

import 'package:flutter/material.dart';

class CountdownScreen extends StatefulWidget {
  final int endsAtMs;

  const CountdownScreen({super.key, required this.endsAtMs});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingMs = widget.endsAtMs - DateTime.now().millisecondsSinceEpoch;
    final seconds = (remainingMs / 1000).ceil().clamp(0, 5);
    final progress = (remainingMs / const Duration(seconds: 5).inMilliseconds)
        .clamp(0.0, 1.0)
        .toDouble();
    final colors = Theme.of(context).colorScheme;

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primary,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ringSize = (constraints.biggest.shortestSide * 0.48)
                .clamp(140.0, 220.0)
                .toDouble();

            return Center(
              child: SizedBox(
                width: ringSize,
                height: ringSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CountdownRingPainter(
                          progress: progress,
                          color: colors.onPrimary,
                          backgroundColor: colors.onPrimary.withValues(alpha: 0.14),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        '$seconds',
                        key: ValueKey(seconds),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: ringSize * 0.48,
                              height: 1,
                              letterSpacing: -2,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CountdownRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.shortestSide * 0.06;
    final paintBase = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final paintProgress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2 - strokeWidth / 2;
    canvas.drawCircle(center, radius, paintBase);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      6.28318 * progress,
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}