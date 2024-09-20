import 'package:clinic_admin/doctor/pages/add_doctor_page.dart';
import 'package:clinic_admin/doctor/pages/doctor_detail_page.dart';
import 'package:clinic_admin/doctor/pages/edit_doctor_page.dart';
import 'package:flutter/material.dart';
import 'package:clinic_admin/doctor/data/doctor_service.dart';
import 'package:clinic_admin/doctor/model/doctor_model.dart';

class DoctorPage extends StatefulWidget {
  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final DoctorService _doctorService = DoctorService();
  List<DoctorModel> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final doctors = await _doctorService.getAllDoctors();
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading doctors: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load doctors. Please try again.')),
      );
    }
  }

  void _navigateToEditDoctor(BuildContext context, DoctorModel doctor) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DoctorEditPage(doctor: doctor)),
    );
    if (result == true) {
      // Doctor was updated, refresh the list
      _loadDoctors();
    }
  }

  void _navigateToDoctorDetails(BuildContext context, DoctorModel doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DoctorDetailPage(doctor: doctor)),
    );
  }

  void _navigateToAddDoctor(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDoctorScreen()),
    );
    if (result == true) {
      _loadDoctors();
    }
  }

  void _showDeleteConfirmation(BuildContext context, DoctorModel doctor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Doctor'),
          content: Text('Are you sure you want to delete ${doctor.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteDoctor(doctor);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDoctor(DoctorModel doctor) async {
    try {
      await _doctorService.deleteDoctor(doctor.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor deleted successfully')),
      );
      _loadDoctors();
    } catch (e) {
      print('Error deleting doctor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to delete doctor. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddDoctor(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctors.isEmpty
              ? const Center(child: Text('No doctors found'))
              : ListView.builder(
                  itemCount: _doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _doctors[index];
                    return ListTile(
                      title: Text(doctor.name),
                      subtitle: Text(doctor.specialty),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _showDeleteConfirmation(context, doctor),
                          ),
                        ],
                      ),
                      onTap: () {
                        _navigateToDoctorDetails(context, doctor);
                      },
                    );
                  },
                ),
    );
  }
}
