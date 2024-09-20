import 'package:clinic_admin/doctor/data/doctor_service.dart';
import 'package:clinic_admin/doctor/model/doctor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddDoctorScreen extends StatefulWidget {
  @override
  _AddDoctorScreenState createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedSpecialty = 'General Practitioner';
  Map<String, List<String>> _availableSlots = {};

  final List<String> _specialties = [
    'General Practitioner',
    'Pediatrician',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Orthopedist',
    'Psychiatrist',
    'Oncologist',
    'Gynecologist',
    'Urologist',
  ];

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> _timeSlots = [
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
    '05:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    for (var day in _daysOfWeek) {
      _availableSlots[day] = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Doctor')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedSpecialty,
              decoration: InputDecoration(labelText: 'Specialty'),
              items: _specialties.map((String specialty) {
                return DropdownMenuItem(
                  value: specialty,
                  child: Text(specialty),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSpecialty = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Available Slots:',
                style: Theme.of(context).textTheme.titleLarge),
            ..._buildAvailableSlotsWidgets(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _submitForm();
              },
              child: Text('Add Doctor'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAvailableSlotsWidgets() {
    List<Widget> widgets = [];
    for (var day in _daysOfWeek) {
      widgets.add(
        ExpansionTile(
          title: Text(day),
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _timeSlots.map((slot) {
                bool isSelected = _availableSlots[day]!.contains(slot);
                return FilterChip(
                  label: Text(slot),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _availableSlots[day]!.add(slot);
                      } else {
                        _availableSlots[day]!.remove(slot);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      );
    }
    return widgets;
  }

  final DoctorService _doctorService = DoctorService();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final doctor = DoctorModel(
          id: 'ss', // You might want to generate this ID or let Firestore auto-generate it
          name: _nameController.text,
          specialty: _selectedSpecialty,
          availableSlots: _availableSlots,
        );

        await _doctorService.addDoctor(doctor);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor added successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add doctor. Please try again.')),
        );
      }
    }
  }
}
