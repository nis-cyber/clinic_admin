import 'package:clinic_admin/queue/service/email-service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminQueuePage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  AdminQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Management'),
        backgroundColor: const Color.fromARGB(255, 173, 205, 204),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 173, 205, 204),
              Color.fromARGB(255, 180, 152, 225),
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getSortedQueues(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No users in the queue.'));
            }

            var queues = snapshot.data!.docs;
            String? currentGroupKey;
            int positionInGroup = 0;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: queues.length,
              itemBuilder: (context, index) {
                var queue = queues[index];
                var data = queue.data() as Map<String, dynamic>;
                data['id'] = queue.id;

                // Calculate group key
                final groupKey =
                    '${data['doctorId']}-${data['date']}-${data['timeSlot']}';

                // Update position tracking
                if (groupKey != currentGroupKey) {
                  currentGroupKey = groupKey;
                  positionInGroup = 1;
                } else {
                  positionInGroup++;
                }

                return _buildQueueItem(
                  data,
                  context,
                  queuePosition: positionInGroup,
                  isFirstInGroup: positionInGroup == 1,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildQueueItem(
    Map<String, dynamic> data,
    BuildContext context, {
    required int queuePosition,
    required bool isFirstInGroup,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isFirstInGroup ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User: ${data['name']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                _QueuePositionBadge(
                  position: queuePosition,
                  isFirst: isFirstInGroup,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.medical_services,
              text: '${data['doctorName']} (${data['doctorSpecialty']})',
            ),
            _InfoRow(
              icon: Icons.calendar_today,
              text: DateFormat('EEEE, MMMM d, y')
                  .format(DateTime.parse(data['date'])),
            ),
            _InfoRow(
              icon: Icons.access_time,
              text: data['timeSlot'],
            ),
            const SizedBox(height: 16),
            _buildActionButtons(data, context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> data, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () => _cancelQueue(context, data),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _appointUser(context, data),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Appoint'),
        ),
      ],
    );
  }

  void _cancelQueue(BuildContext context, Map<String, dynamic> data) async {
    // Delete the queue entry
    await FirebaseFirestore.instance
        .collection('queues')
        .doc(data['id'])
        .delete();

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Queue entry cancelled successfully.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _appointUser(BuildContext context, Map<String, dynamic> data) async {
    try {
      final QuerySnapshot appointmentSnapshot = await FirebaseFirestore.instance
          .collection('appointment_pending')
          .get();

      final List<Map<String, dynamic>> appointments = [];
      for (final doc in appointmentSnapshot.docs) {
        final appointmentData = doc.data() as Map<String, dynamic>;
        appointments.add(
          appointmentData,
        );
      }

      final bool isDataFound = _checkIfDataExists(appointments, data);

      if (!isDataFound) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot no longer available!')),
        );
        return;
      } else {
        final batch = FirebaseFirestore.instance.batch();
        final appointmentRef = FirebaseFirestore.instance
            .collection('appointments_from_queue')
            .doc();
        batch.set(appointmentRef, {
          'doctorId': data['doctorId'],
          'doctorName': data['doctorName'],
          'doctorSpecialty': data['doctorSpecialty'],
          'date': data['date'],
          'timeSlot': data['timeSlot'],
          'userId': data['userId'],
          'timestamp': DateTime.now(),
          'status': 'Pending',
          'name': data['name'],
          'email': data['email'],
          'phone': data['phone'],
        });

        await EmailService.sendConfirmationEmail(
          userName: data['name'],
          userEmail: data['email'],
          date: data['date'],
          timeSlot: data['timeSlot'],
          doctorName: data['doctorName'],
        );

        // Fetch data from the appointment_pending collection
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User appointed successfully!')),
        );
        return;
      }

      // final date = data['date'];
      // final timeSlot = data['timeSlot'];

      // // Get doctor document
      // final doctorRef =
      //     FirebaseFirestore.instance.collection('doctors').doc(doctorId);
      // final doctorDoc = await doctorRef.get();

      // if (!doctorDoc.exists) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Doctor not found!')),
      //   );
      //   return;
      // }

      // // Get availability data
      // final doctorData = doctorDoc.data()!;
      // final availability =
      //     (doctorData['availability'] as Map<String, dynamic>?) ?? {};
      // final slots = (availability[date] as List<dynamic>?) ?? [];

      // // Check if slot is already booked
      // final isAlreadyBooked = slots.contains('$timeSlot (Booked)');
      // if (isAlreadyBooked) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('This slot is already booked!')),
      //   );
      //   return;
      // }

      // // Verify original slot exists
      // final slotIndex = slots.indexOf(timeSlot);
      // if (slotIndex == -1) {

      // // Create batch for atomic operations

      // // 1. Add to appointments

      // // 2. Remove from queue
      // final queueRef =
      //     FirebaseFirestore.instance.collection('queues').doc(data['id']);
      // batch.delete(queueRef);

      // // 3. Update doctor availability
      // final updatedSlots = List<dynamic>.from(slots);
      // updatedSlots[slotIndex] = '$timeSlot (Booked)';
      // batch.update(doctorRef, {'availability.$date': updatedSlots});

      // // Commit all operations atomically
      // await batch.commit();

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('User appointed successfully!')),
      // );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

bool _checkIfDataExists(
    List<Map<String, dynamic>> appointments, Map<String, dynamic> data) {
  final String doctorId = data['doctorId'];
  final String date = data['date'];
  final String timeSlot = data['timeSlot'];

  bool isValid = false;
  for (var i = 0; i < appointments.length; i++) {
    final appointment = appointments[i];
    if (appointment['doctor_id'] == doctorId &&
        appointment['date'] == date &&
        appointment['time_slot'] ==
            timeSlot.replaceAll("(Booked)", "").trim()) {
      isValid = true;
      break;
    }
  }
  return isValid;
}

class _QueuePositionBadge extends StatelessWidget {
  final int position;
  final bool isFirst;

  const _QueuePositionBadge({required this.position, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFirst ? Colors.green : Colors.blueGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Position: $position',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FirestoreService {
  Stream<QuerySnapshot> getSortedQueues() {
    return FirebaseFirestore.instance
        .collection('queues')
        .orderBy('doctorId')
        .orderBy('date')
        .orderBy('timeSlot')
        .orderBy('timestamp')
        .snapshots();
  }
}
