import 'package:cloud_firestore/cloud_firestore.dart';

class Products {
  String name;
  String description;
  String image;
  String category;
  int sold;
  int stock;
  int price;
  Timestamp dateCreated;
  Timestamp dateModified;

  Products({
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.sold,
    required this.stock,
    required this.price,
    required this.dateCreated,
    required this.dateModified,
  });
}
