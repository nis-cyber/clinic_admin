import 'package:clinic_admin/medical_record/medical_record_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FromQueueAppointmentTab extends StatelessWidget {
  const FromQueueAppointmentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Light Gray background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 173, 205, 204),
              const Color.fromARGB(255, 180, 152, 225)
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments_from_queue')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No appointments from queue.',
                  style: TextStyle(
                    color: Color(0xFF374151), // Dark Gray for text
                    fontSize: 18,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var appointmentData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicalReportsPage(
                          speciality: appointmentData['doctorSpecialty'],
                          userId: appointmentData['userId'],
                          appointmentId: snapshot.data!.docs[index].id,
                          doctorName: appointmentData['doctorName'],
                          userName: appointmentData['name'],
                          doctorId: appointmentData['doctorId'],
                          userPhone: appointmentData['phone'],
                          date: appointmentData['date'],
                          timeSlot: appointmentData['timeSlot'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    elevation: 6,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                              'Doctor Name', appointmentData['doctorName']),
                          _buildInfoRow(
                              'Specialty', appointmentData['doctorSpecialty']),
                          _buildInfoRow('User Name', appointmentData['name']),
                          _buildInfoRow('User Phone', appointmentData['phone']),
                          _buildInfoRow(
                              'Date',
                              DateFormat('yyyy-MM-dd').format(
                                  DateTime.parse(appointmentData['date']))),
                          _buildInfoRow(
                              'Time Slot', appointmentData['timeSlot']),
                          _buildInfoRow('Status', appointmentData['status']),
                          _buildInfoRow(
                              'doctorId', appointmentData['doctorId']),
                        ],
                      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A), // Deep Blue for labels
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF374151), // Dark Gray for value text
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
