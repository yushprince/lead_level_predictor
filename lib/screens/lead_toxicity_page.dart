import 'package:flutter/material.dart';

class LeadToxicityPage extends StatelessWidget {
  const LeadToxicityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Lead Toxicity', style: textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'Lead toxicity occurs when lead builds up in the body over time. Even low levels of lead can impair the nervous system, affect learning, and slow growth in young children.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Common Sources',
          bullets: const [
            'Peeling paint in houses built before 1978 and the dust created when it chips.',
            'Contaminated soil near roads, industrial sites, and informal recycling units.',
            'Lead-glazed pottery, soldered food cans, cosmetics such as kohl and sindoor.',
            'Drinking water travelling through old lead pipes or fittings.',
          ],
          textTheme: textTheme,
        ),
        _buildSection(
          title: 'Health Effects',
          bullets: const [
            'Slowed growth and development in infants and children.',
            'Learning problems, lower IQ, irritability, and behavioural changes.',
            'Abdominal pain, constipation, headaches, and fatigue.',
            'In severe cases, seizures, hearing loss, or anemia.',
          ],
          textTheme: textTheme,
        ),
        _buildSection(
          title: 'Prevention Tips',
          bullets: const [
            'Wash hands, toys, and bottles regularly to remove settled dust.',
            'Use wet mopping instead of dry sweeping to limit dust circulation.',
            'Provide iron, calcium, and vitamin C rich meals to block lead absorption.',
            'Use certified filters and flush taps before using water for drinking or cooking.',
            'Avoid storing food in low-quality metal containers or chipped ceramics.',
          ],
          textTheme: textTheme,
        ),
        _buildSection(
          title: 'When to Seek Help',
          bullets: const [
            'If a child shows persistent symptoms such as abdominal pain, lethargy, or pica.',
            'When living near industries or jobs involving batteries, smelting, or painting.',
            'If previous blood tests indicated elevated lead levels.',
            'Whenever a caregiver suspects exposure to lead dust or flakes at home.',
          ],
          textTheme: textTheme,
        ),
        const SizedBox(height: 12),
        Text(
          'Early identification and intervention drastically lower the long-term impact of lead poisoning. Combine regular screening with the preventive steps above to keep families safe.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> bullets,
    required TextTheme textTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        ...bullets.map(
          (bullet) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(bullet, style: textTheme.bodyMedium)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
