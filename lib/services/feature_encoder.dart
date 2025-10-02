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
      final jsonString = await rootBundle.loadString('models/feature_metadata.json');
      final Map<String, dynamic> decoded = jsonDecode(jsonString) as Map<String, dynamic>;

      final orderRaw = decoded['featureOrder'];
      if (orderRaw is List) {
        _featureOrder = orderRaw.map((e) => e.toString()).toList();
      } else {
        _featureOrder = LeadInput.empty().values.keys.toList();
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
        final stdRaw = normalization['std'];
        if (meanRaw is List && stdRaw is List && meanRaw.length == stdRaw.length) {
          _means = meanRaw.map((value) => (value as num).toDouble()).toList();
          _stds = stdRaw.map((value) => (value as num).toDouble()).toList();
        }
      }
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
}
