import 'package:flutter/material.dart';

class TestRenderObject extends RenderBox{
  @override
  void performLayout() {
    size = Size(50, 50);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.fill;
    context.canvas.drawRect(offset & size, paint);
  }
}

class CustomRenderObjectWidget extends SingleChildRenderObjectWidget{
  const CustomRenderObjectWidget({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TestRenderObject();

  }
  
}