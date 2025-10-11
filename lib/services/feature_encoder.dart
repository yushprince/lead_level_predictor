import 'dart:convert';

import 'package:flutter/services.dart' show FlutterError, rootBundle;

import '../models/lead_input.dart';
import 'prediction_exception.dart';

class FeatureEncoder {
  FeatureEncoder._();

  static final FeatureEncoder _instance = FeatureEncoder._();

  factory FeatureEncoder() => _instance;

  List<String>? _featureOrder;
  Map<String, Map<String, double>>? _encodings;
  List<double>? _means;
  List<double>? _stds;
  Future<void>? _loadingFuture;

  Future<List<double>> encode(LeadInput input) async {
    await _ensureLoaded();

    final order = _featureOrder ?? input.values.keys.toList();
    final encodings = _encodings;

    if (encodings == null || encodings.isEmpty) {
      throw PredictionException(
        'Feature encodings were not found. Ensure assets/models/feature_metadata.json contains an "encodings" section.',
      );
    }

    final features = <double>[];

    for (final key in order) {
      final rawValue = input.values[key];
      if (rawValue == null) {
        throw PredictionException('Missing value for "$key".');
      }

      final mapping = encodings[key];
      if (mapping == null) {
        throw PredictionException(
          'No encoding defined for feature "$key". Update feature_metadata.json to match your preprocessing.',
        );
      }

      final encoded = mapping[rawValue];
      if (encoded == null) {
        throw PredictionException(
          'Value "$rawValue" is not mapped for feature "$key". Update feature_metadata.json accordingly.',
        );
      }

      features.add(encoded);
    }

    if (_means != null && _stds != null &&
        _means!.length == features.length &&
        _stds!.length == features.length) {
      for (var i = 0; i < features.length; i++) {
        final std = _stds![i];
        if (std == 0) continue;
        features[i] = (features[i] - _means![i]) / std;
      }
    }

    return features;
  }

  Future<void> _ensureLoaded() {
    if (_featureOrder != null && _encodings != null) {
      return Future.value();
    }

    return _loadingFuture ??= _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      await _loadPrimaryMetadata();
      await _loadFeatureOrderOverride();
      await _loadScalerMetadata();
      _featureOrder ??= LeadInput.empty().values.keys.toList();
    } on FlutterError {
      throw PredictionException(
        'Feature metadata file not found. Add assets/models/feature_metadata.json generated from your training pipeline.',
      );
    } on FormatException catch (error) {
      throw PredictionException('Feature metadata is not valid JSON: ${error.message}');
    } catch (error) {
      throw PredictionException('Unable to load feature metadata: $error');
    } finally {
      _loadingFuture = null;
    }
  }

  Future<void> _loadPrimaryMetadata() async {
    final jsonString = await rootBundle.loadString('models/feature_metadata.json');
    final decoded = jsonDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('feature_metadata.json must contain an object.');
    }

    final orderRaw = decoded['featureOrder'];
    if (orderRaw is List) {
      _featureOrder = orderRaw.map((e) => e.toString()).toList();
    }

    final encodingsRaw = decoded['encodings'];
    if (encodingsRaw is Map<String, dynamic>) {
      _encodings = encodingsRaw.map((key, value) {
        final valueMap = value as Map<String, dynamic>;
        return MapEntry(
          key,
          valueMap.map((option, encoding) => MapEntry(option, (encoding as num).toDouble())),
        );
      });
    }

    final normalization = decoded['normalization'];
    if (normalization is Map<String, dynamic>) {
      final meanRaw = normalization['mean'];
      final stdRaw = normalization['std'] ?? normalization['scale'];
      if (meanRaw is List && stdRaw is List && meanRaw.length == stdRaw.length) {
        _means = meanRaw.map((value) => (value as num).toDouble()).toList();
        _stds = stdRaw.map((value) => (value as num).toDouble()).toList();
      }
    }

    if (_encodings == null || _encodings!.isEmpty) {
      throw const FormatException('feature_metadata.json must include an "encodings" object.');
    }

  }

  Future<void> _loadFeatureOrderOverride() async {
    final decoded = await _tryLoadJson('models/feature_order.json');
    if (decoded is List && decoded.isNotEmpty) {
      _featureOrder = decoded.map((e) => e.toString()).toList();
    }
  }

  Future<void> _loadScalerMetadata() async {
    final needsScaler = _means == null || _stds == null;
    if (!needsScaler) {
      return;
    }

    final decoded = await _tryLoadJson('models/scaler.json');
    if (decoded is! Map<String, dynamic>) {
      return;
    }

    final meanRaw = decoded['mean'] ?? decoded['means'];
    final stdRaw = decoded['std'] ?? decoded['scale'] ?? decoded['scales'];

    if (meanRaw is List && stdRaw is List && meanRaw.length == stdRaw.length) {
      _means = meanRaw.map((value) => (value as num).toDouble()).toList();
      _stds = stdRaw.map((value) => (value as num).toDouble()).toList();
    }
  }

  Future<dynamic> _tryLoadJson(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      return jsonDecode(jsonString);
    } on FlutterError {
      return null;
    }
  }
}
