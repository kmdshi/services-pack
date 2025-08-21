import 'package:file_converter/features/doc_files/view/doc_tab.dart';
import 'package:file_converter/features/image_files/view/image_tab.dart';
import 'package:file_converter/features/video_files/view/video_tab.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Изображения'),
    Tab(text: 'Видео'),
    Tab(text: 'Документы'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер файлов'),
        bottom: TabBar(controller: _tabController, tabs: myTabs),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ImageTab(), VideoTab(), DocumentTab()],
      ),
    );
  }
}
