import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPage extends StatefulWidget {
  final String? idProduct;
  final String? category;
  final int? stockProduct;

  const DetailPage(
      {required this.idProduct,
      required this.stockProduct,
      required this.category,
      Key? key})
      : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int qty = 1;

  int stock = 0;
  int price = 0;
  int weight = 0;
  int shoppingCart = 0;
  String? name, description, image, idProduct;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff0B607E),
          title: Text('Product Detail',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, fontSize: 16)),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('products')
              .doc(widget.idProduct)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                var x = snapshot.data!.data();

                name = x?['name'];
                image = x?['image'];
                price = x?['price'];
                weight = x?['weight'];
                stock = x?['stock'];

                return SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width,
                              child: x?['image'] == null
                                  ? Icon(
                                    Icons.image_not_supported_outlined,
                                    size:
                                        MediaQuery.of(context).size.width *
                                            0.3,
                                  )
                                  : ClipRRect(
                                      child: Image.network(x?['image'] ?? '',
                                          fit: BoxFit.fill),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${x?['name']}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Rp ${x?['price']}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Category',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,

                                          ),
                                      maxLines: 1,
                                        overflow: TextOverflow.clip,
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(x?['category'],
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                          )),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 4,),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('Stock',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                          )),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text((x?['stock']).toString(),
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                          )),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 4,),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Weight',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                          )),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text('${x?['weight']} gr/ml',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Description',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ExpandableText(
                                  x?['description'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300,
                                  ),
                                  expandText: 'show more',
                                  collapseText: 'show less',
                                  maxLines: 5,
                                  linkColor: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                );
              } else {
                return const Text('Product doesnt exist');
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
