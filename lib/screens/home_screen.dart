import 'package:flutter/material.dart';
import '../controllers/lead_prediction_controller.dart';
import 'input_form_page.dart';
import 'results_page.dart';
import 'suggestions_page.dart';
import 'lead_toxicity_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final LeadPredictionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LeadPredictionController();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      InputFormPage(
        controller: _controller,
        onCompleted: () => setState(() => _selectedIndex = 1),
      ),
      ResultsPage(controller: _controller),
      SuggestionsPage(controller: _controller),
      const LeadToxicityPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Level Predictor'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Input',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Results',
          ),
          NavigationDestination(
            icon: Icon(Icons.health_and_safety_outlined),
            selectedIcon: Icon(Icons.health_and_safety),
            label: 'Suggestions',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Lead Toxicity',
          ),
        ],
      ),
    );
  }
}
