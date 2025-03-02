import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AllPendingAppointmentsPage extends StatelessWidget {
  const AllPendingAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        _buildInfoRow(Icons.info_outline, 'Status',
                            appointmentData['status']),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              onPressed: () => _acceptAppointment(
                                  context, appointmentId, appointmentData),
                              label: 'Accept',
                              color: Colors.teal,
                            ),
                            _buildActionButton(
                              onPressed: () => _rejectAppointment(
                                context,
                                appointmentId,
                                appointmentData['doctor_id'],
                                appointmentData['doctor_name'],
                                appointmentData['doctor_specialty'],
                                appointmentData['date'],
                                appointmentData['time_slot'],
                              ),
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
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(label),
    );
  }

  Future<void> _acceptAppointment(BuildContext context, String appointmentId,
      Map<String, dynamic> appointmentData) async {
    try {
      await FirebaseFirestore.instance.collection('accepted_appointments').add({
        'doctor_name': appointmentData['doctor_name'],
        'doctor_specialty': appointmentData['doctor_specialty'],
        'user_name': appointmentData['user_name'],
        'user_phone': appointmentData['user_phone'],
        'date': appointmentData['date'],
        'time_slot': appointmentData['time_slot'],
        'status': 'accepted',
        'doctor_id': appointmentData['doctor_id'],
        'user_id': appointmentData['user_id'],
        'created_at': DateTime.now().toIso8601String(),
      });

      await FirebaseFirestore.instance
          .collection('appointment_pending')
          .doc(appointmentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment accepted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Function to handle appointment rejection and assign to next user in queue
  Future<void> _rejectAppointment(
    BuildContext context,
    String appointmentId,
    String doctorId,
    String doctorName,
    String doctorSpecialty,
    String date,
    String timeSlot,
  ) async {
    try {
      // Step 1: First make the doctor's time slot available in the database
      await _makeSlotAvailable(doctorId, date, timeSlot);
      print("Step 1: Made slot available"); // Debug print

      // Step 2: Get queue snapshot first to see if anyone is waiting
      QuerySnapshot queueSnapshot = await FirebaseFirestore.instance
          .collection('queues')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isEqualTo: date)
          .where('timeSlot', isEqualTo: timeSlot)
          .orderBy(
              'timestamp') // Order by timestamp to get the first person who joined
          .limit(1) // Get only the first person in the queue
          .get();

      print(
          "Step 2: Queue check completed. Found: ${queueSnapshot.docs.length} users"); // Debug print

      // Step 3: Delete the current appointment
      await FirebaseFirestore.instance
          .collection('appointment_pending')
          .doc(appointmentId)
          .delete();
      print("Step 3: Deleted current appointment"); // Debug print

      // Step 4: Process queue if not empty
      if (queueSnapshot.docs.isNotEmpty) {
        // Get the first person's queue entry
        var queueDoc = queueSnapshot.docs.first;
        var queueData = queueDoc.data() as Map<String, dynamic>;
        String nextUserId = queueData['userId'];
        print(
            "Step 4: Found user in queue with ID: $nextUserId"); // Debug print

        // Get user information for the new appointment
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(nextUserId)
            .get();

        print(
            "Step 5: Retrieved user data. Exists: ${userSnapshot.exists}"); // Debug print

        Map<String, dynamic> userData = {};
        if (userSnapshot.exists) {
          userData = userSnapshot.data() as Map<String, dynamic>;
        }

        // Create the appointment data
        Map<String, dynamic> newAppointmentData = {
          'doctor_id': doctorId,
          'doctor_name': doctorName,
          'doctor_specialty': doctorSpecialty,
          'user_id': nextUserId,
          'user_name': userData['name'] ?? 'Unknown User',
          'user_phone': userData['phone'] ?? 'No Phone',
          'date': date,
          'time_slot': timeSlot,
          'status': 'confirmed',
          'created_at': DateTime.now().toIso8601String(),
        };

        print("Step 6: Created new appointment data"); // Debug print

        // Add the new appointment
        DocumentReference newAppointmentRef = await FirebaseFirestore.instance
            .collection('appointment_pending')
            .add(newAppointmentData);

        print(
            "Step 7: Added new appointment with ID: ${newAppointmentRef.id}"); // Debug print

        // Mark the slot as booked again
        await _markSlotAsBooked(doctorId, date, timeSlot);
        print("Step 8: Marked slot as booked again"); // Debug print

        // Remove the user from the queue
        await FirebaseFirestore.instance
            .collection('queues')
            .doc(queueDoc.id)
            .delete();

        print("Step 9: Removed user from queue"); // Debug print

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Appointment rejected and assigned to next person in queue'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // No one in queue, just show normal rejection message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment rejected successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Error in _rejectAppointment: ${e.toString()}"); // Debug print
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _makeSlotAvailable(
    String doctorId,
    String date,
    String timeSlot,
  ) async {
    try {
      // Fetch the doctor's document from Firestore
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();

      if (doctorSnapshot.exists) {
        var doctorData = doctorSnapshot.data() as Map<String, dynamic>;

        if (doctorData['availability'] != null &&
            doctorData['availability'][date] != null) {
          List<dynamic> slots =
              List<dynamic>.from(doctorData['availability'][date]);

          // Find the booked slot and restore it to original format
          for (int i = 0; i < slots.length; i++) {
            if (slots[i] == "$timeSlot (Booked)") {
              slots[i] = timeSlot; // Remove the "(Booked)" marker
              break;
            }
          }

          // Create a new map to avoid reference issues
          Map<String, dynamic> newAvailability =
              Map<String, dynamic>.from(doctorData['availability']);
          newAvailability[date] = slots;

          // Update the doctor's availability with the modified slots
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(doctorId)
              .update({'availability': newAvailability});
        }
      }
    } catch (e) {
      print("Error in _makeSlotAvailable: ${e.toString()}"); // Debug print
      rethrow;
    }
  }

  Future<void> _markSlotAsBooked(
    String doctorId,
    String date,
    String timeSlot,
  ) async {
    try {
      // Fetch the doctor's document from Firestore
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();

      if (doctorSnapshot.exists) {
        var doctorData = doctorSnapshot.data() as Map<String, dynamic>;

        if (doctorData['availability'] != null &&
            doctorData['availability'][date] != null) {
          List<dynamic> slots =
              List<dynamic>.from(doctorData['availability'][date]);

          // Find the slot and mark it as booked
          for (int i = 0; i < slots.length; i++) {
            if (slots[i] == timeSlot) {
              slots[i] = "$timeSlot (Booked)"; // Add the "(Booked)" marker
              break;
            }
          }

          // Create a new map to avoid reference issues
          Map<String, dynamic> newAvailability =
              Map<String, dynamic>.from(doctorData['availability']);
          newAvailability[date] = slots;

          // Update the doctor's availability with the modified slots
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(doctorId)
              .update({'availability': newAvailability});
        }
      }
    } catch (e) {
      print("Error in _markSlotAsBooked: ${e.toString()}"); // Debug print
      rethrow;
    }
  }
}
