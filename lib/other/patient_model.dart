import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String patientId;
  final Timestamp appointmentDate;
  // Add other relevant fields

  Appointment({
    required this.id,
    required this.patientId,
    required this.appointmentDate,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      patientId: data['patientId'],
      appointmentDate: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

class Patient {
  final String id;
  final String fullName;
  final String email;
  final String address;
  final String phoneNumber;

  Patient({
    required this.id,
    required this.fullName,
    required this.email,
    required this.address,
    required this.phoneNumber,
  });

  factory Patient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      fullName: data['fullname'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['number'] ?? '',
    );
  }
}
