import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final String id;
  const ProductCard(this.id, {Key? key}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  String id = '';
  String? name, description, category, image;
  int? stock, price, weight;

  FirebaseFirestore? firestore;
  CollectionReference? product;

  @override
  void initState() {
    super.initState();
    id = widget.id;

    firestore = FirebaseFirestore.instance;
    product = firestore!.collection('product');

    getData();
  }

  void getData() {
    product?.doc(id).get().then((value) {
      name = value.get('name');
      price = value.get('price');
      stock = value.get('stock');
      image = value.get('image');
      description = value.get('description');
      weight = value.get('weight');
      category = value.get('category');
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: Row(
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14), bottom: Radius.circular(14)),
                child: image == null
                    ? Image.network(
                        'https://th.bing.com/th/id/OIP.r4eciF-FM2-3WdhvxTmGEgHaHa?pid=ImgDet&rs=1')
                    : Image.network(
                        image ?? '',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    Text(name!),
                    Text(price.toString()),
                  ],
                ),
                Text(description!),
                Text(category!),
                Text(stock.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
