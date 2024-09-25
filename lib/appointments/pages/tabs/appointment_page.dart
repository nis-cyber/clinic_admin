import 'package:clinic_admin/appointments/data/appointment_provier.dart';
import 'package:clinic_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pending_appointment_tab.dart';
import 'accepted_appointment_tab.dart';

class AppointmentPage extends ConsumerStatefulWidget {
  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends ConsumerState<AppointmentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(appointmentNotifierProvider, (previous, next) {
      // When an appointment is accepted, switch to the Accepted tab
      _tabController.animateTo(1);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        backgroundColor: Color.fromARGB(255, 173, 205, 204),
        leading: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const MainPage();
              }));
            },
            icon: Icon(Icons.arrow_back_ios)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
          ],
        ),
      ),
      body: Container(
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
        child: TabBarView(
          controller: _tabController,
          children: [
            AllPendingAppointmentsPage(),
            AllAcceptedAppointmentsPage(),
          ],
        ),
      ),
    );
  }
}
