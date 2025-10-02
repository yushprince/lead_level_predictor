class LeadInput {
  final Map<String, String?> values;

  LeadInput({required this.values});

  factory LeadInput.empty() {
    return LeadInput(values: {
      'age': null,
      'education': null,
      'occupation': null,
      'take_home_exposure': null,
      'water_source': null,
      'kohl_usage': null,
      'lipstick_usage': null,
      'sindoor_usage': null,
      'utensils': null,
      'non_specific_symptoms': null,
      'gastrointestinal': null,
      'pica_symptoms': null,
      'mother_bll': null,
    });
  }

  LeadInput copyWithField(String key, String? value) {
    final updated = Map<String, String?>.from(values);
    updated[key] = value;
    return LeadInput(values: updated);
  }

  bool get isComplete => values.values.every((value) => value != null && value!.isNotEmpty);

  Map<String, String> asDisplayMap() {
    return values.map((key, value) => MapEntry(
          _formatKey(key),
          value != null ? _formatValue(value) : 'Not selected',
        ));
  }

  String _formatKey(String key) {
    final words = key.split('_').map((word) {
      if (word.toLowerCase() == 'bll') {
        return 'BLL';
      }
      return word[0].toUpperCase() + word.substring(1);
    }).toList();
    return words.join(' ');
  }

  String _formatValue(String value) {
    return value
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'(?<!^)([A-Z])'), ' $1')
        .trim();
  }
}
