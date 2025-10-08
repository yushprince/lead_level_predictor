import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/lead_input.dart';
import '../models/prediction_result.dart';
import 'feature_encoder.dart';
import 'prediction_exception.dart';

class PredictionService {
  PredictionService._();

  static final PredictionService _instance = PredictionService._();

  factory PredictionService() => _instance;

  Interpreter? _interpreter;

  Future<PredictionResult> predict(LeadInput input) async {
    if (!input.isComplete) {
      throw PredictionException('Please complete all fields before calculating the prediction.');
    }

    final interpreter = await _loadInterpreter();
    final features = await FeatureEncoder().encode(input);

    final inputTensor = interpreter.getInputTensor(0);
    final inputShape = inputTensor.shape;
    final expectedFeatureLength = inputShape.isNotEmpty ? inputShape.last : features.length;

    if (expectedFeatureLength != features.length) {
      throw PredictionException(
        'The model expects $expectedFeatureLength features but ${features.length} were provided. Update feature_metadata.json to match your training pipeline.',
      );
    }

    final outputTensor = interpreter.getOutputTensor(0);
    final outputShape = outputTensor.shape;

    final inputBuffer = [features];
    final outputBuffer = List.generate(
      outputShape.isNotEmpty ? outputShape.first : 1,
      (_) => List.filled(outputShape.length > 1 ? outputShape[1] : 1, 0.0),
    );

    interpreter.run(inputBuffer, outputBuffer);

    final predictedValue = _extractFirstValue(outputBuffer);
    final sanitizedValue = predictedValue.isFinite ? predictedValue : 0.0;
    final roundedValue = double.parse(sanitizedValue.toStringAsFixed(2));

    return PredictionResult(
      predictedBll: roundedValue,
      riskLevel: _determineRiskLevel(roundedValue),
    );
  }

  Future<Interpreter> _loadInterpreter() async {
    if (_interpreter != null) {
      return _interpreter!;
    }

    try {
      _interpreter = await Interpreter.fromAsset('models/lead_level_model.tflite');
      return _interpreter!;
    } on Exception catch (error) {
      debugPrint('Failed to load interpreter: $error');
      throw PredictionException(
        'Unable to load the TensorFlow Lite model. Replace assets/models/lead_level_model.tflite with your trained model file.',
      );
    }
  }

  double _extractFirstValue(dynamic tensorOutput) {
    if (tensorOutput is List && tensorOutput.isNotEmpty) {
      return _extractFirstValue(tensorOutput.first);
    }
    if (tensorOutput is num) {
      return tensorOutput.toDouble();
    }
    throw PredictionException('Unexpected model output format: ${tensorOutput.runtimeType}');
  }

  String _determineRiskLevel(double bll) {
    if (bll < 5) {
      return 'Low';
    }
    if (bll < 10) {
      return 'Moderate';
    }
    return 'High';
  }
}
