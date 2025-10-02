# Lead Level Predictor

A Flutter application that collects household and lifestyle details to estimate a child's blood lead level. The interface is divided into four clear sections that mirror the requested layout:


1. **Input Information** – Three paginated forms with four fields per page capture all required features from the dataset (age, education, occupation, take-home exposure, water source, cosmetic usage, utensils, symptoms, and maternal BLL).
2. **Results** – Displays the full set of inputs alongside the predicted blood lead level and the derived risk category.
3. **Suggestions** – Generates prevention tips that adapt to the predicted risk level.
4. **Lead Toxicity** – A concise article that educates users about exposure sources, warning signs, and prevention tactics.

The UI now talks to a TensorFlow Lite interpreter through `PredictionService` so that you can plug in a real trained model without touching the presentation layer.

1. **Input Information** – Three paginated forms with four fields per page capture all required features from the dataset images (age, education, occupation, take home exposure, water source, cosmetic usage, utensils, symptoms, and maternal BLL).
2. **Results** – Displays the full set of inputs alongside the calculated blood lead level and the derived risk category.
3. **Suggestions** – Generates prevention tips that adapt to the predicted risk level.
4. **Lead Toxicity** – A concise article that educates users about exposure sources, warning signs, and prevention tactics.

The prediction logic is implemented in Dart (`lib/services/prediction_service.dart`) as a placeholder scoring system that can be swapped for an actual trained model when available.
 main

## Getting Started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) and ensure that `flutter doctor` passes.
2. (First-time setup only) Generate the native platform folders by running `flutter create .` in the project root. Existing Dart files will be preserved.
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app on an emulator or device:
   ```bash
   flutter run
   ```


## Model Integration Workflow

`PredictionService` loads the TensorFlow Lite model once, encodes the form answers, and performs synchronous inference on the device. To make the pipeline work with your trained artefacts, update the files in `assets/models/`:

| File | Purpose |
| --- | --- |
| `assets/models/lead_level_model.tflite` | The exported TensorFlow Lite model. Replace the placeholder file with the real binary produced by your training notebook/script. |
| `assets/models/feature_metadata.json` | Describes the order of the features, the categorical encodings applied during training, and (optionally) normalisation statistics. Generated once from the preprocessing code so Dart can reproduce the exact transformations. |

The provided `feature_metadata.json` contains ordinal encodings that match the dropdown options in the UI. Adjust it to mirror your real preprocessing steps:

```json
{
  "featureOrder": ["age", "education", "occupation", ...],
  "encodings": {
    "age": {"Less than or Equal to 30": 0.0, "Greater than 30": 1.0},
    "occupation": {"Housewife": 0.0, "Agriculture": 1.0, "AutoDriver": 2.0, ...}
  },
  "normalization": {
    "mean": [/* optional per-feature mean */],
    "std": [/* optional per-feature std-dev */]
  }
}
```

- **Feature order** must match the input tensor expected by the model.
- **Encodings** map each dropdown choice to the numeric value used during training (one-hot encodings can be represented by multiple numeric columns in the order array).
- **Normalization** is optional; when provided, the controller applies `(value - mean) / std` before inference.

If the encoder or model fails to load, the UI surfaces the error in the Results and Suggestions tabs so the user understands what went wrong.
main
## Project Structure

- `lib/main.dart` – App entry point and theme configuration.
- `lib/screens/` – UI for each section (input form, results, suggestions, and lead toxicity article).

- `lib/controllers/` – State management for the collected inputs, asynchronous prediction flow, and error handling.
- `lib/models/` – Data classes for the form inputs and prediction output.
- `lib/services/` – TensorFlow Lite integration, feature encoding, and contextual suggestions.
- `assets/models/` – TensorFlow Lite model plus encoding metadata consumed at runtime.

## Notes

- The suggestion content and lead-toxicity article provide general guidance and should be reviewed by subject matter experts before production use.
- `flutter pub get` / `flutter run` will fail until you replace the placeholder `lead_level_model.tflite` with a valid TFLite binary generated from your training pipeline.

- `lib/controllers/` – Simple state management for the collected inputs and prediction results.
- `lib/models/` – Data classes for the form inputs and prediction output.
- `lib/services/` – Mock prediction logic and contextual suggestions.

## Replacing the Mock Model

To integrate a real trained model:

1. Expose the model through a Dart/Flutter compatible API (for example, a TensorFlow Lite interpreter or a REST endpoint).
2. Update `PredictionService.predict` to call the real inference code and convert the response to `PredictionResult`.
3. Adjust the suggestion thresholds or categories as needed to match the model's output scale.

## Notes

- The current implementation uses dropdown inputs for categorical features to mirror the dataset fields exactly.
- The suggestion content and lead toxicity article provide general guidance and should be reviewed by subject matter experts before production use.
main
