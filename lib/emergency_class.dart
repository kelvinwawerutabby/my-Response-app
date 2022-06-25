import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class EmergencyClass {
  createAnEmergency({
    required String description,
    required numberOfPeople,
  }) async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    UploadTask task = FirebaseStorage.instance
        .ref(DateTime.now().toString())
        .putFile(File(image!.path));
    var url = await (await task.whenComplete(() => print('Upload complete')))
        .ref
        .getDownloadURL();
    var location = await Location.instance.getLocation();

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User user = _auth.currentUser!;
    final String uid = user.uid;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final DocumentReference ref = _firestore.collection('Emergencies').doc();
    final Map<String, dynamic> emergency = {
      'description': description,
      'numberOfPeople': numberOfPeople,
      'uid': uid,
      'image': url,
      'location': GeoPoint(location.latitude!, location.longitude!),
      'timestamp': DateTime.now(),
    };
    await ref.set(emergency);
  }
}
