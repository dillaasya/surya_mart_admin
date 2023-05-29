import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditArticle extends StatefulWidget {
  final QueryDocumentSnapshot<Object?>? article;

  const EditArticle(this.article, {Key? key}) : super(key: key);

  @override
  State<EditArticle> createState() => _EditArticleState();
}

class _EditArticleState extends State<EditArticle> {
  final GlobalKey<FormState> _formKeyValue = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController overviewController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false;

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

  void saveEdit() {
    setState(() {
      isLoading = true;
    });
    String newTitle = titleController.text;
    String newOverview = overviewController.text;
    String newLink = linkController.text;

    String id = widget.article!.id;
    //print("udah kepanggil");
    CollectionReference article = firestore.collection('articles');
    article.doc(id).update({
      'title': newTitle,
      'overview': newOverview,
      'link': newLink,
      'dateModified': FieldValue.serverTimestamp(),
    });

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    titleController.text =
        (widget.article!.data() as Map<String, dynamic>)["title"];
    overviewController.text =
        (widget.article!.data() as Map<String, dynamic>)["overview"];
    linkController.text =
        (widget.article!.data() as Map<String, dynamic>)["link"];
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
                      title: Text('Edit Article',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 16)),
                    ),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Form(
                                key: _formKeyValue,
                                autovalidateMode: AutovalidateMode.always,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Title',
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
                                            return 'Your title is too short!';
                                          } else {
                                            return 'It can\'t be empty!';
                                          }
                                        },
                                        style: GoogleFonts.poppins(),
                                        controller: titleController,
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
                                      'Summary',
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
                                            return 'The summary is too short!';
                                          } else {
                                            return 'It can\'t be empty!';
                                          }
                                        },
                                        style: GoogleFonts.poppins(),
                                        controller: overviewController,
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
                                            return 'Please enter a valid link!';
                                          } else {
                                            return 'It can\'t be empty!';
                                          }
                                        },
                                        style: GoogleFonts.poppins(),
                                        controller: linkController,
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
                          ],
                        ),
                      ),
                    ),
                  )));
  }
}
