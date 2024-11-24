import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class BarometerWidget extends StatefulWidget {
  const BarometerWidget({super.key});

  @override
  State createState() => _BarometerWidgetState();
}

class _BarometerWidgetState extends State<BarometerWidget> {
  late RenderBarometer _barometerRenderObject;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: BarometerRenderObject(
            onCreated: (RenderBarometer renderObject) {
              _barometerRenderObject = renderObject;
            },
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Давление',
          ),
          keyboardType: TextInputType.number,
          onSubmitted: (value) {
            final intValue = int.tryParse(value) ?? 0;
            if (intValue >= 0 && intValue <= 100) {
              _barometerRenderObject.setValue(intValue);
            }
          },
        ),
      ],
    );
  }
}

class BarometerRenderObject extends LeafRenderObjectWidget {
  final ValueChanged<RenderBarometer> onCreated;

  const BarometerRenderObject({super.key, required this.onCreated});

  @override
  RenderBarometer createRenderObject(BuildContext context) {
    final renderObject = RenderBarometer();
    onCreated(renderObject);
    return renderObject;
  }
}

class RenderBarometer extends RenderBox {
  double _angle = 0;
  late final Ticker _ticker;
  bool _forward = true;
  bool _isAnimating = true;
  double _targetAngle = 0;
  double _currentAngle = 0;

  RenderBarometer() {
    _ticker = Ticker(_tick);
    _ticker.start();
  }

  void _tick(Duration elapsedTime) {
    const double delta = 0.05;
    const double fault = 80;

    if (!_isAnimating) return;

    if (_forward) {
      _angle += delta;
      if (_angle >= pi / fault) {
        _forward = false;
      }
    } else {
      _angle -= delta;
      if (_angle <= -pi / fault) {
        _forward = true;
      }
    }
    markNeedsPaint();
  }

  void setValue(int value) {
    _isAnimating = false;
    final normalizedValue = value / 100.0;
    _targetAngle = (normalizedValue * 2 * pi);

    _moveToTarget();
  }

  void _moveToTarget() {
    const double moveSpeed = 0.05;

    if ((_currentAngle - _targetAngle).abs() <= moveSpeed) {
      _currentAngle = _targetAngle;
      _angle = 0;
      _isAnimating = true;
      return;
    }

    if (_currentAngle < _targetAngle) {
      _currentAngle += moveSpeed;
    } else {
      _currentAngle -= moveSpeed;
    }

    markNeedsPaint();
    SchedulerBinding.instance.addPostFrameCallback((_) => _moveToTarget());
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(200, 200));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final center = offset + Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    /// Фон
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
    /// Обрамление
    paint
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, paint);

    /// Значения барометра
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i <= 100; i += 10) {
      final angle = pi / 2 + (i / 100 * 2 * pi);
      final dx = center.dx + radius * 0.8 * cos(angle);
      final dy = center.dy - radius * 0.8 * sin(angle);

      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(fontSize: 12, color: Colors.black),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(dx - textPainter.width / 2, dy - textPainter.height / 2),
      );
    }

    /// Стрелочка
    final needlePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3;

    final needleAngle = pi / 2 + _currentAngle + _angle;
    final needleEnd = Offset(
      center.dx + radius * 0.7 * cos(needleAngle),
      center.dy - radius * 0.7 * sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);
  }
}
