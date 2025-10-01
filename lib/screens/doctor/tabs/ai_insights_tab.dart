import 'package:flutter/material.dart';

class AiInsightsTab extends StatelessWidget {
  const AiInsightsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInsightCard(
          context,
          title: 'Patient Analytics',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricRow('Total Patients', '120'),
              _buildMetricRow('New This Week', '8'),
              _buildMetricRow('Average Age', '45'),
              _buildMetricRow('Most Common Condition', 'Hypertension'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          context,
          title: 'Treatment Effectiveness',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricRow('Success Rate', '85%'),
              _buildMetricRow('Avg. Recovery Time', '2.5 weeks'),
              _buildMetricRow('Follow-ups Required', '3'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInsightCard(
          context,
          title: 'Workload Distribution',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricRow('Appointments/Day', '8'),
              _buildMetricRow('Reports Processed', '25'),
              _buildMetricRow('Avg. Consultation Time', '20 min'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
