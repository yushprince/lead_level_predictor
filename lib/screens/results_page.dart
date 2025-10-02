import 'package:flutter/material.dart';

import '../controllers/lead_prediction_controller.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key, required this.controller});

  final LeadPredictionController controller;

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
          return _buildErrorView(context, textTheme, error);
        }

        final result = controller.result;
        if (result == null) {
          return _buildPlaceholder(textTheme);
        }


        if (!controller.hasPredicted) {
          return _buildPlaceholder(textTheme);
        }

        final result = controller.result;

        final entries = controller.input.asDisplayMap().entries.toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Results', style: textTheme.headlineSmall),
            const SizedBox(height: 12),

            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Predicted Blood Lead Level',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${result.predictedBll.toStringAsFixed(2)} µg/dL',
                      style: textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text('${result.riskLevel} risk'),
                      avatar: const Icon(Icons.warning_amber_outlined),
                    ),
                  ],
                ),
              ),
            ),

            if (result != null && result.riskLevel != 'Incomplete input')
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Predicted Blood Lead Level',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${result.predictedBll.toStringAsFixed(2)} µg/dL',
                        style: textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('${result.riskLevel} risk'),
                        avatar: const Icon(Icons.warning_amber_outlined),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Complete all inputs to generate a prediction.',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
            Text('Your Inputs', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            ...entries.map(
              (entry) => Card(
                child: ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value),
                ),
              ),
            ),
          ],
        );
      },
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
          Text('Calculating prediction…', style: textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, TextTheme textTheme, String message) {
    final entries = controller.input.asDisplayMap().entries.toList();
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Results', style: textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          color: colorScheme.errorContainer,
          elevation: 0,
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
        const SizedBox(height: 24),
        if (entries.isNotEmpty) ...[
          Text('Your Inputs', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          ...entries.map(
            (entry) => Card(
              child: ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value),
              ),
            ),
          ),
        ],
      ],
    );
  }


  Widget _buildPlaceholder(TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pending_actions_outlined, size: 72),
            const SizedBox(height: 16),
            Text(
              'No prediction yet',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete the three input pages and tap Calculate to view the predicted blood lead level.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
