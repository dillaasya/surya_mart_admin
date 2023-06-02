import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: Text('Customer members',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 16)),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var x = snapshot.data!.docs[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: x.data()['profilePicture'] == ''
                                  ? Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                          Icons.image_not_supported_outlined),
                                    )
                                  : Image.network(
                                      x.data()['profilePicture'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Text(
                                            'No Internet',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 6),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.orange.shade200,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Text(
                                      x.data()['displayName'],
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  x.data()['phone'] == ''
                                      ? '-'
                                      : x.data()['phone'],
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  'No customers registered yet!',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
                ),
              );
            }
          } else {
            return const Center(child: Text('Eror'));
          }
        },
      ),
    ));
  }
}
