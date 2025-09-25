# Lead Level Predictor

A Flutter application that collects household and lifestyle details to estimate a child's blood lead level. The interface is divided into four clear sections that mirror the requested layout:

1. **Input Information** – Three paginated forms with four fields per page capture all required features from the dataset images (age, education, occupation, take home exposure, water source, cosmetic usage, utensils, symptoms, and maternal BLL).
2. **Results** – Displays the full set of inputs alongside the calculated blood lead level and the derived risk category.
3. **Suggestions** – Generates prevention tips that adapt to the predicted risk level.
4. **Lead Toxicity** – A concise article that educates users about exposure sources, warning signs, and prevention tactics.

The prediction logic is implemented in Dart (`lib/services/prediction_service.dart`) as a placeholder scoring system that can be swapped for an actual trained model when available.

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

## Project Structure

- `lib/main.dart` – App entry point and theme configuration.
- `lib/screens/` – UI for each section (input form, results, suggestions, and lead toxicity article).
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
