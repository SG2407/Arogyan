import 'package:flutter/material.dart';
import 'package:aarogyan/widgets/processing_history_card.dart';

class OcrProcessingTab extends StatelessWidget {
  const OcrProcessingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Upload Document',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.cloud_upload),
                  label: Text('Select Document'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Processing History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 1; i <= 5; i++)
                ProcessingHistoryCard(
                  title: 'Medical Report $i',
                  date: 'Today',
                  status: i % 3 == 0 ? 'Processing' : 'Completed',
                  icon: Icons.description,
                  onTap: () {},
                ),
            ],
          ),
        ),
      ],
    );
  }
}
