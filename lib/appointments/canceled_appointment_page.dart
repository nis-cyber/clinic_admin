import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentNotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Canceled Appointments'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 173, 205, 204),
      ),
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
        child:
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('cancled_appointment')
              .orderBy('canceled_at', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No canceled appointments found.'));
            }

            var canceledAppointments = snapshot.data!.docs;

            return ListView.builder(
              itemCount: canceledAppointments.length,
              itemBuilder: (context, index) {
                var appointment = canceledAppointments[index].data() as Map<String, dynamic>;
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text("Patient: ${appointment['user_name']}", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Patient Email: ${appointment['user_email']}"),
                        Text("Patient Phone: ${appointment['user_phone']}"),
                        Text("Doctor: ${appointment['doctor_name']}"),

                        Text("Specialty: ${appointment['doctor_specialty']}"),
                        Text("Date: ${appointment['date']}"),
                        Text("Time Slot: ${appointment['time_slot']}"),
                        Text("Canceled At: ${DateFormat('yyyy-MM-dd HH:mm').format(appointment['timestamp'].toDate())}", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    trailing: Icon(Icons.notifications_off, color: Colors.red),
                  ),
                );
              },
            );
          },
        ),
      ),





    );
  }
}