import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddProductToCategory extends StatefulWidget {
  final String catName;

  const AddProductToCategory({required this.catName, Key? key}) : super(key: key);

  @override
  State<AddProductToCategory> createState() => _AddProductToCategoryState();
}

class _AddProductToCategoryState extends State<AddProductToCategory> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<String> selectedIdProduct = [];

  List<bool> _isChecked = [];

  bool isLoading = false;

  emptySelectedProduct() {
    selectedIdProduct.clear();
  }

  addProductToList(String id) {
    selectedIdProduct.add(id);
    //print('Data sementara dari fungsi : $selectedIdProduct');
  }

  removeProductFromList(String id) {
    selectedIdProduct.remove(id);
  }

  save() {
    setState(() {
      isLoading = true;
    });

    CollectionReference product = firestore.collection('products');

    for (var id in selectedIdProduct) {
      product.doc(id).update({
        'dateModified': FieldValue.serverTimestamp(),
        'category': widget.catName,
      });
    }

    emptySelectedProduct();

    Navigator.pop(context);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool?> _onBackPressed() async {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              title: Text(
                "Perhatian",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              content: Text(
                "Apakah anda yakin ingin kembali? Data yang sudah ada tidak akan disimpan",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    emptySelectedProduct();
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    "Ya",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    "Tidak",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ));
  }

  Future<AggregateQuerySnapshot> countProductInCategory() async {
    var countQuery = await firestore
        .collection('products')
        .where('category', isEqualTo: "")
        .count()
        .get();
    //print('Jumlah : ${countQuery.count}');
    return countQuery;
  }

  inisiasiCheckedProduct() async {
    var hasil;
    await countProductInCategory().then((value) => hasil = value.count);

    _isChecked = List<bool>.filled(hasil, false);
    //print('Hasil : $_isChecked');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    inisiasiCheckedProduct();
  }

  @override
  Widget build(BuildContext context) {
    //CollectionReference category = firestore.collection('categories');
    CollectionReference product = firestore.collection('products');

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (isLoading) {
            return false;
          } else {
            final shouldPop = await _onBackPressed();
            return shouldPop ?? false;
          }
        },
        child: isLoading
            ? const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: Colors.black),
                  elevation: 0,
                  title: Text(
                    'Add Product To Category',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 16),
                  ),
                ),
                body: StreamBuilder<QuerySnapshot>(
                  stream: product
                      .orderBy("dateModified", descending: true)
                      .where('category', isEqualTo: '')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (_, index) {
                          var ds = snapshot.data?.docs[index];

                          return CheckboxListTile(
                              title: Text(
                                '${(ds!.data() as Map<String, dynamic>)["name"]}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              value: _isChecked.isNotEmpty
                                  ? _isChecked[index]
                                  : false,
                              onChanged: (newValue) {
                                setState(() {
                                  _isChecked[index] = newValue!;
                                  if (_isChecked[index]) {
                                    var id = ds.id;
                                    //print('ini id yang di klik ${ds.id}');

                                    addProductToList(id);

                                    //selectedIdProduct?.add(ds.id);

                                  } else {
                                    removeProductFromList(ds.id);
                                  }
                                  /*print('Checked setelah di klik : $_isChecked');
                                  print('Isi Produk yang dipilih : $_isChecked');
                                  print('Data sementara $selectedIdProduct');*/
                                });
                              });
                        },
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const Center(
                        child: Text('eror'),
                      );
                    }
                  },
                ),
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.all(12),
                  child: InkWell(
                    onTap: selectedIdProduct.isEmpty
                        ? null
                        : () {
                            save();
                          },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: selectedIdProduct.isEmpty
                            ? Colors.grey
                            : Colors.orangeAccent,
                      ),
                      child: Center(
                        child: Text(
                          'Simpan',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
