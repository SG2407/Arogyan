import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aarogyan/widgets/dashboard_tile.dart';

class PatientHomeTab extends StatelessWidget {
  final Function(int)? onTabSelected;

  const PatientHomeTab({Key? key, this.onTabSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Access',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              DashboardTile(
                title: 'Emotional Diary',
                subtitle: 'Record your feelings',
                icon: Icons.book,
                onTap: () => onTabSelected?.call(1),
              ),
              DashboardTile(
                title: 'Mood Tracker',
                subtitle: 'Track your progress',
                icon: Icons.mood,
                onTap: () => onTabSelected?.call(2),
              ),
              DashboardTile(
                title: 'Documents',
                subtitle: 'Store medical records',
                icon: Icons.description,
                onTap: () => onTabSelected?.call(3),
              ),
              DashboardTile(
                title: 'AI Assistant',
                subtitle: 'Get guidance',
                icon: Icons.chat,
                onTap: () => onTabSelected?.call(4),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Health Agents',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              DashboardTile(
                title: 'Diet Agent',
                subtitle: 'Personalized diet plans',
                icon: Icons.restaurant,
                onTap: () => context.go('/diet-agent'),
              ),
              DashboardTile(
                title: 'Fitness Coach',
                subtitle: 'Exercise routines',
                icon: Icons.fitness_center,
                onTap: () => context.go('/fitness-agent'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Next Appointment',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.medical_services),
                    ),
                    title: Text('Dr. Smith'),
                    subtitle: Text('General Checkup'),
                    trailing: Text(
                      'Tomorrow\n10:00 AM',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
