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
          stream: _firestoreService.getAllQueues(),
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

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: queues.length,
              itemBuilder: (context, index) {
                var queue = queues[index];
                var data = queue.data() as Map<String, dynamic>;
                data['id'] = queue.id; // Add document ID to the data map

                return _buildQueueItem(data, context);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildQueueItem(Map<String, dynamic> data, BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User ID: ${data['userId']}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Doctor: ${data['doctorName']} (${data['doctorSpecialty']})',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat('EEEE, MMMM d, y').format(DateTime.parse(data['date']))}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Time Slot: ${data['timeSlot']}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Row(
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
            ),
          ],
        ),
      ),
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
    // Get doctor and slot details
    var doctorId = data['doctorId'];
    var date = data['date'];
    var timeSlot = data['timeSlot'];

    // Fetch the doctor's availability
    var doctorDoc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .get();
    var doctor = doctorDoc.data();

    if (doctor == null || doctor['availability'][date] == null) {
      // Doctor or availability data is missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor availability data not found.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get the list of slots for the selected date
    var slots = doctor['availability'][date] as List<dynamic>;

    // Check if the slot is already booked
    bool isSlotBooked = slots.any((slot) => slot == '$timeSlot (Booked)');

    if (isSlotBooked) {
      // Slot is already booked
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This time slot is already booked.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Slot is available, proceed to appoint the user
    // Move the user from the queue to appointments
    await FirebaseFirestore.instance.collection('appointments').add({
      'doctorId': doctorId,
      'doctorName': data['doctorName'],
      'doctorSpecialty': data['doctorSpecialty'],
      'date': date,
      'timeSlot': timeSlot,
      'userId': data['userId'],
      'timestamp': DateTime.now(),
    });

    // Remove the user from the queue
    await FirebaseFirestore.instance
        .collection('queues')
        .doc(data['id'])
        .delete();

    // Mark the time slot as booked in the doctor's availability
    List<dynamic> updatedSlots = List.from(slots);
    int slotIndex = updatedSlots.indexOf(timeSlot);
    if (slotIndex != -1) {
      updatedSlots[slotIndex] = '$timeSlot (Booked)';
    }

    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .update({
      'availability.$date': updatedSlots,
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User appointed successfully.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class FirestoreService {
  Stream<QuerySnapshot> getAllQueues() {
    return FirebaseFirestore.instance.collection('queues').snapshots();
  }
}
