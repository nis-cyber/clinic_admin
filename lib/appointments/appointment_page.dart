import 'package:clinic_admin/appointments/from_queue_appointment_tab.dart';
import 'package:clinic_admin/common/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pending_appointment_tab.dart';
import 'accepted_appointment_tab.dart';

class AppointmentPage extends ConsumerStatefulWidget {
  const AppointmentPage({super.key});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends ConsumerState<AppointmentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 173, 205, 204),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'From Queue')
          ],
        ),
      ),
      drawer: MyDrawer(),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            AllPendingAppointmentsPage(),
            AllAcceptedAppointmentsPage(),
            FromQueueAppointmentTab(),
          ],
        ),
      ),
    );
  }
}
