import '../models/prediction_result.dart';

class SuggestionsService {
  List<String> buildSuggestions(PredictionResult? result) {
    if (result == null || result.riskLevel == 'Incomplete input') {
      return const [
        'Complete the assessment to view tailored suggestions.',
      ];
    }

    switch (result.riskLevel) {
      case 'Low':
        return const [
          'Continue regular monitoring of potential lead sources at home.',
          'Maintain a balanced diet rich in calcium and iron to block lead absorption.',
          'Schedule periodic re-testing if there is ongoing exposure.',
        ];
      case 'Moderate':
        return const [
          'Increase cleaning frequency of floors and surfaces to remove lead dust.',
          'Encourage hand-washing before meals and after outdoor play.',
          'Use certified water filters and flush taps before use.',
          'Consult a healthcare provider for targeted blood lead follow-up.',
        ];
      case 'High':
      default:
        return const [
          'Seek immediate medical advice for chelation eligibility and follow-up testing.',
          'Remove or isolate known lead sources such as peeling paint, contaminated soil, or lead-glazed utensils.',
          'Provide iron, calcium, and vitamin C rich meals to reduce lead absorption.',
          'Inform local public health authorities about potential community exposure.',
        ];
    }
  }
}
