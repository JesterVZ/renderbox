import 'package:flutter/material.dart';
import 'package:weather/presentation/gant/gant.dart';

class GanttChartPage extends StatelessWidget {
  const GanttChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GanttChartWidget(
        tasks: [
          GanttTask('Task 1', DateTime(2023, 11, 1), Duration(days: 5),
              Colors.blue),
          GanttTask('Task 2', DateTime(2023, 11, 4), Duration(days: 3),
              Colors.red),
          GanttTask('Task 3', DateTime(2023, 11, 8), Duration(days: 7),
              Colors.green),
        ],
        startDate: DateTime(2023, 11, 1),
        endDate: DateTime(2023, 11, 15),
      ),
    );
  }
}