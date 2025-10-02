import 'package:flutter/material.dart';
import '../controllers/lead_prediction_controller.dart';

class InputFormPage extends StatefulWidget {
  const InputFormPage({
    super.key,
    required this.controller,
    this.onCompleted,
  });

  final LeadPredictionController controller;
  final VoidCallback? onCompleted;

  @override
  State<InputFormPage> createState() => _InputFormPageState();
}

class _InputFormPageState extends State<InputFormPage> {
  final PageController _pageController = PageController();
  final List<GlobalKey<FormState>> _formKeys =
      List.generate(3, (_) => GlobalKey<FormState>());
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleNext() {
    final currentForm = _formKeys[_currentPage].currentState;
    if (currentForm != null && currentForm.validate()) {
      if (_currentPage < 2) {
        _goToPage(_currentPage + 1);
      } else {
        widget.controller.predict();
        widget.onCompleted?.call();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prediction updated. Check the results tab.')),
        );
      }
    }
  }

  void _handlePrevious() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  void _resetForm() {
    widget.controller.reset();
    for (final key in _formKeys) {
      key.currentState?.reset();
    }
    _goToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Input Information', style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Fill in the child and household details. Use the Next button to move between pages.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: (_currentPage + 1) / 3),
              const SizedBox(height: 8),
              Text('Page ${_currentPage + 1} of 3', style: textTheme.labelLarge),
            ],
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildPage(
                formKey: _formKeys[0],
                children: [
                  _buildDropdown(
                    label: 'Age',
                    fieldKey: 'age',
                    options: const ['Less than or Equal to 30', 'Greater than 30'],
                  ),
                  _buildDropdown(
                    label: 'Education',
                    fieldKey: 'education',
                    options: const ['College_HigherDegree', 'NoCollege'],
                  ),
                  _buildDropdown(
                    label: 'Occupation',
                    fieldKey: 'occupation',
                    options: const [
                      'Housewife',
                      'Agriculture',
                      'AutoDriver',
                      'AutoDriver_Ceramics',
                      'AutoRepair',
                      'Batteries',
                      'Batteries_Lock',
                      'Ceramics',
                      'Construction_Furniture',
                      'Construction_Painting_Plastic_Polishing',
                      'Driver',
                      'Electrician',
                      'Engineer',
                      'Factory',
                      'Foundry',
                      'Gold',
                      'HairStylist',
                      'Iron',
                      'Machinery',
                      'Mechanic',
                      'None',
                      'Painting',
                      'Painting_Furniture',
                      'Painting_Polishing',
                      'Plastic',
                      'Plastic-Manufacturing_Soldering',
                      'Polishing',
                      'Polishing_Soldering',
                      'Soldering',
                      'Steel',
                      'Other',
                    ],
                  ),
                  _buildDropdown(
                    label: 'Take Home Exposure',
                    fieldKey: 'take_home_exposure',
                    options: const [
                      'Agriculture',
                      'AutoDriver',
                      'AutoDriver_Ceramics',
                      'AutoRepair',
                      'Batteries',
                      'Batteries_Lock',
                      'Ceramics',
                      'Construction_Furniture',
                      'Construction_Painting_Plastic_Polishing',
                      'Driver',
                      'Electrician',
                      'Engineer',
                      'Factory',
                      'Foundry',
                      'Gold',
                      'HairStylist',
                      'Iron',
                      'Machinery',
                      'Mechanic',
                      'None',
                      'Painting',
                      'Painting_Furniture',
                      'Painting_Polishing',
                      'Plastic',
                      'Plastic-Manufacturing_Soldering',
                      'Polishing',
                      'Polishing_Soldering',
                      'Soldering',
                      'Steel',
                      'Other',
                    ],
                  ),
                ],
              ),
              _buildPage(
                formKey: _formKeys[1],
                children: [
                  _buildDropdown(
                    label: 'Primary Water Source',
                    fieldKey: 'water_source',
                    options: const [
                      'GroundWater',
                      'GroundWater_ROWater',
                      'GroundWater_TapWater',
                      'ROWater',
                      'TapWater',
                    ],
                  ),
                  _buildDropdown(
                    label: 'Kohl Usage',
                    fieldKey: 'kohl_usage',
                    options: const ['Yes', 'No'],
                  ),
                  _buildDropdown(
                    label: 'Lipstick Usage',
                    fieldKey: 'lipstick_usage',
                    options: const ['Yes', 'No'],
                  ),
                  _buildDropdown(
                    label: 'Sindoor Usage',
                    fieldKey: 'sindoor_usage',
                    options: const ['Yes', 'No'],
                  ),
                ],
              ),
              _buildPage(
                formKey: _formKeys[2],
                children: [
                  _buildDropdown(
                    label: 'Utensils',
                    fieldKey: 'utensils',
                    options: const [
                      'Aluminium',
                      'Aluminium_Ceramic_Steel',
                      'Aluminium_Steel',
                      'Other_Steel',
                      'Steel',
                    ],
                  ),
                  _buildDropdown(
                    label: 'Non-specific Symptoms',
                    fieldKey: 'non_specific_symptoms',
                    options: const [
                      'Headache',
                      'Headache_Lethargy',
                      'Headache_Tiredness',
                      'Lethargy',
                      'Lethargy_Tiredness',
                      'No',
                      'Tiredness',
                    ],
                  ),
                  _buildDropdown(
                    label: 'Gastrointestinal Symptoms',
                    fieldKey: 'gastrointestinal',
                    options: const [
                      'Anorexia',
                      'Anorexia_PainAbdomen',
                      'Constipation',
                      'No',
                      'PainAbdomen',
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Additional Health History',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          label: 'Pica Symptoms',
                          fieldKey: 'pica_symptoms',
                          options: const [
                            'CalciumDeficiency',
                            'IronDeficiency',
                            'No',
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDropdown(
                          label: 'Mother Blood Lead Level',
                          fieldKey: 'mother_bll',
                          options: const [
                            'ND_5',
                            'Between5_10',
                            'Between10_15',
                            'GreaterThan15',
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (_currentPage > 0)
                TextButton.icon(
                  onPressed: _handlePrevious,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
              if (_currentPage == 0)
                TextButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _handleNext,
                icon: Icon(_currentPage == 2 ? Icons.check_circle : Icons.arrow_forward),
                label: Text(_currentPage == 2 ? 'Calculate' : 'Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPage({required GlobalKey<FormState> formKey, required List<Widget> children}) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (final child in children) ...[
              child,
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String fieldKey,
    required List<String> options,
  }) {
    final currentValue = widget.controller.input.values[fieldKey];
    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((value) => DropdownMenuItem<String>(
                value: value,
                child: Text(_humanize(value)),
              ))
          .toList(),
      onChanged: (value) {
        widget.controller.updateField(fieldKey, value);
        setState(() {});
      },
      validator: (value) => value == null || value.isEmpty ? 'Please select an option' : null,
    );
  }

  String _humanize(String value) {
    return value
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'(?<!^)([A-Z])'), ' $1')
        .trim();
  }
}
