import 'package:clinic_admin/other/profile_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Assuming you have these classes defined as shown in your code
// import 'path_to_your_models/appointment.dart';
// import 'path_to_your_models/patient.dart';
// import 'path_to_your_repository/appointment_repository.dart';

// Provider for AppointmentRepository
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository();
});

// Provider for accepted appointments stream
final acceptedAppointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.getAcceptedAppointments();
});

// Provider for selected appointment
final selectedAppointmentProvider = StateProvider<Appointment?>((ref) => null);

// Provider for selected patient
final selectedPatientProvider = FutureProvider<Patient?>((ref) async {
  final selectedAppointment = ref.watch(selectedAppointmentProvider);
  if (selectedAppointment == null) return null;

  final repository = ref.watch(appointmentRepositoryProvider);
  return await repository.getPatientById(selectedAppointment.patientId);
});

// Combined provider for appointment and patient data
final appointmentWithPatientProvider =
    FutureProvider<(Appointment, Patient)?>((ref) async {
  final appointment = ref.watch(selectedAppointmentProvider);
  final patientAsync = ref.watch(selectedPatientProvider);

  if (appointment == null) return null;

  return patientAsync.when(
    data: (patient) => patient != null ? (appointment, patient) : null,
    loading: () => null,
    error: (_, __) => null,
  );
});
