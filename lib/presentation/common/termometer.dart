
import 'package:flutter/material.dart';


class ThermometerScreen extends StatefulWidget {
  const ThermometerScreen({super.key});

  @override
  State createState() => _ThermometerScreenState();
}

class _ThermometerScreenState extends State<ThermometerScreen>
    with SingleTickerProviderStateMixin {
  late double _currentValue;
  final double _minValue = -20;
  final double _maxValue = 50;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentValue = 30;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: _minValue, end: _currentValue)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  void _updateValue(double newValue) {
    setState(() {
      _animation = Tween<double>(begin: _animation.value, end: newValue)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.reset();
      _controller.forward();
      _currentValue = newValue;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 400,
          width: 200,
          child: ThermometerWidget(
            animation: _animation,
            minValue: _minValue,
            maxValue: _maxValue,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Введите значение (°C)',
          ),
          keyboardType: TextInputType.number,
          onSubmitted: (value) {
            final double? newValue = double.tryParse(value);
            if (newValue != null &&
                newValue >= _minValue &&
                newValue <= _maxValue) {
              _updateValue(newValue);
            }
          },
        ),
      ],
    );
  }
}

class ThermometerWidget extends LeafRenderObjectWidget {
  final Animation<double> animation;
  final double minValue;
  final double maxValue;

  const ThermometerWidget({
    super.key,
    required this.animation,
    required this.minValue,
    required this.maxValue,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ThermometerRenderBox(
      animation: animation,
      minValue: minValue,
      maxValue: maxValue,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant ThermometerRenderBox renderObject) {
    renderObject
      ..animation = animation
      ..minValue = minValue
      ..maxValue = maxValue;
  }
}

class ThermometerRenderBox extends RenderBox {
  Animation<double> _animation;
  double _minValue;
  double _maxValue;

  ThermometerRenderBox({
    required Animation<double> animation,
    required double minValue,
    required double maxValue,
  })  : _animation = animation,
        _minValue = minValue,
        _maxValue = maxValue {
    _animation.addListener(markNeedsPaint);
  }

  Animation<double> get animation => _animation;
  set animation(Animation<double> newAnimation) {
    if (_animation != newAnimation) {
      _animation.removeListener(markNeedsPaint);
      _animation = newAnimation;
      _animation.addListener(markNeedsPaint);
      markNeedsPaint();
    }
  }

  double get minValue => _minValue;
  set minValue(double newValue) {
    if (_minValue != newValue) {
      _minValue = newValue;
      markNeedsPaint();
    }
  }

  double get maxValue => _maxValue;
  set maxValue(double newValue) {
    if (_maxValue != newValue) {
      _maxValue = newValue;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(200, 400));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    // Общий фон
    final Paint backgroundPaint = Paint()..color = Colors.white;
    final Rect backgroundRect = offset & size;
    final RRect backgroundRRect =
        RRect.fromRectAndRadius(backgroundRect, const Radius.circular(64));
    canvas.drawRRect(backgroundRRect, backgroundPaint);

    // Отступы для градусника и делений
    const double padding = 20;
    final Rect paddedRect = Rect.fromLTWH(
      offset.dx + padding,
      offset.dy + padding,
      size.width - 2 * padding,
      size.height - 2 * padding,
    );

    // Ширина трубки термометра
    final double tubeWidth = paddedRect.width / 7;

    // Шкалы для градусов Цельсия и Фаренгейта
    final Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (double i = _minValue; i <= _maxValue; i += 10) {
      // Положение делений
      double y = paddedRect.bottom -
          ((i - _minValue) / (_maxValue - _minValue) * paddedRect.height);

      // Цельсий (справа)
      textPainter.text = TextSpan(
        text: '${i.toInt()}°C',
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(paddedRect.right - 45, y - textPainter.height / 2),
      );

      // Фаренгейт (слева)
      double fahrenheit = (i * 9 / 5) + 32;
      textPainter.text = TextSpan(
        text: '${fahrenheit.toInt()}°F',
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(paddedRect.left + 5, y - textPainter.height / 2),
      );

      // Линии делений
      canvas.drawLine(
        Offset(paddedRect.left + 40, y),
        Offset(paddedRect.right - 40, y),
        linePaint,
      );
    }

    // Трубка термометра
    final Rect tubeRect = Rect.fromLTWH(
      paddedRect.center.dx - tubeWidth / 2,
      paddedRect.top,
      tubeWidth,
      paddedRect.height,
    );
    final Paint tubePaint = Paint()..color = Colors.grey[300]!;
    final RRect tubeRRect = RRect.fromRectAndRadius(
      tubeRect,
      Radius.circular(tubeWidth / 2),
    );
    canvas.drawRRect(tubeRRect, tubePaint);

    // Жидкость термометра с градиентом
    const  Gradient gradient = LinearGradient(
      colors: [Colors.red, Colors.orange, Colors.yellow],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
    final Paint liquidPaint = Paint()
      ..shader = gradient.createShader(tubeRect);

    double liquidHeight = (_animation.value - _minValue) / (_maxValue - _minValue) * paddedRect.height;
    final Rect liquidRect = Rect.fromLTWH(
      tubeRect.left,
      tubeRect.bottom - liquidHeight,
      tubeWidth,
      liquidHeight,
    );
    final RRect liquidRRect = RRect.fromRectAndRadius(
      liquidRect,
      Radius.circular(tubeWidth / 2),
    );
    canvas.drawRRect(liquidRRect, liquidPaint);
  }
}
