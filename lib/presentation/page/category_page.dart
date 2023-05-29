import 'package:admin_surya_mart_v1/presentation/page/add_category.dart';
import 'package:admin_surya_mart_v1/presentation/page/edit_category.dart';
import 'package:admin_surya_mart_v1/presentation/page/product_in_category_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryProductState();
}

class _CategoryProductState extends State<CategoryPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference category = firestore.collection('categories');
    CollectionReference product = firestore.collection('products');

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

    void onDeleteCollection(String id, String categoryName) async {
      await category.doc(id).delete().whenComplete(
            () => product.where('category', isEqualTo: categoryName).get().then(
                  (value) {

                    for (var element in value.docs) {
                      updateCategoryProduct(element.id);
                    }
                  }
                ),
          );
    }

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0,
            title: Text('Manage Category',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 16)),
          ),
          body: StreamBuilder<QuerySnapshot>(
              stream: category
                  .orderBy("dateModified", descending: true)
                  .snapshots(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.none) {
                  return const Icon(Icons.hourglass_empty_rounded);
                } else if (snapshot.connectionState == ConnectionState.active) {
                  return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        var ds = snapshot.data?.docs[index];

                        return Card(
                          child: Slidable(
                            endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditCategory(ds),
                                        ),
                                      );
                                    },
                                    backgroundColor: const Color(0xFF7BC043),
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: 'Edit',
                                  ),
                                  SlidableAction(
                                    onPressed: (context) {
                                      onDeleteCollection(
                                          ds!.id,
                                          (ds.data()
                                              as Map<String, dynamic>)["name"]);
                                    },
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                ]),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: product
                                  .where('category',
                                      isEqualTo: (ds!.data()
                                          as Map<String, dynamic>)["name"])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.active) {
                                  return ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductInCategoryPage(
                                            catName: (ds.data() as Map<String,
                                                dynamic>)["name"],
                                            idCategory: ds.id,
                                          ),
                                        ),
                                      );
                                    },
                                    title: Text(
                                      '${(ds.data() as Map<String, dynamic>)["name"]}',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      '${snapshot.data!.docs.length} produk',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w300),
                                    ),
                                  );
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            ),
                          ),
                        );
                      });
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xff0B607E),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCategory()),
              );
            },
            child: const Icon(Icons.add),
          )),
    );
  }
}
