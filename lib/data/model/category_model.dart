import 'package:cloud_firestore/cloud_firestore.dart';

class Categories {
  String name;
  Timestamp dateCreated;
  Timestamp dateModified;

  Categories({
    required this.name,
    required this.dateCreated,
    required this.dateModified,
  });
}
