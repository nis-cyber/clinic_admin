import 'package:clinic_admin/appointments/pages/tabs/appointment_page.dart';
import 'package:clinic_admin/dashboard/home_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 173, 205, 204)!,
              const Color.fromARGB(255, 180, 152, 225)!
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 90,
                  color: Colors.teal[700],
                ),
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => ClinicHomeScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  // Update with correct profile screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) =>
                            ClinicHomeScreen()), // Update this if needed
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Appointments'),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AppointmentPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.of(context).pushNamed('/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.query_stats_outlined),
                title: const Text('Manage Queue'),
                onTap: () {},
              ),

              const Divider(), // Add a divider
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  // Handle logout functionality here
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
