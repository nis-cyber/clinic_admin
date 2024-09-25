import 'dart:io';

import 'package:clinic_admin/medical_record/data/report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseMedicalServiceProvider =
    Provider((ref) => FirebaseMedicalService());

class FirebaseMedicalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> submitMedicalReport({
    required String patientName,
    required String patientId,
    required String doctorName,
    required DateTime checkupDate,
    required String diagnosis,
    required String treatment,
    required String medications,
    required String followUpInstructions,
    String? additionalNotes,
    File? reportImage,
    required String patientAddress,
    required String patientEmail,
    required String patientPhone,
  }) async {
    try {
      DocumentReference reportRef =
          await _firestore.collection('medicalReports').add({
        'patientName': patientName,
        'patientId': patientId,
        'doctorName': doctorName,
        'checkupDate': checkupDate,
        'diagnosis': diagnosis,
        'treatment': treatment,
        'medications': medications,
        'followUpInstructions': followUpInstructions,
        'additionalNotes': additionalNotes,
        'createdAt': FieldValue.serverTimestamp(),
        'patientAddress': patientAddress,
        'reportImage': reportImage,
        'patientPhone': patientPhone,
      });

      if (reportImage != null) {
        String fileName = '${reportRef.id}_report_image.jpg';
        Reference storageRef = _storage.ref().child('report_images/$fileName');
        await storageRef.putFile(reportImage);
        String imageUrl = await storageRef.getDownloadURL();

        // Update the document with the image URL
        await reportRef.update({'reportImageUrl': imageUrl});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting medical report: $e');
      }
      rethrow;
    }
  }

  // Future<String> _uploadImage(File image, String name, DateTime dob) async {
  //   try {
  //     String fileName =
  //         '${name.replaceAll(' ', '_')}_${dob.toIso8601String()}.jpg';
  //     Reference ref = _storage.ref('medical_images/$fileName');
  //     UploadTask uploadTask = ref.putFile(image);
  //     TaskSnapshot snapshot = await uploadTask;
  //     String downloadUrl = await snapshot.ref.getDownloadURL();
  //     return downloadUrl;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error uploading image: $e');
  //     }
  //     rethrow;
  //   }
  // }

  Stream<List<MedicalRecord>> getMedicalRecords() {
    return _firestore
        .collection('medicalReports')
        .orderBy('checkupDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalRecord.fromFirestore(doc))
            .toList());
  }

  Future<MedicalRecord> getMedicalRecordById(String id) async {
    DocumentSnapshot doc =
        await _firestore.collection('medicalReports').doc(id).get();
    return MedicalRecord.fromFirestore(doc);
  }
}

final medicalRecordsProvider = StreamProvider<List<MedicalRecord>>((ref) {
  final repository = FirebaseMedicalService();
  return repository.getMedicalRecords();
});

final medicalRecordProvider =
    FutureProvider.family<MedicalRecord, String>((ref, id) async {
  final repository = FirebaseMedicalService();
  return repository.getMedicalRecordById(id);
});
