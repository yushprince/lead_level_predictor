import 'package:flutter/material.dart';
import '../models/lead_input.dart';
import '../models/prediction_result.dart';
import '../services/prediction_service.dart';

class LeadPredictionController extends ChangeNotifier {
  LeadInput input = LeadInput.empty();
  PredictionResult? _result;
  bool _hasPredicted = false;

  PredictionResult? get result => _result;
  bool get hasPredicted => _hasPredicted;

  void updateField(String key, String? value) {
    input = input.copyWithField(key, value);
    notifyListeners();
  }

  void predict() {
    _result = PredictionService().predict(input);
    _hasPredicted = true;
    notifyListeners();
  }

  void reset() {
    input = LeadInput.empty();
    _result = null;
    _hasPredicted = false;
    notifyListeners();
  }
}
