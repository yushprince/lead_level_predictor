import '../models/lead_input.dart';
import '../models/prediction_result.dart';

class PredictionService {
  PredictionResult predict(LeadInput input) {
    if (!input.isComplete) {
      return PredictionResult(predictedBll: 0, riskLevel: 'Incomplete input');
    }

    double score = 1.5; // base score

    score += _scoreFor('age', input.values['age']);
    score += _scoreFor('education', input.values['education']);
    score += _scoreFor('occupation', input.values['occupation']);
    score += _scoreFor('take_home_exposure', input.values['take_home_exposure']);
    score += _scoreFor('water_source', input.values['water_source']);
    score += _scoreFor('kohl_usage', input.values['kohl_usage']);
    score += _scoreFor('lipstick_usage', input.values['lipstick_usage']);
    score += _scoreFor('sindoor_usage', input.values['sindoor_usage']);
    score += _scoreFor('utensils', input.values['utensils']);
    score += _scoreFor('non_specific_symptoms', input.values['non_specific_symptoms']);
    score += _scoreFor('gastrointestinal', input.values['gastrointestinal']);
    score += _scoreFor('pica_symptoms', input.values['pica_symptoms']);
    score += _scoreFor('mother_bll', input.values['mother_bll']);

    final double predictedLevel = double.parse(score.toStringAsFixed(2));
    final String riskLevel;

    if (predictedLevel < 5) {
      riskLevel = 'Low';
    } else if (predictedLevel < 10) {
      riskLevel = 'Moderate';
    } else {
      riskLevel = 'High';
    }

    return PredictionResult(predictedBll: predictedLevel, riskLevel: riskLevel);
  }

  double _scoreFor(String key, String? value) {
    if (value == null) return 0;
    final Map<String, Map<String, double>> scoreTable = {
      'age': {
        'Less than or Equal to 30': 1.0,
        'Greater than 30': 1.8,
      },
      'education': {
        'College_HigherDegree': 0.8,
        'NoCollege': 1.2,
      },
      'occupation': {
        'Housewife': 0.5,
        'Agriculture': 1.2,
        'AutoDriver': 1.5,
        'AutoDriver_Ceramics': 1.6,
        'AutoRepair': 1.7,
        'Batteries': 2.2,
        'Batteries_Lock': 2.0,
        'Ceramics': 1.8,
        'Construction_Furniture': 1.9,
        'Construction_Painting_Plastic_Polishing': 2.1,
        'Driver': 1.5,
        'Electrician': 1.6,
        'Engineer': 1.1,
        'Factory': 2.0,
        'Foundry': 2.2,
        'Gold': 2.3,
        'HairStylist': 1.4,
        'Iron': 2.0,
        'Machinery': 1.9,
        'Mechanic': 1.8,
        'None': 0.3,
        'Painting': 2.0,
        'Painting_Furniture': 1.9,
        'Painting_Polishing': 2.2,
        'Plastic': 2.1,
        'Plastic-Manufacturing_Soldering': 2.3,
        'Polishing': 1.8,
        'Polishing_Soldering': 2.1,
        'Soldering': 2.0,
        'Steel': 1.7,
        'Other': 1.0,
      },
      'take_home_exposure': {
        'Agriculture': 1.0,
        'AutoDriver': 1.4,
        'AutoDriver_Ceramics': 1.5,
        'AutoRepair': 1.6,
        'Batteries': 2.4,
        'Batteries_Lock': 2.2,
        'Ceramics': 1.7,
        'Construction_Furniture': 1.8,
        'Construction_Painting_Plastic_Polishing': 2.0,
        'Driver': 1.3,
        'Electrician': 1.5,
        'Engineer': 1.1,
        'Factory': 2.1,
        'Foundry': 2.3,
        'Gold': 2.4,
        'HairStylist': 1.3,
        'Iron': 2.0,
        'Machinery': 1.8,
        'Mechanic': 1.9,
        'None': 0.4,
        'Painting': 2.0,
        'Painting_Furniture': 1.9,
        'Painting_Polishing': 2.2,
        'Plastic': 2.0,
        'Plastic-Manufacturing_Soldering': 2.4,
        'Polishing': 1.9,
        'Polishing_Soldering': 2.2,
        'Soldering': 2.1,
        'Steel': 1.6,
        'Other': 1.0,
      },
      'water_source': {
        'GroundWater': 1.5,
        'GroundWater_ROWater': 1.2,
        'GroundWater_TapWater': 1.4,
        'ROWater': 0.6,
        'TapWater': 1.1,
      },
      'kohl_usage': {
        'Yes': 1.4,
        'No': 0.6,
      },
      'lipstick_usage': {
        'Yes': 1.1,
        'No': 0.5,
      },
      'sindoor_usage': {
        'Yes': 1.2,
        'No': 0.4,
      },
      'utensils': {
        'Aluminium': 0.9,
        'Aluminium_Ceramic_Steel': 0.8,
        'Aluminium_Steel': 0.9,
        'Other_Steel': 0.7,
        'Steel': 0.6,
      },
      'non_specific_symptoms': {
        'Headache': 1.2,
        'Headache_Lethargy': 1.6,
        'Headache_Tiredness': 1.4,
        'Lethargy': 1.1,
        'Lethargy_Tiredness': 1.3,
        'No': 0.4,
        'Tiredness': 1.0,
      },
      'gastrointestinal': {
        'Anorexia': 1.3,
        'Anorexia_PainAbdomen': 1.8,
        'Constipation': 1.2,
        'No': 0.5,
        'PainAbdomen': 1.4,
      },
      'pica_symptoms': {
        'CalciumDeficiency': 1.6,
        'IronDeficiency': 1.8,
        'No': 0.6,
      },
      'mother_bll': {
        'ND_5': 0.5,
        'Between5_10': 1.3,
        'Between10_15': 2.0,
        'GreaterThan15': 2.8,
      },
    };

    final valueScores = scoreTable[key];
    if (valueScores == null) return 0;
    return valueScores[value] ?? 0.8;
  }
}
