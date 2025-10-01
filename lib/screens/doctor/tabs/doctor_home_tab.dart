import 'package:flutter/material.dart';
import 'package:aarogyan/widgets/dashboard_tile.dart';

class DoctorHomeTab extends StatelessWidget {
  const DoctorHomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, Dr. Smith',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome to your dashboard',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              DashboardTile(
                title: 'Patients',
                subtitle: '12 Appointments Today',
                icon: Icons.people,
                onTap: () {},
              ),
              DashboardTile(
                title: 'OCR Scans',
                subtitle: '3 Pending Reports',
                icon: Icons.document_scanner,
                onTap: () {},
              ),
              DashboardTile(
                title: 'AI Assistant',
                subtitle: 'Get Quick Insights',
                icon: Icons.chat,
                onTap: () {},
              ),
              DashboardTile(
                title: 'Analytics',
                subtitle: 'View Patient Stats',
                icon: Icons.insights,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.notifications),
                  ),
                  title: Text('New patient report uploaded'),
                  subtitle: Text('2 hours ago'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
