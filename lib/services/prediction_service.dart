import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show FlutterError, rootBundle;
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
  List<_RiskBand>? _riskBands;
  Future<void>? _labelsLoadingFuture;

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

    await _ensureLabelConfigLoaded();

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
      return await _attemptInterpreterLoad();
    } on Exception catch (error) {
      debugPrint('Failed to load interpreter: $error');
      throw PredictionException(
        'Unable to load the TensorFlow Lite model. Ensure one of the expected model files exists inside assets/models/.',
      );
    }
  }

  Future<Interpreter> _attemptInterpreterLoad() async {
    final candidates = <String>[
      'models/mother_bll.tflite',
      'models/mother_bll_int8.tflite',
      'models/lead_level_model.tflite',
    ];

    Exception? lastError;

    for (final assetPath in candidates) {
      try {
        final interpreter = await Interpreter.fromAsset(assetPath);
        _interpreter = interpreter;
        return interpreter;
      } on Exception catch (error) {
        lastError = error;
        debugPrint('Failed to load $assetPath: $error');
      }
    }

    throw lastError ?? Exception('No model asset could be loaded.');
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

  Future<void> _ensureLabelConfigLoaded() {
    if (_riskBands != null) {
      return Future.value();
    }
    return _labelsLoadingFuture ??= _loadLabels();
  }

  Future<void> _loadLabels() async {
    try {
      final jsonString = await rootBundle.loadString('models/labels.json');
      final decoded = jsonDecode(jsonString);
      _riskBands = _parseRiskBands(decoded);
    } on FlutterError {
      _riskBands = null;
    } catch (error) {
      debugPrint('Unable to parse labels.json: $error');
      _riskBands = null;
    } finally {
      _labelsLoadingFuture = null;
    }
  }

  List<_RiskBand>? _parseRiskBands(dynamic decoded) {
    if (decoded == null) {
      return null;
    }

    if (decoded is Map<String, dynamic>) {
      final thresholds = _parseDoubleList(decoded['thresholds']);
      final labels = _parseStringList(decoded['labels']);
      if (thresholds != null && labels != null && thresholds.length == labels.length) {
        return List.generate(labels.length, (index) {
          final min = thresholds[index];
          final max = index + 1 < thresholds.length ? thresholds[index + 1] : double.infinity;
          return _RiskBand(label: labels[index], min: min, max: max);
        });
      }

      final ranges = decoded['ranges'];
      final rangeBands = _parseRanges(ranges);
      if (rangeBands != null && rangeBands.isNotEmpty) {
        return rangeBands;
      }
    }

    if (decoded is List) {
      final rangeBands = _parseRanges(decoded);
      if (rangeBands != null && rangeBands.isNotEmpty) {
        return rangeBands;
      }
    }

    return null;
  }

  List<_RiskBand>? _parseRanges(dynamic ranges) {
    if (ranges is! List) {
      return null;
    }

    final bands = <_RiskBand>[];
    for (final entry in ranges) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }

      final label = entry['label']?.toString();
      if (label == null) {
        continue;
      }

      final minValue = entry['min'];
      final maxValue = entry['max'];

      bands.add(
        _RiskBand(
          label: label,
          min: minValue is num ? minValue.toDouble() : null,
          max: maxValue is num ? maxValue.toDouble() : null,
        ),
      );
    }

    return bands.isEmpty ? null : bands;
  }

  List<double>? _parseDoubleList(dynamic value) {
    if (value is! List) {
      return null;
    }
    return value
        .whereType<num>()
        .map((number) => number.toDouble())
        .toList(growable: false);
  }

  List<String>? _parseStringList(dynamic value) {
    if (value is! List) {
      return null;
    }
    return value.map((item) => item.toString()).toList(growable: false);
  }

  String _determineRiskLevel(double bll) {
    final bands = _riskBands;
    if (bands != null && bands.isNotEmpty) {
      for (final band in bands) {
        if (band.contains(bll)) {
          return band.label;
        }
      }
      return bands.last.label;
    }

    if (bll < 5) {
      return 'Low';
    }
    if (bll < 10) {
      return 'Moderate';
    }
    return 'High';
  }
}

class _RiskBand {
  _RiskBand({required this.label, this.min, this.max});

  final String label;
  final double? min;
  final double? max;

  bool contains(double value) {
    final meetsMin = min == null || value >= min!;
    final belowMax = max == null || value < max!;
    return meetsMin && belowMax;
  }
}
