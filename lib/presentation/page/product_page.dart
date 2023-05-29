import 'package:admin_surya_mart_v1/presentation/page/add_product.dart';
import 'package:admin_surya_mart_v1/presentation/page/detail_page.dart';
import 'package:admin_surya_mart_v1/presentation/page/edit_product.dart';
import 'package:admin_surya_mart_v1/presentation/widget/product_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference product = firestore.collection('products');

    void onDeleteCollection(String id) async {
      await product.doc(id).delete();
    }

    void onDeleteImage(String ref) async {
      Reference reference = FirebaseStorage.instance.refFromURL(ref);
      await reference.delete();
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text('Manage Products',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 16)),
        ),
        body: Center(
          child: StreamBuilder<QuerySnapshot>(
              stream:
                  product.orderBy("dateModified", descending: true).snapshots(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        var ds = snapshot.data?.docs[index];
                        return Slidable(
                          endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditProduct(ds)),
                                    );
                                  },
                                  backgroundColor: const Color(0xFF7BC043),
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Edit',
                                ),
                                SlidableAction(
                                  onPressed: (context) {
                                    setState(() {
                                      if ((ds!.data() as Map<String,
                                              dynamic>)["image"] !=
                                          null) {
                                        onDeleteImage((ds.data() as Map<
                                                String, dynamic>)["image"]
                                            .toString());
                                        onDeleteCollection(ds.id);
                                      } else {
                                        onDeleteCollection(ds.id);
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ]),
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailPage(
                                          idProduct: ds!.id,
                                          stockProduct: ds['stock'],
                                          category: ds['category'])),
                                );
                              },
                              child: ProductCard(ds: ds),),
                        );
                      });
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProduct()),
            );
          },
          backgroundColor: const Color(0xff0B607E),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
