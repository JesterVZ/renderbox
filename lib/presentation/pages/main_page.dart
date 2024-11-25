import 'package:flutter/material.dart';
import 'package:weather/presentation/pages/gant_chart_page.dart';

class PlaceholderWidget extends StatelessWidget {
  final String text;

  const PlaceholderWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({ super.key });

  @override
  State createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const GanttChartPage(),
    const PlaceholderWidget(text: 'Page 2'),
    const PlaceholderWidget(text: 'Page 3'),
  ];

  void _onMenuTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RenderBox'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Gantt Chart'),
              onTap: () {
                _onMenuTap(0);
                Navigator.pop(context); // Закрываем меню
              },
            ),
            ListTile(
              leading: const Icon(Icons.pages),
              title: const Text('Page 2'),
              onTap: () {
                _onMenuTap(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pages),
              title: const Text('Page 3'),
              onTap: () {
                _onMenuTap(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}