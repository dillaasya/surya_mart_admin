import 'dart:io';

import 'package:admin_surya_mart_v1/data/model/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  bool isLoading = false;

  File? _imagePath;
  String? _urlItemImage;

  String? category = '';

  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  getImageFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = File(image.path);
      });
    }
  }

  _uploadProduct() async {
    setState(() {
      isLoading = true;
    });

    if (_imagePath != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = storage.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(_imagePath!);
      //uploadTask.snapshotEvents.listen((event) {});

      await uploadTask.whenComplete(() async {
        _urlItemImage = await uploadTask.snapshot.ref.getDownloadURL();

        if (_urlItemImage!.isNotEmpty) {
          //print("URL : $_urlItemImage");

          CollectionReference product = firestore.collection('products');
          product.add({
            'name': nameController.text,
            'description': descriptionController.text,
            'price': int.tryParse(priceController.text) ?? 0,
            'stock': int.tryParse(stockController.text) ?? 0,
            'weight': int.tryParse(weightController.text) ?? 0,
            'dateModified': FieldValue.serverTimestamp(),
            'dateCreated': FieldValue.serverTimestamp(),
            'sold': 0,
            'image': _urlItemImage,
            'category': category ?? '',
          });
        } else {
          _showMessage("Something When Wrong While Uploading Image");
        }
      });
    } else {
      CollectionReference product = firestore.collection('products');
      product.add({
        'name': nameController.text,
        'description': descriptionController.text,
        'price': int.tryParse(priceController.text) ?? 0,
        'stock': int.tryParse(stockController.text) ?? 0,
        'weight': int.tryParse(weightController.text) ?? 0,
        'dateCreated': FieldValue.serverTimestamp(),
        'dateModified': FieldValue.serverTimestamp(),
        'sold': 0,
        'image': _urlItemImage,
        'category': category ?? '',
      });
    }

    setState(() {
      isLoading = false;
    });
    //showDialogSuccess();
    Navigator.pop(context);
  }

  _showMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  Future<bool?> _onBackPressed() async {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          content: Text(
            "Are you sure you want to exit the app?",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:  const Color(0xff0B607E),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                "Yes",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:  const Color(0xff0B607E),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                "No",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Categories>> getListCategory() async {
    QuerySnapshot snapshot = await firestore.collection('categories').get();

    return snapshot.docs
        .map(
          (e) => Categories(
            name: e.get('name'),
            dateCreated: e.get('dateCreated'),
            dateModified: e.get('dateModified'),
          ),
        )
        .toList();
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
                  title: Text('Add New Product',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 16)),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      autovalidateMode: AutovalidateMode.always,
                      key: _formKeyValue,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: _imagePath != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.file(_imagePath!))
                                  : TextButton(
                                      child: const Icon(
                                        Icons.add_a_photo,
                                        size: 50,
                                      ),
                                      onPressed: () async {
                                        await getImageFromGallery();

                                        setState(() {});
                                      },
                                    ),
                            ),
                          ),
                          Text(
                              'Product name',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isNotEmpty && value.length > 2) {
                                  return null;
                                } else if (value.length < 5 &&
                                    value.isNotEmpty) {
                                  return 'Your product name is too short!';
                                } else {
                                  return 'It can\'t be empty!';
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
                          Text(
                              'Description',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'It can\'t be empty!';
                                }
                              },
                              style: GoogleFonts.poppins(),
                              controller: descriptionController,
                              maxLines: 7,
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
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                          Text(
                              'Price',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 20),
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'It can\'t be empty!';
                                }
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(7),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (val){
                                if(val.characters.characterAt(0) == Characters("0") && val.length > 1){
                                  stockController.text = val.substring(1);
                                  stockController.selection = TextSelection.collapsed(offset: stockController.text.length);
                                }
                              },
                              style: GoogleFonts.poppins(),
                              controller: priceController,
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
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Text(
                              'Stock',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'It can\'t be empty!';
                                }
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(4),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (val){
                                if(val.characters.characterAt(0) == Characters("0") && val.length > 1){
                                  stockController.text = val.substring(1);
                                  stockController.selection = TextSelection.collapsed(offset: stockController.text.length);
                                }
                              },
                              style: GoogleFonts.poppins(),
                              controller: stockController,
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
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Text(
                              'Weight (gr/ml)',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'It can\'t be empty!';
                                }
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(4),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (val){
                                if(val.characters.characterAt(0) == Characters("0") && val.length > 1){
                                  stockController.text = val.substring(1);
                                  stockController.selection = TextSelection.collapsed(offset: stockController.text.length);
                                }
                              },
                              style: GoogleFonts.poppins(),
                              controller: weightController,
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
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Text(
                              'Category',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300),
                            ),
                          FutureBuilder(
                            future: getListCategory(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                var x = snapshot.data;
                                //var y= x!.map((e) => e.name);
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8, bottom: 20),
                                  child: DropdownButtonFormField<String>(
                                    icon: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.black.withOpacity(0.25),
                                        size: 20,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      //labelText: "Kategori",
                                      border: InputBorder.none,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        borderSide: const BorderSide(
                                          color: Colors.deepOrangeAccent,
                                          width: 1.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 1.0,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 1.0,
                                        ),
                                      ),
                                      filled: false,
                                      contentPadding: const EdgeInsets.only(
                                          left: 24.0, right: 24),
                                    ),
                                    value: category!.isEmpty ? null : category,
                                    onChanged: (newValue) {
                                      setState(() {
                                        category = newValue;
                                      });
                                    },
                                    items: x
                                        ?.map(
                                          (e) => DropdownMenuItem<String>(
                                            value: e.name,
                                            child: Text(e.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w300),),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                );
                              } else if (snapshot.connectionState ==
                                  ConnectionState.none) {
                                return const Text('EROR');
                              } else if (snapshot.connectionState ==
                                  ConnectionState.active) {
                                return const Center(
                                  child: Text('Ups there is something wrong'),
                                );
                              } else if (snapshot.connectionState ==
                                  ConnectionState.none) {
                                return const Text('Eror');
                              } else {
                                var x = snapshot.data;
                                var y = x?.map((e) => e.name) ?? '';
                                return Text('value : $y');
                              }
                            },
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
                                            _uploadProduct();
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
