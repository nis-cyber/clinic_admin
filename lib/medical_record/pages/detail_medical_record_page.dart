import 'package:flutter/material.dart';

class DetailedReportPage extends StatelessWidget {
  final Map<String, dynamic> reportData;

  DetailedReportPage({required this.reportData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: const Color.fromARGB(255, 173, 205, 204)!,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 173, 205, 204)!,
              const Color.fromARGB(255, 180, 152, 225)!
            ],
          ),
        ), // Light background color for the page
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                'Doctor Information',
                Icons.local_hospital,
                [
                  _buildDetailRow('Doctor Name',
                      reportData['doctor_name'] ?? 'Unknown Doctor'),
                  _buildDetailRow('Specialty',
                      reportData['speciality'] ?? 'Unknown Specialty'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                'Patient Information',
                Icons.person,
                [
                  _buildDetailRow('Patient Name',
                      reportData['user_name'] ?? 'Unknown Patient'),
                  _buildDetailRow('Phone Number',
                      reportData['user_phone'] ?? 'No Phone Number'),
                  _buildDetailRow('Date of Appointment',
                      reportData['date'] ?? 'Unknown Date'),
                  _buildDetailRow('Time Slot',
                      reportData['time_slot'] ?? 'Unknown Time Slot'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                'Medical Report',
                Icons.description,
                [
                  _buildDetailRow('Diagnosis',
                      reportData['diagnosis'] ?? 'No Diagnosis Info'),
                  _buildDetailRow('Treatment',
                      reportData['treatment'] ?? 'No Treatment Info'),
                  _buildDetailRow('Medications',
                      reportData['medications'] ?? 'No Medications Info'),
                  _buildDetailRow(
                      'Comments', reportData['comments'] ?? 'No Comments'),
                ],
              ),
              const SizedBox(height: 16),
              if (reportData['image_url'] != null)
                _buildImageSection(reportData['image_url']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> content) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: Colors.teal), // Use an accent color for the icon
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal, // Accent color for the title
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Slightly dark color for the label
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54, // Softer color for the value
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String imageUrl) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.image, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Attached Image/Document',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes!)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Error loading image.');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
