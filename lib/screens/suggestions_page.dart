import 'package:flutter/material.dart';

import '../controllers/lead_prediction_controller.dart';
import '../services/suggestions_service.dart';

class SuggestionsPage extends StatelessWidget {
  SuggestionsPage({super.key, required this.controller});

  final LeadPredictionController controller;
  final SuggestionsService _service = SuggestionsService();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {

        if (controller.isLoading) {
          return _buildLoading(textTheme);
        }

        final error = controller.error;
        if (error != null) {
          return _buildError(context, textTheme, error);
        }

        final suggestions = _service.buildSuggestions(controller.result);
        final riskLevel = controller.result?.riskLevel;


        final suggestions = _service.buildSuggestions(controller.result);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Suggestions', style: textTheme.headlineSmall),
            const SizedBox(height: 12),

            if (riskLevel != null)
              _buildRiskSummary(context, riskLevel, textTheme)

            if (controller.result != null && controller.result?.riskLevel != 'Incomplete input')
              _buildRiskSummary(context, controller.result!.riskLevel, textTheme)

            else
              _buildPlaceholderCard(context, textTheme),
            const SizedBox(height: 16),
            ...suggestions.map(
              (tip) => Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(tip),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRiskSummary(BuildContext context, String riskLevel, TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Overview', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Current risk category: $riskLevel',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              _riskDescription(riskLevel),
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard(BuildContext context, TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.health_and_safety_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Enter the exposure details and calculate to receive personalised suggestions.',
                style: textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Preparing suggestions…', style: textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, TextTheme textTheme, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _riskDescription(String riskLevel) {
    switch (riskLevel) {
      case 'Low':
        return 'Lead level appears low. Continue monitoring and maintain protective habits.';
      case 'Moderate':
        return 'Lead level suggests moderate exposure. Follow the steps below to lower the risk.';
      case 'High':
        return 'Lead level is high. Please seek medical attention and act on the guidance immediately.';
      default:
        return 'Complete the assessment to understand the exposure risk.';
    }
  }
}
