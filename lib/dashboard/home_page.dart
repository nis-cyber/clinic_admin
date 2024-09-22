import 'package:clinic_admin/auth/pages/status_page.dart';
import 'package:clinic_admin/auth/service/clinic_service.dart';
import 'package:clinic_admin/common/drawer.dart';
import 'package:clinic_admin/doctor/pages/doctor_page.dart';
import 'package:flutter/material.dart';

class ClinicHomeScreen extends StatelessWidget {
  final ClinicAuthService _authService =
      ClinicAuthService(); // Create an instance of AuthService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clinic Home Screen '),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => StatusPage()),
              );
            },
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorPage(),
                  ),
                );
              },
              icon: Icon(Icons.search),
            ),
            DoctorsSection(),
            SizedBox(height: 16.0),
            UpcomingQueueSection(),
            SizedBox(height: 16.0),
            MissedQueueSection(),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class DoctorsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[200]!, Colors.grey[400]!],
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          SectionHeader('Doctors'),
          DoctorCard('Dr. Ram Baran Yadav', 'Available', 'Patient: Nishant'),
          DoctorCard('Dr. Nana Patekar', 'Busy', 'Patient: Bishal'),
        ],
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String status;
  final String patient;

  DoctorCard(this.name, this.status, this.patient);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $status'),
            Text('Patient: $patient'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                // Cancel Consultation action
              },
            ),
            IconButton(
              icon: Icon(Icons.access_alarm),
              onPressed: () {
                // Absent action
              },
            ),
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () {
                // Complete Consultation action
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UpcomingQueueSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[200]!, Colors.grey[400]!],
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          SectionHeader('Upcoming Queue'),
          QueueItem('ID123', 'John Doe', 'A001', 'Male', 'In Queue'),
          QueueItem('ID124', 'Jane Smith', 'A002', 'Female', 'In Queue'),
        ],
      ),
    );
  }
}

class QueueItem extends StatelessWidget {
  final String identityNumber;
  final String name;
  final String queueNumber;
  final String gender;
  final String presenceStatus;

  QueueItem(
    this.identityNumber,
    this.name,
    this.queueNumber,
    this.gender,
    this.presenceStatus,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text('ID: $identityNumber - $name'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Queue Number: $queueNumber'),
            Text('Gender: $gender'),
            Text('Status: $presenceStatus'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.cancel),
          onPressed: () {
            // Cancel Queue action
          },
        ),
      ),
    );
  }
}

class MissedQueueSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[200]!, Colors.grey[400]!],
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          SectionHeader('Missed Queue'),
          MissedQueueItem('ID125', 'Mike Johnson', 'Male'),
        ],
      ),
    );
  }
}

class MissedQueueItem extends StatelessWidget {
  final String identityNumber;
  final String name;
  final String gender;

  MissedQueueItem(this.identityNumber, this.name, this.gender);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text('ID: $identityNumber - $name'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gender: $gender'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            // Rejoin Queue action
          },
        ),
      ),
    );
  }
}
