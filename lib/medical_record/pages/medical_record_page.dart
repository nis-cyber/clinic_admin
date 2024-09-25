import 'package:clinic_admin/medical_record/pages/create_medical_record_page.dart';
import 'package:clinic_admin/medical_record/pages/detail_medical_record_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicalReportsPage extends StatelessWidget {
  final String appointmentId;
  final String doctorName;
  final String userName;
  final String userPhone;
  final String speciality;
  final String doctorId;
  final String date;
  final String timeSlot;
  final String userId;

  MedicalReportsPage({
    required this.appointmentId,
    required this.doctorName,
    required this.userName,
    required this.userPhone,
    required this.date,
    required this.timeSlot,
    required this.doctorId,
    required this.speciality,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 173, 205, 204)!,
        // Dark Blue
        title: Text(
          'Medical Reports for $userName',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 4,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF3F4F6), // Light Gray background
      body: SafeArea(
        child: Container(
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
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('medical_reports')
                      .where('userId', isEqualTo: userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Error loading reports',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No medical reports found.',
                          style: TextStyle(
                            color: Color(0xFF374151), // Dark Gray
                            fontSize: 18,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var reportData = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(
                              reportData['user_name'] ?? 'Unknown Diagnosis',
                              style: const TextStyle(
                                color: Color(0xFF1E40AF), // Dark Blue for title
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              // DateFormat('yyyy-MM-dd – kk:mm').format(
                              //   (reportData['timestamp'] as Timestamp).toDate(),
                              // ),
                              reportData['date'] ?? 'Unknown Doctor',
                              style: const TextStyle(
                                color: Color(
                                    0xFF6B7280), // Muted Gray for timestamp
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF93C5FD), // Light Blue for arrow
                            ),
                            onTap: () {
                              // Navigate to DetailedReportPage and pass the full reportData
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailedReportPage(
                                      reportData: reportData),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(255, 173, 205, 204), // Dark Blue button
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 6,
                  ),
                  onPressed: () {
                    // Navigate to InputReportPage and pass patient details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InputReportPage(
                          userId: userId,
                          appointmentId: appointmentId,
                          doctorName: doctorName,
                          userName: userName,
                          userPhone: userPhone,
                          speciality: speciality,
                          doctorId: doctorId,
                          date: date,
                          timeSlot: timeSlot,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    '   Add Report   ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
