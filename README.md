# Lead Level Predictor

A Flutter application that collects household and lifestyle details to estimate a child's blood lead level. The interface is divided into four clear sections that mirror the requested layout:

1. **Input Information** – Three paginated forms with four fields per page capture all required categorical features from the dataset (age, education, occupation, take-home exposure, water source, cosmetic usage, utensils, and symptom groups).
2. **Results** – Displays the full set of inputs alongside the predicted blood lead level and the derived risk category.
3. **Suggestions** – Generates prevention tips that adapt to the predicted risk level.
4. **Lead Toxicity** – A concise article that educates users about exposure sources, warning signs, and prevention tactics.

The UI now talks to a TensorFlow Lite interpreter through `PredictionService` so that you can plug in a real trained model without touching the presentation layer.

## How the bundled prediction pipeline works

1. The paginated form populates a `LeadInput` object with the 12 categorical answers the user selects. Each field is required, so the controller blocks prediction until the form is complete.
2. `LeadPredictionController.predict()` forwards the completed `LeadInput` to `PredictionService`, showing a loading state in the UI while the async call runs.
3. `PredictionService` lazily loads `assets/models/lead_level_model.tflite` into a TensorFlow Lite `Interpreter`, then calls `FeatureEncoder.encode(...)` to transform the human-readable selections into the numeric values defined in `assets/models/feature_metadata.json`.
4. The encoded feature vector is fed through the interpreter. The model returns a single floating-point value that represents the estimated blood lead level (BLL) in micrograms per decilitre (µg/dL).
5. The service rounds the raw prediction to two decimal places and tags it with a risk band (Low/Moderate/High) using simple threshold logic (<5, <10, ≥10 µg/dL). The `PredictionResult` object propagates this data back to the controller, which updates the Results and Suggestions tabs.

Because BLL is now the predicted output instead of an input, the dropdowns never request it from the user—any attempt to submit the form without a full set of categorical answers raises a validation error before the model runs.

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
| `assets/models/mother_bll.tflite` / `assets/models/mother_bll_int8.tflite` | The exported TensorFlow Lite model (float32 or int8). The app will try to load `mother_bll.tflite` first, fall back to the int8 version, and finally `lead_level_model.tflite` for backward compatibility. |
| `assets/models/feature_metadata.json` | Describes the categorical encodings applied during training. Generated once from the preprocessing code so Dart can reproduce the exact transformations. |
| `assets/models/feature_order.json` *(optional)* | Overrides the feature order if it is not embedded in `feature_metadata.json`. |
| `assets/models/scaler.json` *(optional)* | Stores the `mean`/`std` (or `scale`) vectors so the Flutter encoder can mimic your preprocessing normalisation. |
| `assets/models/labels.json` *(optional)* | Lists the risk bands or thresholds that map the predicted BLL to a textual category surfaced in the UI. |

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

## Preparing a Python model for integration

If you already trained a model in Python, follow these steps to package it for the Flutter app. The process assumes a TensorFlow/Keras workflow, but the same ideas apply to other frameworks that can export TensorFlow Lite graphs.

1. **Align the training columns with the UI** – Remove the blood-lead-level target (BLL) from the feature matrix and make sure every remaining column corresponds to one of the 12 dropdowns in the app (`age`, `education`, `occupation`, `take_home_exposure`, `water_source`, `kohl_usage`, `lipstick_usage`, `sindoor_usage`, `utensils`, `non_specific_symptoms`, `gastrointestinal`, `pica_symptoms`).
2. **Encode categories with stable IDs** – Convert each string choice to the numeric value you want to persist in `feature_metadata.json`. The easiest approach is to build `LabelEncoder`-style lookups and dump them to JSON after training so the same mapping is available in Flutter.
3. **Train and save the TensorFlow model** – Train your network on the encoded features and raw BLL target. Save the resulting model (e.g., `model.save("./export/lead_bll_model")`).
4. **Export the metadata JSON** – Serialize the feature order and encoding tables you used into the following structure:
   ```python
   import json

   feature_order = [
       "age",
       "education",
       "occupation",
       "take_home_exposure",
       "water_source",
       "kohl_usage",
       "lipstick_usage",
       "sindoor_usage",
       "utensils",
       "non_specific_symptoms",
       "gastrointestinal",
       "pica_symptoms",
   ]

   encodings = {feature: mapping for feature, mapping in your_label_tables.items()}

   with open("feature_metadata.json", "w") as fp:
       json.dump({"featureOrder": feature_order, "encodings": encodings}, fp, indent=2)
   ```
5. **Convert to TensorFlow Lite** – Use the TFLite converter on the SavedModel directory:
   ```python
   import tensorflow as tf

   converter = tf.lite.TFLiteConverter.from_saved_model("./export/lead_bll_model")
   tflite_model = converter.convert()

   with open("lead_level_model.tflite", "wb") as f:
       f.write(tflite_model)
   ```
6. **Copy the artefacts into Flutter** – Replace the placeholder assets with your exported files (for example `mother_bll.tflite`, `feature_metadata.json`, `feature_order.json`, `scaler.json`, and `labels.json`), then run `flutter pub get` followed by `flutter run`. The app will automatically pick up the new artefacts at the next launch.

### Installing your `.tflite` file in this repository

Once you have exported the trained model and metadata, drop them into the Flutter project like this:

1. Copy the TensorFlow Lite file into place:
   ```bash
   cp /path/to/your/mother_bll.tflite assets/models/
   ```
2. Copy the matching metadata JSON (generated from your preprocessing code) into the same folder:
   ```bash
   cp /path/to/your/feature_metadata.json assets/models/
   ```
3. (Optional) Drop in additional helpers if your pipeline produced them:
   ```bash
   cp /path/to/your/feature_order.json assets/models/
   cp /path/to/your/scaler.json assets/models/
   cp /path/to/your/labels.json assets/models/
   ```
4. (Optional but recommended) Clean any previously cached assets when swapping models:
   ```bash
   flutter clean
   ```
5. Fetch packages and rebuild the app so the new artefacts are bundled:
   ```bash
   flutter pub get
   flutter run
   ```

If `flutter run` reports that the model or metadata cannot be loaded, double-check that the filenames exactly match the ones above and that your metadata includes every dropdown option exposed in the UI.

Because the Flutter layer now expects BLL to be predicted, not entered, any attempt to keep a maternal BLL field in `feature_metadata.json` will cause a mismatch error during inference.

If the encoder or model fails to load, the UI surfaces the error in the Results and Suggestions tabs so the user understands what went wrong.

## Build troubleshooting

Certain versions of the native tooling bundled with Flutter can prevent the TensorFlow Lite dependency from compiling. If you hit build failures, try the following fixes:

- **Android NDK mismatch** – `tflite_flutter` 0.10.x requires Android NDK `27.0.12077973`. Add the version override inside `android/app/build.gradle.kts`:
  ```kotlin
  android {
      ndkVersion = "27.0.12077973"
  }
  ```
  After editing the file, sync Gradle (or rerun `flutter run`) so the toolchain downloads the new NDK.

- **`UnmodifiableUint8ListView` compilation error** – This comes from `tflite_flutter` 0.10.4 on Flutter channels that still ship an older Dart SDK. The project now pins `tflite_flutter` to `0.10.3` in `pubspec.yaml`. If your `pubspec.lock` already captured 0.10.4, run:
  ```bash
  flutter pub upgrade tflite_flutter
  flutter pub get
  ```
  The downgraded package avoids the newer API and restores compatibility with stable builds prior to Flutter 3.24.

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
