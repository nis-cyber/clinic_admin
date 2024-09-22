import 'package:clinic_admin/appointments/data/appointment_provier.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PendingAppointmentTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsyncValue = ref.watch(pendingAppointmentsProvider);

    return Scaffold(
      body: appointmentsAsyncValue.when(
        data: (appointments) {
          if (appointments.isEmpty) {
            return const Center(child: Text('No pending appointments.'));
          }
          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointment = appointments[index];
              return _buildAppointmentCard(context, ref, appointment);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
      BuildContext context, WidgetRef ref, Map<String, dynamic> data) {
    DateTime createdAt = (data['createdAt'] as Timestamp).toDate();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Dr. ${data['doctorName']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${data['day']}'),
            Text('Time: ${data['slot']}'),
            Text('Status: ${data['status']}'),
            Text(
                'Booked on: ${DateFormat('MMM d, yyyy HH:mm').format(createdAt)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(data['status']),
          ],
        ),
        onTap: () => _showAppointmentDetails(context, ref, data),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData iconData;
    Color color;

    switch (status.toLowerCase()) {
      case 'booked':
        iconData = Icons.event_available;
        color = Colors.green;
        break;
      case 'cancelled':
        iconData = Icons.event_busy;
        color = Colors.red;
        break;
      case 'completed':
        iconData = Icons.check_circle;
        color = Colors.blue;
        break;
      case 'pending':
        iconData = Icons.hourglass_bottom;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.event_note;
        color = Colors.grey;
    }

    return Icon(iconData, color: color);
  }

  void _showAppointmentDetails(BuildContext context, WidgetRef ref,
      Map<String, dynamic> appointmentData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appointment Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Doctor: Dr. ${appointmentData['doctorName']}'),
              Text('Date: ${appointmentData['day']}'),
              Text('Time: ${appointmentData['slot']}'),
              Text('Status: ${appointmentData['status']}'),
              Text(
                  'Booked on: ${DateFormat('MMM d, yyyy HH:mm').format((appointmentData['createdAt'] as Timestamp).toDate())}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (appointmentData['status'].toLowerCase() == 'pending')
              ElevatedButton(
                child: const Text('Accept Appointment'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  _acceptAppointment(context, ref, appointmentData);
                },
              ),
          ],
        );
      },
    );
  }

  void _acceptAppointment(BuildContext context, WidgetRef ref,
      Map<String, dynamic> appointmentData) async {
    try {
      final service = ref.read(pendingAppointmentServiceProvider);
      await service.acceptAppointment(appointmentData);

      // Refresh the accepted appointments
      ref.read(appointmentNotifierProvider.notifier).refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment accepted successfully!')),
      );
    } catch (e) {
      print('Error accepting appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept the appointment: $e')),
      );
    }
  }
}
