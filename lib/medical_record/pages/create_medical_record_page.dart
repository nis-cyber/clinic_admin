import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class InputReportPage extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final String userName;
  final String userPhone;
  final String speciality;
  final String date;
  final String timeSlot;
  final String userId;

  InputReportPage({
    required this.appointmentId,
    required this.doctorName,
    required this.userName,
    required this.userPhone,
    required this.speciality,
    required this.date,
    required this.timeSlot,
    required this.userId,
  });

  @override
  _InputReportPageState createState() => _InputReportPageState();
}

class _InputReportPageState extends State<InputReportPage> {
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  File? _selectedFile;
  String? _uploadedImageUrl;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    try {
      String fileName =
          'reports/${widget.userName}_${DateTime.now().millisecondsSinceEpoch}';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = storageReference.putFile(_selectedFile!);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _uploadedImageUrl = downloadUrl;
      });

      print('File uploaded successfully! Download URL: $_uploadedImageUrl');
    } catch (e) {
      print('Error uploading file: $e');
      setState(() {
        _uploadedImageUrl = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _submitReport() async {
    if (_diagnosisController.text.isEmpty ||
        _treatmentController.text.isEmpty ||
        _medicationsController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('medical_reports').add({
      'appointment_id': widget.appointmentId,
      'doctor_name': widget.doctorName,
      'userId': widget.userId,
      'user_name': widget.userName,
      'user_phone': widget.userPhone,
      'date': widget.date,
      'time_slot': widget.timeSlot,
      'diagnosis': _diagnosisController.text,
      'treatment': _treatmentController.text,
      'medications': _medicationsController.text,
      'comments': _commentsController.text,
      'speciality': widget.speciality,
      'image_url': _uploadedImageUrl,
      'timestamp': Timestamp.now(),
    });

    _diagnosisController.clear();
    _treatmentController.clear();
    _medicationsController.clear();
    _commentsController.clear();
    setState(() {
      _selectedFile = null;
      _uploadedImageUrl = null;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 173, 205, 204)!,
        title: Text(
          'Add Report for ${widget.userName}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF3F4F6), // Light gray background
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title
                const Text(
                  'Patient Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151), // Dark Gray
                  ),
                ),
                const SizedBox(height: 8),
                // Patient Info
                _buildInfoRow('Doctor', widget.doctorName),
                _buildInfoRow('Patient', widget.userName),
                _buildInfoRow('Phone', widget.userPhone),
                _buildInfoRow('Speciality', widget.speciality),
                _buildInfoRow('Date', widget.date),
                _buildInfoRow('Time Slot', widget.timeSlot),
                const SizedBox(height: 16),

                // Diagnosis Input Field
                _buildInputField(
                  label: 'Diagnosis',
                  controller: _diagnosisController,
                ),
                const SizedBox(height: 16),

                // Treatment Input Field
                _buildInputField(
                  label: 'Treatment',
                  controller: _treatmentController,
                ),
                const SizedBox(height: 16),

                // Medications Input Field
                _buildInputField(
                  label: 'Medications',
                  controller: _medicationsController,
                ),
                const SizedBox(height: 16),

                // Comments Input Field
                _buildInputField(
                  label: 'Comments (optional)',
                  controller: _commentsController,
                ),
                const SizedBox(height: 16),

                // Upload Image/Document Button
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color.fromARGB(255, 173, 205, 204), // Teal Button
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.attach_file, color: Colors.white),
                    label: const Text(
                      '   Attach Image/Document   ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                if (_selectedFile != null)
                  Text(
                    'Selected File: ${_selectedFile!.path.split('/').last}',
                    style:
                        const TextStyle(color: Color(0xFF374151)), // Dark Gray
                  ),
                const SizedBox(height: 10),

                // Upload Button
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _selectedFile != null ? _uploadFile : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 173, 205, 204),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '   Upload File   ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Report Button
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_uploadedImageUrl == null && _selectedFile != null) {
                        await _uploadFile();
                      }
                      _submitReport();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 173, 205, 204),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      '   Submit Report   ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 170),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151), // Dark Gray
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF757575), // Muted Gray for values
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF0288D1), // Teal for labels
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0288D1)), // Teal border
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
