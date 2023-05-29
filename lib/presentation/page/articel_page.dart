import 'package:admin_surya_mart_v1/presentation/page/add_article.dart';
import 'package:admin_surya_mart_v1/presentation/page/edit_article.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/link.dart';

class ArticlePage extends StatefulWidget {
  const ArticlePage({Key? key}) : super(key: key);

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference article = firestore.collection('articles');

    void onDeleteCollection(String id) async {
      await article.doc(id).delete();
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text('Manage Articles',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 16)),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream:
                article.orderBy("dateModified", descending: true).snapshots(),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      var ds = snapshot.data?.docs[index];
                      return Link(
                        uri: Uri.parse(
                            (ds!.data() as Map<String, dynamic>)["link"]),
                        builder: (context, followLink) {
                          return InkWell(
                            onTap: followLink,
                            child: Slidable(
                              endActionPane:
                                  ActionPane(motion: const ScrollMotion(), children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditArticle(ds)),
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
                                      onDeleteCollection(ds.id);
                                    });
                                  },
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ]),
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${(ds.data() as Map<String, dynamic>)["title"]}',
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500)),
                                          const Divider(),
                                          Text(
                                              '${(ds.data() as Map<String, dynamic>)["overview"]}',
                                              maxLines: 3,
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w300)),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    });
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
        floatingActionButton: FloatingActionButton(
          backgroundColor:  const Color(0xff0B607E),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddArticle()),
            );
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
