import 'package:clinic_admin/medical_record/pages/create_medical_record_page.dart';
import 'package:clinic_admin/other/patient_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

// Repository
class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Appointment>> getAcceptedAppointments() {
    return _firestore.collection('appointments_accepted').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc))
            .toList());
  }

  Future<Patient> getPatientById(String patientId) async {
    final doc = await _firestore.collection('users').doc(patientId).get();
    return Patient.fromFirestore(doc);
  }
}

// Providers
final appointmentRepositoryProvider =
    Provider((ref) => AppointmentRepository());

final acceptedAppointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getAcceptedAppointments();
});

final patientProvider =
    FutureProvider.family<Patient, String>((ref, patientId) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getPatientById(patientId);
});

// UI Components
class SendMedicalReportButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      child: Text('Send Medical Report'),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => PatientSelectionSheet(),
        );
      },
    );
  }
}

class PatientSelectionSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsyncValue = ref.watch(acceptedAppointmentsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select a Patient',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: appointmentsAsyncValue.when(
              data: (appointments) => ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return PatientListItem(patientId: appointment.patientId);
                },
              ),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class PatientListItem extends ConsumerWidget {
  final String patientId;

  const PatientListItem({Key? key, required this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsyncValue = ref.watch(patientProvider(patientId));

    return patientAsyncValue.when(
      data: (patient) => ListTile(
        title: Text(patient.fullName),
        subtitle: Text(patient.address),
        trailing: patient.email.isNotEmpty ? Text(patient.phoneNumber) : null,
        onTap: () {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) => PatientConfirmationDialog(patient: patient),
          );
        },
      ),
      loading: () => ListTile(title: CircularProgressIndicator()),
      error: (error, stack) => ListTile(title: Text('Error: $error')),
    );
  }
}

class PatientConfirmationDialog extends StatelessWidget {
  final Patient patient;

  const PatientConfirmationDialog({Key? key, required this.patient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm Patient Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Full Name: ${patient.fullName}'),
          Text('Email: ${patient.email}'),
          Text('Address: ${patient.address}'),
          Text('Phone Number: ${patient.phoneNumber}'),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text('Confirm'),
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => CreateMedicalReportPage(),
            //   ),
            // );
          },
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SendMedicalReportButton(),
        ],
      ),
    );
  }
}
