import 'package:cloud_firestore/cloud_firestore.dart';

// Model
class MedicalRecord {
  final String id;
  final String patientName;
  final String patientId;
  final String doctorName;
  final DateTime checkupDate;
  final String diagnosis;
  final String treatment;
  final String medications;
  final String followUpInstructions;
  final String? additionalNotes;
  final String speciality;
  final String? reportImageUrl;

  MedicalRecord({
    required this.id,
    required this.patientName,
    required this.patientId,
    required this.doctorName,
    required this.speciality,
    required this.checkupDate,
    required this.diagnosis,
    required this.treatment,
    required this.medications,
    required this.followUpInstructions,
    this.additionalNotes,
    this.reportImageUrl,
  });

  factory MedicalRecord.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MedicalRecord(
      id: doc.id,
      patientName: data['patientName'] ?? '',
      patientId: data['patientId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      checkupDate: (data['checkupDate'] as Timestamp).toDate(),
      diagnosis: data['diagnosis'] ?? '',
      treatment: data['treatment'] ?? '',
      speciality: data['doctor_specialty'] ?? '',
      medications: data['medications'] ?? '',
      followUpInstructions: data['followUpInstructions'] ?? '',
      additionalNotes: data['additionalNotes'],
      reportImageUrl: data['reportImageUrl'],
    );
  }
}
