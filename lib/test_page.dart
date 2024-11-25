import 'package:flutter/material.dart';
import 'package:weather/presentation/common/barometer.dart';
import 'package:weather/presentation/common/termometer.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          children: [
            BarometerWidget(),
            ThermometerScreen()
          ],
        ),
      ),
    );
  }
}
