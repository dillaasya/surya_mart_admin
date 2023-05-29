import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddArticle extends StatefulWidget {
  const AddArticle({Key? key}) : super(key: key);

  @override
  State<AddArticle> createState() => _AddArticleState();
}

class _AddArticleState extends State<AddArticle> {
  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController overviewController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

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
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  const Color(0xff0B607E),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  const Color(0xff0B607E),
                  ),
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

  _uploadArticle() {
    setState(() {
      isLoading = true;
    });

    CollectionReference category = firestore.collection('articles');
    category.add({
      "title": titleController.text,
      'overview': overviewController.text,
      'link': linkController.text,
      'dateModified': FieldValue.serverTimestamp(),
      'dateCreated': FieldValue.serverTimestamp(),
    });

    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
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
                  title: Text('Add New Article',
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
                              'Judul Artikel',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300),
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
                                controller: titleController,
                                decoration: InputDecoration(
                                  /* label: Text('Judul'),
                                  hintText: "Judul artikel", */
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
                              'Ringkasan Artikel',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 20),
                              child: TextFormField(
                                maxLines: 3,
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
                                controller: overviewController,
                                decoration: InputDecoration(
                                  /* label: Text('Overview'),
                                  hintText: "Sinopsis artikel", */
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
                              'Link',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300),
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
                                controller: linkController,
                                decoration: InputDecoration(
                                  /* label: Text('Link'),
                                  hintText: "Link artikel", */
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
                                            _uploadArticle();
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
              ),
      ),
    );
  }
}
