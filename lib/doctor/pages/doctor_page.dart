import 'package:flutter/material.dart';
import 'package:clinic_admin/doctor/data/doctor_service.dart';
import 'package:clinic_admin/doctor/model/doctor_model.dart';
import 'package:clinic_admin/doctor/pages/add_doctor_page.dart';
import 'package:clinic_admin/doctor/pages/doctor_detail_page.dart';

class DoctorPage extends StatefulWidget {
  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final DoctorService _doctorService = DoctorService();
  List<DoctorModel> _allDoctors = [];
  List<DoctorModel> _filteredDoctors = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

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
        _allDoctors = doctors;
        _filteredDoctors = doctors;
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

  void _filterDoctors(String query) {
    setState(() {
      _filteredDoctors = _allDoctors.where((doctor) {
        return doctor.name.toLowerCase().contains(query.toLowerCase()) ||
            doctor.specialty.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
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

  void _navigateToDoctorDetails(BuildContext context, DoctorModel doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DoctorDetailPage(doctor: doctor)),
    );
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name or specialty',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterDoctors,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                    ? const Center(child: Text('No doctors found'))
                    : ListView.builder(
                        itemCount: _filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _filteredDoctors[index];
                          return ListTile(
                            title: Text(doctor.name),
                            subtitle: Text(doctor.specialty),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _showDeleteConfirmation(context, doctor),
                            ),
                            onTap: () =>
                                _navigateToDoctorDetails(context, doctor),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
