import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text('My Reviews',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 16)),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('reviews')
              .orderBy('dateCreated', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            //print('nilai uid sekaang : ${Auth().currentUser!.uid}');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data!.docs.isNotEmpty) {
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                          height: 8,
                        ),
                        //padding: EdgeInsets.all(16),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var x = snapshot.data!.docs[index];

                          //DateTime dateReviewed = DateTime.parse(x['dateCreated'].toString());

                          return Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('users')
                                                  .where('uid',
                                                      isEqualTo: x['uid'])
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                } else if (snapshot
                                                        .connectionState ==
                                                    ConnectionState.active) {
                                                  var z =
                                                      snapshot.data!.docs.first;
                                                  return Text(
                                                    z['displayName'],
                                                    maxLines: 1,
                                                    overflow: TextOverflow.clip,
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  );
                                                } else {
                                                  return const Center(
                                                      child: Text(
                                                          'Something wrong'));
                                                }
                                              },
                                            ),
                                            Text(
                                              DateFormat.yMMMEd().format(
                                                x['dateCreated'].toDate(),
                                              ),
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ],
                                        ),
                                      ),
                                      RatingBar.builder(
                                        ignoreGestures: true,
                                        initialRating: x['rate'],
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 25,
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (double value) {
                                          null;
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black, //color of border
                                        width: 0.5, //width of border
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                x.data()['review'],
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Belum ada review',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
            } else {
              return const Text('eror');
            }
          },
        ),
      ),
    );
  }
}
