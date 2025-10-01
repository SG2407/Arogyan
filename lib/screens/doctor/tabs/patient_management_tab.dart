import 'package:flutter/material.dart';
import 'package:aarogyan/widgets/patient_card.dart';

class PatientManagementTab extends StatelessWidget {
  const PatientManagementTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search patients...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        for (var i = 1; i <= 10; i++)
          PatientCard(
            name: 'Patient $i',
            condition: 'General Checkup',
            lastVisit: 'Yesterday',
            onTap: () {},
          ),
      ],
    );
  }
}
