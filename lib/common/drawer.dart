import 'package:clinic_admin/appointments/pages/tabs/appointment_page.dart';
import 'package:clinic_admin/dashboard/home_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage(
                      'assets/profile_image.png'), // Replace with user profile image
                ),
                SizedBox(height: 10),
                Text(
                  'Username', // Replace with dynamic user name
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'email@example.com', // Replace with dynamic user email
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Drawer items
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ClinicHomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ClinicHomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Appointments'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AppointmentPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          Divider(), // Add a divider
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Handle logout functionality
            },
          ),
        ],
      ),
    );
  }
}
