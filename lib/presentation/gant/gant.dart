
import 'package:flutter/material.dart';

class GanttTask {
  final String name;
  final DateTime start;
  final Duration duration;
  final Color color;

  GanttTask(this.name, this.start, this.duration, this.color);
}

class GanttChartWidget extends LeafRenderObjectWidget {
  final List<GanttTask> tasks;
  final DateTime startDate;
  final DateTime endDate;

  const GanttChartWidget({
    super.key,
    required this.tasks,
    required this.startDate,
    required this.endDate,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return GanttChartRenderBox(
      tasks: tasks,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant GanttChartRenderBox renderObject) {
    renderObject
      ..tasks = tasks
      ..startDate = startDate
      ..endDate = endDate;
  }
}

class GanttChartRenderBox extends RenderBox {
  List<GanttTask> _tasks;
  DateTime _startDate;
  DateTime _endDate;

  GanttChartRenderBox({
    required List<GanttTask> tasks,
    required DateTime startDate,
    required DateTime endDate,
  })  : _tasks = tasks,
        _startDate = startDate,
        _endDate = endDate;

  List<GanttTask> get tasks => _tasks;
  set tasks(List<GanttTask> newTasks) {
    if (_tasks != newTasks) {
      _tasks = newTasks;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  DateTime get startDate => _startDate;
  set startDate(DateTime newStartDate) {
    if (_startDate != newStartDate) {
      _startDate = newStartDate;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  DateTime get endDate => _endDate;
  set endDate(DateTime newEndDate) {
    if (_endDate != newEndDate) {
      _endDate = newEndDate;
      markNeedsLayout();
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(600, 400));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    const double padding = 20;
    final double chartWidth = size.width - 2 * padding;
    const double taskHeight = 30;
    const double taskSpacing = 10;

    final Paint backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(
        offset & size, backgroundPaint); // Фон диаграммы Ганта

    final Paint gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    final double totalDays = _endDate.difference(_startDate).inDays.toDouble();
    final double pixelsPerDay = chartWidth / totalDays;

    // Шкала времени
    for (int i = 0; i <= totalDays; i++) {
      final double x = offset.dx + padding + i * pixelsPerDay;
      canvas.drawLine(Offset(x, offset.dy + padding),
          Offset(x, offset.dy + size.height - padding), gridPaint);

      final DateTime currentDate = _startDate.add(Duration(days: i));
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${currentDate.month}.${currentDate.day}',
          style: const TextStyle(fontSize: 10, color: Colors.black),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, offset.dy + size.height - padding + 5),
      );
    }

    // Рендеринг задач
    final Paint taskPaint = Paint();

    for (int i = 0; i < _tasks.length; i++) {
      final GanttTask task = _tasks[i];
      final double startX = offset.dx +
          padding +
          task.start.difference(_startDate).inDays * pixelsPerDay;
      final double endX = startX + task.duration.inDays * pixelsPerDay;
      final double y = offset.dy + padding + i * (taskHeight + taskSpacing);

      taskPaint.color = task.color;
      canvas.drawRect(Rect.fromLTRB(startX, y, endX, y + taskHeight), taskPaint);

      // Название задачи
      final textPainter = TextPainter(
        text: TextSpan(
          text: task.name,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: endX - startX - 5);

      textPainter.paint(canvas, Offset(startX + 5, y + (taskHeight - textPainter.height) / 2));
    }
  }
}