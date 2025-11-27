import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aarogyan/providers/language_provider.dart';
import 'package:aarogyan/services/localization_service.dart';
import 'package:aarogyan/widgets/dashboard_tile.dart';

class PatientHomeTab extends StatelessWidget {
  const PatientHomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, _) {
        final lang = langProvider.languageCode;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get('howAreYou', lang),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.get('quickAccess', lang),
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
                    title: AppStrings.get('emotionalDiary', lang),
                    subtitle: AppStrings.get('emotionalDiaryDesc', lang),
                    icon: Icons.book,
                    onTap: () => context.push('/emotional-diary'),
                  ),
                  DashboardTile(
                    title: AppStrings.get('moodTracker', lang),
                    subtitle: AppStrings.get('moodTrackerDesc', lang),
                    icon: Icons.mood,
                    onTap: () => context.push('/mood-tracker'),
                  ),
                  DashboardTile(
                    title: AppStrings.get('documents', lang),
                    subtitle: AppStrings.get('documentsDesc', lang),
                    icon: Icons.description,
                    onTap: () => context.push('/document-analysis'),
                  ),
                  DashboardTile(
                    title: AppStrings.get('aiAssistant', lang),
                    subtitle: AppStrings.get('aiAssistantDesc', lang),
                    icon: Icons.chat,
                    onTap: () => context.push('/ai-assistant'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.get('healthAgents', lang),
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
                    title: AppStrings.get('dietAgent', lang),
                    subtitle: AppStrings.get('dietAgentDesc', lang),
                    icon: Icons.restaurant,
                    onTap: () => context.go('/diet-agent'),
                  ),
                  DashboardTile(
                    title: AppStrings.get('fitnessAgent', lang),
                    subtitle: AppStrings.get('fitnessCoacDesc', lang),
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
                        AppStrings.get('yourNextAppointment', lang),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.medical_services),
                        ),
                        title: Text(AppStrings.get('drSmith', lang)),
                        subtitle: Text(AppStrings.get('generalCheckup', lang)),
                        trailing: Text(
                          '${AppStrings.get('tomorrow', lang)}\n10:00 AM',
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
      },
    );
  }
}
