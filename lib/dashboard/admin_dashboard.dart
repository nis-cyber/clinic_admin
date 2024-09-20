import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff7fc1e0),
              Color(0xff9c92d7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Appointment Management'),
                _buildDashboardItem(context, 'View Appointments', Icons.event,
                    '/view_appointments'),
                _buildDashboardItem(context, 'Confirm/Reject Appointments',
                    Icons.check, '/confirm_reject_appointments'),
                _buildDashboardItem(context, 'Manage Schedules', Icons.schedule,
                    '/manage_schedules'),
                _buildDashboardItem(context, 'Handle Cancellations',
                    Icons.cancel, '/handle_cancellations'),
                _buildSectionHeader('Patient Records'),
                _buildDashboardItem(context, 'Access Patient Records',
                    Icons.person, '/access_patient_records'),
                _buildDashboardItem(context, 'View Appointment History',
                    Icons.history, '/view_appointment_history'),
                _buildDashboardItem(context, 'Manage Patient Information',
                    Icons.person_add, '/manage_patient_information'),
                _buildSectionHeader('Provider Profiles'),
                _buildDashboardItem(
                    context, 'View Providers', Icons.people, '/view_providers'),
                _buildDashboardItem(context, 'Add/Remove Providers',
                    Icons.person_add, '/add_remove_providers'),
                _buildDashboardItem(context, 'Update Provider Information',
                    Icons.edit, '/update_provider_information'),
                _buildSectionHeader('Reports and Analytics'),
                _buildDashboardItem(context, 'Generate Reports',
                    Icons.bar_chart, '/generate_reports'),
                _buildDashboardItem(context, 'Analyze Performance',
                    Icons.analytics, '/analyze_performance'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDashboardItem(
      BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}

// Placeholder screens for each route
class ViewAppointmentsScreen extends StatelessWidget {
  const ViewAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Appointments'),
      ),
      body: Center(
        child: Text('View Appointments Screen'),
      ),
    );
  }
}

class ConfirmRejectAppointmentsScreen extends StatelessWidget {
  const ConfirmRejectAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm/Reject Appointments'),
      ),
      body: const Center(
        child: Text('Confirm/Reject Appointments Screen'),
      ),
    );
  }
}

// ... Placeholder screens for other routes
class ManageSchedulesScreen extends StatelessWidget {
  const ManageSchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Schedules'),
      ),
      body: const Center(
        child: Text('Manage Schedules Screen'),
      ),
    );
  }
}
// this is dashboard for admin
// i think i should route for each icon