import 'package:admin_surya_mart_v1/presentation/page/add_product_to_category.dart';
import 'package:admin_surya_mart_v1/presentation/widget/product_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductInCategoryPage extends StatefulWidget {
  final String idCategory;
  final String catName;

  const ProductInCategoryPage(
      {required this.catName, required this.idCategory, Key? key})
      : super(key: key);

  @override
  State<ProductInCategoryPage> createState() => _ProductInCategoryPageState();
}

class _ProductInCategoryPageState extends State<ProductInCategoryPage> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference product = firestore.collection('products');

    bool isLoading = false;

    updateCategoryProduct(String id) async {
      setState(() {
        isLoading = true;
      });

      CollectionReference product = firestore.collection('products');

      product.doc(id).update({
        'category': "",
      });

      setState(() {
        isLoading = false;
      });
    }

    return SafeArea(
      child: isLoading
          ? const Scaffold(body: CircularProgressIndicator())
          : Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black),
                elevation: 0,
                title: Text(widget.catName,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 16)),
              ),
              body: StreamBuilder<QuerySnapshot>(
                  stream: product
                      .orderBy("dateModified", descending: true)
                      .where('category', isEqualTo: widget.catName)
                      .snapshots(),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState ==
                        ConnectionState.active) {
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Belum ada produk! klik ikon di pojok kanan bawah untuk menambahkan produk kedalam kategori',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else {
                        return ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              var ds = snapshot.data?.docs[index];

                              return Slidable(
                                  //key: Key(ds!.id),
                                  endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            setState(() {
                                              updateCategoryProduct(ds!.id);
                                            });
                                          },
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Delete',
                                        ),
                                      ]),
                                  child: ProductCard(ds: ds));
                            });
                      }
                    } else {
                      return const Center(
                        child: Text('eror'),
                      );
                    }
                  }),
              floatingActionButton: FloatingActionButton(
                backgroundColor:  const Color(0xff0B607E),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddProductToCategory(
                              catName: widget.catName,
                            )),
                  );

                  //showAvailabelProduct();
                },
                child: const Icon(Icons.add),
              ),
            ),
    );
  }
}
