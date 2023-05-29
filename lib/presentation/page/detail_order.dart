import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailOrder extends StatefulWidget {
  final String idOrder;
  final bool isReviewed;
  final String status;
  final String idUser;
  final List<dynamic> listCart;

  const DetailOrder(
      {required this.idOrder,
      required this.isReviewed,
      required this.status,
      required this.idUser,
      required this.listCart,
      Key? key})
      : super(key: key);

  @override
  State<DetailOrder> createState() => _DetailOrderState();
}

class _DetailOrderState extends State<DetailOrder> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          title: Text(
            'Detail Order',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, color: Colors.black, fontSize: 16),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .doc(widget.idOrder)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              var x = snapshot.data;

              List z = x?['productItem'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 5, color:  Color(0xff0B607E)),
                        ),
                        color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20, top: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined),
                              Text(
                                'Alamat Pengiriman',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            x?['shippingAddress'],
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: z.length,
                            itemBuilder: (context, index) {
                              var y = z[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                            //color: Colors.grey.shade200,
                                            border: Border.all(
                                                width: 0.5, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: y['picture'] == null
                                              ? const Icon(Icons
                                                  .image_not_supported_outlined)
                                              : Image.network(y['picture']),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${y['productName']}',
                                                maxLines: 1,
                                                overflow: TextOverflow.clip,
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                'Rp ${y['price']} x${y['qty']}',
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Belanja',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  'Rp ${x?['totalPrice'].toString()}',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          )
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.credit_card_rounded),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                'Metode Pembayaran',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Expanded(
                              child: Text(
                            x?['paymentMethod'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.end,
                          )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  x!['isReviewed']
                      ? Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Theme(
                              data: ThemeData().copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(

                                iconColor: Colors.black,
                                expandedAlignment: Alignment.topLeft,
                                title: Text(
                                  'Ulasan',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16, bottom: 16),
                                    child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('reviews')
                                          .where('idOrder', isEqualTo: x.id)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        var x = snapshot.data?.docs.first;
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.active) {
                                          if (snapshot.data!.docs.isNotEmpty) {
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                RatingBar.builder(
                                                  ignoreGestures: true,
                                                  initialRating: x!['rate'],
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
                                                const SizedBox(height: 4,),
                                                Text(
                                                  x.data()['review'],
                                                  style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w300),
                                                  textAlign: TextAlign.justify,
                                                ),
                                              ],
                                            );
                                          } else {
                                            return const Text('review kosong');
                                          }
                                        } else {
                                          return const Text(
                                              'eror data produk item nya');
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              );
            } else {
              return const Text('eror riwayat order nya');
            }
          },
        ),
        bottomNavigationBar: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .doc(widget.idOrder)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data!['statusOrder'] == 'SUCCEED') {
                if (snapshot.data!['isReviewed'] == true) {
                  return const BottomAppBar(child: null);
                } else {
                  return BottomAppBar(
                      color: Colors.orangeAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Tidak ada ulasan',
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade800,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ));
                }
              } else {
                return const BottomAppBar(
                  child: null,
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
