import 'package:flutter/material.dart';


import '../models/lead_input.dart';
import '../models/prediction_result.dart';
import '../services/prediction_exception.dart';
import '../services/prediction_service.dart';

class LeadPredictionController extends ChangeNotifier {
  LeadPredictionController({PredictionService? service})
      : _service = service ?? PredictionService();

  final PredictionService _service;

  LeadInput input = LeadInput.empty();
  PredictionResult? _result;
  bool _isLoading = false;
  String? _error;

  PredictionResult? get result => _result;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateField(String key, String? value) {
    input = input.copyWithField(key, value);
    _error = null;
    notifyListeners();
  }

  Future<void> predict() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prediction = await _service.predict(input);
      _result = prediction;
    } on PredictionException catch (error) {
      _error = error.message;
      _result = null;
    } catch (error) {
      _error = 'Something went wrong while running the prediction: $error';
      _result = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

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

    _isLoading = false;
    _error = null;

    _hasPredicted = false;

    notifyListeners();
  }
}
