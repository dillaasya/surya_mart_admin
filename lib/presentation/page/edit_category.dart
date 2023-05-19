import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditCategory extends StatefulWidget {
  final QueryDocumentSnapshot<Object?>? category;

  const EditCategory(this.category, {Key? key}) : super(key: key);

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String newName = '';
  bool isLoading = false;

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
  
  setName() {
    setState(() {
      newName = nameController.text;
    });
  }

  void saveEdit() {
    setState(() {
      isLoading = true;
    });

    setName();
    String id = widget.category!.id;

    CollectionReference category = firestore.collection('categories');
    CollectionReference product = firestore.collection('products');

    product
        .where('category',
            isEqualTo:
                (widget.category!.data() as Map<String, dynamic>)["name"])
        .get()
        .then(
          (value) => value.docs.forEach((element) {
            updateCategoryProduct(element.id);
          }),
        )
        .whenComplete(() => category.doc(id).update({
              'name': newName,
              'dateModified': FieldValue.serverTimestamp(),
            }));
    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  updateCategoryProduct(String id) async {
    CollectionReference product = firestore.collection('products');

    product.doc(id).update({
      'category': newName,
    });
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController.text =
        (widget.category!.data() as Map<String, dynamic>)["name"];
  }

  @override
  Widget build(BuildContext context) {
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
                  title: Text('Add New Category',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 16)),
                ),
              body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                            key: _formKeyValue,
                            autovalidateMode: AutovalidateMode.always,
                            child: Column(
                              
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                              'Nama Kategori',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 20),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isNotEmpty && value.length > 2) {
                                    return null;
                                  } else if (value.length < 5 &&
                                      value.isNotEmpty) {
                                    return 'Nama kategori anda terlalu singkat!';
                                  } else {
                                    return 'Tidak boleh kosong!';
                                  }
                                },
                                style: GoogleFonts.poppins(),
                                controller: nameController,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    borderSide: const BorderSide(
                                      color: Colors.deepOrangeAccent,
                                      width: 1.0,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                      left: 24, top: 18, bottom: 18, right: 24),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                                const EdgeInsets.only(
                                                    top: 18, bottom: 18)),
                                            backgroundColor:
                                                MaterialStateProperty.all<Color>(
                                                    const Color(0XFFFFC33A)),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
                                                    side: const BorderSide(color: Color(0XFFFFC33A))))),
                                        child: Text(
                                          'Save',
                                          style: GoogleFonts.poppins(
                                              color: Colors.grey.shade800,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        onPressed: () {
                                          if (_formKeyValue.currentState!
                                              .validate()) {
                                            saveEdit();
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            ),
                              ],
                            )),
                      ),
                    ),
            )));
  }
}
