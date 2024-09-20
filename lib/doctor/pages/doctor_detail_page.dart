import 'package:clinic_admin/doctor/pages/edit_doctor_page.dart';
import 'package:flutter/material.dart';
import 'package:clinic_admin/doctor/model/doctor_model.dart';
import 'package:intl/intl.dart';

class DoctorDetailPage extends StatelessWidget {
  final DoctorModel doctor;

  DoctorDetailPage({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(doctor.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade800, Colors.blue.shade500],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.person, size: 80, color: Colors.white),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  SizedBox(height: 20),
                  Text('Available Slots',
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 10),
                  _buildAvailableSlotsCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditDoctor(context),
        child: Icon(Icons.edit),
        tooltip: 'Edit Doctor',
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                Icons.medical_services, 'Specialty', doctor.specialty),
            Divider(),
            _buildInfoRow(
                Icons.schedule,
                'Total Available Slots',
                doctor.availableSlots.values
                    .expand((slots) => slots)
                    .length
                    .toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                SizedBox(height: 4),
                Text(value,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableSlotsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: doctor.availableSlots.entries.map((entry) {
            return _buildDaySlots(context, entry.key, entry.value);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDaySlots(BuildContext context, String day, List<String> slots) {
    return ExpansionTile(
      title: Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: slots
              .map((slot) => Chip(
                    label: Text(slot),
                    backgroundColor: Colors.blue.shade100,
                    labelStyle: TextStyle(color: Colors.blue.shade800),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _navigateToEditDoctor(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DoctorEditPage(doctor: doctor)),
    );
    if (result == true) {
      // Doctor was updated, you might want to refresh the details
      // You could use a state management solution or pass a callback to refresh the data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doctor information updated')),
      );
    }
  }
}
