import 'package:flutter/material.dart';
import 'package:clinic_admin/doctor/data/doctor_service.dart';
import 'package:clinic_admin/doctor/model/doctor_model.dart';

class DoctorEditPage extends StatefulWidget {
  final DoctorModel doctor;

  DoctorEditPage({Key? key, required this.doctor}) : super(key: key);

  @override
  _DoctorEditPageState createState() => _DoctorEditPageState();
}

class _DoctorEditPageState extends State<DoctorEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _selectedSpecialty;
  late Map<String, List<String>> _availableSlots;

  final DoctorService _doctorService = DoctorService();

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
    _nameController.text = widget.doctor.name;
    _selectedSpecialty = widget.doctor.specialty;
    _availableSlots = Map.from(widget.doctor.availableSlots);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Doctor')),
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
              onPressed: _submitForm,
              child: Text('Update Doctor'),
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
                bool isSelected = _availableSlots[day]?.contains(slot) ?? false;
                return FilterChip(
                  label: Text(slot),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _availableSlots[day] = [
                          ...(_availableSlots[day] ?? []),
                          slot
                        ];
                      } else {
                        _availableSlots[day] = (_availableSlots[day] ?? [])
                          ..remove(slot);
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedDoctor = DoctorModel(
          id: widget.doctor.id,
          name: _nameController.text,
          specialty: _selectedSpecialty,
          availableSlots: _availableSlots,
        );

        await _doctorService.updateDoctor(updatedDoctor);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor updated successfully')),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update doctor. Please try again.')),
        );
      }
    }
  }
}
