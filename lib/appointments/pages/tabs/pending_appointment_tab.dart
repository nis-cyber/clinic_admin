import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AllPendingAppointmentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointment_pending')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No pending appointments.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var appointmentData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                String appointmentId = snapshot.data!.docs[index].id;
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointmentData['doctor_name'],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appointmentData['doctor_specialty'],
                          style:
                              TextStyle(fontSize: 14, color: Colors.teal[500]),
                        ),
                        const Divider(height: 20, thickness: 1),
                        _buildInfoRow(Icons.person, 'Patient',
                            appointmentData['user_name']),
                        _buildInfoRow(Icons.phone, 'Phone',
                            appointmentData['user_phone']),
                        _buildInfoRow(
                            Icons.calendar_today,
                            'Date',
                            DateFormat('MMMM d, yyyy').format(
                                DateTime.parse(appointmentData['date']))),
                        _buildInfoRow(Icons.access_time, 'Time',
                            appointmentData['time_slot']),
                        _buildInfoRow(Icons.description, 'Document',
                            appointmentData['document']),
                        _buildInfoRow(Icons.info_outline, 'Status',
                            appointmentData['status']),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              onPressed: () => _acceptAppointment(
                                  appointmentId, appointmentData),
                              label: 'Accept',
                              color: Colors.teal,
                            ),
                            _buildActionButton(
                              onPressed: () =>
                                  _rejectAppointment(appointmentId),
                              label: 'Reject',
                              color: Colors.red[300]!,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.teal[300]),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style:
                TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required VoidCallback onPressed,
      required String label,
      required Color color}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  Future<void> _acceptAppointment(
      String appointmentId, Map<String, dynamic> appointmentData) async {
    await FirebaseFirestore.instance.collection('accepted_appointments').add({
      'doctor_name': appointmentData['doctor_name'],
      'doctor_specialty': appointmentData['doctor_specialty'],
      'user_name': appointmentData['user_name'],
      'user_phone': appointmentData['user_phone'],
      'date': appointmentData['date'],
      'time_slot': appointmentData['time_slot'],
      'document': appointmentData['document'],
      'status': 'accepted',
      'doctor_id': appointmentData['doctor_id'],
      'user_id': appointmentData['user_id'],
    });

    await FirebaseFirestore.instance
        .collection('appointment_pending')
        .doc(appointmentId)
        .delete();
  }

  Future<void> _rejectAppointment(String appointmentId) async {
    await FirebaseFirestore.instance
        .collection('appointment_pending')
        .doc(appointmentId)
        .delete();
  }
}
