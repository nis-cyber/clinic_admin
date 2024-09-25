import 'dart:convert';

import 'package:clinic_admin/auth/pages/status_page.dart';
import 'package:clinic_admin/auth/service/clinic_service.dart';
import 'package:clinic_admin/common/drawer.dart';
import 'package:clinic_admin/doctor/pages/doctor_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ClinicHomeScreen extends StatefulWidget {
  @override
  State<ClinicHomeScreen> createState() => _ClinicHomeScreenState();
}

class _ClinicHomeScreenState extends State<ClinicHomeScreen> {
  final ClinicAuthService _authService = ClinicAuthService();
  // Create an instance of AuthService

  Map payload = {};
  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments;
    // for background and terminated state
    if (data is RemoteMessage) {
      payload = data.data;
    }
    // for foreground state
    if (data is NotificationResponse) {
      payload = jsonDecode(data.payload!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Home Screen '),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const StatusPage()),
              );
            },
          ),
        ],
      ),
      drawer: MyDrawer(),
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
        child: Column(
          children: [
            SingleChildScrollView(
              child: SingleChildScrollView(
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
                      icon: const Icon(Icons.search),
                    ),
                    ElevatedButton(
                      onPressed: () async {},
                      child: Text('Send Notification'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
