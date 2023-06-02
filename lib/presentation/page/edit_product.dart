import 'dart:io';

import 'package:admin_surya_mart_v1/data/model/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditProduct extends StatefulWidget {
  final QueryDocumentSnapshot<Object?>? product;

  const EditProduct(this.product, {Key? key}) : super(key: key);

  @override
  State<EditProduct> createState() => _EditPageState();
}

class _EditPageState extends State<EditProduct> {
  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  String? image;
  String? category;

  bool isLoading = false;

  File? _imagePath;
  String? _urlItemImage;

  String id = "";

  String? newName, newDescription, newImage;
  int? newPrice, newStock, newWeight;

  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    nameController.text =
        (widget.product!.data() as Map<String, dynamic>)["name"];
    descriptionController.text =
        (widget.product!.data() as Map<String, dynamic>)["description"];
    category = (widget.product!.data() as Map<String, dynamic>)["category"];
    stockController.text =
        (widget.product!.data() as Map<String, dynamic>)["stock"].toString();
    weightController.text =
        (widget.product!.data() as Map<String, dynamic>)["weight"].toString();
    priceController.text =
        (widget.product!.data() as Map<String, dynamic>)["price"].toString();
    image = (widget.product!.data() as Map<String, dynamic>)["image"];
    id = widget.product!.id;
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
                    backgroundColor: const Color(0xff0B607E),
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
                    backgroundColor: const Color(0xff0B607E),
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

  getImageFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = File(image.path);
        //_imageTemporary = File(_image.path).toString();
      });
    }
  }

  Widget gambarSebelumnyaAda() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        //color: Colors.yellow,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: MediaQuery.of(context).size.width / 2 - 60,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: image == null
                      ? const CircularProgressIndicator()
                      : Image.network(
                          image.toString(),
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 60,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: _imagePath != null
                      ? Image.file(
                          _imagePath!,
                          fit: BoxFit.cover,
                          width: 100,
                        )
                      : const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.black,
                        ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: MediaQuery.of(context).size.width / 2 + 10,
              child: _imagePath == null
                  ? Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey[200],
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await getImageFromGallery();

                          setState(() {});
                        },
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.grey[800],
                        ),
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey[200],
                      ),
                      child: IconButton(
                        onPressed: () {
                          _imagePath = null;

                          setState(() {});
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget gambarSebelumnyaKosong() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        //color: Colors.yellow,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: _imagePath != null
                      ? Image.file(
                          _imagePath!,
                          fit: BoxFit.cover,
                          width: 100,
                        )
                      : const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.black,
                        ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: MediaQuery.of(context).size.width / 2,
              child: _imagePath == null
                  ? Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey[200],
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await getImageFromGallery();

                          setState(() {});
                        },
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.grey[800],
                        ),
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey[200],
                      ),
                      child: IconButton(
                        onPressed: () {
                          _imagePath = null;

                          setState(() {});
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  saveEdit() async {
    setState(() {
      isLoading = true;
    });

    newName = nameController.text;
    newDescription = descriptionController.text;
    newPrice = int.tryParse(priceController.text);
    newStock = int.tryParse(stockController.text);
    newWeight = int.tryParse(weightController.text);
    //newCategory = categoryController.text;

    if (image != null) {
      if (_imagePath != null) {
        Reference reference = storage.refFromURL(image!);
        var updateImage = reference.putFile(_imagePath!);
        //uploadTask.snapshotEvents.listen((event) {});

        await updateImage.whenComplete(() async {
          _urlItemImage = await updateImage.snapshot.ref.getDownloadURL();

          if (_urlItemImage!.isNotEmpty) {
            //print("URL : $_urlItemImage");

            CollectionReference product = firestore.collection('products');

            product.doc(id).update({
              'name': newName,
              'description': newDescription,
              'price': newPrice,
              'stock': newStock,
              'dateModified': FieldValue.serverTimestamp(),
              'sold': 0,
              'image': _urlItemImage,
              'category': category,
            });
          } else {
            //_showMessage("Something When Wrong While Uploading Image");
          }
        });
      } else {
        CollectionReference product = firestore.collection('products');

        product.doc(id).update({
          'name': newName,
          'description': newDescription,
          'price': newPrice,
          'stock': newStock,
          'dateModified': FieldValue.serverTimestamp(),
          'sold': 0,
          'category': category,
        });
      }
      //String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    } else {
      if (_imagePath != null) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference reference = storage.ref().child(fileName);
        UploadTask uploadTask = reference.putFile(_imagePath!);

        await uploadTask.whenComplete(() async {
          _urlItemImage = await uploadTask.snapshot.ref.getDownloadURL();

          if (_urlItemImage!.isNotEmpty) {
            CollectionReference product = firestore.collection('products');
            product.doc(id).update({
              'name': newName,
              'description': newDescription,
              'price': newPrice,
              'stock': newStock,
              //'tingkat kesulitan': tingkatKesulitan,
              'dateModified': FieldValue.serverTimestamp(),
              'sold': 0,
              'image': _urlItemImage,
              'category': category,
            });
          } else {}
        });
      } else {
        CollectionReference product = firestore.collection('products');

        product.doc(id).update({
          'name': newName,
          'description': newDescription,
          'price': newPrice,
          'stock': newStock,
          'dateModified': FieldValue.serverTimestamp(),
          'sold': 0,
          'category': category,
        });
      }
    }

    setState(() {
      isLoading = false;
    });
    if (mounted) {
      Navigator.pop(context);
    }
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
                  title: Text('Edit Product',
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
                          image != null
                              ? gambarSebelumnyaAda()
                              : gambarSebelumnyaKosong(),
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
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[a-zA-Z|\\ ]')),
                              ],
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
                              onChanged: (val) {
                                if (val.isNotEmpty) {
                                  if (val.characters.characterAt(0) ==
                                          Characters("0") &&
                                      val.length > 1) {
                                    priceController.text = val.substring(1);
                                    priceController.selection =
                                        TextSelection.collapsed(
                                            offset:
                                                stockController.text.length);
                                  }
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
                              onChanged: (val) {
                                if (val.isNotEmpty) {
                                  if (val.characters.characterAt(0) ==
                                          Characters("0") &&
                                      val.length > 1) {
                                    stockController.text = val.substring(1);
                                    stockController.selection =
                                        TextSelection.collapsed(
                                            offset:
                                                stockController.text.length);
                                  }
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
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (val) {
                                if (val.isNotEmpty) {
                                  if (val.characters.characterAt(0) ==
                                          Characters("0") &&
                                      val.length > 1) {
                                    weightController.text = val.substring(1);
                                    weightController.selection =
                                        TextSelection.collapsed(
                                            offset:
                                                stockController.text.length);
                                  }
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
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 20),
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
                                            child: Text(
                                              e.name,
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w300),
                                            ),
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
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                  side: const BorderSide(
                                                      color:
                                                          Color(0XFFFFC33A))))),
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
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
