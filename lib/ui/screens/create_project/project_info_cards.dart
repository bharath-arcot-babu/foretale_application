import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final String projectName;
  final DateTime startDate;
  final String status;

  const ProjectCard({super.key, 
    required this.projectName,
    required this.startDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projectName,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              "Start Date: ${startDate.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              "Status: $status",
              style: TextStyle(
                  color: status == "Open" ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
